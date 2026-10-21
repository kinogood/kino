************************************************************************
* Title         :  ZTIR0000I01                                         *
*                                                                      *
* Description   : 수입 B/L 관리 PAI Include                            *
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
*&      Module  tc_2130_modify  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE TC_2130_MODIFY INPUT.

  CHECK: G_MODE EQ C_CHARC OR
         G_MODE EQ C_CHARM OR
         G_MODE EQ C_CHARY.

  IF ZTISBLIT-NDFTY IS INITIAL OR
     ZTISBLIT-NDFTY EQ C_CHARO OR
     ZTISBLIT-NDFTY EQ C_CHARA.
    IF NOT ( ZTISBLIT-EBELN IS INITIAL AND
             ZTISBLIT-RSNUM IS INITIAL ).
      G_BLMNGL   = ZTISBLIT-BLMNGL + ZTISBLIT-BLMNGM.
*      g_blmngl_1 = ZTIsblit-blmng  - ZTIsblit-ppmng.

*      IF ZTIsblit-blmng GT ZTIsblit-blmngl.
      IF ZTISBLIT-BLMNG GT G_BLMNGL.
        CLEAR: G_MENGET.
*        WRITE ZTIsblit-blmngl TO g_menget(15) UNIT ZTIsblit-meins.
        WRITE G_BLMNGL        TO G_MENGET(15) UNIT ZTISBLIT-MEINS.
        CONCATENATE G_MENGET ZTISBLIT-MEINS INTO G_MENGET.
        MESSAGE E208 WITH G_MENGET.
      ENDIF.
*> 선급수량 체크 로직.
      IF ZTISBLIT-BLMNG LT ZTISBLIT-PPMNG.
        WRITE ZTISBLIT-PPMNG   TO G_MENGET(15) UNIT ZTISBLIT-MEINS.
        CONCATENATE G_MENGET ZTISBLIT-MEINS INTO G_MENGET.
        MESSAGE E230 WITH G_MENGET.
      ENDIF.
*> 선급금액 체크 로직.
      IF ZTISBLIT-REFWR GT 0.
        IF ZTISBLIT-REFWR LT ZTISBLIT-PPAMT.
          WRITE ZTISBLIT-PPAMT TO G_WRBTR1(17) CURRENCY ZTITBLK-WAERS.
          CONCATENATE G_WRBTR1 ZTITBLK-WAERS INTO G_WRBTR1.
          MESSAGE E233 WITH G_WRBTR1.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDIF.

*> 무환일 경우 체크 로직.
  IF ZTISBLIT-EBELN IS INITIAL AND
     ZTISBLIT-RSNUM IS INITIAL.
    IF ZTISBLIT-IBLIT IS INITIAL.
      IF ZTISBLIT-NDFTY IS INITIAL AND
         ZTISBLIT-BLMNG IS INITIAL AND
         ZTISBLIT-MATNR IS INITIAL AND
         ZTISBLIT-MATNR IS INITIAL.
        CLEAR: ZTISBLIT.
        EXIT.
      ENDIF.
    ELSE.
      IF ZTISBLIT-NDFTY IS INITIAL AND
         ZTISBLIT-BLMNG IS INITIAL AND
         ZTISBLIT-MATNR IS INITIAL AND
         ZTISBLIT-MATNR IS INITIAL.
        DELETE IT_TAB WHERE IBLIT = ZTISBLIT-IBLIT.
        CLEAR: ZTISBLIT.
        EXIT.
      ENDIF.
    ENDIF.
*> 무환 종류 체크.
    IF ZTISBLIT-NDFTY IS INITIAL.
      ZTISBLIT-NDFTY = C_CHARS.
*      PERFORM no_input_check USING 'ZTISBLIT' 'NDFTY' c_error.
    ENDIF.
    IF ZTISBLIT-NDFTY EQ C_CHARO.
      SET CURSOR FIELD 'ZTISBLIT-NDFTY'.
      MESSAGE E215.
    ENDIF.
    IF ZTISBLIT-NDFTY EQ C_CHARN.
      SET CURSOR FIELD 'ZTISBLIT-NDFTY'.
      MESSAGE E227.
    ENDIF.
    IF ZTISBLIT-NDFTY EQ C_CHARA.
      SET CURSOR FIELD 'ZTISBLIT-NDFTY'.
      MESSAGE E228.
    ENDIF.
*> 수량 체크.
    IF ZTISBLIT-BLMNG IS INITIAL.
      PERFORM NO_INPUT_CHECK USING 'ZTISBLIT' 'BLMNG' C_ERROR.
    ENDIF.
*> 자재코드 체크.
    IF ZTISBLIT-MATNR IS INITIAL.
      PERFORM NO_INPUT_CHECK USING 'ZTISBLIT' 'MATNR' C_ERROR.
    ENDIF.
    SELECT SINGLE MEINS
      INTO ZTISBLIT-MEINS
      FROM MARA
     WHERE MATNR EQ ZTISBLIT-MATNR.
    IF SY-SUBRC EQ 0.
      SELECT SINGLE MAKTX
        INTO ZTISBLIT-TXZ01
        FROM MAKT
       WHERE MATNR  EQ  ZTISBLIT-MATNR
         AND SPRAS  EQ  SY-LANGU.
    ENDIF.

**> 단위 체크.
*    IF ZTIsblit-meins IS INITIAL.
*      ZTIsblit-meins = G_MEINS.
*      IF ZTIsblit-meins IS INITIAL.
*        PERFORM no_input_check USING 'ZTISBLIT' 'MEINS' c_error.
*      ENDIF.
*    ENDIF.

*> 플랜트 체크.
    IF ZTISBLIT-WERKS IS INITIAL.
*      ztisblit-werks = '1000'.
      PERFORM NO_INPUT_CHECK USING 'ZTISBLIT' 'WERKS' C_ERROR.
    ENDIF.
    SELECT SINGLE NAME1 J_1BBRANCH
      INTO (ZTISBLIT-NAME1, ZTISBLIT-BUPLA)
      FROM T001W
     WHERE WERKS  EQ  ZTISBLIT-WERKS.
*> 단가 체크.
    IF ZTISBLIT-NETPR IS INITIAL.
      PERFORM NO_INPUT_CHECK USING 'ZTISBLIT' 'NETPR' C_ERROR.
    ENDIF.
*> 단가단위 체크.
    IF ZTISBLIT-PEINH IS INITIAL.
      ZTISBLIT-PEINH = 1.
    ENDIF.
    ZTISBLIT-BPUMZ = ZTISBLIT-BPUMN = 1.
    ZTISBLIT-BPRME = ZTISBLIT-MEINS.
  ENDIF.
  IF ZTISBLIT-WAERS IS INITIAL.
    ZTISBLIT-WAERS = ZTITBLK-WAERS.
  ENDIF.

*-<< CHM2204-00302 - 원산지 증명서 추가
  IF ZTITBLK-BUKRS EQ '1000' AND ZTISBLIT-ZCOTY IS INITIAL.
    if ZTISBLIT-MATNR <> '000000000007100001'.
    PERFORM NO_INPUT_CHECK USING 'ZTISBLIT' 'ZCOTY' C_ERROR.
    endif.
  ENDIF.
*->> CHM2204-00302

  MOVE-CORRESPONDING ZTISBLIT TO G_TC_2130_WA.

*> 정가 계산.
  CALL FUNCTION 'Z_TI_CALC_ITEM_AMOUNT'
    EXPORTING
      PEINH = G_TC_2130_WA-PEINH
      BPUMZ = G_TC_2130_WA-BPUMZ
      BPUMN = G_TC_2130_WA-BPUMN
      MENGE = G_TC_2130_WA-BLMNG
      NETPR = G_TC_2130_WA-NETPR
    CHANGING
      NETWR = G_TC_2130_WA-NETWR.

  G_TC_2130_WA-NETWR = G_TC_2130_WA-NETWR - G_TC_2130_WA-PPAMT.

  IF G_TC_2130_WA-NETWR LT 0.
    G_TC_2130_WA-NETWR = 0.
  ENDIF.

  IF G_TC_2130_WA-REFWR  IS INITIAL.
    G_TC_2130_WA-REFWR = G_TC_2130_WA-NETWR.
  ENDIF.

*> 수량이 변경되었을 경우.
  IF G_MENGE_REQUEST EQ C_TRUE.
    G_TC_2130_WA-REFWR = G_TC_2130_WA-NETWR.
  ENDIF.

  IF G_TC_2130_WA-REFWR NE G_TC_2130_WA-NETWR.
    MESSAGE I212.
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
    INDEX G_INDEX.
*    INDEX tc_2130-current_line.

  IF SY-SUBRC NE 0.
    APPEND G_TC_2130_WA TO IT_TAB.
  ENDIF.

  CLEAR: G_MENGE_REQUEST, G_WRBTR_REQUEST.

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
                                USING  ZTITBLK.
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
*> 수입의뢰 종류가 변경된 경우.
    IF ZTISSCRCOM-REQTY NE ZTITRQK-REQTY.
      PERFORM GET_DOMAIN_VALUE_TEXT
                  USING
                     'ZTIREQTY'
                     ZTITRQK-REQTY
                     G_TEXT32.
      MESSAGE W112 WITH G_TEXT32.
      ZTISSCRCOM-REQTY = ZTITRQK-REQTY.
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
      IF SY-TCODE EQ C_DUE_LIST_OFE.
        MOVE: 'ZTICOPY' TO OK_CODE,
              'ZTICOPY' TO SY-UCOMM.
      ELSEIF SY-TCODE EQ C_DUE_LIST_TT.
        MOVE: 'ZTICOPY1' TO OK_CODE,
              'ZTICOPY1' TO SY-UCOMM.
      ENDIF.
    ELSE.
      G_TCODE = SY-TCODE.
    ENDIF.
  ENDIF.

*> Input fields check
  IF NOT ( OK_CODE EQ 'ZTICOPY' OR OK_CODE EQ 'ZTICOPY1' ).
************************************************************************
*> 무환 문서일 경우..... 로직... START
************************************************************************
    IF ZTISSCRCOM-EBELN IS INITIAL AND
       ZTISSCRCOM-REQNO IS INITIAL AND
       ZTISSCRCOM-OPNNO IS INITIAL.
*> 메시지 출력.
      MESSAGE W218.
      CLEAR: ZTISSCRCOM-EBELN, ZTISSCRCOM-VBELN,
             G_RADIO2, G_RADIO3, G_RADIO4, G_RADIO5,
             G_RADIO6, G_RADIO7, G_RADIO8, G_RADIO9.
      G_RADIO1 = C_TRUE.

      CALL SCREEN '7020' STARTING AT 01 01.
*                         ENDING AT x2 y2
      IF G_ANSWER EQ 'N'.
        MESSAGE S900.
      ELSE.
*>
        PERFORM P3000_SET_DATA_OF_SCREEN.

        CASE G_ANSWER.
          WHEN '1'.  ">무환(보상품목)
            ZTITBLK-BLDTY = C_CHARS.
            G_NDFTY       = C_CHARR.
            MOVE: ZTISSCRCOM-EBELN TO ZTITBLK-EBELN.
            G_ANSWER = C_CHARY.
          WHEN '2'.  ">무환(수리품목)
            ZTITBLK-BLDTY = C_CHARS.
            G_NDFTY       = C_CHARB.
            MOVE: ZTISSCRCOM-EBELN TO ZTITBLK-EBELN.
            G_ANSWER = C_CHARY.
          WHEN '3'.  ">무환(대체품목)
            ZTITBLK-BLDTY = C_CHARS.
            G_NDFTY       = C_CHARC.
            MOVE: ZTISSCRCOM-EBELN TO ZTITBLK-EBELN.
            G_ANSWER = C_CHARY.
          WHEN '4'.  ">무환(샘플품)
            ZTITBLK-BLDTY = C_CHARS.
            G_NDFTY       = C_CHARS.
            MOVE: ZTISSCRCOM-EBELN TO ZTITBLK-EBELN.
            G_ANSWER = C_CHARY.
          WHEN '9'.  ">무환(ShipBack)
            ZTITBLK-BLDTY = C_CHARH.
            G_NDFTY       = C_CHARH.
            MOVE: ZTISSCRCOM-VBELN TO ZTITBLK-VBELN.
            G_ANSWER = C_CHARY.
          WHEN OTHERS.
            EXIT.
        ENDCASE.
      ENDIF.
*----> 영업문서 참조시..
      IF ZTITBLK-BLDTY EQ C_CHARH.

      ELSE.
*----> 구매오더 참조시..
        IF NOT ZTITBLK-EBELN IS INITIAL.
          DESCRIBE TABLE IT_EKPO LINES G_LINE.
          IF G_LINE EQ 0.
            MESSAGE E249 WITH ZTISSCRCOM-EBELN.
          ENDIF.
          MOVE-CORRESPONDING : IT_EKPO TO G_TC_2130_WA,
                               IT_EKPO TO ZTIVPO00,
                               IT_EKPO TO IT_ZTISRQIT.
          LOOP AT IT_EKPO.
            PERFORM SET_BILL_OF_LADING_DATA_PO TABLES IT_TAB
                                               USING  ZTIVPO00
                                                      ZTITBLK
                                                      IT_EKPO.
          ENDLOOP.
          IF SY-SUBRC EQ 0.
            READ TABLE IT_EKPO INDEX 1.
            MOVE-CORRESPONDING IT_EKPO TO ZTITBLK.
          ENDIF.
          ZTITBLK-BLDTY  = C_CHARS.
*  >아이템 번호를 생성함.
          PERFORM SET_ITEM_NUMBER_BUILD TABLES IT_TAB
                                        USING  ZTITBLK.
        ENDIF.
      ENDIF.
*>아이템 기타 정보 Read.
      PERFORM  SET_OTHERS_FIELDS_BY_ITEMS.
*>화면상의 Text를 Master Data 등에서 Read.
      PERFORM  GET_OTHERS_TEXT_BY_MASTER_DATA.
*>B/L 금액 체크.
      PERFORM  CHECK_OPEN_AMOUNT USING C_TRUE C_TRUE.

*>초기값 Setting
      PERFORM  SET_INITIAL_DATA.

      EXIT.
    ENDIF.
************************************************************************
*> 무환 문서일 경우..... 로직... END
************************************************************************
  ENDIF.

*> 구매오더 Select.
  IF NOT ( OK_CODE EQ 'ZTICOPY' OR OK_CODE EQ 'ZTICOPY1' ).
*  IF NOT ZTIsscrcom-ebeln IS INITIAL.
    PERFORM P3000_SET_DATA_OF_SCREEN.

    CLEAR: G_COUNT.

    IF ZTISSCRCOM-REQNO IS INITIAL.
      PERFORM  GET_REQUEST_NO_BY_PO_NUMBER1 USING ZTISSCRCOM-EBELN
                                                  ZTISSCRCOM-REQNO
                                                  ZTISSCRCOM-AMDSQ
                                                  C_FALSE.
    ENDIF.
    IF ZTISSCRCOM-REQNO IS INITIAL.
      PERFORM  GET_REQUEST_NO_BY_OPEN_NUMBER1 USING ZTISSCRCOM-OPNNO
                                                    ZTISSCRCOM-REQNO
                                                    ZTISSCRCOM-AMDSQ
                                                    C_FALSE.
    ENDIF.
    IF NOT ZTISSCRCOM-REQNO IS INITIAL.
      PERFORM GET_BL_DOCUMENT_DATA TABLES IT_ZTISRQIT
                                   USING  ZTISSCRCOM-REQNO
                                          ZTISSCRCOM-AMDSQ
                                          '00000'
                                          C_ERROR
                                          C_ERROR.
      LOOP AT IT_ZTISRQIT.
        CLEAR: G_MODIFY, ZTIVRQ00.
        DESCRIBE TABLE IT_TAB LINES G_COUNT_1.
        PERFORM  GET_AND_CHECK_LC_DATA   USING  IT_ZTISRQIT-REQNO
                                                IT_ZTISRQIT-AMDSQ
                                                IT_ZTISRQIT-REQIT
                                                G_MODIFY
                                                ZTIVRQ00
                                                G_COUNT_1
                                                C_ERROR.
*> L/C data Move
        PERFORM SET_BILL_OF_LADING_DATA    TABLES IT_TAB
                                           USING  ZTIVRQ00
                                                  ZTITBLK
                                                  IT_ZTISRQIT.
      ENDLOOP.
    ENDIF.

  ELSEIF OK_CODE EQ 'ZTICOPY' .
*    g_tcode         = c_due_list_ofe.
    PERFORM P3000_SET_DATA_OF_SCREEN.
    ZTITBLK-BLDTY  = C_CHARO.

    LOOP AT IT_RESB.
      MOVE-CORRESPONDING IT_RESB TO G_TC_2130_WA.
      MOVE: 1             TO G_TC_2130_WA-PEINH,
            1             TO G_TC_2130_WA-BPUMZ,
            1             TO G_TC_2130_WA-BPUMN.
*              it_resb-bstmg TO g_tc_2130_wa-menge,
*              it_resb-bstme TO g_tc_2130_wa-meins.
*
      IF IT_RESB-ENMNG NE 0.
        G_TC_2130_WA-NETPR = IT_RESB-ENWRT / IT_RESB-ENMNG.
      ENDIF.

      MOVE: SY-UNAME TO G_TC_2130_WA-CNAM,
            SY-DATLO TO G_TC_2130_WA-CDAT,
            SY-TIMLO TO G_TC_2130_WA-CTME,
            SY-UNAME TO G_TC_2130_WA-UNAM,
            SY-DATLO TO G_TC_2130_WA-UDAT,
            SY-TIMLO TO G_TC_2130_WA-UTME,
            C_CHARO  TO G_TC_2130_WA-NDFTY,
            C_TRUE   TO G_TC_2130_WA-WEPOS,
            C_TRUE   TO G_TC_2130_WA-REPOS.

      APPEND G_TC_2130_WA  TO IT_TAB.

      MOVE : IT_RESB-LIFNR TO ZTITBLK-LIFNR,
             IT_RESB-PARBU TO ZTITBLK-BUKRS,
             IT_RESB-WAERS TO ZTITBLK-WAERS,
             C_CHARO       TO ZTITBLK-BLDTY.
    ENDLOOP.
*>아이템 번호를 생성함.
    PERFORM SET_ITEM_NUMBER_BUILD TABLES IT_TAB
                                  USING  ZTITBLK.
*>--------------------------------------------------------------------
*> 사후 송금 B/L
*>--------------------------------------------------------------------
  ELSEIF OK_CODE EQ 'ZTICOPY1' .

    PERFORM P3000_SET_DATA_OF_SCREEN.
    ZTITBLK-BLDTY  = C_CHARA.
    LOOP AT IT_EKPO.
      MOVE-CORRESPONDING : IT_EKPO TO G_TC_2130_WA,
                           IT_EKPO TO ZTIVPO00,
                           IT_EKPO TO IT_ZTISRQIT.

*> L/C data Move
      SELECT SINGLE *
        FROM ZTIVPO00
       WHERE EBELN  EQ  IT_EKPO-EBELN
         AND EBELP  EQ  IT_EKPO-EBELP.

      PERFORM SET_BILL_OF_LADING_DATA_TT TABLES IT_TAB
                                         USING  ZTIVPO00
                                                ZTITBLK
                                                IT_EKPO.

    ENDLOOP.
    IF SY-SUBRC EQ 0.
      READ TABLE IT_EKPO INDEX 1.
      MOVE-CORRESPONDING IT_EKPO TO ZTITBLK.
    ENDIF.
    ZTITBLK-BLDTY  = C_CHARA.
*>아이템 번호를 생성함.
    PERFORM SET_ITEM_NUMBER_BUILD TABLES IT_TAB
                                  USING  ZTITBLK.
  ENDIF.

** JS전선 회사코드 2007/04 KSH --------------------------------------
*> AUTHORIZATION_CHECK
  PERFORM P1102_AUTHORIZATION_CHECK USING ZTITBLK-BUKRS.
** JS전선 회사코드 2007/04 KSH --------------------------------------

*>아이템 기타 정보 Read.
  PERFORM  SET_OTHERS_FIELDS_BY_ITEMS.
*>화면상의 Text를 Master Data 등에서 Read.
  PERFORM  GET_OTHERS_TEXT_BY_MASTER_DATA.
*>B/L 금액 체크.
  PERFORM  CHECK_OPEN_AMOUNT USING C_TRUE C_TRUE.
*>초기값 Setting
  PERFORM  SET_INITIAL_DATA.

*>엠트론 관련 BL매핑
  PERFORM SET_BL_MAP_EMTRON .


  G_ANSWER = C_CHARY.

ENDMODULE.                 " pai_scr0100_check_input_fields  INPUT
*&---------------------------------------------------------------------*
*&      Module  user_command_scr0100  INPUT
*&---------------------------------------------------------------------*
MODULE USER_COMMAND_SCR0100 INPUT.

  CHECK G_ANSWER EQ C_CHARY.
*> EXIT확인.
  PERFORM  CHECK_PROGRAM_EXIT_COMMAND.

*> Text Object 관련 Internal Table Initial.
  PERFORM  GET_LONGTEXT_DATA.

*> Create Class Object.
  PERFORM  BUILD_CLASS_OBJECT.

*> Generic Object Service.
  PERFORM  SET_GENERIC_OBJECT_SERVICE USING   C_TEXTOBJECT_HEADER
                                               ZTITBLK+3(10).

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

  IF ZTISSCRCOM-IBLNO IS INITIAL AND
     ZTISSCRCOM-BLNUM IS INITIAL.
    MESSAGE E913.
  ENDIF.

** [기계요청] 20060703 simcho by C2006062601000000323
** BL 상업송장 생성 여부 체크-BL변경일 경우만
*  IF sy-tcode = 'ZTIT202'.
*    CLEAR ztitivp.                   " [Import] 상업송장 Items table
*    DATA lv_ivono LIKE ztitivp-ivono.
*    SELECT SINGLE ivono INTO lv_ivono
*      FROM ztitivp
*     WHERE iblno = ztisscrcom-iblno.
*
*    IF sy-subrc = 0.
*      CLEAR ztitivk.
*      SELECT SINGLE ivono INTO lv_ivono
*        FROM ztitivk
*       WHERE ivono = lv_ivono
*         AND livst = 'P'. "전기완료
*
*      IF sy-subrc = 0.
*        MESSAGE e922 WITH '상업송장이 생성된' .
*      ENDIF.
*    ENDIF.
*  ENDIF.
* end simcho by C2006062601000000323

  CLEAR: G_COUNT.
  IF ZTISSCRCOM-IBLNO IS INITIAL.
    PERFORM  GET_BL_INT_NO_BY_BL_NUMBER  USING ZTISSCRCOM-BLNUM
                                               ZTISSCRCOM-IBLNO
                                               C_FALSE.
  ENDIF.

  IF NOT ZTISSCRCOM-IBLNO IS INITIAL.
    CALL FUNCTION 'Z_TI_GET_BILL_OF_LADING'
      EXPORTING
        IBLNO     = ZTISSCRCOM-IBLNO
      IMPORTING
        ZTITBLK   = ZTITBLK
      TABLES
        ZTITBLP   = IT_TAB
        ZTITBLC   = XZTITBLC
      EXCEPTIONS
        NOT_FOUND = 1
        OTHERS    = 2.
    IF SY-SUBRC <> 0.
      MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
              WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    ENDIF.

*-[XXXXX] 엠트론 한정 조회모드/사후송금 일때 참고용으로
*  대표송장 및 개설관리번호 품목별 매핑 (더블클릭시 화면 이동)
    IF G_MODE EQ C_S AND ZTITBLK-BUKRS EQ C_3000 AND
       ZTITBLK-BLDTY EQ C_A.
      PERFORM SET_REQNO_IVNO_BL_LINK.
    ENDIF.

** JS전선 회사코드 2007/04 KSH --------------------------------------
*> authorization
    PERFORM GET_AUTHORIZATION_BUKRS.
    IF L_YN NE 'A'.
      IF ZTITBLK-BUKRS <> A_BUKRS.
        MESSAGE E998 WITH ZTITBLK-BUKRS  '권한이 없습니다!'..
      ENDIF.
    ENDIF.
** JS전선 회사코드 2007/04 KSH --------------------------------------

*> 변경 문서 관리를 위한 이전데이타를 Move.
     *ZTITBLK   = ZTITBLK.
    YZTITBLC[] = XZTITBLC[].
    REFRESH: G_TC_2122_ITAB.
    LOOP AT YZTITBLC.
      CLEAR: G_TC_2122_WA.
      MOVE-CORRESPONDING YZTITBLC TO G_TC_2122_WA.
      APPEND G_TC_2122_WA TO G_TC_2122_ITAB.
    ENDLOOP.

*> 변경 문서 관리를 위한 이전데이타를 Move (Item Data).
    REFRESH: XZTITBLP, YZTITBLP.
    LOOP AT IT_TAB INTO G_TC_2130_WA.
      MOVE-CORRESPONDING G_TC_2130_WA TO : XZTITBLP,
                                           YZTITBLP.
      APPEND : XZTITBLP, YZTITBLP.

    ENDLOOP.
*>업무영역별 Status Check.
    PERFORM  CHECK_DOCUMENT_STATUS.
*>아이템 기타 정보 Read.
    PERFORM  SET_OTHERS_FIELDS_BY_ITEMS.
*>화면상의 Text를 Master Data 등에서 Read.
    PERFORM  GET_OTHERS_TEXT_BY_MASTER_DATA.
*>조회모드가 아닌 경우 Lock.
    IF G_MODE NE C_CHARS.
      PERFORM SET_BL_LOCK_OBJECT   USING ZTITBLK-IBLNO
                                         '00000'
                                         C_LOCK
                                         C_ERROR
                                         G_MODIFY.
    ENDIF.
*> Document History 조회.
    PERFORM GET_DOCUMENT_HISTORY   TABLES IT_DOCHIS
                                   USING  G_DOCUMENT
                                          ZTITBLK-IBLNO
                                          '00'
                                          G_HISTORY.
*> Cost Document History 조회.
    PERFORM GET_COST_DOCUMENT      TABLES IT_COSTDOC
                                   USING  G_DOCUMENT
                                          ZTITBLK-BUKRS
                                          ZTITBLK-IBLNO
                                          '00'
                                          G_HISTORY_COST.
  ELSE.
    MESSAGE E902.
  ENDIF.
*> B/L 금액 체크.
  PERFORM  CHECK_OPEN_AMOUNT USING C_FALSE C_FALSE.

  G_ANSWER = C_CHARY.

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
*&      Module  pAI_SET_scr2210_sub1_subscreen  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE PAI_SET_SCR2210_SUB1_SUBSCREEN INPUT.

  G_CALL_PROG        =  C_COMMON_PROG.
  G_CALL_SUBSCREEN   =  C_SCR0300.

ENDMODULE.                 " pAI_SET_scr2210_sub1_subscreen  INPUT

*&---------------------------------------------------------------------*
*&      Module  pAI_SET_scr2210_sub2_subscreen  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE PAI_SET_SCR2210_SUB2_SUBSCREEN INPUT.

  G_CALL_PROG        =  C_COMMON_PROG.
  G_CALL_SUBSCREEN   =  C_SCR0300.


ENDMODULE.                 " pAI_SET_scr2210_sub2_subscreen  INPUT
*&---------------------------------------------------------------------*
*&      Module  pAI_SET_scr2210_sub3_subscreen  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE PAI_SET_SCR2210_SUB3_SUBSCREEN INPUT.

  G_CALL_PROG        =  C_COMMON_PROG.
  G_CALL_SUBSCREEN   =  C_SCR0300.

ENDMODULE.                 " pAI_SET_scr2210_sub3_subscreen  INPUT

*&---------------------------------------------------------------------*
*&      Module  user_command_2210  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_2210 INPUT.

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
   WHERE BUKRS EQ ZTITBLK-BUKRS.
  IF SY-SUBRC NE 0.
    MESSAGE E035 WITH ZTITBLK-BUKRS.
  ENDIF.

*> 문서상태 Fixed value read.
  PERFORM  DDIC_DOMAIN_VALUE_TEXT_READ USING 'ZTICRLSE'
                                             SY-LANGU
                                             ZTITBLK-CRLSE
                                             G_DDTEXT
                                             C_SUCCESS.
  L_DDTEXT = G_DDTEXT.

*> 문서상태 Fixed value read.
  PERFORM  DDIC_DOMAIN_VALUE_TEXT_READ USING 'ZTIBLDST'
                                             SY-LANGU
                                             ZTITBLK-BLDST
                                             G_DDTEXT
                                             C_SUCCESS.
  L_DDTEXT1 = G_DDTEXT.

  CASE G_MODE.
    WHEN C_CHARM.             "> 생성/변경.
      CASE ZTITIG00-BLPCS.
        WHEN  C_CHARA OR C_CHARB.
          IF ZTITBLK-BLDST NE C_CHARA.
            MESSAGE E919 WITH L_DDTEXT1.
          ENDIF.
        WHEN   C_CHARZ.
      ENDCASE.
    WHEN C_CHARD.             "> 삭제.
      CASE ZTITIG00-BLPCS.
        WHEN  C_CHARA OR C_CHARB.
          IF ZTITBLK-BLDST NE C_CHARA.
            MESSAGE E919 WITH L_DDTEXT1.
          ENDIF.
        WHEN   C_CHARZ.
      ENDCASE.
    WHEN C_CHARA.             "> 선적서류 송부.
      CASE ZTITIG00-BLPCS.
        WHEN  C_CHARA.
          IF ZTITBLK-BLDST NE C_CHARA.
            IF ZTITBLK-BLDST EQ C_CHARB.
              MESSAGE W921 WITH L_DDTEXT1.
            ELSE.
              MESSAGE E919 WITH L_DDTEXT1.
            ENDIF.
          ENDIF.
        WHEN   C_CHARZ.
          MESSAGE E919 WITH L_DDTEXT1.
      ENDCASE.
    WHEN C_CHARY.             "> 실입항 입력.
      CASE ZTITIG00-BLPCS.
        WHEN  C_CHARA.
          IF ZTITBLK-BLDST EQ C_CHARA OR
*             ztitblk-bldst EQ c_charB OR
             ZTITBLK-BLDST EQ C_CHARD.
            MESSAGE W921 WITH L_DDTEXT1.
          ELSE.
            IF ZTITBLK-BLDST EQ C_CHARE.
              MESSAGE W921 WITH L_DDTEXT1.
            ELSEIF ZTITBLK-BLDST NE C_CHARA.
              MESSAGE W921 WITH L_DDTEXT1.
            ELSEIF ZTITBLK-BLDST NE C_CHARB.
              MESSAGE E919 WITH L_DDTEXT1.
            ENDIF.
          ENDIF.
        WHEN C_CHARB.
          IF ZTITBLK-BLDST EQ C_CHARD.
            MESSAGE W921 WITH L_DDTEXT1.
          ELSE.
            IF ZTITBLK-BLDST NE C_CHARA.
              MESSAGE E919 WITH L_DDTEXT1.
            ENDIF.
          ENDIF.
        WHEN   C_CHARZ.
          MESSAGE E919 WITH L_DDTEXT1.
      ENDCASE.
    WHEN C_CHARO.             "> 기타.
      IF ZTITIG00-CCRPC IS INITIAL.
        MESSAGE E242.
      ELSE.
        CASE ZTITIG00-BLPCS.
          WHEN  C_CHARA OR C_CHARB.
            IF ZTITBLK-BLDST EQ C_CHARE.
              MESSAGE W921 WITH L_DDTEXT1.
            ELSEIF ZTITBLK-BLDST NE C_CHARD.
              MESSAGE E919 WITH L_DDTEXT1.
            ENDIF.
        ENDCASE.
      ENDIF.
  ENDCASE.

  MESSAGE S922 WITH L_DDTEXT1.
*
ENDFORM.                    " check_document_status
*&---------------------------------------------------------------------*
*&      Form  tc_2122_modify
*&---------------------------------------------------------------------*
* input module for tc 'TC_2122'. do not change this line!
* modify table
*----------------------------------------------------------------------*
MODULE TC_2122_MODIFY INPUT.

  MOVE-CORRESPONDING ZTITBLC TO G_TC_2122_WA.

  IF G_TC_2122_WA-CNAM IS INITIAL.
    MOVE: SY-UNAME TO G_TC_2122_WA-CNAM,
          SY-DATLO TO G_TC_2122_WA-CDAT,
          SY-TIMLO TO G_TC_2122_WA-CTME.
  ENDIF.

  MOVE: SY-UNAME TO G_TC_2122_WA-UNAM,
        SY-DATLO TO G_TC_2122_WA-UDAT,
        SY-TIMLO TO G_TC_2122_WA-UTME.

*> Container data Modify.
  MODIFY G_TC_2122_ITAB
    FROM G_TC_2122_WA
    INDEX TC_2122-CURRENT_LINE.
  IF SY-SUBRC NE 0.
    APPEND G_TC_2122_WA TO G_TC_2122_ITAB.
  ENDIF.

ENDMODULE.                    "TC_2122_modify INPUT
*&---------------------------------------------------------------------*
*&      Form  tc_2122_mark
*&---------------------------------------------------------------------*
* input module for tc 'TC_2122'. do not change this line!
* mark table
*----------------------------------------------------------------------*
MODULE TC_2122_MARK INPUT.
  IF TC_2122-LINE_SEL_MODE = 1 AND
     G_TC_2122_WA-FLAG = 'X'.
    LOOP AT G_TC_2122_ITAB INTO G_TC_2122_WA
      WHERE FLAG = 'X'.
      G_TC_2122_WA-FLAG = ''.
      MODIFY G_TC_2122_ITAB
        FROM G_TC_2122_WA
        TRANSPORTING FLAG.
    ENDLOOP.
    G_TC_2122_WA-FLAG = 'X'.
  ENDIF.

  MODIFY G_TC_2122_ITAB
    FROM G_TC_2122_WA
    INDEX TC_2122-CURRENT_LINE
    TRANSPORTING FLAG.

ENDMODULE.                    "TC_2122_mark INPUT
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
  IF G_MODE NE C_CHARS.
    CLEAR G_COUNT.
    LOOP AT G_TC_2122_ITAB INTO G_TC_2122_WA.
      ADD 1 TO G_COUNT.
      MOVE G_COUNT TO G_TC_2122_WA-CTNSQ.
      MODIFY G_TC_2122_ITAB FROM G_TC_2122_WA.
    ENDLOOP.
  ENDIF.
*> F2 Funtion key Event시 해당 필드의 정보 display
  PERFORM  DOUBLE_CLICK_EVENT.

ENDMODULE.                 " USER_COMMAND_2122  INPUT
*&---------------------------------------------------------------------*
*&      Module  check_BL_NUMBER  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE CHECK_BL_NUMBER INPUT.

  CHECK : G_MODE EQ C_CHARC OR
          G_MODE EQ C_CHARM.

  IF G_BLNUM_CHK1 IS INITIAL.
    IF ZTITBLK-BLNUM IS INITIAL.
      PERFORM NO_INPUT_CHECK USING 'ZTITBLK' 'BLNUM' C_WARNING.
      G_BLNUM_CHK1 = C_TRUE.
    ENDIF.
  ENDIF.

  IF G_BLNUM_CHK2 IS INITIAL.
    IF NOT ZTITBLK-BLNUM IS INITIAL.
      SELECT BLNUM
        INTO G_BLNUM
        FROM ZTITBLK UP TO 1 ROWS
       WHERE BLNUM   EQ   ZTITBLK-BLNUM
         AND IBLNO   NE   ZTITBLK-IBLNO.
      ENDSELECT.
*> B/L Number 중복시 오류메시지.
      IF SY-SUBRC EQ 0 AND
         NOT G_BLNUM  IS INITIAL.
        CASE ZTITIG00-BLDDT.
          WHEN C_WARNING OR SPACE.
            MESSAGE W211 WITH ZTITBLK-BLNUM.
          WHEN C_INFO.
            MESSAGE I243 WITH ZTITBLK-BLNUM.
          WHEN OTHERS.
            MESSAGE E243 WITH ZTITBLK-BLNUM.
        ENDCASE.
        G_BLNUM_CHK2 = C_TRUE.
      ENDIF.
    ENDIF.
  ENDIF.

ENDMODULE.                 " check_bl_number  INPUT
*&---------------------------------------------------------------------*
*&      Module  check_insr  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE CHECK_INSR.

  DATA : LV_IIPNO LIKE ZTITIP1-IIPNO.

*  lr_inco1-option = 'EQ'.
*  lr_inco1-low    = 'FOB'.  APPEND lr_inco1.
*  lr_inco1-low    = 'FCA'.  APPEND lr_inco1.
*  lr_inco1-low    = 'FAS'.  APPEND lr_inco1.
*  lr_inco1-low    = 'CPT'.  APPEND lr_inco1.
*  lr_inco1-low    = 'CFR'.  APPEND lr_inco1.
*  lr_inco1-low    = 'EXW'.  APPEND lr_inco1.

******************************************************************
* 20070206 simcho By 박혁세 K 요청 BL조회시에는 불필요함
******************************************************************
  IF SY-TCODE = 'ZTIT200' OR
     SY-TCODE = 'ZTIR201' OR
     SY-TCODE = 'ZTIT201'.

    IF ZTITRQS-INCO1 = 'EXW' OR
       ZTITRQS-INCO1 = 'FOB' OR
       ZTITRQS-INCO1 = 'FCA' OR
       ZTITRQS-INCO1 = 'CFR' OR
       ZTITRQS-INCO1 = 'CPT' OR
       ZTITRQS-INCO1 = 'FAS'.

      CLEAR ZTITIP1.
      SELECT SINGLE IIPNO INTO LV_IIPNO
        FROM ZTITIP1
       WHERE REQNO = ZTITRQS-REQNO.
*       AND docst = 'O'   "부보완료.

******************************************************************
* 20090917 simcho by 오민석K
* 부보내역 체크 로직 삭제
******************************************************************
*      IF sy-subrc <> 0.
*        MESSAGE w998 WITH ztitrqs-reqno '부보내역이 없습니다.'.
*      ENDIF.
    ENDIF.

* 사후송금 경우 check
    IF ZTITBLK-INCO1 = 'EXW' OR
       ZTITBLK-INCO1 = 'FOB' OR
       ZTITBLK-INCO1 = 'FCA' OR
       ZTITRQS-INCO1 = 'CFR' OR
       ZTITRQS-INCO1 = 'CPT' OR
       ZTITBLK-INCO1 = 'FAS'.

      CLEAR ZTITIP1.
      SELECT SINGLE IIPNO INTO LV_IIPNO
        FROM ZTITIP1
       WHERE EBELN = ZTITBLK-EBELN.
*       AND docst = 'O'   "부보완료.

******************************************************************
* 20090917 simcho by 오민석K
* 부보내역 체크 로직 삭제
******************************************************************
*      IF sy-subrc <> 0.
*        MESSAGE w998 WITH ztitblk-ebeln '부보내역이 없습니다.'.
*      ENDIF.

    ENDIF.
  ENDIF.

ENDMODULE.                    "check_insr
*&---------------------------------------------------------------------*
*&      Module  check_bl_number_changed  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE CHECK_BL_NUMBER_CHANGED INPUT.

  CLEAR: G_BLNUM_CHK1, G_BLNUM_CHK2.

ENDMODULE.                 " check_bl_number_chainged  INPUT
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

  IF ZTISSCRCOM-IVAMT IS INITIAL.
    PERFORM  NO_INPUT_CHECK USING 'ZTISSCRCOM' 'IVAMT' C_ERROR.
  ENDIF.
*> 금액 비교.
  IF ZTISSCRCOM-IVAMT = ZTITBLK-SMAMT.
    MESSAGE E221.
  ELSEIF ZTISSCRCOM-IVAMT > ZTITBLK-SMAMT.
    MESSAGE W222.
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
      LEAVE TO SCREEN 0.
    WHEN 'ZTICANCEL'.
      LEAVE TO SCREEN 0.
    WHEN OTHERS.
  ENDCASE.

ENDMODULE.                 " user_command_scr7000  INPUT
*&---------------------------------------------------------------------*
*&      Module  check_input_fields_scr2121  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE CHECK_INPUT_FIELDS_SCR2121 INPUT.

  CHECK: G_MODE EQ C_CHARC OR
         G_MODE EQ C_CHARM OR
         G_MODE EQ C_CHARA OR
         G_MODE EQ C_CHARY OR
         G_MODE EQ C_CHARO.

*> 통화단위.
  IF ZTITBLK-WAERS IS INITIAL.
    PERFORM NO_INPUT_CHECK USING 'ZTITBLK' 'WAERS' C_ERROR.
  ENDIF.

**> 회사코드.
*  IF ztitblk-bukrs IS INITIAL.
*    PERFORM no_input_check USING 'ZTITBLK' 'BUKRS' c_error.
*  ENDIF.
*
*> 체크 로직으로 이관.
**> ASP Interface가 아닐경우. 신고구분 체크.
*  IF ZTITBLK-crlse NE c_charb.
  IF ZTITIG00-BLPCS EQ 'Z'.
    IF ZTITBLK-RPTTY IS INITIAL.
      PERFORM NO_INPUT_CHECK USING 'ZTITBLK' 'RPTTY' C_ERROR.
    ENDIF.
  ENDIF.
*  ENDIF.

*> ETD
  IF ZTITBLK-BLETD IS INITIAL.
    PERFORM NO_INPUT_CHECK USING 'ZTITBLK' 'BLETD' C_ERROR.
  ENDIF.
*> ETA
  IF ZTITBLK-BLETA IS INITIAL.
    PERFORM NO_INPUT_CHECK USING 'ZTITBLK' 'BLETA' C_ERROR.
  ENDIF.
*> 거래구분.
  IF ZTITBLK-CSATY IS INITIAL.
    PERFORM NO_INPUT_CHECK USING 'ZTITBLK' 'CSATY' C_ERROR.
  ENDIF.
*> 수입구분.
*  IF ztitblk-impty IS INITIAL.
*    PERFORM no_input_check USING 'ZTITBLK' 'IMPTY' c_error.
*  ENDIF.

  IF ZTITBLK-BLETA LT ZTITBLK-BLETD AND
     NOT ZTITBLK-BLETD IS INITIAL.
    PERFORM NO_INPUT_CHECK USING 'ZTITBLK' 'BLETD' C_SUCCESS.
    MESSAGE E119 WITH 'ETA(출항예정일)' 'ETD(도착예정일)'.
  ENDIF.

***********************************************************************
* 20060627 simcho by C2006062701000000242
* 1. 포더업체 → 필수코드化
* 2. 20FT QTY, 40FT QTY 입력란 : 운송형태가 FCL일 경우 필수코드化
* 3. 포장유형 : 필수코드化
* 4. 총포장개수, 총중량, 볼륨(운임중량) : 필수코드化
* 5. 기능개선 294534 추가 - 항공은 컨테이너 타입 체크 안함
***********************************************************************

  IF ZTITBLK-FWDFM = 'F' AND ZTITBLK-FWDTY = 'O'. "294534 추가
    IF ZTITBLK-CTNQ2 IS INITIAL
    AND ZTITBLK-CTNQ4 IS INITIAL.                           "20FT Qty
      MESSAGE E915 WITH '20FT QTY or 40FT QTY'.
    ENDIF.
  ELSE.
  ENDIF.

***********************************************************************
*-> 기능개선 99963 - FCL일 때 40FT QTY 는 포장유형 필수코드
*                    해상(FOB/EXW) LCL일 경우 M3 이외 값 에러
*                    항공(FOB/EXW)은 KG 이외 값 에러 (운임계산을 위해서)
***********************************************************************
  IF ZTITBLK-BUKRS EQ '1000' OR ZTITBLK-BUKRS EQ '5000'.

    IF ZTITBLK-FWDTY = 'O'   AND ZTITBLK-FWDFM = 'L' .
      CHECK ZTITBLK-INCO1 = 'FOB' OR  ZTITBLK-INCO1 = 'EXW' OR
            ZTITBLK-INCO1 = 'FAS' OR  ZTITBLK-INCO1 = 'FCA'. "296419 추가
      IF NOT ZTITBLK-VOLEH = 'M3'.
        MESSAGE E999 WITH '볼륨(운임중량) 단위는 M3입니다'.
      ENDIF.
    ENDIF.

    IF ZTITBLK-FWDTY = 'A'.
      CHECK ZTITBLK-INCO1 = 'FOB' OR  ZTITBLK-INCO1 = 'EXW' OR
            ZTITBLK-INCO1 = 'FAS' OR  ZTITBLK-INCO1 = 'FCA'. "296419 추가
      IF NOT ZTITBLK-VOLEH = 'KG'.
        MESSAGE E999 WITH '볼륨(운임중량) 단위는 KG입니다'.
      ENDIF.
    ENDIF.

  ENDIF.

***********************************************************************
*-> 기능개선 283274 - 운송경로 추가
***********************************************************************
*> 운송경로
  IF ZTITBLK-BUKRS EQ '1000' .
    IF ZTITBLK-INCO1 = 'EXW' OR ZTITBLK-INCO1 = 'FOB' OR
       ZTITBLK-INCO1 = 'FAS' OR ZTITBLK-INCO1 = 'FCA'. "296419 추가

      IF ZTITBLK-RPTTY NE C_CHARZ. "기능개선 298023 - 미통관 제외
        PERFORM GET_ZROUTE_DESC USING ZTITBLK-BUKRS
                                      ZTITBLK-ZROUTE
                                      GV_BEZEI.

        IF ZTITBLK-ZROUTE IS NOT INITIAL AND GV_BEZEI IS INITIAL.
          MESSAGE E605 WITH '운송경로' ZTITBLK-ZROUTE.
        ENDIF.

        PERFORM GET_FORT USING ZTITBLK-BUKRS
                               ZTITBLK-ZROUTE
                               ZTITBLK-FLAND
                               ZTITBLK-FPORT.

*-<< 기능개선 298023 - 포장유형 세분화
        IF ZTITBLK-FWDFM = 'F' AND ZTITBLK-FWDTY = 'O'.
          IF NOT ZTITBLK-CTNQ4 IS INITIAL OR
             NOT ZTITBLK-CTNQ2 IS INITIAL.
            IF ZTITBLK-CTNTY IS INITIAL.
              MESSAGE E999 WITH '포장유형을 입력하세요.'.
            ELSE.
              IF ZTITBLK-CTNTY NE 'D' AND
                 ZTITBLK-CTNTY NE 'H' AND
                 ZTITBLK-CTNTY NE 'O' AND
                 ZTITBLK-CTNTY NE 'F' AND
                 ZTITBLK-CTNTY NE 'Z'.
                MESSAGE E999 WITH '포장유형 D/H/O/F/Z만 가능합니다'.
              ENDIF.
            ENDIF.
          ENDIF.
        ENDIF.
*->> 기능개선 298023

        IF ZTITBLK-FWDTY NE 'O' AND ZTITBLK-FWDTY NE 'A'.
          MESSAGE E999 WITH '해상/항공만 가능합니다'.
        ENDIF.

        IF ZTITBLK-FWDTY = 'O'.
          IF ZTITBLK-FWDFM NE 'F' AND ZTITBLK-FWDFM NE 'L'.
            MESSAGE E999 WITH 'FCL/LCL만 가능합니다'.
          ENDIF.
        ENDIF.

      ENDIF.
    ENDIF.
  ENDIF.
***********************************************************************

*  IF ztitblk-ctnty IS INITIAL.         "포장유형
*    PERFORM no_input_check USING 'ZTITBLK' 'CTNTY' c_error.
*  ENDIF.

  IF ZTITBLK-VOLUM IS INITIAL.     "볼륨
    PERFORM NO_INPUT_CHECK USING 'ZTITBLK' 'VOLUM' C_ERROR.
  ENDIF.

  IF ZTITBLK-BRGEW IS INITIAL.     "총중량
    PERFORM NO_INPUT_CHECK USING 'ZTITBLK' 'BRGEW' C_ERROR.
  ENDIF.

  IF ZTITBLK-BIPKG IS INITIAL.     " 포장개수
    PERFORM NO_INPUT_CHECK USING 'ZTITBLK' 'BIPKG' C_ERROR.
  ENDIF.


*-<< 가온전선의 경우 필수값 제외 20260721
  IF ZTITBLK-BUKRS NE '6000' .
* 포워더 필수 입력조건 인도조건에 따라
  IF ZTITBLK-INCO1 = 'EXW' OR
     ZTITBLK-INCO1 = 'FAS' OR
     ZTITBLK-INCO1 = 'FCA' OR
     ZTITBLK-INCO1 = 'FOB'.
    IF ZTITBLK-FWDCD IS INITIAL.     " 포워더
      PERFORM NO_INPUT_CHECK USING 'ZTITBLK' 'FWDCD' C_ERROR.
    ENDIF.
  ENDIF.
 ENDIF.
***********************************************************************
* 20060628 simcho end
***********************************************************************


*> 운송방법.
  IF ZTITBLK-FWDTY IS INITIAL.
    PERFORM NO_INPUT_CHECK USING 'ZTITBLK' 'FWDTY' C_ERROR.
  ENDIF.
*> 선기명.
  IF ZTITBLK-IVSLN IS INITIAL.
    PERFORM NO_INPUT_CHECK USING 'ZTITBLK' 'IVSLN' C_ERROR.
  ENDIF.
*> 운송형태.
  IF ZTITBLK-FWDTY EQ C_CHARO.
    IF ZTITBLK-FWDFM IS INITIAL.
      PERFORM NO_INPUT_CHECK USING 'ZTITBLK' 'FWDFM' C_ERROR.
    ELSE.
      IF ZTITBLK-FWDFM EQ C_CHARF OR
         ZTITBLK-FWDFM EQ C_CHART.
        IF ZTITBLK-CTNQ2 IS INITIAL AND
           ZTITBLK-CTNQ4 IS INITIAL.
          PERFORM NO_INPUT_CHECK USING 'ZTITBLK' 'CTNQ2' C_ERROR.
        ENDIF.
*        IF ztitblk-ctnsz IS INITIAL.
*          PERFORM no_input_check USING 'ZTITBLK' 'CTNSZ' c_error.
*        ENDIF.
      ENDIF.
    ENDIF.
  ENDIF.

*--> LG전선에서 추가된 필드. by MSH
*> 원본여부.
  IF ZTITBLK-BLAYN IS INITIAL.
    PERFORM NO_INPUT_CHECK USING 'ZTITBLK' 'BLAYN' C_ERROR.
  ELSE.
    IF ZTITBLK-BLAYN EQ C_CHARO.
      IF ZTITBLK-OJRDT IS INITIAL.
        PERFORM NO_INPUT_CHECK USING 'ZTITBLK' 'OJRDT' C_ERROR.
      ENDIF.
    ENDIF.
  ENDIF.

**> 통관예정일.
*  IF ztitblk-cdpdt IS INITIAL.
*    PERFORM no_input_check USING 'ZTITBLK' 'CDPDT' c_error.
*  ENDIF.
*> 포장종류.
  IF ZTITBLK-BIPKG IS INITIAL.
    PERFORM NO_INPUT_CHECK USING 'ZTITBLK' 'BIPKG' C_ERROR.
  ENDIF.
  IF ZTITBLK-BPKTY IS INITIAL.
    PERFORM NO_INPUT_CHECK USING 'ZTITBLK' 'BPKTY' C_ERROR.
  ENDIF.
*--> End of Modification.

  IF ZTITBLK-FLAND IS INITIAL.
    PERFORM NO_INPUT_CHECK USING 'ZTITBLK' 'FLAND' C_ERROR.
  ENDIF.
  IF ZTITBLK-FPORT IS INITIAL.
    PERFORM NO_INPUT_CHECK USING 'ZTITBLK' 'FPORT' C_ERROR.
  ENDIF.
  IF ZTITBLK-PLLOD IS INITIAL.
    SELECT SINGLE PORTE
      INTO ZTITBLK-PLLOD
      FROM ZTSTIGP
     WHERE LAND1 EQ ZTITBLK-FLAND
       AND PORTC EQ ZTITBLK-FPORT.
  ENDIF.

  IF ZTITBLK-TLAND IS INITIAL.
    ZTITBLK-TLAND = 'KR'.
*    PERFORM no_input_check USING 'ZTITBLK' 'TLAND' c_error.
  ENDIF.
  IF ZTITBLK-TPORT IS INITIAL.
    ZTITBLK-TPORT = 'PUS'.
*    PERFORM no_input_check USING 'ZTITBLK' 'TPORT' c_error.
  ENDIF.
  IF ZTITBLK-PLTRN IS INITIAL.
    SELECT SINGLE PORTE
      INTO ZTITBLK-PLTRN
      FROM ZTSTIGP
     WHERE LAND1 EQ ZTITBLK-TLAND
       AND PORTC EQ ZTITBLK-TPORT.
  ENDIF.

*> 실입항 입력일 경우.
  CASE G_MODE.
    WHEN C_CHARA.
      IF ZTITBLK-SDRLT IS INITIAL.
        PERFORM NO_INPUT_CHECK USING 'ZTITBLK' 'SDRLT' C_ERROR.
      ENDIF.
      IF ZTITBLK-SDRDT IS INITIAL.
        PERFORM NO_INPUT_CHECK USING 'ZTITBLK' 'SDRDT' C_ERROR.
      ENDIF.
    WHEN C_CHARY.
      IF ZTITBLK-RPTTY IS INITIAL.
        PERFORM NO_INPUT_CHECK USING 'ZTITBLK' 'RPTTY' C_ERROR.
      ENDIF.
*--> LG전선에서 막음. by MSH,20041121
*      IF ztitblk-fwdcd IS INITIAL.
*        PERFORM no_input_check USING 'ZTITBLK' 'FWDCD' c_error.
*      ENDIF.
*--> End of Modification.
      IF ZTITBLK-CSATY IS INITIAL.
        PERFORM NO_INPUT_CHECK USING 'ZTITBLK' 'CSATY' C_ERROR.
      ENDIF.
      IF ZTITBLK-BLAYN IS INITIAL.
        PERFORM NO_INPUT_CHECK USING 'ZTITBLK' 'BLAYN' C_ERROR.
      ENDIF.

*--> LG전선에서 막음. by MSH,20041121
*      IF ztitblk-ojrdt IS INITIAL.
*        PERFORM no_input_check USING 'ZTITBLK' 'OJRDT' c_error.
*      ENDIF.

*      IF ztitblk-inbdt IS INITIAL.
*        PERFORM no_input_check USING 'ZTITBLK' 'INBDT' c_error.
*      ENDIF.
*--> End of Modification.
*----------------------------------------------------------------------*
*                M O D I F I C A T I O N   L O G                       *
*----------------------------------------------------------------------*
* 2004.10.22   Sung-ho Maeng       LG전선은 볼륨, 순중량 필수제외.     *
*----------------------------------------------------------------------*
*      IF ztitblk-volum IS INITIAL.
*        PERFORM no_input_check USING 'ZTITBLK' 'VOLUM' c_error.
*      ENDIF.
*      IF ztitblk-brgew IS INITIAL.
*        PERFORM no_input_check USING 'ZTITBLK' 'BRGEW' c_error.
*      ENDIF.
*      IF ztitblk-ntgew IS INITIAL.
*        PERFORM no_input_check USING 'ZTITBLK' 'NTGEW' c_error.
*      ENDIF.
*----------------------------< INSERT END >----------------------------*

*> 통관요청일 경우.
    WHEN C_CHARO.   ">통관요청.
      IF ZTITBLK-CCRDA IS INITIAL.
        PERFORM NO_INPUT_CHECK USING 'ZTITBLK' 'CCRDA' C_ERROR.
      ENDIF.
  ENDCASE.

*> 무환일 경우 이전 B/L NUMBER CHECK.
  IF OK_CODE NE 'ZTEITEMCHANGE'.
    IF ZTITBLK-BLDTY EQ 'S'.
      READ TABLE IT_TAB INTO G_TC_2130_WA INDEX 1.
      IF SY-SUBRC EQ 0.
        IF ( G_TC_2130_WA-NDFTY EQ 'B' OR
             G_TC_2130_WA-NDFTY EQ 'C' OR
             G_TC_2130_WA-NDFTY EQ 'R' ) AND
             G_TC_2130_WA-EBELN IS INITIAL.
          IF ZTITBLK-BBLNO IS INITIAL.
            PERFORM NO_INPUT_CHECK USING 'ZTITBLK' 'BBLNO' C_WARNING.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDIF.

* 2005.06.03 추가 by JH,Lee
* -->
  IF ZTITBLK-BLDTY EQ 'S'.
*> 프로젝트 정의에서 WBS 요소로 변경.
*    CLEAR: proj.
*    IF NOT ztitblk-pspnr IS INITIAL.
*      SELECT SINGLE *
*        FROM proj
*       WHERE pspnr EQ ztitblk-pspnr.
*
*      IF sy-subrc EQ 0.
*        ztitblk-ps_posid = proj-pspid.
**        IF proj-kostl NE proj-kostl.
*        if not proj-kostl is initial.
*          ztitblk-kostl    = proj-kostl.
*        endif.
**        ENDIF.
*      ENDIF.
    CLEAR: PRPS.
*    CLEAR ztitblk-ps_posid .

    IF NOT ZTITBLK-PSPNR IS INITIAL.
      SELECT SINGLE *
        FROM PRPS
       WHERE PSPNR EQ ZTITBLK-PSPNR.
      IF SY-SUBRC EQ 0.
*        ztitblk-ps_posid = prps-posid.
        IF NOT PROJ-KOSTL IS INITIAL.
          ZTITBLK-KOSTL    = PROJ-KOSTL.
        ENDIF.
      ELSE.
*        CLEAR ztitblk-ps_posid.
      ENDIF.
    ELSE.
*      CLEAR ztitblk-ps_posid.
      IF ZTITBLK-KOSTL IS INITIAL.
*      PERFORM no_input_check USING 'ZTITBLK' 'PS_POSID' c_warning.
        PERFORM NO_INPUT_CHECK USING 'ZTITBLK' 'KOSTL' C_ERROR.
      ENDIF.
    ENDIF.
*    IF ztitblk-kostl IS INITIAL.
*    ENDIF.
  ELSE.
    CLEAR: ZTITBLK-KOSTL, ZTITBLK-PSPNR. ", ztitblk-ps_posid.
  ENDIF.
* <--

*>화면상의 Text를 Master Data 등에서 Read.
  PERFORM  GET_OTHERS_TEXT_BY_MASTER_DATA.


**********************************************************************
*-> 기능개선 99963 - 수입 운임 마스터(ZMMT0207)로 운임을 자동계산 함
**********************************************************************
  PERFORM GET_ZMMT0207_DATA.
**********************************************************************

ENDMODULE.                 " check_input_fields_scr2121  INPUT
*&---------------------------------------------------------------------*
*&      Module  user_command_2123  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_2123 INPUT.
*> F2 Funtion key Event시 해당 필드의 정보 display
  PERFORM  DOUBLE_CLICK_EVENT.

ENDMODULE.                 " user_command_2123  INPUT
*&---------------------------------------------------------------------*
*&      Module  pai_organization_data_scr2123  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE PAI_ORGANIZATION_DATA_SCR2123 INPUT.

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
    ELSE.
      PERFORM NO_INPUT_CHECK USING 'ZTITBLK' 'BUKRS' C_ERROR.
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
ENDMODULE.                 " pai_organization_data_scr2123  INPUT
*&---------------------------------------------------------------------*
*&      Module  pai_read_it_tab  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE PAI_READ_IT_TAB INPUT.

  DESCRIBE TABLE IT_TAB LINES G_COUNT.
  G_INDEX = G_OLD_TOP_LINE + SY-STEPL - 1.
  CHECK G_INDEX LE TC_2130-LINES.
  CHECK G_INDEX LE G_COUNT.

  READ TABLE IT_TAB INTO G_TC_2130_OLD INDEX G_INDEX.

ENDMODULE.                 " pai_read_it_tab  INPUT
*&---------------------------------------------------------------------*
*&      Module  pai_blmng_scr2130  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE PAI_BLMNG_SCR2130 INPUT.

  G_MENGE_REQUEST = C_TRUE.

ENDMODULE.                 " pai_blmng_scr2130  INPUT
*&---------------------------------------------------------------------*
*&      Module  pai_refwr_scr2130  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE PAI_REFWR_SCR2130 INPUT.

  G_WRBTR_REQUEST = C_TRUE.

ENDMODULE.                 " pai_refwr_scr2130  INPUT
*&---------------------------------------------------------------------*
*&      Module  SET_CHANGE_CURRENCY_KEY  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE SET_CHANGE_CURRENCY_KEY INPUT.

*> 통화단위.
  IF ZTITBLK-WAERS IS INITIAL.
    PERFORM NO_INPUT_CHECK USING 'ZTITBLK' 'WAERS' C_ERROR.
  ENDIF.

  REFRESH CONTROL 'TC_2130' FROM SCREEN '2130'.

  LOOP AT IT_TAB INTO G_TC_2130_WA.
    G_TC_2130_WA-WAERS = ZTITBLK-WAERS.

    MODIFY IT_TAB FROM G_TC_2130_WA.
  ENDLOOP.


ENDMODULE.                 " SET_CHANGE_CURRENCY_KEY  INPUT
*&---------------------------------------------------------------------*
*&      Module  check_total_amount  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE CHECK_TOTAL_AMOUNT INPUT.

  G_AMOUNT_CHK1 = C_TRUE.

ENDMODULE.                 " check_total_amount  INPUT
*&---------------------------------------------------------------------*
*&      Module  check_prepaid_amount  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE CHECK_PREPAID_AMOUNT INPUT.

  G_AMOUNT_CHK2 = C_TRUE.

ENDMODULE.                 " check_prepaid_amount  INPUT
*&---------------------------------------------------------------------*
*&      Module  check_retention_amount  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE CHECK_RETENTION_AMOUNT INPUT.

  G_AMOUNT_CHK3 = C_TRUE.

ENDMODULE.                 " check_retention_amount  INPUT
*&---------------------------------------------------------------------*
*&      Module  prepaid_amount_changed  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE PREPAID_AMOUNT_CHANGED INPUT.

  CHECK G_AMOUNT_CHK2 EQ C_TRUE.

  CHECK ZTITBLK-PPAMT NE G_ZTITBLK_PBO-PPAMT.

*> Invoice Amount Check.
  PERFORM CHECK_INVOICE_AMOUNT.

*> 유보금 아이템별 배부.
  PERFORM  PREPAID_AMOUNT_CHANGE_EVENT.

  G_ZTITBLK_PBO-PPAMT = ZTITBLK-PPAMT.
  G_AMOUNT_CHK2 = C_FALSE.

ENDMODULE.                 " prepaid_amount_chainged  INPUT
*&---------------------------------------------------------------------*
*&      Module  total_amount_changed  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE TOTAL_AMOUNT_CHANGED INPUT.

  CHECK G_AMOUNT_CHK1 EQ C_TRUE.
  CHECK ZTITBLK-SMAMT NE G_ZTITBLK_PBO-SMAMT.

*> Invoice Amount Check.
  PERFORM CHECK_INVOICE_AMOUNT.

  IF ZTITBLK-BLDTY EQ 'S'.
    G_ZTITBLK_PBO-SMAMT = ZTITBLK-SMAMT.
    G_AMOUNT_CHK1 = C_FALSE.
    EXIT.
  ENDIF.

*> 금액 배부 확인 창.
  CALL FUNCTION 'Z_TI_DISTRIBUTING_CONFIRMATION'
    EXPORTING
      IM_DEFAULT = '1'
    IMPORTING
      EX_ANSWER  = G_ANSWER.

  IF G_ANSWER EQ 'N'.
    ZTITBLK-SMAMT = G_ZTITBLK_PBO-SMAMT.
    G_AMOUNT_CHK1 = C_FALSE.
    MESSAGE I234.  EXIT.
  ENDIF.

  IF G_ANSWER EQ C_CHAR2.
    READ TABLE IT_TAB INTO G_TC_2130_WA WITH KEY EREKZ = C_TRUE.
    IF SY-SUBRC EQ 0.
      MESSAGE E239.
    ENDIF.
  ENDIF.
*> 수량 및 금액 배부.
  PERFORM SET_ITEM_AMOUNT_CALC  USING G_ANSWER.

  G_ZTITBLK_PBO-SMAMT = ZTITBLK-SMAMT.
  G_AMOUNT_CHK1 = C_FALSE.

ENDMODULE.                 " total_amount_chainged  INPUT
*&---------------------------------------------------------------------*
*&      Module  prepaid_retention_changed  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE PREPAID_RETENTION_CHANGED INPUT.

  CHECK G_AMOUNT_CHK3 EQ C_TRUE.
  CHECK ZTITBLK-RTCHG NE G_ZTITBLK_PBO-RTCHG.

*> Invoice Amount Check.
  PERFORM CHECK_INVOICE_AMOUNT.

  G_ZTITBLK_PBO-RTCHG = ZTITBLK-RTCHG.
  G_AMOUNT_CHK3 = C_FALSE.

ENDMODULE.                 " prepaid_retention_chainged  INPUT
*&---------------------------------------------------------------------*
*&      Module  get_document_amount  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE GET_DOCUMENT_AMOUNT INPUT.

  CHECK: G_AMOUNT_CHK1 EQ C_TRUE OR
         G_AMOUNT_CHK2 EQ C_TRUE OR
         G_AMOUNT_CHK3 EQ C_TRUE.

*> P/O 총금액 계산.
  PERFORM GET_TOTAL_PO_AMOUNT         TABLES GT_EKPO
                                      USING  ZTISSCRCOM-POAMT.
*> 문서금액 계산.
  PERFORM GET_TOTAL_DOCUMENT_AMOUNT   USING  ZTISSCRCOM-DCAMT.

ENDMODULE.                 " get_document_amount  INPUT
*&---------------------------------------------------------------------*
*&      Module  check_input_value_scr2111  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE CHECK_INPUT_VALUE_SCR2111 INPUT.

  CHECK : G_MODE EQ C_CHARC OR
          G_MODE EQ C_CHARM.

*  IF ztitblk-blcnt IS INITIAL.
*    PERFORM no_input_check USING 'ZTITBLK' 'BLCNT' c_error.
*  ENDIF.


************************************************************************
* 날짜   : 2018.11.05
* 요청인 : 김봉중
* 수정자 : 강희대
* 내용   : 회사코드 3000에 대한 bl리스트 가져오기. ( LS 엠트론에만 적용)
************************************************************************


  IF ZTITBLK-BUKRS = '3000'.
    PERFORM SELECT_BLLIST.
  ENDIF.


  IF ZTITBLK-BLDAT IS INITIAL.
    PERFORM NO_INPUT_CHECK USING 'ZTITBLK' 'BLDAT' C_ERROR.
  ENDIF.



************************************************************************
* 날짜   : 2008.10.08
* 요청인 : 박혁세
* 내용   : B/L생성시 B/L발행일을 ETD 날짜로 input
************************************************************************
  IF  ZTITBLK-BLDAT IS NOT INITIAL
  AND ZTITBLK-BLETD IS INITIAL.
    ZTITBLK-BLETD = ZTITBLK-BLDAT.
  ENDIF.






ENDMODULE.                 " check_input_value_scr2111  INPUT
*&---------------------------------------------------------------------*
*&      Module  user_command_scr7020  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_SCR7020 INPUT.

  CASE OK-CODE.
    WHEN 'TC_7020_EX'.
      G_ANSWER = 'N'.
      LEAVE TO SCREEN 0.
    WHEN 'TC_7020_OK'.
      CASE 'X'.
        WHEN G_RADIO1.              G_ANSWER = '1'.
        WHEN G_RADIO2.              G_ANSWER = '2'.
        WHEN G_RADIO3.              G_ANSWER = '3'.
        WHEN G_RADIO4.              G_ANSWER = '4'.
        WHEN G_RADIO5.              G_ANSWER = '5'.
        WHEN G_RADIO6.              G_ANSWER = '6'.
        WHEN G_RADIO7.              G_ANSWER = '7'.
        WHEN G_RADIO8.              G_ANSWER = '8'.
        WHEN G_RADIO9.              G_ANSWER = '9'.
      ENDCASE.
      LEAVE TO SCREEN 0.
  ENDCASE.

  CLEAR: OK_CODE.

ENDMODULE.                 " user_command_scr7020  INPUT
*&---------------------------------------------------------------------*
*&      Module  check_input_value_scr7020  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE CHECK_INPUT_VALUE_SCR7020 INPUT.

  CHECK OK-CODE NE 'TC_7020_EX'.

  CASE C_TRUE.
    WHEN G_RADIO1 OR G_RADIO2.    ">무환(보상/수리)
      IF ZTISSCRCOM-EBELN IS INITIAL.
        PERFORM NO_INPUT_CHECK USING 'ZTISSCRCOM' 'EBELN' C_ERROR.
      ENDIF.
    WHEN G_RADIO3 OR G_RADIO4.    ">무환(대체/샘플)
      IF ZTISSCRCOM-EBELN IS INITIAL.
        PERFORM NO_INPUT_CHECK USING 'ZTISSCRCOM' 'EBELN' C_WARNING.
      ENDIF.
    WHEN G_RADIO5.
    WHEN G_RADIO6.
    WHEN G_RADIO7.
    WHEN G_RADIO8.
    WHEN G_RADIO9.               ">무환(shipback)
      IF ZTISSCRCOM-VBELN IS INITIAL.
        PERFORM NO_INPUT_CHECK USING 'ZTISSCRCOM' 'VBELN' C_ERROR.
      ENDIF.
  ENDCASE.

  CASE C_TRUE.
*> 구매오더번호가 존재하는 경우.
    WHEN G_RADIO1 OR G_RADIO2 OR
         G_RADIO3 OR G_RADIO4.
      IF NOT ZTISSCRCOM-EBELN IS INITIAL.
        PERFORM CHECK_PO_DOCUMENT_BY_EBELN  USING ZTISSCRCOM-EBELN.
      ENDIF.
    WHEN G_RADIO9.
*> 영업문서번호가 존재하는 경우.
      IF NOT ZTISSCRCOM-VBELN IS INITIAL.
        PERFORM CHECK_SO_DOCUMENT_BY_VBELN  USING ZTISSCRCOM-VBELN.
      ENDIF.

  ENDCASE.

ENDMODULE.                 " check_input_value_scr7020  INPUT
*&---------------------------------------------------------------------*
*&      Form  SELECT_BLDAT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM SELECT_BLLIST .


  IF NOT ZTITBLK-BLNUM IS INITIAL.

    SELECT  SINGLE *
      INTO ZTIBLIF
      FROM ZTIBLIF
      WHERE BLNUM = ZTITBLK-BLNUM.

    IF SY-SUBRC = 0.
      ZTITBLK-BLDAT = ZTIBLIF-BLDAT.    "  발행일
      ZTITBLK-BLETA = ZTIBLIF-BLETA.    "  도착예정일
      ZTITBLK-PLLOD = ZTIBLIF-PLLOD.    "  선적항
      ZTITBLK-PLTRN = ZTIBLIF-PLTRN.    "  도착항
      ZTITBLK-VOLUM = ZTIBLIF-VOLUM.    "  볼륨
      ZTITBLK-BRGEW = ZTIBLIF-BRGEW.    "  총중량
      ZTITBLK-BIPKG = ZTIBLIF-BIPKG.    "  총포장갯수
      ZTITBLK-FWDCD = ZTIBLIF-FWDCD.    "  포워더
      ZTITBLK-IVSLN = ZTIBLIF-IVSLN.    "  선기명
      ZTITBLK-FWDTY = ZTIBLIF-FWDTY.    "  운송방법
      ZTITBLK-FWDFM = ZTIBLIF-FWDFM.    "  운송형태
      ZTITBLK-CTNQ2 = ZTIBLIF-CTNQ2.    "  20FT 수량
      ZTITBLK-CTNQ4 = ZTIBLIF-CTNQ4.    "  40FT 수량

    ENDIF.

  ENDIF.


ENDFORM.                    " SELECT_BLDAT
*&---------------------------------------------------------------------*
*&      Module  CLEAR_FREIGHT_CHARGE  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE CLEAR_FREIGHT_CHARGE INPUT.

  IF ZTITBLK-FWDTY <> 'A' OR       "항공
     ZTITBLK-FWDFM <> 'L' OR       "LCL
     ZTITBLK-CTNTY <> 'Z'.         "기타 (DHL 같은 특송에 사용)
    CLEAR : ZTITBLK-CFRAT.
  ENDIF.

ENDMODULE.                 " CLEAR_FREIGHT_CHARGE  INPUT
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_7040  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_7040 INPUT.
  CLEAR : OK_CODE.
  OK_CODE = SY-UCOMM.

  CASE OK_CODE.
    WHEN 'OKAY'.
      IF GV_ZCOTY IS INITIAL.
        MESSAGE S000(ZMM1) WITH '제출여부를 선택하세요.'.
      ELSE.
        LEAVE TO SCREEN 0.
      ENDIF.
  ENDCASE.
ENDMODULE.                 " USER_COMMAND_7040  INPUT
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_EXIT_7040  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_EXIT_7040 INPUT.
  CLEAR GV_ZCOTY.
  LEAVE TO SCREEN 0.
ENDMODULE.                 " USER_COMMAND_EXIT_7040  INPUT
