************************************************************************
* Title         :  ZTIR2000F01                                         *
*                                                                      *
* Description   : 수입 B/L 관리 Subroutine Include                     *
*                                                                      *
* Creation Date : 2004/02/11                                           *
*                                                                      *
* Author        : SeogBong, Kang                                       *
*                 Copyright ⓒ ASEG Co., LTD. All rights reserved.     *
************************************************************************
*----------------------------------------------------------------------*
*                M O D I F I C A T I O N   L O G                       *
*----------------------------------------------------------------------*
* Date         Programmer       Transport#  Description                *
*----------------------------------------------------------------------*
* dd-mmm-yyyy  xxxxxxxxxxxxxxx  DVPK9xxxxx  xxxxxxxxxxxxxxxxxxxxxxxxx  *
*                                                                      *
*                                                                      *
*----------------------------------------------------------------------*


*&---------------------------------------------------------------------*
*&      Form  p2000_get_lc_open_items
*&---------------------------------------------------------------------*
FORM P2000_GET_LC_OPEN_ITEMS .

  CLEAR: G_COUNT, IT_REQNO.
  REFRESH : IT_REQNO.

  G_LINEN    = 20.
  G_OUT_TEXT = '데이타를 검색 중입니다 %99999%%'(P01).
  REPLACE '%99999%' WITH G_LINEN INTO G_OUT_TEXT.
  PERFORM SHOW_PROGRESS_BAR USING G_OUT_TEXT G_LINE.

*  PERFORM get_used_payment_term  TABLES  it_ZTItig02
*                                 USING   g_subrc c_success.
*  IF g_subrc NE 0.
*    EXIT.
*  ENDIF.

  SELECT *
        INTO CORRESPONDING FIELDS OF TABLE IT_ZTISRQIT
        FROM ZTIVRQ00
        WHERE BUKRS  IN S_BUKRS  "회사코드.
          AND REQNO  IN S_REQNO  "수입의뢰 관리번호.
          AND REQTY  IN S_REQTY  "수입의뢰 종류.
          AND ILCTY  IN S_ILCTY  "신용장 종류.
          AND LIFNR  IN S_LIFNR  "공급업체 계정번호.
          AND LIFRE  IN S_LIFRE  "다른 송장발행처.
          AND OFFER  IN S_OFFER  "오퍼상(Offer).
          AND OPNBK  IN S_OPNBK  "개설은행.
          AND EKORG  IN S_EKORG  "구매조직.
          AND EKGRP  IN S_EKGRP  "구매그룹.
          AND OPNNO  IN S_OPNNO  "수입개설번호
          AND OPNDT  IN S_OPNDT  "개설일자.
          AND ZTERM  IN S_ZTERM  "지급조건키.
          AND WAERS  IN S_WAERS  "개설통화.
          AND INCO1  IN S_INCO1  "인도조건 (파트 1).
          AND EXDAT  IN S_EXDAT  "COM:유효기일.
          AND LSDAT  IN S_LSDAT  "COM:최종선적일자.
          AND FWDTY  IN S_FWDTY  "운송 방법.
          AND FLAND  IN S_FLAND  "선적국가.
          AND FPORT  IN S_FPORT  "선적항.
          AND TLAND  IN S_TLAND  "도착국가.
          AND TPORT  IN S_TPORT  "도착항.
          AND DOCST  IN S_DOCST  "문서상태.
          AND REQIT  IN S_REQIT  "수입의뢰 품목번호.
          AND EBELN  IN S_EBELN  "구매전표번호.
          AND EBELP  IN S_EBELP  "구매문서 품목번호.
*>        선급금/유보금 제외.
          AND PPAID  NE C_TRUE
          AND RPAID  NE C_TRUE
*>        수입의뢰 종류 중 LO/PU제외.
          AND REQTY  NE 'PU'
          AND REQTY  NE 'LO'.
**
  PERFORM GET_AVAILABLE_LC_ITEM TABLES IT_ZTISRQIT
                                       IT_REQNO
                                USING  C_SUCCESS
                                       C_TRUE.

ENDFORM.                    " p2000_get_lc_open_items


*&---------------------------------------------------------------------*
*&      Form  set_request_of_import_data
*&---------------------------------------------------------------------*
*       수입의뢰 아이템을 생성함.
*----------------------------------------------------------------------*
FORM SET_REQUEST_OF_IMPORT_DATA TABLES P_IT_TAB    LIKE IT_TAB
                                USING  P_ZTIVPO00 STRUCTURE ZTIVPO00
                                       P_ZTITRQK STRUCTURE ZTITRQK
                                       P_ZTITRQS STRUCTURE ZTITRQS
                                       P_PO_WA    STRUCTURE IT_PO.

  MOVE-CORRESPONDING P_ZTIVPO00 TO : P_IT_TAB, P_ZTITRQK, P_ZTITRQS.

  MOVE: P_PO_WA-RQMNG  TO P_IT_TAB-BLMNG,
        P_PO_WA-RQMNGS TO P_IT_TAB-BLMNGS,
        P_PO_WA-RQMNGL TO P_IT_TAB-BLMNGL.

  MOVE: SY-UNAME TO P_IT_TAB-CNAM,
        SY-DATLO TO P_IT_TAB-CDAT,
        SY-TIMLO TO P_IT_TAB-CTME,
        SY-UNAME TO P_IT_TAB-UNAM,
        SY-DATLO TO P_IT_TAB-UDAT,
        SY-TIMLO TO P_IT_TAB-UTME.

  APPEND P_IT_TAB.

*>아이템 번호를 생성함.
  PERFORM SET_ITEM_NUMBER_BUILD TABLES P_IT_TAB
                                USING  ZTITBLK.

  PERFORM GET_OTHERS_TEXT_BY_MASTER_DATA.

ENDFORM.                    " set_request_of_import_data
*&---------------------------------------------------------------------*
*&      Form  set_bill_of_lading_data
*&---------------------------------------------------------------------*
*       B/L 아이템을 생성함.
*----------------------------------------------------------------------*
FORM SET_BILL_OF_LADING_DATA    TABLES P_IT_TAB   LIKE IT_TAB
                                USING  P_ZTIVRQ00 STRUCTURE ZTIVRQ00
                                       P_ZTITBLK STRUCTURE ZTITBLK
                                       P_ZTISRQIT STRUCTURE IT_ZTISRQIT.
  DATA: L_NETWR               TYPE NETWR.
  DATA: L_RQMNGQ              TYPE ZTIRQMNG,
        L_PPMNGQ              TYPE ZTIPPMNG,
        L_NETWRQ              TYPE NETWR,
        L_REFWR               TYPE REFWR,
        L_PPMNGB              TYPE ZTIPPMNG,
        L_PPAMTQ              TYPE ZTIPPAM2,
        L_PPAMTB              TYPE ZTIPPAM2.

  CLEAR: P_IT_TAB.

  MOVE-CORRESPONDING P_ZTIVRQ00 TO : P_IT_TAB, P_ZTITBLK.

  MOVE: P_ZTISRQIT-BLMNG  TO P_IT_TAB-BLMNG,
        P_ZTISRQIT-BLMNGS TO P_IT_TAB-BLMNGS,
        P_ZTISRQIT-BLMNGL TO P_IT_TAB-BLMNGL,
        P_ZTISRQIT-REPOS  TO P_IT_TAB-REPOS,
        P_ZTISRQIT-WEPOS  TO P_IT_TAB-WEPOS.

  MOVE: SY-UNAME TO P_IT_TAB-CNAM,
        SY-DATLO TO P_IT_TAB-CDAT,
        SY-TIMLO TO P_IT_TAB-CTME,
        SY-UNAME TO P_IT_TAB-UNAM,
        SY-DATLO TO P_IT_TAB-UDAT,
        SY-TIMLO TO P_IT_TAB-UTME.

  IF NOT  P_IT_TAB-EBELN IS INITIAL.

* 구매오더 아이템 Read.
    SELECT SINGLE MENGE WERKS LGORT MATNR TXZ01 MENGE
                  LOEKZ ELIKZ BPRME BPUMZ BPUMN UMREZ
                  UMREN NETPR PEINH UEBTO UEBTK UNTTO
                  REPOS WEPOS
    INTO CORRESPONDING FIELDS OF P_IT_TAB
      FROM EKPO
     WHERE EBELN  EQ  P_IT_TAB-EBELN
       AND EBELP  EQ  P_IT_TAB-EBELP.

*> 수입의뢰 정보 Read.
    IF NOT P_IT_TAB-REQNO IS INITIAL.
      SELECT SINGLE RQMNG PPMNG IPAMT NETWR
        INTO (P_IT_TAB-RQMNG, L_PPMNGQ, L_PPAMTQ, L_NETWRQ)
        FROM ZTIVRQ00
       WHERE REQNO   EQ  P_IT_TAB-REQNO
         AND REQIT   EQ  P_IT_TAB-REQIT.

*> 선급금 참조 수량 집계.
      SELECT  SUM( BLMNG ) SUM( PPMNG ) SUM( PPAMT ) SUM( REFWR )
        INTO  (P_IT_TAB-BLMNGS, L_PPMNGB, L_PPAMTB, L_REFWR)
        FROM  ZTIVBL00
       WHERE  REQNO       EQ  P_IT_TAB-REQNO
         AND  REQIT       EQ  P_IT_TAB-REQIT
         AND NOT ( IBLNO  EQ  P_IT_TAB-IBLNO
         AND       IBLIT  EQ  P_IT_TAB-IBLIT ).

*> 선급금 수량 = 선급금 합계 수량 - 선급금 참조 합계수량.
      P_IT_TAB-PPMNG = L_PPMNGQ - L_PPMNGB.
      P_IT_TAB-PPAMT = L_PPAMTQ - L_PPAMTB.

      IF P_IT_TAB-PPAMT LT 0 OR
         P_IT_TAB-PPMNG LT 0.
        P_IT_TAB-PPAMT = P_IT_TAB-PPMNG = 0.
      ENDIF.
*> 초과납품허용치.
      IF NOT P_IT_TAB-UEBTO IS INITIAL.
        P_IT_TAB-BLMNGM = ( P_IT_TAB-MENGE * P_IT_TAB-UEBTO ) / 100.
      ELSE.
        P_IT_TAB-BLMNGM =  0.
      ENDIF.
**> 무제한 납품 허용..
*      IF NOT ZTITBLP-uebtk IS INITIAL.
*
*      ENDIF.
      P_IT_TAB-BLMNGL =  P_IT_TAB-RQMNG - P_IT_TAB-BLMNGS.
      P_IT_TAB-BLMNG  =  P_IT_TAB-BLMNGL.
*      p_it_tab-refwr  =  l_netwrq - l_ppamtq - l_refwr.
      P_IT_TAB-REFWR  =  L_NETWRQ - L_REFWR.
      IF P_IT_TAB-REFWR LT C_ZERO.
        P_IT_TAB-REFWR = 0.
      ENDIF.
*      p_it_tab-netwr = p_it_tab-refwr.
    ELSEIF NOT P_IT_TAB-EBELN IS INITIAL.
      P_IT_TAB-RQMNG = P_IT_TAB-MENGE.

      SELECT  SUM( BLMNG )
        INTO  P_IT_TAB-BLMNGS
        FROM  ZTIVBL00
       WHERE  EBELN       EQ  P_IT_TAB-EBELN
         AND  EBELP       EQ  P_IT_TAB-EBELP
         AND NOT ( IBLNO  EQ  P_IT_TAB-IBLNO
         AND       IBLIT  EQ  P_IT_TAB-IBLIT ).
*> 초과납품허용치.
      IF NOT P_IT_TAB-UEBTO IS INITIAL.
        P_IT_TAB-BLMNGM = ( P_IT_TAB-MENGE * P_IT_TAB-UEBTO ) / 100.
      ELSE.
        P_IT_TAB-BLMNGM =  0.
      ENDIF.
**> 무제한 납품 허용..
*      IF NOT ZTITBLP-uebtk IS INITIAL.
*
*      ENDIF.
      P_IT_TAB-BLMNGL =  P_IT_TAB-RQMNG - P_IT_TAB-BLMNGS.
      P_IT_TAB-BLMNG  =  P_IT_TAB-BLMNGL.
    ENDIF.

    IF P_IT_TAB-BLMNGL LE 0.
      P_IT_TAB-BLMNGL = 0.
    ENDIF.
  ENDIF.
  IF NOT P_IT_TAB-RSNUM IS INITIAL.
*RSPOS
*RSART
  ENDIF.

*> 무환 Setting.
  IF P_IT_TAB-REPOS IS INITIAL AND
     NOT P_IT_TAB-EBELN IS INITIAL.
    P_IT_TAB-NDFTY = C_CHARS.    "> 무환.
  ENDIF.

  APPEND P_IT_TAB.

*>아이템 번호를 생성함.
  PERFORM SET_ITEM_NUMBER_BUILD TABLES P_IT_TAB
                                USING  P_ZTITBLK.

  PERFORM GET_OTHERS_TEXT_BY_MASTER_DATA.

ENDFORM.                    " set_request_of_import_data

*&---------------------------------------------------------------------*
*&      Form  set_bill_of_lading_data
*&---------------------------------------------------------------------*
*       B/L 아이템을 생성함.
*----------------------------------------------------------------------*
FORM SET_BILL_OF_LADING_DATA_OFE TABLES P_IT_TAB   LIKE IT_TAB
                                 USING P_ZTIVRS00 STRUCTURE ZTIVRS00
                                       P_ZTITBLK STRUCTURE ZTITBLK
                                       P_RESB     STRUCTURE IT_RESB.
  CLEAR: P_IT_TAB.

  MOVE-CORRESPONDING P_ZTIVRS00 TO : P_IT_TAB, P_ZTITBLK.

  MOVE: P_RESB-BLMNG  TO P_IT_TAB-BLMNG,
        P_RESB-BLMNGS TO P_IT_TAB-BLMNGS,
        P_RESB-BLMNGL TO P_IT_TAB-BLMNGL.

  MOVE: SY-UNAME TO P_IT_TAB-CNAM,
        SY-DATLO TO P_IT_TAB-CDAT,
        SY-TIMLO TO P_IT_TAB-CTME,
        SY-UNAME TO P_IT_TAB-UNAM,
        SY-DATLO TO P_IT_TAB-UDAT,
        SY-TIMLO TO P_IT_TAB-UTME.

  SELECT  SUM( BLMNG )
    INTO  P_IT_TAB-BLMNGS
    FROM  ZTIVBL00
   WHERE  RSNUM       EQ  P_IT_TAB-RSNUM
     AND  RSPOS       EQ  P_IT_TAB-RSPOS
     AND  RSART       EQ  P_IT_TAB-RSART
     AND NOT ( IBLNO  EQ  P_IT_TAB-IBLNO
     AND       IBLIT  EQ  P_IT_TAB-IBLIT ).
**> 초과납품허용치.
*        if not ZTITBLP-UEBTO is initial.
*           ZTITBLP-rqmng = ZTITBLP-rqmng +
*                          ( ZTITBLP-rqmng * ZTITBLP-UEBTO ) / 100.
*        endif.
*        if not ZTITBLP-UEBTK is initial.
*
*        endif.
  P_IT_TAB-BLMNGL =  P_IT_TAB-BDMNG - P_IT_TAB-BLMNGS.


  IF P_IT_TAB-BLMNGL LE 0.
    P_IT_TAB-BLMNGL = 0.
  ENDIF.

  APPEND P_IT_TAB.

*>아이템 번호를 생성함.
  PERFORM SET_ITEM_NUMBER_BUILD TABLES P_IT_TAB
                                USING  P_ZTITBLK.

  PERFORM GET_OTHERS_TEXT_BY_MASTER_DATA.

ENDFORM.                    " set_request_of_import_data_ofe

*&---------------------------------------------------------------------*
*&      Form  get_and_check_po_data
*&---------------------------------------------------------------------*
*       Get 구매오더 데이타.
*----------------------------------------------------------------------*
FORM GET_AND_CHECK_PO_DATA  USING    P_EBELN
                                     P_EBELP
                                     P_MODIFY
                                     P_ZTIVPO00 STRUCTURE ZTIVPO00
                                     P_COUNT.

  CLEAR: P_ZTIVPO00.

  SELECT SINGLE * INTO P_ZTIVPO00
    FROM ZTIVPO00
   WHERE EBELN EQ P_EBELN
     AND EBELP EQ P_EBELP.

  IF SY-SUBRC EQ 0.
*>문서유형 체크.
    READ TABLE IT_ZTITIG02 WITH KEY BSART = P_ZTIVPO00-BSART
                                    ZTERM = P_ZTIVPO00-ZTERM
                                    BINARY SEARCH.
    IF SY-SUBRC NE 0.
      MESSAGE S002 WITH P_ZTIVPO00-BSART P_ZTIVPO00-ZTERM.
      P_MODIFY = C_TRUE.
      EXIT.
    ELSE.
      IF IT_ZTITIG02-REQTY  NE ZTITRQK-REQTY.
        IF P_COUNT          GT C_ZERO.
          MESSAGE S004 WITH IT_ZTITIG02-REQTY ZTITRQK-REQTY.
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
      MESSAGE S003 WITH P_ZTIVPO00-LIFNR ZTITRQK-LIFNR.
      P_MODIFY = C_TRUE.
      EXIT.
    ENDIF.
*통화키 체크.
    IF ZTITRQS-WAERS    NE  P_ZTIVPO00-WAERS AND
       P_COUNT           GT  C_ZERO.
      MESSAGE S006 WITH P_ZTIVPO00-WAERS ZTITRQS-WAERS.
      P_MODIFY = C_TRUE.
    ENDIF.

*> Lock Object
    PERFORM  SET_PO_LOCK_OBJECT  USING P_EBELN
                                       P_EBELP
                                       C_LOCK
                                       C_SUCCESS
                                       P_MODIFY.
  ELSE.
    MESSAGE S019(06) WITH P_EBELN.
    P_MODIFY = C_TRUE.
    EXIT.
  ENDIF.

ENDFORM.                    " get_and_check_po_data
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
                                     P_COUNT
                                     P_MSGTY.

  CLEAR: P_ZTIVRQ00.

  SELECT SINGLE * INTO P_ZTIVRQ00
    FROM ZTIVRQ00
   WHERE REQNO EQ P_REQNO
     AND REQIT EQ P_REQIT.


* 20070503 simcho by 박혁세 K
* TT00끼리만 묶일 수 있도록

  IF SY-TABIX = 1 .
    CLEAR : LV_ZTERM, LV_EBELN.
    LV_ZTERM = ZTIVRQ00-ZTERM.
    LV_EBELN = ZTIVRQ00-EBELN.
  ENDIF.

* end simcho

  IF SY-SUBRC EQ 0.
    IF P_ZTIVRQ00-REQTY EQ C_TT.
      IF P_ZTIVRQ00-DOCST NE C_CHARO.
*> 수입의뢰 종류 Fixed value read.
        PERFORM  DDIC_DOMAIN_VALUE_TEXT_READ USING 'ZTIDOCST'
                                                   SY-LANGU
                                                   P_ZTIVRQ00-DOCST
                                                   G_DDTEXT
                                                   C_SUCCESS.
        IF SY-DYNNR EQ C_SCR0100.
          MESSAGE ID 'ZMTI00' TYPE 'W' NUMBER 250
                            WITH P_ZTIVRQ00-REQNO G_DDTEXT.
        ELSE.
          MESSAGE ID 'ZMTI00' TYPE 'I' NUMBER 250
                            WITH P_ZTIVRQ00-REQNO G_DDTEXT.
        ENDIF.
*        p_modify = c_true.
*        EXIT.
      ENDIF.
      IF P_ZTIVRQ00-ANBTY EQ C_CHARA.
        MESSAGE ID 'ZMTI00' TYPE P_MSGTY NUMBER 223
                          WITH '사후송금' P_ZTIVRQ00-REQNO.
        P_MODIFY = C_TRUE.
        EXIT.
      ENDIF.
      IF P_ZTIVRQ00-PPAID EQ C_TRUE.
        MESSAGE ID 'ZMTI00' TYPE P_MSGTY NUMBER 223
                          WITH '선급금' P_ZTIVRQ00-REQNO.
        P_MODIFY = C_TRUE.
        EXIT.
      ENDIF.
      IF ZTIVRQ00-RPAID EQ C_TRUE.
        MESSAGE ID 'ZMTI00' TYPE P_MSGTY NUMBER 223
                          WITH '유보금' P_ZTIVRQ00-REQNO.
        P_MODIFY = C_TRUE.
        EXIT.
      ENDIF.
    ENDIF.
* 20070503 simcho by 박혁세
*    IF lv_zterm = 'TT00' OR ztivrq00-zterm = 'TT00' .
*      IF lv_zterm <> ztivrq00-zterm.
*        MESSAGE ID 'ZMTI00' TYPE p_msgty NUMBER 997
*                          WITH ztivrq00-zterm lv_zterm
*                               '지급조건이 상이합니다'.
*      ENDIF.
*    ENDIF.

*    IF sy-tabix >= 2.
*      IF lv_ebeln <> ztivrq00-ebeln AND
*         lv_zterm EQ 'TT00'         AND
*         ztivrq00-zterm <> 'TT00' .
*        MESSAGE ID 'ZMTI00' TYPE p_msgty NUMBER 998
*                         WITH  '신용장지급조건은'
*                               '다중선택 선적기능을 수행할 수 없습니다'
*.
*
*      ELSEIF lv_ebeln <> ztivrq00-ebeln AND
*             ztivrq00-zterm EQ 'TT00'   AND
*             lv_zterm <> 'TT00' .
*        MESSAGE ID 'ZMTI00' TYPE p_msgty NUMBER 998
*                         WITH  '신용장지급조건은'
*                               '다중선택 선적기능을 수행할 수 없습니다'
*.
*
*      ELSEIF lv_ebeln <> ztivrq00-ebeln AND
*             ztivrq00-zterm <> 'TT00'   AND
*             lv_zterm <> 'TT00' .
*        MESSAGE ID 'ZMTI00' TYPE p_msgty NUMBER 998
*                         WITH  '신용장지급조건은'
*                               '다중선택 선적기능을 수행할 수 없습니다'
*.
*
*      ENDIF.
*    ENDIF.
* end simcho

*>Vendor 체크.
    IF ZTITBLK-LIFNR     NE P_ZTIVRQ00-LIFNR AND
       NOT ZTITBLK-LIFNR IS INITIAL.
      MESSAGE ID 'ZMTI00' TYPE P_MSGTY NUMBER 205
                        WITH P_ZTIVRQ00-LIFNR ZTITBLK-LIFNR.
      P_MODIFY = C_TRUE.
      EXIT.
    ENDIF.
*통화키 체크.
    IF ZTITBLK-WAERS    NE  P_ZTIVRQ00-WAERS AND
       P_COUNT           GT  C_ZERO.
      MESSAGE ID 'ZMTI00' TYPE P_MSGTY NUMBER 206
                        WITH P_ZTIVRQ00-WAERS ZTITBLK-WAERS.
      P_MODIFY = C_TRUE.
    ENDIF.
**회사코드
*    IF ZTITBLK-bukrs NE p_ZTIvrq00-bukrs AND
*       p_count        GT  c_zero.
*      MESSAGE ID 'ZMTI00' TYPE p_msgty NUMBER 226
*           WITH '회사코드' p_ZTIvrq00-bukrs ZTITBLK-bukrs.
*      p_modify = c_true.
*    ENDIF.

**구매조직
*    IF ZTITBLK-ekorg NE p_ZTIvrq00-ekorg AND
*       p_count        GT  c_zero.
*      MESSAGE ID 'ZMTI00' TYPE p_msgty NUMBER 206
*         WITH '구매조직' p_ZTIvrq00-ekorg ZTITBLK-ekorg.
*      p_modify = c_true.
*    ENDIF.
**구매그룹
*    IF ZTITBLK-ekgrp NE p_ZTIvrq00-ekgrp AND
*       p_count        GT  c_zero.
*      MESSAGE ID 'ZMTI00' TYPE p_msgty NUMBER 206
*         WITH '구매그룹' p_ZTIvrq00-ekgrp ZTITBLK-ekgrp.
*      p_modify = c_true.
*    ENDIF.
**project정의.
*    IF ZTITBLK-pspnr NE p_ZTIvrq00-pspnr AND
*       p_count        GT  c_zero.
*      MESSAGE ID 'ZMTI00' TYPE p_msgty NUMBER 226
*         WITH '프로젝트' p_ZTIvrq00-pspnr ZTITBLK-pspnr.
*      p_modify = c_true.
*    ENDIF.

    IF SY-UCOMM NE 'BL_UP'.

*운송방법
      IF ZTITBLK-FWDTY NE P_ZTIVRQ00-FWDTY AND
         P_COUNT        GT  C_ZERO.
        MESSAGE ID 'ZMTI00' TYPE P_MSGTY NUMBER 226
           WITH '운송방법' P_ZTIVRQ00-FWDTY ZTITBLK-FWDTY.
        P_MODIFY = C_TRUE.
      ENDIF.
*인도조건
      IF ZTITBLK-INCO1 NE  P_ZTIVRQ00-INCO1 AND
         P_COUNT        GT  C_ZERO.
        MESSAGE ID 'ZMTI00' TYPE P_MSGTY NUMBER 226
                         WITH '인도조건' P_ZTIVRQ00-INCO1 ZTITBLK-INCO1.
        P_MODIFY = C_TRUE.
        EXIT.
      ENDIF.
*선적항.
      IF ( ZTITBLK-FLAND NE P_ZTIVRQ00-FLAND OR
           ZTITBLK-FPORT NE P_ZTIVRQ00-FPORT ) AND
         P_COUNT        GT  C_ZERO.
        MESSAGE ID 'ZMTI00' TYPE P_MSGTY NUMBER 009
                          WITH '선적항'.
        P_MODIFY = C_TRUE.
      ENDIF.
*도착항.
      IF ( ZTITBLK-TLAND NE P_ZTIVRQ00-TLAND OR
           ZTITBLK-TPORT NE P_ZTIVRQ00-TPORT ) AND
         P_COUNT        GT  C_ZERO.
        MESSAGE ID 'ZMTI00' TYPE P_MSGTY NUMBER 009
                          WITH '도착항'.
        P_MODIFY = C_TRUE.
      ENDIF.
    ENDIF.
*>기타 체크 로직.

*> Lock Object
    PERFORM  SET_LC_LOCK_OBJECT  USING P_REQNO
                                       P_AMDSQ
                                       P_REQIT
                                       C_LOCK
                                       P_MSGTY
                                       P_MODIFY.
  ELSE.
    MESSAGE ID '06' TYPE P_MSGTY NUMBER 019
                    WITH P_REQNO.
    P_MODIFY = C_TRUE.
    EXIT.
  ENDIF.

ENDFORM.                    " get_and_check_lc_data

*&---------------------------------------------------------------------*
*&      Form  get_and_check_resb_data
*&---------------------------------------------------------------------*
*       Get 예약정보 데이타.
*----------------------------------------------------------------------*
FORM GET_AND_CHECK_RESB_DATA  USING  P_RSNUM
                                     P_RSPOS
                                     P_RSART
                                     P_MODIFY
                                     P_ZTIVRS00 STRUCTURE ZTIVRS00
                                     P_COUNT.

  CLEAR: P_ZTIVRS00.

  SELECT SINGLE * INTO P_ZTIVRS00
    FROM ZTIVRS00
   WHERE RSNUM EQ P_RSNUM
     AND RSPOS EQ P_RSPOS
     AND RSART EQ P_RSART.

  IF SY-SUBRC EQ 0.
*>Vendor 체크.
    IF ZTITBLK-LIFNR     NE P_ZTIVRS00-LIFNR AND
       NOT ZTITBLK-LIFNR IS INITIAL.
      MESSAGE S209 WITH P_ZTIVRS00-LIFNR ZTITBLK-LIFNR.
      P_MODIFY = C_TRUE.
      EXIT.
    ENDIF.
*통화키 체크.
    IF ZTITBLK-WAERS    NE  P_ZTIVRS00-WAERS AND
       P_COUNT           GT  C_ZERO.
      MESSAGE S210 WITH P_ZTIVRS00-WAERS ZTITBLK-WAERS.
      P_MODIFY = C_TRUE.
    ENDIF.
*>기타 체크 로직.

**> Lock Object
*    PERFORM  set_lc_lock_object  USING p_reqno
*                                       p_amdsq
*                                       p_reqit
*                                       c_lock
*                                       c_success
*                                       p_modify.
  ELSE.
    MESSAGE S019(06) WITH P_RSNUM.
    P_MODIFY = C_TRUE.
    EXIT.
  ENDIF.

ENDFORM.                    " get_and_check_resb_data

*&---------------------------------------------------------------------*
*&      Form  p3000_set_data_of_screen
*&---------------------------------------------------------------------*
FORM P3000_SET_DATA_OF_SCREEN .

  CHECK : SY-TCODE EQ C_CREATE OR
          SY-TCODE EQ C_CREATE_D.

  REFRESH: IT_TAB, IT_REQNO.

  CLEAR: ZTITBLK,
         ZTITBLP,
         ZTISBLIT,
         ZTITBLC,
         IT_TAB,
         IT_REQNO,
         LFA1,
        *LFA1,
         W_LFA1,
         W_LFA1_BANK,
         T001,
         T024,
         T024E.

  CLEAR:  GT_CONTROL-TEXTLINES[], GT_CONTROL-TEXTTYPES[].

  GET PARAMETER ID 'BUK' FIELD ZTITBLK-BUKRS.
  GET PARAMETER ID 'EKO' FIELD ZTITBLK-EKORG.
  GET PARAMETER ID 'EKG' FIELD ZTITBLK-EKGRP.

  MOVE:  SPACE        TO    ZTITBLK-BLDTY,  ">문서종류.
         'KG'         TO    ZTITBLK-GEWEI,  ">중량단위.
*         ZTITBLK-CRLSE
*         'CBM'        TO    ZTITBLK-voleh,  ">부피단위.
         'Y'          TO    ZTITBLK-APPCT,  ">수입자.
         'USD'        TO    ZTITBLK-CFRATC, ">운임통화.
         'M3'         TO    ZTITBLK-VOLEH,  ">부피단위.
         'GT'         TO    ZTITBLK-BPKTY,  ">포장단위.
         'KR'         TO    ZTITBLK-TLAND.  ">도착국가.
*         'PUS'        TO    ztitblk-tport.  ">도착항.
* 20070510 simcho by 박혁세K
  IF ZTITBLK-TPORT IS INITIAL.
    MOVE   'PUS'        TO    ZTITBLK-TPORT.  ">도착항.
  ENDIF.
* end


* Message preparations
  PERFORM  SET_MESSAGE_PREPARATIONS.

ENDFORM.                    " p3000_set_data_of_screen
*&---------------------------------------------------------------------*
*&      Form  check_for_sub_document_exist
*&---------------------------------------------------------------------*
*  삭제시 후속 문서의 존재여부를 확인함..
*----------------------------------------------------------------------*
FORM CHECK_FOR_SUB_DOCUMENT_EXIST.

  DATA: L_COUNT  TYPE  I.

  LOOP AT IT_TAB INTO G_TC_2130_WA.
    PERFORM CHECK_BL_SUB_DOCUMENT_EXIST
                             USING   G_TC_2130_WA-IBLNO
                                     G_TC_2130_WA-IBLIT
                                     C_ERROR
                                     G_SUBRC.
  ENDLOOP.

*> 비용문서 체크.
  SELECT COUNT( * )
    INTO L_COUNT
    FROM ZTITCSP
   WHERE EXPGR  EQ  C_CHARB
     AND REFNO  EQ  ZTITBLK-IBLNO.

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

  DATA:
  L_IF_NULL         TYPE REF TO IF_MESSAGE_OBJ_MM.

  DATA: L_BLMNGM      TYPE ZTIBLMNGM.
  DATA: LV_ZCOTY      LIKE ZTITBLP-ZCOTY.

*  REFRESH : it_msg.
*  CLEAR: it_msg.
*
* preparations
  CALL METHOD CL_MESSAGE_HANDLER_MM=>GET_HANDLER
    IMPORTING
      EX_HANDLER = G_MESSAGE_HANDLER.

  CALL METHOD G_MESSAGE_HANDLER->SET_CONFIG_FOR_MEPO( ).
  CALL METHOD G_MESSAGE_HANDLER->REMOVE_ALL( ).
  CALL METHOD G_MESSAGE_HANDLER->CLEANUP( ).


  DESCRIBE TABLE IT_PSPNR LINES G_LINE.
  CASE G_LINE.
    WHEN C_ZERO.

    WHEN C_ONE.
      READ TABLE IT_PSPNR INDEX 1.
      IF SY-SUBRC EQ 0.
        IF IT_PSPNR-PSPNR NE ZTITBLK-PSPNR.
          IF ZTITBLK-PSPNR IS INITIAL.
            ZTITBLK-PSPNR = IT_PSPNR-PSPNR.
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

*> Currency
  IF ZTITBLK-WAERS IS INITIAL.
    PERFORM SET_RETURN_MESSAGE USING 'ZTITBLK' 'WAERS' C_ERROR.
  ENDIF.
*> 회사코드
  IF ZTITBLK-BUKRS IS INITIAL.
    PERFORM SET_RETURN_MESSAGE USING 'ZTITBLK' 'BUKRS' C_ERROR.
  ENDIF.
  IF ZTITBLK-BLDTY EQ C_CHARH.
*> 영업문서.
    IF ZTITBLK-VBELN IS INITIAL.
      PERFORM SET_RETURN_MESSAGE USING 'ZTITBLK' 'VBELN' C_ERROR.
    ENDIF.
*> 영업조직.
    IF ZTITBLK-VKORG IS INITIAL.
      PERFORM SET_RETURN_MESSAGE USING 'ZTITBLK' 'VKORG' C_ERROR.
    ENDIF.
*> 유통경로.
    IF ZTITBLK-VTWEG IS INITIAL.
      PERFORM SET_RETURN_MESSAGE USING 'ZTITBLK' 'VTWEG' C_ERROR.
    ENDIF.
*> 제품군.
    IF ZTITBLK-SPART IS INITIAL.
      PERFORM SET_RETURN_MESSAGE USING 'ZTITBLK' 'SPART' C_ERROR.
    ENDIF.
*> 판매처.
    IF ZTITBLK-KUNNR IS INITIAL.
      PERFORM SET_RETURN_MESSAGE USING 'ZTITBLK' 'KUNNR' C_ERROR.
    ENDIF.
  ELSE.
*> Vendor Code
    IF ZTITBLK-LIFNR IS INITIAL.
      PERFORM SET_RETURN_MESSAGE USING 'ZTITBLK' 'LIFNR' C_ERROR.
    ENDIF.
*> 구매조직
    IF ZTITBLK-EKORG IS INITIAL.
      PERFORM SET_RETURN_MESSAGE USING 'ZTITBLK' 'EKORG' C_ERROR.
    ENDIF.
*> 구매그룹
    IF ZTITBLK-EKGRP IS INITIAL.
      PERFORM SET_RETURN_MESSAGE USING 'ZTITBLK' 'EKGRP' C_ERROR.
    ENDIF.
  ENDIF.
*> 수입의뢰종류.
*> ASP Interface가 아닐경우. 신고구분 Setting.
  IF P_MODE EQ C_CHAR3.
    ZTITBLK-CRLSE = C_CHARC.
    ZTITBLK-RNAM  = SY-UNAME.
    ZTITBLK-RDAT  = SY-DATLO.
    ZTITBLK-RTME  = SY-TIMLO.
  ELSEIF P_MODE EQ C_CHAR4.
    ZTITBLK-CRLSE = C_CHARB.
    CLEAR: ZTITBLK-RNAM,
           ZTITBLK-RDAT,
           ZTITBLK-RTME.
  ENDIF.


*> B/L 관련 Process.
  CASE ZTITIG00-BLPCS.
    WHEN C_CHARA OR C_CHARB.  ">
      CASE G_MODE.
        WHEN C_CHARC OR C_CHARM.
        WHEN C_CHARA.
        WHEN C_CHARY.
*          IF ztitblk-crlse NE c_charb.
          IF ZTITBLK-RPTTY IS INITIAL.
            PERFORM SET_RETURN_MESSAGE
                                     USING 'ZTITBLK' 'RPTTY' C_ERROR.
          ENDIF.
          IF ZTITBLK-INBDT IS INITIAL.
            PERFORM SET_RETURN_MESSAGE
                                     USING 'ZTITBLK' 'INBDT' C_ERROR.
          ENDIF.
          IF ZTITBLK-CSATY IS INITIAL.
            PERFORM SET_RETURN_MESSAGE
                                     USING 'ZTITBLK' 'CSATY' C_ERROR.
          ENDIF.
          IF ZTITBLK-FWDCD IS INITIAL.
            PERFORM SET_RETURN_MESSAGE
                                     USING 'ZTITBLK' 'FWDCD' C_ERROR.
          ENDIF.
*          ENDIF.
      ENDCASE.
    WHEN C_CHARZ.
      IF ZTITBLK-RPTTY IS INITIAL.
        PERFORM SET_RETURN_MESSAGE
                                 USING 'ZTITBLK' 'RPTTY' C_ERROR.
      ENDIF.
**> 실입항일.
*      IF ztitblk-inbdt IS INITIAL.
*        PERFORM set_return_message
*                                 USING 'ZTITBLK' 'INBDT' c_error.
*      ENDIF.
      IF ZTITBLK-CSATY IS INITIAL.
        PERFORM SET_RETURN_MESSAGE
                                 USING 'ZTITBLK' 'CSATY' C_ERROR.
      ENDIF.
*      IF ztitblk-fwdcd IS INITIAL.
*        PERFORM set_return_message
*                                 USING 'ZTITBLK' 'FWDCD' c_error.
*      ENDIF.
*          ENDIF.
  ENDCASE.
*> 송장금액.
  IF NOT ( ZTITBLK-BLDTY EQ C_CHARS OR
           ZTITBLK-BLDTY EQ C_CHARO ).
    IF ZTITBLK-SMAMT IS INITIAL.
      PERFORM SET_RETURN_MESSAGE USING 'ZTITBLK' 'SMAMT' C_ERROR.
    ENDIF.
  ENDIF.
*> 선기명.
  IF ZTITBLK-IVSLN IS INITIAL.
    PERFORM SET_RETURN_MESSAGE USING 'ZTITBLK' 'IVSLN' C_ERROR.
  ENDIF.
*> ETD.
  IF ZTITBLK-BLETD IS INITIAL.
    PERFORM SET_RETURN_MESSAGE USING 'ZTITBLK' 'BLETD' C_ERROR.
  ENDIF.
*> ETA.
  IF ZTITBLK-BLETA IS INITIAL.
    PERFORM SET_RETURN_MESSAGE USING 'ZTITBLK' 'BLETA' C_ERROR.
  ENDIF.
*> B/L 발행일.
  IF ZTITBLK-BLDAT IS INITIAL.
    PERFORM SET_RETURN_MESSAGE USING 'ZTITBLK' 'BLDAT' C_ERROR.
  ENDIF.
*--> LG전선에서 추가. by MSH
*> 원본입수여부.
  IF ZTITBLK-BLAYN IS INITIAL.
    PERFORM SET_RETURN_MESSAGE USING 'ZTITBLK' 'BLAYN' C_ERROR.
  ENDIF.

*> 품목 확인.
  IF G_MODE EQ C_CHARC OR
     G_MODE EQ C_CHARM.
    LOOP AT IT_TAB INTO G_TC_2130_WA.
      IF G_TC_2130_WA-STAWN IS INITIAL.
        MESSAGE S133 WITH G_TC_2130_WA-IBLIT 'H/S code'.
        PERFORM SET_RETURN_MESSAGE_FILL USING C_ERROR.
      ENDIF.
      IF G_TC_2130_WA-BLMNG IS INITIAL.
        MESSAGE S133 WITH G_TC_2130_WA-IBLIT '수량'.
        PERFORM SET_RETURN_MESSAGE_FILL USING C_ERROR.
      ENDIF.
      IF G_TC_2130_WA-REFWR IS INITIAL.
        MESSAGE S133 WITH G_TC_2130_WA-IBLIT '금액'.
        PERFORM SET_RETURN_MESSAGE_FILL USING C_ERROR.
      ENDIF.
      IF NOT G_TC_2130_WA-LOEKZ IS INITIAL.
        MESSAGE S170 WITH G_TC_2130_WA-IBLIT G_TC_2130_WA-EBELN
                                             G_TC_2130_WA-EBELP.
        PERFORM SET_RETURN_MESSAGE_FILL USING C_ERROR.
      ENDIF.

      IF G_TC_2130_WA-NDFTY EQ SPACE   OR
         G_TC_2130_WA-NDFTY EQ C_CHARA OR
         G_TC_2130_WA-NDFTY EQ C_CHARN OR
         G_TC_2130_WA-NDFTY EQ C_CHARO.
        L_BLMNGM = G_TC_2130_WA-BLMNGL + G_TC_2130_WA-BLMNGM.
        IF G_TC_2130_WA-BLMNG GT L_BLMNGM.
          MESSAGE S134 WITH G_TC_2130_WA-IBLIT 'B/L'.
          PERFORM SET_RETURN_MESSAGE_FILL USING C_ERROR.
        ENDIF.
      ENDIF.
*1109
      IF ZTITBLK-BUKRS EQ '1000' AND G_TC_2130_WA-ZCOTY IS INITIAL.
        IF ZTITBLK-RPTTY NE 'Z'. "미통관
*START CHM2111-00790 왕욱진D 특정자재 원산지증명서 미발행
          IF G_TC_2130_WA-MATNR NE '000000000007100001'.
*END CHM2111-00790
            MESSAGE S133 WITH G_TC_2130_WA-IBLIT '원산지 증명서 제출여부'.
            PERFORM SET_RETURN_MESSAGE_FILL USING C_ERROR.
          ENDIF.
        ENDIF.
      ENDIF.

    ENDLOOP.

    IF SY-SUBRC NE 0.
      MESSAGE S135.
      PERFORM SET_RETURN_MESSAGE_FILL USING C_ERROR.
    ENDIF.
  ENDIF.

*> 오류정보가 존재시 메시지 상자 POPUP.
  G_LINE = G_MESSAGE_HANDLER->GET_SEVERITY_BO(
                          IM_BUSINESS_OBJ          = L_IF_NULL
                          IM_INCLUDE_CHILD_OBJECTS = C_TRUE ).

  IF G_LINE GT 0.
    CALL METHOD G_MESSAGE_HANDLER->SHOW( IM_POPUP = C_TRUE
      IM_AMODAL = C_FALSE ).
  ELSE.
    LOOP AT IT_TAB INTO G_TC_2130_WA.
*-<< CHM2007-00376 - 원산지 증명서 추가
      IF OK_CODE = 'ZTISAVE'. "프린트 시 발송X
        IF ZTITBLK-BUKRS EQ '1000' AND G_TC_2130_WA-ZCOTY IS NOT INITIAL.
          IF G_TC_2130_WA-ZCOTY EQ 'A' OR
             G_TC_2130_WA-ZCOTY EQ 'L'.
*<<CHM2009-00411 원산지증명서 제출상태 변경만 메일발송
            CLEAR LV_ZCOTY.
            SELECT SINGLE ZCOTY
              FROM ZTITBLP
              INTO LV_ZCOTY
             WHERE IBLNO = ZTITBLK-IBLNO
               AND IBLIT = G_TC_2130_WA-IBLIT.
            IF G_TC_2130_WA-ZCOTY = LV_ZCOTY.
            ELSE.
*>>CHM2009-00411
*START CHM2111-00790 왕욱진D 특정자재 원산지증명서 미발행
              IF G_TC_2130_WA-MATNR NE '000000000007100001'.
*END CHM2111-00790
                PERFORM SEND_MAIL.
              ENDIF.
            ENDIF.
          ENDIF.
        ENDIF.
      ENDIF.
*->> CHM2007-00376
    ENDLOOP.
    MESSAGE S911.
  ENDIF.

*> Message Popop
*  DESCRIBE TABLE it_msg LINES g_line.
*  IF g_line GT 0.
*    CALL FUNCTION 'Z_TI_POPUP_TO_ERROR_MESSAGE'
*      TABLES
*        xmsg = it_msg.
*  ENDIF.
*
ENDFORM.                    " check_for_document_field
*&---------------------------------------------------------------------*
*&      Form  p8000_save_master_data
*&---------------------------------------------------------------------*
FORM P8000_SAVE_MASTER_DATA USING P_MODE.

  DATA: L_MODIFY.

*>Switches on the local update task.
  SET UPDATE TASK LOCAL.

*> 공통테이블 적용.
  IF G_MODE      EQ C_CHARY AND
     OK_CODE_OLD EQ 'ZTISAVE'.
    P_MODE = 'Y'.
  ENDIF.

  PERFORM P8100_SAVE_COMMON_DATA  TABLES IT_TAB
                                         XZTITBLC
                                  USING  ZTITBLK
                                         G_SUBRC
                                         P_MODE.
  IF NOT G_SUBRC IS INITIAL.
    MESSAGE A912.   EXIT.
  ENDIF.

*> Long Text 저장 루틴.
  PERFORM SAVE_LONG_TEXT USING ZTITBLK+3(10)
                               C_TEXTOBJECT_HEADER
                               G_SUBRC.

  IF SY-SUBRC NE 0.
    ROLLBACK WORK.
    MESSAGE A912.   EXIT.
  ELSE.
*> Change document setting.
    PERFORM P8120_CHANGE_DOCUMENT.
*> Commit work.
    COMMIT WORK.
*> Set parameter ID
    IF OK_CODE_OLD EQ 'ZTIDELETE'.
      MESSAGE S201 WITH ZTITBLK-IBLNO.
    ELSE.
*-----------------------------------------------------------------------
*> 물대처리시점 정의에 따라 인보이스 처리화면으로 이동.
*-----------------------------------------------------------------------
      IF NOT ZTITIG00-IVPBL IS INITIAL.
*> Lock Object
        IF G_MODE EQ C_CHARC.
          CLEAR: G_COUNT.
          LOOP AT IT_TAB INTO G_TC_2130_WA WHERE NDFTY = C_CHARA.
            PERFORM  SET_PO_LOCK_OBJECT  USING G_TC_2130_WA-EBELN
                                               G_TC_2130_WA-EBELP
                                               C_UNLOCK
                                               C_ERROR
                                               L_MODIFY.
            ADD 1 TO G_COUNT.
          ENDLOOP.
        ELSE.
          CLEAR: G_COUNT.
          LOOP AT IT_TAB INTO G_TC_2130_WA WHERE NDFTY = C_CHARA.
            ADD 1 TO G_COUNT.
          ENDLOOP.
          PERFORM  SET_BL_LOCK_OBJECT  USING ZTITBLK-IBLNO
                                             '00000'
                                             C_UNLOCK
                                             C_ERROR
                                             L_MODIFY.
        ENDIF.
*> Invoice 문서 생성 BDC
        IF G_COUNT EQ 0.
          IF ZTITBLK-SMAMT NE ZTITBLK-PPAMT.
*> ASP Interface일 경우만 해당됨.
            IF ZTITBLK-CRLSE NE C_CHARB.
              PERFORM  CREATE_INVOICE_DOCUMENT.
            ENDIF.
          ENDIF.
        ENDIF.
*{ 기능개선 283274 - 추가_S
      ELSE.
*___회사코드 '1000'인 경우 B/L 생성 후 적하보험 생성으로 이동
        IF ( G_TCODE EQ C_CREATE OR G_TCODE EQ C_CREATE_D ) AND
            ZTITBLK-BUKRS = '1000'.
          PERFORM CALL_INSURANCE_TCODE.
        ENDIF.
*} 기능개선 283274 - 추가_E
      ENDIF.

      SET PARAMETER ID 'ZTIIBLNO' FIELD ZTITBLK-IBLNO.
      SET PARAMETER ID 'ZTIBLNUM' FIELD ZTITBLK-BLNUM.
      MESSAGE S202 WITH ZTITBLK-IBLNO.
    ENDIF.
  ENDIF.

ENDFORM.                    " p8000_save_master_data
*&---------------------------------------------------------------------*
*&      Form  p8100_save_common_data
*&---------------------------------------------------------------------*
FORM P8100_SAVE_COMMON_DATA  TABLES  PT_TAB     STRUCTURE G_TC_2130_WA
                                     PT_BLCT    STRUCTURE XZTITBLC
                             USING   P_ZTITBLK STRUCTURE ZTITBLK
                                     P_SUBRC    LIKE      SY-SUBRC
                                     P_MODE.

  DATA: L_IBLNO TYPE ZTIREQNO,
        L_REQTY TYPE ZTIREQTY.

  CLEAR: P_SUBRC, L_IBLNO.
  L_REQTY = G_DOCUMENT.

  IF ( G_TCODE EQ C_CREATE OR  G_TCODE EQ C_CREATE_D ) AND
     P_ZTITBLK-IBLNO IS INITIAL.

    CALL FUNCTION 'Z_TI_GET_NUMBER_NEXT'
      EXPORTING
        ZMPTY          = L_REQTY
*   BUKRS          =
     IMPORTING
        LCONO          = L_IBLNO
     EXCEPTIONS
       NOT_TYPE       = 1
       OTHERS         = 2.

    IF SY-SUBRC <> 0.
      MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
              WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    ENDIF.
  ELSE.
    L_IBLNO = P_ZTITBLK-IBLNO.
  ENDIF.

  IF  P_ZTITBLK-CNAM IS INITIAL.
    MOVE: SY-UNAME   TO   P_ZTITBLK-CNAM,
          SY-DATLO   TO   P_ZTITBLK-CDAT,
          SY-TIMLO   TO   P_ZTITBLK-CTME.
  ENDIF.

  MOVE: SY-MANDT   TO   P_ZTITBLK-MANDT,
        L_IBLNO    TO   P_ZTITBLK-IBLNO,
        SY-UNAME   TO   P_ZTITBLK-UNAM,
        SY-DATLO   TO   P_ZTITBLK-UDAT,
        SY-TIMLO   TO   P_ZTITBLK-UTME.

*> 회사별 선적서류 상태변경.
  IF G_MODE EQ C_CHARC.
    CASE ZTITIG00-BLPCS.
      WHEN C_CHARA.  ZTITBLK-BLDST = C_CHARA.
      WHEN C_CHARB.  ZTITBLK-BLDST = C_CHARA.
      WHEN C_CHARZ.  ZTITBLK-BLDST = C_CHARZ.
    ENDCASE.
  ENDIF.

  CASE OK_CODE_OLD.
    WHEN 'ZTIACCEPT'.
      MOVE: C_CHARB  TO   P_ZTITBLK-BLDST,
            SY-UNAME TO   P_ZTITBLK-SDRNM,
            SY-DATLO TO   P_ZTITBLK-SDRDT,
            SY-TIMLO TO   P_ZTITBLK-SDRTM.

    WHEN 'ZTIRETURN'.
      MOVE: C_CHARA  TO   P_ZTITBLK-BLDST,
            SY-UNAME TO   P_ZTITBLK-SDRNM,
            SY-DATLO TO   P_ZTITBLK-SDRDT,
            SY-TIMLO TO   P_ZTITBLK-SDRTM.
    WHEN 'ZTIAPPLY'.
      MOVE: C_CHARD  TO   P_ZTITBLK-BLDST,
            SY-UNAME TO   P_ZTITBLK-INBNM,
            SY-DATLO TO   P_ZTITBLK-INBDA,
            SY-TIMLO TO   P_ZTITBLK-INBTM.

    WHEN 'ZTIAPPLYC'.
      IF ZTITIG00-BLPCS EQ C_CHARA.
        MOVE: C_CHARB  TO  P_ZTITBLK-BLDST.
      ELSE.
        MOVE: C_CHARA  TO  P_ZTITBLK-BLDST.
      ENDIF.
      MOVE: SY-UNAME TO   P_ZTITBLK-INBNM,
            SY-DATLO TO   P_ZTITBLK-INBDA,
            SY-TIMLO TO   P_ZTITBLK-INBTM.
    WHEN 'ZTIRECV'.
      MOVE: C_CHARE  TO   P_ZTITBLK-BLDST,
            SY-UNAME TO   P_ZTITBLK-CCRNM,
            SY-DATLO TO   P_ZTITBLK-CCRDT,
            SY-TIMLO TO   P_ZTITBLK-CCRTM.

    WHEN 'ZTIRECVC'.
      CASE ZTITIG00-BLPCS.
        WHEN C_CHARA OR C_CHARB.
          MOVE: C_CHARD  TO  P_ZTITBLK-BLDST.
        WHEN OTHERS.
          MOVE: C_CHARN  TO  P_ZTITBLK-BLDST.
      ENDCASE.
      MOVE: SY-UNAME TO   P_ZTITBLK-CCRNM,
            SY-DATLO TO   P_ZTITBLK-CCRDT,
            SY-TIMLO TO   P_ZTITBLK-CCRTM.

  ENDCASE.


*> 관련 Invoice 번호 Get.
  IF P_ZTITBLK-IVONO IS INITIAL.
    SELECT IVONO
      INTO P_ZTITBLK-IVONO
      FROM ZTITIVP UP TO 1 ROWS
     WHERE IBLNO  EQ  P_ZTITBLK-IBLNO.
    ENDSELECT.
  ENDIF.

  IF OK_CODE_OLD EQ 'ZTIDELETE'.
*> Header table delete.
    DELETE FROM ZTITBLK WHERE IBLNO EQ P_ZTITBLK-IBLNO.
    IF SY-SUBRC NE 0.
      ROLLBACK WORK.   MOVE 4  TO P_SUBRC.     EXIT.
    ENDIF.
*> Item table delete
    DELETE FROM ZTITBLP WHERE IBLNO EQ P_ZTITBLK-IBLNO.
    IF SY-SUBRC NE 0.
      ROLLBACK WORK.   MOVE 4  TO P_SUBRC.     EXIT.
    ENDIF.
*> Container table delete
    DELETE FROM ZTITBLC WHERE IBLNO EQ P_ZTITBLK-IBLNO.

    IF P_ZTITBLK-BUKRS EQ '3000'. "[엠트론] BL등록매핑취소
      UPDATE ZTITBLH SET IBLNO = SPACE
      WHERE IBLNO EQ P_ZTITBLK-IBLNO.
      "엠로에 매핑전송
      PERFORM SEND_RFC_EMRO_BL_MAPPING USING 'D'.
    ENDIF.

    EXIT.
  ELSE.
*> Header table modify.
    MODIFY ZTITBLK FROM P_ZTITBLK.
    IF SY-SUBRC NE 0.
      ROLLBACK WORK.   MOVE 4  TO P_SUBRC.     EXIT.
    ENDIF.
*> Items table modify.
    DELETE FROM ZTITBLP WHERE IBLNO EQ P_ZTITBLK-IBLNO.
    REFRESH : XZTITBLP.
    LOOP AT IT_TAB INTO G_TC_2130_WA.
      MOVE-CORRESPONDING G_TC_2130_WA TO XZTITBLP.
      XZTITBLP-MANDT = P_ZTITBLK-MANDT.
      XZTITBLP-IBLNO = P_ZTITBLK-IBLNO.
      APPEND XZTITBLP.
    ENDLOOP.

    MODIFY ZTITBLP FROM TABLE XZTITBLP.
    IF SY-SUBRC NE 0.
      ROLLBACK WORK.   MOVE 4  TO P_SUBRC.     EXIT.
    ENDIF.
*> Container table modify.
    REFRESH: XZTITBLC.
    LOOP AT G_TC_2122_ITAB INTO G_TC_2122_WA.
      MOVE-CORRESPONDING G_TC_2122_WA TO XZTITBLC.
      XZTITBLC-MANDT = P_ZTITBLK-MANDT.
      XZTITBLC-IBLNO = P_ZTITBLK-IBLNO.
      APPEND XZTITBLC.
    ENDLOOP.

    DELETE FROM ZTITBLC WHERE IBLNO EQ P_ZTITBLK-IBLNO.
    MODIFY ZTITBLC FROM TABLE XZTITBLC.
    IF SY-SUBRC NE 0.
      ROLLBACK WORK.   MOVE 4  TO P_SUBRC.     EXIT.
    ENDIF.
  ENDIF.

ENDFORM.                    " p8100_save_common_data
*&---------------------------------------------------------------------*
*&      Form  GET_OTHERS_TEXT_BY_MASTER_DATA
*&---------------------------------------------------------------------*
*       화면상의 Text를 Master Data 등에서 Read.
*----------------------------------------------------------------------*
FORM GET_OTHERS_TEXT_BY_MASTER_DATA .

  IF ZTITBLK-BUKRS IS INITIAL.
    CLEAR: T001.
  ELSE.
    SELECT SINGLE * FROM T001
     WHERE BUKRS EQ ZTITBLK-BUKRS.
    IF SY-SUBRC EQ 0.
      SELECT SINGLE *
        FROM T005
       WHERE LAND1 EQ T001-LAND1.

*> 수입 IMG Setting
      SELECT SINGLE *
        FROM ZTITIG00
       WHERE BUKRS EQ ZTITBLK-BUKRS.
      IF SY-SUBRC NE 0.
        MESSAGE E035 WITH ZTITBLK-BUKRS.
      ENDIF.
    ENDIF.

  ENDIF.

* 구매조직 SELECT ( T024E )
  IF ZTITBLK-EKORG IS INITIAL.
    CLEAR T024E.
  ELSE.
    CALL FUNCTION 'T024E_SINGLE_READ'
      EXPORTING
        T024E_EKORG = ZTITBLK-EKORG
      IMPORTING
        WT024E      = T024E
      EXCEPTIONS
        NOT_FOUND   = 1
        OTHERS      = 2.

    IF SY-SUBRC NE 0.
      IF SY-CALLD NE C_TRUE.
        MESSAGE W001(MH) WITH ZTITBLK-EKORG.
      ENDIF.
    ENDIF.
  ENDIF.

* 구매그룹 SELECT ( T024 )
  IF ZTITBLK-EKGRP IS INITIAL.
    CLEAR T024.
  ELSE.
    CALL FUNCTION 'MM_ARRANG_PURCHASE_GRP_SELECT'
      EXPORTING
        PURCHASE_GROUP           = ZTITBLK-EKGRP
      IMPORTING
        E_T024                   = T024
      EXCEPTIONS
        PURCHASE_GROUP_NOT_FOUND = 1
        OTHERS                   = 2.

    IF SY-SUBRC NE 0.
      IF SY-CALLD NE C_TRUE.
        MESSAGE W030(MN) WITH ZTITBLK-EKGRP.
      ENDIF.
    ENDIF.
  ENDIF.
*> Vender master check
  PERFORM  GET_IMPORT_VENDORS_TEXT  USING C_SUCCESS.

ENDFORM.                    " GET_OTHERS_TEXT_BY_MASTER_DATA
*&---------------------------------------------------------------------*
*&      Form  get_used_payment_term
*&---------------------------------------------------------------------*
FORM GET_USED_PAYMENT_TERM  TABLES   P_IT_ZTITIG02 STRUCTURE ZTITIG02
                            USING    P_SUBRC  P_TYPE.

  CLEAR: P_SUBRC.

  SELECT BSTYP BSART ZTERM REQTY SETYN FROM  ZTITIG02
    INTO CORRESPONDING FIELDS OF TABLE P_IT_ZTITIG02.

  P_SUBRC = SY-SUBRC.

  IF P_SUBRC NE 0.
    MESSAGE ID 'ZMTI00' TYPE P_TYPE NUMBER 001.
    EXIT.
  ENDIF.

ENDFORM.                    " get_used_payment_term
*&---------------------------------------------------------------------*
*&      Form  GET_BL_DOCUMENT_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM GET_BL_DOCUMENT_DATA  TABLES   P_IT_ZTISRQIT  STRUCTURE IT_ZTISRQIT
                            USING   P_REQNO
                                    P_AMDSQ
                                    P_REQIT        TYPE ZTIREQIT
                                    P_MTYPE
                                    P_MSGTY.

  REFRESH IT_REQNO.  CLEAR IT_REQNO.
*  IF p_reqit IS INITIAL.
  CALL FUNCTION 'Z_TI_GET_REQUEST_OF_IMPORT'
    EXPORTING
      REQNO     = P_REQNO
      AMDSQ     = P_AMDSQ
      REQIT     = P_REQIT
    IMPORTING
      ZTITRQK   = ZTITRQK
      ZTITRQS   = ZTITRQS
    TABLES
      ZTITRQP   = P_IT_ZTISRQIT
    EXCEPTIONS
      NOT_FOUND = 1
      OTHERS    = 2.
  IF SY-SUBRC <> 0.
    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.
*  else.
*
*  ENDIF.

  IF SY-SUBRC NE 0.
    IF P_REQIT IS INITIAL.
      MESSAGE ID 'ZMTI00' TYPE P_MTYPE NUMBER 217 WITH P_REQNO P_AMDSQ.
    ELSE.
      MESSAGE ID 'ZMTI00' TYPE P_MTYPE NUMBER 217
                        WITH P_REQNO P_AMDSQ P_REQIT.
    ENDIF.
  ENDIF.

*>수입의뢰문서의 종류/상태를 검증.
  PERFORM CHECK_REQUEST_OF_IMPORT.

*>수입의뢰문서의 잔량를 검증.
  PERFORM GET_AVAILABLE_LC_ITEM TABLES P_IT_ZTISRQIT
                                       IT_REQNO
                                USING  P_MSGTY
                                       C_FALSE.

ENDFORM.                    " GET_BL_DOCUMENT_DATA

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

    SELECT  SUM( RQMNG ) INTO P_IT_PO-RQMNGS FROM ZTIVRQ00
     WHERE  EBELN  = P_IT_PO-EBELN
       AND  EBELP  = P_IT_PO-EBELP.

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

  L_OBJECTID(10) = ZTITBLK+3(10).

  L_TCODE        = SY-TCODE.
  L_UTIME        = SY-TIMLO.
  L_UDATE        = SY-DATLO.
  L_USERNAME     = SY-UNAME.

  IF G_MODE EQ C_CHARC.  ">생성모드일 경우.
    REFRESH : YZTITBLP, YZTITBLC.
  ENDIF.

  LOOP AT XZTITBLP.
    XZTITBLP-KZ = L_UPD.
    MODIFY XZTITBLP.
  ENDLOOP.

  LOOP AT XZTITBLC.
    XZTITBLC-KZ = L_UPD.
    MODIFY XZTITBLC.
  ENDLOOP.

  CALL FUNCTION 'ZTIBLCHDOC_WRITE_DOCUMENT'
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
*   UPD_ICDTXT_ZTIBLCHDOC         = ' '
      N_ZTITBLK                    = ZTITBLK
      O_ZTITBLK                    = *ZTITBLK
      UPD_ZTITBLK                  = L_UPD
      UPD_ZTITBLP                  = L_UPD
      UPD_ZTITBLC                  = L_UPD
    TABLES
      ICDTXT_ZTIBLCHDOC             = LT_CDTXT
      XZTITBLC                     = XZTITBLC
      YZTITBLC                     = YZTITBLC
      XZTITBLP                     = XZTITBLP
      YZTITBLP                     = YZTITBLP.

ENDFORM.                    " p8120_change_document
*&---------------------------------------------------------------------*
*&      Form  call_print_process
*&---------------------------------------------------------------------*
FORM CALL_PRINT_PROCESS .

*> GET OUTPUT OPTIONS
  IF IT_PRTCTL[] IS INITIAL.
    REFRESH : IT_PRTCTL.
    CLEAR: IT_PRTCTL.
    IF NOT ZTITRQK-OPNBK IS INITIAL.   ">Openning bank.
      SELECT LIFNR NAME1 LAND1 SPRAS TELFX ADRNR
      INTO CORRESPONDING FIELDS OF TABLE IT_PRTCTL
      FROM LFA1
      WHERE LIFNR IN ( SELECT LIFNR
                       FROM ZTSTIG3
                       WHERE EPART EQ ZTITRQK-OPNBK ).
    ENDIF.
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
*      PERFORM p7000_set_smart_form_name USING ztitrqk-reqty
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

  DATA: L_EINDT  LIKE EKET-EINDT,
        L_BLMNG  TYPE ZTIBLMNG,
        L_CDAT   LIKE SY-DATUM.

  LOOP AT IT_TAB INTO G_TC_2130_WA.
*> 정가 계산.
    L_BLMNG = G_TC_2130_WA-BLMNG - G_TC_2130_WA-PPMNG.
    IF NOT G_TC_2130_WA-EBELN IS INITIAL AND
         ( G_TC_2130_WA-NETWR IS INITIAL ).
*                                         OR
*           sy-dynnr  EQ  c_scr0100       OR
*           sy-dynnr  EQ  c_scr0120 ).
*      if sy-dynnr  EQ  c_scr0100.
      CALL FUNCTION 'Z_TI_CALC_ITEM_AMOUNT'
        EXPORTING
          PEINH = G_TC_2130_WA-PEINH
          BPUMZ = G_TC_2130_WA-BPUMZ
          BPUMN = G_TC_2130_WA-BPUMN
          MENGE = L_BLMNG
          NETPR = G_TC_2130_WA-NETPR
        CHANGING
          NETWR = G_TC_2130_WA-NETWR.
    ENDIF.
*    if sy-dynnr  EQ  c_scr0100.
*      CALL FUNCTION 'Z_TI_CALC_ITEM_AMOUNT'
*        EXPORTING
*          peinh = g_tc_2130_wa-peinh
*          bpumz = g_tc_2130_wa-bpumz
*          bpumn = g_tc_2130_wa-bpumn
*          menge = g_tc_2130_wa-blmng
*          netpr = g_tc_2130_wa-netpr
*        CHANGING
*          netwr = g_tc_2130_wa-netwr.
*      g_tc_2130_wa-refwr = g_tc_2130_wa-netwr.
*    endif.

    IF G_TC_2130_WA-REFWR IS INITIAL AND
       ( G_MODE           EQ C_CHARC OR
         G_MODE           EQ C_CHARM ).
      G_TC_2130_WA-REFWR = G_TC_2130_WA-NETWR.
    ENDIF.
    IF SY-DYNNR  EQ  C_SCR0100       OR
       SY-DYNNR  EQ  C_SCR0120.
      IF G_TC_2130_WA-REFWR IS INITIAL.
        G_TC_2130_WA-REFWR = G_TC_2130_WA-NETWR.
      ENDIF.
    ENDIF.

*>Get 플랜트명 및 사업장코드.
    IF NOT G_TC_2130_WA-WERKS IS INITIAL AND
           G_TC_2130_WA-NAME1 IS INITIAL.
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
    IF NOT G_TC_2130_WA-EBELN IS INITIAL AND
       G_TC_2130_WA-EEIND     IS INITIAL.
      CLEAR: L_EINDT.
      SELECT MIN( EINDT ) INTO L_EINDT
        FROM EKET
       WHERE EBELN EQ G_TC_2130_WA-EBELN
         AND EBELP EQ G_TC_2130_WA-EBELP.

      IF L_EINDT IS INITIAL.
        CLEAR :G_TC_2130_WA-EEIND,
               G_TC_2130_WA-EINDT.
      ELSE.
        WRITE L_EINDT TO G_TC_2130_WA-EEIND.
        G_TC_2130_WA-EINDT = L_EINDT.
      ENDIF.
    ENDIF.
*********************************************************
**>Get H/S code.
*********************************************************
*    IF g_mode EQ c_charc OR
*       g_mode EQ c_charm.
*      IF g_tc_2130_wa-stawn IS INITIAL.
*        SELECT SINGLE stawn
*          INTO (g_tc_2130_wa-stawn)
*          FROM marc
*         WHERE matnr  EQ  g_tc_2130_wa-matnr
*           AND werks  EQ  g_tc_2130_wa-werks.
*
*        IF g_tc_2130_wa-stawn IS INITIAL.
*          SELECT cdat stawn
*            INTO (l_cdat, g_tc_2130_wa-stawn)
*            FROM ztivpo01 UP TO 1 ROWS
*           WHERE matnr  EQ  g_tc_2130_wa-matnr
*             AND werks  EQ  g_tc_2130_wa-werks
*             AND stawn  NE  space
*           ORDER BY cdat DESCENDING.
*          ENDSELECT.
*        ENDIF.
*********************************************************
*>Get H/S code.
*********************************************************
* 속도저하 문제로 자재코드 있는것만 logic타도록 수정
* WRITTEN BY CHOI SEOK WON.
* 2006.12.26 HS CODE AND MATERIAL CODE VALIDATION
*********************************************************
    IF G_MODE EQ C_CHARC OR
       G_MODE EQ C_CHARM.
      IF G_TC_2130_WA-STAWN IS INITIAL AND
         G_TC_2130_WA-MATNR IS NOT INITIAL.
        SELECT SINGLE STAWN
          INTO (G_TC_2130_WA-STAWN)
          FROM MARC
         WHERE MATNR  EQ  G_TC_2130_WA-MATNR
           AND WERKS  EQ  G_TC_2130_WA-WERKS.

        IF G_TC_2130_WA-STAWN IS INITIAL AND
           G_TC_2130_WA-MATNR IS NOT INITIAL.
          SELECT CDAT STAWN
            INTO (L_CDAT, G_TC_2130_WA-STAWN)
            FROM ZTIVPO01 UP TO 1 ROWS
           WHERE MATNR  EQ  G_TC_2130_WA-MATNR
             AND WERKS  EQ  G_TC_2130_WA-WERKS
             AND STAWN  NE  SPACE
           ORDER BY CDAT DESCENDING.
          ENDSELECT.
        ENDIF.
*********************************************************
*    ELSE.
*      CLEAR g_tc_2130_wa-stawn.
      ENDIF.
    ENDIF.
*> 텍스트.
    IF G_TC_2130_WA-TXZ01     IS INITIAL AND
       NOT G_TC_2130_WA-MATNR IS INITIAL.
      SELECT SINGLE MAKTX
        INTO G_TC_2130_WA-TXZ01
        FROM MAKT
       WHERE MATNR  EQ  G_TC_2130_WA-MATNR
         AND SPRAS  EQ  SY-LANGU.
    ENDIF.
*>WBS 요소.
    IF G_MODE EQ C_CHARC OR
       G_MODE EQ C_CHARM.
      IF NOT G_TC_2130_WA-EBELN IS INITIAL.
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
            PERFORM GET_PARENT_WBS_ELEMENT USING G_TC_2130_WA-PS_PSP_PNR
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
*        IF g_tc_2130_wa-ps_psp_pnr IS INITIAL.
*          SELECT SINGLE ps_psp_pnr
*            INTO g_tc_2130_wa-ps_psp_pnr
*            FROM mseg
*           WHERE mblnr   = g_tc_2130_wa-mblnr
*             AND mjahr   = g_tc_2130_wa-mjahr
*             AND zeile   = g_tc_2130_wa-zeile.
*        ENDIF.
*
*        IF NOT g_tc_2130_wa-ps_psp_pnr IS INITIAL.
*          PERFORM get_parent_wbs_element USING g_tc_2130_wa-ps_psp_pnr
*                                               gs_proj.
*          g_tc_2130_wa-ps_psp_pnr = gs_proj-pspnr.
*        ENDIF.
*
*        IF g_tc_2130_wa-ps_psp_pnr IS INITIAL.
*
*        ENDIF.

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

  IF ZTITBLK-LIFNR IS INITIAL.
    CLEAR: LFA1.
  ELSE.
    SELECT SINGLE * FROM LFA1
     WHERE LIFNR EQ ZTITBLK-LIFNR.
    IF SY-SUBRC NE 0.
      PERFORM MESSAGE_NOT_FOUND_VENDOR USING 'ZTITBLK'
                                             'LIFNR'
                                             P_MSGTY.
    ENDIF.
  ENDIF.

  IF ZTITBLK-TRUCK IS INITIAL.
    CLEAR: GS_TRUCKER.
  ELSE.
    SELECT SINGLE NAME1
      INTO GS_TRUCKER-NAME1
      FROM LFA1
     WHERE LIFNR EQ ZTITBLK-TRUCK.
    IF SY-SUBRC NE 0.
      PERFORM MESSAGE_NOT_FOUND_VENDOR USING 'ZTITBLK'
                                             'TRUCK'
                                             P_MSGTY.
    ENDIF.
  ENDIF.

*> 호선.
  IF ZTITBLK-PSPNR IS INITIAL.
    CLEAR : PROJ.
  ELSE.
    SELECT SINGLE *
      FROM PROJ
     WHERE PSPNR EQ ZTITBLK-PSPNR.

    IF SY-SUBRC NE 0.
      ZTITBLK-PSPNR = SPACE.
      MESSAGE ID 'ZMTI00' TYPE P_MSGTY NUMBER 019.
    ENDIF.
  ENDIF.

*> 포더업체.
  IF NOT ZTITBLK-FWDCD IS INITIAL.
    SELECT SINGLE * INTO *LFA1
     FROM  LFA1
     WHERE LIFNR EQ ZTITBLK-FWDCD.
    IF SY-SUBRC NE 0.
*      PERFORM message_not_found_vendor USING 'ZTITBLK'
*                                             'FWDCD'
*                                             p_msgty.
    ELSE.
*********************************************************
* 20060630 simcho by C2006062701000000242
*********************************************************
*      IF ztitblk-fwdtx IS INITIAL.
*        MOVE: *lfa1-name1 TO ztitblk-fwdtx.
*      ENDIF.
      MOVE: *LFA1-NAME1 TO ZTITBLK-FWDTX.
*********************************************************
* end simcho by C2006062701000000242
*********************************************************


    ENDIF.
  ENDIF.
*> 보세구역.
  IF NOT ZTITBLK-BAVAR IS INITIAL.
    SELECT SINGLE BDANM
      INTO ZTSTIG7-BDANM
      FROM ZTSTIG7
     WHERE BDACD  EQ  ZTITBLK-BAVAR.
  ELSE.
    CLEAR: ZTSTIG7.
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

ENDFORM.                    " check_lc_sub_document_exist
*&---------------------------------------------------------------------*
*&      Form  check_bl_sub_document_exist
*&---------------------------------------------------------------------*
*       하위문서 존재여부 체크.
*----------------------------------------------------------------------*
FORM CHECK_BL_SUB_DOCUMENT_EXIST  USING    P_IBLNO
                                           P_IBLIT
                                           P_MSGTY
                                           P_SUBRC.
  DATA: L_COUNT TYPE I.

  CLEAR: P_SUBRC.

  CHECK NOT P_IBLNO IS INITIAL.

*> 통관 문서 체크.
  SELECT COUNT( * ) INTO L_COUNT
    FROM ZTITCCP
   WHERE IBLNO   EQ  P_IBLNO
     AND IBLIT   EQ  P_IBLIT.
  IF L_COUNT GT C_ZERO.
    IF P_MSGTY NE C_NONE.
      MESSAGE ID 'ZMTI00' TYPE P_MSGTY NUMBER '109' WITH 'B/L'.
    ENDIF.
    P_SUBRC = 4.
    EXIT.
  ENDIF.

*> L/G 문서 체크.
  SELECT COUNT( * ) INTO L_COUNT
    FROM ZTITLG1
   WHERE IBLNO   EQ  P_IBLNO.
  IF L_COUNT GT C_ZERO.
    IF P_MSGTY NE C_NONE.
      MESSAGE ID 'ZMTI00' TYPE P_MSGTY NUMBER '109' WITH 'L/G'.
    ENDIF.
    P_SUBRC = 4.
    EXIT.
  ENDIF.

*> 반입예정정보 문서 체크.
  SELECT COUNT( * ) INTO L_COUNT
    FROM ZTITBSK
   WHERE IBLNO   EQ  P_IBLNO.
  IF L_COUNT GT C_ZERO.
    IF P_MSGTY NE C_NONE.
      MESSAGE ID 'ZMTI00' TYPE P_MSGTY NUMBER '109' WITH '반입예정정보'.
    ENDIF.
    P_SUBRC = 4.
    EXIT.
  ENDIF.

*> 반입정보 문서 체크.
  SELECT COUNT( * ) INTO L_COUNT
    FROM ZTITBIK
   WHERE IBLNO   EQ  P_IBLNO.
  IF L_COUNT GT C_ZERO.
    IF P_MSGTY NE C_NONE.
      MESSAGE ID 'ZMTI00' TYPE P_MSGTY NUMBER '109' WITH '반입정보'.
    ENDIF.
    P_SUBRC = 4.
    EXIT.
  ENDIF.

*> 반출정보 문서 체크.
  SELECT COUNT( * ) INTO L_COUNT
    FROM ZTITBOK
   WHERE IBLNO   EQ  P_IBLNO.
  IF L_COUNT GT C_ZERO.
    IF P_MSGTY NE C_NONE.
      MESSAGE ID 'ZMTI00' TYPE P_MSGTY NUMBER '109' WITH '반출정보'.
    ENDIF.
    P_SUBRC = 4.
    EXIT.
  ENDIF.

*> 송장 문서 체크.
  SELECT COUNT( * ) INTO L_COUNT
    FROM ZTITIVP
   WHERE IBLNO   EQ  P_IBLNO
     AND IBLIT   EQ  P_IBLIT.
  IF L_COUNT GT C_ZERO.
    IF P_MSGTY NE C_NONE.
      MESSAGE ID 'ZMTI00' TYPE P_MSGTY NUMBER '109' WITH '선급금'.
    ENDIF.
    P_SUBRC = 4.
    EXIT.
  ENDIF.

ENDFORM.                    " check_lc_sub_document_exist

*&---------------------------------------------------------------------*
*&      Form  SET_INITIAL_VALUE
*&---------------------------------------------------------------------*
FORM SET_INITIAL_VALUE .

*> 문서 종류.
  G_DOCUMENT = C_BL.

  REFRESH: IT_TAB, IT_PO, IT_ZTITIG02, IT_PONUM,
           IT_ZTISRQIT,
           XZTITBLP, YZTITBLP,
           XZTITBLC, YZTITBLC,
           G_TC_2122_ITAB.

  CLEAR:   IT_TAB, IT_PO, IT_ZTITIG02, IT_PONUM,
           XZTITBLP, YZTITBLP,
           XZTITBLC, YZTITBLC,
           ZTITBLK,    ">B/L Header
          *ZTITBLK,    ">B/L Header
           ZTISSCRCOM-CRLSE,
           G_TC_2122_ITAB,
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
* 20070410 simcho by 박혁세 K
* page down 후 double click시 오류 수정
*****************************************************************
      IF SY-TCODE = 'ZTIT203'.
        G_FINDLINE = TC_2130-TOP_LINE + G_FINDLINE - 1.
      ENDIF.
*****************************************************************

      READ TABLE IT_TAB INTO G_TC_2130_WA INDEX G_FINDLINE.
      IF SY-SUBRC NE 0.
        EXIT.
      ENDIF.
      CHECK OK_CODE EQ 'ZTISELECT'.   ">문서선택.

      CASE G_FIELDNAME.
        WHEN 'ZTISBLIT-EBELN' OR 'ZTISBLIT-EBELP'.
          PERFORM DISPLAY_PURCHASE_ORDER USING G_TC_2130_WA-EBELN
                                               G_TC_2130_WA-EBELP.
        WHEN 'ZTISBLIT-REQNO' OR 'ZTISBLIT-REQIT'.
          SELECT SINGLE AMDSQ  INTO ZTIVRQ00-AMDSQ
            FROM ZTIVRQ00
           WHERE REQNO  EQ  G_TC_2130_WA-REQNO
             AND REQIT  EQ  G_TC_2130_WA-REQIT.
          IF SY-SUBRC EQ 0.
            PERFORM DISPLAY_IMPORT_DOCUMENT USING G_TC_2130_WA-REQNO
                                                  ZTIVRQ00-AMDSQ
                                                  G_TC_2130_WA-REQIT.
          ENDIF.
        WHEN 'ZTISBLIT-RSNUM' OR 'ZTISBLIT-RSPOS' OR 'ZTISBLIT-RSART'.
          PERFORM DISPLAY_RESERVATION     USING G_TC_2130_WA-RSNUM
                                                G_TC_2130_WA-RSPOS.
        WHEN 'ZTISBLIT-MATNR'.
          PERFORM DISPLAY_MATERIAL_MASTER USING G_TC_2130_WA-MATNR
                                                G_TC_2130_WA-WERKS
                                                G_TC_2130_WA-LGORT.
        WHEN 'ZTISBLIT-IVONO'.
          PERFORM DISPLAY_CIV_DOCUMENT    USING G_TC_2130_WA-IVONO.

      ENDCASE.
    ENDIF.
  ELSE.
    GET CURSOR FIELD G_FIELDNAME.
    IF SY-SUBRC EQ 0.
      G_FINDSCR = SY-DYNNR.
      CHECK OK_CODE EQ 'ZTISELECT'.   ">문서선택.

      CASE G_FIELDNAME.
        WHEN 'ZTITBLK-LIFNR'.
          PERFORM DISPLAY_VENDOR_MASTER   USING ZTITBLK-LIFNR
                                                ZTITBLK-EKORG.
        WHEN 'ZTITBLK-IVONO'.
          PERFORM DISPLAY_CIV_DOCUMENT    USING ZTITBLK-IVONO.
        WHEN 'ZTITBLK-BBLNO'.
          PERFORM DISPLAY_BL_DOCUMENT     USING ZTITBLK-BBLNO
                                                '00000'.
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
                            USING    P_ZTITBLK STRUCTURE ZTITBLK.

  DATA: L_LPONR LIKE P_ZTITBLK-LPONR.

  IF G_MODE EQ C_CHARC.
    CLEAR: L_LPONR.
    LOOP AT P_IT_TAB.
      ADD 1 TO L_LPONR.
      MOVE L_LPONR TO P_IT_TAB-IBLIT.
      MODIFY P_IT_TAB.
    ENDLOOP.
    MOVE L_LPONR TO P_ZTITBLK-LPONR.
  ELSE.
    CLEAR: G_LINES.
    LOOP AT P_IT_TAB.
      IF NOT P_IT_TAB-IBLIT IS INITIAL.
        PERFORM CHECK_BL_SUB_DOCUMENT_EXIST USING P_IT_TAB-IBLNO
                                                  P_IT_TAB-IBLIT
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
        IF P_IT_TAB-IBLIT IS INITIAL.
          ADD 1 TO P_ZTITBLK-LPONR.
          MOVE P_ZTITBLK-LPONR TO P_IT_TAB-IBLIT.
        ENDIF.
        MODIFY P_IT_TAB.
      ENDLOOP.
    ELSE.
      CLEAR: L_LPONR.
      LOOP AT P_IT_TAB.
        ADD 1 TO L_LPONR.
        MOVE L_LPONR TO P_IT_TAB-IBLIT.
        MODIFY P_IT_TAB.
      ENDLOOP.
      MOVE L_LPONR TO P_ZTITBLK-LPONR.
    ENDIF.
  ENDIF.
  CLEAR: L_LPONR.
  LOOP AT P_IT_TAB.
    IF P_IT_TAB-IBLIT GT L_LPONR.
      MOVE P_IT_TAB-IBLIT TO L_LPONR.
    ENDIF.
  ENDLOOP.
  MOVE L_LPONR TO P_ZTITBLK-LPONR.

ENDFORM.                    " set_item_number_build
*&---------------------------------------------------------------------*
*&      Form  set_function_by_BUSINESS
*&---------------------------------------------------------------------*
FORM SET_FUNCTION_BY_BUSINESS .

  IF ZTITBLK-BLDTY EQ C_CHARS OR
     ZTITBLK-BLDTY EQ C_CHARO OR
     ZTITBLK-BLDTY EQ C_CHARA .
    MOVE 'ZTISPLIT'     TO FTAB-FCODE.   APPEND FTAB. ">금액분할.
  ENDIF.

  IF ZTITBLK-BLDTY EQ C_CHARS.
    LOOP AT IT_TAB INTO G_TC_2130_WA WHERE EBELN NE SPACE.
    ENDLOOP.
    IF SY-SUBRC NE 0.
      MOVE 'ZTITRON'        TO FTAB-FCODE.   APPEND FTAB. ">개요펼치기.
      MOVE 'ZTITROFF'       TO FTAB-FCODE.   APPEND FTAB. ">개요닫기.
    ENDIF.
  ENDIF.

  IF   ZTITBLK-CRLSE IS INITIAL.
    MOVE 'ZTICONFIRM'     TO FTAB-FCODE.   APPEND FTAB. ">확인.
    MOVE 'ZTICONFIRC'     TO FTAB-FCODE.   APPEND FTAB. ">확인취소.
  ELSE.
    IF G_MODE EQ C_CHARM.
      IF ZTITBLK-CRLSE EQ C_CHARB.
        MOVE 'ZTICONFIRC'     TO FTAB-FCODE.   APPEND FTAB. ">확인취소.
      ELSEIF ZTITBLK-CRLSE EQ C_CHARC.
        MOVE 'ZTICONFIRM'     TO FTAB-FCODE.   APPEND FTAB. ">확인.
      ENDIF.
    ELSE.
      MOVE 'ZTICONFIRM'     TO FTAB-FCODE.   APPEND FTAB. ">확인.
      MOVE 'ZTICONFIRC'     TO FTAB-FCODE.   APPEND FTAB. ">확인취소.
    ENDIF.
  ENDIF.

  CASE G_MODE.
    WHEN C_CHARA.   ">선적서류 송부.
      IF ZTITBLK-BLDST EQ C_CHARA.
        MOVE 'ZTIRETURN'     TO FTAB-FCODE.   APPEND FTAB. ">송부취소.
      ELSE.
*        MOVE 'ZTIACCEPT'     TO ftab-fcode.   APPEND ftab. ">서류송부.
      ENDIF.
    WHEN C_CHARY.   ">실입항 입력.
      IF ZTITBLK-BLDST EQ C_CHARB.
        MOVE 'ZTIAPPLYC'     TO FTAB-FCODE.   APPEND FTAB. ">입력취소.
      ELSE.
*        MOVE 'ZTIAPPLY'      TO ftab-fcode.   APPEND ftab. ">입력.
      ENDIF.
      MOVE 'ZTIRECV'         TO FTAB-FCODE.   APPEND FTAB. ">입력취소.
      MOVE 'ZTIRECVC'        TO FTAB-FCODE.   APPEND FTAB. ">입력취소.
    WHEN C_CHARO.   ">>>>>???
      MOVE 'ZTISAVE'         TO FTAB-FCODE.   APPEND FTAB. ">저장.
      IF ZTITBLK-BLDST EQ C_CHARD.
        MOVE 'ZTIRECVC'      TO FTAB-FCODE.   APPEND FTAB. ">입력취소.
      ENDIF.
    WHEN OTHERS.
  ENDCASE.


  CLEAR GV_EMRO_LINK.
  SELECT SINGLE URL INTO GV_EMRO_LINK
   FROM ZTITBLH WHERE BLNUM EQ ZTITBLK-BLNUM.

  IF GV_EMRO_LINK IS INITIAL.
    MOVE 'ZLINK'         TO FTAB-FCODE.   APPEND FTAB.
  ENDIF.

  IF ZTITBLK-BUKRS NE '1000' .
    MOVE 'ZCOTY'         TO FTAB-FCODE.   APPEND FTAB.
  ENDIF.
ENDFORM.                    " set_function_by_BUSINESS
*&---------------------------------------------------------------------*
*&      Form  check_request_of_import
*&---------------------------------------------------------------------*
*  수입의뢰문서의 종류/상태를 검증.
*----------------------------------------------------------------------*
FORM CHECK_REQUEST_OF_IMPORT .
  DATA: L_DDTEXT LIKE G_DDTEXT.

*050302 jp, park 추가.
  G_REQTY = ZTITRQK-REQTY.

  CASE ZTITRQK-REQTY.
    WHEN C_PU OR C_LO.
*> 수입의뢰 종류 Fixed value read.
      PERFORM  DDIC_DOMAIN_VALUE_TEXT_READ USING 'ZTIREQTY'
                                                 SY-LANGU
                                                 ZTITRQK-REQTY
                                                 G_DDTEXT
                                                 C_SUCCESS.
      L_DDTEXT = G_DDTEXT.
      MESSAGE E203 WITH L_DDTEXT.
    WHEN OTHERS.
*> 선급금일 경우.
      IF ZTITRQK-PPAID EQ C_TRUE.
        MESSAGE E204 WITH '선급금'.
      ENDIF.
*> 유보금일 경우.
      IF NOT ZTITRQK-RPAID IS INITIAL.
        MESSAGE E204 WITH '유보금'.
      ENDIF.
  ENDCASE.

ENDFORM.                    " check_request_of_import
*&---------------------------------------------------------------------*
*&      Form  get_available_lc_item
*&---------------------------------------------------------------------*
*       B/L을 입력할 수입의뢰 잔량을 체크함.
*----------------------------------------------------------------------*
FORM GET_AVAILABLE_LC_ITEM  TABLES   PT_ZTISRQIT STRUCTURE IT_ZTISRQIT
                                     PT_REQNO    STRUCTURE IT_REQNO
                            USING    P_MSGTY
                                     P_DEL_MODE.
  DATA: L_BLMNG  LIKE ZTITBLP-BLMNG.

  CLEAR: G_COUNT, G_CNT.

  LOOP AT PT_ZTISRQIT.
    G_TABIX = SY-TABIX.
    CLEAR: L_BLMNG.

    IF NOT PT_ZTISRQIT-EBELN IS INITIAL.
      SELECT  SUM( BLMNG ) INTO PT_ZTISRQIT-BLMNGS
        FROM  ZTIVBL00
       WHERE  EBELN  = PT_ZTISRQIT-EBELN
         AND  EBELP  = PT_ZTISRQIT-EBELP
         AND  REQNO  = PT_ZTISRQIT-REQNO
         AND  REQIT  = PT_ZTISRQIT-REQIT.

      PT_ZTISRQIT-BLMNG =  PT_ZTISRQIT-RQMNG - PT_ZTISRQIT-BLMNGS.

      IF PT_ZTISRQIT-BLMNG LE C_ZERO.
        IF P_DEL_MODE EQ C_TRUE.
          DELETE PT_ZTISRQIT INDEX G_TABIX.
          CONTINUE.
        ELSE.
          PT_ZTISRQIT-BLMNG = 0.
        ENDIF.
      ELSE.
        ADD 1 TO G_CNT.
      ENDIF.

      PT_ZTISRQIT-BLMNGL =  PT_ZTISRQIT-BLMNG.

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
    MESSAGE ID 'ZMTI00' TYPE P_MSGTY NUMBER 103.
  ENDIF.

ENDFORM.                    " get_available_lc_item
*&---------------------------------------------------------------------*
*&      Form  display_import_doc_by_node
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM DISPLAY_IMPORT_DOC_BY_NODE  USING    P_NODE_KEY.

  READ TABLE IT_ZTISRQIT INTO G_ZTISRQIT_WA
                         WITH KEY INDEX = P_NODE_KEY(10).
  IF SY-SUBRC EQ 0.
    PERFORM  DISPLAY_IMPORT_DOCUMENT USING G_ZTISRQIT_WA-REQNO
                                           G_ZTISRQIT_WA-AMDSQ
                                           G_ZTISRQIT_WA-REQIT.
  ELSE.
    MESSAGE S903.
  ENDIF.

ENDFORM.                    " display_import_doc_by_node
*&---------------------------------------------------------------------*
*&      Form  check_open_amount
*&---------------------------------------------------------------------*
*       Header Amount check
*----------------------------------------------------------------------*
FORM CHECK_OPEN_AMOUNT   USING  P_UPDATE_MODE
                                P_FIRST_MODE.

  DATA : L_TEXT_EXRATE(255)    TYPE C,
         L_FOREIGN_FACTOR(255) TYPE C,
         L_FACTOR              TYPE P,
         L_EINDT               TYPE EINDT,
         L_WRBTR               TYPE WRBTR,
         L_NETWR               TYPE NETWR,
         L_EBELN_CNT           TYPE I,
         L_COUNT               TYPE I,
         L_CHECK               TYPE C,
         L_COMPLETE            TYPE C,
         L_BLMNG               TYPE ZTIBLMNG,
         L_RQMNG               TYPE ZTIRQMNG,
         L_RQMNGQ              TYPE ZTIRQMNG,
         L_PPMNGQ              TYPE ZTIPPMNG,
         L_PPMNGB              TYPE ZTIPPMNG,
         L_PPMNG               TYPE ZTIPPMNG,
         L_PPAMT               TYPE ZTIPPAM2,
         L_PPAMTQ              TYPE ZTIPPAM2,
         L_PPAMTB              TYPE ZTIPPAM2,
         L_PPAM1               TYPE ZTIPPAM2,
         L_FIXED_RATE          LIKE TCURS-SPRED,
         L_BLCNT               TYPE ZTIBLCNT,
         L_LOCAL_AMT           LIKE ZTITRQS-USAMT.  " USD 환산 Amount

*> 선적차수 계산용.(ZTITBLK-BLCNT)
  DATA: BEGIN OF LT_EBELN OCCURS 0,
        EBELN    TYPE EBELN,
        END   OF LT_EBELN.

  DATA: BEGIN OF LT_REQNO OCCURS 0,
        REQNO    TYPE ZTIREQNO,
        END   OF LT_REQNO.

  DATA: BEGIN OF LT_EKKO OCCURS 0,
        EBELN    TYPE EBELN,
        END   OF LT_EKKO.


  DATA: BEGIN OF LT_EKPO OCCURS 0,
        EBELN    TYPE EBELN,
        EBELP    TYPE EBELP,
        MENGE    TYPE BSTMG,
        BLMNG    TYPE ZTIBLMNG,
        END   OF LT_EKPO.

  REFRESH: IT_NDFTY, IT_BLCNT, IT_PSPNR.
  CLEAR: G_WRBTR, IT_NDFTY, G_PPAMT, L_EINDT.

*> Begin of Loop
  LOOP AT IT_TAB INTO G_TC_2130_WA.
    IF L_EINDT IS INITIAL.
      L_EINDT = G_TC_2130_WA-EINDT.
    ENDIF.

    IF G_TC_2130_WA-EINDT LT L_EINDT.
      L_EINDT = G_TC_2130_WA-EINDT.
    ENDIF.

    IF ZTITBLK-EBELN IS INITIAL.
      ZTITBLK-EBELN = G_TC_2130_WA-EBELN.
    ENDIF.

    IF ZTITBLK-WERKS IS INITIAL.
      ZTITBLK-WERKS = G_TC_2130_WA-WERKS.
    ENDIF.

    IF ZTITBLK-BUPLA IS INITIAL.
      SELECT SINGLE J_1BBRANCH
        INTO ZTITBLK-BUPLA
        FROM T001W
       WHERE WERKS EQ G_TC_2130_WA-WERKS.
    ENDIF.

*----------------------------------------------------------------------
*> 선급금액 체크.
*----------------------------------------------------------------------
    IF NOT G_TC_2130_WA-REQNO IS INITIAL.
      CLEAR: L_RQMNG,  L_NETWR,
             L_PPMNGQ, L_PPMNGB,
             L_PPAMTQ, L_PPAMTQ.
*> 선급금 수량 집계
*      SELECT  SUM( ppmng )
*        INTO  l_rqmng
*        FROM  ZTIvrq00
*       WHERE  reqno  = g_tc_2130_wa-reqno
*         AND  reqit  = g_tc_2130_wa-reqit.
*
      IF P_FIRST_MODE EQ C_TRUE.
        SELECT  SINGLE *
          FROM  ZTIVRQ00
         WHERE  REQNO  = G_TC_2130_WA-REQNO
           AND  REQIT  = G_TC_2130_WA-REQIT.

        L_PPMNGQ  = ZTIVRQ00-PPMNG.
        L_PPAMTQ  = ZTIVRQ00-IPAMT.

*> 선급금 참조 수량 집계.
        SELECT  SUM( PPMNG ) SUM( PPAMT )
          INTO  (L_PPMNGB, L_PPAMTB)
          FROM  ZTIVBL00
         WHERE  REQNO  = G_TC_2130_WA-REQNO
           AND  REQIT  = G_TC_2130_WA-REQIT
           AND NOT ( IBLNO  = G_TC_2130_WA-IBLNO
           AND       IBLIT  = G_TC_2130_WA-IBLIT ).
*> 선급금 수량 = 선급금 합계 수량 - 선급금 참조 합계수량.
        L_PPMNGB = L_PPMNGQ - L_PPMNGB.
        L_PPAMTB = L_PPAMTQ - L_PPAMTB.

**> if 선급금 수량 > B/L 수량 then
**>    오류 메시지.
*      IF g_tc_2130_wa-netpr GT 0.
*        IF l_ppmngb GT g_tc_2130_wa-blmng.
**          l_rqmng = g_tc_2130_wa-blmng.
*          MESSAGE e219.
*        ENDIF.
*      ENDIF.
      ELSE.
        L_PPAMTB = G_TC_2130_WA-PPAMT.
        L_PPMNGB = G_TC_2130_WA-PPMNG.
      ENDIF.

*> 사전송금일 경우.
      IF ZTIVRQ00-REQTY EQ C_TT    AND
         ZTIVRQ00-ANBTY EQ C_CHARB AND
         ZTIVRQ00-PPAID EQ C_CHARN.
        L_PPMNGB = G_TC_2130_WA-BLMNG.
        L_PPAMTB = G_TC_2130_WA-NETWR.
      ENDIF.

      IF P_FIRST_MODE EQ C_TRUE.
*      IF p_update_mode EQ c_true.
        G_TC_2130_WA-PPMNG = L_PPMNGB.
        G_TC_2130_WA-PPAMT = L_PPAMTB.
      ENDIF.

*      g_tc_2130_wa-ppmngs = l_ppmngb.
*      g_tc_2130_wa-ppamts = l_ppamtb.
*
      IF L_RQMNG LT 0.
        L_PPMNGB = 0.
        L_PPAMTB = 0.
      ENDIF.

**> 선급금 계산.
*      IF NOT l_rqmngB IS INITIAL.
**        if g_tc_2130_wa-netwr is initial.
*        IF g_tc_2130_wa-RQMNG NE g_tc_2130_wa-BLMNG.
*          CALL FUNCTION 'Z_TI_CALC_ITEM_AMOUNT'
*            EXPORTING
*              peinh = g_tc_2130_wa-peinh
*              bpumz = g_tc_2130_wa-bpumz
*              bpumn = g_tc_2130_wa-bpumn
*              menge = l_rqmng
*              netpr = g_tc_2130_wa-netpr
*            CHANGING
*              netwr = l_netwr.
*          else.
*            l_netwr = g_tc_2130_wa-netwr.
*          endif.
*      ELSE.
*        l_netwr = 0.
*      ENDIF.
*
      ADD L_PPAMTB TO G_PPAMT.
    ENDIF.

**> 송장금액 계산.
*    IF ( g_mode EQ c_charc OR
*         g_mode EQ c_charm ) AND
*         g_tc_2130_wa-refwr IS INITIAL.
*
*      l_blmng = g_tc_2130_wa-blmng - g_tc_2130_wa-ppmng.
*      g_tc_2130_wa-refwr = g_tc_2130_wa-netwr.
**> 정가 계산.
*      IF sy-dynnr NE c_scr2000.
*        IF ZTIvrq00-rqmng NE l_blmng.
*          CALL FUNCTION 'Z_TI_CALC_ITEM_AMOUNT'
*            EXPORTING
*              peinh = g_tc_2130_wa-peinh
*              bpumz = g_tc_2130_wa-bpumz
*              bpumn = g_tc_2130_wa-bpumn
*              menge = l_blmng
*              netpr = g_tc_2130_wa-netpr
*            CHANGING
*              netwr = l_netwr.
*          g_tc_2130_wa-netwr = l_netwr.
*          g_tc_2130_wa-refwr = l_netwr.
*        ENDIF.
*      ENDIF.
*    ELSE.
*      l_netwr = g_tc_2130_wa-refwr.
*    ENDIF.
*>
    IF ( G_MODE EQ C_CHARC OR
         G_MODE EQ C_CHARM ) AND
         G_TC_2130_WA-REFWR IS INITIAL.
      IF G_TC_2130_WA-PPAMT GT G_TC_2130_WA-NETWR.
        G_TC_2130_WA-PPAMT = 0.
      ENDIF.
      G_TC_2130_WA-REFWR = G_TC_2130_WA-NETWR - G_TC_2130_WA-PPAMT.
    ENDIF.


********************************************************************
* 20070109 SIMCHO BY 박혁세k
* 사후송금의 경우 BL분할된 경우 금액도 분할되도록 LOGIC수정
********************************************************************
**>유환건만 헤더금액에 가산함..(원본)
*    IF g_tc_2130_wa-ndfty IS INITIAL OR
*       g_tc_2130_wa-ndfty EQ c_chara.
*      ADD g_tc_2130_wa-refwr TO g_wrbtr.
*    ENDIF.
********************************************************************
*>유환건만 헤더금액에 가산함..
    IF G_TC_2130_WA-NDFTY IS INITIAL OR
       G_TC_2130_WA-NDFTY EQ C_CHARA.

      CALL FUNCTION 'Z_TI_CALC_ITEM_AMOUNT'
        EXPORTING
          PEINH = G_TC_2130_WA-PEINH
          BPUMZ = G_TC_2130_WA-BPUMZ
          BPUMN = G_TC_2130_WA-BPUMN
          MENGE = G_TC_2130_WA-BLMNG
          NETPR = G_TC_2130_WA-NETPR
        CHANGING
          NETWR = G_TC_2130_WA-NETWR.

      ADD G_TC_2130_WA-NETWR TO G_WRBTR.
      G_TC_2130_WA-REFWR = G_TC_2130_WA-NETWR.

    ENDIF.
********************************************************************
* END
********************************************************************



*> 호선 정보 collect.
    IF NOT G_TC_2130_WA-PS_PSP_PNR IS INITIAL.
      MOVE: G_TC_2130_WA-PS_PSP_PNR TO IT_PSPNR-PSPNR.
      COLLECT IT_PSPNR.
    ENDIF.

*> 생성 / 변경 모드일 경우, 아이템에 저장.
    IF G_MODE EQ C_CHARC OR
       G_MODE EQ C_CHARM.

      IF G_TC_2130_WA-BLMNG GE G_TC_2130_WA-BLMNGL.
        G_TC_2130_WA-EREKZ = C_TRUE.
      ELSE.
        G_TC_2130_WA-EREKZ = C_FALSE.
      ENDIF.
      IF G_TC_2130_WA-BLMNG LT C_ZERO.
        G_TC_2130_WA-BLMNG = C_ZERO.
      ENDIF.
      IF G_TC_2130_WA-REFWR LT C_ZERO.
        G_TC_2130_WA-REFWR = C_ZERO.
      ENDIF.
      IF G_TC_2130_WA-NETWR LT C_ZERO.
        G_TC_2130_WA-NETWR = C_ZERO.
      ENDIF.
      IF G_TC_2130_WA-PPAMT LT C_ZERO.
        G_TC_2130_WA-PPAMT = C_ZERO.
      ENDIF.
      IF G_TC_2130_WA-PPMNG LT C_ZERO.
        G_TC_2130_WA-PPMNG = C_ZERO.
      ENDIF.

*      SELECT SINGLE *
*        FROM zmmt0001
*       WHERE ebeln EQ g_tc_2130_wa-ebeln
*         AND ebelp EQ g_tc_2130_wa-ebelp.
*      IF sy-subrc EQ 0.
*        g_tc_2130_wa-ndfty = c_charn.
*      ELSE.
      IF G_TC_2130_WA-REPOS EQ SPACE.
        IF G_TC_2130_WA-NDFTY IS INITIAL.
          G_TC_2130_WA-NDFTY = C_CHARS.
        ENDIF.
        IF G_TC_2130_WA-NDFTY EQ C_CHARN.
          G_TC_2130_WA-NDFTY = C_CHARS.
        ENDIF.
      ENDIF.
*      ENDIF.
      SELECT COUNT( DISTINCT IBLNO )
        INTO L_COUNT
        FROM ZTITBLP
       WHERE EBELN EQ G_TC_2130_WA-EBELN
         AND EBELP EQ G_TC_2130_WA-EBELP
         AND IBLNO NE ZTITBLK-IBLNO.

      ADD 1 TO L_COUNT.
      IF L_COUNT LT 10.
        MOVE: '0'          TO G_TC_2130_WA-BLCNT,
              L_COUNT      TO G_TC_2130_WA-BLCNT+1(1).
      ELSE.
        G_TC_2130_WA-BLCNT = L_COUNT.
      ENDIF.

*> 무환일 경우...
      IF G_TC_2130_WA-NDFTY EQ 'B' OR
         G_TC_2130_WA-NDFTY EQ 'C' OR
         G_TC_2130_WA-NDFTY EQ 'R' OR
         G_TC_2130_WA-NDFTY EQ 'H' OR
         G_TC_2130_WA-NDFTY EQ 'S'.
        G_TC_2130_WA-BLCNT = 'XX'.
      ENDIF.
*      IF g_tc_2130_wa-blcnt EQ '01'.
*        IF g_tc_2130_wa-erekz EQ c_true.
*          g_tc_2130_wa-blcnt = 'XX'.
*        ENDIF.
*      ELSE.
*        IF g_tc_2130_wa-erekz EQ c_true.
*          g_tc_2130_wa-blcnt = 'ZZ'.
*        ENDIF.
*      ENDIF.
      IT_BLCNT-BLCNT = G_TC_2130_WA-BLCNT.
      COLLECT IT_BLCNT.

      MODIFY IT_TAB FROM G_TC_2130_WA.
    ENDIF.

*> 무환종류 collect.
    MOVE: G_TC_2130_WA-NDFTY TO IT_NDFTY-NDFTY.
    IF IT_NDFTY-NDFTY EQ 'S' OR
       IT_NDFTY-NDFTY EQ 'R' OR
       IT_NDFTY-NDFTY EQ 'C' OR
       IT_NDFTY-NDFTY EQ 'H' OR
       IT_NDFTY-NDFTY EQ 'N'.
      IT_NDFTY-NDFTY = 'X'.
    ENDIF.
    COLLECT IT_NDFTY.

    IF NOT G_TC_2130_WA-EBELN IS INITIAL.
      MOVE-CORRESPONDING: G_TC_2130_WA TO LT_REQNO,
                          G_TC_2130_WA TO LT_EBELN.
      COLLECT : LT_REQNO, LT_EBELN.
    ENDIF.
  ENDLOOP.
*> End of Loop

  IF ( G_MODE EQ C_CHARC OR
       G_MODE EQ C_CHARM ).
*> 입항예정일.
    IF ZTITBLK-INPDT IS INITIAL.
      ZTITBLK-INPDT = L_EINDT - 5.
    ENDIF.
*> 통관예정일.
    IF ZTITBLK-CDPDT IS INITIAL.
      ZTITBLK-CDPDT = L_EINDT.
    ENDIF.

    IF P_FIRST_MODE EQ C_TRUE.
      IF G_PPAMT GT G_WRBTR.
        G_PPAMT = 0.
      ENDIF.
**> 사전송금일 경우.
*      IF ztivrq00-reqty EQ c_tt    AND
*         ztivrq00-anbty EQ c_charb AND
*         ztivrq00-ppaid EQ c_charn.
*      else.
*        ztitblk-smamt = g_wrbtr + g_ppamt.
      ZTITBLK-SMAMT = G_WRBTR.
      ZTITBLK-PPAMT = G_PPAMT.
*      endif.
    ENDIF.
    IF P_UPDATE_MODE EQ C_TRUE.
      IF G_PPAMT GT G_WRBTR.
        G_PPAMT = 0.
      ENDIF.
*      ztitblk-smamt = g_wrbtr + g_ppamt.
      ZTITBLK-SMAMT = G_WRBTR.
      ZTITBLK-PPAMT = G_PPAMT.
    ENDIF.
  ENDIF.
*  l_wrbtr        = g_wrbtr - g_ppamt - ZTITBLK-rtchg.
*  l_wrbtr        = g_wrbtr - g_ppamt.
  L_WRBTR        = ZTITBLK-SMAMT - G_PPAMT.

  IF P_UPDATE_MODE EQ C_TRUE.
    IF L_WRBTR LT C_ZERO.
      G_PPAMT = ZTITBLK-SMAMT.
      L_WRBTR = 0.
    ENDIF.
  ENDIF.

  IF L_WRBTR LT 0.
    MESSAGE I220.
    ZTITBLK-IVAMT = 0.
*    ZTITBLK-smamt = 0.
    EXIT.
  ENDIF.

*> if update mode eq 'X' then
  IF P_UPDATE_MODE EQ C_TRUE.
    IF ZTITBLK-BLDTY EQ C_CHARS.
      ZTITBLK-IVAMT = C_ZERO.
    ELSE.
      ZTITBLK-IVAMT = L_WRBTR.
    ENDIF.
  ENDIF.

  IF ( G_MODE EQ C_CHARC OR
       G_MODE EQ C_CHARM ).
    IF ZTITBLK-IVAMT IS INITIAL.
      IF ZTITBLK-BLDTY EQ C_CHARS.
        ZTITBLK-IVAMT = C_ZERO.
      ELSE.
        ZTITBLK-IVAMT = L_WRBTR.
      ENDIF.
    ELSE.
      IF ZTITBLK-BLDTY NE C_CHARS.
        IF ZTITBLK-IVAMT NE L_WRBTR.
          IF SY-DYNNR EQ C_SCR2000.
            MESSAGE W214.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.
  ELSE.
    IF ZTITBLK-BLDTY NE C_CHARS.
      IF ZTITBLK-IVAMT NE L_WRBTR.
        MESSAGE I214.
      ENDIF.
    ENDIF.
  ENDIF.


*> 문서 종류 Setting.
  DESCRIBE TABLE IT_NDFTY LINES G_LINE.
  CASE G_LINE.
    WHEN 0.
    WHEN 1.
      READ TABLE IT_NDFTY INDEX 1.
      CASE IT_NDFTY-NDFTY.
        WHEN SPACE.      ">유환.
          MOVE SPACE    TO ZTITBLK-BLDTY.
        WHEN C_CHARA.    ">사후..
          MOVE C_CHARA  TO ZTITBLK-BLDTY.
        WHEN C_CHARO.    ">OFE.
          MOVE C_CHARO  TO ZTITBLK-BLDTY.
        WHEN OTHERS.     ">무환.
          MOVE C_CHARS  TO ZTITBLK-BLDTY.
      ENDCASE.
    WHEN OTHERS.         ">Combine
      MOVE C_CHARC  TO ZTITBLK-BLDTY.
  ENDCASE.

  READ TABLE IT_TAB INTO G_TC_2130_WA WITH KEY NDFTY = C_CHARA.
  IF SY-SUBRC EQ 0.
    G_BLDTY = C_CHARA.
  ELSE.
    G_BLDTY = ZTITBLK-BLDTY.
  ENDIF.

**********************************************************************
* 2009.02.24 simcho by 오민석K : 수입반품
**********************************************************************
  IF ZTITBLK-EBELN IS NOT INITIAL.

    DATA LV_ZTERM LIKE EKKO-ZTERM.
    CLEAR EKKO.

    SELECT SINGLE ZTERM INTO LV_ZTERM
      FROM EKKO
     WHERE EBELN = ZTITBLK-EBELN
       AND ZTERM = 'TANO'.     " 수입반품

    IF SY-SUBRC = 0.
      MOVE C_CHARB  TO ZTITBLK-BLDTY.  " 수입반품 B/L유형 세팅
    ENDIF.

  ENDIF.
**********************************************************************
  IF P_UPDATE_MODE EQ C_TRUE.
*> P/O 총금액 계산.
    PERFORM GET_TOTAL_PO_AMOUNT         TABLES GT_EKPO
                                        USING  ZTISSCRCOM-POAMT.
*> 문서금액 계산.
    PERFORM GET_TOTAL_DOCUMENT_AMOUNT   USING  ZTISSCRCOM-DCAMT.
**> Invoice Amount Check.
*    PERFORM check_invoice_amount.
*> 유보금 아이템별 배부.
    PERFORM  PREPAID_AMOUNT_CHANGE_EVENT.
  ENDIF.

  IF SY-DYNNR      EQ C_SCR0100 OR
     ZTITBLK-CSATY IS INITIAL.
    CASE ZTITBLK-BLDTY.
      WHEN C_CHARS.   ">무환.
        READ TABLE IT_NDFTY INDEX 1.
        CASE IT_NDFTY-NDFTY.
          WHEN C_CHARC.    ">대체품.
            MOVE '93'    TO ZTITBLK-CSATY.
          WHEN C_CHARR.    ">보상품.
            MOVE '93'    TO ZTITBLK-CSATY.
          WHEN C_CHARS.    ">샘플.
            MOVE '87'    TO ZTITBLK-CSATY.
          WHEN C_CHARB.    ">수리품.
            MOVE '90'    TO ZTITBLK-CSATY.
          WHEN OTHERS.     ">기타.
            MOVE '80'    TO ZTITBLK-CSATY.
        ENDCASE.
      WHEN C_CHARH.   ">Ship Back.
        ZTITBLK-CSATY = '89'.  ">수출물품의 크레임등의 사유로 반입.
      WHEN OTHERS.
        ZTITBLK-CSATY = '11'.  ">일반형태의 수입.
    ENDCASE.
  ENDIF.

*> 구매오더별 선적차수.
  CLEAR: L_CHECK.
  IF G_MODE EQ C_CHARC OR
     G_MODE EQ C_CHARM.
    DESCRIBE TABLE IT_BLCNT LINES G_LINE.
    CASE G_LINE.
      WHEN 0.   ZTITBLK-BLCNT = 'XX'.
      WHEN 1.
        SELECT EBELN EBELP MENGE
          INTO CORRESPONDING FIELDS OF TABLE LT_EKPO
          FROM EKPO
           FOR ALL ENTRIES IN IT_TAB
         WHERE EBELN EQ IT_TAB-EBELN.

        REFRESH: LT_EKKO.
        L_COMPLETE = 'Y'.
        LOOP AT LT_EKPO.
          SELECT SUM( BLMNG )
            INTO LT_EKPO-BLMNG
            FROM ZTITBLP
           WHERE EBELN EQ LT_EKPO-EBELN
             AND EBELP EQ LT_EKPO-EBELP
             AND IBLNO NE ZTITBLK-IBLNO.

          LOOP AT IT_TAB INTO G_TC_2130_WA
                         WHERE EBELN = LT_EKPO-EBELN
                           AND EBELP = LT_EKPO-EBELP.
            LT_EKPO-BLMNG = LT_EKPO-BLMNG + G_TC_2130_WA-BLMNG.
          ENDLOOP.
          MODIFY LT_EKPO.

          IF LT_EKPO-BLMNG LT LT_EKPO-MENGE.
            L_COMPLETE = 'N'.
          ENDIF.
          LT_EKKO-EBELN = LT_EKPO-EBELN.
          COLLECT LT_EKKO.
        ENDLOOP.

        IF L_COMPLETE EQ 'Y'.
          READ TABLE IT_BLCNT INDEX 1.
          ZTITBLK-BLCNT = IT_BLCNT-BLCNT.
          IF ZTITBLK-BLCNT EQ '01'.
            ZTITBLK-BLCNT = 'XX'.  ">전량선적
          ELSE.
            ZTITBLK-BLCNT = 'ZZ'.  ">전량선적
          ENDIF.
        ELSE.
          DESCRIBE TABLE LT_EKKO LINES L_EBELN_CNT.
          DESCRIBE TABLE LT_EKPO LINES L_COUNT.
          DESCRIBE TABLE IT_TAB  LINES G_LINE.
          IF G_LINE EQ L_COUNT.
            LOOP AT IT_TAB INTO G_TC_2130_WA.
              READ TABLE LT_EKPO WITH KEY EBELN = G_TC_2130_WA-EBELN
                                          EBELP = G_TC_2130_WA-EBELP.
              IF SY-SUBRC EQ 0.
                IF LT_EKPO-MENGE NE G_TC_2130_WA-BLMNG.
                  L_CHECK = C_TRUE.
                  EXIT.
                ENDIF.
              ENDIF.
            ENDLOOP.
          ELSE.
            L_CHECK = C_TRUE.
          ENDIF.
          IF L_CHECK EQ C_TRUE.
            IF L_EBELN_CNT EQ 1.
              SELECT COUNT( DISTINCT IBLNO )
                INTO L_COUNT
                FROM ZTITBLP
               WHERE EBELN EQ ZTITBLK-EBELN
                 AND IBLNO NE ZTITBLK-IBLNO.
              ADD 1 TO L_COUNT.
              IF L_COUNT LT 10.
                MOVE: '0'          TO ZTITBLK-BLCNT,
                      L_COUNT      TO ZTITBLK-BLCNT+1(1).
              ELSE.
                ZTITBLK-BLCNT = L_COUNT.
              ENDIF.
            ELSE.
              REFRESH IT_BLCNT.
              LOOP AT LT_EKKO.
                SELECT COUNT( DISTINCT IBLNO )
                  INTO L_COUNT
                  FROM ZTITBLP
                 WHERE EBELN EQ LT_EKKO-EBELN.
                ADD 1 TO L_COUNT.
                IF L_COUNT LT 10.
                  MOVE: '0'          TO IT_BLCNT-BLCNT,
                        L_COUNT      TO IT_BLCNT-BLCNT+1(1).
                ELSE.
                  IT_BLCNT = L_COUNT.
                ENDIF.
                COLLECT IT_BLCNT.
              ENDLOOP.
              DESCRIBE TABLE IT_BLCNT LINES G_LINE.
              CASE G_LINE.
                WHEN 0.   ZTITBLK-BLCNT = 'XX'.
                WHEN 1.
                  ZTITBLK-BLCNT = IT_BLCNT-BLCNT.
                WHEN OTHERS.
                  ZTITBLK-BLCNT = '**'.
              ENDCASE.
            ENDIF.
          ENDIF.
        ENDIF.
      WHEN OTHERS.
        ZTITBLK-BLCNT = '**'.
    ENDCASE.
  ENDIF.

*  if not ( g_mode eq c_chars or
*           g_mode eq c_chard ).
*    describe table lt_reqno lines g_line.
*    case g_line.
*      when 0.    ztitblk-blcnt = 'NN'.
*      when 1.
*        read table lt_ndfty index 1.
*        if sy-subrc eq 0.
*          if lt_ndfty-erekz eq c_charx.
*            ztitblk-blcnt = 'ZZ'.
*          else.
*            select max( blcnt )
*              into l_blcnt
*              from ztivbl00
*               for all entries in it_tab
*             where ebeln eq it_tab-ebeln
*               and ebelp eq it_tab-ebelp
*               and blcnt ne '**'
*               and blcnt ne 'NN'
*               and blcnt ne 'ZZ'.
*
*            ztitblk-blcnt
*          endif.
*        endif.
*
*      when others.
*    endif.
*  endif.
*
ENDFORM.                    " check_open_amount
*&---------------------------------------------------------------------*
*&      Form  SET_AMOUNT_SPLIT
*&---------------------------------------------------------------------*
*       금액비율로 수량 및 아이템 Amount를 조정함.
*----------------------------------------------------------------------*
FORM SET_AMOUNT_SPLIT .

*> B/L 금액 체크.
  PERFORM CHECK_OPEN_AMOUNT  USING C_TRUE C_FALSE.

  ZTISSCRCOM-WAERS  =  ZTITBLK-WAERS.
  SPOP-TEXTLINE1    =  '금액 비율로 아이템이 배부됩니다.'.
  SPOP-TEXTLINE2    =  '금액을 분할하시겠습니까?'.

  CLEAR: OK-CODE.
  CALL SCREEN  7000 STARTING AT 01    01
                    ENDING   AT 43    12.

  CHECK OK-CODE EQ 'ZTIOKAY'.

*> P/O 총금액 계산.
  PERFORM GET_TOTAL_PO_AMOUNT         TABLES GT_EKPO
                                      USING  ZTISSCRCOM-POAMT.

*> 수량 및 금액 배부.
  ZTITBLK-SMAMT  =  ZTISSCRCOM-IVAMT.
  PERFORM SET_ITEM_AMOUNT_CALC  USING '1'.

*  PERFORM  set_item_amount_and_qty_calc.
*> Header amount check
  PERFORM  CHECK_OPEN_AMOUNT USING C_TRUE C_FALSE.

ENDFORM.                    " SET_AMOUNT_SPLIT
*&---------------------------------------------------------------------*
*&      Form  set_item_amount_and_qty_calc
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM SET_ITEM_AMOUNT_AND_QTY_CALC .

  DATA: L_RATE       TYPE F,
        L_BLMNG      TYPE ZTIBLMNG,
        L_BLMNGL     TYPE ZTIBLMNGI,
        L_REFWR      TYPE REFWR,
        L_MAX_CNT    LIKE SY-TABIX,
        L_IVAMT_SUM  LIKE ZTITBLK-IVAMT,
        L_NETWR_SUM  LIKE ZTITBLK-IVAMT,
        L_NETWR_OLD  LIKE ZTITBLK-IVAMT.

  CLEAR: L_IVAMT_SUM, L_RATE, L_NETWR_OLD.

  L_RATE  =  ZTISSCRCOM-IVAMT / ZTITBLK-IVAMT.
*> 수량 Over check
  LOOP AT IT_TAB INTO G_TC_2130_WA.
    L_BLMNG = G_TC_2130_WA-BLMNG * L_RATE.
    L_BLMNGL = G_TC_2130_WA-BLMNGL + G_TC_2130_WA-BLMNGM.
    IF L_BLMNG  GT L_BLMNGL.
      CLEAR: G_MENGET.
*        WRITE ZTIsblit-blmngl TO g_menget(15) UNIT ZTIsblit-meins.
      WRITE L_BLMNGL        TO G_MENGET(15) UNIT G_TC_2130_WA-MEINS.
      CONCATENATE G_MENGET G_TC_2130_WA-MEINS INTO G_MENGET.
      MESSAGE E208 WITH G_MENGET.
    ENDIF.
    IF L_BLMNG LE G_TC_2130_WA-PPMNG.
      WRITE G_TC_2130_WA-PPMNG TO G_MENGET(15) UNIT G_TC_2130_WA-MEINS.
      CONCATENATE G_MENGET G_TC_2130_WA-MEINS INTO G_MENGET.
      MESSAGE E230 WITH G_MENGET.
    ENDIF.
    L_REFWR = G_TC_2130_WA-REFWR * L_RATE.
    IF L_REFWR LE G_TC_2130_WA-PPAMT.
      WRITE G_TC_2130_WA-PPAMT TO G_WRBTR1(16) CURRENCY ZTITBLK-WAERS.
      CONCATENATE G_WRBTR1 ZTITBLK-WAERS INTO G_WRBTR1.
      MESSAGE E233 WITH G_WRBTR1.
    ENDIF.
    L_NETWR_OLD = L_NETWR_OLD + G_TC_2130_WA-NETWR.
  ENDLOOP.

  CLEAR: L_IVAMT_SUM, L_NETWR_SUM.
  LOOP AT IT_TAB INTO G_TC_2130_WA.
    G_TC_2130_WA-BLMNG = G_TC_2130_WA-BLMNG * L_RATE.
    G_TC_2130_WA-NETWR = G_TC_2130_WA-NETWR * L_RATE.
    G_TC_2130_WA-REFWR = G_TC_2130_WA-REFWR * L_RATE.
**> 정가 계산.
*    IF NOT g_tc_2130_wa-netpr IS INITIAL.
*      CALL FUNCTION 'Z_TI_CALC_ITEM_AMOUNT'
*        EXPORTING
*          peinh = g_tc_2130_wa-peinh
*          bpumz = g_tc_2130_wa-bpumz
*          bpumn = g_tc_2130_wa-bpumn
*          menge = g_tc_2130_wa-blmng
*          netpr = g_tc_2130_wa-netpr
*        CHANGING
*          netwr = g_tc_2130_wa-netwr.
*      g_tc_2130_wa-refwr = g_tc_2130_wa-netwr.
*      l_max_cnt = g_tabix.
*    ENDIF.
    MODIFY IT_TAB FROM G_TC_2130_WA.
    ADD G_TC_2130_WA-REFWR TO L_IVAMT_SUM.
    ADD G_TC_2130_WA-NETWR TO L_NETWR_SUM.
  ENDLOOP.

  IF L_IVAMT_SUM NE ZTISSCRCOM-IVAMT.
    CLEAR: G_LINE.
    LOOP AT IT_TAB INTO G_TC_2130_WA.
      IF NOT G_TC_2130_WA-REFWR IS INITIAL.
        G_LINE = SY-TABIX.
      ENDIF.
    ENDLOOP.

    READ TABLE IT_TAB INTO G_TC_2130_WA INDEX G_LINE.
    IF SY-SUBRC EQ 0.
      IF L_IVAMT_SUM GT ZTISSCRCOM-IVAMT.
        G_TC_2130_WA-REFWR = G_TC_2130_WA-REFWR
                           - ( L_IVAMT_SUM - ZTISSCRCOM-IVAMT ).
      ELSE.
        G_TC_2130_WA-REFWR = G_TC_2130_WA-REFWR
                           + ( ZTISSCRCOM-IVAMT - L_IVAMT_SUM ).
      ENDIF.
      MODIFY IT_TAB FROM G_TC_2130_WA INDEX G_LINE.
    ENDIF.
  ENDIF.

  IF L_NETWR_SUM NE L_NETWR_OLD.
    CLEAR: G_LINE.
    LOOP AT IT_TAB INTO G_TC_2130_WA.
      IF NOT G_TC_2130_WA-NETWR IS INITIAL.
        G_LINE = SY-TABIX.
      ENDIF.
    ENDLOOP.

    READ TABLE IT_TAB INTO G_TC_2130_WA INDEX G_LINE.
    IF SY-SUBRC EQ 0.
      IF L_NETWR_SUM GT L_NETWR_OLD.
        G_TC_2130_WA-NETWR = G_TC_2130_WA-NETWR
                           - ( L_NETWR_SUM - L_NETWR_OLD ).
      ELSE.
        G_TC_2130_WA-NETWR = G_TC_2130_WA-NETWR
                           + ( L_NETWR_OLD - L_NETWR_SUM ).
      ENDIF.
      MODIFY IT_TAB FROM G_TC_2130_WA INDEX G_LINE.
    ENDIF.
  ENDIF.

  ZTITBLK-IVAMT = ZTISSCRCOM-IVAMT.

ENDFORM.                    " set_item_amount_and_qty_calc
*&---------------------------------------------------------------------*
*&      Form  create_invoice_document
*&---------------------------------------------------------------------*
*       Invoce 생성 BDC.
*----------------------------------------------------------------------*
FORM CREATE_INVOICE_DOCUMENT .

  DATA: L_SUBRC LIKE  SY-SUBRC,
        L_REMNG TYPE  REMNG.
  DATA: L_IF_NULL TYPE REF TO IF_MESSAGE_OBJ_MM.

  CHECK ZTITBLK-IVONO IS INITIAL.

*  clear: g_count.
*  LOOP AT it_tab INTO g_tc_2130_wa where NDFTY eq space
*                                     and repos eq space.
*    select sum( REMNG )
*      into l_remng
*      from ZTITIVP
*     where reqit  eq  g_tc_2130_wa-
*  endloop.
*
* Message preparations
  PERFORM  SET_MESSAGE_PREPARATIONS.


  REFRESH: BDCDATA.
  CLEAR: SESSION.
  CTU_PARAMS-DISMODE  = 'E'. ">처리모드
  CTU_PARAMS-UPDMODE  = 'S'. ">갱신모드
  CTU_PARAMS-CATTMODE = ' '. ">CATT 모드...
  CTU_PARAMS-DEFSIZE  = ' '. ">기본화면 크기
  CTU_PARAMS-RACOMMIT = 'X'.
  CTU_PARAMS-NOBINPT  = ' ' .
  CTU_PARAMS-NOBIEND  = ' '.

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

*> 초기화면.
  PERFORM BDC_DYNPRO_BUILD USING :
         'X' 'ZTIR3000'          '0100',
         ' ' 'ZTISSCRCOM-IBLNO'  ZTITBLK-IBLNO,
         ' ' 'BDC_OKCODE'       '=ZTIENTER'.
*> 세부화면.
  PERFORM BDC_DYNPRO_BUILD USING :
         'X' 'ZTIR3000'         '2000',
         ' ' 'ZTITIVK-IVNUM'   '',
         ' ' 'ZTITIVK-CIVDT'   ZTITBLK-BLDAT,
         ' ' 'ZTITIVK-BUDAT'   SY-DATLO,
*         ' ' 'ZTITIVK-BLDAT'   '',
*         ' ' 'ZTITIVK-BUPLA'   g_tc_2130_wa-bupla,
*         ' ' 'ZTITIVK-GSBER'   '1110',
*         ' ' 'ZTITIVK-BLART'   'RE',
*         ' ' 'ZTITIVK-MWSKZ'   ekpo-mwskz,
         ' ' 'ZTITIVK-ZTERM'   EKKO-ZTERM,
*         ' ' 'ZTITIVK-PKCHG'   '',
*         ' ' 'ZTITIVK-HDCHG'   '',
*         ' ' 'ZTITIVK-OTCHG'   '',
*         ' ' 'ZTITIVK-ZLSPR'   'M',
*         ' ' 'ZTITIVK-RTCHG'   '',
*         ' ' 'ZTITIVK-ZLSCH'   'C',
         ' ' 'ZTITIVK-XBLNR'   ZTITBLK-BLNUM,
         ' ' 'ZTITIVK-BKTXT'   '수입물대금액',
         ' ' 'ZTITIVK-SGTXT'   ZTITBLK-BLNUM.
*ZTISIVIT-SGTXT(01)
*ZTISIVIT-SGTXT(02)
*> 자동생성일 경우.
  IF ZTITIG00-IVPBL EQ 'A' AND
     OK_CODE_OLD    EQ 'ZTIPOST'.
    PERFORM BDC_DYNPRO_BUILD USING :
         ' ' 'BDC_OKCODE'       '=ZTISAVE'.

    PERFORM BDC_DYNPRO_BUILD USING :
           'X' 'SAPLSPO1'         '0300',
           ' ' 'BDC_OKCODE'       '=YES'.
  ENDIF.
*
  SET PARAMETER ID 'ZTIIVONO'  FIELD SPACE.

  PERFORM BDC_TRANSACTION USING 'ZTIT301' L_SUBRC.

  GET PARAMETER ID 'ZTIIVONO'  FIELD ZTITBLK-IVONO.

  IF L_SUBRC           EQ 0         AND
     NOT ZTITBLK-IVONO IS INITIAL.
    MESSAGE S313 WITH ZTITBLK-IVONO.
    PERFORM SET_RETURN_MESSAGE_FILL USING SY-MSGTY.
    MODIFY ZTITBLK.
  ELSE.
*    LOOP AT messtab WHERE msgtyp EQ 'E'.
*      MOVE : messtab-msgtyp  TO it_msg-msgty,
*             messtab-msgid   TO it_msg-msgid,
*             messtab-msgnr   TO it_msg-msgno,
*             messtab-msgv1   TO it_msg-msgv1,
*             messtab-msgv2   TO it_msg-msgv2,
*             messtab-msgv3   TO it_msg-msgv3,
*             messtab-msgv4   TO it_msg-msgv4,
*             ZTITBLK-iblno  TO it_msg-refno.
*      APPEND it_msg.
*    ENDLOOP.
*    IF sy-subrc NE 0.
*      MESSAGE s926.
*      MOVE:  sy-msgid       TO  it_msg-msgid,
*             'E'            TO  it_msg-msgty,
*             sy-msgno       TO  it_msg-msgno,
*             sy-msgv1       TO  it_msg-msgv1,
*             sy-msgv2       TO  it_msg-msgv2,
*             sy-msgv3       TO  it_msg-msgv3,
*             sy-msgv4       TO  it_msg-msgv4,
*             ZTITBLK-iblno TO  it_msg-refno.
*      APPEND it_msg.
*    ENDIF.
  ENDIF.

*  DESCRIBE TABLE it_msg LINES g_line.
*  IF g_line GT 0.
*    CALL FUNCTION 'Z_TI_POPUP_TO_ERROR_MESSAGE'
*      EXPORTING
*        xdocno_show = ' '
*      TABLES
*        xmsg        = it_msg.
*  ENDIF.
*
ENDFORM.                    " create_invoice_document

*******************************NEW VERSION******************************
*&---------------------------------------------------------------------*
*&      Form  p1001_initialization
*&---------------------------------------------------------------------*
FORM P1001_INITIALIZATION .

  SET TITLEBAR 'T1000' WITH 'Due List'(T10).


ENDFORM.                    " p1001_initialization
*&---------------------------------------------------------------------*
*&      Form  p1100_check_input_values
*&---------------------------------------------------------------------*
FORM P1100_CHECK_INPUT_VALUES .
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

ENDFORM.                    " p1100_check_input_values
*&---------------------------------------------------------------------*
*&      Form  p2000_data_selections
*&---------------------------------------------------------------------*
FORM P2000_DATA_SELECTIONS .

  DATA: L_RQMNG  LIKE ZTITRQP-RQMNG.

  DATA : LT_EKES LIKE TABLE OF EKES WITH HEADER LINE .

  CLEAR: G_COUNT, IT_TABH, IT_ZTITIG02, IT_HEADER, IT_LIST.
  REFRESH : IT_TABH, IT_ZTITIG02, IT_HEADER, IT_LIST.
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

*> 수입의뢰 데이타 select.


  IF S_VBELN[] IS INITIAL.

    SELECT *
          INTO CORRESPONDING FIELDS OF TABLE IT_TABH
          FROM ZTIVRQ00 AS A
          WHERE A~BUKRS  IN S_BUKRS  "회사코드.
            AND A~REQNO  IN S_REQNO  "수입의뢰 관리번호.
            AND A~AMDSQ  IN S_AMDSQ  "Amend 차수
            AND A~REQTY  IN S_REQTY  "수입의뢰 종류.
            AND A~ILCTY  IN S_ILCTY  "신용장 종류.
            AND A~LIFNR  IN S_LIFNR  "공급업체 계정번호.
            AND A~LIFRE  IN S_LIFRE  "다른 송장발행처.
            AND A~OFFER  IN S_OFFER  "오퍼상(Offer).
            AND A~OPNBK  IN S_OPNBK  "개설은행.
            AND A~EKORG  IN S_EKORG  "구매조직.
            AND A~EKGRP  IN S_EKGRP  "구매그룹.
            AND A~APPCT  IN S_APPCT  "수입자 구분.
            AND A~OPNNO  IN S_OPNNO  "수입개설번호
            AND A~OPNDT  IN S_OPNDT  "개설일자.
            AND A~ZTERM  IN S_ZTERM  "지급조건키.
            AND A~WAERS  IN S_WAERS  "개설통화.
            AND A~INCO1  IN S_INCO1  "인도조건 (파트 1).
            AND A~INCO2  IN S_INCO2  "인도조건 (파트 2).
            AND A~EXDAT  IN S_EXDAT  "COM:유효기일.
            AND A~LSDAT  IN S_LSDAT  "COM:최종선적일자.
            AND A~EDIYN  IN S_EDIYN  "EDI 적용여부.
            AND A~INSYN  IN S_INSYN  "적하보험대상여부.
            AND A~FWDTY  IN S_FWDTY  "운송 방법.
            AND A~FLAND  IN S_FLAND  "선적국가.
            AND A~FPORT  IN S_FPORT  "선적항.
            AND A~PLLOD  IN S_PLLOD  "COM:선적항.
            AND A~TLAND  IN S_TLAND  "도착국가.
            AND A~TPORT  IN S_TPORT  "도착항.
            AND A~PLTRN  IN S_PLTRN  "COM:도착항.
            AND A~REQDT  IN S_REQDT  "개설희망일자.
            AND A~APPUN  IN S_APPUN  "개설의뢰 요청자.
            AND A~APPDT  IN S_APPDT  "개설의뢰 요청일.
            AND A~APPTM  IN S_APPTM  "개설의뢰 요청시간.
            AND A~ACCUN  IN S_ACCUN  "요청접수 담당자.
            AND A~ACCDT  IN S_ACCDT  "요청접수일자.
            AND A~ACCTM  IN S_ACCTM  "요청접수시간.
            AND A~SNDUN  IN S_SNDUN  "개설신청자.
            AND A~SNDDT  IN S_SNDDT  "개설신청일.
            AND A~SNDTM  IN S_SNDTM  "개설신청시간.
            AND A~RCVUN  IN S_RCVUN  "개설등록자.
            AND A~RCVDT  IN S_RCVDT  "개설등록일자.
            AND A~RCVTM  IN S_RCVTM  "개설등록시간.
            AND A~RECID  IN S_RECID  "수신자 ID.
            AND A~RECNM  IN S_RECNM  "수신자 명.
            AND A~RECNO  IN S_RECNO  "문서번호.
            AND A~DOCST  IN S_DOCST  "문서상태.
            AND A~REQIT  IN S_REQIT  "수입의뢰 품목번호.
            AND A~EBELN  IN S_EBELN  "구매전표번호.
            AND A~EBELP  IN S_EBELP  "구매문서 품목번호.
            AND A~CNAM   IN S_CNAM   "작성인.
            AND A~CDAT   IN S_CDAT   "생성일.
            AND A~CTME   IN S_CTME   "생성시간.
            AND A~UNAM   IN S_UNAM   "최종변경인.
            AND A~UDAT   IN S_UDAT   "변경일.
            AND A~UTME   IN S_UTME   "최종변경시간.
            AND A~DCEND  EQ SPACE    "종료지시자.
            AND A~ANBTY  NE C_CHARA  ">사후건 제외시킴.
*>        수입의뢰 종류 중 LO/PU제외.
            AND A~REQTY  NE 'PU'
            AND A~REQTY  NE 'LO'
            AND A~EBELN  <> '4504428455'. "--> 예외처리


  ELSE.

    SELECT * INTO CORRESPONDING FIELDS OF TABLE LT_EKES
      FROM EKES
     WHERE VBELN  IN S_VBELN.

    IF LT_EKES[] IS NOT INITIAL.
      SELECT *
         INTO CORRESPONDING FIELDS OF TABLE IT_TABH
         FROM ZTIVRQ00 AS A FOR ALL ENTRIES IN LT_EKES
         WHERE A~EBELN   EQ LT_EKES-EBELN
           AND A~EBELP   EQ LT_EKES-EBELP
           AND A~BUKRS  IN S_BUKRS  "회사코드.
           AND A~REQNO  IN S_REQNO  "수입의뢰 관리번호.
           AND A~AMDSQ  IN S_AMDSQ  "Amend 차수
           AND A~REQTY  IN S_REQTY  "수입의뢰 종류.
           AND A~ILCTY  IN S_ILCTY  "신용장 종류.
           AND A~LIFNR  IN S_LIFNR  "공급업체 계정번호.
           AND A~LIFRE  IN S_LIFRE  "다른 송장발행처.
           AND A~OFFER  IN S_OFFER  "오퍼상(Offer).
           AND A~OPNBK  IN S_OPNBK  "개설은행.
           AND A~EKORG  IN S_EKORG  "구매조직.
           AND A~EKGRP  IN S_EKGRP  "구매그룹.
           AND A~APPCT  IN S_APPCT  "수입자 구분.
           AND A~OPNNO  IN S_OPNNO  "수입개설번호
           AND A~OPNDT  IN S_OPNDT  "개설일자.
           AND A~ZTERM  IN S_ZTERM  "지급조건키.
           AND A~WAERS  IN S_WAERS  "개설통화.
           AND A~INCO1  IN S_INCO1  "인도조건 (파트 1).
           AND A~INCO2  IN S_INCO2  "인도조건 (파트 2).
           AND A~EXDAT  IN S_EXDAT  "COM:유효기일.
           AND A~LSDAT  IN S_LSDAT  "COM:최종선적일자.
           AND A~EDIYN  IN S_EDIYN  "EDI 적용여부.
           AND A~INSYN  IN S_INSYN  "적하보험대상여부.
           AND A~FWDTY  IN S_FWDTY  "운송 방법.
           AND A~FLAND  IN S_FLAND  "선적국가.
           AND A~FPORT  IN S_FPORT  "선적항.
           AND A~PLLOD  IN S_PLLOD  "COM:선적항.
           AND A~TLAND  IN S_TLAND  "도착국가.
           AND A~TPORT  IN S_TPORT  "도착항.
           AND A~PLTRN  IN S_PLTRN  "COM:도착항.
           AND A~REQDT  IN S_REQDT  "개설희망일자.
           AND A~APPUN  IN S_APPUN  "개설의뢰 요청자.
           AND A~APPDT  IN S_APPDT  "개설의뢰 요청일.
           AND A~APPTM  IN S_APPTM  "개설의뢰 요청시간.
           AND A~ACCUN  IN S_ACCUN  "요청접수 담당자.
           AND A~ACCDT  IN S_ACCDT  "요청접수일자.
           AND A~ACCTM  IN S_ACCTM  "요청접수시간.
           AND A~SNDUN  IN S_SNDUN  "개설신청자.
           AND A~SNDDT  IN S_SNDDT  "개설신청일.
           AND A~SNDTM  IN S_SNDTM  "개설신청시간.
           AND A~RCVUN  IN S_RCVUN  "개설등록자.
           AND A~RCVDT  IN S_RCVDT  "개설등록일자.
           AND A~RCVTM  IN S_RCVTM  "개설등록시간.
           AND A~RECID  IN S_RECID  "수신자 ID.
           AND A~RECNM  IN S_RECNM  "수신자 명.
           AND A~RECNO  IN S_RECNO  "문서번호.
           AND A~DOCST  IN S_DOCST  "문서상태.
           AND A~REQIT  IN S_REQIT  "수입의뢰 품목번호.
           AND A~EBELN  IN S_EBELN  "구매전표번호.
           AND A~EBELP  IN S_EBELP  "구매문서 품목번호.
           AND A~CNAM   IN S_CNAM   "작성인.
           AND A~CDAT   IN S_CDAT   "생성일.
           AND A~CTME   IN S_CTME   "생성시간.
           AND A~UNAM   IN S_UNAM   "최종변경인.
           AND A~UDAT   IN S_UDAT   "변경일.
           AND A~UTME   IN S_UTME   "최종변경시간.
           AND A~DCEND  EQ SPACE    "종료지시자.
           AND A~ANBTY  NE C_CHARA  ">사후건 제외시킴.
*>        수입의뢰 종류 중 LO/PU제외.
           AND A~REQTY  NE 'PU'
           AND A~REQTY  NE 'LO'
           AND A~EBELN  <> '4504428455'. "--> 예외처리

    ENDIF.
*-- [기능개선 ______]  인바운드 납품문서 조건추가 -[e]

  ENDIF.


***>        구매오더중 서비스제외.
*2004.01.14 inserted by ab_spacekan.
  DATA:  BEGIN  OF  ST_EKKO.
  DATA: EBELN  LIKE  EKKO-EBELN,
        BSART  LIKE  EKKO-BSART,
      END  OF  ST_EKKO.

*


  SORT LT_EKES BY EBELN EBELP.

  LOOP AT IT_TABH.

    SELECT SINGLE EBELN BSART INTO ST_EKKO
    FROM EKKO WHERE EBELN = IT_TABH-EBELN.
    IF ST_EKKO-BSART EQ 'S2'.
      DELETE IT_TABH INDEX SY-TABIX.
    ENDIF.

*-- [기능개선 ______]  인바운드 납품문서 조건추가 -[s]
    READ TABLE LT_EKES WITH KEY EBELN = IT_TABH-EBELN
                                EBELP = IT_TABH-EBELP
                                BINARY SEARCH.
    IF SY-SUBRC EQ 0.
      IT_TABH-VBELN = LT_EKES-VBELN .
      MODIFY IT_TABH TRANSPORTING VBELN .
    ENDIF.
*-- [기능개선 ______]  인바운드 납품문서 조건추가 -[e]

  ENDLOOP.

  CLEAR ST_EKKO.
*2004.01.14 inserted by ab_spacekan.

  IF SY-SUBRC NE 0.
    EXIT.
*    MESSAGE s902.
  ENDIF.

  CLEAR: G_TABIX, G_COUNT, G_CNT.
  LOOP AT IT_TABH.

    G_TABIX = SY-TABIX.

    IF IT_TABH-REQTY EQ 'TT'.
      IF ( IT_TABH-PPAID EQ 'X' ) OR ( IT_TABH-RPAID EQ 'X').
        DELETE IT_TABH INDEX G_TABIX.
        CONTINUE.
      ENDIF.
    ENDIF.

    SELECT  SINGLE MENGE WERKS MATNR TXZ01 MATKL
      INTO  (IT_TABH-MENGE, IT_TABH-WERKS, IT_TABH-MATNR,
             IT_TABH-TXZ01, IT_TABH-MATKL)
      FROM  EKPO
     WHERE  EBELN  = IT_TABH-EBELN
       AND  EBELP  = IT_TABH-EBELP.
    IF NOT IT_TABH-MATKL IN S_MATKL[].
      DELETE IT_TABH INDEX G_TABIX.
      CONTINUE.
    ENDIF.

*   domain의 value.
    PERFORM GET_DOMAIN_VALUE_TEXT(ZTIR0000) USING :
                          'ZTIDOCST'  IT_TABH-DOCST  IT_TABH-DOCSTX,
                          'ZTIILCTY'  IT_TABH-ILCTY  IT_TABH-ILCTYX.

*   공급업체등/다른 송장발행처/오퍼상(Offer) lifnr/lifre/offer
    SELECT SINGLE NAME1 INTO IT_TABH-NAME1
      FROM LFA1
     WHERE LIFNR EQ IT_TABH-LIFNR.

    SELECT SINGLE NAME1 INTO IT_TABH-NAME4
      FROM LFA1
     WHERE LIFNR EQ IT_TABH-OFFER.
*   개설은행  opnbk
    SELECT SINGLE NAMET INTO IT_TABH-NAMET
      FROM ZTSTIG3
     WHERE EPART EQ IT_TABH-OPNBK.
*   수입의뢰 수량, 누적수량, 가능수량, p/o수량.

*   누적수량.
    SELECT  SUM( BLMNG )
      INTO  IT_TABH-BLMNGS
      FROM  ZTIVBL00
     WHERE  REQNO  = IT_TABH-REQNO
       AND  REQIT  = IT_TABH-REQIT.
*   가능수량.
    IT_TABH-BLMNGL =  IT_TABH-RQMNG - IT_TABH-BLMNGS.

    IF IT_TABH-BLMNGL LE 0.
      DELETE IT_TABH INDEX G_TABIX.
      CONTINUE.
    ENDIF.

    ADD 1 TO G_COUNT.

    MOVE 1 TO IT_TABH-COUNT.

    MODIFY IT_TABH INDEX G_TABIX.
  ENDLOOP.

  IF G_COUNT EQ 0.
    EXIT.
*    MESSAGE s103.
  ENDIF.

ENDFORM.                    " p2000_data_selections
*&---------------------------------------------------------------------*
*&      Form  p2100_header_and_list_build
*&---------------------------------------------------------------------*
FORM P2100_HEADER_AND_LIST_BUILD .

*  LOOP AT it_tabh.
*    MOVE-CORRESPONDING it_tabh TO : it_header, it_list.
*    COLLECT : it_header.
*    APPEND    it_list.
*  ENDLOOP.

**************************************************************
* 20070328 simcho by 박혁세K
* 헤더환율 collect오류 수정
**************************************************************
  LOOP AT IT_TABH.

    MOVE-CORRESPONDING IT_TABH TO : IT_HEADER, IT_LIST.

    IF SY-TABIX >= 2.
      IT_HEADER-WKURS = 0.
    ENDIF.
    COLLECT : IT_HEADER.
    APPEND    IT_LIST.

  ENDLOOP.


ENDFORM.                    " p2100_header_and_list_build
*&---------------------------------------------------------------------*
*&      Form  p2101_adjust_header_amount
*&---------------------------------------------------------------------*
FORM P2101_ADJUST_HEADER_AMOUNT .
  LOOP AT IT_HEADER.
    IT_HEADER-OPAMT = IT_HEADER-OPAMT / IT_HEADER-COUNT.
    MODIFY IT_HEADER.
  ENDLOOP.
ENDFORM.                    " p2101_adjust_header_amount

*&---------------------------------------------------------------------*
*&      Form  3000_field_category_build
*&---------------------------------------------------------------------*
FORM 3000_FIELD_CATEGORY_BUILD .
*----------------------------------------------------------------------*
* 필드명과 Output Length등을 사용자의 입맛에 맞게 바꿈.
*----------------------------------------------------------------------*
  PERFORM 3010_FILL_FIELD_CATEGORY USING :
*>>>>>>HEADER
*"BOX.
*          'S' 'TABNAME'       'IT_HEADER',
*          ' ' 'REF_TABNAME'   ' ',
*          ' ' 'FIELDNAME'     'BOX',
*          ' ' 'HOTSPOT'       ' ',       " Double Click 효과
*          'E' 'KEY'           ' ',
"수입의뢰 관리번호
          'S' 'TABNAME'       'IT_HEADER',
          ' ' 'REF_TABNAME'   'ZTITRQK',
*          ' ' 'seltext_m'     'HEADER Middle TEXT(20)',
          ' ' 'FIELDNAME'     'REQNO',
          ' ' 'HOTSPOT'       'X',       " Double Click 효과
          ' ' 'KEY'           'X',
          'E' 'OUTPUTLEN'     '12',
"Amend 차수
          'S' 'TABNAME'       'IT_HEADER',
          ' ' 'REF_TABNAME'   'ZTITRQS',
          ' ' 'seltext_m'     'AMEND',
          ' ' 'FIELDNAME'     'AMDSQ',
          ' ' 'JUST'          C_CHARL,
          ' ' 'LZERO'         C_CHARX,
          ' ' 'HOTSPOT'       'X',       " Double Click 효과
          ' ' 'KEY'           'X',
          'E' 'OUTPUTLEN'     '12',
"문서상태
          'S' 'TABNAME'       'IT_HEADER',
*          ' ' 'REF_TABNAME'   'ZTITRQS',
          ' ' 'seltext_m'     '문서상태',
          ' ' 'FIELDNAME'     'DOCSTX',
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
          ' ' 'OUTPUTLEN'     25,
          'E' 'FIELDNAME'     'NAME1',

"유효기일
          'S' 'TABNAME'       'IT_HEADER',
          ' ' 'REF_TABNAME'   'ZTITRQS',
          ' ' 'JUST'          C_CHARR," (R)ight (L)eft (C)ent.
          ' ' 'LZERO'         C_CHARX,
*          ' ' 'seltext_m'     '종류',
          ' ' 'FIELDNAME'     'EXDAT',
          'E' 'OUTPUTLEN'     '13',

"최종선적일자
          'S' 'TABNAME'       'IT_HEADER',
          ' ' 'REF_TABNAME'   'ZTITRQS',
          ' ' 'JUST'          C_CHARR," (R)ight (L)eft (C)ent.
          ' ' 'LZERO'         C_CHARX,
*          ' ' 'seltext_m'     '종류',
          ' ' 'FIELDNAME'     'LSDAT',
          'E' 'OUTPUTLEN'     '13',

"수입의뢰 종류
          'S' 'TABNAME'       'IT_HEADER',
          ' ' 'REF_TABNAME'   'ZTITRQK',
          ' ' 'seltext_m'     '종류',
          ' ' 'NO_OUT'        'X',
          ' ' 'FIELDNAME'     'REQTY',
          'E' 'OUTPUTLEN'     '4',
"신용장 종류 TEXT
          'S' 'TABNAME'       'IT_HEADER',
          ' ' 'REF_TABNAME'   'ZTITRQK',
          ' ' 'seltext_m'     '신용장 종류',
          ' ' 'NO_OUT'        'X',
          ' ' 'FIELDNAME'     'ILCTYX',
          'E' 'OUTPUTLEN'     '13',
"수입개설번호
          'S' 'TABNAME'       'IT_HEADER',
          ' ' 'REF_TABNAME'   'ZTITRQS',
          ' ' 'FIELDNAME'     'OPNNO',
*          ' ' 'NO_OUT'        'X',
          'E' 'OUTPUTLEN'     '17',
"회사코드
          'S' 'TABNAME'       'IT_HEADER',
          ' ' 'REF_TABNAME'   'ZTITRQK',
          ' ' 'FIELDNAME'     'BUKRS',
          ' ' 'NO_OUT'        'X',
          'E' 'OUTPUTLEN'     '4',
"개설일자
          'S' 'TABNAME'       'IT_HEADER',
          ' ' 'REF_TABNAME'   'ZTITRQS',
          ' ' 'FIELDNAME'     'OPNDT',
          ' ' 'NO_OUT'        'X',
          'E' 'OUTPUTLEN'     '10',
"개설은행.
          'S' 'TABNAME'       'IT_HEADER',
*          ' ' 'REF_TABNAME'   'LFA1',
          ' ' 'seltext_m'     '개설은행',
          ' ' 'FIELDNAME'     'NAMET',
          ' ' 'NO_OUT'        'X',
          'E' 'OUTPUTLEN'     '15',

"Offer상
          'S' 'TABNAME'       'IT_HEADER',
*          ' ' 'REF_TABNAME'   'LFA1',
          ' ' 'seltext_m'     'Offer상',
          ' ' 'FIELDNAME'     'NAME4',
          ' ' 'NO_OUT'        'X',
          'E' 'OUTPUTLEN'     '15',
"개설통화
          'S' 'TABNAME'       'IT_HEADER',
          ' ' 'REF_TABNAME'   'ZTITRQS',
          ' ' 'FIELDNAME'     'WAERS',
          ' ' 'NO_OUT'        'X',
          'E' 'OUTPUTLEN'     '4',
"개설금액.
          'S' 'TABNAME'       'IT_HEADER',
          ' ' 'REF_TABNAME'   'ZTITRQS',
          ' ' 'FIELDNAME'     'OPAMT',
          ' ' 'CFIELDNAME'    'WAERS',
          ' ' 'NO_OUT'        'X',
          'E' 'CTABNAME'      'IT_HEADER',
*          ' ' 'OUTPUTLEN'     '10',
*>>>>>>>>>LIST
"BOX.
          'S' 'TABNAME'       'IT_LIST',
          ' ' 'REF_TABNAME'   ' ',
          ' ' 'FIELDNAME'     'BOX',
          ' ' 'HOTSPOT'       ' ',       " Double Click 효과
          'E' 'KEY'           ' ',

"수입의뢰 품목번호.
          'S' 'TABNAME'       'IT_LIST',
          ' ' 'REF_TABNAME'   'ZTITRQP',
          ' ' 'FIELDNAME'     'REQIT',
          ' ' 'JUST'          C_CHARL," (R)ight (L)eft (C)ent.
          ' ' 'LZERO'         C_CHARX,
          ' ' 'HOTSPOT'       'X',       " Double Click 효과
          ' ' 'KEY'           'X',
          'E' 'OUTPUTLEN'     '12',
"구매전표번호.
          'S' 'TABNAME'       'IT_LIST',
          ' ' 'REF_TABNAME'   'ZTITRQP',
          ' ' 'FIELDNAME'     'EBELN',
          ' ' 'HOTSPOT'       'X',       " Double Click 효과
          ' ' 'KEY'           ' ',
          'E' 'OUTPUTLEN'     '12',
"구매문서 품목번호.
          'S' 'TABNAME'       'IT_LIST',
          ' ' 'REF_TABNAME'   'ZTITRQP',
          ' ' 'FIELDNAME'     'EBELP',
          ' ' 'JUST'          C_CHARL," (R)ight (L)eft (C)ent.
          ' ' 'LZERO'         C_CHARX,
          ' ' 'HOTSPOT'       ' ',       " Double Click 효과
          ' ' 'KEY'           ' ',
          'E' 'OUTPUTLEN'     '10',
"자재그룹.
          'S' 'TABNAME'       'IT_LIST',
          ' ' 'REF_TABNAME'   'EKPO',
          ' ' 'FIELDNAME'     'MATKL',
          ' ' 'NO_OUT'        'X',
          'E' 'OUTPUTLEN'     '18',
"자재.
          'S' 'TABNAME'       'IT_LIST',
          ' ' 'REF_TABNAME'   'ZTISRQIT',
          ' ' 'FIELDNAME'     'MATNR',
          'E' 'OUTPUTLEN'     '20',
"자재내역.
          'S' 'TABNAME'       'IT_LIST',
          ' ' 'REF_TABNAME'   'ZTISRQIT',
          ' ' 'FIELDNAME'     'TXZ01',
          'E' 'OUTPUTLEN'     '25',

"P/O 수량
          'S' 'TABNAME'       'IT_LIST',
          ' ' 'REF_TABNAME'   'EKPO',
          ' ' 'seltext_L'     'P/O 수량',
          ' ' 'seltext_m'     'P/O 수량',
          ' ' 'seltext_S'     'P/O 수량',
          ' ' 'QFIELDNAME'    'MEINS',
          ' ' 'QTABNAME'      'IT_LIST',
          ' ' 'NO_OUT'        'X',
          ' ' 'FIELDNAME'     'MENGE',
          ' ' 'OUTPUTLEN'     '13',
          'E' 'KEY'           ' ',
"수입의뢰수량
          'S' 'TABNAME'       'IT_LIST',
          ' ' 'REF_TABNAME'   'ZTITRQP',
          ' ' 'QFIELDNAME'    'MEINS',
          ' ' 'QTABNAME'      'IT_LIST',
          ' ' 'JUST'          C_CHARR," (R)ight (L)eft (C)ent.
          ' ' 'LZERO'         C_CHARX,
          ' ' 'FIELDNAME'     'RQMNG',
          ' ' 'OUTPUTLEN'     '13',
          'E' 'KEY'           ' ',

"B/L 가능 수량
          'S' 'TABNAME'       'IT_LIST',
          ' ' 'REF_TABNAME'   'ZTISBLIT',
          ' ' 'QFIELDNAME'    'MEINS',
          ' ' 'seltext_L'     'B/L가능수량',
          ' ' 'seltext_m'     'B/L가능수량',
          ' ' 'seltext_S'     'B/L가능수량',
          ' ' 'QTABNAME'      'IT_LIST',
          ' ' 'JUST'          C_CHARR," (R)ight (L)eft (C)ent.
          ' ' 'LZERO'         C_CHARX,
          ' ' 'OUTPUTLEN'     '13',
          ' ' 'FIELDNAME'     'BLMNGL',
          'E' 'KEY'           ' ',

"B/L 누적수량
          'S' 'TABNAME'       'IT_LIST',
          ' ' 'REF_TABNAME'   'ZTISBLIT',
          ' ' 'QFIELDNAME'    'MEINS',
          ' ' 'QTABNAME'      'IT_LIST',
          ' ' 'NO_OUT'        'X',
          ' ' 'seltext_L'     'B/L누적수량',
          ' ' 'seltext_m'     'B/L누적수량',
          ' ' 'seltext_S'     'B/L누적수량',
          ' ' 'OUTPUTLEN'     '13',
          ' ' 'FIELDNAME'     'BLMNGS',
          'E' 'KEY'           ' ',
"기본단위
          'S' 'TABNAME'       'IT_LIST',
          ' ' 'REF_TABNAME'   'ZTITRQP',
          ' ' 'FIELDNAME'     'MEINS',
          'E' 'OUTPUTLEN'     '4'.

*-- [기능개선 ______]  인바운드 납품문서 필드 추가  -[s]
  IF S_VBELN[] IS NOT INITIAL.

    PERFORM 3010_FILL_FIELD_CATEGORY USING :

    'S' 'TABNAME'       'IT_LIST',
    ' ' 'REF_TABNAME'   'EKES',
*          ' ' 'NO_OUT'        'X',
    ' ' 'seltext_L'     '인바운드납품',
    ' ' 'seltext_m'     '인바운드납품',
    ' ' 'seltext_S'     '인바운드납품',
    ' ' 'OUTPUTLEN'     '12',
    ' ' 'FIELDNAME'     'VBELN',
    'E' 'KEY'           ' '.


*          'S' 'TABNAME'       'IT_LIST',
*          ' ' 'REF_TABNAME'   'EKES',
*          ' ' 'NO_OUT'        'X',
*          ' ' 'seltext_L'     '인바운드품목',
*          ' ' 'seltext_m'     '인바운드품목',
*          ' ' 'seltext_S'     '인바운드품목',
*          ' ' 'OUTPUTLEN'     '12',
*          ' ' 'FIELDNAME'     'VBELP',
*          'E' 'KEY'           ' ',
  ENDIF.
*-- [기능개선 ______]  인바운드 납품문서 필드 추가  -[e]

  PERFORM 3010_FILL_FIELD_CATEGORY USING :
"작성인
        'S' 'TABNAME'       'IT_LIST',
        ' ' 'REF_TABNAME'   'ZTITRQS',
        ' ' 'FIELDNAME'     'CNAM',
        ' ' 'NO_OUT'        'X',
        'E' 'OUTPUTLEN'     '10',

"변경인
        'S' 'TABNAME'       'IT_LIST',
        ' ' 'REF_TABNAME'   'ZTITRQS',
        ' ' 'FIELDNAME'     'UNAM',
        ' ' 'NO_OUT'        'X',
        'E' 'OUTPUTLEN'     '10'.


ENDFORM.                    " 3000_field_category_build
*&---------------------------------------------------------------------*
*&      Form  3100_set_color_infomation
*&---------------------------------------------------------------------*
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
  ENDLOOP.

ENDFORM.                    " 3100_set_color_infomation
*&---------------------------------------------------------------------*
*&      Form  3200_key_infomation_build
*&---------------------------------------------------------------------*
FORM 3200_KEY_INFOMATION_BUILD .
  CLEAR GS_KEYINFO.

  GS_KEYINFO-HEADER01 = 'REQNO'.
  GS_KEYINFO-ITEM01   = 'REQNO'.

  GS_KEYINFO-HEADER02 = 'AMDSQ'.
  GS_KEYINFO-ITEM02   = 'AMDSQ'.

  GS_KEYINFO-HEADER03 =  SPACE.
  GS_KEYINFO-ITEM03   = 'REQIT'.
ENDFORM.                    " 3200_key_infomation_build
*&---------------------------------------------------------------------*
*&      Form  3300_event_exit_table_build
*&---------------------------------------------------------------------*
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
FORM 3400_COMMENT_BUILD .

  DATA: L_TEXT20(20) TYPE C.

  CLEAR: IT_LISTHEADER, GS_LISTHEADER.
  REFRESH: IT_LISTHEADER.

* LIST HEADING LINE: TYPE H
  CLEAR GS_LISTHEADER.
  GS_LISTHEADER-TYP  = 'H'.
* gs_listheader-KEY:  NOT USED FOR THIS TYPE
  GS_LISTHEADER-INFO = 'B/L Due List'(T13).
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

ENDFORM.                    " 3400_comment_build
*&---------------------------------------------------------------------*
*&      Form  3500_sort_table_build
*&---------------------------------------------------------------------*
FORM 3500_SORT_TABLE_BUILD .

  DATA: LS_SORT TYPE SLIS_SORTINFO_ALV.

  CLEAR LS_SORT.
  LS_SORT-SPOS      = 1.
  LS_SORT-FIELDNAME = 'REQNO'.
  LS_SORT-TABNAME   = 'IT_LIST'.
  LS_SORT-UP        = 'X'.
* LS_SORT-GROUP     = '*'.             " Seiten- bei Gruppenwechsel
*  ls_sort-group     = 'UL'.            " Underline      -"-
  APPEND LS_SORT TO IT_SORT.

ENDFORM.                    " 3500_sort_table_build
*&---------------------------------------------------------------------*
*&      Form  3600_event_table_build
*&---------------------------------------------------------------------*
FORM 3600_EVENT_TABLE_BUILD  USING   P_NAME.

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
FORM 3700_LAYOUT_BUILD .
  MOVE: 'BOX'        TO GS_LAYOUT-BOX_FIELDNAME,
        'IT_LIST'  TO GS_LAYOUT-BOX_TABNAME.
ENDFORM.                    " 3700_layout_build
*&---------------------------------------------------------------------*
*&      Form  3910_call_alv_hierseq
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

ENDFORM.                    " 3910_call_alv_hierseq
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
*---------------------------------------------------------------------*
*       FORM PF_STATUS_SET                                            *
*---------------------------------------------------------------------*
FORM PF_STATUS_SET USING RT_EXTAB TYPE SLIS_T_EXTAB.

  SET TITLEBAR 'T1000' WITH 'Due List'(T10).

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

*-[] 엠트론 한정 BL 양식 업로드 기능 추가
  IF S_BUKRS-LOW NE '3000'.
    APPEND 'BL_MAP'      TO RT_EXTAB.
    APPEND 'DOWNLOAD'    TO RT_EXTAB.
  ENDIF.


  SET PF-STATUS 'STANDARD ' EXCLUDING RT_EXTAB.
*SET PF-STATUS 'ABCD' OF PROGRAM PROG.

ENDFORM.                    "PF_STATUS_SET
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

  DATA: LS_HEADER        TYPE TY_HEADER,
        LS_LIST          TYPE TY_LIST,
        L_AMDSQ          TYPE ZTIAMDSQ,
        LT_ZTISRQIT_TMP  TYPE T_ZTISRQIT OCCURS 0 WITH HEADER LINE.


  CLEAR: LS_HEADER.

  CASE R_UCOMM.
    WHEN '&REFRESH'.
      PERFORM P9000_DUELIST_REFRESH USING  RS_SELFIELD.

    WHEN 'ZTIT001' OR 'BL_UP'.
      G_TCODE = SY-TCODE.
*>Initialization
***********************************************
* 20070124 박혁세K by simcho
* B/L생성시 long text 저장
***********************************************
      PERFORM  GET_LONGTEXT_DATA.
***********************************************
      PERFORM  P1000_SET_INITIAL_DATA.

      PERFORM  P3000_SET_DATA_OF_SCREEN.

      CLEAR : G_LINE, G_COUNT, G_COUNT_1.
      LOOP AT IT_LIST WHERE BOX EQ 'X'.
        CLEAR: LT_ZTISRQIT_TMP.
        REFRESH: LT_ZTISRQIT_TMP.

        SELECT MAX( AMDSQ )
          INTO L_AMDSQ
          FROM ZTITRQS
         WHERE REQNO EQ IT_LIST-REQNO.

        PERFORM GET_BL_DOCUMENT_DATA TABLES LT_ZTISRQIT_TMP
                                     USING  IT_LIST-REQNO
                                            L_AMDSQ
                                            IT_LIST-REQIT
                                            C_ERROR
                                            C_ERROR.
        ADD 1 TO: G_LINE, G_COUNT.
        ADD 1 TO G_COUNT_1.
        MOVE-CORRESPONDING : LT_ZTISRQIT_TMP TO IT_REQNO,
                             LT_ZTISRQIT_TMP TO IT_ZTISRQIT.
        MOVE: G_COUNT_1                      TO IT_ZTISRQIT-INDEX.
*        COLLECT:  it_reqno.
        APPEND IT_ZTISRQIT.
      ENDLOOP.

      IF G_LINE EQ 0.
        MESSAGE S003(OK). EXIT.
      ENDIF.

      G_TREE_MODE = 'Y'.

      LOOP AT IT_ZTISRQIT.
        CLEAR: G_MODIFY, ZTIVRQ00.
        DESCRIBE TABLE IT_TAB LINES G_COUNT_1.
        PERFORM  GET_AND_CHECK_LC_DATA   USING IT_ZTISRQIT-REQNO
                                               IT_ZTISRQIT-AMDSQ
                                               IT_ZTISRQIT-REQIT
                                               G_MODIFY
                                               ZTIVRQ00
                                               G_COUNT_1
                                               C_ERROR.

        CHECK G_MODIFY EQ C_FALSE.

        PERFORM SET_BILL_OF_LADING_DATA    TABLES IT_TAB
                                           USING  ZTIVRQ00
                                                  ZTITBLK
                                                  IT_ZTISRQIT.
      ENDLOOP.

      DATA : LT_TAB LIKE ZTISBLIT.
      LOOP AT IT_TAB INTO LT_TAB .
        READ TABLE IT_LIST WITH KEY EBELN = LT_TAB-EBELN
                                    EBELP = LT_TAB-EBELP.
        IF SY-SUBRC EQ 0.
          LT_TAB-VBELN_IN = IT_LIST-VBELN.
          MODIFY IT_TAB FROM LT_TAB TRANSPORTING VBELN_IN.
        ENDIF.

      ENDLOOP.

      IF G_MODIFY EQ C_TRUE.
        EXIT.
      ENDIF.
*    >아이템 기타 정보 Read.
      PERFORM SET_OTHERS_FIELDS_BY_ITEMS.
*    >화면상의 Text를 Master Data 등에서 Read.
      PERFORM GET_OTHERS_TEXT_BY_MASTER_DATA.
*    > B/L 금액 체크.
      PERFORM CHECK_OPEN_AMOUNT USING C_TRUE C_TRUE.
*>초기값 Setting
      PERFORM  SET_INITIAL_DATA.
*> Create Class Object.
      PERFORM  BUILD_CLASS_OBJECT.

      IF R_UCOMM EQ 'BL_UP'.
        PERFORM SET_BL_UP_DATA.
      ENDIF.
      CALL SCREEN 2000.

*> 10. Save User setting infomation
      PERFORM  SET_USER_SETTING_STRUCTURE.

      "[기능개선____] 엠트론관련 후속조치
      PERFORM EMTRON_BL_AFTER_EXEC.
      IF R_UCOMM EQ 'BL_UP'.
        EXIT.
      ENDIF.

      PERFORM P9000_DUELIST_REFRESH USING  RS_SELFIELD.

**************************************************************
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

        WHEN 'AMDSQ' OR 'REQNO'.
          SET PARAMETER ID 'ZTIREQNO' FIELD LS_LIST-REQNO.
          SET PARAMETER ID 'ZTIAMDSQ' FIELD LS_LIST-AMDSQ.
          CALL TRANSACTION 'ZTIT003' AND SKIP FIRST SCREEN.

        WHEN 'LIFNR'.
          PERFORM DISPLAY_VENDOR_MASTER(ZTIR0000)
                                          USING LS_LIST-LIFNR
                                                LS_LIST-EKORG.
      ENDCASE.


*-[] BL MAPPING
    WHEN 'BL_MAP'.   "[] 업로드후 기능 추가
      PERFORM SET_MAPPING_DATA .
      PERFORM M9000_DUELIST_REFRESH USING  RS_SELFIELD.
    WHEN OTHERS.
  ENDCASE.

  CLEAR: R_UCOMM.

ENDFORM.                    "USER_COMMAND
*&---------------------------------------------------------------------*
*&      Form  p9000_duelist_refresh
*&---------------------------------------------------------------------*
FORM P9000_DUELIST_REFRESH
                 USING P_SELFIELD TYPE SLIS_SELFIELD.

*> 검색조건에 해당하는 데이타를 Select.
  PERFORM P2000_DATA_SELECTIONS.
*> Header table과 List(Items) table를 만듬.
  PERFORM P2100_HEADER_AND_LIST_BUILD.
  DESCRIBE TABLE IT_TAB LINES G_LINE.
  IF NOT G_LINE IS INITIAL.
    P_SELFIELD-REFRESH = 'X'.
  ELSE.
*> Program 종료.
    PERFORM  P9000_PROGRAM_EXIT.
  ENDIF.

ENDFORM.                    " p9000_duelist_refresh
*&---------------------------------------------------------------------*
*&      Form  get_and_check_ekpo_data
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM GET_AND_CHECK_EKPO_DATA  USING    P_EBELN
                                       P_EBELP
                                       P_MODIFY
                                       P_ZTIVPO00 STRUCTURE ZTIVPO00
                                       P_COUNT.

  CLEAR: P_ZTIVPO00.

  SELECT SINGLE * INTO P_ZTIVPO00
    FROM ZTIVPO00
   WHERE EBELN EQ P_EBELN
     AND EBELP EQ P_EBELP.

  IF SY-SUBRC EQ 0.
*>Vendor 체크.
    IF ZTITBLK-LIFNR     NE P_ZTIVPO00-LIFNR AND
       NOT ZTITBLK-LIFNR IS INITIAL.
      MESSAGE S209 WITH P_ZTIVPO00-LIFNR ZTITBLK-LIFNR.
      P_MODIFY = C_TRUE.
      EXIT.
    ENDIF.
*통화키 체크.
    IF ZTITBLK-WAERS    NE  P_ZTIVPO00-WAERS AND
       P_COUNT           GT  C_ZERO.
      MESSAGE S210 WITH P_ZTIVPO00-WAERS ZTITBLK-WAERS.
      P_MODIFY = C_TRUE.
    ENDIF.
*>기타 체크 로직.

**> Lock Object
*    PERFORM  set_lc_lock_object  USING p_reqno
*                                       p_amdsq
*                                       p_reqit
*                                       c_lock
*                                       c_success
*                                       p_modify.
  ELSE.
    MESSAGE S019(06) WITH P_EBELN.
    P_MODIFY = C_TRUE.
    EXIT.
  ENDIF.

ENDFORM.                    " get_and_check_ekpo_data
*&---------------------------------------------------------------------*
*&      Form  set_bill_of_lading_data_tt
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM SET_BILL_OF_LADING_DATA_TT  TABLES P_IT_TAB   LIKE      IT_TAB
                                 USING  P_ZTIVPO00 STRUCTURE ZTIVPO00
                                        P_ZTITBLK  STRUCTURE ZTITBLK
                                        P_EKPO     STRUCTURE IT_EKPO.
  CLEAR: P_IT_TAB.

  MOVE-CORRESPONDING P_ZTIVPO00 TO : P_IT_TAB, P_ZTITBLK.

  MOVE: P_EKPO-BLMNG  TO P_IT_TAB-BLMNG,
        P_EKPO-BLMNGS TO P_IT_TAB-BLMNGS,
        P_EKPO-BLMNGL TO P_IT_TAB-BLMNGL,
        P_EKPO-REPOS  TO P_IT_TAB-REPOS,
        P_EKPO-WEPOS  TO P_IT_TAB-WEPOS,
        'Y'           TO P_ZTITBLK-APPCT.

  MOVE: SY-UNAME TO P_IT_TAB-CNAM,
        SY-DATLO TO P_IT_TAB-CDAT,
        SY-TIMLO TO P_IT_TAB-CTME,
        SY-UNAME TO P_IT_TAB-UNAM,
        SY-DATLO TO P_IT_TAB-UDAT,
        SY-TIMLO TO P_IT_TAB-UTME.

  SELECT  SUM( BLMNG )
    INTO  P_IT_TAB-BLMNGS
    FROM  ZTIVBL00
   WHERE  EBELN       EQ  P_IT_TAB-EBELN
     AND  EBELP       EQ  P_IT_TAB-EBELP
     AND NOT ( IBLNO  EQ  P_IT_TAB-IBLNO
     AND       IBLIT  EQ  P_IT_TAB-IBLIT ).


*> 초과납품허용치.
  IF NOT P_IT_TAB-UEBTO IS INITIAL.
    P_IT_TAB-BLMNGM = ( P_IT_TAB-MENGE * P_IT_TAB-UEBTO ) / 100.
  ELSE.
    P_IT_TAB-BLMNGM =  0.
  ENDIF.
**> 무제한 납품 허용..
*      IF NOT ZTITBLP-uebtk IS INITIAL.
*
*      ENDIF.
  P_IT_TAB-BLMNGL =  P_IT_TAB-MENGE - P_IT_TAB-BLMNGS.
  P_IT_TAB-BLMNG  =  P_IT_TAB-BLMNGL.

**> 초과납품허용치.
*        if not ZTITBLP-UEBTO is initial.
*           ZTITBLP-rqmng = ZTITBLP-rqmng +
*                          ( ZTITBLP-rqmng * ZTITBLP-UEBTO ) / 100.
*        endif.
*        if not ZTITBLP-UEBTK is initial.
*
*        endif.
*  p_it_tab-blmngl =  p_it_tab-menge - p_it_tab-blmngs.


  IF P_IT_TAB-BLMNGL LE 0.
    P_IT_TAB-BLMNGL = 0.
  ENDIF.

  MOVE C_CHARA  TO P_IT_TAB-NDFTY.

  IF P_IT_TAB-REPOS IS INITIAL.
    MOVE : C_CHARS       TO P_IT_TAB-NDFTY,
           C_TRUE        TO P_IT_TAB-NDFYN.
  ENDIF.

  APPEND P_IT_TAB.

*>아이템 번호를 생성함.
  PERFORM SET_ITEM_NUMBER_BUILD TABLES P_IT_TAB
                                USING  P_ZTITBLK.

  PERFORM GET_OTHERS_TEXT_BY_MASTER_DATA.

ENDFORM.                    " set_bill_of_lading_data_tt
*&---------------------------------------------------------------------*
*&      Form  set_bill_of_lading_data_po
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM SET_BILL_OF_LADING_DATA_PO  TABLES P_IT_TAB   LIKE      IT_TAB
                                 USING  P_ZTIVPO00 STRUCTURE ZTIVPO00
                                        P_ZTITBLK  STRUCTURE ZTITBLK
                                        P_EKPO     STRUCTURE IT_EKPO.
  CLEAR: P_IT_TAB.

  MOVE-CORRESPONDING P_EKPO TO : P_IT_TAB, P_ZTITBLK.

  MOVE: P_EKPO-BLMNG  TO P_IT_TAB-BLMNG,
        P_EKPO-BLMNGS TO P_IT_TAB-BLMNGS,
        P_EKPO-BLMNGL TO P_IT_TAB-BLMNGL,
        P_EKPO-REPOS  TO P_IT_TAB-REPOS,
        P_EKPO-WEPOS  TO P_IT_TAB-WEPOS,
        C_TRUE        TO P_IT_TAB-NDFYN,
        'Y'           TO P_ZTITBLK-APPCT.

  MOVE: SY-UNAME TO P_IT_TAB-CNAM,
        SY-DATLO TO P_IT_TAB-CDAT,
        SY-TIMLO TO P_IT_TAB-CTME,
        SY-UNAME TO P_IT_TAB-UNAM,
        SY-DATLO TO P_IT_TAB-UDAT,
        SY-TIMLO TO P_IT_TAB-UTME.

  MOVE G_NDFTY  TO P_IT_TAB-NDFTY.

  APPEND P_IT_TAB.

*>아이템 번호를 생성함.
  PERFORM SET_ITEM_NUMBER_BUILD TABLES P_IT_TAB
                                USING  P_ZTITBLK.

  PERFORM GET_OTHERS_TEXT_BY_MASTER_DATA.

ENDFORM.                    " set_bill_of_lading_data_po

*&---------------------------------------------------------------------*
*&      Form  set_confirmation_status
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM SET_CONFIRMATION_STATUS USING P_MODE.

  PERFORM  CALL_OTHERS_TRANSACTION  USING   P_MODE
                                            C_DELETE
                                            C_FALSE
                                            C_FALSE.

ENDFORM.                    " set_confirmation_status
*&---------------------------------------------------------------------*
*&      Form  get_longtext_data
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM GET_LONGTEXT_DATA .

*> Partner Text
  PERFORM  P1000_GET_TEXTID_AND_TEXT USING ZTITBLK+3(10)
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

  CALL FUNCTION 'Z_TI_GET_BILL_OF_LADING_QUERY'
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
    WHEN 'ZTICOST'.     ">비용전기.
      PERFORM  POSTING_COST_DOCUMENT.

    WHEN 'ZTISPLIT'.    ">금액분할.
      PERFORM  SET_AMOUNT_SPLIT.

    WHEN 'ZCOTY'.    ">원산지 증명서 일괄입력.
      PERFORM  CALL_ZCOTY.

    WHEN 'ZTIACCEPT'.   ">선적서류 송부.
      PERFORM  CALL_OTHERS_TRANSACTION  USING   C_CHARA
                                                C_DELETE
                                                C_FALSE
                                                C_FALSE.
    WHEN 'ZTIRETURN'.   ">송부 취소.
      PERFORM  CALL_OTHERS_TRANSACTION  USING   C_CHARE
                                                C_DELETE
                                                C_FALSE
                                                C_FALSE.
    WHEN 'ZTIAPPLY'.    ">실입항 입력.
      PERFORM  CALL_OTHERS_TRANSACTION  USING   C_CHAR5
                                                C_DELETE
                                                C_FALSE
                                                C_FALSE.
    WHEN 'ZTIAPPLYC'.   ">실입항 입력 취소.
      PERFORM  CALL_OTHERS_TRANSACTION  USING   C_CHAR6
                                                C_DELETE
                                                C_FALSE
                                                C_FALSE.
    WHEN 'ZTIRECV'.    ">통관요청.
      PERFORM  CALL_OTHERS_TRANSACTION  USING   C_CHARO
                                                C_DELETE
                                                C_FALSE
                                                C_FALSE.
    WHEN 'ZTIRECVC'.   ">통관요청 취소.
      PERFORM  CALL_OTHERS_TRANSACTION  USING   C_CHARN
                                                C_DELETE
                                                C_FALSE
                                                C_FALSE.
    WHEN 'ZTICONFIRM' OR 'ZTICONFIRC'.
      IF OK_CODE EQ 'ZTICONFIRM'.
        PERFORM  SET_CONFIRMATION_STATUS USING C_CHAR3.
      ELSEIF OK_CODE EQ 'ZTICONFIRC'.
        PERFORM  SET_CONFIRMATION_STATUS USING C_CHAR4.
      ENDIF.
    WHEN 'ZTICHDOC'.    ">변경문서.
      G_OBJEKT   = 'ZTIBLCHDOC'.
      G_OBJEKTID = ZTITBLK+3(10).
      PERFORM DISPLAY_CHANGE_DOCUMENT USING G_OBJEKT
                                            G_OBJEKTID.

    WHEN 'ZTIMK03'.     ">공급업체.
      PERFORM DISPLAY_VENDOR_MASTER USING ZTITBLK-LIFNR
                                          ZTITBLK-EKORG.
    WHEN 'ZLINK'.
      PERFORM DISLPAY_URL .


    WHEN OTHERS.
  ENDCASE.

ENDFORM.                    " OTHER_FUNCTIONS

*&---------------------------------------------------------------------*
*&      Form  BEFORE_TRANSPORT_PAI
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM BEFORE_TRANSPORT_PAI .

*> B/L 금액 체크.
  IF G_MODE EQ C_CHARC OR
     G_MODE EQ C_CHARM.
    PERFORM  CHECK_OPEN_AMOUNT USING C_TRUE  C_FALSE.
  ELSE.
    PERFORM  CHECK_OPEN_AMOUNT USING C_FALSE C_FALSE.
  ENDIF.

ENDFORM.                    " BEFORE_TRANSPORT_PAI
*&---------------------------------------------------------------------*
*&      Form  get_total_po_amount
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM GET_TOTAL_PO_AMOUNT TABLES   LT_EKPO  STRUCTURE GT_EKPO
                         USING    P_POAMT.
*******************************************************
* 2006.12.26 원본소스 - BL생성 시스템속도 저하원인
* 해결위한 긴급 수정
*******************************************************
  SELECT EBELN EBELP PEINH BPUMZ BPUMN MENGE NETPR
    INTO CORRESPONDING FIELDS OF TABLE LT_EKPO
    FROM EKPO
     FOR ALL ENTRIES IN IT_TAB
   WHERE EBELN  EQ IT_TAB-EBELN
     AND EBELP  EQ IT_TAB-EBELP.

  CLEAR: P_POAMT.
  LOOP AT LT_EKPO.

    G_TABIX = SY-TABIX.

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
*******************************************************
* 2006.12.26 수정소스 - BL생성 시스템속도 저하원인
* 해결위한 긴급 수정
*******************************************************
*  IF NOT it_tab IS INITIAL.
*    SELECT ebeln ebelp peinh bpumz bpumn menge netpr
*      INTO CORRESPONDING FIELDS OF TABLE lt_ekpo
*      FROM ekpo
*       FOR ALL ENTRIES IN it_tab
*     WHERE ebeln  EQ it_tab-ebeln
*       AND ebelp  EQ it_tab-ebelp.
*
*    CLEAR: p_poamt.
*    LOOP AT lt_ekpo.
*
*      g_tabix = sy-tabix.
*
*      CALL FUNCTION 'Z_TI_CALC_ITEM_AMOUNT'
*        EXPORTING
*          peinh = lt_ekpo-peinh
*          bpumz = lt_ekpo-bpumz
*          bpumn = lt_ekpo-bpumn
*          menge = lt_ekpo-menge
*          netpr = lt_ekpo-netpr
*        CHANGING
*          netwr = lt_ekpo-netwr.
*
*      ADD lt_ekpo-netwr TO p_poamt.
*
*      MODIFY lt_ekpo INDEX g_tabix.
*
*    ENDLOOP.
*  ENDIF.
*******************************************************
* END
*******************************************************

ENDFORM.                    " GET_TOTAL_PO_AMOUNT
*&---------------------------------------------------------------------*
*&      Form  get_total_document_amount
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM GET_TOTAL_DOCUMENT_AMOUNT  USING    P_DCAMT.

  CLEAR: P_DCAMT.

  LOOP AT IT_TAB INTO G_TC_2130_WA.

    G_TABIX = SY-TABIX.

    CALL FUNCTION 'Z_TI_CALC_ITEM_AMOUNT'
      EXPORTING
        PEINH = G_TC_2130_WA-PEINH
        BPUMZ = G_TC_2130_WA-BPUMZ
        BPUMN = G_TC_2130_WA-BPUMN
        MENGE = G_TC_2130_WA-BLMNGL
        NETPR = G_TC_2130_WA-NETPR
      CHANGING
        NETWR = G_TC_2130_WA-NETWR.

    ADD G_TC_2130_WA-NETWR TO P_DCAMT.

  ENDLOOP.

ENDFORM.                    " get_total_document_amount
*&---------------------------------------------------------------------*
*&      Form  prepaid_amount_change_event
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM PREPAID_AMOUNT_CHANGE_EVENT .

  DATA : L_TEXT_EXRATE(255)    TYPE C,
         L_FOREIGN_FACTOR(255) TYPE C,
         L_FACTOR              TYPE P,
         L_RATE                TYPE F,
         L_WRBTR               TYPE WRBTR,
         L_NETWR               TYPE NETWR,
         L_BLMNG               TYPE ZTIBLMNG,
         L_RQMNG               TYPE ZTIRQMNG,
         L_RQMNGQ              TYPE ZTIRQMNG,
         L_PPMNGQ              TYPE ZTIPPMNG,
         L_PPMNGB              TYPE ZTIPPMNG,
         L_PPMNG               TYPE ZTIPPMNG,
         L_PPAMT               TYPE ZTIPPAM2,
         L_PPAMTQ              TYPE ZTIPPAM2,
         L_PPAMTB              TYPE ZTIPPAM2,
         L_PPAMTS              TYPE ZTIPPAM2,
         L_PPAMTD              TYPE ZTIPPAM2,
         L_PPAMTDD             TYPE ZTIPPAM2,
         L_PPAMTSS             TYPE ZTIPPAM2,
         L_PPAM1               TYPE ZTIPPAM2,
         L_FIXED_RATE          LIKE TCURS-SPRED,
         L_LOCAL_AMT           LIKE ZTITRQS-USAMT.  " USD 환산 Amount

  CLEAR: G_WRBTR, G_PPAMT.

  IF ZTITBLK-PPAMT IS INITIAL.
*> Begin of Loop
    LOOP AT IT_TAB INTO G_TC_2130_WA.
      G_TC_2130_WA-PPMNG = 0.
      G_TC_2130_WA-PPAMT = 0.
      MODIFY IT_TAB FROM G_TC_2130_WA.
    ENDLOOP.
*> End of Loop.
  ELSE.
*> 전체구매오더 금액 대비 선급금 금액 비율.
*  l_rate = ZTITBLK-ivamt / ZTIsscrcom-poamt.
*    l_rate = ZTITBLK-ppamt / ZTIsscrcom-poamt.

*> Begin of Loop
    IF NOT G_TC_2130_WA-REQNO IS INITIAL.
      LOOP AT IT_TAB INTO G_TC_2130_WA.
        IF G_TC_2130_WA-NETPR EQ 0.
          CONTINUE.
        ENDIF.

        CLEAR: L_RQMNG,  L_NETWR,
               L_PPMNGQ, L_PPMNGB,
               L_PPAMTQ, L_PPAMTQ.
*> 선급금 수량 집계.
        SELECT  SINGLE *
          FROM  ZTIVRQ00
         WHERE  REQNO  = G_TC_2130_WA-REQNO
           AND  REQIT  = G_TC_2130_WA-REQIT.

        L_PPMNGQ  = ZTIVRQ00-PPMNG.
        L_PPAMTQ  = ZTIVRQ00-IPAMT.

*> 선급금 참조 수량 집계.
        SELECT  SUM( PPMNG ) SUM( PPAMT )
          INTO  (L_PPMNGB, L_PPAMTB)
          FROM  ZTIVBL00
         WHERE  REQNO  = G_TC_2130_WA-REQNO
           AND  REQIT  = G_TC_2130_WA-REQIT
           AND NOT ( IBLNO  = G_TC_2130_WA-IBLNO
           AND       IBLIT  = G_TC_2130_WA-IBLIT ).
*> 선급금 수량 = 선급금 합계 수량 - 선급금 참조 합계수량.
        L_PPMNGB = L_PPMNGQ - L_PPMNGB.
        L_PPAMTB = L_PPAMTQ - L_PPAMTB.

*> 수량 Over check
        IF NOT G_TC_2130_WA-EBELN IS INITIAL.
          READ TABLE GT_EKPO WITH KEY EBELN = G_TC_2130_WA-EBELN
                                      EBELP = G_TC_2130_WA-EBELP.
        ELSE.

        ENDIF.
        G_SUBRC = SY-SUBRC.

        IF NOT G_TC_2130_WA-EBELN IS INITIAL AND
           NOT GT_EKPO-NETWR      IS INITIAL.
*          l_rate = l_ppamtb / gt_ekpo-netwr.
          G_TC_2130_WA-PPMNG = L_PPMNGB.
          G_TC_2130_WA-PPAMT = L_PPAMTB.
        ELSE.
          L_RATE = 0.
          G_TC_2130_WA-PPMNG = 0.
          G_TC_2130_WA-PPAMT = 0.
        ENDIF.

        IF G_TC_2130_WA-PPMNG GT L_PPMNGB.
          G_TC_2130_WA-PPMNG = L_PPMNGB.
        ENDIF.

        IF G_TC_2130_WA-PPAMT GT L_PPAMTB.
          G_TC_2130_WA-PPAMT = L_PPAMTB.
        ENDIF.

        MODIFY IT_TAB FROM G_TC_2130_WA.

        ADD G_TC_2130_WA-PPAMT TO L_PPAMTS.
      ENDLOOP.

      L_PPAMTSS = L_PPAMTS.
      CLEAR: L_PPAMTS.

      LOOP AT IT_TAB INTO G_TC_2130_WA.
        IF G_TC_2130_WA-NETPR EQ 0.
          CONTINUE.
        ENDIF.
*> 수량 Over check
        IF NOT G_TC_2130_WA-EBELN IS INITIAL.
          READ TABLE GT_EKPO WITH KEY EBELN = G_TC_2130_WA-EBELN
                                      EBELP = G_TC_2130_WA-EBELP.
        ELSE.

        ENDIF.
        G_SUBRC = SY-SUBRC.

        IF NOT G_TC_2130_WA-EBELN IS INITIAL AND
           NOT GT_EKPO-NETWR      IS INITIAL.
          L_RATE = G_TC_2130_WA-PPAMT / L_PPAMTSS.
          G_TC_2130_WA-PPAMT = ZTITBLK-PPAMT * L_RATE.
*> 선급금 수량 집계.
          SELECT  SINGLE *
            FROM  ZTIVRQ00
           WHERE  REQNO  = G_TC_2130_WA-REQNO
             AND  REQIT  = G_TC_2130_WA-REQIT.

          L_RATE = G_TC_2130_WA-PPAMT / ZTIVRQ00-IPAMT.
          G_TC_2130_WA-PPMNG = ZTIVRQ00-PPMNG * L_RATE.
        ELSE.
          L_RATE = 0.
          G_TC_2130_WA-PPMNG = 0.
          G_TC_2130_WA-PPAMT = 0.
        ENDIF.
        IF G_TC_2130_WA-EREKZ = C_TRUE.
*> 선급금 참조 수량 집계.
          SELECT  SUM( PPMNG ) SUM( PPAMT )
            INTO  (L_PPMNGB, L_PPAMTB)
            FROM  ZTIVBL00
           WHERE  REQNO       = G_TC_2130_WA-REQNO
             AND  REQIT       = G_TC_2130_WA-REQIT
             AND NOT ( IBLNO  = G_TC_2130_WA-IBLNO
             AND       IBLIT  = G_TC_2130_WA-IBLIT ).
*> 선급금 수량 = 선급금 합계 수량 - 선급금 참조 합계수량.
          G_TC_2130_WA-PPMNG = ZTIVRQ00-PPMNG - L_PPMNGB.
          G_TC_2130_WA-PPAMT = ZTIVRQ00-IPAMT - L_PPAMTB.
        ENDIF.

        MODIFY IT_TAB FROM G_TC_2130_WA.

        ADD G_TC_2130_WA-PPAMT TO L_PPAMTS.
      ENDLOOP.

      IF L_PPAMTS NE ZTITBLK-PPAMT.
        CLEAR: G_LINE.
        LOOP AT IT_TAB INTO G_TC_2130_WA.
          IF NOT G_TC_2130_WA-PPAMT IS INITIAL.
            G_LINE = SY-TABIX.
          ENDIF.
        ENDLOOP.

        READ TABLE IT_TAB INTO G_TC_2130_WA INDEX G_LINE.
        IF SY-SUBRC EQ 0.
          IF L_PPAMTS GT ZTITBLK-PPAMT.
            L_PPAMTD = G_TC_2130_WA-PPAMT
                               - ( L_PPAMTS - ZTITBLK-PPAMT ).
          ELSE.
            L_PPAMTD = G_TC_2130_WA-PPAMT
                               + ( ZTITBLK-PPAMT - L_PPAMTS ).
          ENDIF.
          L_PPAMTDD = G_TC_2130_WA-PPAMT + L_PPAMTD.
          IF L_PPAMTDD LT 0.
            G_TC_2130_WA-PPAMT = 0.
            WRITE L_PPAMTDD TO G_WRBTR1 CURRENCY ZTITBLK-WAERS.
            L_PPAMTDD = L_PPAMTDD * -1.
            ZTITBLK-PPAMT = ZTITBLK-PPAMT + L_PPAMTDD.
            MESSAGE I240 WITH G_WRBTR1.
          ELSE.
            G_TC_2130_WA-PPAMT = G_TC_2130_WA-PPAMT + L_PPAMTDD.
          ENDIF.

          MODIFY IT_TAB FROM G_TC_2130_WA INDEX G_LINE.
        ENDIF.
      ENDIF.

    ENDIF.
*> End of Loop.
  ENDIF.

ENDFORM.                    " prepaid_amount_change_event
*&---------------------------------------------------------------------*
*&      Form  set_item_amount_calc
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM SET_ITEM_AMOUNT_CALC   USING  P_MODE.

  DATA: L_RATE       TYPE F,
        L_BLMNG      TYPE ZTIBLMNG,
        L_BLMNGL     TYPE ZTIBLMNGI,
        L_REFWR      TYPE REFWR,
        L_MAX_CNT    LIKE SY-TABIX,
        L_IVAMT_SUM  LIKE ZTITBLK-IVAMT,
        L_NETWR_SUM  LIKE ZTITBLK-IVAMT,
        L_NETWR_OLD  LIKE ZTITBLK-IVAMT.

  CLEAR: L_IVAMT_SUM, L_RATE, L_NETWR_OLD.

*> 전체구매오더 금액 대비 인보이스 금액 비율.
  L_RATE = ZTITBLK-SMAMT / ZTISSCRCOM-POAMT.
*  l_rate = ( ZTITBLK-smamt - ZTITBLK-ppamt ) / ZTIsscrcom-poamt.

  LOOP AT IT_TAB INTO G_TC_2130_WA.
    IF G_TC_2130_WA-NETPR EQ 0.
      CONTINUE.
    ENDIF.

*> 수량 Over check
    IF NOT G_TC_2130_WA-EBELN IS INITIAL.
      READ TABLE GT_EKPO WITH KEY EBELN = G_TC_2130_WA-EBELN
                                  EBELP = G_TC_2130_WA-EBELP.
    ELSE.

    ENDIF.
    G_SUBRC = SY-SUBRC.

    IF NOT G_TC_2130_WA-EBELN IS INITIAL AND
       NOT GT_EKPO-NETWR      IS INITIAL.
*      l_rate = g_tc_2130_wa-netwr / gt_ekpo-netwr.
      IF P_MODE EQ C_CHAR1.
        G_TC_2130_WA-BLMNG = GT_EKPO-MENGE * L_RATE.
      ENDIF.
      G_TC_2130_WA-NETWR = GT_EKPO-NETWR * L_RATE.
*      g_tc_2130_wa-refwr = gt_ekpo-refwr * l_rate.
      G_TC_2130_WA-REFWR =  G_TC_2130_WA-NETWR.
    ELSE.
      L_RATE = 0.
    ENDIF.

    L_BLMNGL = G_TC_2130_WA-BLMNGL + G_TC_2130_WA-BLMNGM.
*> B/L 가능수량 체크.
    IF G_TC_2130_WA-BLMNG  GT L_BLMNGL.
      G_TC_2130_WA-BLMNG = L_BLMNGL.
    ENDIF.

    IF G_TC_2130_WA-BLMNG  EQ L_BLMNGL.
      G_TC_2130_WA-EREKZ = C_TRUE.
    ELSE.
      G_TC_2130_WA-EREKZ = C_FALSE.
    ENDIF.

*> 기존 정가 누계를 구함.
    L_NETWR_OLD = L_NETWR_OLD + G_TC_2130_WA-NETWR.
    ADD G_TC_2130_WA-REFWR TO L_IVAMT_SUM.
    ADD G_TC_2130_WA-NETWR TO L_NETWR_SUM.


    MODIFY IT_TAB FROM G_TC_2130_WA.

  ENDLOOP.

  IF L_IVAMT_SUM NE ZTITBLK-SMAMT.
    CLEAR: G_LINE.
    LOOP AT IT_TAB INTO G_TC_2130_WA.
      IF NOT G_TC_2130_WA-REFWR IS INITIAL.
        G_LINE = SY-TABIX.
      ENDIF.
    ENDLOOP.

    READ TABLE IT_TAB INTO G_TC_2130_WA INDEX G_LINE.
    IF SY-SUBRC EQ 0.
      IF L_IVAMT_SUM GT ZTITBLK-SMAMT.
        G_TC_2130_WA-REFWR = G_TC_2130_WA-REFWR
                           - ( L_IVAMT_SUM - ZTITBLK-SMAMT ).
      ELSE.
        G_TC_2130_WA-REFWR = G_TC_2130_WA-REFWR
                           + ( ZTITBLK-SMAMT - L_IVAMT_SUM ).
      ENDIF.
      MODIFY IT_TAB FROM G_TC_2130_WA INDEX G_LINE.
    ENDIF.
  ENDIF.

  IF L_NETWR_SUM NE L_NETWR_OLD.
    CLEAR: G_LINE.
    LOOP AT IT_TAB INTO G_TC_2130_WA.
      IF NOT G_TC_2130_WA-NETWR IS INITIAL.
        G_LINE = SY-TABIX.
      ENDIF.
    ENDLOOP.

    READ TABLE IT_TAB INTO G_TC_2130_WA INDEX G_LINE.
    IF SY-SUBRC EQ 0.
      IF L_NETWR_SUM GT L_NETWR_OLD.
        G_TC_2130_WA-NETWR = G_TC_2130_WA-NETWR
                           - ( L_NETWR_SUM - L_NETWR_OLD ).
      ELSE.
        G_TC_2130_WA-NETWR = G_TC_2130_WA-NETWR
                           + ( L_NETWR_OLD - L_NETWR_SUM ).
      ENDIF.
      MODIFY IT_TAB FROM G_TC_2130_WA INDEX G_LINE.
    ENDIF.
  ENDIF.

ENDFORM.                    " set_item_amount_calc
*&---------------------------------------------------------------------*
*&      Form  check_invoice_amount
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM CHECK_INVOICE_AMOUNT .

*> 잔액과 입력 총 송장금액 체크.
  IF ZTITBLK-SMAMT GT ZTISSCRCOM-DCAMT.
    WRITE ZTITBLK-SMAMT    TO G_WRBTR1 CURRENCY ZTITBLK-WAERS.
    WRITE ZTISSCRCOM-DCAMT TO G_WRBTR2 CURRENCY ZTITBLK-WAERS.
    SET CURSOR FIELD 'ZTITBLK-SMAMT'.
    MESSAGE W235 WITH G_WRBTR1 G_WRBTR2.
  ENDIF.

*> 선급금과 입력 총 송장금액 체크.
  IF ZTITBLK-PPAMT GT ZTITBLK-SMAMT.
    WRITE ZTITBLK-SMAMT   TO G_WRBTR1 CURRENCY ZTITBLK-WAERS.
    WRITE ZTITBLK-PPAMT   TO G_WRBTR2 CURRENCY ZTITBLK-WAERS.
    SET CURSOR FIELD 'ZTITBLK-SMAMT'.
    MESSAGE E236 WITH G_WRBTR1 G_WRBTR2.
  ENDIF.

*> (선급금+유보금)과 입력 총 송장금액 체크.
  G_WRBTR = ZTITBLK-PPAMT + ZTITBLK-RTCHG.
  IF G_WRBTR GT ZTITBLK-SMAMT.
    WRITE ZTITBLK-SMAMT    TO G_WRBTR1 CURRENCY ZTITBLK-WAERS.
    WRITE G_WRBTR          TO G_WRBTR2 CURRENCY ZTITBLK-WAERS.
    SET CURSOR FIELD 'ZTITBLK-SMAMT'.
    MESSAGE E237 WITH G_WRBTR1 G_WRBTR2.
  ENDIF.

ENDFORM.                    " check_invoice_amount
*&---------------------------------------------------------------------*
*&      Form  set_initial_data
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM SET_INITIAL_DATA .
*> ASP INTERFACE시 상태.
  IF SY-BINPT EQ C_TRUE.
    ZTITBLK-CRLSE = ZTISSCRCOM-CRLSE.
  ENDIF.

*> 선적서류 상태.
  CASE ZTITIG00-BLPCS.
    WHEN C_CHARA.
      ZTITBLK-BLDST = C_CHARA.
    WHEN C_CHARB.
      ZTITBLK-BLDST = C_CHARA.
    WHEN C_CHARZ.
      ZTITBLK-BLDST = C_CHARZ.
  ENDCASE.
*> 사본 B/L.
  ZTITBLK-BLAYN  = C_CHARD.
  ZTITBLK-CFRATC = 'USD'.

  MOVE:
         'KG'         TO    ZTITBLK-GEWEI,  ">중량단위.
*         ZTITBLK-CRLSE
*         'CBM'        TO    ZTITBLK-voleh,  ">부피단위.
         'Y'          TO    ZTITBLK-APPCT,  ">수입자.
         'USD'        TO    ZTITBLK-CFRATC, ">운임통화.
         'M3'         TO    ZTITBLK-VOLEH,  ">부피단위.
         'GT'         TO    ZTITBLK-BPKTY,  ">포장단위.
         'KR'         TO    ZTITBLK-TLAND.  ">도착국가.
*         'PUS'        TO    ztitblk-tport.  ">도착항.
* 20070510 simcho by 박혁세K
  IF ZTITBLK-TPORT IS INITIAL.
    MOVE   'PUS'        TO    ZTITBLK-TPORT.  ">도착항.
  ENDIF.
* end


*> 지정 포워더 Default
  LOOP AT IT_TAB INTO G_TC_2130_WA.
    IF ZTITBLK-FWDCD IS INITIAL.
      IF NOT G_TC_2130_WA-REQNO IS INITIAL.
        SELECT FWDCD
          INTO ZTITBLK-FWDCD
          FROM ZTITLC4 UP TO 1 ROWS
         WHERE REQNO  EQ  G_TC_2130_WA-REQNO
           AND FWDAM  EQ  C_TRUE.
        ENDSELECT.
      ENDIF.
    ELSE.
      EXIT.
    ENDIF.
*************************************************************
* 20070109 SIMCHO BY 박혁세K
*************************************************************
    CALL FUNCTION 'Z_TI_CALC_ITEM_AMOUNT'
      EXPORTING
        PEINH = G_TC_2130_WA-PEINH
        BPUMZ = G_TC_2130_WA-BPUMZ
        BPUMN = G_TC_2130_WA-BPUMN
        MENGE = G_TC_2130_WA-BLMNG
        NETPR = G_TC_2130_WA-NETPR
      CHANGING
        NETWR = G_TC_2130_WA-NETWR.

    G_TC_2130_WA-REFWR = G_TC_2130_WA-NETWR.
*************************************************************
* end
*************************************************************

  ENDLOOP.
  IF NOT ZTITBLK-FWDCD IS INITIAL.
    SELECT SINGLE NAME1
      INTO ZTITBLK-FWDTX
      FROM LFA1
     WHERE LIFNR EQ ZTITBLK-FWDCD.
  ENDIF.

ENDFORM.                    " set_initial_data

*&---------------------------------------------------------------------*
*&      Form  applications_print
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM APPLICATIONS_PRINT .

  CASE G_MODE.
    WHEN C_CHARC OR C_CHARM.
*> 공용 대화상자(메시지 통일).
      CALL FUNCTION 'Z_TI_POPUP_TO_CONFIRM_MESSAGE'
        EXPORTING
          XMODE  = C_CHARZ
        IMPORTING
          ANSWER = G_ANSWER.
    WHEN OTHERS.
      PERFORM APPLICATIONS_PRINT_OUT.
  ENDCASE.

  IF G_ANSWER EQ C_Y.
    PERFORM CHECK_FOR_DOCUMENT_FIELD USING G_MODE.
    IF G_LINE EQ C_ZERO.
*>Switches on the local update task.
      SET UPDATE TASK LOCAL.
*>Data Save.
      PERFORM P8000_SAVE_MASTER_DATA USING G_MODE.
      CHECK G_SUBRC EQ C_ZERO.
    ENDIF.
    PERFORM APPLICATIONS_PRINT_OUT.
  ENDIF.

ENDFORM.                    " applications_print
*&---------------------------------------------------------------------*
*&      Form  applications_print_out
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM APPLICATIONS_PRINT_OUT .

  DATA: L_DOCNO   TYPE ZTSDOCNO,
        L_DOCTY   TYPE STRING.

*> GET OUTPUT OPTIONS
  IF IT_ZTSPRTCTL[] IS INITIAL.
    REFRESH : IT_ZTSPRTCTL.
    CLEAR: IT_ZTSPRTCTL.

    LOOP AT IT_ZTSPRTCTL.
      MOVE SY-LANGU      TO    IT_ZTSPRTCTL-SPRAS.
      MODIFY IT_ZTSPRTCTL INDEX SY-TABIX.
    ENDLOOP.

    DESCRIBE TABLE IT_ZTSPRTCTL LINES G_LINE.
    IF G_LINE EQ C_ZERO.
      CLEAR: IT_ZTSPRTCTL.
      MOVE: T001-LAND1    TO    IT_ZTSPRTCTL-LAND1,
            SY-LANGU      TO    IT_ZTSPRTCTL-SPRAS.
      APPEND IT_ZTSPRTCTL.
    ENDIF.
  ENDIF.

*> SmartForm 출력용 공용 함수.
  L_DOCNO = ZTITBLK-IBLNO.
  L_DOCTY = G_DOCUMENT.

  CALL FUNCTION 'Z_TS_OUTPUTS_DOCUMENT_BY_TYPE'
    EXPORTING
      IM_IMEXI            = 'I'
      IM_DOCTY            = L_DOCTY
      IM_DOCNO            = L_DOCNO
      IM_AMDNO            = '00'
      IM_REPID            = SY-REPID
    IMPORTING
      EX_ANSWER           = G_ANSWER
    TABLES
      CT_PRTCTL           = IT_ZTSPRTCTL
      CT_PRT_DOC          = IT_PRT_DOC
    EXCEPTIONS
      NO_OUTPUT_DOCUMENTS = 1
      OTHERS              = 2.

  IF SY-SUBRC EQ 0.
    IF G_ANSWER NE 'N'.
      MESSAGE S900.
    ELSE.
      MESSAGE S905.
    ENDIF.
  ELSE.
    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

ENDFORM.                    " applications_print_out

*&---------------------------------------------------------------------*
*&      Form  call_smartforms_functioins
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM CALL_SMARTFORMS_FUNCTIOINS
       USING    P_FUNC_MOD_NAME
                P_SSF_NAME
                P_DOCTY
                P_DOCNO
                P_AMDNO
                P_RREAD
       CHANGING P_MAIL_APPL_OBJ        STRUCTURE G_MAIL_APPL_OBJ
                P_MAIL_RECIPIENT       STRUCTURE G_MAIL_RECIPIENT
                P_MAIL_SENDER          STRUCTURE G_MAIL_SENDER
                P_CONTROL_PARAMETERS   STRUCTURE G_CONTROL_PARAMETERS
                P_OUTPUT_OPTIONS       STRUCTURE G_OUTPUT_OPTIONS
                P_DOCUMENT_OUTPUT_INFO STRUCTURE G_DOCUMENT_OUTPUT_INFO
                P_JOB_OUTPUT_INFO      STRUCTURE G_JOB_OUTPUT_INFO
                P_JOB_OUTPUT_OPTIONS   STRUCTURE G_JOB_OUTPUT_OPTIONS.

  IF P_RREAD EQ C_TRUE.

    ZTISSCRCOM-IBLNO = P_DOCNO.

    CALL FUNCTION 'Z_TI_GET_BILL_OF_LADING'
      EXPORTING
        IBLNO     = ZTISSCRCOM-IBLNO
      IMPORTING
        ZTITBLK   = ZTITBLK
      TABLES
        ZTITBLP   = IT_TAB
      EXCEPTIONS
        NOT_FOUND = 1
        OTHERS    = 2.
    IF SY-SUBRC <> 0.
      MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
              WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    ENDIF.
  ENDIF.

  CALL FUNCTION 'Z_TS_GET_COMPANY_EDI_DATA'
    EXPORTING
      BUKRS     = ZTITBLK-BUKRS
      APPCT     = ZTITBLK-APPCT
    IMPORTING
      NZTSTIG0  = ZTSTIG0
    EXCEPTIONS
      NOT_FOUND = 1
      OTHERS    = 2.
  IF SY-SUBRC <> 0.
    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.



  CALL FUNCTION P_FUNC_MOD_NAME
      EXPORTING
*                ARCHIVE_INDEX      =
*                ARCHIVE_INDEX_TAB  =
*                ARCHIVE_PARAMETERS =
           MAIL_APPL_OBJ      = P_MAIL_APPL_OBJ
           MAIL_RECIPIENT     = P_MAIL_RECIPIENT
           MAIL_SENDER        = P_MAIL_SENDER
           USER_SETTINGS      = SPACE
           CONTROL_PARAMETERS = P_CONTROL_PARAMETERS
           OUTPUT_OPTIONS     = P_OUTPUT_OPTIONS
           IM_ZTITBLK         = ZTITBLK
           IM_ZTSTIG0         = ZTSTIG0
      IMPORTING
           DOCUMENT_OUTPUT_INFO = P_DOCUMENT_OUTPUT_INFO
           JOB_OUTPUT_INFO      = P_JOB_OUTPUT_INFO
           JOB_OUTPUT_OPTIONS   = P_JOB_OUTPUT_OPTIONS
      TABLES
           IT_ZTITBLP           = IT_TAB
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
*&      Form  POSTING_COST_DOCUMENT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM POSTING_COST_DOCUMENT .

  CASE G_MODE.
    WHEN C_CHARS.
      PERFORM CREATE_COST_DOCUMENT.
    WHEN OTHERS.
*> 공용 대화상자(메시지 통일).
      CALL FUNCTION 'Z_TI_POPUP_TO_CONFIRM_MESSAGE'
        EXPORTING
          XMODE  = C_CHAR$
        IMPORTING
          ANSWER = G_ANSWER.
  ENDCASE.

  IF G_ANSWER EQ C_Y.
    PERFORM CHECK_FOR_DOCUMENT_FIELD USING G_MODE.
    IF G_LINE EQ C_ZERO.
*>Switches on the local update task.
      SET UPDATE TASK LOCAL.
*>Data Save.
      PERFORM P8000_SAVE_MASTER_DATA USING G_MODE.
      CHECK G_SUBRC EQ C_ZERO.
    ENDIF.
    PERFORM CREATE_COST_DOCUMENT.
  ENDIF.

ENDFORM.                    " POSTING_COST_DOCUMENT
*&---------------------------------------------------------------------*
*&      Form  CREATE_COST_DOCUMENT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM CREATE_COST_DOCUMENT .

  SUBMIT ZTIR9130_NEW
    WITH S_BUKRS EQ ZTITBLK-BUKRS SIGN C_CHARI
    WITH S_IBLNO EQ ZTITBLK-IBLNO SIGN C_CHARI
    AND RETURN.

*> Cost Document History 조회.
  PERFORM GET_COST_DOCUMENT      TABLES IT_COSTDOC
                                 USING  G_DOCUMENT
                                        ZTITBLK-BUKRS
                                        ZTITBLK-IBLNO
                                        '00'
                                        G_HISTORY_COST.

ENDFORM.                    " CREATE_COST_DOCUMENT
*&---------------------------------------------------------------------*
*&      Form  check_po_document_by_ebeln
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM CHECK_PO_DOCUMENT_BY_EBELN  USING    P_EBELN.

*> Get 수입가능 구매문서 종류 및 지급조건 .
  PERFORM GET_USED_PAYMENT_TERM(ZTIR0000)  TABLES  IT_ZTITIG02
                                           USING   G_SUBRC C_ERROR.

  SELECT *
    INTO CORRESPONDING FIELDS OF TABLE IT_EKPO
    FROM ZTIVPO00
    FOR ALL ENTRIES IN IT_ZTITIG02
   WHERE EBELN  EQ P_EBELN
     AND FRGRL  NE C_TRUE   ">릴리즈 지시자.
     AND ELIKZ  EQ SPACE    ">납품완료 지시자.
     AND HLOEKZ EQ SPACE    ">헤더 삭제지시자.
     AND LOEKZ  EQ SPACE    ">아이템 삭제지시자.
     AND BSTYP  EQ IT_ZTITIG02-BSTYP
     AND BSART  EQ IT_ZTITIG02-BSART
     AND ZTERM  EQ IT_ZTITIG02-ZTERM.

  LOOP AT IT_EKPO.
    G_TABIX = SY-TABIX.
    IF G_RADIO1 EQ C_TRUE OR   ">대체.
       G_RADIO2 EQ C_TRUE.     ">수리.
      SELECT *
        INTO CORRESPONDING FIELDS OF TABLE IT_EKBE
        FROM EKBE
       WHERE EBELN EQ IT_EKPO-EBELN
         AND EBELP EQ IT_EKPO-EBELP
         AND VGABE EQ '1'
         AND BEWTP EQ 'E'
         AND BWART IN ('122', '123').
      IF SY-SUBRC NE 0.
        DELETE IT_EKPO INDEX G_TABIX.
        CONTINUE.
      ELSE.
        CLEAR: G_COUNT, IT_EKPO-MENGE.
        LOOP AT IT_EKBE.
          IF IT_EKBE-SHKZG EQ C_CHARH.
            IT_EKPO-MENGE = IT_EKPO-MENGE + IT_EKBE-MENGE.
          ELSE.
            IT_EKPO-MENGE = IT_EKPO-MENGE - IT_EKBE-MENGE.
          ENDIF.
        ENDLOOP.
        IF IT_EKPO-MENGE LE 0.
          DELETE IT_EKPO INDEX G_TABIX.
          CONTINUE.
        ENDIF.
      ENDIF.
    ENDIF.
    SELECT SUM( BLMNG )
      INTO IT_EKPO-BLMNGS
      FROM ZTIVBL00
     WHERE EBELN  EQ IT_EKPO-EBELN
       AND EBELP  EQ IT_EKPO-EBELP
       AND REQNO  EQ SPACE
       AND NDFTY  IN ('B', 'C', 'R', 'S').

    IT_EKPO-BLMNGL =  IT_EKPO-MENGE - IT_EKPO-BLMNGS.

    IF IT_EKPO-BLMNGL LE 0.
      DELETE IT_EKPO INDEX G_TABIX.
      CONTINUE.
    ENDIF.
    IT_EKPO-BLMNG = IT_EKPO-BLMNGL.
    MODIFY IT_EKPO INDEX G_TABIX.
  ENDLOOP.

  DESCRIBE TABLE IT_EKPO LINES G_LINE.
  IF G_LINE EQ 0.
    MESSAGE E249 WITH  P_EBELN.
  ENDIF.

ENDFORM.                    " check_po_document_by_ebeln
*&---------------------------------------------------------------------*
*&      Form  check_so_document_by_vbeln
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM CHECK_SO_DOCUMENT_BY_VBELN  USING    P_VBELN.


ENDFORM.                    " check_so_document_by_vbeln
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
*&      Form  GET_ZMMT0207_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM GET_ZMMT0207_DATA .

  DATA : GT_ZMMT0207 LIKE ZMMT0207 OCCURS 0 WITH HEADER LINE.
  DATA : LV_CTNQ2    LIKE ZMMT0207-CTNTY,
         LV_CTNQ4    LIKE ZMMT0207-CTNTY,
         LV_CFRAT2   LIKE ZTITBLK-CFRAT,
         LV_CFRAT4   LIKE ZTITBLK-CFRAT,
         LV_CFRATC2  LIKE ZTITBLK-CFRATC,
         LV_CFRATC4  LIKE ZTITBLK-CFRATC.
  DATA : LV_CHK(1).
  DATA : LV_ZROUTE   LIKE ZMMT0234-ZROUTE.

  CLEAR : GT_ZMMT0207, GT_ZMMT0207[], LV_CTNQ2, LV_CTNQ4,
          LV_CFRAT2, LV_CFRAT4, LV_CFRATC2, LV_CFRATC4, LV_CHK.

*  IF ( ZTITBLK-BUKRS EQ '1000' OR ZTITBLK-BUKRS EQ '5000' )
  IF ZTITBLK-BUKRS EQ '1000' AND ZTITBLK-FWDCD IS NOT INITIAL.

    CHECK NOT ZTITBLK-RPTTY EQ C_CHARZ.  "미통관은 운임계산 X

    CHECK ZTITBLK-INCO1 EQ 'FOB' OR ZTITBLK-INCO1 EQ 'EXW' OR
          ZTITBLK-INCO1 EQ 'FAS' OR ZTITBLK-INCO1 EQ 'FCA'. "296419 추가

    "특송은 체크 안함
    IF ZTITBLK-FWDTY = 'A' AND "항공
       ZTITBLK-FWDFM = 'L' AND "LCL
       ZTITBLK-CTNTY = 'Z'.    "기타 (DHL 같은 특송에 사용)
      GV_SUGI = 'X'.
    ENDIF.

    "예외 운송경로는 체크 안함
    SELECT SINGLE ZROUTE
      INTO LV_ZROUTE
      FROM ZMMT0234
     WHERE ZROUTE = ZTITBLK-ZROUTE.

    IF SY-SUBRC = 0.
      GV_SUGI = 'X'.
    ENDIF.

    CHECK GV_SUGI IS INITIAL.            "수기입력이면 체크안함

    IF GV_MANUL IS INITIAL.
      IF ZTITBLK-ZROUTE IS INITIAL.
        PERFORM NO_INPUT_CHECK USING 'ZTITBLK' 'ZROUTE' C_ERROR.
      ENDIF.
    ENDIF.

*   수입운임마스터 GET
    SELECT *
      INTO CORRESPONDING FIELDS OF TABLE GT_ZMMT0207
      FROM ZMMT0207
     WHERE LIFNR  EQ ZTITBLK-FWDCD  "물류업체
*       AND FLAND  EQ ZTITBLK-FLAND  "선적국가 	"기능개선 283274 삭제
*       AND FPORT  EQ ZTITBLK-FPORT  "선적항
*       AND TLAND  EQ ZTITBLK-TLAND  "도착국가
*       AND TPORT  EQ ZTITBLK-TPORT  "도착항
       AND INCO1  EQ ZTITBLK-INCO1  "인도조건
       AND FWDTY  EQ ZTITBLK-FWDTY  "운송방법
       AND ZROUTE EQ ZTITBLK-ZROUTE "수입운송경로
       AND DATAB  <= ZTITBLK-BLDAT  "효력시작일
       AND DATBI  => ZTITBLK-BLDAT  "효력종료일
       AND MAGAM  EQ ' '.

    IF SY-SUBRC NE 0.
      IF GV_MANUL IS INITIAL.   "운임 수기입력 불가인 경우 에러 처리
        MESSAGE E999 WITH '입력값에 대한 운임마스터가 없습니다'.
      ELSE.
*        MESSAGE W999 WITH '입력값에 대한 운임마스터가 없습니다'.
        CLEAR ZTITBLK-CFRAT.
        EXIT.
      ENDIF.
    ENDIF.

*   수입해상
    IF ZTITBLK-FWDTY EQ C_CHARO.
      IF ZTITBLK-FWDFM EQ C_CHARF.   "FCL : 계약가 * 컨테이너 수

        IF NOT ZTITBLK-CTNQ2 IS INITIAL. "20FT
*-<< 기능개선 298023 - 포장유형 세분화
          IF ZTITBLK-CTNTY EQ C_CHARD.
            LV_CTNQ2 = '20DR'.
          ELSEIF ZTITBLK-CTNTY EQ C_CHARO.
            LV_CTNQ2 = '20OT'.
          ELSEIF ZTITBLK-CTNTY EQ C_CHARF.
            LV_CTNQ2 = '20FR'.
          ENDIF.
*->> 기능개선 298023

          READ TABLE GT_ZMMT0207 WITH KEY CTNTY = LV_CTNQ2.

          IF SY-SUBRC EQ 0.
            LV_CFRAT2  = GT_ZMMT0207-DMBTR * ZTITBLK-CTNQ2.
            LV_CFRATC2 = GT_ZMMT0207-WAERS.
          ELSE.
            LV_CHK ='X'.
          ENDIF.
        ENDIF.

        IF NOT ZTITBLK-CTNQ4 IS INITIAL.  "40FT
*-<< 기능개선 298023 - 포장유형 세분화
          IF ZTITBLK-CTNTY EQ C_CHARD.
            LV_CTNQ4 = '40DR'.
          ELSEIF ZTITBLK-CTNTY EQ C_CHARH.
            LV_CTNQ4 = '40HC'.
          ELSEIF ZTITBLK-CTNTY EQ C_CHARO.
            LV_CTNQ4 = '40OT'.
          ELSEIF ZTITBLK-CTNTY EQ C_CHARF.
            LV_CTNQ4 = '40FR'.
          ENDIF.
*->> 기능개선 298023

          READ TABLE GT_ZMMT0207 WITH KEY CTNTY = LV_CTNQ4.

          IF SY-SUBRC EQ 0.
            LV_CFRAT4  = GT_ZMMT0207-DMBTR * ZTITBLK-CTNQ4.
            LV_CFRATC4 = GT_ZMMT0207-WAERS.
          ELSE.
            LV_CHK ='X'.
          ENDIF.
        ENDIF.

        ZTITBLK-CFRAT  = LV_CFRAT2 + LV_CFRAT4.
        IF LV_CFRATC2 IS NOT INITIAL AND LV_CFRATC4  IS INITIAL.
          ZTITBLK-CFRATC = LV_CFRATC2.
        ELSEIF LV_CFRATC2 IS INITIAL AND LV_CFRATC4  IS NOT INITIAL.
          ZTITBLK-CFRATC = LV_CFRATC4.
        ELSE.
          IF LV_CFRATC2 NE LV_CFRATC4.
            MESSAGE W999 WITH '20FT/40FT 통화가 다릅니다'.
            CLEAR ZTITBLK-CFRAT.
          ENDIF.
        ENDIF.
      ENDIF.

      IF ZTITBLK-FWDFM EQ C_CHARL.   " LCL : 계약가 * CBM
        CHECK ZTITBLK-VOLEH = 'M3'.

        READ TABLE GT_ZMMT0207 WITH KEY CTNTY = 'LCL'.

        IF SY-SUBRC EQ 0.
          "기능개선 294534 추가 - LCL 볼륨 1 미만 min.rate 설정
          IF ZTITBLK-VOLUM < 1.
            ZTITBLK-CFRAT  = GT_ZMMT0207-DMBTR.
            ZTITBLK-CFRATC = GT_ZMMT0207-WAERS.
          ELSE.
            ZTITBLK-CFRAT  = GT_ZMMT0207-DMBTR * ZTITBLK-VOLUM.
            ZTITBLK-CFRATC = GT_ZMMT0207-WAERS.
          ENDIF.
        ELSE.
          LV_CHK ='X'.
        ENDIF.
      ENDIF.
    ENDIF.

*   수입항공
    IF ZTITBLK-FWDTY EQ C_CHARA.
      CHECK ZTITBLK-VOLEH = 'KG'.

      READ TABLE GT_ZMMT0207 WITH KEY CTNTY = 'AIR'.

      IF SY-SUBRC EQ 0.

        "기능개선 310412 - EXW / FCA 제외
        IF ( ZTITBLK-INCO1 EQ 'FOB' OR ZTITBLK-INCO1 EQ 'FAS' ) AND
              ZTITBLK-VOLUM <= '13'. " 13kg 이하는 Min.rate 적용
          ZTITBLK-CFRAT  = GT_ZMMT0207-MINRT.
          ZTITBLK-CFRATC = GT_ZMMT0207-WAERS.
        ELSE.
          ZTITBLK-CFRAT  = GT_ZMMT0207-DMBTR * ZTITBLK-VOLUM.
          ZTITBLK-CFRATC = GT_ZMMT0207-WAERS.
        ENDIF.
      ELSE.
        LV_CHK ='X'.
      ENDIF.
    ENDIF.

    IF  LV_CHK ='X'.
      MESSAGE E999 WITH '입력값에 대한 운임마스터가 없습니다'.
      CLEAR ZTITBLK-CFRAT.
    ENDIF.
  ENDIF.
ENDFORM.                    " GET_ZMMT0207_DATA
*&---------------------------------------------------------------------*
*&      Form  GET_ZROUTE_DESC
*&---------------------------------------------------------------------*
*       기능개선 283274 - 추가
*----------------------------------------------------------------------*
FORM GET_ZROUTE_DESC  USING    PV_BUKRS
                               PV_ZROUTE
                               PV_BEZEI.

  CLEAR : PV_BEZEI.

  CHECK PV_ZROUTE IS NOT INITIAL.

  SELECT SINGLE BEZEI
    INTO PV_BEZEI
    FROM ZMMT0230
   WHERE BUKRS  = PV_BUKRS
     AND ZROUTE = PV_ZROUTE.

ENDFORM.                    " GET_ZROUTE_DESC
*&---------------------------------------------------------------------*
*&      Form  CHECK_EXCEPTION_FOR_MANUAL
*&---------------------------------------------------------------------*
*       기능개선 283274 - 추가, 운임 수기입력 가능여부 점검
*----------------------------------------------------------------------*
*  <--  PV_MANUL = ' '  : 운임 수기입력 불가
*  <--  PV_MANUL = 'X'  : 운임 수기입력 가능
*----------------------------------------------------------------------*
FORM CHECK_EXCEPTION_FOR_MANUAL  USING    PV_SUGI
                                          PV_MANUL.

  DATA : LT_ZTITBL LIKE ZTIVBL00 OCCURS 0 WITH HEADER LINE.
  CLEAR : LT_ZTITBL, LT_ZTITBL[].
  PV_MANUL = 'X'.

  CHECK ZTITBLK-BUKRS = '1000'.

*___항공/LCL/포장유형'기타'인 경우 운임 수기 입력
  IF ZTITBLK-FWDTY = 'A' AND       "항공
     ZTITBLK-FWDFM = 'L' AND       "LCL
     ZTITBLK-CTNTY = 'Z'.          "기타 (DHL 같은 특송에 사용)
    PV_MANUL = 'X'.
    PV_SUGI  = 'X'.

    EXIT.
  ENDIF.

  IF ZTITBLK-RPTTY EQ C_CHARZ. "기능개선 298023 - 미통관 제외
    PV_MANUL = 'X'.
    PV_SUGI  = 'X'.
    EXIT.
  ENDIF.

  CHECK ZTITBLK-INCO1 = 'EXW' OR ZTITBLK-INCO1 = 'FOB' OR
        ZTITBLK-INCO1 = 'FAS' OR ZTITBLK-INCO1 = 'FCA'. "296419 추가

  LOOP AT IT_TAB INTO G_TC_2130_WA.

*   BREAK-POINT.

*___B/L 품목의 자재코드로 예외여부 점검
*   비철구매의 경우 운임 계산하지 않음
    SELECT SINGLE MATNR
      INTO G_TC_2130_WA-MATNR
      FROM ZMMT0233
     WHERE MATNR = G_TC_2130_WA-MATNR.

    IF SY-SUBRC = 0.
      CONTINUE.
    ENDIF.

*___사후송금 B/L 생성시 구매오더로 사전송금이 있는지 확인
*   사전송금이 있다면 수기입력 가능
    IF ZTITBLK-BLDTY = 'A'. "사후송금
      SELECT SINGLE *
        INTO LT_ZTITBL
        FROM ZTIVBL00
       WHERE BLDTY = ' '
         AND BUKRS = '1000'
         AND EKORG = '1100'
         AND EBELN = G_TC_2130_WA-EBELN
         AND EBELP = G_TC_2130_WA-EBELP.

      IF SY-SUBRC = 0.
        CONTINUE.
      ENDIF.
    ENDIF.

*___B/L 품목의 구매오더로 예외여부 점검
*   예외로 등록되지 않은 구매오더/품목이 하나라도 있으면 수기입력 불가
    SELECT SINGLE EBELN
      INTO G_TC_2130_WA-EBELN
      FROM ZMMT0231
     WHERE EBELN = G_TC_2130_WA-EBELN
       AND EBELP = G_TC_2130_WA-EBELP.

    IF SY-SUBRC <> 0.
      CLEAR : PV_SUGI, PV_MANUL.
      EXIT.
    ENDIF.
  ENDLOOP.

  IF SY-SUBRC <> 0.
*___B/L 품목이 없는 경우도 운임 수기입력 불가
    CLEAR : PV_SUGI, PV_MANUL.

    EXIT.
  ENDIF.

ENDFORM.                    " CHECK_EXCEPTION_FOR_MANUAL
*&---------------------------------------------------------------------*
*&      Form  CALL_INSURANCE_TCODE
*&---------------------------------------------------------------------*
*       기능개선 283274 - 추가
*----------------------------------------------------------------------*
FORM CALL_INSURANCE_TCODE .
  DATA: LV_ANSWER.

  CHECK ZTITBLK-INCO1 = 'FOB' OR ZTITBLK-INCO1 = 'FCA' OR
        ZTITBLK-INCO1 = 'FAS' OR ZTITBLK-INCO1 = 'CPT' OR
        ZTITBLK-INCO1 = 'CFR' OR ZTITBLK-INCO1 = 'EXW'.

  CHECK ZTITBLK-RPTTY NE 'Z'. "기능개선 298023 - 삼국무역 운임/부보 제외

  CALL FUNCTION 'POPUP_TO_CONFIRM'
    EXPORTING
      TITLEBAR              = '확인'
      TEXT_QUESTION         = '적하보험을 생성하시겠습니까?'
      DISPLAY_CANCEL_BUTTON = ' '
    IMPORTING
      ANSWER                = LV_ANSWER
    EXCEPTIONS
      TEXT_NOT_FOUND        = 1
      OTHERS                = 2.

  CHECK LV_ANSWER = '1'.

  SET PARAMETER ID 'ZTIIBLNO' FIELD ZTITBLK-IBLNO.

  CALL TRANSACTION 'ZTIT101N' AND SKIP FIRST SCREEN.

ENDFORM.                    " CALL_INSURANCE_TCODE
*&---------------------------------------------------------------------*
*&      Form  GET_FORT
*&---------------------------------------------------------------------*
FORM GET_FORT  USING    PV_BUKRS
                        PV_ZROUTE
                        PV_FLAND
                        PV_FPORT.

  IF PV_FLAND IS INITIAL OR PV_FPORT IS INITIAL.

    CLEAR : PV_FLAND, PV_FPORT.

    SELECT SINGLE FPORT FLAND
      INTO (PV_FPORT, PV_FLAND)
      FROM ZMMT0230
     WHERE BUKRS  = PV_BUKRS
       AND ZROUTE = PV_ZROUTE.
  ENDIF.

ENDFORM.                    " GET_FORT
*&---------------------------------------------------------------------*
*&      Form  CALL_ZCOTY
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM CALL_ZCOTY .
  CLEAR : GV_ANSWER, GV_ZCOTY.
  CALL FUNCTION 'POPUP_TO_CONFIRM'
    EXPORTING
      TITLEBAR              = '원산지증명서 제출여부'
      TEXT_QUESTION         = '일괄 입력 하시겠습니까?'
      TEXT_BUTTON_1         = '확인'
      ICON_BUTTON_1         = 'ICON_OKAY'
      TEXT_BUTTON_2         = '취소'
      ICON_BUTTON_2         = 'ICON_CANCEL'
      DEFAULT_BUTTON        = '2'             "Default Button: 취소
      DISPLAY_CANCEL_BUTTON = ' '
      POPUP_TYPE            = 'ICON_MESSAGE_QUESTION'
    IMPORTING
      ANSWER                = GV_ANSWER
    EXCEPTIONS
      TEXT_NOT_FOUND        = 1
      OTHERS                = 2.

  IF GV_ANSWER = '1'.
    CALL SCREEN 7040 STARTING  AT  25 5.
  ENDIF.

  CHECK GV_ZCOTY IS NOT INITIAL.

  LOOP AT IT_TAB INTO G_TC_2130_WA.
    G_TC_2130_WA-ZCOTY = GV_ZCOTY.
    MODIFY IT_TAB FROM G_TC_2130_WA TRANSPORTING ZCOTY.
  ENDLOOP.

ENDFORM.                    " CALL_ZCOTY
*&---------------------------------------------------------------------*
*&      Form  SEND_MAIL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM SEND_MAIL .
  REFRESH: GT_RECV, GT_MESSAGE .
  DATA: LV_FLAG,
        LV_TEXT1(255),
        LV_TEXT2(255),
        LV_TEXT3(255),
        LV_TEXT4(255),
        LV_TEXT5(255),
        LV_TEXT6(255),
        LT_RECV LIKE TABLE OF GT_RECV.

*수신자 리스트
  SELECT BNAME                                   "담당자
      INTO CORRESPONDING FIELDS OF TABLE GT_RECV
      FROM ZTITBLNAM.

  GT_RECV-BNAME = ZTITBLK-CNAM.                  "생성자
  APPEND GT_RECV.
  CLEAR GT_RECV.

  LOOP AT GT_RECV.
    PERFORM GET_RECEIVER_LIST.
  ENDLOOP.

  SORT GT_RECV BY BNAME.

  DELETE ADJACENT DUPLICATES FROM GT_RECV[] COMPARING ALL FIELDS.

  DELETE GT_RECV WHERE SMTP_ADDR IS INITIAL.

*메일 내용 생성
  CLEAR : LV_TEXT1, LV_TEXT2, LV_TEXT3, LV_TEXT4, LV_TEXT5.

*___메일 제목(50 Byte)
  CONCATENATE 'B/L번호:' ZTITBLK-BLNUM
              '원산지증명서 변경알림'
         INTO GV_SUBJECT SEPARATED BY SPACE.  " SEPARATED BY SPACE.
*___메일 내용(라인길이 255 Byte)
  CONCATENATE '<br>'
            '아래 B/L 번호의 원산지 증명서 제출 상태가 변경되었습니다.'
              '<br><br>'
         INTO LV_TEXT1 SEPARATED BY SPACE.
*<<CHM2010-00458 신규 생성시 신규생성 표시
  IF ZTITBLK-IBLNO IS INITIAL.
    CONCATENATE '<br>'
              '1. B/L 관리번호 : ' '신규 생성'
               ', B/L 품목:' G_TC_2130_WA-IBLIT
                '<br><br>'
           INTO LV_TEXT2 SEPARATED BY SPACE.
  ELSE.
    CONCATENATE '<br>'
              '1. B/L 관리번호 : ' ZTITBLK-IBLNO
               ', B/L 품목:' G_TC_2130_WA-IBLIT
                '<br><br>'
           INTO LV_TEXT2 SEPARATED BY SPACE.
  ENDIF.
  CONCATENATE '<br>'
              '2. B/L 변경자 : ' SY-UNAME
              '<br><br>'
         INTO LV_TEXT3 SEPARATED BY SPACE.

  IF G_TC_2130_WA-ZCOTY = 'A'.
    CONCATENATE '<br>'
                '3. 원산지 증명서 제출상태 : 발급완료 '
                '<br><br>'
           INTO LV_TEXT4 SEPARATED BY SPACE.
  ELSEIF G_TC_2130_WA-ZCOTY = 'L'.
    CONCATENATE '<br>'
                '3. 원산지 증명서 제출상태 : 재수출 이행 완료 '
                '<br><br>'
           INTO LV_TEXT4 SEPARATED BY SPACE.
  ENDIF.

  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
    EXPORTING
      INPUT  = G_TC_2130_WA-MATNR
    IMPORTING
      OUTPUT = G_TC_2130_WA-MATNR.


  CONCATENATE '<br>'
              '4. 자재코드  : ' G_TC_2130_WA-MATNR
              '<br><br>'
         INTO LV_TEXT5 SEPARATED BY SPACE.

  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
    EXPORTING
      INPUT  = G_TC_2130_WA-MATNR
    IMPORTING
      OUTPUT = G_TC_2130_WA-MATNR.

  CONCATENATE '<br>'
              '5. 자재내역  : ' G_TC_2130_WA-TXZ01
              '<br><br>'
         INTO LV_TEXT6 SEPARATED BY SPACE.

  MAIL_MSG: '<html>',
            '<body>',
            LV_TEXT1,
            LV_TEXT2,
            LV_TEXT3,
            LV_TEXT4,
            LV_TEXT5,
            LV_TEXT6,
            '</body>',
            '</html>'.

*메일 발송
  IF GT_RECV[] IS NOT INITIAL.
    TRY.
        G_EMAIL = CL_BCS=>CREATE_PERSISTENT( ).

        G_EMAIL_BODY = CL_DOCUMENT_BCS=>CREATE_DOCUMENT(
                        I_TYPE    = 'HTM'
                        I_TEXT    = GT_MESSAGE
                        I_SUBJECT = GV_SUBJECT ).

        G_EMAIL->SET_DOCUMENT( G_EMAIL_BODY ).

        LOOP AT GT_RECV.
          G_RECEIVER = CL_CAM_ADDRESS_BCS=>CREATE_INTERNET_ADDRESS(
                        I_ADDRESS_STRING = GT_RECV-SMTP_ADDR ).

          G_EMAIL->ADD_RECIPIENT( I_RECIPIENT = G_RECEIVER
                                  I_EXPRESS   = 'X' ).
        ENDLOOP.

*        G_SENDER = CL_SAPUSER_BCS=>CREATE( 'ADMIN' ).
        G_SENDER = CL_SAPUSER_BCS=>CREATE( SY-UNAME ).
        G_EMAIL->SET_SENDER( G_SENDER ).

        G_EMAIL->SET_SEND_IMMEDIATELY( 'X' ).

        G_EMAIL->SEND( EXPORTING I_WITH_ERROR_SCREEN = 'X'
                       RECEIVING RESULT              = GV_SEND_RESULT ).

        COMMIT WORK.

      CATCH CX_BCS INTO G_EXCEPTION.
        LV_FLAG = 'X'.

*        EXIT.
    ENDTRY.
  ELSE.
    LV_FLAG = 'X'.
  ENDIF.

ENDFORM.                    " SEND_MAIL
*&----------------------------------------------------------------------
*
*&      Form  GET_RECEIVER_LIST
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM GET_RECEIVER_LIST .
  DATA LT_ADR6 TYPE ADR6 OCCURS 0.
  DATA LV_ADDR TYPE AD_ADDRNUM.
  DATA LV_PERS TYPE AD_PERSNUM.
*  CLEAR   : GT_RECV.
*  REFRESH : GT_RECV.

  FIELD-SYMBOLS <LFS_ADR6> LIKE LINE OF LT_ADR6.

  SELECT SINGLE ADDRNUMBER PERSNUMBER INTO (LV_ADDR, LV_PERS)
    FROM USR21
   WHERE BNAME EQ GT_RECV-BNAME.

  CHECK SY-SUBRC = 0.

  CALL FUNCTION 'ADDR_SELECT_ADR6_SINGLE'
    EXPORTING
      ADDRNUMBER          = LV_ADDR
      PERSNUMBER          = LV_PERS
    TABLES
      ET_ADR6             = LT_ADR6
    EXCEPTIONS
      COMM_DATA_NOT_EXIST = 1
      PARAMETER_ERROR     = 2
      INTERNAL_ERROR      = 3
      OTHERS              = 4.
  IF SY-SUBRC <> 0.
    EXIT.
  ENDIF.

  CHECK NOT LT_ADR6[] IS INITIAL.

  READ TABLE LT_ADR6 ASSIGNING <LFS_ADR6> INDEX 1.
  IF SY-SUBRC = 0.
*    GT_RECV-BNAME = GT_MAIL-ERNAM.
    GT_RECV-SMTP_ADDR = <LFS_ADR6>-SMTP_ADDR.
    MODIFY GT_RECV.
  ENDIF.
ENDFORM.                    " GET_RECEIVER_LIST
*&---------------------------------------------------------------------*
*&      Form  SET_REQNO_IVNO_BL_LINK
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM SET_REQNO_IVNO_BL_LINK .

  GF_RQIV_CHK = C_X.

  LOOP AT IT_TAB INTO G_TC_2130_WA WHERE REQNO IS INITIAL.
    SELECT SINGLE REQNO REQIT
             INTO  (G_TC_2130_WA-REQNO, G_TC_2130_WA-REQIT)
      FROM ZTITRQP
     WHERE IBLNO EQ G_TC_2130_WA-IBLNO
       AND IBLIT EQ G_TC_2130_WA-IBLIT.


    SELECT SINGLE IVONO INTO  G_TC_2130_WA-IVONO
      FROM ZTITIVP
     WHERE IBLNO EQ G_TC_2130_WA-IBLNO
       AND IBLIT EQ G_TC_2130_WA-IBLIT.


    MODIFY IT_TAB FROM G_TC_2130_WA
          TRANSPORTING REQNO REQIT IVONO.
  ENDLOOP.


ENDFORM.                    " SET_REQNO_IVNO_BL_LINK
*&---------------------------------------------------------------------*
*&      Form  p9000_duelist_refresh
*&---------------------------------------------------------------------*
FORM M9000_DUELIST_REFRESH
                 USING P_SELFIELD TYPE SLIS_SELFIELD.

*> 검색조건에 해당하는 데이타를 Select.
  PERFORM P2000_DATA_SELECTIONS.
*> Header table과 List(Items) table를 만듬.
  PERFORM P2100_HEADER_AND_LIST_BUILD.
  DESCRIBE TABLE IT_TABH LINES G_LINE.
  IF NOT G_LINE IS INITIAL.
    P_SELFIELD-REFRESH = 'X'.
  ELSE.
*> Program 종료.
    PERFORM  P9000_PROGRAM_EXIT.
  ENDIF.

ENDFORM.                    " p9000_duelist_refresh
*&---------------------------------------------------------------------*
*&      Form  SET_BL_UP_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM SET_BL_UP_DATA .

  MOVE-CORRESPONDING GT_LIST99 TO ZTITBLK.
  PERFORM GET_OTHERS_TEXT_BY_MASTER_DATA.

  CLEAR : ZTITBLK-PLLOD, ZTITBLK-PLTRN.

  SELECT SINGLE PORTE
    INTO ZTITBLK-PLLOD
    FROM ZTSTIGP
   WHERE LAND1 EQ ZTITBLK-FLAND
     AND PORTC EQ ZTITBLK-FPORT.


  SELECT SINGLE PORTE
    INTO ZTITBLK-PLTRN
    FROM ZTSTIGP
   WHERE LAND1 EQ ZTITBLK-TLAND
     AND PORTC EQ ZTITBLK-TPORT.

ENDFORM.                    "SET_BL_UP_DATA
