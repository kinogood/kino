************************************************************************
* Title         :  ZTIR7000I01                                         *
*                                                                      *
* Description   : 수입 계산서 관리 PAI Include                         *
*                                                                      *
* Creation Date : 2004/02/12                                           *
*                                                                      *
* Author        : SeogBong, Kang                                       *
*                 Copyright ⓒ ASEG Co., LTD. All rights reserved.     *
************************************************************************
*----------------------------------------------------------------------*
*                M O D I F I C A T I O N   L O G                       *
*----------------------------------------------------------------------*
* Date         Programmer       Transport#  Description                *
*----------------------------------------------------------------------*
* 2014-03-27   ZLSGMM(hjkim)    R3TK9A0F7X  CSR 2014031800051 기능개선 *
*                                                                      *
*                                                                      *
*----------------------------------------------------------------------*


*&---------------------------------------------------------------------*
*&      Module  tc_2130_modify  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE TC_2130_MODIFY INPUT.

*  MOVE-CORRESPONDING : g_tc_2130_old TO g_tc_2130_wa.
  MOVE-CORRESPONDING : ZTISVAIT TO G_TC_2130_WA.


  IF G_MENGE_REQUEST EQ C_TRUE.
    MOVE ZTISVAIT-IVMNG TO G_TC_2130_WA-IVMNG.

    IF ZTISVAIT-IVMNG IS INITIAL.
      PERFORM  NO_INPUT_CHECK USING 'ZTISVAIT' 'IVMNG' C_ERROR.
    ENDIF.

*> 송장처리 가능수량을 초과했을 경우.
    IF ZTISVAIT-IVMNG GT ZTISVAIT-IVMNGI.
      CLEAR: G_MENGET.
      WRITE ZTISVAIT-IVMNGI TO G_MENGET(15) UNIT ZTISVAIT-MEINS.
      CONCATENATE G_MENGET ZTISVAIT-MEINS INTO G_MENGET.
      MESSAGE E301 WITH G_MENGET.
    ENDIF.

*> 정가 계산.
    CALL FUNCTION 'Z_TI_CALC_ITEM_AMOUNT'
      EXPORTING
        PEINH = ZTISVAIT-PEINH
        BPUMZ = ZTISVAIT-BPUMZ
        BPUMN = ZTISVAIT-BPUMN
        MENGE = ZTISVAIT-IVMNG
        NETPR = ZTISVAIT-NETPR
      CHANGING
        NETWR = ZTISVAIT-NETWR.

    G_TC_2130_WA-NETWR = ZTISVAIT-NETWR.
    G_TC_2130_WA-REFWR = ZTISVAIT-NETWR.
*    ZTISVAIT-refwr     = ZTISVAIT-netwr.
  ENDIF.

  IF G_WRBTR_REQUEST EQ C_TRUE.
    MOVE ZTISVAIT-REFWR TO G_TC_2130_WA-REFWR.

    IF G_TC_2130_WA-REFWR IS INITIAL.
      G_TC_2130_WA-REFWR = G_TC_2130_OLD-REFWR.
    ENDIF.

    IF G_TC_2130_WA-REFWR NE G_TC_2130_OLD-REFWR.
      MESSAGE W025 WITH G_INDEX.
    ENDIF.
  ENDIF.

  IF ZTISVAIT-MWSKZ IS INITIAL.
    ZTISVAIT-MWSKZ = ZTITVAK-MWSKZ.
  ENDIF.

*> 금액 계산오류 Message
  IF OK_CODE EQ 'ZTIPOST' OR
     OK_CODE EQ 'ZTISIMUL'.
    IF G_TC_2130_WA-REFWR NE G_TC_2130_WA-NETWR.
      MESSAGE W212.
    ENDIF.
  ENDIF.

  MOVE: ZTISVAIT-MWSKZ TO G_TC_2130_WA-MWSKZ,
        ZTISVAIT-SGTXT TO G_TC_2130_WA-SGTXT.

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
                                USING  ZTITVAK.
*> 아이템 정보 display
  PERFORM  DISPLAY_INFOMATION_BY_ITEMS USING   'TC_2130'
                                               'IT_TAB'
                                               'FLAG'
                                               ZTITVAK-LIFNR
                                       CHANGING OK_CODE.
*> F2 Funtion key Event시 해당 필드의 정보 display
  PERFORM  DOUBLE_CLICK_EVENT.

ENDMODULE.                 " tc_2130_user_command  INPUT
*&---------------------------------------------------------------------*
*&      Module  pai_scr0100_check_input_fields  INPUT
*&---------------------------------------------------------------------*
MODULE PAI_SCR0100_CHECK_INPUT_FIELDS INPUT.

*> EXIT확인.
  PERFORM  CHECK_PROGRAM_EXIT_COMMAND.

  OK_CODE_OLD = OK_CODE.
  CLEAR: OK_CODE_POPUP.

*> Input fields check
  IF NOT OK_CODE EQ 'ZTICOPY'.
    IF ZTISSCRCOM-EBELN IS INITIAL AND
       ZTISSCRCOM-REQNO IS INITIAL AND
       ZTISSCRCOM-OPNNO IS INITIAL.
      MESSAGE E913.
    ENDIF.
  ELSE.

  ENDIF.

*> 구매오더 Select.
  IF NOT OK_CODE EQ 'ZTICOPY'.

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
      PERFORM GET_VATBIL_DOCUMENT_DATA TABLES IT_ZTISRQIT
                                       USING  ZTISSCRCOM-REQNO
                                              ZTISSCRCOM-AMDSQ
                                              C_ERROR
                                              C_ERROR.
      CLEAR: G_RBLGP.

      MOVE-CORRESPONDING : ZTITRQK TO ZTITVAK,
                           ZTITRQS TO ZTITVAK.

      SELECT SINGLE *
        FROM ZTITLO1
       WHERE REQNO  EQ  ZTITRQS-REQNO
         AND AMDSQ  EQ  ZTITRQS-AMDSQ.

      CLEAR: G_KURSF.

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
*> 구매오더 이력.
        CLEAR: BKPF-KURSF.
        IF ZTITRQK-REQTY EQ C_LO.
          CASE ZTITLO1-LLCTY.
            WHEN '2AA'.  ">원화표시 내국신용장.
              BKPF-WAERS = T001-WAERS.
            WHEN '2AB'.  ">외화표시 내국신용장.
              BKPF-WAERS = ZTITRQS-WAERS.
            WHEN '2AC'.  ">순수원화표시 내국신용장.
              BKPF-WAERS = ZTITRQS-WAERS.
            WHEN OTHERS.
              BKPF-WAERS = ZTITRQS-WAERS.
          ENDCASE.
        ELSE.
          BKPF-WAERS = ZTITRQS-WAERS.
        ENDIF.

        PERFORM GET_GR_HISTORY_TABLE TABLES IT_EK08RN
                                     USING  IT_ZTISRQIT-EBELN
                                            IT_ZTISRQIT-EBELP
                                            IT_ZTISRQIT-WEBRE
                                            BKPF-KURSF
                                            BKPF-WAERS
                                            EKKO
                                            ZTITLO1-LLCTY.
        LOOP AT IT_EK08RN.
          CLEAR: G_TC_2130_WA.
          ADD 1 TO G_RBLGP.
          MOVE-CORRESPONDING : IT_ZTISRQIT TO G_TC_2130_WA,
                               IT_EK08RN   TO G_TC_2130_WA.

          MOVE: EKPO-MENGE                 TO G_TC_2130_WA-MENGE.

*> G/R Base I/V일 경우. ( 입고수량 -  송장수량 )
          IF IT_EK08RN-WEBRE EQ 'X'.
            G_TC_2130_WA-IVMNGI  = IT_EK08RN-WEMNG - IT_EK08RN-REMNG.
            G_TC_2130_WA-IVMNGS  = IT_EK08RN-REMNG.
          ELSE.
*> G/R Base I/V가 아닐 경우. ( 오더수량 -  송장수량 )
            G_TC_2130_WA-IVMNGI  = IT_EK08RN-BSMNG - IT_EK08RN-REMNG.
            G_TC_2130_WA-IVMNGS  = IT_EK08RN-REMNG.
          ENDIF.

          G_TC_2130_WA-IVMNG = G_TC_2130_WA-IVMNGI.
          G_TC_2130_WA-LFGJA = IT_EK08RN-LFGJA.
          G_TC_2130_WA-LFBNR = IT_EK08RN-LFBNR.
          G_TC_2130_WA-LFPOS = IT_EK08RN-LFPOS.
          G_TC_2130_WA-MWSKZ = IT_EK08RN-MWSKZ.

          IF G_TC_2130_WA-BUDAT IS INITIAL.
            G_TC_2130_WA-BUDAT = SY-DATLO.
          ENDIF.

*> G/R Base I/V일 경우. ( 입고금액 -  송장금액 )
          IF IT_EK08RN-WEBRE EQ 'X'.
            G_TC_2130_WA-REFWR  = IT_EK08RN-WEWWR - IT_EK08RN-REFWR.
          ELSE.
*> G/R Base I/V가 아닐 경우. ( 정가수량 -  송장수량 )
            G_TC_2130_WA-REFWR = IT_EK08RN-NETWR - IT_EK08RN-REFWR.
          ENDIF.

*> 금액이 음수일 경우....
          IF G_TC_2130_WA-REFWR LE 0.
            CALL FUNCTION 'Z_TI_CALC_ITEM_AMOUNT'
              EXPORTING
                PEINH = G_TC_2130_WA-PEINH
                BPUMZ = G_TC_2130_WA-BPUMZ
                BPUMN = G_TC_2130_WA-BPUMN
                MENGE = G_TC_2130_WA-IVMNG
                NETPR = G_TC_2130_WA-NETPR
              CHANGING
                NETWR = G_NETWR.
            G_TC_2130_WA-REFWR = G_NETWR.
          ENDIF.

*----> 외화표시일 경우 환율 더하기....(가중평균환율을 구하기 위함)
          IF ZTITLO1-LLCTY EQ '2AB'.
            PERFORM GET_FI_DOCUMENT_HEADER USING IT_EK08RN-LFGJA
                                                 IT_EK08RN-LFBNR
                                                 IT_EK08RN-BUKRS
                                                 'MKPF'
                                                 BKPF.
            ADD BKPF-KURSF TO G_KURSF.
          ENDIF.

          APPEND G_TC_2130_WA TO IT_TAB.

        ENDLOOP.

      ENDLOOP.
    ENDIF.
    DESCRIBE TABLE IT_TAB LINES G_LINE.

    IF G_LINE EQ 0.
      MESSAGE E103.
    ENDIF.

*----> 외화표시일 경우 가중평균환율을 구함.
    IF ZTITLO1-LLCTY EQ '2AB'.
      ZTITVAK-KURSF = G_KURSF / G_LINE.
    ENDIF.

  ENDIF.

** JS전선 회사코드 2007/04 KSH --------------------------------------
*> AUTHORIZATION_CHECK
  PERFORM P1102_AUTHORIZATION_CHECK USING ZTITVAK-BUKRS.
** JS전선 회사코드 2007/04 KSH --------------------------------------

*>아이템 기타 정보 Read.
  PERFORM SET_OTHERS_FIELDS_BY_ITEMS.
*>화면상의 Text를 Master Data 등에서 Read.
  PERFORM GET_OTHERS_TEXT_BY_MASTER_DATA.
*>Set Defalut values
  PERFORM SET_INVOICE_DEFAULT_VALUES.
*>송장금액 체크.
  PERFORM CHECK_OPEN_AMOUNT.

ENDMODULE.                 " pai_scr0100_check_input_fields  INPUT
*&---------------------------------------------------------------------*
*&      Module  user_command_scr0100  INPUT
*&---------------------------------------------------------------------*
MODULE USER_COMMAND_SCR0100 INPUT.

  IF OK_CODE_OLD = 'ZTICOPY'.
    IF OK_CODE_POPUP NE 'FCOPY'.
      EXIT.
    ENDIF.
  ENDIF.


*> EXIT확인.
  PERFORM  CHECK_PROGRAM_EXIT_COMMAND.

*> Text Object 관련 Internal Table Initial.
  PERFORM  GET_LONGTEXT_DATA.

*> Create Class Object.
  PERFORM  BUILD_CLASS_OBJECT.

*> Generic Object Service.
  PERFORM  SET_GENERIC_OBJECT_SERVICE USING   'ZTIWF_SDOC'
                                               ZTITVAK+3(10).

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

*> Input fields check
  IF ZTISSCRCOM-VATNO IS INITIAL.
    MESSAGE E913.
  ENDIF.

*> I/V Select.
  PERFORM P3000_SET_DATA_OF_SCREEN.

  CLEAR: G_COUNT.
*> B/L Number로 Invoice 관리번호 찾을 경우.
  IF ZTISSCRCOM-VATNO IS INITIAL AND
     NOT ZTISSCRCOM-BLNUM IS INITIAL.
    PERFORM  GET_INVOICE_BY_BL_NUMBER     USING ZTISSCRCOM-VATNO
                                                ZTISSCRCOM-BLNUM
                                                C_FALSE.
  ENDIF.

  IF NOT ZTISSCRCOM-VATNO IS INITIAL.
*>Get 송장 문서.
    CALL FUNCTION 'Z_TI_GET_VATBIL_DOCUMENT'
      EXPORTING
        I_VATNO   = ZTISSCRCOM-VATNO
      IMPORTING
        ZTITVAK   = ZTITVAK
      TABLES
        ZTITVAP   = IT_TAB
        ZTITVAH   = IT_ZTITVAH
*        ztitivv   = it_ztitivv
      EXCEPTIONS
        NOT_FOUND = 1
        OTHERS    = 2.
    IF SY-SUBRC <> 0.
      MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
              WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    ENDIF.

*      perform read_iv_item_data changing it_tab.


*    SELECT * FROM ztivbl00
*      INTO CORRESPONDING FIELDS OF TABLE it_bl
*      FOR ALL ENTRIES IN it_tab
*     WHERE iblno EQ it_tab-iblno
*       AND iblit EQ it_tab-iblit.
*
*    PERFORM get_available_bl_item TABLES it_bl
*                                         it_blnum
*                                  USING  c_success
*                                         c_false.

** JS전선 회사코드 2007/04 KSH --------------------------------------
*> authorization
    PERFORM GET_AUTHORIZATION_BUKRS.
    IF L_YN NE 'A'.
      IF ZTITVAK-BUKRS <> A_BUKRS.
        MESSAGE E998 WITH ZTITVAK-BUKRS  '권한이 없습니다!'..
      ENDIF.
    ENDIF.
** JS전선 회사코드 2007/04 KSH --------------------------------------

*> 변경 문서 관리를 위한 이전데이타를 Move.
     *ZTITVAK   = ZTITVAK.

    YZTITVAP[] = XZTITVAP[].

*> 변경 문서 관리를 위한 이전데이타를 Move (Item Data).
    REFRESH: XZTITVAP, YZTITVAP.
    LOOP AT IT_TAB INTO G_TC_2130_WA.
      MOVE-CORRESPONDING G_TC_2130_WA TO : XZTITVAP,
                                           YZTITVAP.
      APPEND : XZTITVAP, YZTITVAP.
    ENDLOOP.

**> 변경 문서 관리를 위한 이전데이타를 Move (금액분할).
*    REFRESH: xztitivv, yztitivv.
*    LOOP AT it_ztitivv.
*      MOVE-CORRESPONDING it_ztitivv TO : xztitivv,
*                                         yztitivv.
*      APPEND : xztitivv, yztitivv.
*
*    ENDLOOP.

**> 송장--->B/L 번호..
*    IF ZTITVAK-prpyn EQ c_chari.
*      SELECT SINGLE *
*        FROM ztitblk
*       WHERE iblno EQ ztitblk-iblno.
*    ENDIF.

*>업무영역별 Status Check.
    PERFORM CHECK_DOCUMENT_STATUS.
*>아이템 기타 정보 Read.
    PERFORM SET_OTHERS_FIELDS_BY_ITEMS.
*>화면상의 Text를 Master Data 등에서 Read.
    PERFORM GET_OTHERS_TEXT_BY_MASTER_DATA.
*>조회모드가 아닌 경우 Lock.
    IF G_MODE NE C_CHARS.
      PERFORM SET_VA_LOCK_OBJECT   USING ZTITVAK-VATNO
                                         '00000'
                                         C_LOCK
                                         C_ERROR
                                         G_MODIFY.
    ENDIF.

*> Document History 조회.
    DESCRIBE TABLE IT_ZTITVAH LINES G_LINE.
    IF G_LINE GT 0.
      G_HISTORY_POST = C_TRUE.
    ELSE.
      CLEAR G_HISTORY_POST.
    ENDIF.

*> Document History 조회.
    PERFORM GET_DOCUMENT_HISTORY   TABLES IT_DOCHIS
                                   USING  G_DOCUMENT
                                          ZTITVAK-VATNO
                                          '00'
                                          G_HISTORY.
    ZTISSCRCOM-REQTY = C_VA.
  ELSE.
    MESSAGE E902.
  ENDIF.

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
*&      Module  GET_SURSOR_POSITION  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE GET_SURSOR_POSITION INPUT.
*> F2 Funtion key Event시 해당 필드의 정보 display
  PERFORM  DOUBLE_CLICK_EVENT.
ENDMODULE.                 " GET_SURSOR_POSITION  INPUT

*&---------------------------------------------------------------------*
*&      Module  user_command_2120  INPUT
*&---------------------------------------------------------------------*
MODULE USER_COMMAND_2120 INPUT.

ENDMODULE.                 " user_command_2210  INPUT

*&---------------------------------------------------------------------*
*&      Module  tc_2123_modify  INPUT
*&---------------------------------------------------------------------*
*> input module for tc 'TC_2123'. do not change this line!
*> modify table
*&---------------------------------------------------------------------*
MODULE TC_2123_MODIFY INPUT.

*  MOVE-CORRESPONDING ztisivvs TO g_tc_2123_wa.
*
*  MODIFY it_ztitivv
*    FROM g_tc_2123_wa
*    INDEX tc_2123-current_line.
*
*  IF sy-subrc NE 0.
*    APPEND g_tc_2123_wa TO it_ztitivv.
*  ENDIF.

ENDMODULE.                    "TC_2123_modify INPUT

*&---------------------------------------------------------------------*
*&      Module  tc_2123_mark  INPUT
*&---------------------------------------------------------------------*
*> input module for tc 'TC_2123'. do not change this line!
*> mark table
*&---------------------------------------------------------------------*
MODULE TC_2123_MARK INPUT.
*  IF tc_2123-line_sel_mode = 1 AND
*     ztisivvs-flag = 'X'.
*    LOOP AT it_ztitivv INTO g_tc_2123_wa
*      WHERE flag = 'X'.
*      g_tc_2123_wa-flag = ''.
*      MODIFY it_ztitivv
*        FROM g_tc_2123_wa
*        TRANSPORTING flag.
*    ENDLOOP.
*    g_tc_2123_wa-flag = 'X'.
*  ENDIF.
*  MODIFY it_ztitivv
*    FROM g_tc_2123_wa
*    INDEX tc_2123-current_line
*    TRANSPORTING flag.
ENDMODULE.                    "TC_2123_mark INPUT

*&---------------------------------------------------------------------*
*&      Module  tc_2123_user_command  INPUT
*&---------------------------------------------------------------------*
*> input module for tc 'TC_2123'. do not change this line!
*> process user command
*&---------------------------------------------------------------------*
MODULE TC_2123_USER_COMMAND INPUT.
  OK_CODE = SY-UCOMM.
  PERFORM USER_OK_TC USING    'TC_2123'
                              'IT_ZTITIVV'
                              'FLAG'
                     CHANGING OK_CODE.
  SY-UCOMM = OK_CODE.

*> F2 Funtion key Event시 해당 필드의 정보 display
  PERFORM  DOUBLE_CLICK_EVENT.

ENDMODULE.                    "TC_2123_user_command INPUT
*&---------------------------------------------------------------------*
*&      Module  pai_check_input_value_scr2121  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE PAI_CHECK_INPUT_VALUE_SCR2121 INPUT.

  IF OK_CODE_OLD = 'ZTICOPY'.
    IF OK_CODE_POPUP NE 'FCOPY'.
      EXIT.
    ENDIF.
  ENDIF.

**> Input fields check
*  IF NOT ok_code EQ 'ZTICOPY'.
*
  CHECK NOT ( G_MODE EQ 'S' OR
              G_MODE EQ 'D' OR
              G_MODE EQ 'R' ).
*> 전기일자.
  IF ZTITVAK-BLDAT IS INITIAL.
    PERFORM NO_INPUT_CHECK USING 'ZTITVAK' 'BLDAT' C_ERROR.
  ENDIF.
*> 전기일자.
*  IF ZTITVAK-bldat IS INITIAL.
*  ZTITVAK-bldat = ZTITVAK-civdt.
*    PERFORM no_input_check USING 'ZTITVAK' 'BLDAT' c_error.
*  ENDIF.
*> 증빙일자.
  IF ZTITVAK-BUDAT IS INITIAL.
*    ZTITVAK-budat = ZTITVAK-civdt.
    PERFORM NO_INPUT_CHECK USING 'ZTITVAK' 'BUDAT' C_ERROR.
  ENDIF.

*-----> LS전선 Migration관계로 Check logic 제외.by MSH,050501
*  IF ZTITVAK-opnbk IS INITIAL.
*    PERFORM no_input_check USING 'ZTITVAK' 'OPNBK' c_error.
*  ELSE.
  SELECT SINGLE *
    FROM ZTSTIG3
   WHERE PARTI EQ C_CHARB
     AND EPART EQ ZTITVAK-OPNBK
     AND BUKRS EQ ZTITVAK-BUKRS.
*    IF sy-subrc NE 0.
*      MESSAGE e918 WITH ZTITVAK-opnbk.
*    ENDIF.
  IF ZTITIG00-SJPAP EQ C_CHARV.
    ZTITVAK-APVEN = ZTITVAK-LIFNR.
  ELSEIF ZTITIG00-SJPAP EQ C_CHARB.
    ZTITVAK-APVEN = ZTSTIG3-LIFNR.
  ENDIF.
*  ENDIF.
**-----> End of Modification.
  IF ZTITVAK-OPNBK IS INITIAL.
*->CSR 2014031800051 엠트론_원화일 경우 개설은행 공란으로 함
    IF ZTITVAK-BUKRS = '3000' AND ZTITVAK-WAERS = 'KRW'.
      "체크 안함
    ELSE.
*<-CSR 2014031800051 엠트론_원화일 경우 개설은행 공란으로 함
      IF ZTITBLK-BLDTY NE 'A'.
        PERFORM NO_INPUT_CHECK USING 'ZTITVAK' 'OPNBK' C_ERROR.
      ENDIF.
      IF ZTITIG00-SJPAP EQ C_CHARV.
        ZTITVAK-APVEN = ZTITVAK-LIFNR.
      ELSEIF ZTITIG00-SJPAP EQ C_CHARB.
        ZTITVAK-APVEN = ZTSTIG3-LIFNR.
      ENDIF.
    ENDIF. "CSR 2014031800051

  ELSE.
    IF NOT ZTITVAK-OPNBK IS INITIAL.
      SELECT SINGLE *
        FROM ZTSTIG3
       WHERE PARTI EQ C_CHARB
         AND EPART EQ ZTITVAK-OPNBK
         AND BUKRS EQ ZTITVAK-BUKRS.
      IF SY-SUBRC NE 0.
        MESSAGE E918 WITH ZTITVAK-OPNBK.
      ENDIF.
      IF ZTITIG00-SJPAP EQ C_CHARV.
        ZTITVAK-APVEN = ZTITVAK-LIFNR.
      ELSEIF ZTITIG00-SJPAP EQ C_CHARB.
        ZTITVAK-APVEN = ZTSTIG3-LIFNR.
      ENDIF.
    ENDIF.
  ENDIF.


  CLEAR ZTITVAK-GJAHR.

  G_MONAT = ZTITVAK-MONAT.

  PERFORM PERIODE_DETERMINE USING ZTITVAK-BUKRS
                                  ZTITVAK-BUDAT
                                  ZTITVAK-GJAHR
                                  ZTITVAK-MONAT.

  IF NOT G_MONAT IS INITIAL
  AND    G_MONAT NE ZTITVAK-MONAT
  AND ( SY-BINPT = SPACE AND SY-CALLD = SPACE ).
    MESSAGE W000(F5) WITH G_MONAT ZTITVAK-BUDAT ZTITVAK-MONAT.
  ENDIF.

**> 선급금 구분이 선급금일 경우 선급금 % Check.
*  IF ZTITVAK-prpyn EQ c_charp.
*    IF ZTITVAK-pprat IS INITIAL.
*      PERFORM no_input_check USING 'ZTITVAK' 'PPRAT' c_success.
*    ENDIF.
*  ENDIF.

*> 사업장.
  IF NOT ( SY-DYNNR EQ C_SCR0100 OR
           SY-DYNNR EQ C_SCR0120 ).
    IF ZTITVAK-BUPLA IS INITIAL.
      ZTITVAK-BUPLA = C_BUPLA.
      IF ZTITVAK-BUPLA IS INITIAL.
        PERFORM NO_INPUT_CHECK USING 'ZTITVAK' 'BUPLA' C_ERROR.
      ENDIF.
    ENDIF.

*> 사업영역
    IF ZTITVAK-GSBER IS INITIAL.
      PERFORM NO_INPUT_CHECK USING 'ZTITVAK' 'GSBER' C_ERROR.
    ENDIF.
  ENDIF.

***> 사업영역.
*  IF ZTITVAK-gsber IS INITIAL.
*    PERFORM no_input_check USING 'ZTITVAK' 'GSBER' c_error.
*  ENDIF.
*  IF NOT ( ZTITVAK-gsber EQ c_gsber1 OR
*           ZTITVAK-gsber EQ c_gsber2 ).
*    SET CURSOR FIELD 'ZTITVAK-GSBER'.
*    MESSAGE e876 WITH ZTITVAK-gsber.
*  ENDIF.

*> 전표유형.
  IF ZTITVAK-BLART IS INITIAL.
    ZTITVAK-BLART = C_BLART.
    IF ZTITVAK-BLART IS INITIAL.
      PERFORM NO_INPUT_CHECK USING 'ZTITVAK' 'BLART' C_ERROR.
    ENDIF.
  ENDIF.

  CALL FUNCTION 'FI_POSTING_KEY_DATA'
    EXPORTING
      I_BSCHL       = '31'
      I_UMSKZ       = SPACE       ">bseg-umskz
    IMPORTING
      E_T074U       = T074U
      E_TBSL        = TBSL
      E_TBSLT       = TBSLT
    EXCEPTIONS
      ERROR_MESSAGE = 1.

* 1. PBO: no message if bschl request umskz
  IF SY-SUBRC = 1.
* (del) if not ( firstcall = 'X'                           "Note 352492
    IF TBSL-XSONU NE SPACE.
      MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO WITH
              SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    ENDIF.
  ENDIF.

*>> VENDOR MASTER DEFINE.
  IF NOT ZTITVAK-LIFNR IS INITIAL.
    CLEAR : LFA1.
    SELECT SINGLE * INTO LFA1 FROM LFA1
                    WHERE LIFNR EQ ZTITVAK-LIFNR.
    IF SY-SUBRC NE 0.
      MESSAGE E924 WITH '구매처' ZTITVAK-LIFNR.
    ENDIF.

    CALL FUNCTION 'FI_VENDOR_DATA'
      EXPORTING
        I_BUKRS = ZTITVAK-BUKRS
        I_LIFNR = ZTITVAK-LIFNR
      IMPORTING
        E_KRED  = VF_KRED.

    IF ZTITVAK-ZTERM NE VF_KRED-ZTERM.
      IF ZTITVAK-ZTERM IS INITIAL.
        ZTITVAK-ZTERM = VF_KRED-ZTERM.
*      ELSE.
*        MESSAGE w855 WITH ZTITVAK-zterm
*                          ZTITVAK-lifnr vf_kred-zterm.
      ENDIF.
    ENDIF.
  ENDIF.

*> 지급조건.
  IF NOT ZTITVAK-ZTERM IS INITIAL.
    SELECT * FROM T052
             WHERE ZTERM EQ ZTITVAK-ZTERM.
    ENDSELECT.
    IF SY-SUBRC NE 0.
      MESSAGE E839(F5) WITH ZTITVAK-ZTERM.
    ENDIF.
  ENDIF.

*> 세금코드.
  IF ZTITVAK-MWSKZ IS INITIAL.
    READ TABLE IT_TAB INTO G_TC_2130_WA INDEX 1.
    IF SY-SUBRC EQ 0.
      ZTITVAK-MWSKZ = G_TC_2130_WA-MWSKZ.
    ENDIF.
*
*    ZTITVAK-mwskz = c_mwskz.
    IF ZTITVAK-MWSKZ IS INITIAL.
      PERFORM NO_INPUT_CHECK USING 'ZTITVAK' 'MWSKZ' C_ERROR.
    ENDIF.
  ENDIF.

*>> TAX CODE CHECK.
  IF NOT ZTITVAK-LIFNR IS INITIAL.
    CALL FUNCTION 'FI_TAX_INDICATOR_CHECK'
      EXPORTING
        I_BUKRS  = ZTITVAK-BUKRS
        I_HKONT  = VF_KRED-AKONT
        I_KOART  = 'K'
        I_MWSKZ  = ZTITVAK-MWSKZ
        I_STBUK  = SPACE
        X_DIALOG = 'X'
      IMPORTING
        E_EGRKZ  = G_EGRKZ.
  ENDIF.

*> 기준일자.
  IF ZTITVAK-ZFBDT IS INITIAL.
*    ZTITVAK-zfbdt = ZTITVAK-civdt.
    G_ZTERM_MODIFY = C_TRUE.
  ENDIF.

  IF G_ZTERM_MODIFY EQ C_TRUE.
    IF ZTITVAK-ZFBDT IS INITIAL.
      CALL FUNCTION 'FI_TERMS_OF_PAYMENT_PROPOSE'
        EXPORTING
          I_BLDAT = ZTITVAK-BLDAT
          I_BUDAT = ZTITVAK-BUDAT
          I_ZTERM = ZTITVAK-ZTERM
        IMPORTING
          E_ZFBDT = ZTITVAK-ZFBDT
          E_ZBD1T = ZTITVAK-ZBD1T
          E_ZBD1P = ZTITVAK-ZBD1P
          E_ZBD2T = ZTITVAK-ZBD2T
          E_ZBD2P = ZTITVAK-ZBD2P
          E_ZBD3T = ZTITVAK-ZBD3T
          E_ZLSCH = ZTITVAK-ZLSCH
          E_ZSCHF = ZTITVAK-ZLSPR.
    ELSE.
      CALL FUNCTION 'FI_TERMS_OF_PAYMENT_PROPOSE'
        EXPORTING
          I_BLDAT = ZTITVAK-BLDAT
          I_BUDAT = ZTITVAK-BUDAT
          I_CPUDT = SY-DATLO
          I_ZFBDT = ZTITVAK-ZFBDT
          I_ZTERM = ZTITVAK-ZTERM
        IMPORTING
          E_ZBD1T = ZTITVAK-ZBD1T
          E_ZBD1P = ZTITVAK-ZBD1P
          E_ZBD2T = ZTITVAK-ZBD2T
          E_ZBD2P = ZTITVAK-ZBD2P
          E_ZBD3T = ZTITVAK-ZBD3T
          E_ZLSCH = ZTITVAK-ZLSCH
*      e_zschf = ZTITVAK-zlspr
          E_ZSCHF = G_ZLSPR
          E_ZFBDT = G_ZFBDT.
*
*          e_zschf = ZTITVAK-zlspr
*          e_zfbdt = ZTITVAK-zfbdt.
*
      IF NOT G_ZFBDT IS INITIAL.
        ZTITVAK-ZFBDT = G_ZFBDT.
      ENDIF.
    ENDIF.
  ENDIF.

  CLEAR: FAEDE.

  FAEDE-SHKZG = 'H'.
  FAEDE-KOART = 'K'.
  FAEDE-ZFBDT = ZTITVAK-ZFBDT.
  FAEDE-ZBD1T = ZTITVAK-ZBD1T.
  FAEDE-ZBD2T = ZTITVAK-ZBD2T.
  FAEDE-ZBD3T = ZTITVAK-ZBD3T.
*  faede-rebzg = space.
*  faede-rebzt = bseg-rebzt.
  FAEDE-BLDAT = ZTITVAK-BLDAT.

  CALL FUNCTION 'DETERMINE_DUE_DATE'
    EXPORTING
      I_FAEDE = FAEDE
    IMPORTING
      E_FAEDE = FAEDE
    EXCEPTIONS
      OTHERS  = 1.

  ZTITVAK-NETDT = FAEDE-NETDT.

*> 기준일 기준 환율 Set.
  IF ZTITVAK-WWERT IS INITIAL.
    MOVE ZTITVAK-ZFBDT TO ZTITVAK-WWERT.
  ENDIF.

  IF ZTITVAK-KURSF IS INITIAL.
    CLEAR: ZTITVAK-KURSF.

    CALL FUNCTION 'FI_CURRENCY_CHECK'
           EXPORTING
                I_BLDAT  = ZTITVAK-BLDAT
                I_BUDAT  = ZTITVAK-BUDAT
                I_BUKRS  = ZTITVAK-BUKRS
                I_BLART  = ZTITVAK-BLART
*              I_KURS2  = BKPF-KURS2
*              I_KURS3  = BKPF-KURS3
                I_KURSF  = ZTITVAK-KURSF
                I_WAERS  = ZTITVAK-WAERS
                X_DIALOG = 'X'          "Warnungen im Dialog!
                I_WWERT  = ZTITVAK-WWERT
           IMPORTING
*              E_KURS2  = BKPF-KURS2
*              E_KURS3  = BKPF-KURS3
                E_KURSF  = ZTITVAK-KURSF
                E_WWERT  = ZTITVAK-WWERT.

    IF ZTITVAK-KURSF LT 0.
      ZTITVAK-KURSF = 0.
    ENDIF.

    IF ZTITVAK-WAERS EQ T001-WAERS.
      ZTITVAK-KURSF = 1.
    ENDIF.
  ENDIF.

ENDMODULE.                 " pai_check_input_value_scr2121  INPUT
*&---------------------------------------------------------------------*
*&      Module  PAI_ITEM_AMOUNT_ADJUST_SCR2130  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE PAI_ITEM_AMOUNT_ADJUST_SCR2130 INPUT.

  G_WRBTR_REQUEST = C_TRUE.

ENDMODULE.                 " PAI_ITEM_AMOUNT_ADJUST_SCR2130  INPUT
*&---------------------------------------------------------------------*
*&      Module  user_command_2121  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_2121 INPUT.

*> F2 Funtion key Event시 해당 필드의 정보 display
  PERFORM  DOUBLE_CLICK_EVENT.

ENDMODULE.                 " user_command_2121  INPUT
*&---------------------------------------------------------------------*
*&      Module  user_command_2122  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_2122 INPUT.
*> F2 Funtion key Event시 해당 필드의 정보 display
  PERFORM  DOUBLE_CLICK_EVENT.

ENDMODULE.                 " user_command_2122  INPUT
*&---------------------------------------------------------------------*
*&      Module  user_command_2124  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_2124 INPUT.

*> F2 Funtion key Event시 해당 필드의 정보 display
  PERFORM  DOUBLE_CLICK_EVENT.

ENDMODULE.                 " user_command_2124  INPUT
*&---------------------------------------------------------------------*
*&      Module  pai_vender_split_scr2121  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE PAI_VENDER_SPLIT_SCR2121 INPUT.

  CHECK : G_MODE EQ C_CHARC OR
          G_MODE EQ C_CHARM OR
          G_MODE EQ C_CHARP.

*>송장금액 체크.
  PERFORM CHECK_OPEN_AMOUNT.

*  IF ZTITVAK-rtchg IS INITIAL.
*    REFRESH: it_ztitivv.  CLEAR: it_ztitivv.
*  ELSE.
*    READ TABLE it_ztitivv INTO gs_ztitivv WITH KEY split = 1.
*    g_subrc = sy-subrc.
*    gs_ztitivv-split = 1.
*    gs_ztitivv-splam = ZTITVAK-ivamp - ZTITVAK-rtchg.
*    gs_ztitivv-zlsch = ZTITVAK-zlsch.
*    gs_ztitivv-uzawe = ZTITVAK-uzawe.
*    gs_ztitivv-zterm = ZTITVAK-zterm.
*    gs_ztitivv-zlsch = ZTITVAK-zlsch.
*    gs_ztitivv-mwskz = ZTITVAK-mwskz.
*
*    IF g_subrc EQ 0.
*      DELETE it_ztitivv WHERE split = 1.
*    ENDIF.
*    APPEND gs_ztitivv TO it_ztitivv.
*
*    CLEAR: gs_ztitivv.
*    READ TABLE it_ztitivv INTO gs_ztitivv WITH KEY split = 2.
*    g_subrc = sy-subrc.
*    gs_ztitivv-split = 2.
*    gs_ztitivv-splam = ZTITVAK-rtchg.
*    gs_ztitivv-mwskz = ZTITVAK-mwskz.
*    IF g_subrc EQ 0.
*      DELETE it_ztitivv WHERE split = 2.
*    ENDIF.
*    APPEND gs_ztitivv TO it_ztitivv.
*
*    LOOP AT it_ztitivv.
*      IF NOT ( it_ztitivv-split EQ 1 OR
*               it_ztitivv-split EQ 2 ).
*        DELETE it_ztitivv.
*      ENDIF.
*    ENDLOOP.
*  ENDIF.

ENDMODULE.                 " pai_vender_split_scr2121  INPUT
*&---------------------------------------------------------------------*
*&      Module  PAI_CHECK_INVOICE_NUMBER  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE PAI_CHECK_INVOICE_NUMBER INPUT.

  CHECK NOT ( G_MODE EQ 'S' OR
              G_MODE EQ 'D' OR
              G_MODE EQ 'R' ).

  IF ZTITVAK-VORGANG IS INITIAL.
    ZTITVAK-VORGANG = C_CHAR1.
  ENDIF.

  IF NOT ( ZTITVAK-VORGANG EQ C_CHAR1 OR
           ZTITVAK-VORGANG EQ C_CHAR3 ).
*> 문서상태 Fixed value read.
    PERFORM  DDIC_DOMAIN_VALUE_TEXT_READ USING 'MRM_VORGANG'
                                               SY-LANGU
                                               ZTITVAK-VORGANG
                                               G_DDTEXT
                                               C_SUCCESS.
    MESSAGE E305 WITH G_DDTEXT.
  ENDIF.

ENDMODULE.                 " PAI_CHECK_INVOICE_NUMBER  INPUT
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
*&      Module  check_iv_number_chainged  INPUT
*&---------------------------------------------------------------------*
MODULE CHECK_IV_NUMBER_CHAINGED INPUT.
*  CLEAR: g_ivnum_chk1, g_ivnum_chk2.
ENDMODULE.                 " check_iv_number_chainged  INPUT
*&---------------------------------------------------------------------*
*&      Module  check_iv_number  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE CHECK_IV_NUMBER INPUT.

  CHECK : G_MODE EQ C_CHARC OR
          G_MODE EQ C_CHARM.

*  IF g_ivnum_chk1 IS INITIAL.
*    IF ZTITVAK-ivnum IS INITIAL.
*      PERFORM no_input_check USING 'ZTITVAK' 'IVNUM' c_warning.
*      g_ivnum_chk1 = c_true.
*    ENDIF.
*  ENDIF.
*
*  IF g_ivnum_chk2 IS INITIAL.
*    IF NOT ZTITVAK-ivnum IS INITIAL.
*      SELECT ivnum
*        INTO g_ivnum
*        FROM ZTITVAK UP TO 1 ROWS
*       WHERE ivnum   EQ   ZTITVAK-ivnum
*         AND VATNO   NE   ZTITVAK-VATNO.
*      ENDSELECT.
*
*      IF sy-subrc EQ 0.
*        MESSAGE w310 WITH ZTITVAK-ivnum.
*        g_ivnum_chk2 = c_true.
*      ENDIF.
*    ENDIF.
*  ENDIF.

ENDMODULE.                 " check_iv_number  INPUT
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
*&      Module  help_payment_term  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE HELP_PAYMENT_TERM INPUT.

  LOOP AT SCREEN.
    IF SCREEN-NAME EQ 'ZTITVAK-ZTERM'.
      EXIT.
    ENDIF.
  ENDLOOP.

  PERFORM GET_F4_FOR_ZTERM_DYNPRO USING ZTITVAK-ZTERM.


ENDMODULE.                 " help_payment_term  INPUT
*&---------------------------------------------------------------------*
*&      Module  help_payment_term_scr2123  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE HELP_PAYMENT_TERM_SCR2123 INPUT.

  LOOP AT SCREEN.
    IF SCREEN-NAME EQ 'ZTISIVVS-ZTERM'.
      EXIT.
    ENDIF.
  ENDLOOP.

  PERFORM GET_F4_FOR_ZTERM_DYNPRO USING ZTISIVVS-ZTERM.

ENDMODULE.                 " help_payment_term_scr2123  INPUT
*&---------------------------------------------------------------------*
*&      Module  fcode_exit_scr7000  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE FCODE_EXIT_SCR7000 INPUT.

  LEAVE TO SCREEN 0.

ENDMODULE.                 " fcode_exit_scr7000  INPUT
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_7000  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_7000 INPUT.

  CASE OK_CODE_POPUP.
    WHEN 'FEXIT'.
      LEAVE TO SCREEN 0.
    WHEN 'FCOPY'.
      LEAVE TO SCREEN 0.
  ENDCASE.

ENDMODULE.                 " USER_COMMAND_7000  INPUT
*&---------------------------------------------------------------------*
*&      Module  check_prepaid_document  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE CHECK_PREPAID_DOCUMENT INPUT.

  CHECK OK_CODE_POPUP NE 'FEXIT'.

  IF ZTISSCRCOM-REQNO IS INITIAL.
    PERFORM NO_INPUT_CHECK USING 'ZTISSCRCOM' 'REQNO' C_ERROR.
  ENDIF.
  CLEAR:ZTIVRQ04.
  SELECT SINGLE *
    FROM ZTIVRQ04
   WHERE REQNO EQ  ZTISSCRCOM-REQNO.

  IF SY-SUBRC NE 0.
    MESSAGE E108 WITH ZTISSCRCOM-REQNO.
  ELSE.
    CASE ZTIVRQ04-REQTY.
      WHEN 'LC'.
*        MESSAGE e015.
        MESSAGE W027 WITH ZTISSCRCOM-REQNO.
      WHEN 'TT'.
        IF ZTIVRQ04-ANBTY IS INITIAL.
          MESSAGE E015.
        ENDIF.

        IF ZTIVRQ04-ANBTY EQ 'A'.
          MESSAGE E172 WITH ZTIVRQ04-REQNO.
        ENDIF.

        IF ZTIVRQ04-RPAID EQ C_TRUE.
          MESSAGE E026.
        ENDIF.
*        if ZTIvrq04-docst ne c_charo.
*          message
*        endif.
      WHEN OTHERS.
        MESSAGE E014 WITH ZTIVRQ04-REQTY.
    ENDCASE.
    CASE ZTIVRQ04-DOCST.
      WHEN 'W' OR 'Y' OR 'O' .
      WHEN OTHERS.
*> 문서상태 Fixed value read.
        PERFORM  DDIC_DOMAIN_VALUE_TEXT_READ USING 'ZTIDOCST'
                                                   SY-LANGU
                                                   ZTIVRQ04-DOCST
                                                   G_DDTEXT
                                                   C_SUCCESS.
        MESSAGE S922 WITH G_DDTEXT.
    ENDCASE.
    IF ZTIVRQ04-DCEND EQ 'X'.
      MESSAGE E923 WITH ZTIVRQ04-REQNO.
    ENDIF.
    REFRESH: IT_REQIT_TMP, IT_TAB.
    CLEAR: IT_REQIT_TMP, IT_TAB.

    PERFORM GET_LC_DOCUMENT_DATA TABLES IT_REQIT_TMP
                                 USING  ZTIVRQ04-REQNO
                                        ZTIVRQ04-AMDSQ
                                        C_ERROR
                                        C_ERROR.

    LOOP AT IT_REQIT_TMP.
      CLEAR: G_MODIFY, ZTIVRQ00.
      DESCRIBE TABLE IT_TAB LINES G_COUNT_1.
      PERFORM  GET_AND_CHECK_LC_DATA   USING  IT_REQIT_TMP-REQNO
                                              IT_REQIT_TMP-AMDSQ
                                              IT_REQIT_TMP-REQIT
                                              G_MODIFY
                                              ZTIVRQ00
                                              G_COUNT_1
                                              C_SUCCESS.
*> L/C data Move
      PERFORM SET_PREPAID_INVOICE_DATA   TABLES IT_TAB
                                         USING  ZTIVRQ00
                                                ZTITVAK
                                                IT_REQIT_TMP.
    ENDLOOP.
**> 선급금 구분자.
*    CASE ztivrq04-reqty.
*      WHEN c_tt.
*        ZTITVAK-prpyn = c_charp.
*      WHEN c_lc.
*        ZTITVAK-prpyn = c_charr.
*      WHEN OTHERS.
*        ZTITVAK-prpyn = c_charp.
*    ENDCASE.

    LOOP AT IT_TAB INTO G_TC_2130_WA.
      G_TC_2130_WA-IVMNG = G_TC_2130_WA-REMNG.
      MODIFY IT_TAB FROM G_TC_2130_WA.
    ENDLOOP.

  ENDIF.

ENDMODULE.                 " check_prepaid_document  INPUT
*&---------------------------------------------------------------------*
*&      Module  pai_item_amount_scr2130  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE PAI_ITEM_AMOUNT_SCR2130 INPUT.

  G_MENGE_REQUEST = C_TRUE.

ENDMODULE.                 " pai_item_amount_scr2130  INPUT
*&---------------------------------------------------------------------*
*&      Module  pai_read_it_tab  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE PAI_READ_IT_TAB INPUT.

  IF IT_TAB[] IS INITIAL.
    EXIT FROM STEP-LOOP.
  ENDIF.

  DESCRIBE TABLE IT_TAB LINES G_COUNT.
  G_INDEX = G_OLD_TOP_LINE + SY-STEPL - 1.
  CHECK G_INDEX LE TC_2130-LINES.
  CHECK G_INDEX LE G_COUNT.

  READ TABLE IT_TAB INTO G_TC_2130_OLD INDEX G_INDEX.
  IF SY-SUBRC NE 0.
    MESSAGE E008(M8) WITH 'PAI_READ_IT_TAB'.
  ENDIF.

ENDMODULE.                 " pai_read_it_tab  INPUT
*&---------------------------------------------------------------------*
*&      Module  help_exchange_rate  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE HELP_EXCHANGE_RATE INPUT.

  DATA: L_UKURS   TYPE TCURR-UKURS,
        L_DISPALY TYPE XFELD.


  LOOP AT SCREEN.
    IF SCREEN-NAME EQ 'ZTITVAK-KURSF'.
      EXIT.
    ENDIF.
  ENDLOOP.

  IF SCREEN-INPUT EQ '1'.
    L_DISPALY = ' '.
  ELSE.
    L_DISPALY = C_TRUE.
  ENDIF.

  L_UKURS = ZTITVAK-KURSF.


  CALL FUNCTION 'F4_EXCHANGE_RATE'
    EXPORTING
      TYPE_OF_RATE     = 'M'
      DATE             = ZTITVAK-WWERT
      FOREIGN_CURRENCY = ZTITVAK-WAERS
      LOCAL_CURRENCY   = T001-WAERS
      DISPLAY_ONLY     = L_DISPALY
    CHANGING
      KURS             = L_UKURS
    EXCEPTIONS
      OTHERS           = 0.

  ZTITVAK-KURSF = L_UKURS.

ENDMODULE.                 " help_exchange_rate  INPUT
*&---------------------------------------------------------------------*
*&      Module  pai_scr2121_check_payment_term  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE PAI_SCR2121_CHECK_PAYMENT_TERM INPUT.

  G_ZTERM_MODIFY = C_TRUE.

ENDMODULE.                 " pai_scr2121_check_payment_term  INPUT
