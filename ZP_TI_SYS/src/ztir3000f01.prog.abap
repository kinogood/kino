************************************************************************
* Title         :  ZTIR3000F01                                         *
*                                                                      *
* Description   : 수입 I/V 관리 Subroutine Include                     *
*                                                                      *
* Creation Date : 2003/08/12                                           *
*                                                                      *
* Author        : SeogBong, Kang                                       *
*                 Copyright ⓒ ASEG Co., LTD. All rights reserved.     *
************************************************************************
*----------------------------------------------------------------------*
*                M O D I F I C A T I O N   L O G                       *
*----------------------------------------------------------------------*
* Date         Programmer       Transport#  Description                *
*----------------------------------------------------------------------*
*2014.09.11       조성익          43436 : 복합 BL 사후송금송장 생성 개선
*2022.01.27       이원형   CHM2201-00201 엠트론 세금코드 V0 세팅
*----------------------------------------------------------------------*


*&---------------------------------------------------------------------*
*&      Form  p2000_get_bl_open_items
*&---------------------------------------------------------------------*
FORM P2000_GET_BL_OPEN_ITEMS .

  CLEAR: G_COUNT, IT_BLNUM.
  REFRESH : IT_BLNUM.

  G_LINEN    = 20.
  G_OUT_TEXT = '데이타를 검색 중입니다 %99999%%'(P01).
  REPLACE '%99999%' WITH G_LINEN INTO G_OUT_TEXT.
  PERFORM SHOW_PROGRESS_BAR USING G_OUT_TEXT G_LINE.

*> B/L data select.
*       iblno,iblit,ndfty,blmng,refwr,meins,ebeln
*       ebelp,reqno,reqit,mblnr,mjahr,zeile
*       menge
*       ivmngs
*       ivmngl

*> B/L 데이타 select.
  SELECT *
        INTO CORRESPONDING FIELDS OF TABLE IT_BL
        FROM ZTITBLK AS A JOIN ZTITBLP AS B
          ON A~IBLNO EQ B~IBLNO
       WHERE A~BUKRS  IN S_BUKRS  "회사코드.
         AND A~IBLNO  IN S_IBLNO
         AND A~BLNUM  IN S_BLNUM  "B/L 번호.
         AND A~BLDTY  IN S_BLDTY  "문서종류.
         AND A~RPTTY  IN S_RPTTY  "수입신고구분.
         AND A~EKORG  IN S_EKORG  "구매조직.
         AND A~EKGRP  IN S_EKGRP  "구매그룹.
         AND A~LIFNR  IN S_LIFNR  "공급업체 계정번호.
         AND A~BLETD  IN S_BLETD  "ETD(출발 예정 시각).
         AND A~BLETA  IN S_BLETA  "ETA(도착 예정 시각).
         AND A~FWDTY  IN S_FWDTY  "운송 방법.
         AND A~LPONR  IN S_LPONR  "최종품목번호.
         AND A~WAERS  IN S_WAERS  "통화키.
         AND A~LGAYN  IN S_LGAYN  "LG대상여부.
         AND B~IBLIT  IN S_IBLIT  "B/L 품목번호.
         AND B~NDFTY  IN S_NDFTY  "무환품 종류.
         AND B~EBELN  IN S_EBELN  "구매전표번호.
         AND B~EBELP  IN S_EBELP  "구매문서 품목번호.
         AND B~REQNO  IN S_REQNO  "수입의뢰 관리번호.
         AND B~REQIT  IN S_REQIT. "수입의뢰 품목번호.

**
  PERFORM GET_AVAILABLE_BL_ITEM TABLES IT_BL
                                       IT_BLNUM
                                USING  C_SUCCESS
                                       C_FALSE.

ENDFORM.                    " p2000_get_bl_open_items

*&---------------------------------------------------------------------*
*&      Form  display_bl_document_by_node
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM DISPLAY_BL_DOCUMENT_BY_NODE  USING    P_NODE_KEY.
  READ TABLE IT_BL WITH KEY INDEX = P_NODE_KEY(10).
  IF SY-SUBRC EQ 0.
    PERFORM  DISPLAY_BL_DOCUMENT     USING IT_BL-IBLNO
                                           IT_BL-IBLIT.
  ELSE.
    MESSAGE S903.
  ENDIF.

ENDFORM.                    " display_bl_document_by_node

*&---------------------------------------------------------------------*
*&      Form  set_request_of_import_data
*&---------------------------------------------------------------------*
FORM SET_REQUEST_OF_IMPORT_DATA TABLES P_IT_TAB    LIKE IT_TAB
                                USING  P_ZTIVBL00 STRUCTURE ZTIVBL00
                                       P_ZTITIVK STRUCTURE ZTITIVK
                                       P_ZTITIVP STRUCTURE ZTITIVP
                                       P_BL_WA    STRUCTURE IT_BL.

*  MOVE-CORRESPONDING p_ZTIvpo00 TO : p_it_tab, p_ZTITRQK, p_ZTITRQS.
*
*
*  MOVE: p_po_wa-rqmng  TO p_it_tab-rqmng,
*        p_po_wa-rqmngs TO p_it_tab-rqmngs,
*        p_po_wa-rqmngl TO p_it_tab-rqmngl.

  MOVE-CORRESPONDING P_ZTIVBL00 TO : P_IT_TAB, P_ZTITIVK.

  IF P_ZTITIVK-XBLNR IS INITIAL.
    P_ZTITIVK-XBLNR = P_ZTIVBL00-BLNUM.
  ENDIF.
  IF P_ZTITIVK-SGTXT IS INITIAL.
    P_ZTITIVK-SGTXT = P_ZTIVBL00-BLNUM.
  ENDIF.

*   p/o정보.
  IF NOT P_BL_WA-EBELN IS INITIAL.
*    SELECT SINGLE werks name1 lgort matnr txz01
*                  loekz elikz bprme bpumz bpumn
*                  umrez umren peinh uebto uebtk untto
*      INTO (p_it_tab-werks, p_it_tab-name1, p_it_tab-lgort,
*            p_it_tab-matnr, p_it_tab-txz01,
*            p_it_tab-loekz, p_it_tab-elikz, p_it_tab-bprme,
*            p_it_tab-bpumz, p_it_tab-bpumn, p_it_tab-umrez,
*            p_it_tab-umren, p_it_tab-peinh,
*            p_it_tab-uebto, p_it_tab-uebtk, p_it_tab-untto)
*      FROM  ZTIvpo00
*     WHERE  ebeln  = p_bl_wa-ebeln
*       AND  ebelp  = p_bl_wa-ebelp.

*> 050718 jp, park 지급조건(ZTERM) 추가 po의 지급조건 가져오도록
*> 박태균차장 요청

    SELECT SINGLE WERKS LGORT MATNR TXZ01
                  LOEKZ ELIKZ BPUMZ BPUMN
                  UMREZ UMREN PEINH UEBTO UEBTK UNTTO MWSKZ
                  ZTERM
      INTO (P_IT_TAB-WERKS, P_IT_TAB-LGORT,
            P_IT_TAB-MATNR, P_IT_TAB-TXZ01,
            P_IT_TAB-LOEKZ, P_IT_TAB-ELIKZ,
            P_IT_TAB-BPUMZ, P_IT_TAB-BPUMN,
            P_IT_TAB-UMREZ,
            P_IT_TAB-UMREN, P_IT_TAB-PEINH,
            P_IT_TAB-UEBTO, P_IT_TAB-UEBTK, P_IT_TAB-UNTTO,
            P_IT_TAB-MWSKZ, ZTITIVK-ZTERM)
      FROM  ZTIVPO00
     WHERE  EBELN  = P_BL_WA-EBELN
       AND  EBELP  = P_BL_WA-EBELP.

    MOVE: P_BL_WA-REFWR    TO P_IT_TAB-REFWR,
          P_BL_WA-BLMNG    TO P_IT_TAB-MENGE,
          P_BL_WA-IVMNGS   TO P_IT_TAB-IVMNGS,
          P_BL_WA-IVMNGL   TO P_IT_TAB-IVMNGL,
          P_BL_WA-IVMNGL   TO P_IT_TAB-IVMNG,
          P_BL_WA-IVMNGL   TO P_IT_TAB-REMNG.

    MOVE: SY-UNAME         TO P_IT_TAB-CNAM,
          SY-DATLO         TO P_IT_TAB-CDAT,
          SY-TIMLO         TO P_IT_TAB-CTME,
          SY-UNAME         TO P_IT_TAB-UNAM,
          SY-DATLO         TO P_IT_TAB-UDAT,
          SY-TIMLO         TO P_IT_TAB-UTME,
          P_ZTIVBL00-BLNUM TO P_IT_TAB-SGTXT.

    IF P_ZTITIVK-OPNBK IS INITIAL.
      IF NOT P_IT_TAB-REQNO IS INITIAL.
        SELECT SINGLE OPNBK
          INTO P_ZTITIVK-OPNBK
          FROM ZTIVRQ04
         WHERE REQNO  EQ  P_IT_TAB-REQNO.

        IF SY-SUBRC       EQ 0 AND
           NOT P_ZTITIVK-OPNBK IS INITIAL.
          SELECT SINGLE *
            FROM ZTSTIG3
           WHERE PARTI  EQ  C_CHARB
             AND EPART  EQ  P_ZTITIVK-OPNBK
             AND BUKRS  EQ  P_ZTITIVK-BUKRS.
          IF SY-SUBRC NE 0.
            MESSAGE E918 WITH P_ZTITIVK-OPNBK.
          ENDIF.
          IF ZTITIG00-SJPAP EQ C_CHARV.
            P_ZTITIVK-APVEN = ZTITIVK-LIFNR.
          ELSEIF ZTITIG00-SJPAP EQ C_CHARB.
            P_ZTITIVK-APVEN = ZTSTIG3-LIFNR.
          ENDIF.
        ELSE.
          MESSAGE E322 WITH P_IT_TAB-REQNO.
        ENDIF.
      ENDIF.
    ENDIF.


    APPEND P_IT_TAB.
  ENDIF.
*>아이템 번호를 생성함.
  PERFORM SET_ITEM_NUMBER_BUILD TABLES P_IT_TAB
                                USING  P_ZTITIVK.

  PERFORM GET_OTHERS_TEXT_BY_MASTER_DATA.

ENDFORM.                    " set_request_of_import_data
*&---------------------------------------------------------------------*
*&      Form  get_and_check_po_data
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM GET_AND_CHECK_BL_DATA  USING    P_IBLNO
                                     P_IBLIT
                                     P_MODIFY
                                     P_ZTIVBL00 STRUCTURE ZTIVBL00
                                     P_COUNT.

  CLEAR: ZTIVBL00.

  SELECT SINGLE * INTO P_ZTIVBL00
    FROM ZTIVBL00
   WHERE IBLNO EQ P_IBLNO
     AND IBLIT EQ P_IBLIT.

  IF SY-SUBRC EQ 0.
*>Vendor 체크.
    IF ZTITIVK-LIFNR     NE P_ZTIVBL00-LIFNR AND
       NOT ZTITIVK-LIFNR IS INITIAL.
      MESSAGE S306 WITH P_ZTIVBL00-LIFNR ZTITIVK-LIFNR.
      P_MODIFY = C_TRUE.
      EXIT.
    ENDIF.
*통화키 체크.
    IF ZTITIVK-WAERS    NE  P_ZTIVBL00-WAERS AND
       P_COUNT           GT  C_ZERO.
      MESSAGE S307 WITH P_ZTIVBL00-WAERS ZTITIVK-WAERS.
      P_MODIFY = C_TRUE.
    ENDIF.

*> 사전송금 체크
    IF NOT P_ZTIVBL00-REQNO IS INITIAL.
      SELECT SINGLE *
        FROM ZTITRQK
       WHERE REQNO EQ P_ZTIVBL00-REQNO.
      IF SY-SUBRC NE 0.
        MESSAGE S323.
        P_MODIFY = C_TRUE.
        EXIT.
      ENDIF.
      IF ZTITRQK-REQTY EQ 'TT' AND
         ZTITRQK-ANBTY EQ 'B'.
        MESSAGE S324.
        P_MODIFY = C_TRUE.
        EXIT.
      ENDIF.
    ENDIF.

*> Lock Object
    PERFORM  SET_BL_LOCK_OBJECT  USING P_IBLNO
                                       P_IBLIT
                                       C_LOCK
                                       C_SUCCESS
                                       P_MODIFY.
  ELSE.
    MESSAGE S019(06) WITH P_IBLNO.
    P_MODIFY = C_TRUE.
    EXIT.
  ENDIF.

ENDFORM.                    " get_and_check_po_data
*&---------------------------------------------------------------------*
*&      Form  p3000_set_data_of_screen
*&---------------------------------------------------------------------*
FORM P3000_SET_DATA_OF_SCREEN .

  IF SY-TCODE EQ C_CREATE OR
     SY-TCODE EQ C_CREATE_D.

    REFRESH: IT_TAB, IT_ZTITIVH, IT_ZTITIVV.

    CLEAR: ZTITIVK,
          *ZTITIVK,
           ZTITIVP,
           ZTITBLK,
           ZTITBLP,
           IT_TAB,
           LFA1,
          *LFA1,
           W_LFA1,
           W_LFA1_BANK,
           T001,
           T024,
           T024E.

    CLEAR:  GT_CONTROL-TEXTLINES[], GT_CONTROL-TEXTTYPES[].

    MOVE  : '수입상업송장' TO    ZTITIVK-BKTXT,
             C_CHAR1       TO    ZTITIVK-VORGANG,
             C_CHARI       TO    ZTITIVK-PRPYN,
             C_CHARN       TO    ZTITIVK-LIVST,
             'RE'          TO    ZTITIVK-BLART,
             SY-DATLO      TO    ZTITIVK-CIVDT,  ">송장일.
             SY-DATLO      TO    ZTITIVK-BLDAT.
  ELSE.
*> 변경 문서 관리를 위한 이전데이타를 Move.
    ZTITIVK-IVONO   = *ZTITIVK-IVONO.
  ENDIF.

ENDFORM.                    " p3000_set_data_of_screen
*&---------------------------------------------------------------------*
*&      Form  check_for_sub_document_exist
*&---------------------------------------------------------------------*
*  삭제시 후속 문서의 존재여부를 확인함..
*----------------------------------------------------------------------*
FORM CHECK_FOR_SUB_DOCUMENT_EXIST.

  LOOP AT IT_TAB INTO G_TC_2130_WA.
    PERFORM CHECK_IV_SUB_DOCUMENT_EXIST
                             USING   G_TC_2130_WA-IVONO
                                     G_TC_2130_WA-RBLGP
                                     C_ERROR
                                     G_SUBRC.
  ENDLOOP.

ENDFORM.                    " check_for_sub_document_exist


*&---------------------------------------------------------------------*
*&      Form  check_for_document_field
*&---------------------------------------------------------------------*
*  필드들의 오류 값들을 체크하여 공통 nternal table에 저장함.
*----------------------------------------------------------------------*
FORM CHECK_FOR_DOCUMENT_FIELD USING P_MODE.
*
  DATA: L_IF_NULL TYPE REF TO IF_MESSAGE_OBJ_MM.

  DATA: BEGIN OF LT_MWSKZ OCCURS 0,
        MWSKZ    LIKE ZTITIVP-MWSKZ,
        END   OF LT_MWSKZ.

  CLEAR: LT_MWSKZ[], LT_MWSKZ.
* Message preparations
  PERFORM  SET_MESSAGE_PREPARATIONS.

  CLEAR: G_LINE.

*> 총 처리금액.
  IF ZTITIVK-IVAMP IS INITIAL.
    PERFORM SET_RETURN_MESSAGE USING 'ZTITIVK' 'IVAMP' C_ERROR.
  ENDIF.
*> 헤더 텍스트.
  IF ZTITIVK-BKTXT IS INITIAL.
    PERFORM SET_RETURN_MESSAGE USING 'ZTITIVK' 'IVAMP' C_ERROR.
  ENDIF.
*> 유보금이 존재할 경우.
  IF NOT ZTITIVK-RTCHG IS INITIAL.
    READ TABLE IT_ZTITIVV INDEX 2.
    IF SY-SUBRC EQ 0.
      IF IT_ZTITIVV-ZTERM IS INITIAL.
        MESSAGE S316.
        PERFORM SET_RETURN_MESSAGE_FILL USING C_ERROR.
      ENDIF.
    ENDIF.
  ENDIF.

  CLEAR: G_COUNT.
*> 품목 체크.
  LOOP AT IT_TAB INTO G_TC_2130_WA.
    ADD 1 TO G_COUNT.
********************************************************************
*> Simulation일 경우, TP 전략상품 PO & 판매오더 번호 제한...
    IF OK_CODE EQ 'ZTISIMUL'.
      IF NOT G_TC_2130_WA-EBELN IS INITIAL.
        SELECT SINGLE *
          FROM EKKO
         WHERE EBELN EQ G_TC_2130_WA-EBELN.
        IF SY-SUBRC EQ 0.
          IF EKKO-BSART EQ 'TB'.
            SELECT SINGLE *
              FROM EKKN
             WHERE EBELN EQ G_TC_2130_WA-EBELN
               AND EBELP EQ G_TC_2130_WA-EBELP
               AND ZEKKN EQ '01'.
            IF SY-SUBRC       EQ 0       AND
               NOT EKKN-VBELN IS INITIAL.
              MESSAGE S177 WITH G_TC_2130_WA-RBLGP
                                G_TC_2130_WA-EBELN
                                G_TC_2130_WA-EBELP.
              PERFORM SET_RETURN_MESSAGE_FILL USING C_ERROR.
            ENDIF.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.
********************************************************************

    IF G_TC_2130_WA-REMNG IS INITIAL.
      MESSAGE S133 WITH G_TC_2130_WA-RBLGP '수량'.
      PERFORM SET_RETURN_MESSAGE_FILL USING C_ERROR.
    ENDIF.
    IF G_TC_2130_WA-REMNG IS INITIAL.
      MESSAGE S133 WITH G_TC_2130_WA-RBLGP '금액'.
      PERFORM SET_RETURN_MESSAGE_FILL USING C_ERROR.
    ENDIF.
    IF NOT G_TC_2130_WA-LOEKZ IS INITIAL.
      MESSAGE S170 WITH G_TC_2130_WA-RBLGP G_TC_2130_WA-EBELN
                                           G_TC_2130_WA-EBELP.
      PERFORM SET_RETURN_MESSAGE_FILL USING C_ERROR.
    ENDIF.

    LT_MWSKZ-MWSKZ = G_TC_2130_WA-MWSKZ.
    COLLECT LT_MWSKZ.

  ENDLOOP.
  IF G_COUNT EQ 0.
    MESSAGE S001.
    PERFORM SET_RETURN_MESSAGE_FILL USING C_ERROR.
  ENDIF.

*라인아이템의 세금코드가 여러개면 에러 메세지 띄움
  DESCRIBE TABLE LT_MWSKZ LINES G_LINE.
  IF G_LINE GT 1.
    MESSAGE S885.
    PERFORM SET_RETURN_MESSAGE_FILL USING C_ERROR.
  ENDIF.

*> CHM2201-00201 세금코드 V0 아니면 에러
  IF ZTITIVK-BUKRS EQ '3000'.
    IF ZTITIVK-MWSKZ NE 'V0'.
      MESSAGE S886.
    PERFORM SET_RETURN_MESSAGE_FILL USING C_ERROR.
*      MESSAGE E999 WITH '세금코드는 V0로 입력하십시오!'..
    ENDIF.
  ENDIF.
*> CHM2201-00201 세금코드 V0 아니면 에러

*> 오류정보가 존재시 메시지 상자 POPUP.
  G_LINE = G_MESSAGE_HANDLER->GET_SEVERITY_BO(
                          IM_BUSINESS_OBJ          = L_IF_NULL
                          IM_INCLUDE_CHILD_OBJECTS = C_TRUE ).

  IF G_LINE GT 0.
    CALL METHOD G_MESSAGE_HANDLER->SHOW( IM_POPUP = C_TRUE
      IM_AMODAL = C_FALSE ).
  ELSE.
    MESSAGE S911.
  ENDIF.

ENDFORM.                    " check_for_document_field
*&---------------------------------------------------------------------*
*&      Form  p8000_save_master_data
*&---------------------------------------------------------------------*
FORM P8000_SAVE_MASTER_DATA USING P_MODE.

*
*> 공통테이블 적용.
  IF G_MODE      EQ C_CHARY AND
     OK_CODE_OLD EQ 'ZTISAVE'.
    P_MODE = 'Y'.
  ENDIF.

  PERFORM P8100_SAVE_COMMON_DATA  TABLES IT_TAB
                                  USING  ZTITIVK
                                         G_SUBRC
                                         P_MODE.
  IF G_SUBRC NE C_ZERO.
    MESSAGE A912.   EXIT.
  ENDIF.

*> Long Text 저장 루틴.
  PERFORM SAVE_LONG_TEXT USING ZTITIVK+3(10)
                               C_TEXTOBJECT_HEADER
                               G_SUBRC.

  IF SY-SUBRC NE 0.
    ROLLBACK WORK.
    MESSAGE A912.   EXIT.
  ENDIF.

*> Change document setting.
  PERFORM P8120_CHANGE_DOCUMENT.
*> Set parameter ID
  IF OK_CODE_OLD EQ 'ZTIDELETE'.
    MESSAGE S315 WITH ZTITIVK-IVONO.
  ELSE.
    SET PARAMETER ID 'ZTIIVONO' FIELD ZTITIVK-IVONO.
    IF NOT ZTITIVK-IVNUM IS INITIAL.
      SET PARAMETER ID 'ZTIIVNUM' FIELD ZTITIVK-IVNUM.
    ENDIF.
    MESSAGE S314 WITH ZTITIVK-IVONO.
  ENDIF.
*> Commit work.
  COMMIT WORK.
*  COMMIT WORK AND WAIT.


ENDFORM.                    " p8000_save_master_data
*&---------------------------------------------------------------------*
*&      Form  p8100_save_common_data
*&---------------------------------------------------------------------*
FORM P8100_SAVE_COMMON_DATA  TABLES  PT_TAB     STRUCTURE G_TC_2130_WA
                             USING   P_ZTITIVK STRUCTURE ZTITIVK
                                     P_SUBRC    LIKE      SY-SUBRC
                                     P_MODE.

  DATA: L_LCONO TYPE ZTIREQNO.

  CLEAR: P_SUBRC, L_LCONO.

  IF SY-TCODE EQ C_CREATE OR  SY-TCODE EQ C_CREATE_D.

    CALL FUNCTION 'Z_TI_GET_NUMBER_NEXT'
      EXPORTING
        ZMPTY          = 'IV'
*   BUKRS          =
     IMPORTING
        LCONO          = L_LCONO
     EXCEPTIONS
       NOT_TYPE       = 1
       OTHERS         = 2.

    IF SY-SUBRC <> 0.
      MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
              WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    ENDIF.
  ELSE.
    L_LCONO = P_ZTITIVK-IVONO.
  ENDIF.

*  IF sy-tcode EQ c_create_a.
*    ADD 1 TO l_amdsq.
*  ENDIF.

  IF  P_ZTITIVK-CNAM IS INITIAL.
    MOVE: SY-UNAME   TO   P_ZTITIVK-CNAM,
          SY-DATLO   TO   P_ZTITIVK-CDAT,
          SY-TIMLO   TO   P_ZTITIVK-CTME.
  ENDIF.

  MOVE: SY-MANDT   TO   P_ZTITIVK-MANDT,
        L_LCONO    TO   P_ZTITIVK-IVONO,
        SY-UNAME   TO   P_ZTITIVK-UNAM,
        SY-DATLO   TO   P_ZTITIVK-UDAT,
        SY-TIMLO   TO   P_ZTITIVK-UTME.

*> 전기시.
  IF P_MODE EQ 'H'.
    MOVE: INVOICEDOCNUMBER TO P_ZTITIVK-BELNR,
          C_CHARP          TO P_ZTITIVK-LIVST.
  ELSEIF P_MODE EQ 'R'.
    MOVE: SPACE            TO P_ZTITIVK-BELNR,
          C_CHARN          TO P_ZTITIVK-LIVST.
  ENDIF.

  IF OK_CODE_OLD EQ 'ZTIDELETE'.
*> Header table delete.
    DELETE FROM ZTITIVK WHERE IVONO EQ ZTITIVK-IVONO.
    IF SY-SUBRC NE 0.
      ROLLBACK WORK.   MOVE 4  TO P_SUBRC.     EXIT.
    ENDIF.
*> Item table delete
    DELETE FROM ZTITIVP WHERE IVONO EQ ZTITIVK-IVONO.
    IF SY-SUBRC NE 0.
      ROLLBACK WORK.   MOVE 4  TO P_SUBRC.     EXIT.
    ENDIF.
*> 이력 table delete
    DELETE FROM ZTITIVH WHERE IVONO EQ ZTITIVK-IVONO.

*> 분할금액 table delete
    DELETE FROM ZTITIVV WHERE IVONO EQ ZTITIVK-IVONO.

    EXIT.
  ELSE.
*> Header table modify.
    MODIFY ZTITIVK FROM P_ZTITIVK.
    IF SY-SUBRC NE 0.
      ROLLBACK WORK.   MOVE 4  TO P_SUBRC.     EXIT.
    ENDIF.
*> Items table modify.
    DELETE FROM ZTITIVP WHERE IVONO EQ P_ZTITIVK-IVONO.
    REFRESH : XZTITIVP.
    LOOP AT IT_TAB INTO G_TC_2130_WA.
      MOVE-CORRESPONDING G_TC_2130_WA TO XZTITIVP.
      XZTITIVP-MANDT = P_ZTITIVK-MANDT.
      XZTITIVP-IVONO = P_ZTITIVK-IVONO.
*      xZTITRQP-reqit = sy-tabix.
      APPEND XZTITIVP.
    ENDLOOP.

    MODIFY ZTITIVP FROM TABLE XZTITIVP.
    IF SY-SUBRC NE 0.
      ROLLBACK WORK.   MOVE 4  TO P_SUBRC.     EXIT.
    ENDIF.

*> 분할금액 table modify.
    REFRESH : XZTITIVV.
    DELETE FROM ZTITIVV WHERE IVONO EQ ZTITIVK-IVONO.
    DESCRIBE TABLE IT_ZTITIVV  LINES G_LINE.
    IF G_LINE GT 0.
      LOOP AT IT_ZTITIVV.
        IT_ZTITIVV-MANDT = P_ZTITIVK-MANDT.
        IT_ZTITIVV-IVONO = P_ZTITIVK-IVONO.
        MODIFY IT_ZTITIVV.
        MOVE-CORRESPONDING IT_ZTITIVV TO XZTITIVV.
        XZTITIVP-MANDT = P_ZTITIVK-MANDT.
        XZTITIVP-IVONO = P_ZTITIVK-IVONO.
        APPEND XZTITIVV.
      ENDLOOP.

      MODIFY ZTITIVV FROM TABLE IT_ZTITIVV.
    ENDIF.

*> 전기이력 table modify.
    IF P_MODE EQ 'H'.
      CLEAR: ZTITIVH.
      SELECT MAX( IVSEQ )
        INTO ZTITIVH-IVSEQ
        FROM ZTITIVH
       WHERE IVONO    EQ   P_ZTITIVK-IVONO.

      ADD 1 TO  ZTITIVH-IVSEQ.
      IF P_ZTITIVK-VORGANG EQ C_CHAR1 OR
         P_ZTITIVK-VORGANG EQ C_CHAR3.
        MOVE 'H'                 TO     ZTITIVH-SHKZG.
      ELSE.
        MOVE 'S'                 TO     ZTITIVH-SHKZG.
      ENDIF.
      MOVE : SY-MANDT             TO     ZTITIVH-MANDT,
             P_ZTITIVK-BLDAT     TO     ZTITIVH-BUDAT,
             P_ZTITIVK-BUDAT     TO     ZTITIVH-BLDAT,
             P_ZTITIVK-IVONO     TO     ZTITIVH-IVONO,
             P_ZTITIVK-WAERS     TO     ZTITIVH-WAERS,
*             p_ZTITIVK-dmbtr     TO     ZTITIVH-dmbtr,
             P_ZTITIVK-BLART     TO     ZTITIVH-BLART,
             P_ZTITIVK-IVAMP     TO     ZTITIVH-IVAMP,
             P_ZTITIVK-VORGANG   TO     ZTITIVH-VORGANG,
             SY-UNAME             TO     ZTITIVH-CNAM,
             SY-DATLO             TO     ZTITIVH-CDAT,
             SY-TIMLO             TO     ZTITIVH-CTME,
             FISCALYEAR           TO     ZTITIVH-GJAHR,
             INVOICEDOCNUMBER     TO     ZTITIVH-BELNR,
             ''                   TO     ZTITIVH-CBUDAT,
             ''                   TO     ZTITIVH-CGJAHR,
             ''                   TO     ZTITIVH-CBELNR.
      INSERT ZTITIVH.
      IF SY-SUBRC NE 0.
        ROLLBACK WORK.   MOVE 4  TO P_SUBRC.     EXIT.
      ENDIF.
*> 전기 취소.
    ELSEIF P_MODE EQ 'R'.
      CLEAR: ZTITIVH.
      SELECT MAX( IVSEQ )
        INTO ZTITIVH-IVSEQ
        FROM ZTITIVH
       WHERE IVONO    EQ   P_ZTITIVK-IVONO.

      SELECT SINGLE *
        FROM ZTITIVH
       WHERE IVONO    EQ   P_ZTITIVK-IVONO
         AND IVSEQ    EQ   ZTITIVH-IVSEQ.

      IF SY-SUBRC EQ 0.
        MOVE: ZTISSCRCOM-STGRD          TO ZTITIVH-STGRD,
              ZTISSCRCOM-CBUDAT         TO ZTITIVH-CBUDAT,
              FISCALYEAR_REVERSAL       TO ZTITIVH-CGJAHR,
              INVOICEDOCNUMBER_REVERSAL TO ZTITIVH-CBELNR,
              SY-UNAME                  TO ZTITIVH-CNAM,
              SY-DATLO                  TO ZTITIVH-CDAT,
              SY-TIMLO                  TO ZTITIVH-CTME.
        MODIFY ZTITIVH.
        IF SY-SUBRC NE 0.
          ROLLBACK WORK.   MOVE 4  TO P_SUBRC.     EXIT.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDIF.

ENDFORM.                    " p8100_save_common_data
*&---------------------------------------------------------------------*
*&      Form  call_smartforms_functioins
*&---------------------------------------------------------------------*
FORM CALL_SMARTFORMS_FUNCTIOINS USING P_FUNC_MOD_NAME.

  CALL FUNCTION P_FUNC_MOD_NAME
       EXPORTING
*            ARCHIVE_INDEX      =
*            ARCHIVE_INDEX_TAB  =
*            ARCHIVE_PARAMETERS =
*            MAIL_APPL_OBJ      = MAIL_APPL_OBJ
*            MAIL_RECIPIENT     = MAIL_RECIPIENT
*            MAIL_SENDER        = MAIL_SENDER
            USER_SETTINGS      = SPACE
            CONTROL_PARAMETERS = G_CONTROL_PARAMETERS
            OUTPUT_OPTIONS     = G_OUTPUT_OPTIONS
*            LFA1               = LFA1
*            SUMMARY            = ZMMKR_RTC_ERS_LIST
*            SDATE              = GW_SDATE
*            TITLE              = TEXT-T01
*            TITLE              = 'ERS LIST'
       IMPORTING
            DOCUMENT_OUTPUT_INFO = G_DOCUMENT_OUTPUT_INFO
            JOB_OUTPUT_INFO      = G_JOB_OUTPUT_INFO
            JOB_OUTPUT_OPTIONS   = G_JOB_OUTPUT_OPTIONS
*       TABLES
*            I_ITEM             = XITAB
*            SUBTOTAL           = SITAB
       EXCEPTIONS
            FORMATTING_ERROR   = 1
            INTERNAL_ERROR     = 2
            SEND_ERROR         = 3
            USER_CANCELED      = 4.

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

  IF ZTITIVK-BUKRS IS INITIAL.
    CLEAR: T001.
  ELSE.
    SELECT SINGLE * FROM T001
     WHERE BUKRS EQ ZTITIVK-BUKRS.
    IF SY-SUBRC EQ 0.
      SELECT SINGLE *
        FROM T005
       WHERE LAND1 EQ T001-LAND1.
      SELECT SINGLE *
        FROM ZTITIG00
       WHERE BUKRS EQ T001-BUKRS.
      IF SY-SUBRC NE 0.
        MESSAGE E035 WITH T001-BUKRS.
      ENDIF.
    ENDIF.
  ENDIF.

* 구매조직 SELECT ( T024E )
  IF ZTITIVK-EKORG IS INITIAL.
    CLEAR T024E.
  ELSE.
    CALL FUNCTION 'T024E_SINGLE_READ'
      EXPORTING
        T024E_EKORG = ZTITIVK-EKORG
      IMPORTING
        WT024E      = T024E
      EXCEPTIONS
        NOT_FOUND   = 1
        OTHERS      = 2.

    IF SY-SUBRC NE 0.
      IF SY-CALLD NE C_TRUE.
        MESSAGE W001(MH) WITH ZTITIVK-EKORG.
      ENDIF.
    ENDIF.
  ENDIF.

* 구매그룹 SELECT ( T024 )
  IF ZTITIVK-EKGRP IS INITIAL.
    CLEAR T024.
  ELSE.
    CALL FUNCTION 'MM_ARRANG_PURCHASE_GRP_SELECT'
      EXPORTING
        PURCHASE_GROUP           = ZTITIVK-EKGRP
      IMPORTING
        E_T024                   = T024
      EXCEPTIONS
        PURCHASE_GROUP_NOT_FOUND = 1
        OTHERS                   = 2.

    IF SY-SUBRC NE 0.
      IF SY-CALLD NE C_TRUE.
        MESSAGE W030(MN) WITH ZTITIVK-EKGRP.
      ENDIF.
    ENDIF.
  ENDIF.

  PERFORM  GET_IMPORT_VENDORS_TEXT  USING C_SUCCESS.

ENDFORM.                    " GET_OTHERS_TEXT_BY_MASTER_DATA

*&---------------------------------------------------------------------*
*&      Form  GET_BL_DOCUMENT_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM GET_BL_DOCUMENT_DATA     TABLES   P_IT_BL   STRUCTURE IT_BL
                                       P_IT_IG02 STRUCTURE ZTITIG02
                              USING    P_IBLNO
                                       P_IBLIT
                                       P_MTYPE
                                       P_MSGTY.

  REFRESH IT_BLNUM.  CLEAR IT_BLNUM.
  IF P_IBLIT IS INITIAL.
    SELECT * FROM ZTIVBL00
      INTO CORRESPONDING FIELDS OF TABLE P_IT_BL
     WHERE IBLNO EQ P_IBLNO
       AND ( NDFTY EQ SPACE      ">유환.
        OR   NDFTY EQ C_CHARA ). ">사후송금건.
  ELSE.
    SELECT * FROM ZTIVBL00
      INTO CORRESPONDING FIELDS OF TABLE P_IT_BL
     WHERE IBLNO EQ P_IBLNO
       AND IBLIT EQ P_IBLIT
       AND ( NDFTY EQ SPACE      ">유환.
        OR   NDFTY EQ C_CHARA ). ">사후송금건.
  ENDIF.

  IF SY-SUBRC NE 0.
    IF P_IBLIT IS INITIAL.
      MESSAGE ID 'ZMTI00' TYPE P_MTYPE NUMBER 216 WITH P_IBLNO.
    ELSE.
      MESSAGE ID 'ZMTI00' TYPE P_MTYPE NUMBER 216 WITH P_IBLNO P_IBLIT.
    ENDIF.
  ENDIF.

** b/l상태 확인.add.
*  IF ZTIvbl00-crlse EQ 'B'.
*    MESSAGE ID 'ZMTI00' TYPE p_mtype NUMBER 321 WITH '송장'.
*  ENDIF.


  PERFORM GET_AVAILABLE_BL_ITEM TABLES P_IT_BL
                                       IT_BLNUM
                                USING  P_MSGTY
                                       C_FALSE.

ENDFORM.                    " get_bl_document_data
*&---------------------------------------------------------------------*
*&      Form  GET_LC_DOCUMENT_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM GET_LC_DOCUMENT_DATA     TABLES   P_IT_LC   STRUCTURE IT_REQIT_TMP
                              USING    P_REQNO
                                       P_AMDSQ
                                       P_MTYPE
                                       P_MSGTY.
  CHECK: NOT P_REQNO IS INITIAL.

  REFRESH IT_REQNO.  CLEAR IT_REQNO.
  CALL FUNCTION 'Z_TI_GET_REQUEST_OF_IMPORT'
    EXPORTING
      REQNO     = P_REQNO
      AMDSQ     = P_AMDSQ
    IMPORTING
      ZTITRQK   = ZTITRQK
      ZTITRQS   = ZTITRQS
    TABLES
      ZTITRQP   = P_IT_LC
    EXCEPTIONS
      NOT_FOUND = 1
      OTHERS    = 2.

  IF SY-SUBRC <> 0.
    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

  IF SY-SUBRC NE 0.
    MESSAGE ID 'ZMTI00' TYPE P_MTYPE NUMBER 217 WITH P_REQNO P_AMDSQ.
  ENDIF.

  PERFORM GET_AVAILABLE_LC_ITEM TABLES P_IT_LC
                                       IT_REQNO
                                USING  P_MSGTY
                                       C_FALSE.

* 수입의뢰상태 확인.add.
  IF ZTITRQK-OPNBK IS INITIAL.
    MESSAGE ID 'ZMTI00' TYPE 'E' NUMBER 322 WITH ZTITRQK-REQNO.
  ENDIF.

*> 회사별 프로세스 정의 테이블 검색.
  SELECT SINGLE *
    FROM ZTITIG00
   WHERE BUKRS EQ ZTITRQK-BUKRS.
  IF SY-SUBRC NE 0.
    MESSAGE E035 WITH ZTITRQK-BUKRS.
  ENDIF.

ENDFORM.                    " get_lc_document_data

*&---------------------------------------------------------------------*
*&      Form  GET_available_bl_ITEM
*&---------------------------------------------------------------------*
FORM GET_AVAILABLE_BL_ITEM  TABLES   P_IT_BL    STRUCTURE IT_BL
                                     P_IT_BLNUM STRUCTURE IT_BLNUM
                            USING    P_MTYPE
                                     P_DELETE.

  CLEAR: G_TABIX, G_COUNT, G_CNT.
  LOOP AT P_IT_BL.

    G_TABIX = SY-TABIX.

*   p/o정보.
*    select single WERKS NAME1 LGORT LGOBE MATNR TXZ01 NETWR
*                  EEIND UMSON LOEKZ ELIKZ BPRME BPUMZ BPUMN
*                  UMREZ UMREN NETPR PEINH UEBTO UEBTK UNTTO BUPLA
*      into (it_tab-WERKS, it_tab-NAME1, it_tab-LGORT, it_tab-LGOBE,
*            it_tab-MATNR, it_tab-TXZ01, it_tab-NETWR, it_tab-EEIND,
*             it_tab-UMSON, it_tab-LOEKZ, it_tab-ELIKZ, it_tab-BPRME,
*            it_tab-BPUMZ, it_tab-BPUMN, it_tab-UMREZ, it_tab-UMREN,
*            it_tab-NETPR, it_tab-PEINH, it_tab-UEBTO, it_tab-UEBTK,
*            it_tab-UNTTO, it_tab-BUPLA)
*      FROM  ZTIvpo00
*     WHERE  ebeln  = p_it_bl-ebeln
*       AND  ebelp  = p_it_bl-ebelp.

*   bl 정보 수량.
    SELECT  SINGLE BLMNG PPMNG
      INTO  (P_IT_BL-MENGE, P_IT_BL-PPMNG)
      FROM  ZTITBLP
     WHERE  IBLNO  = P_IT_BL-IBLNO
       AND  IBLIT  = P_IT_BL-IBLIT.

    P_IT_BL-BLMNG  = P_IT_BL-MENGE.

*************************************************
* 2008.06.10 simcho by 박혁세K
* 엠트론 test시 오류 발견
* 송장수량 계산 시 필드교체 remng -> ivmng
*************************************************
*> I/V 누적수량.
    SELECT  SUM( IVMNG ) SUM( REFWR )
      INTO  (P_IT_BL-IVMNGS, P_IT_BL-REFWRS)
      FROM  ZTITIVP
     WHERE  ( IBLNO  EQ P_IT_BL-IBLNO
       AND    IBLIT  EQ P_IT_BL-IBLIT ).
**        OR  ( ebeln  EQ p_it_bl-ebeln
**       AND    ebelp  EQ p_it_bl-ebelp
*        OR  ( reqno  EQ p_it_bl-reqno
*       AND    reqit  EQ p_it_bl-reqit
*       AND    iblno  EQ space ).
*
* >I/V 누적수량(선급수량).
    IF NOT P_IT_BL-REQNO IS INITIAL.
      SELECT  SUM( IVMNG ) SUM( IVAMTI )
        INTO  (P_IT_BL-PPMNGS, P_IT_BL-PPAMTS)
        FROM  ZTIVIV00
*       WHERE  reqno  EQ p_it_bl-reqno
*         AND  reqit  EQ p_it_bl-reqit
       WHERE  EBELN  EQ P_IT_BL-EBELN
         AND  EBELP  EQ P_IT_BL-EBELP
         AND  REQNO  EQ P_IT_BL-REQNO
         AND  REQIT  EQ P_IT_BL-REQIT
         AND ( PRPYN EQ C_CHARP
          OR   PRPYN EQ C_CHARR ).
    ENDIF.

**> I/V 누적수량.
*    SELECT  SUM( remng ) SUM( refwr )
*      INTO  (p_it_bl-ivmngs, p_it_bl-refwrs)
*      FROM  ztitivp
*     WHERE  ( iblno  EQ p_it_bl-iblno
*       AND    iblit  EQ p_it_bl-iblit ).
***        OR  ( ebeln  EQ p_it_bl-ebeln
***       AND    ebelp  EQ p_it_bl-ebelp
**        OR  ( reqno  EQ p_it_bl-reqno
**       AND    reqit  EQ p_it_bl-reqit
**       AND    iblno  EQ space ).
**
** >I/V 누적수량(선급수량).
*    IF NOT p_it_bl-reqno IS INITIAL.
*      SELECT  SUM( remng ) SUM( ivamti )
*        INTO  (p_it_bl-ppmngs, p_it_bl-ppamts)
*        FROM  ztiviv00
**       WHERE  reqno  EQ p_it_bl-reqno
**         AND  reqit  EQ p_it_bl-reqit
*       WHERE  ebeln  EQ p_it_bl-ebeln
*         AND  ebelp  EQ p_it_bl-ebelp
*         AND  reqno  EQ p_it_bl-reqno
*         AND  reqit  EQ p_it_bl-reqit
*         AND ( prpyn EQ c_charp
*          OR   prpyn EQ c_charr ).
*    ENDIF.
*************************************************



*   i/v 가능수량.
*    p_it_bl-ivmngl =  p_it_bl-menge - p_it_bl-ivmngs.
    P_IT_BL-IVMNGL =  P_IT_BL-MENGE - P_IT_BL-IVMNGS - P_IT_BL-PPMNGS.
*    p_it_bl-refwr  =  p_it_bl-refwr - p_it_bl-refwrs.
    P_IT_BL-REFWR  =  P_IT_BL-REFWR - P_IT_BL-REFWRS - P_IT_BL-PPAMTS.

    IF P_IT_BL-IVMNGL LE C_ZERO.
*-<< SRM2012-09505 - 분할 송장용 로직 추가
      IF ( SY-UNAME EQ 'C526812' OR "엠트론 사용자 한정
           SY-UNAME EQ 'C526806' OR
           SY-UNAME EQ 'C526811' OR
           SY-UNAME(4) EQ 'ZLSG'  ).
        DELETE P_IT_BL INDEX G_TABIX.
        CONTINUE.
      ELSE.
        IF P_DELETE EQ C_TRUE.
          DELETE P_IT_BL INDEX G_TABIX.
          CONTINUE.
        ELSE.
          P_IT_BL-BLMNG = 0.
        ENDIF.
      ENDIF.
*      IF P_DELETE EQ C_TRUE.
*        DELETE P_IT_BL INDEX G_TABIX.
*        CONTINUE.
*      ELSE.
*        P_IT_BL-BLMNG = 0.
*      ENDIF.
*-->> SRM2012-09505
    ELSE.
      ADD 1 TO G_CNT.
    ENDIF.

    ADD 1 TO G_COUNT.
    P_IT_BL-INDEX = G_COUNT.
    MODIFY P_IT_BL INDEX G_TABIX.

    MOVE P_IT_BL-IBLNO TO P_IT_BLNUM-IBLNO.
    COLLECT P_IT_BLNUM.
  ENDLOOP.

  DESCRIBE TABLE P_IT_BL LINES G_LINE.
  IF G_LINE EQ 0.
    MESSAGE ID 'ZMTI00' TYPE P_MTYPE NUMBER 902.
    EXIT.
  ENDIF.

  IF G_CNT EQ 0.
    MESSAGE ID 'ZMTI00' TYPE P_MTYPE NUMBER 103.
  ENDIF.

ENDFORM.                    " GET_available_bl_ITEM

*&---------------------------------------------------------------------*
*&      Form  get_available_lc_item
*&---------------------------------------------------------------------*
*       B/L을 입력할 수입의뢰 잔량을 체크함.
*----------------------------------------------------------------------*
FORM GET_AVAILABLE_LC_ITEM  TABLES   PT_ZTISRQIT STRUCTURE IT_ZTISRQIT
                                     PT_REQNO    STRUCTURE IT_REQNO
                            USING    P_MSGTY
                                     P_DEL_MODE.
  DATA: L_REMNG  LIKE ZTITIVP-REMNG.

  CLEAR: G_COUNT, G_CNT.

  LOOP AT PT_ZTISRQIT.
    G_TABIX = SY-TABIX.
    CLEAR: L_REMNG.
*> 무환일 경우 삭제함.
    IF PT_ZTISRQIT-REPOS EQ C_FALSE.
      DELETE PT_ZTISRQIT INDEX G_TABIX.
      CONTINUE.
    ENDIF.

    IF NOT PT_ZTISRQIT-EBELN IS INITIAL.
      SELECT  SUM( REMNG ) INTO PT_ZTISRQIT-IVMNGS
        FROM  ZTITIVP
       WHERE  EBELN  EQ PT_ZTISRQIT-EBELN
         AND  EBELP  EQ PT_ZTISRQIT-EBELP
         AND  REQNO  EQ PT_ZTISRQIT-REQNO
         AND  REQIT  EQ PT_ZTISRQIT-REQIT.
*         and  iblno  eq space.
*
      PT_ZTISRQIT-REMNG =  PT_ZTISRQIT-RQMNG - PT_ZTISRQIT-IVMNGS.

      IF PT_ZTISRQIT-REMNG LE C_ZERO.
        IF P_DEL_MODE EQ C_TRUE.
          DELETE PT_ZTISRQIT INDEX G_TABIX.
          CONTINUE.
        ELSE.
          PT_ZTISRQIT-REMNG = 0.
        ENDIF.
      ELSE.
        ADD 1 TO G_CNT.
      ENDIF.

      PT_ZTISRQIT-IVMNGL =  PT_ZTISRQIT-REMNG.

*> Tree용 Internal table modify.
      ADD 1 TO G_COUNT.
      PT_ZTISRQIT-INDEX = G_COUNT.
      MODIFY PT_ZTISRQIT INDEX G_TABIX.

*> 수입의뢰관리번호별 collect.
      MOVE PT_ZTISRQIT-REQNO TO PT_REQNO-REQNO.
      COLLECT PT_REQNO.
    ENDIF.
  ENDLOOP.

  DESCRIBE TABLE PT_ZTISRQIT LINES G_LINE.
  IF G_LINE EQ 0.
    MESSAGE ID 'ZMTI00' TYPE P_MSGTY NUMBER 902.
    EXIT.
  ENDIF.

  IF G_CNT EQ 0.
*    MESSAGE ID 'ZMTI00' TYPE c_warning NUMBER 103.
    MESSAGE ID 'ZMTI00' TYPE P_MSGTY NUMBER 103.
  ENDIF.

ENDFORM.                    " get_available_lc_item
*&---------------------------------------------------------------------*
*&      Form  p8120_change_document
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM P8120_CHANGE_DOCUMENT .

  DATA: L_OBJECTID              TYPE CDHDR-OBJECTID,
        L_TCODE                 TYPE CDHDR-TCODE,
        L_UTIME                 TYPE CDHDR-UTIME,
        L_UDATE                 TYPE CDHDR-UDATE,
        L_USERNAME              TYPE CDHDR-USERNAME,
        L_CDOC_UPD_OBJECT       TYPE CDHDR-CHANGE_IND,
        L_UPD_ICDTXT            TYPE CHAR1,
        L_UPD                   TYPE CHAR1,
*        l_upd                   TYPE char1,
        LT_CDTXT                TYPE STANDARD TABLE OF CDTXT
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

  L_OBJECTID(10) = ZTITIVK+3(10).

  L_TCODE        = SY-TCODE.
  L_UTIME        = SY-TIMLO.
  L_UDATE        = SY-DATLO.
  L_USERNAME     = SY-UNAME.

  IF G_MODE EQ C_CHARC.  ">생성모드일 경우.
    REFRESH : YZTITIVP, YZTITIVV.
  ENDIF.

  LOOP AT XZTITIVP.
    XZTITIVP-KZ = L_UPD.
    MODIFY XZTITIVP.
  ENDLOOP.

  LOOP AT XZTITIVV.
    XZTITIVV-KZ = L_UPD.
    MODIFY XZTITIVV.
  ENDLOOP.


*  CALL FUNCTION 'ZTILCCHDOC_WRITE_DOCUMENT' IN UPDATE TASK
  CALL FUNCTION 'ZTIIVCHDOC_WRITE_DOCUMENT'
    EXPORTING
      OBJECTID                      = L_OBJECTID
      TCODE                         = L_TCODE
      UTIME                         = L_UTIME
      UDATE                         = L_UDATE
      USERNAME                      = L_USERNAME
*   PLANNED_CHANGE_NUMBER         = ' '
      OBJECT_CHANGE_INDICATOR       = L_CDOC_UPD_OBJECT
*   PLANNED_OR_REAL_CHANGES       = ' '
*   NO_CHANGE_POINTERS            = ' '
*   UPD_ICDTXT_ZTIIVCHDOC         = ' '
      N_ZTITIVK                    = ZTITIVK
      O_ZTITIVK                    = *ZTITIVK
      UPD_ZTITIVK                  = L_UPD
      UPD_ZTITIVP                  = L_UPD
      UPD_ZTITIVV                  = L_UPD
    TABLES
      ICDTXT_ZTIIVCHDOC             = LT_CDTXT
      XZTITIVP                     = XZTITIVP
      YZTITIVP                     = YZTITIVP
      XZTITIVV                     = XZTITIVV
      YZTITIVV                     = YZTITIVV.


ENDFORM.                    " p8120_change_document
*&---------------------------------------------------------------------*
*&      Form  call_print_process
*&---------------------------------------------------------------------*
FORM CALL_PRINT_PROCESS .

*> GET OUTPUT OPTIONS
  IF IT_PRTCTL[] IS INITIAL.
    REFRESH : IT_PRTCTL.
    CLEAR: IT_PRTCTL.
*    IF NOT ZTITRQK-opnbk IS INITIAL.   ">Openning bank.
*      SELECT lifnr name1 land1 spras telfx adrnr
*      INTO CORRESPONDING FIELDS OF TABLE it_prtctl
*      FROM lfa1
*      WHERE lifnr IN ( SELECT lifnr
*                       FROM ZTItig04
*                       WHERE epart EQ ZTITRQK-opnbk ).
*    ENDIF.
    DESCRIBE TABLE IT_PRTCTL LINES G_LINE.
    IF G_LINE EQ C_ZERO.
      CLEAR: IT_PRTCTL.
      MOVE: T001-LAND1    TO    IT_PRTCTL-LAND1,
            SY-LANGU      TO    IT_PRTCTL-SPRAS.
      APPEND IT_PRTCTL.
    ENDIF.
  ENDIF.

*> Get Output Paramenters
  PERFORM GET_OUTPUT_INFORMATION TABLES IT_PRTCTL
                                 USING  G_ANSWER.
  IF G_ANSWER EQ C_Y.

    LOOP AT IT_PRTCTL WHERE FLAG EQ C_TRUE.
**> Get SMARTFORM NAME
*      PERFORM p7000_set_smart_form_name USING 'IV'
*                                              '00'
*                                              it_prtctl-docty
*                                              g_ssf_name.
**> GET THE SMART FORM'S FUNCTION MODULE
*      PERFORM get_smart_form_name    USING  g_ssf_name
*                                            g_func_mod_name.
*
**> Set Output Paramenters
*      PERFORM set_output_information USING it_prtctl.
**> Call SmartForms functions
*      PERFORM call_smartforms_functioins USING g_func_mod_name.
**> Call SmartForms functions
*      PERFORM exec_external_sending USING it_prtctl.
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
  DATA: L_EINDT  LIKE EKET-EINDT.

  LOOP AT IT_TAB INTO G_TC_2130_WA.
*> 정가 계산.
    IF ZTITIVK-PRPYN EQ C_CHARI.
      CALL FUNCTION 'Z_TI_CALC_ITEM_AMOUNT'
        EXPORTING
          PEINH = G_TC_2130_WA-PEINH
          BPUMZ = G_TC_2130_WA-BPUMZ
          BPUMN = G_TC_2130_WA-BPUMN
          MENGE = G_TC_2130_WA-IVMNG
          NETPR = G_TC_2130_WA-NETPR
        CHANGING
          NETWR = G_TC_2130_WA-NETWR.

      IF SY-DYNNR           EQ C_SCR0100.
        IF G_TC_2130_WA-NETWR NE G_TC_2130_WA-REFWR.
          G_TC_2130_WA-NETWR = G_TC_2130_WA-REFWR.
        ENDIF.
      ENDIF.

      IF G_TC_2130_WA-REFWR IS INITIAL OR
         SY-DYNNR           EQ C_SCR0100.
        G_TC_2130_WA-REFWR = G_TC_2130_WA-NETWR.
      ENDIF.
    ENDIF.
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

*>Get 납품일.
    CLEAR: L_EINDT.
    SELECT MIN( EINDT ) INTO L_EINDT
      FROM EKET
     WHERE EBELN EQ G_TC_2130_WA-EBELN
       AND EBELP EQ G_TC_2130_WA-EBELP.

    IF L_EINDT IS INITIAL.
      CLEAR G_TC_2130_WA-EEIND.
    ELSE.
      WRITE L_EINDT TO G_TC_2130_WA-EEIND.
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

  IF ZTITIVK-LIFNR IS INITIAL.
    CLEAR: LFA1.
  ELSE.
    SELECT SINGLE * FROM LFA1
     WHERE LIFNR EQ ZTITIVK-LIFNR.
    IF SY-SUBRC NE 0.
      PERFORM MESSAGE_NOT_FOUND_VENDOR USING 'ZTITIVK'
                                             'LIFNR'
                                             P_MSGTY.
    ENDIF.
  ENDIF.
***************************************************************
* 2009.02.27 simcho by 오민석K
* 수입반품 송장생성 logic변경
*** 43436 추가 시작

  CLEAR G_AFTYN.
  PERFORM GET_AFTYN USING ZTITIVK-EBELN CHANGING G_AFTYN.

*** 43436 추가 끝

  IF ZTITBLK-BLDTY NE 'A' AND
     ZTITBLK-BLDTY NE 'B' AND
     ( ZTITBLK-BLDTY NE 'C' OR G_AFTYN NE 'A' ). "43436 추가
***************************************************************
    IF ZTITIVK-OPNBK IS INITIAL.
      PERFORM NO_INPUT_CHECK USING 'ZTITIVK' 'OPNBK' C_ERROR.
    ENDIF.
    SELECT SINGLE *
      FROM ZTSTIG3
     WHERE PARTI EQ C_CHARB
       AND EPART EQ ZTITIVK-OPNBK
       AND BUKRS EQ ZTITIVK-BUKRS.
    IF SY-SUBRC NE 0.
      IF SY-DYNNR EQ C_SCR0100 OR
         SY-DYNNR EQ C_SCR0200.
        MESSAGE S918 WITH ZTITIVK-OPNBK.
      ELSE.
        MESSAGE E918 WITH ZTITIVK-OPNBK.
      ENDIF.
    ENDIF.


  ENDIF.

ENDFORM.                    " get_Import_vendors_text
*&---------------------------------------------------------------------*
*&      Form  check_iv_sub_document_exist
*&---------------------------------------------------------------------*
*       하위문서 존재여부 체크.
*----------------------------------------------------------------------*
FORM CHECK_IV_SUB_DOCUMENT_EXIST  USING    P_IVONO
                                           P_RBLGP
                                           P_MSGTY
                                           P_SUBRC.
  DATA: L_COUNT TYPE I.

  CLEAR: P_SUBRC.

  CHECK NOT P_IVONO IS INITIAL.

*> Notice 문서 체크.
  SELECT COUNT( * ) INTO L_COUNT
    FROM ZTITPNP
   WHERE IVONO   EQ  P_IVONO
     AND RBLGP   EQ  P_RBLGP.
  IF L_COUNT GT C_ZERO.
    IF P_MSGTY NE C_NONE.
      MESSAGE ID 'ZMTI00' TYPE P_MSGTY NUMBER '109' WITH 'Notice'.
    ENDIF.
    P_SUBRC = 4.
    EXIT.
  ENDIF.

ENDFORM.                    " check_iv_sub_document_exist
*&---------------------------------------------------------------------*
*&      Form  SET_INITIAL_VALUE
*&---------------------------------------------------------------------*
FORM SET_INITIAL_VALUE .

*> 문서 종류.
  G_DOCUMENT = C_IV.

  REFRESH: IT_TAB, IT_ZTITIVH, IT_ZTITIVV,
           XZTITIVP, YZTITIVP,
           XZTITIVV, YZTITIVV.

*
  CLEAR :  IT_TAB, IT_ZTITIVH, IT_ZTITIVV,
           XZTITIVP, YZTITIVP,
           XZTITIVV, YZTITIVV,
           ZTITIVK,     ">수입의뢰 Header
          *ZTITIVK,    ">수입의뢰 Header
           LFA1,
          *LFA1,
           OK_CODE_POPUP.

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
* 20070326 simcho by 박혁세 K
* page down 후 double click시 오류 수정
*****************************************************************
      IF SY-TCODE = 'ZTIT303'.
        G_FINDLINE = TC_2130-TOP_LINE + G_FINDLINE - 1.
      ENDIF.
*****************************************************************

      READ TABLE IT_TAB INTO G_TC_2130_WA INDEX G_FINDLINE.
      IF SY-SUBRC NE 0.
        EXIT.
      ENDIF.
      CHECK OK_CODE EQ 'ZTISELECT'.   ">문서선택.

      CASE G_FIELDNAME.

        WHEN 'ZTISIVIT-IBLNO' OR 'ZTISIVIT-IBLIT'.
          PERFORM DISPLAY_BL_DOCUMENT    USING G_TC_2130_WA-IBLNO
                                               G_TC_2130_WA-IBLIT.
        WHEN 'ZTISIVIT-REQNO' OR 'ZTISIVIT-REQIT'.
          PERFORM DISPLAY_IMPORT_DOCUMENT USING G_TC_2130_WA-REQNO
                                                G_TC_2130_WA-REQIT
                                                '00000'.
        WHEN 'ZTISIVIT-EBELN' OR 'ZTISIVIT-EBELP'.
          PERFORM DISPLAY_PURCHASE_ORDER USING G_TC_2130_WA-EBELN
                                               G_TC_2130_WA-EBELP.
        WHEN 'ZTISIVIT-MATNR'.
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
        WHEN 'ZTITIVK-LIFNR'.
          PERFORM DISPLAY_VENDOR_MASTER USING ZTITIVK-LIFNR
                                              ZTITIVK-EKORG.
        WHEN 'ZTITIVK-BELNR'.
          PERFORM DISPLAY_LIV_DOCUMENT  USING ZTITIVK-BELNR
                                              ZTITIVK-GJAHR
                                              ZTITIVK-BUKRS.
      ENDCASE.
    ENDIF.
  ENDIF.

ENDFORM.                    " double_click_event
*&---------------------------------------------------------------------*
*&      Form  set_item_number_build
*&---------------------------------------------------------------------*
*       아이템 번호를 생성함.
*----------------------------------------------------------------------*
FORM SET_ITEM_NUMBER_BUILD  TABLES   P_IT_TAB   LIKE      IT_TAB
                            USING    P_ZTITIVK STRUCTURE ZTITIVK.

  DATA: L_LPONR LIKE P_ZTITIVK-LPONR.

  IF G_MODE EQ C_CHARC.
    CLEAR: L_LPONR.
    LOOP AT P_IT_TAB.
      ADD 1 TO L_LPONR.
      MOVE L_LPONR TO P_IT_TAB-RBLGP.
      MODIFY P_IT_TAB.
    ENDLOOP.
    MOVE L_LPONR TO P_ZTITIVK-LPONR.
  ELSE.
    CLEAR: G_LINES.
    LOOP AT P_IT_TAB.
      IF NOT P_IT_TAB-RBLGP IS INITIAL.
        PERFORM CHECK_IV_SUB_DOCUMENT_EXIST USING P_IT_TAB-IVONO
                                                  P_IT_TAB-RBLGP
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
          ADD 1 TO P_ZTITIVK-LPONR.
          MOVE P_ZTITIVK-LPONR TO P_IT_TAB-RBLGP.
        ENDIF.
        MODIFY P_IT_TAB.
      ENDLOOP.
    ELSE.
      CLEAR: L_LPONR.
      LOOP AT P_IT_TAB.
        ADD 1 TO L_LPONR.
        MOVE L_LPONR TO P_IT_TAB-RBLGP.
        MODIFY P_IT_TAB.
      ENDLOOP.
      MOVE L_LPONR TO P_ZTITIVK-LPONR.
    ENDIF.
  ENDIF.
  CLEAR: L_LPONR.
  LOOP AT P_IT_TAB.
    IF P_IT_TAB-RBLGP GT L_LPONR.
      MOVE P_IT_TAB-RBLGP TO L_LPONR.
    ENDIF.
  ENDLOOP.
  MOVE L_LPONR TO P_ZTITIVK-LPONR.

ENDFORM.                    " set_item_number_build
*&---------------------------------------------------------------------*
*&      Form  set_function_by_BUSINESS
*&---------------------------------------------------------------------*
FORM SET_FUNCTION_BY_BUSINESS .

  IF G_DOCUMENT EQ C_IV.
    IF ZTITIVK-LIVST NE C_CHARP.
      MOVE 'ZTIACDOC'     TO FTAB-FCODE.   APPEND FTAB. ">후속문서.
      MOVE 'ZTIMMDOC'     TO FTAB-FCODE.   APPEND FTAB. ">송장문서.
    ENDIF.

    MOVE 'ZTITAX'  TO FTAB-FCODE.   APPEND FTAB. " <계산서매핑
    MOVE 'ZTITAXC' TO FTAB-FCODE.   APPEND FTAB. " <계산서매핑

  ENDIF.

  IF G_DOCUMENT EQ C_GR.
    IF ZTITGRK-IGRST NE C_CHARG.
      MOVE 'ZTIACDOC'     TO FTAB-FCODE.   APPEND FTAB. ">후속문서.
      MOVE 'ZTIMMDOC'     TO FTAB-FCODE.   APPEND FTAB. ">송장문서.
    ENDIF.

    MOVE 'ZTITAX'  TO FTAB-FCODE.   APPEND FTAB. " <계산서매핑
    MOVE 'ZTITAXC' TO FTAB-FCODE.   APPEND FTAB. " <계산서매핑

  ENDIF.


ENDFORM.                    " set_function_by_BUSINESS
*&---------------------------------------------------------------------*
*&      Form  read_iv_item_data
*&---------------------------------------------------------------------*
FORM READ_IV_ITEM_DATA  CHANGING P_IT_TAB  LIKE IT_TAB.

  CLEAR G_TC_2130_WA.
  LOOP AT P_IT_TAB INTO G_TC_2130_WA.
*     p/o정보.
    SELECT SINGLE WERKS NAME1 LGORT MATNR TXZ01
           LOEKZ ELIKZ BPRME BPUMZ BPUMN
           UMREZ UMREN NETPR PEINH UEBTO UEBTK UNTTO
*        INTO (p_it_tab-werks, p_it_tab-name1, p_it_tab-lgort,
*              p_it_tab-matnr, p_it_tab-txz01,
*              p_it_tab-loekz, p_it_tab-elikz, p_it_tab-bprme,
*              p_it_tab-bpumz, p_it_tab-bpumn, p_it_tab-umrez,
*              p_it_tab-umren, p_it_tab-netpr, p_it_tab-peinh,
*              p_it_tab-uebto, p_it_tab-uebtk, p_it_tab-untto)
      INTO  CORRESPONDING FIELDS OF G_TC_2130_WA
      FROM  ZTIVPO00
     WHERE  EBELN  = G_TC_2130_WA-EBELN
       AND  EBELP  = G_TC_2130_WA-EBELP.

*     bl 정보 수량.
    SELECT  SINGLE BLMNG
      INTO  G_TC_2130_WA-MENGE
      FROM  ZTITBLP
     WHERE  IBLNO  = G_TC_2130_WA-IBLNO
       AND  IBLIT  = G_TC_2130_WA-IBLIT.


**************************************************
* 2008.06.10 simcho by 박혁세K
* 엠트론 test시 오류 발견
* 송장수량 계산 시 필드교체 remng -> ivmng
**************************************************
*     i/v 누적수량.
    SELECT  SUM( IVMNG ) INTO G_TC_2130_WA-IVMNGS FROM ZTITIVP
     WHERE  IBLNO  = G_TC_2130_WA-IBLNO
       AND  IBLIT  = G_TC_2130_WA-IBLIT.

**     i/v 누적수량.
*    SELECT  SUM( remng ) INTO g_tc_2130_wa-ivmngs FROM ztitivp
*     WHERE  iblno  = g_tc_2130_wa-iblno
*       AND  iblit  = g_tc_2130_wa-iblit.
**************************************************


*     i/v 가능수량.
    G_TC_2130_WA-IVMNGL = G_TC_2130_WA-MENGE - G_TC_2130_WA-IVMNGS.


    MODIFY P_IT_TAB FROM G_TC_2130_WA INDEX SY-TABIX.
  ENDLOOP.

ENDFORM.                    " read_iv_item_data
*&---------------------------------------------------------------------*
*&      Form  SET_INVOICE_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM SET_INVOICE_DATA .

  TABLES: TCURC.
  DATA  : L_PKCHG LIKE ZTITIVK-PKCHG.
  DATA  : L_REMNG LIKE G_TC_2130_WA-REMNG.
  DATA  : L_ITEM  LIKE ITEMDATA.
*  DATA  : l_LBLNI LIKE ESSR-LBLNI.

  G_ANSWER = C_CHARY.

  FREE:  ITEMDATA,      TAXDATA,          WITHTAXDATA,
         RETURN,        ACCOUNTINGDATA,   VENDORITEMSPLITDATA,
         GLACCOUNTDATA, MATERIALDATA.


  CLEAR: HEADERDATA,    INVOICEDOCNUMBER, FISCALYEAR,
         ADDRESSDATA,
         ITEMDATA,      TAXDATA,          WITHTAXDATA,
         RETURN,        ACCOUNTINGDATA,   VENDORITEMSPLITDATA,
         GLACCOUNTDATA, MATERIALDATA.

*iso code용.
  SELECT SINGLE *
    FROM TCURC
   WHERE WAERS EQ ZTITIVK-WAERS.

***>>>>>>>>>>>>header data
  IF ZTITIVK-VORGANG EQ C_CHAR1 OR ZTITIVK-VORGANG EQ C_CHAR3 .
    MOVE C_TRUE  TO HEADERDATA-INVOICE_IND."지시자: 송장전기
  ELSE.
    MOVE C_FALSE  TO HEADERDATA-INVOICE_IND.
  ENDIF.

  MOVE  ZTITIVK-BLART TO  HEADERDATA-DOC_TYPE.  "전표유형
  MOVE  ZTITIVK-BLDAT TO  HEADERDATA-DOC_DATE.  "전표증빙일
  MOVE  ZTITIVK-BUDAT TO  HEADERDATA-PSTNG_DATE."전표의 전기일
  MOVE  ZTITIVK-XBLNR TO  HEADERDATA-REF_DOC_NO."참조전표번호
  MOVE  ZTITIVK-BUKRS TO  HEADERDATA-COMP_CODE. "회사코드
*  MOVE  ztitivk-lifnr TO  headerdata-diff_inv.  "다른 송장발행처
  MOVE  ZTITIVK-APVEN TO  HEADERDATA-DIFF_INV.  "다른 송장발행처
  MOVE  ZTITIVK-WAERS TO  HEADERDATA-CURRENCY.  "통화키
  MOVE  TCURC-ISOCD   TO  HEADERDATA-CURRENCY_ISO."ISO 통화코드

  IF ZTITIVK-WAERS NE T001-WAERS.
    MOVE  ZTITIVK-KURSF TO  HEADERDATA-EXCH_RATE. "직접호가환율*
*    headerdata-EXCH_RATE_V."간접호가환율
  ENDIF.
  WRITE : ZTITIVK-IVAMP TO G_TEXT_AMOUNT CURRENCY ZTITIVK-WAERS.
  PERFORM SET_WRITE_NO_MASK   USING G_TEXT_AMOUNT.
  MOVE  G_TEXT_AMOUNT TO  HEADERDATA-GROSS_AMOUNT."총송장금액
*  headerdata-CALC_TAX_IND."세금을 자동으로 계산
  MOVE  ZTITIVK-ZTERM TO  HEADERDATA-PMNTTRMS.  "지급조건키
  MOVE  ZTITIVK-ZFBDT TO  HEADERDATA-BLINE_DATE."만기계산기준일

**************************************************************
*> SB, Kang [ 05/03/11 ] : 지급조건키만 넘기도록 수정
*>    Why? Standard에서 양쪽의 값이 들어오면 오류발생함.
**************************************************************
*  MOVE  ztitivk-zbd1t TO  headerdata-dsct_days1."현금할인기간 1
*  MOVE  ztitivk-zbd2t TO  headerdata-dsct_days2."현금 할인기간 2
*  MOVE  ztitivk-zbd3t TO  headerdata-netterms.  "순액지급조건기간
*  MOVE  ztitivk-zbd1p TO  headerdata-dsct_pct1. "현금할인율 1
*  MOVE  ztitivk-zbd2p TO  headerdata-dsct_pct2. "현금할인율 1
**************************************************************

*  headerdata-IV_CATEGORY."물류송장검증 문서의 원본
  MOVE  ZTITIVK-BKTXT TO  HEADERDATA-HEADER_TXT."전표헤더텍스트
  MOVE  ZTITIVK-ZLSPR TO  HEADERDATA-PMNT_BLOCK."지급보류키

*>비계획운송비용.
  CLEAR L_PKCHG.
  L_PKCHG  =
  ZTITIVK-PKCHG + ZTITIVK-HDCHG + ZTITIVK-OTCHG.
*  ZTITIVK-pkchg + ZTITIVK-hdchg + ZTITIVK-otchg + ZTITIVK-rtchg.
  WRITE : L_PKCHG TO G_TEXT_AMOUNT CURRENCY ZTITIVK-WAERS.
  PERFORM SET_WRITE_NO_MASK   USING G_TEXT_AMOUNT.
  MOVE  G_TEXT_AMOUNT TO  HEADERDATA-DEL_COSTS."비계획운송비용
*  headerdata-DEL_COSTS_TAXC."운송비용 세금코드
*  headerdata-DEL_COSTS_TAXJ."운송비용에 대한 조세관할코드
  MOVE  SY-UNAME       TO  HEADERDATA-PERSON_EXT."외부시스템 사용자.
  MOVE  ZTITIVK-ZLSCH TO  HEADERDATA-PYMT_METH. "지급방법
  MOVE  ZTITIVK-UZAWE TO  HEADERDATA-PMTMTHSUPL."지급방법보충
  MOVE  ZTITIVK-BELNR TO  HEADERDATA-INV_DOC_NO."송장문서문서번호
*  headerdata-SCBANK_IND."중앙은행지시자
*  headerdata-SUPCOUNTRY."공급국가
*  headerdata-BLLSRV_IND."서비스지시자 (해외지급)
  MOVE  ZTITIVK-XBLNR TO  HEADERDATA-REF_DOC_NO_LONG."참조전표번호
*  headerdata-DSCT_AMOUNT."문서통화의 현금할인액
*  headerdata-PO_SUB_NO."POR 서명자번호
*  headerdata-PO_CHECKDG."POR 점검숫자
*  headerdata-PO_REF_NO."POR 참조번호
*  headerdata-PAYEE_PAYER."수취인 / 지급인
*  headerdata-PARTNER_BK."거래처은행유형

*>거래은행에 대한 단축키.
  SELECT SINGLE *
      FROM ZTSTIG3
     WHERE PARTI EQ C_CHARB
       AND EPART EQ ZTITIVK-OPNBK
       AND BUKRS EQ ZTITIVK-BUKRS.
  IF SY-SUBRC      EQ 0 AND
     NOT ZTSTIG3-HBKID IS INITIAL.
    MOVE ZTSTIG3-HBKID TO HEADERDATA-HOUSEBANKID.
  ENDIF.

  MOVE ZTITIVK-ZUONR TO HEADERDATA-ALLOC_NMBR.       "지정번호
*  headerdata-PAYMT_REF."지급참조
*  headerdata-INV_REF_NO."송장참조: 송장참조를 위한 문서번호
*  headerdata-INV_YEAR."관련송장의 회계연도 (대변메모)
*  headerdata-INV_REC_DATE."송장수령일
*  headerdata-PLANNING_LEVEL."계획레벨
*  headerdata-PLANNING_DATE."계획일
*  headerdata-FIXEDTERMS."고정지급조건
  MOVE  ZTITIVK-GSBER TO  HEADERDATA-BUS_AREA.  "사업영역
*  headerdata-LOT_NUMBER."전표 로트번호
  MOVE  ZTITIVK-SGTXT TO  HEADERDATA-ITEM_TEXT. "항목텍스트

*> 분할금액이 있을 경우.
  DESCRIBE TABLE IT_ZTITIVV LINES G_LINE.
  CLEAR: G_COUNT.
  IF G_LINE GT 0.
*  IF NOT ZTITIVK-rtchg IS INITIAL.
    LOOP AT IT_ZTITIVV.
      WRITE : IT_ZTITIVV-SPLAM TO G_TEXT_AMOUNT CURRENCY ZTITIVK-WAERS.
      PERFORM SET_WRITE_NO_MASK   USING G_TEXT_AMOUNT.
      MOVE: IT_ZTITIVV-SPLIT TO VENDORITEMSPLITDATA-SPLIT_KEY,
            G_TEXT_AMOUNT    TO VENDORITEMSPLITDATA-SPLIT_AMOUNT,
            IT_ZTITIVV-ZLSCH TO VENDORITEMSPLITDATA-PYMT_METH,
            IT_ZTITIVV-MWSKZ TO VENDORITEMSPLITDATA-TAX_CODE,
            IT_ZTITIVV-UZAWE TO VENDORITEMSPLITDATA-PMTMTHSUPL,
            IT_ZTITIVV-ZTERM TO VENDORITEMSPLITDATA-PMNTTRMS.
      APPEND VENDORITEMSPLITDATA.
    ENDLOOP.
  ENDIF.

*>>>>>>>>>>>>>>>item.
  LOOP AT IT_TAB INTO G_TC_2130_WA WHERE EBELN NE SPACE.
*    CALL FUNCTION 'ME_READ_HISTORY'
*      EXPORTING
*        ebeln                    = g_tc_2130_wa-ebeln
*        EBELP                    = g_tc_2130_wa-ebelp
*        webre                    =
**       I_BYPASSING_BUFFER       =
**       I_REFRESH_BUFFER         =
**     TABLES
**       XEKBE                    =
**       XEKBES                   =
**       XEKBEZ                   =
**       XEKBNK                   =
**       XEKBZ                    =
*              .
*

*    MOVE g_tc_2130_wa-rblgp TO  itemdata-invoice_doc_item.
    "송장문서의 문서품목
    MOVE G_TC_2130_WA-EBELN TO ITEMDATA-PO_NUMBER.  "구매오더번호
    MOVE G_TC_2130_WA-EBELP TO ITEMDATA-PO_ITEM.    "구매문서 품목번호
*        itemdata-REF_DOC"참조문서의 문서번호
*        itemdata-REF_DOC_YEAR"현재기간 회계연도
*        itemdata-REF_DOC_IT"참조문서품목
    MOVE G_TC_2130_WA-TBTKZ TO ITEMDATA-DE_CRE_IND. "후속 차변/대변
    MOVE G_TC_2130_WA-MWSKZ TO ITEMDATA-TAX_CODE.     "세금코드
*        itemdata-TAXJURCODE"세금계산 관할구역 - 조세관할코드

*    WRITE : g_tc_2130_wa-refwr TO g_text_amount CURRENCY ztitivk-waers.
    WRITE : G_TC_2130_WA-IVAMT TO G_TEXT_AMOUNT CURRENCY ZTITIVK-WAERS.
    PERFORM SET_WRITE_NO_MASK   USING G_TEXT_AMOUNT.
    MOVE G_TEXT_AMOUNT         TO  ITEMDATA-ITEM_AMOUNT."전표통화금액

************************************************************************
* 2009.05.29 결산 중 송장처리 수량 오류 긴급 수정
* g_tc_2130_wa-remng -> l_remng = g_tc_2130_wa-IVMNG.
* : 엠트론 허익한D 요청
************************************************************************
*> 송장처리수량 = 송장수량 - 선급수량.
*    l_remng = g_tc_2130_wa-remng - g_tc_2130_wa-ppmng.
    L_REMNG = G_TC_2130_WA-IVMNG.
*    l_remng = g_tc_2130_wa-remng.
************************************************************************

    IF L_REMNG LE C_ZERO.
      CONTINUE.
    ENDIF.

    WRITE : L_REMNG            TO G_TEXT_AMOUNT UNIT XZTITIVP-MEINS.
    PERFORM SET_WRITE_NO_MASK   USING G_TEXT_AMOUNT.
    MOVE G_TEXT_AMOUNT         TO  ITEMDATA-QUANTITY.   "수량
    MOVE G_TC_2130_WA-MEINS    TO  ITEMDATA-PO_UNIT.    "오더단위
*        itemdata-PO_UNIT_ISO"ISO 코드 오더단위

    SELECT SINGLE PEINH BPRME
      FROM EKPO
      INTO (ITEMDATA-PO_PR_QNT,ITEMDATA-PO_PR_UOM)
     WHERE EBELN EQ G_TC_2130_WA-EBELN
       AND EBELP EQ G_TC_2130_WA-EBELP.
*    MOVE    itemdata-PO_PR_QNT"구매오더가격단위의 수량
*    MOVE    itemdata-PO_PR_UOM"오더가격단위 BPRME

*        itemdata-PO_PR_UOM_ISO"ISO 코드의 구매오더 가격단위
*    MOVE xZTITIVP-kschl TO  itemdata-cond_type.  "조건유형
*    MOVE xZTITIVP-stunr TO  itemdata-cond_st_no. "단계번호
*    MOVE xZTITIVP-zaehk TO  itemdata-cond_count. "조건카운터
*        itemdata-SHEET_NO"입력서번호
    MOVE G_TC_2130_WA-SGTXT TO  ITEMDATA-ITEM_TEXT.  "항목텍스트
*        itemdata-FINAL_INV"최종송장지시자
*        itemdata-SHEET_ITEM"라인번호
*        itemdata-GRIR_CLEAR_SRV
*                      "외부서비스에 대한 GR/IR 전기의 반제지시자
*        itemdata-FREIGHT_VEN"구매처 또는 채권자 계정번호

***** 서비스 오더에 대한 로직.
*   입력서 번호 찾기.
    SELECT SINGLE LBLNI
      FROM ESSR
      INTO ITEMDATA-SHEET_NO
     WHERE EBELN EQ G_TC_2130_WA-EBELN
       AND EBELP EQ G_TC_2130_WA-EBELP.

*   입력서 번호가 있으면 수량/단위 clear.
    IF NOT ITEMDATA-SHEET_NO IS INITIAL.
      CLEAR : ITEMDATA-QUANTITY, ITEMDATA-PO_UNIT,
              ITEMDATA-PO_PR_QNT,ITEMDATA-PO_PR_UOM.
    ENDIF.
**********

    READ TABLE ITEMDATA INTO L_ITEM
                        WITH KEY PO_NUMBER = ITEMDATA-PO_NUMBER
                                 PO_ITEM   = ITEMDATA-PO_ITEM.
    IF SY-SUBRC EQ 0.
      ITEMDATA-PO_PR_QNT = 0.
    ENDIF.

    COLLECT ITEMDATA.
*    APPEND itemdata.
  ENDLOOP.

  CLEAR: G_COUNT.
  LOOP AT ITEMDATA.
    ADD 1 TO G_COUNT.
    ITEMDATA-INVOICE_DOC_ITEM = G_COUNT.
    MODIFY ITEMDATA.

    CLEAR: TAXDATA.
    MOVE: ITEMDATA-TAX_CODE TO TAXDATA-TAX_CODE,
          0                 TO TAXDATA-TAX_AMOUNT ,
          0                 TO TAXDATA-TAX_BASE_AMOUNT.
    COLLECT TAXDATA.
  ENDLOOP.

*  refresH: materialdata.
*  LOOP AT itemdata.
*    clear: materialdata.
*    SELECT SINGLE *
*      FROM ekpo
*     WHERE ebeln  EQ  itemdata-po_number
*       AND ebelp  EQ  itemdata-po_item.
*
*    SELECT SINGLE *
*      FROM t001w
*     WHERE werks  EQ  ekpo-werks.
*
*    SELECT SINGLE *
*      FROM t006
*     WHERE msehi  EQ  ekpo-lmein.
*
*    MOVE: itemdata-invoice_doc_item TO materialdata-invoice_doc_item,
*          ekpo-matnr                TO materialdata-material,
*          t001w-bwkey               TO materialdata-val_area,
*          ekpo-bwtar                TO materialdata-valuation_type,
*          itemdata-de_cre_ind       to materialdata-DB_CR_IND,
*          itemdata-item_amount      TO materialdata-item_amount,
*          itemdata-quantity         TO materialdata-quantity,
*          ekpo-lmein                TO materialdata-base_uom,
*          t006-isocode              TO materialdata-base_uom_iso,
*          itemdata-tax_code         TO materialdata-tax_code.
*    IF headerdata-invoice_ind EQ c_true.
*      materialdata-db_cr_ind = c_chars.
*    ELSE.
*      materialdata-db_cr_ind = c_charh.
*    ENDIF.
**materialdata-TAXJURCODE
**materialdata-MATERIAL_EXTERNAL
**materialdata-MATERIAL_GUID
**materialdata-MATERIAL_VERSION
*    APPEND materialdata.
*  ENDLOOP.

*  TABLES: /nfm/torderpos.
*  REFRESH: nfmetallitms.
*  LOOP AT itemdata.
*    SELECT *
*      INTO CORRESPONDING FIELDS OF TABLE nfm_torderpos
*      FROM /nfm/torderpos
*     WHERE blt     EQ c_charb   ">구매오더.
*       AND belnr   EQ itemdata-po_number
*       AND posnr   EQ itemdata-po_item
*       AND bukrs   EQ ztitivk-bukrs.
*
*    LOOP AT nfm_torderpos.
*      MOVE: itemdata-invoice_doc_item TO nfmetallitms-data_index,
*            nfm_torderpos-belnr       TO nfmetallitms-doc_number,
*            nfm_torderpos-posnr       TO nfmetallitms-itm_number,
*            nfm_torderpos-bukrs       TO nfmetallitms-compcode,
*            ztitivk-gjahr             TO nfmetallitms-fiscyear,
*            nfm_torderpos-nes         TO nfmetallitms-nfmkey,
*            nfm_torderpos-nfs         TO nfmetallitms-ratedetkey,
*            nfm_torderpos-neb         TO nfmetallitms-basekey,
*            nfm_torderpos-bsl         TO nfmetallitms-exchangekey,
*            nfm_torderpos-ndt         TO nfmetallitms-ratedetdat,
*            nfm_torderpos-nmo         TO nfmetallitms-ratemonth,
*            nfm_torderpos-kta         TO nfmetallitms-actratedat,
*            nfm_torderpos-nkn         TO nfmetallitms-rate,
*            nfm_torderpos-nkw         TO nfmetallitms-ratecurky,
**            nfm_torderpos-nkn   TO nfmetallitms-rate,
**            ztitcsk-waers       TO nfmetallitms-ratecurky,
**            tcurc-isocd         TO nfmetallitms-ratecurkyiso,
*            nfm_torderpos-nku         TO nfmetallitms-ratedoccur,
**            amounts-locamount   TO nfmetallitms-ratedoccur,
*            nfm_torderpos-fsp         TO nfmetallitms-invoicebl,
*            nfm_torderpos-bwr         TO nfmetallitms-bvaldoccur,
*            nfm_torderpos-bcu         TO nfmetallitms-bvalcurkyd,
**            ztitcsk-waers       TO nfmetallitms-bvalcurkyd,
**            tcurc-isocd         TO nfmetallitms-bvalcurkydiso,
**            nfmetallitms-rate   TO nfmetallitms-netrate,
*            nfm_torderpos-nno         TO nfmetallitms-netrate,
*            nfm_torderpos-bek         TO nfmetallitms-provider,
*            nfm_torderpos-eind        TO nfmetallitms-vendorcov,
*            nfm_torderpos-eds         TO nfmetallitms-coverageky,
*            nfm_torderpos-nbd         TO nfmetallitms-postingdays,
*            'I'                       TO nfmetallitms-updtype.
*      APPEND nfmetallitms.
*    ENDLOOP.
*  ENDLOOP.
*
*  CLEAR: taxdata.
**  taxdata-tax_code         =  ZTITIVK-mwskz. "부가가치세코드.
*  taxdata-tax_amount       =  0.     "전표통화세액.
*  taxdata-tax_base_amount  =  0.     "문서통화로 표시된 과세표준액.
*  APPEND taxdata.
*
ENDFORM.                    " SET_INVOICE_DATA
*&---------------------------------------------------------------------*
*&      Form  set_cancel_document_number
*&---------------------------------------------------------------------*
FORM SET_CANCEL_DOCUMENT_NUMBER USING P_ZTISSCRCOM STRUCTURE ZTISSCRCOM.
*> Set default value
  PERFORM FILL_ACCOUNT_HEADER_CANCEL USING P_ZTISSCRCOM.

  MOVE: ZTITIVK-BELNR   TO   P_ZTISSCRCOM-BELNR,
        ZTITIVK-GJAHR   TO   P_ZTISSCRCOM-GJAHR,
        ZTITIVK-BUKRS   TO   P_ZTISSCRCOM-BUKRS,
        ZTITIVK-BLART   TO   P_ZTISSCRCOM-BLART,
*        ztitivk-lifnr   TO   p_ztisscrcom-lifnr,
        ZTITIVK-APVEN   TO   P_ZTISSCRCOM-LIFNR,
        ZTITIVK-WAERS   TO   P_ZTISSCRCOM-WAERS,
        ZTITIVK-IVAMP   TO   P_ZTISSCRCOM-WRBTR.

  IF P_ZTISSCRCOM-CBUDAT IS   INITIAL.
    MOVE: SY-DATLO       TO   P_ZTISSCRCOM-CBUDAT.
  ENDIF.

  SPOP-TEXTLINE1 = '해당 송장문서를 취소하시겠습니까?'.

ENDFORM.                    " set_cancel_document_number
*&---------------------------------------------------------------------*
*&      Form  check_document_status
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM CHECK_DOCUMENT_STATUS .

  DATA: L_DDTEXT LIKE G_DDTEXT.

*> 문서상태 Fixed value read.
  PERFORM  DDIC_DOMAIN_VALUE_TEXT_READ USING 'ZTILIVST'
                                             SY-LANGU
                                             ZTITIVK-LIVST
                                             G_DDTEXT
                                             C_SUCCESS.
  L_DDTEXT = G_DDTEXT.

  CASE G_MODE.
    WHEN C_CHARP.    ">전기모드.
      IF ZTITIVK-LIVST EQ C_CHARP.
        MESSAGE E919 WITH G_DDTEXT.
      ENDIF.
    WHEN C_CHARR.    ">취소모드.
      IF ZTITIVK-LIVST EQ C_CHARN.
        MESSAGE E919 WITH G_DDTEXT.
      ENDIF.
    WHEN C_CHARM.    ">변경모드.
      IF ZTITIVK-LIVST EQ C_CHARP.
        MESSAGE E919 WITH G_DDTEXT.
      ENDIF.
    WHEN C_CHARD.    ">삭제모드.
      IF ZTITIVK-LIVST EQ C_CHARP.
        MESSAGE E919 WITH G_DDTEXT.
      ENDIF.
  ENDCASE.

  MESSAGE S922 WITH G_DDTEXT.

ENDFORM.                    " check_document_status
*&---------------------------------------------------------------------*
*&      Form  check_open_amount
*&---------------------------------------------------------------------*
FORM CHECK_OPEN_AMOUNT .
  DATA : L_RATE                TYPE F,
         L_TEXT_EXRATE(255)    TYPE C,
         L_FOREIGN_FACTOR(255) TYPE C,
         L_FACTOR              TYPE P,
         L_AMOUNT              TYPE ZTIOPAMT,
         L_PPAMT               TYPE ZTIPPAM2,
         L_FIXED_RATE          LIKE TCURS-SPRED,
         L_LOCAL_AMT           LIKE ZTITRQS-USAMT.  " USD 환산 Amount

  DATA: L_WEMNG        LIKE EKBES-WEMNG,
        L_REMNG        LIKE EKBES-REMNG,
        L_REMNG_TMP    LIKE EKBES-REMNG,
        L_WEWRT        LIKE EKBES-WEWRT,
        L_AREWR        LIKE EKBES-AREWR,
        L_REWRT        LIKE EKBES-REWRT.

  DATA BEGIN OF IEKBES OCCURS 0.
          INCLUDE STRUCTURE EKBES.
  DATA END OF IEKBES.

  DATA: BEGIN OF LT_MWSKZ OCCURS 0,
        MWSKZ    LIKE ZTITIVP-MWSKZ,
        END   OF LT_MWSKZ.

  CLEAR: LT_MWSKZ[], LT_MWSKZ.

  IF G_MODE EQ C_CHARC OR
     G_MODE EQ C_CHARM OR
     G_MODE EQ C_CHARP.
*> P/O 총금액 계산.
    PERFORM GET_TOTAL_PO_AMOUNT         TABLES GT_EKPO
                                        USING  ZTISSCRCOM-POAMT.
  ENDIF.

  CLEAR: G_WRBTR, L_PPAMT.
  LOOP AT IT_TAB INTO G_TC_2130_WA.
*>
    IF G_MODE EQ C_CHARC OR
       G_MODE EQ C_CHARM OR
       G_MODE EQ C_CHARP.

      IF ZTITIVK-EBELN IS INITIAL.
        ZTITIVK-EBELN = G_TC_2130_WA-EBELN.
      ENDIF.

      IF ZTITIVK-WERKS IS INITIAL.
        ZTITIVK-WERKS = G_TC_2130_WA-WERKS.
      ENDIF.

      IF ZTITIVK-BUPLA IS INITIAL.
        SELECT SINGLE J_1BBRANCH
          INTO ZTITIVK-BUPLA
          FROM T001W
         WHERE WERKS EQ G_TC_2130_WA-WERKS.
      ENDIF.

*> 전체구매오더 금액 대비 인보이스 품목 금액 비율.
      IF NOT G_TC_2130_WA-EBELN IS INITIAL.
        READ TABLE GT_EKPO WITH KEY EBELN = G_TC_2130_WA-EBELN
                                    EBELP = G_TC_2130_WA-EBELP.

        IF SY-SUBRC EQ 0.
*--> 구매오더보다 수량이 더클 경우.
          IF G_TC_2130_WA-PPAMT IS INITIAL.
            IF G_TC_2130_WA-REMNG GT G_TC_2130_WA-IVMNGL.
              G_TC_2130_WA-REMNG = G_TC_2130_WA-IVMNGL.
            ENDIF.
          ELSE.
            IF G_TC_2130_WA-NETWR GT GT_EKPO-NETWR.
              GT_EKPO-NETWR = G_TC_2130_WA-NETWR.
            ENDIF.
            IF G_TC_2130_WA-REMNG GT GT_EKPO-MENGE.
              GT_EKPO-MENGE = G_TC_2130_WA-REMNG.
            ENDIF.

            L_RATE = ( G_TC_2130_WA-REFWR - G_TC_2130_WA-PPAMT )
                     / GT_EKPO-NETWR.

            G_TC_2130_WA-REMNG = GT_EKPO-MENGE * L_RATE.

            IF G_TC_2130_WA-REMNG GT G_TC_2130_WA-IVMNGL.
              G_TC_2130_WA-REMNG = G_TC_2130_WA-IVMNGL.
            ENDIF.
          ENDIF.

          IF G_TC_2130_WA-EREKZ EQ C_TRUE.
*            g_tc_2130_wa-remng = g_tc_2130_wa-ivmngl.
            CLEAR IEKBES. REFRESH IEKBES.

            CALL FUNCTION 'ME_READ_HISTORY'
              EXPORTING
                EBELN              = G_TC_2130_WA-EBELN
                EBELP              = G_TC_2130_WA-EBELP
                WEBRE              = GT_EKPO-WEBRE
                I_BYPASSING_BUFFER = 'X'
                I_REFRESH_BUFFER   = 'X'
              TABLES
*                xekbe              = iekbe
                XEKBES             = IEKBES.
*                xekbez             = iekbez
*                xekbnk             = iekbnk
*                xekbz              = iekbz.
* Goods receipts
            CLEAR: L_WEMNG, L_REMNG,
                   L_WEWRT, L_AREWR, L_REWRT.

            LOOP AT IEKBES WHERE ZEKKN EQ SPACE
                             AND EBELP EQ  G_TC_2130_WA-EBELP.
              ADD IEKBES-WEMNG TO L_WEMNG.  ">입고
              ADD IEKBES-REMNG TO L_REMNG.  ">송장처리
              ADD IEKBES-REWRT TO L_REWRT.  ">입고금액
              ADD IEKBES-WEWRT TO L_WEWRT.  ">송장금액
              IF IEKBES-REWRT <> IEKBES-AREWR.
                ADD      IEKBES-REWRT TO   L_WEWRT.
                SUBTRACT IEKBES-AREWR FROM L_WEWRT.
              ENDIF.
            ENDLOOP.
            G_TC_2130_WA-REMNG = GT_EKPO-MENGE - L_REMNG.
            IF G_TC_2130_WA-REMNG GT G_TC_2130_WA-IVMNGL.
              G_TC_2130_WA-REMNG = G_TC_2130_WA-IVMNGL.
            ENDIF.
*            g_tc_2130_wa-refwr = gt_ekpo-netwr - l_wewrt.
          ENDIF.
        ENDIF.
      ENDIF.

*> Tax code.
      IF G_TC_2130_WA-MWSKZ IS INITIAL.
        G_TC_2130_WA-MWSKZ = ZTITIVK-MWSKZ.
      ENDIF.
      ADD G_TC_2130_WA-PPAMT TO L_PPAMT.
*      g_tc_2130_wa-ivamt = g_tc_2130_wa-refwr - g_tc_2130_wa-ppamt.
      G_TC_2130_WA-IVAMT = G_TC_2130_WA-REFWR - G_TC_2130_WA-PPAMT.
      MODIFY IT_TAB FROM G_TC_2130_WA.
    ENDIF.

    LT_MWSKZ-MWSKZ = G_TC_2130_WA-MWSKZ.
    COLLECT LT_MWSKZ.

    ADD G_TC_2130_WA-REFWR TO G_WRBTR.
  ENDLOOP.

  ZTITIVK-PPAMT = L_PPAMT.

  L_AMOUNT = G_WRBTR - ZTITIVK-RTCHG - L_PPAMT.
  IF L_AMOUNT LE 0.
    CLEAR ZTITIVK-RTCHG.
    L_AMOUNT = G_WRBTR.
    MESSAGE I317.
*    exit.
  ENDIF.

  IF ( G_MODE EQ C_CHARC OR
       G_MODE EQ C_CHARM ).
    L_AMOUNT = G_WRBTR + ZTITIVK-PKCHG + ZTITIVK-HDCHG
                       + ZTITIVK-OTCHG.
*                       + ZTITIVK-rtchg.
*                       + ZTITIVK-ppamt.

    IF ZTITIVK-IVAMT IS INITIAL.
*      ZTITIVK-ivamt = g_wrbtr.
      ZTITIVK-IVAMT = L_AMOUNT.
    ELSE.
      IF ZTITIVK-IVAMT NE L_AMOUNT.
*      IF ZTITIVK-ivamt NE g_wrbtr.
        IF SY-DYNNR EQ C_SCR2000.
          MESSAGE W308.
        ENDIF.
*        ZTITIVK-ivamt = g_wrbtr.
        ZTITIVK-IVAMT = L_AMOUNT.
      ENDIF.
    ENDIF.
  ELSE.
*    IF ZTITIVK-ivamt NE g_wrbtr.
    IF ZTITIVK-IVAMT NE L_AMOUNT.
      MESSAGE S309.
    ENDIF.
  ENDIF.

*> 송장처리금액.
  ZTITIVK-IVAMP = ZTITIVK-IVAMT - ZTITIVK-PPAMT.  ">선급금액.

ENDFORM.                    " check_open_amount

*&---------------------------------------------------------------------*
*&      Form  handle_double_click
*&---------------------------------------------------------------------*
FORM HANDLE_DOUBLE_CLICK  USING  P_ROW P_COLUMN.

  READ TABLE IT_ZTITIVH INDEX P_ROW.

  CHECK SY-SUBRC = 0.

  CASE P_COLUMN.
    WHEN 'CBELNR' OR 'CGJAHR' OR 'CBUDAT'.
      IF NOT IT_ZTITIVH-CBELNR IS INITIAL.
        PERFORM DISPLAY_LIV_DOCUMENT USING  IT_ZTITIVH-CBELNR
                                            IT_ZTITIVH-CGJAHR
                                            ZTITIVK-BUKRS.
      ENDIF.
    WHEN OTHERS.
      IF NOT IT_ZTITIVH-BELNR IS INITIAL.
        PERFORM DISPLAY_LIV_DOCUMENT USING  IT_ZTITIVH-BELNR
                                            IT_ZTITIVH-GJAHR
                                            ZTITIVK-BUKRS.
      ENDIF.
  ENDCASE.

ENDFORM.                    "handle_double_click
*&---------------------------------------------------------------------*
*&      Form  handle_hotspot_click
*&---------------------------------------------------------------------*
FORM HANDLE_HOTSPOT_CLICK  USING E_ROW_ID    TYPE LVC_S_ROW
                                 E_COLUMN_ID TYPE LVC_S_COL.

  READ TABLE IT_ZTITIVH INDEX E_ROW_ID-INDEX.

  CHECK SY-SUBRC = 0.

  CASE E_COLUMN_ID-FIELDNAME.
    WHEN 'CBELNR' OR 'CGJAHR' OR 'CBUDAT'.
      IF NOT IT_ZTITIVH-CBELNR IS INITIAL.
        PERFORM DISPLAY_LIV_DOCUMENT USING  IT_ZTITIVH-CBELNR
                                            IT_ZTITIVH-CGJAHR
                                            ZTITIVK-BUKRS.
      ENDIF.
    WHEN OTHERS.
      IF NOT IT_ZTITIVH-BELNR IS INITIAL.
        PERFORM DISPLAY_LIV_DOCUMENT USING  IT_ZTITIVH-BELNR
                                            IT_ZTITIVH-GJAHR
                                            ZTITIVK-BUKRS.
      ENDIF.
  ENDCASE.

ENDFORM.                    " handle_hotspot_click
*&---------------------------------------------------------------------*
*&      Form  scr2124_fieldcat_build
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM SCR2124_FIELDCAT_BUILD .

  CALL FUNCTION 'LVC_FIELDCATALOG_MERGE'
    EXPORTING
      I_STRUCTURE_NAME = 'ZTISIVHS'
    CHANGING
      CT_FIELDCAT      = IT_FIELDCAT_LVC[].

  LOOP AT IT_FIELDCAT_LVC.
    CASE IT_FIELDCAT_LVC-FIELDNAME.
      WHEN 'BLDAT' OR 'BUDAT' OR 'IVSEQ' OR 'RBLGP'.
        IT_FIELDCAT_LVC-KEY     = C_TRUE.
      WHEN 'BELNR' OR 'GJAHR'.
*        it_fieldcat_lvc-key     = c_true.
        IT_FIELDCAT_LVC-HOTSPOT = C_TRUE.
      WHEN 'CBELNR' OR 'CGJAHR'.
        IT_FIELDCAT_LVC-HOTSPOT = C_TRUE.
      WHEN 'IVONO' OR 'FLAG'.
        IT_FIELDCAT_LVC-NO_OUT  = C_TRUE.
      WHEN OTHERS.
    ENDCASE.
    MODIFY IT_FIELDCAT_LVC.
  ENDLOOP.

ENDFORM.                    " scr2124_fieldcat_build
*&---------------------------------------------------------------------*
*&      Form  get_and_check_lc_data
*&---------------------------------------------------------------------*
*       Get 구매오더 데이타.
*----------------------------------------------------------------------*
FORM GET_AND_CHECK_LC_DATA  USING    P_REQNO
                                     P_AMDSQ
                                     P_REQIT
                                     P_MODIFY
                                     P_ZTIVRQ00 STRUCTURE ZTIVRQ00
                                     P_COUNT.

  DATA : LV_LIFNR LIKE ZTITRQX-LIFRE.
  CLEAR: P_ZTIVRQ00.

  SELECT SINGLE * INTO P_ZTIVRQ00
    FROM ZTIVRQ00
   WHERE REQNO EQ P_REQNO
     AND REQIT EQ P_REQIT.

  IF SY-SUBRC EQ 0.
*>임시로 구성될 수입요청의 구매처계정조회 20061129
    SELECT SINGLE LIFRE
      INTO LV_LIFNR
      FROM ZTITRQX
     WHERE REQNO = ZTIVRQ00-REQNO.

    IF SY-SUBRC = 0.
      P_ZTIVRQ00-LIFNR = LV_LIFNR.
    ENDIF.

*>Vendor 체크.
    IF ZTITIVK-LIFNR     NE P_ZTIVRQ00-LIFNR AND
       NOT ZTITIVK-LIFNR IS INITIAL.
      MESSAGE S311 WITH P_ZTIVRQ00-LIFNR ZTITIVK-LIFNR.
      P_MODIFY = C_TRUE.
      EXIT.
    ENDIF.
*통화키 체크.
    IF ZTITIVK-WAERS    NE  P_ZTIVRQ00-WAERS AND
       P_COUNT           GT  C_ZERO.
      MESSAGE S312 WITH P_ZTIVRQ00-WAERS ZTITIVK-WAERS.
      P_MODIFY = C_TRUE.
    ENDIF.
*>기타 체크 로직.

*> Lock Object
    PERFORM  SET_LC_LOCK_OBJECT  USING P_REQNO
                                       P_AMDSQ
                                       P_REQIT
                                       C_LOCK
                                       C_SUCCESS
                                       P_MODIFY.
  ELSE.
    MESSAGE S019(06) WITH P_REQNO.
    P_MODIFY = C_TRUE.
    EXIT.
  ENDIF.

ENDFORM.                    " get_and_check_lc_data
*&---------------------------------------------------------------------*
*&      Form  set_prepaid_invoice_data
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM SET_PREPAID_INVOICE_DATA   TABLES P_IT_TAB   LIKE IT_TAB
                                USING  P_ZTIVRQ00 STRUCTURE ZTIVRQ00
                                       P_ZTITIVK  STRUCTURE ZTITIVK
                                       P_ZTISRQIT STRUCTURE IT_ZTISRQIT.
  CLEAR: P_IT_TAB.

  MOVE-CORRESPONDING P_ZTIVRQ00 TO : P_IT_TAB, P_ZTITIVK.

  MOVE: P_ZTISRQIT-REMNG  TO P_IT_TAB-REMNG,
        P_ZTISRQIT-REMNG  TO P_IT_TAB-IVMNG,
        P_ZTISRQIT-NETWR  TO P_IT_TAB-REFWR,
        P_ZTISRQIT-NETWR  TO P_IT_TAB-NETWR,
        P_ZTISRQIT-PPMNG  TO P_IT_TAB-PPMNG,
        P_ZTISRQIT-PPAMT  TO P_IT_TAB-PPAMT,
        P_ZTISRQIT-IVMNGS TO P_IT_TAB-IVMNGS,
        P_ZTISRQIT-IVMNGL TO P_IT_TAB-IVMNGL.

  MOVE: SY-UNAME TO P_IT_TAB-CNAM,
        SY-DATLO TO P_IT_TAB-CDAT,
        SY-TIMLO TO P_IT_TAB-CTME,
        SY-UNAME TO P_IT_TAB-UNAM,
        SY-DATLO TO P_IT_TAB-UDAT,
        SY-TIMLO TO P_IT_TAB-UTME.

  IF NOT  P_IT_TAB-EBELN IS INITIAL.
* 구매오더 정보 Read.
    SELECT SINGLE MENGE WERKS LGORT MATNR TXZ01 MWSKZ
                  LOEKZ ELIKZ BPRME BPUMZ BPUMN UMREZ
                  UMREN NETPR PEINH UEBTO UEBTK UNTTO
    INTO CORRESPONDING FIELDS OF P_IT_TAB
      FROM EKPO
     WHERE EBELN  EQ  P_IT_TAB-EBELN
       AND EBELP  EQ  P_IT_TAB-EBELP.
*> 수입의뢰 정보 Read.
    IF NOT P_IT_TAB-REQNO IS INITIAL.
      SELECT SINGLE RQMNG
        INTO P_IT_TAB-RQMNG
        FROM ZTIVRQ00
       WHERE REQNO   EQ  P_IT_TAB-REQNO
         AND REQIT   EQ  P_IT_TAB-REQIT.

      SELECT  SUM( REMNG )
        INTO P_IT_TAB-IVMNGS
        FROM  ZTITIVP
       WHERE  REQNO       EQ  P_IT_TAB-REQNO
         AND  REQIT       EQ  P_IT_TAB-REQIT
         AND NOT ( IVONO  EQ  P_IT_TAB-IVONO
         AND       RBLGP  EQ  P_IT_TAB-RBLGP ).
**> 초과납품허용치.
*        if not ZTITBLP-UEBTO is initial.
*           ZTITBLP-rqmng = ZTITBLP-rqmng +
*                          ( ZTITBLP-rqmng * ZTITBLP-UEBTO ) / 100.
*        endif.
*        if not ZTITBLP-UEBTK is initial.
*
*        endif.
      P_IT_TAB-IVMNGL =  P_IT_TAB-RQMNG - P_IT_TAB-IVMNGS.
      IF ZTITIVK-PRPYN EQ 'P' OR
         ZTITIVK-PRPYN EQ 'R'.
        P_IT_TAB-IVMNG = P_IT_TAB-REMNG.
      ENDIF.
    ENDIF.

    IF P_IT_TAB-IVMNGL LE 0.
      P_IT_TAB-IVMNGL = 0.
    ENDIF.
*> 개설은행 정보.
    SELECT SINGLE OPNBK
      INTO P_ZTITIVK-OPNBK
      FROM ZTIVRQ04
     WHERE REQNO  EQ  P_IT_TAB-REQNO.
    IF SY-SUBRC       EQ 0 AND
       NOT P_ZTITIVK-OPNBK IS INITIAL.
      SELECT SINGLE *
        FROM ZTSTIG3
       WHERE PARTI  EQ  C_CHARB
         AND EPART  EQ  P_ZTITIVK-OPNBK
         AND BUKRS  EQ  P_ZTITIVK-BUKRS.
      IF SY-SUBRC NE 0.
        MESSAGE E918 WITH P_ZTITIVK-OPNBK.
      ENDIF.
      IF ZTITIG00-SJPAP EQ C_CHARV.
        P_ZTITIVK-APVEN = ZTITIVK-LIFNR.
      ELSEIF ZTITIG00-SJPAP EQ C_CHARB.
        P_ZTITIVK-APVEN = ZTSTIG3-LIFNR.
      ENDIF.
    ELSE.
      MESSAGE E322 WITH P_IT_TAB-REQNO.
    ENDIF.
*> 상업송장번호.
    IF P_ZTITIVK-IVNUM IS INITIAL.
      P_ZTITIVK-IVNUM = ZTITRQS-OPNNO.
    ENDIF.
    IF P_ZTITIVK-XBLNR IS INITIAL.
      P_ZTITIVK-XBLNR = ZTITRQS-OPNNO.
    ENDIF.
    IF P_ZTITIVK-SGTXT IS INITIAL.
      P_ZTITIVK-SGTXT = ZTITRQS-OPNNO.
    ENDIF.
  ENDIF.

  APPEND P_IT_TAB.

*>아이템 번호를 생성함.
  PERFORM SET_ITEM_NUMBER_BUILD TABLES P_IT_TAB
                                USING  P_ZTITIVK.

  PERFORM GET_OTHERS_TEXT_BY_MASTER_DATA.


ENDFORM.                    " set_prepaid_invoice_data
*&---------------------------------------------------------------------*
*&      Form  set_invoice_default_values
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM SET_INVOICE_DEFAULT_VALUES .

  IF ZTITIVK-BUKRS IS INITIAL.
** 진로산업 Change 2007/04 --------------------------------------
*    ztitivk-bukrs = c_bukrs.
** 진로산업 Change 2007/04 --------------------------------------
  ENDIF.

  IF ZTITIVK-BUDAT IS INITIAL.
    ZTITIVK-BUDAT = SY-DATLO.
  ENDIF.

  IF ZTITIVK-BUPLA IS INITIAL.
    READ TABLE IT_TAB INTO G_TC_2130_WA INDEX 1.
    IF SY-SUBRC EQ 0.
      ZTITIVK-BUPLA = G_TC_2130_WA-BUPLA.
    ENDIF.
*    IF ztitivk-bupla IS INITIAL.
*      ztitivk-bupla = c_bupla.
*    ENDIF.
  ENDIF.

*> Default Value Setting
  SELECT SINGLE *
    FROM ZTITIG07
   WHERE BUKRS EQ ZTITIVK-BUKRS
     AND CSTCT EQ C_CHARA.
  IF SY-SUBRC EQ 0.
    ZTITIVK-BLART = ZTITIG07-BLART.
    ZTITIVK-MWSKZ = ZTITIG07-MWSKZ.
    ZTITIVK-ZLSPR = ZTITIG07-ZLSPR.
    ZTITIVK-ZLSCH = ZTITIG07-ZLSCH.
    ZTITIVK-UZAWE = ZTITIG07-UZAWE.
  ENDIF.

  IF ZTITIVK-BLART IS INITIAL.
    ZTITIVK-BLART = C_BLART.
  ENDIF.

  IF ZTITIVK-MWSKZ IS INITIAL.
    READ TABLE IT_TAB INTO G_TC_2130_WA INDEX 1.
    IF SY-SUBRC EQ 0.
      ZTITIVK-MWSKZ = G_TC_2130_WA-MWSKZ.
    ENDIF.
  ENDIF.

  IF ZTITIVK-ZTERM IS INITIAL.
    READ TABLE IT_TAB INTO G_TC_2130_WA INDEX 1.
    IF SY-SUBRC               EQ 0       AND
       NOT G_TC_2130_WA-REQNO IS INITIAL.
      SELECT SINGLE ZTERM
        INTO ZTITIVK-ZTERM
        FROM ZTIVRQ02
       WHERE REQNO EQ G_TC_2130_WA-REQNO.
    ENDIF.
  ENDIF.

*> CHM2201-00201 엠트론 세금코드 V0 디폴트
  IF ZTITIVK-BUKRS EQ '3000'.
    ZTITIVK-MWSKZ = 'V0'.
  ENDIF.
*> CHM2201-00201 엠트론 세금코드 V0 디폴트


*  IF ztitivk-zlspr IS INITIAL.
*    ztitivk-zlspr = c_zlspr.
*  ENDIF.

  ZTITIVK-LIVST = C_CHARN.

ENDFORM.                    " set_invoice_default_values
*&---------------------------------------------------------------------*
*&      Form  fill_account_header_cancel
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM FILL_ACCOUNT_HEADER_CANCEL USING P_ZTISSCRCOM STRUCTURE ZTISSCRCOM.

  CALL FUNCTION 'OWN_LOGICAL_SYSTEM_GET'
    IMPORTING
      OWN_LOGICAL_SYSTEM = GS_DOCUMENTHEADER-OBJ_SYS.

* OBJ_TYPE has to be replaced by customers object key (Y* or Z*)
  GS_DOCUMENTHEADER-OBJ_TYPE   = 'BKPFF'.
  GS_DOCUMENTHEADER-OBJ_KEY    = '$'.
  GS_DOCUMENTHEADER-BUS_ACT    = 'RFBU'.   ">FB01, MIRO

  GS_DOCUMENTHEADER-USERNAME   = SY-UNAME.
  GS_DOCUMENTHEADER-HEADER_TXT = P_ZTISSCRCOM-BKTXT.
  GS_DOCUMENTHEADER-COMP_CODE  = P_ZTISSCRCOM-BUKRS.
  GS_DOCUMENTHEADER-DOC_DATE   = P_ZTISSCRCOM-BLDAT.
  GS_DOCUMENTHEADER-PSTNG_DATE = P_ZTISSCRCOM-BUDAT.
  GS_DOCUMENTHEADER-TRANS_DATE = P_ZTISSCRCOM-WWERT.
  GS_DOCUMENTHEADER-FISC_YEAR  = P_ZTISSCRCOM-GJAHR.
  GS_DOCUMENTHEADER-FIS_PERIOD = P_ZTISSCRCOM-MONAT.
  GS_DOCUMENTHEADER-DOC_TYPE   = P_ZTISSCRCOM-BLART.
* Gs_DOCUMENTHEADER-REF_DOC_NO =
* Gs_DOCUMENTHEADER-AC_DOC_NO  =
* gs_documentheader-obj_key_r  =
* Gs_DOCUMENTHEADER-reason_rev =
* Gs_DOCUMENTHEADER-COMPO_ACC  =
  GS_DOCUMENTHEADER-REF_DOC_NO_LONG = P_ZTISSCRCOM-XBLNR.
* Gs_DOCUMENTHEADER-ACC_PRINCIPLE =

ENDFORM.                    " fill_account_header_cancel
*&---------------------------------------------------------------------*
*&      Form  applications_print
*&---------------------------------------------------------------------*
FORM APPLICATIONS_PRINT .

  CALL FUNCTION 'Z_TI_POPUP_TO_CONFIRM_MESSAGE'
    EXPORTING
      XMODE  = C_CHARZ
    IMPORTING
      ANSWER = G_ANSWER.

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
*&      Form  input_field_check
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM INPUT_FIELD_CHECK .

  DATA: L_BUKRS   LIKE T001-BUKRS,
        L_WERKS   LIKE T001W-WERKS,
        L_MATNR   LIKE MARA-MATNR,
        L_MTART   LIKE T134-MTART,
        L_EBELN   LIKE EKKO-EBELN,
        L_LIFNR   LIKE LFA1-LIFNR,
        L_EKORG   LIKE T024E-EKORG,
        L_EKGRP   LIKE T024-EKGRP.

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

ENDFORM.                    " input_field_check
*&---------------------------------------------------------------------*
*&      Form  p1001_initialization
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM P1001_INITIALIZATION .

  SET TITLEBAR 'T1000'.

ENDFORM.                    " p1001_initialization
*&---------------------------------------------------------------------*
*&      Form  p2000_data_selections
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM P2000_DATA_SELECTIONS .

  DATA: L_RQMNG  LIKE ZTITRQP-RQMNG.

  CLEAR: G_COUNT, IT_TAB, IT_ZTITIG02, IT_HEADER, IT_LIST.
  REFRESH : IT_TAB, IT_ZTITIG02, IT_HEADER, IT_LIST.
*> PROGRESS Display.
  G_LINEN    = 30.
  G_OUT_TEXT = '데이타를 검색 중입니다 %99999%%'(P01).
  REPLACE '%99999%' WITH G_LINEN INTO G_OUT_TEXT.
  PERFORM SHOW_PROGRESS_BAR(ZTIR0000) USING G_OUT_TEXT G_LINEN.

*> B/L 데이타 select.
  SELECT *
        INTO CORRESPONDING FIELDS OF TABLE IT_TAB_H
        FROM ( ZTITBLK AS A JOIN ZTITBLP AS B
          ON A~IBLNO EQ B~IBLNO ) JOIN EKPO AS C
          ON  B~EBELN EQ C~EBELN
          AND B~EBELP EQ C~EBELP
       WHERE A~BUKRS  IN S_BUKRS  "회사코드.
         AND A~IBLNO  IN S_IBLNO
         AND A~BLNUM  IN S_BLNUM  "B/L 번호.
         AND A~BLDTY  IN S_BLDTY  "문서종류.
         AND A~RPTTY  IN S_RPTTY  "수입신고구분.
         AND C~MATKL  IN S_MATKL  "자재그룹.
         AND A~EKORG  IN S_EKORG  "구매조직.
         AND A~EKGRP  IN S_EKGRP  "구매그룹.
         AND A~LIFNR  IN S_LIFNR  "공급업체 계정번호.
         AND A~BLETD  IN S_BLETD  "ETD(출발 예정 시각).
         AND A~BLETA  IN S_BLETA  "ETA(도착 예정 시각).
         AND A~FWDTY  IN S_FWDTY  "운송 방법.
         AND A~LPONR  IN S_LPONR  "최종품목번호.
         AND A~WAERS  IN S_WAERS  "통화키.
         AND A~LGAYN  IN S_LGAYN  "LG대상여부.
         AND B~IBLIT  IN S_IBLIT  "B/L 품목번호.
         AND ( B~NDFTY  EQ SPACE     ">유환.
         OR    B~NDFTY  EQ C_CHARA ) ">사후송금.
         AND B~EBELN  IN S_EBELN  "구매전표번호.
         AND B~EBELP  IN S_EBELP  "구매문서 품목번호.
         AND B~REQNO  IN S_REQNO  "수입의뢰 관리번호.
         AND B~REQIT  IN S_REQIT  "수입의뢰 품목번호.
         AND B~CNAM   IN S_CNAM   "작성인.
         AND B~CDAT   IN S_CDAT   "생성일.
         AND B~CTME   IN S_CTME   "생성시간.
         AND B~UNAM   IN S_UNAM   "최종변경인.
         AND B~UDAT   IN S_UDAT   "변경일.
         AND B~UTME   IN S_UTME   "최종변경시간.
         AND A~CRLSE  NE 'B'      "입수경로가 미확인이 아닌것만.
         AND B~EBELN  <> '4504428455'. "--> 예외 처리

  IF SY-SUBRC NE 0.
    MESSAGE S902.
  ENDIF.

  DATA : L_PPMNG LIKE ZTITIVP-PPMNG.

  CLEAR: G_TABIX, G_COUNT, G_CNT.
  LOOP AT IT_TAB_H.
    G_TABIX = SY-TABIX.

    IF NOT IT_TAB_H-REQNO IS INITIAL.
      SELECT SINGLE *
        FROM ZTITRQK
       WHERE REQNO EQ IT_TAB_H-REQNO.
      IF SY-SUBRC NE 0.
        DELETE IT_TAB_H INDEX G_TABIX.
        CONTINUE.
      ENDIF.
      IF ZTITRQK-REQTY EQ 'TT' AND
         ZTITRQK-ANBTY EQ 'B'.
        DELETE IT_TAB_H INDEX G_TABIX.
        CONTINUE.
      ENDIF.
    ENDIF.

*************************************************
* 2008.06.10 simcho by 박혁세K
* 엠트론 test시 오류 발견
* 송장수량 계산 시 필드교체 remng -> ivmng
*************************************************
    IF NOT IT_TAB_H-IBLNO IS INITIAL.
      CLEAR L_PPMNG.
      SELECT  SUM( IVMNG ) SUM( PPMNG )
       INTO   (IT_TAB_H-IVMNGS, L_PPMNG)
       FROM   ZTITIVP
       WHERE  IBLNO  = IT_TAB_H-IBLNO
         AND  IBLIT  = IT_TAB_H-IBLIT.
    ENDIF.

*   i/v 누적수량.
    IF NOT IT_TAB_H-REQNO IS INITIAL.
      SELECT  SUM( IVMNG )
        INTO  L_PPMNG
        FROM  ZTIVIV00
       WHERE  REQNO  EQ IT_TAB_H-REQNO
         AND  REQIT  EQ IT_TAB_H-REQIT
         AND ( PRPYN EQ 'P'
          OR   PRPYN EQ 'R' ).
    ENDIF.

**   I/V 누적수량.
*    IF NOT it_tab_h-iblno IS INITIAL.
*      CLEAR l_ppmng.
*      SELECT  SUM( remng ) SUM( ppmng )
*       INTO   (it_tab_h-ivmngs, l_ppmng)
*       FROM   ztitivp
*       WHERE  iblno  = it_tab_h-iblno
*         AND  iblit  = it_tab_h-iblit.
*    ENDIF.
*
**   i/v 누적수량.
*    IF NOT it_tab_h-reqno IS INITIAL.
*      SELECT  SUM( remng )
*        INTO  l_ppmng
*        FROM  ztiviv00
*       WHERE  reqno  EQ it_tab_h-reqno
*         AND  reqit  EQ it_tab_h-reqit
*         AND ( prpyn EQ 'P'
*          OR   prpyn EQ 'R' ).
*    ENDIF.
*   I/V 누적수량.
*************************************************

*   I/V가능수량.
    IT_TAB_H-IVMNGL =  IT_TAB_H-BLMNG - IT_TAB_H-IVMNGS - L_PPMNG .
    IF IT_TAB_H-IVMNGL LE 0.
      DELETE IT_TAB_H INDEX G_TABIX.
      CONTINUE.
    ENDIF.

*   domain의 value.
    PERFORM GET_DOMAIN_VALUE_TEXT(ZTIR0000) USING :
                           'ZTIBLDTY' IT_TAB_H-BLDTY  IT_TAB_H-BLDTYX,
                           'ZTIRPTTY' IT_TAB_H-RPTTY  IT_TAB_H-RPTTYX,
                           'ZTIFWDTY' IT_TAB_H-FWDTY  IT_TAB_H-FWDTYX,
                           'ZTINDFTY' IT_TAB_H-NDFTY  IT_TAB_H-NDFTYX.
*   공급업체.
    SELECT SINGLE NAME1 INTO IT_TAB_H-NAME1
      FROM LFA1
     WHERE LIFNR EQ IT_TAB_H-LIFNR.

*   p/o정보.
    SELECT  SINGLE WERKS MATNR TXZ01
      INTO  (IT_TAB_H-WERKS, IT_TAB_H-MATNR, IT_TAB_H-TXZ01)
      FROM  ZTIVPO00
     WHERE  EBELN  = IT_TAB_H-EBELN
       AND  EBELP  = IT_TAB_H-EBELP.

    IF IT_TAB_H-REQNO IS NOT INITIAL. "기능개선_XXXX 긴급수정
*   수입의뢰 정보 수량.
      SELECT  SINGLE RQMNG
        INTO  IT_TAB_H-MENGE
        FROM  ZTIVRQ00
       WHERE  REQNO  = IT_TAB_H-REQNO
         AND  REQIT  = IT_TAB_H-REQIT.

*   b/l 누적수량.
      SELECT  SUM( BLMNG )
       INTO   IT_TAB_H-BLMNGS
       FROM   ZTITBLP
       WHERE  REQNO  = IT_TAB_H-REQNO
         AND  REQIT  = IT_TAB_H-REQIT.
    ENDIF.


*   b/l 가능수량.
    IT_TAB_H-BLMNGL =  IT_TAB_H-MENGE - IT_TAB_H-BLMNGS.

    MOVE IT_TAB_H-REFWR TO IT_TAB_H-TREFWR.

    ADD 1 TO G_COUNT.

    MODIFY IT_TAB_H INDEX G_TABIX.
  ENDLOOP.

  IF G_COUNT EQ 0.
    MESSAGE S902.
  ENDIF.

ENDFORM.                    " p2000_data_selections
*&---------------------------------------------------------------------*
*&      Form  p2100_header_and_list_build
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM P2100_HEADER_AND_LIST_BUILD .

  LOOP AT IT_TAB_H.
    MOVE-CORRESPONDING IT_TAB_H TO : IT_HEADER, IT_LIST.
    COLLECT : IT_HEADER.
    APPEND    IT_LIST.
  ENDLOOP.

ENDFORM.                    " p2100_header_and_list_build
*&---------------------------------------------------------------------*
*&      Form  p2001_item_clear
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM P2001_ITEM_CLEAR  USING    P_ITEM.

  IF P_ITEM NE 'X'.
    REFRESH IT_LIST.
  ENDIF.

ENDFORM.                    " p2001_item_clear
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
*>>>>>>HEADER
"BOX.
          'S' 'TABNAME'       'IT_HEADER',
          ' ' 'FIELDNAME'     'BOX',
          'E' 'KEY'           ' ',
"B/L 관리번호
          'S' 'TABNAME'       'IT_HEADER',
          ' ' 'REF_TABNAME'   'ZTITBLK',
          ' ' 'FIELDNAME'     'IBLNO',
          ' ' 'HOTSPOT'       'X',
          ' ' 'KEY'           'X',
          'E' 'OUTPUTLEN'     '12',
"B/L번호
          'S' 'TABNAME'       'IT_HEADER',
          ' ' 'REF_TABNAME'   'ZTITBLK',
*          ' ' 'seltext_m'     'BLNUM',
          ' ' 'FIELDNAME'     'BLNUM',
          ' ' 'HOTSPOT'       'X',
          'E' 'OUTPUTLEN'     '25',
"문서상태
          'S' 'TABNAME'       'IT_HEADER',
*          ' ' 'REF_TABNAME'   'ZTITBLK',
          ' ' 'seltext_m'     '문서종류',
          ' ' 'FIELDNAME'     'BLDTYX',
          'E' 'OUTPUTLEN'     '10',
"공급업체코드
          'S' 'TABNAME'       'IT_HEADER',
          ' ' 'REF_TABNAME'   'EKKO',
          ' ' 'FIELDNAME'     'LIFNR',
          ' ' 'OUTPUTLEN'     20,
          'E' 'HOTSPOT'       'X',

"공급업체명
          'S' 'TABNAME'       'IT_HEADER',
          ' ' 'REF_TABNAME'   'LFA1',
          ' ' 'OUTPUTLEN'     50,
          'E' 'FIELDNAME'     'NAME1',

"ETD
          'S' 'TABNAME'       'IT_HEADER',
          ' ' 'REF_TABNAME'   'ZTITBLK',
          ' ' 'FIELDNAME'     'BLETD',
          'E' 'OUTPUTLEN'     '10',
"ETA
          'S' 'TABNAME'       'IT_HEADER',
          ' ' 'REF_TABNAME'   'ZTITBLK',
*          ' ' 'seltext_m'     '',
          ' ' 'FIELDNAME'     'BLETA',
          'E' 'OUTPUTLEN'     '10',
"회사코드
          'S' 'TABNAME'       'IT_HEADER',
          ' ' 'REF_TABNAME'   'ZTITBLK',
          ' ' 'FIELDNAME'     'BUKRS',
          ' ' 'NO_OUT'        'X',
          'E' 'OUTPUTLEN'     '4',
"운송방법.
          'S' 'TABNAME'       'IT_HEADER',
*          ' ' 'REF_TABNAME'   'ZTITBLK',
          ' ' 'seltext_m'     '운송방법',
           ' ' 'NO_OUT'        'X',
          ' ' 'FIELDNAME'     'FWDTYX',
          'E' 'OUTPUTLEN'     '8',
"수입신고구분
          'S' 'TABNAME'       'IT_HEADER',
          ' ' 'REF_TABNAME'   'ZTITBLK',
          ' ' 'seltext_m'     '신고구분',
           ' ' 'NO_OUT'        'X',
          ' ' 'FIELDNAME'     'RPTTYX',
          'E' 'OUTPUTLEN'     '14',
"송장금액통화
          'S' 'TABNAME'       'IT_HEADER',
          ' ' 'seltext_m'     'Cur',
          ' ' 'REF_TABNAME'   'ZTITBLK',
          ' ' 'FIELDNAME'     'WAERS',
          'E' 'OUTPUTLEN'     '3',
"송장금액.
          'S' 'TABNAME'       'IT_HEADER',
          ' ' 'seltext_m'     '송장값 (외화)',
          ' ' 'FIELDNAME'     'TREFWR',
          ' ' 'CFIELDNAME'    'WAERS',
          ' ' 'CTABNAME'      'IT_HEADER',
          'E' 'OUTPUTLEN'     '16',

*>>>>>>>>>LIST
"B/L 품목번호.
          'S' 'TABNAME'       'IT_LIST',
          ' ' 'REF_TABNAME'   'ZTITBLP',
          ' ' 'FIELDNAME'     'IBLIT',
          ' ' 'HOTSPOT'       'X',
          ' ' 'JUST'          C_CHARL," (R)ight (L)eft (C)ent.
          ' ' 'LZERO'         C_CHARX,
          ' ' 'INTLEN'         10,
          ' ' 'KEY'           'X',
          'E' 'OUTPUTLEN'     '12',
"구매전표번호.
          'S' 'TABNAME'       'IT_LIST',
          ' ' 'REF_TABNAME'   'ZTITBLP',
          ' ' 'FIELDNAME'     'EBELN',
          ' ' 'HOTSPOT'       'X',
          'E' 'OUTPUTLEN'     '12',
"구매문서 품목번호.
          'S' 'TABNAME'       'IT_LIST',
          ' ' 'REF_TABNAME'   'ZTITBLP',
          ' ' 'FIELDNAME'     'EBELP',
          ' ' 'JUST'          C_CHARL," (R)ight (L)eft (C)ent.
          ' ' 'LZERO'         C_CHARX,
          ' ' 'NO_OUT'        'X',
          'E' 'OUTPUTLEN'     '5',
"수입의뢰번호.
          'S' 'TABNAME'       'IT_LIST',
          ' ' 'REF_TABNAME'   'ZTITBLP',
          ' ' 'FIELDNAME'     'REQNO',
          ' ' 'HOTSPOT'       'X',
          ' ' 'KEY'           ' ',
          'E' 'OUTPUTLEN'     '12',
"수입의뢰 품목번호.
          'S' 'TABNAME'       'IT_LIST',
          ' ' 'REF_TABNAME'   'ZTITBLP',
          ' ' 'JUST'          C_CHARL," (R)ight (L)eft (C)ent.
          ' ' 'LZERO'         C_CHARX,
          ' ' 'FIELDNAME'     'REQIT',
          'E' 'OUTPUTLEN'     '10',
"자재번호.
          'S' 'TABNAME'       'IT_LIST',
          ' ' 'REF_TABNAME'   'ZTISBLIT',
          ' ' 'FIELDNAME'     'MATNR',
          'E' 'OUTPUTLEN'     '20',

"자재내역.
          'S' 'TABNAME'       'IT_LIST',
          ' ' 'REF_TABNAME'   'ZTISBLIT',
          ' ' 'FIELDNAME'     'TXZ01',
          'E' 'OUTPUTLEN'     '50',

"수입의뢰수량
          'S' 'TABNAME'       'IT_LIST',
*          ' ' 'REF_TABNAME'   'ZTISBLIT',
          ' ' 'seltext_m'     '수입의뢰수량',
          ' ' 'FIELDNAME'     'MENGE',
          ' ' 'QFIELDNAME'    'MEINS',
          ' ' 'QTABNAME'      'IT_LIST',
          ' ' 'NO_OUT'        'X',
          'E' 'OUTPUTLEN'     '15',
"B/L가능수량
          'S' 'TABNAME'       'IT_LIST',
          ' ' 'REF_TABNAME'   'ZTISBLIT',
*          ' ' 'seltext_m'     '수입의뢰수량',
          ' ' 'FIELDNAME'     'BLMNGL',
          ' ' 'QFIELDNAME'    'MEINS',
          ' ' 'QTABNAME'      'IT_LIST',
          ' ' 'NO_OUT'        'X',
          'E' 'KEY'           ' ',
"B/L누적수량
          'S' 'TABNAME'       'IT_LIST',
          ' ' 'REF_TABNAME'   'ZTISBLIT',
*          ' ' 'seltext_m'     '수입의뢰수량',
          ' ' 'FIELDNAME'     'BLMNGS',
          ' ' 'QFIELDNAME'    'MEINS',
          ' ' 'QTABNAME'      'IT_LIST',
          ' ' 'NO_OUT'        'X',
          'E' 'KEY'           ' ',
"B/L수량
          'S' 'TABNAME'       'IT_LIST',
          ' ' 'REF_TABNAME'   'ZTISBLIT',
*          ' ' 'seltext_m'     '수입의뢰수량',
          ' ' 'QFIELDNAME'    'MEINS',
          ' ' 'QTABNAME'      'IT_LIST',
          ' ' 'NO_OUT'        'X',
          ' ' 'FIELDNAME'     'BLMNG',
          'E' 'KEY'           ' ',
"송장가능수량
          'S' 'TABNAME'       'IT_LIST',
          ' ' 'REF_TABNAME'   'ZTISIVIT',
          ' ' 'seltext_m'     'I/V가능수량    ',
          ' ' 'FIELDNAME'     'IVMNGL',
          ' ' 'QFIELDNAME'    'MEINS',
          ' ' 'QTABNAME'      'IT_LIST',
          'E' 'OUTPUTLEN'     '16',
"기본단위
          'S' 'TABNAME'       'IT_LIST',
          ' ' 'REF_TABNAME'   'ZTITBLP',
          ' ' 'FIELDNAME'     'MEINS',
          ' ' 'INTLEN'         10,
          'E' 'OUTPUTLEN'     '4',
"송장금액.
          'S' 'TABNAME'       'IT_LIST',
          ' ' 'seltext_m'     '송장값',
          ' ' 'FIELDNAME'     'REFWR',
          ' ' 'CFIELDNAME'    'WAERS',
          ' ' 'JUST'          C_CHARR," (R)ight (L)eft (C)ent.
*          ' ' 'LZERO'         c_charx,
          ' ' 'CTABNAME'      'IT_HEADER',
          'E' 'OUTPUTLEN'     '20',
"자재문서번호
          'S' 'TABNAME'       'IT_LIST',
          ' ' 'REF_TABNAME'   'ZTITBLP',
          ' ' 'FIELDNAME'     'MBLNR',
          ' ' 'NO_OUT'        'X',
          'E' 'OUTPUTLEN'     '10',
"자재문서연도
          'S' 'TABNAME'       'IT_LIST',
          ' ' 'REF_TABNAME'   'ZTITBLP',
          ' ' 'FIELDNAME'     'MJAHR',
          ' ' 'NO_OUT'        'X',
          'E' 'OUTPUTLEN'     '10',
"자재문서품목
          'S' 'TABNAME'       'IT_LIST',
          ' ' 'REF_TABNAME'   'ZTITBLP',
          ' ' 'FIELDNAME'     'ZEILE',
          ' ' 'NO_OUT'        'X',
*          'E' 'OUTPUTLEN'     '10'.
"작성인
          'S' 'TABNAME'       'IT_LIST',
          ' ' 'REF_TABNAME'   'ZTITBLP',
          ' ' 'FIELDNAME'     'CNAM',
          ' ' 'NO_OUT'        'X',
          'E' 'OUTPUTLEN'     '10',
"최종변경인
          'S' 'TABNAME'       'IT_LIST',
          ' ' 'REF_TABNAME'   'ZTITBLP',
          ' ' 'FIELDNAME'     'UNAM',
          ' ' 'NO_OUT'        'X',
          'E' 'OUTPUTLEN'     '10'.

ENDFORM.                    " 3000_field_category_build
*&---------------------------------------------------------------------*
*&      Form  3200_key_infomation_build
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM 3200_KEY_INFOMATION_BUILD .

  CLEAR GS_KEYINFO.

  GS_KEYINFO-HEADER01 = 'IBLNO'.
  GS_KEYINFO-ITEM01   = 'IBLNO'.

*  gs_keyinfo-header02 =  space.
*  gs_keyinfo-item02   = 'IBLIT'.
*
*  GS_KEYINFO-HEADER03 = SPACE.
*  GS_KEYINFO-ITEM03   = 'OBJNR'.

ENDFORM.                    " 3200_key_infomation_build
*&---------------------------------------------------------------------*
*&      Form  3100_SET_COLOR_INFOMATION
*&---------------------------------------------------------------------*
FORM 3100_SET_COLOR_INFOMATION .

  LOOP AT IT_LIST.

*    CLEAR: LT_RESRC_VW-COLOR_INFO[],
*           GS_COLOR_INFO.
*    ON CHANGE OF LT_RESRC_VW-RESRC.
*      GS_COLOR_INFO-FIELDNAME = 'RESRC'.
*      GS_COLOR_INFO-COLOR-COL = '3'.
*      APPEND GS_COLOR_INFO TO LT_RESRC_VW-COLOR_INFO[].
*      MODIFY LT_RESRC_VW.
*    ENDON.

  ENDLOOP.                             " AT LT_RESRC_VW

ENDFORM.                    " 3100_SET_COLOR_INFOMATION
*&---------------------------------------------------------------------*
*&      Form  3400_COMMENT_BUILD
*&---------------------------------------------------------------------*
FORM 3400_COMMENT_BUILD .

  DATA: L_TEXT20(20) TYPE C.

  CLEAR: IT_LISTHEADER, GS_LISTHEADER.
  REFRESH: IT_LISTHEADER.

* LIST HEADING LINE: TYPE H
  CLEAR GS_LISTHEADER.
  GS_LISTHEADER-TYP  = 'H'.
* gs_listheader-KEY:  NOT USED FOR THIS TYPE
  GS_LISTHEADER-INFO = 'I/V Due List'(T13).
*  SHIFT gs_listheader-info RIGHT BY 20 PLACES.
  APPEND GS_LISTHEADER TO IT_LISTHEADER.

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

* ACTION LINE: TYPE A
  CLEAR GS_LISTHEADER.
  GS_LISTHEADER-TYP  = 'A'.
  GS_LISTHEADER-INFO = '출력일자 :'(T12).
  WRITE: SY-DATLO TO L_TEXT20.
  CONCATENATE GS_LISTHEADER-INFO L_TEXT20 INTO GS_LISTHEADER-INFO
              SEPARATED BY SPACE.
  APPEND GS_LISTHEADER TO IT_LISTHEADER.

* STATUS LINE: TYPE S
* CLEAR LS_LINE.
* LS_LINE-TYP  = 'S'.
* LS_LINE-KEY  = 'Kostenrechnungskreis:'.
* LS_LINE-INFO = P_KOKRS.
* APPEND LS_LINE TO LT_TOP_OF_PAGE.

* LS_LINE-KEY  = 'Gesch?tsjahr:_______'.
* LS_LINE-INFO = P_GJAHR.
* APPEND LS_LINE TO LT_TOP_OF_PAGE.

* LS_LINE-KEY  = 'Version:_____________'.
* LS_LINE-INFO = P_VERSN.
* APPEND LS_LINE TO LT_TOP_OF_PAGE.

* ACTION LINE: TYPE A
*  CLEAR LS_LINE.
*  LS_LINE-TYP  = 'A'.
** LS_LINE-KEY:  NOT USED FOR THIS TYPE
*  LS_LINE-INFO = '<Action>'.
*  APPEND LS_LINE TO LT_TOP_OF_PAGE.

ENDFORM.                    " 3400_COMMENT_BUILD
*&---------------------------------------------------------------------*
*&      Form  3500_SORT_TABLE_BUILD
*&---------------------------------------------------------------------*
FORM 3500_SORT_TABLE_BUILD .

  DATA: LS_SORT TYPE SLIS_SORTINFO_ALV.

  CLEAR LS_SORT.
  LS_SORT-SPOS      = 1.
  LS_SORT-FIELDNAME = 'IBLNO'.
  LS_SORT-TABNAME   = 'IT_LIST'.
  LS_SORT-UP        = 'X'.
* LS_SORT-GROUP     = '*'.             " Seiten- bei Gruppenwechsel
*  ls_sort-group     = 'UL'.            " Underline      -"-
  APPEND LS_SORT TO IT_SORT.

ENDFORM.                    " 3500_SORT_TABLE_BUILD
*&---------------------------------------------------------------------*
*&      Form  3700_LAYOUT_build
*&---------------------------------------------------------------------*
FORM 3700_LAYOUT_BUILD .

  MOVE: 'BOX'        TO GS_LAYOUT-BOX_FIELDNAME,
        'IT_HEADER'  TO GS_LAYOUT-BOX_TABNAME.

*  MOVE: '3'          TO gs_layout-no_vline. " 분리자 라인.

ENDFORM.                    " 3700_LAYOUT_build

*---------------------------------------------------------------------*
*       FORM TOP_OF_PAGE                                              *
*---------------------------------------------------------------------*
FORM TOP_OF_PAGE.                                           "#EC CALLED

  CALL FUNCTION 'REUSE_ALV_COMMENTARY_WRITE'
    EXPORTING
      IT_LIST_COMMENTARY = IT_LISTHEADER[].



ENDFORM.                    "TOP_OF_PAGE

*---------------------------------------------------------------------*
*       Form  USER_COMMAND                                            *
*---------------------------------------------------------------------*
FORM USER_COMMAND USING R_UCOMM     LIKE SY-UCOMM
                        RS_SELFIELD TYPE SLIS_SELFIELD.

  DATA: LS_LIST TYPE TY_TAB.

  CLEAR: LS_LIST.

  CASE R_UCOMM.
    WHEN '&REFRESH'.
      PERFORM P9000_DUELIST_REFRESH USING  RS_SELFIELD.

    WHEN 'ZTIT001'. " 후속기능
      CLEAR : G_LINE, LS_LIST.
      LOOP AT IT_HEADER WHERE BOX EQ 'X'.
        ADD 1 TO G_LINE.
        MOVE-CORRESPONDING IT_HEADER TO LS_LIST.
      ENDLOOP.
      CASE G_LINE.
        WHEN 0.
          IF RS_SELFIELD-TABNAME EQ 'IT_HEADER'.
            READ TABLE IT_HEADER INDEX RS_SELFIELD-TABINDEX.
          ELSEIF RS_SELFIELD-TABNAME EQ 'IT_LIST'.
            READ TABLE IT_LIST INDEX RS_SELFIELD-TABINDEX.
          ENDIF.
          IF SY-SUBRC NE 0.
            MESSAGE S003(OK). EXIT.
          ENDIF.
          IF RS_SELFIELD-TABNAME EQ 'HEADER'.
            MOVE-CORRESPONDING IT_HEADER TO LS_LIST.
          ELSEIF RS_SELFIELD-TABNAME EQ 'LIST'.
            MOVE-CORRESPONDING IT_LIST   TO LS_LIST.
          ENDIF.
        WHEN 1.
          SET PARAMETER ID 'ZTIIBLNO' FIELD LS_LIST-IBLNO.
          SET PARAMETER ID 'ZTIREQNO' FIELD SPACE.
          SET PARAMETER ID 'BES'      FIELD SPACE.
          CALL TRANSACTION 'ZTIT301' AND SKIP FIRST SCREEN .
        WHEN OTHERS.
          MESSAGE S035(0K).   EXIT.
      ENDCASE.
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
        WHEN 'EBELN'.
          PERFORM  DISPLAY_PURCHASE_ORDER(ZTIR0000)
                                          USING LS_LIST-EBELN
                                                LS_LIST-EBELP.
        WHEN 'REQNO' OR 'REQIT'.
          PERFORM  DISPLAY_IMPORT_DOCUMENT(ZTIR0000)
                                          USING LS_LIST-REQNO
                                                SPACE
                                                LS_LIST-REQIT.
        WHEN 'LIFNR'.
          PERFORM DISPLAY_VENDOR_MASTER(ZTIR0000)
                                          USING LS_LIST-LIFNR
                                                LS_LIST-EKORG.

        WHEN OTHERS.
          PERFORM  DISPLAY_BL_DOCUMENT(ZTIR0000)
                                          USING LS_LIST-IBLNO
                                                '00000'.
      ENDCASE.
    WHEN OTHERS.
  ENDCASE.

  CLEAR: R_UCOMM.

ENDFORM.                    "USER_COMMAND
*---------------------------------------------------------------------*
*       FORM PF_STATUS_SET                                            *
*---------------------------------------------------------------------*
FORM PF_STATUS_SET USING RT_EXTAB TYPE SLIS_T_EXTAB.

  SET TITLEBAR 'T1000'.

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
*&      Form  get_longtext_data
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM GET_LONGTEXT_DATA .

*> Partner Text
  PERFORM  P1000_GET_TEXTID_AND_TEXT USING ZTITIVK+3(10)
                                           C_TEXTOBJECT_HEADER
                                           C_SCR0100
                                           C_TRUE
                                           C_FALSE.

ENDFORM.                    " get_longtext_data

*&---------------------------------------------------------------------*
*&      Form  build_query_factories_class
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM BUILD_QUERY_FACTORIES_CLASS .

  CALL FUNCTION 'Z_TI_GET_INVOICE_TO_QUERY'
    IMPORTING
      EX_FACTORY = G_DATABLADE.

ENDFORM.                    " build_query_factories_class
*&---------------------------------------------------------------------*
*&      Form  3010_fill_field_category
*&---------------------------------------------------------------------*
FORM 3010_FILL_FIELD_CATEGORY  USING  P_SECTION P_FNAME P_VALUE.

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
*&---------------------------------------------------------------------*
*&      Form  3300_EVENT_EXIT_TABLE_BUILD
*&---------------------------------------------------------------------*
FORM 3300_EVENT_EXIT_TABLE_BUILD .

  CLEAR: IT_EVENT_EXIT-AFTER.
  IT_EVENT_EXIT-AFTER = 'X'.
  IT_EVENT_EXIT-UCOMM = '&OL0'.

  APPEND IT_EVENT_EXIT.
  IT_EVENT_EXIT-UCOMM = '&OLX'. APPEND IT_EVENT_EXIT.
  IT_EVENT_EXIT-UCOMM = '&OAD'. APPEND IT_EVENT_EXIT.

ENDFORM.                    " 3300_EVENT_EXIT_TABLE_BUILD

*&---------------------------------------------------------------------*
*&      Form  3910_CALL_ALV_HIERSEQ
*&---------------------------------------------------------------------*
FORM 3910_CALL_ALV_HIERSEQ .

  DATA: LS_VARIANT LIKE DISVARIANT.
  LS_VARIANT-REPORT  = SY-REPID.
  LS_VARIANT-VARIANT = P_VARI.
  G_REPID            = SY-REPID.                  " Callback Program.

  CALL FUNCTION 'REUSE_ALV_HIERSEQ_LIST_DISPLAY'
    EXPORTING
            I_INTERFACE_CHECK              = ' '
            I_CALLBACK_PROGRAM       = G_REPID
*            i_callback_pf_status_set       = ' '
*            i_callback_user_command        = ' '
            IS_LAYOUT                = GS_LAYOUT
            IT_FIELDCAT              = IT_FIELDCAT[]
*            it_excluding                   =
*            IT_SPECIAL_GROUPS              =
            IT_SORT                  = IT_SORT
*            IT_FILTER                      =
*            IS_SEL_HIDE                    =
*            I_SCREEN_START_COLUMN          = 0
*            I_SCREEN_START_LINE            = 0
*            I_SCREEN_END_COLUMN            = 0
*            I_SCREEN_END_LINE              = 0
            I_TABNAME_HEADER         = 'IT_HEADER'
            I_TABNAME_ITEM           = 'IT_LIST'
            I_STRUCTURE_NAME_HEADER  = 'IT_HEADER'
            I_STRUCTURE_NAME_ITEM    = 'IT_LIST'
            IS_KEYINFO               = GS_KEYINFO
            I_DEFAULT                = C_CHARX
            I_SAVE                   = C_CHARA
            IS_VARIANT               = LS_VARIANT
            IT_EVENTS                = IT_EVENTS[]
            IT_EVENT_EXIT            = IT_EVENT_EXIT[]
            IS_PRINT                 = GS_PRINT
*            IS_REPREP_ID             =
*            I_BYPASSING_BUFFER       =
*            I_BUFFER_ACTIVE          =
* IMPORTING
*            E_EXIT_CAUSED_BY_CALLER  =
*            ES_EXIT_CAUSED_BY_USER   =
    TABLES
      T_OUTTAB_HEADER                = IT_HEADER[]
      T_OUTTAB_ITEM                  = IT_LIST[]
 EXCEPTIONS
      PROGRAM_ERROR                  = 1
      OTHERS                         = 2.

  IF SY-SUBRC <> 0.
    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

ENDFORM.                    " 3910_CALL_ALV_HIERSEQ
*&---------------------------------------------------------------------*
*&      Form  3600_event_table_build
*&---------------------------------------------------------------------*
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
*&      Form  p1100_check_input_values
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM P1100_CHECK_INPUT_VALUES .

  DATA: L_BUKRS   LIKE T001-BUKRS,
        L_LIFNR   LIKE LFA1-LIFNR,
        L_EKORG   LIKE T024E-EKORG,
        L_EKGRP   LIKE T024-EKGRP.

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
*&      Form  p9000_duelist_refresh
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
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
*&      Form  FI_DOCUMENT_CREATE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM FI_DOCUMENT_CREATE .


  IF GF_POST_DIV IS NOT INITIAL.  "분할송장로직 분기
    PERFORM FI_IV_POST_DIV USING ' '
                                  ZTITIVK-BUPLA
                                  C_CHARM.
    EXIT.
  ENDIF.

  PERFORM  INVOICE_DOCUMENT_CREATE  USING ' '
                                          ZTITIVK-BUPLA
                                          C_CHARM.

  "[기능개선____] 전기후 사후송금요청화면 이동
  IF ZTITIVK-BELNR IS NOT INITIAL AND ZTITIVK-BUKRS EQ '3000'.
    PERFORM CHECK_REQ_TT_SCREEN.
  ENDIF.


ENDFORM.                    " FI_DOCUMENT_CREATE
*&---------------------------------------------------------------------*
*&      Form  FI_DOCUMENT_CANCEL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM FI_DOCUMENT_CANCEL .

  PERFORM  INVOICE_DOCUMENT_CANCEL  USING C_CHARM.  ">물류송장검증.

ENDFORM.                    " FI_DOCUMENT_CANCEL

*&---------------------------------------------------------------------*
*&      Form  OTHER_FUNCTIONS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM OTHER_FUNCTIONS .

  CASE OK_CODE.
    WHEN 'ZTIACDOC'.
      PERFORM ACCOUNT_DOCUMENT_DISPLAY USING ZTITIVK-BUKRS
                                             ZTITIVK-GJAHR
                                             ZTITIVK-BELNR.

    WHEN 'ZTIMMDOC'.
      PERFORM DISPLAY_LIV_DOCUMENT  USING ZTITIVK-BELNR
                                          ZTITIVK-GJAHR
                                          ZTITIVK-BUKRS.

*    WHEN 'ZTIDSTR'.
*      PERFORM document_simulation_fi USING ok-code.
*
*    WHEN 'ZTIONTIME'.  ">일회성 계정.
*      PERFORM set_one_time_vender_data.
    WHEN 'ZTIMK03'.     ">공급업체.
      PERFORM DISPLAY_VENDOR_MASTER USING ZTITIVK-LIFNR
                                          ZTITIVK-EKORG.
    WHEN 'ZTICHDOC'.    ">변경문서.
      G_OBJEKT   = 'ZTIIVCHDOC'.
      G_OBJEKTID = ZTITIVK+3(10).
      PERFORM DISPLAY_CHANGE_DOCUMENT USING G_OBJEKT
                                            G_OBJEKTID.

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
  IF G_MODE EQ C_CHARC OR
     G_MODE EQ C_CHARM OR
     G_MODE EQ C_CHARP.

*> Item Amount.
*  PERFORM summary_invoice_amount  USING c_success.
    PERFORM CHECK_OPEN_AMOUNT.
  ENDIF.

ENDFORM.                    " BEFORE_TRANSPORT_PAI
*&---------------------------------------------------------------------*
*&      Form  get_total_po_amount
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM GET_TOTAL_PO_AMOUNT TABLES   LT_EKPO  STRUCTURE GT_EKPO
                         USING    P_POAMT.

  SELECT EBELN EBELP PEINH BPUMZ BPUMN MENGE NETPR WEBRE UEBTO
    INTO CORRESPONDING FIELDS OF TABLE LT_EKPO
    FROM EKPO
     FOR ALL ENTRIES IN IT_TAB
   WHERE EBELN  EQ IT_TAB-EBELN
     AND EBELP  EQ IT_TAB-EBELP.

  CLEAR: P_POAMT.
  LOOP AT LT_EKPO.

    G_TABIX = SY-TABIX.

    LT_EKPO-MENGE = LT_EKPO-MENGE +
                    ( ( LT_EKPO-MENGE * LT_EKPO-UEBTO ) / 100 ).

    CALL FUNCTION 'Z_TI_CALC_ITEM_AMOUNT'
      EXPORTING
        PEINH = LT_EKPO-PEINH
        BPUMZ = LT_EKPO-BPUMZ
        BPUMN = LT_EKPO-BPUMN
        MENGE = LT_EKPO-MENGE
        NETPR = LT_EKPO-NETPR
      CHANGING
        NETWR = LT_EKPO-NETWR.

    ADD LT_EKPO-NETWR TO P_POAMT.

    MODIFY LT_EKPO INDEX G_TABIX.

  ENDLOOP.

ENDFORM.                    " get_total_po_amount
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
*&      Form  GET_AFTYN
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_ZTITIVK_EBELN  text
*      <--P_G_AFTYN  text
*----------------------------------------------------------------------*
FORM GET_AFTYN  USING    P_ZTITIVK_EBELN
                CHANGING P_G_AFTYN.

  DATA : L_BSTYP LIKE EKKO-BSTYP,
         L_BSART LIKE EKKO-BSART,
         L_ZTERM LIKE EKKO-ZTERM.

  SELECT SINGLE BSTYP BSART ZTERM
    INTO (L_BSTYP, L_BSART, L_ZTERM)
    FROM EKKO
   WHERE EBELN EQ P_ZTITIVK_EBELN.

  SELECT SINGLE AFTYN
    INTO P_G_AFTYN
    FROM ZTITIG02
   WHERE BSTYP = L_BSTYP
     AND BSART = L_BSART
     AND ZTERM = L_ZTERM.

ENDFORM.                    " GET_AFTYN
*&---------------------------------------------------------------------*
*&      Form  CHECK_INSURANCE_POLICY
*&---------------------------------------------------------------------*
*       기능개선 283274 - 추가
*----------------------------------------------------------------------*
FORM CHECK_INSURANCE_POLICY  USING    PV_IBLNO
                             CHANGING PV_CHECK.
  DATA: LV_BUKRS    LIKE ZTITBLK-BUKRS,
        LV_INCO1    LIKE ZTITBLK-INCO1,
        LV_RPTTY    LIKE ZTITBLK-RPTTY,
        LV_IIPNO    LIKE ZTITIP1-IIPNO,
        LV_MATNR    LIKE MARA-MATNR.

  DATA: BEGIN OF LT_ZTITBLP OCCURS 0.
          INCLUDE STRUCTURE ZTITBLP.
  DATA: CHK(1).
  DATA: END OF LT_ZTITBLP.
  CLEAR : LT_ZTITBLP, LT_ZTITBLP[].

  PV_CHECK = 'X'.              "초기상태 - 오류

  CLEAR : LV_BUKRS, LV_INCO1, LV_RPTTY, LV_IIPNO.

  SELECT SINGLE BUKRS
                INCO1
                RPTTY
    INTO (LV_BUKRS, LV_INCO1, LV_RPTTY)
    FROM ZTITBLK
   WHERE IBLNO = PV_IBLNO.

  SELECT *
    INTO CORRESPONDING FIELDS OF TABLE LT_ZTITBLP
    FROM ZTITBLP
   WHERE IBLNO = PV_IBLNO.


  IF LV_BUKRS = '1000' AND
   ( LV_INCO1 = 'FOB'  OR LV_INCO1 = 'FCA' OR
     LV_INCO1 = 'FAS'  OR LV_INCO1 = 'CPT' OR
     LV_INCO1 = 'CFR'  OR LV_INCO1 = 'EXW' ).

*___미통관은 보험 체크 안함
    IF LV_RPTTY EQ C_CHARZ.
      CLEAR : PV_CHECK.
    ENDIF.

*___적하보험 점검 예외 B/L List
    SELECT SINGLE IBLNO
      INTO PV_IBLNO
      FROM ZMMT0232
     WHERE IBLNO = PV_IBLNO.

    IF SY-SUBRC <> 0.
*___B/L 기준 적하보험 생성 여부 점검
      SELECT SINGLE IIPNO
        INTO LV_IIPNO
        FROM ZTITIP1
       WHERE IBLNO = PV_IBLNO.

      IF SY-SUBRC = 0.
        CLEAR : PV_CHECK.
      ENDIF.
    ELSE.
      CLEAR : PV_CHECK.
    ENDIF.

    CHECK PV_CHECK IS NOT INITIAL.

*___적하보험 점검 예외 자재코드 (운임예외 자재코드와 동일)
    LOOP AT  LT_ZTITBLP.
      SELECT SINGLE MATNR
        INTO LV_MATNR
        FROM ZMMT0233
       WHERE MATNR = LT_ZTITBLP-MATNR.

      IF SY-SUBRC <> 0.
        LT_ZTITBLP-CHK = 'X'.

*___사전 적하보험 생성 여부 점검 (수입요청관리번호)
        IF LT_ZTITBLP-REQNO IS NOT INITIAL.
          SELECT SINGLE IIPNO
            INTO LV_IIPNO
            FROM ZTITIP1
           WHERE REQNO = LT_ZTITBLP-REQNO.
        ELSE.
*___사후 적하보험 생성 여부 점검 (구매오더)
          SELECT SINGLE IIPNO
            INTO LV_IIPNO
            FROM ZTITIP1
           WHERE EBELN = LT_ZTITBLP-EBELN.
        ENDIF.

        IF SY-SUBRC = 0.
          CLEAR  LT_ZTITBLP-CHK.
        ENDIF.
      ENDIF.

      MODIFY LT_ZTITBLP TRANSPORTING CHK.
    ENDLOOP.

    READ TABLE LT_ZTITBLP WITH KEY CHK = 'X'.
    IF SY-SUBRC = 0.
      PV_CHECK = 'X'.
    ELSE.
      CLEAR : PV_CHECK.
    ENDIF.

  ELSE.
    CLEAR : PV_CHECK.
  ENDIF.

ENDFORM.                    " CHECK_INSURANCE_POLICY
*&---------------------------------------------------------------------*
*&      Form  FI_IV_DOCUMENT_DIV
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM FI_IV_DOCUMENT_DIV USING P_EMPFK    LIKE ZTITCSK-EMPFK
                            P_BUPLA    LIKE ZTITCSK-BUPLA
                            P_PTDCL    LIKE ZTITCSK-PTDCL.

*> Fields check.
  PERFORM  CHECK_FOR_DOCUMENT_FIELD USING G_MODE.
  IF G_LINE EQ 0.
    MESSAGE S911.
  ELSE.
    EXIT.
  ENDIF.

  IF OK_CODE EQ 'ZTISIMUL'.
    G_SIMULATION = C_TRUE.
  ELSE.
    G_SIMULATION = SPACE.
  ENDIF.

*> Set posting용 데이타 Move
  PERFORM  SET_INVOICE_DATA.
  CHECK G_ANSWER EQ C_CHARY.

*> 비용처리일 경우.
  IF G_DOCUMENT EQ C_CS.
    PERFORM  CHECK_NO_DRAFT_ITEM IN PROGRAM ZTIR9000 USING G_ANSWER.
    CHECK G_ANSWER EQ 'J'.
  ENDIF.

*> 전기용 BAPI 함수 Call
  CASE P_PTDCL.
    WHEN C_CHARM.   ">물류송장검증.
      PERFORM  CALL_INVOICE_CREATE_FUNC USING   G_SIMULATION
                                                P_EMPFK
                                                P_BUPLA
                                                G_SUBRC.
    WHEN C_CHARF.    ">회계기표(BAPIs).
      PERFORM  CALL_ACCOUNT_CREATE_FUNC USING   G_SIMULATION
                                                G_SUBRC.
*> 회계전표 부가세 기표일 경우.
    WHEN C_CHARV.
      PERFORM  CALL_VAT_CREATE_FUNC     USING   G_SIMULATION
                                                G_SUBRC.
  ENDCASE.

  IF G_SUBRC EQ 0.    ">Success
    IF G_SIMULATION = C_TRUE.
      CASE P_PTDCL.
        WHEN C_CHARM.   ">물류송장검증.
          PERFORM DOCUMENT_SIMULATION.
        WHEN C_CHARF.   ">회계검증.
          PERFORM DOCUMENT_SIMULATION_FI IN PROGRAM (G_REPID)
                                         USING OK-CODE.
        WHEN C_CHARV.   ">회계검증.
          PERFORM DOCUMENT_SIMULATION_FI IN PROGRAM (G_REPID)
                                         USING OK-CODE.
        WHEN OTHERS.
          MESSAGE S869.
      ENDCASE.

      IF OK-CODE EQ FCOBU.
        CLEAR: G_SIMULATION.
        CASE P_PTDCL.
          WHEN C_CHARM.   ">물류송장검증.
            PERFORM  CALL_INVOICE_CREATE_FUNC USING   G_SIMULATION
                                                      P_EMPFK
                                                      P_BUPLA
                                                      G_SUBRC.

          WHEN C_CHARF.    ">회계기표.
            PERFORM  CALL_ACCOUNT_CREATE_FUNC USING   G_SIMULATION
                                                      G_SUBRC.
*> 회계전표 부가세 기표일 경우.
          WHEN C_CHARV.
            PERFORM  CALL_VAT_CREATE_FUNC     USING   G_SIMULATION
                                                      G_SUBRC.
        ENDCASE.

        IF G_SUBRC EQ 0.    ">Success
          PERFORM P8000_SAVE_MASTER_DATA USING 'H'.
          CASE P_PTDCL.
            WHEN C_CHARM.   ">물류송장검증.
              MESSAGE S260(M8) WITH INVOICEDOCNUMBER.
            WHEN OTHERS.
              MESSAGE S260(M8) WITH INVOICEDOCNUMBER.
          ENDCASE.
        ENDIF.

      ELSE.  "뒤로가기인 경우 (종료)
        G_SUBRC = 4.
      ENDIF.
    ELSE.
*>Data Save.
      PERFORM P8000_SAVE_MASTER_DATA USING 'H'.
      CASE P_PTDCL.
        WHEN C_CHARM.   ">물류송장검증.
          MESSAGE S260(M8) WITH INVOICEDOCNUMBER.
        WHEN OTHERS.
          MESSAGE S260(M8) WITH INVOICEDOCNUMBER.
      ENDCASE.
    ENDIF.
  ENDIF.



ENDFORM.                    " FI_IV_DOCUMENT_DIV
