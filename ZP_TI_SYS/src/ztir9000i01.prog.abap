************************************************************************
* Title         :  ZTIR9000I01                                         *
*                                                                      *
* Description   : 수입 제비용 관리 PAI Include                         *
*                                                                      *
* Creation Date : 2004/02/22                                           *
*                                                                      *
* Author        : Seog bong, Kang                                      *
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
*> 생성/변경시만.
  CHECK: G_MODE  EQ  C_CHARC  OR
         G_MODE  EQ  C_CHARM.

*> 입력된 데이타가 존재하지 않을 경우.
  IF ZTISCSIT-EXPCD  IS INITIAL AND
     ZTISCSIT-REQNO  IS INITIAL AND
     ZTISCSIT-IIPNO  IS INITIAL AND
     ZTISCSIT-IBLNO  IS INITIAL AND
     ZTISCSIT-ICCNO  IS INITIAL AND
     ZTISCSIT-TAXNO  IS INITIAL AND
     ZTISCSIT-WRBTR  IS INITIAL AND
     ZTISCSIT-WMWST  IS INITIAL.
**     ZTIscsit-REFNO IS INITIAL.
    CLEAR : ZTISCSIT.
    EXIT.
  ENDIF.

*> 비용그룹.
  ZTISCSIT-EXPGR = ZTITCSK-EXPGR.

*> 비용코드 검증...
  IF ZTISCSIT-EXPCD IS INITIAL.
    PERFORM  CHECK_MANDATORY_INPUT USING 'ZTISCSIT-EXPCD' C_ERROR.
  ELSE.
    SELECT SINGLE * FROM ZTITIG06
           WHERE    BUKRS  EQ  ZTITCSK-BUKRS
           AND      EXPGR  EQ  ZTISCSIT-EXPGR
           AND      EXPCD  EQ  ZTISCSIT-EXPCD.
    IF SY-SUBRC NE 0.
      SET CURSOR FIELD 'ZTISCSIT-EXPCD'.
      MESSAGE E924 WITH '비용코드' ZTISCSIT-EXPCD.
    ENDIF.

    MOVE: ZTITIG06-EXPTX     TO ZTISCSIT-EXPTX,
*          ZTItig06-saknr     TO ZTIscsit-saknr,
          ZTITIG06-KSCHL     TO ZTISCSIT-KSCHL,
          ZTITIG06-CSCTY     TO ZTISCSIT-CSCTY.

    IF ZTISCSIT-SAKNR IS INITIAL.
      MOVE ZTITIG06-SAKNR     TO ZTISCSIT-SAKNR.
    ENDIF.
    IF ZTISCSIT-MWSKZ IS INITIAL.
      MOVE ZTITCSK-MWSKZ     TO ZTISCSIT-MWSKZ.
    ENDIF.
    IF ZTISCSIT-MWSKZ IS INITIAL.
      MOVE ZTITIG06-MWSKZ     TO ZTISCSIT-MWSKZ.
    ENDIF.
    IF ZTISCSIT-KOSTL IS INITIAL.
      MOVE ZTITIG06-KOSTL     TO ZTISCSIT-KOSTL.
    ENDIF.
  ENDIF.

*> 관련문서 검증...
  CASE ZTITCSK-EXPGR.
    WHEN 'L'.       ">수입의뢰 관련비용.
      IF ZTISCSIT-REQNO IS INITIAL.
        PERFORM CHECK_MANDATORY_INPUT USING 'ZTISCSIT-REQNO' C_ERROR.
      ENDIF.
      MOVE: ZTISCSIT-REQNO  TO ZTISCSIT-REFNO.
*> Get 수입번호 .
      PERFORM  GET_REQUEST_OF_IMPORT       USING  ZTISCSIT-REQNO
                                                  ZTISCSIT-AMDSQ
                                                  ZTISCSIT-DOCNM
                                                  ZTIVRQ04.
    WHEN 'I'.     ">적하보험.
      IF ZTISCSIT-IIPNO IS INITIAL.
        PERFORM  CHECK_MANDATORY_INPUT USING 'ZTISCSIT-IIPNO' C_ERROR.
      ENDIF.
      MOVE: ZTISCSIT-IIPNO  TO ZTISCSIT-REFNO,
            ZTISCSIT-AMSEQ  TO ZTISCSIT-AMDSQ.
*> Get 증권번호 .
      PERFORM  GET_INSURANCE_DOCUMENT_NO   USING  ZTISCSIT-IIPNO
                                                  ZTISCSIT-AMSEQ
                                                  ZTISCSIT-DOCNM
                                                  ZTITIP1.
    WHEN 'B'.     ">B/L
      IF ZTISCSIT-IBLNO IS INITIAL.
        PERFORM  CHECK_MANDATORY_INPUT USING 'ZTISCSIT-IBLNO' C_ERROR.
      ENDIF.
      MOVE: ZTISCSIT-IBLNO  TO ZTISCSIT-REFNO.
*> Get B/L number .
      PERFORM  GET_BL_NUMBER               USING  ZTISCSIT-IBLNO
                                                  ZTISCSIT-DOCNM
                                                  ZTITBLK.
    WHEN 'C'.     ">통관.
      IF ZTISCSIT-ICCNO IS INITIAL.
        PERFORM  CHECK_MANDATORY_INPUT USING 'ZTISCSIT-ICCNO' C_ERROR.
      ENDIF.
      MOVE: ZTISCSIT-ICCNO  TO ZTISCSIT-REFNO,
            ZTISCSIT-AMSEQ  TO ZTISCSIT-AMDSQ.
*> Get 수리번호 .
      PERFORM  GET_CUSTOM_CLEARANCE        USING  ZTISCSIT-ICCNO
                                                  ZTISCSIT-DOCNM
                                                  ZTITCCK.
    WHEN 'T'.     ">기납증.
      IF ZTISCSIT-TAXNO IS INITIAL.
        PERFORM  CHECK_MANDATORY_INPUT USING 'ZTISCSIT-TAXNO' C_ERROR.
      ENDIF.
      MOVE: ZTISCSIT-TAXNO  TO ZTISCSIT-REFNO.
*> Get 접수번호 .
      PERFORM  GET_TAX_DOCUMENT            USING  ZTISCSIT-TAXNO
                                                  ZTISCSIT-DOCNM
                                                  ZTITTXK.
*-{ 기능개선 230853 - 기납증 전표 텍스트 내 사업자등록번호 추가
      IF ZTITCSK-BUKRS = '1000'.
        IF ZTITCSK-SGTXT IS INITIAL.
          SELECT SINGLE STCD2 FROM LFA1 INTO ZTITCSK-SGTXT
           WHERE LIFNR = ZTITCSK-LIFNR.
        ENDIF.
      ENDIF.
*-} 기능개선 230853
  ENDCASE.

*>금액 검증.
  IF ZTISCSIT-WRBTR IS INITIAL AND
     ZTISCSIT-WMWST IS INITIAL.
    PERFORM  CHECK_MANDATORY_INPUT USING 'ZTISCSIT-WRBTR' C_ERROR.
  ELSE.
    IF ZTITCSK-WAERS EQ ZTITCSK-HWAER.
      ZTISCSIT-DMBTR = ZTISCSIT-WRBTR.
    ELSE.
      CALL FUNCTION 'CONVERT_TO_LOCAL_CURRENCY'
        EXPORTING
          DATE             = ZTITCSK-WWERT
          FOREIGN_AMOUNT   = ZTISCSIT-WRBTR
          FOREIGN_CURRENCY = ZTITCSK-WAERS
          LOCAL_CURRENCY   = ZTITCSK-HWAER
          RATE             = ZTITCSK-KURSF
        IMPORTING
          EXCHANGE_RATE    = G_TEXT_EXRATE
          FOREIGN_FACTOR   = G_FOREIGN_FACTOR
          LOCAL_AMOUNT     = ZTISCSIT-DMBTR
          FIXED_RATE       = G_FIXED_RATE
        EXCEPTIONS
          OTHERS           = 01.
    ENDIF.
  ENDIF.

  IF NOT ZTISCSIT-WMWST IS INITIAL AND
         ZTISCSIT-FWBAS IS INITIAL.
    ZTISCSIT-FWBAS = ZTISCSIT-WRBTR.
    IF ZTISCSIT-FWBAS IS INITIAL.
      PERFORM  CHECK_MANDATORY_INPUT USING 'ZTISCSIT-FWBAS' C_ERROR.
    ENDIF.
  ENDIF.
*> 아이템 지정 정보.
  IF ZTISCSIT-ZUONR IS INITIAL.
    MOVE ZTISCSIT-DOCNM TO ZTISCSIT-ZUONR.
    IF ZTISCSIT-ZUONR IS INITIAL.
      PERFORM  CHECK_MANDATORY_INPUT USING 'ZTISCSIT-ZUONR' C_ERROR.
    ENDIF.
  ENDIF.

*> 아이템 텍스트 정보.
  IF ZTISCSIT-SGTXT IS INITIAL.
    MOVE ZTISCSIT-EXPTX TO ZTISCSIT-SGTXT.
    IF ZTISCSIT-SGTXT IS INITIAL.
      PERFORM  CHECK_MANDATORY_INPUT USING 'ZTISCSIT-SGTXT' C_ERROR.
    ENDIF.
  ELSE.

  ENDIF.

  MOVE-CORRESPONDING ZTISCSIT TO G_TC_2130_WA.
**
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

  IF SY-SUBRC NE 0.
    APPEND G_TC_2130_WA TO IT_TAB.
  ENDIF.

ENDMODULE.                   " tc_2130_modify  INPUT

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
                                USING  ZTITCSK.
*> 아이템 정보 display
  PERFORM  DISPLAY_INFOMATION_BY_ITEMS USING   'TC_2130'
                                               'IT_TAB'
                                               'FLAG'
                                               ZTITCSK-LIFNR
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

*> data initial.
  PERFORM P3000_SET_DATA_OF_SCREEN.

  CLEAR: G_COUNT.
*> Input field Check.


*> B/L
  IF NOT ZTISSCRCOM-ICSNO IS INITIAL.
    CALL FUNCTION 'Z_TI_GET_CHARGE_DOCUMENT'
      EXPORTING
        XBUKRS    = ZTISSCRCOM-BUKRS
        XICSNO    = ZTISSCRCOM-ICSNO
      IMPORTING
        XZTITCSK  = ZTITCSK
      TABLES
        XZTITCSP  = IT_TAB
        XZTITCSH  = IT_ZTISCSHS
        XZTITCSD  = IT_ZTISCSDT
      EXCEPTIONS
        NOT_FOUND = 1
        OTHERS    = 2.

    IF SY-SUBRC <> 0.
      MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
              WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    ENDIF.

*    REFRESH: it_ZTIspnit.
*    CLEAR: g_count.
*    LOOP AT it_ZTIsivit.
*      CLEAR: it_ZTIspnit.
*      ADD 1 TO g_count.
*      MOVE-CORRESPONDING it_ZTIsivit TO it_ZTIspnit.
*      MOVE : g_count TO it_ZTIspnit-index,
*             c_true  TO it_ZTIspnit-box.
*      APPEND it_ZTIspnit.
*    ENDLOOP.
  ELSE.
    EXIT.
  ENDIF.

**>가용한 Invoice 품목 검증.
*  PERFORM get_available_iv_item TABLES it_ZTIspnit
*                                USING  c_success
*                                       c_false.
*
*>송장문서의 종류/상태를 검증.
  PERFORM CHECK_INVOICE_DOC_STATUS.

*  LOOP AT it_ZTIspnit.
*    CLEAR: g_modify, ZTIviv00.
*    DESCRIBE TABLE it_tab LINES g_count_1.
**> Get Invoice Items data
*    PERFORM  get_and_check_iv_data   USING  it_ZTIspnit-ivono
*                                            it_ZTIspnit-rblgp
*                                            g_modify
*                                            ZTIviv00
*                                            g_count_1.
**> Invoice data Move
*    PERFORM set_request_of_import_data TABLES it_tab
*                                       USING  ZTIviv00
*                                              ZTITPNK
*                                              it_ZTIspnit.
*  ENDLOOP.

*>아이템 기타 정보 Read.
  PERFORM SET_OTHERS_FIELDS_BY_ITEMS.
*>화면상의 Text를 Master Data 등에서 Read.
  PERFORM GET_OTHERS_TEXT_BY_MASTER_DATA.

ENDMODULE.                 " pai_scr0100_check_input_fields  INPUT
*&---------------------------------------------------------------------*
*&      Module  user_command_scr0100  INPUT
*&---------------------------------------------------------------------*
MODULE USER_COMMAND_SCR0100 INPUT.

*> EXIT확인.
  PERFORM  CHECK_PROGRAM_EXIT_COMMAND.

*> 비용항목 선택시.
  IF OK_CODE EQ 'ZTIEXPGR'.
    CASE ZTISSCRCOM-EXPGR.
      WHEN C_CHARL.     ">은행관련비용.
        G_CSTCT_TEMP = C_CHARB.
      WHEN C_CHARI.     ">보험관련비용.
        G_CSTCT_TEMP = C_CHARH.
      WHEN C_CHART.     ">관세전가액.
        G_CSTCT_TEMP = C_CHARZ.
      WHEN OTHERS.
        CLEAR: G_CSTCT_TEMP.
    ENDCASE.

    IF NOT G_CSTCT_TEMP IS INITIAL.
      SELECT SINGLE *
        FROM ZTITIG07
       WHERE BUKRS EQ T001-BUKRS
         AND CSTCT EQ G_CSTCT_TEMP.
      IF SY-SUBRC EQ 0.
        ZTISSCRCOM-BLART = ZTITIG07-BLART.
        ZTISSCRCOM-MWSKZ = ZTITIG07-MWSKZ.
      ENDIF.
    ENDIF.
  ELSEIF OK_CODE EQ 'ZTIENTER'.
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
  ENDIF.

ENDMODULE.                 " user_command_scr0100  INPUT
*&---------------------------------------------------------------------*
*&      Module  pai_scr0200_check_input_fields  INPUT
*&---------------------------------------------------------------------*
MODULE PAI_SCR0200_CHECK_INPUT_FIELDS INPUT.

*> EXIT확인.
  PERFORM  CHECK_PROGRAM_EXIT_COMMAND.

** JS전선 회사코드 2007/04 KSH --------------------------------------
*> AUTHORIZATION_CHECK
  PERFORM P1102_AUTHORIZATION_CHECK USING ZTISSCRCOM-BUKRS.
** JS전선 회사코드 2007/04 KSH --------------------------------------

*> Input fields check
  IF ZTISSCRCOM-ICSNO IS INITIAL.
    MESSAGE E913.
  ENDIF.

*> I/V Select.
  PERFORM P3000_SET_DATA_OF_SCREEN.

  CLEAR: G_COUNT.

  IF NOT ZTISSCRCOM-ICSNO IS INITIAL.
    CALL FUNCTION 'Z_TI_GET_CHARGE_DOCUMENT'
      EXPORTING
        XBUKRS    = ZTISSCRCOM-BUKRS
        XICSNO    = ZTISSCRCOM-ICSNO
      IMPORTING
        XZTITCSK  = ZTITCSK
        XZTITCSO  = ZTITCSO
      TABLES
        XZTITCSP  = IT_TAB
        XZTITCSD  = IT_ZTISCSDT
        XZTITCSH  = IT_ZTISCSHS
      EXCEPTIONS
        NOT_FOUND = 1
        OTHERS    = 2.

    IF SY-SUBRC <> 0.
      MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
              WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    ENDIF.

*> 변경 문서 관리를 위한 이전데이타를 Move.
     *ZTITCSK   = ZTITCSK.
     *ZTITCSO   = ZTITCSO.

*> 변경 문서 관리를 위한 이전데이타를 Move (Item Data).
    REFRESH: XZTITCSP, YZTITCSP.
    LOOP AT IT_TAB INTO G_TC_2130_WA.
      MOVE-CORRESPONDING G_TC_2130_WA TO : XZTITCSP,
                                           YZTITCSP.
      APPEND : XZTITCSP, YZTITCSP.
      IF ZTITCSK-EXPGR EQ 'I'.
        G_TC_2130_WA-AMSEQ = G_TC_2130_WA-AMSEQ.
        MODIFY IT_TAB FROM G_TC_2130_WA.
      ENDIF.
    ENDLOOP.

*>업무영역별 Status Check.
    PERFORM CHECK_DOCUMENT_STATUS.

*>아이템 기타 정보 Read.
    PERFORM SET_OTHERS_FIELDS_BY_ITEMS.

*>화면상의 Text를 Master Data 등에서 Read.
    PERFORM GET_OTHERS_TEXT_BY_MASTER_DATA.

*>조회모드가 아닌 경우 Lock.
    IF G_MODE NE C_CHARS.
      PERFORM SET_CS_LOCK_OBJECT   USING ZTITCSK-BUKRS
                                         ZTITCSK-ICSNO
                                         C_LOCK
                                         C_ERROR
                                         G_MODIFY.
    ENDIF.

*> Document History 조회.
    DESCRIBE TABLE IT_ZTISCSHS LINES G_LINE.
    IF G_LINE GT 0.
      G_HISTORY = C_TRUE.
    ELSE.
      CLEAR G_HISTORY.
    ENDIF.

    ZTISSCRCOM-REQTY = G_DOCUMENT.
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
*&      Module  pai_check_company_code  INPUT
*&---------------------------------------------------------------------*
*       회사코드 점검.
*----------------------------------------------------------------------*
MODULE PAI_CHECK_COMPANY_CODE INPUT.

*> EXIT확인.
  PERFORM  CHECK_PROGRAM_EXIT_COMMAND.

*> Error Message Display (if No Input)
  IF ZTISSCRCOM-BUKRS IS INITIAL.
    PERFORM  NO_INPUT_CHECK    USING 'ZTISSCRCOM' 'BUKRS' C_ERROR.
  ELSE.
    PERFORM  GET_COMPANY_CODE   USING ZTISSCRCOM-BUKRS.
  ENDIF.

** JS전선 회사코드 2007/04 KSH --------------------------------------
*> AUTHORIZATION_CHECK
  PERFORM P1102_AUTHORIZATION_CHECK USING ZTISSCRCOM-BUKRS.
** JS전선 회사코드 2007/04 KSH --------------------------------------

  SELECT SINGLE *
    FROM ZTITIG00
   WHERE BUKRS EQ T001-BUKRS.
  IF SY-SUBRC NE 0.
    MESSAGE E035 WITH T001-WAERS.
  ENDIF.

  IF ZTISSCRCOM-WAERS IS INITIAL.
    ZTISSCRCOM-WAERS  =  T001-WAERS.
  ENDIF.

ENDMODULE.                 " pai_check_company_code  INPUT
*&---------------------------------------------------------------------*
*&      Module  PAI_CHECK_PERIOD  INPUT
*&---------------------------------------------------------------------*
*       전기기간 점검.
*----------------------------------------------------------------------*
MODULE PAI_CHECK_PERIOD INPUT.

  CHECK NOT ( G_MODE EQ 'S' OR
              G_MODE EQ 'D' OR
              G_MODE EQ 'R' ).
*> EXIT확인.
  PERFORM  CHECK_PROGRAM_EXIT_COMMAND.

  IF ZTISSCRCOM-BLDAT IS INITIAL.
    PERFORM NO_INPUT_CHECK USING 'ZTISSCRCOM' 'BLDAT' C_ERROR.
  ENDIF.

  IF ZTISSCRCOM-BUDAT IS INITIAL.
    PERFORM NO_INPUT_CHECK USING 'ZTISSCRCOM' 'BUDAT' C_ERROR.
  ENDIF.

  CLEAR ZTITCSK-GJAHR.
  G_MONAT = ZTITCSK-MONAT.

  PERFORM PERIODE_DETERMINE USING ZTISSCRCOM-BUKRS
                                  ZTISSCRCOM-BUDAT
                                  ZTISSCRCOM-GJAHR
                                  ZTISSCRCOM-MONAT.

  IF NOT G_MONAT IS INITIAL
  AND    G_MONAT NE ZTITCSK-MONAT
  AND ( SY-BINPT = SPACE AND SY-CALLD = SPACE ).
    MESSAGE W000(F5) WITH G_MONAT ZTISSCRCOM-BUDAT ZTISSCRCOM-MONAT.
  ENDIF.

ENDMODULE.                 " PAI_CHECK_PERIOD  INPUT
*&---------------------------------------------------------------------*
*&      Module  pai_scr0100_check_vendor_data  INPUT
*&---------------------------------------------------------------------*
*       지불처 점검.
*----------------------------------------------------------------------*
MODULE PAI_SCR0100_CHECK_VENDOR_DATA INPUT.

  CHECK NOT ( G_MODE EQ 'S' OR
              G_MODE EQ 'D' OR
              G_MODE EQ 'R' ).

*> EXIT확인.
  PERFORM  CHECK_PROGRAM_EXIT_COMMAND.

  IF ZTISSCRCOM-LIFNR IS INITIAL.
    PERFORM NO_INPUT_CHECK USING 'ZTISSCRCOM' 'LIFNR' C_ERROR.
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
*    CLEAR : *LFA1.
*    SELECT SINGLE * INTO *LFA1 FROM LFA1
*                    WHERE LIFNR EQ ZTISSCRCOM-LIFNR.
*    IF SY-SUBRC NE 0.
*       MESSAGE E001 WITH 'Vendor' ZTISSCRCOM-LIFNR.
*    ENDIF.

  CALL FUNCTION 'FI_VENDOR_DATA'
    EXPORTING
      I_BUKRS = ZTISSCRCOM-BUKRS
      I_LIFNR = ZTISSCRCOM-LIFNR
    IMPORTING
      E_KRED  = VF_KRED.

  ZTITCSK-XCPDK = VF_KRED-XCPDK.

  CLEAR: ZTISSCRCOM-ZTERM.
  IF ZTISSCRCOM-ZTERM NE VF_KRED-ZTERM.
    IF ZTISSCRCOM-ZTERM IS INITIAL.
      ZTISSCRCOM-ZTERM = VF_KRED-ZTERM.
    ELSE.
      MESSAGE W855 WITH ZTISSCRCOM-ZTERM
                        ZTISSCRCOM-LIFNR VF_KRED-ZTERM.
    ENDIF.
  ENDIF.

*  IF ZTIsscrcom-mwskz IS INITIAL.
*    PERFORM no_input_check USING 'ZTISSCRCOM' 'MWSKZ' c_error.
*  ENDIF.
*
  ZTISSCRCOM-AKONT = VF_KRED-AKONT.

*>> TAX CODE CHECK.
  CALL FUNCTION 'FI_TAX_INDICATOR_CHECK'
    EXPORTING
      I_BUKRS  = ZTISSCRCOM-BUKRS
      I_HKONT  = VF_KRED-AKONT
      I_KOART  = 'K'
      I_MWSKZ  = ZTISSCRCOM-MWSKZ
      I_STBUK  = SPACE
      X_DIALOG = 'X'
    IMPORTING
      E_EGRKZ  = G_EGRKZ.

ENDMODULE.                 " pai_scr0100_check_vendor_data  INPUT
*&---------------------------------------------------------------------*
*&      Module  pai_scr0100_check_doc_type  INPUT
*&---------------------------------------------------------------------*
*       전표유형 점검.
*----------------------------------------------------------------------*
MODULE PAI_SCR0100_CHECK_DOC_TYPE INPUT.

*> EXIT확인.
  PERFORM  CHECK_PROGRAM_EXIT_COMMAND.

  IF ZTISSCRCOM-BLART IS INITIAL.
    PERFORM NO_INPUT_CHECK USING 'ZTISSCRCOM' 'BLART' C_ERROR.
  ELSE.
*> 문서 종류 체크.
    PERFORM BELEGART_PRUEFEN(SAPFF001)
            USING ZTISSCRCOM-BLART ZTISSCRCOM-GJAHR.
*> 전기년도 체크.
    BKPF-BUKRS = ZTISSCRCOM-BUKRS.
    PERFORM NUMMERNKREIS_LESEN(SAPFF001)
            USING ZTISSCRCOM-GJAHR.
  ENDIF.

ENDMODULE.                 " pai_scr0100_check_doc_type  INPUT
*&---------------------------------------------------------------------*
*&      Module  PAI_SCR0100_GET_EXCHAGE_RATE  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE PAI_SCR0100_GET_EXCHAGE_RATE INPUT.
*> EXIT확인.
  PERFORM  CHECK_PROGRAM_EXIT_COMMAND.

  CLEAR SY-MSGTY.
  CALL FUNCTION 'CURRENCY_CODE_CHECK'
       EXPORTING
            I_OBJECT        = 'BKPF'
            I_BUKRS         = ZTISSCRCOM-BUKRS
            I_CURRENCY_CODE = ZTISSCRCOM-WAERS
*            i_budat         = ZTBKPF-BUDAT
*            i_bldat         = ZTBKPF-BLDAT
*            i_wwert         = ZTBKPF-WWERT
*            i_tcode         = 'F-43'
*            i_awtyp         = 'BKPF'
*            i_blart         = ZTBKPF-BLART
*            i_zedat         = ZTBKPF-DBEDT
       EXCEPTIONS
            ERROR_MESSAGE = 1.
  IF SY-SUBRC <> 0.
    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ELSEIF SY-MSGTY = 'W'.
    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

*------- Waehrungsinformationen fuer den Belegkopf ---------------------
  ZTISSCRCOM-HWAER = T001-WAERS.
*  MOVE-CORRESPONDING X001 TO BKPF.

  CALL FUNCTION 'FI_CURRENCY_CHECK'
       EXPORTING
            I_BLDAT  = ZTISSCRCOM-BLDAT
            I_BUDAT  = ZTISSCRCOM-BUDAT
            I_BUKRS  = ZTISSCRCOM-BUKRS
            I_BLART  = ZTISSCRCOM-BLART
*            I_KURS2  = BKPF-KURS2
*            I_KURS3  = BKPF-KURS3
            I_KURSF  = ZTISSCRCOM-KURSF
            I_WAERS  = ZTISSCRCOM-WAERS
            X_DIALOG = 'X'              "Warnungen im Dialog!
            I_WWERT  = ZTISSCRCOM-WWERT
       IMPORTING
*            E_KURS2  = BKPF-KURS2
*            E_KURS3  = BKPF-KURS3
            E_KURSF  = ZTISSCRCOM-KURSF
            E_WWERT  = ZTISSCRCOM-WWERT.

  IF ZTISSCRCOM-KURSF LT 0.
    ZTISSCRCOM-KURSF = 0.
  ENDIF.

  SET PARAMETER ID 'WHR' FIELD ZTISSCRCOM-WAERS.

ENDMODULE.                 " PAI_SCR0100_GET_EXCHAGE_RATE  INPUT
*&---------------------------------------------------------------------*
*&      Module  pai_scr0100_SET_INITIAL_DATA  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE PAI_SCR0100_SET_INITIAL_DATA INPUT.
*> EXIT확인.
  PERFORM  CHECK_PROGRAM_EXIT_COMMAND.

  IF ZTISSCRCOM-EXPGR IS INITIAL.
    PERFORM NO_INPUT_CHECK USING 'ZTISSCRCOM' 'EXPGR' C_ERROR.
  ELSE.
    PERFORM  GET_DOMAIN_VALUE_TEXT USING   'ZTIEXPGR'
                                            ZTITCSK-EXPGR
                                   CHANGING ZTITCSK-BKTXT.

    IF NOT ( ZTISSCRCOM-EXPGR EQ C_CHARL OR
             ZTISSCRCOM-EXPGR EQ C_CHARI OR
             ZTISSCRCOM-EXPGR EQ C_CHARB OR
             ZTISSCRCOM-EXPGR EQ C_CHARC OR
             ZTISSCRCOM-EXPGR EQ C_CHART ).
      MESSAGE E938 WITH ZTITCSK-BKTXT.
    ENDIF.
  ENDIF.

  MOVE: C_CHARN          TO ZTITCSK-LIVST,
        C_CHAR1          TO ZTITCSK-VORGANG,
        ZTISSCRCOM-BUKRS TO ZTITCSK-BUKRS,
        ZTISSCRCOM-BLDAT TO ZTITCSK-BLDAT,
        ZTISSCRCOM-BUDAT TO ZTITCSK-BUDAT,
        ZTISSCRCOM-LIFNR TO ZTITCSK-LIFNR,
        ZTISSCRCOM-EXPGR TO ZTITCSK-EXPGR,
        ZTISSCRCOM-WAERS TO ZTITCSK-WAERS,
        ZTISSCRCOM-BLART TO ZTITCSK-BLART,
        ZTISSCRCOM-MWSKZ TO ZTITCSK-MWSKZ,
        ZTISSCRCOM-HWAER TO ZTITCSK-HWAER,
        ZTISSCRCOM-AKONT TO ZTITCSK-AKONT,
        ZTISSCRCOM-ZTERM TO ZTITCSK-ZTERM,
        ZTISSCRCOM-HWAER TO ZTITCSK-HWAER,
        ZTISSCRCOM-KURSF TO ZTITCSK-KURSF,
        ZTISSCRCOM-WWERT TO ZTITCSK-WWERT,
        ZTISSCRCOM-CSTYP TO ZTITCSK-CSTYP,
        ZTISSCRCOM-GJAHR TO ZTITCSK-GJAHR,
        ZTISSCRCOM-MONAT TO ZTITCSK-MONAT,
        VF_KRED-XCPDK    TO ZTITCSK-XCPDK,
*        c_chara          TO ztitcsk-zlspr,  ">지급보류키.
*        c_bupla          TO ztitcsk-bupla,
*        '130'            TO ztitcsk-bupla,
        SY-UNAME         TO ZTITCSK-CNAM,
        SY-DATLO         TO ZTITCSK-CDAT,
        SY-TIMLO         TO ZTITCSK-CTME,
        SY-UNAME         TO ZTITCSK-UNAM,
        SY-DATLO         TO ZTITCSK-UDAT,
        SY-TIMLO         TO ZTITCSK-UTME.
*>
*  WRITE: SY-UNAME       TO ZTITCSK-CNAME.

  ZTITCSK-XBLNR = ZTITCSK-BKTXT.

*> Default Value Setting
  CLEAR: G_CSTCT.
  CASE ZTITCSK-EXPGR.
    WHEN C_CHARL.    ">수입의뢰비용.
      G_CSTCT = C_CHARB.
    WHEN C_CHARI.    ">적하보험비용.
      G_CSTCT = C_CHARH.
    WHEN C_CHARB.    ">선적관련비용.
      G_CSTCT = C_CHARF.
    WHEN C_CHARC.    ">수입통관비용.
      G_CSTCT = C_CHARF.
    WHEN C_CHART.    ">관세전가액(기납증).
    WHEN C_CHARV.    ">부가세.
  ENDCASE.

  IF NOT G_CSTCT IS INITIAL.
    SELECT SINGLE *
      FROM ZTITIG07
     WHERE BUKRS EQ ZTITIVK-BUKRS
       AND CSTCT EQ G_CSTCT.
    IF SY-SUBRC EQ 0.
      ZTITCSK-BLART = ZTITIG07-BLART.
      ZTITCSK-MWSKZ = ZTITIG07-MWSKZ.
      ZTITCSK-ZTERM = ZTITIG07-ZTERM.
      ZTITCSK-ZLSPR = ZTITIG07-ZLSPR.
      ZTITCSK-ZLSCH = ZTITIG07-ZLSCH.
      ZTITCSK-UZAWE = ZTITIG07-UZAWE.
      ZTITCSK-BUPLA = ZTITIG07-BUPLA.
      ZTITCSK-GSBER = ZTITIG07-GSBER.
      ZTITCSK-CSTYP = ZTITIG07-CSTYP.
    ENDIF.
  ENDIF.

*>화면상의 Text를 Master Data 등에서 Read.
  PERFORM GET_OTHERS_TEXT_BY_MASTER_DATA.

ENDMODULE.                 " pai_scr0100_SET_INITIAL_DATA  INPUT
*&---------------------------------------------------------------------*
*&      Module  COMPANYCODE_CHECK_SCRCOM  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE COMPANYCODE_CHECK_SCRCOM INPUT.

  IF ZTITCSK-BUKRS IS INITIAL.
    PERFORM  NO_INPUT_CHECK USING 'ZTITCSK' 'BUKRS' C_ERROR.
  ELSE.
    PERFORM  GET_COMPANY_CODE USING ZTITCSK-BUKRS.
  ENDIF.

ENDMODULE.                 " COMPANYCODE_CHECK_SCRCOM  INPUT
*&---------------------------------------------------------------------*
*&      Module  help_payment_term_SCR2121  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE HELP_PAYMENT_TERM_SCR2121 INPUT.

  LOOP AT SCREEN.
    IF SCREEN-NAME EQ 'ZTITCSK-ZTERM'.
      EXIT.
    ENDIF.
  ENDLOOP.

  PERFORM GET_F4_FOR_ZTERM_DYNPRO USING ZTITCSK-ZTERM.

ENDMODULE.                 " help_payment_term_SCR2121  INPUT
*&---------------------------------------------------------------------*
*&      Module  help_payer_SCR2121  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE HELP_PAYER_SCR2121 INPUT.

  LOOP AT SCREEN.
    IF SCREEN-NAME EQ 'ZTITCSK-EMPKF'.
      IF SCREEN-INPUT EQ '1'.
        CLEAR: G_DISPLAY.
      ELSE.
        G_DISPLAY = 'X'.
      ENDIF.
      EXIT.
    ENDIF.
  ENDLOOP.

*> IMG화.
*  IF ztitig00-lfzac EQ c_charp.
  CLEAR: G_BUKRS.
*  ELSEIF ztitig00-lfzac EQ c_chara.
*    g_bukrs = ztitcsk-bukrs.
*  ENDIF.

  SELECT P~BUKRS P~LIFNR P~EMPFK H~NAME1
         INTO CORRESPONDING FIELDS OF TABLE XLFZA
         FROM   LFA1 AS H INNER JOIN LFZA AS P
         ON     H~LIFNR   EQ  P~EMPFK
         WHERE  P~BUKRS   EQ  G_BUKRS
         AND    P~LIFNR   EQ  ZTITCSK-LIFNR.

  IF SY-SUBRC NE 0.
    MESSAGE S854 WITH ZTITCSK-LIFNR.
    EXIT.
  ENDIF.

  DYNPROG = SY-REPID.
  DYNNR   = SY-DYNNR.

  G_WINDOW_TITLE = '대체 수취인 Help'.

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
           EXPORTING
*                RETFIELD        = 'OTYPE'
                RETFIELD        = 'EMPFK'
                DYNPPROG        = DYNPROG
                DYNPNR          = DYNNR
                DYNPROFIELD     = 'ZTITCSK-EMPFK'
                WINDOW_TITLE    = G_WINDOW_TITLE
                VALUE_ORG       = 'S'
                DISPLAY         = G_DISPLAY
           TABLES
                VALUE_TAB       = XLFZA
           EXCEPTIONS
                PARAMETER_ERROR = 1
                NO_VALUES_FOUND = 2
                OTHERS          = 3.
  IF SY-SUBRC <> 0.
    EXIT.
  ENDIF.

ENDMODULE.                 " help_payer_SCR2121  INPUT
*&---------------------------------------------------------------------*
*&      Module  belegart_check_scr2121  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE BELEGART_CHECK_SCR2121 INPUT.

  CHECK NOT ( G_MODE EQ 'S' OR
              G_MODE EQ 'D' OR
              G_MODE EQ 'R' ).

  IF ZTITCSK-BLART IS INITIAL.
    PERFORM NO_INPUT(SAPFMMEX) USING 'ZTITCSK' 'BLART'.
  ENDIF.

*> 문서 종류 체크.
  PERFORM BELEGART_PRUEFEN(SAPFF001)
          USING ZTITCSK-BLART ZTITCSK-GJAHR.
*> 전기년도 체크.
  BKPF-BUKRS = ZTITCSK-BUKRS.
  PERFORM NUMMERNKREIS_LESEN(SAPFF001)
          USING ZTITCSK-GJAHR.
*> 권한 검증.
  PERFORM BELEGART_AUTHORITY_CHECK.

ENDMODULE.                 " belegart_check_scr2121  INPUT
*&---------------------------------------------------------------------*
*&      Module  get_exchage_rate_scr2121  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE GET_EXCHAGE_RATE_SCR2121 INPUT.

  CHECK NOT ( G_MODE EQ 'S' OR
              G_MODE EQ 'D' OR
              G_MODE EQ 'R' ).

* Currency must be set before call of 'CURRENCY_CODE_CHECK "Note 210410
*  if rfopt-xnowa ne space.                                 "Note 210410
*    bkpf-waers = t001-waers.                               "Note 210410
*  endif.                                                   "Note 210410
*
  CLEAR SY-MSGTY.
  CALL FUNCTION 'CURRENCY_CODE_CHECK'
       EXPORTING
            I_OBJECT        = 'BKPF'
            I_BUKRS         = ZTITCSK-BUKRS
            I_CURRENCY_CODE = ZTITCSK-WAERS
*            i_budat         = ZTITCSK-BUDAT
*            i_bldat         = ZTITCSK-BLDAT
*            i_wwert         = ZTITCSK-WWERT
*            i_tcode         = 'F-43'
*            i_awtyp         = 'BKPF'
*            i_blart         = ZTITCSK-BLART
*            i_zedat         = ZTBKPF-DBEDT
       EXCEPTIONS
            ERROR_MESSAGE = 1.
  IF SY-SUBRC <> 0.
    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ELSEIF SY-MSGTY = 'W'.
    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

*------- Waehrungsinformationen fuer den Belegkopf ---------------------
  ZTITCSK-HWAER = T001-WAERS.
*  MOVE-CORRESPONDING X001 TO BKPF.

  IF ZTITCSK-WAERS EQ ZTITCSK-HWAER.
    ZTITCSK-KURSF = 1.
    ZTITCSK-WWERT = ZTITCSK-BUDAT.
  ELSE.

    CALL FUNCTION 'FI_CURRENCY_CHECK'
         EXPORTING
              I_BLDAT  = ZTITCSK-BLDAT
              I_BUDAT  = ZTITCSK-BUDAT
              I_BUKRS  = ZTITCSK-BUKRS
              I_BLART  = ZTITCSK-BLART
*            I_KURS2  = BKPF-KURS2
*            I_KURS3  = BKPF-KURS3
              I_KURSF  = ZTITCSK-KURSF
              I_WAERS  = ZTITCSK-WAERS
              X_DIALOG = 'X'          "Warnungen im Dialog!
              I_WWERT  = ZTITCSK-WWERT
         IMPORTING
*            E_KURS2  = BKPF-KURS2
*            E_KURS3  = BKPF-KURS3
              E_KURSF  = ZTITCSK-KURSF
              E_WWERT  = ZTITCSK-WWERT.

    IF ZTITCSK-KURSF LT 0.
      ZTITCSK-KURSF = 0.
    ENDIF.
  ENDIF.

  SET PARAMETER ID 'WHR' FIELD ZTITCSK-WAERS.

ENDMODULE.                 " get_exchage_rate_scr2121  INPUT
*&---------------------------------------------------------------------*
*&      Module  vendor_account_check_scr2121  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE VENDOR_ACCOUNT_CHECK_SCR2121 INPUT.

  CHECK NOT ( G_MODE EQ 'S' OR
              G_MODE EQ 'D' OR
              G_MODE EQ 'R' ).

  IF ZTITCSK-LIFNR IS INITIAL.
    PERFORM NO_INPUT(SAPFMMEX) USING 'ZTITCSK' 'LIFNR'.
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
  CLEAR : LFA1.
  SELECT SINGLE * INTO LFA1 FROM LFA1
                  WHERE LIFNR EQ ZTITCSK-LIFNR.
  IF SY-SUBRC NE 0.
    MESSAGE E924 WITH '구매처' ZTITCSK-LIFNR.
  ENDIF.

  CALL FUNCTION 'FI_VENDOR_DATA'
    EXPORTING
      I_BUKRS = ZTITCSK-BUKRS
      I_LIFNR = ZTITCSK-LIFNR
    IMPORTING
      E_KRED  = VF_KRED.

  ZTITCSK-XCPDK = VF_KRED-XCPDK.

*    IF ZTBKPF-ZTERM IS INITIAL.
*       ZTBKPF-ZTERM = VF_KRED-ZTERM.
*    ELSEIF ZTBKPF-ZTERM NE VF_KRED-ZTERM.
  IF ZTITCSK-ZTERM NE VF_KRED-ZTERM.
    IF ZTITCSK-ZTERM IS INITIAL.
      ZTITCSK-ZTERM = VF_KRED-ZTERM.
    ELSE.
*      MESSAGE w855 WITH ZTITCSK-zterm
*                        ZTITCSK-lifnr vf_kred-zterm.
    ENDIF.
  ENDIF.

*> 지급조건.
  IF ZTITCSK-ZTERM IS INITIAL.
    PERFORM  CHECK_MANDATORY_INPUT USING 'ZTITCSK-ZTERM' C_ERROR.
  ELSE.
    SELECT * FROM T052
             WHERE ZTERM EQ ZTITCSK-ZTERM.
    ENDSELECT.

    IF SY-SUBRC NE 0.
      MESSAGE E839(F5) WITH ZTITCSK-ZTERM.
    ENDIF.
  ENDIF.

  IF NOT ZTITCSK-EMPFK IS INITIAL.
    SELECT SINGLE EMPFK INTO ZTITCSK-EMPFK
           FROM   LFZA
           WHERE  LIFNR = ZTITCSK-LIFNR
           AND    BUKRS = ZTITCSK-BUKRS
*           AND    bukrs = space
           AND    EMPFK = ZTITCSK-EMPFK.
    IF SY-SUBRC NE 0.
*      IF vf_kred-lnrza NE ZTITCSK-empfk.
      SET CURSOR FIELD 'ZTITCSK-EMPFK'.
      MESSAGE E858 .
*      ENDIF.
    ENDIF.
  ENDIF.
  IF NOT ZTITCSK-EMPFK IS INITIAL.
    SELECT SINGLE * INTO *LFA1
           FROM LFA1
           WHERE  LIFNR EQ ZTITCSK-EMPFK.
  ELSE.
    CLEAR *LFA1.
  ENDIF.

*  IF ZTITCSK-mwskz IS INITIAL.
*    PERFORM  check_mandatory_input USING 'ZTITCSK-MWSKZ' c_error.
*  ENDIF.

  IF ZTITCSK-AKONT IS INITIAL.
    ZTITCSK-AKONT = VF_KRED-AKONT.
  ENDIF.
  IF ZTITCSK-AKONT IS INITIAL.
    PERFORM  CHECK_MANDATORY_INPUT USING 'ZTITCSK-AKONT' C_ERROR.
  ENDIF.

*>> TAX CODE CHECK.
  CALL FUNCTION 'FI_TAX_INDICATOR_CHECK'
    EXPORTING
      I_BUKRS  = ZTITCSK-BUKRS
      I_HKONT  = VF_KRED-AKONT
      I_KOART  = 'K'
      I_MWSKZ  = ZTITCSK-MWSKZ
      I_STBUK  = SPACE
      X_DIALOG = 'X'
    IMPORTING
      E_EGRKZ  = G_EGRKZ.
*> ??????.
*   IF ZTBKPF-WRBTR IS INITIAL AND ZTBKPF-WMWST IS INITIAL.
**      PERFORM NO_INPUT(SAPFMMEX) USING 'ZTBKPF' 'WRBTR'.
*      PERFORM P2000_NO_INPUT USING 'ZTBKPF' 'WRBTR'.
*      MESSAGE E934.
*   ENDIF.
*> ??.
  IF ZTITCSK-WAERS IS INITIAL.
    PERFORM NO_INPUT(SAPFMMEX) USING 'ZTITCSK' 'WAERS'.
  ENDIF.

  IF NOT ZTITIG00-CHKBP IS INITIAL.
    IF ZTITCSK-BUPLA IS INITIAL.    ">
*      PERFORM no_input(sapfmmex) USING 'ZTITCSK' 'BUPLA'.
      PERFORM  CHECK_MANDATORY_INPUT     USING  :
                                    'ZTITCSK-BUPLA' ZTITIG00-CHKBP.
    ENDIF.
  ENDIF.

  IF NOT ZTITIG00-CHKBA IS INITIAL.
    IF ZTITCSK-GSBER IS INITIAL.    ">
*      PERFORM no_input(sapfmmex) USING 'ZTITCSK' 'BUPLA'.
      PERFORM  CHECK_MANDATORY_INPUT     USING  :
                                    'ZTITCSK-GSBER' ZTITIG00-CHKBA.
    ENDIF.
  ENDIF.


************************************************************************
*> '03/12/02 -
*>  FI 모듈과 협의 후 사업영역은 스탠다드에서 자동 Setting되도록 함.
************************************************************************
**************************> Begin of Deleted <**************************
**> 사업영역 체크
*  IF ZTITCSK-gsber IS INITIAL.    ">
*    PERFORM no_input(sapfmmex) USING 'ZTITCSK' 'GSBER'.
*  ENDIF.
*
*  PERFORM  check_business_area  USING ZTITCSK-gsber.

**************************> End of Deleted <****************************
************************************************************************
*> Get Vendor master
  PERFORM  GET_IMPORT_VENDORS_TEXT  USING C_SUCCESS.

**>> TAX CALC..
*   IF ZTITCSK-XMWST EQ 'X'.
*      SELECT SINGLE * FROM T007A
*             WHERE KALSM EQ  T005-KALSM
*             AND   MWSKZ EQ  ZTITCSK-MWSKZ.
*      IF SY-SUBRC NE 0.
*         MESSAGE E495 WITH T005-KALSM ZTITCSK-MWSKZ.
*      ENDIF.
*
*      SELECT * FROM  KONP
*               WHERE KAPPL EQ 'TX'       ">??.
*               AND   KSCHL EQ 'KRIT'     ">?????.
*               AND   MWSK1 EQ ZTITCSK-MWSKZ.
*
*         MOVE: KONP-KBETR   TO   W_KBETR,         ">??.
*               KONP-KONWA   TO   W_KONWA.         ">??.
*         IF NOT W_KBETR IS INITIAL.
*            W_KBETR = W_KBETR / 10.
*         ENDIF.
*      ENDSELECT.
*
*      IF SY-SUBRC EQ 0.
*         IF NOT W_KBETR IS INITIAL.
*            PERFORM SET_CURR_CONV_TO_EXTERNAL
*                    USING ZTITCSK-WRBTR ZTITCSK-WAERS
*                          ZTITCSK-WMWST.
**>>>> ?? : (100 + %) =  X : % ======>
*            W_WMWST = ZTITCSK-WMWST.
*            BAPICURR-BAPICURR = ZTITCSK-WMWST * W_KBETR * 1000.
*            W_KBETR1 = W_KBETR.
*            W_KBETR = ( W_KBETR + 100 ).
*            BAPICURR-BAPICURR = BAPICURR-BAPICURR / W_KBETR.
*
**           ZTBKPF-WMWST = W_WMWST - ( BAPICURR-BAPICURR * 100 / 1000 )
  .
**           ZTBKPF-WMWST = ZTBKPF-WMWST / 10.
*            BAPICURR-BAPICURR = BAPICURR-BAPICURR / 1000.
*            ZTITCSK-WMWST = BAPICURR-BAPICURR.
**            COMPUTE ZTBKPF-WMWST = TRUNC( BAPICURR-BAPICURR ).
**            ZTBKPF-WMWST = ZTBKPF-WMWST * 10.
*
*            PERFORM SET_CURR_CONV_TO_INTERNAL
*                    USING ZTITCSK-WMWST ZTITCSK-WAERS.
*         ELSE.
*            CLEAR : ZTITCSK-WMWST.
*         ENDIF.
*      ELSE.
*         CLEAR : ZTITCSK-WMWST.
*      ENDIF.
*   ENDIF.

*> 물류송장검증일 경우.
**> 직기표일 경우.
*  IF ZTITCSK-ptdcl EQ c_charm.
*    IF ZTITCSK-wrbtr IS INITIAL.
*      PERFORM no_input(sapfmmex) USING 'ZTITCSK' 'WRBTR'.
*    ENDIF.
*  ENDIF.
*
*> 직기표일 경우.
  IF ZTITCSK-PTDCL EQ C_CHARF.
    IF ZTITCSK-AKONT IS INITIAL.
      PERFORM NO_INPUT(SAPFMMEX) USING 'ZTITCSK' 'AKONT'.
    ENDIF.
*    IF ztitcsk-wrbtr IS INITIAL.
*      PERFORM no_input(sapfmmex) USING 'ZTITCSK' 'WRBTR'.
*    ENDIF.
  ENDIF.

*> 부가세 전기일 경우.
  IF ZTITCSK-PTDCL EQ C_CHARV.
    IF ZTITCSK-AKONT IS INITIAL.
      PERFORM NO_INPUT(SAPFMMEX) USING 'ZTITCSK' 'AKONT'.
    ENDIF.
*    IF ZTITCSK-wmwst IS INITIAL.
*      PERFORM no_input(sapfmmex) USING 'ZTITCSK' 'WMWST'.
*    ENDIF.
    IF ZTITCSK-WMWST EQ ZTITCSK-WRBTR.
      IF ZTITCSK-FWBAS IS INITIAL.
*           PERFORM NO_INPUT(SAPFMMEX) USING 'ZTITCSK' 'FWBAS'.
        MESSAGE W857.
        ZTITCSK-FWBAS = ZTITCSK-WMWST * 10.
      ENDIF.
    ELSE.
      MESSAGE E856.
    ENDIF.
  ENDIF.

ENDMODULE.                 " vendor_account_check_scr2121  INPUT
*&---------------------------------------------------------------------*
*&      Module  check_input_fieldS_SCR2121  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE CHECK_INPUT_FIELDS_SCR2121 INPUT.

  CHECK NOT ( G_MODE EQ 'S' OR
              G_MODE EQ 'D' OR
              G_MODE EQ 'R' ).

  IF ZTITCSK-WAERS IS INITIAL.
    PERFORM NO_INPUT(SAPFMMEX) USING 'ZTITCSK' 'WAERS'.
  ENDIF.

  IF ZTITCSK-CSTYP IS INITIAL.
    PERFORM NO_INPUT(SAPFMMEX) USING 'ZTITCSK' 'CSTYP'.
  ELSE.
*> 업무가불일 경우.
    IF ZTITCSK-CSTYP EQ C_CHARA.
*> Get 업무가불 Default value
*      SELECT SINGLE *
*        FROM ztitig07
*       WHERE bukrs EQ ztitcsk-bukrs
*         AND cstct EQ c_charl.
*      IF sy-subrc EQ 0.
*        IF ztitig07-blart NE ztitcsk-blart.
*          MESSAGE w941 WITH ztitcsk-blart ztitig07-blart.
*          ztitcsk-blart = ztitig07-blart.
*        ENDIF.
*      ENDIF.
      IF ZTITCSK-INAME IS INITIAL.
        PERFORM NO_INPUT(SAPFMMEX) USING 'ZTITCSK' 'INAME'.
      ENDIF.

    ENDIF.
  ENDIF.

*  IF ZTITCSK-mwskz IS INITIAL.
*    PERFORM no_input(sapfmmex) USING 'ZTITCSK' 'MWSKZ'.
*  ENDIF.
*  IF ZTITCSK-bktxt IS INITIAL.
*    PERFORM no_input(sapfmmex) USING 'ZTITCSK' 'BKTXT'.
*  ENDIF.
*  IF ZTITCSK-xblnr IS INITIAL.
*    PERFORM no_input(sapfmmex) USING 'ZTITCSK' 'XBLNR'.
*  ENDIF.
*  IF ZTITCSK-sgtxt IS INITIAL.
*    PERFORM no_input(sapfmmex) USING 'ZTITCSK' 'SGTXT'.
*  ENDIF.
*  IF ZTITCSK-ptdcl IS INITIAL.
*    PERFORM no_input(sapfmmex) USING 'ZTITCSK' 'PTDCL'.
*  ENDIF.
**> 전기구분.
*  CASE ZTITCSK-ptdcl.
*    WHEN c_charm.   ">물류송장검증.
*      ZTITCSK-dstrb = c_chard.
*    WHEN c_charf.   ">직기표.
*      IF ZTITCSK-dstrb IS INITIAL.
*        PERFORM no_input(sapfmmex) USING 'ZTITCSK' 'DSTRB'.
*      ENDIF.
*    WHEN c_charv.   ">부가세.
*      ZTITCSK-dstrb = c_charn.
*  ENDCASE.
*
  IF G_ZTERM EQ C_TRUE.
    CALL FUNCTION 'FI_TERMS_OF_PAYMENT_PROPOSE'
      EXPORTING
        I_BLDAT = ZTITCSK-BLDAT
        I_BUDAT = ZTITCSK-BUDAT
        I_CPUDT = SY-DATLO
*      i_zfbdt = ZTITCSK-zfbdt
        I_ZTERM = ZTITCSK-ZTERM
      IMPORTING
        E_ZBD1T = ZTITCSK-ZBD1T
        E_ZBD1P = ZTITCSK-ZBD1P
        E_ZBD2T = ZTITCSK-ZBD2T
        E_ZBD2P = ZTITCSK-ZBD2P
        E_ZBD3T = ZTITCSK-ZBD3T
        E_ZLSCH = ZTITCSK-ZLSCH
        E_ZSCHF = ZTITCSK-ZLSPR
*      e_zschf = g_zlspr
        E_ZFBDT = ZTITCSK-ZFBDT.

    CLEAR: FAEDE.

    FAEDE-SHKZG = 'H'.
    FAEDE-KOART = 'K'.
    FAEDE-ZFBDT = ZTITCSK-ZFBDT.
    FAEDE-ZBD1T = ZTITCSK-ZBD1T.
    FAEDE-ZBD2T = ZTITCSK-ZBD2T.
    FAEDE-ZBD3T = ZTITCSK-ZBD3T.
*  faede-rebzg = space.
*  faede-rebzt = bseg-rebzt.
    FAEDE-BLDAT = ZTITCSK-BLDAT.

    CALL FUNCTION 'DETERMINE_DUE_DATE'
      EXPORTING
        I_FAEDE = FAEDE
      IMPORTING
        E_FAEDE = FAEDE
      EXCEPTIONS
        OTHERS  = 1.

    ZTITCSK-NETDT = FAEDE-NETDT.
  ENDIF.

ENDMODULE.                 " check_input_fieldS_SCR2121  INPUT
*&---------------------------------------------------------------------*
*&      Module  pai_check_period_SCR2121  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE PAI_CHECK_PERIOD_SCR2121 INPUT.
  CHECK NOT ( G_MODE EQ 'S' OR
              G_MODE EQ 'D' OR
              G_MODE EQ 'R' ).

  IF ZTITCSK-BLDAT IS INITIAL.
    PERFORM NO_INPUT_CHECK USING 'ZTITCSK' 'BLDAT' C_ERROR.
  ENDIF.

  IF ZTITCSK-BUDAT IS INITIAL.
    PERFORM NO_INPUT_CHECK USING 'ZTITCSK' 'BUDAT' C_ERROR.
  ENDIF.

*  IF ZTITCSK-zfbdt IS INITIAL.
*    ZTITCSK-zfbdt = ZTITCSK-budat.
*  ENDIF.
  CLEAR ZTITCSK-GJAHR.
  G_MONAT = ZTITCSK-MONAT.

  PERFORM PERIODE_DETERMINE USING ZTITCSK-BUKRS
                                  ZTITCSK-BUDAT
                                  ZTITCSK-GJAHR
                                  ZTITCSK-MONAT.

  IF NOT G_MONAT IS INITIAL
  AND    G_MONAT NE ZTITCSK-MONAT
  AND ( SY-BINPT = SPACE AND SY-CALLD = SPACE ).
    MESSAGE W000(F5) WITH G_MONAT ZTITCSK-BUDAT ZTITCSK-MONAT.
  ENDIF.

ENDMODULE.                 " pai_check_period_SCR2121  INPUT
*&---------------------------------------------------------------------*
*&      Module  user_command_2121  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_2121 INPUT.

*> F2 Funtion key Event시 해당 필드의 정보 display
  PERFORM  DOUBLE_CLICK_EVENT.

  CLEAR: G_ZTERM.

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
*&      Module  check_duplicate_scr2130  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE CHECK_DUPLICATE_SCR2130 INPUT.

  IF ZTISCSIT-EXPCD  IS INITIAL AND
     ZTISCSIT-REQNO  IS INITIAL AND
     ZTISCSIT-IIPNO  IS INITIAL AND
     ZTISCSIT-TAXNO  IS INITIAL AND
     ZTISCSIT-IBLNO  IS INITIAL AND
     ZTISCSIT-ICCNO  IS INITIAL.
    EXIT.
  ENDIF.

  IF ZTITCSK-EXPGR EQ 'L'.
    SELECT *
      FROM ZTIVCS00 UP TO 1 ROWS
      WHERE   EXPGR EQ ZTITCSK-EXPGR
        AND   EXPCD EQ ZTISCSIT-EXPCD
        AND   REFNO EQ ZTISCSIT-REFNO
        AND   AMDSQ EQ ZTISCSIT-AMDSQ
        AND NOT ( BUKRS EQ ZTITCSK-BUKRS
        AND       ICSNO EQ ZTITCSK-ICSNO
        AND       ICSSQ EQ ZTISCSIT-ICSSQ ).
      EXIT.
    ENDSELECT.
  ELSEIF ZTITCSK-EXPGR EQ 'I' OR
         ZTITCSK-EXPGR EQ 'C'.
    SELECT *
      FROM ZTIVCS00 UP TO 1 ROWS
      WHERE   EXPGR EQ ZTITCSK-EXPGR
        AND   EXPCD EQ ZTISCSIT-EXPCD
        AND   REFNO EQ ZTISCSIT-REFNO
        AND   AMDSQ EQ ZTISCSIT-AMSEQ
        AND NOT ( BUKRS EQ ZTITCSK-BUKRS
        AND       ICSNO EQ ZTITCSK-ICSNO
        AND       ICSSQ EQ ZTISCSIT-ICSSQ ).
      EXIT.
    ENDSELECT.
  ELSE.
    SELECT *
      FROM ZTIVCS00 UP TO 1 ROWS
      WHERE   EXPGR EQ ZTITCSK-EXPGR
        AND   EXPCD EQ ZTISCSIT-EXPCD
        AND   REFNO EQ ZTISCSIT-REFNO
        AND NOT ( BUKRS EQ ZTITCSK-BUKRS
        AND       ICSNO EQ ZTITCSK-ICSNO
        AND       ICSSQ EQ ZTISCSIT-ICSSQ ).
      EXIT.
    ENDSELECT.
  ENDIF.
  IF SY-SUBRC EQ 0.
    IF ZTITCSK-EXPGR EQ 'T'.
      MESSAGE E880 WITH ZTISCSIT-EXPTX ZTIVCS00-ICSNO ZTIVCS00-ICSSQ.
    ELSE.
      MESSAGE W862 WITH ZTISCSIT-EXPTX ZTIVCS00-ICSNO ZTIVCS00-ICSSQ.
    ENDIF.
*    IF ztmicsh01-tbtkz EQ '1'.
*      ztmicsh01-tbtkz = '3'.
*    ELSEIF ztmicsh01-tbtkz EQ '2'.
*      ztmicsh01-tbtkz = '4'.
*    ENDIF.
  ENDIF.

ENDMODULE.                 " check_duplicate_scr2130  INPUT
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
*&      Module  user_command_2123  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_2123 INPUT.

ENDMODULE.                 " user_command_2123  INPUT
*&---------------------------------------------------------------------*
*&      Module  user_command_7000  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_7000 INPUT.

  DATA: GT_ROW_NO TYPE LVC_T_ROID WITH HEADER LINE.

  CASE OK-CODE.
    WHEN 'ZTICANCEL' OR 'ABBR' OR 'BACK' OR 'BU'.
      IF G_SCR7000_CONTAINER IS INITIAL.
        CALL METHOD G_SCR7000_GRID->FREE.
      ENDIF.
*      CLEAR: g_scr7000_grid.

      SET SCREEN 0.
      LEAVE SCREEN.
    WHEN 'ZTIDISPLAY1'.
      PERFORM DISPLAY_REF_DOCUMENT IN PROGRAM (G_REPID)
                                   USING ZTISCSIT-EXPGR
                                         ZTISCSIT-REFNO
                                         ZTISCSIT-AMDSQ.

    WHEN 'ZTIDISPLAY'.
      CALL METHOD G_SCR7000_GRID->GET_SELECTED_ROWS
        IMPORTING
          ET_ROW_NO = GT_ROW_NO[].

      IF GT_ROW_NO[] IS INITIAL.
        MESSAGE S909.
        EXIT.
      ENDIF.
      LOOP AT GT_ROW_NO.
        CHECK GT_ROW_NO-ROW_ID > 0.
        READ TABLE IT_ZTISCSDTY INDEX GT_ROW_NO-ROW_ID.
        IF SY-SUBRC EQ 0.
          PERFORM DISPLAY_PURCHASE_ORDER
                      USING  IT_ZTISCSDTY-EBELN IT_ZTISCSDTY-EBELP.

        ENDIF.
      ENDLOOP.
  ENDCASE.
*> F2 Funtion key Event시 해당 필드의 정보 display
  PERFORM  DOUBLE_CLICK_EVENT.
  CLEAR: OK-CODE.
ENDMODULE.                 " user_command_7000  INPUT
