************************************************************************
* Title         :  ZTIR3000                                            *
*                                                                      *
* Description   : 상업송장/접수/조회/삭제/invoice verification 관리    *
*                하는 통합 프로그램                                    *
*                                                                      *
* Creation Date : 2004/02/12                                           *
*                                                                      *
* Author        : SeogBong, Kang                                       *
*                 Copyright ⓒ ASEG Co., LTD. All rights reserved.     *
************************************************************************
*                                                                      *
* Inputs        : None                                                 *
*                                                                      *
* Outputs       : None                                                 *
*                                                                      *
************************************************************************
*                                                                      *
* Processing Steps:                                                    *
* 1.                                                                   *
* 2.                                                                   *
*                                                                      *
************************************************************************
*----------------------------------------------------------------------*
*                M O D I F I C A T I O N   L O G                       *
*----------------------------------------------------------------------*
* Date.      Author.  CSR #            Description.                    *
*----------------------------------------------------------------------*
* 2018.07.09 신재호   기능개선 241468  환율 자동 적용
* 2019.07.16 노승남   기능개선 283274  Comm.Inv 생성 시 적하보험 점검
* 2020.10.23 송승규                    분할송장기능 추가
* 2022.01.27 이원형   CHM2201-00201 엠트론 세금코드 V0 세팅
************************************************************************
************************************************************************
REPORT  ZTIR3000       MESSAGE-ID ZMTI00
                       NO STANDARD PAGE HEADING.

************************************************************************
* User Include Define                                                  *
************************************************************************
INCLUDE ZTIRCOMMTOP.  ">수입 공용 Top Include
INCLUDE ZTIR9000TOP.  ">LIV Simulation Funciton용 Top Include
INCLUDE ZTIR3000T01.  ">수입 I/V 관리 Top Include

************************************************************************
* ALV Class Include Define                                             *
************************************************************************
INCLUDE ZTS_REUSE_ALVFORMS_T02.

************************************************************************
* Local Class Define                                                   *
************************************************************************
INCLUDE ZTSRCOMMCD1.  ">Class Define(lcl_header_basic_model_view)
INCLUDE ZTSRCOMMCD2.  ">Class Define(lcl_Application Class)
INCLUDE ZTIR3000CD1.  ">Others Class Define(lcl_document_view and Etc.)

************************************************************************
* Local Class Implementation                                           *
************************************************************************
INCLUDE ZTSRCOMMCI1.  ">Classe Implementation
INCLUDE ZTSRCOMMCI2.  ">Classe Implementation
INCLUDE ZTSRCOMMCI3.  ">Classe Implementation
INCLUDE ZTIR3000CI1.  ">Invoice document Classes Implementation


DATA:   GF_POST_DIV . "분할송장처리_20201022

*> Local Class Define
DATA: G_TREE            TYPE MMPUR_SCREEN_VIEW,
      G_APPLICATION     TYPE REF TO LCL_APPLICATION,
      G_DOCUMENT_VIEW   TYPE REF TO LCL_DOCUMENT_VIEW,
      G_ITEM_VIEW       TYPE REF TO LCL_ITEM_VIEW,
      G_SHOPPING_BASKET TYPE REF TO LCL_SHOPPING_BASKET.

************************************************************************
* SELECT-OPTIONS / PARAMETERS                                          *
************************************************************************
SELECTION-SCREEN BEGIN OF BLOCK DBSEL WITH FRAME TITLE TEXT-001.
SELECT-OPTIONS:
  S_BUKRS  FOR ZTITBLK-BUKRS                   "회사코드.
                    NO-EXTENSION NO INTERVALS OBLIGATORY
                    MEMORY ID BUK
                    MODIF  ID IOG ,
  S_EKORG  FOR ZTITBLK-EKORG  MODIF ID IOG,     "구매조직.
  S_EKGRP  FOR ZTITBLK-EKGRP  MODIF ID IOG,     "구매그룹.
  S_EBELN  FOR ZTITBLP-EBELN  MODIF ID IOG,     "구매전표번호.
  S_IBLNO  FOR ZTITBLK-IBLNO MODIF ID IOG      "B/L 관리번호.
                              MEMORY ID ZTIIBLNO,
  S_BLNUM  FOR ZTITBLK-BLNUM  MODIF ID IOG,     "B/L 번호.
  S_BLDTY  FOR ZTITBLK-BLDTY  MODIF ID IOG,     "문서종류.
  S_RPTTY  FOR ZTITBLK-RPTTY  MODIF ID IOG,     "수입신고구분.
  S_MATKL  FOR ZTIVPO00-MATKL MODIF ID IOG
                              MEMORY ID MKL,    "자재그룹.
  S_LIFNR  FOR ZTITBLK-LIFNR  MODIF ID IOG,     "공급업체.
  S_BLETD  FOR ZTITBLK-BLETD  MODIF ID IOG,     "ETD.
  S_BLETA  FOR ZTITBLK-BLETA  MODIF ID IOG,     "ETA.
  S_FWDTY  FOR ZTITBLK-FWDTY  MODIF ID IOG,     "운송 방법.
  S_LPONR  FOR ZTITBLK-LPONR  MODIF ID IOG,     "최종품목번호.
  S_WAERS  FOR ZTITBLK-WAERS  MODIF ID IOG,     "통화키.
  S_LGAYN  FOR ZTITBLK-LGAYN  MODIF ID IOG,     "LG대상여부.
  S_IBLIT  FOR ZTITBLP-IBLIT  MODIF ID IOG,     "B/L 품목번호.
  S_NDFTY  FOR ZTITBLP-NDFTY  MODIF ID IOG,     "무환품 종류.
  S_EBELP  FOR ZTITBLP-EBELP  MODIF ID IOG,     "구매문서.
  S_REQNO  FOR ZTITBLP-REQNO  MODIF ID IOG,     "수입의뢰 관리번호.
  S_REQIT  FOR ZTITBLP-REQIT  MODIF ID IOG,     "수입의뢰 품목번호.
  S_CNAM   FOR ZTITBLP-CNAM   MODIF ID IOG,     "작성인.
  S_CDAT   FOR ZTITBLP-CDAT   MODIF ID IOG,     "생성일.
  S_CTME   FOR ZTITBLP-CTME   MODIF ID IOG,     "생성시간.
  S_UNAM   FOR ZTITBLP-UNAM   MODIF ID IOG,     "최종변경인.
  S_UDAT   FOR ZTITBLP-UDAT   MODIF ID IOG,     "변경일.
  S_UTME   FOR ZTITBLP-UTME   MODIF ID IOG.     "최종변경시간.
SELECTION-SCREEN END OF BLOCK DBSEL.

SELECTION-SCREEN BEGIN OF BLOCK LISTS WITH FRAME TITLE TEXT-002.
PARAMETERS: P_VARI LIKE DISVARIANT-VARIANT.
SELECTION-SCREEN END OF BLOCK LISTS.

************************************************************************
* User Include Define                                                  *
************************************************************************
INCLUDE ZTIRCOMMO00.   ">공용 PBO Module Include
INCLUDE ZTIR9000O00.   ">LIV Simulation Funciton용 PBO Include
INCLUDE ZTIR3000O01.   ">I/V 관리 PBO Include
INCLUDE ZTIRCOMMI00.   ">공용 PAI Module Include
INCLUDE ZTIR9000I00.   ">LIV Simulation Funciton용 PAI Include
INCLUDE ZTIR3000I01.   ">I/V 관리 PAI Include
INCLUDE ZTS_REUSE_BDC_SUBROUTINE_F00.  ">BDC 공용 Subroutines
INCLUDE ZTIRCOMMF00.   ">공용 Sub-routine Include
INCLUDE ZTIR9000F00.   ">LIV Simulation Funciton용 Sub-routine Include
INCLUDE ZTIR3000F01.   ">I/V 관리 Sub Routine Include
** JS전선 회사코드 2007/04 KSH --------------------------------------
INCLUDE ZTS_AUTHORIZATION_CHECK. "AUTHORIZATION_CHECK
** JS전선 회사코드 2007/04 KSH --------------------------------------

************************************************************************
* INITIALIZATION Event                                                 *
************************************************************************
INITIALIZATION.
*> Read default layout (description only, w/o field catalog)
  PERFORM  P1000_ALV_FIELDS_INITIAL.
*> Initializaton By Program
  PERFORM  P1000_SET_INITIAL_DATA.
*> Report initialization
  PERFORM  P1001_INITIALIZATION.

************************************************************************
* AT SELECTION-SCREEN Events                                           *
************************************************************************
AT SELECTION-SCREEN.
*> 사용자 Input values Check
  PERFORM P1100_CHECK_INPUT_VALUES.
*> 사용자 레이아웃 Input values Check
  PERFORM P1101_CHECK_VARIANT_VALUE.
** JS전선 회사코드 2007/04 KSH --------------------------------------
*> AUTHORIZATION_CHECK
  PERFORM P1102_AUTHORIZATION_CHECK USING S_BUKRS-LOW.
** JS전선 회사코드 2007/04 KSH --------------------------------------

*> 레이아웃 HELP
AT SELECTION-SCREEN ON VALUE-REQUEST FOR P_VARI.
  PERFORM P1102_F4_FOR_VARIANT.

************************************************************************
* START-OF-SELECTION Event                                             *
************************************************************************
START-OF-SELECTION.
*> 검색조건에 해당하는 데이타를 Select.
  PERFORM P2000_DATA_SELECTIONS.
*> Header table과 List(Items) table를 만듬.
  PERFORM P2100_HEADER_AND_LIST_BUILD.

************************************************************************
* END-OF-SELECTION Event                                               *
************************************************************************
END-OF-SELECTION.
  DESCRIBE TABLE IT_TAB_H LINES G_LINE.
  IF NOT G_LINE IS INITIAL.
*> PROGRESS Display.
    G_LINEN    = 90.
    G_OUT_TEXT = '리스트를 구성 중입니다 %99999%%'(P03).
    REPLACE '%99999%'(P99) WITH G_LINEN INTO G_OUT_TEXT.
    PERFORM SHOW_PROGRESS_BAR(ZTIR0000) USING G_OUT_TEXT G_LINEN.

    PERFORM 3000_FIELD_CATEGORY_BUILD.
    PERFORM 3100_SET_COLOR_INFOMATION.
    PERFORM 3200_KEY_INFOMATION_BUILD.
    PERFORM 3300_EVENT_EXIT_TABLE_BUILD.
    PERFORM 3400_COMMENT_BUILD.
    PERFORM 3500_SORT_TABLE_BUILD.
    PERFORM 3600_EVENT_TABLE_BUILD USING : SLIS_EV_TOP_OF_PAGE,
                                           SLIS_EV_PF_STATUS_SET,
                                           SLIS_EV_USER_COMMAND.
    PERFORM 3700_LAYOUT_BUILD.
    PERFORM 3910_CALL_ALV_HIERSEQ.
*> Program 종료.
    PERFORM  P9000_PROGRAM_EXIT.
  ELSE.
    MESSAGE S902.
  ENDIF.

************************************************************************
* TOP-OF-PAGE Event                                                    *
************************************************************************
TOP-OF-PAGE.

************************************************************************
* END-OF-PAGE Event                                                    *
************************************************************************
END-OF-PAGE.

************************************************************************
* TOP-OF-PAGE DURING LINE-SELECTION Event                              *
************************************************************************
TOP-OF-PAGE DURING LINE-SELECTION.


************************************************************************
* AT LINE-SELECTION Event                                              *
************************************************************************
AT LINE-SELECTION.


************************************************************************
* AT USER-COMMAND Event                                                *
************************************************************************
AT USER-COMMAND.

*eject
************************************************************************
*                                                                      *
* S U B R O U T I N E S                                                *
*                                                                      *
************************************************************************


*eject
************************************************************************
*                                                                      *
* P B O   M O D U L E                                                  *
*                                                                      *
************************************************************************

*eject
************************************************************************
*                                                                      *
* P A I   M O D U L E                                                  *
*                                                                      *
************************************************************************
*&---------------------------------------------------------------------*
*&      Form  CHECK_REQ_TT_SCREEN
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM CHECK_REQ_TT_SCREEN .


  DATA : LV_ANSWER,
         LV_LINE(100).

  CLEAR : LV_ANSWER .

  DATA : LT_PARAM LIKE TABLE OF RSPARAMS WITH HEADER LINE.


  SELECT SINGLE *
     FROM ZTITIVP
    WHERE IVONO EQ ZTITIVK-IVONO
      AND REQNO EQ SPACE.

  CHECK SY-SUBRC EQ 0.

  CONCATENATE
        '생성된 송장(' ZTITIVK-IVONO ')을 사후송금요청 하시겠습니까?'
        INTO LV_LINE.

  CALL FUNCTION 'POPUP_TO_CONFIRM'
    EXPORTING
      TITLEBAR              = '사후송금요청'
      TEXT_QUESTION         = LV_LINE
      TEXT_BUTTON_1         = '확인'
      ICON_BUTTON_1         = 'ICON_OKAY'
      TEXT_BUTTON_2         = '취소'
      ICON_BUTTON_2         = 'ICON_CANCEL'
      DEFAULT_BUTTON        = '2'             "Default Button: 취소
      DISPLAY_CANCEL_BUTTON = ' '
      POPUP_TYPE            = 'ICON_MESSAGE_QUESTION'
    IMPORTING
      ANSWER                = LV_ANSWER
    EXCEPTIONS
      TEXT_NOT_FOUND        = 1
      OTHERS                = 2.


  IF LV_ANSWER = '1'.
    SET PARAMETER ID 'ZTIIBLNO' FIELD ZTITIVP-IBLNO.
    SET PARAMETER ID 'ZTIT300'  FIELD 'X'.
    CALL TRANSACTION 'ZTIR001' AND SKIP FIRST SCREEN .
  ENDIF.


ENDFORM.                    " CHECK_REQ_TT_SCREEN
*&---------------------------------------------------------------------*
*&      Form  FI_IV_POST_DIV
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM FI_IV_POST_DIV   USING P_EMPFK    LIKE ZTITCSK-EMPFK
                            P_BUPLA    LIKE ZTITCSK-BUPLA
                            P_PTDCL    LIKE ZTITCSK-PTDCL.


  DATA : LV_MOD LIKE SY-TFILL,
         IT_TAB_T TYPE TABLE OF T_TC_2130 WITH HEADER LINE,
         LT_TABIX LIKE SY-TFILL,
         LT_IVK   LIKE ZTITIVK.


  SELECT SINGLE * INTO LT_IVK
         FROM ZTITIVK WHERE IVONO  EQ ZTITIVK-IVONO.

   IF SY-SUBRC EQ 0 OR ZTITIVK-BELNR IS NOT INITIAL.
     MESSAGE S999  WITH
        '저장 또는 회계처리된 송장은 처리할수 없습니다'.
     EXIT.
  ENDIF.


*> 공용 대화상자(메시지 통일).
  IF OK_CODE EQ 'ZTIPOST'.
    CALL FUNCTION 'Z_TI_POPUP_TO_CONFIRM_MESSAGE'
      EXPORTING
        XMODE  = C_CHARP
      IMPORTING
        ANSWER = G_ANSWER.

    IF G_ANSWER NE C_CHARY.
      EXIT.
    ENDIF.
  ENDIF.

  MOVE IT_TAB[] TO IT_TAB_T[].
  CLEAR : IT_TAB , IT_TAB[], ZTITIVK-IVAMP, ZTITIVK-IVAMT  .

  LOOP AT IT_TAB_T.
    LT_TABIX = SY-TABIX + 1.
    LV_MOD = SY-TABIX MOD 100.

    APPEND IT_TAB_T TO  IT_TAB .
    ZTITIVK-IVAMT  =  ZTITIVK-IVAMP
                   =  ZTITIVK-IVAMP + IT_TAB_T-REFWR.
    IF LV_MOD EQ 0.
      CLEAR SY-CALLD.
      PERFORM FI_IV_DOCUMENT_DIV USING ' '
                                 ZTITIVK-BUPLA
                                 C_CHARM.
      IF G_SUBRC NE 0.
        EXIT.
      ELSE.
        WAIT UP TO 2 SECONDS.
      ENDIF.
      CLEAR : IT_TAB , IT_TAB[],
              ZTITIVK-IVONO, ZTITIVK-BELNR , ZTITIVK-IVAMP,
              ZTITIVK-IVAMT .
    ENDIF.
  ENDLOOP.

  IF G_SUBRC NE 0.
    LOOP AT IT_TAB_T FROM LT_TABIX .
      APPEND IT_TAB_T TO IT_TAB.
     ZTITIVK-IVAMT  =  ZTITIVK-IVAMP
                    =  ZTITIVK-IVAMP + IT_TAB_T-REFWR.
    ENDLOOP.
    CLEAR : ZTITIVK-BELNR, ZTITIVK-IVONO .
    EXIT.
  ENDIF.

  IF IT_TAB[] IS NOT INITIAL.
    PERFORM FI_IV_DOCUMENT_DIV  USING ' '
                                  ZTITIVK-BUPLA
                                  C_CHARM.
  ENDIF.

  IF G_SUBRC EQ 0.
    PERFORM P9000_CAME_TO_AN_END.
    PERFORM P9000_PROGRAM_EXIT.   ">Program Exit.
  ENDIF.

ENDFORM.                    " FI_IV_POST_DIV
