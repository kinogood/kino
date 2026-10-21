************************************************************************
* Title         :  ZTIR5000I01                                         *
*                                                                      *
* Description   : 수입 입고관리 PAI Include                            *
*                                                                      *
* Creation Date : 2003/07/11                                           *
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

  MOVE-CORRESPONDING ZTISGRIT TO G_TC_2130_WA.

*--> 수입입고 예외처리 - 20250709
  IF G_TC_2130_WA-IGRNO <> '1000109298'.
    IF G_TC_2130_WA-GRMNG GT G_TC_2130_WA-GRMNGL.
      CLEAR: G_MENGET.
      WRITE G_TC_2130_WA-GRMNGL TO G_MENGET(15) UNIT G_TC_2130_WA-MEINS.
      CONCATENATE G_MENGET G_TC_2130_WA-MEINS INTO G_MENGET.
      MESSAGE E860 WITH G_MENGET.
    ENDIF.
  ENDIF.
*<-- 수입입고 예외처리 - 20250709

  IF G_TC_2130_WA-BWART IS INITIAL.
    CLEAR: G_TC_2130_WA-SHKZG.
  ELSE.
    SELECT SINGLE SHKZG
      INTO G_TC_2130_WA-SHKZG
      FROM T156
     WHERE BWART EQ G_TC_2130_WA-BWART.
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

  IF NOT G_TC_2130_WA-HSDAT IS INITIAL.
    G_TC_2130_WA-VFDAT = G_TC_2130_WA-HSDAT +
                         G_TC_2130_WA-MHDHB.
  ELSE.
    CLEAR G_TC_2130_WA-VFDAT.
    IF NOT G_TC_2130_WA-MHDHB IS INITIAL.
      PERFORM NO_INPUT_CHECK USING 'ZTISGRIT' 'HSDAT' C_ERROR.
    ENDIF.
  ENDIF.

**> 정가 계산.
*  CALL FUNCTION 'Z_TI_CALC_ITEM_AMOUNT'
*    EXPORTING
*      peinh = g_tc_2130_wa-peinh
*      bpumz = g_tc_2130_wa-bpumz
*      bpumn = g_tc_2130_wa-bpumn
*      menge = g_tc_2130_wa-blmng
*      netpr = g_tc_2130_wa-netpr
*    CHANGING
*      netwr = g_tc_2130_wa-netwr.

*  IF g_tc_2130_wa-cnam IS INITIAL.
*    MOVE: sy-uname TO g_tc_2130_wa-cnam,
*          sy-datlo TO g_tc_2130_wa-cdat,
*          sy-timlo TO g_tc_2130_wa-ctme.
*  ENDIF.
*
*  MOVE: sy-uname TO g_tc_2130_wa-unam,
*        sy-datlo TO g_tc_2130_wa-udat,
*        sy-timlo TO g_tc_2130_wa-utme.

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
*> 아이템 정보 display
  PERFORM  DISPLAY_INFOMATION_BY_ITEMS USING   'TC_2130'
                                               'IT_TAB'
                                               'FLAG'
                                               ZTITGRK-LIFNR
                                       CHANGING OK_CODE.
*> F2 Funtion key Event시 해당 필드의 정보 display
  PERFORM  DOUBLE_CLICK_EVENT.

  IF OK_CODE EQ 'LINE_SELECT'.
    GET CURSOR LINE G_FINDLINE.
    IF SY-SUBRC EQ 0.
      G_FINDLINE = G_FINDLINE + TC_2130-TOP_LINE - 1.
      READ TABLE IT_TAB INTO G_TC_2130_WA INDEX G_FINDLINE.
      G_BTABIX = SY-TABIX.
      IF SY-SUBRC EQ 0.
        G_ICCIT  = G_TC_2130_WA-ICCIT.
        MOVE-CORRESPONDING : G_TC_2130_WA TO ZTISGRIT,
                             G_TC_2130_WA TO ZTITGRP.

        REFRESH: G_TC_7000_TEMP.
*        LOOP AT g_tc_7000_itab INTO g_tc_7000_wa
*                               WHERE igrno = ztisgrit-igrno
*                                 AND iccit = ztisgrit-iccit.
        LOOP AT G_TC_7000_ITAB INTO G_TC_7000_WA
                               WHERE ICCIT = ZTISGRIT-ICCIT.
          APPEND G_TC_7000_WA TO G_TC_7000_TEMP .
        ENDLOOP.
        SORT G_TC_7000_TEMP BY IBCIT.
        CASE G_MODE.
          WHEN C_CHARC OR C_CHARM.
            PERFORM  GET_ZMMT0024_TABLE.
          WHEN OTHERS.
            DESCRIBE TABLE G_TC_7000_TEMP LINES G_LINE.
            IF G_LINE EQ 0.
              MESSAGE I518.  EXIT.
            ENDIF.
*> SEQ NUMBER MAKE.
            PERFORM SET_SUB_BATCH_SEQ.
        ENDCASE.

        CALL SCREEN '7000'
             STARTING AT 01 01.
*             ENDING   AT x2 y2
        IF OK_CODE EQ 'BU'.
*          DELETE  g_tc_7000_itab WHERE igrno = ztisgrit-igrno
*                                   AND iccit = ztisgrit-iccit.
*
          DELETE  G_TC_7000_ITAB WHERE ICCIT = ZTISGRIT-ICCIT.

          LOOP AT G_TC_7000_TEMP INTO G_TC_7000_WA.
            APPEND G_TC_7000_WA TO G_TC_7000_ITAB.
          ENDLOOP.
          IF SY-SUBRC EQ 0.
            ZTISGRIT-BATCHX = C_TRUE.
          ELSE.
            CLEAR: ZTISGRIT-BATCHX.
          ENDIF.
          MOVE-CORRESPONDING ZTISGRIT TO G_TC_2130_WA.
          MODIFY IT_TAB FROM G_TC_2130_WA INDEX G_BTABIX.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDIF.

ENDMODULE.                 " tc_2130_user_command  INPUT
*&---------------------------------------------------------------------*
*&      Module  check_type_of_request  INPUT
*&---------------------------------------------------------------------*
*&      Module  pai_scr0100_check_input_fields  INPUT
*&---------------------------------------------------------------------*
MODULE PAI_SCR0100_CHECK_INPUT_FIELDS INPUT.

  DATA: L_ICCSQ TYPE ZTIICCSQ.

*> EXIT확인.
  PERFORM  CHECK_PROGRAM_EXIT_COMMAND.

*> call이 되었을 경우.
  IF SY-CALLD EQ C_TRUE.
    IF NOT G_TCODE  IS INITIAL.
*      MESSAGE a003(ok).
*    ELSE.
      IF SY-TCODE EQ C_NO_DRAFT_DUE_LIST OR
         G_TCODE1 EQ C_NO_DRAFT_DUE_LIST.
        MOVE: 'ZTICOPY' TO OK_CODE,
              'ZTICOPY' TO SY-UCOMM.
      ENDIF.
    ENDIF.
  ENDIF.

*> Input fields check
  IF NOT OK_CODE EQ 'ZTICOPY'.
    IF ZTISSCRCOM-ICCNO IS INITIAL.
      MESSAGE E501.
    ENDIF.
  ENDIF.

*  IF NOT zmisscrcom-ebeln IS INITIAL.
  PERFORM P3000_SET_DATA_OF_SCREEN.

  CLEAR: G_COUNT.
  IF NOT OK_CODE EQ 'ZTICOPY'.
    SELECT MAX( ICCSQ )
      INTO L_ICCSQ
      FROM ZTITCCK
     WHERE ICCNO EQ ZTISSCRCOM-ICCNO.

    CALL FUNCTION 'Z_TI_GET_CUSTOM_IMPORT'
      EXPORTING
        ICCNO     = ZTISSCRCOM-ICCNO
        ICCSQ     = L_ICCSQ
      IMPORTING
        ZTITCCK   = ZTITCCK
      TABLES
        ZTITCCP   = IT_CCITM
      EXCEPTIONS
        NOT_FOUND = 1
        OTHERS    = 2.
    IF SY-SUBRC <> 0.
      MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
              WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    ENDIF.

    LOOP AT IT_CCITM.
      G_TABIX = SY-TABIX.
      IF IT_CCITM-WEPOS IS INITIAL.
        DELETE IT_CCITM INDEX G_TABIX.
      ENDIF.
    ENDLOOP.

    SELECT SINGLE *
      FROM ZTITIG00
     WHERE BUKRS EQ ZTITCCK-BUKRS.
    IF SY-SUBRC NE 0.
      MESSAGE E035 WITH ZTITCCK-BUKRS.
    ENDIF.

    SELECT SINGLE *
      FROM ZTITBLK
     WHERE IBLNO EQ ZTITCCK-IBLNO.
    IF SY-SUBRC NE 0.
      MESSAGE E200 WITH ZTITCCK-IBLNO.
    ENDIF.
**> 미송장 처리일 경우.
*    IF ztitblk-bldty NE c_chars.
*      IF NOT ztitig00-igrmt IS INITIAL.
*        SELECT COUNT( * )
*          INTO g_count
*          FROM ztiviv00
*         WHERE iblno EQ ztitcck-iblno
*           AND livst EQ 'P'.
*        IF g_count EQ 0.
*          MESSAGE ID 'ZMTI00' TYPE 'E' NUMBER '004' WITH ztitcck-iblno.
*        ENDIF.
*      ENDIF.
*    ENDIF.
*
*> 자가장치장일 경우, 보세구역 출고데이타로 Setting
    IF ZTITIG00-BDMTU EQ C_TRUE AND
       ZTITBLK-RPTTY  EQ C_CHARN.
      LOOP AT IT_CCITM.
        G_TABIX = SY-TABIX.
        IF IT_CCITM-BDSEQ IS INITIAL.
          DELETE IT_CCITM INDEX G_TABIX.

          SELECT BDQTY BDSEQ IBDSQ
            INTO (IT_CCITM-CCMNG, IT_CCITM-BDSEQ, IT_CCITM-IBDSQ)
            FROM ZTITBDP
           WHERE ICCNO EQ IT_CCITM-ICCNO
             AND ICCIT EQ IT_CCITM-ICCIT
             AND IBLNO EQ IT_CCITM-IBLNO
             AND IBLIT EQ IT_CCITM-IBLIT.
            APPEND IT_CCITM.
          ENDSELECT.
        ENDIF.
      ENDLOOP.
    ENDIF.

  ELSE.
    IF NOT IT_ZTISCCIT[] IS INITIAL.
      SELECT *
        INTO CORRESPONDING FIELDS OF TABLE IT_CCITM
        FROM ZTITBLP
         FOR ALL ENTRIES IN IT_ZTISCCIT
       WHERE IBLNO EQ IT_ZTISCCIT-IBLNO
         AND IBLIT EQ IT_ZTISCCIT-IBLIT.
      LOOP AT IT_CCITM.
        MOVE : IT_CCITM-IBLNO TO IT_CCITM-ICCNO,
               IT_CCITM-IBLIT TO IT_CCITM-ICCIT,
               IT_CCITM-BLMNG TO IT_CCITM-CCMNG.
* 2005.06.03 by JH,LEE
* 미통관입고인 경우 통관관리번호를 삭제함
* -->
        IF ZTITBLK-RPTTY = 'Z'.
          CLEAR : IT_CCITM-ICCNO, IT_CCITM-ICCIT.
        ENDIF.
* <--
        MODIFY  IT_CCITM.
      ENDLOOP.
    ENDIF.
  ENDIF.

  REFRESH: IT_ZTISCCIT.
  LOOP AT IT_CCITM.
*  > 입고누적수량.
    IF OK_CODE EQ 'ZTICOPY'.
      SELECT SUM( GRMNG )
        INTO IT_CCITM-GRMNGS
        FROM ZTIVGR00
       WHERE IBLNO   EQ  IT_CCITM-IBLNO
         AND IBLIT   EQ  IT_CCITM-IBLIT
         AND ICCNO   EQ  SPACE.
      IT_CCITM-GRMNGL = IT_CCITM-BLMNG - IT_CCITM-GRMNGS.
      IF IT_CCITM-GRMNGL LE 0.
        IT_CCITM-GRMNGL = 0.
      ENDIF.
    ELSE.
*> 자가장치장일 경우, 보세구역 출고데이타로 Setting
      IF ZTITIG00-BDMTU EQ C_TRUE AND
         ZTITBLK-RPTTY  EQ C_CHARN.
        SELECT SUM( GRMNG )
          INTO IT_CCITM-GRMNGS
          FROM ZTIVGR00
         WHERE ICCNO  = IT_TAB_H-ICCNO
           AND ICCIT  = IT_TAB_H-ICCIT
           AND BDSEQ  = IT_TAB_H-BDSEQ
           AND IBDSQ  = IT_TAB_H-IBDSQ.
        IT_CCITM-GRMNGL = IT_CCITM-CCMNG - IT_CCITM-GRMNGS.
        IF IT_CCITM-GRMNGL LE 0.
          IT_CCITM-GRMNGL = 0.
        ENDIF.
      ELSE.
        SELECT SUM( GRMNG )
          INTO IT_CCITM-GRMNGS
          FROM ZTIVGR00
         WHERE ICCNO   EQ  IT_CCITM-ICCNO
           AND ICCIT   EQ  IT_CCITM-ICCIT.
        IT_CCITM-GRMNGL = IT_CCITM-CCMNG - IT_CCITM-GRMNGS.
        IF IT_CCITM-GRMNGL LE 0.
          IT_CCITM-GRMNGL = 0.
        ENDIF.
      ENDIF.
    ENDIF.

    IT_CCITM-GRMNG  = IT_CCITM-GRMNGL.

    MOVE-CORRESPONDING IT_CCITM TO IT_ZTISCCIT.
    MOVE-CORRESPONDING IT_CCITM TO G_TC_2130_WA.

*> 자재그룹.
    IF NOT IT_CCITM-MATNR IS INITIAL.
      SELECT SINGLE MATKL MTART
        INTO (IT_ZTISCCIT-MATKL, IT_ZTISCCIT-MTART)
        FROM MARA
       WHERE MATNR EQ IT_CCITM-MATNR.
    ENDIF.

    APPEND IT_ZTISCCIT.
  ENDLOOP.

*>수입통관문서의 종류/상태를 검증.
  PERFORM CHECK_REQUEST_OF_CUSTOM.
*>G/R을 입력할 통관 잔량을 체크함.
  PERFORM GET_AVAILABLE_CC_ITEM TABLES IT_ZTISCCIT
                                       IT_ICCNO
                                USING  C_ERROR
                                       C_TRUE.

  REFRESH: IT_TAB.
  SORT IT_ZTISCCIT BY ICCIT.
  LOOP AT IT_ZTISCCIT.
    MOVE-CORRESPONDING IT_ZTISCCIT TO G_TC_2130_WA.
    APPEND G_TC_2130_WA TO IT_TAB.
  ENDLOOP.

*>Set 입고 헤더용 기초 value
  PERFORM  SET_GR_INITIAL_DATA  USING ZTITGRK.

** JS전선 회사코드 2007/04 KSH --------------------------------------
*> AUTHORIZATION_CHECK
  PERFORM P1102_AUTHORIZATION_CHECK USING ZTITGRK-BUKRS.
** JS전선 회사코드 2007/04 KSH --------------------------------------

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

*> Text Object 관련 Internal Table Initial.
  PERFORM  GET_LONGTEXT_DATA.

*> Create Class Object.
  PERFORM  BUILD_CLASS_OBJECT.

*> Generic Object Service.
  PERFORM  SET_GENERIC_OBJECT_SERVICE USING   'ZTIWF_SDOC'
                                               ZTITIVK+3(10).

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

  IF ZTISSCRCOM-IGRNO IS INITIAL AND
     ZTISSCRCOM-ICCNO IS INITIAL AND
     ZTISSCRCOM-IBLNO IS INITIAL.
    MESSAGE E913.
  ENDIF.

  CLEAR: G_COUNT.
  IF ZTISSCRCOM-IGRNO IS INITIAL.
    PERFORM  GET_GR_INT_NO_BY_BL_NO      USING ZTISSCRCOM-IBLNO
                                               ZTISSCRCOM-IGRNO
                                               C_FALSE.
  ENDIF.
  IF ZTISSCRCOM-IGRNO IS INITIAL.
    PERFORM  GET_GR_INT_NO_BY_CC_NO      USING ZTISSCRCOM-ICCNO
                                               ZTISSCRCOM-IGRNO
                                               C_FALSE.
  ENDIF.

  IF NOT ZTISSCRCOM-IGRNO IS INITIAL.
    CALL FUNCTION 'Z_TI_GET_GOODS_RECEIPT'
      EXPORTING
        XIGRNO    = ZTISSCRCOM-IGRNO
      IMPORTING
        XZTITGRK  = ZTITGRK
      TABLES
        XZTITGRP  = IT_TAB
        XZTITGRH  = IT_ZTISGRHS
        XZTITGRB  = G_TC_7000_ITAB
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
      IF ZTITGRK-BUKRS <> A_BUKRS.
        MESSAGE E998 WITH ZTITGRK-BUKRS  '권한이 없습니다!'..
      ENDIF.
    ENDIF.
** JS전선 회사코드 2007/04 KSH --------------------------------------

*> 변경 문서 관리를 위한 이전데이타를 Move.
    *ZTITGRK   = ZTITGRK.
    YZTITGRP[]  = XZTITGRP[].

*> 변경 문서 관리를 위한 이전데이타를 Move (Item Data).
    REFRESH : XZTITGRP, YZTITGRP.
    LOOP AT IT_TAB INTO G_TC_2130_WA.
      MOVE-CORRESPONDING G_TC_2130_WA TO : XZTITGRP,
                                           YZTITGRP.
      APPEND : XZTITGRP, YZTITGRP.
      IF G_TC_2130_WA-GRMNGL LT 0.
        G_TC_2130_WA-GRMNGL = 0.
      ENDIF.
      MODIFY IT_TAB FROM G_TC_2130_WA.
    ENDLOOP.

*>업무영역별 Status Check.
    PERFORM CHECK_DOCUMENT_STATUS.

*> 전기이력 Tab 화면의 Visible/Invisible용.
    CLEAR: G_HISTORY_POST.
    DESCRIBE TABLE IT_ZTISGRHS LINES G_LINE.
    IF G_LINE GT 0.
      MOVE: C_TRUE TO G_HISTORY_POST.
      LOOP AT IT_ZTISGRHS.
        PERFORM GET_DOMAIN_VALUE_TEXT
                    USING
                       'ZTIIGRST'
                       IT_ZTISGRHS-IGRST
                       IT_ZTISGRHS-GRSTX.
        MODIFY IT_ZTISGRHS.
      ENDLOOP.
    ENDIF.

*>아이템 기타 정보 Read.
    PERFORM SET_OTHERS_FIELDS_BY_ITEMS.
*>화면상의 Text를 Master Data 등에서 Read.
    PERFORM GET_OTHERS_TEXT_BY_MASTER_DATA.
*>조회모드가 아닌 경우 Lock.
    IF G_MODE NE C_CHARS.
      PERFORM SET_GR_LOCK_OBJECT   USING ZTITGRK-IGRNO
                                         C_LOCK
                                         C_ERROR
                                         G_MODIFY.
    ENDIF.
*> Document History 조회.
    PERFORM GET_DOCUMENT_HISTORY   TABLES IT_DOCHIS
                                   USING  G_DOCUMENT
                                          ZTITGRK-IGRNO
                                          '00'
                                          G_HISTORY.

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
*&      Form  check_document_status
*&---------------------------------------------------------------------*
*       업무영역별 Status Check.
*----------------------------------------------------------------------*
FORM CHECK_DOCUMENT_STATUS .

  DATA: L_DDTEXT LIKE G_DDTEXT.

*> 문서상태 Fixed value read.
  PERFORM  DDIC_DOMAIN_VALUE_TEXT_READ USING 'ZTIIGRST'
                                             SY-LANGU
                                             ZTITGRK-IGRST
                                             G_DDTEXT
                                             C_SUCCESS.
  L_DDTEXT = G_DDTEXT.

  CASE G_MODE.
    WHEN C_CHARM.    ">변경일 경우.
      IF ZTITGRK-IGRST EQ C_CHARG OR
         ZTITGRK-IGRST EQ C_CHARN.
        MESSAGE E919 WITH G_DDTEXT.
      ENDIF.
    WHEN C_CHARD.    ">삭제일 경우.
      IF ZTITGRK-IGRST EQ C_CHARG OR
         ZTITGRK-IGRST EQ C_CHARN.
        MESSAGE E919 WITH G_DDTEXT.
      ENDIF.
    WHEN C_CHARP.   ">전기일 경우.
      IF ZTITGRK-IGRST EQ C_CHARG.
        MESSAGE E919 WITH G_DDTEXT.
      ENDIF.
    WHEN C_CHARR.   ">취소일 경우.
      IF NOT ( ZTITGRK-IGRST EQ C_CHARG OR
               ZTITGRK-IGRST EQ C_CHARN ).
        MESSAGE E919 WITH G_DDTEXT.
      ENDIF.
    WHEN C_CHARE.
  ENDCASE.
  MESSAGE S922 WITH L_DDTEXT.
*
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
*&      Module  check_movement_type  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE CHECK_MOVEMENT_TYPE INPUT.

  CHECK: NOT ( G_MODE EQ C_CHARS OR
              G_MODE EQ C_CHARD ).

  IF ZTITGRK-BWART IS INITIAL.
    PERFORM NO_INPUT_CHECK USING 'ZTITGRK' 'BWART' C_ERROR.
  ELSE.
    LOOP AT IT_TAB INTO G_TC_2130_WA.
      IF G_TC_2130_WA-BWART IS INITIAL.
        G_TC_2130_WA-BWART = ZTITGRK-BWART.

        SELECT SINGLE SHKZG
          INTO G_TC_2130_WA-SHKZG
          FROM T156
         WHERE BWART EQ G_TC_2130_WA-BWART.

        MODIFY IT_TAB FROM G_TC_2130_WA.
      ENDIF.
    ENDLOOP.
  ENDIF.

ENDMODULE.                 " check_movement_type  INPUT
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
*&      Module  user_command_2100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_2100 INPUT.
*> F2 Funtion key Event시 해당 필드의 정보 display
  PERFORM  DOUBLE_CLICK_EVENT.
ENDMODULE.                 " user_command_2100  INPUT
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
*&      Module  fcode_exit_scr6010  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE FCODE_EXIT_SCR6010 INPUT.

  LEAVE TO SCREEN 0.

ENDMODULE.                 " fcode_exit_scr6010  INPUT
*&---------------------------------------------------------------------*
*&      Module  check_cancel_fields  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE CHECK_CANCEL_FIELDS INPUT.

  CHECK OK-CODE EQ 'ZTIOKAY'.

  IF ZTISSCRCOM-CBUDAT IS INITIAL.
    PERFORM  NO_INPUT_CHECK USING 'ZTISSCRCOM' 'CBUDAT' C_ERROR.
  ENDIF.

ENDMODULE.                 " check_cancel_fields  INPUT
*&---------------------------------------------------------------------*
*&      Module  user_command_scr6010  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_SCR6010 INPUT.

  CASE OK-CODE.
    WHEN 'ZTIDISDOC'.
      PERFORM DISPLAY_MATERIAL_DOC  USING  ZTISSCRCOM-MBLNR
                                           ZTISSCRCOM-MJAHR
                                           '0000'
                                           ZTISSCRCOM-BUKRS.
    WHEN 'ZTIOKAY'.
      LEAVE TO SCREEN 0.
    WHEN 'ZTICANCEL'.
      LEAVE TO SCREEN 0.
    WHEN OTHERS.
  ENDCASE.
*> F2 Funtion key Event시 해당 필드의 정보 display
  PERFORM  DOUBLE_CLICK_EVENT.
  CLEAR: OK-CODE.

ENDMODULE.                 " user_command_scr6010  INPUT
*&---------------------------------------------------------------------*
*&      Module  check_input_fields  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE CHECK_INPUT_FIELDS INPUT.

  CHECK OK-CODE EQ 'ZTIOKAY'.


  IF ZTITGRP-LGORT IS INITIAL.
    PERFORM  NO_INPUT_CHECK USING 'ZTITGRP' 'LGORT' C_ERROR.
  ENDIF.

*  IF ztitgrp-batch IS INITIAL.
*    PERFORM  no_input_check USING 'ZTITGRP' 'BATCH' W_error.
*  ENDIF.

ENDMODULE.                 " check_input_fields  INPUT
*&---------------------------------------------------------------------*
*&      Module  user_command_scr6020  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_SCR6020 INPUT.

  CASE OK-CODE.
    WHEN 'ZTIOKAY'.
      LEAVE TO SCREEN 0.
    WHEN 'ZTICANCEL'.
      LEAVE TO SCREEN 0.
    WHEN OTHERS.
  ENDCASE.
  CLEAR: OK-CODE.

ENDMODULE.                 " user_command_scr6020  INPUT
*&---------------------------------------------------------------------*
*&      Module  tc_7000_modify  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE TC_7000_MODIFY INPUT.

  MOVE-CORRESPONDING ZTISGRB TO G_TC_7000_WA.
*-> 기능개선 75028_배치분할 시 입고번호 추적되게...
  IF G_TC_2130_WA-WERKS = '3204'.
    G_TC_7000_WA-IGRNO = G_TC_2130_WA-IGRNO .
  ENDIF.
*<- 기능개선 75028
*  IF g_tc_7000_wa-grmng GT g_tc_7000wa-grmngl.
*    CLEAR: g_menget.
*    WRITE g_tc_2130_wa-grmngl TO g_menget(15) UNIT g_tc_2130_wa-meins.
*    CONCATENATE g_menget g_tc_2130_wa-meins INTO g_menget.
*    MESSAGE e860 WITH g_menget.
*  ENDIF.
*
*  IF g_tc_2130_wa-bwart IS INITIAL.
*    CLEAR: g_tc_2130_wa-shkzg.
*  ELSE.
*    SELECT SINGLE shkzg
*      INTO g_tc_2130_wa-shkzg
*      FROM t156
*     WHERE bwart EQ g_tc_2130_wa-bwart.
*  ENDIF.
*
**>Get 플랜트명 및 사업장코드.
*  IF NOT g_tc_2130_wa-werks IS INITIAL.
*    SELECT SINGLE name1 j_1bbranch
*      INTO (g_tc_2130_wa-name1, g_tc_2130_wa-bupla)
*      FROM t001w
*     WHERE werks  EQ  g_tc_2130_wa-werks.
*  ELSE.
*    CLEAR: g_tc_2130_wa-name1, g_tc_2130_wa-bupla.
*  ENDIF.
*

*>Get 저장위치명.
  IF NOT G_TC_7000_WA-LGORT IS INITIAL.
    SELECT SINGLE LGOBE
      INTO (G_TC_7000_WA-LGOBE)
      FROM T001L
     WHERE WERKS  EQ  G_TC_7000_WA-WERKS
       AND LGORT  EQ  G_TC_7000_WA-LGORT.
  ELSE.
    CLEAR G_TC_7000_WA-LGOBE.
  ENDIF.

  IF NOT G_TC_7000_WA-HSDAT IS INITIAL.
    G_TC_7000_WA-VFDAT = G_TC_7000_WA-HSDAT +
                         G_TC_7000_WA-MHDHB.
  ELSE.
    CLEAR G_TC_7000_WA-VFDAT.
    IF NOT G_TC_7000_WA-MHDHB IS INITIAL.
      PERFORM NO_INPUT_CHECK USING 'ZTISGRB' 'HSDAT' C_ERROR.
    ENDIF.
  ENDIF.

**> 정가 계산.
*  CALL FUNCTION 'Z_TI_CALC_ITEM_AMOUNT'
*    EXPORTING
*      peinh = g_tc_2130_wa-peinh
*      bpumz = g_tc_2130_wa-bpumz
*      bpumn = g_tc_2130_wa-bpumn
*      menge = g_tc_2130_wa-blmng
*      netpr = g_tc_2130_wa-netpr
*    CHANGING
*      netwr = g_tc_2130_wa-netwr.

*  IF g_tc_2130_wa-cnam IS INITIAL.
*    MOVE: sy-uname TO g_tc_2130_wa-cnam,
*          sy-datlo TO g_tc_2130_wa-cdat,
*          sy-timlo TO g_tc_2130_wa-ctme.
*  ENDIF.
*
*  MOVE: sy-uname TO g_tc_2130_wa-unam,
*        sy-datlo TO g_tc_2130_wa-udat,
*        sy-timlo TO g_tc_2130_wa-utme.

  G_TC_7000_WA-MEINS = ZTISGRIT-MEINS.
  PERFORM SET_SUB_BATCH_RECORD USING G_IBCIT
                                     G_SUBRC.

  MODIFY  G_TC_7000_TEMP
    FROM  G_TC_7000_WA
    INDEX TC_7000-CURRENT_LINE.
  IF SY-SUBRC NE 0.
    APPEND G_TC_7000_WA TO G_TC_7000_TEMP.
  ENDIF.

ENDMODULE.                 " tc_7000_modify  INPUT
*&---------------------------------------------------------------------*
*&      Module  tc_7000_user_command  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE TC_7000_USER_COMMAND INPUT.

*> SEQ NUMBER MAKE.
  PERFORM SET_SUB_BATCH_SEQ.

  CASE OK_CODE.
    WHEN 'P-'   OR 'P--'  OR 'P+'   OR 'P++' OR
         'MARK' OR 'DMRK' OR 'DELE' OR 'INSR'.
*> table control functions ( 삭제, 추가, 선택, 해제, 이동 등 )
      CONCATENATE 'TC_7000_' OK_CODE INTO OK_CODE.

      PERFORM  USER_OK_TC USING    'TC_7000'
                                   'G_TC_7000_TEMP'
                                   'FLAG'
                          CHANGING OK_CODE.
*> SEQ NUMBER MAKE.
      PERFORM SET_SUB_BATCH_SEQ.

    WHEN 'ZTISELECT'.
*> F2 Funtion key Event시 해당 필드의 정보 display
      PERFORM  DOUBLE_CLICK_EVENT.

    WHEN 'ZTI_OVERVIEW'.
      PERFORM DISPLAY_INVENTORY_OVERVIEW     USING ZTISGRIT-MATNR
                                                   ZTISGRIT-WERKS
                                                   ZTISGRIT-LGORT.
    WHEN 'ABBR'.
      CALL FUNCTION 'POPUP_TO_CONFIRM_LOSS_OF_DATA'
        EXPORTING
          TEXTLINE1 = '작업한 Batch 데이타를 저장하지 않습니다.'
          TEXTLINE2 = '정말로 작업을 취소하시겠습니까?'
          TITEL     = '취소 확인'
        IMPORTING
          ANSWER    = G_ANSWER.
      CHECK G_ANSWER EQ 'J'.
      LEAVE TO SCREEN 0.
    WHEN 'BACK'.
      LEAVE TO SCREEN 0.
    WHEN 'CHECK'.
      PERFORM  CHECK_SUB_BATCH_DATA USING C_INFO.
      IF G_LINE EQ 0.
        MESSAGE I911.
      ENDIF.
    WHEN 'BU'.
      PERFORM  CHECK_SUB_BATCH_DATA USING C_ERROR.
      IF G_LINE EQ 0.
        MESSAGE S911.
        ZTISGRIT-GRMNG = ZTISGRIT-ERFMG.
        LEAVE TO SCREEN 0.
      ELSE.
        MESSAGE S910.
      ENDIF.
  ENDCASE.

ENDMODULE.                 " tc_7000_user_command  INPUT
*&---------------------------------------------------------------------*
*&      Module  tc_7000_mark  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE TC_7000_MARK INPUT.

  MODIFY G_TC_7000_TEMP
    FROM G_TC_7000_WA
    INDEX TC_7000-CURRENT_LINE
    TRANSPORTING FLAG.

ENDMODULE.                 " tc_7000_mark  INPUT
