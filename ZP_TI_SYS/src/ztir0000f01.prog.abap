************************************************************************
* Title         :  ZTIR0000F01                                         *
*                                                                      *
* Description   : 수입 L/C 관리 Subroutine Include                     *
*                                                                      *
* Creation Date : 2003/07/11                                           *
*                                                                      *
* Author        : SeogBong, Kang                                       *
*                 Copyright ⓒ ASEG Co., LTD. All rights reserved.     *
*----------------------------------------------------------------------*
*                M O D I F I C A T I O N   L O G                       *
*----------------------------------------------------------------------*
* Date         Programmer       Transport#  Description                *
*----------------------------------------------------------------------*
* 20090610       MMB03                     C20090611_71632             *
*                                         : 사후송금 process개선       *
* 20101013       MMB03                    C20100928_44287              *
*                                         : EDI문서 등 개선            *
* 20101223       MMB03                    C20101203_84253              *
*                                         : 오류문구 수정처리          *
* 20110215       MMB03                    C20110118_09237              *
*                                         : 공급자대표자명 오류수정    *
* 2011/04/23   FIB05            [제목] TT개설요청접수시_EDI내역check   *
*                               [CSR_NO] C20110323_48869               *
* 2014/02/20   FIB03            [제목] 지급조건 BU36인 경우 EDI문서상  *
*                               텍스트 항목 하드코딩                   *
*                               [CSR_NO] 11083                         *
* 2014/02/26    ZLSGMM          V001: EDI문서의 제시일자 변경          *
*                               [CSR_NO] 2014022100035                 *
* 2014/04/08    ZLSGMM          EDI문서 플랜트 도로명 주소로 변경      *
*                               [CSR_NO] 2014040300032                 *
* 2014/08/25    MMB04          구매승인서 생성시 오류 수정      *
*                               [CSR_NO] 41377                 *
* 2014/10/06    MMB04          사후송금 개설요청시 최신송장정보 업데이트
*                               [CSR_NO] 44036                  *
* 2022/03/02    이원형          메일전송 기능 추가 요청 건
*                               [CSR_NO] CHM2202-00131
*
************************************************************************

*&---------------------------------------------------------------------*
*&      Form  append_po_items
*&---------------------------------------------------------------------*
 FORM APPEND_PO_ITEMS  USING    P_LINE
                                P_UCOMM   LIKE SY-UCOMM.
*> 위탁자재일 경우 추가버튼 기능 disable.
   IF ZTITRQS-SETYN EQ C_TRUE.
     MESSAGE S033.    EXIT.
   ENDIF.

   REFRESH: IT_POKEY.
*> 이전 레코드 갯수.
   DESCRIBE TABLE IT_TAB LINES G_COUNT.

   CALL FUNCTION 'Z_TI_FOR_APPEND_PO_NUMBER'
     EXPORTING
       XZTITRQK  = ZTITRQK
       XZTITRQS  = ZTITRQS
     IMPORTING
       R_UCOMM   = P_UCOMM
     TABLES
       ZTISPOKEY = IT_POKEY
       IT_TAB    = IT_TAB.

   IF P_UCOMM EQ 'FCOPY'.
*> 이후 레코드 갯수.
     DESCRIBE TABLE IT_TAB LINES G_COUNT_1.
     IF G_COUNT NE G_COUNT_1.
*> 자재별 기타 정보 Select.
       PERFORM  SET_OTHERS_FIELDS_BY_ITEMS.
*> Tree상에 반영하기 위함.
       IF G_MODE EQ 'C' OR
          G_MODE EQ 'M'.
         DESCRIBE TABLE IT_PO LINES G_LINE.
         READ TABLE IT_PO INDEX G_LINE.
         IF SY-SUBRC EQ 0.
           G_COUNT = IT_PO-INDEX.
         ELSE.
           G_COUNT = 0.
         ENDIF.
         LOOP AT IT_TAB INTO G_TC_2130_WA.
           READ TABLE IT_PO WITH KEY EBELN = G_TC_2130_WA-EBELN
                                     EBELP = G_TC_2130_WA-EBELP
                                     BINARY SEARCH.
           IF SY-SUBRC NE 0.
             ADD 1 TO G_COUNT.
             MOVE-CORRESPONDING G_TC_2130_WA TO IT_PO.
             IT_PO-INDEX = G_COUNT.
             APPEND IT_PO.
           ENDIF.
         ENDLOOP.
*> Tree 재구성.
         IF G_TREE_MODE EQ C_Y.
           PERFORM P9000_CAME_TO_AN_END.
           G_TREE_MODE = C_Y.
         ENDIF.
         DESCRIBE TABLE IT_TAB LINES P_LINE.
       ENDIF.
     ENDIF.
   ELSE.
     P_LINE = P_LINE - 1.
   ENDIF.

 ENDFORM.                    " append_po_items

*&---------------------------------------------------------------------*
*&      Form  p2000_get_po_open_items
*&---------------------------------------------------------------------*
 FORM P2000_GET_PO_OPEN_ITEMS .

   CLEAR: G_COUNT, IT_PONUM.
   REFRESH : IT_PONUM.

   G_LINEN    = 20.
   G_OUT_TEXT = '데이타를 검색 중입니다 %99999%%'(P01).
   REPLACE '%99999%' WITH G_LINEN INTO G_OUT_TEXT.
   PERFORM SHOW_PROGRESS_BAR USING G_OUT_TEXT G_LINE.

   PERFORM GET_USED_PAYMENT_TERM  TABLES  IT_ZTITIG02
                                  USING   G_SUBRC C_SUCCESS.
   IF G_SUBRC NE 0.
     EXIT.
   ENDIF.

   SELECT *
          INTO CORRESPONDING FIELDS OF TABLE IT_PO
          FROM ZTIVPO00
          FOR ALL ENTRIES IN IT_ZTITIG02
          WHERE EBELN  IN S_EBELN
          AND   BUKRS  IN S_BUKRS
          AND   EKORG  IN S_EKORG
          AND   EKGRP  IN S_EKGRP
          AND   BSTYP  EQ 'F'
          AND   LIFNR  IN S_LIFNR
          AND   WAERS  IN S_WAERS
          AND   MATKL  IN S_MATKL
          AND   MATNR  IN S_MATNR
          AND   TXZ01  IN S_TXZ01
          AND   WERKS  IN S_WERKS
          AND   LAND1  IN S_LAND1
          AND   INCO1  IN S_INCO1
          AND   ZTERM  IN S_ZTERM
          AND   BEDAT  IN S_BEDAT
          AND   AEDAT  IN S_AEDAT
          AND   ERNAM  IN S_ERNAM
          AND   FRGRL  NE C_TRUE   ">릴리즈 지시자.
*         AND   ktokk  EQ xZTIsys01-ktokk
          AND   ELIKZ  EQ SPACE    ">납품완료 지시자.
          AND   HLOEKZ EQ SPACE    ">헤더 삭제지시자.
          AND   LOEKZ  EQ SPACE    ">아이템 삭제지시자.
          AND   BSART  EQ IT_ZTITIG02-BSART
          AND   ZTERM  EQ IT_ZTITIG02-ZTERM.
**
   PERFORM GET_AVAILABLE_PO_ITEM TABLES IT_PO
                                        IT_PONUM
                                 USING  C_SUCCESS
                                        C_FALSE.

 ENDFORM.                    " p2000_get_po_open_items

*&---------------------------------------------------------------------*
*&      Form  DISPLAY_PURCHASING_ORDER
*&---------------------------------------------------------------------*
 FORM DISPLAY_PURCHASING_ORDER  USING    P_NODE_KEY.

   READ TABLE IT_PO WITH KEY INDEX = P_NODE_KEY(10).
   IF SY-SUBRC EQ 0.
     PERFORM  DISPLAY_PURCHASE_ORDER USING IT_PO-EBELN
                                           IT_PO-EBELP.
   ELSE.
     MESSAGE S903.
   ENDIF.

 ENDFORM.                    " DISPLAY_PURCHASING_ORDER
*&---------------------------------------------------------------------*
*&      Form  build_request_data
*&---------------------------------------------------------------------*
 FORM BUILD_REQUEST_DATA  USING    P_NODE_KEY.

   DATA: L_PO_WA  LIKE IT_PO,
         L_TAB_WA LIKE IT_TAB,
         L_MODIFY TYPE C,
         L_COUNT  TYPE C,
         L_CHECK  TYPE C.

   CHECK: G_MODE EQ C_CHARC OR
          G_MODE EQ C_CHARM.


   CLEAR: L_MODIFY, G_TC_2130_WA, L_CHECK, L_COUNT.

   DESCRIBE TABLE IT_TAB LINES L_COUNT.

   READ TABLE IT_PO WITH KEY INDEX = P_NODE_KEY(10).
   G_TABIX = SY-TABIX.

   IF SY-SUBRC EQ 0.
     MOVE-CORRESPONDING IT_PO TO L_PO_WA.
     READ TABLE IT_TAB INTO G_TC_2130_WA
                       WITH KEY EBELN = L_PO_WA-EBELN
                                EBELP = L_PO_WA-EBELP.

     IF SY-SUBRC EQ C_ZERO.
*    IF l_po_wa-box EQ 'X'.
       L_CHECK = 'D'.
       PERFORM CHECK_LC_SUB_DOCUMENT_EXIST USING G_TC_2130_WA-REQNO
                                                 G_TC_2130_WA-REQIT
                                                 C_INFO
                                                 G_SUBRC.
       IF G_SUBRC NE 0.
         EXIT.
       ENDIF.

       DELETE IT_TAB WHERE EBELN = L_PO_WA-EBELN
                       AND EBELP = L_PO_WA-EBELP.
*> Lock Object
       PERFORM  SET_PO_LOCK_OBJECT  USING L_PO_WA-EBELN
                                          L_PO_WA-EBELP
                                          C_UNLOCK
                                          C_SUCCESS
                                          L_MODIFY.
     ELSE.
       L_CHECK     = 'I'.
       PERFORM  GET_AND_CHECK_PO_DATA   USING  L_PO_WA-EBELN
                                               L_PO_WA-EBELP
                                               L_MODIFY
                                               ZTIVPO00
                                               L_COUNT
                                               C_SUCCESS.
       IF L_MODIFY EQ C_TRUE.
         EXIT.
       ELSE.
*> PO data Move
         PERFORM SET_REQUEST_OF_IMPORT_DATA TABLES IT_TAB
                                            USING  ZTIVPO00
                                                   ZTITRQK
                                                   ZTITRQS
                                                   L_PO_WA.
       ENDIF.
     ENDIF.
     IF L_CHECK EQ 'D'.
       CLEAR: IT_PO-BOX.
     ELSEIF L_MODIFY NE C_TRUE.
       IT_PO-BOX = 'X'.
     ENDIF.

     MODIFY IT_PO INDEX G_TABIX.
     DESCRIBE TABLE IT_TAB LINES G_LINE.
     IF G_LINE EQ C_ZERO.
       PERFORM P3000_SET_DATA_OF_SCREEN.
     ENDIF.
*>아이템 번호를 생성함.
     PERFORM SET_ITEM_NUMBER_BUILD TABLES IT_TAB
                                   USING  ZTITRQS.
   ENDIF.

 ENDFORM.                    " build_request_data
*&---------------------------------------------------------------------*
*&      Form  build_request_data_pu
*&---------------------------------------------------------------------*
 FORM BUILD_REQUEST_DATA_PU  USING    P_NODE_KEY.

   DATA: L_RKWA_WA LIKE IT_RKWA,
         L_TAB_WA  LIKE IT_TAB,
         L_MODIFY  TYPE C,
         L_COUNT   TYPE C,
         L_CHECK   TYPE C.

   CHECK: G_MODE EQ C_CHARC OR
          G_MODE EQ C_CHARM.

   CLEAR: L_MODIFY, G_TC_2130_WA, L_CHECK, L_COUNT.

   DESCRIBE TABLE IT_TAB LINES L_COUNT.

   READ TABLE IT_RKWA WITH KEY INDEX = P_NODE_KEY(10).
   G_TABIX = SY-TABIX.

   IF SY-SUBRC EQ 0.
     MOVE-CORRESPONDING IT_RKWA TO L_RKWA_WA.
     READ TABLE IT_TAB INTO G_TC_2130_WA
                       WITH KEY MBLNR = L_RKWA_WA-MBLNR
                                MJAHR = L_RKWA_WA-MJAHR
                                ZEILE = L_RKWA_WA-ZEILE.

     IF SY-SUBRC EQ C_ZERO.
*    IF l_po_wa-box EQ 'X'.
       L_CHECK = 'D'.
       PERFORM CHECK_LC_SUB_DOCUMENT_EXIST USING G_TC_2130_WA-REQNO
                                                 G_TC_2130_WA-REQIT
                                                 C_INFO
                                                 G_SUBRC.
       IF G_SUBRC NE 0.
         EXIT.
       ENDIF.

       DELETE IT_TAB WHERE MBLNR = L_RKWA_WA-MBLNR
                       AND MJAHR = L_RKWA_WA-MJAHR
                       AND ZEILE = L_RKWA_WA-ZEILE.
     ELSE.
       L_CHECK     = 'I'.
       PERFORM  GET_AND_CHECK_RKWA_DATA   USING  L_RKWA_WA-MBLNR
                                                 L_RKWA_WA-MJAHR
                                                 L_RKWA_WA-ZEILE
                                                 L_MODIFY
                                                 RKWA
                                                 L_COUNT.
       IF L_MODIFY EQ C_TRUE.
         EXIT.
       ELSE.
*> PO data Move
         PERFORM SET_REQUEST_OF_RKWA_DATA   TABLES IT_TAB
                                            USING  RKWA
                                                   ZTITRQK
                                                   ZTITRQS
                                                   L_RKWA_WA.
       ENDIF.
     ENDIF.
     IF L_CHECK EQ 'D'.
       CLEAR: IT_RKWA-BOX.
     ELSEIF L_MODIFY NE C_TRUE.
       IT_RKWA-BOX = 'X'.
     ENDIF.

     MODIFY IT_RKWA INDEX G_TABIX.
     DESCRIBE TABLE IT_TAB LINES G_LINE.
     IF G_LINE EQ C_ZERO.
       PERFORM P3000_SET_DATA_OF_SCREEN.
     ENDIF.

*>아이템 기타 정보 Read.
     PERFORM SET_OTHERS_FIELDS_BY_ITEMS.

*>아이템 번호를 생성함.
     PERFORM SET_ITEM_NUMBER_BUILD TABLES IT_TAB
                                   USING  ZTITRQS.
   ENDIF.

 ENDFORM.                    " build_request_data_pu

*&---------------------------------------------------------------------*
*&      Form  set_request_of_import_data
*&---------------------------------------------------------------------*
 FORM SET_REQUEST_OF_IMPORT_DATA TABLES P_IT_TAB    LIKE IT_TAB
                                 USING  P_ZTIVPO00 STRUCTURE ZTIVPO00
                                        P_ZTITRQK STRUCTURE ZTITRQK
                                        P_ZTITRQS STRUCTURE ZTITRQS
                                        P_PO_WA    STRUCTURE IT_PO.

   DATA: L_EXPVZ  TYPE EXPVZ.

   MOVE-CORRESPONDING P_ZTIVPO00 TO : P_IT_TAB,
                                      P_ZTITRQK,
                                      P_ZTITRQS,
                                      EKKO.
*   CLEAR: ekko.
   IF NOT EKKO-EBELN IS INITIAL.
     SELECT SINGLE *
       FROM EKKO
      WHERE EBELN  EQ  EKKO-EBELN.
     IF SY-SUBRC EQ 0 AND
        NOT EKKO-EXNUM IS INITIAL.
*-  해외무역 운송모드(EIKP-EXPVZ) 데이터 가져와야 함
*-  Key Field인 해외무역데이터번호(EXNUM)로 해당 내역 Select

       SELECT SINGLE EXPVZ
         INTO L_EXPVZ
         FROM EIKP
        WHERE EXNUM   EQ EKKO-EXNUM.

       IF NOT L_EXPVZ IS INITIAL.
         SELECT SINGLE *
           FROM T001
          WHERE BUKRS EQ EKKO-BUKRS.
         SELECT FWDTY
           INTO ZTITRQS-FWDTY
           FROM ZTITIG08 UP TO 1 ROWS
          WHERE LAND1  EQ  T001-LAND1
            AND EXPVZ  EQ  L_EXPVZ.
         ENDSELECT.

       ENDIF.
     ENDIF.
   ENDIF.

   IF NOT EKKO-BUKRS IS INITIAL.
     SELECT SINGLE *
       FROM ZTITIG00
      WHERE BUKRS  EQ  EKKO-BUKRS.
   ENDIF.

*> 구매오더 수입관련 필드 --> 수입의뢰 상태 테이블.
   PERFORM MOVE_EKKO_FIELDS_TO_ZTITRQS  USING  EKKO
                                               P_ZTITRQS.


   MOVE: P_PO_WA-RQMNG  TO P_IT_TAB-RQMNG,
         P_PO_WA-RQMNGS TO P_IT_TAB-RQMNGS,
         P_PO_WA-RQMNGL TO P_IT_TAB-RQMNGL.

   MOVE: SY-UNAME TO P_IT_TAB-CNAM,
         SY-DATLO TO P_IT_TAB-CDAT,
         SY-TIMLO TO P_IT_TAB-CTME,
         SY-UNAME TO P_IT_TAB-UNAM,
         SY-DATLO TO P_IT_TAB-UDAT,
         SY-TIMLO TO P_IT_TAB-UTME.

*> 구매오더 정가 계산.
   CALL FUNCTION 'Z_TI_CALC_ITEM_AMOUNT'
     EXPORTING
       PEINH = P_IT_TAB-PEINH
       BPUMZ = P_IT_TAB-BPUMZ
       BPUMN = P_IT_TAB-BPUMN
       MENGE = P_IT_TAB-MENGE
       NETPR = P_IT_TAB-NETPR
     CHANGING
       NETWR = P_IT_TAB-POAMT.

   SELECT SUM( NETWR )
     INTO P_IT_TAB-RQAMTS
     FROM ZTIVRQ00
    WHERE EBELN EQ P_IT_TAB-EBELN
      AND EBELP EQ P_IT_TAB-EBELP
      AND REQNO NE P_ZTITRQK-REQNO.

   APPEND P_IT_TAB.

*>아이템 번호를 생성함.
   PERFORM SET_ITEM_NUMBER_BUILD TABLES P_IT_TAB
                                 USING  P_ZTITRQS.

   PERFORM GET_OTHERS_TEXT_BY_MASTER_DATA.

 ENDFORM.                    " set_request_of_import_data
*&---------------------------------------------------------------------*
*&      Form  set_request_of_rkwa_data
*&---------------------------------------------------------------------*
 FORM SET_REQUEST_OF_RKWA_DATA   TABLES P_IT_TAB   LIKE IT_TAB
                                 USING  P_RKWA     STRUCTURE RKWA
                                        P_ZTITRQK STRUCTURE ZTITRQK
                                        P_ZTITRQS STRUCTURE ZTITRQS
                                        P_RKWA_WA  STRUCTURE IT_RKWA.

   MOVE-CORRESPONDING P_RKWA TO : P_IT_TAB, P_ZTITRQK, P_ZTITRQS.

   MOVE: P_RKWA_WA-RQMNG  TO P_IT_TAB-RQMNG,
         P_RKWA_WA-RQMNGS TO P_IT_TAB-RQMNGS,
         P_RKWA_WA-RQMNGL TO P_IT_TAB-RQMNGL,
         P_RKWA_WA-BSTMG  TO P_IT_TAB-MENGE,
         P_RKWA_WA-BSTME  TO P_IT_TAB-MEINS,
         P_RKWA_WA-BWAER  TO P_ZTITRQS-WAERS,
         P_RKWA_WA-LIFNR  TO P_ZTITRQK-LIFNR.

   MOVE: 1                TO P_IT_TAB-PEINH,
         1                TO P_IT_TAB-BPUMZ,
         1                TO P_IT_TAB-BPUMN,
         P_RKWA_WA-BSTMG  TO P_IT_TAB-MENGE,
         P_RKWA_WA-BSTME  TO P_IT_TAB-MEINS,
         P_RKWA_WA-WERKS  TO P_IT_TAB-WERKS,
         P_RKWA_WA-MATNR  TO P_IT_TAB-MATNR.

   IF RKWA-BSTMG NE 0.
     P_IT_TAB-NETPR = P_RKWA_WA-WRBTR / P_RKWA_WA-BSTMG.
   ENDIF.

   MOVE: SY-UNAME TO P_IT_TAB-CNAM,
         SY-DATLO TO P_IT_TAB-CDAT,
         SY-TIMLO TO P_IT_TAB-CTME,
         SY-UNAME TO P_IT_TAB-UNAM,
         SY-DATLO TO P_IT_TAB-UDAT,
         SY-TIMLO TO P_IT_TAB-UTME.

   APPEND P_IT_TAB.

*>아이템 번호를 생성함.
   PERFORM SET_ITEM_NUMBER_BUILD TABLES P_IT_TAB
                                 USING  P_ZTITRQS.

   PERFORM GET_OTHERS_TEXT_BY_MASTER_DATA.

 ENDFORM.                    " set_request_of_rkwa_data

*&---------------------------------------------------------------------*
*&      Form  get_and_check_po_data
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
 FORM GET_AND_CHECK_PO_DATA  USING    P_EBELN
                                      P_EBELP
                                      P_MODIFY
                                      P_ZTIVPO00 STRUCTURE ZTIVPO00
                                      P_COUNT
                                      P_MSGTY.

   CLEAR: P_ZTIVPO00.

   SELECT SINGLE * INTO P_ZTIVPO00
     FROM ZTIVPO00
    WHERE EBELN EQ P_EBELN
      AND EBELP EQ P_EBELP.

   IF SY-SUBRC EQ 0.
*>문서유형 체크.
     READ TABLE IT_ZTITIG02 WITH KEY BSTYP = P_ZTIVPO00-BSTYP
                                     BSART = P_ZTIVPO00-BSART
                                     ZTERM = P_ZTIVPO00-ZTERM.
*                                     BINARY SEARCH.
     IF SY-SUBRC NE 0.
       MESSAGE ID 'ZMTI00' TYPE P_MSGTY NUMBER 002
                         WITH P_ZTIVPO00-BSART P_ZTIVPO00-ZTERM.
       P_MODIFY = C_TRUE.
       EXIT.
     ELSE.
       IF IT_ZTITIG02-REQTY  NE ZTITRQK-REQTY.
         IF P_COUNT          GT C_ZERO.
           MESSAGE ID 'ZMTI00' TYPE P_MSGTY NUMBER 004
                             WITH IT_ZTITIG02-REQTY ZTITRQK-REQTY.
           P_MODIFY = C_TRUE.
           EXIT.
         ELSE.
           MOVE IT_ZTITIG02-REQTY TO ZTITRQK-REQTY.
         ENDIF.
       ENDIF.
     ENDIF.
*>Vendor 체크.
     IF ZTITRQK-LIFNR     NE P_ZTIVPO00-LIFNR AND
        NOT ZTITRQK-LIFNR IS INITIAL.
       MESSAGE ID 'ZMTI00' TYPE P_MSGTY NUMBER 003
                         WITH P_ZTIVPO00-LIFNR ZTITRQK-LIFNR.
       P_MODIFY = C_TRUE.
       EXIT.
     ENDIF.
*통화키 체크.
     IF ZTITRQS-WAERS    NE  P_ZTIVPO00-WAERS AND
        P_COUNT           GT  C_ZERO.
       MESSAGE ID 'ZMTI00' TYPE P_MSGTY NUMBER 006
                         WITH P_ZTIVPO00-WAERS ZTITRQS-WAERS.
       P_MODIFY = C_TRUE.
     ENDIF.
*인도조건
     IF ZTITRQS-INCO1    NE  P_ZTIVPO00-INCO1 AND
        NOT ZTITRQS-INCO1  IS INITIAL.
       MESSAGE ID 'ZMTI00' TYPE P_MSGTY NUMBER 032
                        WITH '인도조건' P_ZTIVPO00-INCO1 ZTITRQS-INCO1.
       P_MODIFY = C_TRUE.
       EXIT.
     ENDIF.
*지급조건.
     IF ZTITRQS-ZTERM    NE  P_ZTIVPO00-ZTERM AND
        NOT ZTITRQS-ZTERM  IS INITIAL.
       MESSAGE ID 'ZMTI00' TYPE P_MSGTY NUMBER 032
                        WITH '지급조건' P_ZTIVPO00-ZTERM ZTITRQS-ZTERM.
       P_MODIFY = C_TRUE.
       EXIT.
     ENDIF.
*구매그룹.
     IF ZTITRQK-EKGRP    NE  P_ZTIVPO00-EKGRP AND
        NOT ZTITRQK-EKGRP  IS INITIAL.
       MESSAGE ID 'ZMTI00' TYPE P_MSGTY NUMBER 032
                        WITH '구매그룹' P_ZTIVPO00-EKGRP ZTITRQK-EKGRP.
       P_MODIFY = C_TRUE.
       EXIT.
     ENDIF.
*20031103 add.
*작업분할구조요소 (WBS 요소) "뒤에서 check.
*
**운송 방법
*    IF ZTITRQS-fwdty    NE  p_ZTIvpo00-fwdty AND
*       NOT ZTITRQS-fwdty  IS INITIAL.
*      MESSAGE ID 'ZMTI00' TYPE p_msgty NUMBER 032
*                       WITH '운송방법' p_ZTIvpo00-fwdty ZTITRQS-fwdty.
*      p_modify = c_true.
*      EXIT.
*    ENDIF.
**선적항."국가:ZTITRQS-FLAND,항:ZTITRQS-FPORT,항이름:ZTITRQS-PLLOD.
*    IF ZTITRQS-fport    NE  p_ZTIvpo00-fport AND
*       NOT ZTITRQS-fport  IS INITIAL.
*      MESSAGE ID 'ZMTI00' TYPE p_msgty NUMBER 032
*                        WITH '선적항' p_ZTIvpo00-fport ZTITRQS-fport.
*      p_modify = c_true.
*      EXIT.
*    ENDIF.
*
**도착항."국가:ZTITRQS-TLAND,항:ZTITRQS-TPORT,항이름:ZTITRQS-PLTRN.
*    IF ZTITRQS-tport    NE  p_ZTIvpo00-tport AND
*       NOT ZTITRQS-tport  IS INITIAL.
*      MESSAGE ID 'ZMTI00' TYPE p_msgty NUMBER 032
*                        WITH '도착항' p_ZTIvpo00-tport ZTITRQS-tport.
*      p_modify = c_true.
*      EXIT.
*    ENDIF.
*
**원산지.
**  MOVE: p_ekko-herkl TO p_ZTITRQS-ctocd,   "원산국
**        p_ekko-herkl_e TO p_ZTITRQS-ctonm. "원산지
*    IF ZTITRQS-ctocd    NE  p_ZTIvpo00-herkl AND
*       NOT ZTITRQS-ctocd  IS INITIAL.
*      MESSAGE ID 'ZMTI00' TYPE p_msgty NUMBER 032
*                        WITH '원산지' p_ZTIvpo00-herkl ZTITRQS-ctocd.
*      p_modify = c_true.
*      EXIT.
*    ENDIF.
**분할선적여부.
*    IF NOT ZTITRQS-party  IS INITIAL.
*      IF p_ZTIvpo00-party EQ c_char1.
*        IF ZTITRQS-party = '9'.
*          MESSAGE ID 'ZMTI00' TYPE p_msgty NUMBER 032
*              WITH '분할선적여부' p_ZTIvpo00-party ZTITRQS-party.
*          p_modify = c_true.
*          EXIT.
*        ENDIF.
*      ELSE.
*        IF ZTITRQS-party = '10'.
*          MESSAGE ID 'ZMTI00' TYPE p_msgty NUMBER 032
*              WITH '분할선적여부' p_ZTIvpo00-party ZTITRQS-party.
*          p_modify = c_true.
*          EXIT.
*        ENDIF.
*      ENDIF.
*    ENDIF.
**환적여부.
*    IF NOT ZTITRQS-trany  IS INITIAL.
*      IF ZTIvpo00-trany EQ c_char1.
*        IF ZTITRQS-trany = '7'.
*          MESSAGE ID 'ZMTI00' TYPE p_msgty NUMBER 032
*             WITH '환적여부' p_ZTIvpo00-trany ZTITRQS-trany.
*          p_modify = c_true.
*          EXIT.
*        ENDIF.
*      ELSE.
*        IF ZTITRQS-trany = '8'.
*          MESSAGE ID 'ZMTI00' TYPE p_msgty NUMBER 032
*             WITH '환적여부' p_ZTIvpo00-trany ZTITRQS-trany.
*          p_modify = c_true.
*          EXIT.
*        ENDIF.
*      ENDIF.
*    ENDIF.
*
     IF  P_ZTIVPO00-BUKRS NE '6000'.
*> 릴리즈 지시자.
       IF P_ZTIVPO00-FRGRL  EQ C_TRUE.
         MESSAGE ID 'ZMTI00' TYPE P_MSGTY NUMBER 126.
*      MESSAGE s126.
         P_MODIFY = C_TRUE.
       ENDIF.
     ENDIF.
*> Lock Object
     IF P_MODIFY NE C_TRUE.
       PERFORM  SET_PO_LOCK_OBJECT  USING P_EBELN
                                          P_EBELP
                                          C_LOCK
                                          P_MSGTY
                                          P_MODIFY.
     ENDIF.
   ELSE.
     MESSAGE ID '06' TYPE P_MSGTY NUMBER 019
                     WITH P_EBELN.
     P_MODIFY = C_TRUE.
     EXIT.
   ENDIF.


 ENDFORM.                    " get_po_data
*&---------------------------------------------------------------------*
*&      Form  get_and_check_rkwa_data
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
 FORM GET_AND_CHECK_RKWA_DATA  USING    P_MBLNR
                                        P_MJAHR
                                        P_ZEILE
                                        P_MODIFY
                                        P_RKWA STRUCTURE RKWA
                                        P_COUNT.

   CLEAR: P_RKWA.

   SELECT SINGLE * INTO P_RKWA
     FROM RKWA
    WHERE MBLNR EQ P_MBLNR
      AND MJAHR EQ P_MJAHR
      AND ZEILE EQ P_ZEILE.

   IF SY-SUBRC EQ 0.
*>Vendor 체크.
     IF ZTITRQK-LIFNR     NE P_RKWA-LIFNR AND
        NOT ZTITRQK-LIFNR IS INITIAL.
       MESSAGE S008 WITH P_RKWA-LIFNR ZTITRQK-LIFNR.
       P_MODIFY = C_TRUE.
       EXIT.
     ENDIF.
*통화키 체크.
     IF ZTITRQS-WAERS    NE  P_RKWA-BWAER AND
        P_COUNT           GT  C_ZERO.
       MESSAGE S007 WITH P_RKWA-BWAER ZTITRQS-WAERS.
       P_MODIFY = C_TRUE.
     ENDIF.

   ELSE.
     MESSAGE S019(06) WITH P_MBLNR.
     P_MODIFY = C_TRUE.
     EXIT.
   ENDIF.

 ENDFORM.                    " get_and_check_rkwa_data

*&---------------------------------------------------------------------*
*&      Form  p3000_set_data_of_screen
*&---------------------------------------------------------------------*
 FORM P3000_SET_DATA_OF_SCREEN .

   IF G_TCODE EQ C_CREATE OR
      G_TCODE EQ C_CREATE_D.

     REFRESH: IT_TAB, G_TC_2124_ITAB,
              G_TC_2212_ITAB,
              G_TC_2213_ITAB,
              G_TC_2240_ITAB,
              G_TC_2220_1_ITAB,
              G_TC_2220_2_ITAB,
              G_TC_2211_ITAB,
              G_TC_2214_ITAB,
              G_TC_2216_ITAB,
              G_TC_2123_ITAB,
              G_TC_2124_ITAB.

     CLEAR: ZTITRQK,
            ZTITRQS,
            ZTISRQIT,
            ZTITRQP,
            IT_TAB,
            LFA1,
           *LFA1,
            W_LFA1,
            W_LFA1_BANK,
            T001,
            T024,
            T024E.

     CLEAR:  GT_CONTROL-TEXTLINES[], GT_CONTROL-TEXTTYPES[].

     MOVE :
*           c_lc        TO    ZTITRQK-reqty,  ">수입의뢰종류.
*           c_ocean     TO    ZTITRQS-fwdty,  ">운송방법.
            C_Y         TO    ZTITRQK-APPCT,  ">수입자(자사)
            C_BEFORE    TO    ZTITRQK-ANBTY,  ">사전.
            '2AA'       TO    ZTITRQS-PAGRT,  ">신용공여주체.
*S__ 신용장 변경 20181010 BY SDW
*__ 원본소스 주석처리
*            '19'        TO    ZTITLC1-CHGER.  ">수수료부담자.
            '2AG'        TO    ZTITLC1-CHGER.  ">수수료부담자.
*E__ 신용장 변경 20181010 BY SDW
*           '9'         TO    ZTITRQS-party,  ">분할선적(허용).
*           '8'         TO    ZTITRQS-trany,  ">환적(금지)
*           'KR'        TO    ZTITRQS-tland,  ">도착국가.
*           'PUS'       TO    ZTITRQS-tport,  ">도착항.
*----------------------------------------------------------------------*
*                M O D I F I C A T I O N   L O G                       *
*----------------------------------------------------------------------*
* 2004.10.22   Sung-ho Maeng                LG전선 요구로 현재일+ 1일  *
*----------------------------------------------------------------------*
*            sy-datlo    TO    ztitrqs-reqdt.  ">개설희망일자.
     ZTITRQS-REQDT = SY-DATLO + 1.     ">개설희망일자.
     ZTITTT1-DUEDT = ZTITRQS-REQDT.    ">결제기간.
     ZTITTT1-PLIDT = SY-DATLO.         ">확인일자.
*----------------------------< INSERT END >----------------------------*

*> 위탁자재일 경우.
     IF G_TCODE1       EQ 'ZTIR003' OR          ">위탁자재.
       ZTITRQS-SETYN  EQ C_TRUE.
       MOVE : C_PU        TO    ZTITRQK-REQTY,  ">수입의뢰종류
              C_TRUE      TO    ZTITRQS-SETYN.
     ENDIF.
     IF ZTITRQS-SETYN  EQ C_FALSE AND
        ZTITRQK-REQTY  EQ C_PU.
       MOVE C_BEFORE   TO ZTITRQK-ANBTY.  ">사전.
     ENDIF.


*> 구매확인서일 경우.
     IF ZTITRQK-REQTY  EQ C_PU.
*       ztitrqs-reqdt = ztitrqs-reqdt + 7.
*       ztitrqs-zterm = '1001'.
*       ztitrqs-inco1 = 'Z0A'.
       ZTITPC1-PSPY1 = C_CHAR3.
       ZTITPC1-PSPY2 = C_CHAR5.
       ZTITPC1-PSPY3 = C_CHAR7.
     ELSE.
*       ztitrqs-reqdt = ztitrqs-reqdt + 14.
     ENDIF.

   ELSE.
*> 변경 문서 관리를 위한 이전데이타를 Move.
     ZTITRQK-REQNO   = *ZTITRQK-REQNO.
     ZTITRQS-REQNO   = *ZTITRQS-REQNO.
     ZTITRQS-AMDSQ   = *ZTITRQS-AMDSQ.
   ENDIF.

 ENDFORM.                    " p3000_set_data_of_screen
*&---------------------------------------------------------------------*
*&      Form  check_for_sub_document_exist
*&---------------------------------------------------------------------*
*  삭제시 후속 문서의 존재여부를 확인함..
*----------------------------------------------------------------------*
 FORM CHECK_FOR_SUB_DOCUMENT_EXIST.

   DATA: L_COUNT TYPE I.

   LOOP AT IT_TAB INTO G_TC_2130_WA.
     PERFORM CHECK_LC_SUB_DOCUMENT_EXIST(ZTIR0000)
                              USING   G_TC_2130_WA-REQNO
                                      G_TC_2130_WA-REQIT
                                      C_ERROR
                                      G_SUBRC.
   ENDLOOP.

*> 비용문서 체크.
   SELECT COUNT( * )
     INTO L_COUNT
     FROM ZTITCSP
    WHERE EXPGR  EQ  C_CHARL
      AND REFNO  EQ  ZTITRQS-REQNO
      AND AMDSQ  EQ  ZTITRQS-AMDSQ.

   IF L_COUNT GT 0.
     MESSAGE ID 'ZMTI00' TYPE C_ERROR NUMBER '109' WITH '수입제비용'.
   ENDIF.

 ENDFORM.                    " check_for_sub_document_exist
*&---------------------------------------------------------------------*
*&      Form  check_for_document_field
*&---------------------------------------------------------------------*
*  필드들의 오류 값들을 체크하여 공통 nternal table에 저장함.
*----------------------------------------------------------------------*
 FORM CHECK_FOR_DOCUMENT_FIELD USING P_MODE.

   DATA : L_IF_NULL         TYPE REF TO IF_MESSAGE_OBJ_MM.
   DATA : L_TEXT_EXIST      TYPE C.
   DATA : L_TDTEXT          TYPE TDTEXT.
*
* preparations
   CALL METHOD CL_MESSAGE_HANDLER_MM=>GET_HANDLER
     IMPORTING
       EX_HANDLER = G_MESSAGE_HANDLER.

   CALL METHOD G_MESSAGE_HANDLER->SET_CONFIG_FOR_MEPO( ).
   CALL METHOD G_MESSAGE_HANDLER->REMOVE_ALL( ).
   CALL METHOD G_MESSAGE_HANDLER->CLEANUP( ).

*  IF ZTITRQS-zterm IS INITIAL.
*    PERFORM set_return_message USING 'ZTITRQS' 'ZTERM' c_error.
*  ENDIF.

*> 회송사유 필수 체크.
   IF OK_CODE_OLD EQ 'ZTIRETURN'.
     IF NOT ZTITIG00-RTTID IS INITIAL.
       PERFORM CHECK_TEXT_BY_TEXT_ID  USING C_TEXTOBJECT_HEADER
                                            ZTITIG00-RTTID
                                            L_TEXT_EXIST
                                            L_TDTEXT.
       IF L_TEXT_EXIST IS INITIAL.
         IF ZTITIG00-RTMTY EQ 'E'.
           MESSAGE S034 WITH L_TDTEXT.
           PERFORM SET_RETURN_MESSAGE_FILL USING C_ERROR.
         ELSE.
           MESSAGE ID 'ZMTI00' TYPE ZTITIG00-RTMTY NUMBER '034'
                   WITH L_TDTEXT SPACE SPACE SPACE.
         ENDIF.
       ENDIF.
     ENDIF.
   ENDIF.

*> Amend 사유 필수 체크.
   IF OK_CODE_OLD   EQ 'ZTIREQUEST' AND
      ZTITRQS-AMDSQ GT C_ZERO.
     IF NOT ZTITIG00-AMTID IS INITIAL.
       PERFORM CHECK_TEXT_BY_TEXT_ID  USING C_TEXTOBJECT_HEADER
                                            ZTITIG00-AMTID
                                            L_TEXT_EXIST
                                            L_TDTEXT.
       IF L_TEXT_EXIST IS INITIAL.
         IF ZTITIG00-AMMTY EQ 'E'.
           MESSAGE S034 WITH L_TDTEXT.
           PERFORM SET_RETURN_MESSAGE_FILL USING C_ERROR.
         ELSE.
           MESSAGE ID 'ZMTI00' TYPE ZTITIG00-AMMTY NUMBER '034'
                   WITH L_TDTEXT SPACE SPACE SPACE.
         ENDIF.
       ENDIF.
     ENDIF.
   ENDIF.

*> 승인반려 사유 필수 체크.
   IF OK_CODE_OLD   EQ 'ZTIAPPLYB'.
     IF NOT ZTITIG00-GBTID IS INITIAL.
       PERFORM CHECK_TEXT_BY_TEXT_ID  USING C_TEXTOBJECT_HEADER
                                            ZTITIG00-GBTID
                                            L_TEXT_EXIST
                                            L_TDTEXT.
       IF L_TEXT_EXIST IS INITIAL.
         IF ZTITIG00-GBMTY EQ 'E'.
           MESSAGE S034 WITH L_TDTEXT.
           PERFORM SET_RETURN_MESSAGE_FILL USING C_ERROR.
         ELSE.
           MESSAGE ID 'ZMTI00' TYPE ZTITIG00-GBMTY NUMBER '034'
                   WITH L_TDTEXT SPACE SPACE SPACE.
         ENDIF.
       ENDIF.
     ENDIF.
   ENDIF.

   DESCRIBE TABLE IT_PSPNR LINES G_LINE.
   CASE G_LINE.
     WHEN C_ZERO.

     WHEN C_ONE.
       READ TABLE IT_PSPNR INDEX 1.
       IF SY-SUBRC EQ 0.
         IF IT_PSPNR-PSPNR NE ZTITRQK-PSPNR.
           IF ZTITRQK-PSPNR IS INITIAL.
             ZTITRQK-PSPNR = IT_PSPNR-PSPNR.
           ELSE.
             IF NOT IT_PSPNR-PSPNR IS INITIAL.
               MESSAGE S031.
               PERFORM SET_RETURN_MESSAGE_FILL USING C_ERROR.
             ENDIF.
           ENDIF.
         ENDIF.
       ENDIF.
     WHEN OTHERS.
       MESSAGE S017.
       PERFORM SET_RETURN_MESSAGE_FILL USING C_ERROR.
   ENDCASE.

   IF NOT ZTITIG00 IS INITIAL.
     CASE ZTITIG00-RQEDS.
       WHEN C_CHARA.
*> 의뢰요청시 EDI 오류 체크..
         IF OK_CODE EQ 'ZTIREQUEST' AND
            ZTITRQS-EDIYN IS INITIAL.
           IF NOT ( ZTITRQK-REQTY EQ C_DA OR
                    ZTITRQK-REQTY EQ C_DP ).
             MESSAGE S039.
             PERFORM SET_RETURN_MESSAGE_FILL USING C_ERROR.
           ENDIF.
         ENDIF.
       WHEN C_CHARB.
*> 상신시 EDI 오류 체크..
         IF OK_CODE EQ 'ZTIAPPLY' AND
            ZTITRQS-EDIYN IS INITIAL.
           IF NOT ( ZTITRQK-REQTY EQ C_DA OR
                    ZTITRQK-REQTY EQ C_DP ).
             MESSAGE S038.
             PERFORM SET_RETURN_MESSAGE_FILL USING C_ERROR.
           ENDIF.
         ENDIF.
     ENDCASE.
   ENDIF.

* 공통업무 check.
   IF NOT ( OK_CODE_OLD EQ 'ZTIRETURN' OR
            OK_CODE_OLD EQ 'ZTIREQCANC' ).
     PERFORM CHECK_COM_DOCUMENT_FIELD USING P_MODE.
   ENDIF.
*> 업무영역별 필드 체크.
   CASE ZTITRQK-REQTY.
     WHEN C_LC. "수입신용장 field check.
       PERFORM CHECK_LC_DOCUMENT_FIELD USING P_MODE.
     WHEN C_LO. "내국신용장 field check.
       PERFORM CHECK_LO_DOCUMENT_FIELD USING P_MODE.
     WHEN C_PU. "구매확인서 field check.
       PERFORM CHECK_PC_DOCUMENT_FIELD USING P_MODE.
     WHEN C_TT. "전신환 송금 field check.
       IF NOT ( OK_CODE_OLD EQ 'ZTIRETURN' OR
             OK_CODE_OLD EQ 'ZTIREQCANC' ).
         PERFORM CHECK_TT_DOCUMENT_FIELD USING P_MODE.
       ENDIF.
     WHEN C_DA OR C_DP.
*> 포워더 체크.
       IF P_MODE EQ C_CHARY.
         PERFORM  CHECK_FORWARDER_DATA.
       ENDIF.
     WHEN OTHERS.
   ENDCASE.

*> 오류정보가 존재시 메시지 상자 POPUP.
   G_LINE = G_MESSAGE_HANDLER->GET_SEVERITY_BO(
                           IM_BUSINESS_OBJ          = L_IF_NULL
                           IM_INCLUDE_CHILD_OBJECTS = C_TRUE ).

   IF G_LINE GT 0.
     CALL METHOD G_MESSAGE_HANDLER->SHOW(
         IM_POPUP  = C_TRUE
         IM_AMODAL = C_FALSE ).
   ELSE.
     MESSAGE S911.
   ENDIF.

 ENDFORM.                    " check_for_document_field
*&---------------------------------------------------------------------*
*&      Form  p8000_save_master_data
*&---------------------------------------------------------------------*
 FORM P8000_SAVE_MASTER_DATA USING P_MODE.

   DATA: L_MODIFY.
   DATA: L_LIFNR LIKE ZTITIG13-LIFNR.

*>Switches on the local update task.
   SET UPDATE TASK LOCAL.

*> 공통테이블 적용.
   IF G_MODE      EQ C_CHARY AND
      OK_CODE_OLD EQ 'ZTISAVE'.
     P_MODE = 'Y'.
   ENDIF.

   PERFORM  SET_EDI_PARTNER_FIELD.
*--> LS 전선 Consinee 정보 Set By SB, Kang
   IF ZTITRQK-REQTY EQ C_LC.
*> 운송방법에 따라.
     CASE ZTITRQS-FWDTY.
       WHEN C_CHARA.   ">Air
         IF ZTITLC1-ABYCD = 'X'.
           PERFORM  SET_AIR_DOCUMENT_REQUIRED.
         ENDIF.
       WHEN C_CHARO.   ">Ocean
         IF ZTITLC1-BLYCD = 'X'.
           PERFORM  SET_OCEAN_DOCUMENT_REQUIRED.
         ENDIF.
       WHEN C_CHARC.   ">Air + Ocean
         IF ZTITLC1-BLYCD = 'X'.
           PERFORM  SET_OCEAN_DOCUMENT_REQUIRED.
         ENDIF.
         IF ZTITLC1-ABYCD = 'X'.
           PERFORM  SET_AIR_DOCUMENT_REQUIRED.
         ENDIF.
       WHEN C_CHARM.   ">Others.
     ENDCASE.
   ENDIF.

   PERFORM  P8100_SAVE_COMMON_DATA  TABLES IT_TAB
                                    USING  ZTITRQK
                                           ZTITRQS
                                           G_SUBRC
                                           P_MODE.
   IF G_SUBRC NE C_ZERO.
     MESSAGE A912.   EXIT.
   ENDIF.

*> Long Text 저장 루틴.
   PERFORM SAVE_LONG_TEXT USING ZTITRQS+3(12)
                                C_TEXTOBJECT_HEADER
                                G_SUBRC.

   IF SY-SUBRC NE 0.
     ROLLBACK WORK.
     MESSAGE A912.   EXIT.
   ENDIF.

*> 기존 EDI Data clearing.
   PERFORM  P8111_EDI_TABLE_CLEAR USING ZTITRQS
                                        G_SUBRC.

*S__ 신용장 변경에 따른 수정 20181010 BY SDW
   PERFORM  TEXT_TABLE_DATA_CLEAR.
*E__ 신용장 변경에 따른 수정 20181010 BY SDW

*> Long text editor --> Internal table
   PERFORM  GET_EDI_TEXTID_AND_TEXT.

   PERFORM  P8111_EDI_ITEM_TABLE_READ.

*> Type별 EDI Data 적용.
   CASE ZTITRQK-REQTY.
     WHEN C_LC.   ">신용장.
       PERFORM P8110_SAVE_APP700  USING ZTITRQK
                                        ZTITRQS
                                        G_SUBRC.
     WHEN C_PU.   ">구매확인서.
       PERFORM P8110_SAVE_PCRLIC  USING ZTITRQK
                                        ZTITRQS
                                        G_SUBRC.
     WHEN C_LO.   ">로컬 L/C
       PERFORM P8110_SAVE_APPLOC  USING ZTITRQK
                                        ZTITRQS
                                        G_SUBRC.
     WHEN C_TT.   ">전신환 송금.
       PERFORM P8110_SAVE_PAYORD  USING ZTITRQK
                                        ZTITRQS
                                        G_SUBRC.
     WHEN OTHERS.
   ENDCASE.

   IF G_SUBRC NE C_ZERO.
     MESSAGE A912.   EXIT.
   ELSE.
*> Change document setting.
     PERFORM P8120_CHANGE_DOCUMENT.

************************************************************************
**> Begin of 위탁자재일 경우, Work Flow Event 생성.  -
************************************************************************
*     IF ztitrqs-setyn EQ c_true.
*       CLEAR: objtype, objkey,
*              event,   event_id,
*              event_container.
*       REFRESH: event_container.
*
**> WorkFlow용 Business Object 및 Event 정의.
*       objtype = 'ZTIIMPORT'.      "> W/F Business Object
*       objkey  = ztitrqs+3(12).    "> Key fields
*
*       IF g_mode         EQ c_charc.     ">생성.
*         event   = 'Requested'.       "> Event
*         PERFORM  create_work_flow_event.
*       ELSEIF g_mode         EQ c_charm. ">변경.
*         event   = 'Canceled'.       "> Event
*         PERFORM  create_work_flow_event.
*         event   = 'Requested'.       "> Event
*         PERFORM  create_work_flow_event.
*       ENDIF.
*       IF ok_code_old EQ 'ZTIDELETE'.    ">삭제.
*         event   = 'Canceled'.       "> Event
*         PERFORM  create_work_flow_event.
*       ENDIF.
*     ENDIF.
************************************************************************
**> End  of 위탁자재일 경우, Work Flow Event 생성.  -
************************************************************************

*> Commit work.
     COMMIT WORK.

*> CHM2202-00131 메일전송 기능 추가 요청 건 EVK 정재원
     IF ZTITRQK-BUKRS EQ '5000'.
       IF OK_CODE_OLD EQ 'ZTIREQUEST'.
         IF ZTITRQK-REQTY EQ 'PU'.
           PERFORM SEND_MAIL.
         ENDIF.
       ENDIF.
     ENDIF.
*> CHM2202-00131 메일전송 기능 추가 요청 건 EVK 정재원

******************************************************************
** 20060411 simcho 수입개설요청 W/F 생성 By C2006040601000001033
******************************************************************
*     INCLUDE <cntn01>.
*
*     DATA : objkey LIKE sweinstcou-objkey,
*            event_container LIKE swcont OCCURS 0 WITH HEADER LINE,
*            approverpernr LIKE pakey-pernr.
*
*     DATA : BEGIN OF zmmtiappr_key,
*                reqno LIKE ztitrqk-reqno,
*            END OF zmmtiappr_key.
*
** 이부분에 값을 할당해 주세요
**************************************************
*     zmmtiappr_key-reqno =  ztitrqs-reqno.
*     approverpernr = ztitrqs-setlr.
**************************************************
*     objkey = zmmtiappr_key.
*
*
** 이벤트 컨테이너
** PERNR : 승인자 사번
*     swc_set_element event_container 'APPROVERPERNR' approverpernr.
*
** create a event to trigger workflow
*     CALL FUNCTION 'SWE_EVENT_CREATE'
*       EXPORTING
*         objtype           = 'ZMMTIAPPR'
*         objkey            = objkey
*         event             = 'Requested'
*       TABLES
*         event_container   = event_container
*       EXCEPTIONS
*         objtype_not_found = 1.
*
*     IF sy-subrc <> 0.
*       MESSAGE s016(pn) WITH '수입요청 승인WF 이벤트 생성에 실패했습니
*다.'.
*       EXIT.
*     ELSE.
*       MESSAGE s016(pn) WITH '수입요청이 승인요청되었습니다.'.
*     ENDIF.
*
** Start tRFC processing
*     COMMIT WORK.
******************************************************************
** end simcho by C2006040601000001033
******************************************************************

*> Set parameter ID
     IF OK_CODE_OLD EQ 'ZTIDELETE'.
       MESSAGE S111 WITH ZTITRQS-REQNO ZTITRQS-AMDSQ.
     ELSE.
*> Lock Object
       IF G_MODE NE C_CHARC.
         PERFORM  SET_LC_LOCK_OBJECT  USING ZTITRQS-REQNO
                                            ZTITRQS-AMDSQ
                                            '00000'
                                            C_UNLOCK
                                            C_ERROR
                                            L_MODIFY.
       ENDIF.



*> Invoice 문서 생성 BDC
       IF ZTITRQK-ANBTY EQ C_CHARB AND
          ZTITRQK-RPAID IS INITIAL AND
          ZTITRQK-REQTY EQ C_TT    AND
***********************************************************************
*---> 자금요청사항.
*---> 사전송금의 송장생성을 은행배정 단계에서 시행하도록 변경.
*--->  By SB, Kang ( 2005/10/15 )
          ZTITRQS-DOCST EQ C_CHAR1.  " 은행배정시 송장구성
*          ztitrqs-docst EQ c_chary.   "EDI전송시 송장구성
***********************************************************************
*          ztitrqs-docst EQ c_charo.

         SELECT COUNT( * )
           INTO G_COUNT
           FROM ZTIVIV00
            FOR ALL ENTRIES IN IT_TAB
          WHERE REQNO  EQ  IT_TAB-REQNO
            AND REQIT  EQ  IT_TAB-REQIT
            AND PRPYN  EQ  'P'.

         IF G_COUNT EQ C_ZERO.
           PERFORM  CREATE_INVOICE_DOCUMENT.
         ENDIF.
       ENDIF.

*> Invoice 문서 생성 BDC 자금팀 요청 CHM2404-00292
       IF ZTITRQK-REQTY EQ C_LC.
         IF  ZTITRQS-DOCST EQ C_CHAR1.
           IF ZTITRQK-LIFNR IS NOT INITIAL.
             CLEAR:  L_LIFNR.
             SELECT SINGLE LIFNR
               INTO L_LIFNR
               FROM ZTITIG14
              WHERE LIFNR EQ ZTITRQK-LIFNR.

             IF L_LIFNR IS NOT INITIAL.
               SELECT COUNT( * )
                INTO G_COUNT
                FROM ZTIVIV00
                 FOR ALL ENTRIES IN IT_TAB
               WHERE REQNO  EQ  IT_TAB-REQNO
                 AND REQIT  EQ  IT_TAB-REQIT
                 AND PRPYN  EQ  'P'.

               IF G_COUNT EQ C_ZERO.
                 PERFORM  CREATE_INVOICE_DOCUMENT_SAVE.
               ENDIF.
             ENDIF.
           ENDIF.
         ENDIF.
       ENDIF.
*> Invoice 문서 생성 BDC 자금팀 요청 CHM2404-00292

       SET PARAMETER ID 'ZTIREQNO' FIELD ZTITRQS-REQNO.
       SET PARAMETER ID 'ZTIAMDSQ' FIELD ZTITRQS-AMDSQ.
       IF NOT ZTITRQS-OPNNO IS INITIAL.
         SET PARAMETER ID 'ZTIOPNNO' FIELD ZTITRQS-OPNNO.
       ENDIF.
       MESSAGE S105 WITH ZTITRQS-REQNO ZTITRQS-AMDSQ.

     ENDIF.
   ENDIF.

 ENDFORM.                    " p8000_save_master_data
*&---------------------------------------------------------------------*
*&      Form  p8100_save_common_data
*&---------------------------------------------------------------------*
 FORM P8100_SAVE_COMMON_DATA  TABLES  PT_TAB    STRUCTURE G_TC_2130_WA
                              USING   P_ZTITRQK STRUCTURE ZTITRQK
                                      P_ZTITRQS STRUCTURE ZTITRQS
                                      P_SUBRC    LIKE      SY-SUBRC
                                      P_MODE.
   DATA: L_DOCTY(9) TYPE C.
   DATA: L_LCONO    TYPE ZTIREQNO.
   DATA: L_AMDSQ    TYPE ZTIAMDSQ.

   CLEAR: P_SUBRC, L_LCONO, L_AMDSQ.

   IF G_TCODE EQ C_CREATE OR  G_TCODE EQ C_CREATE_D.
     IF P_ZTITRQK-REQNO IS INITIAL.
       CALL FUNCTION 'Z_TI_GET_NUMBER_NEXT'
         EXPORTING
           ZMPTY    = P_ZTITRQK-REQTY
*          BUKRS    =
         IMPORTING
           LCONO    = L_LCONO
         EXCEPTIONS
           NOT_TYPE = 1
           OTHERS   = 2.

       IF SY-SUBRC <> 0.
         MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
                 WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
       ENDIF.
     ELSE.
       L_LCONO = P_ZTITRQS-REQNO.
       L_AMDSQ = P_ZTITRQS-AMDSQ.
     ENDIF.
   ELSE.
     L_LCONO = P_ZTITRQS-REQNO.
     L_AMDSQ = P_ZTITRQS-AMDSQ.
   ENDIF.

   IF SY-TCODE EQ C_CREATE_A.
     MOVE L_AMDSQ TO P_ZTITRQK-LSTAS.
   ENDIF.
*
   IF  P_ZTITRQS-CNAM IS INITIAL.
     MOVE: SY-UNAME   TO   P_ZTITRQS-CNAM,
           SY-DATLO   TO   P_ZTITRQS-CDAT,
           SY-TIMLO   TO   P_ZTITRQS-CTME.
   ENDIF.

   MOVE: SY-MANDT   TO   P_ZTITRQS-MANDT,
         L_LCONO    TO   P_ZTITRQS-REQNO,
         L_AMDSQ    TO   P_ZTITRQS-AMDSQ,
         SY-MANDT   TO   P_ZTITRQK-MANDT,
         L_LCONO    TO   P_ZTITRQK-REQNO,
         SY-UNAME   TO   P_ZTITRQS-UNAM,
         SY-DATLO   TO   P_ZTITRQS-UDAT,
         SY-TIMLO   TO   P_ZTITRQS-UTME.

*> 사전송금 문서...
   IF NOT P_ZTITRQS-IVONO IS INITIAL.
     SELECT SINGLE *
       FROM ZTITIVK
      WHERE IVONO EQ P_ZTITRQS-IVONO.
     IF SY-SUBRC NE 0.
       CLEAR: P_ZTITRQS-IVONO.
     ENDIF.
   ENDIF.

   CASE P_MODE.
     WHEN 'Q'.     ">의뢰.
       MOVE: C_CHARC    TO  P_ZTITRQS-DOCST,
             SPACE      TO  P_ZTITRQS-SNDST,
             SY-UNAME   TO  P_ZTITRQS-APPUN,
             SY-DATLO   TO  P_ZTITRQS-APPDT,
             SY-TIMLO   TO  P_ZTITRQS-APPTM.
*> 위탁자재일 경우, Work Flow를 태워야하기 때문에..
       IF ZTITRQS-SETYN EQ C_TRUE.
         P_ZTITRQS-DOCST = SPACE.
       ENDIF.
     WHEN '1'.     ">의뢰취소.
       MOVE: SPACE      TO  P_ZTITRQS-DOCST,
             SPACE      TO  P_ZTITRQS-SNDST,
             SY-UNAME   TO  P_ZTITRQS-APPUN,
             SY-DATLO   TO  P_ZTITRQS-APPDT,
             SY-TIMLO   TO  P_ZTITRQS-APPTM.
     WHEN '5'.     ">상신.
       MOVE: C_CHAR1    TO  P_ZTITRQS-DOCST,
             SPACE      TO  P_ZTITRQS-SNDST.
     WHEN '6'.     ">상신취소.
       MOVE: C_CHARR    TO  P_ZTITRQS-DOCST,
             SPACE      TO  P_ZTITRQS-SNDST,
             SPACE      TO  P_ZTITRQS-EDIYN,
* 20061218 KIMBG: 상신취소시 수입개설 승인 해제
             SPACE      TO  P_ZTITRQS-RQRLS.
* end
     WHEN '7'.     ">반려.
       MOVE: C_CHAR2    TO  P_ZTITRQS-DOCST,
             SPACE      TO  P_ZTITRQS-SNDST.
     WHEN 'A'.     ">접수.
       MOVE: C_CHARA    TO  P_ZTITRQS-DOCST,
             SPACE      TO  P_ZTITRQS-SNDST,
             SY-UNAME   TO  P_ZTITRQS-ACCUN,
             SY-DATLO   TO  P_ZTITRQS-ACCDT,
             SY-TIMLO   TO  P_ZTITRQS-ACCTM.
     WHEN 'E'.     ">접수취소.
       MOVE: C_CHARR    TO  P_ZTITRQS-DOCST,
             SPACE      TO  P_ZTITRQS-SNDST,
             SY-UNAME   TO  P_ZTITRQS-ACCUN,
             SY-DATLO   TO  P_ZTITRQS-ACCDT,
             SY-TIMLO   TO  P_ZTITRQS-ACCTM,
             SPACE      TO  P_ZTITRQS-EDIYN,
* 20060113 simcho: 취소시 수입개설 승인 해제
             SPACE      TO  P_ZTITRQS-RQRLS.
* end
     WHEN 'Y'.     ">신청서만 저장.
       IF P_ZTITRQS-ACCUN IS INITIAL.
         MOVE: C_CHARW    TO  P_ZTITRQS-DOCST,
               SPACE      TO  P_ZTITRQS-SNDST,
               SY-UNAME   TO  P_ZTITRQS-ACCUN,
               SY-DATLO   TO  P_ZTITRQS-ACCDT,
               SY-TIMLO   TO  P_ZTITRQS-ACCTM.
       ENDIF.
       MOVE: C_CHARW    TO  P_ZTITRQS-DOCST.
*      MOVE: c_chary    TO  p_ZTITRQS-docst,
*            space      TO  p_ZTITRQS-sndst,
*            sy-uname   TO  p_ZTITRQS-sndun,
*            sy-datlo   TO  p_ZTITRQS-snddt,
*            sy-timlo   TO  p_ZTITRQS-sndtm.
     WHEN 'I'.     ">신청.

       IF G_EDI_ANSWER EQ 'Y'.
         IF P_ZTITRQK-REQTY EQ C_DA OR
            P_ZTITRQK-REQTY EQ C_DP.
           CONCATENATE P_ZTITRQK-REQTY P_ZTITRQK-REQNO
                  INTO P_ZTITRQS-OPNNO.
         ENDIF.
       ENDIF.

       IF P_ZTITRQS-ACCUN IS INITIAL.
         MOVE: C_CHARY    TO  P_ZTITRQS-DOCST,
               SPACE      TO  P_ZTITRQS-SNDST,
               SY-UNAME   TO  P_ZTITRQS-ACCUN,
               SY-DATLO   TO  P_ZTITRQS-ACCDT,
               SY-TIMLO   TO  P_ZTITRQS-ACCTM.
       ENDIF.
       MOVE: C_CHARY    TO  P_ZTITRQS-DOCST,
             SPACE      TO  P_ZTITRQS-SNDST,
             SY-UNAME   TO  P_ZTITRQS-SNDUN,
*            sy-datlo   TO  p_ZTITRQS-snddt,
*******************************************************
* BEGIN OF LJK
* 글로벌 요청으로 임시 로직 변경
*             sy-timlo   TO  p_ztitrqs-sndtm,
*             sy-uname   TO  p_ztitrqs-apvun,
*             sy-datlo   TO  p_ztitrqs-apvdt,
*             sy-timlo   TO  p_ztitrqs-apvtm.
             SY-TIMLO   TO  P_ZTITRQS-SNDTM.
       IF P_ZTITRQK-REQTY EQ C_TT.
         CASE ZTITIG00-TTAPV.
           WHEN 'X'.
*******************************************************
*        TT 전송 승인 Check처리
*******************************************************
             IF P_ZTITRQS-APVUN IS INITIAL.
               MESSAGE S999 WITH 'TT전송 미승인내역'.
               ROLLBACK WORK.
               MOVE 8  TO P_SUBRC.
               EXIT.
             ENDIF.
           WHEN OTHERS.
             MOVE: SY-UNAME   TO  P_ZTITRQS-APVUN,
                   SY-DATLO   TO  P_ZTITRQS-APVDT,
                   SY-TIMLO   TO  P_ZTITRQS-APVTM.
         ENDCASE.
       ELSE.
         MOVE: SY-UNAME   TO  P_ZTITRQS-APVUN,
               SY-DATLO   TO  P_ZTITRQS-APVDT,
               SY-TIMLO   TO  P_ZTITRQS-APVTM.

       ENDIF.
******************************************************
* END OF LJK

*> EDI record create
       IF G_EDI_ANSWER EQ C_Y.
*> EDI record create
         IF P_ZTITRQS-AMDSQ IS INITIAL.
           CASE P_ZTITRQK-REQTY.
             WHEN C_LC.            L_DOCTY = 'APP700460'.
             WHEN C_PU.            L_DOCTY = 'APPPCR2CG'.
             WHEN C_LO.            L_DOCTY = 'LOCAPP2AD'.
             WHEN C_TT.            L_DOCTY = 'PAYORD450'.
             WHEN C_DA OR C_DP.    L_DOCTY = 'GENRES961'.
             WHEN OTHERS.
               CLEAR: L_DOCTY.
           ENDCASE.
         ELSE.
           CASE P_ZTITRQK-REQTY.
             WHEN C_LC.    L_DOCTY = 'APP707469'.
             WHEN C_PU.    L_DOCTY = 'APPPCR2CG'.
             WHEN C_LO.    L_DOCTY = 'LOCAMR2AE'.
             WHEN C_TT.    L_DOCTY = 'PAYORD450'.
             WHEN C_DA OR C_DP.    L_DOCTY = 'GENRES961'.
             WHEN OTHERS.
               CLEAR: L_DOCTY.
           ENDCASE.
         ENDIF.
         PERFORM  BUILD_EDI_STATUS_RECORD USING ZTSTEDIS-SNCNT
                                                L_DOCTY
                                                P_ZTITRQK-BUKRS
                                                P_ZTITRQS-REQNO
                                                P_ZTITRQS-AMDSQ
                                                P_ZTITRQS-RECID
                                                P_ZTITRQS-RECNM
                                                P_ZTITRQS-RECNO
                                                P_SUBRC.
         IF P_SUBRC NE 0.
           ROLLBACK WORK.      EXIT.
         ENDIF.
         P_ZTITRQS-SNCNT = ZTSTEDIS-SNCNT.
         P_ZTITRQS-REQMT = C_CHARE.
       ELSE.
         P_ZTITRQS-REQMT = C_CHARM.
       ENDIF.

     WHEN 'F'.     ">신청취소.
       MOVE: C_CHARW    TO  P_ZTITRQS-DOCST,
             SPACE      TO  P_ZTITRQS-SNDST,
             SY-UNAME   TO  P_ZTITRQS-ACCUN,
             SY-DATLO   TO  P_ZTITRQS-ACCDT,
             SY-TIMLO   TO  P_ZTITRQS-ACCTM.
*       MOVE: c_charr    TO  p_ztitrqs-docst.

*> EDI record delete
       IF NOT P_ZTITRQS-SNCNT IS INITIAL.
         PERFORM  DELETE_EDI_STATUS_RECORD USING P_ZTITRQS-SNCNT
                                                 P_SUBRC.
*         IF p_subrc NE 0.
*           ROLLBACK WORK.      exit.
*         ENDIF.
         CLEAR: P_SUBRC.
       ENDIF.

       CLEAR: P_ZTITRQS-SNCNT, P_ZTITRQS-REQMT.

     WHEN 'O'.     ">개설.
       MOVE: C_CHARO    TO  P_ZTITRQS-DOCST,
             SY-UNAME   TO  P_ZTITRQS-RCVUN,
             SY-DATLO   TO  P_ZTITRQS-RCVDT,
             SY-TIMLO   TO  P_ZTITRQS-RCVTM.
       IF P_ZTITRQS-SNDST EQ C_CHARS.
         MOVE C_CHARS   TO  P_ZTITRQS-SNDST.
       ELSE.
         MOVE C_CHARM   TO  P_ZTITRQS-SNDST.
       ENDIF.
     WHEN 'N'.     ">개설취소.
       MOVE: C_CHARW    TO  P_ZTITRQS-DOCST,
             SPACE      TO  P_ZTITRQS-SNDST,
             SY-UNAME   TO  P_ZTITRQS-RCVUN,
             SY-DATLO   TO  P_ZTITRQS-RCVDT,
             SY-TIMLO   TO  P_ZTITRQS-RCVTM.
**> EDI record delete
*       PERFORM  delete_edi_status_record USING p_ztitrqs-sncnt
*                                               p_subrc.
       IF P_SUBRC NE 0.
         ROLLBACK WORK.      EXIT.
       ENDIF.

       CLEAR P_ZTITRQS-SNCNT.

     WHEN 'G'.
       IF OK_CODE_OLD EQ 'ZTICLOSE'.
         MOVE: C_TRUE     TO  P_ZTITRQK-DCEND.
       ELSE.
         MOVE: C_FALSE    TO  P_ZTITRQK-DCEND.
       ENDIF.
   ENDCASE.

   IF OK_CODE_OLD EQ 'ZTIDELETE'.
*> status table delete.
     DELETE FROM ZTITRQS WHERE REQNO EQ P_ZTITRQS-REQNO
                           AND AMDSQ EQ P_ZTITRQS-AMDSQ.
     IF SY-SUBRC NE 0.
       ROLLBACK WORK.   MOVE SY-SUBRC  TO P_SUBRC.     EXIT.
     ENDIF.
*> Item table delete
     DELETE FROM ZTITRQP WHERE REQNO EQ P_ZTITRQS-REQNO
                           AND AMDSQ EQ P_ZTITRQS-AMDSQ.
     IF SY-SUBRC NE 0.
       ROLLBACK WORK.   MOVE SY-SUBRC  TO P_SUBRC.     EXIT.
     ENDIF.
*> Header table delete.
     IF P_ZTITRQS-AMDSQ IS INITIAL.
       DELETE FROM ZTITRQK WHERE REQNO EQ P_ZTITRQS-REQNO.
       IF SY-SUBRC NE 0.
         ROLLBACK WORK.   MOVE SY-SUBRC  TO P_SUBRC.     EXIT.
       ENDIF.
     ELSE.
       SELECT MAX( AMDSQ )
         INTO P_ZTITRQK-LSTAS
         FROM ZTITRQS
        WHERE REQNO EQ P_ZTITRQK-REQNO.

       IF SY-SUBRC EQ 0.
*> Header table modify.
         MODIFY ZTITRQK FROM P_ZTITRQK.
         IF SY-SUBRC NE 0.
           ROLLBACK WORK.   MOVE SY-SUBRC  TO P_SUBRC.     EXIT.
         ENDIF.
       ENDIF.
     ENDIF.
*> 포워더 정보.
     DELETE FROM ZTITLC4 WHERE REQNO EQ P_ZTITRQK-REQNO.

*__S 44036: 사후송금 개설 요청 시 최신 송장정보 업데이트 추가
     IF P_ZTITRQK-ANBTY EQ 'A'.  "사후송금
       REFRESH XZTITIVP.

       LOOP AT IT_TAB INTO G_TC_2130_WA.
         CLEAR XZTITIVP.

         SELECT SINGLE *
           INTO CORRESPONDING FIELDS OF XZTITIVP
           FROM ZTITIVP
          WHERE IBLNO EQ G_TC_2130_WA-IBLNO
            AND IBLIT EQ G_TC_2130_WA-IBLIT
            AND REFWR EQ G_TC_2130_WA-NETWR
            AND REQNO EQ G_TC_2130_WA-REQNO
            AND REQIT EQ G_TC_2130_WA-REQIT.

         IF SY-SUBRC EQ 0.
           CLEAR : XZTITIVP-REQNO, XZTITIVP-REQIT.
           APPEND XZTITIVP.
         ENDIF.
       ENDLOOP.

       MODIFY ZTITIVP FROM TABLE XZTITIVP.

       IF SY-SUBRC NE 0.
         ROLLBACK WORK.   MOVE SY-SUBRC  TO P_SUBRC.     EXIT.
       ENDIF.
     ENDIF.

*__E 44036: 사후송금 개설 요청 시 최신 송장정보 업데이트 추가

     EXIT.


   ELSE.
*> Status table modify
     MODIFY ZTITRQS FROM P_ZTITRQS.
     IF SY-SUBRC NE 0.
       ROLLBACK WORK.   MOVE SY-SUBRC  TO P_SUBRC.
       EXIT.
     ENDIF.

     SELECT MAX( AMDSQ )
       INTO P_ZTITRQK-LSTAS
       FROM ZTITRQS
      WHERE REQNO EQ P_ZTITRQK-REQNO.

*> Header table modify.
     MODIFY ZTITRQK FROM P_ZTITRQK.
     IF SY-SUBRC NE 0.
       ROLLBACK WORK.   MOVE SY-SUBRC  TO P_SUBRC.     EXIT.
     ENDIF.

*> Items table modify.
     DELETE FROM ZTITRQP WHERE REQNO EQ P_ZTITRQS-REQNO
                            AND AMDSQ EQ P_ZTITRQS-AMDSQ.
     REFRESH : XZTITRQP.
     LOOP AT IT_TAB INTO G_TC_2130_WA.
       MOVE-CORRESPONDING G_TC_2130_WA TO XZTITRQP.
       XZTITRQP-MANDT = P_ZTITRQS-MANDT.
       XZTITRQP-REQNO = P_ZTITRQS-REQNO.
       XZTITRQP-AMDSQ = P_ZTITRQS-AMDSQ.
*      xZTITRQP-reqit = sy-tabix.
       APPEND XZTITRQP.
     ENDLOOP.
     MODIFY ZTITRQP FROM TABLE XZTITRQP.
     IF SY-SUBRC NE 0.
       ROLLBACK WORK.   MOVE SY-SUBRC  TO P_SUBRC.     EXIT.
     ENDIF.

*> 포워더 정보.
     DELETE FROM ZTITLC4 WHERE REQNO EQ P_ZTITRQK-REQNO.
     REFRESH : XZTITLC4.
     CLEAR: G_COUNT.
     LOOP AT G_TC_2123_ITAB INTO G_TC_2123_WA.
       ADD 1 TO G_COUNT.
       MOVE-CORRESPONDING G_TC_2123_WA TO XZTITLC4.
       XZTITLC4-MANDT = P_ZTITRQS-MANDT.
       XZTITLC4-REQNO = P_ZTITRQS-REQNO.
       XZTITLC4-FWDSQ = G_COUNT.
       APPEND XZTITLC4.
     ENDLOOP.
     IF SY-SUBRC EQ 0.
       MODIFY ZTITLC4  FROM TABLE XZTITLC4.
       IF SY-SUBRC NE 0.
         ROLLBACK WORK.   MOVE SY-SUBRC  TO P_SUBRC.     EXIT.
       ENDIF.
     ENDIF.

*__S 44036: 사후송금 개설 요청 시 최신 송장정보 업데이트 추가
     IF P_ZTITRQK-ANBTY EQ 'A'.  "사후송금
       REFRESH XZTITIVP.

       LOOP AT XZTITRQP.
         CLEAR XZTITIVP.

         SELECT SINGLE *
           INTO CORRESPONDING FIELDS OF XZTITIVP
           FROM ZTITIVP
          WHERE IBLNO EQ XZTITRQP-IBLNO
            AND IBLIT EQ XZTITRQP-IBLIT
            AND REFWR EQ XZTITRQP-NETWR
            AND REQNO EQ SPACE
            AND REQIT EQ SPACE.

         IF SY-SUBRC EQ 0.
           XZTITIVP-REQNO = XZTITRQP-REQNO.
           XZTITIVP-REQIT = XZTITRQP-REQIT.
           APPEND XZTITIVP.
         ENDIF.
       ENDLOOP.

       MODIFY ZTITIVP FROM TABLE XZTITIVP.

       IF SY-SUBRC NE 0.
         ROLLBACK WORK.   MOVE SY-SUBRC  TO P_SUBRC.     EXIT.
       ENDIF.
     ENDIF.
*__E 44036: 사후송금 개설 요청 시 최신 송장정보 업데이트 추가
   ENDIF.

 ENDFORM.                    " p8100_save_common_data
*&---------------------------------------------------------------------*
*&      Form  p8110_save_app700
*&---------------------------------------------------------------------*
 FORM P8110_SAVE_APP700   USING  P_ZTITRQK STRUCTURE ZTITRQK
                                 P_ZTITRQS STRUCTURE ZTITRQS
                                 P_SUBRC.
   CLEAR P_SUBRC.
*> 삭제 모드일 경우.
   IF OK_CODE_OLD EQ 'ZTIDELETE'.
     EXIT.
   ELSE.
     MOVE: P_ZTITRQS-MANDT   TO   ZTITLC1-MANDT,
           P_ZTITRQS-REQNO   TO   ZTITLC1-REQNO,
           P_ZTITRQS-AMDSQ   TO   ZTITLC1-AMDSQ.
*> L/C Header table modify.
     MODIFY ZTITLC1.
     IF SY-SUBRC NE 0.
       ROLLBACK WORK.   MOVE SY-SUBRC  TO P_SUBRC.     EXIT.
     ENDIF.

     MOVE: P_ZTITRQS-MANDT   TO   ZTITLC5-MANDT,
           P_ZTITRQS-REQNO   TO   ZTITLC5-REQNO,
           P_ZTITRQS-AMDSQ   TO   ZTITLC5-AMDSQ.
     MODIFY ZTITLC5.
     IF SY-SUBRC NE 0.
       ROLLBACK WORK.   MOVE SY-SUBRC  TO P_SUBRC.     EXIT.
     ENDIF.

*> L/C Long text table modify.
     LOOP AT XZTITLC2.
       XZTITLC2-MANDT = P_ZTITRQS-MANDT.
       XZTITLC2-REQNO = P_ZTITRQS-REQNO.
       XZTITLC2-AMDSQ = P_ZTITRQS-AMDSQ.
*      APPEND xZTITLC2.
       MODIFY XZTITLC2 INDEX SY-TABIX.
     ENDLOOP.

     MODIFY ZTITLC2 FROM TABLE XZTITLC2.
     IF SY-SUBRC NE 0.
       ROLLBACK WORK.   MOVE SY-SUBRC  TO P_SUBRC.     EXIT.
     ENDIF.

*> L/C 수입승인 table modify.
     LOOP AT XZTITLC3.
       XZTITLC3-MANDT = P_ZTITRQS-MANDT.
       XZTITLC3-REQNO = P_ZTITRQS-REQNO.
       XZTITLC3-AMDSQ = P_ZTITRQS-AMDSQ.
       MODIFY XZTITLC3 INDEX SY-TABIX.
*      APPEND xZTITLC3.
     ENDLOOP.

     MODIFY ZTITLC3 FROM TABLE XZTITLC3.
     IF SY-SUBRC NE 0.
       ROLLBACK WORK.   MOVE SY-SUBRC  TO P_SUBRC.     EXIT.
     ENDIF.
   ENDIF.
 ENDFORM.                    " p8110_save_app700
*&---------------------------------------------------------------------*
*&      Form  p8110_save_apploc
*&---------------------------------------------------------------------*
 FORM P8110_SAVE_APPLOC   USING  P_ZTITRQK STRUCTURE ZTITRQK
                                 P_ZTITRQS STRUCTURE ZTITRQS
                                 P_SUBRC.
   CLEAR P_SUBRC.
*> 삭제 모드일 경우.
   IF OK_CODE_OLD EQ 'ZTIDELETE'.
     EXIT.
   ELSE.
     MOVE: P_ZTITRQS-MANDT   TO   ZTITLO1-MANDT,
           P_ZTITRQS-REQNO   TO   ZTITLO1-REQNO,
           P_ZTITRQS-AMDSQ   TO   ZTITLO1-AMDSQ.
*> Local L/C Header table modify.
     MODIFY ZTITLO1.
     IF SY-SUBRC NE 0.
       ROLLBACK WORK.   MOVE SY-SUBRC  TO P_SUBRC.     EXIT.
     ENDIF.
   ENDIF.
 ENDFORM.                    " p8110_save_apploc
*&---------------------------------------------------------------------*
*&      Form  p8110_save_payord
*&---------------------------------------------------------------------*
 FORM P8110_SAVE_PAYORD   USING  P_ZTITRQK STRUCTURE ZTITRQK
                                 P_ZTITRQS STRUCTURE ZTITRQS
                                 P_SUBRC.
   DATA :  LV_COUNT TYPE I.
   CLEAR P_SUBRC.
*> 삭제 모드일 경우.
   IF OK_CODE_OLD EQ 'ZTIDELETE'.
     EXIT.
   ELSE.
     IF ZTITRQK-ANBTY EQ C_CHARA AND
        ZTITRQK-RPAID IS INITIAL AND
        ZTITRQK-REQTY EQ C_TT    .

       CLEAR : G_COUNT, LV_COUNT.

       SELECT *
         FROM ZTITRQP
        WHERE REQNO = ZTITRQK-REQNO.

         SELECT COUNT( * )
           INTO LV_COUNT
           FROM ZTIVIV00
          WHERE IBLNO  =  ZTITRQP-IBLNO
            AND IBLIT  =  ZTITRQP-IBLIT
            AND LIVST  EQ  'P'.

         G_COUNT = G_COUNT + LV_COUNT.
       ENDSELECT.
* 20110708 송장처리MIRO에서 했을때 주석처리
       IF G_COUNT EQ C_ZERO.
         MESSAGE E173.
       ENDIF.
* END

     ENDIF.

     MOVE: P_ZTITRQS-MANDT   TO   ZTITTT1-MANDT,
           P_ZTITRQS-REQNO   TO   ZTITTT1-REQNO.
*> T/T Header table modify.
     MODIFY ZTITTT1.
     IF SY-SUBRC NE 0.
       ROLLBACK WORK.   MOVE SY-SUBRC  TO P_SUBRC.     EXIT.
     ENDIF.
*> T/T 입금관련 서류 table modify.
     LOOP AT XZTITTT2.
       XZTITTT2-MANDT = P_ZTITRQS-MANDT.
       XZTITTT2-REQNO = P_ZTITRQS-REQNO.
       MODIFY XZTITTT2 INDEX SY-TABIX.
*      APPEND xZTITTT2.
     ENDLOOP.

     MODIFY ZTITTT2 FROM TABLE XZTITTT2.
     IF SY-SUBRC NE 0.
       ROLLBACK WORK.   MOVE SY-SUBRC  TO P_SUBRC.     EXIT.
     ENDIF.

     LOOP AT XZTITTT3.
       XZTITTT3-MANDT = P_ZTITRQS-MANDT.
       XZTITTT3-REQNO = P_ZTITRQS-REQNO.
       MODIFY XZTITTT3 INDEX SY-TABIX.
*      APPEND xZTITTT2.
     ENDLOOP.
     IF SY-SUBRC EQ 0.
       MODIFY ZTITTT3 FROM TABLE XZTITTT3.
       IF SY-SUBRC NE 0.
         ROLLBACK WORK.   MOVE SY-SUBRC  TO P_SUBRC.     EXIT.
       ENDIF.
     ENDIF.

*> 지급확인 관련 table modify.
     REFRESH: XZTITTT4.
     LOOP AT G_TC_2124_ITAB INTO G_TC_2124_WA.
       MOVE-CORRESPONDING G_TC_2124_WA TO XZTITTT4.
       XZTITTT4-MANDT = P_ZTITRQS-MANDT.
       XZTITTT4-REQNO = P_ZTITRQS-REQNO.
       XZTITTT4-PAYRS = ZTITTT4-PAYRS.
       XZTITTT4-IMACD = ZTITTT4-IMACD.
       APPEND XZTITTT4.
     ENDLOOP.
     IF SY-SUBRC EQ 0.
       MODIFY ZTITTT4 FROM TABLE XZTITTT4.
       IF SY-SUBRC NE 0.
         ROLLBACK WORK.   MOVE SY-SUBRC  TO P_SUBRC.     EXIT.
       ENDIF.
     ENDIF.
   ENDIF.
 ENDFORM.                    " p8110_save_payord
*&---------------------------------------------------------------------*
*&      Form  p8110_save_pcrlic
*&---------------------------------------------------------------------*
 FORM P8110_SAVE_PCRLIC   USING  P_ZTITRQK STRUCTURE ZTITRQK
                                 P_ZTITRQS STRUCTURE ZTITRQS
                                 P_SUBRC.
   CLEAR P_SUBRC.
*> 삭제 모드일 경우.
   IF OK_CODE_OLD EQ 'ZTIDELETE'.
     EXIT.
   ELSE.
     MOVE: P_ZTITRQS-MANDT   TO   ZTITPC1-MANDT,
           P_ZTITRQS-REQNO   TO   ZTITPC1-REQNO,
           P_ZTITRQS-AMDSQ   TO   ZTITPC1-AMDSQ.
*> 구매확인서 Header table modify.
     MODIFY ZTITPC1.
     IF SY-SUBRC NE 0.
       ROLLBACK WORK.   MOVE SY-SUBRC  TO P_SUBRC.     EXIT.
     ENDIF.

*> 구매확인서 근거서류 table modify.
     LOOP AT XZTITPC2.
       XZTITPC2-MANDT = P_ZTITRQS-MANDT.
       XZTITPC2-REQNO = P_ZTITRQS-REQNO.
       XZTITPC2-AMDSQ = P_ZTITRQS-AMDSQ.
       MODIFY XZTITPC2 INDEX SY-TABIX.
*      APPEND xZTITPC2.
     ENDLOOP.

     MODIFY ZTITPC2 FROM TABLE XZTITPC2.
     IF SY-SUBRC NE 0.
       ROLLBACK WORK.   MOVE SY-SUBRC  TO P_SUBRC.     EXIT.
     ENDIF.

*> 구매확인서 물품내역 table modify.
     LOOP AT XZTITPC3.
       XZTITPC3-MANDT = P_ZTITRQS-MANDT.
       XZTITPC3-REQNO = P_ZTITRQS-REQNO.
       XZTITPC3-AMDSQ = P_ZTITRQS-AMDSQ.
       MODIFY XZTITPC3 INDEX SY-TABIX.
*      APPEND xZTITPC3.
     ENDLOOP.

     MODIFY ZTITPC3 FROM TABLE XZTITPC3.
     IF SY-SUBRC NE 0.
       ROLLBACK WORK.   MOVE SY-SUBRC  TO P_SUBRC.     EXIT.
     ENDIF.
   ENDIF.

 ENDFORM.                    " p8110_save_pcrlic
*&---------------------------------------------------------------------*
*&      Form  call_smartforms_functioins
*&---------------------------------------------------------------------*
 FORM CALL_SMARTFORMS_FUNCTIOINS USING P_FUNC_MOD_NAME.


   IF G_SSF_NAME EQ C_DEBADV_R OR G_SSF_NAME EQ C_DEBADV2_R.
     CALL FUNCTION P_FUNC_MOD_NAME
       EXPORTING
*        ARCHIVE_INDEX        =
*        ARCHIVE_INDEX_TAB    =
*        ARCHIVE_PARAMETERS   =
         MAIL_APPL_OBJ        = G_MAIL_APPL_OBJ
         MAIL_RECIPIENT       = G_MAIL_RECIPIENT
         MAIL_SENDER          = G_MAIL_SENDER
         USER_SETTINGS        = SPACE
         CONTROL_PARAMETERS   = G_CONTROL_PARAMETERS
         OUTPUT_OPTIONS       = G_OUTPUT_OPTIONS
         ZTITDAK              = ZTITDAK
*        ztitrqs              = ztitrqs
*        ztitlc1              = ztitlc1
*        ztitlc5              = ztitlc5
*        ztitlo1              = ztitlo1
*        ztitpc1              = ztitpc1
*        ztittt1              = ztittt1
*        ztittt1              = ztittt1
       IMPORTING
         DOCUMENT_OUTPUT_INFO = G_DOCUMENT_OUTPUT_INFO
         JOB_OUTPUT_INFO      = G_JOB_OUTPUT_INFO
         JOB_OUTPUT_OPTIONS   = G_JOB_OUTPUT_OPTIONS
       TABLES
         ZTITDAS              = XZTITDAS
         ZTITDAD              = XZTITDAD
         ZTITDAC              = XZTITDAC
*        ztitrqp              = xztitrqp
*        ztitpc3              = xztitpc3
*        ztitpc2              = xztitpc2
       EXCEPTIONS
         FORMATTING_ERROR     = 1
         INTERNAL_ERROR       = 2
         SEND_ERROR           = 3
         USER_CANCELED        = 4.
   ELSE.
     CALL FUNCTION P_FUNC_MOD_NAME
       EXPORTING
*        ARCHIVE_INDEX        =
*        ARCHIVE_INDEX_TAB    =
*        ARCHIVE_PARAMETERS   =
         MAIL_APPL_OBJ        = G_MAIL_APPL_OBJ
         MAIL_RECIPIENT       = G_MAIL_RECIPIENT
         MAIL_SENDER          = G_MAIL_SENDER
         USER_SETTINGS        = SPACE
         CONTROL_PARAMETERS   = G_CONTROL_PARAMETERS
         OUTPUT_OPTIONS       = G_OUTPUT_OPTIONS
         ZTITRQK              = ZTITRQK
         ZTITRQS              = ZTITRQS
         ZTITLC1              = ZTITLC1
         ZTITLC5              = ZTITLC5
         ZTITLO1              = ZTITLO1
         ZTITPC1              = ZTITPC1
         ZTITTT1              = ZTITTT1
       IMPORTING
         DOCUMENT_OUTPUT_INFO = G_DOCUMENT_OUTPUT_INFO
         JOB_OUTPUT_INFO      = G_JOB_OUTPUT_INFO
         JOB_OUTPUT_OPTIONS   = G_JOB_OUTPUT_OPTIONS
       TABLES
         ZTITLC2              = XZTITLC2
         ZTITLC3              = XZTITLC3
         ZTITTT2              = XZTITTT2
         ZTITRQP              = XZTITRQP
         ZTITPC3              = XZTITPC3
         ZTITPC2              = XZTITPC2
       EXCEPTIONS
         FORMATTING_ERROR     = 1
         INTERNAL_ERROR       = 2
         SEND_ERROR           = 3
         USER_CANCELED        = 4.
   ENDIF.

   IF SY-SUBRC NE 0.
     MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
             WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
   ENDIF.

 ENDFORM.                    " call_smartforms_functioins
*&---------------------------------------------------------------------*
*&      Form  GET_OTHERS_TEXT_BY_MASTER_DATA
*&---------------------------------------------------------------------*
*       화면상의 Text를 Master Data 등에서 Read.
*----------------------------------------------------------------------*
 FORM GET_OTHERS_TEXT_BY_MASTER_DATA .

   IF ZTITRQK-BUKRS IS INITIAL.
     CLEAR: T001.
   ELSE.
     SELECT SINGLE * FROM T001
      WHERE BUKRS EQ ZTITRQK-BUKRS.
     IF SY-SUBRC EQ 0.
*> 현지통화.
       MOVE: T001-WAERS TO ZTITRQS-HWAER.
       SELECT SINGLE *
         FROM ZTITIG00
        WHERE BUKRS EQ ZTITRQK-BUKRS.
       IF SY-SUBRC NE 0.
         MESSAGE E035 WITH ZTITRQK-BUKRS.
       ELSE.
*         BREAK-POINT.
**> 지정 포워더 Setting
*         IF sy-dynnr EQ c_scr0100 OR
*            sy-dynnr EQ c_scr0120.
*           ZTITRQK-FWDAS = ztitig00-fwdyn.
*           IF ZTITRQK-FWDAS EQ c_true.
*             PERFORM  set_forwarder_data.
*           ENDIF.
*         ENDIF.
       ENDIF.
       SELECT SINGLE *
         FROM ZTSTIG0
        WHERE BUKRS EQ ZTITRQK-BUKRS.
       IF SY-SUBRC NE 0.
         MESSAGE E012 WITH T001-BUKRS.
       ENDIF.
     ELSE.
       MESSAGE E011 WITH ZTITRQK-BUKRS.
     ENDIF.
   ENDIF.
* 구매조직 SELECT ( T024E )
   IF ZTITRQK-EKORG IS INITIAL.
     CLEAR T024E.
   ELSE.
     CALL FUNCTION 'T024E_SINGLE_READ'
       EXPORTING
         T024E_EKORG = ZTITRQK-EKORG
       IMPORTING
         WT024E      = T024E
       EXCEPTIONS
         NOT_FOUND   = 1
         OTHERS      = 2.

     IF SY-SUBRC NE 0.
       IF SY-CALLD NE C_TRUE.
         MESSAGE W001(MH) WITH ZTITRQK-EKORG.
       ENDIF.
     ENDIF.
   ENDIF.

* 구매그룹 SELECT ( T024 )
   IF ZTITRQK-EKGRP IS INITIAL.
     CLEAR T024.
   ELSE.
     CALL FUNCTION 'MM_ARRANG_PURCHASE_GRP_SELECT'
       EXPORTING
         PURCHASE_GROUP           = ZTITRQK-EKGRP
       IMPORTING
         E_T024                   = T024
       EXCEPTIONS
         PURCHASE_GROUP_NOT_FOUND = 1
         OTHERS                   = 2.

     IF SY-SUBRC NE 0.
       IF SY-CALLD NE C_TRUE.
         MESSAGE W030(MN) WITH ZTITRQK-EKGRP.
       ENDIF.
     ENDIF.
   ENDIF.

*> 지급조건 Text.
   CLEAR: T052U.
   IF NOT ZTITRQS-ZTERM IS INITIAL.
     SELECT *
       FROM T052U UP TO 1 ROWS
      WHERE ZTERM  EQ  ZTITRQS-ZTERM
        AND SPRAS  EQ  SY-LANGU.
     ENDSELECT.
   ENDIF.

   PERFORM  GET_IMPORT_VENDORS_TEXT  USING C_SUCCESS.

 ENDFORM.                    " GET_OTHERS_TEXT_BY_MASTER_DATA
*&---------------------------------------------------------------------*
*&      Form  get_used_payment_term
*&---------------------------------------------------------------------*
 FORM GET_USED_PAYMENT_TERM  TABLES   P_IT_ZTITIG02 STRUCTURE ZTITIG02
                             USING    P_SUBRC  P_TYPE.

   CLEAR: P_SUBRC.

   SELECT BSTYP BSART ZTERM REQTY SETYN AFTYN ILCTY USCDY
          AFTYN PAGRT
     FROM ZTITIG02
     INTO CORRESPONDING FIELDS OF TABLE P_IT_ZTITIG02.

   P_SUBRC = SY-SUBRC.

   IF P_SUBRC NE 0.
     MESSAGE ID 'ZMTI00' TYPE P_TYPE NUMBER 001.
     EXIT.
   ENDIF.

 ENDFORM.                    " get_used_payment_term
*&---------------------------------------------------------------------*
*&      Form  get_transport_terms
*&---------------------------------------------------------------------*
 FORM GET_TRANSPORT_TERMS    TABLES   P_IT_ZTITIG11 STRUCTURE ZTITIG11
                             USING    P_SUBRC  P_TYPE.

   CLEAR: P_SUBRC.

   SELECT * FROM  ZTITIG11
     INTO CORRESPONDING FIELDS OF TABLE P_IT_ZTITIG11.

   P_SUBRC = SY-SUBRC.

   IF P_SUBRC NE 0.
     MESSAGE ID 'ZMTI00' TYPE P_TYPE NUMBER 018.
     EXIT.
   ENDIF.

 ENDFORM.                    " get_used_payment_term

*&---------------------------------------------------------------------*
*&      Form  GET_PURCHASE_ORDER_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
 FORM GET_PURCHASE_ORDER_DATA  TABLES   P_IT_PO   STRUCTURE IT_PO
                                        P_IT_IG02 STRUCTURE ZTITIG02
                               USING    P_EBELN
                                        P_EBELP
                                        P_MTYPE
                                        P_MSGTY.

   REFRESH IT_PONUM.  CLEAR IT_PONUM.
   IF P_EBELP IS INITIAL.
     SELECT *
            INTO CORRESPONDING FIELDS OF TABLE P_IT_PO
            FROM ZTIVPO00
            FOR ALL ENTRIES IN P_IT_IG02
            WHERE EBELN  EQ P_EBELN
            AND   BSTYP  EQ P_IT_IG02-BSTYP
            AND   BSART  EQ P_IT_IG02-BSART
            AND   ZTERM  EQ P_IT_IG02-ZTERM
            AND   REPOS  EQ C_TRUE.
   ELSE.
     SELECT *
            INTO CORRESPONDING FIELDS OF TABLE P_IT_PO
            FROM ZTIVPO00
            FOR ALL ENTRIES IN P_IT_IG02
            WHERE EBELN  EQ P_EBELN
            AND   EBELP  EQ P_EBELP
            AND   BSTYP  EQ P_IT_IG02-BSTYP
            AND   BSART  EQ P_IT_IG02-BSART
            AND   ZTERM  EQ P_IT_IG02-ZTERM
            AND   REPOS  EQ C_TRUE.
   ENDIF.

   IF SY-SUBRC NE 0.
     IF P_EBELP IS INITIAL.
       MESSAGE ID 'ZMTI00' TYPE P_MTYPE NUMBER 101 WITH P_EBELN.
     ELSE.
       MESSAGE ID 'ZMTI00' TYPE P_MTYPE NUMBER 101 WITH P_EBELN P_EBELP.
     ENDIF.
   ENDIF.

   READ TABLE P_IT_PO INDEX 1.
   IF P_IT_PO-BSTYP NE C_BSTYPF AND
      P_IT_PO-BSTYP NE C_BSTYPL.
     MESSAGE ID 'ZMTI00' TYPE P_MTYPE NUMBER 102 WITH P_IT_PO-BSTYP.
   ENDIF.


   PERFORM GET_AVAILABLE_PO_ITEM TABLES P_IT_PO
                                        IT_PONUM
                                 USING  P_MSGTY
                                        C_FALSE.

 ENDFORM.                    " GET_PURCHASE_ORDER_DATA
*&---------------------------------------------------------------------*
*&      Form  GET_available_PO_ITEM
*&---------------------------------------------------------------------*
 FORM GET_AVAILABLE_PO_ITEM  TABLES   P_IT_PO    STRUCTURE IT_PO
                                      P_IT_PONUM STRUCTURE IT_PONUM
                             USING    P_MTYPE
                                      P_DELETE.

   DATA: L_RQMNG  LIKE ZTITRQP-RQMNG.
**
   CLEAR: G_COUNT, G_CNT.

   LOOP AT P_IT_PO.
     G_TABIX = SY-TABIX.
     CLEAR: L_RQMNG.

     SELECT  SUM( RQMNG )
       INTO  P_IT_PO-RQMNGS
       FROM  ZTIVRQ00
      WHERE   EBELN  EQ P_IT_PO-EBELN
        AND   EBELP  EQ P_IT_PO-EBELP
        AND   PPAID  NE C_TRUE
        AND   RPAID  EQ C_FALSE .
*     WHERE ( ebeln  = p_it_po-ebeln
*       AND   ebelp  = p_it_po-ebelp
*       AND   ppaid  = c_false )
*        OR ( ebeln  = p_it_po-ebeln
*       AND   ebelp  = p_it_po-ebelp
*       AND   rpaid  = c_false ).
*
     P_IT_PO-RQMNG =  P_IT_PO-MENGE - P_IT_PO-RQMNGS.

     IF P_IT_PO-RQMNG LE C_ZERO.
       IF P_DELETE EQ C_TRUE.
         DELETE P_IT_PO INDEX G_TABIX.
         CONTINUE.
       ELSE.
         P_IT_PO-RQMNG = 0.
       ENDIF.
     ELSE.
       ADD 1 TO G_CNT.
     ENDIF.

     P_IT_PO-RQMNGL =  P_IT_PO-RQMNG.

     ADD 1 TO G_COUNT.
     P_IT_PO-INDEX = G_COUNT.
     MODIFY P_IT_PO INDEX G_TABIX.

     MOVE P_IT_PO-EBELN TO P_IT_PONUM-EBELN.
     COLLECT P_IT_PONUM.
   ENDLOOP.

   DESCRIBE TABLE P_IT_PO LINES G_LINE.
   IF G_LINE EQ 0.
     MESSAGE ID 'ZMTI00' TYPE P_MTYPE NUMBER 902.
     EXIT.
   ENDIF.

   IF G_CNT EQ 0.
*    MESSAGE ID 'ZMTI00' TYPE c_warning NUMBER 103.
     MESSAGE ID 'ZMTI00' TYPE P_MTYPE NUMBER 103.
   ENDIF.

 ENDFORM.                    " GET_available_PO_ITEM
*&---------------------------------------------------------------------*
*&      Form  p8120_change_document
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM P8120_CHANGE_DOCUMENT .

   DATA: L_OBJECTID        TYPE CDHDR-OBJECTID,
         L_TCODE           TYPE CDHDR-TCODE,
         L_UTIME           TYPE CDHDR-UTIME,
         L_UDATE           TYPE CDHDR-UDATE,
         L_USERNAME        TYPE CDHDR-USERNAME,
         L_CDOC_UPD_OBJECT TYPE CDHDR-CHANGE_IND,
         L_UPD_ICDTXT      TYPE CHAR1,
         L_UPD             TYPE CHAR1,
*        l_upd                   TYPE char1,
         LT_CDTXT          TYPE STANDARD TABLE OF CDTXT
                                      INITIAL SIZE 0.

   CASE SY-TCODE.
     WHEN C_CREATE OR C_CREATE_D.
       L_CDOC_UPD_OBJECT = 'I'.
       L_UPD_ICDTXT      = ' '.
       L_UPD             = ' '.
*      l_upd_eban        = ' '.
*      l_upd_ebkn        = ' '.
     WHEN OTHERS.
       L_CDOC_UPD_OBJECT = 'U'.
       L_UPD_ICDTXT      = 'U'.
       L_UPD             = 'U'.
*      l_upd_eban        = 'U'.
*      l_upd_ebkn        = 'U'.
   ENDCASE.

   IF OK_CODE_OLD EQ 'ZTIDELETE'.
     L_CDOC_UPD_OBJECT = 'D'.
     L_UPD_ICDTXT      = 'D'.
     L_UPD             = 'D'.
*    l_upd_eban        = 'D'.
*    l_upd_ebkn        = 'D'.
   ENDIF.

   L_OBJECTID(12) = ZTITRQS+3(12).

   L_TCODE        = SY-TCODE.
   L_UTIME        = SY-TIMLO.
   L_UDATE        = SY-DATLO.
   L_USERNAME     = SY-UNAME.

   IF G_MODE EQ C_CHARC.  ">생성모드일 경우.
     REFRESH : YZTITRQP.
   ENDIF.

   LOOP AT XZTITRQP.
     XZTITRQP-KZ = L_UPD.
     MODIFY XZTITRQP.
   ENDLOOP.

*  CALL FUNCTION 'ZTILCCHDOC_WRITE_DOCUMENT' IN UPDATE TASK
   CALL FUNCTION 'ZTILCCHDOC_WRITE_DOCUMENT'
     EXPORTING
       OBJECTID                = L_OBJECTID
       TCODE                   = L_TCODE
       UTIME                   = L_UTIME
       UDATE                   = L_UDATE
       USERNAME                = L_USERNAME
*      PLANNED_CHANGE_NUMBER   = ' '
       OBJECT_CHANGE_INDICATOR = L_CDOC_UPD_OBJECT
*      PLANNED_OR_REAL_CHANGES = ' '
*      NO_CHANGE_POINTERS      = ' '
*      UPD_ICDTXT_ZTILCCHDOC   = ' '
       N_ZTITLC1               = ZTITLC1
       O_ZTITLC1               = *ZTITLC1
       UPD_ZTITLC1             = L_UPD
       UPD_ZTITLC2             = L_UPD
       UPD_ZTITLC4             = L_UPD
       N_ZTITLO1               = ZTITLO1
       O_ZTITLO1               = *ZTITLO1
       UPD_ZTITLO1             = L_UPD
       N_ZTITPC1               = ZTITPC1
       O_ZTITPC1               = *ZTITPC1
       UPD_ZTITPC1             = L_UPD
       UPD_ZTITPC2             = L_UPD
       UPD_ZTITPC3             = L_UPD
       N_ZTITRQK               = ZTITRQK
       O_ZTITRQK               = *ZTITRQK
       UPD_ZTITRQK             = L_UPD
       UPD_ZTITRQP             = L_UPD
       N_ZTITRQS               = ZTITRQS
       O_ZTITRQS               = *ZTITRQS
       UPD_ZTITRQS             = L_UPD
       N_ZTITTT1               = ZTITTT1
       O_ZTITTT1               = *ZTITTT1
       UPD_ZTITTT1             = L_UPD
       UPD_ZTITTT2             = L_UPD
       UPD_ZTITTT3             = L_UPD
     TABLES
       ICDTXT_ZTILCCHDOC       = LT_CDTXT
       XZTITLC2                = XZTITLC2
       YZTITLC2                = YZTITLC2
       XZTITLC3                = XZTITLC3
       YZTITLC3                = YZTITLC3
       XZTITLC4                = XZTITLC4
       YZTITLC4                = YZTITLC4
       XZTITPC2                = XZTITPC2
       YZTITPC2                = YZTITPC2
       XZTITPC3                = XZTITPC3
       YZTITPC3                = YZTITPC3
       XZTITRQP                = XZTITRQP
       YZTITRQP                = YZTITRQP
       XZTITTT2                = XZTITTT2
       YZTITTT2                = YZTITTT2
       XZTITTT3                = XZTITTT3
       YZTITTT3                = YZTITTT3
       XZTITTT4                = XZTITTT4
       YZTITTT4                = YZTITTT4.

 ENDFORM.                    " p8120_change_document
*&---------------------------------------------------------------------*
*&      Form  call_print_process
*&---------------------------------------------------------------------*
 FORM CALL_PRINT_PROCESS .

*> GET OUTPUT OPTIONS
   IF IT_PRTCTL[] IS INITIAL.
     REFRESH : IT_PRTCTL.
     CLEAR: IT_PRTCTL.
     REFRESH : IT_PRTCTL.
     CLEAR: IT_PRTCTL.
     IF NOT ZTITRQK-LIFNR IS INITIAL.
       SELECT LIFNR NAME1 LAND1 SPRAS TELFX ADRNR
         INTO CORRESPONDING FIELDS OF TABLE IT_PRTCTL
         FROM LFA1
        WHERE LIFNR EQ ZTITRQK-LIFNR.
     ENDIF.

     IF NOT ZTITRQK-EKGRP IS INITIAL.
       CLEAR: IT_PRTCTL.

       MOVE: T001-LAND1     TO  IT_PRTCTL-LAND1,
             SY-LANGU       TO  IT_PRTCTL-SPRAS,
             T024-EKNAM     TO  IT_PRTCTL-NAME1,
             T024-TELFX     TO  IT_PRTCTL-TELFX,
             T024-SMTP_ADDR TO  IT_PRTCTL-SMTP_ADDR.

       APPEND IT_PRTCTL.

*&     2010.06.10 영문 양식추가
       CLEAR: IT_PRTCTL.
       MOVE: 'EN'           TO  IT_PRTCTL-LIFNR,
             T001-LAND1     TO  IT_PRTCTL-LAND1,
             'EN'           TO  IT_PRTCTL-SPRAS,
             T024-EKNAM     TO  IT_PRTCTL-NAME1,
             T024-TELFX     TO  IT_PRTCTL-TELFX,
             T024-SMTP_ADDR TO  IT_PRTCTL-SMTP_ADDR.

       APPEND IT_PRTCTL.
     ENDIF.

*    IF NOT ZTITRQK-opnbk IS INITIAL.   ">Openning bank.
*      SELECT lifnr name1 land1 spras telfx adrnr
*      INTO CORRESPONDING FIELDS OF TABLE it_prtctl
*      FROM lfa1
*      WHERE lifnr IN ( SELECT lifnr
*                       FROM ZTSTIG3
*                       WHERE epart EQ ZTITRQK-opnbk ).
*    ENDIF.
*    DESCRIBE TABLE it_prtctl LINES g_line.
*    IF g_line EQ c_zero.
*      CLEAR: it_prtctl.
*      MOVE: t001-land1    TO    it_prtctl-land1,
*            sy-langu      TO    it_prtctl-spras.
*      APPEND it_prtctl.
*    ENDIF.
   ENDIF.

*> Get Output Paramenters
   PERFORM GET_OUTPUT_INFORMATION TABLES IT_PRTCTL
                                  USING  G_ANSWER.
   IF G_ANSWER EQ C_Y.

     LOOP AT IT_PRTCTL WHERE FLAG EQ C_TRUE.
*> Begin work.
       SET UPDATE TASK LOCAL.

*> Get SMARTFORM NAME
       PERFORM P7000_SET_SMART_FORM_NAME USING ZTITRQK-REQTY
                                               ZTITRQS-AMDSQ
                                               IT_PRTCTL-DOCTY
                                               G_SSF_NAME.
*> GET THE SMART FORM'S FUNCTION MODULE
       PERFORM GET_SMART_FORM_NAME    USING  G_SSF_NAME
                                             G_FUNC_MOD_NAME.

*> Set Output Paramenters
       PERFORM SET_OUTPUT_INFORMATION USING IT_PRTCTL.
*-> CSR_2013121700006_STA_2013.12.17 김홍직
       IF G_SSF_NAME = C_INF7002_R OR
          G_SSF_NAME = C_INF700_R  OR
          G_SSF_NAME = C_DEBADV_R  OR
          G_SSF_NAME = C_DEBADV2_R OR
          G_SSF_NAME = C_INF7003_R OR
          G_SSF_NAME = C_INF707_R  . "CSR 2014012000015 추가
         G_CONTROL_PARAMETERS-LANGU = '3'.
       ENDIF.
*<- CSR_2013121700006_END_2013.12.17 김홍직
*> Call SmartForms functions
       PERFORM CALL_SMARTFORMS_FUNCTIOINS USING G_FUNC_MOD_NAME.
*> Call SmartForms functions
       PERFORM EXEC_EXTERNAL_SENDING USING IT_PRTCTL.
*> Commit work.
       COMMIT WORK.
     ENDLOOP.
   ELSE.
     MESSAGE S900.
   ENDIF.

 ENDFORM.                    " call_print_process
*&---------------------------------------------------------------------*
*&      Form  SET_OTHERS_FIELDS_BY_ITEMS
*&---------------------------------------------------------------------*
*       아이템의 기타 필드들을 fill
*----------------------------------------------------------------------*
 FORM SET_OTHERS_FIELDS_BY_ITEMS .

   DATA: L_EINDT LIKE EKET-EINDT,
         L_CDAT  LIKE SY-DATUM,
         L_NETWR TYPE NETWR.

   LOOP AT IT_TAB INTO G_TC_2130_WA.
*>Get 플랜트명 및 사업장코드.
     IF NOT G_TC_2130_WA-WERKS IS INITIAL.
       SELECT SINGLE NAME1 J_1BBRANCH
         INTO (G_TC_2130_WA-NAME1, G_TC_2130_WA-BUPLA)
         FROM T001W
        WHERE WERKS  EQ  G_TC_2130_WA-WERKS.
     ELSE.
       CLEAR: G_TC_2130_WA-NAME1, G_TC_2130_WA-BUPLA.
     ENDIF.

*>Get 저장위치명.
     IF NOT G_TC_2130_WA-LGORT IS INITIAL.
       SELECT SINGLE LGOBE
         INTO (G_TC_2130_WA-LGOBE)
         FROM T001L
        WHERE WERKS  EQ  G_TC_2130_WA-WERKS
          AND LGORT  EQ  G_TC_2130_WA-LGORT.
     ELSE.
       CLEAR G_TC_2130_WA-LGOBE.
     ENDIF.

*>Get H/S code.
     IF G_MODE EQ C_CHARC OR
        G_MODE EQ C_CHARM.

** 200500913 simcho H/S code 자재master로 변경
       IF G_TC_2130_WA-MATNR IS NOT INITIAL.
         SELECT SINGLE STAWN
           INTO (G_TC_2130_WA-STAWN)
           FROM MARC
          WHERE MATNR  EQ  G_TC_2130_WA-MATNR
            AND WERKS  EQ  G_TC_2130_WA-WERKS.
       ELSE.
         IF G_TC_2130_WA-STAWN IS INITIAL.
           SELECT SINGLE STAWN
             INTO (G_TC_2130_WA-STAWN)
             FROM EIPO
            WHERE EXNUM EQ ( SELECT EXNUM
                               FROM EKKO
                              WHERE EBELN EQ G_TC_2130_WA-EBELN )
              AND EXPOS EQ G_TC_2130_WA-EBELP.

           IF G_TC_2130_WA-STAWN IS INITIAL.
             SELECT SINGLE STAWN
               INTO (G_TC_2130_WA-STAWN)
               FROM MARC
              WHERE MATNR  EQ  G_TC_2130_WA-MATNR
                AND WERKS  EQ  G_TC_2130_WA-WERKS.

             IF G_TC_2130_WA-STAWN IS INITIAL.
               SELECT CDAT STAWN
                 INTO (L_CDAT, G_TC_2130_WA-STAWN)
                 FROM ZTIVPO01 UP TO 1 ROWS
                WHERE MATNR  EQ  G_TC_2130_WA-MATNR
                  AND WERKS  EQ  G_TC_2130_WA-WERKS
                  AND STAWN  NE  SPACE
                ORDER BY CDAT DESCENDING.
               ENDSELECT.
             ENDIF.
           ENDIF.
         ENDIF.
       ENDIF.
     ENDIF.

*> 텍스트.
     IF G_TC_2130_WA-TXZ01 IS INITIAL AND
        NOT G_TC_2130_WA-MATNR IS INITIAL.
       SELECT SINGLE MAKTX
         INTO G_TC_2130_WA-TXZ01
         FROM MAKT
        WHERE MATNR  EQ  G_TC_2130_WA-MATNR
          AND SPRAS  EQ  SY-LANGU.
     ENDIF.

*>Get 납품일.
     IF NOT G_TC_2130_WA-EBELN IS INITIAL.
       IF G_TC_2130_WA-EINDT IS INITIAL.
         CLEAR: L_EINDT.
         SELECT MIN( EINDT ) INTO G_TC_2130_WA-EINDT
           FROM EKET
          WHERE EBELN EQ G_TC_2130_WA-EBELN
            AND EBELP EQ G_TC_2130_WA-EBELP.

*        IF l_eindt IS INITIAL.
*          CLEAR g_tc_2130_wa-eeind.
*        ELSE.
*          WRITE l_eindt TO g_tc_2130_wa-eeind.
*        ENDIF.
       ENDIF.
     ENDIF.
*> 최종선적일자.
     IF G_TC_2130_WA-LSDAT IS INITIAL.
       READ TABLE IT_ZTITIG11 WITH KEY LAND1 = LFA1-LAND1.
       IF SY-SUBRC EQ 0.
         G_TC_2130_WA-LSDAT = G_TC_2130_WA-EINDT - IT_ZTITIG11-FWDDY.
       ELSE.
         G_TC_2130_WA-LSDAT = G_TC_2130_WA-EINDT - 45.
       ENDIF.
     ENDIF.
*>WBS 요소.
     IF G_MODE EQ C_CHARC OR
        G_MODE EQ C_CHARM.
*      IF NOT g_tc_2130_wa-ebeln IS INITIAL.
       IF ZTITRQS-SETYN EQ C_FALSE.
         IF G_TC_2130_WA-PS_PSP_PNR IS INITIAL AND
            G_TC_2130_WA-NPLNR      IS INITIAL.
           SELECT SINGLE PS_PSP_PNR NPLNR
             INTO (G_TC_2130_WA-PS_PSP_PNR, G_TC_2130_WA-NPLNR)
             FROM EKKN
            WHERE EBELN EQ G_TC_2130_WA-EBELN
              AND EBELP EQ G_TC_2130_WA-EBELP
              AND ZEKKN EQ '01'.
*>
           CLEAR: GS_PROJ.

           IF NOT G_TC_2130_WA-PS_PSP_PNR IS INITIAL.
             PERFORM GET_PARENT_WBS_ELEMENT USING
             G_TC_2130_WA-PS_PSP_PNR
                                                  GS_PROJ.
           ENDIF.
           IF NOT G_TC_2130_WA-NPLNR IS INITIAL.
             PERFORM GET_WBS_ELEMENT_BY_NETWORK
                                            USING G_TC_2130_WA-NPLNR
                                                  GS_PROJ.
           ENDIF.
           G_TC_2130_WA-PS_PSP_PNR = GS_PROJ-PSPNR.
         ENDIF.
*>구매확인서일 경우 ---> 위탁자재.
       ELSE.
         IF G_TC_2130_WA-PS_PSP_PNR IS INITIAL.
           SELECT SINGLE PS_PSP_PNR AUFNR
             INTO (G_TC_2130_WA-PS_PSP_PNR, G_TC_2130_WA-NPLNR)
             FROM MSEG
            WHERE MBLNR   = G_TC_2130_WA-MBLNR
              AND MJAHR   = G_TC_2130_WA-MJAHR
              AND ZEILE   = G_TC_2130_WA-ZEILE.
         ENDIF.

         IF NOT G_TC_2130_WA-PS_PSP_PNR IS INITIAL.
           PERFORM GET_PARENT_WBS_ELEMENT USING G_TC_2130_WA-PS_PSP_PNR
                                                GS_PROJ.
           G_TC_2130_WA-PS_PSP_PNR = GS_PROJ-PSPNR.
         ENDIF.

         IF NOT G_TC_2130_WA-NPLNR IS INITIAL.
           PERFORM GET_WBS_ELEMENT_BY_NETWORK(ZTIR0000)
                                          USING G_TC_2130_WA-NPLNR
                                                GS_PROJ.
           G_TC_2130_WA-PS_PSP_PNR = GS_PROJ-PSPNR.
         ENDIF.

*        if g_tc_2130_wa-netpr is initial.
       ENDIF.
     ENDIF.

     IF ZTITRQS-SETYN EQ C_TRUE.
*> 정가 계산.
       IF G_TC_2130_WA-PEINH IS INITIAL.
         G_TC_2130_WA-PEINH = 1.
       ENDIF.
       IF G_TC_2130_WA-BPUMZ IS INITIAL.
         G_TC_2130_WA-BPUMZ = 1.
       ENDIF.
       IF G_TC_2130_WA-BPUMN IS INITIAL.
         G_TC_2130_WA-BPUMN = 1.
       ENDIF.
     ENDIF.

     IF SY-DYNNR       EQ C_SCR0100 OR
        ZTITRQS-SETYN EQ C_TRUE.

       IF NOT ( ZTITRQK-REQTY EQ C_TT    AND
                ZTITRQK-ANBTY EQ C_CHARA ).
         CALL FUNCTION 'Z_TI_CALC_ITEM_AMOUNT'
           EXPORTING
             PEINH = G_TC_2130_WA-PEINH
             BPUMZ = G_TC_2130_WA-BPUMZ
             BPUMN = G_TC_2130_WA-BPUMN
             MENGE = G_TC_2130_WA-RQMNG
             NETPR = G_TC_2130_WA-NETPR
           CHANGING
             NETWR = G_TC_2130_WA-NETWR.
       ENDIF.
     ENDIF.

     IF SY-DYNNR      EQ  C_SCR0100 OR
        SY-DYNNR      EQ  C_SCR0120.
       IF G_TC_2130_WA-MENGE NE G_TC_2130_WA-RQMNG AND
          ZTITRQS-SETYN     IS INITIAL.
*         CALL FUNCTION 'Z_TI_CALC_ITEM_AMOUNT'
*           EXPORTING
*             peinh = g_tc_2130_wa-peinh
*             bpumz = g_tc_2130_wa-bpumz
*             bpumn = g_tc_2130_wa-bpumn
*             menge = g_tc_2130_wa-rqmng
*             netpr = g_tc_2130_wa-netpr
*           CHANGING
*             netwr = g_tc_2130_wa-netwr.

         SELECT SINGLE PEINH BPUMZ BPUMN MENGE NETPR NETWR
           INTO CORRESPONDING FIELDS OF G_TC_2130_OLD
           FROM EKPO
          WHERE EBELN EQ G_TC_2130_WA-EBELN
            AND EBELP EQ G_TC_2130_WA-EBELP.

         IF SY-SUBRC EQ 0.
           CALL FUNCTION 'Z_TI_CALC_ITEM_AMOUNT'
             EXPORTING
               PEINH = G_TC_2130_OLD-PEINH
               BPUMZ = G_TC_2130_OLD-BPUMZ
               BPUMN = G_TC_2130_OLD-BPUMN
               MENGE = G_TC_2130_OLD-MENGE
               NETPR = G_TC_2130_OLD-NETPR
             CHANGING
               NETWR = G_TC_2130_OLD-NETWR.

           SELECT SUM( NETWR )
             INTO L_NETWR
             FROM ZTIVRQ00
            WHERE EBELN EQ G_TC_2130_WA-EBELN
              AND EBELP EQ G_TC_2130_WA-EBELP.
           G_TC_2130_WA-NETWR = G_TC_2130_OLD-NETWR - L_NETWR.
           IF G_TC_2130_WA-NETWR LT C_ZERO.
             G_TC_2130_WA-NETWR = 0.
           ENDIF.
         ENDIF.
       ENDIF.
     ENDIF.

     MODIFY IT_TAB FROM G_TC_2130_WA.
   ENDLOOP.

 ENDFORM.                    " SET_OTHERS_FIELDS_BY_ITEMS
*&---------------------------------------------------------------------*
*&      Form  get_Import_vendors_text
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
 FORM GET_IMPORT_VENDORS_TEXT USING P_MSGTY.

   DATA: L_TEMP(24)   TYPE C.

   IF ZTITRQK-LIFNR IS INITIAL.
     CLEAR: LFA1.
   ELSE.
     SELECT SINGLE * FROM LFA1
      WHERE LIFNR EQ ZTITRQK-LIFNR.
     IF SY-SUBRC NE 0.
       PERFORM MESSAGE_NOT_FOUND_VENDOR USING 'ZTITRQK'
                                              'LIFNR'
                                              P_MSGTY.
     ENDIF.
   ENDIF.

*> 호선.
   IF ZTITRQK-PSPNR IS INITIAL.
     CLEAR : PROJ.
   ELSE.
     SELECT SINGLE *
       FROM PROJ
      WHERE PSPNR EQ ZTITRQK-PSPNR.

     IF SY-SUBRC NE 0.
       ZTITRQK-PSPNR = SPACE.
       MESSAGE ID 'ZMTI00' TYPE P_MSGTY NUMBER 019.
     ENDIF.
   ENDIF.

   IF ZTITRQK-OFFER IS INITIAL.
     ZTITRQK-OFFER = ZTITRQK-LIFNR.
     *LFA1 = LFA1.
   ELSE.
     IF ZTITRQK-LIFNR EQ ZTITRQK-OFFER.
       *LFA1 = LFA1.
     ELSE.
       SELECT SINGLE * INTO *LFA1
        FROM  LFA1
        WHERE LIFNR EQ ZTITRQK-OFFER.
       IF SY-SUBRC NE 0.
         PERFORM MESSAGE_NOT_FOUND_VENDOR USING 'ZTITRQK'
                                                'OFFER'
                                                P_MSGTY.
       ENDIF.
     ENDIF.
   ENDIF.

   IF ZTITRQK-LIFRE IS INITIAL.
     ZTITRQK-LIFRE = ZTITRQK-LIFNR.
     W_LFA1 = LFA1.
   ELSE.
     IF ZTITRQK-LIFNR EQ ZTITRQK-LIFRE.
       W_LFA1 = LFA1.
     ELSE.
       SELECT SINGLE * INTO W_LFA1
         FROM LFA1
        WHERE LIFNR EQ ZTITRQK-LIFRE.
       IF SY-SUBRC NE 0.
         PERFORM MESSAGE_NOT_FOUND_VENDOR USING 'ZTITRQK'
                                                'LIFRE'
                                                P_MSGTY.
       ENDIF.
     ENDIF.
   ENDIF.

   CLEAR: ZTSTIG3.
   IF NOT ZTITRQK-OPNBK IS INITIAL.
     PERFORM  GET_EDI_PARTNER USING  ZTITRQK-OPNBK
                                     'B'
                                     ZTSTIG3
                                     C_ERROR.
   ENDIF.

   CLEAR: T052U.
   IF NOT ZTITRQS-ZTERM IS INITIAL.
     SELECT SINGLE *
       FROM T052U
      WHERE SPRAS EQ SY-LANGU
        AND ZTERM EQ ZTITRQS-ZTERM.
   ENDIF.

 ENDFORM.                    " get_Import_vendors_text
*&---------------------------------------------------------------------*
*&      Form  check_lc_sub_document_exist
*&---------------------------------------------------------------------*
*       하위문서 존재여부 체크.
*----------------------------------------------------------------------*
 FORM CHECK_LC_SUB_DOCUMENT_EXIST  USING    P_REQNO
                                            P_REQIT
                                            P_MSGTY
                                            P_SUBRC.
   DATA: L_COUNT TYPE I.

   CLEAR: P_SUBRC.

   CHECK NOT P_REQNO IS INITIAL.

*> I/P 문서 체크. 20050728 amend시 가능토록.
*   SELECT COUNT( * ) INTO l_count
*     FROM ztitip1
*    WHERE reqno   EQ  p_reqno.
*
*   IF l_count GT c_zero.
*     IF p_msgty NE c_none.
*       MESSAGE ID 'ZMTI00' TYPE p_msgty NUMBER '109' WITH 'B/L'.
*     ENDIF.
*     p_subrc = 4.
*     EXIT.
*   ENDIF.

*> B/L 문서 체크.
   SELECT COUNT( * ) INTO L_COUNT
     FROM ZTITBLP
    WHERE REQNO   EQ  P_REQNO
      AND REQIT   EQ  P_REQIT.
   IF L_COUNT GT C_ZERO.
     IF P_MSGTY NE C_NONE.
       MESSAGE ID 'ZMTI00' TYPE P_MSGTY NUMBER '109' WITH 'B/L'.
     ENDIF.
     P_SUBRC = 4.
     EXIT.
   ENDIF.

*__S 44036: 사후송금 개설 요청 시 최신 송장정보 업데이트 추가
   DATA : L_REQTY LIKE ZTITRQK-REQTY,
          L_ANBTY LIKE ZTITRQK-ANBTY.

   SELECT SINGLE REQTY ANBTY
     INTO (L_REQTY, L_ANBTY)
     FROM ZTITRQK
    WHERE REQNO EQ P_REQNO.

   IF L_REQTY NE 'TT' OR L_ANBTY NE 'A'."TT 사후송금인 경우 선급금 없음
*> 선급금 문서 체크.
     SELECT COUNT( * ) INTO L_COUNT
       FROM ZTITIVP
      WHERE REQNO   EQ  P_REQNO
        AND REQIT   EQ  P_REQIT.
     IF L_COUNT GT C_ZERO.
       IF P_MSGTY NE C_NONE.
         MESSAGE ID 'ZMTI00' TYPE P_MSGTY NUMBER '109' WITH '선급금'.
       ENDIF.
       P_SUBRC = 4.
       EXIT.
     ENDIF.
   ENDIF.
*__E 44036: 사후송금 개설 요청 시 최신 송장정보 업데이트 추가

 ENDFORM.                    " check_lc_sub_document_exist
*&---------------------------------------------------------------------*
*&      Form  SET_INITIAL_VALUE
*&---------------------------------------------------------------------*
 FORM SET_INITIAL_VALUE .

*> 문서 종류.
   G_DOCUMENT = C_LC.

   REFRESH: IT_TAB, IT_PONUM, IT_PO,
            XZTITLC2, YZTITLC2,
            XZTITLC3, YZTITLC3,
            XZTITLC4, YZTITLC4,
            XZTITPC2, YZTITPC2,
            XZTITPC3, YZTITPC3,
            XZTITRQP, YZTITRQP,
            XZTITTT2, YZTITTT2,
            XZTITTT3, YZTITTT3.

   CLEAR:   IT_TAB, IT_PONUM, IT_PO,
            XZTITLC2, YZTITLC2,
            XZTITLC3, YZTITLC3,
            XZTITLC4, YZTITLC4,
            XZTITPC2, YZTITPC2,
            XZTITPC3, YZTITPC3,
            XZTITRQP, YZTITRQP,
            XZTITTT2, YZTITTT2,
            XZTITTT3, YZTITTT3,
            ZTITIG00,
            ZTITRQK,    ">수입의뢰 Header
           *ZTITRQK,    ">수입의뢰 Header
            ZTITRQS,    ">수입의뢰 Status
           *ZTITRQS,    ">수입의뢰 Status
            ZTITRQP,    ">수입의뢰 Items
            ZTITLO1,    ">LOCAL  L/C MAIN (LOCAPP/LOCAMR)
           *ZTITLO1,    ">LOCAL  L/C MAIN (LOCAPP/LOCAMR)
            ZTITPC1,    ">구매확인서 MAIN (APPPCR/PCRLIC)
           *ZTITPC1,    ">구매확인서 MAIN (APPPCR/PCRLIC)
            ZTITPC2,    ">구매확인서 ITEM (근거서류)
           *ZTITPC2,    ">구매확인서 ITEM (근거서류)
            ZTITPC3,    ">구매확인서 ITEM (물품내역)
           *ZTITPC3,    ">구매확인서 ITEM (물품내역)
            ZTITLC1,    ">MASTER L/C MAIN (APP700/APP707)
           *ZTITLC1,    ">MASTER L/C MAIN (APP700/APP707)
            ZTITLC2,    ">MASTER L/C ITEM (Long text)
           *ZTITLC2,    ">MASTER L/C ITEM (Long text)
            ZTITLC5,    ">[Import] MASTER L/C MAIN (EDI 수신 데이타)
            ZTITTT1,    ">지급지시서 T/T MAIN (PAYORD)
           *ZTITTT1,    ">지급지시서 T/T MAIN (PAYORD)
            ZTITTT2,    ">지급지시서 T/T ITEM (입금관련서류)
           *ZTITTT2,    ">지급지시서 T/T ITEM (입금관련서류)
            ZTITTT3,    ">지급지시서 T/T ITEM (부가수수료)
           *ZTITTT3,    ">지급지시서 T/T ITEM (부가수수료)
            LFA1,
           *LFA1,
            W_LFA1,
            W_LFA1_BANK.

 ENDFORM.                    " SET_INITIAL_VALUE
*&---------------------------------------------------------------------*
*&      Form  double_click_event
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
 FORM DOUBLE_CLICK_EVENT .

   CHECK G_FIELDNAME IS INITIAL.

   GET CURSOR LINE G_FINDLINE.
   IF SY-SUBRC EQ 0.
     GET CURSOR FIELD G_FIELDNAME.
     IF SY-SUBRC EQ 0.
       G_FINDSCR = SY-DYNNR.
*****************************************************************
* 20070302 simcho by 박혁세 K
* page down 후 double click시 오류 수정
*****************************************************************
       IF SY-TCODE = 'ZTIT003'.
         G_FINDLINE = TC_2130-TOP_LINE + G_FINDLINE - 1.
       ENDIF.
*****************************************************************

       READ TABLE IT_TAB INTO G_TC_2130_WA INDEX G_FINDLINE.
       IF SY-SUBRC NE 0.
         EXIT.
       ENDIF.
       CHECK OK_CODE EQ 'ZTISELECT'.   ">문서선택.

       CASE G_FIELDNAME.
         WHEN 'ZTISRQIT-EBELN' OR 'ZTISRQIT-EBELP'.
           PERFORM DISPLAY_PURCHASE_ORDER USING G_TC_2130_WA-EBELN
                                                G_TC_2130_WA-EBELP.
         WHEN 'ZTISRQIT-MBLNR' OR 'ZTISRQIT-MJAHR' OR 'ZTISRQIT-ZEILE'.
           PERFORM DISPLAY_MATERIAL_DOC   USING G_TC_2130_WA-MBLNR
                                                G_TC_2130_WA-MJAHR
                                                G_TC_2130_WA-ZEILE
                                                ZTITRQK-BUKRS.
         WHEN 'ZTISRQIT-MATNR'.
           PERFORM DISPLAY_MATERIAL_MASTER USING G_TC_2130_WA-MATNR
                                                 G_TC_2130_WA-WERKS
                                                 G_TC_2130_WA-LGORT.
       ENDCASE.
     ENDIF.
   ELSE.
     GET CURSOR FIELD G_FIELDNAME.
     IF SY-SUBRC EQ 0.
       G_FINDSCR = SY-DYNNR.
       CHECK OK_CODE EQ 'ZTISELECT'.   ">문서선택.

       CASE G_FIELDNAME.
         WHEN 'ZTITRQK-PSPNR'.
           PERFORM DISPLAY_PROJECT_MASTER USING ZTITRQK-PSPNR.
         WHEN 'ZTITRQK-LIFNR'.
           PERFORM DISPLAY_VENDOR_MASTER USING ZTITRQK-LIFNR
                                               ZTITRQK-EKORG.
         WHEN 'ZTITRQK-OFFER'.
           PERFORM DISPLAY_VENDOR_MASTER USING ZTITRQK-OFFER
                                               ZTITRQK-EKORG.
*        WHEN 'ZTITRQK-OPNBK'.
*          PERFORM display_vendor_master USING ZTITRQK-opnbk
*                                              ZTITRQK-ekorg.
         WHEN 'ZTITRQK-LIFRE'.
           PERFORM DISPLAY_VENDOR_MASTER USING ZTITRQK-LIFRE
                                               ZTITRQK-EKORG.
       ENDCASE.
     ENDIF.
   ENDIF.

 ENDFORM.                    " double_click_event
*&---------------------------------------------------------------------*
*&      Module  pai_scr2210_sub1_subscreen  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
 MODULE PAI_SCR2210_SUB1_SUBSCREEN INPUT.

   CALL FUNCTION 'Z_TI_OTHERS_TEXT_IMPORT'
     EXPORTING
       LCITY  = C_CHAR7
       MODE   = G_MODE
     TABLES
       IT_TAB = IT_LCTEXT.

 ENDMODULE.                 " pai_scr2210_sub1_subscreen  INPUT
*&---------------------------------------------------------------------*
*&      Module  pai_scr2210_sub2_subscreen  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
 MODULE PAI_SCR2210_SUB2_SUBSCREEN INPUT.

   CALL FUNCTION 'Z_TI_OTHERS_TEXT_IMPORT'
     EXPORTING
       LCITY  = C_CHAR8
       MODE   = G_MODE
     TABLES
       IT_TAB = IT_LCTEXT.

 ENDMODULE.                 " pai_scr2210_sub2_subscreen  INPUT
*&---------------------------------------------------------------------*
*&      Module  pai_scr2210_sub3_subscreen  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
 MODULE PAI_SCR2210_SUB3_SUBSCREEN INPUT.

   CALL FUNCTION 'Z_TI_OTHERS_TEXT_IMPORT'
     EXPORTING
       LCITY  = C_CHAR9
       MODE   = G_MODE
     TABLES
       IT_TAB = IT_LCTEXT.

 ENDMODULE.                 " pai_scr2210_sub3_subscreen  INPUT
*&---------------------------------------------------------------------*
*&      Form  p8111_edi_table_clear
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
 FORM P8111_EDI_TABLE_CLEAR  USING    P_ZTITRQS STRUCTURE ZTITRQS
                                      P_SUBRC.

   CLEAR: P_SUBRC.

*> L/C 관련 테이블.
   DELETE FROM ZTITLC1 WHERE REQNO EQ P_ZTITRQS-REQNO
                          AND AMDSQ EQ P_ZTITRQS-AMDSQ.
*  IF sy-subrc NE 0.
*    ROLLBACK WORK.   MOVE sy-subrc  TO p_subrc.     EXIT.
*  ENDIF.
   DELETE FROM ZTITLC2 WHERE REQNO EQ P_ZTITRQS-REQNO
                          AND AMDSQ EQ P_ZTITRQS-AMDSQ.
*  IF sy-subrc NE 0.
*    ROLLBACK WORK.   MOVE sy-subrc  TO p_subrc.     EXIT.
*  ENDIF.
   DELETE FROM ZTITLC3 WHERE REQNO EQ P_ZTITRQS-REQNO
                         AND AMDSQ EQ P_ZTITRQS-AMDSQ.

*  DELETE FROM ZTITLC4 WHERE reqno EQ p_ZTITRQS-reqno.

*  IF sy-subrc NE 0.
*    ROLLBACK WORK.   MOVE sy-subrc  TO p_subrc.     EXIT.
*  ENDIF.
*> L/C 관련 테이블.
   DELETE FROM ZTITLC5 WHERE REQNO EQ P_ZTITRQS-REQNO
                          AND AMDSQ EQ P_ZTITRQS-AMDSQ.

*> 구매확인서 관련 테이블.
   DELETE FROM ZTITPC1 WHERE REQNO EQ P_ZTITRQS-REQNO
                          AND AMDSQ EQ P_ZTITRQS-AMDSQ.
*  IF sy-subrc NE 0.
*    ROLLBACK WORK.   MOVE sy-subrc  TO p_subrc.     EXIT.
*  ENDIF.
   DELETE FROM ZTITPC2 WHERE REQNO EQ P_ZTITRQS-REQNO
                          AND AMDSQ EQ P_ZTITRQS-AMDSQ.
*  IF sy-subrc NE 0.
*    ROLLBACK WORK.   MOVE sy-subrc  TO p_subrc.     EXIT.
*  ENDIF.
   DELETE FROM ZTITPC3 WHERE REQNO EQ P_ZTITRQS-REQNO
                          AND AMDSQ EQ P_ZTITRQS-AMDSQ.
*  IF sy-subrc NE 0.
*    ROLLBACK WORK.   MOVE sy-subrc  TO p_subrc.     EXIT.
*  ENDIF.

*> Local L/C 관련 테이블.
   DELETE FROM ZTITLO1 WHERE REQNO EQ P_ZTITRQS-REQNO
                          AND AMDSQ EQ P_ZTITRQS-AMDSQ.
*  IF sy-subrc NE 0.
*    ROLLBACK WORK.   MOVE sy-subrc  TO p_subrc.     EXIT.
*  ENDIF.

*> 전신환 송금 관련 테이블.
   DELETE FROM ZTITTT1 WHERE REQNO EQ P_ZTITRQS-REQNO.
*  IF sy-subrc NE 0.
*    ROLLBACK WORK.   MOVE sy-subrc  TO p_subrc.     EXIT.
*  ENDIF.
   DELETE FROM ZTITTT2 WHERE REQNO EQ P_ZTITRQS-REQNO.
*  IF sy-subrc NE 0.
*    ROLLBACK WORK.   MOVE sy-subrc  TO p_subrc.     EXIT.
*  ENDIF.
   DELETE FROM ZTITTT3 WHERE REQNO EQ P_ZTITRQS-REQNO.
   DELETE FROM ZTITTT4 WHERE REQNO EQ P_ZTITRQS-REQNO.
*
 ENDFORM.                    " p8111_edi_table_clear
*&---------------------------------------------------------------------*
*&      Form  set_item_number_build
*&---------------------------------------------------------------------*
*       아이템 번호를 생성함.
*----------------------------------------------------------------------*
 FORM SET_ITEM_NUMBER_BUILD  TABLES   P_IT_TAB   LIKE      IT_TAB
                             USING    P_ZTITRQS STRUCTURE ZTITRQS.

   DATA: L_LPONR LIKE P_ZTITRQS-LPONR.

   IF G_MODE EQ C_CHARC.
     CLEAR: L_LPONR.
     LOOP AT P_IT_TAB.
       ADD 1 TO L_LPONR.
       MOVE L_LPONR TO P_IT_TAB-REQIT.
       MODIFY P_IT_TAB.
     ENDLOOP.
     MOVE L_LPONR TO P_ZTITRQS-LPONR.
   ELSE.
     CLEAR: G_LINES.
     LOOP AT P_IT_TAB.
       IF NOT P_IT_TAB-REQIT IS INITIAL.
         PERFORM CHECK_LC_SUB_DOCUMENT_EXIST USING P_IT_TAB-REQNO
                                                   P_IT_TAB-REQIT
                                                   C_NONE
                                                   G_SUBRC.
         IF G_SUBRC NE C_ZERO.
           ADD 1 TO G_LINES.
           EXIT.
         ENDIF.
       ENDIF.
     ENDLOOP.
     IF G_LINES GT C_ZERO.
       CLEAR: L_LPONR.
       LOOP AT P_IT_TAB.
         IF P_IT_TAB-REQIT IS INITIAL.
           ADD 1 TO P_ZTITRQS-LPONR.
           MOVE P_ZTITRQS-LPONR TO P_IT_TAB-REQIT.
         ENDIF.
         MODIFY P_IT_TAB.
       ENDLOOP.
     ELSE.
       CLEAR: L_LPONR.
       LOOP AT P_IT_TAB.
         ADD 1 TO L_LPONR.
         MOVE L_LPONR TO P_IT_TAB-REQIT.
         MODIFY P_IT_TAB.
       ENDLOOP.
       MOVE L_LPONR TO P_ZTITRQS-LPONR.
     ENDIF.
   ENDIF.
   CLEAR: L_LPONR.
   LOOP AT P_IT_TAB.
     IF P_IT_TAB-REQIT GT L_LPONR.
       MOVE P_IT_TAB-REQIT TO L_LPONR.
     ENDIF.
   ENDLOOP.
   MOVE L_LPONR TO P_ZTITRQS-LPONR.

 ENDFORM.                    " set_item_number_build
*&---------------------------------------------------------------------*
*&      Form  set_function_by_BUSINESS
*&---------------------------------------------------------------------*
 FORM SET_FUNCTION_BY_BUSINESS .

   CASE G_TCODE.
     WHEN C_CREATE OR C_CREATE_D OR C_CREATE_A OR          ">생성.
          C_CHANGE.                                        ">변경.
       IF ZTITRQS-DOCST NE SPACE.
*        MOVE 'ZTIREQUEST'     TO ftab-fcode.   APPEND ftab. ">의뢰.
       ELSE.
         MOVE 'ZTIREQCANC'     TO FTAB-FCODE.   APPEND FTAB. ">취소.
       ENDIF.
     WHEN C_ACCEPTANCE.                                      ">접수.
       IF ZTITRQS-DOCST EQ 'A'.
         MOVE 'ZTIACCEPT'      TO FTAB-FCODE.   APPEND FTAB. ">접수.
       ENDIF.
       IF ZTITRQS-DOCST EQ 'R'.
         MOVE 'ZTIRETURN'      TO FTAB-FCODE.   APPEND FTAB. ">접수.
       ENDIF.
     WHEN C_APPLY.                                          ">개설관리.
       MOVE 'ZTISEND'         TO FTAB-FCODE.   APPEND FTAB. ">접수.
       IF ZTITRQS-DOCST EQ 'O'.
         MOVE 'ZTIRECVC'      TO FTAB-FCODE.   APPEND FTAB. ">접수.
       ELSE.
         MOVE 'ZTIRECVC'      TO FTAB-FCODE.   APPEND FTAB. ">접수.
       ENDIF.
       IF ZTITRQS-DOCST EQ '1'.
         MOVE 'ZTIAPPLY'      TO FTAB-FCODE.   APPEND FTAB. ">상신.
       ELSE.
         MOVE 'ZTIAPPLYC'     TO FTAB-FCODE.   APPEND FTAB. ">상신.
       ENDIF.
     WHEN 'ZTIT009'.                                        ">신청관리.
       IF ZTITRQS-DOCST EQ '1' OR
          ZTITRQS-DOCST EQ 'N'.
         MOVE 'ZTISENDC'        TO FTAB-FCODE.   APPEND FTAB. ">상신.
         MOVE 'ZTIAPPLYC'       TO FTAB-FCODE.   APPEND FTAB. ">반려.
       ELSE.
         IF ZTITRQS-DOCST NE 'Y'.
           MOVE 'ZTISEND'         TO FTAB-FCODE.   APPEND FTAB. ">접수.
         ENDIF.
       ENDIF.
     WHEN C_OPEN.
       IF ZTITRQS-DOCST NE 'O'.
         MOVE 'ZTISENDC'      TO FTAB-FCODE.   APPEND FTAB. ">개설취소.
       ENDIF.
     WHEN C_CLOSE.
       IF ZTITRQK-DCEND EQ 'X'.
         MOVE 'ZTICLOSE'      TO FTAB-FCODE.   APPEND FTAB. ">종료.
       ELSE.
         MOVE 'ZTICLOSEC'     TO FTAB-FCODE.   APPEND FTAB. ">종료취소.
       ENDIF.
     WHEN OTHERS.
   ENDCASE.

   IF ZTITRQK-REQTY EQ 'LO' OR
      ZTITRQK-REQTY EQ 'PU'.
     MOVE 'ZTISPLIT'     TO FTAB-FCODE.   APPEND FTAB. ">금액분할.
   ENDIF.

   IF ZTITRQS-AMDSQ EQ 0.
     MOVE 'ZTIAMEND'     TO FTAB-FCODE.   APPEND FTAB. ">변경항목.
   ENDIF.

   IF ( ZTITRQK-REQTY EQ C_TT      AND
        ZTITRQK-ANBTY EQ C_CHARA ).
     MOVE 'ZTITRON'      TO FTAB-FCODE.   APPEND FTAB. ">개요펼치기.
     MOVE 'ZTITROFF'     TO FTAB-FCODE.   APPEND FTAB. ">개요닫기.
     MOVE 'ZTIHSCODE'    TO FTAB-FCODE.   APPEND FTAB. ">개요닫기.
     MOVE 'ZTISPLIT'     TO FTAB-FCODE.   APPEND FTAB. ">개요닫기.
   ENDIF.

   IF ZTITRQK-REQTY EQ C_DA OR
      ZTITRQK-REQTY EQ C_DP OR
      ZTITRQK-REQTY EQ C_ZZ.
     MOVE 'ZTIEDI'     TO FTAB-FCODE.   APPEND FTAB. ">개요닫기.
   ELSE.
     IF NOT ZTITIG00 IS INITIAL.
       IF ZTITIG00-RQEDS EQ C_CHARB.
         IF G_MODE EQ C_CHARC OR
            G_MODE EQ C_CHARM.
           MOVE 'ZTIEDI'       TO FTAB-FCODE.   APPEND FTAB. ">EDI.
         ENDIF.
       ENDIF.
     ENDIF.
   ENDIF.

   IF ZTITRQK-BUKRS NE '3000'.  "엠트론 전용
     MOVE 'ZTIRQLNK'     TO FTAB-FCODE.   APPEND FTAB.
   ENDIF.

*> 금액수정 Setting에 따라서..
   IF ZTITIG00-AMTCC EQ C_FALSE.
     MOVE 'ZTISPLIT'       TO FTAB-FCODE.   APPEND FTAB. ">EDI.
   ENDIF.

 ENDFORM.                    " set_function_by_BUSINESS
*&---------------------------------------------------------------------*
*&      Form  read_edi_table_document
*&---------------------------------------------------------------------*
 FORM READ_EDI_TABLE_DOCUMENT .

   CLEAR : G_TC_2211_ITAB,
           G_TC_2211_WA,
           G_TC_2212_ITAB,
           G_TC_2212_WA,
           G_TC_2213_ITAB,
           G_TC_2213_WA,
           G_TC_2216_ITAB,
           G_TC_2216_WA.

   REFRESH : G_TC_2211_ITAB,
             G_TC_2212_ITAB,
             G_TC_2213_ITAB,
             G_TC_2216_ITAB.

*S__ 신용장 변경에 따른 수정 20181010 BY SDW
*>기타조건 상품(용역), 구비서류, 부가조건 특별지급 (생성, 삭제, 변경)
   CLEAR : G_TC_2216_ITAB_1_1,
           G_TC_2216_ITAB_1_2,
           G_TC_2216_ITAB_1_3,
           G_TC_2216_ITAB_2_1,
           G_TC_2216_ITAB_2_2,
           G_TC_2216_ITAB_2_3,
           G_TC_2216_ITAB_3_1,
           G_TC_2216_ITAB_3_2,
           G_TC_2216_ITAB_3_3,
           G_TC_2216_ITAB_4_1,
           G_TC_2216_ITAB_4_2,
           G_TC_2216_ITAB_4_3,
           G_TC_2216_WA_1_1,
           G_TC_2216_WA_1_2,
           G_TC_2216_WA_1_3,
           G_TC_2216_WA_2_1,
           G_TC_2216_WA_2_2,
           G_TC_2216_WA_2_3,
           G_TC_2216_WA_3_1,
           G_TC_2216_WA_3_2,
           G_TC_2216_WA_3_3,
           G_TC_2216_WA_4_1,
           G_TC_2216_WA_4_2,
           G_TC_2216_WA_4_3.

   REFRESH : G_TC_2216_ITAB_1_1,
             G_TC_2216_ITAB_1_2,
             G_TC_2216_ITAB_1_3,
             G_TC_2216_ITAB_2_1,
             G_TC_2216_ITAB_2_2,
             G_TC_2216_ITAB_2_3,
             G_TC_2216_ITAB_3_1,
             G_TC_2216_ITAB_3_2,
             G_TC_2216_ITAB_3_3,
             G_TC_2216_ITAB_4_1,
             G_TC_2216_ITAB_4_2,
             G_TC_2216_ITAB_4_3.
*E__ 신용장 변경에 따른 수정 20181010 BY SDW



   LOOP AT XZTITLC2.
     CASE XZTITLC2-LCITY.
       WHEN '7'. "상품명세(TEXT)-상품명/수량/금액.
         MOVE-CORRESPONDING XZTITLC2 TO  G_TC_2211_WA.
         APPEND G_TC_2211_WA TO G_TC_2211_ITAB.
       WHEN '8'.  "기타부가조건(TEXT).
         MOVE-CORRESPONDING XZTITLC2 TO G_TC_2212_WA.
         APPEND G_TC_2212_WA TO G_TC_2212_ITAB.
       WHEN '9'.  "Other Document(TEXT).
         MOVE-CORRESPONDING XZTITLC2 TO G_TC_2213_WA.
         APPEND G_TC_2213_WA TO G_TC_2213_ITAB.
       WHEN 'A'.  "기타조건변경사항(TEXT).
         MOVE-CORRESPONDING XZTITLC2 TO G_TC_2216_WA.
         APPEND G_TC_2216_WA TO G_TC_2216_ITAB.

*S__ 신용장 변경에 따른 수정 20181010 BY SDW
*>기타조건 상품(용역), 구비서류, 부가조건 특별지급 (생성, 삭제, 변경)
       WHEN 'B'.
         MOVE-CORRESPONDING XZTITLC2 TO G_TC_2216_WA_1_1.
         APPEND G_TC_2216_WA_1_1 TO G_TC_2216_ITAB_1_1.

       WHEN 'C'.
         MOVE-CORRESPONDING XZTITLC2 TO G_TC_2216_WA_1_2.
         APPEND G_TC_2216_WA_1_2 TO G_TC_2216_ITAB_1_2.

       WHEN 'D'.
         MOVE-CORRESPONDING XZTITLC2 TO G_TC_2216_WA_1_3.
         APPEND G_TC_2216_WA_1_3 TO G_TC_2216_ITAB_1_3.

       WHEN 'E'.
         MOVE-CORRESPONDING XZTITLC2 TO G_TC_2216_WA_2_1.
         APPEND G_TC_2216_WA_2_1 TO G_TC_2216_ITAB_2_1.

       WHEN 'F'.
         MOVE-CORRESPONDING XZTITLC2 TO G_TC_2216_WA_2_2.
         APPEND G_TC_2216_WA_2_2 TO G_TC_2216_ITAB_2_2.

       WHEN 'G'.
         MOVE-CORRESPONDING XZTITLC2 TO G_TC_2216_WA_2_3.
         APPEND G_TC_2216_WA_2_3 TO G_TC_2216_ITAB_2_3.

       WHEN 'H'.
         MOVE-CORRESPONDING XZTITLC2 TO G_TC_2216_WA_3_1.
         APPEND G_TC_2216_WA_3_1 TO G_TC_2216_ITAB_3_1.

       WHEN 'I'.
         MOVE-CORRESPONDING XZTITLC2 TO G_TC_2216_WA_3_2.
         APPEND G_TC_2216_WA_3_2 TO G_TC_2216_ITAB_3_2.

       WHEN 'J'.
         MOVE-CORRESPONDING XZTITLC2 TO G_TC_2216_WA_3_3.
         APPEND G_TC_2216_WA_3_3 TO G_TC_2216_ITAB_3_3.

       WHEN 'K'.
         MOVE-CORRESPONDING XZTITLC2 TO G_TC_2216_WA_4_1.
         APPEND G_TC_2216_WA_4_1 TO G_TC_2216_ITAB_4_1.

       WHEN 'L'.
         MOVE-CORRESPONDING XZTITLC2 TO G_TC_2216_WA_4_2.
         APPEND G_TC_2216_WA_4_2 TO G_TC_2216_ITAB_4_2.

       WHEN 'M'.
         MOVE-CORRESPONDING XZTITLC2 TO G_TC_2216_WA_4_3.
         APPEND G_TC_2216_WA_4_3 TO G_TC_2216_ITAB_4_3.
*E__ 신용장 변경에 따른 수정 20181010 BY SDW

       WHEN OTHERS.
     ENDCASE.
   ENDLOOP.

   CLEAR : G_TC_2214_ITAB,
           G_TC_2214_WA.
   LOOP AT XZTITLC3.
     MOVE-CORRESPONDING XZTITLC3 TO G_TC_2214_WA.
     APPEND G_TC_2214_WA TO G_TC_2214_ITAB.
   ENDLOOP.

   CLEAR : G_TC_2220_1_ITAB,
           G_TC_2220_1_WA.
   LOOP AT XZTITPC2.
     MOVE-CORRESPONDING XZTITPC2 TO G_TC_2220_1_WA.
     APPEND G_TC_2220_1_WA TO  G_TC_2220_1_ITAB.
   ENDLOOP.

   CLEAR : G_TC_2220_2_ITAB,
           G_TC_2220_2_WA.
   LOOP AT XZTITPC3.
     MOVE-CORRESPONDING XZTITPC3 TO G_TC_2220_2_WA.
     APPEND G_TC_2220_2_WA TO  G_TC_2220_2_ITAB.
   ENDLOOP.

   CLEAR : G_TC_2240_ITAB,
           G_TC_2240_WA.
   LOOP AT XZTITTT2.
     MOVE-CORRESPONDING XZTITTT2 TO G_TC_2240_WA.
     APPEND G_TC_2240_WA TO  G_TC_2240_ITAB.
   ENDLOOP.

 ENDFORM.                    " read_edi_table_document
*&---------------------------------------------------------------------*
*&      Form  p8111_edi_item_table_read
*&---------------------------------------------------------------------*
 FORM P8111_EDI_ITEM_TABLE_READ .


   REFRESH : XZTITLC2,
             XZTITLC3,
             XZTITLC4,
             XZTITPC2,
             XZTITPC3,
             XZTITTT2.

*>상품명세(TEXT)-상품명/수량/금액
   LOOP AT G_TC_2211_ITAB INTO G_TC_2211_WA.
     MOVE-CORRESPONDING  G_TC_2211_WA TO XZTITLC2.
     XZTITLC2-LCITY = '7'.
     APPEND XZTITLC2.
   ENDLOOP.

*>기타부가조건(TEXT)
   LOOP AT G_TC_2212_ITAB INTO G_TC_2212_WA.
     MOVE-CORRESPONDING  G_TC_2212_WA TO XZTITLC2.
     XZTITLC2-LCITY = '8'.
     APPEND XZTITLC2.
   ENDLOOP.

*>Other Document(TEXT)
   LOOP AT G_TC_2213_ITAB INTO G_TC_2213_WA.
     MOVE-CORRESPONDING  G_TC_2213_WA TO XZTITLC2.
     XZTITLC2-LCITY = '9'.
     APPEND XZTITLC2.
   ENDLOOP.

*>기타조건변경사항(TEXT)
   LOOP AT G_TC_2216_ITAB INTO G_TC_2216_WA.
     MOVE-CORRESPONDING  G_TC_2216_WA TO XZTITLC2.
     XZTITLC2-LCITY = 'A'.
     APPEND XZTITLC2.
   ENDLOOP.

*S__ 신용장 변경에 따른 수정 20181010 BY SDW
*>기타조건 상품(용역), 구비서류, 부가조건 특별지급 (생성, 삭제, 변경)

   LOOP AT G_TC_2216_ITAB_1_1 INTO G_TC_2216_WA_1_1.
     MOVE-CORRESPONDING  G_TC_2216_WA_1_1 TO XZTITLC2.
     XZTITLC2-LCITY = 'B'.
     APPEND XZTITLC2.
   ENDLOOP.

   LOOP AT G_TC_2216_ITAB_1_2 INTO G_TC_2216_WA_1_2.
     MOVE-CORRESPONDING  G_TC_2216_WA_1_2 TO XZTITLC2.
     XZTITLC2-LCITY = 'C'.
     APPEND XZTITLC2.
   ENDLOOP.

   LOOP AT G_TC_2216_ITAB_1_3 INTO G_TC_2216_WA_1_3.
     MOVE-CORRESPONDING  G_TC_2216_WA_1_3 TO XZTITLC2.
     XZTITLC2-LCITY = 'D'.
     APPEND XZTITLC2.
   ENDLOOP.

   LOOP AT G_TC_2216_ITAB_2_1 INTO G_TC_2216_WA_2_1.
     MOVE-CORRESPONDING  G_TC_2216_WA_2_1 TO XZTITLC2.
     XZTITLC2-LCITY = 'E'.
     APPEND XZTITLC2.
   ENDLOOP.

   LOOP AT G_TC_2216_ITAB_2_2 INTO G_TC_2216_WA_2_2.
     MOVE-CORRESPONDING  G_TC_2216_WA_2_2 TO XZTITLC2.
     XZTITLC2-LCITY = 'F'.
     APPEND XZTITLC2.
   ENDLOOP.

   LOOP AT G_TC_2216_ITAB_2_3 INTO G_TC_2216_WA_2_3.
     MOVE-CORRESPONDING  G_TC_2216_WA_2_3 TO XZTITLC2.
     XZTITLC2-LCITY = 'G'.
     APPEND XZTITLC2.
   ENDLOOP.

   LOOP AT G_TC_2216_ITAB_3_1 INTO G_TC_2216_WA_3_1.
     MOVE-CORRESPONDING  G_TC_2216_WA_3_1 TO XZTITLC2.
     XZTITLC2-LCITY = 'H'.
     APPEND XZTITLC2.
   ENDLOOP.

   LOOP AT G_TC_2216_ITAB_3_2 INTO G_TC_2216_WA_3_2.
     MOVE-CORRESPONDING  G_TC_2216_WA_3_2 TO XZTITLC2.
     XZTITLC2-LCITY = 'I'.
     APPEND XZTITLC2.
   ENDLOOP.

   LOOP AT G_TC_2216_ITAB_3_3 INTO G_TC_2216_WA_3_3.
     MOVE-CORRESPONDING  G_TC_2216_WA_3_3 TO XZTITLC2.
     XZTITLC2-LCITY = 'J'.
     APPEND XZTITLC2.
   ENDLOOP.

   LOOP AT G_TC_2216_ITAB_4_1 INTO G_TC_2216_WA_4_1.
     MOVE-CORRESPONDING  G_TC_2216_WA_4_1 TO XZTITLC2.
     XZTITLC2-LCITY = 'K'.
     APPEND XZTITLC2.
   ENDLOOP.

   LOOP AT G_TC_2216_ITAB_4_2 INTO G_TC_2216_WA_4_2.
     MOVE-CORRESPONDING  G_TC_2216_WA_4_2 TO XZTITLC2.
     XZTITLC2-LCITY = 'L'.
     APPEND XZTITLC2.
   ENDLOOP.

   LOOP AT G_TC_2216_ITAB_4_3 INTO G_TC_2216_WA_4_3.
     MOVE-CORRESPONDING  G_TC_2216_WA_4_3 TO XZTITLC2.
     XZTITLC2-LCITY = 'M'.
     APPEND XZTITLC2.
   ENDLOOP.
*E__ 신용장 변경에 따른 수정 20181010 BY SDW


   LOOP AT G_TC_2214_ITAB INTO G_TC_2214_WA.
     MOVE-CORRESPONDING  G_TC_2214_WA TO XZTITLC3.
     APPEND XZTITLC3.
   ENDLOOP.

   LOOP AT G_TC_2220_1_ITAB INTO G_TC_2220_1_WA.
     MOVE-CORRESPONDING  G_TC_2220_1_WA TO XZTITPC2.
     APPEND XZTITPC2.
   ENDLOOP.

   LOOP AT G_TC_2220_2_ITAB INTO G_TC_2220_2_WA.
     MOVE-CORRESPONDING  G_TC_2220_2_WA TO XZTITPC3.
     APPEND XZTITPC3.
   ENDLOOP.

   LOOP AT G_TC_2240_ITAB INTO G_TC_2240_WA.
     MOVE-CORRESPONDING  G_TC_2240_WA TO XZTITTT2.
     APPEND XZTITTT2.
   ENDLOOP.

*> 포워더 정보.
   LOOP AT G_TC_2123_ITAB INTO G_TC_2123_WA.
     MOVE-CORRESPONDING  G_TC_2123_WA TO XZTITLC4.
     APPEND XZTITLC4.
   ENDLOOP.

 ENDFORM.                    " p8111_edi_item_table_read
*&---------------------------------------------------------------------*
*&      Form  SET_EDI_DEFAULT_VALUE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
 FORM SET_EDI_DEFAULT_VALUE .

   CHECK: NOT ( G_MODE EQ C_CHARS OR
                G_MODE EQ C_CHARD ).


   CALL FUNCTION 'Z_TS_GET_COMPANY_EDI_DATA'
     EXPORTING
       BUKRS     = ZTITRQK-BUKRS
       APPCT     = ZTITRQK-APPCT
     IMPORTING
*      yZTSTIG0  =
       NZTSTIG0  = ZTSTIG0
       XT001     = T001
     EXCEPTIONS
       NOT_FOUND = 1
       OTHERS    = 2.
   IF SY-SUBRC <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
     MESSAGE ID SY-MSGID TYPE C_WARNING  NUMBER SY-MSGNO
             WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
   ENDIF.

   IF ZTITRQS-EDIYN = C_TRUE.
     PERFORM  SET_EDI_PARTNER_FIELD.
*--> LS 전선 Consinee 정보 Set By SB, Kang
     IF ZTITRQK-REQTY EQ C_LC.
*> 운송방법에 따라.
       CASE ZTITRQS-FWDTY.
         WHEN C_CHARA.   ">Air
           PERFORM  SET_AIR_DOCUMENT_REQUIRED.
         WHEN C_CHARO.   ">Ocean
           PERFORM  SET_OCEAN_DOCUMENT_REQUIRED.
         WHEN C_CHARC.   ">Air + Ocean
           PERFORM  SET_OCEAN_DOCUMENT_REQUIRED.
           PERFORM  SET_AIR_DOCUMENT_REQUIRED.
         WHEN C_CHARM.   ">Others.
       ENDCASE.
     ENDIF.
     EXIT.
   ENDIF.


*----------------------------------------------------------------------
* 2007.07.05 simcho by 박혁세 K
*----------------------------------------------------------------------
   CLEAR : G_EOAD1,G_EOAD2,G_TELNO.

   G_EOAD1 = ZTSTIG0-EOAD1.
   G_EOAD2 = ZTSTIG0-EOAD2.
   G_TELNO = ZTSTIG0-TELNO.

*->2014040300032_기존로직 주석
*   if ztitrqs-werks+0(2) = '12' or
*      ztitrqs-werks+0(2) = '32'.
*
**     ztstig0-eoad1  = 'Anyang-si, Gyonggido, Korea '.
**     ztstig0-eoad2  = '555, Hogwe-dong, Dongan-gu'.
**     ztstig0-telno  = '82-31-428-4084'.
*
*     ztstig0-eoad1  = '555, Hogwe-dong, Dongan-gu,'.
*     ztstig0-eoad2  = 'Gyonggi, Korea'.
*     ztstig0-telno  = '82-31-428-4084'.
*<-2014040300032_기존로직 주석
*->2014040300032_신규로직 추가
   IF ZTITRQS-WERKS+0(2) = '12'.
     ZTSTIG0-EOAD1  = '555, Hogwe-dong, Dongan-gu,'.
     ZTSTIG0-EOAD2  = 'Gyonggi, Korea'.
     ZTSTIG0-TELNO  = '82-31-428-4084'.
   ELSEIF ZTITRQS-WERKS+0(2) = '32'.
     "김충신D 요청으로 32**플랜트는 아래 주소를 사용함
     ZTSTIG0-EOAD1  = '39,116 BEON-GIL,LS-RO,DONGAN-GU,'.
     ZTSTIG0-EOAD2  = 'GYONGGI, KOREA'.
     ZTSTIG0-TELNO  = '82-31-8045-9519'.
*<-2014040300032_신규로직 추가

*-{ LSEVK 분사 관련 추가
   ELSEIF ZTITRQS-WERKS+0(2) = '52'.
     ZTSTIG0-EOAD1  = '1-4F, 28 GORAEDEUL-GIL, GUNPO'.
     ZTSTIG0-EOAD2  = 'GYONGGI, KOREA'.
     ZTSTIG0-TELNO  = '82-31-687-6954'.
*-} LSEVK 분사 관련 추가

   ELSEIF ZTITRQS-WERKS+0(2) = '13'.
*     ztstig0-eoad1  = 'Gyungbuk Province, Korea '.
*     ztstig0-eoad2  = '190, Gongdan-dong, Gumi-si'.
*     ztstig0-telno  = '82-54-469-7291'.

     ZTSTIG0-EOAD1  = '190, Gongdan-dong, Gumi'.
     ZTSTIG0-EOAD2  = 'Gyungbuk, Korea'.
     ZTSTIG0-TELNO  = '82-54-469-7291'.

   ELSEIF ZTITRQS-WERKS+0(2) = '14' OR
          ZTITRQS-WERKS+0(2) = '34'.

*     ztstig0-eoad1  = 'Gyungbuk Province, Korea'.
*     ztstig0-eoad2  = '643, Jinpyeong-dong, Gumi-si'.
*     ztstig0-telno  = '82-54-469-7068'.

     ZTSTIG0-EOAD1  = '643, Jinpyeong-dong, Gumi'.
     ZTSTIG0-EOAD2  = 'Gyungbuk, Korea'.
     ZTSTIG0-TELNO  = '82-54-469-7068'.

   ELSEIF ZTITRQS-WERKS+0(2) = '15' OR
          ZTITRQS-WERKS+0(2) = '35'.

*     ztstig0-eoad1  = 'Buk-myeon Jeongeup, Jeonbuk Province, Korea'.
*     ztstig0-eoad2  = '938 3th Industrial Complex, Taegok-ri'.
*     ztstig0-telno  = '82-63-530-4355'.

     ZTSTIG0-EOAD1  = '938, 3 IndustrialComplex'.
     ZTSTIG0-EOAD2  = 'Taegok,Buk-myeon,Jeongeup,Jeonbuk'.
     ZTSTIG0-TELNO  = '82-63-530-4355'.

   ELSEIF ZTITRQS-WERKS+0(2) = '16' OR ZTITRQS-WERKS+0(2) = '17' OR
          ZTITRQS-WERKS+0(2) = '36' OR ZTITRQS-WERKS+0(2) = '37'.

*     ztstig0-eoad1 = 'Bongdong-eup, Wanju-gun, Jeonbuk Province,Korea'.
*     ztstig0-eoad2  = '778 Jeonju 3 Industrial Complex Yongnam-ri'.
*     ztstig0-telno  = '82-63-279-5144'.

     ZTSTIG0-EOAD1  = '778, 3 IndustrialComplex'.
     ZTSTIG0-EOAD2  = 'Yongnam,Bongdong,Wanju,Jeonbuk'.
     ZTSTIG0-TELNO  = '82-63-279-5144'.

   ENDIF.
*----------------------------------------------------------------------

   CASE ZTITRQK-REQTY.
*----------------------------------------------------------------------
*  수입신용장 field check
*----------------------------------------------------------------------
     WHEN C_LC.
*       IF ztitrqs-amdsq GT 0.
*         PERFORM set_app707_default_value.
*       ELSE.
*         PERFORM set_app700_default_value.
*       endif.
*> 050713 jp, park 수정. 변경시제외.
*<------------------
       IF ZTITRQS-AMDSQ GT 0.
         IF G_MODE NE C_CHARM.
           PERFORM SET_APP707_DEFAULT_VALUE.
         ENDIF.
       ELSE.
         IF G_MODE NE C_CHARM.
           PERFORM SET_APP700_DEFAULT_VALUE.


         ENDIF.
*-------------------->
       ENDIF.
*&---------------------------------------------------------------------
*& 구매확인서.
*----------------------------------------------------------------------
     WHEN C_PU.
       PERFORM SET_APPPCR_DEFAULT_VALUE.
*&---------------------------------------------------------------------
*& 전신환 송금.
*----------------------------------------------------------------------
     WHEN C_TT.
       PERFORM SET_PAYORD_DEFAULT_VALUE.
*&---------------------------------------------------------------------
*& 내국신용장.
*----------------------------------------------------------------------
     WHEN C_LO.
       IF ZTITRQS-AMDSQ GT 0.
         PERFORM SET_LOCAMR_DEFAULT_VALUE.
       ELSE.
         PERFORM SET_LOCAPP_DEFAULT_VALUE.
       ENDIF.
     WHEN C_DA OR C_DP.
       PERFORM  SET_GENRES_DEFAULT_VALUE.
   ENDCASE.

*> Set EDI Internal table .
   PERFORM  P8111_EDI_ITEM_TABLE_READ.

*> Set EDI 문구 .
   PERFORM SET_EDI_TEXTID_AND_TEXT.

*> EDI 적용여부.
   ZTITRQS-EDIYN = C_TRUE.

 ENDFORM.                    " SET_EDI_DEFAULT_VALUE
*&---------------------------------------------------------------------*
*&      Form  CHECK_OPEN_AMOUNT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
 FORM CHECK_OPEN_AMOUNT .

*> 원화환율.
   DATA: L_EXCHANGE_RATE LIKE TCURR-UKURS,
         L_CONV_DATE     LIKE SY-DATUM.

   DATA: BEGIN OF RATEEQUATION,
           KURSP  LIKE RFCU9-KURSP,
           FFACTP LIKE TCURF-FFACT,
           TFACTP LIKE TCURF-TFACT,
           FCURRP LIKE TCURC-WAERS,
           TCURRP LIKE TCURC-WAERS,
           KURSM  LIKE RFCU9-KURSM,
           FFACTM LIKE TCURF-FFACT,
           TFACTM LIKE TCURF-TFACT,
           FCURRM LIKE TCURC-WAERS,
           TCURRM LIKE TCURC-WAERS,
         END OF RATEEQUATION.
   DATA  RATE       LIKE TCURR-UKURS.

   DATA: BEGIN OF AMOUNTS,
           FORAMOUNT(13) TYPE P,
           LOCAMOUNT(13) TYPE P,
           FORCUR        LIKE TCURR-FCURR,
           LOCCUR        LIKE TCURR-TCURR,
         END OF AMOUNTS.


   DATA : L_TEXT_EXRATE(255)    TYPE C,
          L_FOREIGN_FACTOR(255) TYPE C,
          L_FTEXT11(11)         TYPE C,
          L_TTEXT11(11)         TYPE C,
          L_FACTOR              TYPE P,
          L_DATE                TYPE DATUM,
          L_WRBTR               TYPE WRBTR,
          L_NETWR               TYPE NETWR,
          L_RQMNG               TYPE ZTIRQMNG,
          L_PPMNG               TYPE ZTIPPMNG,
          L_PPAMT               TYPE ZTIPPAM2,
          L_PPAMT1              TYPE ZTIPPAM2,
          L_PPAMTS              TYPE ZTIPPAM2,
          L_FIXED_RATE          LIKE TCURS-SPRED,
          L_LOCAL_AMT           LIKE ZTITRQS-USAMT.  " USD 환산 Amount

   REFRESH: IT_PSPNR, IT_LSDAT.
   CLEAR: G_WRBTR, G_PPAMT, IT_PSPNR, ZTITRQS-POAMT.

*----  >>  Begin of Loop.
   LOOP AT IT_TAB INTO G_TC_2130_WA.

     ADD G_TC_2130_WA-NETWR TO G_WRBTR.

     IF ZTITRQS-EBELN IS INITIAL.
       ZTITRQS-EBELN = G_TC_2130_WA-EBELN.
     ENDIF.

     IF ZTITRQS-WERKS IS INITIAL.
       ZTITRQS-WERKS = G_TC_2130_WA-WERKS.
     ENDIF.

     IF ZTITRQS-BUPLA IS INITIAL.
       SELECT SINGLE J_1BBRANCH
         INTO ZTITRQS-BUPLA
         FROM T001W
        WHERE WERKS EQ G_TC_2130_WA-WERKS.
     ENDIF.

     IF NOT G_TC_2130_WA-EBELN IS INITIAL.
       CLEAR: L_RQMNG, L_NETWR.
       CLEAR: L_PPMNG, L_RQMNG.
       IF ZTITRQK-REQTY EQ C_LC.
*> 선급금 수량/금액 집계
         SELECT  SUM( RQMNG ) SUM( NETWR )
           INTO  (L_RQMNG, L_PPAMT)
           FROM  ZTIVRQ00
          WHERE  EBELN  = G_TC_2130_WA-EBELN
            AND  EBELP  = G_TC_2130_WA-EBELP
            AND NOT ( REQNO  = G_TC_2130_WA-REQNO
            AND       REQIT  = G_TC_2130_WA-REQIT )
*         and  ANBTY  = 'B'
*         and  reqty  = 'TT'.
            AND  PPAID  = C_TRUE.

*> 선급금 참조 수량/금액 집계.
         SELECT  SUM( PPMNG ) SUM( IPAMT )
           INTO  (L_PPMNG, L_PPAMT1)
           FROM  ZTIVRQ00
          WHERE  EBELN  = G_TC_2130_WA-EBELN
            AND  EBELP  = G_TC_2130_WA-EBELP
            AND NOT ( REQNO  = G_TC_2130_WA-REQNO
            AND       REQIT  = G_TC_2130_WA-REQIT ).
*         AND  ppaid  = c_false.
       ELSE.
*> 선급금 수량/금액 집계
         SELECT  SUM( RQMNG ) SUM( NETWR )
          INTO  (L_RQMNG, L_PPAMT)
          FROM  ZTIVRQ00
         WHERE  EBELN  = G_TC_2130_WA-EBELN
           AND  EBELP  = G_TC_2130_WA-EBELP
           AND NOT ( REQNO  = G_TC_2130_WA-REQNO
           AND       REQIT  = G_TC_2130_WA-REQIT ).

       ENDIF.
*> 선급금 수량 = 선급금 합계 수량 - 선급금 참조 합계수량.
       IF L_PPMNG GT L_RQMNG.
         L_RQMNG = L_RQMNG.
         L_PPAMT = L_PPAMT.
       ELSE.
         L_RQMNG = L_RQMNG - L_PPMNG.
         L_PPAMT = L_PPAMT - L_PPAMT1.
       ENDIF.

*> if 선급금 수량 > 수입의뢰 수량 then
*>    선급금 수량 = 수입의뢰 수량.
       IF L_RQMNG GT G_TC_2130_WA-RQMNG.
         L_RQMNG = G_TC_2130_WA-RQMNG.
*        l_ppamt = g_tc_2130_wa-ppamt.
       ENDIF.

*> 신용장일 경우 선급된 금액 계산 로직.
       IF ZTITRQK-REQTY EQ C_LC.
         G_TC_2130_WA-PPMNG = L_RQMNG.
         G_TC_2130_WA-PPAMT = L_PPAMT.
       ELSE.
         CLEAR: G_TC_2130_WA-PPMNG,
                G_TC_2130_WA-PPAMT.
       ENDIF.
       ADD L_PPAMT TO G_PPAMT.

*> 구매오더 전체 금액.
       IF NOT G_TC_2130_WA-MENGE IS INITIAL.
         CALL FUNCTION 'Z_TI_CALC_ITEM_AMOUNT'
           EXPORTING
             PEINH = G_TC_2130_WA-PEINH
             BPUMZ = G_TC_2130_WA-BPUMZ
             BPUMN = G_TC_2130_WA-BPUMN
             MENGE = G_TC_2130_WA-MENGE
             NETPR = G_TC_2130_WA-NETPR
           CHANGING
             NETWR = L_NETWR.
       ELSE.
         L_NETWR = 0.
       ENDIF.
       ADD L_NETWR TO ZTITRQS-POAMT.

**> 품목별 정가 계산.
*      IF NOT l_rqmng IS INITIAL.
*        CALL FUNCTION 'Z_TI_CALC_ITEM_AMOUNT'
*          EXPORTING
*            peinh = g_tc_2130_wa-peinh
*            bpumz = g_tc_2130_wa-bpumz
*            bpumn = g_tc_2130_wa-bpumn
*            menge = l_rqmng
*            netpr = g_tc_2130_wa-netpr
*          CHANGING
*            netwr = l_netwr.
*      ELSE.
*        l_netwr = 0.
*      ENDIF.
*      ADD l_netwr TO g_ppamt.
     ENDIF.

*> 호선 정보 collect.
     IF NOT G_TC_2130_WA-PS_PSP_PNR IS INITIAL.
       MOVE: G_TC_2130_WA-PS_PSP_PNR TO IT_PSPNR-PSPNR.
       COLLECT IT_PSPNR.
     ENDIF.

*> 최종선적일자 COLLECT.
     IF NOT G_TC_2130_WA-LSDAT IS INITIAL.
       MOVE: G_TC_2130_WA-LSDAT TO IT_LSDAT-LSDAT.
       COLLECT IT_LSDAT.
     ENDIF.

     IF G_MODE EQ C_CHARC OR
        G_MODE EQ C_CHARM.
       MODIFY IT_TAB FROM G_TC_2130_WA.
     ENDIF.

   ENDLOOP.
*----  >>  End of Loop.

   IF G_MODE EQ C_CHARC OR
      G_MODE EQ C_CHARM.
     IF ZTITRQK-REQTY EQ C_LC.
       ZTITRQS-SMAMT = G_WRBTR.
       ZTITRQS-PPAMT = G_PPAMT.
     ELSE.
       CLEAR: ZTITRQS-PPAMT.
       ZTITRQS-SMAMT = G_WRBTR.
     ENDIF.
   ENDIF.

   IF ZTITRQK-REQTY EQ C_TT.
     L_WRBTR = G_WRBTR.
******************************************
* 2009/06/15 김승한K 요청 : 로컬개설
******************************************
   ELSEIF ZTITRQK-REQTY EQ C_PU.
     L_WRBTR = G_WRBTR.
******************************************
   ELSE.
     L_WRBTR = G_WRBTR - G_PPAMT.
   ENDIF.

*> Ohteer Charge 추가.
   L_WRBTR =  L_WRBTR + ZTITRQS-OTCHG.

   IF ( G_MODE EQ C_CHARC OR
        G_MODE EQ C_CHARM ).
     IF ZTITRQS-OPAMT IS INITIAL.
       ZTITRQS-OPAMT = L_WRBTR.
     ELSE.
       IF ZTITRQS-OPAMT NE L_WRBTR.
         IF G_MODE   EQ C_CHARC AND
            ( SY-DYNNR EQ C_SCR0100 OR
              SY-DYNNR EQ C_SCR0200 ).
           MESSAGE S117.
         ELSE.
*******************************************************
** 20071015 simcho by 박혁세 K
** 사후송금 채권채무 상계시 EDI문서 금액 수정
*******************************************************
**           MESSAGE w117.
*           MESSAGE s117.
         ENDIF.
*******************************************************
* 20080618 simcho by 홍경배C
*  수입개설 수량 변경시 금액 재계산 오류fix
*******************************************************
         ZTITRQS-OPAMT = L_WRBTR.  " 수정금액 원복방지 해제
*******************************************************

       ENDIF.
     ENDIF.
   ELSE.
     IF ZTITRQS-OPAMT NE L_WRBTR.
       MESSAGE S118.
     ENDIF.
   ENDIF.

   CHECK: G_MODE EQ C_CHARC OR
          G_MODE EQ C_CHARM OR
          G_MODE EQ C_CHARY OR
          G_MODE EQ C_CHARO.

   ZTITRQS-UCURR = 'USD'.

   IF ZTITRQS-WAERS EQ ZTITRQS-UCURR.
     ZTITRQS-USAMT = ZTITRQS-OPAMT.
     ZTITRQS-WKURS = 1.
     EXIT.
   ENDIF.

   IF ZTITRQS-SNDDT IS INITIAL.
     L_DATE = SY-DATLO.
   ELSE.
     L_DATE = ZTITRQS-SNDDT.
   ENDIF.

*----------------------------------------------------------------------*
* 원화금액 계산.
*----------------------------------------------------------------------*
*> 신청일자.
   IF L_CONV_DATE IS INITIAL.
     L_CONV_DATE = ZTITRQS-OPNDT.
     IF L_CONV_DATE IS INITIAL.
       L_CONV_DATE = ZTITRQS-SNDDT.
       IF L_CONV_DATE IS INITIAL.
         L_CONV_DATE = ZTITRQS-REQDT.
       ENDIF.
     ENDIF.
   ENDIF.
   IF L_CONV_DATE IS INITIAL.
     L_CONV_DATE = SY-DATLO.
   ENDIF.

   CALL FUNCTION 'READ_EXCHANGE_RATE'
     EXPORTING
       DATE             = L_CONV_DATE
       FOREIGN_CURRENCY = ZTITRQS-WAERS
       LOCAL_CURRENCY   = ZTITRQS-HWAER
       TYPE_OF_RATE     = 'M'
     IMPORTING
       EXCHANGE_RATE    = L_EXCHANGE_RATE
     EXCEPTIONS
       ERROR_MESSAGE    = 1.
   IF SY-SUBRC = 1.
     MESSAGE ID SY-MSGID TYPE 'I' NUMBER SY-MSGNO
             WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
     EXIT.
   ENDIF.

   IF L_EXCHANGE_RATE > 0.
     RATEEQUATION-KURSP = L_EXCHANGE_RATE.
     IF ZTITRQS-AKKUR IS INITIAL.
       ZTITRQS-AKKUR = L_EXCHANGE_RATE.
     ENDIF.
     IF ZTITRQS-AKKUR NE RATEEQUATION-KURSP.
       RATEEQUATION-KURSP = ZTITRQS-AKKUR.
     ENDIF.
     CLEAR RATEEQUATION-KURSM.
   ELSE.
     IF ZTITRQS-AKKUR IS INITIAL.
       ZTITRQS-AKKUR = - L_EXCHANGE_RATE.
     ENDIF.
     RATEEQUATION-KURSM = - L_EXCHANGE_RATE.
     IF ZTITRQS-AKKUR NE RATEEQUATION-KURSM.
       RATEEQUATION-KURSM = ZTITRQS-AKKUR.
     ENDIF.
     CLEAR RATEEQUATION-KURSP.
   ENDIF.

   IF RATEEQUATION-KURSM IS INITIAL.
     RATE = RATEEQUATION-KURSP.
   ELSE.
     RATE = - RATEEQUATION-KURSM.
   ENDIF.
   AMOUNTS-FORAMOUNT = ZTITRQS-OPAMT.

   CALL FUNCTION 'CONVERT_TO_LOCAL_CURRENCY'
     EXPORTING
       DATE             = L_CONV_DATE
       FOREIGN_AMOUNT   = AMOUNTS-FORAMOUNT
       FOREIGN_CURRENCY = ZTITRQS-WAERS
       LOCAL_CURRENCY   = ZTITRQS-HWAER
       RATE             = RATE
       TYPE_OF_RATE     = 'M'
     IMPORTING
       LOCAL_AMOUNT     = AMOUNTS-LOCAMOUNT
     EXCEPTIONS
       ERROR_MESSAGE    = 1.
   IF SY-SUBRC <> 0.
     MESSAGE ID SY-MSGID TYPE 'I' NUMBER SY-MSGNO
             WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
     EXIT.
   ENDIF.
   ZTITRQS-DMBTR = AMOUNTS-LOCAMOUNT.

*----------------------------------------------------------------------*
* USD 금액 계산.
*----------------------------------------------------------------------*
   CALL FUNCTION 'READ_EXCHANGE_RATE'
     EXPORTING
       DATE             = L_CONV_DATE
       FOREIGN_CURRENCY = ZTITRQS-WAERS
       LOCAL_CURRENCY   = ZTITRQS-UCURR
       TYPE_OF_RATE     = 'M'
     IMPORTING
       EXCHANGE_RATE    = L_EXCHANGE_RATE
     EXCEPTIONS
       ERROR_MESSAGE    = 1.
   IF SY-SUBRC = 1.
     MESSAGE ID SY-MSGID TYPE 'I' NUMBER SY-MSGNO
             WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
     EXIT.
   ENDIF.

   IF L_EXCHANGE_RATE > 0.
     ZTITRQS-WKURS = L_EXCHANGE_RATE.
     RATEEQUATION-KURSP = L_EXCHANGE_RATE.
     CLEAR RATEEQUATION-KURSM.
   ELSE.
     ZTITRQS-WKURS = - L_EXCHANGE_RATE.
     RATEEQUATION-KURSM = - L_EXCHANGE_RATE.
     CLEAR RATEEQUATION-KURSP.
   ENDIF.

   IF RATEEQUATION-KURSM IS INITIAL.
     RATE = RATEEQUATION-KURSP.
   ELSE.
     RATE = - RATEEQUATION-KURSM.
   ENDIF.
   AMOUNTS-FORAMOUNT = ZTITRQS-OPAMT.

   CALL FUNCTION 'CONVERT_TO_LOCAL_CURRENCY'
     EXPORTING
       DATE             = L_CONV_DATE
       FOREIGN_AMOUNT   = AMOUNTS-FORAMOUNT
       FOREIGN_CURRENCY = ZTITRQS-WAERS
       LOCAL_CURRENCY   = ZTITRQS-UCURR
       RATE             = RATE
       TYPE_OF_RATE     = 'M'
     IMPORTING
       LOCAL_AMOUNT     = AMOUNTS-LOCAMOUNT
     EXCEPTIONS
       ERROR_MESSAGE    = 1.
   IF SY-SUBRC <> 0.
     MESSAGE ID SY-MSGID TYPE 'I' NUMBER SY-MSGNO
             WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
     EXIT.
   ENDIF.
   ZTITRQS-USAMT = AMOUNTS-LOCAMOUNT.


*> Get exchange rate
*   CLEAR: bapiret1, bapi1093_0.
*   CALL FUNCTION 'BAPI_EXCHANGERATE_GETDETAIL'
*     EXPORTING
*       rate_type  = 'M'
*       from_curr  = ztitrqs-waers
*       to_currncy = ztitrqs-ucurr
*       date       = l_date
*     IMPORTING
*       exch_rate  = bapi1093_0
*       return     = bapiret1.
*
*   IF bapiret1-type EQ c_error.
*     MESSAGE ID bapiret1-id TYPE bapiret1-type NUMBER bapiret1-number
*                WITH bapiret1-message_v1 bapiret1-message_v2
*                     bapiret1-message_v3 bapiret1-message_v4.
*   ENDIF.
*
*   IF ztitrqs-waers NE ztitrqs-ucurr.
*
*     IF ztitrqk-reqty EQ c_pu.
*       IF ztitrqs-docst IS INITIAL.
*         IF bapi1093_0-exch_rate_v IS INITIAL.
*           ztitrqs-wkurs = bapi1093_0-exch_rate.
*         ELSE.
*           ztitrqs-wkurs = bapi1093_0-exch_rate_v.
*         ENDIF.
*       ELSE.
*         IF ztitrqs-wkurs IS INITIAL.
*           IF bapi1093_0-exch_rate_v IS INITIAL.
*             ztitrqs-wkurs = bapi1093_0-exch_rate.
*           ELSE.
*             ztitrqs-wkurs = bapi1093_0-exch_rate_v.
*           ENDIF.
*         ELSE.
*           IF sy-dynnr EQ c_scr2000.
*             IF bapi1093_0-exch_rate_v IS INITIAL.
*               IF ztitrqs-wkurs <> bapi1093_0-exch_rate.
*                 WRITE: ztitrqs-wkurs       TO l_ftext11,
*                        bapi1093_0-exch_rate TO l_ttext11.
*                 MESSAGE w016 WITH l_ftext11 l_ttext11.
*               ENDIF.
*             ELSE.
*               IF ztitrqs-wkurs <> bapi1093_0-exch_rate_v.
*                 WRITE: ztitrqs-wkurs         TO l_ftext11,
*                        bapi1093_0-exch_rate_v TO l_ttext11.
*                 MESSAGE w016 WITH l_ftext11 l_ttext11.
*               ENDIF.
*             ENDIF.
*           ENDIF.
*         ENDIF.
*       ENDIF.
*     ELSE.
*       IF bapi1093_0-exch_rate_v IS INITIAL.
*         ztitrqs-wkurs = bapi1093_0-exch_rate.
*       ELSE.
*         ztitrqs-wkurs = bapi1093_0-exch_rate_v.
*       ENDIF.
*     ENDIF.
*
*    CALL FUNCTION 'CONVERT_TO_LOCAL_CURRENCY'
*      EXPORTING
*        date             = l_date
*        foreign_amount   = 0
*        foreign_currency = ZTITRQS-waers
*        local_currency   = ZTITRQS-ucurr
*      IMPORTING
*        foreign_factor   = l_foreign_factor
*        exchange_rate    = l_text_exrate
*        local_amount     = l_local_amt
*        fixed_rate       = l_fixed_rate
*      EXCEPTIONS
*        OTHERS           = 01.
*
*    IF sy-subrc <> 0.
*      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
*                 WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4
*                 RAISING amount_calculation.
*    ENDIF.
*
*    PERFORM    set_write_no_mask   CHANGING l_text_exrate.
*    PERFORM    set_write_no_mask   CHANGING l_foreign_factor.
*
*    ZTITRQS-wkurs = l_text_exrate.
*    l_factor = l_foreign_factor.
*
*    IF ZTITRQS-wkurs LT 0.
*      ZTITRQS-wkurs = ZTITRQS-wkurs * -1.
*    ENDIF.
*
*    IF l_factor IS INITIAL.
*      l_factor = 1.
*    ENDIF.
*    IF l_factor NE 0.
*      ZTITRQS-wkurs = ZTITRQS-wkurs / l_factor.
*    ENDIF.

* ENDIF.

* IF NOT ztitrqs-wkurs IS INITIAL.
*   CALL FUNCTION 'BAPI_CURRENCY_CONV_TO_EXTERN_9'
*     EXPORTING
*       currency        = ztitrqs-waers
*       amount_internal = ztitrqs-opamt
*     IMPORTING
*       amount_external = bapicurx-bapicurx.
*
**  ZTITRQS-usamt = bapicurx-bapicurx *  bapi1093_0-exch_rate *
**                   ( bapi1093_0-to_factor / bapi1093_0-from_factor ).
*   ztitrqs-usamt = bapicurx-bapicurx *  ( 1 / ztitrqs-wkurs ) *
*                    ( bapi1093_0-to_factor / bapi1093_0-from_factor ).
*
*   bapicurx-bapicurx = ztitrqs-usamt.
*   CALL FUNCTION 'BAPI_CURRENCY_CONV_TO_INTERN_9'
*     EXPORTING
*       currency             = ztitrqs-ucurr
*       amount_external      = bapicurx-bapicurx
*       max_number_of_digits = 18
*     IMPORTING
*       amount_internal      = ztitrqs-usamt.
* ENDIF.
*
*  IF t001-waers EQ ZTITRQS-waers.
*    l_local_amt = ZTITRQS-opamt.
*  ELSE.


**> Local Currency로 변경 후 USD 로 변환.
*  CHECK ZTITRQS-waers NE ZTITRQS-ucurr.
*
*  IF t001-waers EQ ZTITRQS-waers.
*    l_local_amt = ZTITRQS-opamt.
*  ELSE.
*    PERFORM    convert_to_local_currency USING    ZTITRQS-opamt
*                                                  ZTITRQS-waers
*                                                  t001-waers
*                                                  l_date
*                                         CHANGING l_local_amt
*                                                  l_text_exrate
*                                                  l_fixed_rate.
*
*  ENDIF.
**> Local currency ---> USD
*  PERFORM    convert_to_local_currency    USING l_local_amt
*                                                t001-waers
*                                                ZTITRQS-ucurr
*                                                l_date
*                                       CHANGING ZTITRQS-usamt
*                                                l_text_exrate
*                                                l_fixed_rate.

 ENDFORM.                    " CHECK_OPEN_AMOUNT
*&---------------------------------------------------------------------
*&      Form  CONVERT_TO_LOCAL_CURRENCY
*&---------------------------------------------------------------------
 FORM CONVERT_TO_LOCAL_CURRENCY USING    P_FROM_AMOUNT
                                         P_WAERS
                                         P_TO_WAERS
                                         P_DATE
                                CHANGING W_LOCAL_AMT
                                         W_RATE
                                         W_FIXED_RATE.

   CALL FUNCTION 'CONVERT_TO_LOCAL_CURRENCY'
     EXPORTING
       DATE             = P_DATE
       FOREIGN_AMOUNT   = P_FROM_AMOUNT
       FOREIGN_CURRENCY = P_WAERS
       LOCAL_CURRENCY   = P_TO_WAERS
     IMPORTING
       EXCHANGE_RATE    = W_RATE
       LOCAL_AMOUNT     = W_LOCAL_AMT
       FIXED_RATE       = W_FIXED_RATE
     EXCEPTIONS
       OTHERS           = 01.

   IF SY-SUBRC <> 0.
     MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
                WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4
                RAISING AMOUNT_CALCULATION.
   ENDIF.

 ENDFORM.                    " CONVERT_TO_LOCAL_CURRENCY
*&---------------------------------------------------------------------*
*&      Form  set_wbs_element
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
 FORM SET_WBS_ELEMENT  USING    P_MSGTY.

   DESCRIBE TABLE IT_PSPNR LINES G_LINE.
   CASE G_LINE.
     WHEN C_ZERO.
       IF ZTITRQK-PSPNR IS INITIAL.
         IF P_MSGTY NE C_NONE.
           PERFORM NO_INPUT_CHECK USING 'ZTITRQK' 'PSPNR' P_MSGTY.
         ENDIF.
       ENDIF.
     WHEN C_ONE.
       READ TABLE IT_PSPNR INDEX 1.
       IF SY-SUBRC EQ 0.
         IF ZTITRQK-PSPNR IS INITIAL.
           MOVE IT_PSPNR-PSPNR TO  ZTITRQK-PSPNR.
         ELSEIF ZTITRQK-PSPNR NE IT_PSPNR-PSPNR.
           IF P_MSGTY NE C_NONE.
             SET CURSOR FIELD ZTITRQK-PSPNR.
             IF P_MSGTY NE C_NONE.
               MESSAGE ID 'ZMTI00' TYPE P_MSGTY NUMBER 020.
             ENDIF.
           ENDIF.
         ENDIF.
       ENDIF.
     WHEN OTHERS.
       IF P_MSGTY NE C_NONE.
         MESSAGE ID 'ZMTI00' TYPE P_MSGTY NUMBER 021.
       ENDIF.
   ENDCASE.

 ENDFORM.                    " set_wbs_element
*&---------------------------------------------------------------------*
*&      Form  set_insurance_class
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
 FORM SET_INSURANCE_CLASS  USING    P_MSGTY.

   CASE ZTITRQS-INCO1.
     WHEN SPACE.
       IF P_MSGTY NE C_NONE.
         PERFORM NO_INPUT_CHECK USING 'ZTITRQS' 'INCO1' P_MSGTY.
       ENDIF.
     WHEN 'FOB' OR 'FCA' OR 'FAS' OR 'CPT' OR 'CFR' OR 'EXW'.
       ZTITRQS-INSYN = C_CHARY.
     WHEN OTHERS.
       ZTITRQS-INSYN = C_CHARN.
   ENDCASE.

 ENDFORM.                    " set_insurance_class
*&---------------------------------------------------------------------*
*&      Form  set_amount_split
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
 FORM SET_AMOUNT_SPLIT .

*  IF ZTITRQK-ppaid IS INITIAL.
*    MESSAGE w125.
*  ENDIF.
*
*> 개설 금액 체크.
   PERFORM CHECK_OPEN_AMOUNT.

   ZTISSCRCOM-WAERS  =  ZTITRQS-WAERS.
   SPOP-TEXTLINE1    =  '구매오더액 대비 비율로 아이템이 배부됩니다.'.
   SPOP-TEXTLINE2    =  '금액을 분할하시겠습니까?'.

   CALL SCREEN  7000 STARTING AT 01    01
                     ENDING   AT 43    10.

   CHECK OK-CODE EQ 'ZTIOKAY'.

*> 금액 분할.
   PERFORM  SET_ITEM_AMOUNT_AND_QTY_CALC.

*> 개설 금액 체크.
   PERFORM CHECK_OPEN_AMOUNT.

 ENDFORM.                    " set_amount_split
*&---------------------------------------------------------------------*
*&      Form  set_item_amount_and_qty_calc
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
 FORM SET_ITEM_AMOUNT_AND_QTY_CALC .
   DATA: L_RATE      TYPE F,
         L_RQMNG     TYPE ZTIRQMNG,
         L_RQMNGL    TYPE ZTIRQMNGI,
         L_OPAMT_SUM LIKE ZTITRQS-OPAMT.

   CLEAR: L_OPAMT_SUM, L_RATE.

   L_RATE  =  ZTISSCRCOM-OPAMT / ZTITRQS-POAMT.
*  l_rate  =  ZTIsscrcom-opamt / ZTITRQS-opamt.
*> 수량 Over check
   LOOP AT IT_TAB INTO G_TC_2130_WA.
     L_RQMNG = G_TC_2130_WA-MENGE * L_RATE.
*    l_rqmng = g_tc_2130_wa-rqmng * l_rate.
     IF L_RQMNG  GT G_TC_2130_WA-RQMNGL.
       CLEAR: G_MENGET.
       WRITE G_TC_2130_WA-RQMNGL TO G_MENGET(15) UNIT G_TC_2130_WA-MEINS
       .
       CONCATENATE G_MENGET G_TC_2130_WA-MEINS INTO G_MENGET.
       MESSAGE E005 WITH G_MENGET.
     ENDIF.
     IF L_RQMNG  LT G_TC_2130_WA-PPMNG.
       CLEAR: G_MENGET.
       WRITE G_TC_2130_WA-PPMNG TO G_MENGET(15) UNIT G_TC_2130_WA-MEINS.
       CONCATENATE G_MENGET G_TC_2130_WA-MEINS INTO G_MENGET.
       MESSAGE E028 WITH G_MENGET.
     ENDIF.
   ENDLOOP.

   CLEAR: L_OPAMT_SUM.
   LOOP AT IT_TAB INTO G_TC_2130_WA.
     IF NOT G_TC_2130_WA-REPOS IS INITIAL.
       G_TC_2130_WA-RQMNG = G_TC_2130_WA-MENGE * L_RATE.
*    g_tc_2130_wa-rqmng = g_tc_2130_wa-rqmng * l_rate.
       G_TC_2130_WA-NETWR = G_TC_2130_WA-NETWR * L_RATE.
     ENDIF.

**> 정가 계산.
*    CALL FUNCTION 'Z_TI_CALC_ITEM_AMOUNT'
*      EXPORTING
*        peinh = g_tc_2130_wa-peinh
*        bpumz = g_tc_2130_wa-bpumz
*        bpumn = g_tc_2130_wa-bpumn
*        menge = g_tc_2130_wa-rqmng
*        netpr = g_tc_2130_wa-netpr
*      CHANGING
*        netwr = g_tc_2130_wa-netwr.
*
     MODIFY IT_TAB FROM G_TC_2130_WA.
     ADD G_TC_2130_WA-NETWR TO L_OPAMT_SUM.
   ENDLOOP.

   IF L_OPAMT_SUM NE ZTISSCRCOM-OPAMT.
     CLEAR: G_LINE.
     LOOP AT IT_TAB INTO G_TC_2130_WA.
       IF NOT G_TC_2130_WA-NETWR IS INITIAL.
         G_LINE = SY-TABIX.
       ENDIF.
     ENDLOOP.
*    DESCRIBE TABLE it_tab LINES g_line.
     READ TABLE IT_TAB INTO G_TC_2130_WA INDEX G_LINE.
     IF SY-SUBRC EQ 0.
       IF L_OPAMT_SUM GT ZTISSCRCOM-OPAMT.
         G_TC_2130_WA-NETWR = G_TC_2130_WA-NETWR
                            - ( L_OPAMT_SUM - ZTISSCRCOM-OPAMT ).
       ELSE.
         G_TC_2130_WA-NETWR = G_TC_2130_WA-NETWR
                            + ( ZTISSCRCOM-OPAMT - L_OPAMT_SUM ).
       ENDIF.
       MODIFY IT_TAB FROM G_TC_2130_WA INDEX G_LINE.
     ENDIF.
   ENDIF.

   ZTITRQS-OPAMT = ZTISSCRCOM-OPAMT.

 ENDFORM.                    " set_item_amount_and_qty_calc
*&---------------------------------------------------------------------*
*&      Form  set_Ocean_document_required
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
 FORM SET_OCEAN_DOCUMENT_REQUIRED .

*> Ocean B/L
   ZTITLC1-BLYCD = 'X'.
   IF ZTITLC1-BCON1 IS INITIAL.
     ZTITLC1-BCON1 = ZTSTIG3-ENMT1.
   ENDIF.
   IF ZTITLC1-BCON2 IS INITIAL.
     ZTITLC1-BCON2 = ZTSTIG3-ENMT2.
   ENDIF.

   IF ZTITLC1-BFREY IS INITIAL.
     CASE ZTITRQS-INCO1.
       WHEN 'CFR' OR 'CIF' OR 'CPT' OR 'CIP' OR
            'DES' OR 'DEQ' OR 'DDU' OR 'DDP' OR 'DAF'.
         ZTITLC1-BFREY = '31'.
       WHEN 'FOB' OR 'FCA' OR 'FAS' OR 'EXW'.
         ZTITLC1-BFREY = '32'.
     ENDCASE.
   ENDIF.

   IF ZTITLC1-BNOT1 IS INITIAL.
     ZTITLC1-BNOT1 = ZTSTIG0-EOMNS.
   ENDIF.

 ENDFORM.                    " set_Ocean_document_required
*&---------------------------------------------------------------------*
*&      Form  set_air_document_required
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
 FORM SET_AIR_DOCUMENT_REQUIRED .

*> Airway B/L
   ZTITLC1-ABYCD = 'X'.
   IF ZTITLC1-ACON1 IS INITIAL.
     ZTITLC1-ACON1 = ZTSTIG3-ENMT1.
   ENDIF.
   IF ZTITLC1-ACON2 IS INITIAL.
     ZTITLC1-ACON2 = ZTSTIG3-ENMT2.
   ENDIF.

   IF ZTITLC1-AFREY IS INITIAL.
     CASE ZTITRQS-INCO1.
       WHEN 'CFR' OR 'CIF' OR 'CPT' OR 'CIP' OR
            'DES' OR 'DEQ' OR 'DDU' OR 'DDP' OR 'DAF'.
         ZTITLC1-AFREY = '31'.
       WHEN 'FOB' OR 'FCA' OR 'FAS' OR 'EXW'.
         ZTITLC1-AFREY = '32'.
     ENDCASE.
   ENDIF.

   IF ZTITLC1-ANOT1 IS INITIAL.
     ZTITLC1-ANOT1 = ZTSTIG0-EOMNS.
   ENDIF.

 ENDFORM.                    " set_air_document_required
*&---------------------------------------------------------------------*
*&      Form  SET_OTHERS_DOCUMENTS_TEXT
*&---------------------------------------------------------------------*
*       기타 문서번호
*----------------------------------------------------------------------*
 FORM SET_OTHERS_DOCUMENTS_TEXT  USING    P_TEXT.

   ADD 1 TO G_COUNT.
   G_TC_2212_WA-QITNO  = G_COUNT.
   G_TC_2212_WA-LTEXT  = P_TEXT.
   APPEND  G_TC_2212_WA TO G_TC_2212_ITAB.

 ENDFORM.                    " SET_OTHERS_DOCUMENTS_TEXT

*&---------------------------------------------------------------------*
*&      Form  set_others_conditions_text
*&---------------------------------------------------------------------*
*       기타 부가조건
*----------------------------------------------------------------------*
 FORM SET_OTHERS_CONDITIONS_TEXT  USING    P_TEXT.

   ADD 1 TO G_COUNT.
   G_TC_2213_WA-QITNO  = G_COUNT.
   G_TC_2213_WA-LTEXT  = P_TEXT.
   APPEND  G_TC_2213_WA TO G_TC_2213_ITAB.

 ENDFORM.                    " set_others_conditions_text
*&---------------------------------------------------------------------*
*&      Form  set_amend_text
*&---------------------------------------------------------------------*
*       기타 부가조건
*----------------------------------------------------------------------*
 FORM SET_AMEND_TEXT  USING    P_TEXT.

   ADD 1 TO G_COUNT.
   G_TC_2216_WA-QITNO  = G_COUNT.
   G_TC_2216_WA-LTEXT  = P_TEXT.
   APPEND  G_TC_2216_WA TO G_TC_2216_ITAB.

 ENDFORM.                    " set_amend_text
*&---------------------------------------------------------------------*
*&      Form  set_price_or_place
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
 FORM SET_PRICE_OR_PLACE  USING    P_INCOX.

   CASE ZTITRQS-INCO1.
     WHEN 'FOB' OR 'FAS'.                                    ">선적항
       P_INCOX = ZTITRQS-PLLOD.
     WHEN 'DES' OR 'DEQ' OR 'DDU' OR 'DDP' OR 'CIP' OR 'CFR'.">도착항
       P_INCOX = ZTITRQS-PLTRN.
     WHEN OTHERS.                                     ">NAMED PLACE
       CLEAR: P_INCOX.
   ENDCASE.

 ENDFORM.                    " set_price_or_place
*&---------------------------------------------------------------------*
*&      Form  applications_print
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
 FORM APPLICATIONS_PRINT .
*      PERFORM  p8111_edi_item_table_read.
   CASE G_MODE.
     WHEN C_CHARY OR C_CHARO.
*> 공용 대화상자(메시지 통일).
       CALL FUNCTION 'Z_TI_POPUP_TO_CONFIRM_MESSAGE'
         EXPORTING
           XMODE  = C_CHARZ
         IMPORTING
           ANSWER = G_ANSWER.
     WHEN OTHERS.
       CASE ZTITRQS-DOCST.
         WHEN SPACE OR C_CHARC OR C_CHARW OR C_CHARY OR C_CHARA
                    OR C_CHARN OR C_CHARO OR C_CHAR1 OR C_CHAR2
                    OR C_CHAR3 OR C_CHARR OR SPACE.
           G_ANSWER = C_Y.
         WHEN OTHERS.
*> 문서상태 Fixed value read.
           PERFORM  DDIC_DOMAIN_VALUE_TEXT_READ USING 'ZTIDOCST1'
                                                      SY-LANGU
                                                      ZTITRQS-DOCST
                                                      G_DDTEXT
                                                      C_SUCCESS.

           MESSAGE S114 WITH ZTITRQS-REQNO ZTITRQS-AMDSQ G_DDTEXT.

           G_ANSWER = C_N.
       ENDCASE.
   ENDCASE.

   IF G_ANSWER EQ C_Y.
     IF G_MODE EQ C_CHARY OR
        G_MODE EQ C_CHARO.
       PERFORM CHECK_FOR_DOCUMENT_FIELD USING G_MODE.
       IF G_LINE EQ C_ZERO.
*>Switches on the local update task.
         SET UPDATE TASK LOCAL.
*>Data Save.
         PERFORM P8000_SAVE_MASTER_DATA USING G_MODE.
         CHECK G_SUBRC EQ C_ZERO.
       ENDIF.
     ENDIF.
     PERFORM  CALL_PRINT_PROCESS.
   ENDIF.

 ENDFORM.                    " applications_print
*&---------------------------------------------------------------------*
*&      Form  SET_CHANGE_SYMBOLS_MODE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
 FORM SET_CHANGE_SYMBOLS_MODE  USING    P_MODE.

   IF P_MODE EQ C_TRUE.
     IF SCREEN-NAME(1) EQ 'G'.
       SCREEN-INVISIBLE = C_CHAR0.
     ELSE.
       SCREEN-INTENSIFIED = C_CHAR1.
     ENDIF.
   ELSE.
     IF SCREEN-NAME(1) EQ 'G'.
       SCREEN-INVISIBLE = C_CHAR1.
     ELSE.
       SCREEN-INTENSIFIED = C_CHAR0.
     ENDIF.
   ENDIF.

 ENDFORM.                    " SET_CHANGE_SYMBOLS_MODE
*&---------------------------------------------------------------------*
*&      Form  compare_fields_changed
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
 FORM COMPARE_FIELDS_CHANGED .

*> Amount 구분자.
   IF ZTITRQS-OPAMT NE OLD_ZTITRQS-OPAMT.
     ZTITRQS-OPAMTX = C_TRUE.
   ELSE.
     ZTITRQS-OPAMTX = C_FALSE.
   ENDIF.
*> E/D 구분자.
   IF ZTITRQS-EXDAT NE OLD_ZTITRQS-EXDAT.
     ZTITRQS-EXDATX = C_TRUE.
   ELSE.
     ZTITRQS-EXDATX = C_FALSE.
   ENDIF.
*> S/D 구분자.
   IF ZTITRQS-LSDAT NE OLD_ZTITRQS-LSDAT.
     ZTITRQS-LSDATX = C_TRUE.
   ELSE.
     ZTITRQS-LSDATX = C_FALSE.
   ENDIF.
*> 분할선적 구분자.
   IF ZTITRQS-PARTY NE OLD_ZTITRQS-PARTY.
     ZTITRQS-PARTYX = C_TRUE.
   ELSE.
     ZTITRQS-PARTYX = C_FALSE.
   ENDIF.
*> 환적 구분자.
   IF ZTITRQS-TRANY NE OLD_ZTITRQS-TRANY.
     ZTITRQS-TRANYX = C_TRUE.
   ELSE.
     ZTITRQS-TRANYX = C_FALSE.
   ENDIF.
*> 보험적용구분자.
   IF ZTITRQS-INSYN NE OLD_ZTITRQS-INSYN.
     ZTITRQS-INSYNX = C_TRUE.
   ELSE.
     ZTITRQS-INSYNX = C_FALSE.
   ENDIF.
*> 운송방법.
   IF ZTITRQS-FWDTY NE OLD_ZTITRQS-FWDTY.
     ZTITRQS-FWDTYX = C_TRUE.
   ELSE.
     ZTITRQS-FWDTYX = C_FALSE.
   ENDIF.
*> Incoterms.
   IF ZTITRQS-INCO1 NE OLD_ZTITRQS-INCO1.
     ZTITRQS-INCO1X = C_TRUE.
   ELSE.
     ZTITRQS-INCO1X = C_FALSE.
   ENDIF.
*> 지급조건.
   IF ZTITRQS-ZTERM NE OLD_ZTITRQS-ZTERM.
     ZTITRQS-ZTERMX = C_TRUE.
   ELSE.
     ZTITRQS-ZTERMX = C_FALSE.
   ENDIF.
*> 선적항.
   IF ZTITRQS-PLLOD NE OLD_ZTITRQS-PLLOD.
     ZTITRQS-FPORTX = C_TRUE.
   ELSE.
     ZTITRQS-FPORTX = C_FALSE.
   ENDIF.
*> 도착항.
   IF ZTITRQS-PLTRN NE OLD_ZTITRQS-PLTRN.
     ZTITRQS-TPORTX = C_TRUE.
   ELSE.
     ZTITRQS-TPORTX = C_FALSE.
   ENDIF.
*> 원산지.
   IF ZTITRQS-CTONM NE OLD_ZTITRQS-CTONM.
     ZTITRQS-CTOCDX = C_TRUE.
   ELSE.
     ZTITRQS-CTOCDX = C_FALSE.
   ENDIF.

   CHECK: NOT ( G_MODE EQ C_CHARS OR
                G_MODE EQ C_CHARD ).

*> EDI table로 데이타 Move.
   CASE ZTITRQK-REQTY.
*----------------------------------------------------------------------
*> 신용장일 경우.
*----------------------------------------------------------------------
     WHEN C_LC.
*---> 금액.
       ZTITLC1-LAMPA = ZTITRQS-OPAMT - OLD_ZTITRQS-OPAMT.
       IF ZTITRQS-OPAMTX EQ C_TRUE.
         ZTITLC1-LAMLA = ZTITRQS-OPAMT.
       ELSE.
         CLEAR: ZTITLC1-LAMLA.
       ENDIF.
*---> E/D.
       IF ZTITRQS-EXDATX EQ C_TRUE.
         ZTITLC1-LEXDT = ZTITRQS-EXDAT.
       ELSE.
         CLEAR: ZTITLC1-LEXDT.
       ENDIF.
*---> S/D.
       IF ZTITRQS-LSDATX EQ C_TRUE.
         ZTITLC1-LSPDT = ZTITRQS-LSDAT.
       ELSE.
         CLEAR: ZTITLC1-LSPDT.
       ENDIF.
*---> 선적항.
       IF ZTITRQS-FPORTX EQ C_TRUE.
         ZTITLC1-LPLLO = ZTITRQS-PLLOD.
       ELSE.
         CLEAR: ZTITLC1-LPLLO.
       ENDIF.
*---> 도착항.
       IF ZTITRQS-TPORTX EQ C_TRUE.
         ZTITLC1-LPLTR = ZTITRQS-PLTRN.
       ELSE.
         CLEAR: ZTITLC1-LPLTR.
       ENDIF.
       ZTITLC1-OPDAT = ZTITRQS-SNDDT.
*----------------------------------------------------------------------
*> 내국 신용장일 경우.
*----------------------------------------------------------------------
     WHEN C_LO.
*---> 금액.
       IF ZTITRQS-OPAMTX EQ C_TRUE.
         ZTITLO1-LAMLA = ZTITRQS-OPAMT.
       ELSE.
         CLEAR: ZTITLO1-LAMLA.
       ENDIF.
*---> E/D.
       IF ZTITRQS-EXDATX EQ C_TRUE.
         ZTITLO1-LEXDT = ZTITRQS-EXDAT.
       ELSE.
         CLEAR: ZTITLO1-LEXDT.
       ENDIF.
*---> S/D.
       IF ZTITRQS-LSDATX EQ C_TRUE.
         ZTITLO1-SDLDT = ZTITRQS-LSDAT.
       ELSE.
         CLEAR: ZTITLO1-SDLDT.
       ENDIF.

*----------------------------------------------------------------------
*> 구매확인서일 경우.
*----------------------------------------------------------------------
     WHEN C_PU.
       ZTITPC1-PTAMT =  ZTITRQS-OPAMT.
       IF ZTITPC1-PTAMT GT OLD_ZTITPC1-PTAMT.
         ZTITPC1-PTDCT = 'S'.
         ZTITPC1-PDCAT =  ZTITPC1-PTAMT - OLD_ZTITPC1-PTAMT.
       ELSEIF ZTITPC1-PTAMT LT OLD_ZTITPC1-PTAMT.
         ZTITPC1-PTDCT = 'Q'.
         ZTITPC1-PDCAT =  OLD_ZTITPC1-PTAMT - ZTITPC1-PTAMT.
       ENDIF.
       ZTITPC1-PTAMF = ZTITRQS-USAMT.
       IF ZTITPC1-PTAMF GT OLD_ZTITPC1-PTAMF.
         ZTITPC1-PDCAF =  ZTITPC1-PTAMF - OLD_ZTITPC1-PTAMF.
       ELSEIF ZTITPC1-PTAMF LT OLD_ZTITPC1-PTAMF.
         ZTITPC1-PDCAF =  OLD_ZTITPC1-PTAMF - ZTITPC1-PTAMF.
       ENDIF.
   ENDCASE.

 ENDFORM.                    " compare_fields_changed
*&---------------------------------------------------------------------*
*&      Form  MOVE_EKKO_FIELDS_TO_ZTITRQS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
 FORM MOVE_EKKO_FIELDS_TO_ZTITRQS USING  P_EKKO     STRUCTURE EKKO
                                          P_ZTITRQS STRUCTURE ZTITRQS.
   FIELD-SYMBOLS <L_FS>.
   DATA: L_FIELDNAME TYPE FIELDNAME.

*  MOVE-CORRESPONDING   p_ekko  TO  p_ZTITRQS.

*> Offer을 복사할 구매오더 헤더 필드
   IF NOT ZTITIG30-OFFER IS INITIAL.
     CONCATENATE 'EKKO-' ZTITIG30-OFFER INTO L_FIELDNAME.
*     l_fieldname = 'EKKO-ZZOFFER'.
     ASSIGN (L_FIELDNAME) TO <L_FS>.
     IF SY-SUBRC     EQ 0        AND
        NOT <L_FS>   IS INITIAL.
       ZTITRQK-OFFER = <L_FS>.
     ENDIF.
   ENDIF.
   IF NOT ZTITIG00-PARVW IS INITIAL AND
          ZTITRQK-OFFER  IS INITIAL.
     SELECT LIFN2
       INTO ZTITRQK-OFFER
       FROM EKPA UP TO 1 ROWS
      WHERE EBELN EQ EKKO-EBELN
        AND EKORG EQ EKKO-EKORG
        AND PARVW EQ ZTITIG00-PARVW.
     ENDSELECT.
     IF SY-SUBRC NE 0.
       SELECT LIFN2
         INTO ZTITRQK-OFFER
         FROM WYT3 UP TO 1 ROWS
        WHERE LIFNR EQ EKKO-LIFNR
          AND EKORG EQ EKKO-EKORG
          AND PARVW EQ ZTITIG00-PARVW.
       ENDSELECT.
     ENDIF.
   ENDIF.

*> 수입자재종류 복사할 구매오더 헤더 필드
   IF NOT ZTITIG30-IMPTY IS INITIAL.
     CONCATENATE 'EKKO-' ZTITIG30-IMPTY INTO L_FIELDNAME.
*     l_fieldname = 'EKKO-ZZIMPTY'.
     ASSIGN (L_FIELDNAME) TO <L_FS>.
     IF SY-SUBRC     EQ 0        AND
        NOT <L_FS>   IS INITIAL.
       ZTITRQK-IMPTY = <L_FS>.
     ENDIF.
   ENDIF.

*> 운송방법 복사할 구매오더 헤더필드
   IF NOT ZTITIG30-FWDTY IS INITIAL.
     CONCATENATE 'EKKO-' ZTITIG30-FWDTY INTO L_FIELDNAME.
*     l_fieldname = 'EKKO-ZZFWDTY'.
     ASSIGN (L_FIELDNAME) TO <L_FS>.
     IF SY-SUBRC     EQ 0        AND
        NOT <L_FS>   IS INITIAL.
       ZTITRQS-FWDTY = <L_FS>.
     ENDIF.
   ENDIF.

*> 수입자 구분을 복사할 구매오더 헤더 필드
   IF NOT ZTITIG30-APPCT IS INITIAL.
     CONCATENATE 'EKKO-' ZTITIG30-APPCT INTO L_FIELDNAME.
*     l_fieldname = 'EKKO-ZZAPPCT'.
     ASSIGN (L_FIELDNAME) TO <L_FS>.
     IF SY-SUBRC     EQ 0        AND
        NOT <L_FS>   IS INITIAL.
       ZTITRQK-APPCT = <L_FS>.
     ENDIF.
   ENDIF.

*> 원산지 코드 복사할 구매오더 필드
   IF NOT ZTITIG30-CTOCD IS INITIAL.
     CONCATENATE 'EKKO-' ZTITIG30-CTOCD INTO L_FIELDNAME.
*     l_fieldname = 'EKKO-CTOCD'.
     ASSIGN (L_FIELDNAME) TO <L_FS>.
     IF SY-SUBRC     EQ 0        AND
        NOT <L_FS>   IS INITIAL.
       ZTITRQS-CTOCD = <L_FS>.
     ENDIF.
   ENDIF.

*> 원산지명 복사할 구매오더 헤더필드
   IF NOT ZTITIG30-CTONM IS INITIAL.
     CONCATENATE 'EKKO-' ZTITIG30-CTONM INTO L_FIELDNAME.
*     l_fieldname = 'EKKO-CTONM'.
     ASSIGN (L_FIELDNAME) TO <L_FS>.
     IF SY-SUBRC     EQ 0        AND
        NOT <L_FS>   IS INITIAL.
       ZTITRQS-CTONM = <L_FS>.
     ENDIF.
   ENDIF.

*> 선적국가코드 복사할 구매오더 헤더필드
   IF NOT ZTITIG30-FLAND IS INITIAL.
     CONCATENATE 'EKKO-' ZTITIG30-FLAND INTO L_FIELDNAME.
*     l_fieldname = 'EKKO-FLAND'.
     ASSIGN (L_FIELDNAME) TO <L_FS>.
     IF SY-SUBRC     EQ 0        AND
        NOT <L_FS>   IS INITIAL.
       ZTITRQS-FLAND = <L_FS>.
     ENDIF.
   ENDIF.

*> 선적항 복사할 구매오더 헤더필드
   IF NOT ZTITIG30-FPORT IS INITIAL.
     CONCATENATE 'EKKO-' ZTITIG30-FPORT INTO L_FIELDNAME.
*     l_fieldname = 'EKKO-FPORT'.
     ASSIGN (L_FIELDNAME) TO <L_FS>.
     IF SY-SUBRC     EQ 0        AND
        NOT <L_FS>   IS INITIAL.
       ZTITRQS-FPORT = <L_FS>.
     ENDIF.
   ENDIF.

*> 선적항 텍스트를 복사할 구매오더 헤더필드
   IF NOT ZTITIG30-PLLOD IS INITIAL.
     CONCATENATE 'EKKO-' ZTITIG30-PLLOD INTO L_FIELDNAME.
*     l_fieldname = 'EKKO-PLLOD'.
     ASSIGN (L_FIELDNAME) TO <L_FS>.
     IF SY-SUBRC     EQ 0        AND
        NOT <L_FS>   IS INITIAL.
       ZTITRQS-PLLOD = <L_FS>.
     ENDIF.
   ENDIF.

*> 도착국가코드 복사할 구매오더 헤더필드
   IF NOT ZTITIG30-TLAND IS INITIAL.
     CONCATENATE 'EKKO-' ZTITIG30-TLAND INTO L_FIELDNAME.
*     l_fieldname = 'EKKO-TLAND'.
     ASSIGN (L_FIELDNAME) TO <L_FS>.
     IF SY-SUBRC     EQ 0        AND
        NOT <L_FS>   IS INITIAL.
       ZTITRQS-TLAND = <L_FS>.
     ENDIF.
   ENDIF.

*> 도착항을 복사할 구매오더 헤더필드
   IF NOT ZTITIG30-TPORT IS INITIAL.
     CONCATENATE 'EKKO-' ZTITIG30-TPORT INTO L_FIELDNAME.
*     l_fieldname = 'EKKO-TPORT'.
     ASSIGN (L_FIELDNAME) TO <L_FS>.
     IF SY-SUBRC     EQ 0        AND
        NOT <L_FS>   IS INITIAL.
       ZTITRQS-TPORT = <L_FS>.
     ENDIF.
   ENDIF.

*> 도착항 텍스트를 복사할 구매오더 헤더필드
   IF NOT ZTITIG30-PLTRN IS INITIAL.
     CONCATENATE 'EKKO-' ZTITIG30-PLTRN INTO L_FIELDNAME.
*     l_fieldname = 'EKKO-PLTRN'.
     ASSIGN (L_FIELDNAME) TO <L_FS>.
     IF SY-SUBRC     EQ 0        AND
        NOT <L_FS>   IS INITIAL.
       ZTITRQS-PLTRN = <L_FS>.
     ENDIF.
   ENDIF.

*> 분할선적허용여부를 복사할 구매오더 헤더필드
   IF NOT ZTITIG30-PARTY IS INITIAL.
     CONCATENATE 'EKKO-' ZTITIG30-PARTY INTO L_FIELDNAME.
*     l_fieldname = 'EKKO-PARTY'.
     ASSIGN (L_FIELDNAME) TO <L_FS>.
     IF SY-SUBRC     EQ 0        AND
        NOT <L_FS>   IS INITIAL.
       IF <L_FS> EQ '9' OR
          <L_FS> EQ '10'.
         ZTITRQS-PARTY = <L_FS>.
       ENDIF.
     ENDIF.
   ENDIF.

*> 환적허용여부를 복사할 구매오더 헤더필드
   IF NOT ZTITIG30-TRANY IS INITIAL.
     CONCATENATE 'EKKO-' ZTITIG30-TRANY INTO L_FIELDNAME.
*     l_fieldname = 'EKKO-TRANY'.
     ASSIGN (L_FIELDNAME) TO <L_FS>.
     IF SY-SUBRC     EQ 0        AND
        NOT <L_FS>   IS INITIAL.
       IF <L_FS> EQ '7' OR
          <L_FS> EQ '8'.
         ZTITRQS-TRANY = <L_FS>.
       ENDIF.
     ENDIF.
   ENDIF.

*> 최종선적일자를 복사할 구매오더 헤더필드
   IF NOT ZTITIG30-LSDAT IS INITIAL.
     CONCATENATE 'EKKO-' ZTITIG30-LSDAT INTO L_FIELDNAME.
*     l_fieldname = 'EKKO-LSDAT'.
     ASSIGN (L_FIELDNAME) TO <L_FS>.
     IF SY-SUBRC     EQ 0        AND
        NOT <L_FS>   IS INITIAL.
       ZTITRQS-LSDAT = <L_FS>.
     ENDIF.
   ENDIF.

*> 유효일자를 복사할 구매오더 헤더 필드
   IF NOT ZTITIG30-EXDAT IS INITIAL.
     CONCATENATE 'EKKO-' ZTITIG30-EXDAT INTO L_FIELDNAME.
*     l_fieldname = 'EKKO-EXDAT'.
     ASSIGN (L_FIELDNAME) TO <L_FS>.
     IF SY-SUBRC     EQ 0        AND
        NOT <L_FS>   IS INITIAL.
       ZTITRQS-EXDAT = <L_FS>.
     ENDIF.
   ENDIF.
*> 개설희망일자를 복사할 구매오더 헤더필드
   IF NOT ZTITIG30-REQDT IS INITIAL.
     CONCATENATE 'EKKO-' ZTITIG30-REQDT INTO L_FIELDNAME.
*     l_fieldname = 'EKKO-REQDT'.
     ASSIGN (L_FIELDNAME) TO <L_FS>.
     IF SY-SUBRC     EQ 0        AND
        NOT <L_FS>   IS INITIAL.
       ZTITRQS-REQDT = <L_FS>.
     ENDIF.
   ENDIF.
*> 신용공여주체를 복사할 구매오더 헤더필드
   IF NOT ZTITIG30-PAGRT IS INITIAL.
     CONCATENATE 'EKKO-' ZTITIG30-PAGRT INTO L_FIELDNAME.
*     l_fieldname = 'EKKO-PAGRT'.
     ASSIGN (L_FIELDNAME) TO <L_FS>.
     IF SY-SUBRC     EQ 0        AND
        NOT <L_FS>   IS INITIAL.
       ZTITRQS-PAGRT = <L_FS>.
     ENDIF.
   ENDIF.
*> 수수료 부담자를 복사할 구매오더 헤더필드
   IF NOT ZTITIG30-CHGER IS INITIAL.
     CONCATENATE 'EKKO-' ZTITIG30-CHGER INTO L_FIELDNAME.
*     l_fieldname = 'EKKO-CHGER'.
     ASSIGN (L_FIELDNAME) TO <L_FS>.
     IF SY-SUBRC     EQ 0        AND
        NOT <L_FS>   IS INITIAL.
       ZTITLC1-CHGER = <L_FS>.
     ENDIF.
   ENDIF.
**>원산지.
*  MOVE: p_ekko-herkl   TO p_ZTITRQS-ctocd,
*        p_ekko-herkl_e TO p_ZTITRQS-ctonm.

**> 분할선적 허용여부.
*  IF p_ekko-party EQ c_char1.
*    p_ZTITRQS-party = '10'.
*  ELSE.
*    p_ZTITRQS-party = '9'.
*  ENDIF.
*
**>환적허용여부.
*  IF p_ekko-trany EQ c_char1.
*    p_ZTITRQS-trany = '8'.
*  ELSE.
*    p_ZTITRQS-trany = '7'.
*  ENDIF.
*
**> 최종선적일.
**  p_ZTITRQS-lsdat = p_ekko-lsdat.
**  p_ZTITRQS-lsdat =
*
**> 유효기일.
*  IF NOT p_ZTITRQS-lsdat IS INITIAL.
*    p_ZTITRQS-exdat = p_ZTITRQS-lsdat + 20.
*  ENDIF.

*> 전신환 송금일 경우  ---> 사전으로 Set.
   IF ZTITRQK-REQTY EQ C_TT.
     ZTITRQK-ANBTY = C_CHARB.
   ELSEIF ZTITRQK-REQTY EQ C_LO.
     ZTITLO1-LOPME = '2AD'.
   ENDIF.

   IF ZTITRQS-AMDSQ EQ '00'.
     ZTITRQK-ILCTY    = IT_ZTITIG02-ILCTY.
     ZTITRQK-USCDY    = IT_ZTITIG02-USCDY.
   ENDIF.

*> 가온전선 전신환 송금일 경우 기업은행 set
   IF  ZTITRQK-BUKRS EQ '6000'.
     IF ZTITRQK-REQTY  EQ C_TT.
       ZTITRQK-OPNBK = 'NET02'.
     ENDIF.
   ENDIF.


 ENDFORM.                    " MOVE_EKKO_FIELDS_TO_ZTITRQS
*&---------------------------------------------------------------------*
*&      Form  set_app700_default_value
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
 FORM SET_APP700_DEFAULT_VALUE .

   DATA: L_POS        TYPE I,
         L_TEXT30(30) TYPE C.
   DATA: L_LINE(65)      TYPE C,
         L_LONGTXT(65)   TYPE C,
         L_ROWCNT        TYPE I,
         L_HEADER1(65)   TYPE C,
         L_HEADER2(65)   TYPE C,
         L_FOOTER(65)    TYPE C,
         L_QUANTITY(17)  TYPE C,
         L_UNITPRICE(28) TYPE C,
         L_AMOUNT(18)    TYPE C.

   DATA: BEGIN OF LV_BODY OCCURS 0,
           BLANK(1),                 "indentation
           QUANTITY(17),             "HS-CODE
           UNITPRICE(28),             "품목내역
           AMOUNT(18),             "QUANTITY
         END OF LV_BODY .

   IF ZTITRQS-WERKS+0(1) = '5'.
*> applicant
     MOVE: ZTSTIG0-EOMNM  TO  ZTITLC1-APPNM,
           ZTSTIG0-EOMPR  TO  ZTITLC1-APPPR,
           ZTSTIG0-EOAD1  TO  ZTITLC1-APAD1,
           ZTSTIG0-EOAD2  TO  ZTITLC1-APAD2,
           ZTSTIG0-TELNO  TO  ZTITLC1-APTEL.

   ELSEIF ZTITRQS-WERKS+0(1) = '1'.
*> applicant
     MOVE: ZTSTIG0-EOMNM  TO  ZTITLC1-APPNM,
           ZTSTIG0-EOAD1  TO  ZTITLC1-APAD1,
           ZTSTIG0-EOAD2  TO  ZTITLC1-APAD2.

*--> [가온수입] 요청사항 반영
   ELSEIF ZTITRQS-WERKS+0(1) = '6'.
*> applicant
     MOVE: ZTSTIG0-EOMNM  TO  ZTITLC1-APPNM,
           ZTSTIG0-EOAD1  TO  ZTITLC1-APAD1,
           ZTSTIG0-EOAD2  TO  ZTITLC1-APAD2.
*<-- [가온수입] 요청사항 반영

   ENDIF.

***************************************************************
* 20080709 simcno by 박혁세K
***************************************************************
*> 명의인.
***************************************************************
*   MOVE: ztstig0-eomns  TO  ztitlc1-nomnm,
*         ztstig0-eompr  TO  ztitlc1-nompr,
*         ztstig0-eoad1  TO  ztitlc1-noad1,
*         ztstig0-eoad2  TO  ztitlc1-noad2,
*         ztstig0-esign  TO  ztitlc1-nomid.

   MOVE: ZTSTIG0-EOMNS  TO  ZTITLC1-NOMNM,
         ZTSTIG0-EOMPR  TO  ZTITLC1-NOMPR,
         G_EOAD1  TO  ZTITLC1-NOAD1,
         G_EOAD2  TO  ZTITLC1-NOAD2,
         ZTSTIG0-ESIGN  TO  ZTITLC1-NOMID.

   IF ZTITRQS-WERKS+0(1) = '6'.
     MOVE:  '120'  TO  ZTITLC1-NOMPR,
        'LS-RO 45BEN-GIL'  TO  ZTITLC1-APAD1,
        'GUNPO SI, GYEONG GI DO, SOUTH KOREA'  TO  ZTITLC1-APAD2.

   ENDIF.


***************************************************************

*> 개설은행.
   MOVE: "ZTSTIG3-epart  TO  ZTITLC1-opbcd,
         ZTSTIG3-IBKCD  TO  ZTITLC1-OPBCD,
         ZTSTIG3-ENMT1  TO  ZTITLC1-OPBNM,
         ZTSTIG3-ADDR1  TO  ZTITLC1-OPBBR,

*S__ 신용장 변경에 따른 수정 20181010 BY SDW
         ZTSTIG3-ADDR2  TO  ZTITLC1-OPBBR2,
*E__ 신용장 변경에 따른 수정 20181010 BY SDW

         ZTSTIG3-TELNO  TO  ZTITLC1-OPBTL.
*> 수신자 Setting.
   MOVE: ZTSTIG3-EPART  TO  ZTITRQS-RECID, ">수신자 IDs
         ZTSTIG3-NAMET  TO  ZTITRQS-RECNM,
         'APP700-'       TO  ZTITRQS-RECNO,
         ZTITRQS+3(10)  TO  ZTITRQS-RECNO+7(10),
         '-'             TO  ZTITRQS-RECNO+17(1),
         ZTITRQS+13(2)  TO  ZTITRQS-RECNO+18(2).

*> 수익자.
   CLEAR: LFBK.
   SELECT BANKN
     INTO LFBK-BANKN
     FROM LFBK UP TO 1 ROWS
    WHERE LIFNR EQ LFA1-LIFNR.
   ENDSELECT.

   MOVE: LFA1-NAME1      TO ZTITLC1-BENNM,
         LFA1-STRAS      TO ZTITLC1-BEAD1,
         LFA1-ORT01      TO ZTITLC1-BEAD2,
         LFA1-ORT02      TO ZTITLC1-BEAD3,
         LFBK-BANKN      TO ZTITLC1-BEFAC.
*> 기타 초기값 Setting.
   MOVE: C_CHAR9         TO ZTITLC1-RECTR,  ">전송.
         'AB'            TO ZTITLC1-RECAS,  ">응답요구.
         'DF'            TO ZTITLC1-OPMET,  ">개설방법.
         'DA'            TO ZTITLC1-CFIST,  ">확인지시문언.
         '5'             TO ZTITLC1-MLCTY,  ">신용장종류.
         '21'            TO ZTITLC1-SHDRD,  ">선적서류 제시기간.
         ZTITRQS-INCO2   TO ZTITLC1-EXPLC,  ">유효장소.
         '2AO'           TO ZTITLC1-PAYTY,  ">지급구분.
         '2AB'           TO ZTITLC1-ALCHY,  ">과부족허용여부.
         'AT NEGO BANK'  TO ZTITLC1-EXPLC,
         ZTITRQS-INCO1   TO ZTITLC1-INCON,
         ZTITRQS-INCO2   TO ZTITLC1-INCOP.

*> 가격조건 관련 장소.
   IF ZTITLC1-INCOP IS INITIAL.
     PERFORM  SET_PRICE_OR_PLACE  USING ZTITLC1-INCOP.
   ENDIF.
*----------------------------------------------------------------------
*> 지급조건.
*----------------------------------------------------------------------
   IF ZTITLC1-PATE1 IS INITIAL.
     IF ZTITRQK-ILCTY     EQ C_CHARA.   ">At Sight일 경우.
       ZTITLC1-PATE1 = 'AT SIGHT'.
     ELSEIF ZTITRQK-ILCTY EQ C_CHARU.   ">Usance일 경우.
       IF ZTITRQK-USCDY GT 999.
         L_POS = 0.
       ELSEIF ZTITRQK-USCDY GT 99.
         L_POS = 1.
       ELSEIF ZTITRQK-USCDY GT 9.
         L_POS = 2.
       ELSE.
         L_POS = 3.
       ENDIF.

*  ----> LG전선 요청에 의해 Text 문구 수정, by MSH(050126)
*       CONCATENATE ztitrqk-uscdy+l_pos  'DAYS AFTER SIGHT'
*  ----> End of Modification.
************************************************************************
* 20050907 simcho 박태균C 요청 문구수정
************************************************************************
*       CONCATENATE ztitrqk-uscdy+l_pos  'DAYS FROM B/L DATE'
*       INTO ztitlc1-pate1 SEPARATED BY space.
************************************************************************
* 20101013 CSR : C20100928_44287
************************************************************************

*-->> 11083 BU36 추가
*       IF ztitrqs-zterm = 'BU18'.
*       IF ZTITRQS-ZTERM = 'BU18' OR ZTITRQS-ZTERM = 'BU36'
*<<-- 11083 BU36 추가
*-{ 기능개선 193765 - 지급조건 추가
       IF ZTITRQS-ZTERM+0(2) = 'BU'.
*-} 기능개선 193765
         CONCATENATE ZTITRQK-USCDY+L_POS  'DAYS AFTER SIGHT'
         INTO ZTITLC1-PATE1 SEPARATED BY SPACE.
       ELSE.
         CONCATENATE ZTITRQK-USCDY+L_POS  'DAYS FROM B/L DATE'
         INTO ZTITLC1-PATE1 SEPARATED BY SPACE.
       ENDIF.
************************************************************************
     ENDIF.
   ENDIF.

*----------------------------------------------------------------------
*> 상품명세.
*----------------------------------------------------------------------
   CLEAR: G_COUNT.
************************************************************************
* 20101013 CSR : C20100928_44287
************************************************************************
*   l_line =
*     '----------------------------------------------------------------'
   .
************************************************************************
* 20101013 CSR : C20100928_44287
************************************************************************

   L_HEADER1 =
     ' H.S CODE   DESCRIPTION                                         '.
   L_HEADER2 =
     ' QUANTITY         UNIT PRICE                  AMOUNT            '.

************************************************************************
* 20101013 CSR : C20100928_44287
************************************************************************
   G_TC_2211_WA-LTEXT = L_LINE.
   ADD 1 TO G_COUNT.
   G_TC_2211_WA-QITNO  = G_COUNT.
   APPEND  G_TC_2211_WA TO G_TC_2211_ITAB.

   G_TC_2211_WA-LTEXT = L_HEADER1.
   ADD 1 TO G_COUNT.
   G_TC_2211_WA-QITNO  = G_COUNT.
   APPEND  G_TC_2211_WA TO G_TC_2211_ITAB.

   G_TC_2211_WA-LTEXT = L_HEADER2.
   ADD 1 TO G_COUNT.
   G_TC_2211_WA-QITNO  = G_COUNT.
   APPEND  G_TC_2211_WA TO G_TC_2211_ITAB.

   G_TC_2211_WA-LTEXT = L_LINE.
   ADD 1 TO G_COUNT.
   G_TC_2211_WA-QITNO  = G_COUNT.
   APPEND  G_TC_2211_WA TO G_TC_2211_ITAB.

   CLEAR : L_ROWCNT.

   LOOP AT IT_TAB INTO G_TC_2130_WA.

     L_ROWCNT = L_ROWCNT + 1.

*  ' H.S CODE   DESCRIPTION                                         '
     CONCATENATE '^' G_TC_2130_WA-STAWN '^' G_TC_2130_WA-TXZ01 ' '
            INTO L_LONGTXT.
     DO.
       REPLACE '^' WITH ' ' INTO L_LONGTXT.
       IF  SY-SUBRC  <>    0.
         EXIT.
       ENDIF.
     ENDDO.

     ADD 1 TO G_COUNT.
     G_TC_2211_WA-QITNO = G_COUNT.
     G_TC_2211_WA-LTEXT = L_LONGTXT.
     APPEND  G_TC_2211_WA TO G_TC_2211_ITAB.

*  ' QUANTITY       UNIT PRICE              AMOUNT                  '
*    QUANTITY
     WRITE: G_TC_2130_WA-RQMNG TO   L_QUANTITY
                               UNIT G_TC_2130_WA-MEINS
                               LEFT-JUSTIFIED.

************************************************************************
* 20101013 CSR : C20100928_44287
************************************************************************
*     IF g_tc_2130_wa-meins = 'TON'.
*       g_tc_2130_wa-meins = 'MT'.
*     ENDIF.
************************************************************************

     CONCATENATE L_QUANTITY G_TC_2130_WA-MEINS
                   INTO L_QUANTITY.
************************************************************************
* 20101013 CSR : C20100928_44287
************************************************************************
*     IF l_quantity = '1TON'.
*       l_quantity = 'MT'.
*     ENDIF.
************************************************************************
     WRITE: L_QUANTITY TO L_QUANTITY LEFT-JUSTIFIED.

*    UNIT PRICE
     WRITE: G_TC_2130_WA-NETPR TO   L_UNITPRICE
                               CURRENCY ZTITRQS-WAERS
                               LEFT-JUSTIFIED .

     WRITE: G_TC_2130_WA-PEINH TO   L_TEXT30 LEFT-JUSTIFIED.
     CONCATENATE ZTITRQS-WAERS L_UNITPRICE
                 '/' L_TEXT30 G_TC_2130_WA-BPRME
                   INTO L_UNITPRICE.
*                   SEPARATED BY space.

     WRITE: L_UNITPRICE TO L_UNITPRICE LEFT-JUSTIFIED.

*>   AMOUNT.
     WRITE: G_TC_2130_WA-NETWR TO   L_AMOUNT
                               CURRENCY ZTITRQS-WAERS
                               LEFT-JUSTIFIED.
     CONCATENATE ZTITRQS-WAERS L_AMOUNT
                   INTO L_AMOUNT
                   SEPARATED BY SPACE.

     MOVE L_QUANTITY  TO LV_BODY-QUANTITY.
     MOVE L_UNITPRICE TO LV_BODY-UNITPRICE.
     MOVE L_AMOUNT    TO LV_BODY-AMOUNT.

     L_LONGTXT = LV_BODY .

     ADD 1 TO G_COUNT.
     G_TC_2211_WA-QITNO = G_COUNT.
     G_TC_2211_WA-LTEXT = L_LONGTXT.
     APPEND  G_TC_2211_WA TO G_TC_2211_ITAB.

     IF L_ROWCNT > 185.
       EXIT.
     ENDIF.

   ENDLOOP.

   G_TC_2211_WA-LTEXT = L_LINE.
   ADD 1 TO G_COUNT.
   G_TC_2211_WA-QITNO  = G_COUNT.
   APPEND  G_TC_2211_WA TO G_TC_2211_ITAB.

*>개설금액
   CLEAR L_LONGTXT.
   WRITE: ZTITRQS-OPAMT TO L_LONGTXT CURRENCY ZTITRQS-WAERS
          LEFT-JUSTIFIED.
*>개설금액통화
   CONCATENATE ZTITRQS-WAERS L_LONGTXT INTO L_LONGTXT
     SEPARATED BY SPACE.
*   WRITE l_longtxt TO l_longtxt RIGHT-JUSTIFIED.

   CONCATENATE ' ' 'SUM OF AMOUNT        :' L_LONGTXT ' '
          INTO L_LONGTXT SEPARATED BY SPACE.
*   DO.
*     REPLACE '^' WITH ' ' INTO l_longtxt.
*     IF  sy-subrc  <>    0.
*       EXIT.
*     ENDIF.
*   ENDDO.

   G_TC_2211_WA-LTEXT = L_LONGTXT.
   ADD 1 TO G_COUNT.
   G_TC_2211_WA-QITNO  = G_COUNT.
   APPEND  G_TC_2211_WA TO G_TC_2211_ITAB.

   G_TC_2211_WA-LTEXT = L_LINE.
   ADD 1 TO G_COUNT.
   G_TC_2211_WA-QITNO  = G_COUNT.
   APPEND  G_TC_2211_WA TO G_TC_2211_ITAB.
** 20090813 주석처리
**> 자재내역.
*   LOOP AT it_tab INTO g_tc_2130_wa.
**> H/S CODE.
*     ADD 1 TO g_count.
*     g_tc_2211_wa-qitno  = g_count.
*     CONCATENATE 'H.S CODE :' g_tc_2130_wa-stawn
*                   INTO g_tc_2211_wa-ltext
*                   SEPARATED BY space.
*     APPEND  g_tc_2211_wa TO g_tc_2211_itab.
**> DESCRIPTION.
*     ADD 1 TO g_count.
*     g_tc_2211_wa-qitno  = g_count.
*     CONCATENATE 'DESCRIPTION :' g_tc_2130_wa-txz01
*                   INTO g_tc_2211_wa-ltext
*                   SEPARATED BY space.
*     APPEND  g_tc_2211_wa TO g_tc_2211_itab.
**> QUANTITY.
*     ADD 1 TO g_count.
*     g_tc_2211_wa-qitno  = g_count.
*     WRITE: g_tc_2130_wa-rqmng TO   g_tc_2211_wa-ltext
*                               UNIT g_tc_2130_wa-meins
*                               LEFT-JUSTIFIED.
*
**     PERFORM set_write_no_mask   USING g_tc_2211_wa-ltext.
*     CONCATENATE 'QUANTITY :' g_tc_2211_wa-ltext
*                              g_tc_2130_wa-meins
*                   INTO g_tc_2211_wa-ltext
*                   SEPARATED BY space.
*     APPEND  g_tc_2211_wa TO g_tc_2211_itab.
**> UNIT PRICE.
*     ADD 1 TO g_count.
*     g_tc_2211_wa-qitno  = g_count.
*     WRITE: g_tc_2130_wa-netpr TO   g_tc_2211_wa-ltext
*                               CURRENCY ztitrqs-waers
*                               LEFT-JUSTIFIED .
**     PERFORM set_write_no_mask   USING g_tc_2211_wa-ltext.
*     WRITE: g_tc_2130_wa-peinh TO   l_text30 LEFT-JUSTIFIED.
**     PERFORM set_write_no_mask   USING l_text30 .
*     CONCATENATE 'UNIT PRICE :' ztitrqs-waers g_tc_2211_wa-ltext
*                 '/' l_text30 g_tc_2130_wa-bprme
*                   INTO g_tc_2211_wa-ltext
*                   SEPARATED BY space.
*     APPEND  g_tc_2211_wa TO g_tc_2211_itab.
**> AMOUNT.
*     ADD 1 TO g_count.
*     g_tc_2211_wa-qitno  = g_count.
*     WRITE: g_tc_2130_wa-netwr TO   g_tc_2211_wa-ltext
*                               CURRENCY ztitrqs-waers
*                               LEFT-JUSTIFIED.
*     CONCATENATE 'AMOUNT :' ztitrqs-waers g_tc_2211_wa-ltext
*                   INTO g_tc_2211_wa-ltext
*                   SEPARATED BY space.
*     APPEND  g_tc_2211_wa TO g_tc_2211_itab.
*   ENDLOOP.
********************************************************************

*   DESCRIBE TABLE it_tab LINES g_line.
*   IF g_line GT 0.
*     ADD 1 TO g_count.
*     g_tc_2211_wa-qitno  = g_count.
*     READ TABLE it_tab INTO g_tc_2130_wa INDEX 1.
*     g_tc_2211_wa-ltext = g_tc_2130_wa-txz01.
*     IF g_line GT 1.
*       CONCATENATE g_tc_2211_wa-ltext 'AND OTHERS'
*                   INTO g_tc_2211_wa-ltext
*                   SEPARATED BY space.
*     ENDIF.
*     IF NOT ztitrqk-pspnr IS INITIAL.
*       CONCATENATE g_tc_2211_wa-ltext '(' proj-pspid ')'
*                   INTO g_tc_2211_wa-ltext
*                   SEPARATED BY space.
*     ENDIF.
*     APPEND  g_tc_2211_wa TO g_tc_2211_itab.
*   ENDIF.

**> 구매오더.
*   REFRESH: it_ponum.
*   LOOP AT it_tab INTO g_tc_2130_wa.
*     MOVE g_tc_2130_wa-ebeln TO it_ponum-ebeln.
*     COLLECT it_ponum.
*   ENDLOOP.
*   ADD 1 TO g_count.
*   g_tc_2211_wa-qitno  = g_count.
*   g_tc_2211_wa-ltext  = 'REF. NO. '.
*
**> 원산지
*   ADD 1 TO g_count.
*   g_tc_2211_wa-qitno  = g_count.
*   CONCATENATE '+ COUNTRY OF ORIGIN :' ztitrqs-ctonm
*               INTO g_tc_2211_wa-ltext
*               SEPARATED BY space.
*   APPEND  g_tc_2211_wa TO g_tc_2211_itab.
*
*   CLEAR: g_tabix, g_tc_2211_wa-ltext.
*   g_tc_2211_wa-ltext ='+ P/O NUMBER :'.
*   LOOP AT it_ponum.
*     g_tabix = sy-tabix.
*     g_mod   = g_tabix MOD 5.
*     IF g_tabix EQ 1.
*       CONCATENATE g_tc_2211_wa-ltext it_ponum-ebeln
*                   INTO g_tc_2211_wa-ltext
*                   SEPARATED BY space.
*     ELSE.
*       CONCATENATE g_tc_2211_wa-ltext '/' it_ponum-ebeln
*                   INTO g_tc_2211_wa-ltext
*                   SEPARATED BY space.
*     ENDIF.
*
*     IF g_mod EQ 0.
*       ADD 1 TO g_count.
*       g_tc_2211_wa-qitno  = g_count.
*       APPEND  g_tc_2211_wa TO g_tc_2211_itab.
*       CLEAR: g_tc_2211_wa.
*       g_tc_2211_wa-ltext = '/'.
*     ENDIF.
*   ENDLOOP.
*   IF g_mod NE 0.
*     ADD 1 TO g_count.
*     g_tc_2211_wa-qitno  = g_count.
*     APPEND  g_tc_2211_wa TO g_tc_2211_itab.
*   ENDIF.

*----------------------------------------------------------------------
*> 구비서류.
*----------------------------------------------------------------------
*> COMMERCIAL_INVOICE
   ZTITLC1-CIYCD = 'X'.      ZTITLC1-PLCPY = 3.
*> PACKING_LIST
   ZTITLC1-PLYCD = 'X'.      ZTITLC1-CICPY = 3.

*> 운송방법에 따라.
   CASE ZTITRQS-FWDTY.
     WHEN C_CHARA.   ">Air
       PERFORM  SET_AIR_DOCUMENT_REQUIRED.
     WHEN C_CHARO.   ">Ocean
       PERFORM  SET_OCEAN_DOCUMENT_REQUIRED.
     WHEN C_CHARC.   ">Air + Ocean
       PERFORM  SET_OCEAN_DOCUMENT_REQUIRED.
       PERFORM  SET_AIR_DOCUMENT_REQUIRED.
     WHEN C_CHARM.   ">Others.
   ENDCASE.

   DESCRIBE TABLE G_TC_2123_ITAB LINES G_LINE.
   IF G_LINE GT 0.
     ZTITLC1-MATE1 = C_TRUE.
     LOOP AT G_TC_2123_ITAB INTO  G_TC_2123_WA
                            WHERE FWDAM EQ C_TRUE.
       EXIT.
     ENDLOOP.
     IF SY-SUBRC NE 0.
       READ TABLE G_TC_2123_ITAB INTO  G_TC_2123_WA INDEX 1 .
     ENDIF.
     ZTITLC1-CARNM = G_TC_2123_WA-NAME1.
   ENDIF.

*> other documents
   ZTITLC1-ODYCD = 'X'.
*> Get 기타추가문서 텍스트.
   CLEAR: G_COUNT.
   SELECT *
     INTO CORRESPONDING FIELDS OF TABLE IT_ZTITIG52
     FROM ZTITIG52.

   SORT IT_ZTITIG52 BY OUTSQ.
*> 기본문구.
   LOOP AT IT_ZTITIG52 WHERE BASTX EQ C_TRUE
                         AND TXTCL NE C_CHARP.
     PERFORM  SET_OTHERS_DOCUMENTS_TEXT USING : IT_ZTITIG52-LTEXT.
   ENDLOOP.

*> 보험부보시.
   IF ZTITRQS-INSYN EQ C_CHARY.
     LOOP AT IT_ZTITIG52 WHERE TXTCL EQ C_CHARP.
       PERFORM  SET_OTHERS_DOCUMENTS_TEXT USING : IT_ZTITIG52-LTEXT.
     ENDLOOP.
     IF SY-SUBRC NE 0.
       ZTITLC1-IPYCD = C_TRUE.
     ENDIF.
   ENDIF.

*> 운송방법이 '기타일 경우'.
   IF ZTITRQS-FWDTY EQ C_CHARM.
     LOOP AT IT_ZTITIG52 WHERE TXTCL EQ C_CHARZ.
       PERFORM  SET_OTHERS_DOCUMENTS_TEXT USING : IT_ZTITIG52-LTEXT.
     ENDLOOP.
   ENDIF.
*----------------------------------------------------------------------
*> 부가조건.  --> Usance일 경우.
*----------------------------------------------------------------------
   IF ZTITRQK-ILCTY EQ C_CHARU.
     ZTITLC1-MATE2 = 'X'.
   ENDIF.
   ZTITLC1-MATE3 = 'X'.
* 기타 조건.
   ZTITLC1-MATE5 = 'X'.

*> 구매오더 명시 요구.
   CLEAR: G_COUNT.
   ADD 1 TO G_COUNT.
   G_TC_2213_WA-QITNO  = G_COUNT.
   G_TC_2213_WA-LTEXT  = '+ BUYER''''S P.O NO. '.

   CLEAR: G_TABIX.
   LOOP AT IT_PONUM.
     G_TABIX = SY-TABIX.
     G_MOD   = G_TABIX MOD 5.
     IF G_TABIX EQ 1.
       CONCATENATE G_TC_2213_WA-LTEXT IT_PONUM-EBELN
                   INTO G_TC_2213_WA-LTEXT
                   SEPARATED BY SPACE.
     ELSE.
       CONCATENATE G_TC_2213_WA-LTEXT '/' IT_PONUM-EBELN
                   INTO G_TC_2213_WA-LTEXT
                   SEPARATED BY SPACE.
     ENDIF.

     IF G_MOD EQ 0.
       ADD 1 TO G_COUNT.
       G_TC_2213_WA-QITNO  = G_COUNT.
       APPEND  G_TC_2213_WA TO G_TC_2213_ITAB.
       CLEAR: G_TC_2213_WA.
       G_TC_2213_WA-LTEXT = '/'.
     ENDIF.
   ENDLOOP.
   IF G_MOD NE 0.
     ADD 1 TO G_COUNT.
     G_TC_2213_WA-QITNO  = G_COUNT.
     APPEND  G_TC_2213_WA TO G_TC_2213_ITAB.
   ENDIF.
   PERFORM  SET_OTHERS_CONDITIONS_TEXT USING :
            '  SHOULD BE SHOWN ON EVERY TRANSPORT DOCUMENTS.'.

*> Get 기타조건 텍스트.
   SELECT *
     INTO CORRESPONDING FIELDS OF TABLE IT_ZTITIG51
     FROM ZTITIG51
    WHERE BASTX  EQ  C_TRUE.

   SORT IT_ZTITIG51 BY OUTSQ.

   LOOP AT IT_ZTITIG51 WHERE BASTX EQ C_TRUE.
     PERFORM  SET_OTHERS_CONDITIONS_TEXT USING : IT_ZTITIG51-LTEXT.
   ENDLOOP.

**> 마직막 추가..--> 이종 통화.
*   IF ztitrqs-umtcu EQ c_true AND   ">이종통화이고.
*      ztitrqk-ilcty EQ c_charu.     ">Usnace일 경우.
*     PERFORM  set_others_conditions_text USING :
*   '+ ACCEPTANCE SHOULD BE MADE IN U.S DOLLARS BY THE DRAWEE AT THE',
*    '  TIME OF PRESENTATION OF DOCUMENTS',
*    '  AND TLX QUOTING FX RATE AND CALCULATION PARAMETER THEREOF'.
*   ENDIF.
**> Usance일 경우.
*   IF ztitrqk-ilcty EQ c_charu.     ">Usnace일 경우
*     PERFORM  set_others_conditions_text USING :
*   '+ DISCOUNT CHARGE INCLUDING ACCEPTANCE COMM.MUST NOT EXCEED USD',
*    '  MONTHS LIBOR +          PERCENTAGE P.A'.
*   ENDIF.
*
   IF ZTITRQS-OTHT1 IS INITIAL.
     ZTITRQS-OTHT1 = ZTITRQS-EBELN.
   ENDIF.

*  if ztitrqs-otht2 is initial.
*    ZTITRQK-IMPTY
*
*    concatenate '자재구분 : '  into ztitrqs-otht2
*                     SEPARATED BY space.
*
*  endif.


 ENDFORM.                    " set_app700_default_value
*&---------------------------------------------------------------------*
*&      Form  set_app707_default_value
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
 FORM SET_APP707_DEFAULT_VALUE .

   CHECK: NOT ( G_MODE EQ C_CHARS OR
                G_MODE EQ C_CHARD ).

*> 수신자 Setting.
   MOVE: ZTSTIG3-EPART   TO  ZTITRQS-RECID, ">수신자 IDs
         ZTSTIG3-NAMET   TO  ZTITRQS-RECNM,
         'APP707-'       TO  ZTITRQS-RECNO,
         ZTITRQS+3(10)   TO  ZTITRQS-RECNO+7(10),
         '-'             TO  ZTITRQS-RECNO+17(1),
         ZTITRQS+13(2)   TO  ZTITRQS-RECNO+18(2).

   REFRESH: G_TC_2216_ITAB.
   CLEAR: G_COUNT.
*> 분할선적.
   IF ZTITRQS-PARTYX EQ C_TRUE.
     IF ZTITRQS-PARTY EQ '9'.          ">허용.
       PERFORM SET_AMEND_TEXT USING '+ PARTIAL SHIPMENT ALLOWED'.
     ELSEIF ZTITRQS-PARTY EQ '10'.     ">금지.
       PERFORM SET_AMEND_TEXT USING '+ PARTIAL SHIPMENT NOT ALLOWED'.
     ENDIF.
   ENDIF.

*> 환적.
   IF ZTITRQS-TRANYX EQ C_TRUE.
     IF ZTITRQS-TRANY EQ '7'.     ">허용.
       PERFORM SET_AMEND_TEXT USING '+ TRANSHIPMENT ALLOWED'.
     ELSEIF ZTITRQS-TRANY EQ '8'. ">금지.
       PERFORM SET_AMEND_TEXT USING '+ TRANSHIPMENT NOT ALLOWED'.
     ENDIF.
   ENDIF.

*> Incoterms
   IF ZTITRQS-INCO1X EQ C_TRUE.
     CONCATENATE '+ PRICE TERM CHANGED TO' ZTITRQS-INCO1
                 INTO G_TC_2216_WA-LTEXT
                       SEPARATED BY SPACE.

     PERFORM SET_AMEND_TEXT USING G_TC_2216_WA-LTEXT.
     CLEAR: G_TC_2216_WA-LTEXT.
   ENDIF.

 ENDFORM.                    " set_app707_default_value
*&---------------------------------------------------------------------*
*&      Form  set_payord_default_value
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
 FORM SET_PAYORD_DEFAULT_VALUE .
   DATA: LV_BNFA LIKE ZTITIG00-BNFA.

*> applicant
   MOVE: ZTSTIG0-EOMNM  TO  ZTITTT1-TOCNM,
         ZTSTIG0-EOMPR  TO  ZTITTT1-TOCPR1,
         ZTSTIG0-EOAD1  TO  ZTITTT1-TOCAD1,
         ZTSTIG0-EOAD2  TO  ZTITTT1-TOCAD2,
         ZTSTIG0-TELNO  TO  ZTITTT1-TOCTL.

*> 명의인.
   MOVE: ZTSTIG0-NOMNM  TO  ZTITTT1-TNONM,
         ZTSTIG0-NOMPR  TO  ZTITTT1-TNOPR,
*            ZTSTIG0-noad1  TO  ZTITTT1-toad1,
*            ZTSTIG0-noad2  TO  ZTITTT1-toad2,
         ZTSTIG0-ESIGN  TO  ZTITTT1-TNOID.

   MOVE: ZTSTIG0-NOAD1  TO  ZTITTT1-NOAD1,
         ZTSTIG0-NOAD2  TO  ZTITTT1-NOAD2.
*> 개설은행.
   MOVE: ZTSTIG3-IBKCD  TO  ZTITTT1-TOBCD,
         ZTSTIG3-ENMT1  TO  ZTITTT1-TOBNM,
         ZTSTIG3-ENMT2  TO  ZTITTT1-TOBBR,
         ZTSTIG3-IBKCD  TO  ZTITTT1-TOBCD,
         ZTITRQS-WAERS  TO  ZTITTT1-TOBAC,
         ZTITRQS-WAERS  TO  ZTITTT1-TBBAC.
*        ZTSTIG3-telno  TO  ZTITTT1-TObtl.

*   BREAK-POINT.

   SELECT BANKN
     INTO ZTITTT1-TOBAN
     FROM T012K UP TO 1 ROWS
    WHERE BUKRS EQ ZTITRQK-BUKRS
      AND WAERS EQ ZTITRQS-WAERS
*> 이장욱 위원 요청.    --> Start
      AND BKONT EQ 'E '
*> 이장욱 위원 요청.    --> Ened
      AND HBKID EQ ( SELECT HBKID
                       FROM ZTSTIG3
                      WHERE PARTI EQ 'B'
                        AND EPART EQ ZTSTIG3-EPART
                        AND BUKRS EQ ZTITRQK-BUKRS ).
   ENDSELECT.

*> 수신자 Setting.
   MOVE: ZTSTIG3-EPART  TO  ZTITRQS-RECID, ">수신자 IDs
         ZTSTIG3-NAMET  TO  ZTITRQS-RECNM,
         'PAYORD-'      TO  ZTITRQS-RECNO,
         ZTITRQS+3(10)  TO  ZTITRQS-RECNO+7(10),
         '-'            TO  ZTITRQS-RECNO+17(1),
         ZTITRQS+13(2)  TO  ZTITRQS-RECNO+18(2).

*> 수익자.
   CLEAR: LFBK.
   SELECT BANKN
     INTO LFBK-BANKN
     FROM LFBK UP TO 1 ROWS
    WHERE LIFNR EQ LFA1-LIFNR.
   ENDSELECT.

   MOVE: LFA1-NAME1      TO ZTITTT1-TBENM,
*                            TO ZTITTT1-TBEPR1
         LFA1-STRAS      TO ZTITTT1-TBEAD1,
         LFA1-ORT01      TO ZTITTT1-TBEAD2,
         LFA1-ORT02      TO ZTITTT1-TBEAD3,
         LFBK-BANKN      TO ZTITTT1-TBETL.
*> 기타 초기값 Setting.
   MOVE: C_CHAR9         TO ZTITTT1-RECTR,  ">전송.
         'AB'            TO ZTITTT1-RECAS,  ">유효장소.
         ZTITRQS-SNDDT   TO ZTITTT1-TAPDT,  ">신청일자.
         ZTITRQS-REQDT   TO ZTITTT1-TECDT,
         ZTITTT1-TBBAD3  TO ZTITTT1-TBBCD.

   IF ZTITRQK-ANBTY EQ C_CHARB.
     ZTITTT1-TPYME = C_CHAR4.  ">사전.
   ELSEIF ZTITRQK-ANBTY EQ C_CHARA.
     ZTITTT1-TPYME = C_CHAR5.  ">사후.
   ENDIF.


   IF ZTITRQK-BUKRS EQ '6000'.
     MOVE: 'P01'      TO ZTITTT1-TBENM.

   ENDIF.


*> 송금내역 텍스트.

*   IF ztittt1-tpyte1 IS INITIAL.
*     IF ztitrqk-anbty EQ c_charb.
*       ztittt1-tpyte1 = '전신송금 (T/T) ( 사전송금 )'.
*     ELSE.
*       ztittt1-tpyte1 = '전신송금 (T/T) ( 사후송금 )'.
*     ENDIF.
*   ENDIF.
*   IF ztittt1-tpyte2 IS INITIAL.
*     CONCATENATE t001-butxt '금융팀에 금액 확인 후 송금'
*                 INTO ztittt1-tpyte2 SEPARATED BY space.
*   ENDIF.
*   IF ztittt1-tpyte3 IS INITIAL.
*     CONCATENATE 'P/O NUMBER :' ztitrqs-ebeln
*                 INTO ztittt1-tpyte3 SEPARATED BY space.
*   ENDIF.
*> 송금내역 수정_050306 by jp, park
   IF ZTITTT1-TPYTE1 IS INITIAL.
     IF ZTITRQK-ANBTY EQ C_CHARB.
       ZTITTT1-TPYTE1 = 'Advanced Payment(T/T)'.
     ELSE.
       ZTITTT1-TPYTE1 = 'After Payment(T/T)'.
     ENDIF.
   ENDIF.

   IF ZTITTT1-TPYTE2 IS INITIAL.
     CONCATENATE 'P/O NUMBER :' ZTITRQS-EBELN
                 INTO ZTITTT1-TPYTE2 SEPARATED BY SPACE.
   ENDIF.

*> 수취인 계좌내역 Setting
***********************************************************************
* 회사별 프로세스 정의 개설요청 수취인거래은행 관리여부 => x
* 수취인 관리계좌내역에서 테이터를 QUERY
***********************************************************************
   SELECT SINGLE BNFA
    INTO LV_BNFA
    FROM ZTITIG00
   WHERE BUKRS EQ ZTITRQK-BUKRS.
***********************************************************************
   IF LV_BNFA EQ 'X'.
     SELECT SINGLE *
       FROM ZTITIG04
      WHERE BUKRS EQ ZTITRQK-BUKRS
        AND LIFNR EQ ZTITRQK-LIFNR
        AND WAERS EQ ZTITRQS-WAERS
        AND APVYN EQ 'B'.

     MOVE : ZTITIG04-TBBAM TO ZTITTT1-TBBAM,
            ZTITIG04-TBBAO TO ZTITTT1-TBBAO,
            ZTITTT1-TBBNM  TO ZTITTT1-TBBNM,
            ZTITTT1-TBBAD1 TO ZTITTT1-TBBBR,
            ZTITTT1-TBBAD2 TO ZTITRQS-OTHT5,
            ZTITTT1-TBBAD3 TO ZTITTT1-TBBCD,
            ZTITTT1-TBBAN  TO ZTITTT1-TBBAN.
     MOVE : ZTITIG04-TIBAO TO ZTITTT1-TIBAO.
*     MOVE : ztitig04-tibam TO ztittt1-tibam.
   ENDIF.
*> 기타정보
   READ TABLE IT_TAB INTO G_TC_2130_WA INDEX 1.
   IF SY-SUBRC EQ 0.
     IF ZTITRQS-OTHT1 IS INITIAL.
       MOVE G_TC_2130_WA-STAWN TO ZTITRQS-OTHT1.
     ENDIF.
     IF ZTITRQS-OTHT2 IS INITIAL.
       MOVE G_TC_2130_WA-TXZ01 TO ZTITRQS-OTHT2.
     ENDIF.
   ENDIF.
   IF ZTITRQS-OTHT3 IS INITIAL.
     MOVE ZTITRQS-WAERS TO ZTITRQS-OTHT3.
   ENDIF.
   IF ZTITRQS-OTHT4 IS INITIAL.
     WRITE ZTITRQS-OPAMT TO ZTITRQS-OTHT4 CURRENCY ZTITRQS-WAERS.
     CONDENSE ZTITRQS-OTHT4.
   ENDIF.

   DESCRIBE TABLE G_TC_2240_ITAB LINES G_LINE.
   IF G_LINE EQ 0.

     MOVE: 1             TO G_TC_2240_WA-TBQIT,
           '105'         TO G_TC_2240_WA-TBDCD,
           ZTITRQS-EBELN TO G_TC_2240_WA-TBDNO.
     SELECT SINGLE BEDAT
       INTO G_TC_2240_WA-TBIDT
       FROM EKKO
      WHERE EBELN EQ ZTITRQS-EBELN.
*TBIDT
*TBANO
     APPEND G_TC_2240_WA TO G_TC_2240_ITAB.

   ENDIF.

 ENDFORM.                    " set_payord_default_value
*&---------------------------------------------------------------------*
*&      Form  set_locapp_default_value
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
 FORM SET_LOCAPP_DEFAULT_VALUE .

************************************************************************
* 변경자 : FIB05            * 변경일 : 2011.10.27
* CSR No : C20110916_63637  * CSR제목 : 내국신용장 개설 시 필수조항 추가
* 변경내역 : 개설의뢰인과 수혜자에 사업자등록번호 default값으로.
************************************************************************
************************************************************************
* 변경자 : FIB05            * 변경일 : 2013.01.23
* CSR No : C20130123_58503
* CSR제목 : 내국신용장 개설 시 필수조항 추가
* 변경내역 : 개설의뢰인 내역에서 주소사항 삭제 및 신규주소필드추가.
************************************************************************
************************************************************************
* 변경자 : FIB03            * 변경일 : 2014.03.31
* CSR No : 14889
* CSR제목 : 로컬LC/구매확인서 EDI 정보변경
* 변경내역 : 로컬LC/구매확인서 개설요청시 EDI 수혜자번호 입력로직 변경
************************************************************************


* CSR No : C20130123_58503 START
*> applicant(개설의뢰인)
*   MOVE: ztstig0-nomnm  TO  ztitlo1-lapnm,
*         ztstig0-noad1  TO  ztitlo1-lappr1,
*         ztstig0-busid  TO  ztitlo1-lappr2.
**         ztstig0-noad2  TO  ztitlo1-lappr2.

   MOVE: ZTSTIG0-NOMNM  TO  ZTITLO1-LAPNM,
         ZTSTIG0-NOMPR  TO  ZTITLO1-LAPPR1,
         ZTSTIG0-BUSID  TO  ZTITLO1-LAPPR2.

   MOVE: ZTSTIG0-NOAD1  TO ZTITLO1-APAD1,
         ZTSTIG0-NOAD2  TO ZTITLO1-APAD2.
*         ztstig0-noad2  TO ztitlo1-APAD3.

* CSR No : C20130123_58503 END

*> 명의인.
   MOVE: ZTSTIG0-NOMNM  TO  ZTITLO1-LNONM,
         ZTSTIG0-NOMPR  TO  ZTITLO1-LNOPR,
*        ZTSTIG0-noad1  TO  ZTITLO1-noad1,
*        ZTSTIG0-noad2  TO  ZTITLO1-noad2,
         ZTSTIG0-ESIGN  TO  ZTITLO1-LNOID.

*> 개설은행.
   MOVE: ZTSTIG3-IBKCD  TO  ZTITLO1-LOBCD,
         ZTSTIG3-NAMET  TO  ZTITLO1-LOBNM,
         ZTSTIG3-ADDR1  TO  ZTITLO1-LOBBR.
*        ZTSTIG3-telno  TO  ZTITLC1-opbtl.

*> 수익자.(수혜자)
*  CLEAR: lfbk.
*  SELECT bankn
*    INTO lfbk-bankn
*    FROM lfbk UP TO 1 ROWS
*   WHERE lifnr EQ lfa1-lifnr.
*  ENDSELECT.

* CSR No : C20130123_58503 START
*   MOVE: lfa1-name1      TO ztitlo1-lbenm,
*         lfa1-ort01      TO ztitlo1-lbepr1,
*         lfa1-stcd2      TO ztitlo1-lbepr2.
**         lfa1-stras      TO ztitlo1-lbepr2.
**        lfa1-ort02      TO ZTITLO1-bead3,
**        lfbk-bankn      TO ZTITLO1-befac.

   MOVE: LFA1-NAME1      TO ZTITLO1-LBENM,
         LFA1-DATLT      TO ZTITLO1-LBEPR1.

*-->> 14889 로컬LC의 경우
* 수혜자번호 : 사업자번호+식별자+상세식별자 필수
*{Remark}
*         lfa1-stcd2      TO ztitlo1-lbepr2.
*{/Remark}

*{Insert}
   DATA : LV_IDENF  LIKE ZTSTIG3-IDENF,
          LV_IDENF1 LIKE ZTSTIG3-IDENF1.

   CLEAR : LV_IDENF, LV_IDENF1.

   CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
     EXPORTING
       INPUT  = LFA1-LIFNR
     IMPORTING
       OUTPUT = LFA1-LIFNR.

   SELECT SINGLE IDENF IDENF1
     FROM ZTSTIG3
     INTO (LV_IDENF, LV_IDENF1)
    WHERE PARTI = 'V'
      AND EPART = LFA1-LIFNR
      AND BUKRS = ZTITRQK-BUKRS.

   CLEAR : G_CHECK.    "에러체크용 변수

* 세 변수 모두 값이 있을때만 처리, 하나라도 없으면 에러처리
   IF LFA1-STCD2 IS NOT INITIAL AND
      LV_IDENF   IS NOT INITIAL AND
      LV_IDENF1  IS NOT INITIAL.

     CONCATENATE LFA1-STCD2 LV_IDENF '/' LV_IDENF1
               INTO ZTITLO1-LBEPR2.
   ELSE.
     CLEAR : ZTITLO1-LBEPR2.
     G_CHECK = 'X'.
   ENDIF.
*{/Insert}
*<<-- 14889

   MOVE: LFA1-ORT01      TO ZTITLO1-BEAD1,
         LFA1-STRAS      TO ZTITLO1-BEAD2.
*         lfa1-stras      TO ZTITLO1-BEAD2.
* CSR No : C20130123_58503 END


*> 수신자 Setting.
   MOVE: ZTSTIG3-EPART  TO  ZTITRQS-RECID, ">수신자 IDs
         ZTSTIG3-NAMET  TO  ZTITRQS-RECNM.

**> 기능개선 96084 - 2015.09.17 문서번호 변경
   DATA : LV_RECNO     LIKE ZTITRQS-RECNO,
          LV_RECNO_CON LIKE ZTITRQS-RECNO,
          LV_RECNO_MAX LIKE ZTITRQS-RECNO,
          LV_NUMC(3)   TYPE N.

   CLEAR : LV_RECNO, LV_RECNO_CON, LV_RECNO_MAX, LV_NUMC.

   IF ZTITRQS-REQNO IS INITIAL.
     IF ZTITRQK-BUKRS EQ '1000'.
       CONCATENATE 'LOCAPP' 'LOVE8888-'
       ZTSTIG3-IBKCD(2) ZTITRQS-SNDDT+2(6) '%'
       INTO LV_RECNO_CON.

       SELECT SINGLE MAX( RECNO )
        INTO LV_RECNO_MAX
        FROM ZTITRQS
         WHERE RECNO LIKE LV_RECNO_CON.
       IF LV_RECNO_MAX IS NOT INITIAL.
         LV_NUMC = LV_RECNO_MAX+25(3) + '001'.
         CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
           EXPORTING
             INPUT  = LV_NUMC
           IMPORTING
             OUTPUT = LV_NUMC.
         CONCATENATE 'LOCAPP' 'LOVE8888-'
         ZTSTIG3-IBKCD(2) ZTITRQS-SNDDT+2(6) LV_NUMC
         INTO LV_RECNO.
       ELSE.
         LV_NUMC = '001'.
         CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
           EXPORTING
             INPUT  = LV_NUMC
           IMPORTING
             OUTPUT = LV_NUMC.
         CONCATENATE 'LOCAPP' 'LOVE8888-'
         ZTSTIG3-IBKCD(2) ZTITRQS-SNDDT+2(6) LV_NUMC
         INTO LV_RECNO.
       ENDIF.

     ELSEIF ZTITRQK-BUKRS EQ '3000'.
       CONCATENATE 'LOCAPP' 'LSM9123-'
       ZTSTIG3-IBKCD(2) ZTITRQS-SNDDT+2(6) '%'
       INTO LV_RECNO_CON.

       SELECT SINGLE MAX( RECNO )
        INTO LV_RECNO_MAX
        FROM ZTITRQS
         WHERE RECNO LIKE LV_RECNO_CON.
       IF LV_RECNO_MAX IS NOT INITIAL.
         LV_NUMC = LV_RECNO_MAX+24(3) + '001'.
         CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
           EXPORTING
             INPUT  = LV_NUMC
           IMPORTING
             OUTPUT = LV_NUMC.
         CONCATENATE 'LOCAPP' 'LSM9123-'
         ZTSTIG3-IBKCD(2) ZTITRQS-SNDDT+2(6) LV_NUMC
         INTO LV_RECNO.
       ELSE.
         LV_NUMC = '001'.
         CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
           EXPORTING
             INPUT  = LV_NUMC
           IMPORTING
             OUTPUT = LV_NUMC.
         CONCATENATE 'LOCAPP' 'LSM9123-'
         ZTSTIG3-IBKCD(2) ZTITRQS-SNDDT+2(6) LV_NUMC
         INTO LV_RECNO.
       ENDIF.

     ELSEIF ZTITRQK-BUKRS EQ '5000'.   "LSEVK 추가
       CONCATENATE 'LOCAPP' 'LSEVK7-'
       ZTSTIG3-IBKCD(2) ZTITRQS-SNDDT+2(6) '%'
       INTO LV_RECNO_CON.

       SELECT SINGLE MAX( RECNO )
        INTO LV_RECNO_MAX
        FROM ZTITRQS
         WHERE RECNO LIKE LV_RECNO_CON.
       IF LV_RECNO_MAX IS NOT INITIAL.
         LV_NUMC = LV_RECNO_MAX+25(3) + '001'.
         CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
           EXPORTING
             INPUT  = LV_NUMC
           IMPORTING
             OUTPUT = LV_NUMC.
         CONCATENATE 'LOCAPP' 'LSEVK7-'
         ZTSTIG3-IBKCD(2) ZTITRQS-SNDDT+2(6) LV_NUMC
         INTO LV_RECNO.
       ELSE.
         LV_NUMC = '001'.
         CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
           EXPORTING
             INPUT  = LV_NUMC
           IMPORTING
             OUTPUT = LV_NUMC.
         CONCATENATE 'LOCAPP' 'LSEVK7-'
         ZTSTIG3-IBKCD(2) ZTITRQS-SNDDT+2(6) LV_NUMC
         INTO LV_RECNO.
       ENDIF.

     ELSEIF ZTITRQK-BUKRS EQ '6000'.   "가온전선 추가
       CONCATENATE 'LOCAPP' 'GAON77-'
       ZTSTIG3-IBKCD(2) ZTITRQS-SNDDT+2(6) '%'
       INTO LV_RECNO_CON.

       SELECT SINGLE MAX( RECNO )
        INTO LV_RECNO_MAX
        FROM ZTITRQS
         WHERE RECNO LIKE LV_RECNO_CON.
       IF LV_RECNO_MAX IS NOT INITIAL.
         LV_NUMC = LV_RECNO_MAX+25(3) + '001'.
         CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
           EXPORTING
             INPUT  = LV_NUMC
           IMPORTING
             OUTPUT = LV_NUMC.
         CONCATENATE 'LOCAPP' 'GAON77-'
         ZTSTIG3-IBKCD(2) ZTITRQS-SNDDT+2(6) LV_NUMC
         INTO LV_RECNO.
       ELSE.
         LV_NUMC = '001'.
         CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
           EXPORTING
             INPUT  = LV_NUMC
           IMPORTING
             OUTPUT = LV_NUMC.
         CONCATENATE 'LOCAPP' 'GAON77-'
         ZTSTIG3-IBKCD(2) ZTITRQS-SNDDT+2(6) LV_NUMC
         INTO LV_RECNO.
       ENDIF.

     ENDIF.
     MOVE LV_RECNO TO ZTITRQS-RECNO.
   ENDIF.

*move:         'LOCAPP-'       TO  ztitrqs-recno,
*         ztitrqs+3(10)  TO  ztitrqs-recno+7(10),
*         '-'             TO  ztitrqs-recno+17(1),
*         ztitrqs+13(2)  TO  ztitrqs-recno+18(2).

*> 기타 초기값 Setting.
   MOVE: C_CHAR9         TO ZTITLC1-RECTR,  ">전송.
         'AB'            TO ZTITLC1-RECAS,  ">응답요구.
*-> CSR 2014022100035 / V001 선적서류 제시기간 7->5일 변경
*         7               TO ztitlo1-ldodt,  ">선적서류 제시기간.
         5               TO ZTITLO1-LDODT,  ">선적서류 제시기간.
*<- CSR 2014022100035 / V001 선적서류 제시기간 7->5일 변경
         1               TO ZTITLO1-L2AHN,
         '9'             TO ZTITLO1-RECTR,
         'AB'            TO ZTITLO1-RECAS,
         1               TO ZTITLO1-L2AJN,
         1               TO ZTITLO1-L2APN,
         1               TO ZTITLO1-L310N.

*> 자재내역.
   DESCRIBE TABLE IT_TAB LINES G_LINE.
   IF G_LINE GT 0.
     ADD 1 TO G_COUNT.
     G_TC_2211_WA-QITNO  = G_COUNT.
     READ TABLE IT_TAB INTO G_TC_2130_WA INDEX 1.
     ZTITLO1-LGDO1 = G_TC_2130_WA-TXZ01.
*>by PJP(050705)미그변경수정

     ZTITLO1-STAWN = G_TC_2130_WA-STAWN.

     IF G_LINE GT 1.
       CONCATENATE ZTITLO1-LGDO1 'AND OTHERS'
                   INTO ZTITLO1-LGDO1
                   SEPARATED BY SPACE.
     ENDIF.
     IF NOT ZTITRQK-PSPNR IS INITIAL.
*      CONCATENATE ZTITLO1-lgdo1 '( H' ZTITRQK-pspnr ')'
       CONCATENATE ZTITLO1-LGDO1 '( H' PROJ-PSPID ')'
                   INTO ZTITLO1-LGDO1
                   SEPARATED BY SPACE.
     ENDIF.
   ENDIF.

*> 물품확약서 번호.
*>ZTITLO1-LSENO1
 ENDFORM.                    " set_locapp_default_value
*&---------------------------------------------------------------------*
*&      Form  set_locamr_default_value
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
 FORM SET_LOCAMR_DEFAULT_VALUE .
*> 수신자 Setting.
   MOVE: ZTSTIG3-EPART  TO  ZTITRQS-RECID, ">수신자 IDs
         ZTSTIG3-NAMET  TO  ZTITRQS-RECNM,
         'LOCAMR-'       TO  ZTITRQS-RECNO,
         ZTITRQS+3(10)  TO  ZTITRQS-RECNO+7(10),
         '-'             TO  ZTITRQS-RECNO+17(1),
         ZTITRQS+13(2)  TO  ZTITRQS-RECNO+18(2).

*-->> 14889 로컬LC Amend의 경우
* 수혜자번호 : 사업자번호+식별자+상세식별자 필수
*{Insert}
   DATA : LV_IDENF  LIKE ZTSTIG3-IDENF,
          LV_IDENF1 LIKE ZTSTIG3-IDENF1.

   CLEAR : LV_IDENF, LV_IDENF1.

   CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
     EXPORTING
       INPUT  = LFA1-LIFNR
     IMPORTING
       OUTPUT = LFA1-LIFNR.

   SELECT SINGLE IDENF IDENF1
     FROM ZTSTIG3
     INTO (LV_IDENF, LV_IDENF1)
    WHERE PARTI = 'V'
      AND EPART = LFA1-LIFNR
      AND BUKRS = ZTITRQK-BUKRS.

   CLEAR : G_CHECK.    "에러체크용 변수

* 세 변수 모두 값이 있을때만 처리, 하나라도 없으면 에러처리
   IF LFA1-STCD2 IS NOT INITIAL AND
      LV_IDENF   IS NOT INITIAL AND
      LV_IDENF1  IS NOT INITIAL.

     CONCATENATE LFA1-STCD2 LV_IDENF '/' LV_IDENF1
               INTO ZTITLO1-LBEPR2.
   ELSE.
     CLEAR : ZTITLO1-LBEPR2.
     G_CHECK = 'X'.
   ENDIF.
*{/Insert}
*<<-- 14889

 ENDFORM.                    " set_locamr_default_value
*&---------------------------------------------------------------------*
*&      Form  set_apppcr_default_value
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
 FORM SET_APPPCR_DEFAULT_VALUE .

   DATA: L_REQNO    TYPE  ZTIREQNO.
**************************************************
* Date : 2011/02/15
* CSR  : C20110118_09237
**************************************************
   DATA : LV_ADRNR      LIKE LFA1-ADRNR,
          LV_EXTENSION1 LIKE ADRC-EXTENSION1.

   CLEAR : ADRC.

   SELECT SINGLE EXTENSION1 INTO LV_EXTENSION1
     FROM ADRC
    WHERE ADDRNUMBER = LFA1-ADRNR
      AND EXTENSION1 <> ''.
**************************************************

*> 신청인.
   MOVE: ZTSTIG0-NOMNM TO ZTITPC1-PAPNM,
         ZTSTIG0-NOMPR TO ZTITPC1-PAPPR,
         ZTSTIG0-BUSID TO ZTITPC1-PAPID,
         ZTSTIG0-NOAD1 TO ZTITPC1-PAPAD1,
         ZTSTIG0-NOAD2 TO ZTITPC1-PAPAD2,
         SPACE          TO ZTITPC1-PAPAD3.
*> 공급자.
   MOVE: LFA1-NAME1      TO ZTITPC1-PSPNM,
         LFA1-J_1KFREPRE TO ZTITPC1-PSPPR,
         LFA1-ORT01      TO ZTITPC1-PSPAD1,
         LFA1-STRAS      TO ZTITPC1-PSPAD2,
         SPACE           TO ZTITPC1-PSPAD3.

*-->> 14889 구매확인서의 경우
* 1. 메인화면에서 동보전송 체크하면
*    사업자등록번호 : 사업자번호+식별자+상세식별자 필수
* 2. 메인화면에서 동보전송 언체크하면
*    사업자등록번호 : 사업자번호
*{Remark}
*         lfa1-stcd2      TO ztitpc1-pspid.
*{/Remark}

*{Insert}
   DATA : LV_IDENF  LIKE ZTSTIG3-IDENF,
          LV_IDENF1 LIKE ZTSTIG3-IDENF1.

   CLEAR : LV_IDENF, LV_IDENF1.

   CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
     EXPORTING
       INPUT  = LFA1-LIFNR
     IMPORTING
       OUTPUT = LFA1-LIFNR.

   SELECT SINGLE IDENF IDENF1
     FROM ZTSTIG3
     INTO (LV_IDENF, LV_IDENF1)
    WHERE PARTI = 'V'
      AND EPART = LFA1-LIFNR
      AND BUKRS = ZTITRQK-BUKRS.

   CLEAR : G_CHECK.    "에러체크용 변수

   IF ZTITRQS-DONGBO = 'X'.
* 세 변수 모두 값이 있을때만 처리, 하나라도 없으면 에러처리
     IF LFA1-STCD2 IS NOT INITIAL AND
        LV_IDENF   IS NOT INITIAL AND
        LV_IDENF1  IS NOT INITIAL.

       CONCATENATE LFA1-STCD2 LV_IDENF '/' LV_IDENF1
                 INTO ZTITPC1-PSPID.
     ELSE.
       CLEAR : ZTITPC1-PSPID.
       G_CHECK = 'X'.
     ENDIF.

   ELSE.
     MOVE LFA1-STCD2      TO ZTITPC1-PSPID.
   ENDIF.
*{/Insert}
*<<-- 14889

*> 명의인.
   MOVE: ZTSTIG0-NOMNM TO ZTITPC1-PNONM,
         ZTSTIG0-NOMPR TO ZTITPC1-PNOPR,
         ZTSTIG0-ESIGN TO ZTITPC1-PNOID.

*> 발급은행.
   MOVE: ZTSTIG3-IBKCD TO ZTITPC1-PCBCD,
         ZTSTIG3-NAMET TO ZTITPC1-PCBNM,
         SPACE          TO ZTITPC1-PCBBR.

*> 수신자 Setting.
   MOVE: ZTSTIG3-EPART  TO  ZTITRQS-RECID, ">수신자 IDs
         ZTSTIG3-NAMET  TO  ZTITRQS-RECNM,
         'APPPCR-'       TO  ZTITRQS-RECNO,
         ZTITRQS+3(10)  TO  ZTITRQS-RECNO+7(10),
         '-'             TO  ZTITRQS-RECNO+17(1),
         ZTITRQS+13(2)  TO  ZTITRQS-RECNO+18(2).

*> 기타 초기값 Setting.
   MOVE: C_CHAR9         TO ZTITPC1-RECTR,  ">전송.
         'AB'            TO ZTITPC1-RECAS,  ">응답요구.
         '2CG'           TO ZTITPC1-PDOTY,
         ZTITRQS-UCURR  TO ZTITPC1-UCURR,
         ZTITRQS-WAERS  TO ZTITPC1-PDCATC,
         ZTITRQS-WAERS  TO ZTITPC1-PTAMTC,
         ZTITRQS-OPAMT  TO ZTITPC1-PTAMT,
         ZTITRQS-USAMT  TO ZTITPC1-PTAMF.

**************************************************
* Date : 2011/02/15
* CSR  : C20110118_09237 - 공급자대표명 변경
**************************************************
   IF ZTITRQK-REQTY = 'PU'. "구매승인서
     MOVE: LV_EXTENSION1 TO ZTITPC1-PSPPR.
   ENDIF.
**************************************************
   IF ZTITRQS-AMDSQ GT 0.
     MOVE: '2CH'              TO ZTITPC1-PDOTY,
           OLD_ZTITRQS-OPNNO TO ZTITPC1-PBFNO,
           ZTITPC1-PCBCD     TO ZTITPC1-PIBCD,
           ZTITPC1-PCBNM     TO ZTITPC1-PIBNM,
           ZTITPC1-PCBBR     TO ZTITPC1-PIBBR.

     IF ZTITPC1-PTAMT GT OLD_ZTITPC1-PTAMT.
       ZTITPC1-PTDCT = 'S'.
       ZTITPC1-PDCAT =  ZTITPC1-PTAMT - OLD_ZTITPC1-PTAMT.
     ELSEIF ZTITPC1-PTAMT LT OLD_ZTITPC1-PTAMT.
       ZTITPC1-PTDCT = 'Q'.
       ZTITPC1-PDCAT =  OLD_ZTITPC1-PTAMT - ZTITPC1-PTAMT.
     ENDIF.

     IF ZTITPC1-PTAMF GT OLD_ZTITPC1-PTAMF.
       ZTITPC1-PDCAF =  ZTITPC1-PTAMF - OLD_ZTITPC1-PTAMF.
     ELSEIF ZTITPC1-PTAMF LT OLD_ZTITPC1-PTAMF.
       ZTITPC1-PDCAF =  OLD_ZTITPC1-PTAMF - ZTITPC1-PTAMF.
     ENDIF.
   ENDIF.

*> 근거서류.
   IF ZTITRQS-AMDSQ EQ 0.
     REFRESH: G_TC_2220_1_ITAB.
     CLEAR: G_TC_2220_1_ITAB, L_REQNO.

     SELECT MAX( REQNO )
       INTO L_REQNO
       FROM ZTITRQK
      WHERE PSPNR  EQ  ZTITRQK-PSPNR.
     IF NOT L_REQNO IS INITIAL.
       SELECT *
         INTO CORRESPONDING FIELDS OF G_TC_2220_1_WA
         FROM ZTITPC2 UP TO 1 ROWS
        WHERE REQNO EQ L_REQNO.
       ENDSELECT.
       MOVE: 1              TO G_TC_2220_1_WA-PBQIT.
     ELSE.
       MOVE: 1              TO G_TC_2220_1_WA-PBQIT,
             '2AN'          TO G_TC_2220_1_WA-PBDTY,
*            ZTITRQK-pspnr TO g_tc_2220_1_wa-pbdno.
             PROJ-PSPID     TO G_TC_2220_1_WA-PBDNO.
     ENDIF.
     APPEND G_TC_2220_1_WA TO G_TC_2220_1_ITAB.
   ENDIF.

*> 품목내역.
   REFRESH: G_TC_2220_2_ITAB.
   CLEAR: G_COUNT, ZTITPC1-PTNUM, G_WRBTR, G_DMBTR.
   LOOP AT IT_TAB INTO G_TC_2130_WA.
     IF G_COUNT EQ 999.
       EXIT.
     ENDIF.
     CLEAR:G_TC_2220_2_WA.
     ADD 1 TO G_COUNT.
     IF G_COUNT EQ 1.
       MOVE: G_TC_2130_WA-MEINS TO ZTITPC1-PTNUMU.
     ENDIF.
     MOVE: G_COUNT            TO G_TC_2220_2_WA-PCQIT,
           G_TC_2130_WA-STAWN TO G_TC_2220_2_WA-PCHSC,
           G_TC_2130_WA-RQMNG TO G_TC_2220_2_WA-PCNUM,
           G_TC_2130_WA-MEINS TO G_TC_2220_2_WA-PCNUMU,
           ZTITRQS-WAERS     TO G_TC_2220_2_WA-PCAMTC,
           'USD'              TO G_TC_2220_2_WA-PCAMTU,
           G_TC_2130_WA-NETPR TO G_TC_2220_2_WA-PCPAM,
           G_TC_2130_WA-NETWR TO G_TC_2220_2_WA-PCAMT,
           G_TC_2130_WA-TXZ01 TO G_TC_2220_2_WA-PCSNM.
*>USD 단가.
     CALL FUNCTION 'BAPI_CURRENCY_CONV_TO_EXTERN_9'
       EXPORTING
         CURRENCY        = ZTITRQS-WAERS
         AMOUNT_INTERNAL = G_TC_2130_WA-NETPR
       IMPORTING
         AMOUNT_EXTERNAL = BAPICURX-BAPICURX.

     G_TC_2220_2_WA-PCPAF = BAPICURX-BAPICURX *  ( 1 / ZTITRQS-WKURS ) *
                      ( BAPI1093_0-TO_FACTOR / BAPI1093_0-FROM_FACTOR ).

*>USD 금액.
     CALL FUNCTION 'BAPI_CURRENCY_CONV_TO_EXTERN_9'
       EXPORTING
         CURRENCY        = ZTITRQS-WAERS
         AMOUNT_INTERNAL = G_TC_2130_WA-NETWR
       IMPORTING
         AMOUNT_EXTERNAL = BAPICURX-BAPICURX.

     G_TC_2220_2_WA-PCAMF = BAPICURX-BAPICURX * ( 1 / ZTITRQS-WKURS ) *
                      ( BAPI1093_0-TO_FACTOR / BAPI1093_0-FROM_FACTOR ).

     ADD G_TC_2220_2_WA-PCAMF TO G_WRBTR.   ">USD금액.
     ADD G_TC_2220_2_WA-PCAMT TO G_DMBTR.   ">정가.

*> 총수량 누적.
     ADD G_TC_2130_WA-RQMNG TO ZTITPC1-PTNUM.
*> Append
     APPEND G_TC_2220_2_WA TO G_TC_2220_2_ITAB.
   ENDLOOP.

*> usd 금액 차이.
   IF G_WRBTR <> ZTITRQS-USAMT.
     IF ZTITRQS-USAMT GT G_WRBTR.
       G_TC_2220_2_WA-PCAMF = G_TC_2220_2_WA-PCAMF +
                              ( ZTITRQS-USAMT - G_WRBTR ).
     ELSE.
       G_TC_2220_2_WA-PCAMF = G_TC_2220_2_WA-PCAMF -
                              ( G_WRBTR - ZTITRQS-USAMT ).
     ENDIF.
   ENDIF.

*> 개설금액.
   IF G_DMBTR <> ZTITRQS-OPAMT.
     IF ZTITRQS-OPAMT GT G_DMBTR.
       G_TC_2220_2_WA-PCAMT = G_TC_2220_2_WA-PCAMT +
                              ( ZTITRQS-OPAMT - G_DMBTR ).
     ELSE.
       G_TC_2220_2_WA-PCAMT = G_TC_2220_2_WA-PCAMT -
                              ( G_DMBTR - ZTITRQS-OPAMT ).
     ENDIF.
   ENDIF.
   MODIFY G_TC_2220_2_ITAB FROM G_TC_2220_2_WA INDEX G_COUNT.

 ENDFORM.                    " set_apppcr_default_value
*&---------------------------------------------------------------------*
*&      Form  scr2210_check_document_req
*&---------------------------------------------------------------------*
 FORM SCR2210_CHECK_DOCUMENT_REQ .

   IF  NOT ( ZTITLC1-CIYCD = 'X'
    OR ZTITLC1-BLYCD = 'X'
    OR ZTITLC1-ABYCD = 'X'
    OR ZTITLC1-IPYCD = 'X'
*    OR ztitlc1-plcpy = 'X'
    OR ZTITLC1-COYCD = 'X'
    OR ZTITLC1-COYCD = 'X' ).
     MESSAGE E131.
   ENDIF.

   IF ZTITLC1-CIYCD = 'X'.
     IF ZTITLC1-CICPY IS INITIAL.
       PERFORM NO_INPUT_CHECK USING 'ZTITLC1' 'CICPY' C_ERROR.
     ENDIF.
   ELSEIF NOT ZTITLC1-CICPY IS INITIAL.
     ZTITLC1-CIYCD = 'X'.
   ENDIF.

   IF ZTITLC1-PLYCD = 'X'.
     IF ZTITLC1-PLYCD IS INITIAL.
       PERFORM NO_INPUT_CHECK USING 'ZTITLC1' 'PLCPY' C_ERROR.
     ENDIF.
   ELSEIF NOT ZTITLC1-PLCPY IS INITIAL.
     ZTITLC1-PLYCD = 'X'.
   ENDIF.

   IF ZTITLC1-BLYCD = 'X'.
     IF ZTITLC1-BCON1 IS INITIAL.
       IF G_MODE EQ C_CHARY.
         PERFORM NO_INPUT_CHECK USING 'ZTITLC1' 'BCON1' C_ERROR.
       ENDIF.
     ENDIF.
     IF ZTITLC1-BFREY IS INITIAL.
       PERFORM NO_INPUT_CHECK USING 'ZTITLC1' 'BFREY' C_ERROR.
     ENDIF.
     IF ZTITLC1-BNOT1 IS INITIAL.
       PERFORM NO_INPUT_CHECK USING 'ZTITLC1' 'BNOT1' C_ERROR.
     ENDIF.
   ELSEIF NOT ( ZTITLC1-BCON1 IS INITIAL
             OR ZTITLC1-BFREY IS INITIAL
             OR ZTITLC1-BNOT1 IS INITIAL ).
     ZTITLC1-BLYCD = 'X'.
   ENDIF.

   IF ZTITLC1-ABYCD = 'X'.
     IF ZTITLC1-ACON1 IS INITIAL.
       IF G_MODE EQ C_CHARY.
*         PERFORM no_input_check USING 'ZTITLC1' 'ACON1' c_error.
       ENDIF.
     ENDIF.
     IF ZTITLC1-AFREY IS INITIAL.
       PERFORM NO_INPUT_CHECK USING 'ZTITLC1' 'AFREY' C_ERROR.
     ENDIF.
     IF ZTITLC1-ANOT1 IS INITIAL.
       PERFORM NO_INPUT_CHECK USING 'ZTITLC1' 'ANOT1' C_ERROR.
     ENDIF.
   ELSEIF NOT ( ZTITLC1-ACON1 IS INITIAL
             OR ZTITLC1-AFREY IS INITIAL
             OR ZTITLC1-ANOT1 IS INITIAL ).
     ZTITLC1-ABYCD = 'X'.
   ENDIF.

   IF ZTITLC1-IPYCD = 'X'.
     IF ZTITLC1-IPTE1 IS INITIAL.
       PERFORM NO_INPUT_CHECK USING 'ZTITLC1' 'IPTE1' C_ERROR.
     ENDIF.
   ELSEIF NOT ZTITLC1-IPTE1 IS INITIAL.
     ZTITLC1-IPYCD = 'X'.
   ENDIF.

   IF ZTITLC1-MATE1 = 'X'.
     IF ZTITLC1-CARNM IS INITIAL.
       PERFORM NO_INPUT_CHECK USING 'ZTITLC1' 'CARNM' C_ERROR.
     ENDIF.
   ELSEIF NOT ZTITLC1-CARNM IS INITIAL.
     ZTITLC1-MATE1 = 'X'.
   ENDIF.

   IF ZTITLC1-ADBNM IS INITIAL.
     PERFORM NO_INPUT_CHECK USING 'ZTITLC1' 'ADBNM' C_ERROR.
   ENDIF.


 ENDFORM.                    " scr2210_check_document_req
*&---------------------------------------------------------------------*
*&      Form  check_last_shipdate
*&---------------------------------------------------------------------*
*       S/D 및 E/D Check
*----------------------------------------------------------------------*
 FORM CHECK_LAST_SHIPDATE .

   IF ZTITRQS-LSDAT IS INITIAL.   "최종선적일.
     PERFORM NO_INPUT_CHECK USING 'ZTITRQS' 'LSDAT' C_ERROR.
   ELSE.
     IF ZTITRQS-DOCST EQ SPACE.
*      IF ZTITRQS-lsdat LE sy-datlo.
*        PERFORM no_input_check USING 'ZTITRQS' 'LSDAT' c_success.
*        MESSAGE e119 WITH '최종선적일(S/D)' '현재일자'.
*      ENDIF.
     ENDIF.
   ENDIF.
   IF ZTITRQS-EXDAT IS INITIAL.   "유효기일.
     ZTITRQS-EXDAT = ZTITRQS-LSDAT + 20.
*        PERFORM no_input_check USING 'ZTITRQS' 'EXDAT' c_error.
*      ELSE.
*        IF ZTITRQS-exdat LE sy-datlo.
*          PERFORM no_input_check USING 'ZTITRQS' 'EXDAT' c_success.
*          MESSAGE e119 WITH '유효기일(E/D)' '현재일자'.
*        ENDIF.
   ENDIF.
   IF ZTITRQS-LSDAT GT ZTITRQS-EXDAT.
     PERFORM NO_INPUT_CHECK USING 'ZTITRQS' 'EXDAT' C_SUCCESS.
     MESSAGE E119 WITH '유효기일(E/D)' '최종선적일(S/D)'.
   ENDIF.

 ENDFORM.                    " check_last_shipdate
*&---------------------------------------------------------------------*
*&      Form  create_invoice_document
*&---------------------------------------------------------------------*
*       사전 T/T일 경우, Simple Invoice 생성.
*----------------------------------------------------------------------*
 FORM CREATE_INVOICE_DOCUMENT .

   DATA: L_SUBRC  LIKE  SY-SUBRC.
   DATA: L_BKTXT  TYPE  BKTXT.

   DATA: L_IF_NULL TYPE REF TO IF_MESSAGE_OBJ_MM.

   CHECK ZTITRQS-IVONO IS INITIAL.

   REFRESH: BDCDATA.

   CLEAR: SESSION.
   CTU_PARAMS-DISMODE  = 'E'. ">처리모드
   CTU_PARAMS-UPDMODE  = 'S'. ">갱신모드
   CTU_PARAMS-CATTMODE = ' '. ">CATT 모드...
   CTU_PARAMS-DEFSIZE  = ' '. ">기본화면 크기
   CTU_PARAMS-RACOMMIT = 'X'.
   CTU_PARAMS-NOBINPT  = ' ' .
   CTU_PARAMS-NOBIEND  = ' '.

* Message preparations
   PERFORM  SET_MESSAGE_PREPARATIONS.

*> 품목 정보.
   CLEAR: G_TC_2130_WA, EKKO, EKPO.
   READ TABLE IT_TAB INTO G_TC_2130_WA INDEX 1.
   IF SY-SUBRC EQ C_ZERO.
     IF NOT G_TC_2130_WA-EBELN IS INITIAL.
       SELECT SINGLE *
         FROM EKKO
        WHERE EBELN EQ G_TC_2130_WA-EBELN.

       SELECT SINGLE *
         FROM EKPO
        WHERE EBELN EQ G_TC_2130_WA-EBELN
          AND EBELP EQ G_TC_2130_WA-EBELP.
       IF SY-SUBRC NE 0.
         EXIT.
       ENDIF.
     ELSE.
       EXIT.
     ENDIF.
   ELSE.
     EXIT.
   ENDIF.

   IF ZTITRQK-ANBTY EQ C_CHARB.
     IF ZTITRQK-PPAID EQ C_CHARN.
       L_BKTXT = '수입물대금액(사전송금)'.
     ELSE.
       L_BKTXT = '수입물대금액(선급금)'.
     ENDIF.
   ELSE.
     L_BKTXT = '수입물대금액(사후송금)'.
   ENDIF.

*> 초기화면.
   PERFORM BDC_DYNPRO_BUILD USING :
          'X' 'ZTIR3000'          '0100',
          ' ' 'BDC_OKCODE'       '=ZTICOPY'.
*> 초기화면.
   PERFORM BDC_DYNPRO_BUILD USING :
          'X' 'ZTIR3000'          '7000',
          ' ' 'ZTISSCRCOM-REQNO'  ZTITRQK-REQNO,
          ' ' 'BDC_OKCODE'       '=FCOPY'.

*> 세부화면.

   PERFORM BDC_DYNPRO_BUILD USING :
          'X' 'ZTIR3000'         '2000',
          ' ' 'ZTITIVK-IVNUM'   ZTITRQK-REQNO,
          ' ' 'ZTITIVK-CIVDT'   ZTITRQS-SNDDT,
          ' ' 'ZTITIVK-BUDAT'   ZTITRQS-SNDDT,
*         ' ' 'ZTITIVK-BLDAT'   '',
*          ' ' 'ZTITIVK-BUPLA'   g_tc_2130_wa-bupla,
*          ' ' 'ZTITIVK-GSBER'   '1110',
*          ' ' 'ZTITIVK-BLART'   'RE',
*          ' ' 'ZTITIVK-MWSKZ'   ekpo-mwskz,
          ' ' 'ZTITIVK-ZTERM'   ZTITRQS-ZTERM,
*         ' ' 'ZTITIVK-PKCHG'   '',
*         ' ' 'ZTITIVK-HDCHG'   '',
*         ' ' 'ZTITIVK-OTCHG'   '',
*          ' ' 'ZTITIVK-ZLSPR'   'M',
*         ' ' 'ZTITIVK-RTCHG'   '',
*          ' ' 'ZTITIVK-ZLSCH'   'C',
          ' ' 'ZTITIVK-XBLNR'   ZTITRQK-REQNO,
          ' ' 'ZTITIVK-BKTXT'   L_BKTXT,
*         ' ' 'ZTITIVK-SGTXT'   '수입물대'.
*ZMISIVIT-SGTXT(01)
*ZMISIVIT-SGTXT(02)
         ' ' 'BDC_OKCODE'       '=ZTIPOST'.

*--> 가온 사업영역 TEST 지정
*   DATA : LV_GSBER TYPE GSBER.
*   IF ZTITRQK-BUKRS = '6000'.
*     LV_GSBER = '6000'.
*     PERFORM BDC_DYNPRO_BUILD USING :
*            'X' 'ZTIR3000'         '2000',
*            ' ' 'ZTITIVK-IVNUM'   ZTITRQK-REQNO,
*            ' ' 'ZTITIVK-CIVDT'   ZTITRQS-SNDDT,
*            ' ' 'ZTITIVK-BUDAT'   ZTITRQS-SNDDT,
**         ' ' 'ZTITIVK-BLDAT'   '',
**          ' ' 'ZTITIVK-BUPLA'   g_tc_2130_wa-bupla,
*            ' ' 'ZTITIVK-GSBER'   LV_GSBER,
**          ' ' 'ZTITIVK-GSBER'   '1110',
**          ' ' 'ZTITIVK-BLART'   'RE',
**          ' ' 'ZTITIVK-MWSKZ'   ekpo-mwskz,
*            ' ' 'ZTITIVK-ZTERM'   ZTITRQS-ZTERM,
**         ' ' 'ZTITIVK-PKCHG'   '',
**         ' ' 'ZTITIVK-HDCHG'   '',
**         ' ' 'ZTITIVK-OTCHG'   '',
**          ' ' 'ZTITIVK-ZLSPR'   'M',
**         ' ' 'ZTITIVK-RTCHG'   '',
**          ' ' 'ZTITIVK-ZLSCH'   'C',
*            ' ' 'ZTITIVK-XBLNR'   ZTITRQK-REQNO,
*            ' ' 'ZTITIVK-BKTXT'   L_BKTXT,
**         ' ' 'ZTITIVK-SGTXT'   '수입물대'.
**ZMISIVIT-SGTXT(01)
**ZMISIVIT-SGTXT(02)
*           ' ' 'BDC_OKCODE'       '=ZTIPOST'.
*   ELSE.
*     PERFORM BDC_DYNPRO_BUILD USING :
*            'X' 'ZTIR3000'         '2000',
*            ' ' 'ZTITIVK-IVNUM'   ZTITRQK-REQNO,
*            ' ' 'ZTITIVK-CIVDT'   ZTITRQS-SNDDT,
*            ' ' 'ZTITIVK-BUDAT'   ZTITRQS-SNDDT,
**         ' ' 'ZTITIVK-BLDAT'   '',
**          ' ' 'ZTITIVK-BUPLA'   g_tc_2130_wa-bupla,
**          ' ' 'ZTITIVK-GSBER'   '1110',
**          ' ' 'ZTITIVK-BLART'   'RE',
**          ' ' 'ZTITIVK-MWSKZ'   ekpo-mwskz,
*            ' ' 'ZTITIVK-ZTERM'   ZTITRQS-ZTERM,
**         ' ' 'ZTITIVK-PKCHG'   '',
**         ' ' 'ZTITIVK-HDCHG'   '',
**         ' ' 'ZTITIVK-OTCHG'   '',
**          ' ' 'ZTITIVK-ZLSPR'   'M',
**         ' ' 'ZTITIVK-RTCHG'   '',
**          ' ' 'ZTITIVK-ZLSCH'   'C',
*            ' ' 'ZTITIVK-XBLNR'   ZTITRQK-REQNO,
*            ' ' 'ZTITIVK-BKTXT'   L_BKTXT,
**         ' ' 'ZTITIVK-SGTXT'   '수입물대'.
**ZMISIVIT-SGTXT(01)
**ZMISIVIT-SGTXT(02)
*           ' ' 'BDC_OKCODE'       '=ZTIPOST'.
*   ENDIF.
*<--가온 사업영역 TEST 지정

   PERFORM BDC_DYNPRO_BUILD USING :
          'X' 'SAPLSPO1'         '0300',
          ' ' 'BDC_OKCODE'       '=YES'.
*
   SET PARAMETER ID 'ZTIIVONO'  FIELD SPACE.

   PERFORM BDC_TRANSACTION USING 'ZTIT301' L_SUBRC.

   GET PARAMETER ID 'ZTIIVONO'  FIELD ZTITRQS-IVONO.

   IF L_SUBRC EQ 0.
     MESSAGE S313 WITH ZTITRQS-IVONO.

     PERFORM SET_RETURN_MESSAGE_FILL USING SY-MSGTY.
*> 상태 테이블 변경.
     MODIFY ZTITRQS.
   ELSE.
     LOOP AT MESSTAB WHERE MSGTYP EQ 'E'.
       SY-MSGNO = MESSTAB-MSGNR.
       ZTI_MESSAGE MESSTAB-MSGTYP MESSTAB-MSGID SY-MSGNO
           MESSTAB-MSGV1 MESSTAB-MSGV2 MESSTAB-MSGV3 MESSTAB-MSGV4.
     ENDLOOP.
     IF SY-SUBRC NE 0.
       MESSAGE S926.
       PERFORM SET_RETURN_MESSAGE_FILL USING C_ERROR.
     ENDIF.
   ENDIF.

*> 오류정보가 존재시 메시지 상자 POPUP.
   IF SY-CALLD NE C_TRUE.
     G_LINE = G_MESSAGE_HANDLER->GET_SEVERITY_BO(
                             IM_BUSINESS_OBJ          = L_IF_NULL
                             IM_INCLUDE_CHILD_OBJECTS = C_TRUE ).

     IF G_LINE GT 0.
       CALL METHOD G_MESSAGE_HANDLER->SHOW(
           IM_POPUP  = C_TRUE
           IM_AMODAL = C_FALSE ).
     ENDIF.
   ENDIF.

 ENDFORM.                    " create_invoice_document
*&---------------------------------------------------------------------*
*&      Form  create_invoice_document_save
*&---------------------------------------------------------------------*
*       특정 벤더 사전 T/T일 경우,  Invoice 저장.
*----------------------------------------------------------------------*
 FORM CREATE_INVOICE_DOCUMENT_SAVE .

   DATA: L_SUBRC  LIKE  SY-SUBRC.
   DATA: L_BKTXT  TYPE  BKTXT.

   DATA: L_IF_NULL TYPE REF TO IF_MESSAGE_OBJ_MM.

   CHECK ZTITRQS-IVONO IS INITIAL.

   REFRESH: BDCDATA.

   CLEAR: SESSION.
   CTU_PARAMS-DISMODE  = 'E'. ">처리모드
   CTU_PARAMS-UPDMODE  = 'S'. ">갱신모드
   CTU_PARAMS-CATTMODE = ' '. ">CATT 모드...
   CTU_PARAMS-DEFSIZE  = ' '. ">기본화면 크기
   CTU_PARAMS-RACOMMIT = 'X'.
   CTU_PARAMS-NOBINPT  = ' ' .
   CTU_PARAMS-NOBIEND  = ' '.

* Message preparations
   PERFORM  SET_MESSAGE_PREPARATIONS.

*> 품목 정보.
   CLEAR: G_TC_2130_WA, EKKO, EKPO.
   READ TABLE IT_TAB INTO G_TC_2130_WA INDEX 1.
   IF SY-SUBRC EQ C_ZERO.
     IF NOT G_TC_2130_WA-EBELN IS INITIAL.
       SELECT SINGLE *
         FROM EKKO
        WHERE EBELN EQ G_TC_2130_WA-EBELN.

       SELECT SINGLE *
         FROM EKPO
        WHERE EBELN EQ G_TC_2130_WA-EBELN
          AND EBELP EQ G_TC_2130_WA-EBELP.
       IF SY-SUBRC NE 0.
         EXIT.
       ENDIF.
     ELSE.
       EXIT.
     ENDIF.
   ELSE.
     EXIT.
   ENDIF.

   IF ZTITRQK-ANBTY EQ C_CHARB.
     IF ZTITRQK-PPAID EQ C_CHARN.
       L_BKTXT = '수입물대금액(사전송금)'.
     ELSE.
       L_BKTXT = '수입물대금액(선급금)'.
     ENDIF.
   ELSE.
     L_BKTXT = '수입물대금액(사후송금)'.
   ENDIF.

*> 초기화면.
   PERFORM BDC_DYNPRO_BUILD USING :
          'X' 'ZTIR3000'          '0100',
          ' ' 'BDC_OKCODE'       '=ZTICOPY'.
*> 초기화면.
   PERFORM BDC_DYNPRO_BUILD USING :
          'X' 'ZTIR3000'          '7000',
          ' ' 'ZTISSCRCOM-REQNO'  ZTITRQK-REQNO,
          ' ' 'BDC_OKCODE'       '=FCOPY'.

*> 세부화면.

   PERFORM BDC_DYNPRO_BUILD USING :
          'X' 'ZTIR3000'         '2000',
          ' ' 'ZTITIVK-IVNUM'   ZTITRQK-REQNO,
          ' ' 'ZTITIVK-CIVDT'   ZTITRQS-SNDDT,
          ' ' 'ZTITIVK-BUDAT'   ZTITRQS-SNDDT,
*         ' ' 'ZTITIVK-BLDAT'   '',
*          ' ' 'ZTITIVK-BUPLA'   g_tc_2130_wa-bupla,
*          ' ' 'ZTITIVK-GSBER'   '1110',
*          ' ' 'ZTITIVK-BLART'   'RE',
*          ' ' 'ZTITIVK-MWSKZ'   ekpo-mwskz,
          ' ' 'ZTITIVK-ZTERM'   ZTITRQS-ZTERM,
*         ' ' 'ZTITIVK-PKCHG'   '',
*         ' ' 'ZTITIVK-HDCHG'   '',
*         ' ' 'ZTITIVK-OTCHG'   '',
*          ' ' 'ZTITIVK-ZLSPR'   'M',
*         ' ' 'ZTITIVK-RTCHG'   '',
*          ' ' 'ZTITIVK-ZLSCH'   'C',
          ' ' 'ZTITIVK-XBLNR'   ZTITRQK-REQNO,
          ' ' 'ZTITIVK-BKTXT'   L_BKTXT,
*         ' ' 'ZTITIVK-SGTXT'   '수입물대'.
*ZMISIVIT-SGTXT(01)
*ZMISIVIT-SGTXT(02)
         ' ' 'BDC_OKCODE'       '=ZTISAVE'.
*
   PERFORM BDC_DYNPRO_BUILD USING :
          'X' 'SAPLSPO1'         '0300',
          ' ' 'BDC_OKCODE'       '=YES'.
*
   SET PARAMETER ID 'ZTIIVONO'  FIELD SPACE.

   PERFORM BDC_TRANSACTION USING 'ZTIT301' L_SUBRC.

   GET PARAMETER ID 'ZTIIVONO'  FIELD ZTITRQS-IVONO.

   IF L_SUBRC EQ 0.
     MESSAGE S313 WITH ZTITRQS-IVONO.

     PERFORM SET_RETURN_MESSAGE_FILL USING SY-MSGTY.
*> 상태 테이블 변경.
     MODIFY ZTITRQS.
   ELSE.
     LOOP AT MESSTAB WHERE MSGTYP EQ 'E'.
       SY-MSGNO = MESSTAB-MSGNR.
       ZTI_MESSAGE MESSTAB-MSGTYP MESSTAB-MSGID SY-MSGNO
           MESSTAB-MSGV1 MESSTAB-MSGV2 MESSTAB-MSGV3 MESSTAB-MSGV4.
     ENDLOOP.
     IF SY-SUBRC NE 0.
       MESSAGE S926.
       PERFORM SET_RETURN_MESSAGE_FILL USING C_ERROR.
     ENDIF.
   ENDIF.

*> 오류정보가 존재시 메시지 상자 POPUP.
   IF SY-CALLD NE C_TRUE.
     G_LINE = G_MESSAGE_HANDLER->GET_SEVERITY_BO(
                             IM_BUSINESS_OBJ          = L_IF_NULL
                             IM_INCLUDE_CHILD_OBJECTS = C_TRUE ).

     IF G_LINE GT 0.
       CALL METHOD G_MESSAGE_HANDLER->SHOW(
           IM_POPUP  = C_TRUE
           IM_AMODAL = C_FALSE ).
     ENDIF.
   ENDIF.

 ENDFORM.                    " create_invoice_document
*&---------------------------------------------------------------------*
*&      Form  p1001_initialization
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
 FORM P1001_INITIALIZATION .

   DATA: L_DATE  LIKE SY-DATLO.

   SET TITLEBAR 'T1000' WITH '요청'(T10).

*  l_date = sy-datlo + 30.

*   l_date = '99991231'.
*
*   MOVE: 'I'            TO s_eindt-sign,
*         'BT'           TO s_eindt-option,
*         sy-datlo       TO s_eindt-low,
*         l_date         TO s_eindt-high.
*
*   APPEND s_eindt.

 ENDFORM.                    " p1001_initialization
*&---------------------------------------------------------------------*
*&      Form  p1100_check_input_values
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
 FORM P1100_CHECK_INPUT_VALUES .

   DATA: L_BUKRS LIKE T001-BUKRS,
         L_LIFNR LIKE LFA1-LIFNR,
         L_EKORG LIKE T024E-EKORG,
         L_EKGRP LIKE T024-EKGRP.

* Company code
   SELECT BUKRS INTO (L_BUKRS)
                FROM T001 UP TO 1 ROWS WHERE BUKRS IN S_BUKRS.
   ENDSELECT.
   IF SY-SUBRC <> 0.
     PERFORM GET_FTEXT(RDDFIE00) USING 'T001' 'BUKRS' SY-LANGU
                                 CHANGING DFIES G_SUBRC.
     SET CURSOR FIELD 'S_BUKRS-LOW'.
     MESSAGE E348(M7) WITH '회사코드'.
   ENDIF.
* Vendor
   READ TABLE S_LIFNR INDEX 1 TRANSPORTING NO FIELDS.
   IF SY-SUBRC = 0.
     SELECT LIFNR INTO (L_LIFNR)
                  FROM LFB1 UP TO 1 ROWS WHERE LIFNR IN S_LIFNR
                                         AND   BUKRS IN S_BUKRS.
     ENDSELECT.
     IF SY-SUBRC <> 0.
       PERFORM GET_FTEXT(RDDFIE00) USING 'LFA1' 'LIFNR' SY-LANGU
                                   CHANGING DFIES G_SUBRC.
       SET CURSOR FIELD 'S_LIFNR-LOW'.
       MESSAGE E348(M7) WITH DFIES-SCRTEXT_M.
     ENDIF.
   ENDIF.

* Purchase Organization
   READ TABLE S_EKORG INDEX 1 TRANSPORTING NO FIELDS.
   IF SY-SUBRC = 0.
     SELECT EKORG INTO (L_EKORG)
                  FROM T024E UP TO 1 ROWS WHERE EKORG IN S_EKORG.
     ENDSELECT.
     IF SY-SUBRC <> 0.
       PERFORM GET_FTEXT(RDDFIE00) USING 'T024E' 'EKORG' SY-LANGU
                                   CHANGING DFIES G_SUBRC.
       SET CURSOR FIELD 'S_EKORG-LOW'.
       MESSAGE E348(M7) WITH DFIES-SCRTEXT_M.
     ENDIF.
   ENDIF.

* Purchase GROUP
   READ TABLE S_EKGRP INDEX 1 TRANSPORTING NO FIELDS.
   IF SY-SUBRC = 0.
     SELECT EKGRP INTO (L_EKGRP)
                  FROM T024 UP TO 1 ROWS WHERE EKGRP IN S_EKGRP.
     ENDSELECT.
     IF SY-SUBRC <> 0.
       PERFORM GET_FTEXT(RDDFIE00) USING 'T024' 'EKGRP' SY-LANGU
                                   CHANGING DFIES G_SUBRC.
       SET CURSOR FIELD 'S_EKGRP-LOW'.
       MESSAGE E348(M7) WITH DFIES-SCRTEXT_M.
     ENDIF.
   ENDIF.

 ENDFORM.                    " p1100_check_input_values
*&---------------------------------------------------------------------*
*&      Form  p2000_data_selections
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
 FORM P2000_DATA_SELECTIONS .

   DATA: L_RQMNG  LIKE ZTITRQP-RQMNG.

   CLEAR: G_COUNT, IT_TAB_H, IT_ZTITIG02, IT_HEADER, IT_LIST.
   REFRESH : IT_TAB_H, IT_ZTITIG02, IT_HEADER, IT_LIST.
*> PROGRESS Display.
   G_LINEN    = 30.
   G_OUT_TEXT = '데이타를 검색 중입니다 %99999%%'(P01).
   REPLACE '%99999%' WITH G_LINEN INTO G_OUT_TEXT.
   PERFORM SHOW_PROGRESS_BAR(ZTIR0000) USING G_OUT_TEXT G_LINEN.

*> Get 수입가능 구매문서 종류 및 지급조건 .
   PERFORM GET_USED_PAYMENT_TERM(ZTIR0000)  TABLES  IT_ZTITIG02
                                            USING   G_SUBRC C_SUCCESS.
   IF G_SUBRC NE 0.
     EXIT.
   ENDIF.
*> 무환건 삭제.
   DELETE IT_ZTITIG02 WHERE REQTY = 'ZZ'.

*> 사후송금건 삭제.
   DELETE IT_ZTITIG02 WHERE REQTY EQ 'TT'
                        AND AFTYN EQ 'A'.

*> Get 국가별 운송기간 .
   PERFORM GET_TRANSPORT_TERMS(ZTIR0000)   TABLES  IT_ZTITIG11
                                            USING   G_SUBRC C_SUCCESS.
*   IF g_subrc NE 0.
*     EXIT.
*   ENDIF.
*
*> 구매오더 데이타 select.
***********************************************************************
   IF S_BUKRS-LOW EQ 6000.

     SELECT *
           INTO CORRESPONDING FIELDS OF TABLE IT_TAB_H
           FROM ZTIVPO00
           FOR ALL ENTRIES IN IT_ZTITIG02
           WHERE EBELN  IN S_EBELN
           AND   BUKRS  IN S_BUKRS
           AND   EKORG  IN S_EKORG
           AND   EKGRP  IN S_EKGRP
*          AND   bstyp  EQ c_charf   ">구매오더만.
           AND   REPOS  NE SPACE     ">무환건 삭제.
           AND   LIFNR  IN S_LIFNR
           AND   WAERS  IN S_WAERS
           AND   MATKL  IN S_MATKL
           AND   MATNR  IN S_MATNR
           AND   TXZ01  IN S_TXZ01
           AND   WERKS  IN S_WERKS
           AND   LAND1  IN S_LAND1
           AND   INCO1  IN S_INCO1
           AND   ZTERM  IN S_ZTERM
           AND   BEDAT  IN S_BEDAT
           AND   AEDAT  IN S_AEDAT
           AND   ERNAM  IN S_ERNAM
*         AND   FRGRL  NE C_TRUE   ">릴리즈 지시자.
           AND   ELIKZ  EQ SPACE    ">납품완료 지시자.
           AND   HLOEKZ EQ SPACE    ">헤더 삭제지시자.
           AND   LOEKZ  EQ SPACE    ">아이템 삭제지시자.
           AND   BSTYP  EQ IT_ZTITIG02-BSTYP
           AND   BSART  EQ IT_ZTITIG02-BSART
           AND   ZTERM  EQ IT_ZTITIG02-ZTERM.

   ELSE.

     SELECT *
           INTO CORRESPONDING FIELDS OF TABLE IT_TAB_H
           FROM ZTIVPO00
           FOR ALL ENTRIES IN IT_ZTITIG02
           WHERE EBELN  IN S_EBELN
           AND   BUKRS  IN S_BUKRS
           AND   EKORG  IN S_EKORG
           AND   EKGRP  IN S_EKGRP
*          AND   bstyp  EQ c_charf   ">구매오더만.
           AND   REPOS  NE SPACE     ">무환건 삭제.
           AND   LIFNR  IN S_LIFNR
           AND   WAERS  IN S_WAERS
           AND   MATKL  IN S_MATKL
           AND   MATNR  IN S_MATNR
           AND   TXZ01  IN S_TXZ01
           AND   WERKS  IN S_WERKS
           AND   LAND1  IN S_LAND1
           AND   INCO1  IN S_INCO1
           AND   ZTERM  IN S_ZTERM
           AND   BEDAT  IN S_BEDAT
           AND   AEDAT  IN S_AEDAT
           AND   ERNAM  IN S_ERNAM
           AND   FRGRL  NE C_TRUE   ">릴리즈 지시자.
           AND   ELIKZ  EQ SPACE    ">납품완료 지시자.
           AND   HLOEKZ EQ SPACE    ">헤더 삭제지시자.
           AND   LOEKZ  EQ SPACE    ">아이템 삭제지시자.
           AND   BSTYP  EQ IT_ZTITIG02-BSTYP
           AND   BSART  EQ IT_ZTITIG02-BSART
           AND   ZTERM  EQ IT_ZTITIG02-ZTERM.

   ENDIF.

   IF SY-SUBRC NE 0.
     EXIT.
   ENDIF.

   DATA LS_0165 TYPE ZMMT0165.

*> select된 구매오더 데이타를 수입의뢰된 수량과 비교.
   CLEAR: G_COUNT, G_CNT.
   LOOP AT IT_TAB_H.
     G_TABIX = SY-TABIX.
     CLEAR: L_RQMNG.

*&   2010.09.20 MMC23 zmmt0165 table 존재하는 대상 제외
     SELECT SINGLE * INTO LS_0165 FROM ZMMT0165
      WHERE EBELN EQ IT_TAB_H-EBELN
        AND EBELP EQ IT_TAB_H-EBELP
        AND WERKS EQ IT_TAB_H-WERKS.
     IF SY-SUBRC = 0.
       DELETE IT_TAB_H INDEX G_TABIX.
       CONTINUE.
     ENDIF.

     CLEAR: IT_ZTITIG02.
     READ TABLE IT_ZTITIG02 WITH KEY BSTYP = IT_TAB_H-BSTYP
                                     BSART = IT_TAB_H-BSART
                                     ZTERM = IT_TAB_H-ZTERM.
*                                     BINARY SEARCH.
     IF SY-SUBRC EQ 0.
       MOVE: IT_ZTITIG02-REQTY TO IT_TAB_H-REQTY.
       PERFORM GET_DOMAIN_VALUE_TEXT(ZTIR0000) USING 'ZTIREQTY'
                                                     IT_TAB_H-REQTY
                                                     IT_TAB_H-REQTX.
     ELSE.
       DELETE IT_TAB_H INDEX G_TABIX.
       CONTINUE.
     ENDIF.

     IF IT_TAB_H-BSART EQ 'NB'.
       IF (  IT_TAB_H-EKGRP EQ 'Z30' OR
            IT_TAB_H-EKGRP EQ 'Z31'   OR
            IT_TAB_H-EKGRP EQ 'Z32' ) AND  IT_TAB_H-FRGKE NE 'S'.

         DELETE IT_TAB_H INDEX G_TABIX.
         CONTINUE.
       ENDIF.
     ENDIF.

     IF IT_ZTITIG02-REQTY EQ C_LC.
       SELECT  SUM( RQMNG ) SUM( NETWR )
         INTO (IT_TAB_H-RQMNGS, IT_TAB_H-NETWRS)
         FROM ZTIVRQ00
        WHERE  EBELN  EQ IT_TAB_H-EBELN
          AND  EBELP  EQ IT_TAB_H-EBELP
          AND  PPAID  NE C_TRUE
          AND  RPAID  EQ C_FALSE .
     ELSE.
       SELECT  SUM( RQMNG ) SUM( NETWR )
         INTO (IT_TAB_H-RQMNGS, IT_TAB_H-NETWRS)
         FROM ZTIVRQ00
        WHERE  EBELN  = IT_TAB_H-EBELN
          AND  EBELP  = IT_TAB_H-EBELP.
     ENDIF.
     IT_TAB_H-RQMNG =  IT_TAB_H-MENGE - IT_TAB_H-RQMNGS.

     IF IT_TAB_H-RQMNG LE C_ZERO.
*      IF p_delete EQ c_true.
       DELETE IT_TAB_H INDEX G_TABIX.
       CONTINUE.
*      ELSE.
*        it_tab-rqmng = 0.
*      ENDIF.
     ELSE.
       SELECT EINDT
         INTO IT_TAB_H-EINDT
         FROM EKET UP TO 1 ROWS
        WHERE EBELN EQ IT_TAB_H-EBELN
          AND EBELP EQ IT_TAB_H-EBELP
*         AND etenr EQ '01'
          AND EINDT IN S_EINDT.
       ENDSELECT.
       IF SY-SUBRC NE 0.
         DELETE IT_TAB_H INDEX G_TABIX.
         CONTINUE.
       ENDIF.
*>S/D 계산.
       READ TABLE IT_ZTITIG11 WITH KEY LAND1 = IT_TAB_H-LAND1.
       IF SY-SUBRC EQ 0.
         IT_TAB_H-LSDAT = IT_TAB_H-EINDT - IT_ZTITIG11-FWDDY.
       ELSE.
         IT_TAB_H-LSDAT = IT_TAB_H-EINDT - 45.
       ENDIF.

       IF NOT IT_TAB_H-LSDAT IN S_LSDAT[].
         DELETE IT_TAB_H INDEX G_TABIX.
         CONTINUE.
       ENDIF.
*> 호선정보.
       SELECT PS_PSP_PNR NPLNR
             INTO (IT_TAB_H-PSPNR, IT_TAB_H-NPLNR)
             FROM EKKN UP TO 1 ROWS
            WHERE EBELN EQ IT_TAB_H-EBELN
              AND EBELP EQ IT_TAB_H-EBELP.
*             AND zekkn EQ '01'.
       ENDSELECT.

       CLEAR: GS_PROJ.
       IF NOT IT_TAB_H-PSPNR IS INITIAL.
         PERFORM GET_PARENT_WBS_ELEMENT USING IT_TAB_H-PSPNR
                                              GS_PROJ.
       ENDIF.
       IF NOT IT_TAB_H-NPLNR IS INITIAL.
         PERFORM GET_WBS_ELEMENT_BY_NETWORK
                                        USING IT_TAB_H-NPLNR
                                              GS_PROJ.
       ENDIF.
       IT_TAB_H-PSPNR = GS_PROJ-PSPNR.
       IT_TAB_H-PSPID = GS_PROJ-PSPID.
       ADD 1 TO G_CNT.
     ENDIF.

     IT_TAB_H-RQMNGL =  IT_TAB_H-RQMNG.

     CALL FUNCTION 'Z_TI_CALC_ITEM_AMOUNT'
       EXPORTING
         PEINH = IT_TAB_H-PEINH
         BPUMZ = IT_TAB_H-BPUMZ
         BPUMN = IT_TAB_H-BPUMN
         MENGE = IT_TAB_H-MENGE
         NETPR = IT_TAB_H-NETPR
       CHANGING
         NETWR = IT_TAB_H-NETWR.

     IT_TAB_H-NETWR = IT_TAB_H-NETWR - IT_TAB_H-NETWRS.

     SELECT SINGLE NAME1 INTO IT_TAB_H-NAME1
       FROM LFA1
      WHERE LIFNR EQ IT_TAB_H-LIFNR.

     MOVE IT_TAB_H-NETWR TO IT_TAB_H-HNETWR.
     ADD 1 TO G_COUNT.

     MODIFY IT_TAB_H INDEX G_TABIX.
   ENDLOOP.

 ENDFORM.                    " p2000_data_selections
*&---------------------------------------------------------------------*
*&      Form  p2100_header_and_list_build
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
 FORM P2100_HEADER_AND_LIST_BUILD .

   DATA: L_HEADER  TYPE TY_HEADER .

   LOOP AT IT_TAB_H.
     MOVE-CORRESPONDING IT_TAB_H TO : IT_HEADER, IT_LIST.
*   READ TABLE it_header INTO l_header WITH KEY ebeln = it_tab_h-ebeln.
*     IF sy-subrc NE 0.
     COLLECT : IT_HEADER.
*     ENDIF.
     APPEND    IT_LIST.
   ENDLOOP.

 ENDFORM.                    " p2100_header_and_list_build
*&---------------------------------------------------------------------*
*&      Form  3000_field_category_build
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
 FORM 3000_FIELD_CATEGORY_BUILD .

*----------------------------------------------------------------------*
* 필드명과 Output Length등을 사용자의 입맛에 맞게 바꿈.
*----------------------------------------------------------------------*
   PERFORM 3010_FILL_FIELD_CATEGORY USING :

          'S' 'TABNAME'       'IT_HEADER',
          ' ' 'REF_TABNAME'   'EKKO',
          ' ' 'FIELDNAME'     'EBELN',
          ' ' 'OUTPUTLEN'     12,
          ' ' 'HOTSPOT'       'X',       " Double Click 효과
          'E' 'KEY'           ' ',

          'S' 'TABNAME'       'IT_HEADER',
          ' ' 'REF_TABNAME'   'EKKO',
          ' ' 'FIELDNAME'     'LIFNR',
          ' ' 'OUTPUTLEN'     15,
          'E' 'HOTSPOT'       'X',       " Double Click 효과

          'S' 'TABNAME'       'IT_HEADER',
          ' ' 'REF_TABNAME'   'LFA1',
          ' ' 'OUTPUTLEN'     30,
          'E' 'FIELDNAME'     'NAME1',

          'S' 'TABNAME'       'IT_HEADER',
          ' ' 'REF_TABNAME'   'EKKO',
          ' ' 'NO_OUT'        'X',
          'E' 'FIELDNAME'     'ZTERM',

          'S' 'TABNAME'       'IT_HEADER',
          ' ' 'REF_TABNAME'   'ZTITRQK',
          ' ' 'FIELDNAME'     'REQTY',
          'E' 'NO_OUT'        'X',

          'S' 'TABNAME'       'IT_HEADER',
          ' ' 'FIELDNAME'     'REQTX',
          ' ' 'SELTEXT_L'     '수입의뢰종류'(T11),
          ' ' 'SELTEXT_M'     '수입의뢰종류'(T11),
          ' ' 'SELTEXT_S'     '수입의뢰종류'(T11),
          'E' 'OUTPUTLEN'     '20',

          'S' 'TABNAME'       'IT_HEADER',
          ' ' 'REF_TABNAME'   'EKKO',
*          ' ' 'OUTPUTLEN'      6,
          'E' 'FIELDNAME'     'WAERS',

          'S' 'TABNAME'       'IT_HEADER',
          ' ' 'REF_TABNAME'   'EKPO',
          ' ' 'REF_FIELDNAME' 'NETWR',
          ' ' 'CFIELDNAME'    'WAERS',
          ' ' 'CTABNAME'      'IT_HEADER',
*          ' ' 'SELTEXT_L'     '금액'(t14),
*          ' ' 'SELTEXT_M'     '금액'(t14),
*          ' ' 'SELTEXT_S'     '금액'(t14),
          ' ' 'OUTPUTLEN'      16,
          'E' 'FIELDNAME'     'HNETWR',

          'S' 'TABNAME'       'IT_HEADER',
          ' ' 'REF_TABNAME'   'LFA1',
          ' ' 'FIELDNAME'     'LAND1',
          'E' 'NO_OUT'        ' ',

          'S' 'TABNAME'       'IT_HEADER',
          ' ' 'REF_TABNAME'   'EKKO',
          ' ' 'FIELDNAME'     'BUKRS',
          'E' 'NO_OUT'        'X',

          'S' 'TABNAME'       'IT_HEADER',
          ' ' 'REF_TABNAME'   'EKKO',
          ' ' 'FIELDNAME'     'EKORG',
          'E' 'NO_OUT'        'X',

          'S' 'TABNAME'       'IT_HEADER',
          ' ' 'REF_TABNAME'   'EKKO',
          ' ' 'FIELDNAME'     'EKGRP',
          'E' 'NO_OUT'        'X',

          'S' 'TABNAME'       'IT_LIST',
          ' ' 'REF_TABNAME'   ' ',
          'E' 'FIELDNAME'     'BOX',

          'S' 'TABNAME'       'IT_LIST',
          ' ' 'REF_TABNAME'   'EKPO',
          ' ' 'FIELDNAME'     'EBELP',
          ' ' 'OUTPUTLEN'     12,
          ' ' 'JUST'          C_CHARL,
          ' ' 'LZERO'         C_CHARX,
          ' ' 'HOTSPOT'       'X',       " Double Click 효과
          'E' 'KEY'           ' ',

          'S' 'TABNAME'       'IT_LIST',
          ' ' 'REF_TABNAME'   'EKPO',
          ' ' 'FIELDNAME'     'MATNR',
          ' ' 'OUTPUTLEN'     15,
          'E' 'HOTSPOT'       'X',       " Double Click 효과

          'S' 'TABNAME'       'IT_LIST',
          ' ' 'REF_TABNAME'   'EKPO',
          ' ' 'OUTPUTLEN'     27,
          'E' 'FIELDNAME'     'TXZ01',

          'S' 'TABNAME'       'IT_LIST',
          ' ' 'REF_TABNAME'   'EKPO',
          ' ' 'QFIELDNAME'    'MEINS',
          ' ' 'QTABNAME'      'IT_LIST',
          ' ' 'NO_OUT'        'X',
          ' ' 'OUTPUTLEN'     13,
          'E' 'FIELDNAME'     'MENGE',

          'S' 'TABNAME'       'IT_LIST',
          ' ' 'REF_TABNAME'   'ZTITRQP',
          ' ' 'QFIELDNAME'    'MEINS',
          ' ' 'QTABNAME'      'IT_LIST',
          ' ' 'NO_OUT'        ' ',
          ' ' 'OUTPUTLEN'     13,
          'E' 'FIELDNAME'     'RQMNG',

          'S' 'TABNAME'       'IT_LIST',
          ' ' 'REF_TABNAME'   'ZTITRQP',
          ' ' 'OUTPUTLEN'     15,
          'E' 'FIELDNAME'     'MEINS',

          'S' 'TABNAME'       'IT_LIST',
          ' ' 'REF_TABNAME'   'EKPO',
          ' ' 'CFIELDNAME'    'WAERS',
          ' ' 'CTABNAME'      'IT_HEADER',
          ' ' 'NO_OUT'        ' ',
          'E' 'FIELDNAME'     'NETWR',

          'S' 'TABNAME'       'IT_LIST',
          ' ' 'REF_TABNAME'   'ZTITRQS',
          ' ' 'SELTEXT_L'     '선적일자',
          ' ' 'SELTEXT_M'     '선적일자',
          ' ' 'SELTEXT_S'     '선적일자',
*          ' ' 'JUST'           'C',
          ' ' 'OUTPUTLEN'     12,
          'E' 'FIELDNAME'     'LSDAT',

          'S' 'TABNAME'       'IT_LIST',
          ' ' 'REF_TABNAME'   'EKET',
          ' ' 'SELTEXT_L'     '납품일자',
          ' ' 'SELTEXT_M'     '납품일자',
          ' ' 'SELTEXT_S'     '납품일자',
*          ' ' 'JUST'           'C',
          ' ' 'OUTPUTLEN'     12,
          'E' 'FIELDNAME'     'EINDT',

          'S' 'TABNAME'       'IT_LIST',
          ' ' 'REF_TABNAME'   'PROJ',
          ' ' 'REF_FIELDNAME' 'PSPID',
          ' ' 'NO_OUT'        ' ',
          'E' 'FIELDNAME'     'PSPID',

          'S' 'TABNAME'       'IT_LIST',
          ' ' 'REF_TABNAME'   'EKPO',
          ' ' 'NO_OUT'        'X',
          'E' 'FIELDNAME'     'WERKS'.

 ENDFORM.                    " 3000_field_category_build
*&---------------------------------------------------------------------*
*&      Form  3100_set_color_infomation
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
 FORM 3100_SET_COLOR_INFOMATION .
   LOOP AT IT_LIST.
     CLEAR: IT_LIST-COLOR[],
            GS_COLOR_INFO.

*    ON CHANGE OF IT_LIST-EBELN.
     GS_COLOR_INFO-FIELDNAME = 'MATNR'.
     GS_COLOR_INFO-COLOR-COL = '3'.
     APPEND GS_COLOR_INFO TO IT_LIST-COLOR[].
     MODIFY IT_LIST.
*    ENDON.
   ENDLOOP.                             " AT LT_RESRC_VW

 ENDFORM.                    " 3100_set_color_infomation
*&---------------------------------------------------------------------*
*&      Form  3200_key_infomation_build
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
 FORM 3200_KEY_INFOMATION_BUILD .

   CLEAR GS_KEYINFO.

   GS_KEYINFO-HEADER01 = 'EBELN'.
   GS_KEYINFO-ITEM01   = 'EBELN'.

 ENDFORM.                    " 3200_key_infomation_build
*&---------------------------------------------------------------------*
*&      Form  3300_event_exit_table_build
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
 FORM 3300_EVENT_EXIT_TABLE_BUILD .

   CLEAR: IT_EVENT_EXIT-AFTER.
   IT_EVENT_EXIT-AFTER = 'X'.
   IT_EVENT_EXIT-UCOMM = '&OL0'.

   APPEND IT_EVENT_EXIT.
   IT_EVENT_EXIT-UCOMM = '&OLX'. APPEND IT_EVENT_EXIT.
   IT_EVENT_EXIT-UCOMM = '&OAD'. APPEND IT_EVENT_EXIT.

 ENDFORM.                    " 3300_event_exit_table_build
*&---------------------------------------------------------------------*
*&      Form  3400_comment_build
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
 FORM 3400_COMMENT_BUILD .

   DATA: L_TEXT20(20)   TYPE C.
   DATA: L_TEXT100(100) TYPE C.

   CLEAR: IT_LISTHEADER, GS_LISTHEADER.
   REFRESH: IT_LISTHEADER.

* LIST HEADING LINE: TYPE H
   CLEAR GS_LISTHEADER.
   GS_LISTHEADER-TYP  = 'H'.
* gs_listheader-KEY:  NOT USED FOR THIS TYPE
   GS_LISTHEADER-INFO = '수입의뢰 요청 Due List'(T13).
   APPEND GS_LISTHEADER TO IT_LISTHEADER.


* ACTION LINE: TYPE A
*  CLEAR gs_listheader.
*  gs_listheader-typ  = 'A'.
*  gs_listheader-info = '출력일자 :'(t12).
*  WRITE: sy-datlo TO l_text20.
*  CONCATENATE gs_listheader-info l_text20 INTO gs_listheader-info
*              SEPARATED BY space.
*  APPEND gs_listheader TO it_listheader.
** JS전선 회사코드 2007/04 KSH --------------------------------------
   DATA: L_BUTXT LIKE T001-BUTXT.
   CLEAR: L_BUTXT.
   SELECT SINGLE BUTXT FROM T001
                       INTO L_BUTXT
                      WHERE BUKRS EQ S_BUKRS-LOW.

   CLEAR GS_LISTHEADER.
   GS_LISTHEADER-TYP  = 'A'.
   GS_LISTHEADER-INFO = '회사코드 :'.
   CONCATENATE GS_LISTHEADER-INFO S_BUKRS-LOW L_BUTXT
          INTO GS_LISTHEADER-INFO SEPARATED BY SPACE.
   APPEND GS_LISTHEADER TO IT_LISTHEADER.
** JS전선 회사코드 2007/04 KSH --------------------------------------

   CLEAR: T024.
   READ TABLE S_EKGRP INDEX 1.
   IF SY-SUBRC EQ 0.
     SELECT SINGLE *
       FROM T024
      WHERE EKGRP = S_EKGRP-LOW.
   ENDIF.

   CLEAR GS_LISTHEADER.
   GS_LISTHEADER-TYP  = 'A'.
   GS_LISTHEADER-INFO = '구매그룹 :'.
*  WRITE: s_ekgrp-low TO l_text20.
   WRITE: T024-EKNAM TO L_TEXT20.
   CONCATENATE GS_LISTHEADER-INFO L_TEXT20 INTO GS_LISTHEADER-INFO
               SEPARATED BY SPACE.
   APPEND GS_LISTHEADER TO IT_LISTHEADER.

*  CLEAR: t023t.
*  READ TABLE s_matkl INDEX 1.
*  IF sy-subrc EQ 0.
*    SELECT SINGLE *
*      FROM t023t
*     WHERE matkl EQ s_matkl-low
*       AND spras EQ sy-langu.
*  ENDIF.
*
*  CLEAR gs_listheader.
*  gs_listheader-typ  = 'A'.
*  gs_listheader-info = '자재그룹 :'.
**  WRITE: s_ekgrp-low TO l_text20.
*  WRITE: t023t-wgbez60 TO l_text100.
*  CONCATENATE gs_listheader-info l_text100 INTO gs_listheader-info
*              SEPARATED BY space.
*  APPEND gs_listheader TO it_listheader.

 ENDFORM.                    " 3400_comment_build
*&---------------------------------------------------------------------*
*&      Form  3500_sort_table_build
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
 FORM 3500_SORT_TABLE_BUILD .

   DATA: LS_SORT TYPE SLIS_SORTINFO_ALV.
**
*  CLEAR ls_sort.
*  ls_sort-spos      = 1.
*  ls_sort-fieldname = 'EKGRP'.
*  ls_sort-tabname   = 'IT_LIST'.
*  ls_sort-up        = 'X'.
*  ls_sort-group     = '*'.             " Seiten- bei Gruppenwechsel
**  ls_sort-group     = 'UL'.            " Underline      -"-
*  APPEND ls_sort TO it_sort.
*
   CLEAR LS_SORT.
   LS_SORT-SPOS      = 1.
   LS_SORT-FIELDNAME = 'EBELN'.
   LS_SORT-TABNAME   = 'IT_LIST'.
   LS_SORT-UP        = 'X'.
* LS_SORT-GROUP     = '*'.             " Seiten- bei Gruppenwechsel
*  ls_sort-group     = 'UL'.            " Underline      -"-
   APPEND LS_SORT TO IT_SORT.

   CLEAR LS_SORT.
   LS_SORT-SPOS      = 2.
   LS_SORT-FIELDNAME = 'EBELP'.
   LS_SORT-TABNAME   = 'IT_LIST'.
   LS_SORT-UP        = 'X'.
* LS_SORT-GROUP     = '*'.             " Seiten- bei Gruppenwechsel
*  ls_sort-group     = 'UL'.            " Underline      -"-
   APPEND LS_SORT TO IT_SORT.


 ENDFORM.                    " 3500_sort_table_build
*&---------------------------------------------------------------------*
*&      Form  3600_event_table_build
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
 FORM 3600_EVENT_TABLE_BUILD  USING  P_NAME.

   DATA: LS_EVENT TYPE SLIS_ALV_EVENT.

   IF IT_EVENTS[] IS INITIAL.
     CALL FUNCTION 'REUSE_ALV_EVENTS_GET'
       EXPORTING
         I_LIST_TYPE = 0
       IMPORTING
         ET_EVENTS   = IT_EVENTS.
   ENDIF.

   READ TABLE IT_EVENTS WITH KEY NAME = P_NAME
                        INTO LS_EVENT.
   IF SY-SUBRC = 0.
     MOVE LS_EVENT-NAME TO LS_EVENT-FORM.
     APPEND LS_EVENT TO IT_EVENTS.
   ENDIF.

 ENDFORM.                    " 3600_event_table_build
*&---------------------------------------------------------------------*
*&      Form  3700_layout_build
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
 FORM 3700_LAYOUT_BUILD .

   MOVE: 'BOX'        TO GS_LAYOUT-BOX_FIELDNAME,
         'IT_LIST'    TO GS_LAYOUT-BOX_TABNAME.

 ENDFORM.                    " 3700_layout_build
*&---------------------------------------------------------------------*
*&      Form  3910_call_alv_hierseq
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
 FORM 3910_CALL_ALV_HIERSEQ .

   DATA: LS_VARIANT LIKE DISVARIANT.
   LS_VARIANT-REPORT  = SY-REPID.
   LS_VARIANT-VARIANT = P_VARI.
   G_REPID            = SY-REPID.                  " Callback Program.

   CALL FUNCTION 'REUSE_ALV_HIERSEQ_LIST_DISPLAY'
     EXPORTING
       I_INTERFACE_CHECK       = ' '
       I_CALLBACK_PROGRAM      = G_REPID
*      i_callback_pf_status_set       = ' '
*      i_callback_user_command = ' '
       IS_LAYOUT               = GS_LAYOUT
       IT_FIELDCAT             = IT_FIELDCAT[]
*      it_excluding            =
*      IT_SPECIAL_GROUPS       =
       IT_SORT                 = IT_SORT
*      IT_FILTER               =
*      IS_SEL_HIDE             =
*      I_SCREEN_START_COLUMN   = 0
*      I_SCREEN_START_LINE     = 0
*      I_SCREEN_END_COLUMN     = 0
*      I_SCREEN_END_LINE       = 0
       I_TABNAME_HEADER        = 'IT_HEADER'
       I_TABNAME_ITEM          = 'IT_LIST'
       I_STRUCTURE_NAME_HEADER = 'IT_HEADER'
       I_STRUCTURE_NAME_ITEM   = 'IT_LIST'
       IS_KEYINFO              = GS_KEYINFO
       I_DEFAULT               = C_CHARX
       I_SAVE                  = C_CHARA
       IS_VARIANT              = LS_VARIANT
       IT_EVENTS               = IT_EVENTS[]
       IT_EVENT_EXIT           = IT_EVENT_EXIT[]
       IS_PRINT                = GS_PRINT
*      IS_REPREP_ID            =
*      I_BYPASSING_BUFFER      =
*      I_BUFFER_ACTIVE         =
* IMPORTING
*      E_EXIT_CAUSED_BY_CALLER =
*      ES_EXIT_CAUSED_BY_USER  =
     TABLES
       T_OUTTAB_HEADER         = IT_HEADER[]
       T_OUTTAB_ITEM           = IT_LIST[]
     EXCEPTIONS
       PROGRAM_ERROR           = 1
       OTHERS                  = 2.

   IF SY-SUBRC <> 0.
     MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
             WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
   ENDIF.

 ENDFORM.                    " 3910_call_alv_hierseq
*&---------------------------------------------------------------------*
*&      Form  3010_fill_field_category
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
 FORM 3010_FILL_FIELD_CATEGORY USING P_SECTION P_FNAME P_VALUE.

   DATA L_COL(40).
   FIELD-SYMBOLS <L_FS>.

   IF P_SECTION = 'S'.
     CLEAR GS_FIELDCAT.
   ENDIF.

* 속성 MOVE
   CONCATENATE 'GS_FIELDCAT-' P_FNAME  INTO L_COL.
   ASSIGN      (L_COL)         TO       <L_FS>.
   MOVE         P_VALUE        TO       <L_FS>.

   IF P_SECTION = 'E'.
     APPEND GS_FIELDCAT TO IT_FIELDCAT.
   ENDIF.

 ENDFORM.                    " 3010_fill_field_category
*---------------------------------------------------------------------*
*       FORM TOP_OF_PAGE                                              *
*---------------------------------------------------------------------*
 FORM TOP_OF_PAGE.                                          "#EC CALLED

   CALL FUNCTION 'REUSE_ALV_COMMENTARY_WRITE'
     EXPORTING
       IT_LIST_COMMENTARY = IT_LISTHEADER[].

 ENDFORM.                    "TOP_OF_PAGE

*---------------------------------------------------------------------*
*       Form  USER_COMMAND                                            *
*---------------------------------------------------------------------*
 FORM USER_COMMAND USING R_UCOMM     LIKE SY-UCOMM
                         RS_SELFIELD TYPE SLIS_SELFIELD.

   DATA: LS_LIST   TYPE TY_TAB.

   CLEAR: LS_LIST.

   CASE R_UCOMM.
     WHEN 'ZTIT001'.
       CLEAR : G_LINE, G_COUNT.
*>Initialization
       PERFORM  P1000_SET_INITIAL_DATA.

       LOOP AT IT_LIST WHERE BOX EQ 'X'.
         ADD 1 TO: G_LINE, G_COUNT.
         MOVE-CORRESPONDING : IT_LIST TO IT_PONUM,
                              IT_LIST TO IT_PO.
         MOVE: G_COUNT                TO IT_PO-INDEX.
         COLLECT:  IT_PONUM, IT_PO.
       ENDLOOP.

       IF G_LINE EQ C_ZERO.
         MESSAGE S003(OK). EXIT.
       ENDIF.

*>Set Default value
       PERFORM P3000_SET_DATA_OF_SCREEN.

*>[Import] 수입의뢰요청 -> 구매오더 복사필드 정의.
       CLEAR: ZTITIG30.
       SELECT SINGLE *
         FROM ZTITIG30.

*>선택된 레코드를 반복하며 Internal Table로 Move
       LOOP AT IT_PO.
         CLEAR: G_MODIFY, ZTIVPO00.
         DESCRIBE TABLE IT_TAB LINES G_COUNT_1.
         PERFORM  GET_AND_CHECK_PO_DATA   USING  IT_PO-EBELN
                                                 IT_PO-EBELP
                                                 G_MODIFY
                                                 ZTIVPO00
                                                 G_COUNT_1
                                                 C_SUCCESS.
         CHECK G_MODIFY EQ C_FALSE.
*> PO data Move
         MOVE IT_ZTITIG02-REQTY TO ZTITRQK-REQTY.
         PERFORM SET_REQUEST_OF_IMPORT_DATA TABLES IT_TAB
                                            USING  ZTIVPO00
                                                   ZTITRQK
                                                   ZTITRQS
                                                   IT_PO.
       ENDLOOP.
       CHECK G_MODIFY EQ C_FALSE.

*> 수입의뢰 텍스트 아이디 GET.
       PERFORM  P1000_GET_TEXTID_AND_TEXT  USING SPACE
                                                 C_TEXTOBJECT_HEADER
                                                 C_SCR0100
                                                 C_TRUE
                                                 C_FALSE.
*> 전신환 송금일 경우, 은행정보 Setting.
       PERFORM  SET_REMITTANCE_BANK.
*> 기본값 Setting.
       PERFORM  SET_DEFAULT_DATA.
*> 자재별 기타 정보 Select.
       PERFORM  SET_OTHERS_FIELDS_BY_ITEMS.
*> 개설금액 체크.
       PERFORM  CHECK_OPEN_AMOUNT.
*> WBS 요소.
       PERFORM  SET_WBS_ELEMENT        USING C_NONE.
*> 최종선적일자.
       PERFORM  SET_LAST_SHIPPING_DATE USING C_NONE.
*> Incoterms.
       PERFORM  SET_INSURANCE_CLASS    USING C_NONE.
*> 헤더 관련 Text select.
       PERFORM  GET_OTHERS_TEXT_BY_MASTER_DATA.
*> 구매오더 TEXT COPY.
       PERFORM  P1001_GET_AND_COPY_PO_TEXT TABLES IT_PONUM.
*> Create Class Object.
       PERFORM  BUILD_CLASS_OBJECT.

       CALL SCREEN 2000.

*> 10. Save User setting infomation
       PERFORM  SET_USER_SETTING_STRUCTURE.

       PERFORM P9000_DUELIST_REFRESH USING  RS_SELFIELD.

     WHEN '&IC1'.
       IF RS_SELFIELD-TABNAME EQ 'IT_HEADER'.
         READ TABLE IT_HEADER INDEX RS_SELFIELD-TABINDEX.
       ELSEIF RS_SELFIELD-TABNAME EQ 'IT_LIST'.
         READ TABLE IT_LIST INDEX RS_SELFIELD-TABINDEX.
       ENDIF.
       IF SY-SUBRC NE 0.
         MESSAGE S903. EXIT.
       ENDIF.
       IF RS_SELFIELD-TABNAME EQ 'IT_HEADER'.
         MOVE-CORRESPONDING IT_HEADER TO LS_LIST.
       ELSEIF RS_SELFIELD-TABNAME EQ 'IT_LIST'.
         MOVE-CORRESPONDING IT_LIST   TO LS_LIST.
       ENDIF.

       CASE RS_SELFIELD-FIELDNAME.
         WHEN 'EBELN' OR 'EBELP'.
           PERFORM  DISPLAY_PURCHASE_ORDER(ZTIR0000)
                                           USING LS_LIST-EBELN
                                                 LS_LIST-EBELP.
         WHEN 'LIFNR'.
           PERFORM DISPLAY_VENDOR_MASTER   USING LS_LIST-LIFNR
                                                 LS_LIST-EKORG.
         WHEN 'MATNR'.
           PERFORM DISPLAY_MATERIAL_MASTER USING LS_LIST-MATNR
                                                 LS_LIST-WERKS
                                                 SPACE.
       ENDCASE.
     WHEN OTHERS.
   ENDCASE.

   CLEAR: R_UCOMM.

 ENDFORM.                    "USER_COMMAND
*---------------------------------------------------------------------*
*       FORM PF_STATUS_SET                                            *
*---------------------------------------------------------------------*
 FORM PF_STATUS_SET USING RT_EXTAB TYPE SLIS_T_EXTAB.

   SET TITLEBAR 'T1000' WITH '요청'(T10).

   REFRESH: RT_EXTAB.

   APPEND 'ARCHIVE'   TO RT_EXTAB.
   APPEND '&VEXCEL'   TO RT_EXTAB.
   APPEND '&AQW'      TO RT_EXTAB.
   APPEND '&VCRYSTAL' TO RT_EXTAB.
   APPEND '&VGRID'    TO RT_EXTAB.
   APPEND '&EB9'      TO RT_EXTAB.
   APPEND '&CRDESIG'  TO RT_EXTAB.
   APPEND '&XXL'      TO RT_EXTAB.
   APPEND '&ABC'      TO RT_EXTAB.

   SET PF-STATUS 'STANDARD ' EXCLUDING RT_EXTAB.
*SET PF-STATUS 'ABCD' OF PROGRAM PROG.

 ENDFORM.                    "PF_STATUS_SET

*&---------------------------------------------------------------------*
*&      Form  p9000_duelist_refresh
*&---------------------------------------------------------------------*
 FORM P9000_DUELIST_REFRESH
                  USING P_SELFIELD TYPE SLIS_SELFIELD.

*> 검색조건에 해당하는 데이타를 Select.
   PERFORM P2000_DATA_SELECTIONS.
*> Header table과 List(Items) table를 만듬.
   PERFORM P2100_HEADER_AND_LIST_BUILD.
   DESCRIBE TABLE IT_TAB_H LINES G_LINE.
   IF NOT G_LINE IS INITIAL.
     P_SELFIELD-REFRESH = 'X'.
   ELSE.
*> Program 종료.
     PERFORM  P9000_PROGRAM_EXIT.
   ENDIF.

 ENDFORM.                    " p9000_duelist_refresh
*&---------------------------------------------------------------------*
*&      Form  set_last_shipping_date
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
 FORM SET_LAST_SHIPPING_DATE  USING    P_MSGTY.

   DATA: L_MAX_DATE  LIKE SY-DATUM.

   CHECK ZTITRQS-LSDAT IS INITIAL.

   LOOP AT IT_LSDAT.
     IF L_MAX_DATE LT IT_LSDAT-LSDAT.
       MOVE IT_LSDAT-LSDAT TO L_MAX_DATE.
     ENDIF.
   ENDLOOP.

   IF L_MAX_DATE IS INITIAL.
     EXIT.
   ENDIF.

   ZTITRQS-LSDAT = L_MAX_DATE.
   ZTITRQS-EXDAT = ZTITRQS-LSDAT + 20.

*_--> LS 전선 요청사항. ( By SB, Kang )
*     최종선적일을 개설요청일 + 60일
*     유효기일 = 최종선적일 + 9
   IF ZTITRQK-REQTY EQ C_LO.
* --> GSPOC요청번호 2014011700006
*     Amend요청일 경우 처리하지 않음
     IF ZTITRQS-AMDSQ IS INITIAL.
* --< GSPOC요청번호 2014011700006
       PERFORM  SET_LOCAL_DATE  USING ZTITRQS-REQDT SPACE.
* --> GSPOC요청번호 2014011700006
*     Amend요청일 경우 처리하지 않음
     ENDIF.
* --< GSPOC요청번호 2014011700006
   ENDIF.

 ENDFORM.                    " set_last_shipping_date
*&---------------------------------------------------------------------*
*&      Form  check_com_document_field
*&---------------------------------------------------------------------*
 FORM CHECK_COM_DOCUMENT_FIELD  USING    P_MODE.

   DATA : LV_STAWN LIKE MARC-STAWN.

   READ TABLE IT_ZTITIG02 WITH KEY ZTERM = ZTITRQS-ZTERM.
   IF SY-SUBRC EQ 0.
     IF ZTITRQK-REQTY NE IT_ZTITIG02-REQTY.
       MESSAGE S149 WITH ZTITRQK-REQTY IT_ZTITIG02-REQTY.
       PERFORM SET_RETURN_MESSAGE_FILL USING C_ERROR.
     ENDIF.
   ELSE.
     "--> [가온] 선급금/잔금 처리 위한 예외적용
     IF ZTITRQS-WERKS+0(1) = '6' AND ZTITRQS-EBELN = '4504235179'.
     ELSE.
       MESSAGE S164 WITH ZTITRQS-ZTERM.
       PERFORM SET_RETURN_MESSAGE_FILL USING C_ERROR.
     ENDIF.
     "<-- [가온] 선급금/잔금 처리 위한 예외적용
   ENDIF.
*****공통 check.
*> WBS 요소 Input Check.
   IF ZTITRQK-REQTY EQ C_PU.
*     IF ztitrqk-pspnr IS INITIAL.
*       PERFORM set_return_message USING 'ZTITRQK' 'PSPNR' c_error.
*     ENDIF.
   ELSE.
*    IF ZTITRQK-pspnr IS INITIAL.
*      PERFORM set_return_message USING 'ZTITRQK' 'PSPNR' c_warning.
*    ENDIF.
   ENDIF.
*> 금액 확인.
   IF P_MODE EQ C_CHARC OR
      P_MODE EQ C_CHARM.
     IF ZTITRQS-OPAMT IS INITIAL.
       PERFORM SET_RETURN_MESSAGE USING 'ZTITRQS' 'OPAMT' C_ERROR.
     ENDIF.
   ENDIF.

   CASE ZTITRQK-REQTY.
     WHEN C_LC OR C_TT OR C_DA OR C_DP.
*> 최종선적일자.
       IF ZTITRQK-REQTY NE C_TT.
         IF ZTITRQS-LSDAT IS INITIAL.
           PERFORM SET_RETURN_MESSAGE USING 'ZTITRQS' 'LSDAT' C_ERROR.
         ENDIF.
       ENDIF.
*>보험부보여부.
       IF ZTITRQS-INSYN IS INITIAL.   "보험부보여부.
         PERFORM SET_RETURN_MESSAGE USING 'ZTITRQS' 'INSYN' C_ERROR.
       ENDIF.
     WHEN OTHERS.
   ENDCASE.

*> 품목 확인.
   IF G_MODE EQ C_CHARC OR
      G_MODE EQ C_CHARM.
     CLEAR: G_COUNT.
     LOOP AT IT_TAB INTO G_TC_2130_WA.
       ADD 1 TO G_COUNT.
       IF G_TC_2130_WA-STAWN IS INITIAL AND
         ( SY-UNAME NE 'C526812'  AND  "엠트론제외
           SY-UNAME NE 'C287805'  ) .
         MESSAGE S133 WITH G_TC_2130_WA-REQIT 'H/S code'.
         PERFORM SET_RETURN_MESSAGE_FILL USING C_ERROR.
       ENDIF.
       IF G_TC_2130_WA-RQMNG IS INITIAL.
         MESSAGE S133 WITH G_TC_2130_WA-REQIT '수량'.
         PERFORM SET_RETURN_MESSAGE_FILL USING C_ERROR.
       ENDIF.
       IF G_TC_2130_WA-RQMNG GT G_TC_2130_WA-RQMNGL.
         MESSAGE S134 WITH G_TC_2130_WA-REQIT '수입의뢰'.
         PERFORM SET_RETURN_MESSAGE_FILL USING C_ERROR.
       ENDIF.
       IF NOT G_TC_2130_WA-LOEKZ IS INITIAL.
         MESSAGE S170 WITH G_TC_2130_WA-REQIT G_TC_2130_WA-EBELN
                                              G_TC_2130_WA-EBELP.
         PERFORM SET_RETURN_MESSAGE_FILL USING C_ERROR.
       ENDIF.

       IF ZTITRQK-REQTY EQ C_TT AND ZTITRQK-BUKRS EQ '1000'.
         SELECT SINGLE CCNGN
                 INTO (LV_STAWN)
                FROM ZMMT0131
               WHERE CCNGN  EQ  G_TC_2130_WA-STAWN.
         IF  LV_STAWN IS INITIAL.
           MESSAGE E999 WITH '등록할 수 있는 HS-CODE가 아닙니다!'.
         ENDIF.

       ENDIF.


     ENDLOOP.
     IF G_COUNT EQ 0.
       MESSAGE S135.
       PERFORM SET_RETURN_MESSAGE_FILL USING C_ERROR.
     ENDIF.
   ENDIF.

*>지급조건,희망일자.
   IF ZTITRQS-ZTERM IS INITIAL.   "지급조건.
     PERFORM SET_RETURN_MESSAGE USING 'ZTITRQS' 'ZTERM' C_ERROR.
   ENDIF.
   IF P_MODE EQ C_CHARC OR P_MODE EQ C_CHARM.
     IF ZTITRQS-REQDT IS INITIAL.   "희망일자.
       PERFORM SET_RETURN_MESSAGE USING 'ZTITRQS' 'REQDT' C_ERROR.
     ELSE.
       IF ZTITRQS-DOCST EQ SPACE.
         IF ZTITRQS-REQDT LT SY-DATLO.
           MESSAGE S119 WITH '개설희망일자' '현재일자'.
           PERFORM SET_RETURN_MESSAGE_FILL USING C_ERROR.
         ENDIF.
*----> LG전선에서 추가 요구로 수정, by MSH(050126)
         IF ZTITRQK-REQTY EQ C_LC.
* 20070416 simcho 박혁세K 요청으로 에러메세지 삭제
*           IF ztitrqs-reqdt GT ztitrqs-exdat.
*             MESSAGE s119 WITH '유효기일(E/D)' '개설희망일자'.
*             PERFORM set_return_message_fill USING c_error.
*           ENDIF.
         ENDIF.
*----> End of Modification.
       ENDIF.
     ENDIF.
   ENDIF.

*******> 신청 관리 작업일 경우.
   IF P_MODE EQ C_CHARY.
     IF ZTITRQS-SNDDT IS INITIAL.  ">신청일자.
       PERFORM SET_RETURN_MESSAGE USING 'ZTITRQS' 'SNDDT' C_ERROR.
     ENDIF.
     IF ZTITRQS-DOCST EQ C_CHARA OR
        ZTITRQS-DOCST EQ C_CHARW.
       IF ZTITRQS-SNDDT LT SY-DATLO.
         MESSAGE S119 WITH '개설신청일자' '현재일자'.
         PERFORM SET_RETURN_MESSAGE_FILL USING C_ERROR.
*         PERFORM set_return_message USING 'ZTITRQS' 'SNDDT' c_error.
*        MESSAGE e119 WITH '개설신청일자' '현재일자'.
       ENDIF.
     ENDIF.
     IF ZTITRQK-OPNBK IS INITIAL.  ">개설은행.
       PERFORM SET_RETURN_MESSAGE USING 'ZTITRQK' 'OPNBK' C_ERROR.
     ENDIF.
     IF ZTITRQK-REQTY EQ 'LC'.
       IF ZTITRQK-ILCTY IS INITIAL.  ">신용장 종류.
         PERFORM SET_RETURN_MESSAGE USING 'ZTITRQK' 'ILCTY' C_ERROR.
       ENDIF.
       IF ZTITRQK-ILCTY EQ 'U'.
         IF ZTITRQK-USCDY IS INITIAL.  ">유산스 기간.
           PERFORM SET_RETURN_MESSAGE USING 'ZTITRQK' 'USCDY' C_ERROR.
         ENDIF.
       ENDIF.
     ENDIF.
   ENDIF.

*> 개설관리 정보등록일 경우.
   IF P_MODE EQ C_CHARO.
     IF ZTITRQS-OPNDT IS INITIAL.  ">개설일자.
       PERFORM SET_RETURN_MESSAGE USING 'ZTITRQS' 'OPNDT' C_ERROR.
     ENDIF.
     IF ZTITRQS-OPNDT LT ZTITRQS-SNDDT.
       MESSAGE S119 WITH '개설일자' '개설신청일자'.
       PERFORM SET_RETURN_MESSAGE_FILL USING C_ERROR.
*       PERFORM set_return_message USING 'ZTITRQS' 'OPNDT' c_success.
*      MESSAGE e119 WITH '개설일자' '개설신청일자'.
     ENDIF.
     IF ZTITRQS-OPNNO IS INITIAL.  ">개설번호.
       PERFORM SET_RETURN_MESSAGE USING 'ZTITRQS' 'OPNNO' C_ERROR.
     ENDIF.
   ENDIF.
 ENDFORM.                    " check_com_document_field
*&---------------------------------------------------------------------*
*&      Form  check_lc_document_field
*&---------------------------------------------------------------------*
 FORM CHECK_LC_DOCUMENT_FIELD  USING    P_MODE.
*운송방법.
   IF ZTITRQS-FWDTY IS INITIAL.
     PERFORM SET_RETURN_MESSAGE USING 'ZTITRQS' 'FWDTY' C_ERROR.
   ENDIF.
*수수료부담자.
   IF ZTITLC1-CHGER IS INITIAL.
     PERFORM SET_RETURN_MESSAGE USING 'ZTITLC1' 'CHGER' C_ERROR.
   ENDIF.
*신용공여주체.
   IF ZTITRQK-REQTY EQ C_LC AND
      ZTITRQK-ILCTY EQ C_CHARU.
     IF ZTITRQS-PAGRT IS INITIAL.
       PERFORM SET_RETURN_MESSAGE USING 'ZTITRQS' 'PAGRT' C_ERROR.
     ENDIF.
   ENDIF.
*원산지 코드/명.
   IF ZTITRQS-CTOCD IS INITIAL.
     PERFORM SET_RETURN_MESSAGE USING 'ZTITRQS' 'CTOCD' C_ERROR.
   ENDIF.
   IF ZTITRQS-CTONM IS INITIAL.    ">원산지 명.
     SELECT SINGLE LANDX50
       INTO ZTITRQS-CTONM
       FROM T005T
      WHERE SPRAS EQ 'E'
        AND LAND1 EQ ZTITRQS-CTOCD.
     IF SY-SUBRC NE 0.
       PERFORM SET_RETURN_MESSAGE USING 'ZTITRQS' 'CTONM' C_ERROR.
     ENDIF.
   ENDIF.
*선적국가/항/명.
   IF ZTITRQS-FLAND IS INITIAL.
     PERFORM SET_RETURN_MESSAGE USING 'ZTITRQS' 'FLAND' C_ERROR.
   ENDIF.
   IF ZTITRQS-FPORT IS INITIAL.  ">선적항.
     PERFORM SET_RETURN_MESSAGE USING 'ZTITRQS' 'FPORT' C_ERROR.
   ENDIF.
   IF ZTITRQS-PLLOD IS INITIAL.  ">선적항명.
     PERFORM SET_RETURN_MESSAGE USING 'ZTITRQS' 'PLLOD' C_ERROR.
   ENDIF.
*도착국가/항/명.
   IF ZTITRQS-TLAND IS INITIAL.  ">도착국가.
     PERFORM SET_RETURN_MESSAGE USING 'ZTITRQS' 'TLAND' C_ERROR.
   ENDIF.
   IF ZTITRQS-TPORT IS INITIAL.  ">도착항.
     PERFORM SET_RETURN_MESSAGE USING 'ZTITRQS' 'TPORT' C_ERROR.
   ENDIF.
*    IF ZTITRQS-pltrn IS INITIAL.  ">선적항명.
*      PERFORM set_return_message USING 'ZTITRQS' 'PLTRN' c_error.
*    ENDIF.
*> 가격조건 관련 장소.
   IF ZTITRQS-INCO2 IS INITIAL.    "유효장소.
     PERFORM SET_RETURN_MESSAGE USING 'ZTITRQS' 'INCO2' C_ERROR.
   ENDIF.

*> 신청일 경우.
   IF P_MODE EQ C_CHARY.
*> 포워더 체크.
     PERFORM  CHECK_FORWARDER_DATA.
*        IF ZTITRQK-fwdcd IS INITIAL.  ">선적국가.
*          PERFORM set_return_message USING 'ZTITRQK' 'FWDCD' c_error.
*        ENDIF.
*    edi check!!!
*    PERFORM  set_return_mandatory     USING  :
*                                 'ZTITLC1-APPNM' c_error,
*                                 'ZTITLC1-APPNM' c_error, "
*                                 'ZTITLC1-BENNM' c_error, "
*                                 'ZTITLC1-NOMNM' c_error, "
*                                 'ZTITLC1-NOMID' c_error, "
*                                 'ZTITLC1-OPBCD' c_error, "
*                                 'ZTITRQS-SNDDT' c_error, "
*                                 'ZTITLC1-OPMET' c_error, "
*                                 'ZTITRQS-EXDAT' c_error, "
*                                 'ZTITLC1-EXPLC' c_error, "
*                                 'ZTITLC1-CHGER' c_error, "
*                                 'ZTITRQS-OPAMT' c_error, "
*                                 'ZTITRQS-WAERS' c_error, "
*                                 'ZTITRQS-PLLOD' c_error, "
*                                 'ZTITRQS-PLTRN' c_error, "
*                                 'ZTITRQS-PARTY' c_error, "
*                                 'ZTITRQS-TRANY' c_error, "
*                                 'ZTITRQS-INCO1' c_error. "
   ENDIF.
 ENDFORM.                    " check_lc_document_field
*&---------------------------------------------------------------------*
*&      Form  check_lo_document_field
*&---------------------------------------------------------------------*
 FORM CHECK_LO_DOCUMENT_FIELD  USING    P_MODE.
*"최종선적일
   IF ZTITRQS-LSDAT IS INITIAL.   .
     PERFORM SET_RETURN_MESSAGE USING 'ZTITRQS' 'LSDAT' C_ERROR.
   ELSE.
*    IF ZTITRQS-lsdat LE sy-datlo.
*      PERFORM set_return_message USING 'ZTITRQS' 'LSDAT' c_error.
*          MESSAGE e119 WITH '물품인도기일' '현재일자'.
*    ENDIF.
   ENDIF.
*"유효기일
*      IF ZTITRQS-exdat IS INITIAL.   .
*        PERFORM set_return_message USING 'ZTITRQS' 'EXDAT' c_error.
*      ENDIF.
*물품인도기일
*  IF ZTITRQS-lsdat GT ZTITRQS-exdat.
*    PERFORM set_return_message USING 'ZTITRQS' 'EXDAT' c_error.
**        MESSAGE e119 WITH '유효기일' '물품인도기일'.
*  ENDIF.
*> 분할선적.
   IF ZTITRQS-PARTY IS INITIAL.
     PERFORM SET_RETURN_MESSAGE USING 'ZTITRQS' 'PARTY' C_ERROR.
   ENDIF.

*> 근거서류 종류.
   IF ZTITLO1-LOPME IS INITIAL.
     PERFORM SET_RETURN_MESSAGE USING 'ZTITLO1' 'LOPME' C_ERROR.
   ENDIF.
*> 신용장 종류.
*   IF p_mode EQ c_chary OR
*      p_mode EQ c_charo.
   IF ZTITLO1-LLCTY IS INITIAL.
     PERFORM SET_RETURN_MESSAGE USING 'ZTITLO1' 'LLCTY' C_ERROR.
   ENDIF.
*   ENDIF.

**> 신청일 경우.
*  IF p_mode EQ c_chary.
**    edi check!!!
*    PERFORM  set_return_mandatory     USING  :
*                                    'ZTITLO1-LAPNM'  c_error,
*                                    'ZTITLO1-LBENM'  c_error, "
*                                    'ZTITLO1-LNONM'  c_error, "
*                                    'ZTITLO1-LNOID'  c_error, "
*                                    'ZTITLO1-LDODT'  c_error, "
*                                    'ZTITLO1-LGDO1'  c_error, "
*                                    'ZTITLO1-LSENO1' c_error. "
*
*  ENDIF.

*-->> 14889
* 수혜자사업자등록번호
*{Insert}
*   IF ztitlo1-lbepr2 IS INITIAL.
*     PERFORM set_return_message USING 'ZTITLO1' 'LBEPR2' c_error.
*   ENDIF.
*{/Insert}
*<<-- 14889

 ENDFORM.                    " check_lo_document_field
*&---------------------------------------------------------------------*
*&      Form  check_pc_document_field
*&---------------------------------------------------------------------*
 FORM CHECK_PC_DOCUMENT_FIELD  USING    P_MODE.

   IF ZTITRQK-ANBTY IS INITIAL.
     PERFORM SET_RETURN_MESSAGE USING 'ZTITPC1' 'ANBTY' C_ERROR.
   ENDIF.

*..구매확인서 EDI 문서 변경에 따른 수정 - 근거서류 필수 항목 check
*  (Req.by 이상엽K/2013.12.13/EDB03)
   IF OK_CODE = 'ZTIREQUEST' OR
      OK_CODE = 'ZTICHECK'.

     DATA: L_COUNT TYPE I.  "[41377 구매승인서 생성시 오류_변경]
     LOOP AT G_TC_2220_1_ITAB INTO G_TC_2220_1_WA.
       ADD 1 TO L_COUNT.
       IF G_TC_2220_1_WA-PBDAT IS INITIAL.
         PERFORM SET_RETURN_MESSAGE USING 'ZTITPC2' 'PBDAT' C_ERROR.
       ELSEIF G_TC_2220_1_WA-PBDATC IS INITIAL.
         PERFORM SET_RETURN_MESSAGE USING 'ZTITPC2' 'PBDATC' C_ERROR.
       ELSEIF G_TC_2220_1_WA-PBDSD IS INITIAL.
         PERFORM SET_RETURN_MESSAGE USING 'ZTITPC2' 'PBDSD' C_ERROR.
       ENDIF.
     ENDLOOP.

     IF L_COUNT IS INITIAL.
       PERFORM SET_RETURN_MESSAGE USING 'ZTITPC2' 'PBDNO' C_ERROR.
     ENDIF.
   ENDIF.

*   IF ztitpc1-pspy1 IS INITIAL.
*     PERFORM set_return_message USING 'ZTITPC1' 'PSPY1' c_error.
*   ENDIF.
*
*   IF ztitpc1-pspy2 IS INITIAL.
*     PERFORM set_return_message USING 'ZTITPC1' 'PSPY2' c_error.
*   ENDIF.
*
*   IF ztitpc1-pspy3 IS INITIAL.
*     PERFORM set_return_message USING 'ZTITPC1' 'PSPY3' c_error.
*   ENDIF.

   IF ZTITPC1-PSPCD IS INITIAL.
     PERFORM SET_RETURN_MESSAGE USING 'ZTITPC1' 'PSPCD' C_ERROR.
   ENDIF.

 ENDFORM.                    " check_pc_document_field
*&---------------------------------------------------------------------*
*&      Form  check_tt_document_field
*&---------------------------------------------------------------------*
 FORM CHECK_TT_DOCUMENT_FIELD  USING    P_MODE.
*">운송방법.
   IF ZTITRQS-FWDTY IS INITIAL.
     PERFORM SET_RETURN_MESSAGE USING 'ZTITRQS' 'FWDTY' C_ERROR.
   ENDIF.
*>"사전/사후 구분.
   IF ZTITRQK-ANBTY IS INITIAL.
     PERFORM SET_RETURN_MESSAGE USING 'ZTITRQK' 'ANBTY' C_ERROR.
   ENDIF.
* "지급지시서용도
   IF ZTITTT1-TPYFN IS INITIAL.
     PERFORM SET_RETURN_MESSAGE USING 'ZTITTT1' 'TPYFN' C_ERROR.
   ENDIF.
* "수수료부담자.
   IF ZTITTT1-TSTCD IS INITIAL.
*        ZTITTT1-tstcd = '14'.
     PERFORM SET_RETURN_MESSAGE USING 'ZTITTT1' 'TSTCD' C_ERROR.
   ENDIF.
*> 수취인 거래은행명.
   IF ZTITTT1-TBBNM IS INITIAL.
     PERFORM SET_RETURN_MESSAGE USING 'ZTITTT1' 'TBBNM' C_ERROR.
   ENDIF.
*> 수취인 거래은행코드.
   IF ZTITTT1-TBBAD3 IS INITIAL.
     PERFORM SET_RETURN_MESSAGE USING 'ZTITTT1' 'TBBAD3' C_ERROR.
*        MESSAGE e130.
   ENDIF.
*> 수취인 계좌번호.
   IF ZTITTT1-TBBAN IS INITIAL.
     PERFORM SET_RETURN_MESSAGE USING 'ZTITTT1' 'TBBAN' C_ERROR.
   ENDIF.
*> 수취인 계좌주명.  "기능개선 184344 - 구매처명/계좌주명 확인 로직 추가
   IF ZTITTT1-TBBAM IS INITIAL.
     PERFORM SET_RETURN_MESSAGE USING 'ZTITTT1' 'TBBAM' C_ERROR.
   ENDIF.
*>"유효장소.
   IF ZTITRQS-INCO2 IS INITIAL.
     PERFORM SET_RETURN_MESSAGE USING 'ZTITRQS' 'INCO2' C_ERROR.
   ENDIF.

*>"인도조건2 에러추가 .
   IF ZTITRQS-INCO2(1) = '.'.
     MESSAGE S325 .
     PERFORM SET_RETURN_MESSAGE_FILL USING C_ERROR.
   ENDIF.

*> 사후송금일 경우.
   IF ZTITRQK-ANBTY EQ C_CHARA.
     IF ZTITTT1-PAYRS IS INITIAL.
       PERFORM SET_RETURN_MESSAGE USING 'ZTITTT1' 'PAYRS' C_ERROR.
     ENDIF.

     IF ZTITTT1-GLCNO IS INITIAL.
       PERFORM SET_RETURN_MESSAGE USING 'ZTITTT1' 'GLCNO' C_ERROR.
     ENDIF.

     IF ZTITTT1-IMACD IS INITIAL.
       PERFORM SET_RETURN_MESSAGE USING 'ZTITTT1' 'IMACD' C_ERROR.
     ENDIF.

     IF ZTITTT1-DUEDT IS INITIAL.
       PERFORM SET_RETURN_MESSAGE USING 'ZTITTT1' 'DUEDT' C_ERROR.
     ENDIF.

     IF ZTITTT1-PLIDT IS INITIAL.
       PERFORM SET_RETURN_MESSAGE USING 'ZTITTT1' 'PLIDT' C_ERROR.
     ENDIF.
   ENDIF.
*****>>

   IF G_MODE EQ C_CHARY OR
      G_MODE EQ C_CHARO.
*> 포워더 체크.
     PERFORM  CHECK_FORWARDER_DATA.

     IF ZTITTT1-TECDT IS INITIAL.   " 이체희망일자.
       PERFORM SET_RETURN_MESSAGE USING 'ZTITTT1' 'TECDT' C_ERROR.
     ENDIF.
     IF ZTITRQS-SNDDT GT ZTITTT1-TECDT.
       PERFORM SET_RETURN_MESSAGE USING 'ZTITTT1' 'TECDT' C_ERROR.
*          MESSAGE e119 WITH '이체희망일자' '신청일자'.
     ENDIF.
   ENDIF.

 ENDFORM.                    " check_tt_document_field
*&---------------------------------------------------------------------*
*&      Form  P1001_GET_AND_COPY_PO_TEXT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
 FORM P1001_GET_AND_COPY_PO_TEXT TABLES  PT_EBELN STRUCTURE IT_PONUM.

   DATA: L_TDLINE   TYPE TDLINE.

   CHECK  NOT PT_EBELN[] IS INITIAL.
   CHECK: SY-TCODE       EQ C_CREATE OR
          SY-TCODE       EQ C_CREATE_D.
   CHECK  ZTITRQS-SETYN IS INITIAL.

   SELECT *
     INTO CORRESPONDING FIELDS OF TABLE IT_ZTSTIGT
     FROM ZTSTIGT
    WHERE TDOBF  EQ  'EKKO'.

   CHECK SY-SUBRC EQ 0.

*> Long text move
   IT_ALL_LINES[] = GT_CONTROL-TEXTLINES[].

   REFRESH: G_TEXTLINES.

   LOOP AT PT_EBELN.
     LOOP AT IT_ZTSTIGT.
       THEAD-TDID      = IT_ZTSTIGT-TDIDF.
       THEAD-TDOBJECT  = IT_ZTSTIGT-TDOBF.
       THEAD-TDNAME    = PT_EBELN-EBELN.
       THEAD-TDSPRAS   = SY-LANGU.

       REFRESH: IT_LINE. CLEAR: IT_LINE.

       CALL FUNCTION 'READ_TEXT'
         EXPORTING
*          CLIENT                  = SY-MANDT
           ID                      = THEAD-TDID
           LANGUAGE                = THEAD-TDSPRAS
           NAME                    = THEAD-TDNAME
           OBJECT                  = THEAD-TDOBJECT
*          ARCHIVE_HANDLE          = 0
*          LOCAL_CAT               = ' '
*     IMPORTING
*          HEADER                  =
         TABLES
           LINES                   = IT_LINE
         EXCEPTIONS
           ID                      = 1
           LANGUAGE                = 2
           NAME                    = 3
           NOT_FOUND               = 4
           OBJECT                  = 5
           REFERENCE_CHECK         = 6
           WRONG_ACCESS_TO_ARCHIVE = 7
           OTHERS                  = 8.
       IF SY-SUBRC <> 0.
*     MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
       ELSE.
         MOVE: IT_ZTSTIGT-TDOBT   TO THEAD-TDOBJECT,
               PT_EBELN-EBELN      TO THEAD-TDNAME,
               SY-LANGU            TO THEAD-TDSPRAS,
               IT_ZTSTIGT-TDIDT   TO THEAD-TDID.

         LOOP AT IT_LINE.
           IF SY-TABIX EQ 1.
             CONCATENATE '[ 구매오더 : ' PT_EBELN-EBELN ']' INTO
             L_TDLINE
             SEPARATED BY SPACE.
             MOVE: L_TDLINE             TO G_TEXTLINES-TDLINE,
                   IT_LINE-TDFORMAT     TO G_TEXTLINES-TDFORMAT,
                   THEAD-TDOBJECT       TO G_TEXTLINES-TDOBJECT,
                   THEAD-TDID           TO G_TEXTLINES-TDID.
             APPEND G_TEXTLINES.
           ENDIF.
           MOVE: IT_LINE-TDLINE       TO G_TEXTLINES-TDLINE,
                 IT_LINE-TDFORMAT     TO G_TEXTLINES-TDFORMAT,
                 THEAD-TDOBJECT       TO G_TEXTLINES-TDOBJECT,
                 THEAD-TDID           TO G_TEXTLINES-TDID.
           APPEND G_TEXTLINES.
         ENDLOOP.
       ENDIF.
     ENDLOOP.
   ENDLOOP.

   IF SY-SUBRC EQ 0.
     READ TABLE GT_CONTROL WITH KEY OBJECT = C_TEXTOBJECT_HEADER.
     IF SY-SUBRC EQ 0.
       G_TABIX = SY-TABIX.
       GT_CONTROL-TEXTLINES[] = G_TEXTLINES[].
       MODIFY GT_CONTROL INDEX G_TABIX.
     ENDIF.
   ENDIF.

 ENDFORM.                    " P1001_GET_AND_COPY_PO_TEXT
*&---------------------------------------------------------------------*
*&      Module  tc_2130_amount_modify  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
 MODULE TC_2130_AMOUNT_MODIFY INPUT.

   MOVE ZTISRQIT-NETWR TO G_TC_2130_WA-NETWR.

*> 정가 계산.
   CALL FUNCTION 'Z_TI_CALC_ITEM_AMOUNT'
     EXPORTING
       PEINH = G_TC_2130_WA-PEINH
       BPUMZ = G_TC_2130_WA-BPUMZ
       BPUMN = G_TC_2130_WA-BPUMN
       MENGE = G_TC_2130_WA-RQMNG
       NETPR = G_TC_2130_WA-NETPR
     CHANGING
       NETWR = G_NETWR.

   IF G_TC_2130_WA-NETWR IS INITIAL.
     G_TC_2130_WA-NETWR = G_NETWR.
   ELSE.
     IF G_TC_2130_WA-NETWR <> G_NETWR.
       MESSAGE W025 WITH TC_2130-CURRENT_LINE.
     ENDIF.
   ENDIF.

   IF G_TC_2130_WA-CNAM IS INITIAL.
     MOVE: SY-UNAME TO G_TC_2130_WA-CNAM,
           SY-DATLO TO G_TC_2130_WA-CDAT,
           SY-TIMLO TO G_TC_2130_WA-CTME.
   ENDIF.

   MOVE: SY-UNAME TO G_TC_2130_WA-UNAM,
         SY-DATLO TO G_TC_2130_WA-UDAT,
         SY-TIMLO TO G_TC_2130_WA-UTME.


   MODIFY  IT_TAB
     FROM  G_TC_2130_WA
     INDEX TC_2130-CURRENT_LINE.

 ENDMODULE.                 " tc_2130_amount_modify  INPUT
*&---------------------------------------------------------------------*
*&      Form  set_HS_CODE_REG
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM SET_HS_CODE_REG .

   SELECT SINGLE *
     FROM T005
    WHERE LAND1  =  T001-LAND1.

   CALL SCREEN  8000 STARTING AT 01    01.

   CHECK OK-CODE EQ 'ZTIOKAY'.

   LOOP AT IT_TAB INTO G_TC_2130_WA.
     G_TC_2130_WA-STAWN = ZTISSCRCOM-STAWN.
     MODIFY IT_TAB FROM G_TC_2130_WA.
   ENDLOOP.

 ENDFORM.                    " set_HS_CODE_REG
*&---------------------------------------------------------------------*
*&      Form  SET_REQUEST_BY_PUR_DOCUMENT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
 FORM SET_REQUEST_BY_PUR_DOCUMENT .

   PERFORM P3000_SET_DATA_OF_SCREEN.
   ZTITRQS-SETYN  = C_TRUE.

   IF SY-CALLD EQ C_TRUE AND
      G_TCODE1 EQ C_DUE_LIST_PU.
     LOOP AT IT_RKWA.
       MOVE-CORRESPONDING IT_RKWA TO G_TC_2130_WA.
       MOVE: 1             TO G_TC_2130_WA-PEINH,
             1             TO G_TC_2130_WA-BPUMZ,
             1             TO G_TC_2130_WA-BPUMN,
             IT_RKWA-BSTMG TO G_TC_2130_WA-MENGE,
             IT_RKWA-BSTME TO G_TC_2130_WA-MEINS.

       SELECT  SUM( RQMNG )
         INTO G_TC_2130_WA-RQMNGS
         FROM ZTIVRQ00
        WHERE  MBLNR  = G_TC_2130_WA-MBLNR
          AND  MJAHR  = G_TC_2130_WA-MJAHR
          AND  ZEILE  = G_TC_2130_WA-ZEILE.

       G_TC_2130_WA-RQMNG  = G_TC_2130_WA-MENGE - G_TC_2130_WA-RQMNGS.
       G_TC_2130_WA-RQMNGL = G_TC_2130_WA-RQMNG.

       IF G_TC_2130_WA-RQMNG LE C_ZERO.
         MESSAGE E103.
       ENDIF.

       SELECT SINGLE PS_PSP_PNR AUFNR
         INTO (G_TC_2130_WA-PS_PSP_PNR, G_TC_2130_WA-NPLNR)
         FROM MSEG
        WHERE MBLNR   = IT_RKWA-MBLNR
          AND MJAHR   = IT_RKWA-MJAHR
          AND ZEILE   = IT_RKWA-ZEILE.
       IF G_TC_2130_WA-PS_PSP_PNR IS INITIAL.
         IF G_TC_2130_WA-MENGE EQ 0.
           G_TC_2130_WA-NETPR = 0.
         ELSE.
           G_TC_2130_WA-NETPR = IT_RKWA-WRBTR / IT_RKWA-BSTMG.
         ENDIF.
       ELSE.
         PERFORM GET_PARENT_WBS_ELEMENT(ZTIR0000)
                                        USING G_TC_2130_WA-PS_PSP_PNR
                                              GS_PROJ.
         MOVE: GS_PROJ-PSPNR   TO G_TC_2130_WA-PS_PSP_PNR.

*        SELECT SINGLE netpr
*          INTO g_tc_2130_wa-netpr
*          FROM zmmt0003
*         WHERE lifnr EQ it_rkwa-lifnr
*           AND matnr EQ g_tc_2130_wa-matnr
*           AND pspid EQ g_tc_2130_wa-ps_psp_pnr
*           AND sdate LE it_rkwa-budat
*           AND edate GE it_rkwa-budat.
*
         G_TC_2130_WA-NETWR = G_TC_2130_WA-NETPR * G_TC_2130_WA-MENGE.

       ENDIF.
       IF NOT G_TC_2130_WA-NPLNR IS INITIAL.
         PERFORM GET_WBS_ELEMENT_BY_NETWORK(ZTIR0000)
                                        USING G_TC_2130_WA-NPLNR
                                              GS_PROJ.
         MOVE: GS_PROJ-PSPNR   TO G_TC_2130_WA-PS_PSP_PNR.
       ENDIF.

       MOVE: SY-UNAME TO G_TC_2130_WA-CNAM,
             SY-DATLO TO G_TC_2130_WA-CDAT,
             SY-TIMLO TO G_TC_2130_WA-CTME,
             SY-UNAME TO G_TC_2130_WA-UNAM,
             SY-DATLO TO G_TC_2130_WA-UDAT,
             SY-TIMLO TO G_TC_2130_WA-UTME.

       APPEND G_TC_2130_WA  TO IT_TAB.

       MOVE : IT_RKWA-LIFNR TO ZTITRQK-LIFNR,
              IT_RKWA-BUKRS TO ZTITRQK-BUKRS,
              IT_RKWA-BWAER TO ZTITRQS-WAERS,
              C_PU          TO ZTITRQK-REQTY,
              C_TRUE        TO ZTITRQS-SETYN.
     ENDLOOP.
*>아이템 번호를 생성함.
     PERFORM SET_ITEM_NUMBER_BUILD TABLES IT_TAB
                                   USING  ZTITRQS.
   ELSE.
*      perform

   ENDIF.

   CLEAR: G_MODIFY.

 ENDFORM.                    " SET_REQUEST_BY_PUR_DOCUMENT
*&---------------------------------------------------------------------*
*&      Form  SET_REQUEST_BY_BL_DOCUMENT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
 FORM SET_REQUEST_BY_BL_DOCUMENT .

   CLEAR: ZTITRQS-SETYN.

   PERFORM P3000_SET_DATA_OF_SCREEN.

   ZTITRQK-ANBTY = C_CHARA.
   ZTITRQS-SETYN = SPACE.
   ZTITRQK-REQTY = C_TT.

*> 삼국무역일 경우.
   IF ZTITRQK-TDPYN EQ SPACE.
     MOVE: 'ACB' TO ZTITTT1-PAYRS.  ">지급사유."-->수입대금 결제.
   ELSE.
     MOVE: 'ACE' TO ZTITTT1-PAYRS.  ">지급사유."-->수입대금 결제.
   ENDIF.

   IF SY-CALLD EQ C_TRUE AND
      G_TCODE1 EQ C_DUE_LIST_TT.
     LOOP AT IT_ZTISBLIT.
       MOVE-CORRESPONDING IT_ZTISBLIT TO G_TC_2130_WA.

       CLEAR: G_MODIFY, ZTIVPO00.
       DESCRIBE TABLE IT_TAB LINES G_COUNT_1.
*> 면장정보 확인..
************************************************************************
* 20070314 박혁세K 요청 by simcho
************************************************************************
       IF IT_ZTISBLIT-RPTTY <> 'Z'.   "미통관이 아니면
************************************************************************
**** 20130404 CLAER 처리 확인
         CLEAR : ZTIVCC02.

         SELECT SINGLE *
           FROM ZTIVCC02
          WHERE IBLNO  EQ   IT_ZTISBLIT-IBLNO
            AND IBLIT  EQ   IT_ZTISBLIT-IBLIT.
************************************************************************
* CSR  : C20090611_71632
* 내역 : 사후송금 조건의 경우 수입필증 체크로직 삭제
************************************************************************
*         IF sy-subrc EQ 0.
         PERFORM  GET_AND_CHECK_PO_DATA   USING  IT_ZTISBLIT-EBELN
                                                 IT_ZTISBLIT-EBELP
                                                 G_MODIFY
                                                 ZTIVPO00
                                                 G_COUNT_1
                                                 C_ERROR.

*> PO data Move
         PERFORM SET_REQUEST_OF_BL_DATA     TABLES IT_TAB
                                            USING  ZTIVPO00
                                                   ZTITRQK
                                                   ZTITRQS
                                                   IT_ZTISBLIT.
         IF ZTITTT1-PAYRS EQ 'ACB'.  ">수입대금결제.
           CLEAR: G_TC_2124_WA.
           MOVE: ZTITTT1-PAYRS   TO G_TC_2124_WA-PAYRS,
                 ZTIVCC02-ICCNO  TO G_TC_2124_WA-REFNO,
                 ZTIVCC02-CDCNO  TO G_TC_2124_WA-CDCNO,
                 ZTIVCC02-CDRDT  TO G_TC_2124_WA-CDRDT,
                 ZTIVCC02-CREFWR TO G_TC_2124_WA-VPTAF,
                 ZTIVCC02-WAERS  TO G_TC_2124_WA-WAERS,
                 ZTIVCC02-BLNUM  TO G_TC_2124_WA-BLNUM.
*PAYAT
*GLCNO
*IVNUM
*IMACD
           COLLECT G_TC_2124_WA INTO G_TC_2124_ITAB.
         ELSE.

         ENDIF.
*         ELSE.
*           MESSAGE e043 WITH it_ztisblit-iblno it_ztisblit-iblit.
*         ENDIF.
       ELSE.
         PERFORM  GET_AND_CHECK_PO_DATA   USING  IT_ZTISBLIT-EBELN
                                                 IT_ZTISBLIT-EBELP
                                                 G_MODIFY
                                                 ZTIVPO00
                                                 G_COUNT_1
                                                 C_ERROR.

*> PO data Move
         PERFORM SET_REQUEST_OF_BL_DATA     TABLES IT_TAB
                                            USING  ZTIVPO00
                                                   ZTITRQK
                                                   ZTITRQS
                                                   IT_ZTISBLIT.
         IF ZTITTT1-PAYRS EQ 'ACB'.  ">수입대금결제.
           CLEAR: G_TC_2124_WA.
           MOVE: ZTITTT1-PAYRS   TO G_TC_2124_WA-PAYRS,
                 ZTIVCC02-ICCNO  TO G_TC_2124_WA-REFNO,
                 ZTIVCC02-CDCNO  TO G_TC_2124_WA-CDCNO,
                 ZTIVCC02-CDRDT  TO G_TC_2124_WA-CDRDT,
                 ZTIVCC02-CREFWR TO G_TC_2124_WA-VPTAF,
                 ZTIVCC02-WAERS  TO G_TC_2124_WA-WAERS,
                 ZTIVCC02-BLNUM  TO G_TC_2124_WA-BLNUM.
*PAYAT
*GLCNO
*IVNUM
*IMACD
           COLLECT G_TC_2124_WA INTO G_TC_2124_ITAB.
         ELSE.

         ENDIF.
       ENDIF.
     ENDLOOP.
*>아이템 번호를 생성함.
     PERFORM SET_ITEM_NUMBER_BUILD TABLES IT_TAB
                                   USING  ZTITRQS.
   ELSE.
*      perform

   ENDIF.

   IF ZTITTT1-TPYFN IS INITIAL.    "지급지시서용도
     IF ZTITRQS-WAERS EQ T001-WAERS.
       ZTITTT1-TPYFN = '2AN'.
     ELSE.
       ZTITTT1-TPYFN = '2AM'.
     ENDIF.
*        PERFORM no_input_check USING 'ZTITTT1' 'TPYFN' c_error.
   ENDIF.
   IF ZTITTT1-TSTCD IS INITIAL.    "수수료부담자.
     ZTITTT1-TSTCD = '14'.
*        PERFORM no_input_check USING 'ZTITTT1' 'TSTCD' c_error.
   ENDIF.
*> 지급확인서(APPCOP)용,.
   IF ZTITRQK-ANBTY EQ 'A'.
     CLEAR: G_COUNT.
     LOOP AT G_TC_2124_ITAB INTO G_TC_2124_WA.
       G_TABIX = SY-TABIX.
       SELECT SUM( PAYAT )
         INTO G_TC_2124_WA-PAYATS
         FROM ZTITTT4
        WHERE CDCNO EQ G_TC_2124_WA-CDCNO.
* 20051010 simcho 임동욱D 요청 - 총외화금액 오류 수정
* 총 금액에 기 지급금액 포함
       G_TC_2124_WA-VPTAF = G_TC_2124_WA-VPTAF + G_TC_2124_WA-PAYATS.
*
       G_TC_2124_WA-PAYATL = G_TC_2124_WA-VPTAF - G_TC_2124_WA-PAYATS.
       IF G_TC_2124_WA-PAYATL LT 0.
         G_TC_2124_WA-PAYATL = 0.
       ENDIF.
       G_TC_2124_WA-PAYAT = G_TC_2124_WA-PAYATL.
       IF G_TC_2124_WA-PAYATL EQ 0.
         DELETE G_TC_2124_ITAB INDEX G_TABIX.
       ELSE.
         ADD 1 TO G_COUNT.
         G_TC_2124_WA-PAYIT = G_COUNT.
         MODIFY G_TC_2124_ITAB FROM G_TC_2124_WA.
       ENDIF.
     ENDLOOP.
   ENDIF.

   REFRESH: IT_PONUM.
   LOOP AT IT_TAB INTO G_TC_2130_WA.
     IT_PONUM-EBELN = G_TC_2130_WA-EBELN.
     COLLECT IT_PONUM.
   ENDLOOP.

   CLEAR: G_MODIFY.

 ENDFORM.                    " SET_REQUEST_BY_BL_DOCUMENT
*&---------------------------------------------------------------------*
*&      Form  SET_REQUEST_BY_RETENTION
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
 FORM SET_REQUEST_BY_RETENTION .

   CLEAR: ZTITRQS-SETYN.
   PERFORM P3000_SET_DATA_OF_SCREEN.
   ZTITRQK-ANBTY = C_CHARA.
   ZTITRQS-SETYN = SPACE.
   ZTITRQK-REQTY = C_TT.
   ZTITRQK-RPAID = C_TRUE.

   IF SY-CALLD EQ C_TRUE AND
      G_TCODE1 EQ C_DUE_LIST_RT.
     LOOP AT IT_ZTISBLIT.

       MOVE : IT_ZTISBLIT-IBLNO       TO ZTITRQS-RBLNO.
       MOVE-CORRESPONDING IT_ZTISBLIT TO G_TC_2130_WA.

       CLEAR: G_MODIFY, ZTIVPO00.
       DESCRIBE TABLE IT_TAB LINES G_COUNT_1.
       PERFORM  GET_AND_CHECK_PO_DATA   USING  IT_ZTISBLIT-EBELN
                                               IT_ZTISBLIT-EBELP
                                               G_MODIFY
                                               ZTIVPO00
                                               G_COUNT_1
                                               C_SUCCESS.
*                                              c_error.

*> PO data Move
       PERFORM SET_REQUEST_OF_BL_DATA     TABLES IT_TAB
                                          USING  ZTIVPO00
                                                 ZTITRQK
                                                 ZTITRQS
                                                 IT_ZTISBLIT.
     ENDLOOP.
*>아이템 번호를 생성함.
     PERFORM SET_ITEM_NUMBER_BUILD TABLES IT_TAB
                                   USING  ZTITRQS.
   ELSE.
*      perform

   ENDIF.

   SELECT SINGLE *
     FROM ZTITBLK
    WHERE IBLNO EQ ZTITRQS-RBLNO.
   IF SY-SUBRC EQ 0.
     ZTITRQS-FWDTY = ZTITBLK-FWDTY.
     ZTITRQS-OPAMT = ZTITBLK-RTCHG.
     ZTISSCRCOM-OPAMT = ZTITBLK-RTCHG.
*> 금액 체크.
     PERFORM CHECK_OPEN_AMOUNT.
*> 금액 분할.
     PERFORM  SET_ITEM_AMOUNT_AND_QTY_CALC.

   ENDIF.

   IF ZTITTT1-TPYFN IS INITIAL.    "지급지시서용도
     IF ZTITRQS-WAERS EQ T001-WAERS.
       ZTITTT1-TPYFN = '2AN'.
     ELSE.
       ZTITTT1-TPYFN = '2AM'.
     ENDIF.
*        PERFORM no_input_check USING 'ZTITTT1' 'TPYFN' c_error.
   ENDIF.
   IF ZTITTT1-TSTCD IS INITIAL.    "수수료부담자.
     ZTITTT1-TSTCD = '14'.
*        PERFORM no_input_check USING 'ZTITTT1' 'TSTCD' c_error.
   ENDIF.

   ZTITRQK-RPAID = C_TRUE.

   REFRESH: IT_PONUM.
   LOOP AT IT_TAB INTO G_TC_2130_WA.
     IT_PONUM-EBELN = G_TC_2130_WA-EBELN.
     COLLECT IT_PONUM.
   ENDLOOP.

   CLEAR: G_MODIFY.

 ENDFORM.                    " SET_REQUEST_BY_RETENTION
*&---------------------------------------------------------------------*
*&      Form  set_request_of_bl_data
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
 FORM SET_REQUEST_OF_BL_DATA     TABLES P_IT_TAB   LIKE IT_TAB
                                 USING  P_ZTIVPO00 STRUCTURE ZTIVPO00
                                        P_ZTITRQK STRUCTURE ZTITRQK
                                        P_ZTITRQS STRUCTURE ZTITRQS
                                       P_ZTISBLIT STRUCTURE IT_ZTISBLIT.

   MOVE-CORRESPONDING P_ZTIVPO00 TO : P_IT_TAB,
                                      P_ZTITRQK,
                                      P_ZTITRQS,
                                      EKKO.

*> 구매오더 수입관련 필드 --> 수입의뢰 상태 테이블.
   PERFORM MOVE_EKKO_FIELDS_TO_ZTITRQS  USING  EKKO
                                                P_ZTITRQS.

   ZTITRQK-ANBTY = C_CHARA.
   ZTITRQK-REQTY = C_TT.

   MOVE: P_ZTISBLIT-RQMNG  TO P_IT_TAB-RQMNG,
         P_ZTISBLIT-RQMNGS TO P_IT_TAB-RQMNGS,
         P_ZTISBLIT-RQMNGL TO P_IT_TAB-RQMNGL,
         P_ZTISBLIT-REFWR  TO P_IT_TAB-NETWR,
         P_ZTISBLIT-NETPR  TO P_IT_TAB-NETPR,
         P_ZTISBLIT-STAWN  TO P_IT_TAB-STAWN,
         P_ZTISBLIT-BLMNG  TO P_IT_TAB-MENGE,
         P_ZTISBLIT-IBLNO  TO P_IT_TAB-IBLNO,
         P_ZTISBLIT-IBLIT  TO P_IT_TAB-IBLIT.

   MOVE: SY-UNAME TO P_IT_TAB-CNAM,
         SY-DATLO TO P_IT_TAB-CDAT,
         SY-TIMLO TO P_IT_TAB-CTME,
         SY-UNAME TO P_IT_TAB-UNAM,
         SY-DATLO TO P_IT_TAB-UDAT,
         SY-TIMLO TO P_IT_TAB-UTME.

   APPEND P_IT_TAB.

*>아이템 번호를 생성함.
   PERFORM SET_ITEM_NUMBER_BUILD TABLES P_IT_TAB
                                 USING  P_ZTITRQS.

   PERFORM GET_OTHERS_TEXT_BY_MASTER_DATA.
 ENDFORM.                    " set_request_of_bl_data
*&---------------------------------------------------------------------*
*&      Form  SET_EDI_PARTNER_FIELD
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
 FORM SET_EDI_PARTNER_FIELD .

   DATA: L_POS   TYPE I.

   CHECK : G_MODE EQ C_CHARC OR
           G_MODE EQ C_CHARM OR
           G_MODE EQ C_CHARY OR
           G_MODE EQ C_CHARO OR
           G_MODE EQ C_CHARW.

   CASE ZTITRQK-REQTY.
     WHEN C_DA OR C_DP.
       MOVE: 'GENRES-'       TO  ZTITRQS-RECNO,
             ZTITRQS+3(10)   TO  ZTITRQS-RECNO+7(10),
             '-'             TO  ZTITRQS-RECNO+17(1),
             ZTITRQS+13(2)   TO  ZTITRQS-RECNO+18(2).
*> 수신자 Setting.
       MOVE: ZTSTIG3-EPART  TO  ZTITRQS-RECID, ">수신자 IDs
             ZTSTIG3-ENMT1  TO  ZTITRQS-RECNM.
     WHEN C_LC.
       IF ZTITRQS-AMDSQ EQ C_ZERO.
         MOVE: 'APP700-'       TO  ZTITRQS-RECNO,
               ZTITRQS+3(10)   TO  ZTITRQS-RECNO+7(10),
               '-'             TO  ZTITRQS-RECNO+17(1),
               ZTITRQS+13(2)   TO  ZTITRQS-RECNO+18(2).
**-------------------------------------------------------------------
**> 지급조건.
**-------------------------------------------------------------------
*         IF ztitrqk-ilcty     EQ c_chara.   ">At Sight일 경우.
*           ztitlc1-pate1 = 'AT SIGHT'.
*         ELSEIF ztitrqk-ilcty EQ c_charu.   ">Usance일 경우.
*           IF ztitrqk-uscdy GT 999.
*             l_pos = 0.
*           ELSEIF ztitrqk-uscdy GT 99.
*             l_pos = 1.
*           ELSEIF ztitrqk-uscdy GT 9.
*             l_pos = 2.
*           ELSE.
*             l_pos = 3.
*           ENDIF.
**  ----> LG전선 요청에 의해 Text 문구 수정, by jp,park(050718)
**           CONCATENATE ztitrqk-uscdy+l_pos  'DAYS AFTER SIGHT'
*           CONCATENATE ztitrqk-uscdy+l_pos  'DAYS FROM B/L DATE'
*                INTO ztitlc1-pate1 SEPARATED BY space.
*         ENDIF.
**> 운송방법에 따라.
*         CASE ztitrqs-fwdty.
*           WHEN c_chara.   ">Air
*             PERFORM  set_air_document_required.
*           WHEN c_charo.   ">Ocean
*             PERFORM  set_ocean_document_required.
*           WHEN c_charc.   ">Air + Ocean
*             PERFORM  set_ocean_document_required.
*             PERFORM  set_air_document_required.
*           WHEN c_charm.   ">Others.
*         ENDCASE.
*> 지정 포워더일 경우.
         DESCRIBE TABLE G_TC_2123_ITAB LINES G_LINE.
         IF G_LINE GT 0.
           LOOP AT G_TC_2123_ITAB INTO G_TC_2123_WA.
             IF G_TC_2123_WA-FWDAM EQ C_TRUE.
               IF ZTITLC1-MATE1 IS INITIAL.
                 ZTITLC1-MATE1 = 'X'.
                 ZTITLC1-CARNM = G_TC_2123_WA-NAME1.
                 EXIT.
               ENDIF.
             ENDIF.
           ENDLOOP.
           IF ZTITLC1-CARNM IS INITIAL.
             LOOP AT G_TC_2123_ITAB INTO G_TC_2123_WA.
               IF ZTITLC1-MATE1 IS INITIAL.
                 ZTITLC1-MATE1 = 'X'.
                 ZTITLC1-CARNM = G_TC_2123_WA-NAME1.
                 EXIT.
               ENDIF.
             ENDLOOP.
           ENDIF.
         ENDIF.
       ELSE.
         MOVE: 'APP707-'       TO  ZTITRQS-RECNO,
               ZTITRQS+3(10)  TO  ZTITRQS-RECNO+7(10),
               '-'             TO  ZTITRQS-RECNO+17(1),
               ZTITRQS+13(2)  TO  ZTITRQS-RECNO+18(2).
       ENDIF.

*> 명의인.
       IF ZTITRQS-WERKS+0(1) EQ '6'.
         MOVE: ZTSTIG0-EOMNS  TO  ZTITLC1-NOMNM,
                    '120'  TO  ZTITLC1-NOMPR,
               ZTSTIG0-EOAD1  TO  ZTITLC1-NOAD1,
               ZTSTIG0-EOAD2  TO  ZTITLC1-NOAD2,
                ZTSTIG0-ESIGN  TO  ZTITLC1-NOMID.

       ELSE.

         MOVE: ZTSTIG0-EOMNS  TO  ZTITLC1-NOMNM,
               ZTSTIG0-EOMPR  TO  ZTITLC1-NOMPR,
               ZTSTIG0-EOAD1  TO  ZTITLC1-NOAD1,
               ZTSTIG0-EOAD2  TO  ZTITLC1-NOAD2,
               ZTSTIG0-ESIGN  TO  ZTITLC1-NOMID.
       ENDIF.

*> 개설은행.
*      MOVE: ZTSTIG3-epart  TO  ZTITLC1-opbcd,
       MOVE: ZTSTIG3-IBKCD  TO  ZTITLC1-OPBCD,
             ZTSTIG3-ENMT1  TO  ZTITLC1-OPBNM,
             ZTSTIG3-ADDR1  TO  ZTITLC1-OPBBR,
*S__ 신용장 변경에 따른 수정 20181010 BY SDW
             ZTSTIG3-ADDR2  TO  ZTITLC1-OPBBR2,
*E__ 신용장 변경에 따른 수정 20181010 BY SDW
             ZTSTIG3-TELNO  TO  ZTITLC1-OPBTL.

*------------------------------------------------------------------
*>> LS 전선 로직 수정사항.  By SB, Kang
*   2. 외환은행 은행코드 오류:
*      지급지시서-> 05, 신용장/AMEND->06M8 로 되어야 하는데,
*      모두 05로 처리됨.
       IF ZTITLC1-OPBCD EQ '05'.
         ZTITLC1-OPBCD = '06M8'.
       ENDIF.
*------------------------------------------------------------------

*> 수신자 Setting.
       MOVE: ZTSTIG3-EPART  TO  ZTITRQS-RECID, ">수신자 IDs
             ZTSTIG3-ENMT1  TO  ZTITRQS-RECNM.
     WHEN C_PU.
       MOVE: 'APPPCR-'       TO  ZTITRQS-RECNO,
             ZTITRQS+3(10)  TO  ZTITRQS-RECNO+7(10),
             '-'             TO  ZTITRQS-RECNO+17(1),
             ZTITRQS+13(2)  TO  ZTITRQS-RECNO+18(2).
*> 발급은행.
*      MOVE: ZTSTIG3-epart TO ZTITPC1-pcbcd,
       MOVE: ZTSTIG3-IBKCD TO ZTITPC1-PCBCD,
             ZTSTIG3-ENMT1 TO ZTITPC1-PCBNM,
             SPACE          TO ZTITPC1-PCBBR.
*> 수신자 Setting.
       MOVE: ZTSTIG3-EPART  TO  ZTITRQS-RECID, ">수신자 IDs
             ZTSTIG3-ENMT1  TO  ZTITRQS-RECNM.

*-->> 14889 구매확인서의 경우
* 1. 메인화면에서 동보전송 체크하면
*    사업자등록번호 : 사업자번호+식별자+상세식별자 필수
* 2. 메인화면에서 동보전송 언체크하면
*    사업자등록번호 : 사업자번호
*{Remark}
*         lfa1-stcd2      TO ztitpc1-pspid.
*{/Remark}

*{Insert}
       DATA : LV_IDENF  LIKE ZTSTIG3-IDENF,
              LV_IDENF1 LIKE ZTSTIG3-IDENF1.

       CLEAR : LV_IDENF, LV_IDENF1.

       CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
         EXPORTING
           INPUT  = LFA1-LIFNR
         IMPORTING
           OUTPUT = LFA1-LIFNR.

       SELECT SINGLE IDENF IDENF1
         FROM ZTSTIG3
         INTO (LV_IDENF, LV_IDENF1)
        WHERE PARTI = 'V'
          AND EPART = LFA1-LIFNR
          AND BUKRS = ZTITRQK-BUKRS.

       CLEAR : G_CHECK.    "에러체크용 변수

       IF ZTITRQS-DONGBO = 'X'.
* 세 변수 모두 값이 있을때만 처리, 하나라도 없으면 에러처리
         IF LFA1-STCD2 IS NOT INITIAL AND
            LV_IDENF   IS NOT INITIAL AND
            LV_IDENF1  IS NOT INITIAL.

           CONCATENATE LFA1-STCD2 LV_IDENF '/' LV_IDENF1
                     INTO ZTITPC1-PSPID.
         ELSE.
           CLEAR : ZTITPC1-PSPID.
           G_CHECK = 'X'.
         ENDIF.

       ELSE.
         MOVE LFA1-STCD2      TO ZTITPC1-PSPID.
       ENDIF.
*{/Insert}
*<<-- 14889

     WHEN C_TT.
*> 개설은행.
       MOVE: ZTSTIG3-IBKCD  TO  ZTITTT1-TOBCD,
             ZTSTIG3-ENMT1  TO  ZTITTT1-TOBNM,
             ZTSTIG3-ENMT2  TO  ZTITTT1-TOBBR,
             ZTITRQS-WAERS  TO  ZTITTT1-TOBAC,
             ZTITRQS-WAERS  TO  ZTITTT1-TBBAC.

*       BREAK-POINT.

       SELECT BANKN
         INTO ZTITTT1-TOBAN
         FROM T012K UP TO 1 ROWS
        WHERE BUKRS EQ ZTITRQK-BUKRS
          AND WAERS EQ ZTITRQS-WAERS
*> 이장욱 위원 요청.    --> Start
          AND BKONT EQ 'E '
*> 이장욱 위원 요청.    --> Ened
          AND HBKID EQ ( SELECT HBKID
                           FROM ZTSTIG3
                          WHERE PARTI EQ 'B'
                            AND BUKRS EQ ZTITRQK-BUKRS
                            AND EPART EQ ZTSTIG3-EPART ).
       ENDSELECT.


*> 수신자 Setting.
       MOVE: ZTSTIG3-EPART  TO  ZTITRQS-RECID, ">수신자 IDs
             ZTSTIG3-ENMT1  TO  ZTITRQS-RECNM,
             'PAYORD-'      TO  ZTITRQS-RECNO,
             ZTITRQS+3(10)  TO  ZTITRQS-RECNO+7(10),
             '-'            TO  ZTITRQS-RECNO+17(1),
             ZTITRQS+13(2)  TO  ZTITRQS-RECNO+18(2).
*> 기타 초기값 Setting.
       MOVE: C_CHAR9        TO ZTITTT1-RECTR,  ">전송.
             'AB'           TO ZTITTT1-RECAS,  ">유효장소.
             ZTITRQS-SNDDT  TO ZTITTT1-TAPDT.  ">신청일자.
       MOVE: ZTSTIG0-NOAD1  TO ZTITTT1-NOAD1,
             ZTSTIG0-NOAD2  TO ZTITTT1-NOAD2.

*>CHM2407-00576 HS CODE Item 필드값으로 setting.
       READ TABLE IT_TAB INTO G_TC_2130_WA INDEX 1.
       IF SY-SUBRC EQ 0.
         MOVE G_TC_2130_WA-STAWN TO ZTITRQS-OTHT1.
       ENDIF.
*>CHM2407-00576 HS CODE Item 필드값으로 setting.

     WHEN C_LO.
       IF ZTITRQS-AMDSQ EQ C_ZERO.

*> 기능개선 96084 - 2015.09.17 문서번호 변경
         DATA : LV_SNDDT LIKE ZTITRQS-SNDDT,
                LV_OPNBK LIKE ZTITRQK-OPNBK.

         CLEAR : GV_RECNO, LV_SNDDT, LV_OPNBK.

         IF SY-TCODE = 'ZTIT006'.
           IF ZTITRQS-RECNO IS INITIAL.
             PERFORM GET_RECNO.
           ELSE.

             SELECT SINGLE
               SNDDT
               INTO LV_SNDDT
               FROM ZTITRQS
               WHERE REQNO = ZTITRQS-REQNO.

             SELECT SINGLE
               OPNBK
               INTO LV_OPNBK
               FROM ZTITRQK
               WHERE REQNO = ZTITRQS-REQNO.

             IF NOT ZTITRQS-SNDDT EQ LV_SNDDT
               OR NOT ZTITRQK-OPNBK EQ LV_OPNBK.
               PERFORM GET_RECNO.
             ELSE.
               SELECT SINGLE RECNO
                 INTO GV_RECNO
                 FROM ZTITRQS
                 WHERE REQNO = ZTITRQS-REQNO.
             ENDIF.
           ENDIF.
         ELSE.
           SELECT SINGLE RECNO
             INTO GV_RECNO
             FROM ZTITRQS
             WHERE REQNO = ZTITRQS-REQNO.
         ENDIF.
         MOVE GV_RECNO TO ZTITRQS-RECNO.
*   ENDIF.
*         MOVE: 'LOCAPP-'       TO  ztitrqs-recno,
*               ztitrqs+3(10)   TO  ztitrqs-recno+7(10),
*               '-'             TO  ztitrqs-recno+17(1),
*               ztitrqs+13(2)   TO  ztitrqs-recno+18(2).
       ELSE.
         MOVE: 'LOCAMR-'       TO  ZTITRQS-RECNO,
               ZTITRQS+3(10)   TO  ZTITRQS-RECNO+7(10),
               '-'             TO  ZTITRQS-RECNO+17(1),
               ZTITRQS+13(2)   TO  ZTITRQS-RECNO+18(2).

       ENDIF.
*> 발급은행.
       MOVE: ZTSTIG3-IBKCD  TO  ZTITLO1-LOBCD,
             ZTSTIG3-ENMT1  TO  ZTITLO1-LOBNM,
             ZTSTIG3-ADDR1  TO  ZTITLO1-LOBBR.
*> 수신자 Setting.
       MOVE: ZTSTIG3-EPART  TO  ZTITRQS-RECID, ">수신자 IDs
             ZTSTIG3-ENMT1  TO  ZTITRQS-RECNM.
   ENDCASE.

 ENDFORM.                    " SET_EDI_PARTNER_FIELD
*&---------------------------------------------------------------------*
*&      Form  display_amendent_fields
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
 FORM DISPLAY_AMENDENT_FIELDS .

   REFRESH: IT_AMEND_FIELDS.

*> Amount 구분자.
*--------> 금액.
   IF ZTITRQS-OPAMTX = C_TRUE.
     PERFORM  FILL_AMENDENT_FILED USING :
            'ZTITRQS-OPAMT' 'OLD_ZTITRQS-OPAMT' 'C' ZTITRQS-WAERS ''.
   ENDIF.
*--------> E/D 구분자.
   IF ZTITRQS-EXDATX = C_TRUE.
     CASE ZTITRQK-REQTY.
       WHEN C_LC.
         PERFORM  FILL_AMENDENT_FILED USING :
                  'ZTITRQS-EXDAT' 'OLD_ZTITRQS-EXDAT' '' '' ''.
       WHEN C_LO.
         PERFORM  FILL_AMENDENT_FILED USING :
             'ZTITRQS-EXDAT' 'OLD_ZTITRQS-EXDAT' '' '' '물품인도기일'.
     ENDCASE.
   ENDIF.
*--------> S/D 구분자.
   IF ZTITRQS-LSDATX = C_TRUE.
     CASE ZTITRQK-REQTY.
       WHEN C_LC OR C_LO.
         PERFORM  FILL_AMENDENT_FILED USING :
              'ZTITRQS-LSDAT' 'OLD_ZTITRQS-LSDAT' '' '' ''.
     ENDCASE.
   ENDIF.
*--------> 분할선적 구분자.
   IF ZTITRQS-PARTYX = C_TRUE.
     CASE ZTITRQK-REQTY.
       WHEN C_LC OR C_LO.
         PERFORM  FILL_AMENDENT_FILED USING :
              'ZTITRQS-PARTY' 'OLD_ZTITRQS-PARTY' '' '' ''.
     ENDCASE.
   ENDIF.

*--------> 환적 구분자.
   IF ZTITRQS-TRANYX = C_TRUE.
     CASE ZTITRQK-REQTY.
       WHEN C_LC.
         PERFORM  FILL_AMENDENT_FILED USING :
              'ZTITRQS-TRANY' 'OLD_ZTITRQS-TRANY' '' '' ''.
     ENDCASE.
   ENDIF.
*--------> 선적항.
   IF ZTITRQS-FPORTX = C_TRUE.
     CASE ZTITRQK-REQTY.
       WHEN C_LC.
         PERFORM  FILL_AMENDENT_FILED USING :
              'ZTITRQS-PLLOD' 'OLD_ZTITRQS-PLLOD' '' '' ''.
     ENDCASE.
   ENDIF.
*--------> 도착항.
   IF ZTITRQS-TPORTX = C_TRUE.
     CASE ZTITRQK-REQTY.
       WHEN C_LC.
         PERFORM  FILL_AMENDENT_FILED USING :
              'ZTITRQS-PLTRN' 'OLD_ZTITRQS-PLTRN' '' '' ''.
     ENDCASE.
   ENDIF.
*--------> 원산지.
   IF ZTITRQS-CTOCDX = C_TRUE.
     CASE ZTITRQK-REQTY.
       WHEN C_LC.
         PERFORM  FILL_AMENDENT_FILED USING :
              'ZTITRQS-CTONM' 'OLD_ZTITRQS-CTONM' '' '' ''.
     ENDCASE.
   ENDIF.

*--------> 보험적용구분자.
   IF ZTITRQS-INSYNX = C_TRUE.
     PERFORM  FILL_AMENDENT_FILED USING :
          'ZTITRQS-INSYN' 'OLD_ZTITRQS-INSYN' '' '' ''.
   ENDIF.
*--------> 운송방법.
   IF ZTITRQS-FWDTYX = C_TRUE.
     PERFORM  FILL_AMENDENT_FILED USING :
          'ZTITRQS-FWDTY' 'OLD_ZTITRQS-FWDTY' '' '' ''.
   ENDIF.
*--------> Incoterms.
   IF ZTITRQS-INCO1X = C_TRUE.
     PERFORM  FILL_AMENDENT_FILED USING :
          'ZTITRQS-INCO1' 'OLD_ZTITRQS-INCO1' '' '' ''.
   ENDIF.

*--------> 품목 변경사항.
   LOOP AT IT_TAB_O INTO G_TAB_OLD.
     READ TABLE IT_TAB INTO G_TC_2130_WA
                       WITH KEY REQIT = G_TAB_OLD-REQIT.
     IF SY-SUBRC NE 0.
       WRITE G_TAB_OLD-REQIT TO IT_AMEND_FIELDS-SCRTEXT_M.
       CONCATENATE IT_AMEND_FIELDS-SCRTEXT_M '번째 품목 삭제'
             INTO IT_AMEND_FIELDS-SCRTEXT_M
             SEPARATED BY SPACE.
       APPEND IT_AMEND_FIELDS.
     ELSE.
*-------> 품목수량.
       IF G_TC_2130_WA-RQMNG NE G_TAB_OLD-RQMNG.
         MOVE: 'ZTITRQP'  TO IT_AMEND_FIELDS-TABNAME,
               'RQMNG'     TO IT_AMEND_FIELDS-FIELDNAME.

         WRITE G_TAB_OLD-REQIT TO IT_AMEND_FIELDS-SCRTEXT_M.
         CONCATENATE IT_AMEND_FIELDS-SCRTEXT_M '번째 품목 수량'
               INTO IT_AMEND_FIELDS-SCRTEXT_M
               SEPARATED BY SPACE.

         WRITE: G_TC_2130_WA-RQMNG TO IT_AMEND_FIELDS-F_NEW
                                   UNIT G_TC_2130_WA-MEINS.
         WRITE: G_TAB_OLD-RQMNG    TO IT_AMEND_FIELDS-F_OLD
                                   UNIT G_TAB_OLD-MEINS.

         CONDENSE IT_AMEND_FIELDS-F_NEW.
         CONDENSE IT_AMEND_FIELDS-F_OLD.

         CONCATENATE IT_AMEND_FIELDS-F_NEW G_TC_2130_WA-MEINS
                INTO IT_AMEND_FIELDS-F_NEW
                SEPARATED BY SPACE.
         CONCATENATE IT_AMEND_FIELDS-F_OLD G_TAB_OLD-MEINS
                INTO IT_AMEND_FIELDS-F_OLD
                SEPARATED BY SPACE.

         APPEND IT_AMEND_FIELDS.
       ENDIF.
*-------> 품목금액.
       IF G_TC_2130_WA-NETWR NE G_TAB_OLD-NETWR.
         MOVE: 'ZTITRQP'  TO IT_AMEND_FIELDS-TABNAME,
               'NETWR'     TO IT_AMEND_FIELDS-FIELDNAME.

         WRITE G_TAB_OLD-REQIT TO IT_AMEND_FIELDS-SCRTEXT_M.
         CONCATENATE IT_AMEND_FIELDS-SCRTEXT_M '번째 품목 금액'
               INTO IT_AMEND_FIELDS-SCRTEXT_M
               SEPARATED BY SPACE.

         WRITE: G_TC_2130_WA-NETWR TO IT_AMEND_FIELDS-F_NEW
                                   CURRENCY ZTITRQS-WAERS.
         WRITE: G_TAB_OLD-NETWR    TO IT_AMEND_FIELDS-F_OLD
                                   CURRENCY ZTITRQS-WAERS.

         CONDENSE IT_AMEND_FIELDS-F_NEW.
         CONDENSE IT_AMEND_FIELDS-F_OLD.

         CONCATENATE IT_AMEND_FIELDS-F_NEW ZTITRQS-WAERS
                INTO IT_AMEND_FIELDS-F_NEW
                SEPARATED BY SPACE.
         CONCATENATE IT_AMEND_FIELDS-F_OLD ZTITRQS-WAERS
                INTO IT_AMEND_FIELDS-F_OLD
                SEPARATED BY SPACE.

         APPEND IT_AMEND_FIELDS.
       ENDIF.
*> 구매오더.
       IF G_TC_2130_WA-EBELN NE G_TAB_OLD-EBELN.
         ZTITRQP-EBELN = G_TC_2130_WA-EBELN.
         PERFORM  FILL_AMENDENT_FILED USING :
              'ZTITRQP-EBELN' 'G_TAB_OLD-EBELN' '' '' ''.
       ENDIF.
*> 구매오더 품목.
       IF G_TC_2130_WA-EBELP NE G_TAB_OLD-EBELP.
         ZTITRQP-EBELP = G_TC_2130_WA-EBELP.
         PERFORM  FILL_AMENDENT_FILED USING :
              'ZTITRQP-EBELP' 'G_TAB_OLD-EBELP' '' '' ''.
       ENDIF.
     ENDIF.
   ENDLOOP.

   LOOP AT IT_TAB INTO G_TC_2130_WA.
     READ TABLE IT_TAB_O INTO G_TAB_OLD
                         WITH KEY REQIT = G_TC_2130_WA-REQIT.
     IF SY-SUBRC NE 0.
       WRITE G_TC_2130_WA-REQIT TO IT_AMEND_FIELDS-SCRTEXT_M.
       CONCATENATE IT_AMEND_FIELDS-SCRTEXT_M '번째 품목 삽입'
              INTO IT_AMEND_FIELDS-SCRTEXT_M
              SEPARATED BY SPACE.
       APPEND IT_AMEND_FIELDS.
     ENDIF.
   ENDLOOP.

   CALL FUNCTION 'Z_TI_DISPLAY_AMENDENT_FIELDS'
     TABLES
       IT_ZTISAMENDFID = IT_AMEND_FIELDS
     EXCEPTIONS
       NO_DATA         = 1
       OTHERS          = 2.
   IF SY-SUBRC <> 0.
*    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
     MESSAGE ID SY-MSGID TYPE 'S' NUMBER SY-MSGNO
             WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
   ENDIF.

 ENDFORM.                    " display_amendent_fields
*&---------------------------------------------------------------------*
*&      Form  set_forwarder_data
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
 FORM SET_FORWARDER_DATA .

   REFRESH: G_TC_2123_ITAB. CLEAR: G_TC_2123_ITAB.

*> 선적국가별 포워더.
   SELECT  H~MANDT H~LAND1 H~FWDCD H~ASGMK H~FWDTY V~NAME1
           H~PORTC H~PORTE
           H~CNAM  H~CDAT  H~CTME  H~UNAM  H~UDAT H~UTME
     INTO  CORRESPONDING FIELDS OF TABLE IT_ZTITIG10
     FROM  ZTITIG10 AS H INNER JOIN LFA1 AS V
       ON  H~FWDCD  EQ  V~LIFNR
    WHERE  H~LAND1  EQ  ZTITRQS-FLAND
    AND    H~ASGMK  EQ  C_TRUE.

   IF SY-SUBRC NE 0.
     IF NOT ( SY-DYNNR EQ C_SCR0100 OR
              SY-DYNNR EQ C_SCR0120 ).
       MESSAGE I128 WITH ZTITRQS-FLAND '지정'.
     ENDIF.
   ELSE.
     CLEAR G_COUNT.
     LOOP AT IT_ZTITIG10.
       IF IT_ZTITIG10-FWDTY EQ ZTITRQS-FWDTY.
         ADD 1 TO G_COUNT.
       ENDIF.
     ENDLOOP.
     IF G_COUNT EQ 0.
       CLEAR: G_COUNT.
       LOOP AT IT_ZTITIG10.
         CLEAR: G_TC_2123_WA.
         ADD 1 TO G_COUNT.
         MOVE-CORRESPONDING IT_ZTITIG10 TO G_TC_2123_WA.
         IF ZTITRQS-FWDTY EQ C_CHARY OR
            ZTITRQS-FWDTY EQ C_CHARO OR
            ZTITRQS-FWDTY EQ C_CHARC OR
            ZTITRQS-FWDTY EQ C_CHARM.
           MOVE: ZTITRQS-FWDTY           TO G_TC_2123_WA-FWDTY.
         ENDIF.
         MOVE: G_COUNT TO G_TC_2123_WA-FWDSQ.
         APPEND G_TC_2123_WA TO G_TC_2123_ITAB.
         IF SY-DYNNR EQ C_SCR0100 OR
            SY-DYNNR EQ C_SCR0120.
           IF ZTITRQS-FLAND IS INITIAL.
             ZTITRQS-FLAND = IT_ZTITIG10-LAND1.
             ZTITRQS-FPORT = IT_ZTITIG10-PORTC.
             ZTITRQS-PLLOD = IT_ZTITIG10-PORTE.
           ENDIF.
         ENDIF.
       ENDLOOP.
     ELSE.
       LOOP AT IT_ZTITIG10 WHERE FWDTY EQ ZTITRQS-FWDTY.
         CLEAR: G_TC_2123_WA.
         ADD 1 TO G_COUNT.
         MOVE-CORRESPONDING IT_ZTITIG10 TO G_TC_2123_WA.
         MOVE: G_COUNT TO G_TC_2123_WA-FWDSQ.
         APPEND G_TC_2123_WA TO G_TC_2123_ITAB.
         IF SY-DYNNR EQ C_SCR0100 OR
            SY-DYNNR EQ C_SCR0120.
           IF ZTITRQS-FLAND IS INITIAL.
             ZTITRQS-FLAND = IT_ZTITIG10-LAND1.
             ZTITRQS-FPORT = IT_ZTITIG10-PORTC.
             ZTITRQS-PLLOD = IT_ZTITIG10-PORTE.
           ENDIF.
         ENDIF.
       ENDLOOP.
     ENDIF.
   ENDIF.

 ENDFORM.                    " set_forwarder_data
*&---------------------------------------------------------------------*
*&      Form  check_forwarder_data
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
 FORM CHECK_FORWARDER_DATA .
* 포워더 체크 안함.
*  IF ZTITRQK-fwdas = c_true.
**> 지정 포워더 Setting
*    DESCRIBE TABLE g_tc_2123_itab LINES g_line.
*    IF g_line EQ 0.
*      MESSAGE s030.
*      PERFORM set_return_message_fill USING c_error.
*    ENDIF.
*  ENDIF.
 ENDFORM.                    " check_forwarder_data
*&---------------------------------------------------------------------*
*&      Form  create_work_flow_event
*&---------------------------------------------------------------------*
*       위탁자재 WorkFlow Event 생성.
*----------------------------------------------------------------------*
 FORM CREATE_WORK_FLOW_EVENT .

*> API for Events
   CALL FUNCTION 'SWE_EVENT_CREATE'
     EXPORTING
       OBJTYPE           = OBJTYPE
       OBJKEY            = OBJKEY
       EVENT             = EVENT
     IMPORTING
       EVENT_ID          = EVENT_ID
     TABLES
       EVENT_CONTAINER   = EVENT_CONTAINER
     EXCEPTIONS
       OBJTYPE_NOT_FOUND = 1.

   IF SY-SUBRC NE 0.
     ROLLBACK WORK.
     MESSAGE A934.   EXIT.
   ENDIF.

 ENDFORM.                    " create_work_flow_event
*&---------------------------------------------------------------------*
*&      Form  get_longtext_data
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
 FORM GET_LONGTEXT_DATA .

   DATA: L_MODE   TYPE   C,
         L_SCREEN TYPE   SY-DYNNR.

*> Partner Text
   PERFORM  P1000_GET_TEXTID_AND_TEXT USING ZTITRQS+3(12)
                                            C_TEXTOBJECT_HEADER
                                            C_SCR0100
                                            C_TRUE
                                            C_FALSE.

*> Set EDI 문구 .
   PERFORM SET_EDI_TEXTID_AND_TEXT.

*S__ 신용장 변경에 따른 수정 20181010 BY SDW
   PERFORM GET_TEXT_CHECKBOX.
*E__ 신용장 변경에 따른 수정 20181010 BY SDW

*>TEXT Object COPY.
   CHECK G_MODE EQ C_CHARC.

   LOOP AT IT_PONUM.
     IF SY-TABIX EQ 1.
       L_MODE = C_TRUE.
     ELSE.
       L_MODE = C_FALSE.
     ENDIF.

     SELECT SINGLE *
       FROM EKKO
      WHERE EBELN EQ IT_PONUM-EBELN.
*header TEXT.
     PERFORM  GET_AND_COPY_PRE_DOC_TEXT USING    IT_PONUM-EBELN
                                                 'EKKO'
                                                 'ZTIRQHD'
                                                 L_MODE
                                                 EKKO-SPRAS.
   ENDLOOP.

 ENDFORM.                    " get_longtext_data
*&---------------------------------------------------------------------*
*&      Form  build_query_factories_class
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
 FORM BUILD_QUERY_FACTORIES_CLASS .

   CALL FUNCTION 'Z_TI_GET_REQ_OF_IMPORT_QUERY'
     IMPORTING
       EX_FACTORY = G_DATABLADE.

 ENDFORM.                    " build_query_factories_class

*&---------------------------------------------------------------------*
*&      Form  OTHER_FUNCTIONS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
 FORM OTHER_FUNCTIONS .

   CASE OK_CODE.
     WHEN 'ZTIREQTY_CHG'.  ">수입의뢰종류변경.

     WHEN 'ZTIREQUEST'.    ">수입의뢰.
       CASE ZTITIG00-RQEDS.
         WHEN C_CHARA.
           IF ZTITRQS-EDIYN = C_FALSE.
             IF NOT ( ZTITRQK-REQTY EQ C_DA OR
                      ZTITRQK-REQTY EQ C_DP ).
               MESSAGE E013.
             ENDIF.
           ENDIF.
       ENDCASE.

************************************************************************
** CSR  : C20090611_71632
** 사후송금 조건:수입통관 기준아닌 BL입력 시점으로 logic변경
**               송장생성 여부 체크
************************************************************************
       DATA : LV_IVONO     LIKE ZTITIVP-IVONO,
              LV_RBLGP     LIKE ZTITIVP-RBLGP,
              LV_BELNR     LIKE ZTITIVK-BELNR,
              LV_GJAHR     LIKE ZTITIVK-GJAHR,
              LV_BELNR_SAP LIKE BKPF-BELNR.

       IF ZTITRQK-REQTY = C_TT.
         LOOP AT IT_ZTISBLIT.
           CLEAR : LV_IVONO, LV_RBLGP, LV_BELNR, LV_GJAHR.

           SELECT SINGLE IVONO  RBLGP  INTO (LV_IVONO, LV_RBLGP)
             FROM ZTITIVP
            WHERE IBLNO  EQ  IT_ZTISBLIT-IBLNO
              AND IBLIT  EQ  IT_ZTISBLIT-IBLIT.

           IF SY-SUBRC = '00'.
             SELECT SINGLE BELNR GJAHR INTO (LV_BELNR, LV_GJAHR)
               FROM ZTITIVK
              WHERE IVONO = LV_IVONO.
           ENDIF.
* 20110613 박혁S,이민영S 긴급요청
* 20110708 이길상C 긴급요청
* 20110708 송장MIRO처리 했을 경우 주석처리
           IF LV_BELNR = '' .
             MESSAGE E997 WITH IT_ZTISBLIT-IBLNO IT_ZTISBLIT-IBLIT
                               '송장 미처리 상태입니다.'.
           ENDIF.
*
         ENDLOOP.
************************************************************************
*-- 자체개선 222199 : 특수문자 체크로직 추가
************************************************************************
       ELSEIF ZTITRQK-REQTY = C_PU.
         LOOP AT G_TC_2220_2_ITAB INTO G_TC_2220_2_WA.
           PERFORM  CHECK_EDI_AVAILABLE_CHAR3  USING :
                          G_TC_2220_2_WA-PCSNM 'ZTITPC3-PCSNM'  C_ERROR,
                          G_TC_2220_2_WA-PCSZ1 'ZTITPC3-PCSZ1'  C_ERROR,
                          G_TC_2220_2_WA-PCSZ2 'ZTITPC3-PCSZ2'  C_ERROR,
                          G_TC_2220_2_WA-PCSZ3 'ZTITPC3-PCSZ3'  C_ERROR,
                          G_TC_2220_2_WA-PCSZ4 'ZTITPC3-PCSZ4'  C_ERROR,
                          G_TC_2220_2_WA-PCSZ5 'ZTITPC3-PCSZ5'  C_ERROR,
                          G_TC_2220_2_WA-PCSA1 'ZTITPC3-PCSA1'  C_ERROR,
                          G_TC_2220_2_WA-PCSA2 'ZTITPC3-PCSA2'  C_ERROR,
                          G_TC_2220_2_WA-PCSA3 'ZTITPC3-PCSA3'  C_ERROR,
                          G_TC_2220_2_WA-PCSA4 'ZTITPC3-PCSA4'  C_ERROR,
                          G_TC_2220_2_WA-PCSA5 'ZTITPC3-PCSA5'  C_ERROR.
         ENDLOOP.
       ENDIF.
************************************************************************

*S__ 신용장 변경에 따른 수정 20181010 BY SDW
       PERFORM CHECK_TEXT_EDIT_DATA.
*E__ 신용장 변경에 따른 수정 20181010 BY SDW

       PERFORM  CALL_OTHERS_TRANSACTION  USING   C_CHARQ
                                                 C_DELETE
                                                 C_FALSE
                                                 C_FALSE.
     WHEN 'ZTIREQCANC'.  ">수입의뢰취소.
       PERFORM  CALL_OTHERS_TRANSACTION  USING   C_CHAR1
                                                 C_DELETE
                                                 C_FALSE
                                                 C_FALSE.
     WHEN 'ZTIACCEPT'.   ">접수.
       CASE ZTITIG00-RQEDS.
         WHEN C_CHARA.
           IF ZTITRQK-REQTY EQ C_TT.
             SELECT SINGLE *
               FROM ZTITTT1
              WHERE REQNO EQ ZTITRQK-REQNO.
             IF SY-SUBRC <> 0.
               MESSAGE E013.
             ENDIF.
           ENDIF.
       ENDCASE.

       PERFORM  CALL_OTHERS_TRANSACTION  USING   C_CHARA
                                                 C_DELETE
                                                 C_FALSE
                                                 C_FALSE.
     WHEN 'ZTIRETURN'.   ">접수반려.
       PERFORM  CALL_OTHERS_TRANSACTION  USING   C_CHARE
                                                 C_DELETE
                                                 C_FALSE
                                                 C_FALSE.
     WHEN 'ZTIAPPLY'.    ">상신.
       PERFORM  CALL_OTHERS_TRANSACTION  USING   C_CHAR5
                                                 C_DELETE
                                                 C_FALSE
                                                 C_FALSE.
     WHEN 'ZTIAPPLYC'.   ">상신취소.
       PERFORM  CALL_OTHERS_TRANSACTION  USING   C_CHAR6
                                                 C_DELETE
                                                 C_FALSE
                                                 C_FALSE.
     WHEN 'ZTIAPPLYB'.   ">반려.
       PERFORM  CALL_OTHERS_TRANSACTION  USING   C_CHAR7
                                                 C_DELETE
                                                 C_FALSE
                                                 C_FALSE.

     WHEN 'ZTISEND'.     ">EDI 신청.
       CASE ZTITIG00-RQEDS.
         WHEN C_CHARB.
           IF ZTITRQS-EDIYN = C_FALSE.
*             IF NOT ( ztitrqk-reqty EQ c_da OR
*                      ztitrqk-reqty EQ c_dp ).
*               MESSAGE e013.
*             ENDIF.
           ENDIF.
       ENDCASE.
       PERFORM  CALL_OTHERS_TRANSACTION  USING   C_CHARI
                                                 C_DELETE
                                                 C_FALSE
                                                 C_FALSE.

     WHEN 'ZTISENDC'.   ">신청취소.
       PERFORM  CALL_OTHERS_TRANSACTION  USING   C_CHARF
                                                 C_DELETE
                                                 C_FALSE
                                                 C_FALSE.
     WHEN 'ZTIRECVC'.   ">개설취소.
       PERFORM  CALL_OTHERS_TRANSACTION  USING   C_CHARN
                                                 C_DELETE
                                                 C_FALSE
                                                 C_FALSE.
     WHEN 'ZTICLOSE'.   ">종료처리.
       PERFORM  CALL_OTHERS_TRANSACTION  USING   C_CHARG
                                                 C_DELETE
                                                 C_FALSE
                                                 C_FALSE.
     WHEN 'ZTICLOSEC'.   ">종료취소 처리.
       PERFORM  CALL_OTHERS_TRANSACTION  USING   C_CHARG
                                                 C_DELETE
                                                 C_FALSE
                                                 C_FALSE.
     WHEN 'ZTISPLIT'.    ">금액분할.
       PERFORM  SET_AMOUNT_SPLIT.
     WHEN 'ZTIHSCODE'.   ">H/S CODE일괄등록.
       PERFORM  SET_HS_CODE_REG.
     WHEN 'ZTIAMEND'.    ">변경데이타 확인.
       PERFORM  DISPLAY_AMENDENT_FIELDS.
     WHEN 'ZTIEDI'.      ">EDI 화면으로 이동.
*> Set 문서별 EDI Default value
       PERFORM SET_EDI_DEFAULT_VALUE.
*> EDI Main 화면으로 이동.
       IF G_MODE EQ C_CHARC OR
          G_MODE EQ C_CHARM OR
          G_MODE EQ C_CHARY.
         PERFORM  CHECK_FOR_DOCUMENT_FIELD USING G_MODE.
         IF G_LINE EQ 0.
*-->> 14889
*{Remark}
*           MESSAGE s911.
*{/Remark}

*{Insert}
           IF G_CHECK = 'X'.
             MESSAGE S999 WITH
             '사업자번호(식별자정보) 마스터정보가 누락되었습니다!!'.
           ELSE.
             MESSAGE S911.
           ENDIF.
*{/Insert}
*<<-- 14889
           SET SCREEN C_SCR2200.
         ENDIF.
       ELSE.
         SET SCREEN C_SCR2200.
       ENDIF.
     WHEN 'ZTIMK03'.     ">공급업체.
       PERFORM DISPLAY_VENDOR_MASTER USING ZTITRQK-LIFNR
                                           ZTITRQK-EKORG.
     WHEN 'ZTICHDOC'.    ">변경문서.
       G_OBJEKT   = 'ZTILCCHDOC'.
       G_OBJEKTID = ZTITRQS+3(12).
       PERFORM DISPLAY_CHANGE_DOCUMENT USING G_OBJEKT
                                             G_OBJEKTID.
*-[CHM2205-00327] 연결 BL의 첨부파일 리스트 팝업버튼 추가
     WHEN 'ZTIRQLNK'.
       CHECK ZTITRQK-REQNO IS NOT INITIAL.
       CALL FUNCTION 'ZMM_DOC_LINK_LIST'
         EXPORTING
           P_TYPE = 'REQ'
           P_LNUM = ZTITRQK-REQNO.

     WHEN OTHERS.
   ENDCASE.
 ENDFORM.                    " OTHER_FUNCTIONS

*&---------------------------------------------------------------------*
*&      Form  BEFORE_TRANSPORT_PAI
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
 FORM BEFORE_TRANSPORT_PAI .

*> 개설금액 체크.
   PERFORM  CHECK_OPEN_AMOUNT.
*> 이전 값과 비교하여 change 구분자를 설정함.
   IF ZTITRQS-AMDSQ GT C_ZERO.
     PERFORM  COMPARE_FIELDS_CHANGED.
   ENDIF.
   IF G_MODE EQ C_CHARC OR
      G_MODE EQ C_CHARM.
*> WBS 요소.
     PERFORM  SET_WBS_ELEMENT        USING C_NONE.
*> 최종선적일자.
     PERFORM  SET_LAST_SHIPPING_DATE USING C_NONE.
   ENDIF.

 ENDFORM.                    " BEFORE_TRANSPORT_PAI

*&---------------------------------------------------------------------*
*&      Form  SET_TEXTID_AND_TEXT_LC
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
 FORM SET_TEXTID_AND_TEXT_LC  TABLES   PT_ZTITLC2 STRUCTURE VZTITLC2
                              USING    P_TEXTOBJECT
                                       P_TEXTID
                                       P_SCREEN.
   DATA: L_SUBRC_OBJ LIKE SY-SUBRC,
         L_TABIX_OBJ LIKE SY-TABIX,
         L_SUBRC_ID  LIKE SY-SUBRC,
         L_TABIX_ID  LIKE SY-TABIX.

   CLEAR: GT_CONTROL.
   REFRESH : G_TEXTTYPES, G_TEXTLINES.

   READ TABLE GT_CONTROL WITH KEY OBJECT = P_TEXTOBJECT.
   L_SUBRC_OBJ = SY-SUBRC.
   L_TABIX_OBJ = SY-TABIX.

   IF L_SUBRC_OBJ EQ 0.
     G_TEXTTYPES[] = GT_CONTROL-TEXTTYPES[].
     READ TABLE G_TEXTTYPES WITH KEY TDID = P_TEXTID.
     L_SUBRC_ID = SY-SUBRC.
     L_TABIX_ID = SY-TABIX.
   ELSE.
     L_SUBRC_ID = L_SUBRC_OBJ.
     L_TABIX_ID = L_TABIX_OBJ.
   ENDIF.

   GT_CONTROL-OBJECT = P_TEXTOBJECT.

   GT_CONTROL-EDITOR_TYPE   = C_TEXTEDIT.
   GT_CONTROL-DYNNR         = P_SCREEN.
   GT_CONTROL-CURRENT_NODE  = P_TEXTID.
   GT_CONTROL-PREVIOUS_NODE = P_TEXTID.

   G_TEXTTYPES-TDOBJECT    = P_TEXTOBJECT.
   G_TEXTTYPES-TDID        = P_TEXTID.
   G_TEXTTYPES-TDTEXT      = P_TEXTID.
   G_TEXTTYPES-TEXTFLAG    = SPACE.
   G_TEXTTYPES-FIXIE       = SPACE.
   G_TEXTTYPES-SOURCE      = SPACE.

   CASE G_MODE.
     WHEN C_CHARC OR C_CHARM OR C_CHARY.
       CLEAR: G_TEXTTYPES-DISPLAYMODE.
     WHEN OTHERS.
       G_TEXTTYPES-DISPLAYMODE = C_TRUE.
   ENDCASE.
*   IF NOT ( sy-tcode EQ c_display OR
*            sy-tcode EQ c_delete  ).
*     CLEAR: g_texttypes-displaymode.
*   ELSE.
*     g_texttypes-displaymode = c_true.
*   ENDIF.
*
   IF L_SUBRC_ID EQ 0.
     MODIFY G_TEXTTYPES INDEX L_TABIX_ID.
   ELSE.
     APPEND G_TEXTTYPES.
   ENDIF.

   LOOP AT PT_ZTITLC2 WHERE LCITY EQ P_TEXTID.
     MOVE: PT_ZTITLC2-LTEXT     TO G_TEXTLINES-TDLINE,
           '*'                  TO G_TEXTLINES-TDFORMAT,
           P_TEXTOBJECT         TO G_TEXTLINES-TDOBJECT,
           P_TEXTID             TO G_TEXTLINES-TDID.
     APPEND G_TEXTLINES.
   ENDLOOP.

   GT_CONTROL-TEXTTYPES[] = G_TEXTTYPES[].
   GT_CONTROL-TEXTLINES[] = G_TEXTLINES[].

   IF L_SUBRC_OBJ EQ 0.
     MODIFY GT_CONTROL INDEX L_TABIX_OBJ.
   ELSE.
     APPEND GT_CONTROL.
   ENDIF.

 ENDFORM.                    " SET_TEXTID_AND_TEXT_LC
*&---------------------------------------------------------------------*
*&      Form  set_edi_textid_and_text
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM SET_EDI_TEXTID_AND_TEXT .

   DATA: L_SCREEN LIKE SY-DYNNR.

   CASE ZTITRQK-REQTY.
     WHEN C_LC.
       SELECT *
         INTO CORRESPONDING FIELDS OF TABLE IT_DD07T
         FROM DD07T
        WHERE DOMNAME    EQ 'ZTILCITY'
          AND DDLANGUAGE EQ SY-LANGU
          AND AS4LOCAL   EQ C_CHARA.
       L_SCREEN = C_SCR2065.
       LOOP AT IT_DD07T.
         IF ZTITRQS-AMDSQ EQ C_ZERO.
*S__ 신용장 변경에 따른 수정 20181010 BY SDW
** 원본소스 주석처리
*           IF IT_DD07T-DOMVALUE_L EQ C_CHARA.
*             CONTINUE.
*           ENDIF.

           IF IT_DD07T-DOMVALUE_L EQ C_CHARA OR
              IT_DD07T-DOMVALUE_L EQ C_CHARB OR
              IT_DD07T-DOMVALUE_L EQ C_CHARC OR
              IT_DD07T-DOMVALUE_L EQ C_CHARD OR
              IT_DD07T-DOMVALUE_L EQ C_CHARE OR
              IT_DD07T-DOMVALUE_L EQ C_CHARF OR
              IT_DD07T-DOMVALUE_L EQ C_CHARG OR
              IT_DD07T-DOMVALUE_L EQ C_CHARH OR
              IT_DD07T-DOMVALUE_L EQ C_CHARI OR
              IT_DD07T-DOMVALUE_L EQ C_CHARJ OR
              IT_DD07T-DOMVALUE_L EQ C_CHARK OR
              IT_DD07T-DOMVALUE_L EQ C_CHARL OR
              IT_DD07T-DOMVALUE_L EQ C_CHARM.
             CONTINUE.
           ENDIF.

*E__ 신용장 변경에 따른 수정 20181010 BY SDW
         ELSE.

*S__ 신용장 변경에 따른 수정 20181010 BY SDW
** 원본소스 주석처리
*           IF IT_DD07T-DOMVALUE_L NE C_CHARA.
**           IF not ( it_dd07t-domvalue_l eq c_chara or
**                    it_dd07t-domvalue_l eq c_char7 )  .
*             CONTINUE.
*           ENDIF.
           IF IT_DD07T-DOMVALUE_L NE C_CHARA AND
              IT_DD07T-DOMVALUE_L NE C_CHARB AND
              IT_DD07T-DOMVALUE_L NE C_CHARC AND
              IT_DD07T-DOMVALUE_L NE C_CHARD AND
              IT_DD07T-DOMVALUE_L NE C_CHARE AND
              IT_DD07T-DOMVALUE_L NE C_CHARF AND
              IT_DD07T-DOMVALUE_L NE C_CHARG AND
              IT_DD07T-DOMVALUE_L NE C_CHARH AND
              IT_DD07T-DOMVALUE_L NE C_CHARI AND
              IT_DD07T-DOMVALUE_L NE C_CHARJ AND
              IT_DD07T-DOMVALUE_L NE C_CHARK AND
              IT_DD07T-DOMVALUE_L NE C_CHARL AND
              IT_DD07T-DOMVALUE_L NE C_CHARM.
*           IF not ( it_dd07t-domvalue_l eq c_chara or
*                    it_dd07t-domvalue_l eq c_char7 )  .
             CONTINUE.
           ENDIF.

*E__ 신용장 변경에 따른 수정 20181010 BY SDW

         ENDIF.
         CONCATENATE C_TEXTOBJECT_EDI IT_DD07T-DOMVALUE_L
                                      INTO G_TEXTOBJ.
*S__ 신용장 변경에 따른 수정 20181010 BY SDW
* 원본소스 주석처리
*         PERFORM  SET_TEXTID_AND_TEXT_LC  TABLES XZTITLC2
*                                          USING G_TEXTOBJ
*                                                IT_DD07T-DOMVALUE_L
*                                                L_SCREEN.

*E__ 신용장 변경에 따른 수정 20181010 BY SDW

*S__ 신용장 변경에 따른 수정 20181010 BY SDW

         CASE IT_DD07T-DOMVALUE_L.
           WHEN 'A'.
             PERFORM  SET_TEXTID_AND_TEXT_LC  TABLES XZTITLC2
                                              USING G_TEXTOBJ
                                                    IT_DD07T-DOMVALUE_L
                                                    '2065'.
           WHEN 'B'.
             PERFORM  SET_TEXTID_AND_TEXT_LC  TABLES XZTITLC2
                                              USING G_TEXTOBJ
                                                    IT_DD07T-DOMVALUE_L
                                                    '3001'.
           WHEN 'C'.
             PERFORM  SET_TEXTID_AND_TEXT_LC  TABLES XZTITLC2
                                              USING G_TEXTOBJ
                                                    IT_DD07T-DOMVALUE_L
                                                    '3002'.
           WHEN 'D'.
             PERFORM  SET_TEXTID_AND_TEXT_LC  TABLES XZTITLC2
                                              USING G_TEXTOBJ
                                                    IT_DD07T-DOMVALUE_L
                                                    '3003'.
           WHEN 'E'.
             PERFORM  SET_TEXTID_AND_TEXT_LC  TABLES XZTITLC2
                                              USING G_TEXTOBJ
                                                    IT_DD07T-DOMVALUE_L
                                                    '3011'.
           WHEN 'F'.
             PERFORM  SET_TEXTID_AND_TEXT_LC  TABLES XZTITLC2
                                              USING G_TEXTOBJ
                                                    IT_DD07T-DOMVALUE_L
                                                    '3012'.
           WHEN 'G'.
             PERFORM  SET_TEXTID_AND_TEXT_LC  TABLES XZTITLC2
                                              USING G_TEXTOBJ
                                                    IT_DD07T-DOMVALUE_L
                                                    '3013'.
           WHEN 'H'.
             PERFORM  SET_TEXTID_AND_TEXT_LC  TABLES XZTITLC2
                                              USING G_TEXTOBJ
                                                    IT_DD07T-DOMVALUE_L
                                                    '3021'.
           WHEN 'I'.
             PERFORM  SET_TEXTID_AND_TEXT_LC  TABLES XZTITLC2
                                              USING G_TEXTOBJ
                                                    IT_DD07T-DOMVALUE_L
                                                    '3022'.
           WHEN 'J'.
             PERFORM  SET_TEXTID_AND_TEXT_LC  TABLES XZTITLC2
                                              USING G_TEXTOBJ
                                                    IT_DD07T-DOMVALUE_L
                                                    '3023'.
           WHEN 'K'.
             PERFORM  SET_TEXTID_AND_TEXT_LC  TABLES XZTITLC2
                                              USING G_TEXTOBJ
                                                    IT_DD07T-DOMVALUE_L
                                                    '3031'.
           WHEN 'L'.
             PERFORM  SET_TEXTID_AND_TEXT_LC  TABLES XZTITLC2
                                              USING G_TEXTOBJ
                                                    IT_DD07T-DOMVALUE_L
                                                    '3032'.
           WHEN 'M'.
             PERFORM  SET_TEXTID_AND_TEXT_LC  TABLES XZTITLC2
                                              USING G_TEXTOBJ
                                                    IT_DD07T-DOMVALUE_L
                                                    '3033'.
           WHEN OTHERS.
             PERFORM  SET_TEXTID_AND_TEXT_LC  TABLES XZTITLC2
                                USING G_TEXTOBJ
                                      IT_DD07T-DOMVALUE_L
                                      L_SCREEN.
         ENDCASE.
*E__ 신용장 변경에 따른 수정 20181010 BY SDW
         ADD 1 TO L_SCREEN.
       ENDLOOP.

     WHEN OTHERS.

   ENDCASE.

 ENDFORM.                    " set_edi_textid_and_text
*&---------------------------------------------------------------------*
*&      Form  get_edi_textid_and_text
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM GET_EDI_TEXTID_AND_TEXT .

   DATA: L_QITNO LIKE ZTITLC2-QITNO.

   CASE ZTITRQK-REQTY.
     WHEN C_LC.
       SELECT *
         INTO CORRESPONDING FIELDS OF TABLE IT_DD07T
         FROM DD07T
        WHERE DOMNAME    EQ 'ZTILCITY'
          AND DDLANGUAGE EQ SY-LANGU
          AND AS4LOCAL   EQ C_CHARA.

       LOOP AT IT_DD07T.

*S__ 신용장 변경에 따른 수정 20181010 BY SDW
* 원본소스 주석처리
*         IF ZTITRQS-AMDSQ EQ C_ZERO.
*           IF IT_DD07T-DOMVALUE_L EQ C_CHARA.
*             CONTINUE.
*           ENDIF.
*         ELSE.
*           IF IT_DD07T-DOMVALUE_L NE C_CHARA.
*             CONTINUE.
*           ENDIF.
*         ENDIF.

         IF ZTITRQS-AMDSQ EQ C_ZERO.
           IF IT_DD07T-DOMVALUE_L EQ C_CHARA OR
              IT_DD07T-DOMVALUE_L EQ C_CHARB OR
              IT_DD07T-DOMVALUE_L EQ C_CHARC OR
              IT_DD07T-DOMVALUE_L EQ C_CHARD OR
              IT_DD07T-DOMVALUE_L EQ C_CHARE OR
              IT_DD07T-DOMVALUE_L EQ C_CHARF OR
              IT_DD07T-DOMVALUE_L EQ C_CHARG OR
              IT_DD07T-DOMVALUE_L EQ C_CHARH OR
              IT_DD07T-DOMVALUE_L EQ C_CHARI OR
              IT_DD07T-DOMVALUE_L EQ C_CHARJ OR
              IT_DD07T-DOMVALUE_L EQ C_CHARK OR
              IT_DD07T-DOMVALUE_L EQ C_CHARL OR
              IT_DD07T-DOMVALUE_L EQ C_CHARM.
             CONTINUE.
           ENDIF.
         ELSE.
           IF IT_DD07T-DOMVALUE_L NE C_CHARA AND
              IT_DD07T-DOMVALUE_L NE C_CHARB AND
              IT_DD07T-DOMVALUE_L NE C_CHARC AND
              IT_DD07T-DOMVALUE_L NE C_CHARD AND
              IT_DD07T-DOMVALUE_L NE C_CHARE AND
              IT_DD07T-DOMVALUE_L NE C_CHARF AND
              IT_DD07T-DOMVALUE_L NE C_CHARG AND
              IT_DD07T-DOMVALUE_L NE C_CHARH AND
              IT_DD07T-DOMVALUE_L NE C_CHARI AND
              IT_DD07T-DOMVALUE_L NE C_CHARJ AND
              IT_DD07T-DOMVALUE_L NE C_CHARK AND
              IT_DD07T-DOMVALUE_L NE C_CHARL AND
              IT_DD07T-DOMVALUE_L NE C_CHARM.
             CONTINUE.
           ENDIF.
         ENDIF.
*E__ 신용장 변경에 따른 수정 20181010 BY SDW


         CONCATENATE C_TEXTOBJECT_EDI IT_DD07T-DOMVALUE_L
                                      INTO G_TEXTOBJ.
         CASE IT_DD07T-DOMVALUE_L.
*> 상품명세(TEXT)-상품명/수량/금액
           WHEN C_CHAR7.
             REFRESH: G_TC_2211_ITAB.
*> 기타부가조건(TEXT)
           WHEN C_CHAR8.
             REFRESH: G_TC_2212_ITAB.
*> Other Document(TEXT)
           WHEN C_CHAR9.
             REFRESH: G_TC_2213_ITAB.
*> 기타조건변경사항(TEXT)
           WHEN C_CHARA.
             REFRESH: G_TC_2216_ITAB.

*S__ 신용장 변경에 따른 수정 20181010 BY SDW
*> 기타조건(상품, 주요구비서류, 부가조건, 특별지급) - 생성 삭제 변경
           WHEN C_CHARB.
             REFRESH: G_TC_2216_ITAB_1_1.
           WHEN C_CHARC.
             REFRESH: G_TC_2216_ITAB_1_2.
           WHEN C_CHARD.
             REFRESH: G_TC_2216_ITAB_1_3.
           WHEN C_CHARE.
             REFRESH: G_TC_2216_ITAB_2_1.
           WHEN C_CHARF.
             REFRESH: G_TC_2216_ITAB_2_2.
           WHEN C_CHARG.
             REFRESH: G_TC_2216_ITAB_2_3.
           WHEN C_CHARH.
             REFRESH: G_TC_2216_ITAB_3_1.
           WHEN C_CHARI.
             REFRESH: G_TC_2216_ITAB_3_2.
           WHEN C_CHARJ.
             REFRESH: G_TC_2216_ITAB_3_3.
           WHEN C_CHARK.
             REFRESH: G_TC_2216_ITAB_4_1.
           WHEN C_CHARL.
             REFRESH: G_TC_2216_ITAB_4_2.
           WHEN C_CHARM.
             REFRESH: G_TC_2216_ITAB_4_3.
*E__ 신용장 변경에 따른 수정 20181010 BY SDW
         ENDCASE.

         READ TABLE GT_CONTROL WITH KEY OBJECT = G_TEXTOBJ.
         IF SY-SUBRC EQ 0.
           G_TEXTLINES[] = GT_CONTROL-TEXTLINES[].
           CLEAR: L_QITNO.
           LOOP AT G_TEXTLINES WHERE TDID EQ IT_DD07T-DOMVALUE_L.
             ADD 1 TO L_QITNO.
             CASE IT_DD07T-DOMVALUE_L.
*> 상품명세(TEXT)-상품명/수량/금액
               WHEN C_CHAR7.
                 CLEAR: G_TC_2211_WA.
                 MOVE: L_QITNO            TO  G_TC_2211_WA-QITNO,
                       G_TEXTLINES-TDLINE TO  G_TC_2211_WA-LTEXT.

                 APPEND G_TC_2211_WA TO G_TC_2211_ITAB.
*> 기타부가조건(TEXT)
               WHEN C_CHAR8.
                 CLEAR: G_TC_2212_WA.
                 MOVE: L_QITNO            TO  G_TC_2212_WA-QITNO,
                       G_TEXTLINES-TDLINE TO  G_TC_2212_WA-LTEXT.
                 APPEND G_TC_2212_WA TO G_TC_2212_ITAB.
*> Other Document(TEXT)
               WHEN C_CHAR9.
                 CLEAR: G_TC_2213_WA.
                 MOVE: L_QITNO            TO  G_TC_2213_WA-QITNO,
                       G_TEXTLINES-TDLINE TO  G_TC_2213_WA-LTEXT.
                 APPEND G_TC_2213_WA TO G_TC_2213_ITAB.
*> 기타조건변경사항(TEXT)
               WHEN C_CHARA.
                 CLEAR: G_TC_2216_WA.
                 MOVE: L_QITNO            TO  G_TC_2216_WA-QITNO,
                       G_TEXTLINES-TDLINE TO  G_TC_2216_WA-LTEXT.
                 APPEND G_TC_2216_WA TO G_TC_2216_ITAB.

*S__ 신용장 변경에 따른 수정 20181010 BY SDW
*> 기타조건(상품, 주요구비서류, 부가조건, 특별지급) - 생성 삭제 변경
               WHEN C_CHARB.
                 CLEAR: G_TC_2216_WA_1_1.
                 MOVE: L_QITNO            TO  G_TC_2216_WA_1_1-QITNO,
                       G_TEXTLINES-TDLINE TO  G_TC_2216_WA_1_1-LTEXT.
                 APPEND G_TC_2216_WA_1_1 TO G_TC_2216_ITAB_1_1.

               WHEN C_CHARC.
                 CLEAR: G_TC_2216_WA_1_2.
                 MOVE: L_QITNO            TO  G_TC_2216_WA_1_2-QITNO,
                       G_TEXTLINES-TDLINE TO  G_TC_2216_WA_1_2-LTEXT.
                 APPEND G_TC_2216_WA_1_2 TO G_TC_2216_ITAB_1_2.

               WHEN C_CHARD.
                 CLEAR: G_TC_2216_WA_1_3.
                 MOVE: L_QITNO            TO  G_TC_2216_WA_1_3-QITNO,
                       G_TEXTLINES-TDLINE TO  G_TC_2216_WA_1_3-LTEXT.
                 APPEND G_TC_2216_WA_1_3 TO G_TC_2216_ITAB_1_3.

               WHEN C_CHARE.
                 CLEAR: G_TC_2216_WA_2_1.
                 MOVE: L_QITNO            TO  G_TC_2216_WA_2_1-QITNO,
                       G_TEXTLINES-TDLINE TO  G_TC_2216_WA_2_1-LTEXT.
                 APPEND G_TC_2216_WA_2_1 TO G_TC_2216_ITAB_2_1.

               WHEN C_CHARF.
                 CLEAR: G_TC_2216_WA_2_2.
                 MOVE: L_QITNO            TO  G_TC_2216_WA_2_2-QITNO,
                       G_TEXTLINES-TDLINE TO  G_TC_2216_WA_2_2-LTEXT.
                 APPEND G_TC_2216_WA_2_2 TO G_TC_2216_ITAB_2_2.

               WHEN C_CHARG.
                 CLEAR: G_TC_2216_WA_2_3.
                 MOVE: L_QITNO            TO  G_TC_2216_WA_2_3-QITNO,
                       G_TEXTLINES-TDLINE TO  G_TC_2216_WA_2_3-LTEXT.
                 APPEND G_TC_2216_WA_2_3 TO G_TC_2216_ITAB_2_3.

               WHEN C_CHARH.
                 CLEAR: G_TC_2216_WA_3_1.
                 MOVE: L_QITNO            TO  G_TC_2216_WA_3_1-QITNO,
                       G_TEXTLINES-TDLINE TO  G_TC_2216_WA_3_1-LTEXT.
                 APPEND G_TC_2216_WA_3_1 TO G_TC_2216_ITAB_3_1.

               WHEN C_CHARI.
                 CLEAR: G_TC_2216_WA_3_2.
                 MOVE: L_QITNO            TO  G_TC_2216_WA_3_2-QITNO,
                       G_TEXTLINES-TDLINE TO  G_TC_2216_WA_3_2-LTEXT.
                 APPEND G_TC_2216_WA_3_2 TO G_TC_2216_ITAB_3_2.

               WHEN C_CHARJ.
                 CLEAR: G_TC_2216_WA_3_3.
                 MOVE: L_QITNO            TO  G_TC_2216_WA_3_3-QITNO,
                       G_TEXTLINES-TDLINE TO  G_TC_2216_WA_3_3-LTEXT.
                 APPEND G_TC_2216_WA_3_3 TO G_TC_2216_ITAB_3_3.

               WHEN C_CHARK.
                 CLEAR: G_TC_2216_WA_4_1.
                 MOVE: L_QITNO            TO  G_TC_2216_WA_4_1-QITNO,
                       G_TEXTLINES-TDLINE TO  G_TC_2216_WA_4_1-LTEXT.
                 APPEND G_TC_2216_WA_4_1 TO G_TC_2216_ITAB_4_1.

               WHEN C_CHARL.
                 CLEAR: G_TC_2216_WA_4_2.
                 MOVE: L_QITNO            TO  G_TC_2216_WA_4_2-QITNO,
                       G_TEXTLINES-TDLINE TO  G_TC_2216_WA_4_2-LTEXT.
                 APPEND G_TC_2216_WA_4_2 TO G_TC_2216_ITAB_4_2.

               WHEN C_CHARM.
                 CLEAR: G_TC_2216_WA_4_3.
                 MOVE: L_QITNO            TO  G_TC_2216_WA_4_3-QITNO,
                       G_TEXTLINES-TDLINE TO  G_TC_2216_WA_4_3-LTEXT.
                 APPEND G_TC_2216_WA_4_3 TO G_TC_2216_ITAB_4_3.

*E__ 신용장 변경에 따른 수정 20181010 BY SDW

             ENDCASE.
           ENDLOOP.
         ENDIF.
       ENDLOOP.
     WHEN OTHERS.

   ENDCASE.

 ENDFORM.                    " get_edi_textid_and_text
*&---------------------------------------------------------------------*
*&      Form  payord_data_move
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
 FORM PAYORD_DATA_MOVE .

   IF ZTITRQK-REQTY EQ 'TT'.
     ZTITTT1-TBBAD3 = ZTITTT1-TBBCD.
   ENDIF.

 ENDFORM.                    " payord_data_move
*&---------------------------------------------------------------------*
*&      Form  check_type_of_request
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
 FORM CHECK_TYPE_OF_REQUEST .

*> 수입의뢰 종류가 변경된 경우.
   IF ZTISSCRCOM-REQTY NE ZTITRQK-REQTY.
     ZTISSCRCOM-REQTY = ZTITRQK-REQTY.
     IF ZTITRQK-REQTY EQ C_TT.
       READ TABLE IT_TAB INTO G_TC_2130_WA INDEX 1.
       IF SY-SUBRC EQ 0.
         IF G_TC_2130_WA-IBLNO IS INITIAL.
           ZTITRQK-ANBTY = C_CHARB.
         ELSE.
           ZTITRQK-ANBTY = C_CHARA.
         ENDIF.
       ENDIF.
     ENDIF.
*----  >>  Begin of Loop.
     LOOP AT IT_TAB INTO G_TC_2130_WA.
       IF ZTITRQK-REQTY EQ C_LC.
         SELECT  SUM( RQMNG ) SUM( NETWR )
           INTO (G_TC_2130_WA-RQMNGS, G_TC_2130_WA-RQAMTS)
           FROM ZTIVRQ00
          WHERE  EBELN  = G_TC_2130_WA-EBELN
            AND  EBELP  = G_TC_2130_WA-EBELP
            AND NOT ( REQNO  = G_TC_2130_WA-REQNO
            AND       REQIT  = G_TC_2130_WA-REQIT )
            AND  PPAID  NE C_TRUE
            AND  RPAID  EQ C_FALSE .
         G_TC_2130_WA-RQMNGL = G_TC_2130_WA-MENGE -
                              G_TC_2130_WA-RQMNGS.
*         IF g_tc_2130_wa-rqmngl GT g_tc_2130_wa-rqmng.
         G_TC_2130_WA-RQMNG = G_TC_2130_WA-RQMNGL.
*         ENDIF.
         SELECT  SUM( RQMNG ) SUM( NETWR )
           INTO (G_TC_2130_WA-PPMNG, G_TC_2130_WA-PPAMT)
           FROM ZTIVRQ00
          WHERE  EBELN  = G_TC_2130_WA-EBELN
            AND  EBELP  = G_TC_2130_WA-EBELP
            AND NOT ( REQNO  = G_TC_2130_WA-REQNO
            AND       REQIT  = G_TC_2130_WA-REQIT )
            AND  PPAID  EQ C_TRUE.
       ELSE.
         SELECT  SUM( RQMNG ) SUM( NETWR )
           INTO (G_TC_2130_WA-RQMNGS, G_TC_2130_WA-RQAMTS)
           FROM ZTIVRQ00
          WHERE  EBELN  = G_TC_2130_WA-EBELN
            AND  EBELP  = G_TC_2130_WA-EBELP
            AND NOT ( REQNO  = G_TC_2130_WA-REQNO
            AND       REQIT  = G_TC_2130_WA-REQIT ).

         G_TC_2130_WA-RQMNGL = G_TC_2130_WA-MENGE -
                              G_TC_2130_WA-RQMNGS.
*         IF g_tc_2130_wa-rqmngl GT g_tc_2130_wa-rqmng.
         G_TC_2130_WA-RQMNG = G_TC_2130_WA-RQMNGL.
*         ENDIF.
         CLEAR: G_TC_2130_WA-PPMNG, G_TC_2130_WA-PPAMT.
       ENDIF.
       G_TC_2130_WA-NETWR = G_TC_2130_WA-POAMT - G_TC_2130_WA-RQAMTS.

       MODIFY IT_TAB FROM G_TC_2130_WA.
     ENDLOOP.
*----  >>  End of Loop.
     CLEAR : ZTITRQK-PPAID, ZTITRQK-RPAID.
   ENDIF.

 ENDFORM.                    " check_type_of_request
*&---------------------------------------------------------------------*
*&      Form  get_vendor_bank
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
 FORM GET_VENDOR_BANK .

 ENDFORM.                    " get_vendor_bank
*&---------------------------------------------------------------------*
*&      Form  set_remittance_bank
*&---------------------------------------------------------------------*
*       전신환 송금일 경우, 은행정보 Setting.
*----------------------------------------------------------------------*
 FORM SET_REMITTANCE_BANK .
   DATA: LV_BNFA LIKE ZTITIG00-BNFA.

   CHECK ZTITRQK-REQTY EQ C_TT.

   IF NOT ZTITRQK-LIFNR IS INITIAL.
***********************************************************************
* 회사별 프로세스 정의 개설요청 수취인거래은행 관리여부 => x
* 수취인 관리계좌내역에서 테이터를 QUERY
***********************************************************************
     SELECT SINGLE BNFA
      INTO LV_BNFA
      FROM ZTITIG00
     WHERE BUKRS EQ ZTITRQK-BUKRS.

***********************************************************************
* 관리하지 않을 경우
***********************************************************************
     IF LV_BNFA NE 'X'.

       SELECT *
         FROM LFBK UP TO 1 ROWS
        WHERE LIFNR EQ ZTITRQK-LIFNR.
       ENDSELECT.
       IF SY-SUBRC EQ 0.
         SELECT SINGLE *
           FROM BNKA
          WHERE BANKS EQ LFBK-BANKS
            AND BANKL EQ LFBK-BANKL.
         IF SY-SUBRC EQ 0.
           MOVE: BNKA-BANKA TO ZTITTT1-TBBNM,  ">은행명.
*               bnka-ort01 TO ztittt1-tbbad1,                ">주소1.
*               bnka-stras TO ztittt1-tbbad2.                ">주소2.
***********************************************************************
* 20070711 simcho by 박혁세K
***********************************************************************
                 BNKA-ORT01 TO ZTITTT1-TBBAD2,              ">주소2.
                 BNKA-STRAS TO ZTITTT1-TBBAD1,              ">주소1.
                 BNKA-SWIFT TO ZTITTT1-TBBAD3.        ">[=은행 코드]
***********************************************************************

         ENDIF.
         MOVE: LFBK-BANKN TO ZTITTT1-TBBAN.  ">계좌번호.
*             lfbk-bankl TO ztittt1-tbbad3. ">[=은행 코드]
       ENDIF.

***********************************************************************
* 관리할 경우
***********************************************************************
     ELSE.
       SELECT SINGLE *
         FROM ZTITIG04
        WHERE BUKRS EQ ZTITRQK-BUKRS
          AND LIFNR EQ ZTITRQK-LIFNR
          AND WAERS EQ ZTITRQS-WAERS
          AND APVYN EQ 'B'.

       IF SY-SUBRC EQ 0.
         MOVE : ZTITIG04-TBBNM  TO ZTITTT1-TBBNM,
                ZTITIG04-TBBBR  TO ZTITTT1-TBBAD1,
                ZTITIG04-TBBAD2 TO ZTITTT1-TBBAD2,
                ZTITIG04-TBBAD3 TO ZTITTT1-TBBAD3,
                ZTITIG04-TBBAN  TO ZTITTT1-TBBAN,
                ZTITIG04-TBBAM  TO ZTITTT1-TBBAM.

         IF NOT ZTITIG04-TIBNM IS INITIAL.
           MOVE : ZTITIG04-TIBNM  TO ZTITTT1-TIBNM,
                  ZTITIG04-TIBBR  TO ZTITTT1-TIBBR,
                  ZTITIG04-TIBAN  TO ZTITTT1-TIBAN,
                  ZTITRQS-WAERS   TO ZTITTT1-TIBAC.
*-{기능개선 186110 - 경유은행 SWIFT 코드 추가
           IF ZTITRQK-BUKRS = '1000' OR ZTITRQK-BUKRS = '5000'.
             MOVE : ZTITIG04-TIBAM  TO ZTITTT1-TIBCD.
           ENDIF.
*-}기능개선 186110
         ENDIF.
       ELSE.
         MESSAGE E997 WITH ZTITRQK-LIFNR ZTITRQS-WAERS
                        '에 등록된 계좌가 없습니다.'.
       ENDIF.
     ENDIF.
***********************************************************************

   ENDIF.

 ENDFORM.                    " set_remittance_bank
*&---------------------------------------------------------------------*
*&      Form  edi_data_sending
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
 FORM EDI_DATA_SENDING .

   DATA: L_IMEXI TYPE C,
         L_DOCNO TYPE CHAR10,
         L_AMDSQ TYPE NUMC2,
         L_DOCTY TYPE ZTSTEDIS-EDITY,
         L_SNCNT TYPE ZTSTEDIS-SNCNT.

   CASE ZTSTIG0-FNAME.
     WHEN 'L'.    ">LG CNS VAN I/F
       CASE G_DOCUMENT.
         WHEN C_IP.
           IF ZTSTIG0-LGIPI EQ C_TRUE.
*>[TraSys] LG 화재 VAN용 OutBound 공통모듈 .
             G_EDI_FUNC = 'Z_TD_APPLICATION_TO_LGINSURE'.
           ELSE.
*>[TraSys] LG CNS VAN용 OutBound 공통모듈 .
             G_EDI_FUNC = 'Z_TD_EDI_OUTBOUND_FOR_LGCNS'.
           ENDIF.
         WHEN OTHERS.
*>[TraSys] LG CNS VAN용 OutBound 공통모듈 .
           G_EDI_FUNC = 'Z_TD_EDI_OUTBOUND_FOR_LGCNS'.
       ENDCASE.
     WHEN 'R'.   ">Ready Korea Package I/F
       CASE G_DOCUMENT.
         WHEN C_IP.
           IF ZTSTIG0-LGIPI EQ C_TRUE.
*>[TraSys] LG 화재 VAN용 OutBound 공통모듈 .
             G_EDI_FUNC = 'Z_TD_APPLICATION_TO_LGINSURE'.
           ELSE.
*>[TraSys] LG CNS VAN용 OutBound 공통모듈 .
             G_EDI_FUNC = 'Z_TD_EDI_OUTBOUND_FOR_RK'.
           ENDIF.
         WHEN OTHERS.
*>[TraSys] 레디코리아용 OutBound 공통모듈 .
           G_EDI_FUNC = 'Z_TD_EDI_OUTBOUND_FOR_RK'.
       ENDCASE.
     WHEN OTHERS.
       EXIT.
   ENDCASE.

**>[TraSys] LG 화재 VAN용 OutBound 공통모듈 .
*   IF ztstig0-lgipi EQ c_true AND
*      g_document    EQ c_ip.
*     g_edi_func = 'Z_TD_EDI_OUTBOUND_FOR_LGCNS'.
*   ENDIF.

*> 수출입 구분.
   L_IMEXI = C_CHARI.

   CASE G_DOCUMENT.
     WHEN C_LC.
       L_SNCNT  =  ZTITRQS-SNCNT.
       L_DOCNO  =  ZTITRQS-REQNO.
       L_AMDSQ  =  ZTITRQS-AMDSQ.
     WHEN C_IP.
       L_SNCNT  =  ZTITIP1-SNCNT.
       L_DOCNO  =  ZTITIP1-IIPNO.
       L_AMDSQ  =  ZTITIP1-AMDSQ.
     WHEN C_CR.
       L_SNCNT  =  ZTITCRK-SNCNT.
       L_DOCNO  =  ZTITCRK-ICCNO.
       L_AMDSQ  =  ZTITCRK-ICCSQ.
     WHEN C_LG.
       L_SNCNT  =  ZTITLG1-SNCNT.
       L_DOCNO  =  ZTITLG1-ILGNO.
       CLEAR: L_AMDSQ.
     WHEN OTHERS.
       CLEAR: L_SNCNT, L_DOCNO, L_AMDSQ.
   ENDCASE.

   SELECT SINGLE *
     FROM ZTSTEDIS
    WHERE SNCNT  EQ  ZTITRQS-SNCNT.
   IF SY-SUBRC EQ 0.
     L_DOCTY = ZTSTEDIS-EDITY.
   ENDIF.

*> EDI Sending.

   CALL FUNCTION G_EDI_FUNC
     EXPORTING
       IM_IMEXI    = L_IMEXI
       IM_DOCTY    = L_DOCTY
       IM_DOCNO    = L_DOCNO
       IM_SEQNO    = L_AMDSQ
       IM_ZTSTEDIS = ZTSTEDIS
       IM_ZTSTIG0  = ZTSTIG0
     IMPORTING
       EX_SUBRC    = G_SUBRC
       EX_ZTSTEDIS = ZTSTEDIS.

   IF SY-SUBRC EQ 0.
     IF ZTITRQK-REQTY EQ 'TT' AND
        ZTITRQK-ANBTY EQ 'A'.    ">사후송금일 경우.

       ZTSTEDIS-EDITY = 'APPCOP2BP'.
       L_DOCTY        = 'APPCOP2BP'.
       CALL FUNCTION G_EDI_FUNC
         EXPORTING
           IM_IMEXI    = L_IMEXI
           IM_DOCTY    = L_DOCTY
           IM_DOCNO    = L_DOCNO
           IM_SEQNO    = L_AMDSQ
           IM_ZTSTEDIS = ZTSTEDIS
           IM_ZTSTIG0  = ZTSTIG0
         IMPORTING
           EX_SUBRC    = G_SUBRC
           EX_ZTSTEDIS = ZTSTEDIS.
     ENDIF.
     IF G_SUBRC EQ 0.
       MESSAGE S040.
     ELSE.
       MESSAGE S041.
     ENDIF.
   ELSE.
     MESSAGE S041.
   ENDIF.

 ENDFORM.                    " edi_data_sending
*&---------------------------------------------------------------------*
*&      Form  set_genres_default_value
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
 FORM SET_GENRES_DEFAULT_VALUE .

 ENDFORM.                    " set_genres_default_value
*&---------------------------------------------------------------------*
*&      Form  set_default_data
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
 FORM SET_DEFAULT_DATA .

   CASE ZTITRQK-REQTY.
     WHEN C_LC.
     WHEN C_LO.
*> 신용장 종류.
       IF ZTITLO1-LLCTY IS INITIAL.
         IF ZTITRQS-WAERS EQ T001-WAERS.
           ZTITLO1-LLCTY = '2AC'.
         ELSE.
           ZTITLO1-LLCTY = '2AA'.
         ENDIF.
       ENDIF.
*>개설근거별용도
       IF ZTITLO1-LOPME IS INITIAL.
         ZTITLO1-LOPME = '2AD'.
       ENDIF.
     WHEN C_TT.
*> 선급금 필드.
       IF ZTITRQK-PPAID IS INITIAL.
         ZTITRQK-PPAID = 'N'.
       ENDIF.

       IF ZTITTT1-TPYFN IS INITIAL.    "지급지시서용도
         IF ZTITRQS-WAERS EQ T001-WAERS.
           ZTITTT1-TPYFN = '2AN'.
         ELSE.
           ZTITTT1-TPYFN = '2AM'.
         ENDIF.
       ENDIF.
       IF ZTITTT1-TSTCD IS INITIAL.    "수수료부담자.
         ZTITTT1-TSTCD = '14'.
       ENDIF.

   ENDCASE.

 ENDFORM.                    " set_default_data
*&---------------------------------------------------------------------*
*&      Form  SET_PORT_CODE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM SET_PORT_CODE .

   IF ZTITRQS-FLAND IS INITIAL.  ">선적국가.
     PERFORM NO_INPUT_CHECK USING 'ZTITRQS' 'FLAND' C_ERROR.
   ENDIF.
   IF ZTITRQS-FPORT IS INITIAL.  ">선적항.
     PERFORM NO_INPUT_CHECK USING 'ZTITRQS' 'FPORT' C_ERROR.
   ELSE.
     SELECT SINGLE *
       FROM ZTSTIGP
      WHERE LAND1   EQ  ZTITRQS-FLAND
        AND PORTC   EQ  ZTITRQS-FPORT.
     IF SY-SUBRC NE 0.
       SET CURSOR FIELD 'ZTITRQS-FPORT'.
       MESSAGE E120 WITH ZTITRQS-FLAND ZTITRQS-FPORT.
     ENDIF.
   ENDIF.

* 20060703 SIMCHO BY C2006062601000000323
* 선적항 변경시 text 반드시 변경되도록 수정
*   IF ztitrqs-pllod IS INITIAL.  ">선적항명.
*     MOVE ztstigp-porte TO ztitrqs-pllod.
*   ENDIF.
   IF ZTITRQS-PLLOD IS INITIAL.  ">선적항명.
     MOVE ZTSTIGP-PORTE TO ZTITRQS-PLLOD.
   ELSE.
*     MOVE ztstigp-porte TO ztitrqs-pllod.
   ENDIF.
* END SIMCHO BY C2006062601000000323

   IF ZTITRQS-TLAND IS INITIAL.  ">도착국가.
     MOVE: T001-LAND1  TO ZTITRQS-TLAND .
   ENDIF.
   IF ZTITRQS-TPORT IS INITIAL.  ">도착항.
     MOVE: 'PUS'  TO ZTITRQS-TPORT .
   ENDIF.

   SELECT SINGLE PORTE
     INTO ZTSTIGP-PORTE
     FROM ZTSTIGP
    WHERE LAND1   EQ  ZTITRQS-TLAND
      AND PORTC   EQ  ZTITRQS-TPORT.
   IF SY-SUBRC NE 0.
     SET CURSOR FIELD 'ZTITRQS-TPORT'.
     MESSAGE E120 WITH ZTITRQS-TLAND ZTITRQS-TPORT.
   ENDIF.

* 20060703 SIMCHO BY C2006062601000000323
* 선적항 변경시 text 반드시 변경되도록 수정
*   IF ztitrqs-pltrn IS INITIAL.  ">선적항명.
*     MOVE ztstigp-porte TO ztitrqs-pltrn.
*   ENDIF.
   IF ZTITRQS-PLTRN IS INITIAL.  ">선적항명.
     MOVE ZTSTIGP-PORTE TO ZTITRQS-PLTRN.
   ELSE.
*     MOVE ztstigp-porte TO ztitrqs-pltrn.
   ENDIF.
* END SIMCHO BY C2006062601000000323

 ENDFORM.                    " SET_PORT_CODE
*&---------------------------------------------------------------------*
*&      Form  check_request_release
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM CHECK_REQUEST_RELEASE .

*> 수입요청 승인을 관리할 경우...
   IF ZTITIG00-RQRLS EQ 'X'.
     CASE G_MODE.
       WHEN 'M' OR 'D'.
         IF ZTITRQS-RQRLS EQ 'X'.
           MESSAGE E168 WITH ZTITRQS-REQNO ZTITRQS-AMDSQ.
         ENDIF.
       WHEN 'A'.
         IF ZTITRQS-RQRLS NE 'X'.
           MESSAGE E169 WITH ZTITRQS-REQNO ZTITRQS-AMDSQ.
         ENDIF.
*        WHEN 'Y' OR 'O' OR 'G' OR 'P' OR 'R' OR '0'.
*          IF ztitrqs-rqrls NE 'X'.
*            MESSAGE e169 WITH ztitrqs-reqno ztitrqs-amdsq.
*          ENDIF.
       WHEN OTHERS.
     ENDCASE.
   ENDIF.

 ENDFORM.                    " check_request_release
*&---------------------------------------------------------------------*
*&      Form  set_local_date
*&---------------------------------------------------------------------*
*_--> LS 전선 요청사항. ( By SB, Kang )
*     최종선적일을 개설요청일 + 60일
*     유효기일 = 최종선적일 + 9
*----------------------------------------------------------------------*
 FORM SET_LOCAL_DATE  USING    P_DATE  P_MESSAGE.

   DATA : L_LSDAT LIKE SY-DATLO,
          L_EXDAT LIKE SY-DATLO.

   CHECK NOT P_DATE IS INITIAL.

   L_LSDAT = P_DATE + 60.
   L_EXDAT = L_LSDAT + 9.

   IF P_MESSAGE EQ 'X'.
     IF L_EXDAT <> ZTITRQS-EXDAT OR
        L_LSDAT <> ZTITRQS-LSDAT.
       MESSAGE I049.
     ENDIF.
   ENDIF.

   ZTITRQS-LSDAT = L_LSDAT.
   ZTITRQS-EXDAT = L_EXDAT.

 ENDFORM.                    " set_local_date
*&---------------------------------------------------------------------*
*&      Form  get_authorization_bukrs
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM GET_AUTHORIZATION_BUKRS .

   PERFORM INIT_AUTHORIZATION_CHECK USING A_BUKRS
                                 CHANGING A_BUKRS.

 ENDFORM.                    " get_authorization_bukrs
*&---------------------------------------------------------------------*
*&      Form  GET_RECNO
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM GET_RECNO .

   DATA : LV_RECNO_CON LIKE ZTITRQS-RECNO,
          LV_RECNO_MAX LIKE ZTITRQS-RECNO,
          LV_NUMC(3)   TYPE C.

   CLEAR : LV_RECNO_CON, LV_RECNO_MAX, LV_NUMC.

*   IF ztitrqs-reqno IS INITIAL.
   IF ZTITRQK-BUKRS EQ '1000'.
     CONCATENATE 'LOCAPP' 'LOVE8888-'
     ZTSTIG3-IBKCD(2) ZTITRQS-SNDDT+2(6) '%'
     INTO LV_RECNO_CON.
     "테이블 LOCK
     CALL FUNCTION 'ENQUEUE_EZ_ZTITI01'
       EXPORTING
         MODE_ZTITRQS = 'E'
*        MANDT        = SY-MANDT
*        REQNO        = ztitrqs-reqno
*        X_REQNO      = ' '
*        _SCOPE       = '2'
*        _WAIT        = ' '
*        _COLLECT     = ' '
*      EXCEPTIONS
*        FOREIGN_LOCK = 1
*        SYSTEM_FAILURE       = 2
*        OTHERS       = 3
       .
     IF SY-SUBRC <> 0.
       MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
     ELSE.

       SELECT SINGLE MAX( RECNO )
        INTO LV_RECNO_MAX
        FROM ZTITRQS
         WHERE RECNO LIKE LV_RECNO_CON.
       IF LV_RECNO_MAX IS NOT INITIAL.
         LV_NUMC = LV_RECNO_MAX+25(3) + '001'.
         CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
           EXPORTING
             INPUT  = LV_NUMC
           IMPORTING
             OUTPUT = LV_NUMC.
         CONCATENATE 'LOCAPP' 'LOVE8888-'
         ZTSTIG3-IBKCD(2) ZTITRQS-SNDDT+2(6) LV_NUMC
         INTO GV_RECNO.
       ELSE.
         LV_NUMC = '001'.
         CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
           EXPORTING
             INPUT  = LV_NUMC
           IMPORTING
             OUTPUT = LV_NUMC.
         CONCATENATE 'LOCAPP' 'LOVE8888-'
         ZTSTIG3-IBKCD(2) ZTITRQS-SNDDT+2(6) LV_NUMC
         INTO GV_RECNO.
       ENDIF.
     ENDIF.

   ELSEIF ZTITRQK-BUKRS EQ '3000'.
     CONCATENATE 'LOCAPP' 'LSM9123-'
     ZTSTIG3-IBKCD(2) ZTITRQS-SNDDT+2(6) '%'
     INTO LV_RECNO_CON.

     "테이블 LOCK
     CALL FUNCTION 'ENQUEUE_EZ_ZTITI01'
       EXPORTING
         MODE_ZTITRQS = 'E'
*        MANDT        = SY-MANDT
*        REQNO        = ztitrqs-reqno
*        X_REQNO      = ' '
*        _SCOPE       = '2'
*        _WAIT        = ' '
*        _COLLECT     = ' '
*      EXCEPTIONS
*        FOREIGN_LOCK = 1
*        SYSTEM_FAILURE       = 2
*        OTHERS       = 3
       .

     IF SY-SUBRC <> 0.
       MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
     ELSE.

       SELECT SINGLE MAX( RECNO )
        INTO LV_RECNO_MAX
        FROM ZTITRQS
         WHERE RECNO LIKE LV_RECNO_CON.
       IF LV_RECNO_MAX IS NOT INITIAL.
         LV_NUMC = LV_RECNO_MAX+24(3) + '001'.
         CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
           EXPORTING
             INPUT  = LV_NUMC
           IMPORTING
             OUTPUT = LV_NUMC.

         CONCATENATE 'LOCAPP' 'LSM9123-'
         ZTSTIG3-IBKCD(2) ZTITRQS-SNDDT+2(6) LV_NUMC
         INTO GV_RECNO.
       ELSE.
         LV_NUMC = '001'.
         CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
           EXPORTING
             INPUT  = LV_NUMC
           IMPORTING
             OUTPUT = LV_NUMC.
         CONCATENATE 'LOCAPP' 'LSM9123-'
         ZTSTIG3-IBKCD(2) ZTITRQS-SNDDT+2(6) LV_NUMC
         INTO GV_RECNO.
       ENDIF.
     ENDIF.

   ELSEIF ZTITRQK-BUKRS EQ '5000'.   "LSEVK 추가
     CONCATENATE 'LOCAPP' 'LSEVK7-'
     ZTSTIG3-IBKCD(2) ZTITRQS-SNDDT+2(6) '%'
     INTO LV_RECNO_CON.
     "테이블 LOCK
     CALL FUNCTION 'ENQUEUE_EZ_ZTITI01'
       EXPORTING
         MODE_ZTITRQS = 'E'
*        MANDT        = SY-MANDT
*        REQNO        = ztitrqs-reqno
*        X_REQNO      = ' '
*        _SCOPE       = '2'
*        _WAIT        = ' '
*        _COLLECT     = ' '
*      EXCEPTIONS
*        FOREIGN_LOCK = 1
*        SYSTEM_FAILURE       = 2
*        OTHERS       = 3
       .
     IF SY-SUBRC <> 0.
       MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
     ELSE.

       SELECT SINGLE MAX( RECNO )
        INTO LV_RECNO_MAX
        FROM ZTITRQS
         WHERE RECNO LIKE LV_RECNO_CON.
       IF LV_RECNO_MAX IS NOT INITIAL.
         LV_NUMC = LV_RECNO_MAX+25(3) + '001'.
         CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
           EXPORTING
             INPUT  = LV_NUMC
           IMPORTING
             OUTPUT = LV_NUMC.
         CONCATENATE 'LOCAPP' 'LSEVK7-'
         ZTSTIG3-IBKCD(2) ZTITRQS-SNDDT+2(6) LV_NUMC
         INTO GV_RECNO.
       ELSE.
         LV_NUMC = '001'.
         CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
           EXPORTING
             INPUT  = LV_NUMC
           IMPORTING
             OUTPUT = LV_NUMC.
         CONCATENATE 'LOCAPP' 'LSEVK7-'
         ZTSTIG3-IBKCD(2) ZTITRQS-SNDDT+2(6) LV_NUMC
         INTO GV_RECNO.
       ENDIF.
     ENDIF.

   ELSEIF ZTITRQK-BUKRS EQ '6000'.   "가온추가
     CONCATENATE 'LOCAPP' 'GAON77-'
     ZTSTIG3-IBKCD(2) ZTITRQS-SNDDT+2(6) '%'
     INTO LV_RECNO_CON.
     "테이블 LOCK
     CALL FUNCTION 'ENQUEUE_EZ_ZTITI01'
       EXPORTING
         MODE_ZTITRQS = 'E'
*        MANDT        = SY-MANDT
*        REQNO        = ztitrqs-reqno
*        X_REQNO      = ' '
*        _SCOPE       = '2'
*        _WAIT        = ' '
*        _COLLECT     = ' '
*      EXCEPTIONS
*        FOREIGN_LOCK = 1
*        SYSTEM_FAILURE       = 2
*        OTHERS       = 3
       .
     IF SY-SUBRC <> 0.
       MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
     ELSE.

       SELECT SINGLE MAX( RECNO )
        INTO LV_RECNO_MAX
        FROM ZTITRQS
         WHERE RECNO LIKE LV_RECNO_CON.
       IF LV_RECNO_MAX IS NOT INITIAL.
         LV_NUMC = LV_RECNO_MAX+25(3) + '001'.
         CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
           EXPORTING
             INPUT  = LV_NUMC
           IMPORTING
             OUTPUT = LV_NUMC.
         CONCATENATE 'LOCAPP' 'GAON77-'
         ZTSTIG3-IBKCD(2) ZTITRQS-SNDDT+2(6) LV_NUMC
         INTO GV_RECNO.
       ELSE.
         LV_NUMC = '001'.
         CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
           EXPORTING
             INPUT  = LV_NUMC
           IMPORTING
             OUTPUT = LV_NUMC.
         CONCATENATE 'LOCAPP' 'GAON77-'
         ZTSTIG3-IBKCD(2) ZTITRQS-SNDDT+2(6) LV_NUMC
         INTO GV_RECNO.
       ENDIF.
     ENDIF.

   ENDIF.
 ENDFORM.                    " GET_RECNO
*&---------------------------------------------------------------------*
*&      Form  SET_RETURN_MESSAGE2
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_6398   text
*      -->P_6399   text
*      -->P_C_ERROR  text
*----------------------------------------------------------------------*
 FORM SET_RETURN_MESSAGE2  USING    NOI_TAB NOI_FIELD P_MSGTY.

   DATA: BEGIN OF FELD,
           TABLE(10),
           STRICH,
           NAME(10),
         END OF FELD,
         RC.

   FELD-TABLE = NOI_TAB.
   FELD-STRICH = '-'.
   CONDENSE FELD.
   SEARCH FELD FOR '-'.
   SY-FDPOS = SY-FDPOS - 1.
   WRITE '-' TO FELD+SY-FDPOS.
   SY-FDPOS = SY-FDPOS + 1.
   WRITE NOI_FIELD TO FELD+SY-FDPOS.
   IF SY-STEPL EQ 0.
     SET CURSOR FIELD FELD.
   ELSE.
     SET CURSOR FIELD FELD LINE SY-STEPL.
   ENDIF.

   PERFORM GET_FTEXT(RDDFIE00) USING NOI_TAB NOI_FIELD SY-LANGU
                               CHANGING DFIES RC.
   IF RC EQ 0.
     MESSAGE S003(ZMM1) WITH DFIES-SCRTEXT_M '은 변경 불가능합니다.'.
   ELSE.
     MESSAGE S003(ZMM1) WITH NOI_TAB NOI_FIELD '은 변경 불가능합니다.'.
   ENDIF.

   PERFORM SET_RETURN_MESSAGE_FILL USING P_MSGTY.

 ENDFORM.                    " SET_RETURN_MESSAGE2
*&---------------------------------------------------------------------*
*&      Form  SET_RETURN_MESSAGE2
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_6398   text
*      -->P_6399   text
*      -->P_C_ERROR  text
*----------------------------------------------------------------------*
 FORM SET_RETURN_MESSAGE3  USING    NOI_TAB NOI_FIELD P_MSGTY.

   DATA: BEGIN OF FELD,
           TABLE(10),
           STRICH,
           NAME(10),
         END OF FELD,
         RC.

   FELD-TABLE = NOI_TAB.
   FELD-STRICH = '-'.
   CONDENSE FELD.
   SEARCH FELD FOR '-'.
   SY-FDPOS = SY-FDPOS - 1.
   WRITE '-' TO FELD+SY-FDPOS.
   SY-FDPOS = SY-FDPOS + 1.
   WRITE NOI_FIELD TO FELD+SY-FDPOS.
   IF SY-STEPL EQ 0.
     SET CURSOR FIELD FELD.
   ELSE.
     SET CURSOR FIELD FELD LINE SY-STEPL.
   ENDIF.

   PERFORM GET_FTEXT(RDDFIE00) USING NOI_TAB NOI_FIELD SY-LANGU
                               CHANGING DFIES RC.
   IF RC EQ 0.
     MESSAGE E003(ZMM1) WITH DFIES-SCRTEXT_M '은 변경 불가능합니다.'.
   ELSE.
     MESSAGE E003(ZMM1) WITH NOI_TAB NOI_FIELD '은 변경 불가능합니다.'.
   ENDIF.

*   PERFORM SET_RETURN_MESSAGE_FILL USING P_MSGTY.

 ENDFORM.                    " SET_RETURN_MESSAGE3
*&---------------------------------------------------------------------*
*&      Form  CHECK_TEXT_EDIT_DATA
*&---------------------------------------------------------------------*
 FORM CHECK_TEXT_EDIT_DATA .

   IF ( GV_CHK_TEXT_B = 'X' OR
        GV_CHK_TEXT_C = 'X' ) AND
        GV_CHK_TEXT_D = 'X'.
     MESSAGE E997(ZMTI00) WITH
     '상품(용역)명세 변경은 (신규 및 삭제)와'
     '같이 입력할 수 없습니다.'.
   ENDIF.


   IF ( GV_CHK_TEXT_E = 'X' OR
        GV_CHK_TEXT_F = 'X' ) AND
        GV_CHK_TEXT_G = 'X'.
     MESSAGE E997(ZMTI00) WITH
     '주요구비서류 변경은 (신규 및 삭제)와'
     '같이 입력할 수 없습니다.'.
   ENDIF.

   IF ( GV_CHK_TEXT_H = 'X' OR
        GV_CHK_TEXT_I = 'X' ) AND
        GV_CHK_TEXT_J = 'X'.
     MESSAGE E997(ZMTI00) WITH
     '부가조건 변경은 (신규 및 삭제)와'
     '같이 입력할 수 없습니다.'.
   ENDIF.

   IF ( GV_CHK_TEXT_K = 'X' OR
        GV_CHK_TEXT_L = 'X' ) AND
        GV_CHK_TEXT_M = 'X'.
     MESSAGE E997(ZMTI00) WITH
     '특별지급조건 변경은 (신규 및 삭제)와'
     '같이 입력할 수 없습니다.'.
   ENDIF.

 ENDFORM.                    " CHECK_TEXT_EDIT_DATA
*&---------------------------------------------------------------------*
*&      Form  TEXT_TABLE_DATA_CLEAR
*&---------------------------------------------------------------------*
 FORM TEXT_TABLE_DATA_CLEAR .

*__ 체크하지 않은 기타텍스트 제거
   LOOP AT GT_CONTROL WHERE OBJECT+0(6) = C_TEXTOBJECT_EDI.

     CASE GT_CONTROL-OBJECT+6(1).
       WHEN 'B'.
         IF GV_CHK_TEXT_B NE 'X'.
           CLEAR : GT_CONTROL-TEXTLINES[].
         ENDIF.
       WHEN 'C'.
         IF GV_CHK_TEXT_C NE 'X'.
           CLEAR : GT_CONTROL-TEXTLINES[].
         ENDIF.
       WHEN 'D'.
         IF GV_CHK_TEXT_D NE 'X'.
           CLEAR : GT_CONTROL-TEXTLINES[].
         ENDIF.
       WHEN 'E'.
         IF GV_CHK_TEXT_E NE 'X'.
           CLEAR : GT_CONTROL-TEXTLINES[].
         ENDIF.
       WHEN 'F'.
         IF GV_CHK_TEXT_F NE 'X'.
           CLEAR : GT_CONTROL-TEXTLINES[].
         ENDIF.
       WHEN 'G'.
         IF GV_CHK_TEXT_G NE 'X'.
           CLEAR : GT_CONTROL-TEXTLINES[].
         ENDIF.
       WHEN 'H'.
         IF GV_CHK_TEXT_H NE 'X'.
           CLEAR : GT_CONTROL-TEXTLINES[].
         ENDIF.
       WHEN 'I'.
         IF GV_CHK_TEXT_I NE 'X'.
           CLEAR : GT_CONTROL-TEXTLINES[].
         ENDIF.
       WHEN 'J'.
         IF GV_CHK_TEXT_J NE 'X'.
           CLEAR : GT_CONTROL-TEXTLINES[].
         ENDIF.
       WHEN 'K'.
         IF GV_CHK_TEXT_K NE 'X'.
           CLEAR : GT_CONTROL-TEXTLINES[].
         ENDIF.
       WHEN 'L'.
         IF GV_CHK_TEXT_L NE 'X'.
           CLEAR : GT_CONTROL-TEXTLINES[].
         ENDIF.
       WHEN 'M'.
         IF GV_CHK_TEXT_M NE 'X'.
           CLEAR : GT_CONTROL-TEXTLINES[].
         ENDIF.
     ENDCASE.

   ENDLOOP.


 ENDFORM.                    " TEXT_TABLE_DATA_CLEAR
*&---------------------------------------------------------------------*
*&      Form  GET_TEXT_CHECKBOX
*&---------------------------------------------------------------------*
 FORM GET_TEXT_CHECKBOX .

   LOOP AT GT_CONTROL WHERE OBJECT+0(6) = C_TEXTOBJECT_EDI.

     CASE GT_CONTROL-OBJECT+6(1).
       WHEN 'B'.
         IF GT_CONTROL-TEXTLINES[] IS NOT INITIAL.
           GV_CHK_TEXT_B = 'X'.
         ENDIF.
       WHEN 'C'.
         IF GT_CONTROL-TEXTLINES[] IS NOT INITIAL.
           GV_CHK_TEXT_C = 'X'.
         ENDIF.
       WHEN 'D'.
         IF GT_CONTROL-TEXTLINES[] IS NOT INITIAL.
           GV_CHK_TEXT_D = 'X'.
         ENDIF.
       WHEN 'E'.
         IF GT_CONTROL-TEXTLINES[] IS NOT INITIAL.
           GV_CHK_TEXT_E = 'X'.
         ENDIF.
       WHEN 'F'.
         IF GT_CONTROL-TEXTLINES[] IS NOT INITIAL.
           GV_CHK_TEXT_F = 'X'.
         ENDIF.
       WHEN 'G'.
         IF GT_CONTROL-TEXTLINES[] IS NOT INITIAL.
           GV_CHK_TEXT_G = 'X'.
         ENDIF.
       WHEN 'H'.
         IF GT_CONTROL-TEXTLINES[] IS NOT INITIAL.
           GV_CHK_TEXT_H = 'X'.
         ENDIF.
       WHEN 'I'.
         IF GT_CONTROL-TEXTLINES[] IS NOT INITIAL.
           GV_CHK_TEXT_I = 'X'.
         ENDIF.
       WHEN 'J'.
         IF GT_CONTROL-TEXTLINES[] IS NOT INITIAL.
           GV_CHK_TEXT_J = 'X'.
         ENDIF.
       WHEN 'K'.
         IF GT_CONTROL-TEXTLINES[] IS NOT INITIAL.
           GV_CHK_TEXT_K = 'X'.
         ENDIF.
       WHEN 'L'.
         IF GT_CONTROL-TEXTLINES[] IS NOT INITIAL.
           GV_CHK_TEXT_L = 'X'.
         ENDIF.
       WHEN 'M'.
         IF GT_CONTROL-TEXTLINES[] IS NOT INITIAL.
           GV_CHK_TEXT_M = 'X'.
         ENDIF.
     ENDCASE.

   ENDLOOP.

 ENDFORM.                    " GET_TEXT_CHECKBOX
*&---------------------------------------------------------------------*
*&      Form  SEND_MAIL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM SEND_MAIL .
   DATA: LV_FLAG,
         LV_TEXT1(255),
         LV_TEXT2(255),
         LV_TEXT3(255),
         LV_STEP_TXT(15),
         LV_STEP_TXT_S(15). "메일제목

**E-MAIL
   DATA: GT_MESSAGE     TYPE BCSY_TEXT,
         GV_SEND_RESULT TYPE C,
         G_RECEIVER     TYPE REF TO IF_RECIPIENT_BCS,
         G_EMAIL        TYPE REF TO CL_BCS,
         G_EMAIL_BODY   TYPE REF TO CL_DOCUMENT_BCS,
         G_SENDER       TYPE REF TO IF_SENDER_BCS,
         G_EXCEPTION    TYPE REF TO CX_BCS,
         GV_ADDRESS     TYPE AD_SMTPADR,
         GT_FTEXT       TYPE LVC_TXTCOL OCCURS 0,
         GV_HDTITLE(40) TYPE C,
         GV_SUBJECT     TYPE SO_OBJ_DES.


   DATA : LV_SEND LIKE ADR6-SMTP_ADDR,
          LV_RECV LIKE ADR6-SMTP_ADDR.

   DATA: RESULT_TAB  TYPE MATCH_RESULT_TAB.

   CLEAR : LV_FLAG.

   DEFINE MAIL_MSG.
     APPEND &1 TO GT_MESSAGE.
   END-OF-DEFINITION.

   CLEAR  : GT_MESSAGE, GV_SUBJECT, LV_TEXT1, LV_TEXT2, LV_TEXT3.
   REFRESH: GT_MESSAGE.

   CLEAR : LV_STEP_TXT, LV_STEP_TXT_S.

   LV_STEP_TXT = '승인요청의 건'.
   LV_STEP_TXT_S = ' 수입문서'.

   CONCATENATE LV_STEP_TXT
           '[' LV_STEP_TXT_S ':'  ZTITRQS-REQNO ']'
          INTO GV_SUBJECT SEPARATED BY SPACE.


   CONCATENATE '<br>'
               '수입요청번호 : ['
               ZTITRQS-REQNO
               '] 가 생성되었습니다.'
               '확인 후 승인 부탁 드립니다.'
               '<br><br>'
          INTO LV_TEXT1 SEPARATED BY SPACE.

   MAIL_MSG: '<html>',
             '<body>',
             LV_TEXT1,
*            LV_TEXT2,
*            LV_TEXT3,
             '</body>',
             '</html>'.

   TRY.
       G_EMAIL = CL_BCS=>CREATE_PERSISTENT( ).

       " 보내는 사람 지정
       CLEAR : LV_SEND.

       G_EMAIL_BODY = CL_DOCUMENT_BCS=>CREATE_DOCUMENT(
                       I_TYPE    = 'HTM'
                       I_TEXT    = GT_MESSAGE
                       I_SUBJECT = GV_SUBJECT ).

       G_EMAIL->SET_DOCUMENT( G_EMAIL_BODY ).


       CLEAR : LV_RECV.
*       LV_RECV = 'lwh10@naver.com'.

       SELECT SINGLE  EMAIL
         INTO LV_RECV
         FROM ZTITRQM
         WHERE ZAUTH EQ 'I'.

       G_RECEIVER = CL_CAM_ADDRESS_BCS=>CREATE_INTERNET_ADDRESS(
                     I_ADDRESS_STRING = LV_RECV ).

       G_EMAIL->ADD_RECIPIENT( I_RECIPIENT = G_RECEIVER
                               I_EXPRESS   = 'X' ).

       G_EMAIL->SET_SEND_IMMEDIATELY( 'X' ).

       G_EMAIL->SEND( EXPORTING I_WITH_ERROR_SCREEN = 'X'
                      RECEIVING RESULT              = GV_SEND_RESULT ).

       COMMIT WORK.

     CATCH CX_BCS INTO G_EXCEPTION.
*       LV_FLAG = 'X'.

       EXIT.
   ENDTRY.

** 메일 전송여부에 따라 COMMIT 및 ROLLBACK 수행
   IF LV_FLAG = 'X'.
*___메일 전송 실패
     ROLLBACK WORK.
     MESSAGE S001 WITH '메일전송 실패!'
     DISPLAY LIKE 'E'.
     EXIT.
   ELSE.
     COMMIT WORK.
   ENDIF.

 ENDFORM.                    " SEND_MAIL
