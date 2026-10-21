************************************************************************
* Title         :  ZTIR1000I01                                         *
*                                                                      *
* Description   : 적하부보 관리 PAI Include                            *
*                                                                      *
* Creation Date : 2003/08/20                                           *
*                                                                      *
* Author        : Seung Jun, Lee                                       *
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
*&      Module  pai_scr0100_check_input_fields  INPUT
*&---------------------------------------------------------------------*
MODULE PAI_SCR0100_CHECK_INPUT_FIELDS INPUT.
*> EXIT확인.
  PERFORM  CHECK_PROGRAM_EXIT_COMMAND.

*> call이 되었을 경우.
  IF SY-TCODE EQ C_DUE_LIST_PO OR
     G_TCODE1 EQ C_DUE_LIST_PO.
    MOVE: 'ZTICOPY' TO OK_CODE,
          'ZTICOPY' TO SY-UCOMM.
  ENDIF.

*> Input fields check
  IF NOT OK_CODE EQ 'ZTICOPY'.
    IF ZTISSCRCOM-EBELN IS INITIAL AND
       ZTISSCRCOM-REQNO IS INITIAL AND
       ZTISSCRCOM-IBLNO IS INITIAL AND       "기능개선 283274 - 추가
       ZTISSCRCOM-OPNNO IS INITIAL.
      MESSAGE E913.
    ENDIF.
  ENDIF.

*> 구매오더 Select.
  IF NOT OK_CODE EQ 'ZTICOPY'.
*{ 기능개선 283274 - 추가_S
    IF G_TCODE1 = C_CREATE_BL.
      PERFORM P3000_SET_DATA_OF_SCREEN.

      CLEAR: G_COUNT.

      CALL FUNCTION 'Z_TI_GET_BILL_OF_LADING'
        EXPORTING
          IBLNO     = ZTISSCRCOM-IBLNO
        IMPORTING
          ZTITBLK   = ZTITBLK
        TABLES
          ZTITBLP   = IT_ZTITBLP
        EXCEPTIONS
          NOT_FOUND = 1
          OTHERS    = 2.

*> 해당 아이템 Internal table Move.
      REFRESH: IT_TAB, G_TC_2210_ITAB.
      DATA: LV_CHK(1).
      CLEAR LV_CHK.

      LOOP AT IT_ZTITBLP.

        PERFORM CHECK_BL_ITEM USING LV_CHK.
        IF LV_CHK = 'X'.
          CONTINUE.
        ENDIF.

        IF ZTISSCRCOM-REQNO IS INITIAL.
          ZTISSCRCOM-REQNO = IT_ZTITBLP-REQNO.
        ENDIF.

        MOVE-CORRESPONDING IT_ZTITBLP TO G_TC_2130_WA.

        G_TC_2130_WA-RQMNG = IT_ZTITBLP-BLMNG.

        APPEND G_TC_2130_WA TO IT_TAB.
      ENDLOOP.

      IF IT_TAB[] IS INITIAL.
        MESSAGE E997 WITH '적하보험이 생성된 건입니다'.
      ENDIF.
      CLEAR :  ZTITRQK, ZTITRQS.

      IF NOT ZTISSCRCOM-REQNO IS INITIAL.
*> 첫번째 B/L 품목의 수입요청번호 최종차수
        SELECT MAX( AMDSQ )
          INTO ZTISSCRCOM-AMDSQ
          FROM ZTITRQS
         WHERE REQNO EQ ZTISSCRCOM-REQNO.

        CALL FUNCTION 'Z_TI_GET_REQUEST_OF_IMPORT'
          EXPORTING
            REQNO     = ZTISSCRCOM-REQNO
            AMDSQ     = ZTISSCRCOM-AMDSQ
          IMPORTING
            ZTITRQK   = ZTITRQK
            ZTITRQS   = ZTITRQS
          TABLES
            ZTITRQP   = IT_ZTISRQIT
          EXCEPTIONS
            NOT_FOUND = 1
            OTHERS    = 2.
        IF SY-SUBRC <> 0.
          MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
                  WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
        ENDIF.
      ENDIF.

*>B/L의 종류/상태를 검증.
      PERFORM CHECK_BILL_OF_LADING.
*>화면상의 Text를 Master Data 등에서 Read.
      MOVE-CORRESPONDING ZTITBLK TO ZTITIP1.
*>화면상의 Text를 Master Data 등에서 Read.
      PERFORM GET_OTHERS_TEXT_BY_MASTER_DATA.
*>B/L 품목 필드 --> 적하보험 테이블.
      PERFORM MOVE_BL_ITEM_TO_ZTITIP1.
    ELSE.
*} 기능개선 283274 - 추가_E
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
*> Get 최종차수.
        SELECT MAX( AMDSQ )
          INTO ZTISSCRCOM-AMDSQ
          FROM ZTITRQS
         WHERE REQNO EQ ZTISSCRCOM-REQNO.

        CALL FUNCTION 'Z_TI_GET_REQUEST_OF_IMPORT'
          EXPORTING
            REQNO     = ZTISSCRCOM-REQNO
            AMDSQ     = ZTISSCRCOM-AMDSQ
          IMPORTING
            ZTITRQK   = ZTITRQK
            ZTITRQS   = ZTITRQS
          TABLES
            ZTITRQP   = IT_ZTISRQIT
          EXCEPTIONS
            NOT_FOUND = 1
            OTHERS    = 2.
        IF SY-SUBRC <> 0.
          MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
                  WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
        ENDIF.
      ENDIF.

*> 해당 아이템 Internal table Move.
      REFRESH: IT_TAB, G_TC_2210_ITAB.
      LOOP AT IT_ZTISRQIT.
        MOVE-CORRESPONDING IT_ZTISRQIT TO G_TC_2130_WA.
        APPEND G_TC_2130_WA TO IT_TAB.
      ENDLOOP.

*>수입의뢰문서의 종류/상태를 검증.
      PERFORM CHECK_REQUEST_OF_IMPORT.
*>화면상의 Text를 Master Data 등에서 Read.
      MOVE-CORRESPONDING ZTITRQK TO ZTITIP1.
*>화면상의 Text를 Master Data 등에서 Read.
      PERFORM GET_OTHERS_TEXT_BY_MASTER_DATA.
*>수입의뢰 상태 필드 --> 적하보험 테이블.
      PERFORM MOVE_REQ_FIELDS_TO_ZTITIP1.
    ENDIF.
  ELSE.
    PERFORM P3000_SET_DATA_OF_SCREEN.

    IF SY-CALLD EQ C_TRUE AND
       SY-TCODE EQ C_DUE_LIST_PO.
      PERFORM  CHECK_INSURANCE_DOC_BY_EBELN.
      OK_CODE_POPUP = 'FCOPY'.
    ELSE.
      CALL SCREEN 7000 STARTING AT 01 01
                        ENDING  AT 32 04 .

      IF OK_CODE_POPUP NE 'FCOPY'.
        EXIT.
      ENDIF.
    ENDIF.


*  >화면상의 Text를 Master Data 등에서 Read.
    MOVE-CORRESPONDING EKKO TO ZTITIP1.
*  >화면상의 Text를 Master Data 등에서 Read.
    PERFORM GET_OTHERS_TEXT_BY_MASTER_DATA.
*  > 수입의뢰 상태 필드 --> 적하보험 테이블.
    PERFORM MOVE_EKKO_FIELDS_TO_ZTITIP1.
  ENDIF.

** JS전선 회사코드 2007/04 KSH --------------------------------------
*> AUTHORIZATION_CHECK
*  PERFORM p1102_authorization_check USING ztitip1-bukrs.
** JS전선 회사코드 2007/04 KSH --------------------------------------

*  >아이템 기타 정보 Read.
  PERFORM SET_OTHERS_FIELDS_BY_ITEMS.

ENDMODULE.                 " pai_scr0100_check_input_fields  INPUT
*&---------------------------------------------------------------------*
*&      Module  user_command_scr0100  INPUT
*&---------------------------------------------------------------------*
MODULE USER_COMMAND_SCR0100 INPUT.

  CHECK : ( OK_CODE       EQ 'ZTICOPY' AND
            OK_CODE_POPUP EQ 'FCOPY' ) OR
            OK_CODE       EQ 'ZTIENTER'.

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

  IF ZTISSCRCOM-IIPNO IS INITIAL.
    MESSAGE E913.
  ENDIF.

  CLEAR: G_COUNT.

  IF NOT ZTISSCRCOM-IIPNO IS INITIAL.
    IF SY-TCODE EQ C_CREATE_A.
      SELECT MAX( AMDSQ )
        INTO ZTISSCRCOM-AMSEQ
        FROM ZTITIP1
       WHERE IIPNO EQ ZTISSCRCOM-IIPNO.
    ENDIF.

    CALL FUNCTION 'Z_TI_GET_INSURANCE_POL'
      EXPORTING
        IIPNO     = ZTISSCRCOM-IIPNO
        AMDSQ     = ZTISSCRCOM-AMSEQ
      IMPORTING
        ZTITIP1   = ZTITIP1
        ZTITIP3   = ZTITIP3
        ZTITIP4   = ZTITIP4
        ZTITRQK   = ZTITRQK
      TABLES
        ZTITRQP   = IT_TAB
        ZTITIP2   = G_TC_2210_ITAB
      EXCEPTIONS
        NOT_FOUND = 1
        OTHERS    = 2.
    IF SY-SUBRC <> 0.
      MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
              WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    ENDIF.

** JS전선 회사코드 2007/04 KSH --------------------------------------
*> authorization
*    PERFORM get_authorization_bukrs.
*    IF l_yn NE 'A'.
*    IF ztitip1-bukrs <> a_bukrs.
*      MESSAGE e998 WITH ztitip1-bukrs  '권한이 없습니다!'..
*    ENDIF.
*    ENDIF.
** JS전선 회사코드 2007/04 KSH --------------------------------------

*> 변경 문서 관리를 위한 이전데이타를 Move.
     *ZTITIP1   = ZTITIP1.
     *ZTITIP3   = ZTITIP3.
     *ZTITIP4   = ZTITIP4.

    REFRESH: YZTITIP2, XZTITIP2.
    LOOP AT G_TC_2210_ITAB INTO G_TC_2210_WA.
      MOVE-CORRESPONDING G_TC_2210_WA TO XZTITIP2.
      APPEND XZTITIP2.
    ENDLOOP.
    YZTITIP2[] = XZTITIP2[].

*>업무영역별 Status Check.
    PERFORM CHECK_DOCUMENT_STATUS.

*>조회모드가 아닌 경우 Lock.
    IF G_MODE NE C_CHARS.
      PERFORM SET_IP_LOCK_OBJECT   USING ZTITIP1-IIPNO
                                         ZTITIP1-AMDSQ
                                         C_LOCK
                                         C_ERROR
                                         G_MODIFY.
    ENDIF.
*> 구상관리일 경우.
    IF G_MODE EQ C_CHAR0.
      ZTITIP1-DAMAG = C_TRUE.
    ENDIF.
  ELSE.
    MESSAGE E902.
  ENDIF.

*> Amend 생성시.g_tc_2210_itab_o
  IF SY-TCODE EQ C_CREATE_A.
    PERFORM  GET_OLD_IP_TABLES  USING ZTITIP1-IIPNO
                                      ZTITIP1-AMDSQ.

    ZTITIP1-AMDSQ = ZTITIP1-AMDSQ + 1.
    CLEAR: ZTITIP1-TAPDT,
           ZTITIP1-IFTX1,  ZTITIP1-IFTX2,  ZTITIP1-IFTX3,
           ZTITIP1-IFTX4,  ZTITIP1-IFTX5,
*           ZTITIP1-ISPNO,  ZTITIP1-ICPNM,  ZTITIP1-ICPPR,
*           ZTITIP1-ICPID,
*           ZTITIP1-itoat,  ZTITIP1-itoatc,
*           ZTITIP1-icaat,  ZTITIP1-icaatc, ZTITIP1-iduat,
*           ZTITIP1-iduatc,
*           ZTITIP1-iisdt,
*           ZTITIP1-IISPL,
*           ZTITIP1-ipdte1, ZTITIP1-ipdte2, ZTITIP1-ipdte3,
*           ZTITIP1-ipdte4, ZTITIP1-ipdte5,
           ZTITIP1-IISNU,
           ZTITIP1-ISCRN,  ZTITIP1-ISVLN,  ZTITIP1-IDMCD,
           ZTITIP1-IDMNM,  ZTITIP1-IBACU,  ZTITIP1-IAMCU,
*           ZTITIP1-iajrt,
*           ZTITIP4-IMSNM1, ZTITIP4-IMSNM2, ZTITIP4-IMSNM3,
*           ZTITIP4-IMSNM4, ZTITIP4-IMSNM5,
*           ZTITIP4-IMSAD1, ZTITIP4-IMSAD2, ZTITIP4-IMSAD3,
*           ZTITIP4-ICANM1, ZTITIP4-ICANM2, ZTITIP4-ICANM3,
*           ZTITIP4-ICANM5, ZTITIP4-ICANM5,
*           ZTITIP4-ICAAD1, ZTITIP4-ICAAD2, ZTITIP4-ICAAD3,
           ZTITIP1-IAPNO,  "ZTITIP1-IIVDT,
*           ZTITIP1-itpa1,  ZTITIP1-itpa1c, ZTITIP1-itpa2,
*           ZTITIP1-itpa2c, ZTITIP1-itpa3,  ZTITIP1-itpa3c,
*           ZTITIP1-icpam,  ZTITIP1-icpamc, ZTITIP1-idpam,
*           ZTITIP1-idpamc, ZTITIP1-ivpam,  ZTITIP1-ivpamc,
*           ZTITIP1-iteam,  ZTITIP1-iteamc,
*           ZTITIP1-itprt,
*           ZTITIP1-icprt,  ZTITIP1-idprt,  ZTITIP1-ivprt,
*           ZTITIP1-itert,  ZTITIP1-irart,
           ZTITIP1-IOPAO,
*           ZTITIP1-ipste1, ZTITIP1-ipste2, ZTITIP1-ipste3,
*           ZTITIP1-ipste4, ZTITIP1-ipste5,
           ZTITIP1-SNDUN,  ZTITIP1-SNDDT,  ZTITIP1-SNDTM,
           ZTITIP1-RCVUN,  ZTITIP1-RCVDT,  ZTITIP1-RCVTM,
           ZTITIP1-RECID,  ZTITIP1-RECNM,  ZTITIP1-RECNO,
           ZTITIP1-DOCST,  ZTITIP1-SNDST,  ZTITIP1-RCVNO,
           ZTITIP1-CNAM ,  ZTITIP1-CDAT ,  ZTITIP1-CTME ,
           ZTITIP1-UNAM ,  ZTITIP1-UDAT ,  ZTITIP1-UTME.

*    CLEAR: ZTITIP4.
*>아이템 기타 정보 Read.
    PERFORM SET_OTHERS_FIELDS_BY_ITEMS.
    IF NOT ZTITRQK-REQNO IS INITIAL.
      MOVE-CORRESPONDING : ZTITRQK TO ZTITIP1.
    ENDIF.
*>화면상의 Text를 Master Data 등에서 Read.
    PERFORM GET_OTHERS_TEXT_BY_MASTER_DATA.
    IF NOT ZTITRQK-REQNO IS INITIAL.
*> 수입의뢰 상태 필드 --> 적하보험 테이블.
      SELECT SINGLE *
        FROM ZTITRQS
       WHERE REQNO  EQ   ZTITRQK-REQNO
         AND AMDSQ  EQ   ZTITRQK-LSTAS.

      PERFORM MOVE_REQ_FIELDS_TO_ZTITIP1.
    ENDIF.
*> 이전 값과 비교하여 change 구분자를 설정함.
*    PERFORM  COMPARE_FIELDS_CHANGED.             "SRM2203-09738 - 삭제
  ELSE.
    IF ZTITIP1-AMDSQ GT 0.
      G_AMDSQ = ZTITIP1-AMDSQ - 1.
      PERFORM  GET_OLD_IP_TABLES  USING ZTITIP1-IIPNO
                                        G_AMDSQ.
    ENDIF.
    IF G_MODE NE C_CHARS.
      IF NOT ZTITRQK-REQNO IS INITIAL.
        MOVE-CORRESPONDING : ZTITRQK TO ZTITIP1.
      ENDIF.
    ENDIF.

    IF NOT ZTITRQK-REQNO IS INITIAL.
      SELECT SINGLE *
        FROM ZTITRQS
       WHERE REQNO  EQ   ZTITRQK-REQNO
         AND AMDSQ  EQ   ZTITRQK-LSTAS.
    ENDIF.

*>아이템 기타 정보 Read.
    PERFORM SET_OTHERS_FIELDS_BY_ITEMS.
*>화면상의 Text를 Master Data 등에서 Read.
    PERFORM GET_OTHERS_TEXT_BY_MASTER_DATA.
  ENDIF.

*> Document History 조회.
  PERFORM GET_DOCUMENT_HISTORY   TABLES IT_DOCHIS
                                 USING  G_DOCUMENT
                                        ZTITIP1-IIPNO
                                        ZTITIP1-AMDSQ
                                        G_HISTORY.

*> Cost Document History 조회.
  PERFORM GET_COST_DOCUMENT      TABLES IT_COSTDOC
                                 USING  G_DOCUMENT
                                        ZTITIP1-BUKRS
                                        ZTITIP1-IIPNO
                                        ZTITIP1-AMDSQ
                                        G_HISTORY_COST.
  ZTISSCRCOM-REQTY = C_IP.

ENDMODULE.                 " pai_scr0200_check_input_fields  INPUT
*&---------------------------------------------------------------------*
*&      Module  PAI_SCR2121_CHECK_INPUT_FIELDS  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE PAI_SCR2121_CHECK_INPUT_FIELDS INPUT.

  CHECK : G_MODE EQ C_CHARC OR
          G_MODE EQ C_CHARM OR
          G_MODE EQ C_CHARY OR
          G_MODE EQ C_CHARO.

*> 필수 항목 체크.
  PERFORM  CHECK_MANDATORY_INPUT  USING  :
                  'ZTITIP1-INSCP' C_ERROR,
*                  'ZTSTIG3-NAMET' c_error,
                  'ZTITIP1-TAPDT' C_ERROR,
*                  'ZTITIP1-PSPNR' C_ERROR,
                  'ZTITIP1-IOPDT' C_ERROR,
*                  'ZTITRQS-OPNNO' C_ERROR,
*                  'ZTITIP1-ITOCP' c_error,
*                  'ZTITIP1-ITORT' c_error,
                  'ZTITIP1-IIVAT' C_ERROR,
                  'ZTITIP1-IIVATC' C_ERROR,
                  'ZTITIP1-IWART' C_ERROR,
*                  'ZTITIP1-IOPNO' c_error,
                  'ZTITIP1-IVSLN' C_ERROR,
                  'ZTITIP1-ISHCD' C_ERROR,
                  'ZTITIP1-ISHNM' C_ERROR,
*                  'ZTITIP1-ICARN' C_ERROR,
                  'ZTITIP1-ILDCD' C_ERROR,
                  'ZTITIP1-ILDNM' C_ERROR,
                  'ZTITIP1-IDPDT' C_ERROR,   "자체개선 192404
                  'ZTITIP1-IGOTE1' C_ERROR,
                  'ZTITIP1-IHSCD' C_ERROR,
                  'ZTITIP1-IPCON' C_ERROR,
                  'ZTITIP1-IPORN' C_ERROR,
                  'ZTITIP1-IRECD' C_ERROR.
*                  'ZTITIP1-IRENO' c_error.

  IF NOT ZTSTIG3-ITOYN IS INITIAL.
    PERFORM  CHECK_MANDATORY_INPUT  USING  :
             'ZTITIP1-ITOCP' C_ERROR,
             'ZTITIP1-ITORT' C_ERROR.
  ENDIF.

  IF NOT ZTSTIG3-IOPYN IS INITIAL.
    PERFORM  CHECK_MANDATORY_INPUT  USING  :
             'ZTITIP1-IOPNO' C_ERROR.
  ENDIF.

  CASE G_MODE.
    WHEN C_CHARC OR C_CHARM OR C_CHARY.
    WHEN C_CHARO.

*> 보험금액.
      IF ZTITIP1-ITOAT IS INITIAL.
        ZTITIP1-ITOAT = ZTITIP1-IIVAT * ( ZTITIP1-ITORT / 100 ).
      ENDIF.
      IF ZTITIP1-ITOATC IS INITIAL.
        ZTITIP1-ITOATC = ZTITIP1-IIVATC.
      ENDIF.

*> 필수 항목 체크.
      PERFORM  CHECK_MANDATORY_INPUT  USING  :
         'ZTITIP1-IISDT' C_ERROR,
         'ZTITIP1-ITPRT' C_ERROR.

      IF ZTITIP1-IAJRT IS INITIAL.
        IF ZTITIP1-ITPA1C IS INITIAL.
          ZTITIP1-ITPA1C = T001-WAERS.
        ENDIF.
        ZTITIP1-IBACU = ZTITIP1-ITOATC.
        ZTITIP1-IAMCU = ZTITIP1-ITPA1C.

      ENDIF.

      IF ZTITIP1-ITPA1 IS INITIAL.
*> Get exchange rate
        CLEAR: BAPIRET1, BAPI1093_0.
        CALL FUNCTION 'BAPI_EXCHANGERATE_GETDETAIL'
          EXPORTING
            RATE_TYPE  = 'M'
            FROM_CURR  = ZTITIP1-ITOATC
            TO_CURRNCY = ZTITIP1-ITPA1C
            DATE       = ZTITIP1-IISDT
          IMPORTING
            EXCH_RATE  = BAPI1093_0
            RETURN     = BAPIRET1.

        IF BAPIRET1-TYPE EQ C_ERROR.
          MESSAGE ID BAPIRET1-ID TYPE BAPIRET1-TYPE
                  NUMBER BAPIRET1-NUMBER
                  WITH BAPIRET1-MESSAGE_V1 BAPIRET1-MESSAGE_V2
                       BAPIRET1-MESSAGE_V3 BAPIRET1-MESSAGE_V4.
        ENDIF.

        IF ZTITIP1-ITOATC = T001-WAERS.
          ZTITIP1-IAJRT = 1.
        ELSE.
          IF ZTITIP1-IAJRT IS INITIAL.
            IF BAPI1093_0-EXCH_RATE_V IS INITIAL.
              ZTITIP1-IAJRT  = BAPI1093_0-EXCH_RATE.
            ELSE.
              ZTITIP1-IAJRT  = BAPI1093_0-EXCH_RATE_V.
            ENDIF.
          ENDIF.
        ENDIF.

        CALL FUNCTION 'BAPI_CURRENCY_CONV_TO_EXTERN_9'
          EXPORTING
            CURRENCY        = ZTITIP1-ITOATC
            AMOUNT_INTERNAL = ZTITIP1-ITOAT
          IMPORTING
            AMOUNT_EXTERNAL = BAPICURX-BAPICURX.

        ZTITIP1-ITPA1 = BAPICURX-BAPICURX *  ZTITIP1-IAJRT *
                      ( BAPI1093_0-TO_FACTOR / BAPI1093_0-FROM_FACTOR ).

        ZTITIP1-ITPA1 = ZTITIP1-ITPA1 * ZTITIP1-ITPRT.
        BAPICURX-BAPICURX = ZTITIP1-ITPA1.

        CALL FUNCTION 'BAPI_CURRENCY_CONV_TO_INTERN_9'
          EXPORTING
            CURRENCY             = ZTITIP1-ITPA1C
            AMOUNT_EXTERNAL      = BAPICURX-BAPICURX
            MAX_NUMBER_OF_DIGITS = 18
          IMPORTING
            AMOUNT_INTERNAL      = ZTITIP1-ITPA1.
      ENDIF.
  ENDCASE.

  PERFORM  GET_IMPORT_VENDORS_TEXT  USING C_ERROR.

ENDMODULE.                 " PAI_SCR2121_CHECK_INPUT_FIELDS  INPUT

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

  DATA: L_DDTEXT LIKE G_DDTEXT.

*> 문서상태 Fixed value read.
  PERFORM  DDIC_DOMAIN_VALUE_TEXT_READ USING 'ZTIDOCST'
                                             SY-LANGU
                                             ZTITIP1-DOCST
                                             G_DDTEXT
                                             C_SUCCESS.
  L_DDTEXT = G_DDTEXT.

*> Ammend 생성일 경우.
  IF SY-TCODE EQ C_CREATE_A.
    IF ZTITIP1-DOCST NE C_CHARO.
      MESSAGE E114 WITH ZTITIP1-REQNO ZTITIP1-AMDSQ G_DDTEXT.
      EXIT.
    ENDIF.
  ELSE.
*> Status check.
    CASE ZTITIP1-DOCST.
      WHEN SPACE.  ">의뢰대상.
        IF G_MODE EQ C_CHARA OR
           G_MODE EQ C_CHARY OR
           G_MODE EQ C_CHARO.
          MESSAGE S919 WITH G_DDTEXT.
        ENDIF.
      WHEN 'Y'.    ">부보신청.
*        IF g_mode EQ c_charm OR g_mode EQ c_chard OR
        IF G_MODE EQ C_CHARM OR
           G_MODE EQ C_CHARA.
          MESSAGE S919 WITH G_DDTEXT.
        ENDIF.

        IF G_MODE EQ C_CHARD.
          MESSAGE E919 WITH G_DDTEXT.
        ENDIF.

        IF G_MODE EQ C_CHARY OR G_MODE EQ C_CHARO.
          IF NOT ZTITIP1-SNDST IS INITIAL.
*> EDI 송수신 상태 Fixed value read.
            PERFORM  DDIC_DOMAIN_VALUE_TEXT_READ
                                        USING 'ZTISNDST'
                                               SY-LANGU
                                               ZTITIP1-SNDST
                                               G_DDTEXT
                                               C_SUCCESS.
            IF G_MODE EQ C_CHARY.
              IF ZTITIP1-SNDST EQ C_CHARW.
                MESSAGE E919 WITH G_DDTEXT.
              ELSE.
                MESSAGE E919 WITH G_DDTEXT.
              ENDIF.
            ENDIF.
            IF G_MODE EQ C_CHARO.
              MESSAGE W920 WITH G_DDTEXT.
            ENDIF.
          ELSE.
            IF G_MODE EQ C_CHARO OR
               G_MODE EQ C_CHARY.
              MESSAGE W920 WITH G_DDTEXT.
            ELSE.
              MESSAGE E919 WITH G_DDTEXT.
            ENDIF.
          ENDIF.
        ENDIF.
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
*&      Module  USER_COMMAND_2121  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_2121 INPUT.
*> F2 Funtion key Event시 해당 필드의 정보 display
  PERFORM  DOUBLE_CLICK_EVENT.

ENDMODULE.                 " USER_COMMAND_2121  INPUT

*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_2121  INPUT
*&---------------------------------------------------------------------*
*> input module for tc 'TC_2210'. do not change this line!
*> modify table
*&---------------------------------------------------------------------*
MODULE TC_2210_MODIFY INPUT.

  IF ZTISIP02-ITETY IS INITIAL.
    ZTISIP02-ITETY = C_CHARB.
*    PERFORM no_input_check USING 'ZTISIP02' 'ITETY' c_error.
  ENDIF.
  IF ZTISIP02-ITECD IS INITIAL.
    PERFORM NO_INPUT_CHECK USING 'ZTISIP02' 'ITECD' C_ERROR.
  ELSE.
    SELECT SINGLE *
      FROM ZTSTIG4
     WHERE ITECD  EQ  ZTISIP02-ITECD.
    IF SY-SUBRC NE 0.
      MESSAGE E058(00) WITH ZTISIP02-ITECD 'ZTSTIG4'.
    ENDIF.
  ENDIF.

  IF ZTISIP02-ITET1 IS INITIAL.
    ZTISIP02-ITET1 = ZTSTIG4-ITET1.
    ZTISIP02-ITET2 = ZTSTIG4-ITET2.
    ZTISIP02-ITET3 = ZTSTIG4-ITET3.
    ZTISIP02-ITET4 = ZTSTIG4-ITET4.
    ZTISIP02-ITET5 = ZTSTIG4-ITET5.
    ZTISIP02-ITES1 = ZTSTIG4-ITES1.
    ZTISIP02-ITES2 = ZTSTIG4-ITES2.
    ZTISIP02-ITES3 = ZTSTIG4-ITES3.
    ZTISIP02-ITES4 = ZTSTIG4-ITES4.
    ZTISIP02-ITES5 = ZTSTIG4-ITES5.
  ENDIF.

  MOVE-CORRESPONDING ZTISIP02 TO G_TC_2210_WA.

  IF SY-DYNNR EQ C_SCR2124.
    MODIFY G_TC_2210_ITAB
      FROM G_TC_2210_WA
      INDEX TC_2124-CURRENT_LINE.
  ELSEIF SY-DYNNR EQ C_SCR2210.
    MODIFY G_TC_2210_ITAB
      FROM G_TC_2210_WA
      INDEX TC_2210-CURRENT_LINE.
  ENDIF.

  IF SY-SUBRC NE 0.
    APPEND G_TC_2210_WA TO G_TC_2210_ITAB.
  ENDIF.

ENDMODULE.                    "TC_2210_modify INPUT

*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_2121  INPUT
*&---------------------------------------------------------------------*
*> input module for tc 'TC_2210'. do not change this line!
*> mark table
*&---------------------------------------------------------------------*
MODULE TC_2210_MARK INPUT.

*  IF tc_2210-line_sel_mode = 1 AND
*     g_tc_2210_wa-flag = 'X'.
*    LOOP AT g_tc_2210_itab INTO g_tc_2210_wa
*      WHERE flag = 'X'.
*      g_tc_2210_wa-flag = ''.
*      MODIFY g_tc_2210_itab
*        FROM g_tc_2210_wa
*        TRANSPORTING flag.
*    ENDLOOP.
*    g_tc_2210_wa-flag = 'X'.
*  ENDIF.

  IF SY-DYNNR EQ C_SCR2124.
    MODIFY G_TC_2210_ITAB
      FROM G_TC_2210_WA
      INDEX TC_2124-CURRENT_LINE
      TRANSPORTING FLAG.
  ELSEIF SY-DYNNR EQ C_SCR2210.
    MODIFY G_TC_2210_ITAB
      FROM G_TC_2210_WA
      INDEX TC_2210-CURRENT_LINE
      TRANSPORTING FLAG.
  ENDIF.

ENDMODULE.                    "TC_2210_mark INPUT
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_2121  INPUT
*&---------------------------------------------------------------------*
*> input module for tc 'TC_2210'. do not change this line!
*> process user command
*&---------------------------------------------------------------------*
MODULE TC_2210_USER_COMMAND INPUT.
  OK_CODE = SY-UCOMM.
  PERFORM USER_OK_TC USING    'TC_2210'
                              'G_TC_2210_ITAB'
                              'FLAG'
                     CHANGING OK_CODE.
  SY-UCOMM = OK_CODE.

  CLEAR G_LINE.
  LOOP AT G_TC_2210_ITAB INTO G_TC_2210_WA.
    ADD 1 TO G_LINE.
    MOVE: G_LINE TO G_TC_2210_WA-ITESQ.
    MODIFY G_TC_2210_ITAB FROM G_TC_2210_WA.
  ENDLOOP.

*> F2 Funtion key Event시 해당 필드의 정보 display
  PERFORM  DOUBLE_CLICK_EVENT.

ENDMODULE.                    "TC_2210_user_command INPUT
*&---------------------------------------------------------------------*
*&      Module  check_ip_number_chainged  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE CHECK_IP_NUMBER_CHAINGED INPUT.

  CLEAR: G_IPNUM_CHK1, G_IPNUM_CHK2.

ENDMODULE.                 " check_ip_number_chainged  INPUT
*&---------------------------------------------------------------------*
*&      Module  check_ip_number  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE CHECK_IP_NUMBER INPUT.

  CHECK : G_MODE EQ C_CHARO.

  IF G_IPNUM_CHK1 IS INITIAL.
    IF ZTITIP1-ISPNO IS INITIAL.
      PERFORM NO_INPUT_CHECK USING 'ZTITIP1' 'ISPNO' C_WARNING.
      G_IPNUM_CHK1 = C_TRUE.
    ENDIF.
  ENDIF.

  IF G_IPNUM_CHK2 IS INITIAL.
    IF NOT ZTITIP1-ISPNO IS INITIAL.
      SELECT ISPNO
        INTO G_ISPNO
        FROM ZTITIP1 UP TO 1 ROWS
       WHERE ISPNO   EQ   ZTITIP1-ISPNO
         AND IIPNO   NE   ZTITIP1-IIPNO.
      ENDSELECT.

      IF SY-SUBRC EQ 0.
        MESSAGE W155 WITH ZTITIP1-ISPNO.
        G_IPNUM_CHK2 = C_TRUE.
      ENDIF.
    ENDIF.
  ENDIF.

ENDMODULE.                 " check_ip_number  INPUT
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
*&      Module  check_input_value_scr2210  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE CHECK_INPUT_VALUE_SCR2210 INPUT.


*  CHECK: g_mode EQ c_chary OR
*         g_mode EQ c_charo.
*> 필수 항목 체크.
  PERFORM  CHECK_MANDATORY_INPUT     USING  :
                                    'ZTITIP1-IPCON'  C_ERROR,
                                    'ZTITIP1-IPORN'  C_ERROR,
                                    'ZTITIP1-IASNM1' C_ERROR,
                                    'ZTITIP1-IAPNM'  C_ERROR,
                                    'ZTITIP1-IGOTE1' C_ERROR.

**> 사용가능 문자집합 체크.
*  PERFORM  check_edi_available_char  USING :
*                                    'ZTITTT01-TOCNM' c_error,
*                                    'ZTITTT01-TBENM' c_error,
*                                    'ZTITTT01-TOCPR' c_error.

ENDMODULE.                 " check_input_value_scr2210  INPUT
*&---------------------------------------------------------------------*
*&      Module  check_input_value_TC_2210  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE CHECK_INPUT_VALUE_TC_2210 INPUT.

*  CHECK G_TABIX EQ 1.
*  IF g_tc_2210_wa-ITETY NE 'B'.
*       MESSAGE E999
*           WITH '부보조건 첫번째 라인에는 기본조건이 필수사항 입니다.'.
*  ENDIF.
ENDMODULE.                 " check_input_value_TC_2210  INPUT
*&---------------------------------------------------------------------*
*&      Module  user_command_2120  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_2120 INPUT.
*> F2 Funtion key Event시 해당 필드의 정보 display
  PERFORM  DOUBLE_CLICK_EVENT.
ENDMODULE.                 " user_command_2120  INPUT
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
*&      Module  user_command_2123  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_2123 INPUT.
*> F2 Funtion key Event시 해당 필드의 정보 display
  PERFORM  DOUBLE_CLICK_EVENT.
ENDMODULE.                 " user_command_2123  INPUT
*&---------------------------------------------------------------------*
*&      Module  user_command_2124  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_2124 INPUT.

  OK_CODE = SY-UCOMM.
  PERFORM USER_OK_TC USING    'TC_2124'
                              'G_TC_2210_ITAB'
                              'FLAG'
                     CHANGING OK_CODE.
  SY-UCOMM = OK_CODE.

  CLEAR G_LINE.
  LOOP AT G_TC_2210_ITAB INTO G_TC_2210_WA.
    ADD 1 TO G_LINE.
    MOVE: G_LINE TO G_TC_2210_WA-ITESQ.
    MODIFY G_TC_2210_ITAB FROM G_TC_2210_WA.
  ENDLOOP.

*> F2 Funtion key Event시 해당 필드의 정보 display
  PERFORM  DOUBLE_CLICK_EVENT.

ENDMODULE.                 " user_command_2124  INPUT
*&---------------------------------------------------------------------*
*&      Module  fcode_exit_scr7000  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE FCODE_EXIT_SCR7000 INPUT.

  LEAVE TO SCREEN 0.

ENDMODULE.                 " fcode_exit_scr7000  INPUT
*&---------------------------------------------------------------------*
*&      Module  check_purchasing_document  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE CHECK_PURCHASING_DOCUMENT INPUT.

  CHECK OK_CODE_POPUP NE 'FEXIT'.

  PERFORM  CHECK_INSURANCE_DOC_BY_EBELN.

ENDMODULE.                 " check_purchasing_document  INPUT
*&---------------------------------------------------------------------*
*&      Module  user_command_7000  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_7000 INPUT.

  CASE OK_CODE_POPUP.
    WHEN 'FEXIT'.
      LEAVE TO SCREEN 0.
    WHEN 'FCOPY'.
      ZTITIP1-REFPO = C_TRUE.
      LEAVE TO SCREEN 0.
  ENDCASE.

ENDMODULE.                 " user_command_7000  INPUT
*&---------------------------------------------------------------------*
*&      Module  CHECK_FIELDS  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE CHECK_FIELDS INPUT.
  PERFORM  CHECK_MANDATORY_INPUT     USING  :
                                    'ZTITIP1-IDPDT'  C_ERROR.
ENDMODULE.                 " CHECK_FIELDS  INPUT
