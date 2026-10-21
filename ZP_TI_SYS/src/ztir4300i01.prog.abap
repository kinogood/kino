************************************************************************
* Title         :  ZTIR4300I01                                         *
*                                                                      *
* Description   : 수입신고의뢰  관리 PAI Include                       *
*                                                                      *
* Creation Date : 2004/08/23                                           *
*                                                                      *
* Author        : Sung Ho, Maeng                                       *
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

  MOVE-CORRESPONDING ZTISCRIT TO G_TC_2130_WA.

  IF G_TC_2130_WA-CCMNG GT G_TC_2130_WA-CCMNGL.
    CLEAR: G_MENGET.
    WRITE G_TC_2130_WA-CCMNGL TO G_MENGET(15) UNIT G_TC_2130_WA-MEINS.
    CONCATENATE G_MENGET G_TC_2130_WA-MEINS INTO G_MENGET.
    MESSAGE E434 WITH G_MENGET.
  ENDIF.

*> 정가 계산.
  CALL FUNCTION 'Z_TI_CALC_ITEM_AMOUNT'
    EXPORTING
      PEINH = G_TC_2130_WA-PEINH
      BPUMZ = G_TC_2130_WA-BPUMZ
      BPUMN = G_TC_2130_WA-BPUMN
      MENGE = G_TC_2130_WA-CCMNG
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
                                USING  ZTITCRK.
*> 아이템 정보 display
  PERFORM  DISPLAY_INFOMATION_BY_ITEMS USING   'TC_2130'
                                               'IT_TAB'
                                               'FLAG'
                                               ZTITCRK-LIFNR
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

*  CHECK: g_mode EQ c_charc OR
*         g_mode EQ c_charm.
*
*  IF ZTITRQK-reqty IS INITIAL.
*    PERFORM no_input(sapfmmex) USING 'ZTITRQK' 'REQTY'.
*  ELSE.
*    PERFORM check_domain_values USING 'ZTIREQTY'
*                                      ZTITRQK-reqty.
**> 수입의뢰 종류가 변경된 경우.
*    IF ZTIsscrcom-reqty NE ZTITRQK-reqty.
*      PERFORM get_domain_value_text
*                  USING
*                     'ZTIREQTY'
*                     ZTITRQK-reqty
*                     g_text32.
*      MESSAGE w112 WITH g_text32.
*      ZTIsscrcom-reqty = ZTITRQK-reqty.
*    ENDIF.
*  ENDIF.

ENDMODULE.                 " check_type_of_request  INPUT
*&---------------------------------------------------------------------*
*&      Module  pai_scr0100_check_input_fields  INPUT
*&---------------------------------------------------------------------*
MODULE PAI_SCR0100_CHECK_INPUT_FIELDS INPUT.
*> EXIT확인.
  PERFORM  CHECK_PROGRAM_EXIT_COMMAND.

*>>
  IF ZTISSCRCOM-IBLNO IS INITIAL AND
    ZTISSCRCOM-BLNUM IS INITIAL.
    MESSAGE E913.
  ENDIF.

  IF ZTISSCRCOM-IBLNO IS INITIAL.
    PERFORM  GET_BL_INT_NO_BY_BL_NUMBER  USING ZTISSCRCOM-BLNUM
                                             ZTISSCRCOM-IBLNO
                                             C_FALSE.
  ENDIF.

*> Set Initial fields
  PERFORM P3000_SET_DATA_OF_SCREEN.

  CLEAR: G_COUNT.

  IF NOT ZTISSCRCOM-IBLNO IS INITIAL.
    CLEAR: ZTISSCRCOM-IBLIT.
* b/l상태 확인.add.
    SELECT SINGLE * FROM ZTITBLK
     WHERE IBLNO EQ ZTISSCRCOM-IBLNO.
    IF ZTITBLK-CRLSE EQ 'B'.
      MESSAGE ID 'ZMTI00' TYPE 'E' NUMBER 321 WITH '수입신고'.
    ENDIF.

*{ 기능개선 283274 - 추가_S
*___B/L로 생성된 적하보험 존재 여부 점검
    PERFORM CHECK_INSURANCE_POLICY(ZTIR3000) USING    ZTITBLK-IBLNO
                                             CHANGING G_CHECK.

    IF G_CHECK = 'X'.
      IF SY-CALLD = 'X'.
        MESSAGE S997 DISPLAY LIKE 'E'
           WITH '적하보험이 생성되지 않았습니다.'
                'B/L 관리번호 :' ZTITBLK-IBLNO.

        LEAVE PROGRAM.
      ELSE.
        MESSAGE E997 WITH '적하보험이 생성되지 않았습니다.'
                          'B/L 관리번호 :' ZTITBLK-IBLNO.
      ENDIF.
    ENDIF.
*} 기능개선 283274 - 추가_E

    PERFORM GET_BL_DOCUMENT_DATA    TABLES IT_BL
                                    USING  ZTISSCRCOM-IBLNO
                                           ZTISSCRCOM-IBLIT
                                           C_ERROR
                                           C_ERROR.
  ENDIF.
  LOOP AT IT_BL.
    CLEAR: G_MODIFY, ZTIVBL00.
    DESCRIBE TABLE IT_TAB LINES G_COUNT_1.
    PERFORM  GET_AND_CHECK_BL_DATA   USING  IT_BL-IBLNO
                                            IT_BL-IBLIT
                                            G_MODIFY
                                            ZTIVBL00
                                            G_COUNT_1.
*> PO data Move
    PERFORM SET_REQUEST_OF_IMPORT_DATA TABLES IT_TAB
                                       USING  ZTIVBL00
                                              ZTITCRK
                                              ZTITCRP
                                              IT_BL.
  ENDLOOP.

** JS전선 회사코드 2007/04 KSH --------------------------------------
*> AUTHORIZATION_CHECK
  PERFORM P1102_AUTHORIZATION_CHECK USING ZTITCRK-BUKRS.
** JS전선 회사코드 2007/04 KSH --------------------------------------

*>아이템 기타 정보 Read.
  PERFORM SET_OTHERS_FIELDS_BY_ITEMS.
*>화면상의 Text를 Master Data 등에서 Read.
  PERFORM GET_OTHERS_TEXT_BY_MASTER_DATA.
**>Set bl data ---> cc data.
  PERFORM MOVE_BL_FIELDS_TO_CC_FIELDS.
************************************************************************

*>송장금액 체크.
  PERFORM CHECK_OPEN_AMOUNT.

*> Document History 조회.
  PERFORM GET_DOCUMENT_HISTORY   TABLES IT_DOCHIS
                                 USING  'BL'
                                        ZTITCRK-IBLNO
                                        '00'
                                        G_HISTORY.


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

  IF ZTITIG00-CCDCL IS INITIAL.
    G_TABSTRIP-PRESSED_TAB = C_TABSTRIP-TAB4.
  ENDIF.

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

  IF ZTISSCRCOM-ICRNO IS INITIAL.
    MESSAGE E913.
  ENDIF.


*  CLEAR: g_count.
*  IF ZTIsscrcom-reqno IS INITIAL.
*    PERFORM  get_request_no_by_po_number USING ZTIsscrcom-ebeln
*                                               ZTIsscrcom-reqno
*                                               ZTIsscrcom-amdsq
*                                               c_false.
*  ENDIF.
*
*  IF ZTIsscrcom-reqno IS INITIAL.
*    PERFORM  get_request_no_by_open_number USING ZTIsscrcom-opnno
*                                                 ZTIsscrcom-reqno
*                                                 ZTIsscrcom-amdsq
*                                                 c_false.
*  ENDIF.

  IF NOT ZTISSCRCOM-ICRNO IS INITIAL.
*> Ammend 생성일 경우.
    IF SY-TCODE EQ C_CREATE_A.
      SELECT MAX( ICCSQ )
        INTO ZTISSCRCOM-ICRSQ
        FROM ZTITCRK
       WHERE ICCNO EQ ZTISSCRCOM-ICRNO.

      SELECT SINGLE *
        FROM ZTITCCK
       WHERE ICCNO EQ ZTISSCRCOM-ICRNO
         AND ICCSQ EQ ZTISSCRCOM-ICRSQ.
      IF SY-SUBRC NE 0.
        MESSAGE E442 WITH ZTISSCRCOM-ICRNO ZTISSCRCOM-ICRSQ.
      ENDIF.
    ENDIF.

    CALL FUNCTION 'Z_TI_GET_CUSTOM_IMPORT_REQ'
      EXPORTING
        ICCNO     = ZTISSCRCOM-ICRNO
        ICCSQ     = ZTISSCRCOM-ICRSQ
      IMPORTING
        ZTITCRK   = ZTITCRK
      TABLES
        ZTITCRP   = IT_TAB
        ZTITCR1   = XZTITCR1
        ZTITCR2   = XZTITCR2
        ZTITCR3   = XZTITCR3
        ZTITCR5   = XZTITCR5 "기능개선 XXXXX
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
      IF ZTITCRK-BUKRS <> A_BUKRS.
        MESSAGE E998 WITH ZTITCRK-BUKRS  '권한이 없습니다!'..
      ENDIF.
    ENDIF.
** JS전선 회사코드 2007/04 KSH --------------------------------------

    G_TC_2211_ITAB[] = XZTITCR1[].

*> 변경 문서 관리를 위한 이전데이타를 Move.
    *ZTITCRK   = ZTITCRK.

    YZTITCR1[] = XZTITCR1[].
    YZTITCR2[] = XZTITCR2[].
    YZTITCR3[] = XZTITCR3[].
    YZTITCR5[] = XZTITCR5[]. "기능개선 XXXXX

*> 변경 문서 관리를 위한 이전데이타를 Move (Item Data).
    REFRESH: XZTITCRP, YZTITCRP.
    LOOP AT IT_TAB INTO G_TC_2130_WA.
      MOVE-CORRESPONDING G_TC_2130_WA TO : XZTITCRP,
                                           YZTITCRP.
      APPEND : XZTITCRP, YZTITCRP.
    ENDLOOP.

    REFRESH: G_TC_2211_ITAB, G_TC_2212_ITAB, G_TC_2212_1_ITAB.
    LOOP AT XZTITCR1.
      MOVE-CORRESPONDING XZTITCR1 TO G_TC_2211_WA.
      APPEND G_TC_2211_WA TO G_TC_2211_ITAB.
    ENDLOOP.

    LOOP AT XZTITCR2.
      MOVE-CORRESPONDING XZTITCR2 TO G_TC_2212_WA.
      APPEND G_TC_2212_WA TO G_TC_2212_ITAB.
    ENDLOOP.

    LOOP AT XZTITCR3.
      MOVE-CORRESPONDING XZTITCR3 TO G_TC_2212_1_WA.
      APPEND G_TC_2212_1_WA TO G_TC_2212_1_ITAB.
    ENDLOOP.

*-> 기능개선 XXXXX_요건확인(4G)
    LOOP AT XZTITCR5.
      MOVE-CORRESPONDING XZTITCR5 TO G_TC_2212_2_WA.
      APPEND G_TC_2212_2_WA TO G_TC_2212_2_ITAB.
    ENDLOOP.
*<- 기능개선 XXXXX

*>업무영역별 Status Check.
    PERFORM CHECK_DOCUMENT_STATUS.
*-----------------------------------------------------------------------
*> Ammend 생성일 경우.
*-----------------------------------------------------------------------
    IF SY-TCODE EQ C_CREATE_A.
      ZTITCRK-CFNST = C_CHARC.
*===> Calc 정정차수.
      SELECT MAX( ICCSQ )
        INTO ZTITCRK-ICCSQ
        FROM ZTITCRK
       WHERE ICCNO EQ ZTITCRK-ICCNO.
      ADD 1 TO ZTITCRK-ICCSQ.
*===> Set Default.
      ZTITCRK-CREAG1 = ZTITCRK-EBELN.
      IF NOT ZTITCRK-OPNNO IS INITIAL.
        CONCATENATE ZTITCRK-CREAG1 '-' ZTITCRK-OPNNO
               INTO ZTITCRK-CREAG1.
      ENDIF.
      CLEAR: ZTITCRK-DOCST, ZTITCRK-SNDST,
             ZTITCRK-UNAM,  ZTITCRK-UDAT,
             ZTITCRK-UTME,
             ZTITCRK-REQMT,
             ZTITCRK-ACCUN,
             ZTITCRK-ACCDT,
             ZTITCRK-ACCTM,
             ZTITCRK-SNDUN,
             ZTITCRK-SNDDT,
             ZTITCRK-SNDTM,
             ZTITCRK-APVUN,
             ZTITCRK-APVDT,
             ZTITCRK-APVTM.

      MOVE: ZTITCRK-ICCSQ  TO ZTITCRK-RECNO+19(2),
            SY-DATLO       TO ZTITCRK-CDCDT,
            SY-DATLO       TO ZTITCRK-CDADT,
            SY-DATLO       TO ZTITCRK-CDHDT,
            SY-UNAME       TO ZTITCRK-CNAM,
            SY-DATLO       TO ZTITCRK-CDAT,
            SY-TIMLO       TO ZTITCRK-CTME.
*> 통화.
      ZTITCRK-CPYATC = ZTITBLK-WAERS.
*> 결제금액.
      ZTITCRK-CPYAT  = ZTITBLK-IVAMT + ZTITBLK-RTCHG + ZTITBLK-PPAMT.
      IF ZTITCRK-CPYAT IS INITIAL.
        LOOP AT IT_TAB INTO G_TC_2130_WA.
          ZTITCRK-CPYAT = ZTITCRK-CPYAT + G_TC_2130_WA-REFWR.
        ENDLOOP.
      ENDIF.
*>관세청 고시환율을 구함.
      PERFORM  GET_CUSTOM_EXCHANGE_RATE.
*>란/행 Refresh
*-->050819 jp,park 주석처리
*      PERFORM  set_row_columns_refresh.
*>관세금액 등 계산.
      PERFORM  CALC_CUSTOMS_AMOUNT.
    ENDIF.

*>아이템 기타 정보 Read.
    PERFORM SET_OTHERS_FIELDS_BY_ITEMS.
*>화면상의 Text를 Master Data 등에서 Read.
    PERFORM GET_OTHERS_TEXT_BY_MASTER_DATA.
*>조회모드가 아닌 경우 Lock.
    IF G_MODE NE C_CHARS.
      PERFORM SET_CC_LOCK_OBJECT   USING ZTITCRK-ICCNO
                                         '00'
                                         '00000'
                                         C_LOCK
                                         C_ERROR
                                         G_MODIFY.
    ENDIF.

*> Document History 조회.
    PERFORM GET_DOCUMENT_HISTORY   TABLES IT_DOCHIS
                                   USING  G_DOCUMENT
                                          ZTITCRK-ICCNO
                                          ZTITCRK-ICCSQ
                                          G_HISTORY.

*> Cost Document History 조회.
    PERFORM GET_COST_DOCUMENT      TABLES IT_COSTDOC
                                   USING  G_DOCUMENT
                                          ZTITCRK-BUKRS
                                          ZTITCRK-ICCNO
                                          '00'
                                          G_HISTORY_COST.
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
*>  input module for tc 'TC_2211'. do not change this line!
*>  modify table
*&---------------------------------------------------------------------*
MODULE TC_2211_MODIFY INPUT.

  MOVE-CORRESPONDING ZTITCR1 TO G_TC_2211_WA.
  MODIFY G_TC_2211_ITAB  FROM  G_TC_2211_WA
                         INDEX TC_2211-CURRENT_LINE.
  IF SY-SUBRC NE 0.
    APPEND G_TC_2211_WA TO G_TC_2211_ITAB.
  ENDIF.
*
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

  IF OK_CODE EQ 'LINE_SELECT'.
*> 기존 데이타 삭제.
    IF NOT ZTISCR01-CSSEQ IS INITIAL.
      DELETE G_TC_2211_ITAB   WHERE CSSEQ = ZTISCR01-CSSEQ.
      DELETE G_TC_2212_ITAB   WHERE CSSEQ = ZTISCR01-CSSEQ.
      DELETE G_TC_2212_1_ITAB WHERE CSSEQ = ZTISCR01-CSSEQ.
      DELETE G_TC_2212_2_ITAB WHERE CSSEQ = ZTISCR01-CSSEQ. "기능개선 XXXXX
*> 신규데이타 Insert.
      MOVE-CORRESPONDING ZTISCR01 TO G_TC_2211_WA.
      APPEND G_TC_2211_WA TO G_TC_2211_ITAB.

      LOOP AT G_TC_2212_TMP   INTO G_TC_2212_WA.
        APPEND G_TC_2212_WA TO G_TC_2212_ITAB.
      ENDLOOP.

      LOOP AT G_TC_2212_1_TMP INTO G_TC_2212_1_WA.
        APPEND G_TC_2212_1_WA TO G_TC_2212_1_ITAB.
      ENDLOOP.
*-> 기능개선 XXXXX_요건확인서(4G) 신규데이터 INSERT
      LOOP AT G_TC_2212_2_TMP INTO G_TC_2212_2_WA.
        APPEND G_TC_2212_2_WA TO G_TC_2212_2_ITAB.
      ENDLOOP.
*<- 기능개선 XXXXX
      SORT G_TC_2211_ITAB BY CSSEQ.
    ENDIF.
*> Temp Table refresh.
    CLEAR: G_TC_2212_COPIED.
    REFRESH CONTROL 'TC_2212'   FROM SCREEN '2212'.

    CLEAR: G_TC_2212_1_COPIED.
    REFRESH CONTROL 'TC_2212_1' FROM SCREEN '2212'.

*-> 기능개선 XXXXX_요건확인서(4G) 신규데이터 INSERT
    CLEAR: G_TC_2212_2_COPIED.
    REFRESH CONTROL 'TC_2212_2' FROM SCREEN '2212'.
*<- 기능개선 XXXXX

    REFRESH: G_TC_2212_TMP, G_TC_2212_1_TMP,
             G_TC_2212_2_TMP. "기능개선 XXXXX
    CLEAR: ZTISCR01, G_CSSEQ.

    GET CURSOR LINE G_FINDLINE.
    IF SY-SUBRC EQ 0.
      G_FINDLINE = G_FINDLINE + TC_2211-TOP_LINE - 1.
      READ TABLE G_TC_2211_ITAB INTO G_TC_2211_WA INDEX G_FINDLINE.
      IF SY-SUBRC EQ 0.
        G_CSSEQ = G_TC_2211_WA-CSSEQ.
        MOVE-CORRESPONDING G_TC_2211_WA TO ZTISCR01.
        LOOP AT G_TC_2212_ITAB INTO G_TC_2212_WA
                               WHERE CSSEQ EQ ZTISCR01-CSSEQ.
          APPEND G_TC_2212_WA TO G_TC_2212_TMP.
        ENDLOOP.
        LOOP AT G_TC_2212_1_ITAB INTO G_TC_2212_1_WA
                               WHERE CSSEQ EQ ZTISCR01-CSSEQ.
          APPEND G_TC_2212_1_WA TO G_TC_2212_1_TMP.
        ENDLOOP.
*-> 기능개선 XXXXX_요건확인서(4G) 신규데이터 INSERT
        LOOP AT G_TC_2212_2_ITAB INTO G_TC_2212_2_WA
                               WHERE CSSEQ EQ ZTISCR01-CSSEQ.
          APPEND G_TC_2212_2_WA TO G_TC_2212_2_TMP.
        ENDLOOP.
*<- 기능개선 XXXXX
      ENDIF.
    ENDIF.
    SORT G_TC_2211_ITAB BY CSSEQ.
  ENDIF.

ENDMODULE.                    "TC_2211_user_command INPUT
*&---------------------------------------------------------------------*
*>  input module for tc 'TC_2212'. do not change this line!
*>  modify table
*&---------------------------------------------------------------------*
MODULE TC_2212_MODIFY INPUT.
  MOVE-CORRESPONDING ZTITCR2 TO G_TC_2212_WA.
  MODIFY G_TC_2212_TMP
    FROM G_TC_2212_WA
    INDEX TC_2212-CURRENT_LINE.
  IF SY-SUBRC NE 0.
    APPEND G_TC_2212_WA TO G_TC_2212_TMP.
  ENDIF.

ENDMODULE.                    "TC_2212_modify INPUT
*&---------------------------------------------------------------------*
*>  input module for tc 'TC_2212_1'. do not change this line!
*>  modify table
*&---------------------------------------------------------------------*
MODULE TC_2212_1_MODIFY INPUT.

  MOVE-CORRESPONDING ZTITCR3 TO G_TC_2212_1_WA.

*  if tc_2212_1-current_line gt 0.
  MODIFY G_TC_2212_1_TMP
    FROM G_TC_2212_1_WA
    INDEX TC_2212_1-CURRENT_LINE.
*  endif.
  IF SY-SUBRC NE 0.
    APPEND G_TC_2212_1_WA TO G_TC_2212_1_TMP.
  ENDIF.

ENDMODULE.                    "TC_2212_modify INPUT
*&---------------------------------------------------------------------*
*> input module for tc 'TC_2212'. do not change this line!
*> mark table
*&---------------------------------------------------------------------*
MODULE TC_2212_MARK INPUT.

  IF TC_2212-LINE_SEL_MODE = 1 AND
     G_TC_2212_WA-FLAG = 'X'.
    LOOP AT G_TC_2212_TMP INTO G_TC_2212_WA
      WHERE FLAG = 'X'.
      G_TC_2212_WA-FLAG = ''.
      MODIFY G_TC_2212_TMP
        FROM G_TC_2212_WA
        TRANSPORTING FLAG.
    ENDLOOP.
    G_TC_2212_WA-FLAG = 'X'.
  ENDIF.
  MODIFY G_TC_2212_TMP
    FROM G_TC_2212_WA
    INDEX TC_2212-CURRENT_LINE
    TRANSPORTING FLAG.

ENDMODULE.                    "TC_2212_mark INPUT
*&---------------------------------------------------------------------*
*> input module for tc 'TC_2212_1'. do not change this line!
*> mark table
*&---------------------------------------------------------------------*
MODULE TC_2212_1_MARK INPUT.

  IF TC_2212_1-LINE_SEL_MODE = 1 AND
     G_TC_2212_1_WA-FLAG = 'X'.
    LOOP AT G_TC_2212_1_TMP INTO G_TC_2212_1_WA
      WHERE FLAG = 'X'.
      G_TC_2212_WA-FLAG = ''.
      MODIFY G_TC_2212_1_TMP
        FROM G_TC_2212_1_WA
        TRANSPORTING FLAG.
    ENDLOOP.
    G_TC_2212_1_WA-FLAG = 'X'.
  ENDIF.
  MODIFY G_TC_2212_1_TMP
    FROM G_TC_2212_1_WA
    INDEX TC_2212_1-CURRENT_LINE
    TRANSPORTING FLAG.

ENDMODULE.                    "TC_2212_1_mark INPUT


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

*> 기존 데이타 삭제.
  CHECK NOT ZTISCR01-CSSEQ IS INITIAL.

  DELETE G_TC_2211_ITAB   WHERE CSSEQ = ZTISCR01-CSSEQ.
  DELETE G_TC_2212_ITAB   WHERE CSSEQ = ZTISCR01-CSSEQ.
  DELETE G_TC_2212_1_ITAB WHERE CSSEQ = ZTISCR01-CSSEQ.
  DELETE G_TC_2212_2_ITAB WHERE CSSEQ = ZTISCR01-CSSEQ. "기능개선 XXXXX

  DESCRIBE TABLE G_TC_2212_TMP   LINES ZTISCR01-CSSZN.
  DESCRIBE TABLE G_TC_2212_1_TMP LINES ZTISCR01-CSNDN.

  MOVE-CORRESPONDING ZTISCR01 TO G_TC_2211_WA. "란사항
  APPEND G_TC_2211_WA TO G_TC_2211_ITAB.

*> 신규데이타 Insert.
  LOOP AT G_TC_2212_TMP   INTO G_TC_2212_WA. "규격
    APPEND G_TC_2212_WA TO G_TC_2212_ITAB.
  ENDLOOP.

  CLEAR: G_CDSEQ.
  LOOP AT G_TC_2212_1_TMP INTO G_TC_2212_1_WA. "요건확인(3G)
    G_TABIX = SY-TABIX.
    ADD 1 TO G_CDSEQ.
    G_TC_2212_1_WA-CSSEQ = ZTISCR01-CSSEQ.
    G_TC_2212_1_WA-CDSEQ = G_CDSEQ.
    MODIFY G_TC_2212_1_TMP FROM G_TC_2212_1_WA INDEX G_TABIX.
  ENDLOOP.

  LOOP AT G_TC_2212_1_TMP INTO G_TC_2212_1_WA.
    APPEND G_TC_2212_1_WA TO G_TC_2212_1_ITAB.
  ENDLOOP.

*-> 기능개선 XXXXX_요건확인서(4G) 신규데이터 INSERT
  CLEAR G_Z9050.
  SORT G_TC_2212_2_TMP BY ICCNO ICCSQ CSSEQ CMSEQ.

  LOOP AT G_TC_2212_2_TMP INTO G_TC_2212_2_WA. "요건확인(4G).
    ON CHANGE OF G_TC_2212_2_WA-CMSEQ.
      CLEAR G_Z9050.
    ENDON.
    G_TABIX = SY-TABIX.
    ADD 1 TO G_Z9050.
    IF G_Z9050 > 8.
      MESSAGE '동일 규격번호에 대해 8개를 초과하여 요건을 입력할 수 없습니다.'
        TYPE 'S' DISPLAY LIKE 'E'.
    ENDIF.
    G_TC_2212_2_WA-CSSEQ = ZTISCR01-CSSEQ. "란번호
    G_TC_2212_2_WA-Z9050 = G_Z9050.
    MODIFY G_TC_2212_2_TMP FROM G_TC_2212_2_WA INDEX G_TABIX.
  ENDLOOP.

  LOOP AT G_TC_2212_2_TMP INTO G_TC_2212_2_WA.
    APPEND G_TC_2212_2_WA TO G_TC_2212_2_ITAB.
  ENDLOOP.
*<- 기능개선 XXXXX

  SORT G_TC_2211_ITAB BY CSSEQ.

ENDMODULE.                    "TC_2212_user_command INPUT

*&---------------------------------------------------------------------*
*&      Form  check_document_status
*&---------------------------------------------------------------------*
*       업무영역별 Status Check.
*----------------------------------------------------------------------*
FORM CHECK_DOCUMENT_STATUS .

  DATA: L_DDTEXT LIKE G_DDTEXT.

*> 문서상태 Fixed value read.
  PERFORM  DDIC_DOMAIN_VALUE_TEXT_READ USING 'ZTIDOCST'
                                             SY-LANGU
                                             ZTITCRK-DOCST
                                             G_DDTEXT
                                             C_SUCCESS.
  L_DDTEXT = G_DDTEXT.

*> Ammend 생성일 경우.
  IF SY-TCODE EQ C_CREATE_A.
    IF ZTITCRK-DOCST NE C_CHARO.
      MESSAGE E114 WITH ZTITCRK-ICCNO ZTITCRK-ICCSQ G_DDTEXT.
      EXIT.
    ENDIF.
  ELSE.
*> Status check.
    CASE ZTITCRK-DOCST.
      WHEN SPACE.  ">의뢰대상.
        IF G_MODE EQ C_CHARA OR
           G_MODE EQ C_CHARY OR
           G_MODE EQ C_CHARO.
          MESSAGE S919 WITH G_DDTEXT.
        ENDIF.
      WHEN 'Y'.    ">신청.
        IF G_MODE EQ C_CHARM OR
           G_MODE EQ C_CHARA.
          MESSAGE W921 WITH G_DDTEXT.
        ELSEIF G_MODE EQ C_CHARD.
          MESSAGE W921 WITH G_DDTEXT.
        ENDIF.

*        IF g_mode EQ c_chary OR g_mode EQ c_charo.
*          IF NOT ztitip1-sndst IS INITIAL.
**> EDI 송수신 상태 Fixed value read.
*            PERFORM  ddic_domain_value_text_read
*                                        USING 'ZTISNDST'
*                                               sy-langu
*                                               ztitip1-sndst
*                                               g_ddtext
*                                               c_success.
*            IF g_mode EQ c_chary.
*              IF ztitip1-sndst EQ c_charw.
*                MESSAGE e919 WITH g_ddtext.
*              ELSE.
*                MESSAGE e919 WITH g_ddtext.
*              ENDIF.
*            ENDIF.
*            IF g_mode EQ c_charo.
*              MESSAGE w920 WITH g_ddtext.
*            ENDIF.
*          ELSE.
*            IF g_mode EQ c_charo OR
*               g_mode EQ c_chary.
*              MESSAGE w920 WITH g_ddtext.
*            ELSE.
*              MESSAGE e919 WITH g_ddtext.
*            ENDIF.
*          ENDIF.
*        ENDIF.
      WHEN 'O'.    ">개설완료.
        IF G_MODE EQ C_CHARM OR G_MODE EQ C_CHARD OR
           G_MODE EQ C_CHARA OR G_MODE EQ C_CHARY.
          MESSAGE E919 WITH G_DDTEXT.
        ENDIF.
      WHEN OTHERS.
    ENDCASE.
  ENDIF.

  MESSAGE S922 WITH L_DDTEXT.

ENDFORM.                    " check_document_status
*&---------------------------------------------------------------------*
*&      Module  make_ztitcr1_data  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE MAKE_ZTITCR1_DATA INPUT.

  CLEAR G_COUNT.

  REFRESH XZTITCR1.

  LOOP AT G_TC_2211_ITAB INTO G_TC_2211_WA.
    ADD 1 TO G_COUNT.
    G_TC_2211_WA-CSSEQ = G_COUNT.
    MODIFY G_TC_2211_ITAB FROM G_TC_2211_WA.

    MOVE-CORRESPONDING G_TC_2211_WA TO XZTITCR1.
    APPEND XZTITCR1.
  ENDLOOP.


  IF SY-UCOMM EQ 'LINE_SELECT'.
    CLEAR G_CSSEQ.

    GET CURSOR LINE G_FINDLINE.
    IF SY-SUBRC EQ 0.
*        GET CURSOR FIELD g_fieldname.
      G_FINDLINE = G_FINDLINE + TC_2211-TOP_LINE - 1.
      READ TABLE G_TC_2211_ITAB INTO  G_TC_2211_WA
                                INDEX G_FINDLINE.
      IF SY-SUBRC NE 0.
        EXIT.
      ENDIF.
    ENDIF.
    G_CSSEQ = G_TC_2211_WA-CSSEQ.

*란 사항.
    READ TABLE G_TC_2211_ITAB INTO G_TC_2211_WA
                              WITH KEY CSSEQ = G_CSSEQ.
    MOVE-CORRESPONDING G_TC_2211_WA TO ZTISCR01.
  ENDIF.

ENDMODULE.                 " make_ztitcr1_data  INPUT
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
*&      Module  user_command_2125  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_2125 INPUT.
**> F2 Funtion key Event시 해당 필드의 정보 display
*  PERFORM  double_click_event.
ENDMODULE.                 " user_command_2125  INPUT

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
*&      Module  check_cc_number_chainged  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE CHECK_CC_NUMBER_CHAINGED INPUT.

  CLEAR: G_CCNUM_CHK1, G_CCNUM_CHK2.

ENDMODULE.                 " check_cc_number_chainged  INPUT
*&---------------------------------------------------------------------*
*&      Module  check_cc_number  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE CHECK_CC_NUMBER INPUT.

  CHECK : G_MODE EQ C_CHARC OR
          G_MODE EQ C_CHARM.

  IF G_CCNUM_CHK1 IS INITIAL.
    IF ZTITCRK-CDRNO IS INITIAL.
      PERFORM NO_INPUT_CHECK USING 'ZTITCRK' 'CDRNO' C_ERROR.
      G_CCNUM_CHK1 = C_TRUE.
    ENDIF.
  ENDIF.

  IF G_CCNUM_CHK2 IS INITIAL.
    IF NOT ZTITCRK-CDRNO IS INITIAL.
      SELECT CDRNO
        INTO G_CDRNO
        FROM ZTITCRK UP TO 1 ROWS
       WHERE CDRNO EQ ZTITCRK-CDRNO
         AND ICCNO NE ZTITCRK-ICCNO.
      ENDSELECT.

      IF SY-SUBRC EQ 0.
        MESSAGE E431 WITH ZTITCRK-CDRNO.
        G_CCNUM_CHK2 = C_TRUE.
      ENDIF.
    ENDIF.
  ENDIF.

ENDMODULE.                 " check_cc_number  INPUT
*&---------------------------------------------------------------------*
*&      Module  user_command_2100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_2100 INPUT.

ENDMODULE.                 " user_command_2100  INPUT
*&---------------------------------------------------------------------*
*&      Module  make_zmTtccK_data  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE MAKE_ZTITCRK_DATA INPUT.

ENDMODULE.                 " make_ZTITCRK_data  INPUT
*&---------------------------------------------------------------------*
*&      Module  check_input_value_scr2121  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE CHECK_INPUT_VALUE_SCR2121 INPUT.

  CHECK : G_MODE EQ C_CHARC OR
          G_MODE EQ C_CHARM.

  IF ZTITCRK-CBLNO IS INITIAL.
    PERFORM NO_INPUT_CHECK USING 'ZTITCRK' 'CBLNO' C_ERROR.
  ENDIF.

*-----> LS전선 요청으로 필수항목 제외.by MSH,050510
*  IF ztitcrk-cdcor IS INITIAL.
*    PERFORM no_input_check USING 'ZTITCRK' 'CDCOR' c_error.
*  ENDIF.
*-----> End of Modification.

  IF ZTITCRK-CPYME IS INITIAL.
    PERFORM NO_INPUT_CHECK USING 'ZTITCRK' 'CPYME' C_ERROR.
  ENDIF.

  IF ZTITCRK-CPYAT IS INITIAL.
    PERFORM NO_INPUT_CHECK USING 'ZTITCRK' 'CPYAT' C_ERROR.
  ENDIF.

*--> [가온] 관세사 필수 체크 X
**** 원본 BK - START
*  IF ztitcrk-state IS INITIAL.
*    PERFORM no_input_check USING 'ZTITCRK' 'STATE' c_error.
*  ENDIF.
**** 원본 BK - END
  IF ZTITCRK-BUKRS = '6000'.
  ELSE.
    IF ZTITCRK-STATE IS INITIAL.
      PERFORM NO_INPUT_CHECK USING 'ZTITCRK' 'STATE' C_ERROR.
    ENDIF.
  ENDIF.
*<-- [가온] 관세사 필수 체크 X

  IF ZTITCRK-CINCO IS INITIAL.
    PERFORM NO_INPUT_CHECK USING 'ZTITCRK' 'CINCO' C_ERROR.
  ENDIF.

  IF ZTITCRK-CPYAT IS INITIAL.
    PERFORM NO_INPUT_CHECK USING 'ZTITCRK' 'CPYAT' C_ERROR.
  ENDIF.

  IF ZTITCRK-CFNST IS INITIAL.
    PERFORM NO_INPUT_CHECK USING 'ZTITCRK' 'CFNST' C_ERROR.
  ENDIF.
*  IF ztitcrk-cpyrt IS INITIAL.
*    PERFORM no_input_check USING 'ZTITCRK' 'CPYRT' c_error.
*  ENDIF.
*


*    IF ZTITCRK-CDRNO IS INITIAL.
*      PERFORM no_input_check USING 'ZTITCRK' 'CDRNO' c_error.
*      g_ccnum_chk1 = c_true.
*    ENDIF.
*

ENDMODULE.                 " check_input_value_scr2121  INPUT
*&---------------------------------------------------------------------*
*&      Module  user_command_2111  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_2111 INPUT.
*> F2 Funtion key Event시 해당 필드의 정보 display
  PERFORM  DOUBLE_CLICK_EVENT.
ENDMODULE.                 " user_command_2111  INPUT
*&---------------------------------------------------------------------*
*&      Module  TC_2212_2_MODIFY  INPUT
*&---------------------------------------------------------------------*
*       기능개선 XXXXX
*----------------------------------------------------------------------*
MODULE TC_2212_2_MODIFY INPUT.

  MOVE-CORRESPONDING ZTITCR5 TO G_TC_2212_2_WA.

*  if tc_2212_2-current_line gt 0.
  MODIFY G_TC_2212_2_TMP
    FROM G_TC_2212_2_WA
    INDEX TC_2212_2-CURRENT_LINE.
*  endif.
  IF SY-SUBRC NE 0.
    APPEND G_TC_2212_2_WA TO G_TC_2212_2_TMP.
  ENDIF.

ENDMODULE.                 " TC_2212_2_MODIFY  INPUT
*&---------------------------------------------------------------------*
*&      Module  TC_2212_2_MARK  INPUT
*&---------------------------------------------------------------------*
*       기능개선 XXXXX
*----------------------------------------------------------------------*
MODULE TC_2212_2_MARK INPUT.

  IF TC_2212_2-LINE_SEL_MODE = 1 AND
     G_TC_2212_2_WA-FLAG = 'X'.
    LOOP AT G_TC_2212_2_TMP INTO G_TC_2212_2_WA
      WHERE FLAG = 'X'.
      G_TC_2212_WA-FLAG = ''.
      MODIFY G_TC_2212_2_TMP
        FROM G_TC_2212_2_WA
        TRANSPORTING FLAG.
    ENDLOOP.
    G_TC_2212_2_WA-FLAG = 'X'.
  ENDIF.
  MODIFY G_TC_2212_2_TMP
    FROM G_TC_2212_2_WA
    INDEX TC_2212_2-CURRENT_LINE
    TRANSPORTING FLAG.

ENDMODULE.                 " TC_2212_2_MARK  INPUT
