FUNCTION z_ti_expences_distribution.
*"----------------------------------------------------------------------
*"*"Local interface:
*"  IMPORTING
*"     VALUE(XEXPGR) TYPE  ZTIEXPGR OPTIONAL
*"  TABLES
*"      XZTISCSDT STRUCTURE  ZTISCSDT OPTIONAL
*"      XZTISCSIT STRUCTURE  ZTISCSIT OPTIONAL
*"  CHANGING
*"     VALUE(XZTITCSK) LIKE  ZTITCSK STRUCTURE  ZTITCSK OPTIONAL
*"  EXCEPTIONS
*"      DISTRIBUTION_ERROR
*"----------------------------------------------------------------------
* 2015.10.12  신재호  [기능개선 99077] 적하보험 비용처리 시 유환/무환 PO
*                     섞여있으면 오류메세지 출력
*-----------------------------------------------------------------------
  DATA: l_line    TYPE   i.

*> Internal TABLE Define.
  DATA : BEGIN OF xreqno OCCURS 0,
         reqno    TYPE   ztireqno,
         iipno    TYPE   ztiiipno,
         amdsq    TYPE   ztiamseq,
         ebeln    TYPE   ztiebeln,
         END   OF xreqno.

*> Internal TABLE Define.
  DATA : BEGIN OF xebeln OCCURS 0,
         iipno    TYPE   ztiiipno,
         amdsq    TYPE   ztiamseq,
         ebeln    TYPE   ztiebeln,
         END   OF xebeln.

  DATA : BEGIN OF xiblno OCCURS 0,
         refno    TYPE   ztirefno,
         iblno    TYPE   ztiiblno,
         END   OF xiblno.

  DATA : BEGIN OF xiccno OCCURS 0,
         refno    TYPE   ztirefno,
         iccno    TYPE   ztiiccno,
         iccsq    TYPE   ztiiccsq,
         END   OF xiccno.

*> 전기종류.
  DATA : BEGIN OF xcscrt OCCURS 5,
         cscrt    TYPE   zticscrt,
         END   OF xcscrt.

*> 품목 Text.
  DATA : BEGIN OF xsgtxt OCCURS 5,
         icsno    TYPE   ztiicsno,
         amdsq    TYPE   ztiamdsq,
         saknr    TYPE   saknr,
*         ebeln    TYPE   ebeln,
*         ebelp    TYPE   ebelp,
         sgtxt    TYPE   sgtxt,
         END   OF xsgtxt.

  DATA : BEGIN OF xsgtxth OCCURS 5,
         sgtxt    TYPE   sgtxt,
         END   OF xsgtxth.

  DATA : taxdata     LIKE bapi_incinv_create_tax
                                    OCCURS 1 WITH HEADER LINE.
  DATA : xztiscsdt_t LIKE ztiscsdt  OCCURS 0 WITH HEADER LINE.
  DATA : xpokey      LIKE ztispokey OCCURS 0 WITH HEADER LINE.
  DATA : xekko       LIKE ekko      OCCURS 0 WITH HEADER LINE.
  DATA : xekpo       LIKE ekpo      OCCURS 0 WITH HEADER LINE.
  DATA : xztivrq02   LIKE ztivrq02  OCCURS 0 WITH HEADER LINE.
  DATA : xztivrq04   LIKE ztivrq04  OCCURS 0 WITH HEADER LINE.
  DATA : xztitrqk    LIKE ztitrqk   OCCURS 0 WITH HEADER LINE.
  DATA : xztislcit   LIKE ztisrqit  OCCURS 0 WITH HEADER LINE.
  DATA : xztisblit   LIKE ztisblit  OCCURS 0 WITH HEADER LINE.
  DATA : xztisccit   LIKE ztisccit  OCCURS 0 WITH HEADER LINE.
  DATA : xztistxit   LIKE ztistxit  OCCURS 0 WITH HEADER LINE.
  DATA : xztivtx01   LIKE ztivtx01  OCCURS 0 WITH HEADER LINE.
  DATA : xztitig06   LIKE ztitig06  OCCURS 0 WITH HEADER LINE.
*>
  DATA : xcsit       LIKE ztiscsit   OCCURS 0 WITH HEADER LINE.
  DATA : xcsit_f     LIKE ztiscsit   OCCURS 0 WITH HEADER LINE.
  DATA : xcsit_n     LIKE ztiscsit   OCCURS 0 WITH HEADER LINE.
  DATA : xcsit_v     LIKE ztiscsit   OCCURS 0 WITH HEADER LINE.

*>
  DATA : l_buzei     LIKE ztitcsd-buzei,
         ls_proj     LIKE proj,
         l_ins_chk   TYPE c,
         l_ztiscsdt  LIKE ztiscsdt.

  DATA : l_rate      TYPE f,
         l_subrc     LIKE sy-subrc,
         l_tabix     LIKE sy-tabix,
         l_count_n   LIKE sy-tabix,      ">무환건수 counter
         l_count_n1  LIKE sy-tabix,      ">무환건수 counter
         l_count_y   LIKE sy-tabix,      ">유환건수 counter
         l_count_y1  LIKE sy-tabix,      ">유환건수 counter
         l_count_v   LIKE sy-tabix,      ">VAT 건수 counter
         l_count_v1  LIKE sy-tabix,      ">VAT 건수 counter
         l_ebeln     TYPE ebeln,              ">P/O Number
         l_ebelp     TYPE ebelp,              ">P/O Number
         l_zekkn     TYPE dzekkn,             ">P/O Number
         l_check     TYPE c,                  ">P/O Number
         l_wrbtr_n   TYPE bapicurr_d,
         l_wrbtr_n1  TYPE bapicurr_d,
         l_wrbtr_y   TYPE bapicurr_d,
         l_wrbtr_y1  TYPE bapicurr_d,
         l_wmwst     TYPE bapicurr_d,
         l_fwbas     TYPE bapicurr_d,
         l_wrbtr     TYPE bapicurr_d,
         l_dmbtr     TYPE bapicurr_d,
         l_netwr     TYPE bapicurr_d.

  DATA : l_doc_check TYPE c.

  REFRESH: xztiscsdt.
  CLEAR: xztiscsdt.
*> 지정번호.
*  IF XZTITCSK-ZUONR IS INITIAL.
*  xztitcsk-zuonr = xztitcsk-xblnr.
*  ENDIF.

  DESCRIBE TABLE xztiscsit LINES g_line.
  IF g_line EQ 0.
    MESSAGE e852 RAISING distribution_error.
  ENDIF.

  IF xztitcsk-wrbtr IS INITIAL.
    MESSAGE e864 RAISING distribution_error.
  ENDIF.

*> 수입 IMG Setting.
  SELECT SINGLE *
    FROM ztitig00
   WHERE bukrs EQ xztitcsk-bukrs.
  IF sy-subrc NE 0.
    MESSAGE e035 WITH xztitcsk-bukrs RAISING distribution_error.
  ENDIF.

*> Get 비용코드.
  SELECT *
    INTO CORRESPONDING FIELDS OF TABLE xztitig06
    FROM ztitig06
   WHERE bukrs  EQ xztitcsk-bukrs.
  IF sy-subrc NE 0.
    MESSAGE e865 RAISING distribution_error.
  ENDIF.


**> 부가세 기표일 경우.
*  IF xztitcsk-wrbtr EQ xztitcsk-wmwst.
*    PERFORM build_vat_posting_data TABLES xztiscsdt
*                                          xztitig06
*                                          xztiscsit
*                                   USING  xztitcsk
*                                          xexpgr.
*
*    xztiscsit-cscrt = 'F'.
*    MODIFY xztiscsit TRANSPORTING cscrt WHERE cscrt <> 'F'.
*    EXIT.
*  ENDIF.
*  IF sy-uname EQ 'FIC09'.
*    BREAK-POINT.
*  ENDIF.
*
  CASE xexpgr.
*--------------------------------------------------------------
*> 수입의뢰/적하보험 ..
*--------------------------------------------------------------
    WHEN 'L' OR 'I'. ">수입의뢰 및 적하보험관련비용.
      CLEAR: l_ins_chk.
      IF xexpgr EQ 'L'.
*-----> 수입의뢰 헤더 조회.(수입의뢰일 경우)
        SELECT *
          INTO CORRESPONDING FIELDS OF TABLE xztivrq02
          FROM ztivrq02
           FOR ALL ENTRIES IN xztiscsit
         WHERE reqno  EQ  xztiscsit-refno
           AND amdsq  EQ  xztiscsit-amdsq.
        IF sy-subrc NE 0.
          MESSAGE e872 RAISING distribution_error.
        ENDIF.
      ELSEIF xexpgr EQ 'I'.
*-----> 수입의뢰 헤더 조회.(적하보험일 경우)
        SELECT reqno iipno amdsq ebeln
          INTO CORRESPONDING FIELDS OF TABLE xreqno
          FROM ztitip1
           FOR ALL ENTRIES IN xztiscsit
         WHERE iipno  EQ  xztiscsit-refno
           AND amdsq  EQ  xztiscsit-amdsq.
        IF sy-subrc NE 0.
          MESSAGE e852 RAISING distribution_error.
        ENDIF.

        REFRESH: xebeln.
        LOOP AT xreqno WHERE reqno IS INITIAL.
          g_tabix = sy-tabix.
          MOVE-CORRESPONDING xreqno TO xebeln.
          COLLECT xebeln.
          DELETE xreqno INDEX g_tabix.
        ENDLOOP.

*-----> 수입의뢰 헤더 조회.
        REFRESH: xztivrq02.
        SELECT *
          INTO CORRESPONDING FIELDS OF TABLE xztivrq02
          FROM ztivrq04
           FOR ALL ENTRIES IN xreqno
         WHERE reqno  EQ  xreqno-reqno.
        DESCRIBE TABLE xebeln LINES g_line.
        IF g_line GT 0.
          l_ins_chk = 'X'.
          SELECT *
            APPENDING CORRESPONDING FIELDS OF TABLE xztivrq02
            FROM ekpo
             FOR ALL ENTRIES IN xebeln
           WHERE ebeln  EQ  xebeln-ebeln.
        ENDIF.
      ENDIF.

*      IF l_ins_chk EQ 'X'.
*        SELECT *
*          INTO CORRESPONDING FIELDS OF TABLE xztislcit
*          FROM ekpo
*           FOR ALL ENTRIES IN xreqno
*         WHERE ebeln  EQ  xreqno-ebeln.
*      ELSE.
**-----> 수입의뢰 아이템 조회.
*        SELECT *
*          INTO CORRESPONDING FIELDS OF TABLE xztislcit
*          FROM ztivrq00 AS r INNER JOIN ekpo AS p
*            ON r~ebeln  EQ  p~ebeln
*           AND r~ebelp  EQ  p~ebelp
*           FOR ALL ENTRIES IN xztivrq02
*         WHERE r~reqno  EQ  xztivrq02-reqno
*           AND r~amdsq  EQ  xztivrq02-amdsq.
**        IF sy-subrc NE 0.
**          MESSAGE e872 RAISING distribution_error.
**        ENDIF.
*      ENDIF.
*-----> 수입의뢰 아이템 조회.
      SELECT *
        INTO CORRESPONDING FIELDS OF TABLE xztislcit
        FROM ztivrq00 AS r INNER JOIN ekpo AS p
          ON r~ebeln  EQ  p~ebeln
         AND r~ebelp  EQ  p~ebelp
         FOR ALL ENTRIES IN xztivrq02
       WHERE r~reqno  EQ  xztivrq02-reqno
         AND r~amdsq  EQ  xztivrq02-amdsq.

      DESCRIBE TABLE xebeln LINES l_line.
      IF l_line GT 0.
        SELECT *
          APPENDING CORRESPONDING FIELDS OF TABLE xztislcit
          FROM ekpo
           FOR ALL ENTRIES IN xebeln
         WHERE ebeln  EQ  xebeln-ebeln.

*       ELSE.
*        MESSAGE e877 RAISING distribution_error.
      ENDIF.

      IF xztislcit[] IS INITIAL.
        MESSAGE e877 RAISING distribution_error.
      ENDIF.


*> 유환/무환 문서를 구분하여 Counter함.
      REFRESH: xcsit, xcsit_f, xcsit_n, xcsit_v.
      CLEAR: l_count_n, l_count_y, l_count_v.
      CLEAR: l_wrbtr_n, l_wrbtr_y, l_wmwst, l_fwbas.
      LOOP AT xztiscsit.
        l_tabix = sy-tabix.
        CLEAR xztiscsit-cscrt.
*-----> .(수입의뢰일 경우)
        IF xexpgr EQ 'L'.
          READ TABLE xztivrq02 WITH KEY reqno = xztiscsit-refno
                                        amdsq = xztiscsit-amdsq.
*-----> .(적하보험일 경우)
        ELSEIF xexpgr EQ 'I'.
          READ TABLE  xreqno   WITH KEY iipno = xztiscsit-refno
                                        amdsq = xztiscsit-amdsq.
          IF sy-subrc EQ 0.
            READ TABLE xztivrq02 WITH KEY reqno = xreqno-reqno.
          ELSE.
            READ TABLE  xebeln   WITH KEY iipno = xztiscsit-refno
                                          amdsq = xztiscsit-amdsq.
            IF sy-subrc EQ 0.
              READ TABLE xztivrq02 WITH KEY ebeln = xebeln-ebeln.
            ENDIF.
          ENDIF.
        ENDIF.
*> 위탁자재일 경우 무환.
        IF sy-subrc EQ 0.
          IF xztivrq02-setyn EQ 'X'.
            ADD 1               TO l_count_n.
            ADD xztiscsit-wrbtr TO l_wrbtr_n.
            xztiscsit-cscrt = 'N'.
*> 무환문서만 temp internal table로 append함.
            MOVE-CORRESPONDING xztiscsit TO xcsit_n.
            APPEND xcsit_n.
          ELSE.
*-----> CHECK 유환 구매문서 품목.
            IF xztivrq02-reqno IS INITIAL.
              READ TABLE xztislcit WITH KEY ebeln = xztivrq02-ebeln
                                            reqno = space
                                            repos = 'X'.
            ELSE.
              READ TABLE xztislcit WITH KEY reqno = xztivrq02-reqno
                                            amdsq = xztivrq02-amdsq
                                            repos = 'X'.
            ENDIF.

            IF sy-subrc EQ 0.
              ADD 1                        TO l_count_y.
              ADD xztiscsit-wrbtr          TO l_wrbtr_y.
*> 유환문서만 temp internal table로 append함.
              MOVE-CORRESPONDING xztiscsit TO xcsit.
              APPEND xcsit.
            ELSE.
              ADD 1               TO l_count_n.
              ADD xztiscsit-wrbtr TO l_wrbtr_n.
              xztiscsit-cscrt = 'N'.
*> 무환문서만 temp internal table로 append함.
              MOVE-CORRESPONDING xztiscsit TO xcsit_n.
              APPEND xcsit_n.
            ENDIF.
          ENDIF.
        ENDIF.
        MODIFY xztiscsit INDEX l_tabix.
      ENDLOOP.

*> 무환건만 존재할 경우.
      IF l_count_y EQ 0.

****************************************************************
* 20071029 simcho by 황지희씨 적하보험료 처리시 에러
* 무환건만 있을 경우 수입개설 요청정보가 없을 것이므로 해당 구매오더
* 外 개설요청 정보는 삭제함
****************************************************************
        LOOP AT xztislcit.
          IF xztislcit-ebeln <> xebeln-ebeln.
            DELETE xztislcit.
          ENDIF.
        ENDLOOP.
****************************************************************

        PERFORM build_ap_posting_data  TABLES xztiscsdt
                                              xztitig06
                                              xztiscsit
                                              xztislcit
                                              xztisblit
                                              xztisccit
                                              xztistxit
                                       USING  xztitcsk
                                              xexpgr
                                              l_wrbtr_n.
        IF xztitcsk-wmwst EQ xztitcsk-wrbtr.
          xztiscsit-cscrt = 'V'.
          MODIFY xztiscsit TRANSPORTING cscrt WHERE cscrt <> 'V'.
        ELSE.
          xztiscsit-cscrt = 'F'.
          MODIFY xztiscsit TRANSPORTING cscrt WHERE cscrt <> 'F'.
        ENDIF.
        EXIT.
      ENDIF.

      LOOP AT xcsit.
        l_tabix = sy-tabix.
*-----> .(수입의뢰일 경우)
        IF xexpgr EQ 'L'.
          READ TABLE xztivrq02 WITH KEY reqno = xcsit-refno
                                        amdsq = xcsit-amdsq.
*-----> .(적하보험일 경우)
        ELSEIF xexpgr EQ 'I'.
          READ TABLE  xreqno   WITH KEY iipno = xcsit-refno
                                        amdsq = xcsit-amdsq.
          IF sy-subrc EQ 0.
            READ TABLE xztivrq02 WITH KEY reqno = xreqno-reqno.
          ELSE.
            READ TABLE  xebeln   WITH KEY iipno = xcsit-refno
                                          amdsq = xcsit-amdsq.
            IF sy-subrc EQ 0.
              READ TABLE xztivrq02 WITH KEY ebeln = xebeln-ebeln.
            ENDIF.
          ENDIF.
        ENDIF.

*> 단가 및 금액을 계산.(품목별 총합 계산)
        IF xztivrq02-reqno IS INITIAL.
          PERFORM  get_items_net_price_by_request TABLES xztitrqk
                                                         xztislcit
                                             USING  xztivrq02-reqno
                                                    xztivrq02-amdsq
                                                    xztivrq02-ebeln
                                                         l_netwr.
        ELSE.
          PERFORM  get_items_net_price_by_request TABLES xztitrqk
                                                         xztislcit
                                             USING  xztivrq02-reqno
                                                    xztivrq02-amdsq
                                                         space
                                                         l_netwr.
        ENDIF.
*> Items 배부.
        IF xztivrq02-reqno IS INITIAL.
          PERFORM  build_invoice_items_by_po    TABLES xztivrq02
                                                       xztislcit
                                                       xztiscsdt
                                                       xztitig06
                                                USING  xcsit
                                                       xztitcsk
                                                       l_netwr
                                                    xztivrq02-ebeln.
        ELSE.
          PERFORM  build_invoice_items_by_lc    TABLES xztivrq02
                                                       xztislcit
                                                       xztiscsdt
                                                       xztitig06
                                                USING  xcsit
                                                       xztitcsk
                                                       l_netwr
                                                    xztivrq02-reqno
                                                    xztivrq02-amdsq.
        ENDIF.
*> 전기가능여부 판단.
        PERFORM  check_posting_methods          TABLES xztiscsdt
                                                USING  xcsit.
*        BREAK-POINT.
        MODIFY xcsit INDEX l_tabix.

        READ TABLE xztiscsit WITH KEY icssq = xcsit-icssq.
        IF sy-subrc EQ 0.
          MOVE-CORRESPONDING  xcsit TO xztiscsit.
          MODIFY xztiscsit INDEX sy-tabix.
        ENDIF.
      ENDLOOP.


      CLEAR: l_count_n1, l_count_y1.

      IF ztitig00-pstmt EQ 'F' OR
         ztitig00-pstmt EQ 'B'.
        LOOP AT xztiscsdt.
          IF xztiscsdt-ebeln IS INITIAL.
            ADD 1               TO l_count_n1.
            ADD xztiscsdt-wrbtr TO l_wrbtr_n.
          ELSE.
            ADD 1               TO l_count_y1.
          ENDIF.
        ENDLOOP.
      ELSE.
        LOOP AT xztiscsdt.
          g_tabix = sy-tabix.
          IF xztiscsdt-itmst = '3' OR
             xztiscsdt-itmst = '4' OR
             xztiscsdt-itmst = '5'.
            ADD 1               TO l_count_n1.
            ADD xztiscsdt-wrbtr TO l_wrbtr_n.
            DELETE xztiscsdt INDEX g_tabix.
          ELSE.
            ADD 1               TO l_count_y1.
*             ADD xZTIscsdt-WRBTR TO l_wrbtr_Y
          ENDIF.
        ENDLOOP.
      ENDIF.
*> 무환건만 존재할 경우.
      IF l_count_y1 EQ 0.
        PERFORM build_ap_posting_data  TABLES xztiscsdt
                                              xztitig06
                                              xztiscsit
                                              xztislcit
                                              xztisblit
                                              xztisccit
                                              xztistxit
                                       USING  xztitcsk
                                              xexpgr
                                              l_wrbtr_n.
        IF xztitcsk-wmwst EQ xztitcsk-wrbtr.
          xztiscsit-cscrt = 'V'.
          MODIFY xztiscsit TRANSPORTING cscrt WHERE cscrt <> 'V'.
        ELSE.
          xztiscsit-cscrt = 'F'.
          MODIFY xztiscsit TRANSPORTING cscrt WHERE cscrt <> 'F'.
        ENDIF.
        EXIT.
      ENDIF.

*> 무환건이 존재할 경우 무환금액을 유환에 추가함..
      IF l_count_n1  NE 0 OR
         l_wrbtr_n   NE 0.
*********************************************************************
*-> 기능개선 99077 - 적하보험관련 비용 처리 시 유환/무환 PO가
*                    섞여있을 경우 오류메세지를 출력함_2015.10.12
*********************************************************************
        MESSAGE e949 RAISING distribution_error.          "추가
*        PERFORM add_no_draft_amount    TABLES xztiscsdt  "삭제
*                                              xztitig06
*                                              xcsit
*                                       USING  xztitcsk
*                                              ekkn
*                                              xexpgr
*                                              l_wrbtr_n
*                                              l_ebeln
*                                              l_ebelp
*                                              l_zekkn.
*-< 기능개선 99077
*********************************************************************
      ENDIF.

*--------------------------------------------------------------
*> B/L 비용 ..
*--------------------------------------------------------------
    WHEN 'B'. ">B/L 비용.

      REFRESH: xiblno.
      LOOP AT xztiscsit.
        SELECT SINGLE *
          FROM ztitblk
         WHERE iblno EQ xztiscsit-refno.
        IF ztitblk-bldty EQ 'S' AND
           NOT ztitblk-bblno IS INITIAL.
          xiblno-iblno = ztitblk-bblno.
        ELSE.
          xiblno-iblno = ztitblk-iblno.
        ENDIF.
        xiblno-refno = xztiscsit-refno.
        APPEND xiblno.
      ENDLOOP.

*      SELECT *
*        INTO CORRESPONDING FIELDS OF TABLE xztisblit
*        FROM ztivbl00
*         FOR ALL ENTRIES IN xztiscsit
*       WHERE iblno  EQ  xztiscsit-refno.
      SELECT *
        INTO CORRESPONDING FIELDS OF TABLE xztisblit
        FROM ztivbl00
         FOR ALL ENTRIES IN xiblno
       WHERE iblno  EQ  xiblno-iblno.
      IF sy-subrc NE 0.
        MESSAGE e852 RAISING distribution_error.
      ENDIF.

      LOOP AT xztisblit.
        l_tabix = sy-tabix.
        IF NOT xztisblit-ebeln IS INITIAL.
          SELECT SINGLE *
            INTO CORRESPONDING FIELDS OF xztisblit
            FROM ekpo
           WHERE ebeln EQ xztisblit-ebeln
             AND ebelp EQ xztisblit-ebelp.
        ELSE.
          CLEAR: xztisblit-repos.
        ENDIF.
        MODIFY xztisblit INDEX l_tabix.
      ENDLOOP.

*> 유환/무환 문서를 구분하여 Counter함.
      REFRESH: xcsit, xcsit_f.
      CLEAR: l_count_n, l_count_y.
      CLEAR: l_wrbtr_n, l_wrbtr_y.
      LOOP AT xztiscsit.
        l_tabix = sy-tabix.
        CLEAR xztiscsit-cscrt.

*-----> CHECK 유환 구매문서 품목.
*        READ TABLE xztisblit WITH KEY iblno = xztiscsit-refno
*                                      repos = 'X'.
*
        READ TABLE xiblno WITH KEY refno = xztiscsit-refno.
        IF sy-subrc EQ 0.
          READ TABLE xztisblit WITH KEY iblno = xiblno-iblno
                                        repos = 'X'.
        ENDIF.

        IF sy-subrc EQ 0.
          ADD 1                        TO l_count_y.
          ADD xztiscsit-wrbtr          TO l_wrbtr_y.
*> 유환문서만 temp internal table로 append함.
          MOVE-CORRESPONDING xztiscsit TO xcsit.
          APPEND xcsit.
        ELSE.

          ADD 1               TO l_count_n.
          ADD xztiscsit-wrbtr TO l_wrbtr_n.
          xztiscsit-cscrt = 'N'.
*> 무환문서만 temp internal table로 append함.
          MOVE-CORRESPONDING xztiscsit TO xcsit_n.
          APPEND xcsit_n.

        ENDIF.
        MODIFY xztiscsit INDEX l_tabix.
      ENDLOOP.

*> 무환건만 존재할 경우.
      IF l_count_y EQ 0.
        PERFORM build_ap_posting_data  TABLES xztiscsdt
                                              xztitig06
                                              xztiscsit
                                              xztislcit
                                              xztisblit
                                              xztisccit
                                              xztistxit
                                       USING  xztitcsk
                                              xexpgr
                                              l_wrbtr_n.
        IF xztitcsk-wmwst EQ xztitcsk-wrbtr.
          xztiscsit-cscrt = 'V'.
          MODIFY xztiscsit TRANSPORTING cscrt WHERE cscrt <> 'V'.
        ELSE.
          xztiscsit-cscrt = 'F'.
          MODIFY xztiscsit TRANSPORTING cscrt WHERE cscrt <> 'F'.
        ENDIF.
        EXIT.
      ENDIF.

      LOOP AT xcsit.
        l_tabix = sy-tabix.
        READ TABLE xiblno WITH KEY refno = xcsit-refno.
        IF sy-subrc EQ 0.
          READ TABLE xztisblit WITH KEY iblno = xiblno-iblno.
        ENDIF.

*> 단가 및 금액을 계산.(품목별 총합 계산)
        PERFORM  get_items_net_price_by_bl      TABLES xztisblit
                                                USING  xiblno-iblno
                                                       l_netwr.
*> Items 배부.
        PERFORM  build_invoice_items_by_bl      TABLES xztisblit
                                                       xztiscsdt
                                                       xztitig06
                                                USING  xcsit
                                                       xztitcsk
                                                       l_netwr
                                                       xiblno-iblno.
*> 전기가능여부 판단.
        PERFORM  check_posting_methods          TABLES xztiscsdt
                                                USING  xcsit.

        MODIFY xcsit INDEX l_tabix.

        READ TABLE xztiscsit WITH KEY icssq = xcsit-icssq.
        IF sy-subrc EQ 0.
          MOVE-CORRESPONDING  xcsit TO xztiscsit.
          MODIFY xztiscsit INDEX sy-tabix.
        ENDIF.
      ENDLOOP.

      CLEAR: l_count_n1, l_count_y1.
      IF ztitig00-pstmt EQ 'F' OR
         ztitig00-pstmt EQ 'B'.
        LOOP AT xztiscsdt.
          IF xztiscsdt-ebeln IS INITIAL.
            ADD 1               TO l_count_n1.
            ADD xztiscsdt-wrbtr TO l_wrbtr_n.
          ELSE.
            ADD 1               TO l_count_y1.
          ENDIF.
        ENDLOOP.
      ELSE.
        LOOP AT xztiscsdt.
          g_tabix = sy-tabix.
          IF xztiscsdt-itmst = '3' OR
             xztiscsdt-itmst = '4' OR
             xztiscsdt-itmst = '5'.
            ADD 1               TO l_count_n1.
            ADD xztiscsdt-wrbtr TO l_wrbtr_n.
            DELETE xztiscsdt INDEX g_tabix.
          ELSE.
            ADD 1               TO l_count_y1.
*             ADD xZTIscsdt-WRBTR TO l_wrbtr_Y
          ENDIF.
        ENDLOOP.
      ENDIF.

*> 무환건만 존재할 경우.
      IF l_count_y1 EQ 0.
        PERFORM build_ap_posting_data  TABLES xztiscsdt
                                              xztitig06
                                              xztiscsit
                                              xztislcit
                                              xztisblit
                                              xztisccit
                                              xztistxit
                                       USING  xztitcsk
                                              xexpgr
                                              l_wrbtr_n.
        IF xztitcsk-wmwst EQ xztitcsk-wrbtr.
          xztiscsit-cscrt = 'V'.
          MODIFY xztiscsit TRANSPORTING cscrt WHERE cscrt <> 'V'.
        ELSE.
          xztiscsit-cscrt = 'F'.
          MODIFY xztiscsit TRANSPORTING cscrt WHERE cscrt <> 'F'.
        ENDIF.
        EXIT.
      ENDIF.

*> 무환건이 존재할 경우 무환금액을 유환에 추가함..
      IF l_count_n1  NE 0 OR
         l_wrbtr_n   NE 0.
        PERFORM add_no_draft_amount    TABLES xztiscsdt
                                              xztitig06
                                              xcsit
                                       USING  xztitcsk
                                              ekkn
                                              xexpgr
                                              l_wrbtr_n
                                              l_ebeln
                                              l_ebelp
                                              l_zekkn.
      ENDIF.

*--------------------------------------------------------------
*> 통관비용 ..
*--------------------------------------------------------------
    WHEN 'C'. ">통관비용.

      REFRESH: xiccno.
      LOOP AT xztiscsit.
        SELECT SINGLE *
          FROM ztitcck
         WHERE iccno EQ xztiscsit-refno
           AND iccsq EQ xztiscsit-amdsq.

        IF NOT ztitcck-bblno IS INITIAL.
          SELECT *
            FROM ztitcck UP TO 1 ROWS
           WHERE iblno EQ ztitcck-bblno.
          ENDSELECT.

          IF sy-subrc EQ 0.
            xiccno-iccno = ztitcck-iccno.
            xiccno-iccsq = ztitcck-iccsq.
          ELSE.
            xiccno-iccno = xztiscsit-refno.
            xiccno-iccsq = xztiscsit-amdsq.
          ENDIF.
        ELSE.
          xiccno-iccno = xztiscsit-refno.
          xiccno-iccsq = xztiscsit-amdsq.
        ENDIF.

        xiccno-refno = xztiscsit-refno.
        APPEND xiccno.
      ENDLOOP.

*      SELECT *
*        INTO CORRESPONDING FIELDS OF TABLE xztisccit
*        FROM ztivcc00
*         FOR ALL ENTRIES IN xztiscsit
*       WHERE iccno  EQ  xztiscsit-refno
*         AND iccsq  EQ  xztiscsit-amdsq.
      SELECT *
        INTO CORRESPONDING FIELDS OF TABLE xztisccit
        FROM ztivcc00
         FOR ALL ENTRIES IN xiccno
       WHERE iccno  EQ  xiccno-iccno
         AND iccsq  EQ  xiccno-iccsq.

      IF sy-subrc NE 0.
        MESSAGE e852 RAISING distribution_error.
      ENDIF.

      LOOP AT xztisccit.
        l_tabix = sy-tabix.
        IF NOT xztisccit-ebeln IS INITIAL.
          SELECT SINGLE *
            INTO CORRESPONDING FIELDS OF xztisccit
            FROM ekpo
           WHERE ebeln EQ xztisccit-ebeln
             AND ebelp EQ xztisccit-ebelp.
        ELSE.
          CLEAR: xztisccit-repos.
        ENDIF.
        MODIFY xztisccit INDEX l_tabix.
      ENDLOOP.

*> 유환/무환 문서를 구분하여 Counter함.
      REFRESH: xcsit, xcsit_f, xcsit_n, xcsit_v.
      CLEAR: l_count_n, l_count_y, l_count_v.
      CLEAR: l_wrbtr_n, l_wrbtr_y, l_wmwst, l_fwbas.
      LOOP AT xztiscsit.
        l_tabix = sy-tabix.
        CLEAR xztiscsit-cscrt.
*-----> VAT만 있을 경우.
        IF xztiscsit-wrbtr IS INITIAL AND
           NOT xztiscsit-wmwst IS INITIAL.
          ADD 1                        TO l_count_v.
          ADD xztiscsit-wmwst          TO l_wmwst.
          ADD xztiscsit-fwbas          TO l_fwbas.
*> 유환문서만 temp internal table로 append함.
          MOVE-CORRESPONDING xztiscsit TO xcsit_v.
          APPEND xcsit_v.
        ELSE.
*-----> CHECK 유환 구매문서 품목.
*          READ TABLE xztisccit WITH KEY iccno = xztiscsit-refno
*                                        repos = 'X'.
          READ TABLE xiccno WITH KEY refno = xztiscsit-refno.
          IF sy-subrc EQ 0.
            READ TABLE xztisccit WITH KEY iccno = xiccno-iccno
                                          repos = 'X'.
          ENDIF.
          IF sy-subrc EQ 0.
            ADD 1                        TO l_count_y.
            ADD xztiscsit-wrbtr          TO l_wrbtr_y.
*> 유환문서만 temp internal table로 append함.
            MOVE-CORRESPONDING xztiscsit TO xcsit.
            APPEND xcsit.
          ELSE.

            ADD 1               TO l_count_n.
            ADD xztiscsit-wrbtr TO l_wrbtr_n.
            xztiscsit-cscrt = 'N'.
*> 무환문서만 temp internal table로 append함.
            MOVE-CORRESPONDING xztiscsit TO xcsit_n.
            APPEND xcsit_n.
          ENDIF.
        ENDIF.
        MODIFY xztiscsit INDEX l_tabix.
      ENDLOOP.

*> 무환건만 존재할 경우.
      IF l_count_y EQ 0 AND
         l_count_n GT 0.
        PERFORM build_ap_posting_data  TABLES xztiscsdt
                                              xztitig06
                                              xztiscsit
                                              xztislcit
                                              xztisblit
                                              xztisccit
                                              xztistxit
                                       USING  xztitcsk
                                              xexpgr
                                              l_wrbtr_n.
        IF xztitcsk-wmwst EQ xztitcsk-wrbtr.
          xztiscsit-cscrt = 'V'.
          MODIFY xztiscsit TRANSPORTING cscrt WHERE cscrt <> 'V'.
        ELSE.
          xztiscsit-cscrt = 'F'.
          MODIFY xztiscsit TRANSPORTING cscrt WHERE cscrt <> 'F'.
        ENDIF.
        EXIT.
      ENDIF.

      LOOP AT xcsit.
        l_tabix = sy-tabix.
*        READ TABLE xztisccit WITH KEY iccno = xcsit-refno.
        READ TABLE xiccno WITH KEY refno = xcsit-refno.
        IF sy-subrc EQ 0.
          READ TABLE xztisccit WITH KEY iccno = xiccno-iccno
                                        repos = 'X'.
        ENDIF.
*> 단가 및 금액을 계산.(품목별 총합 계산)
        PERFORM  get_items_net_price_by_cc      TABLES xztisccit
                                                USING  xiccno-iccno
                                                       l_netwr.
*> Items 배부.
        PERFORM  build_invoice_items_by_cc      TABLES xztisccit
                                                       xztiscsdt
                                                       xztitig06
                                                USING  xcsit
                                                       xztitcsk
                                                       l_netwr
                                                       xiccno-iccno.
*> 전기가능여부 판단.
        PERFORM  check_posting_methods          TABLES xztiscsdt
                                                USING  xcsit.

        MODIFY xcsit INDEX l_tabix.

        READ TABLE xztiscsit WITH KEY icssq = xcsit-icssq.
        IF sy-subrc EQ 0.
          MOVE-CORRESPONDING  xcsit TO xztiscsit.
          MODIFY xztiscsit INDEX sy-tabix.
        ENDIF.
      ENDLOOP.

      CLEAR: l_count_n1, l_count_y1.
      IF ztitig00-pstmt EQ 'F' OR
         ztitig00-pstmt EQ 'B'.
        LOOP AT xztiscsdt.
          IF xztiscsdt-ebeln IS INITIAL.
            ADD 1               TO l_count_n1.
            ADD xztiscsdt-wrbtr TO l_wrbtr_n.
          ELSE.
            ADD 1               TO l_count_y1.
          ENDIF.
        ENDLOOP.
      ELSE.
        LOOP AT xztiscsdt.
          g_tabix = sy-tabix.
          IF xztiscsdt-itmst = '3' OR
             xztiscsdt-itmst = '4' OR
             xztiscsdt-itmst = '5'.
            ADD 1               TO l_count_n1.
            ADD xztiscsdt-wrbtr TO l_wrbtr_n.
            DELETE xztiscsdt INDEX g_tabix.
          ELSE.
            ADD 1               TO l_count_y1.
*             ADD xZTIscsdt-WRBTR TO l_wrbtr_Y
          ENDIF.
        ENDLOOP.
      ENDIF.

*> 무환건만 존재할 경우.
      IF l_count_y1 EQ 0.
        PERFORM build_ap_posting_data  TABLES xztiscsdt
                                              xztitig06
                                              xztiscsit
                                              xztislcit
                                              xztisblit
                                              xztisccit
                                              xztistxit
                                       USING  xztitcsk
                                              xexpgr
                                              l_wrbtr_n.
        IF xztitcsk-wmwst EQ xztitcsk-wrbtr.
          xztiscsit-cscrt = 'V'.
          MODIFY xztiscsit TRANSPORTING cscrt WHERE cscrt <> 'V'.
        ELSE.
          xztiscsit-cscrt = 'F'.
          MODIFY xztiscsit TRANSPORTING cscrt WHERE cscrt <> 'F'.
        ENDIF.
        EXIT.
      ENDIF.

*> 무환건이 존재할 경우 무환금액을 유환에 추가함..
      IF l_count_n1  NE 0 OR
         l_wrbtr_n   NE 0.
        PERFORM add_no_draft_amount    TABLES xztiscsdt
                                              xztitig06
                                              xcsit
                                       USING  xztitcsk
                                              ekkn
                                              xexpgr
                                              l_wrbtr_n
                                              l_ebeln
                                              l_ebelp
                                              l_zekkn.
      ENDIF.

*--------------------------------------------------------------
*> 관세전가액..
*--------------------------------------------------------------
    WHEN 'T'. ">관세전가액.
      SELECT *
        INTO CORRESPONDING FIELDS OF TABLE xztistxit
        FROM ztittxp
         FOR ALL ENTRIES IN xztiscsit
       WHERE taxno  EQ  xztiscsit-refno.
      IF sy-subrc NE 0.
        MESSAGE e852 RAISING distribution_error.
      ENDIF.

      SELECT *
        INTO CORRESPONDING FIELDS OF TABLE xztivtx01
        FROM ztivtx01
         FOR ALL ENTRIES IN xztiscsit
       WHERE taxno  EQ  xztiscsit-refno.

      LOOP AT xztistxit.
        l_tabix = sy-tabix.
        IF NOT xztistxit-ebeln IS INITIAL.
          SELECT SINGLE *
            INTO CORRESPONDING FIELDS OF xztistxit
            FROM ekpo
           WHERE ebeln EQ xztistxit-ebeln
             AND ebelp EQ xztistxit-ebelp.
        ELSE.
          CLEAR: xztistxit-repos.
        ENDIF.
        MODIFY xztistxit INDEX l_tabix.
      ENDLOOP.

      LOOP AT xztivtx01.
        l_tabix = sy-tabix.
        IF NOT xztivtx01-ebeln IS INITIAL.
          SELECT SINGLE *
            INTO CORRESPONDING FIELDS OF xztivtx01
            FROM ekpo
           WHERE ebeln EQ xztivtx01-ebeln
             AND ebelp EQ xztivtx01-ebelp.
        ELSE.
          CLEAR: xztivtx01-repos.
        ENDIF.
        MODIFY xztivtx01 INDEX l_tabix.
      ENDLOOP.


*> 유환/무환 문서를 구분하여 Counter함.
      REFRESH: xcsit, xcsit_f.
      CLEAR: l_count_n, l_count_y.
      CLEAR: l_wrbtr_n, l_wrbtr_y.
      LOOP AT xztiscsit.
        l_tabix = sy-tabix.
        CLEAR xztiscsit-cscrt.

*-----> CHECK 유환 구매문서 품목.
        READ TABLE xztistxit WITH KEY taxno = xztiscsit-refno
                                      repos = 'X'.

        IF sy-subrc EQ 0.
          ADD 1                        TO l_count_y.
          ADD xztiscsit-wrbtr          TO l_wrbtr_y.
*> 유환문서만 temp internal table로 append함.
          MOVE-CORRESPONDING xztiscsit TO xcsit.
          APPEND xcsit.
        ELSE.

          ADD 1               TO l_count_n.
          ADD xztiscsit-wrbtr TO l_wrbtr_n.
          xztiscsit-cscrt = 'N'.
*> 무환문서만 temp internal table로 append함.
          MOVE-CORRESPONDING xztiscsit TO xcsit_n.
          APPEND xcsit_n.

        ENDIF.
        MODIFY xztiscsit INDEX l_tabix.
      ENDLOOP.

*> 무환건만 존재할 경우.
      IF l_count_y EQ 0.
        PERFORM build_ap_posting_data  TABLES xztiscsdt
                                              xztitig06
                                              xztiscsit
                                              xztislcit
                                              xztisblit
                                              xztisccit
                                              xztistxit
                                       USING  xztitcsk
                                              xexpgr
                                              l_wrbtr_n.
        IF xztitcsk-wmwst EQ xztitcsk-wrbtr.
          xztiscsit-cscrt = 'V'.
          MODIFY xztiscsit TRANSPORTING cscrt WHERE cscrt <> 'V'.
        ELSE.
          xztiscsit-cscrt = 'F'.
          MODIFY xztiscsit TRANSPORTING cscrt WHERE cscrt <> 'F'.
        ENDIF.
        EXIT.
      ENDIF.

      LOOP AT xcsit.
        l_tabix = sy-tabix.
        READ TABLE xztistxit WITH KEY taxno = xcsit-refno.
**> 단가 및 금액을 계산.(품목별 총합 계산)
*        PERFORM  get_items_net_price_by_tx      TABLES xztistxit
*                                                USING  xcsit-taxno
*                                                       l_netwr.
**> Items 배부.
*        PERFORM  build_invoice_items_by_tx      TABLES xztistxit
*                                                       xztiscsdt
*                                                       xztitig06
*                                                USING  xcsit
*                                                       xztitcsk
*                                                       l_netwr
*                                                       xcsit-taxno.
*> Items 배부.
        PERFORM  build_invoice_items_by_tx1     TABLES xztivtx01
                                                       xztiscsdt
                                                       xztitig06
                                                USING  xcsit
                                                       xztitcsk
                                                       l_netwr
                                                       xcsit-taxno.

*> 전기가능여부 판단.
        PERFORM  check_posting_methods          TABLES xztiscsdt
                                                USING  xcsit.

        MODIFY xcsit INDEX l_tabix.

        READ TABLE xztiscsit WITH KEY icssq = xcsit-icssq.
        IF sy-subrc EQ 0.
          MOVE-CORRESPONDING  xcsit TO xztiscsit.
          MODIFY xztiscsit INDEX sy-tabix.
        ENDIF.
      ENDLOOP.

      CLEAR: l_count_n1, l_count_y1.
      IF ztitig00-pstmt EQ 'F' OR
         ztitig00-pstmt EQ 'B'.
        LOOP AT xztiscsdt.
          IF xztiscsdt-ebeln IS INITIAL.
            ADD 1               TO l_count_n1.
            ADD xztiscsdt-wrbtr TO l_wrbtr_n.
          ELSE.
            ADD 1               TO l_count_y1.
          ENDIF.
        ENDLOOP.
      ELSE.
        LOOP AT xztiscsdt.
          g_tabix = sy-tabix.
          IF xztiscsdt-itmst = '3' OR
             xztiscsdt-itmst = '4' OR
             xztiscsdt-itmst = '5'.
            ADD 1               TO l_count_n1.
            ADD xztiscsdt-wrbtr TO l_wrbtr_n.
            DELETE xztiscsdt INDEX g_tabix.
          ELSE.
            ADD 1               TO l_count_y1.
*             ADD xZTIscsdt-WRBTR TO l_wrbtr_Y
          ENDIF.
        ENDLOOP.
      ENDIF.
*> 무환건만 존재할 경우.
      IF l_count_y1 EQ 0.
        PERFORM build_ap_posting_data  TABLES xztiscsdt
                                              xztitig06
                                              xztiscsit
                                              xztislcit
                                              xztisblit
                                              xztisccit
                                              xztistxit
                                       USING  xztitcsk
                                              xexpgr
                                              l_wrbtr_n.
        IF xztitcsk-wmwst EQ xztitcsk-wrbtr.
          xztiscsit-cscrt = 'V'.
          MODIFY xztiscsit TRANSPORTING cscrt WHERE cscrt <> 'V'.
        ELSE.
          xztiscsit-cscrt = 'F'.
          MODIFY xztiscsit TRANSPORTING cscrt WHERE cscrt <> 'F'.
        ENDIF.
        EXIT.
      ENDIF.

*> 무환건이 존재할 경우 무환금액을 유환에 추가함..
      IF l_count_n1  NE 0 OR
         l_wrbtr_n   NE 0.
        PERFORM add_no_draft_amount    TABLES xztiscsdt
                                              xztitig06
                                              xcsit
                                       USING  xztitcsk
                                              ekkn
                                              xexpgr
                                              l_wrbtr_n
                                              l_ebeln
                                              l_ebelp
                                              l_zekkn.
      ENDIF.

*--------------------------------------------------------------
*> 기타 비용 ..
*--------------------------------------------------------------
    WHEN OTHERS.
      MESSAGE e853 WITH xexpgr RAISING distribution_error.
  ENDCASE.

  CLEAR: xztiscsdt.
  LOOP AT xcsit_v.
    xztiscsdt-wrbtr = xztiscsdt-wrbtr + xcsit_v-wrbtr.
    xztiscsdt-dmbtr = xztiscsdt-dmbtr + xcsit_v-dmbtr.
    xztiscsdt-wmwst = xztiscsdt-wmwst + xcsit_v-wmwst.
    xztiscsdt-fwbas = xztiscsdt-fwbas + xcsit_v-fwbas.

    MOVE: 999             TO xztiscsdt-buzei,
          '40'            TO xztiscsdt-bschl,
          xexpgr          TO xztiscsdt-expgr,
          'S'             TO xztiscsdt-koart,
          xcsit_v-mwskz   TO xztiscsdt-mwskz,
          'S'             TO xztiscsdt-shkzg,
*        xztitcsk-wmwst  TO xztiscsdt-wrbtr,
*        xZTITCSK-wmwst TO xZTIscsdt-wmwst,
*        0               TO xZTIscsdt-wmwst,
*        xztitcsk-wmwst  TO xztiscsdt-dmbtr,
*        0               TO xZTIscsdt-fwbas,
*        xztitcsk-fwbas TO xztiscsdt-fwbas,

          xcsit_v-kostl   TO xztiscsdt-kostl,
          xcsit_v-prctr   TO xztiscsdt-prctr,
          xcsit_v-pspnr   TO xztiscsdt-pspnr,
          xztitcsk-bupla  TO xztiscsdt-bupla,
          xztitcsk-gsber  TO xztiscsdt-gsber,
          xcsit_v-sgtxt   TO xztiscsdt-sgtxt,
          xcsit_v-zuonr   TO xztiscsdt-zuonr,
*          xcsit_v-xref1   TO xztiscsdt-xref1,
*          xcsit_v-xref2   TO xztiscsdt-xref2,
*          xcsit_v-xref3   TO xztiscsdt-xref3,
*
          xcsit_v-refno   TO xztiscsdt-refno,
          xcsit_v-amdsq   TO xztiscsdt-amdsq,
          xcsit_v-expcd   TO xztiscsdt-expcd,
          xcsit_v-icssq   TO xztiscsdt-icssq,
          xcsit_v-bukrs   TO xztiscsdt-bukrs,
          xcsit_v-icsno   TO xztiscsdt-icsno,
          sy-mandt        TO xztiscsdt-mandt,
          xcsit_v-saknr   TO xztiscsdt-saknr,
          'V'             TO xztiscsdt-itmst,
          sy-uname        TO xztiscsdt-cnam,
          sy-datlo        TO xztiscsdt-cdat,
          sy-timlo        TO xztiscsdt-ctme,
          sy-uname        TO xztiscsdt-unam,
          sy-datlo        TO xztiscsdt-udat,
          sy-timlo        TO xztiscsdt-utme.
  ENDLOOP.
  IF sy-subrc EQ 0.
    APPEND xztiscsdt.
  ELSE.
    LOOP AT xztiscsdt INTO xztiscsdt_t WHERE wmwst GT 0.
      taxdata-tax_code        = xztiscsdt_t-mwskz. "부가가치세코드
      taxdata-tax_amount      = xztiscsdt_t-wmwst. "전표통화세액
      taxdata-tax_base_amount = xztiscsdt_t-fwbas. "문서통화 과세표준액
      COLLECT taxdata.
    ENDLOOP.

    READ TABLE xztitig06 WITH KEY expgr = 'V'.
    IF sy-subrc NE 0.
      MESSAGE e868 RAISING distribution_error.
    ELSE.
      IF xztitig06-saknr IS INITIAL.
        MESSAGE e868 RAISING distribution_error.
      ENDIF.
    ENDIF.

    LOOP AT taxdata.
      CLEAR: xztiscsdt.
      READ TABLE xztiscsdt INTO xztiscsdt_t
                           WITH KEY mwskz = taxdata-tax_code.
      MOVE: 999                     TO xztiscsdt-buzei,
            '40'                    TO xztiscsdt-bschl,
            xexpgr                  TO xztiscsdt-expgr,
            'S'                     TO xztiscsdt-koart,
            taxdata-tax_code        TO xztiscsdt-mwskz,
            'S'                     TO xztiscsdt-shkzg,
            taxdata-tax_amount      TO xztiscsdt-wrbtr,
            taxdata-tax_amount      TO xztiscsdt-dmbtr,
            taxdata-tax_amount      TO xztiscsdt-wmwst,
            taxdata-tax_base_amount TO xztiscsdt-fwbas,
            xztiscsdt_t-kostl       TO xztiscsdt-kostl,
            xztiscsdt_t-prctr       TO xztiscsdt-prctr,
            xztiscsdt_t-pspnr       TO xztiscsdt-pspnr,
            xztiscsdt_t-bupla       TO xztiscsdt-bupla,
            xztiscsdt_t-gsber       TO xztiscsdt-gsber,
            xztiscsdt_t-sgtxt       TO xztiscsdt-sgtxt,
            xztiscsdt_t-zuonr       TO xztiscsdt-zuonr,
*            xztiscsdt_t-xref1       TO xztiscsdt-xref1,
*            xztiscsdt_t-xref2       TO xztiscsdt-xref2,
*            xztiscsdt_t-xref3       TO xztiscsdt-xref3,
            xztiscsdt_t-refno       TO xztiscsdt-refno,
            xztiscsdt_t-amdsq       TO xztiscsdt-amdsq,
            xztiscsdt_t-expcd       TO xztiscsdt-expcd,
            xztiscsdt_t-icssq       TO xztiscsdt-icssq,
            xztiscsdt_t-bukrs       TO xztiscsdt-bukrs,
            xztiscsdt_t-icsno       TO xztiscsdt-icsno,
            sy-mandt                TO xztiscsdt-mandt,
            xztitig06-saknr         TO xztiscsdt-saknr,
            'V'                     TO xztiscsdt-itmst,
            sy-uname                TO xztiscsdt-cnam,
            sy-datlo                TO xztiscsdt-cdat,
            sy-timlo                TO xztiscsdt-ctme,
            sy-uname                TO xztiscsdt-unam,
            sy-datlo                TO xztiscsdt-udat,
            sy-timlo                TO xztiscsdt-utme.

      APPEND xztiscsdt.
    ENDLOOP.

*    MOVE: 999             TO xztiscsdt-buzei,
*          '40'            TO xztiscsdt-bschl,
*          xexpgr          TO xztiscsdt-expgr,
*          'S'             TO xztiscsdt-koart,
*          XZTITCSK-mwskz  TO xztiscsdt-mwskz,
*          'S'             TO xztiscsdt-shkzg,
**        xztitcsk-wmwst  TO xztiscsdt-wrbtr,
**        xZTITCSK-wmwst TO xZTIscsdt-wmwst,
**        0               TO xZTIscsdt-wmwst,
**        xztitcsk-wmwst  TO xztiscsdt-dmbtr,
**        0               TO xZTIscsdt-fwbas,
**        xztitcsk-fwbas TO xztiscsdt-fwbas,
*
*          xcsit_v-kostl   TO xztiscsdt-kostl,
*          xcsit_v-prctr   TO xztiscsdt-prctr,
*          xcsit_v-pspnr   TO xztiscsdt-pspnr,
*          xztitcsk-bupla  TO xztiscsdt-bupla,
*          xztitcsk-gsber  TO xztiscsdt-gsber,
*          xcsit_v-sgtxt   TO xztiscsdt-sgtxt,
*          xcsit_v-zuonr   TO xztiscsdt-zuonr,
*          xcsit_v-refno   TO xztiscsdt-refno,
*          xcsit_v-amdsq   TO xztiscsdt-amdsq,
*          xcsit_v-expcd   TO xztiscsdt-expcd,
*          xcsit_v-icssq   TO xztiscsdt-icssq,
*          xcsit_v-bukrs   TO xztiscsdt-bukrs,
*          xcsit_v-icsno   TO xztiscsdt-icsno,
*          sy-mandt        TO xztiscsdt-mandt,
*          xcsit_v-saknr   TO xztiscsdt-saknr,
*          'V'             TO xztiscsdt-itmst,
*          sy-uname        TO xztiscsdt-cnam,
*          sy-datlo        TO xztiscsdt-cdat,
*          sy-timlo        TO xztiscsdt-ctme,
*          sy-uname        TO xztiscsdt-unam,
*          sy-datlo        TO xztiscsdt-udat,
*          sy-timlo        TO xztiscsdt-utme.
  ENDIF.

**> 계정결정이 평가클래스일 경우.
*  IF ZTITIG00-ACDTM EQ 'V'.
*    SELECT *
*      INTO CORRESPONDING FIELDS OF TABLE
*
*  ENDIF.
*
*> 같은 항목별로 Summary.  REFRESH: xZTIscsdt_t, xsgtxt.
  LOOP AT xztiscsdt.
    g_tabix = sy-tabix.

    IF xztiscsdt-ebeln IS INITIAL.
      MOVE-CORRESPONDING xztiscsdt TO xztiscsdt_t.
      COLLECT xztiscsdt_t.
    ELSE.
      READ TABLE xztiscsdt_t INTO l_ztiscsdt
                             WITH KEY ebeln = xztiscsdt-ebeln
                                      ebelp = xztiscsdt-ebelp.
      IF sy-subrc EQ 0.
        l_ztiscsdt-wrbtr = l_ztiscsdt-wrbtr + xztiscsdt-wrbtr.
        l_ztiscsdt-dmbtr = l_ztiscsdt-dmbtr + xztiscsdt-dmbtr.
        l_ztiscsdt-wmwst = l_ztiscsdt-wmwst + xztiscsdt-wmwst.
        l_ztiscsdt-fwbas = l_ztiscsdt-fwbas + xztiscsdt-fwbas.
        MODIFY xztiscsdt_t FROM l_ztiscsdt INDEX sy-tabix.
      ELSE.
        MOVE-CORRESPONDING xztiscsdt TO xztiscsdt_t.
        COLLECT xztiscsdt_t.
      ENDIF.
    ENDIF.
  ENDLOOP.

**> Items Text collect
*  LOOP AT xztiscsit.
*    MOVE-CORRESPONDING : xztiscsit TO xsgtxt,
*                         xztiscsit TO xsgtxth.
*    MOVE xztitcsk-icsno         TO xsgtxt-icsno.
*    COLLECT : xsgtxt, xsgtxth.
*  ENDLOOP.
**> Items Text
*  LOOP AT xztiscsdt_t.
*    CLEAR: xztiscsdt_t-sgtxt.
*    LOOP AT xsgtxt WHERE icsno = xztiscsdt_t-icsno
*                     AND amdsq = xztiscsdt_t-amdsq
*                     AND saknr = xztiscsdt_t-saknr.
*      IF xztiscsdt_t-sgtxt IS INITIAL.
*        xztiscsdt_t-sgtxt = xsgtxt-sgtxt.
*      ELSE.
*        CONCATENATE  xztiscsdt_t-sgtxt xsgtxt-sgtxt
*                     INTO xztiscsdt_t-sgtxt
*                     SEPARATED BY '/'.
*      ENDIF.
*    ENDLOOP.
**    IF  xztiscsdt_t-itmst EQ '5'.
**      CLEAR: xztiscsdt_t-wmwst.
**    ENDIF.
*    MODIFY xztiscsdt_t.
*  ENDLOOP.
*> Header Text.
*  CLEAR: xZTITCSK-sgtxt.
*  IF xztitcsk-sgtxt IS INITIAL.
*    LOOP AT xsgtxth.
*      IF xztitcsk-sgtxt IS INITIAL.
*        xztitcsk-sgtxt = xsgtxth-sgtxt.
*      ELSE.
*        CONCATENATE  xztitcsk-sgtxt xsgtxth-sgtxt
*                     INTO xztitcsk-sgtxt
*                     SEPARATED BY '/'.
*      ENDIF.
*    ENDLOOP.
*  ENDIF.

*  xztiscsdt[] = xztiscsdt_t[].

  IF ztitig00-pstmt EQ 'F'.
    PERFORM  build_ap_line_data  TABLES  xztiscsdt
                                         xztiscsit
                                 USING   xztitcsk
                                         xexpgr.
    xztitcsk-ptdcl = 'F'.
  ELSEIF ztitig00-pstmt EQ 'M'.
    xztitcsk-ptdcl = 'M'.
  ELSE.
    IF xztitcsk-ptdcl EQ 'F' OR
       xztitcsk-ptdcl EQ 'V'.
      PERFORM  build_ap_line_data  TABLES  xztiscsdt
                                           xztiscsit
                                   USING   xztitcsk
                                           xexpgr.
    ENDIF.
  ENDIF.
  xztitcsk-dstrb = 'D'.

  SORT xztiscsdt BY buzei.

  g_count = 0.
  LOOP AT xztiscsdt.
    ADD 1 TO g_count.
    xztiscsdt-buzei = g_count.

    MODIFY xztiscsdt.
  ENDLOOP.

ENDFUNCTION.
