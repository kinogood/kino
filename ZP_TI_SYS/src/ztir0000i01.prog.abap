************************************************************************
* Title         :  ZTIR0000I01                                         *
*                                                                      *
* Description   : 수입 L/C 관리 PAI Include                            *
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
* 2011/04/23   FIB05          [제목] TT개설요청접수시_EDI내역check     *
*                             [CSR_NO] C20110323_48869                 *
* 2014/10/06   MMB04          사후송금 개설요청시 최신송장정보 업데이트*
*                             [CSR_NO] 44036                           *
* 2016/12/16   신재호         [자체개선 174544]                        *
*                             구매승인서 HS코드 필수 및 10자리로 변경  *
* 2024/06/25   이원형         [CHM2403-00155]                        *
*                              HS CODE 체크로직 추가  *
************************************************************************

*&---------------------------------------------------------------------*
*&      Module  tc_2130_modify  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE TC_2130_MODIFY INPUT.

  DATA : LF_MTRON_CHK,
         LW_TAB LIKE ZTISRQIT .

  CHECK: G_MODE EQ C_CHARC OR
         G_MODE EQ C_CHARM.

  MOVE-CORRESPONDING: ZTISRQIT TO G_TC_2130_OLD.

*- 엠트론 조건 추가 (첫번째 라인만 HS_CODE 및 제한된 사용자)
  CLEAR LF_MTRON_CHK.
  IF SY-UNAME EQ 'C526812'  OR
     SY-UNAME EQ 'C526806'  OR
     SY-UNAME(4) EQ 'ZLSG'  .
    LF_MTRON_CHK = 'X'.
  ENDIF.

*    READ TABLE IT_TAB INTO LW_TAB INDEX 1.
*
*    IF ( ZTISRQIT-REQIT EQ 1 AND ZTISRQIT-STAWN IS NOT INITIAL )
*         AND  ZTITRQK-BUKRS EQ '3000'.
*      IF SY-UNAME EQ 'C526812'  OR
*         SY-UNAME EQ 'C287805'  OR
*         SY-UNAME(4) EQ 'ZLSG'  .
*         LF_MTRON_CHK = 'X'.
*      ENDIF.
*    ELSEIF LW_TAB-STAWN IS NOT INITIAL
*           AND  ZTITRQK-BUKRS EQ '3000'.
*      IF SY-UNAME EQ 'C526812'  OR
*         SY-UNAME EQ 'C287805'  OR
*         SY-UNAME(4) EQ 'ZLSG'  .
*         LF_MTRON_CHK = 'X'.
*      ENDIF.
*    ENDIF.

  MOVE: ZTISRQIT-RQMNG   TO  G_TC_2130_WA-RQMNG,
        ZTISRQIT-STAWN   TO  G_TC_2130_WA-STAWN.

  IF G_TC_2130_WA-RQMNG GT G_TC_2130_WA-RQMNGL.
    CLEAR: G_MENGET.
    WRITE G_TC_2130_WA-RQMNGL TO G_MENGET(15) UNIT G_TC_2130_WA-MEINS.
    CONCATENATE G_MENGET G_TC_2130_WA-MEINS INTO G_MENGET.
*> Settlement가 적용된 경우.
    IF NOT ZTITRQS-SETYN IS INITIAL.
      MESSAGE E010 WITH G_MENGET.
    ELSE.
      MESSAGE E005 WITH G_MENGET.
    ENDIF.
  ENDIF.

*> 선급수량.
  IF G_TC_2130_WA-RQMNG LT G_TC_2130_WA-PPMNG.
    CLEAR: G_MENGET.
    WRITE G_TC_2130_WA-PPMNG TO G_MENGET(15) UNIT G_TC_2130_WA-MEINS.
    CONCATENATE G_MENGET G_TC_2130_WA-MEINS INTO G_MENGET.
    MESSAGE E028 WITH G_MENGET.
  ENDIF.

*> H/S code Check.
  IF NOT ( ZTITRQK-REQTY EQ C_LO ). " OR "자체개선 174544
*           ZTITRQK-REQTY EQ C_PU ).     "구매승인서 HS 필수로 변경
    IF G_TC_2130_WA-STAWN IS INITIAL AND
        LF_MTRON_CHK  IS INITIAL.
      PERFORM NO_INPUT_CHECK USING 'ZTISRQIT' 'STAWN' C_ERROR.
    ENDIF.
  ENDIF.



  MOVE-CORRESPONDING: G_TC_2130_OLD TO G_TC_2130_WA.

* 20050914 simcho 자재master H/S코드와 비교
* 자재master HS코드와 다를시 에러
  IF G_TC_2130_WA-MATNR IS NOT INITIAL AND
      LF_MTRON_CHK  IS INITIAL.
    DATA LV_STAWN LIKE MARC-STAWN.

    CLEAR: LV_STAWN.
    SELECT SINGLE STAWN
             INTO (LV_STAWN)
             FROM MARC
            WHERE MATNR  EQ  G_TC_2130_WA-MATNR
              AND WERKS  EQ  G_TC_2130_WA-WERKS.
    IF G_TC_2130_WA-STAWN <> LV_STAWN.
      PERFORM NO_INPUT_CHECK USING
                 G_TC_2130_WA-MATNR
                 '자재master의 HS코드'
                 C_ERROR.
    ENDIF.
  ENDIF.

*-<<자체개선 174544 - 구매승인서 HS코드 필수 및 10자리로 변경
  IF ZTITRQK-REQTY EQ C_PU AND
      LF_MTRON_CHK  IS INITIAL.
    DATA L_CNT TYPE I.
    CLEAR L_CNT.
    L_CNT = STRLEN( G_TC_2130_WA-STAWN ).
    IF L_CNT NE '10'.
      MESSAGE E999 WITH 'HS-CODE는 10자리입니다!'.
    ENDIF.
  ENDIF.
*->>자체개선 174544

*>>> CHM2403-00155 HS CODE 체크로직 추가
  CLEAR: LV_STAWN.
  IF ZTITRQK-REQTY EQ C_TT AND ZTITRQK-BUKRS EQ '1000' .
    SELECT SINGLE CCNGN
        INTO (LV_STAWN)
        FROM ZMMT0131
       WHERE CCNGN  EQ  G_TC_2130_WA-STAWN.
    IF  LV_STAWN IS INITIAL.
      MESSAGE E999 WITH '등록할 수 있는 HS-CODE가 아닙니다!'.
    ENDIF.
  ENDIF.
*>>> CHM2403-00155 HS CODE 체크로직 추가


*> 정가 계산.
  CALL FUNCTION 'Z_TI_CALC_ITEM_AMOUNT'
    EXPORTING
      PEINH = G_TC_2130_WA-PEINH
      BPUMZ = G_TC_2130_WA-BPUMZ
      BPUMN = G_TC_2130_WA-BPUMN
      MENGE = G_TC_2130_WA-RQMNG
      NETPR = G_TC_2130_WA-NETPR
    CHANGING
      NETWR = G_TC_2130_WA-NETWR.

  IF G_TC_2130_WA-CNAM IS INITIAL.
    MOVE: SY-UNAME TO G_TC_2130_WA-CNAM,
          SY-DATLO TO G_TC_2130_WA-CDAT,
          SY-TIMLO TO G_TC_2130_WA-CTME.
  ENDIF.

  MOVE: SY-UNAME TO G_TC_2130_WA-UNAM,
        SY-DATLO TO G_TC_2130_WA-UDAT,
        SY-TIMLO TO G_TC_2130_WA-UTME.


*__S 44036: 사후송금 개설 요청 시 최신 송장정보 업데이트 추가
  DATA : IT_TAB_WA LIKE LINE OF IT_TAB.

  READ TABLE IT_TAB INTO IT_TAB_WA INDEX TC_2130-CURRENT_LINE.
  G_TC_2130_WA-IBLNO = IT_TAB_WA-IBLNO.
  G_TC_2130_WA-IBLIT = IT_TAB_WA-IBLIT.
*__E 44036: 사후송금 개설 요청 시 최신 송장정보 업데이트 추가

  MODIFY  IT_TAB
    FROM  G_TC_2130_WA
    INDEX TC_2130-CURRENT_LINE.

ENDMODULE.                 " tc_2130_modify  INPUT
*&---------------------------------------------------------------------*
*&      Module  tc_2130_mark  INPUT
*&---------------------------------------------------------------------*
MODULE TC_2130_MARK INPUT.

  MODIFY IT_TAB
    FROM G_TC_2130_WA
    INDEX TC_2130-CURRENT_LINE
    TRANSPORTING FLAG.

ENDMODULE.                 " tc_2130_mark  INPUT
*&---------------------------------------------------------------------*
*&      Module  tc_2130_user_command  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE TC_2130_USER_COMMAND INPUT.

  OK_CODE = SY-UCOMM.
*> table control functions ( 삭제, 추가, 선택, 해제, 이동 등 )
  PERFORM  USER_OK_TC USING    'TC_2130'
                               'IT_TAB'
                               'FLAG'
                      CHANGING OK_CODE.
*>아이템 번호를 생성함.
  PERFORM SET_ITEM_NUMBER_BUILD TABLES IT_TAB
                                USING  ZTITRQS.
*> 아이템 정보 display
  PERFORM  DISPLAY_INFOMATION_BY_ITEMS USING   'TC_2130'
                                               'IT_TAB'
                                               'FLAG'
                                               ZTITRQK-LIFNR
                                       CHANGING OK_CODE.
*> F2 Funtion key Event시 해당 필드의 정보 display
  PERFORM  DOUBLE_CLICK_EVENT.

ENDMODULE.                 " tc_2130_user_command  INPUT
*&---------------------------------------------------------------------*
*&      Module  check_type_of_request  INPUT
*&---------------------------------------------------------------------*
*  개설요청 문서 종류 체크
*----------------------------------------------------------------------*
MODULE CHECK_TYPE_OF_REQUEST INPUT.

  CHECK: G_MODE EQ C_CHARC OR
         G_MODE EQ C_CHARM.

  IF ZTITRQK-REQTY IS INITIAL.
    PERFORM NO_INPUT(SAPFMMEX) USING 'ZTITRQK' 'REQTY'.
  ELSE.
    PERFORM CHECK_DOMAIN_VALUES USING 'ZTIREQTY'
                                      ZTITRQK-REQTY.
    PERFORM GET_DOMAIN_VALUE_TEXT
                USING
                   'ZTIREQTY'
                   ZTITRQK-REQTY
                   G_TEXT32.

*> 무환일 경우 수입의뢰를 막음.
    IF ZTITRQK-REQTY EQ 'ZZ'.
      MESSAGE E141 WITH G_TEXT32.
    ENDIF.

*> 수입의뢰 종류가 변경된 경우.
    IF ZTISSCRCOM-REQTY NE ZTITRQK-REQTY.
      MESSAGE W112 WITH G_TEXT32.
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
          SELECT  SUM( RQMNG )
            INTO G_TC_2130_WA-RQMNGS
            FROM ZTIVRQ00
           WHERE  EBELN  = G_TC_2130_WA-EBELN
             AND  EBELP  = G_TC_2130_WA-EBELP
             AND NOT ( REQNO  = G_TC_2130_WA-REQNO
             AND       REQIT  = G_TC_2130_WA-REQIT )
             AND  PPAID  = C_FALSE
             AND  RPAID  = C_FALSE .
          G_TC_2130_WA-RQMNGL = G_TC_2130_WA-MENGE -
                               G_TC_2130_WA-RQMNGS.
          IF G_TC_2130_WA-RQMNGL GT G_TC_2130_WA-RQMNG.
            G_TC_2130_WA-RQMNG = G_TC_2130_WA-RQMNGL.
          ENDIF.
        ELSE.
          SELECT  SUM( RQMNG )
            INTO G_TC_2130_WA-RQMNGS
            FROM ZTIVRQ00
           WHERE  EBELN  = G_TC_2130_WA-EBELN
             AND  EBELP  = G_TC_2130_WA-EBELP
             AND NOT ( REQNO  = G_TC_2130_WA-REQNO
             AND       REQIT  = G_TC_2130_WA-REQIT ).

          G_TC_2130_WA-RQMNGL = G_TC_2130_WA-MENGE -
                               G_TC_2130_WA-RQMNGS.
          IF G_TC_2130_WA-RQMNGL GT G_TC_2130_WA-RQMNG.
            G_TC_2130_WA-RQMNG = G_TC_2130_WA-RQMNGL.
          ENDIF.
        ENDIF.

        CALL FUNCTION 'Z_TI_CALC_ITEM_AMOUNT'
          EXPORTING
            PEINH = G_TC_2130_WA-PEINH
            BPUMZ = G_TC_2130_WA-BPUMZ
            BPUMN = G_TC_2130_WA-BPUMN
            MENGE = G_TC_2130_WA-RQMNG
            NETPR = G_TC_2130_WA-NETPR
          CHANGING
            NETWR = G_TC_2130_WA-NETWR.

        MODIFY IT_TAB FROM G_TC_2130_WA.
      ENDLOOP.
*> 개설금액 체크.
      PERFORM  CHECK_OPEN_AMOUNT.
*----  >>  End of Loop.
      CLEAR : ZTITRQK-PPAID, ZTITRQK-RPAID.
    ENDIF.
  ENDIF.

ENDMODULE.                 " check_type_of_request  INPUT
*&---------------------------------------------------------------------*
*&      Module  pai_scr0100_check_input_fields  INPUT
*&---------------------------------------------------------------------*
MODULE PAI_SCR0100_CHECK_INPUT_FIELDS INPUT.
*> EXIT확인.
  PERFORM  CHECK_PROGRAM_EXIT_COMMAND.

*> call이 되었을 경우.
  IF SY-CALLD EQ C_TRUE.
    IF NOT G_TCODE  IS INITIAL.
*      MESSAGE a003(ok).
*    ELSE.
      IF SY-TCODE EQ C_DUE_LIST_PU OR
         G_TCODE1 EQ C_DUE_LIST_PU OR
         G_TCODE1 EQ C_DUE_LIST_TT OR
         G_TCODE1 EQ C_DUE_LIST_RT.
        MOVE: 'ZTICOPY' TO OK_CODE,
              'ZTICOPY' TO SY-UCOMM.
      ENDIF.
    ENDIF.
  ENDIF.

*> Input fields check
  IF NOT OK_CODE EQ 'ZTICOPY'.
    IF ZTISSCRCOM-EBELN IS INITIAL AND
       ZTISSCRCOM-BELNR IS INITIAL.
      MESSAGE E100 WITH '구매오더'(S01).
    ENDIF.
  ENDIF.

  PERFORM GET_USED_PAYMENT_TERM   TABLES IT_ZTITIG02
                                  USING  G_SUBRC C_WARNING.

*> 무환건 삭제.
  DELETE IT_ZTITIG02 WHERE REQTY = 'ZZ'.
**> 사후송금건 삭제.
*  DELETE it_ztitig02 WHERE reqty = 'TT'
*                       AND aftyn = 'A'.

  DESCRIBE TABLE IT_ZTITIG02 LINES G_LINE.
  IF G_LINE EQ 0.
    MESSAGE ID 'ZMTI00' TYPE C_ERROR NUMBER 001.
  ENDIF.

  PERFORM GET_TRANSPORT_TERMS     TABLES IT_ZTITIG11
                                  USING  G_SUBRC C_WARNING.

*> 구매오더 Select.
  IF NOT OK_CODE EQ 'ZTICOPY'.
*  IF NOT ZTIsscrcom-ebeln IS INITIAL.
    PERFORM P3000_SET_DATA_OF_SCREEN.

*> 구매오더 Data Select.
*------------------------------------------------------------
*---> 사후송금 PO 개별생성 막음...
*------------------------------------------------------------
    SELECT SINGLE *
      FROM EKKO
     WHERE EBELN EQ ZTISSCRCOM-EBELN.
    IF SY-SUBRC EQ 0.
      READ TABLE IT_ZTITIG02 WITH KEY BSTYP = EKKO-BSTYP
                                      BSART = EKKO-BSART
                                      ZTERM = EKKO-ZTERM.
      IF SY-SUBRC EQ 0.
        IF IT_ZTITIG02-AFTYN EQ 'A'.
          MESSAGE E174 WITH ZTISSCRCOM-EBELN.
        ENDIF.
      ENDIF.
    ENDIF.
*------------------------------------------------------------
    CLEAR: ZTISSCRCOM-EBELP.
    PERFORM GET_PURCHASE_ORDER_DATA TABLES IT_PO
                                           IT_ZTITIG02
                                    USING  ZTISSCRCOM-EBELN
                                           ZTISSCRCOM-EBELP
                                           C_ERROR
                                           C_ERROR.
*>[Import] 수입의뢰요청 -> 구매오더 복사필드 정의.
    CLEAR: ZTITIG30.
    SELECT SINGLE *
      FROM ZTITIG30.

    LOOP AT IT_PO.
      CLEAR: G_MODIFY, ZTIVPO00.
      DESCRIBE TABLE IT_TAB LINES G_COUNT_1.
      PERFORM  GET_AND_CHECK_PO_DATA   USING  IT_PO-EBELN
                                              IT_PO-EBELP
                                              G_MODIFY
                                              ZTIVPO00
                                              G_COUNT_1
                                              C_ERROR.
*      IF g_modify EQ c_true.
*        EXIT.
*      ENDIF.
      IF ZTISSCRCOM-REQTY IS INITIAL.
        PERFORM  DDIC_DOMAIN_VALUE_TEXT_READ USING 'ZTIREQTY'
                                                   SY-LANGU
                                                   IT_ZTITIG02-REQTY
                                                   G_DDTEXT
                                                   C_SUCCESS.
*        IF sy-calld NE c_true.
*          MESSAGE w104 WITH g_ddtext.
*        ENDIF.
        ZTISSCRCOM-REQTY = IT_ZTITIG02-REQTY.
        ZTITRQK-ILCTY    = IT_ZTITIG02-ILCTY.
        ZTITRQK-USCDY    = IT_ZTITIG02-USCDY.
        ZTITRQS-PAGRT    = IT_ZTITIG02-PAGRT.
      ENDIF.

*> 수입의뢰 종류 Move
      MOVE ZTISSCRCOM-REQTY TO ZTITRQK-REQTY.

*> PO data Move
      PERFORM SET_REQUEST_OF_IMPORT_DATA TABLES IT_TAB
                                         USING  ZTIVPO00
                                                ZTITRQK
                                                ZTITRQS
                                                IT_PO.
    ENDLOOP.
  ELSE.
    CASE G_TCODE1.
      WHEN C_DUE_LIST_PU.
        PERFORM  SET_REQUEST_BY_PUR_DOCUMENT.
      WHEN C_DUE_LIST_TT.
        PERFORM  SET_REQUEST_BY_BL_DOCUMENT.
      WHEN C_DUE_LIST_RT.
        PERFORM  SET_REQUEST_BY_RETENTION.
    ENDCASE.

*> 수입의뢰 종류 Move ---> 구매확인서.
*         TO c_pu.
  ENDIF.

** JS전선 회사코드 2007/04 KSH --------------------------------------
*> AUTHORIZATION_CHECK
  PERFORM P1102_AUTHORIZATION_CHECK USING ZTITRQK-BUKRS.
** JS전선 회사코드 2007/04 KSH --------------------------------------

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

ENDMODULE.                 " pai_scr0100_check_input_fields  INPUT
*&---------------------------------------------------------------------*
*&      Module  user_command_scr0100  INPUT
*&---------------------------------------------------------------------*
MODULE USER_COMMAND_SCR0100 INPUT.

*> EXIT확인.
  PERFORM  CHECK_PROGRAM_EXIT_COMMAND.

*> Text Object 관련 Internal Table Initial.
  PERFORM  GET_LONGTEXT_DATA.

*> Create Class Object.
  PERFORM  BUILD_CLASS_OBJECT.

*> Generic Object Service.
  PERFORM  SET_GENERIC_OBJECT_SERVICE USING   'ZTIWF_SDOC'
                                               ZTITRQS+3(12).

  LEAVE TO SCREEN 2000.

*> 10. Save User setting infomation
  PERFORM  SET_USER_SETTING_STRUCTURE.

ENDMODULE.                 " user_command_scr0100  INPUT
*&---------------------------------------------------------------------*
*&      Module  pai_scr0200_check_input_fields  INPUT
*&---------------------------------------------------------------------*
MODULE PAI_SCR0200_CHECK_INPUT_FIELDS INPUT.

*> EXIT확인.
  PERFORM  CHECK_PROGRAM_EXIT_COMMAND.

  IF ZTISSCRCOM-EBELN IS INITIAL AND
     ZTISSCRCOM-REQNO IS INITIAL AND
     ZTISSCRCOM-OPNNO IS INITIAL.
    MESSAGE E913.
  ENDIF.

  CLEAR: G_COUNT.
  IF ZTISSCRCOM-REQNO IS INITIAL.
*> Ammend 생성일 경우.
    IF SY-TCODE EQ C_CREATE_A.
      PERFORM  GET_REQUEST_NO_BY_PO_NUMBER1 USING ZTISSCRCOM-EBELN
                                                  ZTISSCRCOM-REQNO
                                                  ZTISSCRCOM-AMDSQ
                                                  C_FALSE.
    ELSE.
      PERFORM  GET_REQUEST_NO_BY_PO_NUMBER USING ZTISSCRCOM-EBELN
                                                 ZTISSCRCOM-REQNO
                                                 ZTISSCRCOM-AMDSQ
                                                 C_FALSE.
    ENDIF.
  ENDIF.

  IF ZTISSCRCOM-REQNO IS INITIAL.
*> Ammend 생성일 경우.
    IF SY-TCODE EQ C_CREATE_A.
      PERFORM  GET_REQUEST_NO_BY_OPEN_NUMBER1 USING ZTISSCRCOM-OPNNO
                                                   ZTISSCRCOM-REQNO
                                                   ZTISSCRCOM-AMDSQ
                                                   C_FALSE.
    ELSE.
      PERFORM  GET_REQUEST_NO_BY_OPEN_NUMBER USING ZTISSCRCOM-OPNNO
                                                   ZTISSCRCOM-REQNO
                                                   ZTISSCRCOM-AMDSQ
                                                   C_FALSE.
    ENDIF.
  ENDIF.

*> Ammend 생성일 경우.
  IF SY-TCODE EQ C_CREATE_A.
    SELECT SINGLE LSTAS
      INTO ZTISSCRCOM-AMDSQ
      FROM ZTITRQK
     WHERE REQNO  EQ  ZTISSCRCOM-REQNO.

    IF SY-SUBRC NE 0.
      MESSAGE E108 WITH ZTISSCRCOM-REQNO.
    ENDIF.
  ENDIF.

  IF NOT ZTISSCRCOM-REQNO IS INITIAL.
    CALL FUNCTION 'Z_TI_GET_REQUEST_OF_IMPORT'
      EXPORTING
        REQNO     = ZTISSCRCOM-REQNO
        AMDSQ     = ZTISSCRCOM-AMDSQ
      IMPORTING
        ZTITRQK   = ZTITRQK
        ZTITRQS   = ZTITRQS
        ZTITLC1   = ZTITLC1
        ZTITLC5   = ZTITLC5
        ZTITLO1   = ZTITLO1
        ZTITPC1   = ZTITPC1
        ZTITTT1   = ZTITTT1
        ZTITDAK   = ZTITDAK
      TABLES
        ZTITRQP   = IT_TAB
        ZTITLC2   = XZTITLC2
        ZTITLC3   = XZTITLC3
        ZTITLC4   = G_TC_2123_ITAB
        ZTITPC2   = XZTITPC2
        ZTITPC3   = XZTITPC3
        ZTITTT2   = XZTITTT2
        ZTITTT3   = XZTITTT3
        ZTITTT4   = G_TC_2124_ITAB
        ZTITDAS   = XZTITDAS
        ZTITDAD   = XZTITDAD
        ZTITDAC   = XZTITDAC
      EXCEPTIONS
        NOT_FOUND = 1
        OTHERS    = 2.
    IF SY-SUBRC <> 0.
      MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
              WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    ENDIF.

** JS전선 회사코드 2007/04 KSH --------------------------------------
*> authorization
    PERFORM GET_AUTHORIZATION_BUKRS.
    IF L_YN NE 'A'.
      IF ZTITRQK-BUKRS <> A_BUKRS.
        MESSAGE E998 WITH ZTITRQK-BUKRS  '권한이 없습니다!'..
      ENDIF.
    ENDIF.
** JS전선 회사코드 2007/04 KSH --------------------------------------

*> 변경 문서 관리를 위한 이전데이타를 Move.
    *ZTITRQK   = ZTITRQK.
    *ZTITRQS   = ZTITRQS.
    *ZTITLC1   = ZTITLC1.
    *ZTITLO1   = ZTITLO1.
    *ZTITPC1   = ZTITPC1.
    *ZTITTT1   = ZTITTT1.

    YZTITLC2[] = XZTITLC2[].
    YZTITLC3[] = XZTITLC3[].
    YZTITPC2[] = XZTITPC2[].
    YZTITPC3[] = XZTITPC3[].
    YZTITTT2[] = XZTITTT2[].
    YZTITTT3[] = XZTITTT3[].
*> 변경 문서 관리를 위한 이전데이타를 Move (Item Data).
    REFRESH: XZTITRQP, YZTITRQP.
    LOOP AT IT_TAB INTO G_TC_2130_WA.
      MOVE-CORRESPONDING G_TC_2130_WA TO : XZTITRQP,
                                           YZTITRQP.
      APPEND : XZTITRQP, YZTITRQP.
    ENDLOOP.
*> 변경 문서 관리를 위한 이전데이타를 Move (포워더 Data).
    REFRESH: XZTITLC4, YZTITLC4.
    LOOP AT G_TC_2123_ITAB INTO G_TC_2123_WA.
      MOVE-CORRESPONDING G_TC_2123_WA TO : XZTITLC4,
                                           YZTITLC4.
      APPEND : XZTITLC4, YZTITLC4.
    ENDLOOP.
*> 변경 문서 관리를 위한 이전데이타를 Move (지급확인 Data).
    REFRESH: XZTITTT4, YZTITTT4.
    LOOP AT G_TC_2124_ITAB INTO G_TC_2124_WA.
      MOVE-CORRESPONDING G_TC_2124_WA TO : XZTITTT4,
                                           YZTITTT4.
      APPEND : XZTITTT4, YZTITTT4.
    ENDLOOP.

* EDI ITEM TABLE SETTING.
    PERFORM READ_EDI_TABLE_DOCUMENT.

*>업무영역별 Status Check.
    PERFORM CHECK_DOCUMENT_STATUS.

*>조회모드가 아닌 경우 Lock.
    IF G_MODE NE C_CHARS.
      PERFORM SET_LC_LOCK_OBJECT   USING ZTITRQS-REQNO
                                         ZTITRQS-AMDSQ
                                         '00000'
                                         C_LOCK
                                         C_ERROR
                                         G_MODIFY.
    ENDIF.
  ELSE.
    MESSAGE E902.
  ENDIF.

  PERFORM GET_USED_PAYMENT_TERM   TABLES IT_ZTITIG02
                                  USING  G_SUBRC C_WARNING.

*> Ammend 생성일 경우.
  IF SY-TCODE EQ C_CREATE_A.
    CLEAR: OLD_ZTITRQS, NEW_EKKO, OLD_ZTITPC1.
    IF ZTITRQK-REQTY EQ C_PU.
      SELECT SINGLE *
        INTO OLD_ZTITPC1
        FROM ZTITPC1
       WHERE REQNO   EQ  ZTITRQS-REQNO
         AND AMDSQ   EQ  ZTITRQS-AMDSQ.
*it_tab_o
    ENDIF.

    IF ZTITRQS-SETYN EQ C_FALSE.
      SELECT SINGLE *
        INTO OLD_ZTITRQS
        FROM ZTITRQS
       WHERE REQNO   EQ  ZTITRQS-REQNO
         AND AMDSQ   EQ  ZTITRQS-AMDSQ.
    ENDIF.

    ZTITRQS-AMDSQ = ZTITRQS-AMDSQ + 1.
    CLEAR: ZTITRQS-EDIYN, ZTITRQS-REQDT, ZTITRQS-APPUN,
           ZTITRQS-APPDT, ZTITRQS-APPTM, ZTITRQS-ACCUN,
           ZTITRQS-ACCDT, ZTITRQS-ACCTM, ZTITRQS-SNDUN,
           ZTITRQS-SNDDT, ZTITRQS-SNDTM, ZTITRQS-RCVUN,
           ZTITRQS-RCVDT, ZTITRQS-RCVTM, ZTITRQS-RECID,
           ZTITRQS-RECNM, ZTITRQS-RECNO, ZTITRQS-RCVNO,
           ZTITRQS-DOCST, ZTITRQS-SNDST, ZTITRQS-OTHT1,
           ZTITRQS-OTHT2, ZTITRQS-OTHT3, ZTITRQS-OTHT4,
           ZTITRQS-OTHT5, ZTITRQS-ROTT1, ZTITRQS-ROTT2,
           ZTITRQS-ROTT3, ZTITRQS-ROTT4, ZTITRQS-ROTT5,
           ZTITRQS-NOMN1, ZTITRQS-NOMN2, ZTITRQS-ESIGN,
           ZTITRQS-NOAD1, ZTITRQS-NOAD2, ZTITRQS-CNAM ,
           ZTITRQS-CDAT , ZTITRQS-CTME , ZTITRQS-REQMT,
           ZTITRQS-UNAM , ZTITRQS-UDAT , ZTITRQS-UTME ,
           ZTITRQS-RQRLS, ZTITRQS-RETNS,
*> 변경지시자.
           ZTITRQS-OPAMTX,
           ZTITRQS-EXDATX,
           ZTITRQS-LSDATX,
           ZTITRQS-PARTYX,
           ZTITRQS-TRANYX,
           ZTITRQS-FPORTX,
           ZTITRQS-TPORTX,
           ZTITRQS-INCO1X,
           ZTITRQS-ZTERMX,
           ZTITRQS-FWDTYX,
           ZTITRQS-CTOCDX,
           ZTITRQS-INSYNX.

*> 변경 항목 체크.
    IF ZTITRQS-SETYN EQ C_FALSE.
      READ TABLE IT_TAB INTO G_TC_2130_WA INDEX 1.
      IF SY-SUBRC EQ 0.
        SELECT SINGLE *
          INTO NEW_EKKO
          FROM EKKO
         WHERE EBELN EQ  G_TC_2130_WA-EBELN.
*> 릴리즈 지시자 체크.
        IF EKKO-FRGRL  EQ C_TRUE.
          MESSAGE E126.
        ENDIF.
      ENDIF.

      REFRESH: IT_TAB_O.
      LOOP AT IT_TAB INTO G_TC_2130_WA.
        SELECT SINGLE *
          INTO CORRESPONDING FIELDS OF G_TC_2130_WA
          FROM EKPO
         WHERE EBELN  EQ  G_TC_2130_WA-EBELN
           AND EBELP  EQ  G_TC_2130_WA-EBELP.
        IF SY-SUBRC EQ 0.
          G_TC_2130_WA-RQMNG = G_TC_2130_WA-RQMNGL =
                   G_TC_2130_WA-MENGE - G_TC_2130_WA-RQMNGS.
          MODIFY IT_TAB FROM G_TC_2130_WA.
        ENDIF.
        APPEND G_TC_2130_WA TO IT_TAB_O.
      ENDLOOP.

*> 아이템 기타 정보 Read.
      PERFORM  SET_OTHERS_FIELDS_BY_ITEMS.
*> 개설금액 체크.
      PERFORM  CHECK_OPEN_AMOUNT.
*> Payment Terms
      PERFORM GET_USED_PAYMENT_TERM   TABLES IT_ZTITIG02
                                      USING  G_SUBRC C_WARNING.

      READ TABLE IT_ZTITIG02 WITH KEY BSTYP = NEW_EKKO-BSTYP
                                      BSART = NEW_EKKO-BSART
                                      ZTERM = NEW_EKKO-ZTERM.
*> 구매오더 수입관련 필드 --> 수입의뢰 상태 테이블.
      PERFORM  MOVE_EKKO_FIELDS_TO_ZTITRQS  USING  NEW_EKKO
                                                   ZTITRQS.

*> 이전 값과 비교하여 change 구분자를 설정함.
      PERFORM  COMPARE_FIELDS_CHANGED.
    ENDIF.
  ELSE.
    IF ZTITRQS-AMDSQ GT 0.
      G_AMDSQ = ZTITRQS-AMDSQ - 1.
      CLEAR: OLD_ZTITRQS, NEW_EKKO, OLD_ZTITPC1.

      SELECT * INTO CORRESPONDING FIELDS OF TABLE IT_TAB_O
        FROM ZTITRQP
       WHERE REQNO  EQ ZTITRQS-REQNO
         AND AMDSQ  EQ G_AMDSQ.

      IF ZTITRQK-REQTY EQ C_PU.
        SELECT SINGLE *
          INTO OLD_ZTITPC1
          FROM ZTITPC1
         WHERE REQNO   EQ  ZTITRQS-REQNO
           AND AMDSQ   EQ  G_AMDSQ.
*it_tab_o
      ENDIF.

      IF ZTITRQS-SETYN EQ C_FALSE.
        SELECT SINGLE *
          INTO OLD_ZTITRQS
          FROM ZTITRQS
         WHERE REQNO   EQ  ZTITRQS-REQNO
           AND AMDSQ   EQ  G_AMDSQ.
        READ TABLE IT_TAB INTO G_TC_2130_WA INDEX 1.
        IF SY-SUBRC EQ 0.
          SELECT SINGLE *
            INTO NEW_EKKO
            FROM EKKO
           WHERE EBELN EQ  G_TC_2130_WA-EBELN.
*> 릴리즈 지시자 체크.
          IF NOT NEW_EKKO-FRGRL IS INITIAL.
            MESSAGE E126.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.
*>아이템 기타 정보 Read.
    PERFORM  SET_OTHERS_FIELDS_BY_ITEMS.
*> 개설금액 체크.
    PERFORM  CHECK_OPEN_AMOUNT.
  ENDIF.

*>화면상의 Text를 Master Data 등에서 Read.
  PERFORM GET_OTHERS_TEXT_BY_MASTER_DATA.

  IF ZTITRQS-AMDSQ IS INITIAL.
    IF G_MODE EQ C_CHARY.
*> 포워더 지정
      CASE ZTITRQK-REQTY.
        WHEN C_LC OR C_TT OR C_DA OR C_DP.
          ZTITRQK-FWDAS = ZTITIG00-FWDYN.
*> 지정 포워더 Setting
          IF ZTITIG00-FWDYN EQ C_TRUE.
            DESCRIBE TABLE G_TC_2123_ITAB LINES G_LINE.
            IF G_LINE EQ 0.
              PERFORM  SET_FORWARDER_DATA.
            ENDIF.
          ENDIF.
        WHEN OTHERS.
          CLEAR: ZTITRQK-FWDAS.
      ENDCASE.
    ENDIF.
  ENDIF.

  IF ZTITRQS-SETYN EQ C_FALSE.
*> Document History 조회.
    PERFORM GET_DOCUMENT_HISTORY   TABLES IT_DOCHIS
                                   USING  G_DOCUMENT
                                          ZTITRQS-REQNO
                                          ZTITRQS-AMDSQ
                                          G_HISTORY.
  ENDIF.
*> Cost Document History 조회.
  PERFORM GET_COST_DOCUMENT      TABLES IT_COSTDOC
                                 USING  G_DOCUMENT
                                        ZTITRQK-BUKRS
                                        ZTITRQS-REQNO
                                        ZTITRQS-AMDSQ
                                        G_HISTORY_COST.
  ZTISSCRCOM-REQTY = ZTITRQK-REQTY.

ENDMODULE.                 " pai_scr0200_check_input_fields  INPUT
*&---------------------------------------------------------------------*
*&      Module  PAI_SCR2121_CHECK_VENDOR  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE PAI_SCR2121_CHECK_VENDOR INPUT.

  PERFORM  GET_IMPORT_VENDORS_TEXT  USING C_ERROR.

ENDMODULE.                 " PAI_SCR2121_CHECK_VENDOR  INPUT

*&---------------------------------------------------------------------*
*&      Module  tc_2240_modify  INPUT
*&---------------------------------------------------------------------*
*> input module for tc 'TC_2240'. do not change this line!
*> modify table
*&---------------------------------------------------------------------*
MODULE TC_2240_MODIFY INPUT.
  MOVE-CORRESPONDING ZTITTT2 TO G_TC_2240_WA.
  MODIFY G_TC_2240_ITAB
    FROM G_TC_2240_WA
    INDEX TC_2240-CURRENT_LINE.
  IF SY-SUBRC NE 0.
    APPEND G_TC_2240_WA TO G_TC_2240_ITAB.
  ENDIF.
ENDMODULE.                    "TC_2240_modify INPUT

*&---------------------------------------------------------------------*
*&      Module  tc_2240_mark  INPUT
*&---------------------------------------------------------------------*
*> input module for tc 'TC_2240'. do not change this line!
*> mark table
*&---------------------------------------------------------------------*
MODULE TC_2240_MARK INPUT.
  IF TC_2240-LINE_SEL_MODE = 1 AND
     G_TC_2240_WA-FLAG = 'X'.
    LOOP AT G_TC_2240_ITAB INTO G_TC_2240_WA
      WHERE FLAG = 'X'.
      G_TC_2240_WA-FLAG = ''.
      MODIFY G_TC_2240_ITAB
        FROM G_TC_2240_WA
        TRANSPORTING FLAG.
    ENDLOOP.
    G_TC_2240_WA-FLAG = 'X'.
  ENDIF.
  MODIFY G_TC_2240_ITAB
    FROM G_TC_2240_WA
    INDEX TC_2240-CURRENT_LINE
    TRANSPORTING FLAG.
ENDMODULE.                    "TC_2240_mark INPUT

*&---------------------------------------------------------------------*
*&      Module  tc_2240_user_command  INPUT
*&---------------------------------------------------------------------*
*> input module for tc 'TC_2240'. do not change this line!
*> process user command
*&---------------------------------------------------------------------*
MODULE TC_2240_USER_COMMAND INPUT.
  OK_CODE = SY-UCOMM.
  PERFORM USER_OK_TC USING    'TC_2240'
                              'G_TC_2240_ITAB'
                              'FLAG'
                     CHANGING OK_CODE.
  SY-UCOMM = OK_CODE.

  CLEAR G_COUNT.
  LOOP AT G_TC_2240_ITAB INTO G_TC_2240_WA.
    ADD 1 TO G_COUNT.
    G_TC_2240_WA-TBQIT = G_COUNT.
    MODIFY G_TC_2240_ITAB FROM G_TC_2240_WA.
  ENDLOOP.

*> F2 Funtion key Event시 해당 필드의 정보 display
  PERFORM  DOUBLE_CLICK_EVENT.

ENDMODULE.                    "TC_2240_user_command INPUT

*&---------------------------------------------------------------------*
*&      Module  tc_2220_1_modify  INPUT
*&---------------------------------------------------------------------*
*> input module for tc 'TC_2220_1'. do not change this line!
*> modify table
*&---------------------------------------------------------------------*
MODULE TC_2220_1_MODIFY INPUT.

* 2007.02.05 simcho KRW/JPY 금액 수정
  IF ZTITPC2-PBDATC = 'KRW' OR ZTITPC2-PBDATC = 'JPY'.
    ZTITPC2-PBDAT = ZTITPC2-PBDAT / 100.
  ENDIF.
* end simcho

  MOVE-CORRESPONDING ZTITPC2 TO G_TC_2220_1_WA.

  MODIFY G_TC_2220_1_ITAB  FROM G_TC_2220_1_WA
                          INDEX TC_2220_1-CURRENT_LINE.

*.구매확인서 EDI 문서 변경에 따른 수정 - 근거서류 필수 항목 check
* (Req.by 이상엽K/2013.12.13/EDB03)
  IF G_MODE EQ C_CHARC OR
     G_MODE EQ C_CHARM OR
     G_MODE EQ C_CHARY OR
     G_MODE EQ C_CHARO.

    IF G_TC_2220_1_WA-PBDAT IS INITIAL.
      PERFORM NO_INPUT_CHECK USING 'ZTITPC2' 'PBDAT' C_ERROR.
    ELSEIF G_TC_2220_1_WA-PBDATC IS INITIAL.
      PERFORM NO_INPUT_CHECK USING 'ZTITPC2' 'PBDATC' C_ERROR.
    ELSEIF G_TC_2220_1_WA-PBDSD IS INITIAL.
      PERFORM NO_INPUT_CHECK USING 'ZTITPC2' 'PBDSD' C_ERROR.
    ENDIF.

    IF G_TC_2220_1_WA-PBDED < G_TC_2220_1_WA-PBDSD.
      MESSAGE E999 WITH '유효기일이 근거서류선적기일 이후여야 합니다.'.
    ENDIF.

*-{기능개선 213478 - 구매승인서 특수문자 체크 추가
*> 사용가능 문자집합 체크.
    PERFORM  CHECK_EDI_AVAILABLE_CHAR2  USING :
                                        'ZTITPC2-PBDNO'  C_ERROR,
                                        'ZTITPC2-PBDSN'  C_ERROR,
                                        'ZTITPC2-PBDSN2'  C_ERROR,
                                        'ZTITPC2-PBDSN3'  C_ERROR,
                                        'ZTITPC2-PBDSN4'  C_ERROR,
                                        'ZTITPC2-PBDSN5'  C_ERROR,
                                        'ZTITPC2-PBDS1'  C_ERROR,
                                        'ZTITPC2-PBDS2'  C_ERROR,
                                        'ZTITPC2-PBDS3'  C_ERROR,
                                        'ZTITPC2-PBDS4'  C_ERROR,
                                        'ZTITPC2-PBDS5'  C_ERROR.
*-}기능개선 213478
  ENDIF.

  IF SY-SUBRC NE 0.
    APPEND G_TC_2220_1_WA TO G_TC_2220_1_ITAB.
  ENDIF.
ENDMODULE.                    "TC_2220_1_modify INPUT

*&---------------------------------------------------------------------*
*&      Module  tc_2220_1_mark  INPUT
*&---------------------------------------------------------------------*
*> input module for tc 'TC_2220_1'. do not change this line!
*> mark table
*&---------------------------------------------------------------------*
MODULE TC_2220_1_MARK INPUT.
  IF TC_2220_1-LINE_SEL_MODE = 1 AND
     G_TC_2220_1_WA-FLAG = 'X'.
    LOOP AT G_TC_2220_1_ITAB INTO G_TC_2220_1_WA
      WHERE FLAG = 'X'.
      G_TC_2220_1_WA-FLAG = ''.
      MODIFY G_TC_2220_1_ITAB
        FROM G_TC_2220_1_WA
        TRANSPORTING FLAG.
    ENDLOOP.
    G_TC_2220_1_WA-FLAG = 'X'.
  ENDIF.
  MODIFY G_TC_2220_1_ITAB
    FROM G_TC_2220_1_WA
    INDEX TC_2220_1-CURRENT_LINE
    TRANSPORTING FLAG.
ENDMODULE.                    "TC_2220_1_mark INPUT
*&---------------------------------------------------------------------*
*&      Module  tc_2220_1_user_command  INPUT
*&---------------------------------------------------------------------*
* input module for tc 'TC_2220_1'. do not change this line!
* process user command
*&---------------------------------------------------------------------*
MODULE TC_2220_1_USER_COMMAND INPUT.
  OK_CODE = SY-UCOMM.
  PERFORM USER_OK_TC USING    'TC_2220_1'
                              'G_TC_2220_1_ITAB'
                              'FLAG'
                     CHANGING OK_CODE.
  SY-UCOMM = OK_CODE.

  CLEAR G_COUNT.

  LOOP AT G_TC_2220_1_ITAB INTO G_TC_2220_1_WA.
    ADD 1 TO G_COUNT.
    G_TC_2220_1_WA-PBQIT = G_COUNT.
    MODIFY G_TC_2220_1_ITAB FROM G_TC_2220_1_WA.
  ENDLOOP.

ENDMODULE.                    "TC_2220_1_user_command INPUT

*&---------------------------------------------------------------------*
*&      Module  tc_2220_2_modify  INPUT
*&---------------------------------------------------------------------*
*  input module for tc 'TC_2220_2'. do not change this line!
*  modify table
*&---------------------------------------------------------------------*
MODULE TC_2220_2_MODIFY INPUT.

*-{기능개선 213478 - 구매승인서 특수문자 체크 추가
  IF G_MODE EQ C_CHARC OR
     G_MODE EQ C_CHARM OR
     G_MODE EQ C_CHARY OR
     G_MODE EQ C_CHARO.
*> 사용가능 문자집합 체크.
    PERFORM  CHECK_EDI_AVAILABLE_CHAR2  USING :
                                        'ZTITPC3-PCSNM'  C_ERROR,
                                        'ZTITPC3-PCSZ1'  C_ERROR,
                                        'ZTITPC3-PCSZ2'  C_ERROR,
                                        'ZTITPC3-PCSZ3'  C_ERROR,
                                        'ZTITPC3-PCSZ4'  C_ERROR,
                                        'ZTITPC3-PCSZ5'  C_ERROR,
                                        'ZTITPC3-PCSA1'  C_ERROR,
                                        'ZTITPC3-PCSA2'  C_ERROR,
                                        'ZTITPC3-PCSA3'  C_ERROR,
                                        'ZTITPC3-PCSA4'  C_ERROR,
                                        'ZTITPC3-PCSA5'  C_ERROR.
  ENDIF.
*-}기능개선 213478

  IF ZTITPC3-PCSPD IS INITIAL.
    PERFORM NO_INPUT_CHECK USING 'ZTITPC3' 'PCSPD' C_ERROR.
  ENDIF.

  IF ZTITPC3-PCSPD IS NOT INITIAL.
    IF ZTITPC3-PCSPD > ZTITPC2-PBDED.
      MESSAGE E999 WITH '유효기일이 물품내역 구매일자 이후여야 합니다.'.
    ENDIF.
  ENDIF.

  IF ZTITPC3-PCSPD IS NOT INITIAL.
    IF ZTITPC3-PCSPD > ZTITPC2-PBDSD.
      MESSAGE E999 WITH '선적기일이 물품내역 구매일자 이후여야 합니다.'.
    ENDIF.
  ENDIF.

  MOVE-CORRESPONDING ZTITPC3 TO G_TC_2220_2_WA.
  MODIFY G_TC_2220_2_ITAB  FROM G_TC_2220_2_WA
                          INDEX TC_2220_2-CURRENT_LINE.
  IF SY-SUBRC NE 0.
    APPEND G_TC_2220_2_WA TO G_TC_2220_2_ITAB.
  ENDIF.
ENDMODULE.                    "TC_2220_2_modify INPUT

*&---------------------------------------------------------------------*
*&      Module  tc_2220_2_mark  INPUT
*&---------------------------------------------------------------------*
* input module for tc 'TC_2220_2'. do not change this line!
* mark table
*&---------------------------------------------------------------------*
MODULE TC_2220_2_MARK INPUT.
  IF TC_2220_2-LINE_SEL_MODE = 1 AND
     G_TC_2220_2_WA-FLAG = 'X'.
    LOOP AT G_TC_2220_2_ITAB INTO G_TC_2220_2_WA
      WHERE FLAG = 'X'.
      G_TC_2220_2_WA-FLAG = ''.
      MODIFY G_TC_2220_2_ITAB
        FROM G_TC_2220_2_WA
        TRANSPORTING FLAG.
    ENDLOOP.
    G_TC_2220_2_WA-FLAG = 'X'.
  ENDIF.
  MODIFY G_TC_2220_2_ITAB
    FROM G_TC_2220_2_WA
    INDEX TC_2220_2-CURRENT_LINE
    TRANSPORTING FLAG.
ENDMODULE.                    "TC_2220_2_mark INPUT
*&---------------------------------------------------------------------*
*&      Module  tc_2220_2_user_command  INPUT
*&---------------------------------------------------------------------*
* input module for tc 'TC_2220_2'. do not change this line!
* process user command
*&---------------------------------------------------------------------*
MODULE TC_2220_2_USER_COMMAND INPUT.
  OK_CODE = SY-UCOMM.
  PERFORM USER_OK_TC USING    'TC_2220_2'
                              'G_TC_2220_2_ITAB'
                              'FLAG'
                     CHANGING OK_CODE.
  SY-UCOMM = OK_CODE.

  CLEAR G_COUNT.
  LOOP AT G_TC_2220_2_ITAB INTO G_TC_2220_2_WA.
    ADD 1 TO G_COUNT.
    G_TC_2220_2_WA-PCQIT = G_COUNT.
    MODIFY G_TC_2220_2_ITAB FROM G_TC_2220_2_WA.
  ENDLOOP.

*> F2 Funtion key Event시 해당 필드의 정보 display
  PERFORM  DOUBLE_CLICK_EVENT.

ENDMODULE.                    "TC_2220_2_user_command INPUT
*&---------------------------------------------------------------------*
*&      Module  pAI_SET_scr2210_sub1_subscreen  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE PAI_SET_SCR2210_SUB1_SUBSCREEN INPUT.

  G_CALL_PROG        =  C_COMMON_PROG.
  G_CALL_SUBSCREEN   =  C_SCR0300.

  CALL FUNCTION 'Z_TI_OTHERS_TEXT_EXPORT'
    EXPORTING
      LCITY  = C_CHAR7
      MODE   = G_MODE
    TABLES
      IT_TAB = IT_LCTEXT.

ENDMODULE.                 " pAI_SET_scr2210_sub1_subscreen  INPUT

*&---------------------------------------------------------------------*
*&      Module  pAI_SET_scr2210_sub2_subscreen  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE PAI_SET_SCR2210_SUB2_SUBSCREEN INPUT.

  G_CALL_PROG        =  C_COMMON_PROG.
  G_CALL_SUBSCREEN   =  C_SCR0300.

  CALL FUNCTION 'Z_TI_OTHERS_TEXT_EXPORT'
    EXPORTING
      LCITY  = C_CHAR8
      MODE   = G_MODE
    TABLES
      IT_TAB = IT_LCTEXT.

ENDMODULE.                 " pAI_SET_scr2210_sub2_subscreen  INPUT
*&---------------------------------------------------------------------*
*&      Module  pAI_SET_scr2210_sub3_subscreen  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE PAI_SET_SCR2210_SUB3_SUBSCREEN INPUT.

  G_CALL_PROG        =  C_COMMON_PROG.
  G_CALL_SUBSCREEN   =  C_SCR0300.

  CALL FUNCTION 'Z_TI_OTHERS_TEXT_EXPORT'
    EXPORTING
      LCITY  = C_CHAR9
      MODE   = G_MODE
    TABLES
      IT_TAB = IT_LCTEXT.

ENDMODULE.                 " pAI_SET_scr2210_sub3_subscreen  INPUT

*&---------------------------------------------------------------------*
*&      Module  user_command_2210  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_2210 INPUT.

  IF G_MODE NE C_CHARS.
*> 기타 추가문서 .
    IF G_MODE EQ C_CHARC OR
       G_MODE EQ C_CHARM OR
       G_MODE EQ C_CHARY.
      G_DISPLAY1 = C_FALSE.
    ELSE.
      G_DISPLAY1 = C_TRUE.
    ENDIF.

    IF OK_CODE EQ 'ZTICOPY_FROM1'.

      CALL FUNCTION 'Z_TI_GET_OTHER_DOCUMENT_TEXT'
        EXPORTING
          IM_DISPLAY = G_DISPLAY1
        IMPORTING
          P_ANSWER   = G_ANSWER
        TABLES
          XZTISIG52  = XZTISIG52
        EXCEPTIONS
          NOT_FOUND  = 1
          OTHERS     = 2.
      IF SY-SUBRC <> 0.
        SET CURSOR FIELD 'PB_COPY_FROM1'.
        MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
                WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
      ENDIF.

      IF G_ANSWER EQ 'Y'.
*> Long text editor --> Internal table
        PERFORM  GET_EDI_TEXTID_AND_TEXT.

        SORT XZTISIG52 BY OUTSQ.
        DESCRIBE TABLE G_TC_2212_ITAB LINES G_COUNT.
        LOOP AT XZTISIG52 WHERE BOX EQ C_TRUE.
          PERFORM  SET_OTHERS_DOCUMENTS_TEXT USING : XZTISIG52-LTEXT.
        ENDLOOP.
*> Screen용 Internal table --> ztitlc2 internal table
        PERFORM  P8111_EDI_ITEM_TABLE_READ.
*> Set EDI 문구 ztitlc2 internal table --> Text table.
        PERFORM  SET_EDI_TEXTID_AND_TEXT.
      ENDIF.
      SET CURSOR FIELD 'PB_COPY_FROM1'.
    ENDIF.

*> 기타 부가조건 .
    IF OK_CODE EQ 'ZTICOPY_FROM2'.
      CALL FUNCTION 'Z_TI_GET_OTHER_CONDITIONS_TEXT'
        EXPORTING
          IM_DISPLAY = G_DISPLAY1
        IMPORTING
          P_ANSWER   = G_ANSWER
        TABLES
          XZTISIG51  = XZTISIG51
        EXCEPTIONS
          NOT_FOUND  = 1
          OTHERS     = 2.
      IF SY-SUBRC <> 0.
        SET CURSOR FIELD 'PB_COPY_FROM2'.
        MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
                WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
      ENDIF.
      IF G_ANSWER EQ 'Y'.
*> Long text editor --> Internal table
        PERFORM  GET_EDI_TEXTID_AND_TEXT.

        SORT XZTISIG51 BY OUTSQ.
        DESCRIBE TABLE G_TC_2213_ITAB LINES G_COUNT.
        LOOP AT XZTISIG51 WHERE BOX EQ C_TRUE.
          PERFORM  SET_OTHERS_CONDITIONS_TEXT USING XZTISIG51-LTEXT.
        ENDLOOP.
*> Screen용 Internal table --> ztitlc2 internal table
        PERFORM  P8111_EDI_ITEM_TABLE_READ.
*> Set EDI 문구 ztitlc2 internal table --> Text table.
        PERFORM  SET_EDI_TEXTID_AND_TEXT.
      ENDIF.
      SET CURSOR FIELD 'PB_COPY_FROM2'.
    ENDIF.
*>
* 2010.10.13 CSR : C20100928_44287
* : 전상우D 요청 :Other Document 체크 메뉴얼세팅
*    CLEAR g_odycd.
*    DESCRIBE TABLE g_tc_2212_itab LINES g_line.
*    IF g_line EQ 0.
*      g_odycd = space.
*    ELSE.
*      g_odycd = 'X'.
*    ENDIF.
*>

* 2010.10.13 CSR : C20100928_44287
* : 전상우D 요청 :Other Document 체크 메뉴얼세팅
*    DESCRIBE TABLE g_tc_2213_itab LINES g_line.
*    CLEAR : g_mate5.
*    IF g_line EQ 0.
*      g_mate5 = space.
*    ELSE.
*      g_mate5 = 'X'.
*    ENDIF.

*    ztitlc1-odycd = g_odycd.
*    ztitlc1-mate5 = g_mate5.
  ENDIF.

*> F2 Funtion key Event시 해당 필드의 정보 display
  PERFORM  DOUBLE_CLICK_EVENT.

ENDMODULE.                 " user_command_2210  INPUT
*&---------------------------------------------------------------------*
*&      Module  user_command_2211  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_2211 INPUT.
*> F2 Funtion key Event시 해당 필드의 정보 display
  PERFORM  DOUBLE_CLICK_EVENT.
ENDMODULE.                 " user_command_2211  INPUT
*&---------------------------------------------------------------------*
*&      Module  user_command_2220  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_2220 INPUT.
*> F2 Funtion key Event시 해당 필드의 정보 display
  PERFORM  DOUBLE_CLICK_EVENT.
ENDMODULE.                 " user_command_2220  INPUT
*&---------------------------------------------------------------------*
*&      Module  user_command_2230  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_2230 INPUT.
*> F2 Funtion key Event시 해당 필드의 정보 display
  PERFORM  DOUBLE_CLICK_EVENT.
ENDMODULE.                 " user_command_2230  INPUT
*&---------------------------------------------------------------------*
*&      Module  user_command_2231  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_2231 INPUT.
*> F2 Funtion key Event시 해당 필드의 정보 display
  PERFORM  DOUBLE_CLICK_EVENT.
ENDMODULE.                 " user_command_2231  INPUT
*&---------------------------------------------------------------------*
*&      Module  user_command_2220  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_2240 INPUT.
*> F2 Funtion key Event시 해당 필드의 정보 display
  PERFORM  DOUBLE_CLICK_EVENT.
ENDMODULE.                 " user_command_2240  INPUT
*&---------------------------------------------------------------------*
*&      Module  GET_SURSOR_POSITION  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE GET_SURSOR_POSITION INPUT.
*> F2 Funtion key Event시 해당 필드의 정보 display
  PERFORM  DOUBLE_CLICK_EVENT.
ENDMODULE.                 " GET_SURSOR_POSITION  INPUT
*&---------------------------------------------------------------------*
*>  input module for tc 'TC_2211'. do not change this line!
*>  modify table
*&---------------------------------------------------------------------*
MODULE TC_2211_MODIFY INPUT.
  MOVE-CORRESPONDING ZTITLC2 TO G_TC_2211_WA.
  MODIFY G_TC_2211_ITAB  FROM G_TC_2211_WA
                        INDEX TC_2211-CURRENT_LINE.
  IF SY-SUBRC NE 0.
    APPEND G_TC_2211_WA TO G_TC_2211_ITAB.
  ENDIF.

ENDMODULE.                    "TC_2211_modify INPUT
*&---------------------------------------------------------------------*
*> input module for tc 'TC_2211'. do not change this line!
*> mark table
*&---------------------------------------------------------------------*
MODULE TC_2211_MARK INPUT.
  IF TC_2211-LINE_SEL_MODE = 1 AND
     G_TC_2211_WA-FLAG = 'X'.
    LOOP AT G_TC_2211_ITAB INTO G_TC_2211_WA
      WHERE FLAG = 'X'.
      G_TC_2211_WA-FLAG = ''.
      MODIFY G_TC_2211_ITAB
        FROM G_TC_2211_WA
        TRANSPORTING FLAG.
    ENDLOOP.
    G_TC_2211_WA-FLAG = 'X'.
  ENDIF.
  MODIFY G_TC_2211_ITAB
    FROM G_TC_2211_WA
    INDEX TC_2211-CURRENT_LINE
    TRANSPORTING FLAG.
ENDMODULE.                    "TC_2211_mark INPUT

*&---------------------------------------------------------------------*
*>  input module for tc 'TC_0300'. do not change this line!
*>  process user command
*&---------------------------------------------------------------------*
MODULE TC_2211_USER_COMMAND INPUT.
*> F2 Funtion key Event시 해당 필드의 정보 display
  PERFORM  DOUBLE_CLICK_EVENT.

  OK_CODE = SY-UCOMM.

  PERFORM USER_OK_TC USING    'TC_2211'
                                'G_TC_2211_ITAB'
                                'FLAG'
                       CHANGING OK_CODE.
  SY-UCOMM = OK_CODE.

  CLEAR G_COUNT.

  LOOP AT G_TC_2211_ITAB INTO G_TC_2211_WA.
    ADD 1 TO G_COUNT.
    G_TC_2211_WA-QITNO = G_COUNT.
    MODIFY G_TC_2211_ITAB FROM G_TC_2211_WA.
  ENDLOOP.

*> F2 Funtion key Event시 해당 필드의 정보 display
  PERFORM  DOUBLE_CLICK_EVENT.


ENDMODULE.                    "TC_2211_user_command INPUT
*&---------------------------------------------------------------------*
*>  input module for tc 'TC_2212'. do not change this line!
*>  modify table
*&---------------------------------------------------------------------*
MODULE TC_2212_MODIFY INPUT.

  MOVE-CORRESPONDING ZTITLC2 TO G_TC_2212_WA.
  MODIFY G_TC_2212_ITAB  FROM G_TC_2212_WA
                        INDEX TC_2212-CURRENT_LINE.
  IF SY-SUBRC NE 0.
    APPEND G_TC_2212_WA TO G_TC_2212_ITAB.
  ENDIF.

ENDMODULE.                    "TC_2212_modify INPUT
*&---------------------------------------------------------------------*
*> input module for tc 'TC_2212'. do not change this line!
*> mark table
*&---------------------------------------------------------------------*
MODULE TC_2212_MARK INPUT.
  IF TC_2212-LINE_SEL_MODE = 1 AND
     G_TC_2212_WA-FLAG = 'X'.
    LOOP AT G_TC_2212_ITAB INTO G_TC_2212_WA
      WHERE FLAG = 'X'.
      G_TC_2212_WA-FLAG = ''.
      MODIFY G_TC_2212_ITAB
        FROM G_TC_2212_WA
        TRANSPORTING FLAG.
    ENDLOOP.
    G_TC_2212_WA-FLAG = 'X'.
  ENDIF.
  MODIFY G_TC_2212_ITAB
    FROM G_TC_2212_WA
    INDEX TC_2212-CURRENT_LINE
    TRANSPORTING FLAG.
ENDMODULE.                    "TC_2212_mark INPUT

*&---------------------------------------------------------------------*
*>  input module for tc 'TC_2212'. do not change this line!
*>  process user command
*&---------------------------------------------------------------------*
MODULE TC_2212_USER_COMMAND INPUT.
*> F2 Funtion key Event시 해당 필드의 정보 display
  PERFORM  DOUBLE_CLICK_EVENT.

  OK_CODE = SY-UCOMM.

  PERFORM USER_OK_TC USING    'TC_2212'
                              'G_TC_2212_ITAB'
                              'FLAG'
                     CHANGING OK_CODE.
  SY-UCOMM = OK_CODE.

  CLEAR G_COUNT.
  LOOP AT G_TC_2212_ITAB INTO G_TC_2212_WA.
    ADD 1 TO G_COUNT.
    G_TC_2212_WA-QITNO = G_COUNT.
    MODIFY G_TC_2212_ITAB FROM G_TC_2212_WA.
  ENDLOOP.
  CLEAR G_ODYCD.
  DESCRIBE TABLE G_TC_2212_ITAB LINES G_LINE.
  IF G_LINE EQ 0.
    G_ODYCD = SPACE.
  ELSE.
    G_ODYCD = 'X'.
  ENDIF.
*> F2 Funtion key Event시 해당 필드의 정보 display
  PERFORM  DOUBLE_CLICK_EVENT.

ENDMODULE.                    "TC_2212_user_command INPUT
*&---------------------------------------------------------------------*
*>  input module for tc 'TC_2213'. do not change this line!
*>  modify table
*&---------------------------------------------------------------------*
MODULE TC_2213_MODIFY INPUT.
  MOVE-CORRESPONDING ZTITLC2 TO G_TC_2213_WA.
  MODIFY G_TC_2213_ITAB  FROM G_TC_2213_WA
                        INDEX TC_2213-CURRENT_LINE.
  IF SY-SUBRC NE 0.
    APPEND G_TC_2213_WA TO G_TC_2213_ITAB.
  ENDIF.

ENDMODULE.                    "TC_2213_modify INPUT
*&---------------------------------------------------------------------*
*> input module for tc 'TC_2213'. do not change this line!
*> mark table
*&---------------------------------------------------------------------*
MODULE TC_2213_MARK INPUT.
  IF TC_2213-LINE_SEL_MODE = 1 AND
     G_TC_2213_WA-FLAG = 'X'.
    LOOP AT G_TC_2213_ITAB INTO G_TC_2213_WA
      WHERE FLAG = 'X'.
      G_TC_2213_WA-FLAG = ''.
      MODIFY G_TC_2213_ITAB
        FROM G_TC_2213_WA
        TRANSPORTING FLAG.
    ENDLOOP.
    G_TC_2213_WA-FLAG = 'X'.
  ENDIF.
  MODIFY G_TC_2213_ITAB
    FROM G_TC_2213_WA
    INDEX TC_2213-CURRENT_LINE
    TRANSPORTING FLAG.
ENDMODULE.                    "TC_2213_mark INPUT

*&---------------------------------------------------------------------*
*>  input module for tc 'TC_2213'. do not change this line!
*>  process user command
*&---------------------------------------------------------------------*
MODULE TC_2213_USER_COMMAND INPUT.
*> F2 Funtion key Event시 해당 필드의 정보 display
  PERFORM  DOUBLE_CLICK_EVENT.

  OK_CODE = SY-UCOMM.

  PERFORM USER_OK_TC USING    'TC_2213'
                              'G_TC_2213_ITAB'
                              'FLAG'
                     CHANGING OK_CODE.

  SY-UCOMM = OK_CODE.

  CLEAR G_COUNT.
  LOOP AT G_TC_2213_ITAB INTO G_TC_2213_WA.
    ADD 1 TO G_COUNT.
    G_TC_2213_WA-QITNO = G_COUNT.
    MODIFY G_TC_2213_ITAB FROM G_TC_2213_WA.
  ENDLOOP.
*> F2 Funtion key Event시 해당 필드의 정보 display
  PERFORM  DOUBLE_CLICK_EVENT.

ENDMODULE.                    "TC_2213_user_command INPUT

*&---------------------------------------------------------------------*
*> input module for tc 'TC_2214'. do not change this line!
*> modify table
*&---------------------------------------------------------------------*
MODULE TC_2214_MODIFY INPUT.
  MOVE-CORRESPONDING ZTITLC3 TO G_TC_2214_WA.
  MODIFY G_TC_2214_ITAB  FROM G_TC_2214_WA
                        INDEX TC_2214-CURRENT_LINE.
  IF SY-SUBRC NE 0.
    APPEND G_TC_2214_WA TO G_TC_2214_ITAB.
  ENDIF.

ENDMODULE.                    "TC_2214_modify INPUT

*&---------------------------------------------------------------------*
*> input module for tc 'TC_2214'. do not change this line!
*> mark table
*&---------------------------------------------------------------------*
MODULE TC_2214_MARK INPUT.
  IF TC_2214-LINE_SEL_MODE = 1 AND
     G_TC_2214_WA-FLAG = 'X'.
    LOOP AT G_TC_2214_ITAB INTO G_TC_2214_WA
      WHERE FLAG = 'X'.
      G_TC_2214_WA-FLAG = ''.
      MODIFY G_TC_2214_ITAB
        FROM G_TC_2214_WA
        TRANSPORTING FLAG.
    ENDLOOP.
    G_TC_2214_WA-FLAG = 'X'.
  ENDIF.
  MODIFY G_TC_2214_ITAB
    FROM G_TC_2214_WA
    INDEX TC_2214-CURRENT_LINE
    TRANSPORTING FLAG.
ENDMODULE.                    "TC_2214_mark INPUT

*&---------------------------------------------------------------------*
*> input module for tc 'TC_2214'. do not change this line!
*> process user command
*&---------------------------------------------------------------------*
MODULE TC_2214_USER_COMMAND INPUT.
*> F2 Funtion key Event시 해당 필드의 정보 display
  PERFORM  DOUBLE_CLICK_EVENT.

  OK_CODE = SY-UCOMM.
  PERFORM USER_OK_TC USING    'TC_2214'
                              'G_TC_2214_ITAB'
                              'FLAG'
                     CHANGING OK_CODE.
  SY-UCOMM = OK_CODE.

  CLEAR G_COUNT.
  LOOP AT G_TC_2214_ITAB INTO G_TC_2214_WA.
    ADD 1 TO G_COUNT.
    G_TC_2214_WA-IMASQ = G_COUNT.
    MODIFY G_TC_2214_ITAB FROM G_TC_2214_WA.
  ENDLOOP.

*> F2 Funtion key Event시 해당 필드의 정보 display
  PERFORM  DOUBLE_CLICK_EVENT.

ENDMODULE.                    "TC_2214_user_command INPUT
*&---------------------------------------------------------------------*
*>  input module for tc 'TC_2216'. do not change this line!
*>  modify table
*&---------------------------------------------------------------------*
MODULE TC_2216_MODIFY INPUT.
  MOVE-CORRESPONDING ZTITLC2 TO G_TC_2216_WA.
  MODIFY G_TC_2216_ITAB  FROM G_TC_2216_WA
                        INDEX TC_2216-CURRENT_LINE.
  IF SY-SUBRC NE 0.
    APPEND G_TC_2216_WA TO G_TC_2216_ITAB.
  ENDIF.
*
ENDMODULE.                    "TC_2216_modify INPUT
*&---------------------------------------------------------------------*
*> input module for tc 'TC_2216'. do not change this line!
*> mark table
*&---------------------------------------------------------------------*
MODULE TC_2216_MARK INPUT.
  IF TC_2216-LINE_SEL_MODE = 1 AND
     G_TC_2216_WA-FLAG = 'X'.
    LOOP AT G_TC_2216_ITAB INTO G_TC_2216_WA
      WHERE FLAG = 'X'.
      G_TC_2216_WA-FLAG = ''.
      MODIFY G_TC_2216_ITAB
        FROM G_TC_2216_WA
        TRANSPORTING FLAG.
    ENDLOOP.
    G_TC_2216_WA-FLAG = 'X'.
  ENDIF.
  MODIFY G_TC_2216_ITAB
    FROM G_TC_2216_WA
    INDEX TC_2216-CURRENT_LINE
    TRANSPORTING FLAG.
ENDMODULE.                    "TC_2216_mark INPUT

*&---------------------------------------------------------------------*
*>  input module for tc 'TC_2216'. do not change this line!
*>  process user command
*&---------------------------------------------------------------------*
MODULE TC_2216_USER_COMMAND INPUT.
*> F2 Funtion key Event시 해당 필드의 정보 display
  PERFORM  DOUBLE_CLICK_EVENT.

  OK_CODE = SY-UCOMM.

  PERFORM USER_OK_TC USING    'TC_2216'
                              'G_TC_2216_ITAB'
                              'FLAG'
                     CHANGING OK_CODE.

  SY-UCOMM = OK_CODE.

  CLEAR G_COUNT.
  LOOP AT G_TC_2216_ITAB INTO G_TC_2216_WA.
    ADD 1 TO G_COUNT.
    G_TC_2216_WA-QITNO = G_COUNT.
    MODIFY G_TC_2216_ITAB FROM G_TC_2216_WA.
  ENDLOOP.

*> F2 Funtion key Event시 해당 필드의 정보 display
  PERFORM  DOUBLE_CLICK_EVENT.

ENDMODULE.                    "TC_2216_user_command INPUT
*&---------------------------------------------------------------------*
*&      Form  check_document_status
*&---------------------------------------------------------------------*
*       업무영역별 Status Check.
*----------------------------------------------------------------------*
FORM CHECK_DOCUMENT_STATUS .

  DATA: L_DDTEXT  LIKE G_DDTEXT,
        L_DDTEXT1 LIKE G_DDTEXT.

*> 수입 IMG Setting
  SELECT SINGLE *
    FROM ZTITIG00
   WHERE BUKRS EQ ZTITRQK-BUKRS.
  IF SY-SUBRC NE 0.
    MESSAGE E035 WITH ZTITRQK-BUKRS.
  ENDIF.

*> 문서상태 Fixed value read.
  PERFORM  DDIC_DOMAIN_VALUE_TEXT_READ USING 'ZTIDOCST1'
                                             SY-LANGU
                                             ZTITRQS-DOCST
                                             G_DDTEXT
                                             C_SUCCESS.
  L_DDTEXT = G_DDTEXT.
*> Status check.
*> Ammend 생성일 경우.
  IF SY-TCODE EQ C_CREATE_A.
    IF ZTITRQS-DOCST NE C_CHARO.
      MESSAGE E114 WITH ZTITRQS-REQNO ZTITRQS-AMDSQ G_DDTEXT.
      EXIT.
    ENDIF.
    IF ZTITRQS-AMDSQ NE ZTITRQK-LSTAS.
      MESSAGE E115 WITH ZTITRQS-AMDSQ ZTITRQK-LSTAS.
      EXIT.
    ENDIF.
    IF NOT ( ZTITRQK-REQTY EQ 'LC' OR
             ZTITRQK-REQTY EQ 'LO' OR
             ZTITRQK-REQTY EQ 'PU' ).
      PERFORM  DDIC_DOMAIN_VALUE_TEXT_READ USING 'ZTIREQTY'
                                                SY-LANGU
                                                ZTITRQK-REQTY
                                                L_DDTEXT
                                                C_SUCCESS.

      MESSAGE E116 WITH L_DDTEXT.
    ENDIF.
*> 종료여부.
    IF ZTITRQK-DCEND EQ C_TRUE.
      MESSAGE E923 WITH ZTITRQK-REQNO.
    ENDIF.
  ENDIF.

  CASE ZTITRQS-DOCST.
    WHEN SPACE.  ">의뢰대상.
      IF G_MODE EQ C_CHARA OR
         G_MODE EQ C_CHARY OR
         G_MODE EQ C_CHARO.
        MESSAGE E919 WITH G_DDTEXT.
      ENDIF.
    WHEN 'C'.    ">수입의뢰.
      CASE ZTITIG00-RQPCS.
        WHEN C_CHARA OR C_CHARB.  ">접수단계사용.
          IF G_MODE EQ C_CHARY OR G_MODE EQ C_CHARO.
            MESSAGE E919 WITH G_DDTEXT.
          ENDIF.
          IF G_MODE EQ C_CHARM.
            MESSAGE W921 WITH G_DDTEXT.
          ENDIF.
        WHEN C_CHARC OR C_CHARD.  ">은행배정단계사용.
          IF G_MODE EQ C_CHARA OR G_MODE EQ C_CHARO.
            MESSAGE E939 WITH L_DDTEXT1.
          ENDIF.
          IF G_MODE EQ C_CHARM.
            MESSAGE W921 WITH G_DDTEXT.
          ENDIF.
        WHEN C_CHARE.             ">개설등록만 사용.
          IF G_MODE EQ C_CHARY OR G_MODE EQ C_CHARA.
*            l_ddtext1
            MESSAGE E919 WITH G_DDTEXT.
          ENDIF.
          IF G_MODE EQ C_CHARM.
            MESSAGE W921 WITH G_DDTEXT.
          ENDIF.
        WHEN OTHERS.
      ENDCASE.

    WHEN 'A'.    ">접수완료.
      IF G_MODE EQ C_CHARM OR G_MODE EQ C_CHARD OR
         G_MODE EQ C_CHARO.
        MESSAGE E919 WITH G_DDTEXT.
      ENDIF.
      IF G_MODE EQ C_CHARA.
        MESSAGE W921 WITH G_DDTEXT.
      ENDIF.
    WHEN 'Y'.    ">개설신청.
      IF G_MODE EQ C_CHARM OR G_MODE EQ C_CHARD OR
         G_MODE EQ C_CHARA.
        MESSAGE E919 WITH G_DDTEXT.
      ENDIF.

      IF G_MODE EQ C_CHARY OR G_MODE EQ C_CHARO.
*        IF NOT ZTITRQS-sndst IS INITIAL.
*> EDI 송수신 상태 Fixed value read.
        PERFORM  DDIC_DOMAIN_VALUE_TEXT_READ
                                    USING 'ZTISNDST'
                                           SY-LANGU
                                           ZTITRQS-SNDST
                                           G_DDTEXT
                                           C_SUCCESS.
        IF G_MODE EQ C_CHARY.
          IF ZTITRQS-SNDST EQ C_CHARW OR
*             ztitrqs-sndst EQ c_chars OR
             ZTITRQS-SNDST EQ C_CHARR.
            MESSAGE E919 WITH G_DDTEXT.
          ELSE.
            MESSAGE W920 WITH G_DDTEXT.
          ENDIF.
        ENDIF.
        IF G_MODE EQ C_CHARO.
          IF ZTITRQS-SNDST EQ C_CHARW OR
*             ZTITRQS-sndst EQ c_chars OR
             ZTITRQS-SNDST EQ C_CHARR.
            MESSAGE E919 WITH G_DDTEXT.
          ELSE.
            MESSAGE W920 WITH G_DDTEXT.
          ENDIF.
        ENDIF.
*        ENDIF.
      ENDIF.
    WHEN 'W'.    ">신청서 작성.
      IF G_MODE EQ C_CHARM OR G_MODE EQ C_CHARD.
*        MESSAGE e919 WITH g_ddtext.
        MESSAGE W921 WITH G_DDTEXT.
      ELSEIF G_MODE EQ C_CHARA.
        MESSAGE W921 WITH G_DDTEXT.
      ELSEIF G_MODE EQ C_CHARY OR G_MODE EQ C_CHARO.
        MESSAGE W921 WITH G_DDTEXT.
      ENDIF.
    WHEN 'O'.    ">개설완료.
      IF G_MODE EQ C_CHARM OR G_MODE EQ C_CHARD OR
         G_MODE EQ C_CHARA OR G_MODE EQ C_CHARY.
        MESSAGE E919 WITH G_DDTEXT.
      ENDIF.
      IF G_MODE EQ C_CHARG.
        IF ZTITRQK-REQTY NE C_LC.
          MESSAGE E136 WITH ZTITRQK-REQTY.
        ENDIF.
        IF ZTITRQK-DCEND EQ C_TRUE.
          MESSAGE S923 WITH ZTITRQK-REQNO.
        ENDIF.
      ELSEIF G_MODE NE C_CHARS.
        IF ZTITRQS-SNDST NE C_CHARM.
          PERFORM  DDIC_DOMAIN_VALUE_TEXT_READ
                                    USING 'ZTISNDST'
                                           SY-LANGU
                                           ZTITRQS-SNDST
                                           G_DDTEXT
                                           C_SUCCESS.

*               ZTITRQS-sndst EQ c_charR OR
*               ZTITRQS-sndst EQ c_chars OR
*               ZTITRQS-sndst EQ c_charr.
*              MESSAGE e919 WITH g_ddtext.
          MESSAGE W920 WITH G_DDTEXT.
        ENDIF.
*  > 종료여부.
        IF ZTITRQK-DCEND EQ C_TRUE.
          MESSAGE E923 WITH ZTITRQK-REQNO.
        ENDIF.
      ENDIF.
    WHEN 'N'.    ">개설취소.
      IF G_MODE EQ C_CHARM OR G_MODE EQ C_CHARD OR
         G_MODE EQ C_CHARA.
        MESSAGE E919 WITH G_DDTEXT.
      ENDIF.
*> 종료여부.
      IF ZTITRQK-DCEND EQ C_TRUE.
        MESSAGE E923 WITH ZTITRQK-REQNO.
      ENDIF.

    WHEN 'R'.    ">접수반려.
      IF G_MODE EQ C_CHARY OR G_MODE EQ C_CHARO.
        MESSAGE E919 WITH G_DDTEXT.
      ENDIF.
    WHEN 'G'.
      IF G_MODE NE C_CHARO.
        MESSAGE E919 WITH G_DDTEXT.
      ENDIF.
*
    WHEN OTHERS.
  ENDCASE.

*> Release 상태 체크...
  PERFORM CHECK_REQUEST_RELEASE.

  MESSAGE S922 WITH L_DDTEXT.

  IF ZTITRQK-DCEND EQ C_TRUE.
    MESSAGE I923 WITH ZTITRQS-REQNO.
  ENDIF.

ENDFORM.                    " check_document_status
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_2121  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_2121 INPUT.
*> F2 Funtion key Event시 해당 필드의 정보 display
  PERFORM  DOUBLE_CLICK_EVENT.

ENDMODULE.                 " USER_COMMAND_2121  INPUT
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_2122  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_2122 INPUT.

  OK_CODE = SY-UCOMM.
  PERFORM USER_OK_TC USING    'TC_2122'
                              'G_TC_2122_ITAB'
                              'FLAG'
                     CHANGING OK_CODE.
  SY-UCOMM = OK_CODE.
*> F2 Funtion key Event시 해당 필드의 정보 display
  PERFORM  DOUBLE_CLICK_EVENT.

ENDMODULE.                 " USER_COMMAND_2122  INPUT
*&---------------------------------------------------------------------*
*&      Module  pbo_scr0100_Import_memory  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE PBO_SCR0100_IMPORT_MEMORY OUTPUT.

  IF SY-CALLD EQ C_TRUE .
*> Batch Input일 경우.
    IF SY-BINPT EQ C_TRUE.
      FREE MEMORY ID G_INDXKEY.

      GS_INDX-AEDAT = SY-DATLO.
      GS_INDX-USERA = SY-UNAME.

      IMPORT G_TCODE = G_TCODE1
             MSG01   = G_MSG01
             MSG02   = G_MSG02
             FROM DATABASE INDX(ZM)  ID G_INDXKEY
                                     TO GS_INDX.

      G_TCODE = G_TCODE1.
    ENDIF.

    IF SY-TCODE NE C_CREATE.
      G_TCODE = SY-TCODE.
    ENDIF.

    CASE G_TCODE.
      WHEN 'ZTIR000'.  ">수입의뢰 Due List(기타)

*      WHEN 'ZTIR003'.  ">수입의뢰 Due List(위탁자재)
*        IF sy-binpt EQ c_true.
*          IMPORT it_rkwa  = it_rkwa
*                 FROM DATABASE indx(zm)  ID g_indxkey
*                                         TO gs_indx.
*        ENDIF.
*
*        IF it_rkwa[] IS INITIAL.
*          MESSAGE a003(ok).
*        ENDIF.
*        g_tcode1 = g_tcode.
*        g_tcode  = c_create.
*        g_mode   = c_charc.
      WHEN C_DUE_LIST_TT.  ">수입의뢰 Due List(사후송금).
        IF IT_ZTISBLIT[] IS INITIAL.
          MESSAGE A003(OK).
        ENDIF.
        G_TCODE1 = G_TCODE.
        G_TCODE  = C_CREATE.
        G_MODE   = C_CHARC.
      WHEN C_DUE_LIST_RT.  ">수입의뢰 Due List(유보금).
        IF IT_ZTISBLIT[] IS INITIAL.
          MESSAGE A003(OK).
        ENDIF.
        G_TCODE1 = G_TCODE.
        G_TCODE  = C_CREATE.
        G_MODE   = C_CHARC.
      WHEN OTHERS.
    ENDCASE.
*    FREE MEMORY ID g_indxkey.
  ELSE.
*    CLEAR: g_tcode.
    G_TCODE = SY-TCODE.
  ENDIF.

ENDMODULE.                 " pbo_scr0100_Import_memory  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_2235  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_2235 INPUT.

*> F2 Funtion key Event시 해당 필드의 정보 display
  PERFORM  DOUBLE_CLICK_EVENT.

ENDMODULE.                 " USER_COMMAND_2235  INPUT
*&---------------------------------------------------------------------*
*&      Module  pai_scr2121_check_input_value  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE PAI_SCR2121_CHECK_INPUT_VALUE INPUT.

  DATA: L_DATE LIKE SY-DATLO,
        L_DAY  TYPE I.

  CHECK: G_MODE EQ C_CHARC OR  ">생성.
         G_MODE EQ C_CHARM OR  ">변경.
         G_MODE EQ C_CHARY OR  ">신청.
         G_MODE EQ C_CHARO.    ">개설시만.

  CHECK: OK_CODE NE 'ZTISHOWMSG'.

**> WBS 요소 Input Check.
*  IF ztitrqk-reqty EQ c_pu.
*    IF ztitrqk-pspnr IS INITIAL.
*      PERFORM no_input_check USING 'ZTITRQK' 'PSPNR' c_error.
*    ENDIF.
*  ELSE.
*    IF g_pspnr_chk IS INITIAL.
*      IF ztitrqk-pspnr IS INITIAL. "WBS 요소.
*        PERFORM  set_wbs_element  USING c_warning.
*        g_pspnr_chk  =  c_true.
*      ENDIF.
*    ENDIF.
*  ENDIF.

*S__ 신용장 변경에 따른 수정 20181010 BY SDW
  IF ZTITRQS-AMDSQ GT C_ZERO.

  ELSE.
    IF ZTITLC1-CHGER = '16' OR ZTITLC1-CHGER = '19'.
      MESSAGE ID 'ZMTE' TYPE 'E'
         NUMBER 997 WITH '수수료 부담자 Code'
                         ZTITLC1-CHGER
                        '는 입력할 수 없는 Old Code입니다.'.
    ENDIF.
  ENDIF.
*E__ 신용장 변경에 따른 수정 20181010 BY SDW

*----------------------------------------------------------------------*
*                M O D I F I C A T I O N   L O G                       *
*----------------------------------------------------------------------*
* Date         Programmer       Transport#  Description                *
*----------------------------------------------------------------------*
* 2004.10.18   Sung-ho Maeng                사용여부 Check             *
*----------------------------------------------------------------------*
*> 수입자재구분.
*  IF ztitrqk-impty IS INITIAL.
*    PERFORM no_input_check USING 'ZTITRQK' 'IMPTY' c_error.
*  ENDIF.
*----------------------------< INSERT END >---------------------------*
*> 최종선적일자.
  IF ZTITRQS-LSDAT IS INITIAL.
    PERFORM  SET_LAST_SHIPPING_DATE USING C_WARNING.
  ENDIF.

*> 공통 필드 체크.
  IF ZTITRQS-ZTERM IS INITIAL.   "지급조건.
    PERFORM NO_INPUT_CHECK USING 'ZTITRQS' 'ZTERM' C_ERROR.
  ELSE.
    READ TABLE IT_ZTITIG02 WITH KEY ZTERM = ZTITRQS-ZTERM.
    IF SY-SUBRC EQ 0.
      ZTITRQK-ILCTY    = IT_ZTITIG02-ILCTY.
      ZTITRQK-USCDY    = IT_ZTITIG02-USCDY.
*> 050713 jp, park 수정.
*      ztitrqs-pagrt    = it_ztitig02-pagrt.
      IF ZTITRQS-PAGRT IS INITIAL.
        ZTITRQS-PAGRT    = IT_ZTITIG02-PAGRT.
      ENDIF.
*-------------------->
    ELSE.
      "--> [가온] 선급금/잔금 처리 위한 예외적용
      IF ZTITRQS-WERKS+0(1) = '6' AND ZTITRQS-EBELN = '4504235179'.
      ELSE.
        MESSAGE E164 WITH ZTITRQS-ZTERM.
      ENDIF.
      "<-- [가온] 선급금/잔금 처리 위한 예외적용
    ENDIF.
  ENDIF.

* 20060411 simcho By C2006040601000001033
  DATA LV_PERNR LIKE ZZPA0001-PERNR. "TR-HR
  IF ZTITRQS-SETLR IS INITIAL.
*    MESSAGE w999 WITH '결재자 입력이 안되었습니다.진행하시겠습니까?' .
  ELSE.
    CLEAR ZZPA0001. "TR-HR
    SELECT SINGLE PERNR
      INTO LV_PERNR
      FROM ZZPA0001 "TR-HR
     WHERE PERNR = ZTITRQS-SETLR.
    IF SY-SUBRC <> '0'.
      MESSAGE E999 WITH '결재자 사번 오류입니다.'  .
    ENDIF.
  ENDIF.
* end simcho By C2006040601000001033

* TT송금, 회사코드 2000의 경우 EDI전송 check
  DATA LV_COUNT TYPE I.
*******************************************************
  IF OK_CODE = 'ZTISEND'.
*     ZTITRQK-ANBTY = 'B' AND
    IF  ZTITRQK-REQTY = C_TT.
      IF ZTITRQK-BUKRS = '2000'.

        CLEAR LV_COUNT.

        SELECT COUNT(*)
          INTO LV_COUNT
          FROM ZTRT048
         WHERE BUKRS = ZTITRQK-BUKRS
           AND REQNO = ZTITRQK-REQNO
           AND APPRO = 'X'.
        IF LV_COUNT = 0.
          MESSAGE E997 WITH '요청번호'
                            ZTITRQK-REQNO
                            '건은 승인미처리건입니다.'  .
        ENDIF.
      ENDIF.

********************************************************
**<       TT 전송 승인 Check처리 20140305
********************************************************
*      CASE ztitig00-ttapv.
*        WHEN 'X'.
*
*          IF ztitrqs-apvun IS INITIAL.
*            MESSAGE E999 WITH 'TT전송 미승인내역'.
*          ENDIF.
*        WHEN OTHERS.
*      ENDCASE.
********************************************************
**>        TT 전송 승인 Check처리 20140305
********************************************************
    ENDIF.

  ENDIF.

*******************************************************
  IF G_MODE EQ C_CHARC OR G_MODE EQ C_CHARM.
    IF ZTITRQS-REQDT IS INITIAL.   "희망일자.
      PERFORM NO_INPUT_CHECK USING 'ZTITRQS' 'REQDT' C_ERROR.
    ELSE.
      IF G_MODE EQ C_CHARC OR
         G_MODE EQ C_CHARM.
        IF ZTITRQS-DOCST EQ SPACE.
          IF ZTITRQS-REQDT LT SY-DATLO.
*이두원과장요청(2005.07.31 11.17)
*           PERFORM no_input_check USING 'ZTITRQS' 'REQDT' c_success.
*           MESSAGE e119 WITH '개설희망일자' '현재일자'.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDIF.

*> 신청 작업일 경우.
  IF G_MODE EQ C_CHARY.
    IF ZTITRQS-SNDDT IS INITIAL.  ">신청일자.
      PERFORM NO_INPUT_CHECK USING 'ZTITRQS' 'SNDDT' C_ERROR.
    ENDIF.
*_--> LS 전선 요청사항. ( By SB, Kang )
*     최종선적일을 개설요청일 + 60일
*     유효기일 = 최종선적일 + 9
    IF ZTITRQK-REQTY EQ C_LO.
* --> GSPOC요청번호 2014011700006
*     Amend요청일 경우 처리하지 않음
      IF ZTITRQS-AMDSQ IS INITIAL.
* --< GSPOC요청번호 2014011700006
        PERFORM  SET_LOCAL_DATE USING ZTITRQS-SNDDT 'X'.
* --> GSPOC요청번호 2014011700006
*     Amend요청일 경우 처리하지 않음
      ENDIF.
* --< GSPOC요청번호 2014011700006
    ENDIF.


    IF ZTITRQS-DOCST EQ C_CHARA OR
       ZTITRQS-DOCST EQ C_CHARW.
      IF ZTITRQS-SNDDT LT SY-DATLO.
*이두원과장요청(2005.07.31 11.17)
*        PERFORM no_input_check USING 'ZTITRQS' 'SNDDT' c_success.
*        MESSAGE e119 WITH '개설신청일자' '현재일자'.
      ENDIF.
    ENDIF.
    IF ZTITRQK-OPNBK IS INITIAL.  ">개설은행.
      PERFORM NO_INPUT_CHECK USING 'ZTITRQK' 'OPNBK' C_ERROR.
    ENDIF.
*> 사업구분.
*    IF ztitrqs-buscl IS INITIAL.
*      PERFORM no_input_check USING 'ZTITRQS' 'BUSCL' c_error.
*    ENDIF.


    IF ZTITRQK-REQTY EQ 'LC'.
      IF ZTITRQK-ILCTY IS INITIAL.  ">신용장 종류.
        PERFORM NO_INPUT_CHECK USING 'ZTITRQK' 'ILCTY' C_ERROR.
      ENDIF.
      IF ZTITRQK-ILCTY EQ 'U'.
        IF ZTITRQK-USCDY IS INITIAL.  ">유산스 기간.
          PERFORM NO_INPUT_CHECK USING 'ZTITRQK' 'USCDY' C_ERROR.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDIF.

  IF ZTITRQS-INSYN IS INITIAL.   "보험부보여부.
    PERFORM  SET_INSURANCE_CLASS  USING C_ERROR.
  ENDIF.

*---> 부보대상이 'Y'일 경우 부보조건 반드시 입력(Only LG전선). by MSH
  IF  ZTITRQS-INSYN EQ 'Y'.
    IF ZTITRQS-ITECD IS INITIAL. "부보조건
      PERFORM  NO_INPUT_CHECK USING 'ZTITRQS' 'ITECD' C_ERROR.
    ENDIF.
  ENDIF.
*---> End of Modification.

*> 개설정보 등록일 경우.
  IF G_MODE EQ C_CHARO.
    IF ZTITRQS-OPNDT IS INITIAL.  ">개설일자.
      PERFORM NO_INPUT_CHECK USING 'ZTITRQS' 'OPNDT' C_ERROR.
    ENDIF.
    IF ZTITRQS-OPNDT LT ZTITRQS-SNDDT.
      PERFORM NO_INPUT_CHECK USING 'ZTITRQS' 'OPNDT' C_SUCCESS.
      MESSAGE E119 WITH '개설일자' '개설신청일자'.
    ENDIF.
    IF ZTITRQS-OPNNO IS INITIAL.  ">개설번호.
      PERFORM NO_INPUT_CHECK USING 'ZTITRQS' 'OPNNO' C_ERROR.
    ENDIF.
  ENDIF.

*  if ZTITRQS-PAYCD is initial and
*     ztitrqk-reqty EQ c_da    and
*     ( g_mode      EQ c_charc OR  ">생성.
*       g_mode      EQ c_charm ).  ">변경.
*    PERFORM no_input_check USING 'ZTITRQS' 'PAYCD' c_error.
*  endif.
*

  IF ZTITRQK-REQTY EQ C_LC OR
     ZTITRQK-REQTY EQ C_DA OR
     ZTITRQK-REQTY EQ C_DP OR
     ZTITRQK-REQTY EQ C_TT.

    IF ZTITRQS-FWDTY IS INITIAL.    ">운송방법.
      PERFORM NO_INPUT_CHECK USING 'ZTITRQS' 'FWDTY' C_ERROR.
    ENDIF.
*----------------------------------------------------------------------*
*                M O D I F I C A T I O N   L O G                       *
*----------------------------------------------------------------------*
* 2004.10.20   Sung-ho Maeng                필수항목 Check 변경.       *
*----------------------------------------------------------------------*
*    IF ztitrqs-ctocd IS INITIAL.    ">원산지 코드.
*      PERFORM no_input_check USING 'ZTITRQS' 'CTOCD' c_error.
*    ENDIF.
*    IF ztitrqs-ctonm IS INITIAL.    ">원산지 명.
*      SELECT SINGLE landx50
*        INTO ztitrqs-ctonm
*        FROM t005t
*       WHERE spras EQ 'E'
*         AND land1 EQ ztitrqs-ctocd.
*      IF sy-subrc NE 0.
*        PERFORM no_input_check USING 'ZTITRQS' 'CTONM' c_error.
*      ENDIF.
*    ENDIF.

    IF ZTITRQK-REQTY EQ C_LC OR
       ZTITRQK-REQTY EQ C_DA OR
       ZTITRQK-REQTY EQ C_DP.

      IF ZTITRQS-CTOCD IS INITIAL.    ">원산지 코드.
        PERFORM NO_INPUT_CHECK USING 'ZTITRQS' 'CTOCD' C_ERROR.
      ENDIF.
      IF ZTITRQS-CTONM IS INITIAL.    ">원산지 명.
        SELECT SINGLE LANDX50
          INTO ZTITRQS-CTONM
          FROM T005T
         WHERE SPRAS EQ 'E'
           AND LAND1 EQ ZTITRQS-CTOCD.
        IF SY-SUBRC NE 0.
          PERFORM NO_INPUT_CHECK USING 'ZTITRQS' 'CTONM' C_ERROR.
        ENDIF.
      ENDIF.

*> 선적항/도착항...
      PERFORM  SET_PORT_CODE.

    ENDIF.
*----------------------------< INSERT END >----------------------------*
  ENDIF.

*> 업무영역별 필드 체크.
  CASE ZTITRQK-REQTY.
*----------------------------------------------------------------------
*  수입신용장 field check
*----------------------------------------------------------------------
    WHEN C_LC.
*> S/D 및 E/D Check.
      PERFORM  CHECK_LAST_SHIPDATE.

      IF ZTITLC1-CHGER IS INITIAL.    "수수료부담자.
        PERFORM NO_INPUT_CHECK USING 'ZTITLC1' 'CHGER' C_ERROR.
      ENDIF.
      IF ZTITRQK-REQTY EQ C_LC AND
         ZTITRQK-ILCTY EQ C_CHARU.
        IF ZTITRQS-PAGRT IS INITIAL.    "신용공여주체.
          PERFORM NO_INPUT_CHECK USING 'ZTITRQS' 'PAGRT' C_ERROR.
        ENDIF.
      ELSE.
        CLEAR: ZTITRQS-PAGRT.
      ENDIF.
      IF ZTITRQS-PARTY IS INITIAL.    "분할선적허용.
        PERFORM NO_INPUT_CHECK USING 'ZTITRQS' 'PARTY' C_ERROR.
      ENDIF.
      IF ZTITRQS-TRANY IS INITIAL.    "환적허용.
        PERFORM NO_INPUT_CHECK USING 'ZTITRQS' 'TRANY' C_ERROR.
      ENDIF.

*> 신청일 경우.
      IF G_MODE EQ C_CHARY.
*--> Begin.LG전선에서 사용안함.by MSH
*        IF ztitrqs-buscl IS INITIAL.
*          PERFORM no_input_check USING 'ZTITRQS' 'BUSCL' c_error.
*        ENDIF.
*--> End.
*        IF ZTITRQK-fwdcd IS INITIAL.  ">선적국가.
*          PERFORM no_input_check USING 'ZTITRQK' 'FWDCD' c_error.
*        ENDIF.
*        IF ZTITRQK-fwdtx IS INITIAL.  ">선적국가.
*          SELECT SINGLE name1
*            INTO ZTITRQK-fwdtx
*            FROM lfa1
*           WHERE lifnr EQ ZTITRQK-fwdcd.
*        ENDIF.
      ENDIF.

*> 가격조건 관련 장소.
      IF ZTITRQS-INCO2 IS INITIAL.    "유효장소.
        PERFORM  SET_PRICE_OR_PLACE  USING ZTITRQS-INCO2.
      ENDIF.
      IF ZTITRQS-INCO2 IS INITIAL.    "유효장소.
        PERFORM NO_INPUT_CHECK USING 'ZTITRQS' 'INCO2' C_ERROR.
      ENDIF.

*> 사용가능 문자집합 체크.
      IF ZTITRQK-REQTY EQ C_LC.
        PERFORM  CHECK_EDI_AVAILABLE_CHAR  USING :
                                        'ZTITRQS-INCO2' C_ERROR, "
                                        'ZTITRQS-CTONM' C_ERROR, "
                                        'ZTITRQS-PLLOD' C_ERROR, "
                                        'ZTITRQS-PLTRN' C_ERROR. "
      ENDIF.

*----------------------------------------------------------------------
*  내국신용장 field check
*----------------------------------------------------------------------
    WHEN C_LO.
      IF ZTITRQS-LSDAT IS INITIAL.   "최종선적일.
        PERFORM NO_INPUT_CHECK USING 'ZTITRQS' 'LSDAT' C_ERROR.
      ELSE.
*        IF ZTITRQS-lsdat LE sy-datlo.
*          PERFORM no_input_check USING 'ZTITRQS' 'LSDAT' c_success.
*          MESSAGE e119 WITH '물품인도기일' '현재일자'.
*        ENDIF.
      ENDIF.

      IF ZTITRQS-EXDAT IS INITIAL.   "유효기일.
        ZTITRQS-EXDAT = ZTITRQS-LSDAT + 10.
*        PERFORM no_input_check USING 'ZTITRQS' 'EXDAT' c_error.
*      ELSE.
*        IF ZTITRQS-exdat LE sy-datlo.
*          PERFORM no_input_check USING 'ZTITRQS' 'EXDAT' c_success.
*          MESSAGE e119 WITH '유효기일' '현재일자'.
*        ENDIF.
      ENDIF.

*> 휴일이면 하루 이후로 변경 배진숙 과장 요청
      CALL FUNCTION 'ZTR_GET_AFTER_WORKDAY'
        EXPORTING
          I_DATE         = ZTITRQS-EXDAT
          I_CALENDAR1    = 'L3'
        IMPORTING
          O_WORKDAY      = ZTITRQS-EXDAT
        EXCEPTIONS
          CALENDAR_ERROR = 1
          OTHERS         = 2.

*> 휴일이면 하루 이후로 변경 배진숙 과장 요청
      CALL FUNCTION 'ZTR_GET_AFTER_WORKDAY'
        EXPORTING
          I_DATE         = ZTITRQS-LSDAT
          I_CALENDAR1    = 'L3'
        IMPORTING
          O_WORKDAY      = ZTITRQS-LSDAT
        EXCEPTIONS
          CALENDAR_ERROR = 1
          OTHERS         = 2.


      IF ZTITRQS-LSDAT GT ZTITRQS-EXDAT.
        PERFORM NO_INPUT_CHECK USING 'ZTITRQS' 'EXDAT' C_SUCCESS.
        MESSAGE E119 WITH '유효기일' '물품인도기일'.
      ENDIF.

*      l_date = ztitrqs-exdat.
*      l_day  = ztitrqs-exdat - ztitrqs-lsdat.
*      IF l_day GT 10.
*        SET CURSOR FIELD 'ZTITRQS-EXDAT'.
*        MESSAGE e148 WITH '유효기일' '물품인도기일' '10'.
*      ENDIF.

*> 분할선적.
      IF ZTITRQS-PARTY IS INITIAL.
        PERFORM NO_INPUT_CHECK USING 'ZTITRQS' 'PARTY' C_ERROR.
      ENDIF.
*> 근거서류 종류.
      IF ZTITLO1-LOPME IS INITIAL.
        PERFORM NO_INPUT_CHECK USING 'ZTITLO1' 'LOPME' C_ERROR.
      ENDIF.
*> 물품매도확약서 번호.
      " 2015.09.16
      " 수입요청종류가 LO이면서 다음과 같은 개설근거용도일때
      " 물품매도확약서 필수 체크
      IF ZTITRQK-REQTY = 'LO'.
        IF ZTITLO1-LOPME = '2AA' OR
          ZTITLO1-LOPME = '2AB' OR ZTITLO1-LOPME = '2AC' OR
          ZTITLO1-LOPME = '2AJ' OR ZTITLO1-LOPME = '2AK' OR
          ZTITLO1-LOPME = '2AO'.

          IF ZTITLO1-LSENO1 IS INITIAL.
            MESSAGE E915 WITH '물품매도확약서'.
          ENDIF.

        ELSE.
          IF ZTITLO1-LSENO1 IS NOT INITIAL.
            MESSAGE E947.
          ENDIF.
        ENDIF.
      ENDIF.
*      IF ztitlo1-lseno1 IS INITIAL.
*        PERFORM no_input_check USING 'ZTITLO1' 'LSENO1' c_error.
*      ENDIF.
*> 신용장 종류.
      IF G_MODE EQ C_CHARY OR
         G_MODE EQ C_CHARO.
        IF ZTITLO1-LLCTY IS INITIAL.
          IF ZTITRQS-WAERS EQ T001-WAERS.
            ZTITLO1-LLCTY  =  '2AA'.
          ELSE.
            ZTITLO1-LLCTY  =  '2AB'.
          ENDIF.
        ENDIF.

        IF ZTITLO1-LLCTY IS INITIAL.
          PERFORM NO_INPUT_CHECK USING 'ZTITLO1' 'LLCTY' C_ERROR.
        ENDIF.
      ENDIF.

*----------------------------------------------------------------------
*  구매확인서 field check
*----------------------------------------------------------------------
    WHEN C_PU.
      IF ZTITRQK-ANBTY IS INITIAL.
        PERFORM NO_INPUT_CHECK USING 'ZTITPC1' 'ANBTY' C_ERROR.
      ENDIF.

*      IF ztitpc1-pspy1 IS INITIAL.
*        PERFORM no_input_check USING 'ZTITPC1' 'PSPY1' c_error.
*      ENDIF.
*
*      IF ztitpc1-pspy2 IS INITIAL.
*        PERFORM no_input_check USING 'ZTITPC1' 'PSPY2' c_error.
*      ENDIF.
*
*      IF ztitpc1-pspy3 IS INITIAL.
*        PERFORM no_input_check USING 'ZTITPC1' 'PSPY3' c_error.
*      ENDIF.

*      IF ztitpc1-pspcd IS INITIAL.
*        PERFORM no_input_check USING 'ZTITPC1' 'PSPCD' c_error.
*      ENDIF.
*      IF ztitpc1-psbnm IS INITIAL.
**> 문서상태 Fixed value read.
*        PERFORM  ddic_domain_value_text_read USING 'ZTIPSPCD'
*                                                   sy-langu
*                                                   ztitpc1-pspcd
*                                                   g_ddtext
*                                                   c_success.
*        ztitpc1-psbnm =  g_ddtext.
*      ENDIF.


**> 위탁자재일 경우, 결제자 정보.
*      IF g_mode EQ c_charc OR g_mode EQ c_charm.
*        IF ZTITRQS-setyn EQ c_true.
*          IF ZTITRQS-setlr IS INITIAL.
*            PERFORM no_input_check USING 'ZTITRQS' 'SETLR' c_error.
*          ENDIF.
*          IF NOT ZTITRQS-setlr IS INITIAL.
*            SELECT SINGLE *
*              FROM zmmv006
*             WHERE pernr  EQ  ZTITRQS-setlr.
*          ENDIF.
*        ENDIF.
*      ENDIF.

******* 상신자 추가  및 결제자 사번으로 변경 2004.01.15.
** 상신자 입력
*      DATA:  BEGIN OF st1_zmmv006,                      "*** 0300 화면
*              pernr       LIKE zmmt0025-zsettler,"결재자사번
*              usrid          LIKE pa0105-usrid,    "결재자ID
*              ename          LIKE pa0001-ename,    "결재자성명
*              orgtx          LIKE zmmv006-orgtx,   "조직 단위 텍스트
*
*              ernam          LIKE zmmt0025-ernam,  "상신자사번
*              ername         LIKE pa0001-ename,    "상신자성명
*            orgtx1       LIKE zmmv006-orgtx,   "상신자조직 단위 텍스트
*              zyn(1),                              "예:Y,아니오:N
*            END   OF st1_zmmv006.
*
** 결재자 입력
*      DATA:  BEGIN OF st2_zmmv006,                      "*** 0300 화면
*              pernr       LIKE zmmt0025-zsettler,"결재자사번
*              usrid          LIKE pa0105-usrid,    "결재자ID
*              ename          LIKE pa0001-ename,    "결재자성명
*              orgtx          LIKE zmmv006-orgtx,   "조직 단위 텍스트
*
*              ernam          LIKE zmmt0025-ernam,  "상신자사번
*              ername         LIKE pa0001-ename,    "상신자성명
*          orgtx1         LIKE zmmv006-orgtx,   "상신자조직 단위 텍스트
*              zyn(1),                              "예:Y,아니오:N
*            END   OF st2_zmmv006.
*
*CLEAR: ST1_ZMMV006,
*       ST2_ZMMV006.
*
**> 위탁자재일 경우, 상신자 정보.
*      IF g_mode EQ c_charc OR g_mode EQ c_charm.
*        IF ZTITRQS-setyn EQ c_true.
*          IF ZTITRQS-reptr IS INITIAL.
*            PERFORM no_input_check USING 'ZTITRQS' 'REPTR' c_error.
*          ENDIF.
*          IF NOT ZTITRQS-reptr IS INITIAL.
*            SELECT SINGLE * INTO st1_zmmv006
*              FROM zmmv006
*             WHERE pernr  EQ  ZTITRQS-reptr.
*            IF st1_zmmv006-pernr IS INITIAL.
*              MESSAGE e924 WITH '사원정보' st1_zmmv006-pernr.
*            ENDIF.
*          ENDIF.
*        ENDIF.
*      ENDIF.
*
**> 위탁자재일 경우, 결제자 정보.
*      IF g_mode EQ c_charc OR g_mode EQ c_charm.
*        IF ZTITRQS-setyn EQ c_true.
*          IF ZTITRQS-setlr IS INITIAL.
*            PERFORM no_input_check USING 'ZTITRQS' 'SETLR' c_error.
*          ENDIF.
*          IF NOT ZTITRQS-setlr IS INITIAL.
*            SELECT SINGLE * INTO st2_zmmv006
*              FROM zmmv006
*             WHERE pernr  EQ  ZTITRQS-setlr.
*            IF st2_zmmv006-pernr IS INITIAL.
*              MESSAGE e924 WITH '사원정보' st2_zmmv006-pernr.
*            ENDIF.
*          ENDIF.
*        ENDIF.
*      ENDIF.
******* 상신자 추가 및 결제자 사번으로 변경 2004.01.15.
*
*----------------------------------------------------------------------
*  전신환 송금 field check
*----------------------------------------------------------------------
    WHEN C_TT.
**> S/D 및 E/D Check.
*      PERFORM  check_last_shipdate.
*
      IF ZTITRQS-FWDTY IS INITIAL.    ">운송방법.
        PERFORM NO_INPUT_CHECK USING 'ZTITRQS' 'FWDTY' C_ERROR.
      ENDIF.

      IF ZTITRQK-RPAID EQ C_TRUE AND
         ZTITRQK-PPAID EQ C_TRUE.
        SET CURSOR FIELD 'ZTITRQK-PPAID'.
        MESSAGE E124.
      ENDIF.

      IF ZTITRQK-RPAID EQ C_TRUE.    "사전/사후 구분
        ZTITRQK-ANBTY = C_CHARA.
      ENDIF.
      IF ZTITRQK-PPAID EQ C_TRUE.    "사전/사후 구분
        ZTITRQK-ANBTY = C_CHARB.
      ENDIF.

      IF ZTITRQK-ANBTY IS INITIAL.    "사전/사후 구분.
        PERFORM NO_INPUT_CHECK USING 'ZTITRQK' 'ANBTY' C_ERROR.
      ENDIF.

      IF ZTITRQK-ANBTY = C_CHARB.
        IF ZTITRQK-PPAID IS INITIAL.    "선급금구분.
          PERFORM NO_INPUT_CHECK USING 'ZTITRQK' 'PPAID' C_ERROR.
        ENDIF.
      ENDIF.
*> 선적항/도착항...
      PERFORM  SET_PORT_CODE.

      IF NOT ( OK_CODE EQ 'ZTIREQCANC' OR
               OK_CODE EQ 'ZTIEDI' ).          "취소시 체크 제외처리

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
*> 수취인 거래은행명.
        IF ZTITTT1-TBBNM IS INITIAL.
***-> Vendor Master의 은행정보 가져옴. by MSH********************
          PERFORM GET_VENDOR_BANK.
*****************************************************************
          IF ZTITTT1-TBBNM IS INITIAL.
            PERFORM NO_INPUT_CHECK USING 'ZTITTT1' 'TBBNM' C_ERROR.
          ENDIF.
        ENDIF.
**> 수취인 거래은행코드.
*      IF ztittt1-tbbad3 IS INITIAL.
*        PERFORM no_input_check USING 'ZTITTT1' 'TBBAD3' c_success.
*        MESSAGE e130.
*      ENDIF.
*> 수취인 계좌번호.
        IF ZTITTT1-TBBAN IS INITIAL.
          PERFORM NO_INPUT_CHECK USING 'ZTITTT1' 'TBBAN' C_ERROR.
        ENDIF.


        IF G_MODE EQ C_CHARY OR
           G_MODE EQ C_CHARO.

          IF ZTITTT1-TECDT IS INITIAL.   " 이체희망일자.
            PERFORM NO_INPUT_CHECK USING 'ZTITTT1' 'TECDT' C_ERROR.
          ENDIF.
          IF ZTITRQS-SNDDT GT ZTITTT1-TECDT.
            PERFORM NO_INPUT_CHECK USING 'ZTITTT1' 'TECDT' C_SUCCESS.
            MESSAGE E119 WITH '이체희망일자' '신청일자'.
          ENDIF.
        ENDIF.
        IF ZTITRQS-INCO2 IS INITIAL.    "유효장소.
          PERFORM  SET_PRICE_OR_PLACE  USING ZTITRQS-INCO2.
        ENDIF.
        IF ZTITRQS-INCO2 IS INITIAL.    "유효장소.
          PERFORM NO_INPUT_CHECK USING 'ZTITRQS' 'INCO2' C_ERROR.
        ENDIF.
*> 사후송금일 경우.
        IF ZTITRQK-ANBTY EQ 'A'.
          CASE ZTITRQK-IMPTY.
            WHEN 'A'.
              ZTITTT1-IMACD = 'E'.
            WHEN 'B'.
              ZTITTT1-IMACD = 'N'.
            WHEN 'C'.
            WHEN 'D'.
            WHEN 'E'.
            WHEN 'F'.
              IF ZTITRQK-BUKRS = '3000'.
                ZTITTT1-IMACD = 'Z'. "기능개선 224957 전선EVK 제외
              ENDIF.
            WHEN OTHERS.
          ENDCASE.
        ENDIF.
      ENDIF.
*----------------------------------------------------------------------
*  D/A or D/P field check
*----------------------------------------------------------------------
    WHEN C_DA OR C_DP.

    WHEN OTHERS.
  ENDCASE.

ENDMODULE.                 " pai_scr2121_check_input_value  INPUT
*&---------------------------------------------------------------------*
*&      Module  user_command_2100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_2100 INPUT.
*> F2 Funtion key Event시 해당 필드의 정보 display
  PERFORM  DOUBLE_CLICK_EVENT.
ENDMODULE.                 " user_command_2100  INPUT
*&---------------------------------------------------------------------*
*&      Module  user_command_2101  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_2101 INPUT.
*> F2 Funtion key Event시 해당 필드의 정보 display
  PERFORM  DOUBLE_CLICK_EVENT.
ENDMODULE.                 " user_command_2101  INPUT
*&---------------------------------------------------------------------*
*&      Module  fcode_exit_scr7000  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE FCODE_EXIT_SCR7000 INPUT.

  LEAVE TO SCREEN 0.

ENDMODULE.                 " fcode_exit_scr7000  INPUT
*&---------------------------------------------------------------------*
*&      Module  check_input_fields  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE CHECK_INPUT_FIELDS INPUT.

  CHECK OK-CODE EQ 'ZTIOKAY'.

  IF ZTISSCRCOM-OPAMT IS INITIAL.
    PERFORM  NO_INPUT_CHECK USING 'ZTISSCRCOM' 'OPAMT' C_ERROR.
  ENDIF.
*> 금액 비교.
  IF ZTISSCRCOM-OPAMT = ZTITRQS-POAMT.
    MESSAGE E221.
  ELSEIF ZTISSCRCOM-OPAMT > ZTITRQS-POAMT.
    MESSAGE E222.
  ENDIF.

ENDMODULE.                 " check_input_fields  INPUT
*&---------------------------------------------------------------------*
*&      Module  user_command_scr7000  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_SCR7000 INPUT.

  CASE OK-CODE.
    WHEN 'ZTIOKAY'.
*> 금액 비교.
      IF ZTISSCRCOM-OPAMT = ZTITRQS-POAMT.
        MESSAGE E221.
      ELSEIF ZTISSCRCOM-OPAMT > ZTITRQS-POAMT.
        MESSAGE E222.
      ENDIF.

      LEAVE TO SCREEN 0.
    WHEN 'ZTICANCEL'.
      LEAVE TO SCREEN 0.
    WHEN OTHERS.
  ENDCASE.

ENDMODULE.                 " user_command_scr7000  INPUT

*&---------------------------------------------------------------------*
*&      Module  tc_2123_modify  INPUT
*&---------------------------------------------------------------------*
* input module for tc 'TC_2123'. do not change this line!
* modify table
*----------------------------------------------------------------------*
MODULE TC_2123_MODIFY INPUT.

  IF ZTITLC4-LAND1 IS INITIAL AND
     ZTITLC4-FWDCD IS INITIAL AND
     ZTITLC4-FWDTY IS INITIAL.
  ENDIF.

*> 선적국가.
  IF ZTITLC4-LAND1 IS INITIAL.
    PERFORM NO_INPUT_CHECK USING 'ZTITLC4' 'LAND1' C_ERROR.
  ENDIF.

*> 포워더 코드.
  IF ZTITLC4-FWDCD IS INITIAL.
    PERFORM NO_INPUT_CHECK USING 'ZTITLC4' 'FWDCD' C_ERROR.
  ENDIF.
  SELECT  SINGLE NAME1
    INTO  ZTISLC04-NAME1
    FROM  LFA1
   WHERE  LIFNR  EQ  ZTITLC4-FWDCD.
  IF SY-SUBRC NE 0.
    PERFORM MESSAGE_NOT_FOUND_VENDOR USING 'ZTITLC4'
                                           'FWDCD'
                                           C_ERROR.
  ENDIF.
*> 포워더 관리 테이블 CHECK.
  SELECT SINGLE *
    FROM ZTITIG10
   WHERE FWDCD  EQ  ZTITLC4-FWDCD
     AND LAND1  EQ  ZTITLC4-LAND1.

  IF SY-SUBRC NE 0.
    SET CURSOR FIELD 'ZTITLC4-FWDCD'.
    MESSAGE E128 WITH ZTITLC4-LAND1 ZTISLC04-NAME1.
  ENDIF.
*> 운송방법.
  IF ZTITLC4-FWDTY IS INITIAL.
    PERFORM NO_INPUT_CHECK USING 'ZTITLC4' 'FWDTY' C_ERROR.
  ENDIF.

  MOVE-CORRESPONDING ZTITLC4 TO G_TC_2123_WA.
  MOVE ZTISLC04-NAME1         TO G_TC_2123_WA-NAME1.

  MODIFY G_TC_2123_ITAB
    FROM G_TC_2123_WA
    INDEX TC_2123-CURRENT_LINE.

  IF SY-SUBRC NE 0.
    APPEND G_TC_2123_WA TO G_TC_2123_ITAB.
  ENDIF.

ENDMODULE.                    "tc_2123_modify INPUT

*&---------------------------------------------------------------------*
*&      Module  tc_2123_mark  INPUT
*&---------------------------------------------------------------------*
*  input module for tc 'TC_2123'. do not change this line!
*  mark table
*----------------------------------------------------------------------*
MODULE TC_2123_MARK INPUT.
  IF TC_2123-LINE_SEL_MODE = 1 AND
     G_TC_2123_WA-FLAG = 'X'.
    LOOP AT G_TC_2123_ITAB INTO G_TC_2123_WA
      WHERE FLAG = 'X'.
      G_TC_2123_WA-FLAG = ''.
      MODIFY G_TC_2123_ITAB
        FROM G_TC_2123_WA
        TRANSPORTING FLAG.
    ENDLOOP.
    G_TC_2123_WA-FLAG = 'X'.
  ENDIF.

  MODIFY G_TC_2123_ITAB
    FROM G_TC_2123_WA
    INDEX TC_2123-CURRENT_LINE
    TRANSPORTING FLAG.

ENDMODULE.                    "TC_2123_mark INPUT

*&---------------------------------------------------------------------*
*&      Module  tc_2123_mark  INPUT
*&---------------------------------------------------------------------*
*  input module for tc 'TC_2123'. do not change this line!
*  process user command
*----------------------------------------------------------------------*
MODULE TC_2123_USER_COMMAND INPUT.
*> 순번 build.
  CLEAR: G_COUNT.
  LOOP AT G_TC_2123_ITAB INTO G_TC_2123_WA.
    ADD 1 TO G_COUNT.
    G_TC_2123_WA-FWDSQ = G_COUNT.
    G_TC_2123_WA-REQNO = ZTITRQK-REQNO.
    MODIFY G_TC_2123_ITAB FROM G_TC_2123_WA.
  ENDLOOP.

  OK_CODE = SY-UCOMM.
  PERFORM USER_OK_TC USING    'TC_2123'
                              'G_TC_2123_ITAB'
                              'FLAG'
                     CHANGING OK_CODE.
  SY-UCOMM = OK_CODE.

*> F2 Funtion key Event시 해당 필드의 정보 display
  PERFORM  DOUBLE_CLICK_EVENT.

ENDMODULE.                    "TC_2123_user_command INPUT
*&---------------------------------------------------------------------*
*&      Module  pai_scr2121_set_forwarder  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE PAI_SCR2121_SET_FORWARDER INPUT.

  DESCRIBE TABLE G_TC_2123_ITAB LINES G_LINE.

  IF ZTITRQK-FWDAS IS INITIAL.
    IF G_LINE GT 0.
      MESSAGE W127.
    ENDIF.
    REFRESH: G_TC_2123_ITAB. CLEAR: G_TC_2123_ITAB.
  ELSE.
    IF G_LINE GT 0.
      MESSAGE W127.
    ENDIF.
*> 지정 포워더 Setting
    PERFORM  SET_FORWARDER_DATA.
  ENDIF.

ENDMODULE.                 " pai_scr2121_set_forwarder  INPUT
*&---------------------------------------------------------------------*
*&      Module  check_input_value_scr2210  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE CHECK_INPUT_VALUE_SCR2210 INPUT.

  CHECK: G_MODE EQ C_CHARC OR
         G_MODE EQ C_CHARM OR
         G_MODE EQ C_CHARY OR
         G_MODE EQ C_CHARO.
*
*> 필수 항목 체크.
  PERFORM  CHECK_MANDATORY_INPUT     USING  :
                                    'ZTITLC1-APPNM' C_ERROR,
                                    'ZTITLC1-APPNM' C_ERROR, "
                                    'ZTITLC1-BENNM' C_ERROR, "
                                    'ZTITLC1-NOMNM' C_ERROR, "
                                    'ZTITLC1-NOMID' C_ERROR, "

*                                    'ZTITLC1-OPBCD' c_error, "
*                                    'ZTITRQS-SNDDT' c_error, "
                                    'ZTITLC1-OPMET' C_ERROR, "
                                    'ZTITRQS-EXDAT' C_ERROR, "
                                    'ZTITLC1-EXPLC' C_ERROR, "
                                    'ZTITLC1-CHGER' C_ERROR, "
                                    'ZTITRQS-OPAMT' C_ERROR, "
                                    'ZTITRQS-WAERS' C_ERROR, "
                                    'ZTITLC1-PATE1' C_ERROR,
*                                    'ZTITLC1-AMTE1' c_error, "
                                    'ZTITLC1-ALCHY' C_ERROR,
                                    'ZTITRQS-PLLOD' C_ERROR, "
                                    'ZTITRQS-PLTRN' C_ERROR, "
                                    'ZTITRQS-PARTY' C_ERROR, "
                                    'ZTITRQS-TRANY' C_ERROR, "
                                    'ZTITRQS-INCO1' C_ERROR. "
*                                    'ZTITLC1-CIYCD' c_error, "
*                                    'ZTITLC1-BLYCD' c_error, "
*                                    'ZTITLC1-ABYCD' c_error, "
*                                    'ZTITLC1-IPYCD' c_error, "
*                                    'ZTITLC1-PLYCD' c_error, "
*                                    'ZTITLC1-COYCD' c_error, "
*                                    'ZTITLC1-ODYCD' c_error. "

  IF G_MODE EQ C_CHARY.
    PERFORM  CHECK_MANDATORY_INPUT     USING  :
                                      'ZTITRQS-SNDDT' C_ERROR.
  ENDIF.

  IF ZTITLC1-ALCHY EQ 'T'.
    PERFORM  CHECK_MANDATORY_INPUT     USING  :
                                      'ZTITLC1-ALCHP' C_ERROR,
                                      'ZTITLC1-ALCHM' C_ERROR.
  ENDIF.

*S__ 신용장 변경에 따른 수정 20181010 BY SDW
* 확인지시문언이 DB or DC 일 경우 확인은행코드 필수입력
  IF ZTITLC1-CFIST EQ 'DB' OR
     ZTITLC1-CFIST EQ 'DC'.
    PERFORM  CHECK_MANDATORY_INPUT_2     USING  :
                                      'ZTITLC1-CBNCODE' C_WARNING.
  ENDIF.
*E__ 신용장 변경에 따른 수정 20181010 BY SDW


  PERFORM SCR2210_CHECK_DOCUMENT_REQ.


*> 사용가능 문자집합 체크.
  PERFORM  CHECK_EDI_AVAILABLE_CHAR  USING :
                                    'ZTITLC1-APPNM' C_ERROR, "
                                    'ZTITLC1-APPPR' C_ERROR, "
                                    'ZTITLC1-APAD1' C_ERROR, "
                                    'ZTITLC1-APAD2' C_ERROR, "
                                    'ZTITLC1-BENNM' C_ERROR, "
                                    'ZTITLC1-BEAD1' C_ERROR, "
                                    'ZTITLC1-BEAD2' C_ERROR, "
                                    'ZTITLC1-BEAD3' C_ERROR, "
                                    'ZTITLC1-BEFAC' C_ERROR, "
                                    'ZTITLC1-CFIST' C_ERROR, "
                                    'ZTITRQS-EXDAT' C_ERROR, "
                                    'ZTITLC1-EXPLC' C_ERROR, "
                                    'ZTITLC1-CHGER' C_ERROR, "
                                    'ZTITRQS-OPAMT' C_ERROR, "
                                    'ZTITRQS-WAERS' C_ERROR, "
                                    'ZTITLC1-ALCHP' C_ERROR, "
                                    'ZTITLC1-ALCHM' C_ERROR, "
                                    'ZTITLC1-ALCHY' C_ERROR, "
                                    'ZTITLC1-PAYTY' C_ERROR, "
                                    'ZTITLC1-PATE1' C_ERROR, "
                                    'ZTITLC1-PATE2' C_ERROR, "
                                    'ZTITLC1-PATE3' C_ERROR, "
                                    'ZTITLC1-PATE4' C_ERROR, "
                                    'ZTITLC1-AMTE1' C_ERROR, "
                                    'ZTITLC1-AMTE2' C_ERROR, "
                                    'ZTITLC1-AMTE3' C_ERROR, "
                                    'ZTITLC1-AMTE4' C_ERROR, "
                                    'ZTITRQS-PLLOD' C_ERROR, "
                                    'ZTITRQS-PLTRN' C_ERROR, "
                                    'ZTITRQS-LSDAT' C_ERROR, "
                                    'ZTITLC1-SPRD1' C_ERROR, "
                                    'ZTITLC1-SPRD2' C_ERROR, "
                                    'ZTITLC1-SPRD3' C_ERROR, "
                                    'ZTITLC1-SHDRD' C_ERROR, "
                                    'ZTITRQS-PARTY' C_ERROR, "
                                    'ZTITRQS-TRANY' C_ERROR, "
                                    'ZTITRQS-CTOCD' C_ERROR, "
                                    'ZTITRQS-CTONM' C_ERROR, "
                                    'ZTITRQS-INCO1' C_ERROR, "
                                    'ZTITLC1-INCON' C_ERROR, "
                                    'ZTITLC1-INCOP' C_ERROR, "
                                    'ZTITLC1-CIYCD' C_ERROR, "
                                    'ZTITLC1-CICPY' C_ERROR, "
                                    'ZTITLC1-BLYCD' C_ERROR, "
                                    'ZTITLC1-BCON1' C_ERROR, "
                                    'ZTITLC1-BCON2' C_ERROR, "
                                    'ZTITLC1-BFREY' C_ERROR, "
                                    'ZTITLC1-BNOT1' C_ERROR, "
                                    'ZTITLC1-ABYCD' C_ERROR, "
                                    'ZTITLC1-ACON1' C_ERROR, "
                                    'ZTITLC1-ACON2' C_ERROR, "
                                    'ZTITLC1-AFREY' C_ERROR, "
                                    'ZTITLC1-ANOT1' C_ERROR, "
                                    'ZTITLC1-IPYCD' C_ERROR, "
                                    'ZTITLC1-IPTE1' C_ERROR, "
                                    'ZTITLC1-IPTE2' C_ERROR, "
                                    'ZTITLC1-PLYCD' C_ERROR, "
                                    'ZTITLC1-PLCPY' C_ERROR, "
                                    'ZTITLC1-COYCD' C_ERROR, "
                                    'ZTITLC1-ODYCD' C_ERROR, "
                                    'ZTITLC1-CARNM' C_ERROR, "
                                    'ZTITLC1-MATE1' C_ERROR, "
                                    'ZTITLC1-MATE2' C_ERROR, "
                                    'ZTITLC1-MATE3' C_ERROR, "
                                    'ZTITLC1-MATE4' C_ERROR, "
                                    'ZTITLC1-MATE5' C_ERROR. "


*S__ 신용장 변경에 따른 수정 20181010 BY SDW
  IF ZTITLC1-CHGER = '16' OR ZTITLC1-CHGER = '19'.
    MESSAGE ID 'ZMTE' TYPE 'E'
       NUMBER 997 WITH '수수료 부담자 Code'
                       ZTITLC1-CHGER
                      '는 입력할 수 없는 Old Code입니다.'.
  ENDIF.

  IF STRLEN( ZTITLC1-BEFAC ) > 34.
    MESSAGE ID 'ZMTE' TYPE 'E'
       NUMBER 997 WITH '수익자계좌번호'
                       ZTITLC1-BEFAC
                      '는 입력자리수 34자리를 초과하였습니다.'.
  ENDIF.

  IF STRLEN( ZTITLC1-OPBNM ) > 35.
    MESSAGE ID 'ZMTE' TYPE 'E'
       NUMBER 997 WITH '개설은행명1'
                       ZTITLC1-OPBNM
                      '는 입력자리수 35자리를 초과하였습니다.'.
  ENDIF.

  IF STRLEN( ZTITLC1-OPBBR ) > 35.
    MESSAGE ID 'ZMTE' TYPE 'E'
       NUMBER 997 WITH '개설은행점1'
                       ZTITLC1-OPBBR
                      '는 입력자리수 35자리를 초과하였습니다.'.
  ENDIF.

  IF STRLEN( ZTITLC1-OPBBR2 ) > 35.
    MESSAGE ID 'ZMTE' TYPE 'E'
       NUMBER 997 WITH '개설은행점2'
                       ZTITLC1-OPBBR2
                      '는 입력자리수 35자리를 초과하였습니다.'.
  ENDIF.

  IF STRLEN( ZTITLC1-ADBNM ) > 35.
    MESSAGE ID 'ZMTE' TYPE 'E'
       NUMBER 997 WITH '통지은행명1'
                       ZTITLC1-ADBNM
                      '는 입력자리수 35자리를 초과하였습니다.'.
  ENDIF.

  IF STRLEN( ZTITLC1-ADBNM2 ) > 35.
    MESSAGE ID 'ZMTE' TYPE 'E'
       NUMBER 997 WITH '통지은행명2'
                       ZTITLC1-ADBNM2
                      '는 입력자리수 35자리를 초과하였습니다.'.
  ENDIF.

  IF STRLEN( ZTITLC1-ADBBR ) > 35.
    MESSAGE ID 'ZMTE' TYPE 'E'
       NUMBER 997 WITH '통지은행점1'
                       ZTITLC1-ADBBR
                      '는 입력자리수 35자리를 초과하였습니다.'.
  ENDIF.

  IF STRLEN( ZTITLC1-ADBBR2 ) > 35.
    MESSAGE ID 'ZMTE' TYPE 'E'
       NUMBER 997 WITH '통지은행점2'
                       ZTITLC1-ADBBR2
                      '는 입력자리수 35자리를 초과하였습니다.'.
  ENDIF.

*E__ 신용장 변경에 따른 수정 20181010 BY SDW

ENDMODULE.                 " check_input_value_scr2210  INPUT
*&---------------------------------------------------------------------*
*&      Module  check_input_value_scr2211  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE CHECK_INPUT_VALUE_SCR2211 INPUT.
  CHECK: G_MODE EQ C_CHARY OR
         G_MODE EQ C_CHARO.

*> 사용가능 문자집합 체크.
  PERFORM  CHECK_EDI_AVAILABLE_CHAR  USING :
                                    'ZTITLC2-LTEXT' C_ERROR. "

ENDMODULE.                 " check_input_value_scr2210  INPUT
*&---------------------------------------------------------------------*
*&      Module  check_input_value_scr2211  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE CHECK_INPUT_VALUE_SCR2215 INPUT.
  CHECK: G_MODE EQ C_CHARC OR
         G_MODE EQ C_CHARM OR
         G_MODE EQ C_CHARY OR
         G_MODE EQ C_CHARO.
*> 필수 항목 체크.
  PERFORM  CHECK_MANDATORY_INPUT     USING  :
                                    'ZTITLC1-APPNM' C_ERROR,
                                    'ZTITLC1-APPNM' C_ERROR, "
                                    'ZTITLC1-BENNM' C_ERROR, "
                                    'ZTITLC1-NOMNM' C_ERROR, "
                                    'ZTITLC1-NOMID' C_ERROR, "
*                                    'ZTITLC1-OPBCD' c_error, "
                                    'ZTITRQS-OPNDT' C_ERROR, "
*                                    'ZTITLC1-OPDAT' c_error, "
                                    'ZTITRQS-AMDSQ' C_ERROR, "
                                    'ZTITLC1-OPMET' C_ERROR. "

  IF ZTITLC1-LALHY EQ 'T'.
    PERFORM  CHECK_MANDATORY_INPUT     USING  :
                                    'ZTITLC1-LALHM' C_ERROR,
                                    'ZTITLC1-LALHP' C_ERROR.
*S__ 신용장 변경에 따른 수정 20181010 BY SDW
* 화면에서 삭제된 필드 -> 주석처리
*                               'ZTITLC1-LBAMT' C_ERROR.
*E__ 신용장 변경에 따른 수정 20181010 BY SDW

  ENDIF.

  IF G_MODE EQ C_CHARY.
    PERFORM  CHECK_MANDATORY_INPUT     USING  :
                                    'ZTITLC1-OPDAT' C_ERROR.
  ENDIF.

*> 사용가능 문자집합 체크.
  PERFORM  CHECK_EDI_AVAILABLE_CHAR  USING :
                                    'ZTITLC1-APPNM' C_ERROR, "
                                    'ZTITLC1-APPPR' C_ERROR, "
                                    'ZTITLC1-APAD1' C_ERROR, "
                                    'ZTITLC1-APAD2' C_ERROR, "
                                    'ZTITLC1-BENNM' C_ERROR, "
                                    'ZTITLC1-BEAD1' C_ERROR, "
                                    'ZTITLC1-BEAD2' C_ERROR, "
                                    'ZTITLC1-BEAD3' C_ERROR, "
                                    'ZTITLC1-BEFAC' C_ERROR, "
                                    'ZTITRQS-OPNDT' C_ERROR, "
                                    'ZTITRQS-OPNNO' C_ERROR, "
                                    'ZTITLC1-OPDAT' C_ERROR, "
                                    'ZTITRQS-AMDSQ' C_ERROR, "
                                    'ZTITLC1-OPMET' C_ERROR, "
                                    'ZTITLC1-LEXDT' C_ERROR, "
                                    'ZTITLC1-LSPDT' C_ERROR, "
                                    'ZTITLC1-LSPR1' C_ERROR, "
                                    'ZTITLC1-LSPR2' C_ERROR, "
                                    'ZTITLC1-LSPR3' C_ERROR, "
                                    'ZTITLC1-LPLLO' C_ERROR, "
                                    'ZTITLC1-LPLTR' C_ERROR, "
                                    'ZTITLC1-LALHM' C_ERROR, "
                                    'ZTITLC1-LALHP' C_ERROR, "
                                    'ZTITLC1-LALHY' C_ERROR, "
*                                    'ZTITLC1-LAMPA' c_error, "
                                    'ZTITLC1-LAMT2' C_ERROR, "
                                    'ZTITLC1-LAMT3' C_ERROR, "
                                    'ZTITLC1-LAMT4' C_ERROR, "
                                    'ZTITLC1-LAMLA' C_ERROR, "
                                    'ZTITRQS-WAERS' C_ERROR. "

***S__ 신용장 변경에 따른 수정 20181010 BY SDW
**  PERFORM CHECK_TEXT_EDIT_DATA.
***E__ 신용장 변경에 따른 수정 20181010 BY SDW


ENDMODULE.                 " check_input_value_scr2210  INPUT
*&---------------------------------------------------------------------*
*&      Module  check_input_value_scr2230  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE CHECK_INPUT_VALUE_SCR2230 INPUT.

  DATA : LV_MSG(35)  TYPE C,
         LV_DOMNAME  LIKE DD07V-DOMNAME,
         LV_DOMVALUE LIKE DD07V-DOMVALUE_L,
         LV_TEXT     LIKE DD07V-DDTEXT.

  CHECK: G_MODE EQ C_CHARC OR
         G_MODE EQ C_CHARM OR
         G_MODE EQ C_CHARY OR
         G_MODE EQ C_CHARO.
*> 필수 항목 체크.
  PERFORM  CHECK_MANDATORY_INPUT     USING  :
                                    'ZTITLO1-LAPNM'  C_ERROR,
                                    'ZTITLO1-LBENM'  C_ERROR, "
                                    'ZTITLO1-LNONM'  C_ERROR, "
                                    'ZTITLO1-LNOID'  C_ERROR, "
                                    'ZTITLO1-LDODT'  C_ERROR, "
                                    'ZTITLO1-LGDO1'  C_ERROR, ""
                                    'ZTITLO1-LAPPR2' C_ERROR,
                                    'ZTITLO1-LBEPR2' C_ERROR,
*>by PJP(050705)미그변경
                                    'ZTITLO1-STAWN'  C_ERROR.

*> 물품매도확약서 번호.
  " 2015.09.16
  " 수입요청종류가 LO이면서 다음과 같은 개설근거용도일때
  " 물품매도확약서 필수 체크
  IF ZTITRQK-REQTY = 'LO'.
    IF ZTITLO1-LOPME = '2AA' OR
      ZTITLO1-LOPME = '2AB' OR ZTITLO1-LOPME = '2AC' OR
      ZTITLO1-LOPME = '2AJ' OR ZTITLO1-LOPME = '2AK' OR
      ZTITLO1-LOPME = '2AO'.
      IF ZTITLO1-LSENO1 IS INITIAL.
        MESSAGE E915 WITH '물품매도확약서'.
      ENDIF.
    ELSE.
      IF ZTITLO1-LSENO1 IS NOT INITIAL.
        MESSAGE E947.
      ENDIF.
    ENDIF.
  ENDIF.
*> 개설근거서류에 따른 필수확인
  CLEAR : LV_MSG, LV_DOMNAME, LV_DOMVALUE, LV_TEXT.
  IF ZTITLO1-LDOTY IS NOT INITIAL.
    IF ZTITLO1-LBANR IS INITIAL.
      LV_DOMNAME = 'ZTILDOTY'.
      LV_DOMVALUE = ZTITLO1-LDOTY.
      CALL FUNCTION 'DOMAIN_VALUE_GET'
        EXPORTING
          I_DOMNAME  = LV_DOMNAME
          I_DOMVALUE = LV_DOMVALUE
        IMPORTING
          E_DDTEXT   = LV_TEXT.

      CONCATENATE ZTITLO1-LDOTY LV_TEXT
      INTO LV_MSG SEPARATED BY SPACE.
      MESSAGE E948 WITH LV_MSG.
    ELSE.
      IF ZTITLO1-LDOTY = '465' OR
        ZTITLO1-LDOTY = '2AP' OR
        ZTITLO1-LDOTY = '2CJ'.
        IF ZTITLO1-LPMAT IS INITIAL.
          MESSAGE E999 WITH '결제금액을 입력하세요'.
        ELSE.
          IF ZTITLO1-LPMATC IS INITIAL.
            MESSAGE E999 WITH '통화를 입력하세요'.
          ELSE.
            IF ZTITLO1-LSHDT IS INITIAL.
              MESSAGE E999 WITH '선적일자를 입력하세요'.
            ELSE.
              IF ( ZTITLO1-LDOTY = '465' OR
                ZTITLO1-LDOTY = '2AP' ).
                IF ZTITLO1-LESDT IS INITIAL.
                  MESSAGE E999 WITH '유효기일을 입력하세요'.
                ENDIF.
              ENDIF.
*              IF ztitlo1-libnm IS INITIAL.
*                MESSAGE E999 WITH '발급은행명을 입력하세요'.
*              ENDIF.
            ENDIF.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDIF.

ENDMODULE.                 " check_input_value_scr2230  INPUT
*&---------------------------------------------------------------------*
*&      Module  check_input_value_scr2235  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE CHECK_INPUT_VALUE_SCR2235 INPUT.
  CHECK: G_MODE EQ C_CHARC OR
         G_MODE EQ C_CHARM OR
         G_MODE EQ C_CHARY OR
         G_MODE EQ C_CHARO.
*> 필수 항목 체크.
  PERFORM  CHECK_MANDATORY_INPUT     USING  : "
                                    'ZTITLO1-LBEPR2' C_ERROR.

*> 물품매도확약서 번호.
  " 2015.09.16
  " 수입요청종류가 LO이면서 다음과 같은 개설근거용도일때
  " 물품매도확약서 필수 체크
  IF ZTITRQK-REQTY = 'LO'.
    IF ZTITLO1-LOPME = '2AA' OR
      ZTITLO1-LOPME = '2AB' OR ZTITLO1-LOPME = '2AC' OR
      ZTITLO1-LOPME = '2AJ' OR ZTITLO1-LOPME = '2AK' OR
      ZTITLO1-LOPME = '2AO'.
      IF ZTITLO1-LSENO1 IS INITIAL.
        MESSAGE E915 WITH '물품매도확약서'.
      ENDIF.
    ELSE.
      IF ZTITLO1-LSENO1 IS NOT INITIAL.
        MESSAGE E947.
      ENDIF.
    ENDIF.
  ENDIF.

ENDMODULE.                 " check_input_value_scr2230  INPUT
*&---------------------------------------------------------------------*
*&      Module  check_input_value_scr2220  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE CHECK_INPUT_VALUE_SCR2220 INPUT.
  CHECK: G_MODE EQ C_CHARC OR
         G_MODE EQ C_CHARM OR
         G_MODE EQ C_CHARY OR
         G_MODE EQ C_CHARO.
*> 필수 항목 체크.
  PERFORM  CHECK_MANDATORY_INPUT     USING  :
                                    'ZTITPC1-PAPNM'  C_ERROR,
                                    'ZTITPC1-PAPAD1' C_ERROR,
                                    'ZTITPC1-PSPNM'  C_ERROR,
                                    'ZTITPC1-PSPAD1' C_ERROR,
                                    'ZTITPC1-PNONM'  C_ERROR,
                                    'ZTITPC1-PTNUM'  C_ERROR,
                                    'ZTITPC1-PSPCD'  C_ERROR,
                                    'ZTITPC1-PSPID'  C_ERROR.

*-{기능개선 213478 - 구매승인서 특수문자 체크 추가
*> 사용가능 문자집합 체크.
  PERFORM  CHECK_EDI_AVAILABLE_CHAR2  USING :
                                      'ZTITPC1-PSPNM'  C_ERROR,
                                      'ZTITPC1-PSPAD1'  C_ERROR,
                                      'ZTITPC1-PSPAD2'  C_ERROR,
                                      'ZTITPC1-PSPAD3'  C_ERROR.
*-}기능개선 213478

ENDMODULE.                 " check_input_value_scr2230  INPUT
*&---------------------------------------------------------------------*
*&      Module  check_input_value_scr2240  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE CHECK_INPUT_VALUE_SCR2240 INPUT.
  CHECK: G_MODE EQ C_CHARC OR
         G_MODE EQ C_CHARM OR
         G_MODE EQ C_CHARY OR
         G_MODE EQ C_CHARO.
*> 필수 항목 체크.
  PERFORM  CHECK_MANDATORY_INPUT     USING  :
*                                    'ZTITTT1-TAPDT' c_error,
                                    'ZTITTT1-TECDT' C_ERROR,
                                    'ZTITTT1-TTYCD' C_ERROR,  "거래형태
*                                    'ZTITTT1-TOBCD' C_ERROR,
                                    'ZTITTT1-TSTCD' C_ERROR,
*                                    'ZTITRQS-OPAMT' c_error,
                                    'ZTITRQS-WAERS' C_ERROR.

** '사전T/T'일 경우 '수입예정일' 필수
  IF ZTITRQK-ANBTY = 'B'.
    PERFORM  CHECK_MANDATORY_INPUT     USING  :
                                      'ZTITTT1-TEIDT' C_ERROR.
  ENDIF.

  IF G_MODE EQ C_CHARY.   "전송의뢰
    PERFORM  CHECK_MANDATORY_INPUT     USING  :
                                   'ZTITTT1-TAPDT' C_ERROR,
                                   'ZTITTT1-TOBAN' C_ERROR.
  ENDIF.
*> 사용가능 문자집합 체크.
  PERFORM  CHECK_EDI_AVAILABLE_CHAR  USING :
*                                    'ZTITTT1-TOCNM'  c_error,
*                                    'ZTITTT1-TOCPR1' c_error,
*                                    'ZTITTT1-TOCPR2' c_error,
*                                    'ZTITTT1-TOCAD1' c_error,
*                                    'ZTITTT1-TOCAD2' c_error,
*                                    'ZTITTT1-TOCAD3' c_error,
                                    'ZTITTT1-TOCTL'  C_ERROR,
                                    'ZTITTT1-TOCID'  C_ERROR,
*                                    'ZTITTT1-TBENM'  c_error,
                                    'ZTITTT1-TBEPR1' C_ERROR,
                                    'ZTITTT1-TBEPR2' C_ERROR,
                                    'ZTITTT1-TBEAD1' C_ERROR,
                                    'ZTITTT1-TBEAD2' C_ERROR,
                                    'ZTITTT1-TBEAD3' C_ERROR,
                                    'ZTITTT1-TBETL'  C_ERROR,
                                    'ZTITRQS-OTHT1'  C_ERROR,
*                                    'ZTITRQS-OTHT2'  C_ERROR,
                                    'ZTITRQS-OTHT3'  C_ERROR,
                                    'ZTITRQS-OTHT4'  C_ERROR,
                                    'ZTITRQS-OTHT5'  C_ERROR,
                                    'ZTITTT1-TAPDT'  C_ERROR,
                                    'ZTITTT1-TECDT'  C_ERROR,
                                    'ZTITTT1-TPYFN'  C_ERROR,
                                    'ZTITTT1-TBOCD'  C_ERROR,
                                    'ZTITTT1-TRENO'  C_ERROR,
                                    'ZTITTT1-TOBCD'  C_ERROR,
                                    'ZTITTT1-TOBNM'  C_ERROR,
*                                    'ZTITTT1-TOBAN'  c_error,
                                    'ZTITTT1-TOBAM'  C_ERROR,
                                    'ZTITTT1-TOBAC'  C_ERROR,
                                    'ZTITTT1-TBBCD'  C_ERROR,
                                    'ZTITTT1-TBBNM'  C_ERROR,
*                                    'ZTITTT1-TBBAN'  c_error,
                                    'ZTITTT1-TBBAM'  C_ERROR,
                                    'ZTITTT1-TBBAC'  C_ERROR,
                                    'ZTITTT1-TIBCD'  C_ERROR,
                                    'ZTITTT1-TIBNM'  C_ERROR,
                                    'ZTITTT1-TIBAN'  C_ERROR,
                                    'ZTITTT1-TIBAM'  C_ERROR,
                                    'ZTITTT1-TIBAC'  C_ERROR,
                                    'ZTITTT1-TPYME'  C_ERROR,
                                    'ZTITTT1-TSTCD'  C_ERROR,
*                                    'ZTITRQS-OPAMT'  c_error,
                                    'ZTITRQS-WAERS'  C_ERROR.
*                                    'ZTITTT1-TPYTE1' c_error,
*                                    'ZTITTT1-TPYTE2' c_error,
*                                    'ZTITTT1-TPYTE3' c_error,
*                                    'ZTITTT1-TPYTE4' c_error,
*                                    'ZTITTT1-TPYTE5' c_error.

  PERFORM  CHECK_EDI_AVAILABLE_CHAR2  USING :
                                        'ZTITRQS-OTHT2'  C_ERROR.
  IF ZTITRQK-BUKRS = '1000'.
    CLEAR : LV_STAWN.
    SELECT SINGLE CCNGN
              INTO (LV_STAWN)
    FROM ZMMT0131
   WHERE CCNGN  EQ  ZTITRQS-OTHT1.
    IF  LV_STAWN IS INITIAL.
      MESSAGE E999 WITH '등록할 수 있는 HS-CODE가 아닙니다!'.
    ENDIF.
  ENDIF.

*-{ 기능개선 186601 - 은행정보 변경 시 체크로직 추가
  IF SY-TCODE NE 'ZTIT006'.

    IF ZTITRQK-BUKRS = '1000' OR ZTITRQK-BUKRS = '5000'.
***********************************************************************
      IF ZTITIG04-LIFNR IS INITIAL.
        CLEAR ZTITIG04.
        SELECT SINGLE BNFA
          INTO LV_BNFA
          FROM ZTITIG00
         WHERE BUKRS EQ ZTITRQK-BUKRS.

        IF LV_BNFA EQ 'X'.
          SELECT SINGLE *
            FROM ZTITIG04
           WHERE BUKRS EQ ZTITRQK-BUKRS
             AND LIFNR EQ ZTITRQK-LIFNR
             AND WAERS EQ ZTITRQS-WAERS
             AND APVYN EQ 'B'.
        ENDIF.
      ENDIF.
***********************************************************************
      IF ZTITTT1-TBBCD NE ZTITIG04-TBBAD3. "swift code
        PERFORM SET_RETURN_MESSAGE3 USING 'ZTITTT1' 'TBBCD' C_ERROR.
      ENDIF.

      IF ZTITTT1-TBBAC NE ZTITRQS-WAERS. "통화코드
        PERFORM SET_RETURN_MESSAGE3 USING 'ZTITTT1' 'TBBCD' C_ERROR.
      ENDIF.

      IF ZTITTT1-TBBNM NE ZTITIG04-TBBNM. "은행명
        PERFORM SET_RETURN_MESSAGE3 USING 'ZTITTT1' 'TBBNM' C_ERROR.
      ENDIF.

*      IF ZTITTT1-TBBBR NE ZTITIG04-TBBBR. "지점명
*        PERFORM SET_RETURN_MESSAGE3 USING 'ZTITTT1' 'TBBBR' C_ERROR.
*      ENDIF.

      IF ZTITTT1-TBBAN NE ZTITIG04-TBBAN. "계좌번호
        PERFORM SET_RETURN_MESSAGE3 USING 'ZTITTT1' 'TBBAN' C_ERROR.
      ENDIF.

      IF ZTITTT1-TBBAO NE ZTITIG04-TBBAO. "국가
        PERFORM SET_RETURN_MESSAGE3 USING 'ZTITTT1' 'TBBAO' C_ERROR.
      ENDIF.


      IF NOT ZTITIG04-TIBNM IS INITIAL.
        IF ZTITTT1-TIBNM NE ZTITIG04-TIBNM. "은행명
          PERFORM SET_RETURN_MESSAGE3 USING 'ZTITTT1' 'TIBNM' C_ERROR.
        ENDIF.

*        IF ZTITTT1-TIBBR NE ZTITIG04-TIBBR. "지점명
*          PERFORM SET_RETURN_MESSAGE3 USING 'ZTITTT1' 'TIBBR' C_ERROR.
*        ENDIF.

        IF ZTITTT1-TIBAN NE ZTITIG04-TIBAN. "계좌번호
          PERFORM SET_RETURN_MESSAGE3 USING 'ZTITTT1' 'TIBAN' C_ERROR.
        ENDIF.

        IF ZTITTT1-TIBAC NE ZTITRQS-WAERS. "통화코드
          PERFORM SET_RETURN_MESSAGE3 USING 'ZTITTT1' 'TIBAC' C_ERROR.
        ENDIF.

        IF ZTITTT1-TIBCD NE ZTITIG04-TIBAM. "은행코드
          PERFORM SET_RETURN_MESSAGE3 USING 'ZTITTT1' 'TIBCD' C_ERROR.
        ENDIF.

        IF ZTITTT1-TIBAO NE ZTITIG04-TIBAO. "국가
          PERFORM SET_RETURN_MESSAGE3 USING 'ZTITTT1' 'TIBAO' C_ERROR.
        ENDIF.

      ENDIF.
    ENDIF.
  ENDIF.
*-} 기능개선 186601

ENDMODULE.                 " check_input_value_scr2240  INPUT
*&---------------------------------------------------------------------*
*&      Module  TC_2130_HS_CODE  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE TC_2130_HS_CODE INPUT.

  MOVE ZTISRQIT-STAWN   TO  G_TC_2130_WA-STAWN.
*> H/S code Check.
  IF NOT ( ZTITRQK-REQTY EQ C_LO OR
           ZTITRQK-REQTY EQ C_PU ).
    IF G_TC_2130_WA-STAWN IS INITIAL.
      PERFORM NO_INPUT_CHECK USING 'ZTISRQIT' 'STAWN' C_ERROR.
    ENDIF.
  ENDIF.

  MODIFY  IT_TAB
    FROM  G_TC_2130_WA
    INDEX TC_2130-CURRENT_LINE.

ENDMODULE.                 " TC_2130_HS_CODE  INPUT
*&---------------------------------------------------------------------*
*&      Module  check_input_fields_SCR8000  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE CHECK_INPUT_FIELDS_SCR8000 INPUT.

  CHECK OK-CODE EQ 'ZTIOKAY'.

  IF ZTISSCRCOM-STAWN IS INITIAL.
    PERFORM  NO_INPUT_CHECK USING 'ZTISSCRCOM' 'STAWN' C_ERROR.
  ENDIF.

ENDMODULE.                 " check_input_fields_SCR8000  INPUT
*&---------------------------------------------------------------------*
*&      Module  user_command_scr8000  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_SCR8000 INPUT.

  CASE OK-CODE.
    WHEN 'ZTIOKAY'.
      LEAVE TO SCREEN 0.
    WHEN 'ZTICANCEL'.
      LEAVE TO SCREEN 0.
    WHEN OTHERS.
  ENDCASE.

ENDMODULE.                 " user_command_scr8000  INPUT
*&---------------------------------------------------------------------*
*&      Module  tc_2220_1_check  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE TC_2220_1_CHECK INPUT.

  CASE OK_CODE.
    WHEN 'ZTISEND'.
      CASE ZTITRQK-REQTY.
        WHEN C_PU. "구매확인서 field check.
          IF TC_2220_1-CURRENT_LINE = '1'.
            PERFORM CHECK_PC_DOCUMENT_FIELD_EDI USING G_MODE.
          ENDIF.
        WHEN OTHERS.
      ENDCASE.

    WHEN 'ZTISHOWMSG'.
      CASE ZTITRQK-REQTY.
        WHEN C_PU. "구매확인서 field check.
          IF TC_2220_1-CURRENT_LINE = '1'.
            PERFORM CHECK_PC_DOCUMENT_FIELD_EDI USING G_MODE.
          ENDIF.
        WHEN OTHERS.
      ENDCASE.

    WHEN OTHERS.
  ENDCASE.

ENDMODULE.                 " tc_2220_1_check  INPUT
*&---------------------------------------------------------------------*
*&      Form  check_pc_document_field_edi
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM CHECK_PC_DOCUMENT_FIELD_EDI  USING    P_MODE.

  DATA: L_IF_NULL TYPE REF TO IF_MESSAGE_OBJ_MM.

* Message preparations
  PERFORM  SET_MESSAGE_PREPARATIONS.

  IF ZTITPC2-PBDNO IS INITIAL.
    PERFORM SET_RETURN_MESSAGE USING 'ZTITPC2' 'PBDNO' C_ERROR.
  ENDIF.
  IF ZTITPC2-PBDTY IS INITIAL.
    PERFORM SET_RETURN_MESSAGE USING 'ZTITPC2' 'PBDTY' C_ERROR.
  ENDIF.

*> 오류정보가 존재시 메시지 상자 POPUP.
  G_LINE = G_MESSAGE_HANDLER->GET_SEVERITY_BO(
                          IM_BUSINESS_OBJ          = L_IF_NULL
                          IM_INCLUDE_CHILD_OBJECTS = C_TRUE ).

  IF G_LINE GT 0.
    CALL METHOD G_MESSAGE_HANDLER->SHOW(
        IM_POPUP  = C_TRUE
        IM_AMODAL = C_FALSE ).
  ENDIF.

ENDFORM.                    " check_pc_document_field_edi
*&---------------------------------------------------------------------*
*&      Module  get_okcode_scr2210_sub1  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE GET_OKCODE_SCR2210_SUB1 INPUT.

*> 텍스트 데이타 Put
  G_TEXTID  =  '7'.
  CONCATENATE C_TEXTOBJECT_EDI G_TEXTID INTO G_TEXTOBJ.

  CALL FUNCTION 'Z_TS_TEXT_SET_OKCODE_SINGLE'
    EXPORTING
      IM_TEXTOBJECT = G_TEXTOBJ
      IM_TEXTID     = G_TEXTID
      IM_OKCODE     = OK_CODE.

ENDMODULE.                 " get_okcode_scr2210_sub1  INPUT
*&---------------------------------------------------------------------*
*&      Module  get_okcode_scr2210_sub2  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE GET_OKCODE_SCR2210_SUB2 INPUT.

  G_TEXTID  =  '8'.
  CONCATENATE C_TEXTOBJECT_EDI G_TEXTID INTO G_TEXTOBJ.

  CALL FUNCTION 'Z_TS_TEXT_SET_OKCODE_SINGLE'
    EXPORTING
      IM_TEXTOBJECT = G_TEXTOBJ
      IM_TEXTID     = G_TEXTID
      IM_OKCODE     = OK_CODE.

ENDMODULE.                 " get_okcode_scr2210_sub2  INPUT

*&---------------------------------------------------------------------*
*&      Module  get_okcode_scr2210_sub3  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE GET_OKCODE_SCR2210_SUB3 INPUT.

*> 텍스트 데이타 Put
  G_TEXTID  =  '9'.
  CONCATENATE C_TEXTOBJECT_EDI G_TEXTID INTO G_TEXTOBJ.

  CALL FUNCTION 'Z_TS_TEXT_SET_OKCODE_SINGLE'
    EXPORTING
      IM_TEXTOBJECT = G_TEXTOBJ
      IM_TEXTID     = G_TEXTID
      IM_OKCODE     = OK_CODE.

ENDMODULE.                 " get_okcode_scr2210_sub3  INPUT
*&---------------------------------------------------------------------*
*&      Module  get_textline_scr2210_sub1  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE GET_TEXTLINE_SCR2210_SUB1 INPUT.

  G_TEXTID  =  '7'.
  CONCATENATE C_TEXTOBJECT_EDI G_TEXTID INTO G_TEXTOBJ.

  READ TABLE GT_CONTROL WITH KEY OBJECT = G_TEXTOBJ.
  IF SY-SUBRC EQ 0.
    IT_TEXTTYPES[] = GT_CONTROL-TEXTTYPES[].
    IT_ALL_LINES[] = GT_CONTROL-TEXTLINES[].
  ENDIF.

  CALL FUNCTION 'Z_TS_TEXT_IMP_SUBSCREEN_SINGLE'
    EXPORTING
      IM_TEXTOBJECT = G_TEXTOBJ
      IM_TEXTID     = G_TEXTID
    TABLES
      EXT_TEXTTYPES = IT_TEXTTYPES
      EXT_TEXTLINES = IT_ALL_LINES.

  READ TABLE GT_CONTROL WITH KEY OBJECT = G_TEXTOBJ.
  IF SY-SUBRC EQ 0.
    G_TABIX = SY-TABIX.
    GT_CONTROL-TEXTTYPES[] = IT_TEXTTYPES[].
    GT_CONTROL-TEXTLINES[] = IT_ALL_LINES[].
    MODIFY GT_CONTROL INDEX G_TABIX.
  ENDIF.

ENDMODULE.                 " get_textline_scr2210_sub1  INPUT
*&---------------------------------------------------------------------*
*&      Module  get_textline_scr2210_sub2  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE GET_TEXTLINE_SCR2210_SUB2 INPUT.

  G_TEXTID  =  '8'.
  CONCATENATE C_TEXTOBJECT_EDI G_TEXTID INTO G_TEXTOBJ.

  READ TABLE GT_CONTROL WITH KEY OBJECT = G_TEXTOBJ.
  IF SY-SUBRC EQ 0.
    IT_TEXTTYPES[] = GT_CONTROL-TEXTTYPES[].
    IT_ALL_LINES[] = GT_CONTROL-TEXTLINES[].
  ENDIF.

  CALL FUNCTION 'Z_TS_TEXT_IMP_SUBSCREEN_SINGLE'
    EXPORTING
      IM_TEXTOBJECT = G_TEXTOBJ
      IM_TEXTID     = G_TEXTID
    TABLES
      EXT_TEXTTYPES = IT_TEXTTYPES
      EXT_TEXTLINES = IT_ALL_LINES.

  READ TABLE GT_CONTROL WITH KEY OBJECT = G_TEXTOBJ.
  IF SY-SUBRC EQ 0.
    G_TABIX = SY-TABIX.
    GT_CONTROL-TEXTTYPES[] = IT_TEXTTYPES[].
    GT_CONTROL-TEXTLINES[] = IT_ALL_LINES[].
    MODIFY GT_CONTROL INDEX G_TABIX.
  ENDIF.

ENDMODULE.                 " get_textline_scr2210_sub2  INPUT

*&---------------------------------------------------------------------*
*&      Module  get_textline_scr2210_sub3  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE GET_TEXTLINE_SCR2210_SUB3 INPUT.

  G_TEXTID  =  '9'.
  CONCATENATE C_TEXTOBJECT_EDI G_TEXTID INTO G_TEXTOBJ.

  READ TABLE GT_CONTROL WITH KEY OBJECT = G_TEXTOBJ.
  IF SY-SUBRC EQ 0.
    IT_TEXTTYPES[] = GT_CONTROL-TEXTTYPES[].
    IT_ALL_LINES[] = GT_CONTROL-TEXTLINES[].
  ENDIF.

  CALL FUNCTION 'Z_TS_TEXT_IMP_SUBSCREEN_SINGLE'
    EXPORTING
      IM_TEXTOBJECT = G_TEXTOBJ
      IM_TEXTID     = G_TEXTID
    TABLES
      EXT_TEXTTYPES = IT_TEXTTYPES
      EXT_TEXTLINES = IT_ALL_LINES.

  READ TABLE GT_CONTROL WITH KEY OBJECT = G_TEXTOBJ.
  IF SY-SUBRC EQ 0.
    G_TABIX = SY-TABIX.
    GT_CONTROL-TEXTTYPES[] = IT_TEXTTYPES[].
    GT_CONTROL-TEXTLINES[] = IT_ALL_LINES[].
    MODIFY GT_CONTROL INDEX G_TABIX.
  ENDIF.

ENDMODULE.                 " get_textline_scr2210_sub3  INPUT
*&---------------------------------------------------------------------*
*&      Module  get_okcode_scr2215_sub1  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE GET_OKCODE_SCR2215_SUB1 INPUT.

*> 텍스트 데이타 Put
  G_TEXTID  =  'A'.
  CONCATENATE C_TEXTOBJECT_EDI G_TEXTID INTO G_TEXTOBJ.

  CALL FUNCTION 'Z_TS_TEXT_SET_OKCODE_SINGLE'
    EXPORTING
      IM_TEXTOBJECT = G_TEXTOBJ
      IM_TEXTID     = G_TEXTID
      IM_OKCODE     = OK_CODE.

ENDMODULE.                 " get_okcode_scr2215_sub1  INPUT
*&---------------------------------------------------------------------*
*&      Module  get_textline_scr2215_sub1  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE GET_TEXTLINE_SCR2215_SUB1 INPUT.

  G_TEXTID  =  'A'.
  CONCATENATE C_TEXTOBJECT_EDI G_TEXTID INTO G_TEXTOBJ.

  READ TABLE GT_CONTROL WITH KEY OBJECT = G_TEXTOBJ.
  IF SY-SUBRC EQ 0.
    IT_TEXTTYPES[] = GT_CONTROL-TEXTTYPES[].
    IT_ALL_LINES[] = GT_CONTROL-TEXTLINES[].
  ENDIF.

  CALL FUNCTION 'Z_TS_TEXT_IMP_SUBSCREEN_SINGLE'
    EXPORTING
      IM_TEXTOBJECT = G_TEXTOBJ
      IM_TEXTID     = G_TEXTID
    TABLES
      EXT_TEXTTYPES = IT_TEXTTYPES
      EXT_TEXTLINES = IT_ALL_LINES.

  READ TABLE GT_CONTROL WITH KEY OBJECT = G_TEXTOBJ.
  IF SY-SUBRC EQ 0.
    G_TABIX = SY-TABIX.
    GT_CONTROL-TEXTTYPES[] = IT_TEXTTYPES[].
    GT_CONTROL-TEXTLINES[] = IT_ALL_LINES[].
    MODIFY GT_CONTROL INDEX G_TABIX.
  ENDIF.


ENDMODULE.                 " get_textline_scr2215_sub1  INPUT
*&---------------------------------------------------------------------*
*&      Module  help_exchange_rate  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE HELP_EXCHANGE_RATE INPUT.

  LOOP AT SCREEN.
    IF SCREEN-NAME EQ 'ZTITRQS-AKKUR'.
      EXIT.
    ENDIF.
  ENDLOOP.

  IF SCREEN-INPUT EQ '1'.
    G_DISPALY = ' '.
  ELSE.
    G_DISPALY = C_TRUE.
  ENDIF.

  G_UKURS = ZTITRQS-AKKUR.


  CALL FUNCTION 'F4_EXCHANGE_RATE'
    EXPORTING
      TYPE_OF_RATE     = 'M'
      DATE             = ZTITRQS-OPNDT
      FOREIGN_CURRENCY = ZTITRQS-WAERS
      LOCAL_CURRENCY   = ZTITRQS-HWAER
      DISPLAY_ONLY     = G_DISPALY
    CHANGING
      KURS             = G_UKURS
    EXCEPTIONS
      OTHERS           = 0.

  ZTITRQS-AKKUR = G_UKURS.

ENDMODULE.                 " help_exchange_rate  INPUT
*&---------------------------------------------------------------------*
*&      Module  tc_2124_modify  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE TC_2124_MODIFY INPUT.

*  IF ztitlc4-land1 IS INITIAL AND
*     ztitlc4-fwdcd IS INITIAL AND
*     ztitlc4-fwdty IS INITIAL.
*  ENDIF.
*
**> 선적국가.
*  IF ztitlc4-land1 IS INITIAL.
*    PERFORM no_input_check USING 'ZTITLC4' 'LAND1' c_error.
*  ENDIF.
*
**> 포워더 코드.
*  IF ztitlc4-fwdcd IS INITIAL.
*    PERFORM no_input_check USING 'ZTITLC4' 'FWDCD' c_error.
*  ENDIF.
*  SELECT  SINGLE name1
*    INTO  ztislc04-name1
*    FROM  lfa1
*   WHERE  lifnr  EQ  ztitlc4-fwdcd.
*  IF sy-subrc NE 0.
*    PERFORM message_not_found_vendor USING 'ZTITLC4'
*                                           'FWDCD'
*                                           c_error.
*  ENDIF.
**> 포워더 관리 테이블 CHECK.
*  SELECT SINGLE *
*    FROM ztitig10
*   WHERE fwdcd  EQ  ztitlc4-fwdcd
*     AND land1  EQ  ztitlc4-land1.
*
*  IF sy-subrc NE 0.
*    SET CURSOR FIELD 'ZTITLC4-FWDCD'.
*    MESSAGE e128 WITH ztitlc4-land1 ztislc04-name1.
*  ENDIF.
**> 운송방법.
*  IF ztitlc4-fwdty IS INITIAL.
*    PERFORM no_input_check USING 'ZTITLC4' 'FWDTY' c_error.
*  ENDIF.
*
*--> BL 1000093870 예외처리 - 20250708
  IF ZTISRQIT-IBLNO <> '1000093870'.
    IF ZTISTT4-PAYAT GT ZTISTT4-PAYATL.
      MESSAGE E044.
    ENDIF.
    MOVE-CORRESPONDING ZTISTT4 TO G_TC_2124_WA.

    MODIFY G_TC_2124_ITAB
      FROM G_TC_2124_WA
      INDEX TC_2124-CURRENT_LINE.
  ELSE.
    IF G_TC_2124_ITAB[] IS INITIAL.
      MOVE-CORRESPONDING ZTISTT4 TO G_TC_2124_WA.
      APPEND G_TC_2124_WA TO G_TC_2124_ITAB.
    ELSE.
      MOVE-CORRESPONDING ZTISTT4 TO G_TC_2124_WA.

      MODIFY G_TC_2124_ITAB
        FROM G_TC_2124_WA
        INDEX TC_2124-CURRENT_LINE.
    ENDIF.
  ENDIF.
*<-- BL 1000093870 예외처리 - 20250708
ENDMODULE.                 " tc_2124_modify  INPUT
*&---------------------------------------------------------------------*
*&      Module  tc_2124_mark  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE TC_2124_MARK INPUT.

  IF TC_2124-LINE_SEL_MODE = 1 AND
     G_TC_2124_WA-FLAG = 'X'.
    LOOP AT G_TC_2124_ITAB INTO G_TC_2124_WA
      WHERE FLAG = 'X'.
      G_TC_2124_WA-FLAG = ''.
      MODIFY G_TC_2124_ITAB
        FROM G_TC_2124_WA
        TRANSPORTING FLAG.
    ENDLOOP.
    G_TC_2124_WA-FLAG = 'X'.
  ENDIF.

  MODIFY G_TC_2124_ITAB
    FROM G_TC_2124_WA
    INDEX TC_2124-CURRENT_LINE
    TRANSPORTING FLAG.

ENDMODULE.                 " tc_2124_mark  INPUT
*&---------------------------------------------------------------------*
*&      Module  tc_2124_user_command  INPUT
*&---------------------------------------------------------------------*
*  input module for tc 'TC_2124'. do not change this line!
*  process user command
*----------------------------------------------------------------------*
MODULE TC_2124_USER_COMMAND INPUT.

*> 순번 build.
  CLEAR: G_COUNT.
  LOOP AT G_TC_2124_ITAB INTO G_TC_2124_WA.
    ADD 1 TO G_COUNT.
    G_TC_2124_WA-PAYIT = G_COUNT.
    G_TC_2124_WA-REQNO = ZTITRQK-REQNO.
    MODIFY G_TC_2124_ITAB FROM G_TC_2124_WA.
  ENDLOOP.

  OK_CODE = SY-UCOMM.
  PERFORM USER_OK_TC USING    'TC_2124'
                              'G_TC_2124_ITAB'
                              'FLAG'
                     CHANGING OK_CODE.
  SY-UCOMM = OK_CODE.
  CASE OK_CODE.
    WHEN 'TC_2124_INSERT'.

    WHEN OTHERS.
  ENDCASE.

*> F2 Funtion key Event시 해당 필드의 정보 display
  PERFORM  DOUBLE_CLICK_EVENT.

ENDMODULE.                    "TC_2124_user_command INPUT
*&---------------------------------------------------------------------*
*&      Module  pai_scr2124_check_input_value  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE PAI_SCR2124_CHECK_INPUT_VALUE INPUT.

  CHECK: G_MODE EQ C_CHARC OR  ">생성.
         G_MODE EQ C_CHARM OR  ">변경.
         G_MODE EQ C_CHARY.    ">신청.

  IF ZTITTT1-PAYRS IS INITIAL.
    PERFORM NO_INPUT_CHECK USING 'ZTITTT1' 'PAYRS' C_ERROR.
  ENDIF.

  IF ZTITTT1-GLCNO IS INITIAL.
    PERFORM NO_INPUT_CHECK USING 'ZTITTT1' 'GLCNO' C_ERROR.
  ENDIF.

  IF ZTITTT1-IMACD IS INITIAL.
    PERFORM NO_INPUT_CHECK USING 'ZTITTT1' 'IMACD' C_ERROR.
  ENDIF.

  IF ZTITTT1-DUEDT IS INITIAL.
    PERFORM NO_INPUT_CHECK USING 'ZTITTT1' 'DUEDT' C_ERROR.
  ENDIF.

  IF ZTITTT1-PLIDT IS INITIAL.
    PERFORM NO_INPUT_CHECK USING 'ZTITTT1' 'PLIDT' C_ERROR.
  ENDIF.


ENDMODULE.                 " pai_scr2124_check_input_value  INPUT
*&---------------------------------------------------------------------*
*&      Module  pai_scr2121_set_setlr  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*MODULE pai_scr2121_set_setlr INPUT.
*
*  DATA lv_pernr LIKE pa0001-pernr.
*
*  IF ztitrqs-setlr IS INITIAL.
*    MESSAGE w999 WITH '결재자 입력이 안되었습니다.진행하시겠습니까?' .
*  ELSE.
*    CLEAR pa0001.
*    SELECT SINGLE pernr
*      INTO lv_pernr
*      FROM pa0001
*     WHERE pernr = ztitrqs-setlr.
*    IF sy-subrc <> '0'.
*      MESSAGE e999 WITH '결재자 사번 오류입니다.'  .
*    ENDIF.
*  ENDIF.
*
*ENDMODULE.                 " pai_scr2121_set_setlr INPUT
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  F4_CBNCODE  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE F4_CBNCODE INPUT.


  DATA: T_RETURN LIKE DDSHRETVAL OCCURS 0 WITH HEADER LINE.

  DATA: BEGIN OF T_VALUE OCCURS 0,
          IBKCD LIKE ZTSTIG3-IBKCD,
          NAMET LIKE ZTSTIG3-NAMET,
        END OF T_VALUE.


  SELECT DISTINCT IBKCD NAMET
    INTO CORRESPONDING FIELDS OF TABLE T_VALUE
    FROM ZTSTIG3
   WHERE BUKRS = ZTITRQK-BUKRS
     AND PARTI = 'B'.


  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      RETFIELD        = 'IBKCD'
      VALUE_ORG       = 'S'
    TABLES
      VALUE_TAB       = T_VALUE
      RETURN_TAB      = T_RETURN
    EXCEPTIONS
      PARAMETER_ERROR = 1
      NO_VALUES_FOUND = 2
      OTHERS          = 3.

  IF SY-SUBRC = 0.

    READ TABLE T_RETURN INDEX 1.

    MOVE T_RETURN-FIELDVAL TO ZTITLC1-CBNCODE.

  ENDIF.

ENDMODULE.                 " F4_CBNCODE  INPUT
*&---------------------------------------------------------------------*
*&      Module  GET_OKCODE_SCR2215_SUB1_1  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE GET_OKCODE_SCR2215_SUB1_1 INPUT.

*> 텍스트 데이타 Put
  G_TEXTID  =  'B'.
  CONCATENATE C_TEXTOBJECT_EDI G_TEXTID INTO G_TEXTOBJ.

  CALL FUNCTION 'Z_TS_TEXT_SET_OKCODE_SINGLE'
    EXPORTING
      IM_TEXTOBJECT = G_TEXTOBJ
      IM_TEXTID     = G_TEXTID
      IM_OKCODE     = OK_CODE.


ENDMODULE.                 " GET_OKCODE_SCR2215_SUB1_1  INPUT
*&---------------------------------------------------------------------*
*&      Module  GET_OKCODE_SCR2215_SUB1_2  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE GET_OKCODE_SCR2215_SUB1_2 INPUT.

*> 텍스트 데이타 Put
  G_TEXTID  =  'C'.
  CONCATENATE C_TEXTOBJECT_EDI G_TEXTID INTO G_TEXTOBJ.

  CALL FUNCTION 'Z_TS_TEXT_SET_OKCODE_SINGLE'
    EXPORTING
      IM_TEXTOBJECT = G_TEXTOBJ
      IM_TEXTID     = G_TEXTID
      IM_OKCODE     = OK_CODE.


ENDMODULE.                 " GET_OKCODE_SCR2215_SUB1_2  INPUT
*&---------------------------------------------------------------------*
*&      Module  GET_OKCODE_SCR2215_SUB1_3  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE GET_OKCODE_SCR2215_SUB1_3 INPUT.

*> 텍스트 데이타 Put
  G_TEXTID  =  'D'.
  CONCATENATE C_TEXTOBJECT_EDI G_TEXTID INTO G_TEXTOBJ.

  CALL FUNCTION 'Z_TS_TEXT_SET_OKCODE_SINGLE'
    EXPORTING
      IM_TEXTOBJECT = G_TEXTOBJ
      IM_TEXTID     = G_TEXTID
      IM_OKCODE     = OK_CODE.


ENDMODULE.                 " GET_OKCODE_SCR2215_SUB1_3  INPUT
*&---------------------------------------------------------------------*
*&      Module  GET_OKCODE_SCR2215_SUB2_1  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE GET_OKCODE_SCR2215_SUB2_1 INPUT.

*> 텍스트 데이타 Put
  G_TEXTID  =  'E'.
  CONCATENATE C_TEXTOBJECT_EDI G_TEXTID INTO G_TEXTOBJ.

  CALL FUNCTION 'Z_TS_TEXT_SET_OKCODE_SINGLE'
    EXPORTING
      IM_TEXTOBJECT = G_TEXTOBJ
      IM_TEXTID     = G_TEXTID
      IM_OKCODE     = OK_CODE.


ENDMODULE.                 " GET_OKCODE_SCR2215_SUB2_1  INPUT
*&---------------------------------------------------------------------*
*&      Module  GET_OKCODE_SCR2215_SUB2_2  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE GET_OKCODE_SCR2215_SUB2_2 INPUT.

*> 텍스트 데이타 Put
  G_TEXTID  =  'F'.
  CONCATENATE C_TEXTOBJECT_EDI G_TEXTID INTO G_TEXTOBJ.

  CALL FUNCTION 'Z_TS_TEXT_SET_OKCODE_SINGLE'
    EXPORTING
      IM_TEXTOBJECT = G_TEXTOBJ
      IM_TEXTID     = G_TEXTID
      IM_OKCODE     = OK_CODE.


ENDMODULE.                 " GET_OKCODE_SCR2215_SUB2_2  INPUT
*&---------------------------------------------------------------------*
*&      Module  GET_OKCODE_SCR2215_SUB2_3  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE GET_OKCODE_SCR2215_SUB2_3 INPUT.

*> 텍스트 데이타 Put
  G_TEXTID  =  'G'.
  CONCATENATE C_TEXTOBJECT_EDI G_TEXTID INTO G_TEXTOBJ.

  CALL FUNCTION 'Z_TS_TEXT_SET_OKCODE_SINGLE'
    EXPORTING
      IM_TEXTOBJECT = G_TEXTOBJ
      IM_TEXTID     = G_TEXTID
      IM_OKCODE     = OK_CODE.


ENDMODULE.                 " GET_OKCODE_SCR2215_SUB2_3  INPUT
*&---------------------------------------------------------------------*
*&      Module  GET_OKCODE_SCR2215_SUB3_1  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE GET_OKCODE_SCR2215_SUB3_1 INPUT.

*> 텍스트 데이타 Put
  G_TEXTID  =  'H'.
  CONCATENATE C_TEXTOBJECT_EDI G_TEXTID INTO G_TEXTOBJ.

  CALL FUNCTION 'Z_TS_TEXT_SET_OKCODE_SINGLE'
    EXPORTING
      IM_TEXTOBJECT = G_TEXTOBJ
      IM_TEXTID     = G_TEXTID
      IM_OKCODE     = OK_CODE.


ENDMODULE.                 " GET_OKCODE_SCR2215_SUB3_1  INPUT
*&---------------------------------------------------------------------*
*&      Module  GET_OKCODE_SCR2215_SUB3_2  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE GET_OKCODE_SCR2215_SUB3_2 INPUT.

*> 텍스트 데이타 Put
  G_TEXTID  =  'I'.
  CONCATENATE C_TEXTOBJECT_EDI G_TEXTID INTO G_TEXTOBJ.

  CALL FUNCTION 'Z_TS_TEXT_SET_OKCODE_SINGLE'
    EXPORTING
      IM_TEXTOBJECT = G_TEXTOBJ
      IM_TEXTID     = G_TEXTID
      IM_OKCODE     = OK_CODE.


ENDMODULE.                 " GET_OKCODE_SCR2215_SUB3_2  INPUT
*&---------------------------------------------------------------------*
*&      Module  GET_OKCODE_SCR2215_SUB3_3  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE GET_OKCODE_SCR2215_SUB3_3 INPUT.

*> 텍스트 데이타 Put
  G_TEXTID  =  'J'.
  CONCATENATE C_TEXTOBJECT_EDI G_TEXTID INTO G_TEXTOBJ.

  CALL FUNCTION 'Z_TS_TEXT_SET_OKCODE_SINGLE'
    EXPORTING
      IM_TEXTOBJECT = G_TEXTOBJ
      IM_TEXTID     = G_TEXTID
      IM_OKCODE     = OK_CODE.


ENDMODULE.                 " GET_OKCODE_SCR2215_SUB3_3  INPUT
*&---------------------------------------------------------------------*
*&      Module  GET_OKCODE_SCR2215_SUB4_1  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE GET_OKCODE_SCR2215_SUB4_1 INPUT.

*> 텍스트 데이타 Put
  G_TEXTID  =  'K'.
  CONCATENATE C_TEXTOBJECT_EDI G_TEXTID INTO G_TEXTOBJ.

  CALL FUNCTION 'Z_TS_TEXT_SET_OKCODE_SINGLE'
    EXPORTING
      IM_TEXTOBJECT = G_TEXTOBJ
      IM_TEXTID     = G_TEXTID
      IM_OKCODE     = OK_CODE.


ENDMODULE.                 " GET_OKCODE_SCR2215_SUB4_1  INPUT
*&---------------------------------------------------------------------*
*&      Module  GET_OKCODE_SCR2215_SUB4_2  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE GET_OKCODE_SCR2215_SUB4_2 INPUT.

*> 텍스트 데이타 Put
  G_TEXTID  =  'L'.
  CONCATENATE C_TEXTOBJECT_EDI G_TEXTID INTO G_TEXTOBJ.

  CALL FUNCTION 'Z_TS_TEXT_SET_OKCODE_SINGLE'
    EXPORTING
      IM_TEXTOBJECT = G_TEXTOBJ
      IM_TEXTID     = G_TEXTID
      IM_OKCODE     = OK_CODE.


ENDMODULE.                 " GET_OKCODE_SCR2215_SUB4_2  INPUT
*&---------------------------------------------------------------------*
*&      Module  GET_OKCODE_SCR2215_SUB4_3  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE GET_OKCODE_SCR2215_SUB4_3 INPUT.

*> 텍스트 데이타 Put
  G_TEXTID  =  'M'.
  CONCATENATE C_TEXTOBJECT_EDI G_TEXTID INTO G_TEXTOBJ.

  CALL FUNCTION 'Z_TS_TEXT_SET_OKCODE_SINGLE'
    EXPORTING
      IM_TEXTOBJECT = G_TEXTOBJ
      IM_TEXTID     = G_TEXTID
      IM_OKCODE     = OK_CODE.


ENDMODULE.                 " GET_OKCODE_SCR2215_SUB4_3  INPUT
*&---------------------------------------------------------------------*
*&      Module  GET_TEXTLINE_SCR2215_SUB1_1  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE GET_TEXTLINE_SCR2215_SUB1_1 INPUT.

  G_TEXTID  =  'B'.
  CONCATENATE C_TEXTOBJECT_EDI G_TEXTID INTO G_TEXTOBJ.

  READ TABLE GT_CONTROL WITH KEY OBJECT = G_TEXTOBJ.
  IF SY-SUBRC EQ 0.
    IT_TEXTTYPES[] = GT_CONTROL-TEXTTYPES[].
    IT_ALL_LINES[] = GT_CONTROL-TEXTLINES[].
  ENDIF.

  CALL FUNCTION 'Z_TS_TEXT_IMP_SUBSCREEN_SINGLE'
    EXPORTING
      IM_TEXTOBJECT = G_TEXTOBJ
      IM_TEXTID     = G_TEXTID
    TABLES
      EXT_TEXTTYPES = IT_TEXTTYPES
      EXT_TEXTLINES = IT_ALL_LINES.

  READ TABLE GT_CONTROL WITH KEY OBJECT = G_TEXTOBJ.
  IF SY-SUBRC EQ 0.
    G_TABIX = SY-TABIX.
    GT_CONTROL-TEXTTYPES[] = IT_TEXTTYPES[].
    GT_CONTROL-TEXTLINES[] = IT_ALL_LINES[].
    MODIFY GT_CONTROL INDEX G_TABIX.
  ENDIF.

ENDMODULE.                 " GET_TEXTLINE_SCR2215_SUB1_1  INPUT
*&---------------------------------------------------------------------*
*&      Module  GET_TEXTLINE_SCR2215_SUB1_2  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE GET_TEXTLINE_SCR2215_SUB1_2 INPUT.

  G_TEXTID  =  'C'.
  CONCATENATE C_TEXTOBJECT_EDI G_TEXTID INTO G_TEXTOBJ.

  READ TABLE GT_CONTROL WITH KEY OBJECT = G_TEXTOBJ.
  IF SY-SUBRC EQ 0.
    IT_TEXTTYPES[] = GT_CONTROL-TEXTTYPES[].
    IT_ALL_LINES[] = GT_CONTROL-TEXTLINES[].
  ENDIF.

  CALL FUNCTION 'Z_TS_TEXT_IMP_SUBSCREEN_SINGLE'
    EXPORTING
      IM_TEXTOBJECT = G_TEXTOBJ
      IM_TEXTID     = G_TEXTID
    TABLES
      EXT_TEXTTYPES = IT_TEXTTYPES
      EXT_TEXTLINES = IT_ALL_LINES.

  READ TABLE GT_CONTROL WITH KEY OBJECT = G_TEXTOBJ.
  IF SY-SUBRC EQ 0.
    G_TABIX = SY-TABIX.
    GT_CONTROL-TEXTTYPES[] = IT_TEXTTYPES[].
    GT_CONTROL-TEXTLINES[] = IT_ALL_LINES[].
    MODIFY GT_CONTROL INDEX G_TABIX.
  ENDIF.

ENDMODULE.                 " GET_TEXTLINE_SCR2215_SUB1_2  INPUT
*&---------------------------------------------------------------------*
*&      Module  GET_TEXTLINE_SCR2215_SUB1_3  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE GET_TEXTLINE_SCR2215_SUB1_3 INPUT.

  G_TEXTID  =  'D'.
  CONCATENATE C_TEXTOBJECT_EDI G_TEXTID INTO G_TEXTOBJ.

  READ TABLE GT_CONTROL WITH KEY OBJECT = G_TEXTOBJ.
  IF SY-SUBRC EQ 0.
    IT_TEXTTYPES[] = GT_CONTROL-TEXTTYPES[].
    IT_ALL_LINES[] = GT_CONTROL-TEXTLINES[].
  ENDIF.

  CALL FUNCTION 'Z_TS_TEXT_IMP_SUBSCREEN_SINGLE'
    EXPORTING
      IM_TEXTOBJECT = G_TEXTOBJ
      IM_TEXTID     = G_TEXTID
    TABLES
      EXT_TEXTTYPES = IT_TEXTTYPES
      EXT_TEXTLINES = IT_ALL_LINES.

  READ TABLE GT_CONTROL WITH KEY OBJECT = G_TEXTOBJ.
  IF SY-SUBRC EQ 0.
    G_TABIX = SY-TABIX.
    GT_CONTROL-TEXTTYPES[] = IT_TEXTTYPES[].
    GT_CONTROL-TEXTLINES[] = IT_ALL_LINES[].
    MODIFY GT_CONTROL INDEX G_TABIX.
  ENDIF.

ENDMODULE.                 " GET_TEXTLINE_SCR2215_SUB1_3  INPUT
*&---------------------------------------------------------------------*
*&      Module  GET_TEXTLINE_SCR2215_SUB2_1  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE GET_TEXTLINE_SCR2215_SUB2_1 INPUT.

  G_TEXTID  =  'E'.
  CONCATENATE C_TEXTOBJECT_EDI G_TEXTID INTO G_TEXTOBJ.

  READ TABLE GT_CONTROL WITH KEY OBJECT = G_TEXTOBJ.
  IF SY-SUBRC EQ 0.
    IT_TEXTTYPES[] = GT_CONTROL-TEXTTYPES[].
    IT_ALL_LINES[] = GT_CONTROL-TEXTLINES[].
  ENDIF.

  CALL FUNCTION 'Z_TS_TEXT_IMP_SUBSCREEN_SINGLE'
    EXPORTING
      IM_TEXTOBJECT = G_TEXTOBJ
      IM_TEXTID     = G_TEXTID
    TABLES
      EXT_TEXTTYPES = IT_TEXTTYPES
      EXT_TEXTLINES = IT_ALL_LINES.

  READ TABLE GT_CONTROL WITH KEY OBJECT = G_TEXTOBJ.
  IF SY-SUBRC EQ 0.
    G_TABIX = SY-TABIX.
    GT_CONTROL-TEXTTYPES[] = IT_TEXTTYPES[].
    GT_CONTROL-TEXTLINES[] = IT_ALL_LINES[].
    MODIFY GT_CONTROL INDEX G_TABIX.
  ENDIF.

ENDMODULE.                 " GET_TEXTLINE_SCR2215_SUB2_1  INPUT
*&---------------------------------------------------------------------*
*&      Module  GET_TEXTLINE_SCR2215_SUB2_2  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE GET_TEXTLINE_SCR2215_SUB2_2 INPUT.

  G_TEXTID  =  'F'.
  CONCATENATE C_TEXTOBJECT_EDI G_TEXTID INTO G_TEXTOBJ.

  READ TABLE GT_CONTROL WITH KEY OBJECT = G_TEXTOBJ.
  IF SY-SUBRC EQ 0.
    IT_TEXTTYPES[] = GT_CONTROL-TEXTTYPES[].
    IT_ALL_LINES[] = GT_CONTROL-TEXTLINES[].
  ENDIF.

  CALL FUNCTION 'Z_TS_TEXT_IMP_SUBSCREEN_SINGLE'
    EXPORTING
      IM_TEXTOBJECT = G_TEXTOBJ
      IM_TEXTID     = G_TEXTID
    TABLES
      EXT_TEXTTYPES = IT_TEXTTYPES
      EXT_TEXTLINES = IT_ALL_LINES.

  READ TABLE GT_CONTROL WITH KEY OBJECT = G_TEXTOBJ.
  IF SY-SUBRC EQ 0.
    G_TABIX = SY-TABIX.
    GT_CONTROL-TEXTTYPES[] = IT_TEXTTYPES[].
    GT_CONTROL-TEXTLINES[] = IT_ALL_LINES[].
    MODIFY GT_CONTROL INDEX G_TABIX.
  ENDIF.

ENDMODULE.                 " GET_TEXTLINE_SCR2215_SUB2_2  INPUT
*&---------------------------------------------------------------------*
*&      Module  GET_TEXTLINE_SCR2215_SUB2_3  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE GET_TEXTLINE_SCR2215_SUB2_3 INPUT.

  G_TEXTID  =  'G'.
  CONCATENATE C_TEXTOBJECT_EDI G_TEXTID INTO G_TEXTOBJ.

  READ TABLE GT_CONTROL WITH KEY OBJECT = G_TEXTOBJ.
  IF SY-SUBRC EQ 0.
    IT_TEXTTYPES[] = GT_CONTROL-TEXTTYPES[].
    IT_ALL_LINES[] = GT_CONTROL-TEXTLINES[].
  ENDIF.

  CALL FUNCTION 'Z_TS_TEXT_IMP_SUBSCREEN_SINGLE'
    EXPORTING
      IM_TEXTOBJECT = G_TEXTOBJ
      IM_TEXTID     = G_TEXTID
    TABLES
      EXT_TEXTTYPES = IT_TEXTTYPES
      EXT_TEXTLINES = IT_ALL_LINES.

  READ TABLE GT_CONTROL WITH KEY OBJECT = G_TEXTOBJ.
  IF SY-SUBRC EQ 0.
    G_TABIX = SY-TABIX.
    GT_CONTROL-TEXTTYPES[] = IT_TEXTTYPES[].
    GT_CONTROL-TEXTLINES[] = IT_ALL_LINES[].
    MODIFY GT_CONTROL INDEX G_TABIX.
  ENDIF.

ENDMODULE.                 " GET_TEXTLINE_SCR2215_SUB2_3  INPUT
*&---------------------------------------------------------------------*
*&      Module  GET_TEXTLINE_SCR2215_SUB3_1  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE GET_TEXTLINE_SCR2215_SUB3_1 INPUT.

  G_TEXTID  =  'H'.
  CONCATENATE C_TEXTOBJECT_EDI G_TEXTID INTO G_TEXTOBJ.

  READ TABLE GT_CONTROL WITH KEY OBJECT = G_TEXTOBJ.
  IF SY-SUBRC EQ 0.
    IT_TEXTTYPES[] = GT_CONTROL-TEXTTYPES[].
    IT_ALL_LINES[] = GT_CONTROL-TEXTLINES[].
  ENDIF.

  CALL FUNCTION 'Z_TS_TEXT_IMP_SUBSCREEN_SINGLE'
    EXPORTING
      IM_TEXTOBJECT = G_TEXTOBJ
      IM_TEXTID     = G_TEXTID
    TABLES
      EXT_TEXTTYPES = IT_TEXTTYPES
      EXT_TEXTLINES = IT_ALL_LINES.

  READ TABLE GT_CONTROL WITH KEY OBJECT = G_TEXTOBJ.
  IF SY-SUBRC EQ 0.
    G_TABIX = SY-TABIX.
    GT_CONTROL-TEXTTYPES[] = IT_TEXTTYPES[].
    GT_CONTROL-TEXTLINES[] = IT_ALL_LINES[].
    MODIFY GT_CONTROL INDEX G_TABIX.
  ENDIF.

ENDMODULE.                 " GET_TEXTLINE_SCR2215_SUB3_1  INPUT
*&---------------------------------------------------------------------*
*&      Module  GET_TEXTLINE_SCR2215_SUB3_2  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE GET_TEXTLINE_SCR2215_SUB3_2 INPUT.

  G_TEXTID  =  'I'.
  CONCATENATE C_TEXTOBJECT_EDI G_TEXTID INTO G_TEXTOBJ.

  READ TABLE GT_CONTROL WITH KEY OBJECT = G_TEXTOBJ.
  IF SY-SUBRC EQ 0.
    IT_TEXTTYPES[] = GT_CONTROL-TEXTTYPES[].
    IT_ALL_LINES[] = GT_CONTROL-TEXTLINES[].
  ENDIF.

  CALL FUNCTION 'Z_TS_TEXT_IMP_SUBSCREEN_SINGLE'
    EXPORTING
      IM_TEXTOBJECT = G_TEXTOBJ
      IM_TEXTID     = G_TEXTID
    TABLES
      EXT_TEXTTYPES = IT_TEXTTYPES
      EXT_TEXTLINES = IT_ALL_LINES.

  READ TABLE GT_CONTROL WITH KEY OBJECT = G_TEXTOBJ.
  IF SY-SUBRC EQ 0.
    G_TABIX = SY-TABIX.
    GT_CONTROL-TEXTTYPES[] = IT_TEXTTYPES[].
    GT_CONTROL-TEXTLINES[] = IT_ALL_LINES[].
    MODIFY GT_CONTROL INDEX G_TABIX.
  ENDIF.

ENDMODULE.                 " GET_TEXTLINE_SCR2215_SUB3_2  INPUT
*&---------------------------------------------------------------------*
*&      Module  GET_TEXTLINE_SCR2215_SUB3_3  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE GET_TEXTLINE_SCR2215_SUB3_3 INPUT.

  G_TEXTID  =  'J'.
  CONCATENATE C_TEXTOBJECT_EDI G_TEXTID INTO G_TEXTOBJ.

  READ TABLE GT_CONTROL WITH KEY OBJECT = G_TEXTOBJ.
  IF SY-SUBRC EQ 0.
    IT_TEXTTYPES[] = GT_CONTROL-TEXTTYPES[].
    IT_ALL_LINES[] = GT_CONTROL-TEXTLINES[].
  ENDIF.

  CALL FUNCTION 'Z_TS_TEXT_IMP_SUBSCREEN_SINGLE'
    EXPORTING
      IM_TEXTOBJECT = G_TEXTOBJ
      IM_TEXTID     = G_TEXTID
    TABLES
      EXT_TEXTTYPES = IT_TEXTTYPES
      EXT_TEXTLINES = IT_ALL_LINES.

  READ TABLE GT_CONTROL WITH KEY OBJECT = G_TEXTOBJ.
  IF SY-SUBRC EQ 0.
    G_TABIX = SY-TABIX.
    GT_CONTROL-TEXTTYPES[] = IT_TEXTTYPES[].
    GT_CONTROL-TEXTLINES[] = IT_ALL_LINES[].
    MODIFY GT_CONTROL INDEX G_TABIX.
  ENDIF.

ENDMODULE.                 " GET_TEXTLINE_SCR2215_SUB3_3  INPUT
*&---------------------------------------------------------------------*
*&      Module  GET_TEXTLINE_SCR2215_SUB4_1  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE GET_TEXTLINE_SCR2215_SUB4_1 INPUT.

  G_TEXTID  =  'K'.
  CONCATENATE C_TEXTOBJECT_EDI G_TEXTID INTO G_TEXTOBJ.

  READ TABLE GT_CONTROL WITH KEY OBJECT = G_TEXTOBJ.
  IF SY-SUBRC EQ 0.
    IT_TEXTTYPES[] = GT_CONTROL-TEXTTYPES[].
    IT_ALL_LINES[] = GT_CONTROL-TEXTLINES[].
  ENDIF.

  CALL FUNCTION 'Z_TS_TEXT_IMP_SUBSCREEN_SINGLE'
    EXPORTING
      IM_TEXTOBJECT = G_TEXTOBJ
      IM_TEXTID     = G_TEXTID
    TABLES
      EXT_TEXTTYPES = IT_TEXTTYPES
      EXT_TEXTLINES = IT_ALL_LINES.

  READ TABLE GT_CONTROL WITH KEY OBJECT = G_TEXTOBJ.
  IF SY-SUBRC EQ 0.
    G_TABIX = SY-TABIX.
    GT_CONTROL-TEXTTYPES[] = IT_TEXTTYPES[].
    GT_CONTROL-TEXTLINES[] = IT_ALL_LINES[].
    MODIFY GT_CONTROL INDEX G_TABIX.
  ENDIF.

ENDMODULE.                 " GET_TEXTLINE_SCR2215_SUB4_1  INPUT
*&---------------------------------------------------------------------*
*&      Module  GET_TEXTLINE_SCR2215_SUB4_2  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE GET_TEXTLINE_SCR2215_SUB4_2 INPUT.

  G_TEXTID  =  'L'.
  CONCATENATE C_TEXTOBJECT_EDI G_TEXTID INTO G_TEXTOBJ.

  READ TABLE GT_CONTROL WITH KEY OBJECT = G_TEXTOBJ.
  IF SY-SUBRC EQ 0.
    IT_TEXTTYPES[] = GT_CONTROL-TEXTTYPES[].
    IT_ALL_LINES[] = GT_CONTROL-TEXTLINES[].
  ENDIF.

  CALL FUNCTION 'Z_TS_TEXT_IMP_SUBSCREEN_SINGLE'
    EXPORTING
      IM_TEXTOBJECT = G_TEXTOBJ
      IM_TEXTID     = G_TEXTID
    TABLES
      EXT_TEXTTYPES = IT_TEXTTYPES
      EXT_TEXTLINES = IT_ALL_LINES.

  READ TABLE GT_CONTROL WITH KEY OBJECT = G_TEXTOBJ.
  IF SY-SUBRC EQ 0.
    G_TABIX = SY-TABIX.
    GT_CONTROL-TEXTTYPES[] = IT_TEXTTYPES[].
    GT_CONTROL-TEXTLINES[] = IT_ALL_LINES[].
    MODIFY GT_CONTROL INDEX G_TABIX.
  ENDIF.

ENDMODULE.                 " GET_TEXTLINE_SCR2215_SUB4_2  INPUT
*&---------------------------------------------------------------------*
*&      Module  GET_TEXTLINE_SCR2215_SUB4_3  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE GET_TEXTLINE_SCR2215_SUB4_3 INPUT.

  G_TEXTID  =  'M'.
  CONCATENATE C_TEXTOBJECT_EDI G_TEXTID INTO G_TEXTOBJ.

  READ TABLE GT_CONTROL WITH KEY OBJECT = G_TEXTOBJ.
  IF SY-SUBRC EQ 0.
    IT_TEXTTYPES[] = GT_CONTROL-TEXTTYPES[].
    IT_ALL_LINES[] = GT_CONTROL-TEXTLINES[].
  ENDIF.

  CALL FUNCTION 'Z_TS_TEXT_IMP_SUBSCREEN_SINGLE'
    EXPORTING
      IM_TEXTOBJECT = G_TEXTOBJ
      IM_TEXTID     = G_TEXTID
    TABLES
      EXT_TEXTTYPES = IT_TEXTTYPES
      EXT_TEXTLINES = IT_ALL_LINES.

  READ TABLE GT_CONTROL WITH KEY OBJECT = G_TEXTOBJ.
  IF SY-SUBRC EQ 0.
    G_TABIX = SY-TABIX.
    GT_CONTROL-TEXTTYPES[] = IT_TEXTTYPES[].
    GT_CONTROL-TEXTLINES[] = IT_ALL_LINES[].
    MODIFY GT_CONTROL INDEX G_TABIX.
  ENDIF.

ENDMODULE.                 " GET_TEXTLINE_SCR2215_SUB4_3  INPUT
