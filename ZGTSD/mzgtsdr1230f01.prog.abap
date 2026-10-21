*&---------------------------------------------------------------------*
*&  Include           MZGTSDR1230
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  GET_BUKRS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM GET_BUKRS  USING    P_WERKS
                CHANGING P_BUKRS.

  CALL FUNCTION 'Z_FI_GET_ORG_CODE'
    EXPORTING
      I_WERKS = P_WERKS
*     I_GSBER =
*     I_PRCTR =
*     I_UNAME =
*     I_BUKRS =
*     I_KOKRS =
    IMPORTING
      E_BUKRS = P_BUKRS.
*   E_KOKRS       =


ENDFORM.                    " GET_BUKRS
*&---------------------------------------------------------------------*
*&      Form  FILL_TREE_STRUCTURE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM FILL_TREE_STRUCTURE .

  CLEAR   : GS_NODE.
  REFRESH : GT_NODE.

*___개요
  CLEAR : GS_NODE.
  GS_NODE-NODE_KEY = '1'.
  GS_NODE-TEXT     = '개요'.
  GS_NODE-EXPANDER = ' '.
  APPEND GS_NODE TO GT_NODE.

*___자재/불량정보
  CLEAR : GS_NODE.
  GS_NODE-NODE_KEY = '2'.
  GS_NODE-TEXT     = '자재/불량정보'.
  GS_NODE-EXPANDER = ' '.
  GS_NODE-N_IMAGE = '@FA@'.
  APPEND GS_NODE TO GT_NODE.

  IF GV_TRTYP <> 'H' AND
    GS_100-STATUS <> 'CL10' AND GS_100-STATUS <> 'CL20'.

*___물류처리
    CLEAR : GS_NODE.
    GS_NODE-NODE_KEY = '3'.
    GS_NODE-TEXT     = '물류처리'.
    GS_NODE-ISFOLDER = 'X'.
*    GS_NODE-EXPANDER = 'X'.
    APPEND GS_NODE TO GT_NODE.

*___물류처리 - 반품/출고
    CLEAR : GS_NODE.
    GS_NODE-NODE_KEY  = '4'.
    GS_NODE-RELATKEY  = '3'.
    GS_NODE-TEXT      = '반품/출고'.
    GS_NODE-RELATSHIP = CL_GUI_SIMPLE_TREE=>RELAT_LAST_CHILD.
    APPEND GS_NODE TO GT_NODE.

*->[가온전선]--------------------CHG S
**___물류처리 - 반품검사로트
*    CLEAR : GS_NODE.
*    GS_NODE-NODE_KEY  = '5'.
*    GS_NODE-RELATKEY  = '3'.
*    GS_NODE-TEXT      = '반품검사로트'.
*    GS_NODE-RELATSHIP = CL_GUI_SIMPLE_TREE=>RELAT_LAST_CHILD.
*    APPEND GS_NODE TO GT_NODE.
*
*
**___손실금액
*    CLEAR : GS_NODE.
*    GS_NODE-NODE_KEY = '6'.
*    GS_NODE-TEXT     = '손실금액'.
*    GS_NODE-ISFOLDER = 'X'.
**    GS_NODE-EXPANDER = 'X'.
*    APPEND GS_NODE TO GT_NODE.

**___손실금액 - 물류관련 손실금액
*    CLEAR : GS_NODE.
*    GS_NODE-NODE_KEY  = '7'.
*    GS_NODE-RELATKEY  = '6'.
*    GS_NODE-TEXT      = '물류관련손실금액'.
*    GS_NODE-N_IMAGE = '@Q7@'.
*    GS_NODE-RELATSHIP = CL_GUI_SIMPLE_TREE=>RELAT_LAST_CHILD.
*    APPEND GS_NODE TO GT_NODE.
*
**___손실금액 - A/S 관련 손실금액
*    CLEAR : GS_NODE.
*    GS_NODE-NODE_KEY  = '8'.
*    GS_NODE-RELATKEY  = '6'.
*    GS_NODE-TEXT      = 'A/S 관련손실금액'.
*    GS_NODE-N_IMAGE = '@Q6@'.
*    GS_NODE-RELATSHIP = CL_GUI_SIMPLE_TREE=>RELAT_LAST_CHILD.
*    APPEND GS_NODE TO GT_NODE.
*-<[가온전선]--------------------CHG E


*___시정조치
    CLEAR : GS_NODE.
    GS_NODE-NODE_KEY = '9'.
    GS_NODE-TEXT     = '시정조치'.
    GS_NODE-N_IMAGE = '@GS@'.
    APPEND GS_NODE TO GT_NODE.

*___처리결과/승인
    CLEAR : GS_NODE.
    GS_NODE-NODE_KEY = '10'.
    GS_NODE-TEXT     = '처리결과/승인'.
    GS_NODE-N_IMAGE = '@8X@'.
    APPEND GS_NODE TO GT_NODE.

*___불만이력
    CLEAR : GS_NODE.
    GS_NODE-NODE_KEY = '11'.
    GS_NODE-TEXT     = '불만이력'.
    GS_NODE-N_IMAGE = '@96@'.
    APPEND GS_NODE TO GT_NODE.
  ENDIF.

ENDFORM.                    " FILL_TREE_STRUCTURE
*&---------------------------------------------------------------------*
*&      Form  SET_SUBSCREEN
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM SET_SUBSCREEN  USING    P_NODE_KEY.
  IF  GV_TRTYP <> 'A'.
    PERFORM CHECK_DATA_CHANGED USING GV_FLAG.

    IF GV_FLAG = 'J'.
      PERFORM SAVE_COMPLAIN_DATA USING 'X'.
      PERFORM GET_COMPLAIN_DATA.
*    ELSEIF GV_FLAG = 'N' OR GV_FLAG = SPACE.
*      LEAVE TO SCREEN 0.
    ELSEIF GV_FLAG = 'A'.
      EXIT.
    ENDIF.

  ENDIF.

  CLEAR : GV_SUBSCR_1, GV_SUBSCR_2, GV_SUBSCR_3,
          GV_SUBSCR_4, GV_SUBSCR_5, GV_SUBSCR_6,
          GV_SUBSCR_7, GV_SUBSCR_8, GV_SUBSCR_9.

  GV_NODE_KEY = P_NODE_KEY.

  CASE P_NODE_KEY.
    WHEN '1'.   "개요
      CLEAR GV_NO.
      GV_TITLE    = '개요'.
      GV_SUBSCR_1 = '0200'.
      GV_SUBSCR_2 = '0210'.
      GV_SUBSCR_3 = '0220'.
      GV_SUBSCR_4 = '0230'.
      GV_SUBSCR_5 = '0240'.
      GV_SUBSCR_6 = '0250'.
      GV_SUBSCR_7 = '0260'.

    WHEN '2'.   "자재/불량정보
*      IF GV_Y IS INITIAL.
*        CLEAR: GV_ANSWER.
*        %%POPUP_TO_CONFIRM_STEP '저장되지 않은 정보가 있습니다.'
*                                '저장 후 진행하시겠습니까?' '저장'.
*        CHECK GV_ANSWER = 'J'.
*        OK_SAVE = 'SAVE'.
*        CASE OK_SAVE.
*          WHEN 'SAVE'.
*            PERFORM SAVE_COMPLAIN_DATA USING 'X'.
*        ENDCASE.
*      ENDIF.
      GV_TITLE    = '자재/불량정보'.
      GV_SUBSCR_1 = '0300'.
      GV_SUBSCR_2 = '0210'.
      GV_SUBSCR_3 = '0310'.

    WHEN '3'.   "물류처리
      GV_NO = 'X'.
      GV_TITLE    = '물류처리'.
      GV_SUBSCR_1 = '0400'.
      GV_SUBSCR_2 = '0210'.
      GV_SUBSCR_3 = '0410'.
    WHEN '4'.   "물류처리 - 반품/출고
      CLEAR GV_NO.
      GV_TITLE    = '반품/출고'.
      GV_SUBSCR_1 = '0500'.
      GV_SUBSCR_2 = '0510'.
    WHEN '5'.   "물류처리 - 반품검사로트
      CLEAR GV_NO.
      GV_TITLE    = '반품검사로트'.
      GV_SUBSCR_1 = '0600'.
      GV_SUBSCR_2 = '0610'.
    WHEN '6'.   "손실금액
      GV_NO = 'X'.
      GV_TITLE    = '손실금액'.
      GV_SUBSCR_1 = '0700'.
      GV_SUBSCR_2 = '0210'.
      GV_SUBSCR_3 = '0710'.
    WHEN '7'.   "손실금액 - 물류관련 손실금액
      CLEAR GV_NO.
      GV_TITLE    = '물류관련손실금액'.
      GV_SUBSCR_1 = '0800'.
      GV_SUBSCR_2 = '0810'.
    WHEN '8'.   "손실금액 - A/S 관련 손실금액
      CLEAR GV_NO.
      GV_TITLE    = 'A/S 관련손실금액'.
      GV_SUBSCR_1 = '0900'.
      GV_SUBSCR_2 = '0910'.
    WHEN '9'.   "시정조치
      CLEAR GV_NO.
      GV_TITLE    = '시정조치'.
      GV_SUBSCR_1 = '1100'.
      GV_SUBSCR_2 = '0210'.
      GV_SUBSCR_3 = '0250'.
      GV_SUBSCR_4 = '0230'.
      GV_SUBSCR_5 = '0240'.
      GV_SUBSCR_6 = '1110'.
      GV_SUBSCR_7 = '1120'.
      GV_SUBSCR_8 = '1130'.
      GV_SUBSCR_9 = '1140'.
    WHEN '10'.  "처리결과/승인
      CLEAR GV_NO.
      GV_TITLE    = '처리결과/승인'.
      GV_SUBSCR_1 = '1200'.
      GV_SUBSCR_2 = '0210'.
      GV_SUBSCR_3 = '0250'.
      GV_SUBSCR_4 = '1210'.
      GV_SUBSCR_5 = '0260'.

*      GV_SUBSCR_1 = '1200'.
*      GV_SUBSCR_5 = '0210'.   "개요
*      GV_SUBSCR_3 = '0250'.   "불만처리담당자
*      GV_SUBSCR_4 = '1210'.  "editor
*      GV_SUBSCR_2 = '0260'.   "변경정보
*

    WHEN '11'.  "불만이력
      CLEAR GV_NO.
      GV_TITLE    = '불만이력'.
      GV_SUBSCR_1 = '1300'.
      GV_SUBSCR_2 = '1310'.
*{ WBS 집행금액 관련
    WHEN '12'.
      CLEAR GV_NO.
      GV_TITLE    = 'WBS 집행금액'.
      GV_SUBSCR_1 = '1400'.
      GV_SUBSCR_2 = '1410'.
*} WBS집행금액 관련
  ENDCASE.

ENDFORM.                    " SET_SUBSCREEN
*&---------------------------------------------------------------------*
*&      Form  NODE_SET_IMAGE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM NODE_SET_IMAGE  USING    P_NODE  TYPE TV_NODEKEY
                              P_IMAGE TYPE TV_IMAGE.
  DATA: LS_NODE    LIKE MTREESNODE.

  READ TABLE GT_NODE INTO LS_NODE WITH KEY NODE_KEY = P_NODE.
  IF SY-SUBRC = 0.
    CALL METHOD GC_TREE_01->NODE_SET_N_IMAGE
      EXPORTING
        NODE_KEY = P_NODE
        N_IMAGE  = P_IMAGE.

    CALL METHOD GC_TREE_01->NODE_SET_EXP_IMAGE
      EXPORTING
        NODE_KEY  = P_NODE
        EXP_IMAGE = P_IMAGE.
  ENDIF.

ENDFORM.                    " NODE_SET_IMAGE
*&---------------------------------------------------------------------*
*&      Form  AUTHORITY_CHECKING_PROC
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GS_100_WERKS  text
*      <--P_GV_SUBRC  text
*----------------------------------------------------------------------*
FORM AUTHORITY_CHECKING_PROC  USING P_WERKS TYPE WERKS_D
                              CHANGING P_SUBRC TYPE SY-SUBRC .

  CALL FUNCTION 'ZQM_AUTHORIZATION_CHECK'
    EXPORTING
      I_WERKS = P_WERKS
      I_TYPE  = '1'
    IMPORTING
      E_SUBRC = P_SUBRC.

ENDFORM.                    " AUTHORITY_CHECKING_PROC
*&---------------------------------------------------------------------*
*&      Form  GET_SUL_STATUS_TXT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_0395   text
*      -->P_GS_100_STATUS  text
*      <--P_GS_100_STATUST  text
*----------------------------------------------------------------------*
FORM GET_SUL_STATUS_TXT  USING    P_DOMNAME P_VAL
                         CHANGING P_TEXT.


  IF  NOT  P_VAL IS INITIAL.

    DATA: L_DOMNAME LIKE DD07L-DOMNAME,
          L_VALUE   LIKE DD07L-DOMVALUE_L,
          L_DD07V   LIKE DD07V,
          L_RC      LIKE SY-SUBRC.

*& 엠트론인 경우 중요도 'B' 설정 금지 (C20120830_74181)_21020830
*->[가온전선]--------------------CHG S
    L_DOMNAME = P_DOMNAME.
*    IF GS_100-BUKRS = '3000' OR GV_BUKRS = '3000'.
*      IF P_VAL = 'B'.
*        CLEAR : P_VAL.
*        MESSAGE E001 WITH '적합하지 않은 중요도 값입니다!'.
*      ENDIF.
*      L_DOMNAME = 'ZPRIORITY_2'.
*    ELSE.
*      L_DOMNAME = P_DOMNAME.
*    ENDIF.
*-<[가온전선]--------------------CHG E
    L_VALUE   = P_VAL.

    CLEAR: L_DD07V, L_RC.
    CALL FUNCTION 'DD_DOMVALUE_TEXT_GET'
      EXPORTING
        DOMNAME  = L_DOMNAME
        VALUE    = L_VALUE
        LANGU    = SY-LANGU
*       BYPASS_BUFFER       = ' '
      IMPORTING
        DD07V_WA = L_DD07V
        RC       = L_RC.

    P_TEXT = L_DD07V-DDTEXT.

  ELSE.
    CLEAR: P_TEXT.
  ENDIF.

ENDFORM.                    " GET_SUL_STATUS_TXT
*&---------------------------------------------------------------------*
*&      Form  GET_NUMBER_CHECK_TDNAME
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_0490   text
*----------------------------------------------------------------------*
FORM GET_NUMBER_CHECK_TDNAME  USING   P_GUBUN TYPE C.
  IF P_GUBUN EQ '1'.

    CALL FUNCTION 'NUMBER_GET_NEXT'
      EXPORTING
        NR_RANGE_NR             = '01'
        OBJECT                  = 'ZQMCOMP1'
        QUANTITY                = '1'
      IMPORTING
        NUMBER                  = G_NUMBER
      EXCEPTIONS
        INTERVAL_NOT_FOUND      = 1
        NUMBER_RANGE_NOT_INTERN = 2
        OBJECT_NOT_FOUND        = 3
        QUANTITY_IS_0           = 4
        QUANTITY_IS_NOT_1       = 5
        INTERVAL_OVERFLOW       = 6
        BUFFER_OVERFLOW         = 7
        OTHERS                  = 8.
    IF SY-SUBRC <> 0.
      MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
              WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
      EXIT.
    ENDIF.

  ENDIF.
  CONCATENATE G_HEADER-TDOBJECT G_HEADER-TDID G_NUMBER
              INTO G_HEADER-TDNAME.
ENDFORM.                    " GET_NUMBER_CHECK_TDNAME
*&---------------------------------------------------------------------*
*&      Form  PROCESS_CHECK
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM PROCESS_CHECK .

  CLEAR: GV_FORM_FLG, GS_CHECK.

  PERFORM  CHECK_DATA_100       CHANGING  GV_FORM_FLG
                                          GS_CHECK.

* 점검후 ERROR가 존재시 메세지 출력
  IF  GV_FORM_FLG  IS INITIAL.
*    MESSAGE S001  WITH '점검이 완료되었습니다.'.
  ELSE.
* 2012.11 수정. 불만내용/요구사항 입력 안해도 자재/불량정보로 넘어가는
* 오류
*    MESSAGE I002  WITH  GS_CHECK-RESULT1
*                        GS_CHECK-RESULT2.
    MESSAGE E002  WITH  GS_CHECK-RESULT1
                        GS_CHECK-RESULT2
*            DISPLAY LIKE 'I'. "자체개선_100782
            DISPLAY LIKE 'E'. "자체개선_100782
  ENDIF.

ENDFORM.                    " PROCESS_CHECK
*&---------------------------------------------------------------------*
*&      Form  CHECK_DATA_100
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_GV_FORM_FLG  text
*      <--P_GS_CHECK  text
*----------------------------------------------------------------------*
FORM CHECK_DATA_100  CHANGING P_FLG
                              P_CHECK LIKE GS_CHECK.

* 접수일
  IF  GS_100-RCEPDT  IS INITIAL.
    P_FLG            =  'X'.
*    P_CHECK-RESULT1  =  '접수일은 필수입력 항목입니다.'.
    CONCATENATE P_CHECK-RESULT1 '/접수일'
           INTO P_CHECK-RESULT1.
  ENDIF.

* 고객
  IF  GS_100-KUNUM  IS INITIAL.
    P_FLG            =  'X'.
*    P_CHECK-RESULT1  =  '고객은 필수입력 항목입니다.'.
    CONCATENATE P_CHECK-RESULT1 '/고객'
           INTO P_CHECK-RESULT1.
  ENDIF.

* 중요도
  IF  GS_100-PRIORITY  IS INITIAL.
    P_FLG            =  'X'.
*    P_CHECK-RESULT1  =  '중요도는 필수입력 항목입니다.'.
    CONCATENATE P_CHECK-RESULT1 '/중요도'
           INTO P_CHECK-RESULT1.
  ENDIF.

* 손익센터
  IF  GS_100-PRCTR  IS INITIAL.
    P_FLG            =  'X'.
*    P_CHECK-RESULT1  =  '손익센터는 필수입력 항목입니다.'.
    CONCATENATE P_CHECK-RESULT1 '/손익센터'
       INTO P_CHECK-RESULT1.
  ENDIF.

* 플랜트
  IF  GS_100-WERKS_H  IS INITIAL.
    P_FLG            =  'X'.
*    P_CHECK-RESULT1  =  '플랜트는 필수입력 항목입니다.'.
    CONCATENATE P_CHECK-RESULT1 '/플랜트'
       INTO P_CHECK-RESULT1.
  ENDIF.

* 주제
  IF  GS_100-QMTXT  IS INITIAL.
    P_FLG            =  'X'.
*    P_CHECK-RESULT1  =  '주제는 필수입력 항목입니다.'.
    CONCATENATE P_CHECK-RESULT1 '/주제'
       INTO P_CHECK-RESULT1.
  ENDIF.

* 접수자
  IF  GS_100-RCPERNR  IS INITIAL.
    P_FLG            =  'X'.
*    P_CHECK-RESULT1  =  '접수자 사번은 필수입력 항목입니다.'.
    CONCATENATE P_CHECK-RESULT1 '/접수자사번'
       INTO P_CHECK-RESULT1.
  ENDIF.

* 코디네이터
  IF  GS_100-CORDINR  IS INITIAL.
    P_FLG            =  'X'.
*    P_CHECK-RESULT1  =  '코디네이터 사번은 필수입력 항목입니다.'.
    CONCATENATE P_CHECK-RESULT1 '/코디네이터사번'
       INTO P_CHECK-RESULT1.
  ENDIF.

*C20110628_13547
* 불만내용
  READ TABLE G_LINES1_N WITH KEY TDFORMAT = '*'.
  IF  SY-SUBRC NE 0.
    P_FLG            =  'X'.
*    P_CHECK-RESULT1  =  '코디네이터 사번은 필수입력 항목입니다.'.
    CONCATENATE P_CHECK-RESULT1 '/불만내용'
       INTO P_CHECK-RESULT1.
  ENDIF.


* 고객요구사항
  READ TABLE G_LINES2_N WITH KEY TDFORMAT = '*'.
  IF  SY-SUBRC NE 0.
    P_FLG            =  'X'.
*    P_CHECK-RESULT1  =  '코디네이터 사번은 필수입력 항목입니다.'.
    CONCATENATE P_CHECK-RESULT1 '/고객요구사항'
       INTO P_CHECK-RESULT1.
  ENDIF.




*C20110628_13547
  REPLACE '/' IN P_CHECK-RESULT1 WITH '필수 항목 : '.

ENDFORM.                    " CHECK_DATA_100
*&---------------------------------------------------------------------*
*&      Form  SAVE_PROCESS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_0282   text
*      -->P_GS_200  text
*----------------------------------------------------------------------*
FORM SAVE_PROCESS  USING  PV_FLAG.

  CLEAR: GV_ANSWER.

  IF PV_FLAG IS INITIAL.
    %%POPUP_TO_CONFIRM_STEP '입력하신 Data를 저장하시겠습니까?' ' '
    '저장'.
  ELSE.
    GV_ANSWER = 'J'.
  ENDIF.

  IF GV_ANSWER = 'J'.
*  접수번호 생성
    GV_RCEPNO = GS_100-RCEPNO.

    IF  GV_RCEPNO  IS INITIAL.
      PERFORM  CLEATE_RECEIPT_NUMBER  CHANGING  GV_RCEPNO
                                                GV_FORM_FLG.

      IF  GV_FORM_FLG  IS INITIAL.
        PERFORM  INSERT_CUSTOM_CLAIM_100  USING  GV_RCEPNO
                                       CHANGING  GV_FORM_FLG.
      ENDIF.
    ELSE.
      PERFORM MODIFY_CUSTOM_CLAIM_100 USING GV_RCEPNO
                                   CHANGING GV_FORM_FLG.

    ENDIF.
  ELSE.
    GV_FORM_FLG = 'X'.
  ENDIF.

ENDFORM.                    " SAVE_PROCESS
*&---------------------------------------------------------------------*
*&      Form  CLEATE_RECEIPT_NUMBER
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_GV_RCEPNO  text
*      <--P_GV_FORM_FLG  text
*----------------------------------------------------------------------*
FORM CLEATE_RECEIPT_NUMBER  CHANGING P_RCEPNO
                                     P_FLG.

  CALL FUNCTION 'NUMBER_GET_NEXT'
    EXPORTING
      NR_RANGE_NR             = '01'
      OBJECT                  = 'ZQM_RCEPNO'
      QUANTITY                = '1'
    IMPORTING
      NUMBER                  = P_RCEPNO
    EXCEPTIONS
      INTERVAL_NOT_FOUND      = 1
      NUMBER_RANGE_NOT_INTERN = 2
      OBJECT_NOT_FOUND        = 3
      QUANTITY_IS_0           = 4
      QUANTITY_IS_NOT_1       = 5
      INTERVAL_OVERFLOW       = 6
      OTHERS                  = 7.

  IF  SY-SUBRC  NE  0.
    P_FLG    =  'X'.
  ENDIF.

ENDFORM.                    " CLEATE_RECEIPT_NUMBER
*&---------------------------------------------------------------------*
*&      Form  GET_USRID
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GS_100_RCPERNR  text
*      <--P_GS_100_RCPERNRT  text
*      <--P_GS_100_RCNAM  text
*      <--P_GS_100_RCNAMT  text
*----------------------------------------------------------------------*
FORM GET_USRID  USING    VALUE(P_PERNR)
                CHANGING P_PERNRT   LIKE ZQMT0011H-CORDINRT
                         P_PERNRID  LIKE ZQMT0011H-CORDI
                         P_PERNRIDT LIKE ZQMT0011H-CORDIT.

  CLEAR : G_PERNR, G_USRID.

  CHECK P_PERNR IS NOT INITIAL.

  SELECT *
     FROM ZZPA0001  UP TO 1 ROWS
    WHERE PERNR = P_PERNR
      AND ENDDA = '99991231' .
  ENDSELECT.

  IF SY-SUBRC EQ 0.
    P_PERNRT = ZZPA0001-SNAME.

  ELSE.
    CLEAR : P_PERNRT, P_PERNR, P_PERNRID, P_PERNRIDT.
    IF GV_FLAG = '1'.
      MESSAGE E001 WITH TEXT-015. " DISPLAY LIKE 'E'.
    ELSEIF GV_FLAG = '2'.
      MESSAGE E001 WITH TEXT-016. " DISPLAY LIKE 'E'.
    ELSEIF GV_FLAG = '3'.
      MESSAGE E001 WITH TEXT-017. " DISPLAY LIKE 'E'.
    ELSEIF GV_FLAG = '4'.
      MESSAGE E001 WITH TEXT-018. " DISPLAY LIKE 'E'.
    ENDIF.
  ENDIF.

  G_PERNR = P_PERNR.
  CALL FUNCTION 'Z_QM_GET_USERID'
    EXPORTING
      I_PERNR = G_PERNR
    IMPORTING
      E_USRID = G_USRID.

  IF G_USRID IS INITIAL.

    IF GV_FLAG = '1'.
      MESSAGE E003 WITH TEXT-019 TEXT-020 TEXT-024. " DISPLAY LIKE 'W'.

    ELSEIF GV_FLAG = '2'.
      MESSAGE E003 WITH TEXT-021 TEXT-020 TEXT-024. " DISPLAY LIKE 'W'.

    ELSEIF GV_FLAG = '3'.
      MESSAGE E003 WITH TEXT-022 TEXT-020 TEXT-024. " DISPLAY LIKE 'W'.

    ELSEIF GV_FLAG = '4'.
      MESSAGE E003 WITH TEXT-023 TEXT-020 TEXT-024. " DISPLAY LIKE 'W'.
    ENDIF.

  ENDIF.

*-[가온전선]--------------------------USER ID -S
  G_USRID = |{ G_USRID ALPHA = OUT }|.
*-[가온전선]--------------------------USER ID -E

  P_PERNRID = G_USRID.


  IF  NOT  P_PERNRID  IS INITIAL.
    PERFORM  RESPT_READ  USING    'KO'    P_PERNRID
                         CHANGING  P_PERNRIDT.
  ELSE.
    CLEAR: P_PERNRIDT.
  ENDIF.


  IF SY-SUBRC <> 0.
    CLEAR: P_PERNRIDT.

  ENDIF.

ENDFORM.                    " GET_USRID
*&---------------------------------------------------------------------*
*&      Form  RESPT_READ
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_0883   text
*      -->P_P_PERNRID  text
*      <--P_P_PERNRIDT  text
*----------------------------------------------------------------------*
FORM RESPT_READ  USING     P_PARVW      LIKE IHPA-PARVW
                           P_PARNR      LIKE IHPA-PARNR
                 CHANGING  P_NAME.

  CLEAR: DIADRP, DIADRC, DIADR.

  CALL FUNCTION 'PM_PARTNER_READ'
    EXPORTING
      PARVW                = P_PARVW
      PARNR                = P_PARNR
    IMPORTING
      DIADRP_WA            = DIADRP
      DIADRC_WA            = DIADRC
      DIADR_WA             = DIADR
*     parnr_exp            = p_parnr
    EXCEPTIONS
      NO_VALID_PARNR_TODAY = 01
      OTHERS               = 02.
*  if sy-subrc <> 0.
*    clear: diadrp, diadrc, diadr.
*  endif.

*  F_KUNNR = DIADRP-KUNNR.
  P_NAME    =  DIADR-NAME_LIST.

ENDFORM.                    " RESPT_READ
*&---------------------------------------------------------------------*
*&      Form  DSTGR_READ
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GS_100_DSTGR  text
*      <--P_GS_100_DSTGRT  text
*----------------------------------------------------------------------*
FORM DSTGR_READ  USING    P_DSTGR
                 CHANGING P_DSTGRT.

  IF  NOT  P_DSTGR  IS INITIAL.

    SELECT  SINGLE BEZEI
             INTO P_DSTGRT
             FROM TVAUT
            WHERE SPRAS = SY-LANGU
              AND AUGRU = P_DSTGR.   "오더사유(불만사유)

    IF  SY-SUBRC  NE  0.
      MESSAGE E001  WITH '존재하지 않는 불만사유입니다.'.
    ENDIF.
  ELSE.
    CLEAR: P_DSTGRT.
  ENDIF.

ENDFORM.                    " DSTGR_READ
*&---------------------------------------------------------------------*
*&      Form  VKBUR_READ
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GS_100_VKBUR  text
*      <--P_GS_100_VKBURT  text
*----------------------------------------------------------------------*
FORM VKBUR_READ  USING    P_VKBUR
                 CHANGING P_VKBURT.


  IF  NOT  P_VKBUR  IS INITIAL.

    SELECT  SINGLE    BEZEI
           INTO  P_VKBURT
           FROM  TVKBT
           WHERE SPRAS = SY-LANGU
           AND VKBUR   = P_VKBUR.

    IF  SY-SUBRC  NE  0.
      MESSAGE E001  WITH '존재하지 않는 영업팀입니다.'.
    ENDIF.
  ELSE.
    CLEAR P_VKBURT.
  ENDIF.

*  IF  NOT  P_VKBUR  IS INITIAL.
*  IF G_BUKRS = ''.
*    GET PARAMETER ID 'BUK' FIELD G_BUKRS.
*  ENDIF.
*
*    SELECT SINGLE BEZEI
*      INTO P_VKBURT
*      FROM ZCOTA031
*     WHERE KOKRS = G_BUKRS
*       AND VKGRP = P_VKBUR
*       AND GJAHR = GS_100-RCEPDT(4).
*
*    IF  SY-SUBRC  NE  0.
*      MESSAGE E001  WITH '존재하지 않는 영업팀입니다.'.
*    ENDIF.
*  ELSE.
*    CLEAR P_VKBURT.
*  ENDIF.

ENDFORM.                    " VKBUR_READ
*&---------------------------------------------------------------------*
*&      Form  VKGRP_READ
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GS_100_VKGRP  text
*      <--P_GS_100_VKGRPT  text
*----------------------------------------------------------------------*
FORM VKGRP_READ  USING    P_VKGRP
                 CHANGING P_VKGRPT.

  IF  NOT  P_VKGRP  IS INITIAL.

    SELECT SINGLE    BEZEI
           INTO  P_VKGRPT
           FROM  TVGRT
           WHERE SPRAS  = SY-LANGU
           AND   VKGRP  = P_VKGRP.

    IF  SY-SUBRC  NE  0.
      MESSAGE E001  WITH '존재하지 않는 영업그룹입니다.'.
    ENDIF.
  ELSE.
    CLEAR P_VKGRPT.
  ENDIF.

ENDFORM.                    " VKGRP_READ
*&---------------------------------------------------------------------*
*&      Form  VTWEG_READ
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GS_100_VTWEG  text
*      <--P_GS_100_VTWEGT  text
*----------------------------------------------------------------------*
FORM VTWEG_READ  USING    P_VTWEG
                 CHANGING P_VTWEGT.

  IF  NOT  P_VTWEG  IS INITIAL.

    SELECT SINGLE  VTEXT
           INTO  P_VTWEGT
           FROM  TVTWT
           WHERE SPRAS  EQ '3'
           AND   VTWEG  EQ P_VTWEG.

    IF  SY-SUBRC  NE  0.
      MESSAGE E001  WITH '존재하지 않는 유통경로입니다.'.
    ENDIF.
  ELSE.
    CLEAR P_VTWEGT.
  ENDIF.

ENDFORM.                    " VTWEG_READ
*&---------------------------------------------------------------------*
*&      Form  SAVE_LONG_TEXT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM SAVE_LONG_TEXT.

*___불만내용
  PERFORM SAVE_LONG_TEXT_DB TABLES G_LINES1_N
                                   G_LINES1_O
                            USING  GC_TDOBJECT
                                   GC_TDID1.

*___고객요구사항
  PERFORM SAVE_LONG_TEXT_DB TABLES G_LINES2_N
                                   G_LINES2_O
                            USING  GC_TDOBJECT
                                   GC_TDID2.

*___처리현황(시정)
  PERFORM SAVE_LONG_TEXT_DB TABLES G_LINES3_N
                                   G_LINES3_O
                            USING  GC_TDOBJECT
                                   GC_TDID3.

*___현상 및 원인
  PERFORM SAVE_LONG_TEXT_DB TABLES G_LINES4_N
                                   G_LINES4_O
                            USING  GC_TDOBJECT
                                   GC_TDID4.

*___재발방지 대책수립/실행/확인
  PERFORM SAVE_LONG_TEXT_DB TABLES G_LINES5_N
                                   G_LINES5_O
                            USING  GC_TDOBJECT
                                   GC_TDID5.

*___처리결과
  PERFORM SAVE_LONG_TEXT_DB TABLES G_LINES6_N
                                   G_LINES6_O
                            USING  GC_TDOBJECT
                                   GC_TDID6.

ENDFORM.                    " SAVE_LONG_TEXT
*&---------------------------------------------------------------------*
*&      Form  INSERT_CUSTOM_CLAIM_100
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_P_SCRNM  text
*      -->P_GV_RCEPNO  text
*      <--P_GV_FORM_FLG  text
*----------------------------------------------------------------------*
FORM INSERT_CUSTOM_CLAIM_100  USING   " P_SCR    TYPE  STRING
                                       P_RCEPNO
                              CHANGING P_FLG.

  DATA: LS_CLAIM      LIKE  ZQMT0011H.
  DATA: LV_TDNAME(70).

  GS_100-RCEPNO   =  P_RCEPNO.                    "접수번호

  CASE  'X'.
    WHEN  GV_RCLAS1.
      GS_100-RCLAS   =  '1'.
    WHEN  GV_RCLAS2.
      GS_100-RCLAS   =  '2'.
    WHEN  GV_RCLAS3.
      GS_100-RCLAS   =  '3'.
    WHEN  GV_RCLAS4.
      GS_100-RCLAS   =  '4'.
    WHEN  GV_RCLAS5.
      GS_100-RCLAS   =  '5'.
    WHEN  GV_RCLAS6.
      GS_100-RCLAS   =  '6'.
    WHEN  GV_RCLAS7.
      GS_100-RCLAS   =  '7'.
  ENDCASE.

  CONCATENATE GC_TDOBJECT GC_TDID1 GV_RCEPNO
              INTO LV_TDNAME.

  GS_100-TDNAME1 = LV_TDNAME.

  PERFORM TRANS_DATA_UPDAT USING 'ZQMT0011H'.

  SELECT SINGLE B~BUKRS
    INTO GS_100-BUKRS
    FROM T001W AS A INNER JOIN T001K AS B
    ON A~BWKEY = B~BWKEY
    WHERE A~WERKS = GS_100-WERKS_H.

  MOVE-CORRESPONDING    GS_100  TO  LS_CLAIM.
*->[가온전선]--------------------CHG S
* 첨부파일
  IF GS_100-ATTCH IS NOT INITIAL.
    LS_CLAIM-DOKNR = GC_X.
  ELSE.
    CLEAR LS_CLAIM-DOKNR.
  ENDIF.
*-<[가온전선]--------------------CHG E

  INSERT    ZQMT0011H  FROM  LS_CLAIM.
  IF SY-SUBRC = 0.
    GS_100_OLD   = GS_100.
    COMMIT WORK.
*    GV_Y = 'X'.
    MESSAGE S001 WITH '입력하신 Data가 저장되었습니다.'.
  ELSE.
    ROLLBACK WORK.
*    CLEAR GV_Y.
  ENDIF.

ENDFORM.                    " INSERT_CUSTOM_CLAIM_100
*&---------------------------------------------------------------------*
*&      Form  UPDATE_SABUN
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_LS_CLAIM  text
*----------------------------------------------------------------------*
FORM UPDATE_SABUN  CHANGING PS_CLAIM TYPE ZQMT0011H.

  IF STRLEN( PS_CLAIM-RCPERNR ) NE 8.
    CONCATENATE '00' PS_CLAIM-RCPERNR INTO PS_CLAIM-RCPERNR .
  ENDIF.

  IF STRLEN( PS_CLAIM-CORDINR ) NE 8.
    CONCATENATE '00' PS_CLAIM-CORDINR INTO PS_CLAIM-CORDINR .
  ENDIF.

  IF STRLEN( PS_CLAIM-JGNAMNR ) NE 8.
    CONCATENATE '00' PS_CLAIM-JGNAMNR INTO PS_CLAIM-JGNAMNR .
  ENDIF.

  IF STRLEN( PS_CLAIM-SDNAMNR ) NE 8.
    CONCATENATE '00' PS_CLAIM-SDNAMNR INTO PS_CLAIM-SDNAMNR .
  ENDIF.

ENDFORM.                    " UPDATE_SABUN
*&---------------------------------------------------------------------*
*&      Form  SAVE_LONG_TEXT2
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM SAVE_LONG_TEXT2 .

  CALL FUNCTION 'NUMBER_GET_NEXT'
    EXPORTING
      NR_RANGE_NR             = '01'
      OBJECT                  = 'ZQMCOMP1'
      QUANTITY                = '1'
    IMPORTING
      NUMBER                  = G_NUMBER
    EXCEPTIONS
      INTERVAL_NOT_FOUND      = 1
      NUMBER_RANGE_NOT_INTERN = 2
      OBJECT_NOT_FOUND        = 3
      QUANTITY_IS_0           = 4
      QUANTITY_IS_NOT_1       = 5
      INTERVAL_OVERFLOW       = 6
      BUFFER_OVERFLOW         = 7
      OTHERS                  = 8.
  IF SY-SUBRC <> 0.
    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    EXIT.
  ENDIF.

* 불만내용
  G_HEADER-TDOBJECT = 'ZQMTCOMP1'.
  G_HEADER-TDID = 'ZQM'.
  G_HEADER-TDSPRAS = SY-LANGU.

  CONCATENATE G_HEADER-TDOBJECT G_HEADER-TDID G_NUMBER
              INTO G_HEADER-TDNAME.


  CALL FUNCTION 'SAVE_TEXT'
    EXPORTING
      HEADER    = G_HEADER
    IMPORTING
      NEWHEADER = G_HEADER
    TABLES
      LINES     = G_LINES1_N
    EXCEPTIONS
      ID        = 1
      LANGUAGE  = 2
      NAME      = 3
      OBJECT    = 4
      OTHERS    = 5.

  IF SY-SUBRC NE 0.
    MESSAGE E001  WITH '저장시 에러가 발생하였습니다.'.
    GV_FORM_FLG = 'X'.
    EXIT.
  ENDIF.

* 고객요구사항
  G_HEADER-TDOBJECT = 'ZQMTCOMP1'.
  G_HEADER-TDID = 'ZQM2'.
  G_HEADER-TDSPRAS = SY-LANGU.

  CONCATENATE G_HEADER-TDOBJECT G_HEADER-TDID G_NUMBER
              INTO G_HEADER-TDNAME.


  CALL FUNCTION 'SAVE_TEXT'
    EXPORTING
      HEADER    = G_HEADER
    IMPORTING
      NEWHEADER = G_HEADER
    TABLES
      LINES     = G_LINES2_N
    EXCEPTIONS
      ID        = 1
      LANGUAGE  = 2
      NAME      = 3
      OBJECT    = 4
      OTHERS    = 5.

  IF SY-SUBRC NE 0.
    MESSAGE E001  WITH '저장시 에러가 발생하였습니다.'.
    GV_FORM_FLG = 'X'.
    EXIT.
  ENDIF.

ENDFORM.                    " SAVE_LONG_TEXT2
*&---------------------------------------------------------------------*
*&      Form  GET_TC_100_ADD
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM GET_TC_100_ADD .

  CLEAR : GS_101-MATNR, GS_101-MAKTX.
  CALL SCREEN '0311' STARTING AT 10 2
                     ENDING AT 110 9.

ENDFORM.                    " GET_TC_100_ADD
*&---------------------------------------------------------------------*
*&      Form  CHECK_DATA_CHANGED
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM CHECK_DATA_CHANGED  USING    PV_FLAG.

  CLEAR : PV_FLAG,
          GV_ISFIRST.  "0310 화면에서 사용하는 FLAG

  CLEAR : S_810.

  CLEAR : GT_100-MARK,     GT_110-MARK,     GT_110A-MARK,
          GT_120-MARK,     GT_120A-MARK,    GT_130-MARK,
          GT_140-MARK,     GT_150-MARK,     GT_160-MARK,
          GT_170-MARK,     GT_180-MARK,     GT_190-MARK,
          GT_200-MARK,     GT_210-MARK,     GT_220-MARK,
          GT_230-MARK,     GT_240-MARK,
          GT_100_OLD-MARK, GT_110_OLD-MARK, GT_120_OLD-MARK,
          GT_130_OLD-MARK, GT_140_OLD-MARK, GT_150_OLD-MARK,
          GT_160_OLD-MARK, GT_170_OLD-MARK, GT_180_OLD-MARK,
          GT_190_OLD-MARK, GT_200_OLD-MARK, GT_210_OLD-MARK,
          GT_220_OLD-MARK, GT_230_OLD-MARK, GT_240_OLD-MARK.


*  if GT_120[] is initial.
*    MESSAGE i001  WITH  '자재/불량정보 결함유형을 입력하세요.'.
*
*    exit.
*  endif.


  MODIFY GT_100 TRANSPORTING MARK
                WHERE ZMATSEQ IS NOT INITIAL.
  MODIFY GT_110 TRANSPORTING MARK
                WHERE ZMATSEQ IS NOT INITIAL.
  MODIFY GT_110A TRANSPORTING MARK
                WHERE ZMATSEQ IS NOT INITIAL.
  MODIFY GT_120 TRANSPORTING MARK
                WHERE ZMATSEQ IS NOT INITIAL.
  MODIFY GT_120A TRANSPORTING MARK
                WHERE ZMATSEQ IS NOT INITIAL.
  MODIFY GT_140 TRANSPORTING MARK
                WHERE ZMATSEQ IS NOT INITIAL.
  MODIFY GT_150 TRANSPORTING MARK
                WHERE ZMATSEQ IS NOT INITIAL.
  MODIFY GT_160 TRANSPORTING MARK
                WHERE ZMATSEQ IS NOT INITIAL.
  MODIFY GT_170 TRANSPORTING MARK
                WHERE ZMATSEQ IS NOT INITIAL.
  MODIFY GT_180 TRANSPORTING MARK
                WHERE ZMATSEQ IS NOT INITIAL.
  MODIFY GT_190 TRANSPORTING MARK
                WHERE ZMATSEQ IS NOT INITIAL.
  MODIFY GT_200 TRANSPORTING MARK
                WHERE ZMATSEQ IS NOT INITIAL.
  MODIFY GT_210 TRANSPORTING MARK
                WHERE ZMATSEQ IS NOT INITIAL.
  MODIFY GT_220 TRANSPORTING MARK
                WHERE BELNR IS NOT INITIAL.
  MODIFY GT_230 TRANSPORTING MARK
                WHERE ZMATSEQ IS NOT INITIAL.
  MODIFY GT_240 TRANSPORTING MARK
                WHERE ZMATSEQ IS NOT INITIAL.
  MODIFY GT_100_OLD TRANSPORTING MARK
                WHERE ZMATSEQ IS NOT INITIAL.
  MODIFY GT_110_OLD TRANSPORTING MARK
                WHERE ZMATSEQ IS NOT INITIAL.
  MODIFY GT_120_OLD TRANSPORTING MARK
                WHERE ZMATSEQ IS NOT INITIAL.
  MODIFY GT_140_OLD TRANSPORTING MARK
                WHERE ZMATSEQ IS NOT INITIAL.
  MODIFY GT_150_OLD TRANSPORTING MARK
                WHERE ZMATSEQ IS NOT INITIAL.
  MODIFY GT_160_OLD TRANSPORTING MARK
                WHERE ZMATSEQ IS NOT INITIAL.
  MODIFY GT_170_OLD TRANSPORTING MARK
                WHERE ZMATSEQ IS NOT INITIAL.
  MODIFY GT_180_OLD TRANSPORTING MARK
                WHERE ZMATSEQ IS NOT INITIAL.
  MODIFY GT_190_OLD TRANSPORTING MARK
                WHERE ZMATSEQ IS NOT INITIAL.
  MODIFY GT_200_OLD TRANSPORTING MARK
                WHERE ZMATSEQ IS NOT INITIAL.
  MODIFY GT_210_OLD TRANSPORTING MARK
                WHERE ZMATSEQ IS NOT INITIAL.
  MODIFY GT_220_OLD TRANSPORTING MARK
                WHERE BELNR IS NOT INITIAL.
  MODIFY GT_230_OLD TRANSPORTING MARK
                WHERE ZMATSEQ IS NOT INITIAL.
  MODIFY GT_240_OLD TRANSPORTING MARK
                WHERE ZMATSEQ IS NOT INITIAL.

  DATA : LV_CHK.

  IF GS_100       <> GS_100_OLD. "  OR
    LV_CHK = '1'.
  ELSEIF GT_100[]     <> GT_100_OLD[]." OR
    LV_CHK = '2'.
  ELSEIF GT_110A[]    <> GT_110_OLD[].
    " OR                        "gt_110아님
    LV_CHK = '3'.
  ELSEIF GT_120A[]    <> GT_120_OLD[].
    " OR                        "gt_120아님
    LV_CHK = '4'.
  ELSEIF GT_130[]     <> GT_130_OLD[]." OR
    LV_CHK = '5'.
  ELSEIF GT_140[]     <> GT_140_OLD[]." OR
    LV_CHK = '6'.
  ELSEIF GT_150[]     <> GT_150_OLD[]." OR
    LV_CHK = '7'.
  ELSEIF GT_160[]     <> GT_160_OLD[]." OR
    LV_CHK = '8'.
  ELSEIF GT_170[]     <> GT_170_OLD[]." OR
    LV_CHK = '9'.
  ELSEIF GT_180[]     <> GT_180_OLD[]." OR
    LV_CHK = '10'.
  ELSEIF GT_190[]     <> GT_190_OLD[]." OR
    LV_CHK = '11'.
  ELSEIF GT_200[]     <> GT_200_OLD[]." OR
    LV_CHK = '12'.
  ELSEIF GT_210[]     <> GT_210_OLD[]." OR
    LV_CHK = '13'.
  ELSEIF GT_220[]     <> GT_220_OLD[]." OR
    LV_CHK = '14'.
  ELSEIF GT_230[]     <> GT_230_OLD[]." OR
    LV_CHK = '15'.
  ELSEIF GT_240[]     <> GT_240_OLD[]." OR
    LV_CHK = '16'.
  ELSEIF GT_250[]     <> GT_250_OLD[]." OR
    LV_CHK = '17'.
  ELSEIF GT_260[]     <> GT_260_OLD[]." OR
    LV_CHK = '18'.
  ELSEIF GT_270[]     <> GT_270_OLD[]." OR
    LV_CHK = '19'.
  ELSEIF G_LINES1_N[] <> G_LINES1_O[]." OR
    LV_CHK = '20'.
  ELSEIF G_LINES2_N[] <> G_LINES2_O[]." OR
    LV_CHK = '21'.
  ELSEIF G_LINES3_N[] <> G_LINES3_O[]." OR
    LV_CHK = '22'.
  ELSEIF G_LINES4_N[] <> G_LINES4_O[]." OR
    LV_CHK = '23'.
  ELSEIF G_LINES5_N[] <> G_LINES5_O[]." OR
    LV_CHK = '24'.
  ELSEIF G_LINES6_N[] <> G_LINES6_O[].
    LV_CHK = '25'.
  ENDIF.

  IF NOT LV_CHK IS INITIAL.
* 접수완료시 팝업창 띄우지 않고 자동으로 저장 (C20121024_05510)
    IF OK_SAVE = 'CONF'.
      PV_FLAG = 'J'.
    ELSE.
      %%POPUP_TO_CONFIRM_STEP '변경된 데이터가 존재합니다.'
                              '저장하시겠습니까?'
                              '확인'.

      PV_FLAG = GV_ANSWER.
    ENDIF.
  ENDIF.

ENDFORM.                    " CHECK_DATA_CHANGED
*&---------------------------------------------------------------------*
*&      Form  SAVE_COMPLAIN_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM SAVE_COMPLAIN_DATA USING PV_FLAG .

  PERFORM PROCESS_CHECK.
  CHECK GV_FORM_FLG NE 'X'.
  PERFORM SAVE_PROCESS USING PV_FLAG.
  CHECK GV_FORM_FLG NE 'X'.
  PERFORM SAVE_LONG_TEXT.

  GV_TRTYP = 'V'.

ENDFORM.                    " SAVE_COMPLAIN_DATA
*&---------------------------------------------------------------------*
*&      Form  CLEAR_ALL_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM CLEAR_ALL_DATA .

*  GV_RCEPNO = GS_100-RCEPNO.

  CLEAR   : GT_100,     GT_110,     GT_120,     GT_130,     GS_100,
            GT_140,     GT_150,     GT_160,     GT_170,     GT_180,
            GT_190,     GT_200,     GT_210,     GT_220,     GT_230,
            GT_240,     GT_250,     GT_260,     GT_270,     GT_280,
            GT_110A,    GT_120A,    GT_100_OLD, GT_110_OLD, GT_120_OLD,
            GT_130_OLD,
            GS_100_OLD, GT_140_OLD, GT_150_OLD, GT_160_OLD, GT_170_OLD,
            GT_180_OLD, GT_190_OLD, GT_110A,    GT_200_OLD, GT_210_OLD,
            GT_220_OLD, GT_230_OLD, GT_240_OLD, GT_250_OLD, GT_260_OLD,
            GT_270_OLD, S_810.
  REFRESH : GT_100,     GT_110,     GT_120,     GT_130,     GT_140,
            GT_150,     GT_160,     GT_170,     GT_180,     GT_190,
            GT_200,     GT_210,     GT_220,     GT_230,     GT_240,
            GT_250,     GT_260,     GT_270,     GT_280,     GT_110A,
            GT_120A,    GT_100_OLD, GT_110_OLD, GT_120_OLD, GT_130_OLD,
            GT_140_OLD, GT_150_OLD, GT_160_OLD, GT_170_OLD, GT_180_OLD,
            GT_190_OLD, GT_200_OLD, GT_210_OLD, GT_220_OLD, GT_230_OLD,
            GT_240_OLD, GT_250_OLD, GT_260_OLD, GT_270_OLD.

ENDFORM.                    " CLEAR_ALL_DATA
*&---------------------------------------------------------------------*
*&      Form  GET_COMPLAIN_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM GET_COMPLAIN_DATA.

  PERFORM CLEAR_ALL_DATA.

*__개요
  PERFORM GET_COMPLAIN_DATA_200.

  CHECK GS_100-RCEPNO IS NOT INITIAL.

  PERFORM GET_BUKRS USING    GS_100-WERKS_H
                    CHANGING GV_BUKRS.

  "첨부파일
  PERFORM CHECK_ATTACH.

*  IF GV_BUKRS EQ '2000'.
*    GV_DOKAR = 'JQS'.
*  ELSE.
*    GV_DOKAR = 'QCS'.
*  ENDIF.

*__자재/불량정보
  PERFORM GET_COMPLAIN_DATA_300.


*__물류처리
  PERFORM GET_COMPLAIN_DATA_400.


*__반품/출고
  PERFORM GET_COMPLAIN_DATA_500.


*__반품검사로트
  PERFORM GET_COMPLAIN_DATA_600.


*__손실금액
  PERFORM GET_COMPLAIN_DATA_700.


*__물류관련손실금액
  PERFORM GET_COMPLAIN_DATA_800.


*__A/S관련손실금액
  PERFORM GET_COMPLAIN_DATA_900.


*__시정조치
  PERFORM GET_COMPLAIN_DATA_1100.


*__처리결과/승인
  PERFORM GET_COMPLAIN_DATA_1200.


*__불만이력
  PERFORM GET_COMPLAIN_DATA_1300.


  GS_100_OLD   = GS_100.
  GT_100_OLD[] = GT_100[].
  GT_110_OLD[] = GT_110A[].  "gt_110 아님
  GT_120_OLD[] = GT_120A[].  "gt_120 아님
  GT_130_OLD[] = GT_130[].
  GT_140_OLD[] = GT_140[].
  GT_150_OLD[] = GT_150[].
  GT_160_OLD[] = GT_160[].
  GT_190_OLD[] = GT_190[].
  GT_210_OLD[] = GT_210[].
  GT_220_OLD[] = GT_220[].
  GT_230_OLD[] = GT_230[].
  GT_240_OLD[] = GT_240[].
  GT_250_OLD[] = GT_250[].
  GT_260_OLD[] = GT_260[].
  GT_270_OLD[] = GT_270[].
  G_LINES1_N[] = G_LINES1_O[].
  G_LINES2_N[] = G_LINES2_O[].
  G_LINES3_N[] = G_LINES3_O[].
  G_LINES4_N[] = G_LINES4_O[].
  G_LINES5_N[] = G_LINES5_O[].
  G_LINES6_N[] = G_LINES6_O[].

  DESCRIBE TABLE G_LINES1_O LINES G_OLIN1.
  DESCRIBE TABLE G_LINES2_O LINES G_OLIN2.
  DESCRIBE TABLE G_LINES3_O LINES G_OLIN3.
  DESCRIBE TABLE G_LINES4_O LINES G_OLIN4.
  DESCRIBE TABLE G_LINES5_O LINES G_OLIN5.
  DESCRIBE TABLE G_LINES6_O LINES G_OLIN6.
  DESCRIBE TABLE G_LINES1_N LINES G_NLIN1.
  DESCRIBE TABLE G_LINES2_N LINES G_NLIN2.
  DESCRIBE TABLE G_LINES3_N LINES G_NLIN3.
  DESCRIBE TABLE G_LINES4_N LINES G_NLIN4.
  DESCRIBE TABLE G_LINES5_N LINES G_NLIN5.
  DESCRIBE TABLE G_LINES6_N LINES G_NLIN6.

ENDFORM.                    " GET_COMPLAIN_DATA
*&---------------------------------------------------------------------*
*&      Form  GET_MATNR_DESC
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM GET_MATNR_DESC  USING    PV_MATNR
                              PV_MAKTX.

  CLEAR : PV_MAKTX.

  CHECK PV_MATNR IS NOT INITIAL.

  SELECT SINGLE MAKTX
    INTO PV_MAKTX
    FROM MAKT
   WHERE MATNR = PV_MATNR
     AND SPRAS = SY-LANGU.

ENDFORM.                    " GET_MATNR_DESC
*&---------------------------------------------------------------------*
*&      Form  GET_MATCT_DESC
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GV_RCEPNO  text
*      <--P_GT_110_MATCT  text
*      <--P_GT_110_KUNCT  text
*      <--P_GT_110_ZAEDAT_B  text
*      <--P_GT_110_ZAEZET_B  text
*----------------------------------------------------------------------*
FORM GET_MATCT_DESC  USING    P_RCEPNO
                     CHANGING P_MATCT
                              P_KUNCT
                              P_ZAEDAT_B
                              P_ZAEZET_B.

  READ TABLE GT_100 WITH KEY RCEPNO = P_RCEPNO
                             BINARY SEARCH.
  IF SY-SUBRC = 0.
    P_MATCT    = GT_100-MATCT.
    P_KUNCT    = GT_100-KUNCT.
    P_ZAEDAT_B = GT_100-ZAEDAT_B.
    P_ZAEZET_B = GT_100-ZAEZET_B.
  ENDIF.

ENDFORM.                    " GET_MATCT_DESC
*&---------------------------------------------------------------------*
*&      Form  GET_FLTTPT_DESC
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GT_120_FTKAT  text
*      -->P_GT_120_FTGRP  text
*      -->P_GT_120_FLTTP  text
*      <--P_GT_120_FLTTPT  text
*----------------------------------------------------------------------*
FORM GET_FLTTPT_DESC  USING    P_FTKAT
                               P_FTGRP
                               P_FLTTP
                      CHANGING P_FLTTPT.

  CLEAR : P_FLTTPT.

  CHECK P_FTKAT IS NOT INITIAL AND P_FTGRP IS NOT INITIAL
    AND P_FLTTP IS NOT INITIAL.

  SELECT SINGLE KURZTEXT
    INTO P_FLTTPT
    FROM QPCT
   WHERE KATALOGART = P_FTKAT
     AND CODEGRUPPE = P_FTGRP
     AND CODE       = P_FLTTP
     AND SPRACHE    = SY-LANGU.

ENDFORM.                    " GET_FLTTPT_DESC
*&---------------------------------------------------------------------*
*&      Form  GET_OTEILT_DESC
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GT_120_OTKAT  text
*      -->P_GT_120_OTRGRP  text
*      -->P_GT_120_OTEIL  text
*      <--P_GT_120_OTEILT  text
*----------------------------------------------------------------------*
FORM GET_OTEILT_DESC  USING    P_OTKAT
                               P_OTRGRP
                               P_OTEIL
                      CHANGING P_OTEILT.

  CLEAR : P_OTEILT.

  CHECK P_OTKAT IS NOT INITIAL AND P_OTRGRP IS NOT INITIAL
    AND P_OTEIL IS NOT INITIAL.

  SELECT SINGLE KURZTEXT
    INTO P_OTEILT
    FROM QPCT
   WHERE KATALOGART = P_OTKAT
     AND CODEGRUPPE = P_OTRGRP
     AND CODE       = P_OTEIL
     AND SPRACHE    = SY-LANGU.

ENDFORM.                    " GET_OTEILT_DESC
*&---------------------------------------------------------------------*
*&      Form  READ_LONG_TEXT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GC_TDID1  text
*      -->P_GS_100_TDNAME1  text
*      -->P_GC_TDOBJECT  text
*----------------------------------------------------------------------*
FORM READ_LONG_TEXT  TABLES PT_LINES STRUCTURE TLINE
                     USING  P_TDID1
                            P_TDNAME1
                            P_TDOBJECT.

  CLEAR   : G_HEADER, G_LINES.
  REFRESH : G_LINES.

  CALL FUNCTION 'READ_TEXT'
    EXPORTING
      CLIENT                  = SY-MANDT
      ID                      = P_TDID1
      LANGUAGE                = SY-LANGU
      NAME                    = P_TDNAME1
      OBJECT                  = P_TDOBJECT
    IMPORTING
      HEADER                  = G_HEADER
    TABLES
      LINES                   = G_LINES
    EXCEPTIONS
      ID                      = 1
      LANGUAGE                = 2
      NAME                    = 3
      NOT_FOUND               = 4
      OBJECT                  = 5
      REFERENCE_CHECK         = 6
      WRONG_ACCESS_TO_ARCHIVE = 7
      OTHERS                  = 8.

  PT_LINES[] = G_LINES[].

ENDFORM.                    " READ_LONG_TEXT
*&---------------------------------------------------------------------*
*&      Form  EXCLUDE_OF_TOOLBAR_BUTTON_GRID
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_1157   text
*----------------------------------------------------------------------*
FORM EXCLUDE_OF_TOOLBAR_BUTTON_GRID  USING    P_TABNAME.
  DATA: L_TAB_NAME LIKE FELD-NAME.

  FIELD-SYMBOLS: <TABLE> TYPE UI_FUNCTIONS.

  CONCATENATE P_TABNAME '[]' INTO  L_TAB_NAME.
  ASSIGN     (L_TAB_NAME)    TO <TABLE>.

  CLEAR : <TABLE>.
*-제거할 버튼 지정
  PERFORM ADD_EXCLUDE_TOOLBAR_BUTTON
          TABLES <TABLE>
*          USING: CL_GUI_ALV_GRID=>MC_FC_EXCL_ALL.  "**툴바 모두제거 **
          USING:
                 CL_GUI_ALV_GRID=>MC_FC_LOC_UNDO, "실행취소 &LOCAL&UNDO
                 CL_GUI_ALV_GRID=>MC_FC_AUF,        "소계확장 &AUF
                 CL_GUI_ALV_GRID=>MC_FC_AVERAGE,    "&AVERAGE
*                 cl_gui_alv_grid=>mc_fc_back_classic,
*                 cl_gui_alv_grid=>mc_fc_call_abc,  "&ABC
*                 cl_gui_alv_grid=>mc_fc_call_chain,
*                 cl_gui_alv_grid=>mc_fc_call_crbatch,
*                 cl_gui_alv_grid=>mc_fc_call_crweb,
*                 cl_gui_alv_grid=>mc_fc_call_lineitems,
*                 cl_gui_alv_grid=>mc_fc_call_master_data,
*                 cl_gui_alv_grid=>mc_fc_call_more,
*                 cl_gui_alv_grid=>mc_fc_call_report,
*                 cl_gui_alv_grid=>mc_fc_call_xint,
*                 cl_gui_alv_grid=>mc_fc_call_xxl,
*                 cl_gui_alv_grid=>mc_fc_col_invisible,
*                 cl_gui_alv_grid=>mc_fc_col_optimize,
*                 CL_GUI_ALV_GRID=>MC_FC_CURRENT_VARIANT,
*                 cl_gui_alv_grid=>mc_fc_data_save,
*                 cl_gui_alv_grid=>mc_fc_delete_filter,
*                 CL_GUI_ALV_GRID=>MC_FC_DESELECT_ALL,
*                 cl_gui_alv_grid=>mc_fc_detail,
*                 cl_gui_alv_grid=>mc_fc_expcrdata,
*                 cl_gui_alv_grid=>mc_fc_expcrdesig,
*                 cl_gui_alv_grid=>mc_fc_expcrtempl,
*                 cl_gui_alv_grid=>mc_fc_expmdb,
*                 cl_gui_alv_grid=>mc_fc_extend,
*                 cl_gui_alv_grid=>mc_fc_f4,
*                 cl_gui_alv_grid=>mc_fc_filter,
                 CL_GUI_ALV_GRID=>MC_FC_FIND,
*                 cl_gui_alv_grid=>mc_fc_fix_columns,
                 CL_GUI_ALV_GRID=>MC_FC_GRAPH,
*                 cl_gui_alv_grid=>mc_fc_help,
                 CL_GUI_ALV_GRID=>MC_FC_INFO,
*                 CL_GUI_ALV_GRID=>MC_FC_LOAD_VARIANT,
                 CL_GUI_ALV_GRID=>MC_FC_LOC_COPY,          "행 카피.
*                 cl_gui_alv_grid=>mc_fc_html,
                 CL_GUI_ALV_GRID=>MC_FC_LOC_COPY_ROW,      "행 카피.
                 CL_GUI_ALV_GRID=>MC_FC_LOC_CUT,           "가위.
*->[CH 가온전선]---S
                 CL_GUI_ALV_GRID=>MC_FC_LOC_DELETE_ROW,    "행삭제.
                 CL_GUI_ALV_GRID=>MC_FC_LOC_INSERT_ROW,    "행삽입.
*-<[CH 가온전선]---S
                 CL_GUI_ALV_GRID=>MC_FC_LOC_MOVE_ROW,
                 CL_GUI_ALV_GRID=>MC_FC_LOC_APPEND_ROW,    "라인생성.
                 CL_GUI_ALV_GRID=>MC_FC_LOC_PASTE,         "겹쳐쓰기.
                 CL_GUI_ALV_GRID=>MC_FC_LOC_PASTE_NEW_ROW, "겹쳐쓰기.
*                 CL_GUI_ALV_GRID=>MC_FC_MAINTAIN_VARIANT,
*                 cl_gui_alv_grid=>mc_fc_maximum,
*                 cl_gui_alv_grid=>mc_fc_minimum,
*                 cl_gui_alv_grid=>mc_fc_pc_file,
                 CL_GUI_ALV_GRID=>MC_FC_PRINT,
*                 cl_gui_alv_grid=>mc_fc_print_back,
*                 cl_gui_alv_grid=>mc_fc_print_prev,
                 CL_GUI_ALV_GRID=>MC_FC_REFRESH,
*                 cl_gui_alv_grid=>mc_fc_reprep,
*                 CL_GUI_ALV_GRID=>MC_FC_SAVE_VARIANT.
*                 CL_GUI_ALV_GRID=>MC_FC_SELECT_ALL,
*                 cl_gui_alv_grid=>mc_fc_send,
*                 cl_gui_alv_grid=>mc_fc_separator,
*                 cl_gui_alv_grid=>mc_fc_sort,
*                 cl_gui_alv_grid=>mc_fc_sort_asc,
*                 cl_gui_alv_grid=>mc_fc_sort_dsc,
                 CL_GUI_ALV_GRID=>MC_FC_SUBTOT,
                 CL_GUI_ALV_GRID=>MC_MB_SUM,
                 CL_GUI_ALV_GRID=>MC_FC_SUM.
*                 cl_gui_alv_grid=>mc_fc_to_office,
*                 cl_gui_alv_grid=>mc_fc_to_rep_tree,
*                 cl_gui_alv_grid=>mc_fc_unfix_columns,
*                 cl_gui_alv_grid=>mc_fc_views,
*                 cl_gui_alv_grid=>mc_fc_view_crystal,
*                 cl_gui_alv_grid=>mc_fc_view_excel,
*                 cl_gui_alv_grid=>mc_fc_view_grid,
*                 cl_gui_alv_grid=>mc_fc_word_processor.



ENDFORM.                    " EXCLUDE_OF_TOOLBAR_BUTTON_GRID

*&---------------------------------------------------------------------*
*&      Form  EXCLUDE_OF_TOOLBAR_BUTTON_GRID
*&---------------------------------------------------------------------*
*       text C20111123_03752 합계버튼 추가
*----------------------------------------------------------------------*
*      -->P_1157   text
*----------------------------------------------------------------------*
FORM EXCLUDE_OF_TOOLBAR_BUTTON_910  USING    P_TABNAME.
  DATA: L_TAB_NAME LIKE FELD-NAME.

  FIELD-SYMBOLS: <TABLE> TYPE UI_FUNCTIONS.

  CONCATENATE P_TABNAME '[]' INTO  L_TAB_NAME.
  ASSIGN     (L_TAB_NAME)    TO <TABLE>.

*-제거할 버튼 지정
  PERFORM ADD_EXCLUDE_TOOLBAR_BUTTON
          TABLES <TABLE>
*          USING: CL_GUI_ALV_GRID=>MC_FC_EXCL_ALL.  "**툴바 모두제거 **
          USING:
                 CL_GUI_ALV_GRID=>MC_FC_LOC_UNDO, "실행취소 &LOCAL&UNDO
                 CL_GUI_ALV_GRID=>MC_FC_AUF,        "소계확장 &AUF
                 CL_GUI_ALV_GRID=>MC_FC_AVERAGE,    "&AVERAGE
*                 cl_gui_alv_grid=>mc_fc_back_classic,
*                 cl_gui_alv_grid=>mc_fc_call_abc,  "&ABC
*                 cl_gui_alv_grid=>mc_fc_call_chain,
*                 cl_gui_alv_grid=>mc_fc_call_crbatch,
*                 cl_gui_alv_grid=>mc_fc_call_crweb,
*                 cl_gui_alv_grid=>mc_fc_call_lineitems,
*                 cl_gui_alv_grid=>mc_fc_call_master_data,
*                 cl_gui_alv_grid=>mc_fc_call_more,
*                 cl_gui_alv_grid=>mc_fc_call_report,
*                 cl_gui_alv_grid=>mc_fc_call_xint,
*                 cl_gui_alv_grid=>mc_fc_call_xxl,
*                 cl_gui_alv_grid=>mc_fc_col_invisible,
*                 cl_gui_alv_grid=>mc_fc_col_optimize,
*                 CL_GUI_ALV_GRID=>MC_FC_CURRENT_VARIANT,
*                 cl_gui_alv_grid=>mc_fc_data_save,
*                 cl_gui_alv_grid=>mc_fc_delete_filter,
*                 CL_GUI_ALV_GRID=>MC_FC_DESELECT_ALL,
*                 cl_gui_alv_grid=>mc_fc_detail,
*                 cl_gui_alv_grid=>mc_fc_expcrdata,
*                 cl_gui_alv_grid=>mc_fc_expcrdesig,
*                 cl_gui_alv_grid=>mc_fc_expcrtempl,
*                 cl_gui_alv_grid=>mc_fc_expmdb,
*                 cl_gui_alv_grid=>mc_fc_extend,
*                 cl_gui_alv_grid=>mc_fc_f4,
*                 cl_gui_alv_grid=>mc_fc_filter,
                 CL_GUI_ALV_GRID=>MC_FC_FIND,
*                 cl_gui_alv_grid=>mc_fc_fix_columns,
                 CL_GUI_ALV_GRID=>MC_FC_GRAPH,
*                 cl_gui_alv_grid=>mc_fc_help,
                 CL_GUI_ALV_GRID=>MC_FC_INFO,
*                 CL_GUI_ALV_GRID=>MC_FC_LOAD_VARIANT,
                 CL_GUI_ALV_GRID=>MC_FC_LOC_COPY,          "행 카피.
*                 cl_gui_alv_grid=>mc_fc_html,
                 CL_GUI_ALV_GRID=>MC_FC_LOC_COPY_ROW,      "행 카피.
                 CL_GUI_ALV_GRID=>MC_FC_LOC_CUT,           "가위.
                 CL_GUI_ALV_GRID=>MC_FC_LOC_DELETE_ROW,    "행삭제.
                 CL_GUI_ALV_GRID=>MC_FC_LOC_INSERT_ROW,    "행삽입.
                 CL_GUI_ALV_GRID=>MC_FC_LOC_MOVE_ROW,
                 CL_GUI_ALV_GRID=>MC_FC_LOC_APPEND_ROW,    "라인생성.
                 CL_GUI_ALV_GRID=>MC_FC_LOC_PASTE,         "겹쳐쓰기.
                 CL_GUI_ALV_GRID=>MC_FC_LOC_PASTE_NEW_ROW, "겹쳐쓰기.
*                 CL_GUI_ALV_GRID=>MC_FC_MAINTAIN_VARIANT,
*                 cl_gui_alv_grid=>mc_fc_maximum,
*                 cl_gui_alv_grid=>mc_fc_minimum,
*                 cl_gui_alv_grid=>mc_fc_pc_file,
                 CL_GUI_ALV_GRID=>MC_FC_PRINT,
*                 cl_gui_alv_grid=>mc_fc_print_back,
*                 cl_gui_alv_grid=>mc_fc_print_prev,
                 CL_GUI_ALV_GRID=>MC_FC_REFRESH,
*                 cl_gui_alv_grid=>mc_fc_reprep,
*                 CL_GUI_ALV_GRID=>MC_FC_SAVE_VARIANT.
*                 CL_GUI_ALV_GRID=>MC_FC_SELECT_ALL,
*                 cl_gui_alv_grid=>mc_fc_send,
*                 cl_gui_alv_grid=>mc_fc_separator,
*                 cl_gui_alv_grid=>mc_fc_sort,
*                 cl_gui_alv_grid=>mc_fc_sort_asc,
*                 cl_gui_alv_grid=>mc_fc_sort_dsc,
                 CL_GUI_ALV_GRID=>MC_FC_SUBTOT.
*                 cl_gui_alv_grid=>mc_mb_sum,
*                 cl_gui_alv_grid=>mc_fc_sum.
*                 cl_gui_alv_grid=>mc_fc_to_office,
*                 cl_gui_alv_grid=>mc_fc_to_rep_tree,
*                 cl_gui_alv_grid=>mc_fc_unfix_columns,
*                 cl_gui_alv_grid=>mc_fc_views,
*                 cl_gui_alv_grid=>mc_fc_view_crystal,
*                 cl_gui_alv_grid=>mc_fc_view_excel,
*                 cl_gui_alv_grid=>mc_fc_view_grid,
*                 cl_gui_alv_grid=>mc_fc_word_processor.

ENDFORM.                    " EXCLUDE_OF_TOOLBAR_BUTTON_GRID
*&---------------------------------------------------------------------*
*&      Form  ADD_EXCLUDE_TOOLBAR_BUTTON
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_<TABLE>  text
*      -->P_CL_GUI_ALV_GRID=>MC_FC_LOC_UND  text
*----------------------------------------------------------------------*
FORM ADD_EXCLUDE_TOOLBAR_BUTTON  TABLES   P_TABLE
                                 USING    P_VALUE.
  DATA: L_EXCLUDE TYPE UI_FUNC.

  L_EXCLUDE = P_VALUE.
  APPEND L_EXCLUDE TO P_TABLE. "결과적으로 IT_EXCLUDE에 제거할 버튼 저장

ENDFORM.                    " ADD_EXCLUDE_TOOLBAR_BUTTON
*&---------------------------------------------------------------------*
*&      Form  FILL_FIELD_CATEGORY_1
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_1161   text
*      <--P_GT_FIELDCAT_2  text
*----------------------------------------------------------------------*
FORM FILL_FIELD_CATEGORY_1  USING VALUE(P_TABLE)
                             CHANGING PT_FIELDCAT TYPE LVC_T_FCAT.
  DATA: LS_FCAT          TYPE LVC_S_FCAT.
  REFRESH: PT_FIELDCAT.

  CALL FUNCTION 'Z_QM_FIELDCATALOG_MERGE'
    EXPORTING
      I_PROGRAM              = SY-REPID
      I_TABLE                = P_TABLE
      I_BYPASSING_BUFFER     = 'X'
      I_CLIENT_NEVER_DISPLAY = 'X'
    CHANGING
      GT_FIELDCAT            = PT_FIELDCAT[]
    EXCEPTIONS
      INCONSISTENT_INTERFACE = 1
      PROGRAM_ERROR          = 2
      OTHERS                 = 3.
  IF SY-SUBRC NE 0.
    MESSAGE A001 WITH 'Field Catalog를 찾을 수 없습니다.'.
  ENDIF.

ENDFORM.                    " FILL_FIELD_CATEGORY_1
*&---------------------------------------------------------------------*
*&      Form  MODIFY_FIELDCAT_1
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_GT_FIELDCAT_2  text
*----------------------------------------------------------------------*
FORM MODIFY_FIELDCAT_1  CHANGING  PT_FIELDCAT TYPE LVC_T_FCAT.

  DATA: LS_FCAT          TYPE LVC_S_FCAT.

  LOOP AT PT_FIELDCAT INTO LS_FCAT .
    CASE  LS_FCAT-FIELDNAME.
      WHEN  'MANDT'.
        DELETE PT_FIELDCAT .
      WHEN  'MARK' .
        LS_FCAT-COL_POS    =  1.
        LS_FCAT-CHECKBOX   = 'X'.
*        IF GV_TRTYP        = 'V'.
        LS_FCAT-EDIT     = 'X'.
*        ELSE.
*          LS_FCAT-EDIT     = ' '.
*        ENDIF.
        LS_FCAT-FIX_COLUMN = 'X'.
        LS_FCAT-KEY = 'X'.
        LS_FCAT-COLTEXT    = '선택'.
        MODIFY PT_FIELDCAT FROM LS_FCAT INDEX SY-TABIX.
      WHEN  'LIGHTS' .
        LS_FCAT-COL_POS    =  2.
        LS_FCAT-COLTEXT    = '모니터'.
        LS_FCAT-KEY = ' '.
        MODIFY PT_FIELDCAT FROM LS_FCAT INDEX SY-TABIX.
*      WHEN 'STATUS'.
*            DELETE pt_fieldcat .
      WHEN  'STATUST' .
        LS_FCAT-COL_POS    =  4.
        LS_FCAT-COLTEXT    = '상태'.
        LS_FCAT-KEY = ' '.
        MODIFY PT_FIELDCAT FROM LS_FCAT INDEX SY-TABIX.
      WHEN  'WERKST' .
*        LS_FCAT-COL_POS    =  5.
        LS_FCAT-COLTEXT    = '플랜트내역'.
        LS_FCAT-KEY = ' '.
        MODIFY PT_FIELDCAT FROM LS_FCAT INDEX SY-TABIX.
      WHEN 'RCEPNO'.
        IF GV_SUBSCR_2 = '1310'.
          LS_FCAT-HOTSPOT    =  'X'.
          MODIFY PT_FIELDCAT FROM LS_FCAT INDEX SY-TABIX.
        ENDIF.
      WHEN 'BELNR'.
        LS_FCAT-HOTSPOT    =  'X'.
        MODIFY PT_FIELDCAT FROM LS_FCAT INDEX SY-TABIX.
      WHEN 'VBELN' OR 'KDAUF'.
        LS_FCAT-HOTSPOT    =  'X'.
        MODIFY PT_FIELDCAT FROM LS_FCAT INDEX SY-TABIX.
      WHEN 'LVBELN'.
        LS_FCAT-HOTSPOT    =  'X'.
        MODIFY PT_FIELDCAT FROM LS_FCAT INDEX SY-TABIX.
      WHEN 'PRUEFLOS'.
        LS_FCAT-HOTSPOT    =  'X'.
        MODIFY PT_FIELDCAT FROM LS_FCAT INDEX SY-TABIX.
      WHEN 'ZAEDAT_B'.
        LS_FCAT-COLTEXT = 'BackJob Update일'.
        MODIFY PT_FIELDCAT FROM LS_FCAT INDEX SY-TABIX.

      WHEN 'ZAEZET_B'.
        LS_FCAT-COLTEXT = 'BackJob Update 시간'.
        MODIFY PT_FIELDCAT FROM LS_FCAT INDEX SY-TABIX.
      WHEN OTHERS.
    ENDCASE.
  ENDLOOP.

  CLEAR :  LS_FCAT .

ENDFORM.                    " MODIFY_FIELDCAT_1
*&---------------------------------------------------------------------*
*&      Form  PRO_LAYOUT_1
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GS_LAYOUT_2  text
*----------------------------------------------------------------------*
FORM PRO_LAYOUT_1  USING  P_LAYOCAT TYPE LVC_S_LAYO.
*- General display options
* 컬럼 사이즈에 따라서 자동으로 길이를 지정함.
  P_LAYOCAT-CWIDTH_OPT = 'X'.
*- Grid customizing
* TITLE BAR
*  p_layocat-grid_title = '검사여장 수량 변경'.
* Selection modes for SEL_MODE
* 'A' : Column and row selection
* 'B' : Simple selection, list box
* 'C' : Multiple selection, list box
* 'D' : Cell selection
  P_LAYOCAT-SEL_MODE = 'D'.
  P_LAYOCAT-NO_ROWMARK = 'X'.
  P_LAYOCAT-EDIT       = ' '.
* Provide the fieldname of the celltab field by using field
* STYLEFNAME of the layout structure.

*  p_layocat-excp_fname     = 'LIGHTS'.  "field for lights
*  p_layocat-excp_rolln     = 'QVLOTSLIGHTS'.  "F1 help forlights

*    gs_layocat-excp_rolln     = 'QVLOTSLIGHTS'.  "F1 help forlights
*    G_LAYOUT-LIGHTS_ROLLNAME    = 'QVLOTSLIGHTS'.  "F1 help forlights


*    p_layocat-edit = 'X'.
*-Color

* GRID 별로 색깔을 지정
*  p_layocat-zebra      = 'X'.

ENDFORM.                    " PRO_LAYOUT_1
*&---------------------------------------------------------------------*
*&      Form  G_GRID_2_REFRESH
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM G_GRID_2_REFRESH .
  GS_SCROLL-ROW = 'X'.
  GS_SCROLL-COL = 'X'.

  CALL METHOD G_GRID_2->REFRESH_TABLE_DISPLAY
    EXPORTING
      I_SOFT_REFRESH = ' '
      IS_STABLE      = GS_SCROLL.

*  CALL METHOD CL_GUI_CFW=>FLUSH.
ENDFORM.                    " G_GRID_2_REFRESH
*&---------------------------------------------------------------------*
*&      Form  G_GRID_3_REFRESH
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM G_GRID_3_REFRESH .

  GS_SCROLL-ROW = 'X'.
  GS_SCROLL-COL = 'X'.

  CALL METHOD G_GRID_3->REFRESH_TABLE_DISPLAY
    EXPORTING
      I_SOFT_REFRESH = ' '
      IS_STABLE      = GS_SCROLL.

*  CALL METHOD CL_GUI_CFW=>FLUSH.

ENDFORM.                    " G_GRID_3_REFRESH
*&---------------------------------------------------------------------*
*&      Form  GET_ICON_IMAGE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_0429   text
*      <--P_GV_ICON1  text
*----------------------------------------------------------------------*
FORM GET_ICON_IMAGE  USING    P_0429
                     CHANGING P_ICON.

  CLEAR: P_ICON.

  IF P_0429 = '3'.

    READ TABLE GT_140 WITH KEY DFLG = ''
                               STATUS = '1'.
    IF SY-SUBRC = 0.
      P_ICON = '@0A@'.
    ELSE.
      READ TABLE GT_150 WITH KEY DFLG = ''
                                 STATUS = '1'.
      IF SY-SUBRC = 0.
        P_ICON = '@0A@'.
      ELSE.
        P_ICON = '@08@'.
      ENDIF.
    ENDIF.

  ELSEIF P_0429 = '4'.

    READ TABLE GT_140 WITH KEY DFLG = ''
                               STATUS = '1'.
    IF SY-SUBRC = 0.
      P_ICON = '@0A@'.
    ELSE.
      P_ICON = '@08@'.
    ENDIF.

  ELSEIF P_0429 = '5'.

    READ TABLE GT_150 WITH KEY DFLG = ''
                               STATUS = '1'.
    IF SY-SUBRC = 0.
      P_ICON = '@0A@'.
    ELSE.
      P_ICON = '@08@'.
    ENDIF.

  ENDIF.

ENDFORM.                    " GET_ICON_IMAGE
*&---------------------------------------------------------------------*
*&      Form  CLEAR_ALL_DATA2
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM CLEAR_ALL_DATA2 .
  GV_RCEPNO = GS_100-RCEPNO.

  CLEAR   : GT_100,     GT_110,     GT_120,     GT_130,     GS_100,
            GT_140,     GT_150,     GT_160,     GT_170,     GT_180,
            GT_190,     GT_200,     GT_210,     GT_220,     GT_230,
            GT_240,     GT_250,     GT_260,     GT_270,     GT_280,
            GT_110A.

  REFRESH : GT_100,     GT_110,     GT_120,     GT_130,     GT_140,
            GT_150,     GT_160,     GT_170,     GT_180,     GT_190,
            GT_200,     GT_210,     GT_220,     GT_230,     GT_240,
            GT_250,     GT_260,     GT_270,     GT_280,     GT_110A.

ENDFORM.                    " CLEAR_ALL_DATA2
*&---------------------------------------------------------------------*
*&      Form  GET_WERKST
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GS_100_WERKS  text
*      <--P_GS_100_WERKST  text
*----------------------------------------------------------------------*
FORM GET_WERKST  USING    P_WERKS
                 CHANGING P_WERKST.

  IF  NOT   P_WERKS  IS INITIAL.
    SELECT SINGLE NAME1
             INTO P_WERKST
             FROM T001W
            WHERE WERKS = P_WERKS.   "플랜트

    IF  SY-SUBRC  NE  0.
      MESSAGE E001  WITH '존재하지 않는 플랜트입니다.'.
    ENDIF.
  ELSE.
    CLEAR:  P_WERKST.
  ENDIF.

ENDFORM.                    " GET_WERKST
*&---------------------------------------------------------------------*
*&      Form  GET_PRCTRT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GS_100_PRCTR  text
*      <--P_GS_100_PRCTRT  text
*----------------------------------------------------------------------*
FORM GET_PRCTRT  USING    P_PRCTR
                 CHANGING P_PRCTRT.

  IF  NOT  P_PRCTR  IS INITIAL.
    SELECT SINGLE KTEXT
             INTO P_PRCTRT
             FROM CEPCT
            WHERE PRCTR = P_PRCTR    "손익센터
              AND SPRAS = SY-LANGU.

    IF  SY-SUBRC  NE  0.
      MESSAGE E001  WITH '존재하지 않는 손익센터 입니다.'.
    ENDIF.
  ELSE.
    CLEAR: P_PRCTRT.
  ENDIF.

ENDFORM.                    " GET_PRCTRT
*&---------------------------------------------------------------------*
*&      Form  GET_KUNUMT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GS_100_KUNUM  text
*      <--P_GS_100_KUNUMT  text
*----------------------------------------------------------------------*
FORM GET_KUNUMT  USING    P_KUNUM
                 CHANGING P_KUNUMT.

  IF  NOT  P_KUNUM  IS INITIAL.
    SELECT SINGLE NAME1
             INTO P_KUNUMT
             FROM KNA1
            WHERE KUNNR = P_KUNUM.   "고객번호

    IF  SY-SUBRC  NE  0.
      MESSAGE E001  WITH '존재하지 않는 고객번호입니다.'.
    ENDIF.
  ELSE.
    CLEAR: P_KUNUMT.
  ENDIF.

ENDFORM.                    " GET_KUNUMT
*&---------------------------------------------------------------------*
*&      Module  DISPLAY_NOTIFICATION  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE DISPLAY_NOTIFICATION INPUT.

  CHECK GS_100-SQMNUM <> ''.

  SET PARAMETER ID 'IQM' FIELD GS_100-SQMNUM.

  CALL TRANSACTION 'IW53' AND SKIP FIRST SCREEN.

ENDMODULE.                 " DISPLAY_NOTIFICATION  INPUT
*&---------------------------------------------------------------------*
*&      Form  CANC_COMPLAIN_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM CANC_COMPLAIN_DATA .

  $$POPUP_TO_CONFIRM_STEP '고객불만을 취소하시겠습니까?'
                          ' '
                          '고객불만 취소'.

  CHECK GV_ANSWER = 'J'.


  SELECT SINGLE *
    FROM ZQMT0014S
    WHERE RCEPNO = GV_RCEPNO
    AND STATUS <> '3'.
  IF SY-SUBRC = 0.
    MESSAGE E002 WITH '유효한 반품/출고오더 또는 반품 검사로트가'
                      '존재하여 취소할 수 없습니다.'.
  ELSE.


*C20110504_78331
    SELECT SINGLE * FROM ZQMT0015Q
                   WHERE RCEPNO = GV_RCEPNO
                  AND STATUS <> '3'.
    IF SY-SUBRC = 0.
      MESSAGE E002 WITH '유효한 반품/출고오더 또는 반품 검사로트가'
                        '존재하여 취소할 수 없습니다.'.
    ENDIF.
  ENDIF.

  SELECT SINGLE *
    FROM ZQMT0016F
    WHERE RCEPNO = GV_RCEPNO
    AND DFLG = ''.
  IF SY-SUBRC = 0.
    MESSAGE E001 WITH '유효한 전표가 존재하여 취소할 수 없습니다.'.
  ENDIF.

  DATA: BEGIN OF LT_0011M OCCURS 0,
          RTAMT  LIKE ZQMT0011M-RTAMT,
          RTAMT2 LIKE ZQMT0011M-RTAMT2,
          GBAMT  LIKE ZQMT0011M-GBAMT,
          CLAMT  LIKE ZQMT0011M-CLAMT,
        END OF LT_0011M.

  DATA: LS_0011M LIKE LT_0011M.

  SELECT RTAMT RTAMT2 GBAMT CLAMT
    FROM ZQMT0011M
    INTO CORRESPONDING FIELDS OF TABLE LT_0011M
    WHERE RCEPNO = GV_RCEPNO
    AND KZLOESCH = ''.

  LOOP AT LT_0011M INTO LS_0011M.
    COLLECT LT_0011M.        CLEAR LT_0011M.
  ENDLOOP.

  IF LT_0011M-RTAMT > 0 OR LT_0011M-RTAMT2 > 0 OR
     LT_0011M-GBAMT > 0 OR LT_0011M-CLAMT > 0.
    MESSAGE E001 WITH '유효한 손실금액이 존재하여 취소할 수 없습니다.'.
  ENDIF.
*C20110504_78331
  GS_100-KZLOESCH = 'X'.
  GS_100-STATUS = 'CL99'.

ENDFORM.                    " CANC_COMPLAIN_DATA
*&---------------------------------------------------------------------*
*&      Form  G_GRID_4_REFRESH
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM G_GRID_4_REFRESH .

  CALL METHOD G_GRID_4->REFRESH_TABLE_DISPLAY
    EXPORTING
      I_SOFT_REFRESH = ' '.

  CALL METHOD CL_GUI_CFW=>FLUSH.

ENDFORM.                    " G_GRID_4_REFRESH
*&---------------------------------------------------------------------*
*&      Module  DISPLAY_NOTIFICATION2  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE DISPLAY_NOTIFICATION2 INPUT.

  CHECK GS_100-AUFNR <> ''.

  SET PARAMETER ID 'ANR' FIELD GS_100-AUFNR.

  CALL TRANSACTION 'IW33' AND SKIP FIRST SCREEN.

ENDMODULE.                 " DISPLAY_NOTIFICATION2  INPUT
*&---------------------------------------------------------------------*
*&      Form  G_GRID_5_REFRESH
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM G_GRID_5_REFRESH .
  CALL METHOD G_GRID_5->REFRESH_TABLE_DISPLAY
    EXPORTING
      I_SOFT_REFRESH = ' '.

  CALL METHOD CL_GUI_CFW=>FLUSH.
ENDFORM.                    " G_GRID_5_REFRESH
*&---------------------------------------------------------------------*
*&      Form  MODIFY_SCREEN_BUTTON
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_1441   text
*      -->P_1442   text
*      -->P_1443   text
*----------------------------------------------------------------------*
FORM MODIFY_SCREEN_BUTTON  USING    P_DO
                                    P_CR
                                    P_CH.
  IF P_DO IS NOT INITIAL.
    IF SCREEN-NAME = P_CR.
      SCREEN-INPUT = 0.
    ELSEIF SCREEN-NAME = P_CH.
      SCREEN-INPUT = 1.
    ENDIF.
  ELSE.
    IF SCREEN-NAME = P_CR.
      SCREEN-INPUT = 1.
    ELSEIF SCREEN-NAME = P_CH.
      SCREEN-INPUT = 0.
    ENDIF.
  ENDIF.

ENDFORM.                    " MODIFY_SCREEN_BUTTON
*&---------------------------------------------------------------------*
*&      Module  DISPLAY_NOTIFICATION3  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE DISPLAY_NOTIFICATION3 INPUT.

  CHECK GV_RE <> ''.

  SET PARAMETER ID 'AUN' FIELD GV_RE.

  CALL TRANSACTION 'VA03' AND SKIP FIRST SCREEN.

ENDMODULE.                 " DISPLAY_NOTIFICATION3  INPUT
*&---------------------------------------------------------------------*
*&      Module  DISPLAY_NOTIFICATION4  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE DISPLAY_NOTIFICATION4 INPUT.

  CHECK GV_ZREQ <> ''.

  SET PARAMETER ID 'AUN' FIELD GV_ZREQ.

  CALL TRANSACTION 'VA03' AND SKIP FIRST SCREEN.

ENDMODULE.                 " DISPLAY_NOTIFICATION4  INPUT
*&---------------------------------------------------------------------*
*&      Module  DISPLAY_NOTIFICATION5  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE DISPLAY_NOTIFICATION5 INPUT.

  CHECK GV_ZORQ <> ''.

  SET PARAMETER ID 'AUN' FIELD GV_ZORQ.

  CALL TRANSACTION 'VA03' AND SKIP FIRST SCREEN.

ENDMODULE.                 " DISPLAY_NOTIFICATION5  INPUT
*&---------------------------------------------------------------------*
*&      Module  DISPLAY_NOTIFICATION6  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE DISPLAY_NOTIFICATION6 INPUT.

  CHECK GV_ZFQ <> ''.

  SET PARAMETER ID 'AUN' FIELD GV_ZFQ.

  CALL TRANSACTION 'VA03' AND SKIP FIRST SCREEN.

ENDMODULE.                 " DISPLAY_NOTIFICATION6  INPUT
*&---------------------------------------------------------------------*
*&      Form  GET_DATA_180
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM GET_DATA_180 .

  CLEAR   : GT_180, GV_TEXT1.
  REFRESH : GT_180.

  IF GV_CHK = '1'.
    GV_TEXT1 = '동시에 정상반품(RE)을 진행할 품목을 모두 선택하십시오.'.
  ELSEIF GV_CHK = '2'.
    GV_TEXT1 =
    '동시에 클레임출고(ZFQ)을 진행할 품목을 모두 선택하십시오.'.
  ENDIF.

  SELECT A~ZMATSEQ
         A~MATNR
         A~WERKS_M
         A~KDAUF
         B~KDPOS
         B~RKMNG
         A~MGEIN
*         A~KDPOS
    INTO CORRESPONDING FIELDS OF TABLE GT_180
    FROM ZQMT0011M      AS A
   INNER JOIN ZQMT0011B AS B
      ON A~RCEPNO   = B~RCEPNO
     AND A~ZMATSEQ  = B~ZMATSEQ
   WHERE A~RCEPNO   = GV_RCEPNO
     AND A~KZLOESCH = ' '
     AND A~KDAUF    = GV_KDAUF
*     AND A~ZMATSEQ  = GV_ZMATSEQ
     AND A~WERKS_M  = GV_WERKS_M.


  LOOP AT GT_180.
*___자재내역
    PERFORM GET_MATNR_DESC USING GT_180-MATNR
                                 GT_180-MAKTX.
* 판매문서의 품목번호 조회
*    SELECT SINGLE POSNR
*      INTO GT_180-KDPOS
*      FROM VBAP
*     WHERE MATNR = GT_180-MATNR
*       AND VBELN = GT_180-KDAUF.
    MODIFY GT_180.
  ENDLOOP.

ENDFORM.                    " GET_DATA_180
*&---------------------------------------------------------------------*
*&      Form  ALV_INIT_180
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM ALV_INIT_180 .

  IF  G_CUSTOM_C_6  IS INITIAL.
    CREATE OBJECT G_CUSTOM_C_6
      EXPORTING
        CONTAINER_NAME              = G_CONTAINER_6
      EXCEPTIONS
        CNTL_ERROR                  = 1
        CNTL_SYSTEM_ERROR           = 2
        CREATE_ERROR                = 3
        LIFETIME_ERROR              = 4
        LIFETIME_DYNPRO_DYNPRO_LINK = 5.

    CREATE OBJECT G_GRID_6
      EXPORTING
        I_APPL_EVENTS = 'X'
        I_PARENT      = G_CUSTOM_C_6.

    PERFORM  FILL_FIELD_CATEGORY_1    USING  'GT_180'
                                      CHANGING  GT_FIELDCAT_6 .
    PERFORM  MODIFY_FIELDCAT_1     CHANGING  GT_FIELDCAT_6 .

    PERFORM PRO_LAYOUT_1 USING GS_LAYOUT_6.

*-Edit Event 및 Event Handler 등록
    PERFORM EVENT_HANDLER_REGISTER_180.

*-- At least field REPORT of this structure has to be filled!
    GS_VARIANT_6-REPORT = SY-REPID.

    CALL METHOD G_GRID_6->SET_TABLE_FOR_FIRST_DISPLAY
      EXPORTING
        IS_LAYOUT            = GS_LAYOUT_6
        IT_TOOLBAR_EXCLUDING = GT_EXCLUDE
*       i_save               = 'A'   " 전체가능유형.
        IS_VARIANT           = GS_VARIANT_6  " 선택 메뉴 display
      CHANGING
        IT_FIELDCATALOG      = GT_FIELDCAT_6
*       IT_SORT              = GT_SORT
        IT_OUTTAB            = GT_180[].
  ELSE.
    PERFORM G_GRID_6_REFRESH.
  ENDIF .

*  CALL METHOD G_GRID_100->SET_TOOLBAR_INTERACTIVE.

*  CALL METHOD CL_GUI_CONTROL=>SET_FOCUS
*    EXPORTING
*      CONTROL = G_GRID_6.
ENDFORM.                    " ALV_INIT_180
*&---------------------------------------------------------------------*
*&      Form  G_GRID_6_REFRESH
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM G_GRID_6_REFRESH .
  GS_SCROLL-ROW = 'X'.
  GS_SCROLL-COL = 'X'.

  CALL METHOD G_GRID_6->REFRESH_TABLE_DISPLAY
    EXPORTING
      I_SOFT_REFRESH = ' '
      IS_STABLE      = GS_SCROLL.

  CALL METHOD CL_GUI_CFW=>FLUSH.
ENDFORM.                    " G_GRID_6_REFRESH
*&---------------------------------------------------------------------*
*&      Form  EVENT_HANDLER_REGISTER_170
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM EVENT_HANDLER_REGISTER_170 .

* TOOLBAR 구성은 EVENT에서 한다.
  CREATE OBJECT G_EVENT_HANDLER_5.
*

*-Edit  이벤트 등록
  CALL METHOD G_GRID_5->REGISTER_EDIT_EVENT
    EXPORTING
      I_EVENT_ID = CL_GUI_ALV_GRID=>MC_EVT_MODIFIED.

  CALL METHOD G_GRID_5->REGISTER_EDIT_EVENT
    EXPORTING
      I_EVENT_ID = CL_GUI_ALV_GRID=>MC_EVT_ENTER.

* 툴바지정
  SET HANDLER G_EVENT_HANDLER_5->HANDLE_TOOLBAR
                              FOR G_GRID_5.
* 툴바에 해당하는 이벤트 지정
  SET HANDLER G_EVENT_HANDLER_5->HANDLE_USER_COMMAND
                              FOR G_GRID_5.
** DATA_CHANGED
  SET HANDLER G_EVENT_HANDLER_5->HANDLE_DATA_CHANGED_1 FOR G_GRID_5.
  SET HANDLER G_EVENT_HANDLER_5->HANDLE_DATA_CHANGED_FINISHED_1
                                                     FOR G_GRID_5.
  SET HANDLER G_EVENT_HANDLER_5->HANDLE_HOTSPOT_CLICK_6
                        FOR G_GRID_5.

ENDFORM.                    " EVENT_HANDLER_REGISTER_170
*&---------------------------------------------------------------------*
*&      Form  DATA_CHANGED_1
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_ER_DATA_CHANGED  text
*----------------------------------------------------------------------*
FORM DATA_CHANGED_1  USING    ER_DATA_CHANGED
                            TYPE REF TO CL_ALV_CHANGED_DATA_PROTOCOL.
*
  DATA: LS_MOD_CELLS TYPE LVC_S_MODI,
        LS_CELLS     TYPE LVC_S_MODI,
        LS_FIELDCAT  TYPE LVC_S_FCAT.

  CLEAR: GT_170, GS_170, GV_RE, GV_ZREQ, GV_ZORQ, GV_ZFQ.

  LOOP AT ER_DATA_CHANGED->MT_GOOD_CELLS INTO LS_MOD_CELLS.

    READ TABLE GT_170 INDEX LS_MOD_CELLS-ROW_ID.
    MOVE-CORRESPONDING GT_170 TO GS_170.

    IF GS_170-AUART EQ 'RE'.
      IF GT_170-MARK IS INITIAL.
        GV_RE = GS_170-VBELN.
      ELSE.
        CLEAR GV_RE.
      ENDIF.
    ENDIF.

    IF GS_170-AUART EQ 'ZREQ'.
      IF GT_170-MARK IS INITIAL.
        GV_ZREQ = GS_170-VBELN.
      ELSE.
        CLEAR GV_ZREQ.
      ENDIF.
    ENDIF.

    IF GS_170-AUART EQ 'ZORQ'.
      IF GT_170-MARK IS INITIAL.
        GV_ZORQ = GS_170-VBELN.
      ELSE.
        CLEAR GV_ZORQ.
      ENDIF.
    ENDIF.

    IF GS_170-AUART EQ 'ZFQ'.
      IF GT_170-MARK IS INITIAL.
        GV_ZFQ = GS_170-VBELN.
      ELSE.
        CLEAR GV_ZFQ.
      ENDIF.
    ENDIF.

  ENDLOOP.

  LOOP AT GT_170.
    IF LS_MOD_CELLS-ROW_ID NE SY-TABIX.
      GT_170-MARK = SPACE.
    ELSE.
      GT_170-MARK = 'X'.
    ENDIF.
    MODIFY GT_170.
  ENDLOOP.

ENDFORM.                    " DATA_CHANGED_1
*&---------------------------------------------------------------------*
*&      Form  GET_SPART
*&---------------------------------------------------------------------*
*       수량 및 제품군을 읽어온다.
*----------------------------------------------------------------------*
FORM GET_SPART  USING    P_MATNR      "자재번호
                CHANGING P_SPGCD      "제품군
                         P_MEINS.     "수량
  CLEAR: P_SPGCD, P_MEINS.

  CHECK NOT P_MATNR IS INITIAL.
  SELECT SINGLE MEINS SPART
           FROM MARA
           INTO (P_MEINS, P_SPGCD)
          WHERE MATNR EQ P_MATNR.

ENDFORM.                    " GET_SPART
*&---------------------------------------------------------------------*
*&      Form  GET_SPGCD_DESC
*&---------------------------------------------------------------------*
*       제품군 코드를 읽어온다.
*----------------------------------------------------------------------*
FORM GET_SPGCD_DESC  USING    P_CODE
                     CHANGING P_TEXT.
  CLEAR: P_TEXT.

  CHECK NOT P_CODE IS INITIAL.
  SELECT SINGLE VTEXT
           FROM TSPAT
           INTO P_TEXT
          WHERE SPRAS EQ SY-LANGU
            AND SPART EQ P_CODE.    "SPG (제품군 )

ENDFORM.                    " GET_SPGCD_DESC
*&---------------------------------------------------------------------*
*&      Form  BDC_VA01_RE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM BDC_VA01_RE .
  DATA: LV_RKMNG(15),
        LV_TCODE LIKE SY-TCODE.

  DATA: BEGIN OF LT_180 OCCURS 0,
          MARK,
          ZMATSEQ(6),  "  LIKE ZQMT0011M-ZMATSEQ,
          MATNR      LIKE ZQMT0011M-MATNR,
          MAKTX      LIKE MAKT-MAKTX,
          WERKS_M    LIKE ZQMT0011M-WERKS_M,
          KDAUF      LIKE ZQMT0011M-KDAUF,
          KDPOS(6), "    LIKE ZQMT0011B-KDPOS,
          RKMNG      LIKE ZQMT0011M-RKMNG,
          MGEIN      LIKE ZQMT0011M-MGEIN,
        END OF LT_180.
* 일단 sum해줌
  LOOP AT     GT_180.
    CLEAR LT_180.
    MOVE-CORRESPONDING GT_180  TO  LT_180.
    LT_180-ZMATSEQ = LT_180-ZMATSEQ.
    LT_180-KDPOS = LT_180-KDPOS.
    COLLECT LT_180.
  ENDLOOP.

  PERFORM STORE_BDCDATA   USING:
           'X'  'SAPMV45A'          '0101',
           ' '  'BDC_OKCODE'        '=COPY',
           ' '  'VBAK-AUART'        'RE',
           ' '  'VBAK-VKORG'         GS_100-BUKRS,
           ' '  'VBAK-VTWEG'         GS_100-VTWEG,
           ' '  'VBAK-SPART'         GS_100-SPGCD,
           ' '  'VBAK-VKBUR'         GS_100-VKBUR,
           ' '  'VBAK-VKGRP'         GS_100-VKGRP.


  PERFORM STORE_BDCDATA   USING:
          'X'  'SAPLV45C'          '0100',
          ' '  'BDC_OKCODE'        '=RUE1',
          ' '  'LV45C-VBELN'       GT_160-KDAUF.

  PERFORM STORE_BDCDATA   USING:
        'X'  'SAPMV45A'           '4413',
        ' '  'BDC_OKCODE'         '=MKLO'.


  LOOP AT LT_180 WHERE MARK = 'X'.


    LV_RKMNG = LT_180-RKMNG.


    CONDENSE LV_RKMNG NO-GAPS.

    PERFORM STORE_BDCDATA   USING:
            'X'  'SAPMV45A'          '4413',
            ' '  'BDC_OKCODE'        '=POPO'.

    PERFORM STORE_BDCDATA   USING:
            'X'  'SAPMV45A'          '0251',
            ' '  'BDC_OKCODE'        '=POSI',
            ' '  'RV45A-POSNR'       LT_180-KDPOS.

    PERFORM STORE_BDCDATA   USING:
            'X'  'SAPMV45A'            '4413',
            ' '  'BDC_OKCODE'          '/00',
            ' ' 'RV45A-VBAP_SELKZ(01)' 'X',
            ' ' 'VBAPD-ORFMNG(01)'     LV_RKMNG.

  ENDLOOP.

  PERFORM STORE_BDCDATA   USING:
          'X'  'SAPMV45A'          '4413',
          ' '  'BDC_OKCODE'        '=RUEB'.

  PERFORM STORE_BDCDATA   USING:
          'X'  'SAPMV45A'          '4001',
*          ' '  'BDC_OKCODE'        '/00',
          ' '  'BDC_OKCODE'        '=KKAU',
          ' '  'VBKD-BSTKD'        GV_RCEPNO.

  PERFORM STORE_BDCDATA   USING:
          'X'  'SAPMV45A'          '4002',
          ' '  'BDC_OKCODE'        '/EBACK',
          ' ' 'VBAK-AUGRU'         GS_100-DSTGR.

*->[가온전선]--------------------CHG S
  "SAPMV45A userexit_save_document_prepare => check_qm 에서 IMPORT
  LV_TCODE = 'ZGTSDR1250' .
*  LV_TCODE = 'ZQM2R0696' .
*-<[가온전선]--------------------CHG E
  EXPORT LV_TCODE TO MEMORY ID 'BDC_CALLER'.

  PERFORM BDC_TRANSACTION  USING     'VA01'
                                     'E'
                           CHANGING  GV_SUBRC.

  READ    TABLE MESSTAB  WITH KEY MSGTYP = 'S' MSGNR = '311'.
  IF  SY-SUBRC  EQ  0.

    CLEAR : GV_RFUND, GV_AUART.

    GV_RFUND = MESSTAB-MSGV2.

    SELECT SINGLE AUART
      INTO GV_AUART
      FROM VBAK
     WHERE VBELN EQ GV_RFUND.

    CLEAR GV_ERROR_FLG.

    COMMIT WORK.
    MESSAGE S003  WITH MESSTAB-MSGV1  MESSTAB-MSGV2
                       '을(를) 생성하였습니다'.
  ELSE.
    MESSAGE S001  WITH '정상반품오더 생성중 오류가 발생하였습니다'.
    GV_ERROR_FLG = 'X'.
    EXIT.
  ENDIF.


ENDFORM.                    " BDC_VA01_RE
*&---------------------------------------------------------------------*
*&      Form  STORE_BDCDATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_4124   text
*      -->P_4125   text
*      -->P_4126   text
*----------------------------------------------------------------------*
FORM STORE_BDCDATA  USING P_BEGIN
                          P_FNAM
                          P_FVAL.

  CLEAR  GT_BDC.

  IF  P_BEGIN <> SPACE.                    " BDC화면 시작여부
    GT_BDC-DYNBEGIN    =  P_BEGIN.         " 새로운 화면시작
    GT_BDC-PROGRAM     =  P_FNAM.          " BDC 프로그램 ID
    GT_BDC-DYNPRO      =  P_FVAL.          " BDC 화면번호
  ELSE.
    GT_BDC-FNAM        =  P_FNAM.          " 필드이름
    GT_BDC-FVAL        =  P_FVAL.          " BDC 필드값
  ENDIF.

  APPEND    GT_BDC.

ENDFORM.                    " STORE_BDCDATA
*&---------------------------------------------------------------------*
*&      Form  BDC_TRANSACTION
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_4291   text
*      -->P_4292   text
*      <--P_GV_SUBRC  text
*----------------------------------------------------------------------*
FORM BDC_TRANSACTION  USING     P_TCODE
                               VALUE(P_DIMODE)
                     CHANGING  P_SUBRC.

  DATA: L_DIMODE LIKE CTU_PARAMS-DISMODE VALUE 'E',  "A, E, N
        L_UPDATE LIKE CTU_PARAMS-UPDMODE VALUE 'S'.  "S, A, L
*

  L_DIMODE = P_DIMODE.

  CLEAR:   MESSTAB, GV_SUBRC.
  REFRESH  MESSTAB.
*
*  CALL  TRANSACTION  p_tcode   USING  gt_bdc
*                                MODE  l_dimode
*                              UPDATE  l_update
*                            MESSAGES  INTO messtab.


  CLEAR: GW_BDCPARAMS.

  GW_BDCPARAMS-DISMODE  = P_DIMODE.   " 처리모드
  GW_BDCPARAMS-UPDMODE  = 'L'.   " 갱신세션
*  gw_bdcparams-cattmode = 'A'.   " CATT모드
  GW_BDCPARAMS-DEFSIZE  = ' '.   " 기본화면
  GW_BDCPARAMS-RACOMMIT = 'X'.   " COMMAND 이후 지속
  GW_BDCPARAMS-NOBINPT  = 'X'.   " BI 세션
  CALL TRANSACTION P_TCODE USING GT_BDC
                         OPTIONS FROM GW_BDCPARAMS
                   MESSAGES INTO MESSTAB.
  P_SUBRC    =  SY-SUBRC.



ENDFORM.                    " BDC_TRANSACTION
*&---------------------------------------------------------------------*
*&      Form  GET_VBAK_RFUND_102
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM GET_VBAK_RFUND_102  USING VALUE(P_RFUND)
                                VALUE(P_POSNR)
                                VALUE(P_AUART)
                      CHANGING  VALUE(P_VRKME)
                                VALUE(P_KWMENG)
                                VALUE(P_RFAMT)
                                VALUE(P_RFMEIN)
                                VALUE(P_ERATE)
                                VALUE(P_RMEIN)
                                VALUE(P_LVBELN)
                                VALUE(P_LPOSNR)
                                VALUE(P_FROM_FACTOR)
                                VALUE(P_LFIMG)
                                VALUE(P_NETPR)
                                VALUE(P_WAERK)
                                VALUE(P_ZMATSEQ).

  DATA: L_KNUMV      TYPE VBAK-KNUMV,
        L_WAERK      TYPE VBAK-WAERK,
        L_AMT        TYPE VBAK-NETWR,
        LS_EXCH_RATE TYPE BAPI1093_0,
        LS_RETURN    TYPE BAPIRET1.

  DATA: LS_VBAK        LIKE GS_VBAK_R.
  DATA: LT_VBAK        LIKE TABLE OF LS_VBAK WITH HEADER LINE.
  DATA: L_NETWR_TOT LIKE VBAP-NETWR.
  DATA: L_KDATU LIKE KONV-KDATU,
        L_AUART LIKE VBAK-AUART.

  DATA: BEGIN OF LS_CODE,
          VDATU TYPE VBAK-VDATU,   "납품요청일
          VKORG TYPE VBAK-VKORG,  " 영업조직
          VTWEG TYPE VBAK-VTWEG,  " 유통경로
          SPART TYPE VBAK-SPART,  " 제품군
          VKGRP TYPE VBAK-VKGRP,  " 영업그룹
          VKBUR TYPE VBAK-VKBUR,  " 영업팀
          KUNNR TYPE VBAK-KUNNR,  " 판매처
        END OF   LS_CODE.
  DATA: LT_CODE        LIKE TABLE OF LS_CODE.

  DATA: L_NETPR LIKE VBAP-NETPR,
        L_KPEIN LIKE VBAP-KPEIN,
        L_KMEIN LIKE VBAP-KMEIN,
        L_VBELN LIKE VBAP-VBELN.



  SELECT  SINGLE KNUMV WAERK
       INTO  (L_KNUMV, L_WAERK)
       FROM  VBAK
      WHERE  VBELN  EQ  P_RFUND.

  IF  SY-SUBRC  NE  0.
    EXIT.
  ENDIF.

  IF P_AUART EQ 'ZFQ'.
    PERFORM  GET_MESG_COST2      USING  P_RFUND
                                        P_POSNR
                              CHANGING  P_RFAMT
                                        P_ZMATSEQ.
    EXIT.
  ENDIF.


  IF P_AUART EQ 'RE'.

    CLEAR : P_RFAMT, P_KWMENG, P_VRKME,
            P_LFIMG, P_ERATE,  P_RMEIN,
            P_FROM_FACTOR,     P_NETPR.

    PERFORM GET_RE_COST USING P_RFUND P_POSNR
                        CHANGING P_RFAMT
                          P_KWMENG P_VRKME
                          P_LFIMG
                          P_ERATE
                          P_RMEIN
                          P_FROM_FACTOR
                          P_NETPR
                          P_WAERK
                          P_ZMATSEQ.

    P_RFMEIN   = 'KRW'.
    EXIT.

  ENDIF.



  IF P_AUART EQ 'ZREQ'.

    P_ZMATSEQ = GV_ZMATSEQ.

    DATA: BEGIN OF LT_LIPS OCCURS 0,
            VBELN LIKE LIPS-VBELN,
            POSNR LIKE LIPS-POSNR,
            LFIMG LIKE LIPS-LFIMG,
            VRKME LIKE LIPS-VRKME,
            UECHA LIKE LIPS-UECHA,
          END   OF LT_LIPS.
    DATA: LT_TEMP  LIKE LT_LIPS  OCCURS 0 WITH HEADER LINE.

* 반품입고 수량 구함
*^ 오더번호로 출하문서 검색
    REFRESH LT_LIPS. CLEAR LT_LIPS.
*->CCM : ZITCS4HDEV01 2023.04.15 - VBUP 사용못하여 수정함
*    SELECT S~VBELN S~POSNR LFIMG VRKME UECHA
*      INTO CORRESPONDING FIELDS OF TABLE LT_LIPS
*      FROM LIKP  AS P
*      JOIN LIPS  AS S
*        ON P~VBELN = S~VBELN
*      JOIN VBUP  AS V
*        ON S~VBELN = V~VBELN
*       AND S~POSNR = V~POSNR
*     WHERE VGBEL = P_RFUND
*     AND VGPOS = P_POSNR
*       AND WBSTA = 'C'.          " 출고완료
**       AND zout <> 'W'.         " 실물입고여부 통문
    SELECT S~VBELN S~POSNR LFIMG VRKME UECHA
      INTO CORRESPONDING FIELDS OF TABLE LT_LIPS
      FROM LIKP  AS P
      JOIN LIPS  AS S
        ON P~VBELN = S~VBELN
     WHERE VGBEL = P_RFUND
     AND VGPOS = P_POSNR
       AND WBSTA = 'C'.          " 출고완료
*<-

    LT_TEMP[] = LT_LIPS[].
    LOOP AT LT_LIPS WHERE UECHA IS INITIAL.   "원래 품목번호

*   BATCH 분할한 경우 - 분할된 품목의 수량
      LOOP AT LT_TEMP WHERE VBELN = LT_LIPS-VBELN
                        AND UECHA = LT_LIPS-POSNR.

        ADD LT_TEMP-LFIMG TO P_LFIMG.

      ENDLOOP.

*   BATCH 분할 안한 경우 - 원 품목의 수량
      IF SY-SUBRC NE 0.
        ADD LT_LIPS-LFIMG TO P_LFIMG.

      ENDIF.
    ENDLOOP.


*-- 정상반품오더의 영업조직정보를 가져옴
    SELECT  *
    INTO CORRESPONDING FIELDS OF TABLE LT_CODE
    FROM VBAK
    WHERE VBELN = P_RFUND.

    READ TABLE LT_CODE INDEX 1 INTO LS_CODE.
*-- 자재코드와 영업정보로 최근의 판매오더를 가져옴
    SELECT MAX( B~VBELN )
    INTO L_VBELN
    FROM VBAP AS A INNER JOIN VBAK AS B
         ON A~VBELN EQ B~VBELN
    WHERE MATNR EQ GV_MATNR
    AND B~VKORG EQ LS_CODE-VKORG
    AND B~VTWEG EQ LS_CODE-VTWEG
    AND B~SPART EQ LS_CODE-SPART
*    AND b~vkgrp EQ ls_code-vkgrp  2009/09/01 김병준
*    AND b~vkbur EQ ls_code-vkbur
    AND B~KUNNR EQ LS_CODE-KUNNR
    AND B~VDATU < LS_CODE-VDATU
    AND ( B~AUART EQ 'TA' OR B~AUART = 'ZEXE'
    OR B~AUART = 'Z3RD' )  "OR 내수/로컬주문
*    AND b~vbeln < p_rfund
    AND A~NETPR > 0.

    IF L_VBELN IS NOT INITIAL.
*-- 오더에대한 단가를 가져옴
      SELECT SINGLE NETPR KPEIN WAERK KMEIN VBELN POSNR
      INTO (L_NETPR, L_KPEIN, L_WAERK, L_KMEIN,
      P_LVBELN, P_LPOSNR)
      FROM VBAP
      WHERE VBELN EQ L_VBELN
      AND MATNR EQ GV_MATNR.
    ELSE.
      SELECT MAX( B~VBELN )
      INTO L_VBELN
      FROM VBAP AS A INNER JOIN VBAK AS B
         ON A~VBELN EQ B~VBELN
      WHERE MATNR EQ GV_MATNR
      AND B~VKORG EQ LS_CODE-VKORG
      AND B~VTWEG EQ LS_CODE-VTWEG
      AND B~SPART EQ LS_CODE-SPART
*      AND b~vkgrp EQ ls_code-vkgrp
*      AND b~vkbur EQ ls_code-vkbur
      AND B~KUNNR EQ LS_CODE-KUNNR
      AND B~VDATU < LS_CODE-VDATU
    AND ( B~AUART EQ 'TA' OR B~AUART = 'ZEXE'
    OR B~AUART = 'Z3RD' )  "OR 내수/로컬주문
*      AND b~vbeln < p_rfund
      AND A~NETWR > 0.
* 오더에 대한 단가를 가져옴
      SELECT SINGLE NETWR AS NETPR KWMENG AS KPEIN WAERK KMEIN
      VBELN POSNR
      INTO (L_NETPR, L_KPEIN, L_WAERK, L_KMEIN,
      P_LVBELN, P_LPOSNR)
      FROM VBAP
      WHERE VBELN EQ L_VBELN
      AND MATNR EQ GV_MATNR.
    ENDIF.

    IF P_AUART NE 'ZREQ'.
      CLEAR :  P_LVBELN, P_LPOSNR.
    ENDIF.

    IF L_KMEIN EQ P_VRKME.
      LS_VBAK-NETWR = L_NETPR * P_LFIMG. "반품입고수량
      LS_VBAK-NETWR = LS_VBAK-NETWR / L_KPEIN.
      LS_VBAK-WAERK = L_WAERK.

      APPEND LS_VBAK TO LT_VBAK.
    ELSE.  "단위가 다를경우 또는 RE인 경우 표준원가를 가져옴
      SELECT KPOSN AS POSNR
             KWERT AS NETWR
             WAERS AS WAERK
             KDATU AS ERDAT
        INTO CORRESPONDING FIELDS OF TABLE LT_VBAK
        FROM KONV
       WHERE KNUMV EQ L_KNUMV
         AND KPOSN EQ P_POSNR
         AND KSCHL EQ 'VPRS'. "표준원가 "
    ENDIF.
  ENDIF.

  IF L_KDATU IS INITIAL.
    SELECT SINGLE KDATU
             INTO L_KDATU
             FROM KONV
            WHERE KNUMV EQ L_KNUMV
              AND KSCHL EQ 'VPRS'. "표준원가 "
    IF  SY-SUBRC  NE  0.
      EXIT.
    ENDIF.
  ENDIF.


  LOOP AT  LT_VBAK  INTO LS_VBAK.
    CLEAR: LS_EXCH_RATE, LS_RETURN.

* ls_vbak-waers는 전체금액에 대한 단위 l_waerk는 단가에 대한 단위
*    IF  ls_vbak-waerk  NE  'KRW'.
    IF  L_WAERK  NE  'KRW'.
      CALL FUNCTION 'BAPI_EXCHANGERATE_GETDETAIL'
        EXPORTING
          RATE_TYPE  = 'M'
          FROM_CURR  = L_WAERK   "ls_vbak-waers
          TO_CURRNCY = 'KRW'
          DATE       = L_KDATU "ls_vbak-erdat
        IMPORTING
          EXCH_RATE  = LS_EXCH_RATE
          RETURN     = LS_RETURN.

      IF  LS_RETURN-TYPE  NE  'E'.
*특히  JPY 인 경우  우리나라 돈보다 약 10배 정도 되는데  환율 Filed에는
*" 10 "이 들어가는 것이 아니고1000 " 이 들어 감..
* 환산율이 100:1 로 환율시장에서 통용
*        IF ls_vbak-waerk = 'JPY' AND ls_exch_rate-from_factor > 0.
        IF L_WAERK = 'JPY' AND LS_EXCH_RATE-FROM_FACTOR > 0.
* csrno :
          LS_EXCH_RATE-EXCH_RATE = LS_EXCH_RATE-EXCH_RATE
              /    ( LS_EXCH_RATE-FROM_FACTOR / LS_EXCH_RATE-TO_FACTOR )
              .
          P_FROM_FACTOR = LS_EXCH_RATE-FROM_FACTOR.
        ENDIF.
        LS_VBAK-NETWR  = ( LS_VBAK-NETWR  *  LS_EXCH_RATE-EXCH_RATE ).
      ELSE.
        CLEAR: LS_VBAK-NETWR.
      ENDIF.

    ENDIF.

    PERFORM CHANGE_TCURX USING    L_WAERK
                         CHANGING LS_VBAK-NETWR.

    P_RMEIN = L_WAERK.
    P_ERATE = LS_EXCH_RATE-EXCH_RATE.

    L_NETWR_TOT = L_NETWR_TOT + LS_VBAK-NETWR.
  ENDLOOP.

  L_AMT  =  L_AMT  +  L_NETWR_TOT." ls_vbak-netwr.

  L_AMT = L_AMT / 100.
  P_RFAMT    =  L_AMT.
  P_RFMEIN   = 'KRW'.

ENDFORM.                    " GET_VBAK_RFUND_102
*&---------------------------------------------------------------------*
*&      Form  CHANGE_TCURX
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_L_WAERK  text
*      <--P_LS_VBAK_NETWR  text
*----------------------------------------------------------------------*
FORM CHANGE_TCURX  USING    P_WAERK
                   CHANGING P_NETWR.

  DATA L_DEC TYPE TCURX-CURRDEC.
  IF P_WAERK IS NOT INITIAL.
    SELECT SINGLE CURRDEC
    INTO L_DEC
    FROM TCURX
    WHERE CURRKEY = P_WAERK.
    IF SY-SUBRC EQ 0.
      IF L_DEC > 0.
        P_NETWR = P_NETWR * ( 100 / 10 ** L_DEC ) .
      ELSE.
        P_NETWR = P_NETWR * 100.
      ENDIF.
    ELSE.
      P_NETWR = P_NETWR.
    ENDIF.

*        ENDIF.
  ELSE.
    P_NETWR = P_NETWR * 100.
  ENDIF.

ENDFORM.                    " CHANGE_TCURX
*&---------------------------------------------------------------------*
*&      Form  GET_MESG_COST2
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_P_RFUND  text
*      -->P_P_POSNR  text
*      <--P_P_RFAMT  text
*----------------------------------------------------------------------*
FORM GET_MESG_COST2  USING VALUE(P_RFUND)
                            VALUE(P_POSNR)
                   CHANGING VALUE(P_RFAMT)
                            VALUE(P_ZMATSEQ).

  CLEAR : P_RFAMT.
  DATA: BEGIN OF LS_VBFA,
          VBELV   TYPE VBFA-VBELV,
          POSNV   TYPE VBFA-POSNV,
          VBTYP_N TYPE VBFA-VBTYP_N,
          RFWRT   TYPE VBFA-RFWRT,
          WAERS   TYPE VBFA-WAERS,
        END OF   LS_VBFA.
  DATA: LT_VBFA        LIKE TABLE OF LS_VBFA.

  SELECT *
    INTO CORRESPONDING FIELDS OF TABLE LT_VBFA
    FROM VBFA
   WHERE VBELV = P_RFUND
     AND POSNV = P_POSNR
     AND ( VBTYP_N = 'R' OR VBTYP_N = 'H' )
     AND BWART <> ''.

  LOOP AT LT_VBFA INTO LS_VBFA.

    IF LS_VBFA-VBTYP_N = 'R'.
      P_RFAMT = P_RFAMT + LS_VBFA-RFWRT.
    ELSEIF LS_VBFA-VBTYP_N = 'H'.
      P_RFAMT = P_RFAMT + ( LS_VBFA-RFWRT * -1 ).
    ENDIF.

  ENDLOOP.

  READ TABLE GT_180 WITH KEY KDAUF = P_RFUND
                             KDPOS = P_POSNR.
  IF SY-SUBRC = 0.
    P_ZMATSEQ = GT_180-ZMATSEQ.
  ELSE.
    P_ZMATSEQ = GV_ZMATSEQ.
  ENDIF.


ENDFORM.                    " GET_MESG_COST2
*&---------------------------------------------------------------------*
*&      Form  GET_RE_COST
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM GET_RE_COST  USING VALUE(P_RFUND)
                            VALUE(P_POSNR)
                  CHANGING VALUE(P_RFAMT)
                           VALUE(P_KWMENG)
                           VALUE(P_VRKME)
                           VALUE(P_LFIMG)
                           VALUE(P_ERATE)
                           VALUE(P_RMEIN)
                           VALUE(P_FROM_FACTOR)
                           VALUE(P_NETPR)
                           VALUE(P_WAERK)
                           VALUE(P_ZMATSEQ).


  DATA : BEGIN OF LS_RE,
           FKART TYPE VBRK-FKART,
           NETWR TYPE VBRP-NETWR,   "납품요청일
           KURSK TYPE VBRP-KURSK,   " 영업조직
           LFIMG TYPE VBRP-FKLMG,
           ERATE TYPE ZQMT0014S-ERATE,
           RMEIN TYPE ZQMT0014S-RMEIN,

         END OF LS_RE.
  DATA: LT_RE        LIKE TABLE OF LS_RE.

  DATA : L_FKREL     TYPE VBAP-FKREL.

  DATA: BEGIN OF LT_LIPS OCCURS 0,
          VBELN LIKE LIPS-VBELN,
          POSNR LIKE LIPS-POSNR,
          LFIMG LIKE LIPS-LFIMG,
          VRKME LIKE LIPS-VRKME,
          UECHA LIKE LIPS-UECHA,
          ERDAT LIKE LIKP-ERDAT,
        END   OF LT_LIPS.
  DATA: LT_TEMP  LIKE LT_LIPS  OCCURS 0 WITH HEADER LINE.
  DATA : L_NETPR      TYPE VBAP-NETPR,
         L_WAERK      TYPE VBAP-WAERK,
         L_KPEIN      TYPE VBAP-KPEIN,
         L_ERDAT      TYPE LIKP-ERDAT,
         LS_EXCH_RATE TYPE BAPI1093_0,
         LS_RETURN    TYPE BAPIRET1.

  SELECT SINGLE FKREL INTO L_FKREL
   FROM VBAP
   WHERE VBELN = P_RFUND
    AND POSNR = P_POSNR.

  IF L_FKREL = 'I'. " 대금청구 '

    SELECT A~FKART
           B~NETWR
           B~KURSK FKIMG AS LFIMG
           A~WAERK AS  RMEIN
           B~KURSK AS ERATE
      INTO CORRESPONDING FIELDS OF TABLE  LT_RE
      FROM VBRK AS A JOIN VBRP AS B
        ON A~VBELN EQ B~VBELN
     WHERE AUBEL = P_RFUND
       AND AUPOS = P_POSNR.

    LOOP AT LT_RE INTO LS_RE.
      IF LS_RE-FKART = 'S2'.  "취소 차변
        P_RFAMT = P_RFAMT - ( LS_RE-NETWR * LS_RE-KURSK ).
        P_LFIMG = P_LFIMG - LS_RE-LFIMG.
        P_ERATE = LS_RE-ERATE.
        P_RMEIN = LS_RE-RMEIN.
      ELSE.  "대변 RE
        P_RFAMT = P_RFAMT + ( LS_RE-NETWR * LS_RE-KURSK ).
        P_LFIMG = P_LFIMG + LS_RE-LFIMG.
        P_ERATE = LS_RE-ERATE.
        P_RMEIN = LS_RE-RMEIN.
      ENDIF.

    ENDLOOP.
  ELSE.  "K 납품문서


* 반품입고 수량 구함
*^ 오더번호로 출하문서 검색
    REFRESH LT_LIPS. CLEAR LT_LIPS.
*->CCM : ZITCS4HDEV01 2023.04.15 - VBUP 사용못하여 수정함
*    SELECT S~VBELN
*           S~POSNR
*           LFIMG
*           VRKME
*           UECHA
*           P~ERDAT
*      INTO CORRESPONDING FIELDS OF TABLE LT_LIPS
*      FROM LIKP  AS P
*      JOIN LIPS  AS S
*        ON P~VBELN = S~VBELN
*      JOIN VBUP  AS V
*        ON S~VBELN = V~VBELN
*       AND S~POSNR = V~POSNR
*     WHERE VGBEL = P_RFUND
*       AND VGPOS = P_POSNR
*       AND WBSTA = 'C'.          " 출고완료
**       AND zout <> 'W'.         " 실물입고여부 통문
    SELECT S~VBELN
           S~POSNR
           LFIMG
           VRKME
           UECHA
           P~ERDAT
      INTO CORRESPONDING FIELDS OF TABLE LT_LIPS
      FROM LIKP  AS P
      JOIN LIPS  AS S
        ON P~VBELN = S~VBELN
     WHERE VGBEL = P_RFUND
       AND VGPOS = P_POSNR
       AND WBSTA = 'C'.          " 출고완료
*<-

    LT_TEMP[] = LT_LIPS[].
    LOOP AT LT_LIPS WHERE UECHA IS INITIAL.   "원래 품목번호

*   BATCH 분할한 경우 - 분할된 품목의 수량
      LOOP AT LT_TEMP WHERE VBELN = LT_LIPS-VBELN
                        AND UECHA = LT_LIPS-POSNR.

        ADD LT_TEMP-LFIMG TO P_LFIMG.

      ENDLOOP.

*   BATCH 분할 안한 경우 - 원 품목의 수량
      IF SY-SUBRC NE 0.
        ADD LT_LIPS-LFIMG TO P_LFIMG.

      ENDIF.

    ENDLOOP.

    L_ERDAT = LT_LIPS-ERDAT.


    SELECT SINGLE NETPR WAERK KPEIN
             INTO (L_NETPR, L_WAERK, L_KPEIN)
             FROM VBAP
            WHERE VBELN = P_RFUND
              AND POSNR = P_POSNR.
* 단가
    L_NETPR = L_NETPR / L_KPEIN.
    P_RMEIN = L_WAERK.
    P_WAERK = L_WAERK.

    CALL FUNCTION 'BAPI_EXCHANGERATE_GETDETAIL'
      EXPORTING
        RATE_TYPE  = 'M'
        FROM_CURR  = L_WAERK
        TO_CURRNCY = 'KRW'
        DATE       = L_ERDAT
      IMPORTING
        EXCH_RATE  = LS_EXCH_RATE
        RETURN     = LS_RETURN.

    IF  LS_RETURN-TYPE  NE  'E'.
*특히  JPY 인 경우  우리나라 돈보다 약 10배 정도 되는데  환율 Filed에는
*" 10 "이 들어가는 것이 아니고1000 " 이 들어 감..
* 환산율이 100:1 로 환율시장에서 통용
*        IF ls_vbak-waerk = 'JPY' AND ls_exch_rate-from_factor > 0.
      IF L_WAERK = 'JPY' AND LS_EXCH_RATE-FROM_FACTOR > 0.
* csrno :
        LS_EXCH_RATE-EXCH_RATE = LS_EXCH_RATE-EXCH_RATE
            /    ( LS_EXCH_RATE-FROM_FACTOR / LS_EXCH_RATE-TO_FACTOR ).
        P_FROM_FACTOR = LS_EXCH_RATE-FROM_FACTOR.
      ENDIF.
      L_NETPR  = ( L_NETPR *  LS_EXCH_RATE-EXCH_RATE ).
    ELSE.
      CLEAR: L_NETPR.
    ENDIF.

    PERFORM CHANGE_TCURX USING    L_WAERK
                         CHANGING L_NETPR.

    P_ERATE = LS_EXCH_RATE-EXCH_RATE.
    P_RFAMT = P_LFIMG * L_NETPR.
    P_NETPR = L_NETPR.

    PERFORM CHANGE_TCURX_SAVE USING    L_WAERK
                              CHANGING P_ERATE.

  ENDIF.

  P_RFAMT    =  P_RFAMT / 100.
  P_NETPR    = P_NETPR / 100.

  READ TABLE GT_180 WITH KEY KDAUF = P_RFUND
                             KDPOS = P_POSNR.
  IF SY-SUBRC = 0.
    P_ZMATSEQ = GT_180-ZMATSEQ.
  ELSE.
    P_ZMATSEQ = GV_ZMATSEQ.
  ENDIF.

ENDFORM.                    " GET_RE_COST
*&---------------------------------------------------------------------*
*&      Form  CHANGE_TCURX_SAVE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_L_WAERK  text
*      <--P_P_ERATE  text
*----------------------------------------------------------------------*
FORM CHANGE_TCURX_SAVE  USING    P_WAERK
                        CHANGING P_NETWR.

  DATA L_DEC TYPE TCURX-CURRDEC.

  IF P_WAERK IS NOT INITIAL.
    SELECT SINGLE CURRDEC
    INTO L_DEC
    FROM TCURX
    WHERE CURRKEY = P_WAERK.
    IF SY-SUBRC EQ 0.
      IF L_DEC > 0.
        P_NETWR = P_NETWR / ( 100 / 10 ** L_DEC ) .
      ELSE.
        P_NETWR = P_NETWR / 100.
      ENDIF.
    ELSE.
      P_NETWR = P_NETWR.
    ENDIF.

*        ENDIF.
  ELSE.
    P_NETWR = P_NETWR * 100.
  ENDIF.

ENDFORM.                    " CHANGE_TCURX_SAVE
*&---------------------------------------------------------------------*
*&      Form  BDC_VA01_RE_NEW
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM BDC_VA01_RE_NEW .
  DATA: LV_RKMNG(15),
        LV_TCODE LIKE SY-TCODE.

  LV_RKMNG = GT_160-RKMNG.
  CONDENSE LV_RKMNG NO-GAPS.

  PERFORM STORE_BDCDATA   USING:
          'X'  'SAPMV45A'          '0101',
          ' '  'BDC_OKCODE'        '/00',
          ' '  'VBAK-AUART'        'RE',
          ' '  'VBAK-VKORG'        GS_100-BUKRS,
          ' '  'VBAK-VTWEG'        GS_100-VTWEG,
          ' '  'VBAK-SPART'        GS_100-SPGCD,
          ' '  'VBAK-VKBUR'        GS_100-VKBUR,
          ' '  'VBAK-VKGRP'        GS_100-VKGRP.

  PERFORM STORE_BDCDATA   USING:
          'X'  'SAPMV45A'          '4001',
          ' '  'VBKD-BSTKD'        GV_RCEPNO,
          ' '  'KUAGV-KUNNR'       GS_100-KUNUM,
          ' '  'KUWEV-KUNNR'       GS_100-KUNUM,
          ' '  'RV45A-MABNR(02)'   GT_160-MATNR,
          ' '  'RV45A-KWMENG(02)'  LV_RKMNG,
          ' '  'VBAP-WERKS(02)'    GT_160-WERKS_M.


*->[가온전선]--------------------CHG S
  "SAPMV45A userexit_save_document_prepare => check_qm 에서 IMPORT
  LV_TCODE = 'ZGTSDR1250' .
*  LV_TCODE = 'ZQM2R0696' .
*-<[가온전선]--------------------CHG E
  EXPORT LV_TCODE TO MEMORY ID 'BDC_CALLER'.

  PERFORM BDC_TRANSACTION  USING     'VA01'
                                     'E'
                           CHANGING  GV_SUBRC.

  READ    TABLE MESSTAB  WITH KEY MSGTYP = 'S' MSGNR = '311'.
  IF  SY-SUBRC  EQ  0.
    COMMIT WORK.
    MESSAGE S003  WITH MESSTAB-MSGV1  MESSTAB-MSGV2
                       '을(를) 생성하였습니다'.
    CLEAR GV_ERROR_FLG.
  ELSE.
    MESSAGE S001  WITH '정상반품오더 생성중 오류가 발생하였습니다'.
    GV_ERROR_FLG = 'X'.
    EXIT.
  ENDIF.

  GV_RFUND = MESSTAB-MSGV2.

  SELECT SINGLE AUART
         INTO GV_AUART
   FROM VBAK
   WHERE VBELN EQ GV_RFUND.

ENDFORM.                    " BDC_VA01_RE_NEW
*&---------------------------------------------------------------------*
*&      Form  BDC_VA01_ZREQ
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM BDC_VA01_ZREQ .

  DATA: LV_RKMNG(15),
        LV_TCODE LIKE SY-TCODE.

  LV_RKMNG = GT_160-RKMNG.
  CONDENSE LV_RKMNG NO-GAPS.

  SELECT SINGLE
         B~KDPOS
    INTO GV_KDPOS
    FROM ZQMT0011M AS A
   INNER JOIN ZQMT0011B AS B
      ON A~RCEPNO   = B~RCEPNO
     AND A~ZMATSEQ  = B~ZMATSEQ
   WHERE A~KZLOESCH = SPACE
     AND A~RCEPNO   = GT_160-RCEPNO
     AND A~KDAUF    = GT_160-KDAUF
     AND A~ZMATSEQ  = GT_160-ZMATSEQ.

  PERFORM STORE_BDCDATA   USING:
          'X'  'SAPMV45A'          '0101',
          ' '  'BDC_OKCODE'        '=COPY',
          ' '  'VBAK-AUART'        'ZREQ',
          ' '  'VBAK-VKORG'        GS_100-BUKRS,
          ' '  'VBAK-VTWEG'        GS_100-VTWEG,
          ' '  'VBAK-SPART'        GS_100-SPGCD,
          ' '  'VBAK-VKBUR'        GS_100-VKBUR,
          ' '  'VBAK-VKGRP'        GS_100-VKGRP.


  PERFORM STORE_BDCDATA   USING:
          'X'  'SAPLV45C'          '0100',
          ' '  'BDC_OKCODE'        '=RUE1',
          ' '  'LV45C-VBELN'       GT_160-KDAUF.

  PERFORM STORE_BDCDATA   USING:
        'X'  'SAPMV45A'          '4413',
        ' '  'BDC_OKCODE'        '=MKLO'.

  PERFORM STORE_BDCDATA   USING:
          'X'  'SAPMV45A'          '4413',
          ' '  'BDC_OKCODE'        '=POPO'.

  PERFORM STORE_BDCDATA   USING:
          'X'  'SAPMV45A'          '0251',
          ' '  'BDC_OKCODE'        '=POSI',
          ' '  'RV45A-POSNR'       GV_KDPOS.

  PERFORM STORE_BDCDATA   USING:
          'X'  'SAPMV45A'            '4413',
          ' '  'BDC_OKCODE'          '=RUEB',
          ' ' 'RV45A-VBAP_SELKZ(01)' 'X',
          ' ' 'VBAPD-ORFMNG(01)'   LV_RKMNG.

  PERFORM STORE_BDCDATA   USING:
          'X'  'SAPMV45A'          '4001',
*          ' '  'BDC_OKCODE'        '=HEAD',
          ' '  'BDC_OKCODE'        '=KKAU',
          ' '  'VBKD-BSTKD'        GV_RCEPNO.

  PERFORM STORE_BDCDATA   USING:
          'X'  'SAPMV45A'          '4002',
          ' '  'BDC_OKCODE'        '/EBACK',
          ' ' 'VBAK-AUGRU'         GS_100-DSTGR.


*->[가온전선]--------------------CHG S
  "SAPMV45A userexit_save_document_prepare => check_qm 에서 IMPORT
  LV_TCODE = 'ZGTSDR1250' .
*  LV_TCODE = 'ZQM2R0696' .
*-<[가온전선]--------------------CHG E
  EXPORT LV_TCODE TO MEMORY ID 'BDC_CALLER'.

  PERFORM BDC_TRANSACTION  USING     'VA01'
                                     'E'
                           CHANGING  GV_SUBRC.

  READ    TABLE MESSTAB  WITH KEY MSGTYP = 'S' MSGNR = '311'.
  IF  SY-SUBRC  EQ  0.

    GV_RFUND = MESSTAB-MSGV2.

    SELECT SINGLE AUART
             INTO GV_AUART
       FROM VBAK
       WHERE VBELN EQ GV_RFUND.

    COMMIT WORK.
    MESSAGE S003  WITH MESSTAB-MSGV1  MESSTAB-MSGV2
                       '을(를) 생성하였습니다'.
    CLEAR GV_ERROR_FLG.
  ELSE.
    MESSAGE S001  WITH '불량품교환반품오더 생성중 오류가 발생하였습니다'
    .
    GV_ERROR_FLG = 'X'.
    EXIT.
  ENDIF.

ENDFORM.                    " BDC_VA01_ZREQ
*&---------------------------------------------------------------------*
*&      Form  BDC_VA01_ZREQ_NEW
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM BDC_VA01_ZREQ_NEW .

  DATA: LV_RKMNG(15),
        LV_TCODE LIKE SY-TCODE.

  LV_RKMNG = GT_160-RKMNG.
  CONDENSE LV_RKMNG NO-GAPS.

  PERFORM STORE_BDCDATA   USING:
          'X'  'SAPMV45A'          '0101',
          ' '  'BDC_OKCODE'        '/00',
          ' '  'VBAK-AUART'        'ZREQ',
          ' '  'VBAK-VKORG'        GS_100-BUKRS,
          ' '  'VBAK-VTWEG'        GS_100-VTWEG,
          ' '  'VBAK-SPART'        GS_100-SPGCD,
          ' '  'VBAK-VKBUR'        GS_100-VKBUR,
          ' '  'VBAK-VKGRP'        GS_100-VKGRP.

  PERFORM STORE_BDCDATA   USING:
          'X'  'SAPMV45A'          '4001',
          ' '  'VBKD-BSTKD'        GV_RCEPNO,
          ' '  'KUAGV-KUNNR'       GS_100-KUNUM,
          ' '  'KUWEV-KUNNR'       GS_100-KUNUM,
          ' '  'RV45A-MABNR(02)'   GT_160-MATNR,
          ' '  'RV45A-KWMENG(02)'  LV_RKMNG,
          ' '  'VBAP-WERKS(02)'    GT_160-WERKS_M.

*->[가온전선]--------------------CHG S
  "SAPMV45A userexit_save_document_prepare => check_qm 에서 IMPORT
  LV_TCODE = 'ZGTSDR1250' .
*  LV_TCODE = 'ZQM2R0696' .
*-<[가온전선]--------------------CHG E
  EXPORT LV_TCODE TO MEMORY ID 'BDC_CALLER'.

  PERFORM BDC_TRANSACTION  USING     'VA01'
                                     'E'
                           CHANGING  GV_SUBRC.

  READ    TABLE MESSTAB  WITH KEY MSGTYP = 'S' MSGNR = '311'.
  IF  SY-SUBRC  EQ  0.
    COMMIT WORK.
    MESSAGE S003  WITH MESSTAB-MSGV1  MESSTAB-MSGV2
                       '을(를) 생성하였습니다'.
    CLEAR GV_ERROR_FLG.
  ELSE.
    MESSAGE S001  WITH '불량품교환반품오더 생성중 오류가 발생하였습니다'
    .
    GV_ERROR_FLG = 'X'.
    EXIT.
  ENDIF.

  GV_RFUND = MESSTAB-MSGV2.

  SELECT SINGLE AUART
         INTO GV_AUART
   FROM VBAK
   WHERE VBELN EQ GV_RFUND.

ENDFORM.                    " BDC_VA01_ZREQ_NEW
*&---------------------------------------------------------------------*
*&      Form  BDC_VA01_ZORQ
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM BDC_VA01_ZORQ .
  DATA : LV_TCODE LIKE SY-TCODE.

  CLEAR GV_KDPOS.

  SELECT SINGLE POSNR
    INTO GV_KDPOS
    FROM VBAP
   WHERE VBELN EQ GV_ZREQ.

  PERFORM STORE_BDCDATA   USING:
          'X'  'SAPMV45A'          '0101',
          ' '  'BDC_OKCODE'        '=COPY',
          ' '  'VBAK-AUART'        'ZORQ'.


  PERFORM STORE_BDCDATA   USING:
          'X'  'SAPLV45C'          '0100',
          ' '  'BDC_OKCODE'        '=RUE1',
          ' '  'LV45C-VBELN'       GV_ZREQ.

  PERFORM STORE_BDCDATA   USING:
          'X'  'SAPMV45A'          '4413',
          ' '  'BDC_OKCODE'        '=MKLO'.

  PERFORM STORE_BDCDATA   USING:
          'X'  'SAPMV45A'          '4413',
          ' '  'BDC_OKCODE'        '=POPO'.

  PERFORM STORE_BDCDATA   USING:
          'X'  'SAPMV45A'          '0251',
          ' '  'BDC_OKCODE'        '=POSI',
          ' '  'RV45A-POSNR'       GV_KDPOS.
  PERFORM STORE_BDCDATA   USING:
          'X'  'SAPMV45A'          '4413',
          ' '  'BDC_OKCODE'        '=MARK'.

  PERFORM STORE_BDCDATA   USING:
          'X'  'SAPMV45A'          '4413',
          ' '  'BDC_OKCODE'        '=RUEB'.
  PERFORM STORE_BDCDATA   USING:
          'X'  'SAPMV45A'          '4001',
          ' '  'VBKD-BSTKD'        GV_RCEPNO.

  PERFORM STORE_BDCDATA   USING:
          'X'  'SAPMV45A'          '4001',
          ' '  'BDC_OKCODE'        '=T\01'.

  PERFORM STORE_BDCDATA   USING:
          'X'  'SAPMV45A'          '4001',
          ' '  'VBAK-AUGRU'        GS_100-DSTGR.

  PERFORM STORE_BDCDATA   USING:
          'X'  'SAPMV45A'          '4001',
          ' '  'BDC_OKCODE'        '=T\08'.

*->[가온전선]--------------------CHG S
  "SAPMV45A userexit_save_document_prepare => check_qm 에서 IMPORT
  LV_TCODE = 'ZGTSDR1250' .
*  LV_TCODE = 'ZQM2R0696' .
*-<[가온전선]--------------------CHG E
  EXPORT LV_TCODE TO MEMORY ID 'BDC_CALLER'.

  PERFORM BDC_TRANSACTION  USING     'VA01'
                                     'E'
                           CHANGING  GV_SUBRC.


  READ    TABLE MESSTAB  WITH KEY MSGTYP = 'S' MSGNR = '311'.
  IF  SY-SUBRC  EQ  0.
    CLEAR: GV_RFUND, GV_AUART.

    GV_RFUND = MESSTAB-MSGV2.

    GV_AUART = 'ZORQ'.
    COMMIT WORK.

    MESSAGE S003  WITH MESSTAB-MSGV1  MESSTAB-MSGV2
                       '을(를) 생성하였습니다'.
    CLEAR GV_ERROR_FLG.
  ELSE.
    MESSAGE S001  WITH '불량품교환출고오더 생성중 오류가 발생하였습니다'
    .
    GV_ERROR_FLG = 'X'.
    EXIT.
  ENDIF.

ENDFORM.                    " BDC_VA01_ZORQ
*&---------------------------------------------------------------------*
*&      Form  BDC_VA01_ZFQ
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM BDC_VA01_ZFQ .
  DATA: LV_RKMNG(15),
        LV_TCODE LIKE SY-TCODE.

  PERFORM STORE_BDCDATA   USING:
           'X' 'SAPMV45A'           '0101',
           ' ' 'BDC_OKCODE'         '=COPY',
           ' ' 'VBAK-AUART'         'ZFQ',
           ' ' 'VBAK-VKORG'         GS_100-BUKRS,
           ' ' 'VBAK-VTWEG'         GS_100-VTWEG,
           ' ' 'VBAK-SPART'         GS_100-SPGCD,
           ' ' 'VBAK-VKBUR'         GS_100-VKBUR,
           ' ' 'VBAK-VKGRP'         GS_100-VKGRP.

  PERFORM STORE_BDCDATA   USING:
          'X'  'SAPLV45C'          '0100',
          ' '  'BDC_OKCODE'        '=RUE1',
          ' '  'LV45C-VBELN'       GT_160-KDAUF.

  PERFORM STORE_BDCDATA   USING:
        'X'  'SAPMV45A'          '4413',
        ' '  'BDC_OKCODE'        '=MKLO'.


  LOOP AT GT_180 WHERE MARK = 'X'.
    LV_RKMNG = GT_180-RKMNG.
    CONDENSE LV_RKMNG NO-GAPS.

    PERFORM STORE_BDCDATA   USING:
            'X'  'SAPMV45A'          '4413',
            ' '  'BDC_OKCODE'        '=POPO'.

    PERFORM STORE_BDCDATA   USING:
            'X'  'SAPMV45A'          '0251',
            ' '  'BDC_OKCODE'        '=POSI',
            ' '  'RV45A-POSNR'       GT_180-KDPOS.

    PERFORM STORE_BDCDATA   USING:
            'X'  'SAPMV45A'            '4413',
            ' '  'BDC_OKCODE'          '/00',
            ' ' 'RV45A-VBAP_SELKZ(01)' 'X',
            ' ' 'VBAPD-ORFMNG(01)'     LV_RKMNG.

  ENDLOOP.

  PERFORM STORE_BDCDATA   USING:
          'X'  'SAPMV45A'          '4413',
          ' '  'BDC_OKCODE'        '=RUEB'.

  PERFORM STORE_BDCDATA   USING:
          'X'  'SAPMV45A'          '4001',
*          ' '  'BDC_OKCODE'        '/00',
          ' '  'BDC_OKCODE'        '=KKAU',
          ' '  'VBKD-BSTKD'        GV_RCEPNO.

  PERFORM STORE_BDCDATA   USING:
          'X'  'SAPMV45A'          '4002',
          ' '  'BDC_OKCODE'        '/EBACK',
          ' ' 'VBAK-AUGRU'         GS_100-DSTGR.

*->[가온전선]--------------------CHG S
  "SAPMV45A userexit_save_document_prepare => check_qm 에서 IMPORT
  LV_TCODE = 'ZGTSDR1250' .
*  LV_TCODE = 'ZQM2R0696' .
*-<[가온전선]--------------------CHG E
  EXPORT LV_TCODE TO MEMORY ID 'BDC_CALLER'.

  PERFORM BDC_TRANSACTION  USING     'VA01'
                                     'E'
                           CHANGING  GV_SUBRC.

  READ    TABLE MESSTAB  WITH KEY MSGTYP = 'S' MSGNR = '311'.
  IF  SY-SUBRC  EQ  0.

    CLEAR : GV_RFUND, GV_AUART.

    GV_RFUND = MESSTAB-MSGV2.

    SELECT SINGLE AUART
             INTO GV_AUART
       FROM VBAK
       WHERE VBELN EQ GV_RFUND.

    CLEAR GV_ERROR_FLG.

    COMMIT WORK.
    MESSAGE S003  WITH MESSTAB-MSGV1  MESSTAB-MSGV2
                       '을(를) 생성하였습니다'.
  ELSE.
    MESSAGE S001  WITH '출고오더 생성중 오류가 발생하였습니다'.
    GV_ERROR_FLG = 'X'.
    EXIT.
  ENDIF.


ENDFORM.                    " BDC_VA01_ZFQ
*&---------------------------------------------------------------------*
*&      Form  BDC_VA01_ZFQ_NEW
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM BDC_VA01_ZFQ_NEW .
  DATA: LV_RKMNG(15),
        LV_TCODE LIKE SY-TCODE.

  LV_RKMNG = GT_160-RKMNG.
  CONDENSE LV_RKMNG NO-GAPS.

  PERFORM STORE_BDCDATA   USING:
          'X'  'SAPMV45A'          '0101',
          ' '  'BDC_OKCODE'        '/00',
          ' '  'VBAK-AUART'        'ZFQ',
          ' '  'VBAK-VKORG'        GS_100-BUKRS,
          ' '  'VBAK-VTWEG'        GS_100-VTWEG,
          ' ' 'VBAK-SPART'         GS_100-SPGCD,
          ' '  'VBAK-VKBUR'        GS_100-VKBUR,
          ' '  'VBAK-VKGRP'        GS_100-VKGRP.

  PERFORM STORE_BDCDATA   USING:
          'X'  'SAPMV45A'          '4001',
          ' '  'VBKD-BSTKD'        GV_RCEPNO,
          ' '  'KUAGV-KUNNR'       GS_100-KUNUM,
          ' '  'KUWEV-KUNNR'       GS_100-KUNUM,
          ' '  'RV45A-MABNR(02)'   GT_160-MATNR,
          ' '  'RV45A-KWMENG(02)'  LV_RKMNG,
          ' '  'VBAP-WERKS(02)'    GT_160-WERKS_M.

*->[가온전선]--------------------CHG S
  "SAPMV45A userexit_save_document_prepare => check_qm 에서 IMPORT
  LV_TCODE = 'ZGTSDR1250' .
*  LV_TCODE = 'ZQM2R0696' .
*-<[가온전선]--------------------CHG E
  EXPORT LV_TCODE TO MEMORY ID 'BDC_CALLER'.

  PERFORM BDC_TRANSACTION  USING     'VA01'
                                     'E'
                           CHANGING  GV_SUBRC.

  READ    TABLE MESSTAB  WITH KEY MSGTYP = 'S' MSGNR = '311'.
  IF  SY-SUBRC  EQ  0.
    COMMIT WORK.
    MESSAGE S003  WITH MESSTAB-MSGV1  MESSTAB-MSGV2
                       '을(를) 생성하였습니다'.
    CLEAR GV_ERROR_FLG.
  ELSE.
    MESSAGE S001  WITH '출고오더 생성중 오류가 발생하였습니다'.
    GV_ERROR_FLG = 'X'.
    EXIT.
  ENDIF.

  CLEAR: GV_RFUND, GV_AUART.

  GV_RFUND = MESSTAB-MSGV2.

  SELECT SINGLE AUART
         INTO GV_AUART
   FROM VBAK
   WHERE VBELN EQ GV_RFUND.

ENDFORM.                    " BDC_VA01_ZFQ_NEW
*&---------------------------------------------------------------------*
*&      Form  CHANGE_VA02
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GV_RE  text
*----------------------------------------------------------------------*
FORM CHANGE_VA02  USING    P_RE.
  DATA : LV_TCODE LIKE SY-TCODE.

*->[가온전선]--------------------CHG S
  "SAPMV45A userexit_save_document_prepare => check_qm 에서 IMPORT
  LV_TCODE = 'ZGTSDR1250' .
*  LV_TCODE = 'ZQM2R0696' .
*-<[가온전선]--------------------CHG E
  EXPORT LV_TCODE TO MEMORY ID 'BDC_CALLER'.

  SET PARAMETER ID 'AUN' FIELD P_RE.

  CALL TRANSACTION 'VA02' AND SKIP FIRST SCREEN.

ENDFORM.                    " CHANGE_VA02
*&---------------------------------------------------------------------*
*&      Form  CHECK_EMAIL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_GV_FLG  text
*----------------------------------------------------------------------*
FORM CHECK_EMAIL  CHANGING P_FLG.

  CLEAR: GV_ADDRESS.

***  E-MAIL 정보체크
  SELECT SINGLE USRID
   INTO GV_ADDRESS
   FROM ZPA0105
   WHERE PERNR EQ GS_100-SDNAMNR
     AND ENDDA >= SY-DATUM
     AND SUBTY EQ '0007'.
  IF SY-SUBRC <> 0 OR GS_100-SDNAMNR = '' OR GS_100-SDNAM = ''.
    P_FLG = 'X'.      "에러
    MESSAGE S002 WITH '영업사원 정보가 부정확하여'
                      '메일을 송부할 수 없습니다.'
                      DISPLAY LIKE 'E'.
    EXIT.
  ELSE.
    P_FLG = ' '.      "정상
  ENDIF.

ENDFORM.                    " CHECK_EMAIL
*&---------------------------------------------------------------------*
*&      Form  BUILD_MAIL_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_GV_FLG  text
*----------------------------------------------------------------------*
FORM BUILD_MAIL_DATA  CHANGING P_FLG.

  DATA: LS_MSG  TYPE SO_TEXT255,
        LS_MSG1 TYPE SO_TEXT255,
        LS_MSG2 TYPE SO_TEXT255,
        LS_MSG3 TYPE SO_TEXT255,
        LS_MSG4 TYPE SO_TEXT255,
        LS_MSG5 TYPE SO_TEXT255,
        LS_MSG6 TYPE SO_TEXT255,
        LS_MSG7 TYPE SO_TEXT255.

  DATA: LV_INDEX TYPE I.
  DATA: LV_NAME  LIKE ZZPA0001-ENAME.
  DATA: LV_TTEXT LIKE TSTCT-TTEXT.
  DATA: LV_MATNR LIKE ZQMT0011M-MATNR.
  DATA: LV_RCEPNO LIKE ZQMT0011H-RCEPNO.
  DATA: LV_KUNUM  LIKE ZQMT0011H-KUNUM.
  DATA: LV_ERDAT(10).

  CLEAR: GT_MESSAGE, LV_NAME,   LS_MSG ,    LS_MSG1,   LS_MSG2,
         LS_MSG3,    LS_MSG4,   LS_MSG5,    LS_MSG6,   LV_INDEX,
         LV_TTEXT,   LV_MATNR,  GV_SUBJECT, LV_RCEPNO, LV_KUNUM,
         LV_ERDAT,   LS_MSG7.

  REFRESH: GT_MESSAGE.


*__접수번호
  %%ALPHA_CONV_OUT  GV_RCEPNO  LV_RCEPNO.


*__고객번호
  %%ALPHA_CONV_OUT  GS_100-KUNUM  LV_KUNUM.


*__코디네이터
  SELECT SINGLE ENAME
   INTO LV_NAME
   FROM ZZPA0001
   WHERE PERNR EQ GS_100-CORDINR
     AND ENDDA >= SY-DATUM.

*__T-CODE 내역
  LV_TTEXT = '고객불만관리'.

*__자재/접수일
  READ TABLE GT_160 WITH KEY MARK = 'X'.
  IF SY-SUBRC = 0.
    LV_MATNR = GT_160-MATNR.
    %%ALPHA_CONV_OUT  LV_MATNR  LV_MATNR.
    WRITE GT_160-ERDAT TO LV_ERDAT.
  ELSE.
    MESSAGE S001 DISPLAY LIKE 'E'
       WITH '처리요청할 자재를 먼저 선택하십시오.'.
    EXIT.
  ENDIF.


  IF GV_CHK1 = '1'.
    CONCATENATE '정상반품오더(RE) 생성요청' '(' '고객불만' LV_RCEPNO
    ')'
                  INTO GV_SUBJECT." SEPARATED BY SPACE.
  ELSEIF GV_CHK1 = '2'.
    CONCATENATE '불량품교환반품오더(ZREQ) 생성요청' '(' '고객불만'
    LV_RCEPNO ')'
                  INTO GV_SUBJECT." SEPARATED BY SPACE.
  ELSEIF GV_CHK1 = '3'.
    CONCATENATE '불량품교환출고오더(ZORQ) 생성요청' '(' '고객불만'
    LV_RCEPNO ')'
                  INTO GV_SUBJECT." SEPARATED BY SPACE.
  ELSEIF GV_CHK1 = '4'.
    CONCATENATE '클레임출고오더(ZFQ) 생성요청' '(' '고객불만' LV_RCEPNO
    ')'
                  INTO GV_SUBJECT." SEPARATED BY SPACE.
  ENDIF.


  CONCATENATE
     '.'   '&nbsp' '고 객 불 만 : ' '&nbsp' INTO LS_MSG1.
  CONCATENATE LS_MSG1
       LV_RCEPNO '번' '<br>'
                INTO LS_MSG1 SEPARATED BY SPACE.

  CONCATENATE
     '.'   '&nbsp'
     '접'  '&nbsp' '&nbsp' '&nbsp'
     '수'  '&nbsp' '&nbsp' '&nbsp'
     '일'  '&nbsp'
     ':'   '&nbsp' INTO LS_MSG7.
  CONCATENATE
  LS_MSG7 LV_ERDAT '<br>'
                   INTO LS_MSG7 SEPARATED BY SPACE.

  CONCATENATE
     '.'  '&nbsp'
     '고' '&nbsp' '&nbsp' '&nbsp' '&nbsp' '&nbsp' '&nbsp' '&nbsp'
     '&nbsp' '&nbsp'
     '객' '&nbsp'
     ':'  '&nbsp' INTO LS_MSG2.
  CONCATENATE
      LS_MSG2 GS_100-KUNUMT '(' LV_KUNUM ')' '<br>'
                INTO LS_MSG2 SEPARATED BY SPACE.

  CONCATENATE
     '.'   '&nbsp'
     '코'
     '디'
     '네'
     '이'
     '터' '&nbsp'
     ':'  '&nbsp' INTO LS_MSG3.
  CONCATENATE
  LS_MSG3  GS_100-CORDINRT '(' GS_100-CORDINR ')' '<br>'
                INTO LS_MSG3 SEPARATED BY SPACE.

  CONCATENATE
     '.'  '&nbsp'
     '주' '&nbsp' '&nbsp' '&nbsp' '&nbsp' '&nbsp' '&nbsp' '&nbsp'
     '&nbsp' '&nbsp'
     '제' '&nbsp'
     ':'  '&nbsp' INTO LS_MSG4.
  CONCATENATE
    LS_MSG4 GS_100-QMTXT '<p>'
                INTO LS_MSG4 SEPARATED BY SPACE.

  CONCATENATE
     '* T-CODE :' '&nbsp' INTO LS_MSG5.

*->[가온전선]--------------------CHG S
  CONCATENATE
    LS_MSG5  'ZGTSDR1250' '(' LV_TTEXT ')' '<p>'
                INTO LS_MSG5 SEPARATED BY SPACE.
*  CONCATENATE
*    LS_MSG5  'ZQM2R0696' '(' LV_TTEXT ')' '<p>'
*                INTO LS_MSG5 SEPARATED BY SPACE.
*-<[가온전선]--------------------CHG E

  CONCATENATE
      '.'  '&nbsp'
      '자' '&nbsp' '&nbsp' '&nbsp' '&nbsp' '&nbsp' '&nbsp' '&nbsp'
      '&nbsp' '&nbsp'
      '재' '&nbsp'
      ':'  '&nbsp' INTO LS_MSG6.
  CONCATENATE
  LS_MSG6  LV_MATNR '(' GT_160-MAKTX ')'  '<p>'
                  INTO LS_MSG6 SEPARATED BY SPACE.


  IF GV_CHK1 = '1'.
    MAIL_MSG: '<html>',
              '<body>',
              TEXT-003,
              LS_MSG5,
              LS_MSG1,
              LS_MSG7,
              LS_MSG2,
              LS_MSG3,
              LS_MSG4,
              LS_MSG6,
              '끝.<br>',
              '</body>',
              '</html>'.

  ELSEIF GV_CHK1 = '2'.
    MAIL_MSG: '<html>',
              '<body>',
              TEXT-004,
              LS_MSG5,
              LS_MSG1,
              LS_MSG7,
              LS_MSG2,
              LS_MSG3,
              LS_MSG4,
              LS_MSG6,
              '끝.<br>',
              '</body>',
              '</html>'.

  ELSEIF GV_CHK1 = '3'.
    MAIL_MSG: '<html>',
              '<body>',
              TEXT-005,
              LS_MSG5,
              LS_MSG1,
              LS_MSG7,
              LS_MSG2,
              LS_MSG3,
              LS_MSG4,
              LS_MSG6,
              '끝.<br>',
              '</body>',
              '</html>'.

  ELSEIF GV_CHK1 = '4'.
    MAIL_MSG: '<html>',
              '<body>',
              TEXT-006,
              LS_MSG5,
              LS_MSG1,
              LS_MSG7,
              LS_MSG2,
              LS_MSG3,
              LS_MSG4,
              LS_MSG6,
              '끝.<br>',
              '</body>',
              '</html>'.
  ENDIF.

  CLEAR GV_CHK1.

* EMAIL 내용 전송
  PERFORM SEND_MAIL USING GV_FLAG.
ENDFORM.                    " BUILD_MAIL_DATA
*&---------------------------------------------------------------------*
*&      Form  SEND_MAIL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_P_FLAG  text
*----------------------------------------------------------------------*
FORM SEND_MAIL  USING    P_FLAG.

  DATA RESULT_TAB TYPE MATCH_RESULT_TAB.

  TRY.
      G_EMAIL = CL_BCS=>CREATE_PERSISTENT( ).

      G_EMAIL_BODY = CL_DOCUMENT_BCS=>CREATE_DOCUMENT(
                      I_TYPE    = 'HTM'
                      I_TEXT    = GT_MESSAGE
                      I_SUBJECT = GV_SUBJECT ).

*     첨부
*      PERFORM add_attachment USING g_email_body.

      G_EMAIL->SET_DOCUMENT( G_EMAIL_BODY ).

      G_RECEIVER =
      CL_CAM_ADDRESS_BCS=>CREATE_INTERNET_ADDRESS( GV_ADDRESS ).

      G_EMAIL->ADD_RECIPIENT( I_RECIPIENT = G_RECEIVER
                              I_EXPRESS   = 'X' ).

      G_EMAIL->SET_SEND_IMMEDIATELY( 'X' ).

      G_EMAIL->SEND( EXPORTING I_WITH_ERROR_SCREEN = 'X'
                     RECEIVING RESULT              = GV_SEND_RESULT ).

      MESSAGE S001 WITH '메일을 전송하였습니다.'.
      COMMIT WORK.

    CATCH CX_BCS INTO G_EXCEPTION.
      P_FLAG = 'X'.
      MESSAGE S001 DISPLAY LIKE 'E'
         WITH '메일전송에 실패하였습니다.'.
  ENDTRY.



ENDFORM.                    " SEND_MAIL
*&---------------------------------------------------------------------*
*&      Form  MODIFY_CUSTOM_CLAIM_100
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_P_SCRNM  text
*      -->P_GV_RCEPNO  text
*      <--P_GV_FORM_FLG  text
*----------------------------------------------------------------------*
FORM MODIFY_CUSTOM_CLAIM_100  USING   " P_SCR    TYPE  STRING
                                       P_RCEPNO
                              CHANGING P_FLG.

  DATA: LS_CLAIM      LIKE  ZQMT0011H.

  CLEAR:   LS_CLAIM,  GV_SAVE_Y.

  PERFORM TRANS_DATA_UPDAT USING 'ZQMT0011H'.

*__접수구분
  CASE  'X'.
    WHEN  GV_RCLAS1.
      GS_100-RCLAS   =  '1'.
    WHEN  GV_RCLAS2.
      GS_100-RCLAS   =  '2'.
    WHEN  GV_RCLAS3.
      GS_100-RCLAS   =  '3'.
    WHEN  GV_RCLAS4.
      GS_100-RCLAS   =  '4'.
    WHEN  GV_RCLAS5.
      GS_100-RCLAS   =  '5'.
    WHEN  GV_RCLAS6.
      GS_100-RCLAS   =  '6'.
    WHEN  GV_RCLAS7.
      GS_100-RCLAS   =  '7'.
  ENDCASE.

  IF GS_100-DSTDT IS INITIAL.
    GS_100-DSTDT = SY-DATUM.
  ENDIF.

  MOVE-CORRESPONDING    GS_100  TO  LS_CLAIM.
*->[가온전선]--------------------CHG S
* 첨부파일
  IF GS_100-ATTCH IS NOT INITIAL.
    LS_CLAIM-DOKNR = GC_X.
  ELSE.
    CLEAR LS_CLAIM-DOKNR.
  ENDIF.
*-<[가온전선]--------------------CHG E


  MODIFY    ZQMT0011H  FROM  LS_CLAIM.
  IF SY-SUBRC = 0.
    GS_100_OLD   = GS_100.
    GV_SAVE_Y = 'X'.
  ELSE.
    CLEAR GV_SAVE_Y.
    ROLLBACK WORK.
  ENDIF.


  PERFORM  INSERT_CUSTOM_CLAIM_0320.

  PERFORM  INSERT_CUSTOM_CLAIM_0500.

  PERFORM  INSERT_CUSTOM_CLAIM_0600.

  PERFORM  INSERT_CUSTOM_CLAIM_0800.

  PERFORM  INSERT_CUSTOM_CLAIM_1100.


  IF GV_SAVE_Y = 'X'.
    COMMIT WORK AND WAIT.
    MESSAGE S001 WITH '입력하신 Data가 저장되었습니다.'.
  ENDIF.

ENDFORM.                    " MODIFY_CUSTOM_CLAIM_100
*&---------------------------------------------------------------------*
*&      Form  MODIFY_LIST
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GT_200_STATUS  text
*      <--P_GT_200_LIGHTS  text
*      <--P_GT_200_STATUST  text
*----------------------------------------------------------------------*
FORM MODIFY_LIST  USING    P_STATUS
                  CHANGING P_LIGHTS
                           P_STATUST.

  CHECK P_STATUS IS NOT INITIAL.

  CLEAR: P_LIGHTS, P_STATUST.

  IF P_STATUS = '1'.
    P_LIGHTS = ICON_RED_LIGHT.
    P_STATUST = '미결'.
  ELSEIF P_STATUS = '2'.
    P_LIGHTS = ICON_GREEN_LIGHT.
    P_STATUST = '완료'.
  ELSEIF P_STATUS = '3'.
    P_LIGHTS = ICON_YELLOW_LIGHT.
    P_STATUST = '삭제'.
  ENDIF.

ENDFORM.                    " MODIFY_LIST
*&---------------------------------------------------------------------*
*&      Form  EVENT_HANDLER_REGISTER_200
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM EVENT_HANDLER_REGISTER_200 .

* TOOLBAR 구성은 EVENT에서 한다.
  CREATE OBJECT G_EVENT_HANDLER_7.
*

*-Edit  이벤트 등록
  CALL METHOD G_GRID_7->REGISTER_EDIT_EVENT
    EXPORTING
      I_EVENT_ID = CL_GUI_ALV_GRID=>MC_EVT_MODIFIED.

  CALL METHOD G_GRID_7->REGISTER_EDIT_EVENT
    EXPORTING
      I_EVENT_ID = CL_GUI_ALV_GRID=>MC_EVT_ENTER.

* 툴바지정
*    SET HANDLER g_event_handler_5->handle_toolbar
*                                FOR g_grid_5.
* 툴바에 해당하는 이벤트 지정
*    SET HANDLER g_event_handler_5->handle_user_command
*                                FOR g_grid_5.
** DATA_CHANGED
  SET HANDLER G_EVENT_HANDLER_7->HANDLE_DATA_CHANGED_7 FOR G_GRID_7.
*  SET HANDLER G_EVENT_HANDLER_7->HANDLE_DATA_CHANGED_FINISHED_1
*                                                     FOR G_GRID_7.
  SET HANDLER G_EVENT_HANDLER_7->HANDLE_HOTSPOT_CLICK_7
                        FOR G_GRID_7.

ENDFORM.                    " EVENT_HANDLER_REGISTER_200
*&---------------------------------------------------------------------*
*&      Form  G_GRID_7_REFRESH
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM G_GRID_7_REFRESH .

  CALL METHOD G_GRID_7->REFRESH_TABLE_DISPLAY
    EXPORTING
      I_SOFT_REFRESH = ' '.

  CALL METHOD CL_GUI_CFW=>FLUSH.

ENDFORM.                    " G_GRID_7_REFRESH
*&---------------------------------------------------------------------*
*&      Form  DATA_CHANGED3
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_ER_DATA_CHANGED  text
*----------------------------------------------------------------------*
FORM DATA_CHANGED3  USING    ER_DATA_CHANGED
                    TYPE REF TO CL_ALV_CHANGED_DATA_PROTOCOL.
*
  DATA: LS_MOD_CELLS TYPE LVC_S_MODI,
        LS_CELLS     TYPE LVC_S_MODI,
        LS_FIELDCAT  TYPE LVC_S_FCAT.

  CLEAR: GT_150, GS_150.
  LOOP AT ER_DATA_CHANGED->MT_GOOD_CELLS INTO LS_MOD_CELLS.
    READ TABLE GT_150 INDEX LS_MOD_CELLS-ROW_ID.
    MOVE-CORRESPONDING GT_150 TO GS_150.
  ENDLOOP.

  LOOP AT GT_150.
    IF LS_MOD_CELLS-ROW_ID NE SY-TABIX.
      GT_150-MARK = SPACE.
    ELSE.
      GT_150-MARK = 'X'.
    ENDIF.
    MODIFY GT_150.
  ENDLOOP.


ENDFORM.                    " DATA_CHANGED3
*&---------------------------------------------------------------------*
*&      Form  MODIFY_SCREEN_BUTTON2
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GV_PRUEFLOS  text
*      -->P_2017   text
*      -->P_2018   text
*      -->P_2019   text
*      -->P_2020   text
*----------------------------------------------------------------------*
FORM MODIFY_SCREEN_BUTTON2  USING   P_PRUEFLOS
                                    P_CR
                                    P_CH
                                    P_IN_CH
                                    P_UD_CH
                                    P_MB1B.

  IF P_PRUEFLOS IS NOT INITIAL.
    IF SCREEN-NAME = P_CH OR SCREEN-NAME = P_IN_CH OR
      SCREEN-NAME = P_UD_CH OR SCREEN-NAME = P_MB1B .
      SCREEN-INPUT = 1.
    ELSEIF SCREEN-NAME = P_CR.
      SCREEN-INPUT = 0.
    ENDIF.
  ELSE.
    IF SCREEN-NAME = P_CH OR SCREEN-NAME = P_IN_CH OR
      SCREEN-NAME = P_UD_CH OR SCREEN-NAME = P_MB1B .
      SCREEN-INPUT = 0.
    ELSEIF SCREEN-NAME = P_CR.
      SCREEN-INPUT = 1.
    ENDIF.
  ENDIF.


ENDFORM.                    " MODIFY_SCREEN_BUTTON2
*&---------------------------------------------------------------------*
*&      Form  BDC_LOT_CREATE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM BDC_LOT_CREATE USING    P_LOT    LIKE  GS_LOT.

  DATA L_ART  LIKE QALS-ART.

  IF GS_LOT-WERKS_M EQ '3601' OR
     GS_LOT-WERKS_M EQ '3602' OR
     GS_LOT-WERKS_M EQ '3603' OR
     GS_LOT-WERKS_M EQ '3604' OR
     GS_LOT-WERKS_M EQ '3606'."트랙터 엔진 플랜트 분리 2018.12.13 HJW
    L_ART = '89'.
  ELSEIF GS_LOT-WERKS_M EQ '2200' OR
     GS_LOT-WERKS_M EQ '2201' OR
     GS_LOT-WERKS_M EQ '2202' OR
     GS_LOT-WERKS_M EQ '2281' OR
     GS_LOT-WERKS_M EQ '2291' OR
     GS_LOT-WERKS_M EQ '2300' OR
     GS_LOT-WERKS_M EQ '2301' OR
     GS_LOT-WERKS_M EQ '2302' OR
     GS_LOT-WERKS_M EQ '2381' OR
     GS_LOT-WERKS_M EQ '2391'.
    L_ART = '89'..

  ELSE.
    L_ART = '06'.
  ENDIF.


  PERFORM STORE_BDCDATA   USING:
          'X'  'SAPLQPL1'          '0100',
          ' '  'BDC_OKCODE'        '/00',
          ' '  'QALS-MATNR'        GS_LOT-MATNR,
          ' '  'QALS-WERK'         GS_LOT-WERKS_M,
          ' '  'QALS-HERKUNFT'      L_ART.

  IF L_ART = '89'.
    SELECT COUNT(*) FROM
    QMAT
    WHERE MATNR EQ P_LOT-MATNR
    AND ( ART EQ '89' OR ART EQ '91' OR ART EQ '92').

    IF SY-DBCNT > 1.
      PERFORM STORE_BDCDATA   USING:
             'X'  'SAPMSSY0'          '0120',
             ' '  'BDC_CURSOR'        '06/04',
             ' '  'BDC_OKCODE'        '=PICK'.
    ENDIF.
  ENDIF.


  PERFORM STORE_BDCDATA   USING:
          'X'  'SAPLQPL1'          '0200',
*          ' '  'QALS-CHARG'        p_lot-charg,    "배치번호
          ' '  'QALS-LOSMENGE'     P_LOT-RKMNG,    "검사로트수량
          ' '  'QALS-KUNNR'        P_LOT-KUNUM,    "고객
          ' '  'QALS-KTEXTLOS'     P_LOT-QMTXT.    "내역

  PERFORM BDC_TRANSACTION  USING     'QA01'
                                     'E'
                           CHANGING  GV_SUBRC.

  READ    TABLE MESSTAB  WITH KEY MSGTYP = 'S' MSGNR = '100'.
  IF  SY-SUBRC  EQ  0.
    CLEAR GV_PRUEFLOS.
    GV_PRUEFLOS = MESSTAB-MSGV2.
    COMMIT WORK.
    MESSAGE S004  WITH '검사로트' MESSTAB-MSGV1 MESSTAB-MSGV2
                       '가(이) 생성되었습니다'.
  ELSE.
    MESSAGE S001  WITH '검사로트 생성중 오류가 발생하였습니다'.
    EXIT.
  ENDIF.

  CHECK GV_PRUEFLOS NE SPACE.

  PERFORM UPDATE_QA USING GV_PRUEFLOS.

ENDFORM.                    " BDC_LOT_CREATE
*&---------------------------------------------------------------------*
*&      Form  UPDATE_QA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM UPDATE_QA USING P_PRUEFLOS.

  DELETE GT_200 WHERE PRUEFLOS = P_PRUEFLOS.

  SELECT  *
   APPENDING CORRESPONDING FIELDS OF TABLE GT_200
   FROM QALS
   WHERE PRUEFLOS = P_PRUEFLOS.

  DATA : L_IDX TYPE I.

  LOOP AT GT_200 WHERE PRUEFLOS = P_PRUEFLOS.
    L_IDX = SY-TABIX.

    GT_200-STATUS = '1'.
    GT_200-RCEPNO = GS_100-RCEPNO.

    SELECT COUNT(*)
      FROM JEST AS A JOIN QALS AS B
        ON A~OBJNR EQ B~OBJNR
     WHERE PRUEFLOS EQ GS_0015Q-PRUEFLOS
       AND STAT = 'I0224'
       AND INACT NE 'X'.
    IF SY-SUBRC EQ 0.
      GT_200-DFLG = 'X'.
    ENDIF.


    PERFORM GET_BUKRS USING    GS_LOT-WERKS_M
                      CHANGING GT_200-BUKRS.

*    GT_200-BUKRS   = GS_100-BUKRS.
    GT_200-ZMATSEQ = GT_190-ZMATSEQ.

*     검사로트에서 검사비용 발췌
    IF  NOT  P_PRUEFLOS  IS INITIAL.
      PERFORM  GET_QALS_PRUEFLOS_102   USING  P_PRUEFLOS
                                    CHANGING  GT_200-IPCST
                                              GT_200-PMEIN. "검
    ENDIF.

    PERFORM MODIFY_LIST USING    GT_200-STATUS
                        CHANGING GT_200-LIGHTS
                                 GT_200-STATUST.

    PERFORM TRANS_DATA_UPDAT USING 'ZQMT0015Q'.

    MODIFY GT_200 INDEX  L_IDX.
    CLEAR GT_200.
  ENDLOOP.

*  SORT : GT_170 BY VBELN POSNR.

  READ TABLE GT_200 WITH KEY MARK = 'X'.
  IF SY-SUBRC <> 0.
    CLEAR : GV_PRUEFLOS.
  ENDIF.

  PERFORM SAVE_COMPLAIN_DATA_2 USING 'X'.

ENDFORM.                    " UPDATE_QA
*&---------------------------------------------------------------------*
*&      Form  GET_QALS_PRUEFLOS_102
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GV_PRUEFLOS  text
*      <--P_GS_0015Q_IPCST  text
*      <--P_GS_0015Q_PMEIN  text
*----------------------------------------------------------------------*
FORM GET_QALS_PRUEFLOS_102  USING    VALUE(P_PRUEFLOS)
                            CHANGING VALUE(P_IPCST)
                                     VALUE(P_PMEIN).

  DATA: L_AUFPL        TYPE  QALS-AUFPL.

  DATA: BEGIN OF LS_COBK,
          KOKRS TYPE  COBK-KOKRS,
          BELNR TYPE  COBK-BELNR,
        END OF   LS_COBK.
  DATA: LT_COBK        LIKE  TABLE OF LS_COBK.

  DATA: LS_COEP TYPE  COEP,
        LT_COEP LIKE  TABLE OF LS_COEP.

  DATA: L_WTGBTR       TYPE  COEP-WTGBTR.
*

  SELECT SINGLE  AUFPL
       INTO  L_AUFPL
       FROM  QALS
      WHERE  PRUEFLOS  EQ  P_PRUEFLOS.

  IF  SY-SUBRC  NE  0.
    EXIT.
  ENDIF.

  SELECT    A~KOKRS  A~BELNR
      INTO  CORRESPONDING FIELDS OF TABLE LT_COBK
      FROM  COBK AS A  INNER JOIN  AFVC AS B
      ON    A~REFBN = B~RUECK
      WHERE B~AUFPL  EQ  L_AUFPL
        AND A~REFBT  EQ  'R'
        AND A~AWTYP  EQ  'AFRU'
        AND A~STFLG  EQ  SPACE
        AND A~STOKZ  EQ  SPACE.

  IF  SY-SUBRC  NE  0.
    EXIT.
  ENDIF.

  SELECT  *
       INTO  CORRESPONDING FIELDS OF TABLE LT_COEP
       FROM  COEP
       FOR  ALL ENTRIES IN  LT_COBK
      WHERE  KOKRS  EQ  LT_COBK-KOKRS
        AND  BELNR  EQ  LT_COBK-BELNR
        AND  BEKNZ  EQ  'S'.

  LOOP AT  LT_COEP  INTO LS_COEP.
    L_WTGBTR  =  L_WTGBTR  +  LS_COEP-WTGBTR.
  ENDLOOP.

  P_IPCST    =  L_WTGBTR.
  P_PMEIN    =  LS_COEP-TWAER.

ENDFORM.                    " GET_QALS_PRUEFLOS_102
*&---------------------------------------------------------------------*
*&      Form  GET_COMPLAIN_DATA_200
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM GET_COMPLAIN_DATA_200 .

  DATA : LV_WERKS  LIKE ZQMT0011H-WERKS_H.
  DATA : LV_POSID      LIKE PRPS-POSID,
         LV_PSPEL      LIKE AUFK-PSPEL,
         LV_WOGBTR     TYPE Z_WOGXXX,
         LV_WOGBTR_SUB TYPE Z_WOGXXX,
         LV_WAERS      TYPE OWAER,
         LV_PSPHI      TYPE PS_PSPHI,
         LV_PSPNR      TYPE PS_POSNR.


*___최초 실행시 비용재계산 실행
  SELECT SINGLE WERKS_H
    INTO LV_WERKS
    FROM ZQMT0011H
   WHERE RCEPNO = GV_RCEPNO
     AND BUKRS  = G_BUKRS.     "가온전선

  IF GV_RCEPNO IS NOT INITIAL AND
     LV_WERKS  IS NOT INITIAL.

    CALL FUNCTION 'Z_QM_RECOM_COST'
      EXPORTING
        I_RCEPNO = GV_RCEPNO
        I_WERKS  = LV_WERKS.
  ENDIF.

*___개요
  SELECT SINGLE *
    INTO CORRESPONDING FIELDS OF GS_100
    FROM ZQMT0011H
   WHERE RCEPNO = GV_RCEPNO
     AND BUKRS  = G_BUKRS.     "가온전선

  CHECK SY-SUBRC = 0.

  PERFORM GET_WERKST USING GS_100-WERKS_H CHANGING GS_100-WERKST.

  PERFORM GET_PRCTRT USING GS_100-PRCTR CHANGING GS_100-PRCTRT.

  PERFORM GET_KUNUMT USING GS_100-KUNUM CHANGING GS_100-KUNUMT.

  PERFORM GET_SUL_STATUS_TXT USING    'ZPRIORITY' GS_100-PRIORITY
                             CHANGING GS_100-PRIORITYT.

  PERFORM GET_SUL_STATUS_TXT USING    'ZSTATUS_H' GS_100-STATUS
                             CHANGING GS_100-STATUST.

  PERFORM  VKBUR_READ  USING  GS_100-VKBUR  CHANGING  GS_100-VKBURT.

  PERFORM  VKGRP_READ  USING  GS_100-VKGRP  CHANGING  GS_100-VKGRPT.

  PERFORM  VTWEG_READ  USING  GS_100-VTWEG  CHANGING  GS_100-VTWEGT.

  PERFORM  DSTGR_READ  USING  GS_100-DSTGR  CHANGING  GS_100-DSTGRT.

  PERFORM GET_SPGCD_DESC  USING  GS_100-SPGCD  CHANGING GS_100-SPGCDT.


*__불만사항 Long Text
  PERFORM READ_LONG_TEXT TABLES G_LINES1_O
                         USING  GC_TDID1
                                GS_100-TDNAME1
                                GC_TDOBJECT.

*__고객요구사항 Long Text
  PERFORM READ_LONG_TEXT TABLES G_LINES2_O
                         USING  GC_TDID2
                                GS_100-TDNAME1
                                GC_TDOBJECT.

*__접수구분
  CLEAR : GV_RCLAS1,  GV_RCLAS2,  GV_RCLAS3,  GV_RCLAS4,
          GV_RCLAS5,  GV_RCLAS6,  GV_RCLAS7.

  CASE GS_100-RCLAS.
    WHEN '1'.
      GV_RCLAS1 = 'X'.
    WHEN '2'.
      GV_RCLAS2 = 'X'.
    WHEN '3'.
      GV_RCLAS3 = 'X'.
    WHEN '4'.
      GV_RCLAS4 = 'X'.
    WHEN '5'.
      GV_RCLAS5 = 'X'.
    WHEN '6'.
      GV_RCLAS6 = 'X'.
    WHEN '7'.
      GV_RCLAS7 = 'X'.
  ENDCASE.

  PERFORM GET_USER_NAME USING : GS_100-ERNAM GS_100-ERNAMT,
                                GS_100-AENAM GS_100-AENAMT.

*{ [기능개선_224713] [LSC] 고객불만 WBS금액 표기의 건
* 고객불만 조회시, WBS코드 있는 경우
* 해당 WBS로 집행된 금액을 표기하도록함

  CLEAR :GT_0722, GT_0722[], GT_PRHI, GT_PRHI[],
         LV_POSID, LV_PSPEL, LV_WAERS, LV_PSPHI.

  IF  GS_100-BUKRS = '6000'.

    IF GS_100-POSID IS NOT INITIAL.

      LV_POSID = GS_100-POSID+0(9).


      CALL FUNCTION 'CONVERSION_EXIT_KONPD_INPUT'
        EXPORTING
          INPUT  = LV_POSID
        IMPORTING
          OUTPUT = LV_PSPHI.

      SELECT *
        INTO TABLE GT_PRHI
        FROM PRHI
       WHERE PSPHI EQ LV_PSPHI.


      LOOP AT GT_PRHI.


        CLEAR LV_WOGBTR_SUB.

        SELECT SINGLE SUM( WOGBTR )
          INTO LV_WOGBTR_SUB
          FROM ZQMT0722
         WHERE PSPNR EQ  GT_PRHI-POSNR.

        LV_WOGBTR = LV_WOGBTR + LV_WOGBTR_SUB.


*        IF gs_100-waers IS INITIAL.

        IF GS_100-WAERS_C IS INITIAL.
          SELECT SINGLE WAERS
            INTO LV_WAERS
            FROM ZQMT0722
           WHERE PSPNR EQ GT_PRHI-POSNR.

          GS_100-WAERS_C = LV_WAERS.

        ENDIF.

      ENDLOOP.

      GS_100-WOGBTR_C = LV_WOGBTR * 100.

    ENDIF.

  ENDIF.

*} 고객불만- WBS집행금액 표기의 건

ENDFORM.                    " GET_COMPLAIN_DATA_200
*&---------------------------------------------------------------------*
*&      Form  GET_COMPLAIN_DATA_300
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM GET_COMPLAIN_DATA_300 .
*___자재 List
  SELECT *
    INTO CORRESPONDING FIELDS OF TABLE GT_100
    FROM ZQMT0011M
   WHERE RCEPNO = GV_RCEPNO.


  LOOP AT GT_100.
*___자재내역
    PERFORM GET_MATNR_DESC USING GT_100-MATNR
                                 GT_100-MAKTX.

    MODIFY GT_100.
  ENDLOOP.

  SORT: GT_100 BY ZMATSEQ.

*___불만제품 상세
  SELECT *
    INTO CORRESPONDING FIELDS OF TABLE GT_110A
    FROM ZQMT0011B
   WHERE RCEPNO = GV_RCEPNO.


  LOOP AT GT_110A.
    PERFORM GET_MATCT_DESC USING GV_RCEPNO
                           CHANGING GT_110A-MATCT
                                 GT_110A-KUNCT
                                 GT_110A-ZAEDAT_B
                                 GT_110A-ZAEZET_B.

    MODIFY GT_110A.
  ENDLOOP.

*___불량유형
  SELECT *
    INTO CORRESPONDING FIELDS OF TABLE GT_120A
    FROM ZQMT0012N
   WHERE RCEPNO = GV_RCEPNO.

  LOOP AT GT_120A.

    PERFORM GET_FLTTPT_DESC USING    GT_120A-FTKAT
                                     GT_120A-FTGRP
                                     GT_120A-FLTTP
                            CHANGING GT_120A-FLTTPT.

    PERFORM GET_OTEILT_DESC USING    GT_120A-OTKAT
                                     GT_120A-OTRGRP
                                     GT_120A-OTEIL
                            CHANGING GT_120A-OTEILT.

    MODIFY GT_120A.
  ENDLOOP.

ENDFORM.                    " GET_COMPLAIN_DATA_300
*&---------------------------------------------------------------------*
*&      Form  GET_COMPLAIN_DATA_400
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM GET_COMPLAIN_DATA_400 .

*__영업문서 List
  SELECT *
    INTO CORRESPONDING FIELDS OF TABLE GT_140
    FROM ZQMT0014S
   WHERE RCEPNO = GV_RCEPNO.

  LOOP AT GT_140.

    CASE GT_140-STATUS .
      WHEN  '1'.
        GT_140-LIGHTS = ICON_RED_LIGHT.
        GT_140-STATUST = '미결'.
      WHEN  '2'.
        GT_140-LIGHTS = ICON_GREEN_LIGHT.
        GT_140-STATUST = '완료'.
      WHEN  '3'.
        GT_140-LIGHTS = ICON_YELLOW_LIGHT.
        GT_140-STATUST = '삭제'.
      WHEN  '4'.
        GT_140-LIGHTS = ICON_RED_LIGHT.
        GT_140-STATUST = '처리'.
    ENDCASE.

    MODIFY GT_140.
  ENDLOOP.

  SORT: GT_140 BY ZMATSEQ.

*__검사로트 List
  SELECT *
  INTO CORRESPONDING FIELDS OF TABLE GT_150
  FROM ZQMT0015Q
 WHERE RCEPNO = GV_RCEPNO.

  LOOP AT GT_150.

    PERFORM MODIFY_LIST USING    GT_150-STATUS
                        CHANGING GT_150-LIGHTS
                                 GT_150-STATUST.

    MODIFY GT_150.
  ENDLOOP.

ENDFORM.                    " GET_COMPLAIN_DATA_400
*&---------------------------------------------------------------------*
*&      Form  GET_COMPLAIN_DATA_500
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM GET_COMPLAIN_DATA_500 .

*__반품/출고 자재 List
  LOOP AT GT_100.
    MOVE-CORRESPONDING GT_100 TO GT_160.

*___신호등
    IF GT_160-KZLOESCH = 'X'.
      GT_160-LIGHTS = ICON_YELLOW_LIGHT.
    ELSE.
      READ TABLE GT_140 WITH KEY ZMATSEQ = GT_160-ZMATSEQ
                                 DFLG    = ' '
                                 STATUS  = '1'.
      IF SY-SUBRC = 0.
        GT_160-LIGHTS = ICON_RED_LIGHT.
      ELSE.
        GT_160-LIGHTS = ICON_GREEN_LIGHT.
      ENDIF.
    ENDIF.

    APPEND GT_160.    CLEAR GT_160.
  ENDLOOP.

  SORT GT_160 BY ZMATSEQ.


ENDFORM.                    " GET_COMPLAIN_DATA_500
*&---------------------------------------------------------------------*
*&      Form  GET_COMPLAIN_DATA_600
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM GET_COMPLAIN_DATA_600 .

*__반품검사로트 자재 List
  LOOP AT GT_100.
    MOVE-CORRESPONDING GT_100 TO GT_190.

*___신호등
    IF GT_190-KZLOESCH = 'X'.
      GT_190-LIGHTS = ICON_YELLOW_LIGHT.
    ELSE.
      READ TABLE GT_150 WITH KEY ZMATSEQ = GT_190-ZMATSEQ
                                 DFLG    = ' '
                                 STATUS  = '1'.
      IF SY-SUBRC = 0.
        GT_190-LIGHTS = ICON_RED_LIGHT.
      ELSE.
        GT_190-LIGHTS = ICON_GREEN_LIGHT.
      ENDIF.
    ENDIF.

    APPEND GT_190.    CLEAR GT_190.
  ENDLOOP.

ENDFORM.                    " GET_COMPLAIN_DATA_600
*&---------------------------------------------------------------------*
*&      Form  GET_COMPLAIN_DATA_700
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM GET_COMPLAIN_DATA_700 .

*__물류관련 손실금액
  CLEAR : S_710-RFAMT,   S_710-CLAMT,   S_710-RTAMT,
          S_710-RTAMT2,  S_710-GBAMT,   S_710-MVCST,
          S_710-IPCST,   S_710-CSACT,   S_710-CSOUT,
          S_710-CSPAT,   S_710-LSCST,   S_710-ETAMT,
          S_710-BEAMT01, S_710-BEAMT02, S_710-BEAMT03,
          S_710-BEAMT04, S_710-BEAMT05, S_710-BEAMT06,
          S_710-BEAMT07, S_710-BEAMT08, S_710-BEAMT09.

  LOOP AT GT_100.
    S_710-RFAMT  = S_710-RFAMT  + GT_100-RFAMT.   "반품금액
    S_710-CLAMT  = S_710-CLAMT  + GT_100-CLAMT.   "클레임출고비
    S_710-RTAMT  = S_710-RTAMT  + GT_100-RTAMT.   "반품폐기비
    S_710-RTAMT2 = S_710-RTAMT2 + GT_100-RTAMT2.  "반품폐기비(외부)
    S_710-GBAMT  = S_710-GBAMT  + GT_100-GBAMT.   "잡손실폐기비
    S_710-MVCST  = S_710-MVCST  + GT_100-MVCST.   "반품운반비
    S_710-IPCST  = S_710-IPCST  + GT_100-IPCST.   "반품검사비
  ENDLOOP.


* CS인건비 / CS외주비 / CS부품비
  SELECT SINGLE CSACT  CSOUT  CSPAT
    FROM ZQMT0011H
    INTO (S_710-CSACT, S_710-CSOUT, S_710-CSPAT)
   WHERE RCEPNO EQ GS_100-RCEPNO.

*__AS관련 손실금액
  PERFORM GET_AS_AMOUNT.

*__추정손실금액
  S_710-ETAMT = GS_100-ETAMT.

*__총손실금액
  S_710-LSCST = S_710-RTAMT           "반품폐기비
              + S_710-RTAMT2          "반품폐기비(외부)
              + S_710-GBAMT           "잡손실폐기비
              + S_710-CLAMT           "클레임출고비
*              + S_710-CSACT           "CS인건비
              + S_710-CSOUT           "CS외주비
              + S_710-CSPAT           "CS부품비
              + S_710-MVCST           "반품운반비
              + S_710-BEAMT01         "손실보상비
              + S_710-BEAMT02         "지체상환금
              + S_710-BEAMT03         "A/S지원비
              + S_710-BEAMT04         "하자보수비
              + S_710-BEAMT05         "분석검사비
              + S_710-BEAMT06         "Warranty비
              + S_710-BEAMT07.        "CS자재등구입비

ENDFORM.                    " GET_COMPLAIN_DATA_700
*&---------------------------------------------------------------------*
*&      Form  GET_COMPLAIN_DATA_800
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM GET_COMPLAIN_DATA_800 .

  GT_210[] = GT_160[].

ENDFORM.                    " GET_COMPLAIN_DATA_800
*&---------------------------------------------------------------------*
*&      Form  GET_COMPLAIN_DATA_900
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM GET_COMPLAIN_DATA_900 .

*__회계전표 List
  SELECT *
    INTO CORRESPONDING FIELDS OF TABLE GT_220
    FROM ZQMT0016F
   WHERE RCEPNO = GV_RCEPNO.
*     AND DFLG EQ SPACE.

ENDFORM.                    " GET_COMPLAIN_DATA_900
*&---------------------------------------------------------------------*
*&      Form  GET_COMPLAIN_DATA_1100
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM GET_COMPLAIN_DATA_1100 .

*__처리현황(시정) Long Text
  PERFORM READ_LONG_TEXT TABLES G_LINES3_O
                         USING  GC_TDID3
                                GS_100-TDNAME1
                                GC_TDOBJECT.

*__현상 및 원인 Long Text
  PERFORM READ_LONG_TEXT TABLES G_LINES4_O
                         USING  GC_TDID4
                                GS_100-TDNAME1
                                GC_TDOBJECT.

*__재발방지 대책수립/실행/확인 Long Text
  PERFORM READ_LONG_TEXT TABLES G_LINES5_O
                         USING  GC_TDID5
                                GS_100-TDNAME1
                                GC_TDOBJECT.

*__자재/불량유형 List
  SELECT A~ZMATSEQ
         A~KZLOESCH
         A~WERKS_M
         A~MATNR
         A~KDAUF
         B~ZBADSEQ
         B~DFLG
         B~FTGRP
         B~FLTTP
         B~OTRGRP
         B~OTEIL
         B~TEXT
         B~REDCT
         B~ERNAM
         B~ERDAT
         B~ERZET
         B~AENAM
         B~AEDAT
         B~AEZET
         B~ZAEDAT_B
         B~ZAEZET_B
         C~KDPOS
    INTO CORRESPONDING FIELDS OF TABLE GT_230
    FROM ZQMT0011M AS A
   INNER JOIN ZQMT0012N AS B
      ON A~RCEPNO  = B~RCEPNO
     AND A~ZMATSEQ = B~ZMATSEQ
   INNER JOIN ZQMT0011B AS C
      ON B~RCEPNO  = C~RCEPNO
     AND B~ZMATSEQ = C~ZMATSEQ
   WHERE A~RCEPNO   = GV_RCEPNO.

  DELETE ADJACENT DUPLICATES FROM GT_230 COMPARING ZMATSEQ ZBADSEQ.


  LOOP AT GT_230.
*__자재내역
    PERFORM GET_MATNR_DESC USING GT_230-MATNR
                                 GT_230-MAKTX.
*__결함유형 내역
    PERFORM GET_FLTTPT_DESC USING    '9'
                                     GT_230-FTGRP
                                     GT_230-FLTTP
                            CHANGING GT_230-FLTTPT.

*__위치코드 내역
    PERFORM GET_OTEILT_DESC USING    'E'
                                     GT_230-OTRGRP
                                     GT_230-OTEIL
                            CHANGING GT_230-OTEILT.

    MODIFY GT_230.
  ENDLOOP.


*__원인 List
  SELECT *
    INTO CORRESPONDING FIELDS OF TABLE GT_240
    FROM ZQMT0012C
   WHERE RCEPNO = GV_RCEPNO.

  LOOP AT GT_240.
*__원인 내역
    PERFORM GET_FLTTPT_DESC USING    '5'
                                     GT_240-FTGRP
                                     GT_240-FLTTP
                            CHANGING GT_240-FLTTPT.
    MODIFY GT_240.
  ENDLOOP.


ENDFORM.                    " GET_COMPLAIN_DATA_1100
*&---------------------------------------------------------------------*
*&      Form  GET_COMPLAIN_DATA_1200
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM GET_COMPLAIN_DATA_1200 .

*__처리결과 Long Text
  PERFORM READ_LONG_TEXT TABLES G_LINES6_O
                         USING  GC_TDID6
                                GS_100-TDNAME1
                                GC_TDOBJECT.

*__처리결과/승인 자재 List
  LOOP AT GT_100.
    MOVE-CORRESPONDING GT_100 TO GT_280.
    APPEND GT_280.    CLEAR GT_280.
  ENDLOOP.

ENDFORM.                    " GET_COMPLAIN_DATA_1200
*&---------------------------------------------------------------------*
*&      Form  GET_COMPLAIN_DATA_1300
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM GET_COMPLAIN_DATA_1300 .

*__헤더 List
  SELECT RCEPNO
         AJAHR
         RCEPDT
         STATUS
         KUNUM
         PRCTR
         WERKS_H
         QMTXT
         QMDAT
         DSTDT
         CMPDT
         SPGCD
    INTO CORRESPONDING FIELDS OF TABLE GT_250
    FROM ZQMT0011H
   WHERE KUNUM    =  GS_100-KUNUM
     AND BUKRS    =  GS_100-BUKRS
*     AND RCEPDT   >= GS_100-RCEPDT
     AND KZLOESCH =  ' '
     AND RCEPNO   <> GV_RCEPNO.

*  SELECT A~RCEPNO
*         A~AJAHR
*         A~RCEPDT
*         A~STATUS
*         A~KUNUM
*         A~PRCTR
*         A~WERKS_H
*         A~QMTXT
*         A~QMDAT
*         A~DSTDT
*         A~CMPDT
*         B~SPGCD
*    INTO CORRESPONDING FIELDS OF TABLE GT_250
*    FROM ZQMT0011H AS A
*   INNER JOIN ZQMT0011M AS B
*      ON A~RCEPNO = B~RCEPNO
*   WHERE A~KUNUM = GS_100-KUNUM
**     AND A~RCEPDT >= GS_100-RCEPDT
*     AND A~KZLOESCH = ' '
*     AND A~RCEPNO <> GV_RCEPNO.

  LOOP AT GT_250.

*__플랜트 내역
    PERFORM GET_WERKST USING GT_250-WERKS_H CHANGING GT_250-WERKST.

*__손익센터 내역
    PERFORM GET_PRCTRT USING GT_250-PRCTR CHANGING GT_250-PRCTRT.

*__고객 내역
    PERFORM GET_KUNUMT USING GT_250-KUNUM CHANGING GT_250-KUNUMT.

*__상태내역
    PERFORM GET_SUL_STATUS_TXT USING    'ZSTATUS_H' GT_250-STATUS
                               CHANGING GT_250-STATUST.

    MODIFY GT_250.
  ENDLOOP.



*__불만이력 - 자재 List
  IF LINES( GT_100 ) > 0.

    SELECT A~RCEPNO
           A~AJAHR
           A~RCEPDT
           A~STATUS
           A~KUNUM
           A~PRCTR
           B~WERKS_M
           A~QMTXT
           A~QMDAT
           A~DSTDT
           A~CMPDT
           B~SPGCD
           B~ZMATSEQ
           B~MATNR
           B~RKMNG
           B~MGEIN
           B~KDAUF
           B~KWMENG
           B~VRKME
           B~MATCT
           B~KUNCT
      INTO CORRESPONDING FIELDS OF TABLE GT_260
      FROM ZQMT0011H AS A
     INNER JOIN ZQMT0011M AS B
        ON A~RCEPNO = B~RCEPNO
      FOR ALL ENTRIES IN GT_100
     WHERE B~MATNR    =  GT_100-MATNR
       AND A~BUKRS    =  GS_100-BUKRS
*       AND A~RCEPDT   >= GS_100-RCEPDT
       AND A~KZLOESCH =  ' '
       AND B~KZLOESCH =  ' '
       AND A~RCEPNO   <> GV_RCEPNO.

  ENDIF.

  LOOP AT GT_260.

*__상태내역
    PERFORM GET_SUL_STATUS_TXT USING    'ZSTATUS_H' GT_260-STATUS
                               CHANGING GT_260-STATUST.
*__고객 내역
    PERFORM GET_KUNUMT USING GT_260-KUNUM CHANGING GT_260-KUNUMT.

*__손익센터 내역
    PERFORM GET_PRCTRT USING GT_260-PRCTR CHANGING GT_260-PRCTRT.

*__플랜트 내역
    PERFORM GET_WERKST USING GT_260-WERKS_M CHANGING GT_260-WERKST.

*__제품군 내역
    PERFORM GET_SPGCD_DESC  USING    GT_260-SPGCD
                            CHANGING GT_260-SPGCDT.

*__자재 내역
    PERFORM GET_MATNR_DESC USING GT_260-MATNR
                                 GT_260-MAKTX.

    MODIFY GT_260.
  ENDLOOP.


*__불만이력 - 고객/자재 List
  IF LINES( GT_100 ) > 0.

    SELECT A~RCEPNO
           A~AJAHR
           A~RCEPDT
           A~STATUS
           A~KUNUM
           A~PRCTR
           B~WERKS_M
           A~QMTXT
           A~QMDAT
           A~DSTDT
           A~CMPDT
           B~SPGCD
           B~ZMATSEQ
           B~MATNR
           B~RKMNG
           B~MGEIN
           B~KDAUF
           B~KWMENG
           B~VRKME
           B~MATCT
           B~KUNCT
      INTO CORRESPONDING FIELDS OF TABLE GT_270
      FROM ZQMT0011H AS A INNER JOIN ZQMT0011M AS B
                          ON A~RCEPNO = B~RCEPNO
       FOR ALL ENTRIES IN GT_100
     WHERE A~KUNUM    =  GS_100-KUNUM
       AND B~MATNR    =  GT_100-MATNR
       AND A~BUKRS    =  GS_100-BUKRS
*       AND A~RCEPDT   >= GS_100-RCEPDT
       AND A~KZLOESCH =  ' '
       AND B~KZLOESCH =  ' '
       AND A~RCEPNO   <> GV_RCEPNO.

  ENDIF.

  LOOP AT GT_270.

*__상태내역
    PERFORM GET_SUL_STATUS_TXT USING    'ZSTATUS_H' GT_270-STATUS
                               CHANGING GT_270-STATUST.
*__고객 내역
    PERFORM GET_KUNUMT USING GT_270-KUNUM CHANGING GT_270-KUNUMT.

*__손익센터 내역
    PERFORM GET_PRCTRT USING GT_270-PRCTR CHANGING GT_270-PRCTRT.

*__플랜트 내역
    PERFORM GET_WERKST USING GT_270-WERKS_M CHANGING GT_270-WERKST.

*__제품군 내역
    PERFORM GET_SPGCD_DESC  USING    GT_270-SPGCD
                            CHANGING GT_270-SPGCDT.

*__자재 내역
    PERFORM GET_MATNR_DESC USING GT_270-MATNR
                                 GT_270-MAKTX.

    MODIFY GT_270.
  ENDLOOP.


ENDFORM.                    " GET_COMPLAIN_DATA_1300
*&---------------------------------------------------------------------*
*&      Form  SAVE_LONG_TEXT_DB
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GC_TDOBJECT  text
*      -->P_GC_TDID1  text
*----------------------------------------------------------------------*
FORM SAVE_LONG_TEXT_DB  TABLES PT_LINES_N STRUCTURE TLINE
                               PT_LINES_O STRUCTURE TLINE
                        USING  PV_TDOBJECT
                               PV_TDID1.

  CLEAR : G_HEADER.

  G_HEADER-TDOBJECT = PV_TDOBJECT.
  G_HEADER-TDID     = PV_TDID1.
  G_HEADER-TDSPRAS  = SY-LANGU.
  G_HEADER-TDNAME   = GS_100-TDNAME1.

*  CONCATENATE G_HEADER-TDOBJECT GC_TDID1 GV_RCEPNO
*              INTO G_HEADER-TDNAME.

  CALL FUNCTION 'SAVE_TEXT'
    EXPORTING
      HEADER          = G_HEADER
      SAVEMODE_DIRECT = 'X'
    IMPORTING
      NEWHEADER       = G_HEADER
    TABLES
      LINES           = PT_LINES_N
    EXCEPTIONS
      ID              = 1
      LANGUAGE        = 2
      NAME            = 3
      OBJECT          = 4
      OTHERS          = 5.

  IF SY-SUBRC NE 0.
    MESSAGE E001  WITH '저장시 에러가 발생하였습니다.'.
    GV_FORM_FLG = 'X'.
    EXIT.
  ELSE.
    PT_LINES_O[] = PT_LINES_N[].
    GV_ZQM5 = 'X'.
  ENDIF.

ENDFORM.                    " SAVE_LONG_TEXT_DB
*&---------------------------------------------------------------------*
*&      Form  REFRESH_GRID_170
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM REFRESH_GRID_170 .

  CHECK NOT G_GRID_5 IS INITIAL.
  PERFORM PRO_LAYOUT_1 USING GS_LAYOUT_5.

  CALL METHOD G_GRID_5->SET_FRONTEND_LAYOUT
    EXPORTING
      IS_LAYOUT = GS_LAYOUT_5.

  CALL METHOD G_GRID_5->REFRESH_TABLE_DISPLAY
    EXPORTING
      I_SOFT_REFRESH = ' '.

  CALL METHOD CL_GUI_CFW=>FLUSH.

ENDFORM.                    " REFRESH_GRID_170
*&---------------------------------------------------------------------*
*&      Form  REFRESH_GRID_200
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM REFRESH_GRID_200 .
  CHECK NOT G_GRID_7 IS INITIAL.
  PERFORM PRO_LAYOUT_1 USING GS_LAYOUT_7.

  CALL METHOD G_GRID_7->SET_FRONTEND_LAYOUT
    EXPORTING
      IS_LAYOUT = GS_LAYOUT_7.

  CALL METHOD G_GRID_7->REFRESH_TABLE_DISPLAY
    EXPORTING
      I_SOFT_REFRESH = ' '.

  CALL METHOD CL_GUI_CFW=>FLUSH.

ENDFORM.                    " REFRESH_GRID_200
*&---------------------------------------------------------------------*
*&      Form  GET_SA_LIST
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM GET_SA_LIST .
  DATA: LS_VBELN LIKE VBAK-VBELN.
  CLEAR: LS_VBELN.
  CLEAR : GT_170, GT_170[].

  SELECT VBELN
    INTO LS_VBELN
    FROM VBKD
   WHERE POSNR = '000000'
     AND BSTKD = GV_RCEPNO.

    SELECT *
      APPENDING CORRESPONDING FIELDS OF TABLE GT_170
     FROM VBAP AS B
    WHERE VBELN = LS_VBELN.

  ENDSELECT.

  SELECT *
  APPENDING CORRESPONDING FIELDS OF TABLE GT_170
  FROM ZQMT0014S
  WHERE RCEPNO = GV_RCEPNO.

  SORT GT_170 BY VBELN POSNR.
  DELETE ADJACENT DUPLICATES FROM GT_170
  COMPARING VBELN POSNR.

ENDFORM.                    " GET_SA_LIST
*&---------------------------------------------------------------------*
*&      Form  GET_MESG_COST
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GT_170_VBELN  text
*      -->P_GT_170_POSNR  text
*      <--P_G_710_RTAMT  text
*      <--P_G_710_RTAMT2  text
*----------------------------------------------------------------------*
FORM GET_MESG_COST  USING     VALUE(P_RFUND)
                              VALUE(P_POSNR)
                     CHANGING VALUE(P_RTAMT)
                              VALUE(P_RTAMT2).
  DATA: BEGIN OF LS_LIPS,
          ERDAT TYPE LIPS-ERDAT,
          MATNR TYPE LIPS-MATNR,  "
          WERKS TYPE LIPS-WERKS,  "
          LGORT TYPE LIPS-LGORT,  "
          CHARG TYPE LIPS-CHARG,  "
          BWART TYPE LIPS-BWART,  "
        END OF   LS_LIPS.
  DATA: LT_LIPS       LIKE TABLE OF LS_LIPS.
  DATA: L_DMBTR       LIKE MATDOC-DMBTR.
  DATA  L_MBLNR_I     LIKE ZCOTP006-MBLNR_I.



  DATA: L_DMBTR_CO LIKE MATDOC-DMBTR,
        L_BWART_CO LIKE MATDOC-BWART.


  CLEAR : GT_MBLNR, P_RTAMT, GT_MBLNR[].

  SELECT A~MBLNR
         A~MJAHR
         A~MATNR
         A~CHARG
         A~WERKS
         A~BWART
         A~DMBTR
         A~QCODE1
    INTO CORRESPONDING FIELDS OF TABLE GT_MBLNR
    FROM ZQMT0718 AS A
   INNER JOIN ZQMT0720 AS B
      ON A~MATNR EQ B~MATNR
     AND A~CHARG EQ B~CHARG
     AND A~WERKS EQ B~WERKS
   WHERE B~VBELN EQ P_RFUND
     AND B~POSNR EQ P_POSNR
     AND ( A~QCODE1 = 'CG009'
      OR A~QCODE1 = 'CG014' )
     AND B~REV_FLAG NE 'X'
     AND B~NO_TRACE NE 'X'
     AND A~SCR_RET = 'X'.

  DATA L_GUBUN TYPE I.
  LOOP AT GT_MBLNR.
    CLEAR:  L_MBLNR_I, L_DMBTR_CO.

    MOVE-CORRESPONDING  GT_MBLNR TO GS_RTAMT.

    SELECT SINGLE MBLNR_I
      INTO L_MBLNR_I
      FROM ZCOTP006
     WHERE MBLNR_O EQ GT_MBLNR-MBLNR
       AND MBLNR_OC EQ ''.

    SELECT SINGLE BWART DMBTR
      INTO (L_BWART_CO, L_DMBTR_CO)
      FROM MATDOC
     WHERE MBLNR = L_MBLNR_I
       AND MJAHR = GT_MBLNR-MJAHR.

    CLEAR L_GUBUN.
    L_GUBUN =   L_BWART_CO MOD 2.
    IF L_GUBUN EQ 1.
      L_DMBTR_CO = L_DMBTR_CO * '-1'.
    ENDIF.

    IF  GT_MBLNR-QCODE1 = 'CG009'.
      P_RTAMT = P_RTAMT + ( L_DMBTR_CO * 100 )
                        + ( GT_MBLNR-DMBTR * 100 ).
    ELSEIF GT_MBLNR-QCODE1 = 'CG014'.
      P_RTAMT2 = P_RTAMT2 + ( L_DMBTR_CO * 100 )
                      + ( GT_MBLNR-DMBTR * 100 ).

    ENDIF .

  ENDLOOP.

ENDFORM.                    " GET_MESG_COST
*&---------------------------------------------------------------------*
*&      Form  GET_ZQMT0732_COST
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GT_170_VBELN  text
*      -->P_GT_170_POSNR  text
*      <--P_G_710_GBAMT  text
*----------------------------------------------------------------------*
FORM GET_ZQMT0732_COST  USING   VALUE(P_RFUND)
                                 VALUE(P_POSNR)
                        CHANGING VALUE(P_RTAMT).
  DATA: BEGIN OF LS_LIPS,
          ERDAT TYPE LIPS-ERDAT,
          MATNR TYPE LIPS-MATNR,  "
          WERKS TYPE LIPS-WERKS,  "
          LGORT TYPE LIPS-LGORT,  "
          CHARG TYPE LIPS-CHARG,  "
          BWART TYPE LIPS-BWART,  "
        END OF   LS_LIPS.

  DATA: LT_LIPS       LIKE TABLE OF LS_LIPS.
  DATA: L_DMBTR       LIKE MATDOC-DMBTR.
  DATA: L_MBLNR_I     LIKE ZCOTP006-MBLNR_I.
  DATA: L_DMBTR_CO LIKE MATDOC-DMBTR,
        L_BWART_CO LIKE MATDOC-BWART.

  CLEAR : GT_MBLNR2, P_RTAMT, GT_MBLNR2[].
  SELECT A~MBLNR
         A~MJAHR
         A~MATNR
         A~CHARG
         A~WERKS
         A~BWART
         A~DMBTR
         A~QCODE1
    INTO CORRESPONDING FIELDS OF TABLE GT_MBLNR2
    FROM ZQMT0732 AS A
   INNER JOIN ZQMT0720 AS B
      ON A~MATNR EQ B~MATNR
     AND A~CHARG EQ B~CHARG
     AND A~WERKS EQ B~WERKS
   WHERE B~VBELN EQ P_RFUND
     AND B~POSNR EQ P_POSNR
     AND A~QCODE1 = 'CM004'
     AND B~REV_FLAG NE 'X'
     AND B~NO_TRACE NE 'X'
     AND A~SCR_RET = 'X'.

  DATA L_GUBUN TYPE I.

  LOOP AT GT_MBLNR2.
    CLEAR:  L_MBLNR_I, L_DMBTR_CO.

    MOVE-CORRESPONDING  GT_MBLNR2 TO GS_RTAMT.

    SELECT SINGLE MBLNR_I
      INTO L_MBLNR_I
      FROM ZCOTP006
     WHERE MBLNR_O  EQ GT_MBLNR2-MBLNR
       AND MBLNR_OC EQ ''.

    SELECT SINGLE BWART DMBTR
      INTO (L_BWART_CO, L_DMBTR_CO)
      FROM MATDOC
     WHERE MBLNR = L_MBLNR_I
       AND MJAHR = GT_MBLNR2-MJAHR.

    CLEAR L_GUBUN.
    L_GUBUN =   L_BWART_CO MOD 2.
    IF L_GUBUN EQ 1.
      L_DMBTR_CO = L_DMBTR_CO * '-1'.
    ENDIF.

    P_RTAMT = P_RTAMT + ( L_DMBTR_CO * 100 )
                      + ( GT_MBLNR2-DMBTR * 100 ).


  ENDLOOP.

ENDFORM.                    " GET_ZQMT0732_COST
*&---------------------------------------------------------------------*
*&      Form  GET_TRANS_COST
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GT_170_VBELN  text
*      -->P_GT_170_POSNR  text
*      <--P_G_710_MVCST  text
*----------------------------------------------------------------------*
FORM GET_TRANS_COST  USING    P_RFUND
                              P_POSNR
                     CHANGING P_MVCST.
  DATA: BEGIN OF LS_LIPS,
          ERDAT TYPE LIPS-ERDAT,
          VBELN TYPE LIPS-VBELN,
          MATNR TYPE LIPS-MATNR,  "
          WERKS TYPE LIPS-WERKS,  "
          LGORT TYPE LIPS-LGORT,  "
          CHARG TYPE LIPS-CHARG,  "
          BWART TYPE LIPS-BWART,  "
        END OF   LS_LIPS.
  DATA: LT_LIPS        LIKE TABLE OF LS_LIPS.

  CLEAR : P_MVCST,  LT_LIPS,  LT_LIPS[],  GT_LIST,  GT_LIST[].

  SELECT C~VBELN
         C~MATNR
         C~WERKS
         C~LGORT
         C~CHARG
         C~BWART
         A~ERDAT
   INTO CORRESPONDING FIELDS OF TABLE LT_LIPS
   FROM VBAK AS A
   JOIN VBAP AS B
     ON A~VBELN EQ B~VBELN
   JOIN LIPS AS C
     ON B~VBELN EQ C~VGBEL
    AND B~POSNR EQ C~VGPOS
  WHERE B~VBELN EQ P_RFUND
    AND B~POSNR EQ P_POSNR.

  DELETE ADJACENT DUPLICATES FROM LT_LIPS COMPARING VBELN.
  IF LT_LIPS[] IS INITIAL.
    EXIT.
  ENDIF.

  SELECT K~FKNUM
         K~FKART
         K~STBER
         P~TDLNR
         P~KNUMV
         P~WAERS
         P~STABR
         P~STFRE
         V~TPLST
         V~TKNUM
         V~SHTYP
         V~DTABF
         V~EXTI1
         V~SDABW
         V~ALLOWED_TWGT
         L~VSTEL
         L~VBELN
         L~LFART
         L~ROUTE
         L~KUNAG
         L~KUNNR
         L~WADAT_IST AS WADAT
         L~XABLN
         L~ANZPK
    INTO CORRESPONDING FIELDS OF TABLE GT_LIST
    FROM VFKK AS K
   INNER JOIN VFKP AS P
      ON K~FKNUM = P~FKNUM
   INNER JOIN VTTK AS V
      ON P~REBEL = V~TKNUM
   INNER JOIN VTTP AS U
      ON V~TKNUM = U~TKNUM
   INNER JOIN LIKP AS L
      ON U~VBELN = L~VBELN
     FOR ALL ENTRIES IN LT_LIPS
   WHERE L~VBELN EQ LT_LIPS-VBELN
     AND L~LFART = 'LR'.

  LOOP AT GT_LIST.
    SELECT SUM( NETWR )
      INTO GT_LIST-NETWR1
      FROM VFKN
     WHERE FKNUM = GT_LIST-FKNUM
       AND REBEL = GT_LIST-VBELN.

    MODIFY GT_LIST INDEX SY-TABIX.
    P_MVCST = P_MVCST + ( GT_LIST-NETWR1 * 100 ).
  ENDLOOP.

ENDFORM.                    " GET_TRANS_COST
*&---------------------------------------------------------------------*
*&      Form  G_GRID_10_REFRESH
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM G_GRID_10_REFRESH .
  GS_SCROLL-ROW = 'X'.
  GS_SCROLL-COL = 'X'.

  CALL METHOD G_GRID_10->REFRESH_TABLE_DISPLAY
    EXPORTING
      I_SOFT_REFRESH = ' '
      IS_STABLE      = GS_SCROLL.

*  CALL METHOD CL_GUI_CFW=>FLUSH.
ENDFORM.                    " G_GRID_10_REFRESH
*&---------------------------------------------------------------------*
*&      Form  EVENT_HANDLER_REGISTER_230
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM EVENT_HANDLER_REGISTER_230 .
* TOOLBAR 구성은 EVENT에서 한다.
  CREATE OBJECT G_EVENT_HANDLER_10.
*

*-Edit  이벤트 등록
  CALL METHOD G_GRID_10->REGISTER_EDIT_EVENT
    EXPORTING
      I_EVENT_ID = CL_GUI_ALV_GRID=>MC_EVT_MODIFIED.

  CALL METHOD G_GRID_10->REGISTER_EDIT_EVENT
    EXPORTING
      I_EVENT_ID = CL_GUI_ALV_GRID=>MC_EVT_ENTER.

* 툴바지정
*    SET HANDLER g_event_handler_5->handle_toolbar
*                                FOR g_grid_5.
* 툴바에 해당하는 이벤트 지정
*    SET HANDLER g_event_handler_5->handle_user_command
*                                FOR g_grid_5.
** DATA_CHANGED
  SET HANDLER G_EVENT_HANDLER_10->HANDLE_DATA_CHANGED_5 FOR G_GRID_10.
  SET HANDLER G_EVENT_HANDLER_10->HANDLE_DATA_CHANGED_FINISHED_1
                                                     FOR G_GRID_10.
  SET HANDLER G_EVENT_HANDLER_10->HANDLE_HOTSPOT_CLICK_5
                        FOR G_GRID_10.
ENDFORM.                    " EVENT_HANDLER_REGISTER_230
*&---------------------------------------------------------------------*
*&      Form  DATA_CHANGED_5
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_ER_DATA_CHANGED  text
*----------------------------------------------------------------------*
FORM DATA_CHANGED_5  USING    ER_DATA_CHANGED
                            TYPE REF TO CL_ALV_CHANGED_DATA_PROTOCOL.
*
  DATA: LS_MOD_CELLS TYPE LVC_S_MODI,
        LS_CELLS     TYPE LVC_S_MODI,
        LS_FIELDCAT  TYPE LVC_S_FCAT.

  CLEAR   : GT_230, GS_230, GT_240, GT_240_TC.
  REFRESH : GT_240_TC.

  LOOP AT ER_DATA_CHANGED->MT_GOOD_CELLS INTO LS_MOD_CELLS.
    READ TABLE GT_230 INDEX LS_MOD_CELLS-ROW_ID.
    MOVE-CORRESPONDING GT_230 TO GS_230.

    IF GT_230-MARK IS INITIAL.
      LOOP AT GT_240 WHERE ZMATSEQ = GT_230-ZMATSEQ
                       AND ZBADSEQ = GT_230-ZBADSEQ.
        MOVE-CORRESPONDING GT_240 TO GT_240_TC.
        APPEND GT_240_TC.        CLEAR GT_240_TC.
      ENDLOOP.

      TC_1130-TOP_LINE     = 1.
      TC_1130-CURRENT_LINE = 1.
    ELSE.
      CLEAR : GT_240_TC, GT_240_TC[].
    ENDIF.

  ENDLOOP.

  LOOP AT GT_230.
    IF LS_MOD_CELLS-ROW_ID NE SY-TABIX.
      GT_230-MARK = SPACE.
    ELSE.
      GT_230-MARK = 'X'.
    ENDIF.
    MODIFY GT_230.
  ENDLOOP.

ENDFORM.                    " DATA_CHANGED_5
*&---------------------------------------------------------------------*
*&      Form  GET_TC_ADD_1130
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM GET_TC_ADD_1130 .
* local variable
  DATA: LS_TMP LIKE GT_240_TC,
        LT_TMP LIKE TABLE OF LS_TMP.

  READ TABLE GT_230 WITH KEY MARK = 'X'.
  IF SY-SUBRC = 0.

    LT_TMP = GT_240_TC[].
    SORT LT_TMP BY ZCAUSEQ DESCENDING.
    READ TABLE LT_TMP INTO LS_TMP INDEX 1.

    IF LS_TMP-ZCAUSEQ IS INITIAL OR
       LS_TMP-FTGRP   IS NOT INITIAL OR
       LS_TMP-FLTTP   IS NOT INITIAL.

      CLEAR : GT_240_TC, GT_240.

      GT_240_TC-ZMATSEQ = GT_230-ZMATSEQ.
      GT_240_TC-ZBADSEQ = GT_230-ZBADSEQ.
      GT_240_TC-RCEPNO  = GV_RCEPNO.
      GT_240_TC-ZCAUSEQ = LS_TMP-ZCAUSEQ + 1.

      PERFORM GET_BUKRS USING    GT_230-WERKS_M
                        CHANGING GT_240_TC-BUKRS.

      APPEND  GT_240_TC.

      MOVE-CORRESPONDING GT_240_TC TO GT_240.
*
      APPEND GT_240.
    ENDIF.

  ELSE.
    MESSAGE S001 WITH '자재를 선택하세요.' DISPLAY LIKE 'E'.
  ENDIF.

  DESCRIBE  TABLE  GT_240_TC  LINES TC_1130-LINES.

ENDFORM.                    " GET_TC_ADD_1130
*&---------------------------------------------------------------------*
*&      Form  GET_TC_DELETE_1130
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM GET_TC_DELETE_1130 .
* local variable
  DATA: LV_INDEX TYPE SY-TABIX,
        LW_INDEX TYPE SY-TABIX.

  CLEAR: LV_INDEX, LW_INDEX.

* 라디오 버튼이 체크된 항목을 읽어온다.
  CLEAR: GT_240_TC.
  READ TABLE GT_240_TC WITH KEY MARK = 'X'.
  IF SY-SUBRC = 0.
    LV_INDEX = SY-TABIX.

    %%POPUP_TO_CONFIRM_STEP '선택된 원인정보를 삭제하시겠습니까?.'
                            ' '  '삭제'.
    CHECK GV_ANSWER = 'J'.

* 고객불만(원인) 테이블 확인
    SELECT SINGLE *
      FROM ZQMT0012C
     WHERE RCEPNO  EQ GV_RCEPNO
       AND ZMATSEQ EQ GT_240_TC-ZMATSEQ
       AND ZBADSEQ EQ GT_240_TC-ZBADSEQ
       AND ZCAUSEQ EQ GT_240_TC-ZCAUSEQ.

* 해당 내용이 테이블에 존재하면 삭제플래그에 X만 update
    IF SY-SUBRC EQ 0.
*   고객불만 삭제처리
      IF GT_240_TC-DFLG <> ''.
        MESSAGE S001 WITH '이미 삭제된 데이타입니다.' DISPLAY LIKE 'E'.
        EXIT.
      ELSE.
        GT_240_TC-DFLG = 'X'.
      ENDIF.

      PERFORM TRANS_DATA_UPDAT USING 'ZQMT0012C'.

      MODIFY GT_240_TC INDEX LV_INDEX
                    TRANSPORTING DFLG AENAM AEDAT AEZET.

      READ TABLE GT_240 WITH KEY RCEPNO = GV_RCEPNO
                                 ZMATSEQ = GT_240_TC-ZMATSEQ
                                 ZBADSEQ = GT_240_TC-ZBADSEQ
                                 ZCAUSEQ = GT_240_TC-ZCAUSEQ.
      IF SY-SUBRC = 0.
        LW_INDEX = SY-TABIX.
        GT_240-DFLG = 'X'.
        MODIFY GT_240 INDEX LW_INDEX
                     TRANSPORTING DFLG AENAM AEDAT AEZET.
      ENDIF.
    ELSE.
      READ TABLE GT_240 WITH KEY RCEPNO  = GV_RCEPNO
                                 ZMATSEQ = GT_240_TC-ZMATSEQ
                                 ZBADSEQ = GT_240_TC-ZBADSEQ
                                 ZCAUSEQ = GT_240_TC-ZCAUSEQ.
      IF SY-SUBRC = 0.
        LW_INDEX = SY-TABIX.
        DELETE GT_240  INDEX LW_INDEX.
      ENDIF.

      DELETE GT_240_TC  INDEX LV_INDEX.

      SORT GT_240_TC BY ZMATSEQ ZBADSEQ ZCAUSEQ.

      LOOP AT GT_240_TC.
        GT_240_TC-ZCAUSEQ = SY-TABIX.
        MODIFY GT_240_TC.
      ENDLOOP.

      SORT GT_240 BY ZMATSEQ ZBADSEQ ZCAUSEQ.

      LOOP AT GT_240 WHERE RCEPNO = GV_RCEPNO
                       AND ZMATSEQ = GT_240_TC-ZMATSEQ
                       AND ZBADSEQ = GT_240_TC-ZBADSEQ.
        GT_240-ZCAUSEQ = SY-TABIX.
        MODIFY GT_240.
      ENDLOOP.

    ENDIF.

  ELSE.
    MESSAGE S001 WITH '삭제할 데이타를 선택하십시오.' DISPLAY LIKE 'E'.
    EXIT.
  ENDIF.

ENDFORM.                    " GET_TC_DELETE_1130
*&---------------------------------------------------------------------*
*&      Form  GET_TC_DEL_CANC_1130
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM GET_TC_DEL_CANC_1130 .
* local variable
  DATA : LV_INDEX TYPE SY-TABIX,
         LW_INDEX TYPE SY-TABIX.

  CLEAR : LV_INDEX, LW_INDEX.

* 라디오 버튼이 체크된 항목을 읽어온다.
  CLEAR: GT_240_TC.
  READ TABLE GT_240_TC WITH KEY MARK = 'X'.
  IF SY-SUBRC = 0.
    LV_INDEX = SY-TABIX.

    %%POPUP_TO_CONFIRM_STEP '삭제된 원인 정보를 복원하시겠습니까?'
                            ' '  '삭제취소'.
    CHECK GV_ANSWER = 'J'.

* 원인정보 삭제복원
    IF GT_240_TC-DFLG <> 'X'.
      MESSAGE S001 WITH '삭제된 데이타가 아닙니다.' DISPLAY LIKE 'E'.
      EXIT.
    ELSE.
      GT_240_TC-DFLG = ''.
    ENDIF.

    PERFORM TRANS_DATA_UPDAT USING 'ZQMT0012C'.

    MODIFY GT_240_TC INDEX LV_INDEX
                  TRANSPORTING DFLG AENAM AEDAT AEZET.

    READ TABLE GT_240 WITH KEY RCEPNO  = GV_RCEPNO
                               ZMATSEQ = GT_240_TC-ZMATSEQ
                               ZBADSEQ = GT_240_TC-ZBADSEQ
                               ZCAUSEQ = GT_240_TC-ZCAUSEQ.
    IF SY-SUBRC = 0.
      LW_INDEX = SY-TABIX.
      GT_240-DFLG = ' '.
      MODIFY GT_240 INDEX LW_INDEX.
    ENDIF.

  ELSE.
    MESSAGE S001 WITH '복원할 데이타를 선택하십시오.' DISPLAY LIKE 'E'.
    EXIT.
  ENDIF.

ENDFORM.                    " GET_TC_DEL_CANC_1130
*&---------------------------------------------------------------------*
*&      Form  CHECK_EMAIL1
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_GV_FLG  text
*----------------------------------------------------------------------*
FORM CHECK_EMAIL1  CHANGING P_FLG.

  CLEAR: GV_ADDRESS.

***  E-MAIL 정보체크
  SELECT SINGLE USRID
   INTO GV_ADDRESS
   FROM ZPA0105
   WHERE PERNR EQ GS_100-JGNAMNR
     AND ENDDA >= SY-DATUM
     AND SUBTY EQ '0007'.
  IF SY-SUBRC <> 0 OR GS_100-JGNAMNR = '' OR GS_100-JGNAM = ''.
    P_FLG = 'X'.      "에러
    MESSAGE S002 WITH '승인자 정보가 부정확하여'
                      '종료승인을 요청할 수 없습니다.'
                      DISPLAY LIKE 'E'.
  ELSE.
    P_FLG = ' '.      "정상
  ENDIF.


ENDFORM.                    " CHECK_EMAIL1
*&---------------------------------------------------------------------*
*&      Form  CHECK_DATA1
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_GV_FLG  text
*----------------------------------------------------------------------*
FORM CHECK_DATA1  CHANGING P_FLG.

  READ TABLE GT_100 WITH KEY KZLOESCH = ' '
                             KWMENG = ' '.
  IF SY-SUBRC = 0.
    P_FLG = 'X'.      "에러
    MESSAGE S004 WITH '불만확정수량을 입력하십시오.' DISPLAY LIKE 'E'.
  ELSE.
    READ TABLE GT_140 WITH KEY STATUS = '1'.
    IF SY-SUBRC = 0.
      P_FLG = 'X'.      "에러
      MESSAGE S002 WITH '미결된 반품/출고오더 '
                        '존재하여 종료할 수 없습니다.'
                         DISPLAY LIKE 'E'.
    ELSE.
      READ TABLE GT_200 WITH KEY STATUS = '1'.
      IF SY-SUBRC = 0.
        P_FLG = 'X'.      "에러
        MESSAGE S002 WITH '미결된 반품검사로트가'
                          '존재하여 종료할 수 없습니다.'
                           DISPLAY LIKE 'E'.
*      ELSEIF GV_ZQM5 = ' '.
      ELSEIF G_LINES5_N[] IS INITIAL.
        GV_MAIL = 'X'.
        %%POPUP_TO_CONFIRM_STEP '재발방지 정보가 없습니다.'
                                '그래도 종료승인을 요청하시겠습니까?'
                                '종료승인요청'.
        IF GV_ANSWER = 'J'.

          GS_100-STATUS = 'CL40'.
          PERFORM SAVE_COMPLAIN_DATA USING 'X'.
          PERFORM GET_COMPLAIN_DATA.

          PERFORM BUILD_MAIL_DATA1 CHANGING GV_FLG.

*          GV_MAIL = 'X'.
*
*        ELSE.
*          CLEAR GV_MAIL.
*          EXIT.
        ENDIF.

      ELSE.
        P_FLG = ' '.      "정상
      ENDIF.
    ENDIF.
  ENDIF.

ENDFORM.                    " CHECK_DATA1
*&---------------------------------------------------------------------*
*&      Form  BUILD_MAIL_DATA1
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_GV_FLG  text
*----------------------------------------------------------------------*
FORM BUILD_MAIL_DATA1  CHANGING P_FLG.

  DATA: LS_MSG  TYPE SO_TEXT255,
        LS_MSG1 TYPE SO_TEXT255,
        LS_MSG2 TYPE SO_TEXT255,
        LS_MSG3 TYPE SO_TEXT255,
        LS_MSG4 TYPE SO_TEXT255,
        LS_MSG5 TYPE SO_TEXT255,
        LS_MSG6 TYPE SO_TEXT255,
        LS_LONG TYPE SO_TEXT255,
        LS_MSG7 TYPE SO_TEXT255.


  DATA: LV_INDEX  TYPE I.
  DATA: LV_NAME   LIKE ZZPA0001-ENAME.
  DATA: LV_TTEXT  LIKE TSTCT-TTEXT.
  DATA: LV_MATNR     LIKE ZQMT0011M-MATNR,
        LV_RCEPNO    LIKE ZQMT0011H-RCEPNO,
        LV_KUNUM     LIKE ZQMT0011H-KUNUM,
        LV_ERDAT(10).

  CLEAR: GT_MESSAGE, LV_NAME,   LS_MSG ,    LS_MSG1,   LS_MSG2,
         LS_MSG3,    LS_MSG4,   LS_MSG5,    LS_MSG6,   LV_INDEX,
         LV_TTEXT,   LV_MATNR,  GV_SUBJECT, LS_LONG,   LV_RCEPNO,
         LS_MSG7,    LV_KUNUM,  LV_ERDAT.
  REFRESH: GT_MESSAGE.


*__접수번호
  %%ALPHA_CONV_OUT  GV_RCEPNO  LV_RCEPNO.

*__고객번호
  %%ALPHA_CONV_OUT  GS_100-KUNUM  LV_KUNUM.

*__접수일
  WRITE GS_100-RCEPDT TO LV_ERDAT.

*__ 코디네이터
  SELECT SINGLE ENAME
   INTO LV_NAME
   FROM ZZPA0001
   WHERE PERNR EQ GS_100-CORDINR
     AND ENDDA >= SY-DATUM.

*__T-CODE 내역
  LV_TTEXT = '고객불만관리'.



  CONCATENATE '[Frm.' LV_NAME ']' '고객불만' LV_RCEPNO '번 종료승인요청'
            INTO GV_SUBJECT." SEPARATED BY SPACE.


  CONCATENATE
     '.' '&nbsp' '고 객 불 만 : ' '&nbsp' INTO LS_MSG1.
  CONCATENATE LS_MSG1
       LV_RCEPNO '번' '<br>'
                INTO LS_MSG1 SEPARATED BY SPACE.

  CONCATENATE
     '.'   '&nbsp'
     '접'  '&nbsp' '&nbsp' '&nbsp'
     '수'  '&nbsp' '&nbsp' '&nbsp'
     '일'  '&nbsp'
     ':'   '&nbsp' INTO LS_MSG7.
  CONCATENATE
  LS_MSG7 LV_ERDAT '<br>'
                   INTO LS_MSG7 SEPARATED BY SPACE.

  CONCATENATE
     '.'   '&nbsp'
     '고' '&nbsp' '&nbsp' '&nbsp' '&nbsp' '&nbsp' '&nbsp' '&nbsp'
     '&nbsp' '&nbsp'
     '객' '&nbsp'
     ':'  '&nbsp' INTO LS_MSG2.
  CONCATENATE
      LS_MSG2 GS_100-KUNUMT '(' LV_KUNUM ')' '<br>'
                INTO LS_MSG2 SEPARATED BY SPACE.

  CONCATENATE
     '.'   '&nbsp'
     '코'
     '디'
     '네'
     '이'
     '터' '&nbsp'
     ':'  '&nbsp' INTO LS_MSG3.
  CONCATENATE
  LS_MSG3  GS_100-CORDINRT '(' GS_100-CORDINR ')' '<br>'
                INTO LS_MSG3 SEPARATED BY SPACE.

*  CONCATENATE
*     '.'   '&nbsp' '주    제:' GS_100-QMTXT '<p>'
*                INTO LS_MSG4 SEPARATED BY SPACE.
  CONCATENATE
     '.' '&nbsp'
     '주' '&nbsp' '&nbsp' '&nbsp' '&nbsp' '&nbsp' '&nbsp' '&nbsp'
     '&nbsp' '&nbsp'
     '제' '&nbsp'
     ':'  '&nbsp' INTO LS_MSG4.



  CONCATENATE
    LS_MSG4 GS_100-QMTXT '<p>'
                INTO LS_MSG4 SEPARATED BY SPACE.

  CONCATENATE
     '* T-CODE :' '&nbsp' INTO LS_MSG5.

*->[가온전선]--------------------CHG S
  CONCATENATE
    LS_MSG5  'ZGTSDR1250' '(' LV_TTEXT ')' '<br>'
                INTO LS_MSG5 SEPARATED BY SPACE.
*  CONCATENATE
*    LS_MSG5  'ZQM2R0696' '(' LV_TTEXT ')' '<br>'
*                INTO LS_MSG5 SEPARATED BY SPACE.
*-<[가온전선]--------------------CHG E



  MAIL_MSG: '<html>',
            '<body>',
            TEXT-007,
            TEXT-008,
            LS_MSG5,
            TEXT-009,
            TEXT-010,
            LS_MSG1,
            LS_MSG7,
            LS_MSG2,
            LS_MSG3,
            LS_MSG4,
            '불만내용:<br>',
*            '끝.<br>',
            '</body>',
            '</html>'.


  LOOP AT G_LINES1_O.
    CONCATENATE G_LINES1_O-TDLINE '<br>'
                  INTO LS_LONG SEPARATED BY SPACE.
    APPEND LS_LONG TO GT_MESSAGE.
    CLEAR LS_LONG.
  ENDLOOP.


  MAIL_MSG: '<html>',
            '<body>',
            '<p>',
            '고객요구사항 :<br>',
            '</body>',
            '</html>'.


  LOOP AT G_LINES2_O.
    CONCATENATE G_LINES2_O-TDLINE '<br>'
                  INTO LS_LONG SEPARATED BY SPACE.
    APPEND LS_LONG TO GT_MESSAGE.
    CLEAR LS_LONG.
  ENDLOOP.


  MAIL_MSG: '<html>',
            '<body>',
            '<p>',
            '처리결과 :<br>',
            '</body>',
            '</html>'.


  LOOP AT G_LINES6_O.
    CONCATENATE G_LINES6_O-TDLINE '<br>'
                  INTO LS_LONG SEPARATED BY SPACE.
    APPEND LS_LONG TO GT_MESSAGE.
    CLEAR LS_LONG.
  ENDLOOP.

  MAIL_MSG: '<html>',
            '<body>',
            '<p>',
            '끝.<br>',
            '</body>',
            '</html>'.


* EMAIL 내용 전송
  PERFORM SEND_MAIL1 USING GV_FLAG.

ENDFORM.                    " BUILD_MAIL_DATA1
*&---------------------------------------------------------------------*
*&      Form  SEND_MAIL1
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GV_FLAG  text
*----------------------------------------------------------------------*
FORM SEND_MAIL1  USING    P_FLAG.

  DATA RESULT_TAB TYPE MATCH_RESULT_TAB.

  TRY.
      G_EMAIL = CL_BCS=>CREATE_PERSISTENT( ).

      G_EMAIL_BODY = CL_DOCUMENT_BCS=>CREATE_DOCUMENT(
                      I_TYPE    = 'HTM'
                      I_TEXT    = GT_MESSAGE
                      I_SUBJECT = GV_SUBJECT ).

*     첨부
*      PERFORM add_attachment USING g_email_body.

      G_EMAIL->SET_DOCUMENT( G_EMAIL_BODY ).

      G_RECEIVER =
      CL_CAM_ADDRESS_BCS=>CREATE_INTERNET_ADDRESS( GV_ADDRESS ).

      G_EMAIL->ADD_RECIPIENT( I_RECIPIENT = G_RECEIVER
                              I_EXPRESS   = 'X' ).

      G_EMAIL->SET_SEND_IMMEDIATELY( 'X' ).

      G_EMAIL->SEND( EXPORTING I_WITH_ERROR_SCREEN = 'X'
                     RECEIVING RESULT              = GV_SEND_RESULT ).

      G_LINES6_N-TDFORMAT = '>X'.

      CALL FUNCTION 'TEXT_CREATE_HISTORY_LINE'
        IMPORTING
          HISTORY_LINE = G_LINES6_N-TDLINE.

      G_LINES6_N-TDLINE(1) = '>'.

      APPEND G_LINES6_N.

      G_LINES6_N-TDFORMAT = '*'.
      G_LINES6_N-TDLINE   = '고객불만 종료승인 요청'.
      APPEND G_LINES6_N.

      MESSAGE S001 WITH '고객불만 종료승인이 요청되었습니다.'.
      COMMIT WORK.

    CATCH CX_BCS INTO G_EXCEPTION.
      P_FLAG = 'X'.
      MESSAGE S001 DISPLAY LIKE 'E'
         WITH '메일전송에 실패하였습니다.'.
  ENDTRY.

ENDFORM.                    " SEND_MAIL1
*&---------------------------------------------------------------------*
*&      Form  F4_CONET_S1210
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM F4_CONET_S1210 .
  DATA: L_FIELD(20),
        L_LINO      LIKE  SY-INDEX     VALUE 0,
        L_HLINO     LIKE  SY-INDEX     VALUE 0,
        L_MODE      TYPE  C,
        L_MESSAGE   LIKE  SY-MSGNO     VALUE ' ',
        L_MESID     LIKE  SY-MSGID     VALUE ' ',
        L_CDGRP     LIKE  QMFE-FEGRP,
        L_CODE      LIKE  QMFE-FECOD,
        L_DISP      TYPE  C.
*

  GET    CURSOR  LINE L_LINO  FIELD L_FIELD.
  L_LINO     =  1.
  L_HLINO    =  0.

  PERFORM CALL_CODE_SELEKTION_F40  USING   L_DISP
                                           'Q'       "귀책카타로그
                                           'SELEKTION_BEARBEITEN_F432'
                                           L_CDGRP
                                           L_CODE
                                           L_LINO
                                           L_MODE
                                           L_MESID
                                           L_MESSAGE .

  IF  NOT L_MESSAGE  IS INITIAL.
    MESSAGE ID L_MESID TYPE 'I' NUMBER L_MESSAGE WITH L_CDGRP L_CODE.
    EXIT.
  ENDIF.
ENDFORM.                    " F4_CONET_S1210
*&---------------------------------------------------------------------*
*&      Form  CALL_CODE_SELEKTION_F40
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_L_DISP  text
*      -->P_1585   text
*      -->P_1586   text
*      -->P_L_CDGRP  text
*      -->P_L_CODE  text
*      -->P_L_LINO  text
*      -->P_L_MODE  text
*      -->P_L_MESID  text
*      -->P_L_MESSAGE  text
*----------------------------------------------------------------------*
FORM CALL_CODE_SELEKTION_F40  USING      P_DISP     TYPE C
                           VALUE(P_KATART)
                           VALUE(P_FORM)
                           CDGRP      LIKE QMFE-FEGRP
                           CODE       LIKE QMFE-FECOD
                           ICODEINDEX LIKE SY-INDEX
                           L_MODE     TYPE CLIKE
                           P_MES_ID   LIKE SY-MSGID
                           P_MESSAGE  LIKE SY-MSGNO .

  DATA: L_KATART        LIKE  QKAT-KATALOGART .
  DATA: L_PICK      VALUE ' ',
        L_RETN      VALUE ' ',
        L_CODE      LIKE  VIQMFE-FECOD     VALUE ' ',
        L_FIELD(20) VALUE ' '.

  DATA: BEGIN OF LT_CODEGRPTAB OCCURS 0.
          INCLUDE STRUCTURE QPK1CODEGRP.
  DATA: END   OF LT_CODEGRPTAB.

  DATA: BEGIN OF LT_IQPK1CD OCCURS 10.
          INCLUDE STRUCTURE QPK1CD.
  DATA: END   OF LT_IQPK1CD.
*


  L_KATART = P_KATART.

  L_PICK    =  'X'.

  IF  L_MODE  =  'X'.
    L_RETN  =  'X'.
  ENDIF.

  CLEAR: L_FIELD.
  GET    CURSOR  FIELD L_FIELD.

  IF CDGRP IS INITIAL.
    CLEAR   LT_CODEGRPTAB.
    REFRESH LT_CODEGRPTAB.
    LT_CODEGRPTAB-CODEGRUPPE  =  '*'.
    APPEND  LT_CODEGRPTAB.

  ELSE.
    CLEAR   LT_CODEGRPTAB.
    REFRESH LT_CODEGRPTAB.

  ENDIF.

  IF CODE  IS INITIAL.
    L_CODE  = '*'.
  ELSE.
    L_CODE  = CODE.
  ENDIF.

  CALL FUNCTION 'QPK1_GP_CODE_SELECTION'
    EXPORTING
      I_KATALOGART           = L_KATART
      I_CODEGRUPPE           = CDGRP
      I_CODE                 = L_CODE
      I_SPRACHE              = SY-LANGU
      I_PICKUP_MODE          = L_PICK
      I_DISPLAY_MODE         = P_DISP
      I_RETURN_IF_ONE        = L_RETN
    TABLES
      T_QPK1CDTAB            = LT_IQPK1CD
      T_CODEGRPTAB           = LT_CODEGRPTAB
    EXCEPTIONS
      NO_MATCH_IN_RANGE      = 01
      NO_USER_SELECTION      = 02
      NO_AUTHORIZATION       = 03
      NO_SELECTION_SPECIFIED = 04
      OBJECT_LOCKED          = 05
      LOCK_ERROR             = 06
      OBJECT_MISSING         = 07.

  CASE SY-SUBRC.
    WHEN 0.
      CLEAR: P_MESSAGE.
      DESCRIBE    TABLE  LT_IQPK1CD  LINES SY-TFILL.
      CHECK SY-TFILL > 0.

      LOOP AT LT_IQPK1CD WHERE CODE IS INITIAL.
        CLEAR: LT_IQPK1CD-KURZTEXTCD.
        MODIFY LT_IQPK1CD.
      ENDLOOP.
      CASE  L_KATART.
        WHEN  '9'.
          PERFORM (P_FORM) IN PROGRAM (SY-REPID) USING LT_IQPK1CD[]
                                                       L_MODE
                                                       'P' ICODEINDEX.
        WHEN  'E'.
          PERFORM (P_FORM) IN PROGRAM (SY-REPID) USING LT_IQPK1CD[]
                                                       L_MODE
                                                       'P' ICODEINDEX.
        WHEN  'Q'.
*          IF g_val = '1'.
          PERFORM (P_FORM) IN PROGRAM (SY-REPID)
                           USING LT_IQPK1CD[]
                                 L_MODE
                                 'P' ICODEINDEX.
*          ELSE.
*            READ TABLE lt_iqpk1cd INDEX 1.
*            s_103-conet2  = lt_iqpk1cd-code.
*            s_103-conett2 = lt_iqpk1cd-kurztextcd.
*          ENDIF.
        WHEN  '5'.
          PERFORM (P_FORM) IN PROGRAM (SY-REPID) USING LT_IQPK1CD[]
                                                       L_MODE
                                                       'P' ICODEINDEX.
        WHEN  '2'.            "직무
          PERFORM (P_FORM) IN PROGRAM (SY-REPID) USING LT_IQPK1CD[]
                                                       L_MODE
                                                       'P' ICODEINDEX.
      ENDCASE.

    WHEN 1.
      IF  L_MODE  NE  'X'.
        MOVE    103     TO  P_MESSAGE.
        MOVE    'IM'    TO  P_MES_ID.
        MOVE    L_CODE  TO  CODE.
      ELSE.
        MESSAGE  E004  WITH  '선택기준 ' CDGRP L_CODE
                             '에 대한 엔트리가 없습니다.'.
      ENDIF.

    WHEN 2.
      REFRESH: LT_IQPK1CD.

    WHEN 3.
      IF  L_MODE  NE  'X'.
        MOVE    291   TO  P_MESSAGE.
        MOVE    'QS'  TO  P_MES_ID.
      ELSE.
        MESSAGE  E291(QS).
      ENDIF.

    WHEN 4.
      IF  L_MODE  NE  'X'.
        MOVE    343   TO  P_MESSAGE.
        MOVE    'QS'  TO  P_MES_ID.
      ELSE.
        MESSAGE  E343(QS).
      ENDIF.

    WHEN 5.
      IF  L_MODE  NE  'X'.
        MOVE    100   TO  P_MESSAGE.
        MOVE    'Q0'  TO  P_MES_ID.
      ELSE.
        MESSAGE  E100(Q0).
      ENDIF.

    WHEN 6.
      IF  L_MODE  NE  'X'.
        MOVE    101   TO  P_MESSAGE.
        MOVE    'Q0'  TO  P_MES_ID.
      ELSE.
        MESSAGE  E101(Q0).
      ENDIF.

    WHEN 7.
      IF  L_MODE  NE  'X'.
        MOVE    267   TO  P_MESSAGE.
        MOVE    'QS'  TO  P_MES_ID.
      ELSE.
        MESSAGE  E267(QS).
      ENDIF.

  ENDCASE.

ENDFORM.                    " CALL_CODE_SELEKTION_F40
*&---------------------------------------------------------------------*
*&      Form  F4_RESPT_1210
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM F4_RESPT_1210 .

  DATA: L_SUBRC      LIKE  SY-SUBRC,
        L_PARNR      LIKE  IHPA-PARNR,
        L_PARNRT(40),
        L_RETURN     TYPE  I.
*

  CLEAR: SCR_FIELDS.
  REFRESH: SCR_FIELDS.
  SCR_FIELDS-FIELDNAME = 'GS_100-RESPT'.
  APPEND SCR_FIELDS.

  PERFORM  DYNP_VALUES_READ   TABLES    SCR_FIELDS
                              USING     SY-REPID
                                        SY-DYNNR
                              CHANGING  L_SUBRC.

  READ  TABLE SCR_FIELDS  INDEX 1.
  CHECK NOT SCR_FIELDS-FIELDINP IS INITIAL.
  SET LOCALE LANGUAGE SY-LANGU.
  TRANSLATE SCR_FIELDS-FIELDVALUE TO UPPER CASE.
  L_PARNR = SCR_FIELDS-FIELDVALUE.

  PERFORM F4_PARNR_F00  USING  L_PARNR.

  CHECK NOT L_PARNR IS INITIAL.
  READ  TABLE SCR_FIELDS  INDEX 1.
  SCR_FIELDS-FIELDVALUE = L_PARNR.
  MODIFY  SCR_FIELDS INDEX 1.

  PERFORM  DYNP_VALUES_UPDATE   TABLES  SCR_FIELDS
                                CHANGING  L_RETURN.


  CALL FUNCTION 'SAPGUI_SET_FUNCTIONCODE'
    EXPORTING
      FUNCTIONCODE           = 'ENTE'
    EXCEPTIONS
      FUNCTION_NOT_SUPPORTED = 1
      OTHERS                 = 2.

ENDFORM.                    " F4_RESPT_1210
*&---------------------------------------------------------------------*
*&      Form  DYNP_VALUES_READ
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_SCR_FIELDS  text
*      -->P_SY_REPID  text
*      -->P_SY_DYNNR  text
*      <--P_L_SUBRC  text
*----------------------------------------------------------------------*
FORM DYNP_VALUES_READ  TABLES   P_SCR_FIELDS STRUCTURE SCR_FIELDS
                      USING    P_REPID      LIKE  SY-REPID
                               P_DYNNR      LIKE  SY-DYNNR
                      CHANGING P_SUBRC      LIKE  SY-SUBRC.

  CALL FUNCTION 'DYNP_VALUES_READ'
    EXPORTING
      DYNAME               = P_REPID   "sy-cprog
      DYNUMB               = P_DYNNR
      TRANSLATE_TO_UPPER   = 'X'
    TABLES
      DYNPFIELDS           = P_SCR_FIELDS
    EXCEPTIONS
      INVALID_ABAPWORKAREA = 01
      INVALID_DYNPROFIELD  = 02
      INVALID_DYNPRONAME   = 03
      INVALID_DYNPRONUMMER = 04
      INVALID_REQUEST      = 05
      NO_FIELDDESCRIPTION  = 06
      UNDEFIND_ERROR       = 07.

  P_SUBRC    =  SY-SUBRC.

ENDFORM.                    " DYNP_VALUES_READ
*&---------------------------------------------------------------------*
*&      Form  F4_PARNR_F00
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_L_PARNR  text
*----------------------------------------------------------------------*
FORM F4_PARNR_F00  USING   P_PARNR      LIKE IHPA-PARNR.

  DATA: L_PARNR LIKE  IHPA-PARNR,
        L_NRART LIKE  TPAR-NRART  VALUE 'O',
        L_OTYPE LIKE  OBJEC-OTYPE VALUE '  ',
        L_OBJID LIKE  OBJEC-OBJID VALUE '00000000'.

  DATA: L_SHLPNAME   LIKE  DDSHDESCR-SHLPNAME,
        LOC_SHLP_OUT LIKE  DDSHDESCR.
*

  CALL FUNCTION 'F4TOOL_GET_DEF_SHLP'
    EXPORTING
      USER     = SY-UNAME
      TOP_SHLP = 'CS_ORG'
    IMPORTING
      DEF_SHLP = L_SHLPNAME.

  IF L_SHLPNAME IS INITIAL.
    CALL FUNCTION 'F4_SELECT_SEARCH_HELP'
      EXPORTING
        SHLPNAME_IN    = 'CS_ORG'
        STARTING_X     = 5
        STARTING_Y     = 5
      IMPORTING
        SHLP_OUT       = LOC_SHLP_OUT
      EXCEPTIONS
        INVALID_HOTKEY = 1
        INTERNAL_ERROR = 2
        OTHERS         = 3.
    L_SHLPNAME =    LOC_SHLP_OUT-SHLPNAME.
  ENDIF.

  IF NOT L_SHLPNAME = 'CS_ORG_02'.
    CLEAR L_SHLPNAME.
  ENDIF.

  CALL FUNCTION 'SEARCH_OM_PARTNER'
    EXPORTING
      ACT_NRART         = L_NRART
      ACTIVE_PLVAR      = ' '
      SEARCH_STRING     = P_PARNR
      RESTRICTION_OTYPE = L_OTYPE
      RESTRICTION_OBJID = L_OBJID
    IMPORTING
      SEL_PARNR         = L_PARNR
    EXCEPTIONS
      NO_ACTIVE_PLVAR   = 01
      NOT_SELECTED      = 02
      NO_OM_OTYPE       = 03.

  CASE SY-SUBRC.
    WHEN 00.
      IF NOT L_PARNR IS INITIAL AND NOT L_PARNR = '00000000'.
        P_PARNR = L_PARNR.
      ENDIF.
  ENDCASE.

ENDFORM.                    " F4_PARNR_F00
*&---------------------------------------------------------------------*
*&      Form  DYNP_VALUES_UPDATE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_SCR_FIELDS  text
*      <--P_L_RETURN  text
*----------------------------------------------------------------------*
FORM DYNP_VALUES_UPDATE  TABLES   P_SCR_FIELDS STRUCTURE SCR_FIELDS
                        CHANGING P_RETURN.

  CALL FUNCTION 'DYNP_VALUES_UPDATE'
    EXPORTING
      DYNAME               = SY-CPROG
      DYNUMB               = SY-DYNNR
    TABLES
      DYNPFIELDS           = P_SCR_FIELDS
    EXCEPTIONS
      INVALID_ABAPWORKAREA = 1
      INVALID_DYNPROFIELD  = 2
      INVALID_DYNPRONAME   = 3
      INVALID_DYNPRONUMMER = 4
      INVALID_REQUEST      = 5
      NO_FIELDDESCRIPTION  = 6
      UNDEFIND_ERROR       = 7
      OTHERS               = 8.

  P_RETURN    =  SY-SUBRC.

ENDFORM.                    " DYNP_VALUES_UPDATE
*&---------------------------------------------------------------------*
*&      Form  GET_RESPT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM GET_RESPT .


ENDFORM.                    " GET_RESPT
*&---------------------------------------------------------------------*
*&      Form  G_GRID_11_REFRESH
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM G_GRID_11_REFRESH .
  CALL METHOD G_GRID_11->REFRESH_TABLE_DISPLAY
    EXPORTING
      I_SOFT_REFRESH = ' '.

  CALL METHOD CL_GUI_CFW=>FLUSH.
ENDFORM.                    " G_GRID_11_REFRESH
*&---------------------------------------------------------------------*
*&      Form  ENDING_PERMIT_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM ENDING_PERMIT_DATA .
  $$POPUP_TO_CONFIRM_STEP '고객불만 종료를 승인하시겠습니까?'
                          '' '종료승인'.
  CHECK GV_ANSWER = 'J'.

  GS_100-STATUS = 'CL50'.
  GS_100-CMPDT  = SY-DATUM.

  PERFORM SAVE_COMPLAIN_DATA USING 'X'.
  PERFORM GET_COMPLAIN_DATA.

  PERFORM CHECK_EMAIL2 CHANGING GV_FLG.

  CHECK GV_FLG IS INITIAL.

  GV_CHK1 = '1'.

  PERFORM BUILD_MAIL_DATA2 CHANGING GV_FLG.

ENDFORM.                    " ENDING_PERMIT_DATA
*&---------------------------------------------------------------------*
*&      Form  CHECK_EMAIL2
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_GV_FLG  text
*----------------------------------------------------------------------*
FORM CHECK_EMAIL2  CHANGING P_FLG.

  CLEAR: GV_ADDRESS.

***  E-MAIL 정보체크
  SELECT SINGLE USRID
   INTO GV_ADDRESS
   FROM ZPA0105
   WHERE PERNR EQ GS_100-CORDINR
     AND ENDDA >= SY-DATUM
     AND SUBTY EQ '0007'.
  IF SY-SUBRC <> 0 OR GS_100-CORDINR = '' OR GS_100-CORDI = ''.
    P_FLG = 'X'.      "에러
    MESSAGE S001 WITH TEXT-025 DISPLAY LIKE 'E'.
  ELSE.
    P_FLG = ' '.      "정상
  ENDIF.

ENDFORM.                    " CHECK_EMAIL2
*&---------------------------------------------------------------------*
*&      Form  BUILD_MAIL_DATA2
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_GV_FLG  text
*----------------------------------------------------------------------*
FORM BUILD_MAIL_DATA2  CHANGING P_FLG.

  DATA: LS_MSG  TYPE SO_TEXT255,
        LS_MSG1 TYPE SO_TEXT255,
        LS_MSG2 TYPE SO_TEXT255,
        LS_MSG3 TYPE SO_TEXT255,
        LS_MSG4 TYPE SO_TEXT255,
        LS_MSG5 TYPE SO_TEXT255,
        LS_MSG6 TYPE SO_TEXT255,
        LS_MSG7 TYPE SO_TEXT255,
        LS_LONG TYPE SO_TEXT255.


  DATA: LV_INDEX  TYPE I.
  DATA: LV_NAME   LIKE ZZPA0001-ENAME.
  DATA: LV_TTEXT     LIKE TSTCT-TTEXT,
        LV_RCEPNO    LIKE ZQMT0011H-RCEPNO,
        LV_KUNUM     LIKE ZQMT0011H-KUNUM,
        LV_ERDAT(10).

  CLEAR: GT_MESSAGE, LV_NAME,    LS_MSG ,    LS_MSG1,   LS_MSG2,
         LS_MSG3,    LS_MSG4,    LS_MSG5,    LS_MSG6,   LV_INDEX,
         LV_TTEXT,   GV_SUBJECT, LS_LONG,    LV_RCEPNO, LV_KUNUM,
         LV_ERDAT,   LS_MSG7.
  REFRESH: GT_MESSAGE.


*__접수번호
  %%ALPHA_CONV_OUT  GV_RCEPNO  LV_RCEPNO.

*__고객번호
  %%ALPHA_CONV_OUT  GS_100-KUNUM  LV_KUNUM.

*__접수일
  WRITE GS_100-RCEPDT TO LV_ERDAT.

*__처리승인자
  SELECT SINGLE ENAME
   INTO LV_NAME
   FROM ZZPA0001
   WHERE PERNR EQ GS_100-JGNAMNR
     AND ENDDA >= SY-DATUM.

*__T-CODE 내역
  LV_TTEXT = '고객불만관리'.


  IF GV_CHK1 = '1'.
    CONCATENATE '[Frm.' LV_NAME ']' '고객불만' LV_RCEPNO
    '번 종료승인완료'
              INTO GV_SUBJECT." SEPARATED BY SPACE.
  ELSEIF GV_CHK1 = '2'.
    CONCATENATE '[Frm.' LV_NAME ']' '고객불만' LV_RCEPNO
    '번 종료승인반려'
            INTO GV_SUBJECT." SEPARATED BY SPACE.
  ENDIF.


  CONCATENATE
     '.' '&nbsp' '고 객 불 만 : ' '&nbsp' INTO LS_MSG1.
  CONCATENATE LS_MSG1
       LV_RCEPNO '번' '<br>'
                INTO LS_MSG1 SEPARATED BY SPACE.

  CONCATENATE
     '.'   '&nbsp'
     '접'  '&nbsp' '&nbsp' '&nbsp'
     '수'  '&nbsp' '&nbsp' '&nbsp'
     '일'  '&nbsp'
     ':'   '&nbsp' INTO LS_MSG7.
  CONCATENATE
  LS_MSG7 LV_ERDAT '<br>'
                   INTO LS_MSG7 SEPARATED BY SPACE.


  CONCATENATE
     '.'  '&nbsp'
     '고' '&nbsp' '&nbsp' '&nbsp' '&nbsp' '&nbsp' '&nbsp' '&nbsp'
     '&nbsp' '&nbsp'
     '객' '&nbsp'
     ':'  '&nbsp' INTO LS_MSG2.
  CONCATENATE
      LS_MSG2 GS_100-KUNUMT '(' LV_KUNUM ')' '<br>'
                INTO LS_MSG2 SEPARATED BY SPACE.


  CONCATENATE
     '.' '&nbsp'
     '코'
     '디'
     '네'
     '이'
     '터' '&nbsp'
     ':'  '&nbsp' INTO LS_MSG3.
  CONCATENATE
  LS_MSG3  GS_100-CORDINRT '(' GS_100-CORDINR ')' '<br>'
                INTO LS_MSG3 SEPARATED BY SPACE.


  CONCATENATE
     '.' '&nbsp'
     '주' '&nbsp' '&nbsp' '&nbsp' '&nbsp' '&nbsp' '&nbsp' '&nbsp'
     '&nbsp' '&nbsp'
     '제' '&nbsp'
     ':'  '&nbsp' INTO LS_MSG4.
  CONCATENATE
    LS_MSG4 GS_100-QMTXT '<p>'
                INTO LS_MSG4 SEPARATED BY SPACE.


  CONCATENATE
     '* T-CODE :' '&nbsp' INTO LS_MSG5.
*->[가온전선]--------------------CHG S
  CONCATENATE
    LS_MSG5  'ZGTSDR1250' '(' LV_TTEXT ')' '<p>'
                INTO LS_MSG5 SEPARATED BY SPACE.
*  CONCATENATE
*    LS_MSG5  'ZQM2R0696' '(' LV_TTEXT ')' '<p>'
*                INTO LS_MSG5 SEPARATED BY SPACE.
*-<[가온전선]--------------------CHG E

  IF GV_CHK1 = '1'.
    MAIL_MSG: '<html>',
              '<body>',
              TEXT-011,
              LS_MSG5,
              LS_MSG1,
              LS_MSG7,
              LS_MSG2,
              LS_MSG3,
              LS_MSG4,
              '불만내용 :<br>',
*            '끝.<br>',
              '</body>',
              '</html>'.

  ELSEIF GV_CHK1 = '2'.
    MAIL_MSG: '<html>',
              '<body>',
              TEXT-012,
              TEXT-013,
              LS_MSG5,
              LS_MSG1,
              LS_MSG7,
              LS_MSG2,
              LS_MSG3,
              LS_MSG4,
              '불만내용 :<br>',
*            '끝.<br>',
              '</body>',
              '</html>'.
  ENDIF.


  LOOP AT G_LINES1_O.
    CONCATENATE G_LINES1_O-TDLINE '<br>'
                  INTO LS_LONG SEPARATED BY SPACE.
    APPEND LS_LONG TO GT_MESSAGE.
    CLEAR LS_LONG.
  ENDLOOP.


  MAIL_MSG: '<html>',
            '<body>',
            '<p>',
            '고객요구사항 :<br>',
            '</body>',
            '</html>'.


  LOOP AT G_LINES2_O.
    CONCATENATE G_LINES2_O-TDLINE '<br>'
                  INTO LS_LONG SEPARATED BY SPACE.
    APPEND LS_LONG TO GT_MESSAGE.
    CLEAR LS_LONG.
  ENDLOOP.


  MAIL_MSG: '<html>',
            '<body>',
            '<p>',
            '처리결과 :<br>',
            '</body>',
            '</html>'.


  LOOP AT G_LINES6_O.
    CONCATENATE G_LINES6_O-TDLINE '<br>'
                  INTO LS_LONG SEPARATED BY SPACE.
    APPEND LS_LONG TO GT_MESSAGE.
    CLEAR LS_LONG.
  ENDLOOP.

  MAIL_MSG: '<html>',
            '<body>',
            '<p>',
            '끝.<br>',
            '</body>',
            '</html>'.


* EMAIL 내용 전송
  PERFORM SEND_MAIL2 USING P_FLG.

ENDFORM.                    " BUILD_MAIL_DATA2
*&---------------------------------------------------------------------*
*&      Form  SEND_MAIL2
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GV_FLAG  text
*----------------------------------------------------------------------*
FORM SEND_MAIL2  USING    P_FLAG.

  DATA RESULT_TAB TYPE MATCH_RESULT_TAB.

  TRY.
      G_EMAIL = CL_BCS=>CREATE_PERSISTENT( ).

      G_EMAIL_BODY = CL_DOCUMENT_BCS=>CREATE_DOCUMENT(
                      I_TYPE    = 'HTM'
                      I_TEXT    = GT_MESSAGE
                      I_SUBJECT = GV_SUBJECT ).

*     첨부
*      PERFORM add_attachment USING g_email_body.

      G_EMAIL->SET_DOCUMENT( G_EMAIL_BODY ).

      G_RECEIVER =
      CL_CAM_ADDRESS_BCS=>CREATE_INTERNET_ADDRESS( GV_ADDRESS ).

      G_EMAIL->ADD_RECIPIENT( I_RECIPIENT = G_RECEIVER
                              I_EXPRESS   = 'X' ).

      G_EMAIL->SET_SEND_IMMEDIATELY( 'X' ).

      G_EMAIL->SEND( EXPORTING I_WITH_ERROR_SCREEN = 'X'
                     RECEIVING RESULT              = GV_SEND_RESULT ).


      IF GV_CHK1 = '1'.

        G_LINES6_N-TDFORMAT = '>X'.

        CALL FUNCTION 'TEXT_CREATE_HISTORY_LINE'
          IMPORTING
            HISTORY_LINE = G_LINES6_N-TDLINE.

        G_LINES6_N-TDLINE(1) = '>'.
        APPEND G_LINES6_N.

        G_LINES6_N-TDFORMAT = '*'.
        G_LINES6_N-TDLINE   = '고객불만 종료승인 완료'.
        APPEND G_LINES6_N.

        MESSAGE S001 WITH '고객불만 종료 승인이 완료되었습니다.'.

      ELSEIF GV_CHK1 = '2'.

        G_LINES6_N-TDFORMAT = '>X'.

        CALL FUNCTION 'TEXT_CREATE_HISTORY_LINE'
          IMPORTING
            HISTORY_LINE = G_LINES6_N-TDLINE.

        G_LINES6_N-TDLINE(1) = '>'.
        APPEND G_LINES6_N.

        G_LINES6_N-TDFORMAT = '*'.
        G_LINES6_N-TDLINE   = '고객불만 종료승인 반려'.
        APPEND G_LINES6_N.


        MESSAGE S001 WITH '고객불만 종료 승인이 반려되었습니다.'.

      ENDIF.

      COMMIT WORK.

    CATCH CX_BCS INTO G_EXCEPTION.
      P_FLAG = 'X'.
      MESSAGE S001 DISPLAY LIKE 'E'
         WITH '메일전송에 실패하였습니다.'.
  ENDTRY.

  CLEAR GV_CHK1.

ENDFORM.                    " SEND_MAIL2
*&---------------------------------------------------------------------*
*&      Form  ENDING_UNDO_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM ENDING_UNDO_DATA .
  $$POPUP_TO_CONFIRM_STEP '고객불만 종료 승인을 반려하시겠습니까?'
                          '' '종료반려'.
  CHECK GV_ANSWER = 'J'.

  GS_100-STATUS = 'CL30'.
  PERFORM SAVE_COMPLAIN_DATA USING 'X'.
  PERFORM GET_COMPLAIN_DATA.

  PERFORM CHECK_EMAIL2 CHANGING GV_FLG.

  CHECK GV_FLG IS INITIAL.

  GV_CHK1 = '2'.

  PERFORM BUILD_MAIL_DATA2 CHANGING GV_FLG.

ENDFORM.                    " ENDING_UNDO_DATA
*&---------------------------------------------------------------------*
*&      Form  G_GRID_12_REFRESH
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM G_GRID_12_REFRESH .
  CALL METHOD G_GRID_12->REFRESH_TABLE_DISPLAY
    EXPORTING
      I_SOFT_REFRESH = ' '.

  CALL METHOD CL_GUI_CFW=>FLUSH.
ENDFORM.                    " G_GRID_12_REFRESH
*&---------------------------------------------------------------------*
*&      Form  G_GRID_13_REFRESH
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM G_GRID_13_REFRESH .
  CALL METHOD G_GRID_13->REFRESH_TABLE_DISPLAY
    EXPORTING
      I_SOFT_REFRESH = ' '.

  CALL METHOD CL_GUI_CFW=>FLUSH.
ENDFORM.                    " G_GRID_13_REFRESH
*&---------------------------------------------------------------------*
*&      Form  G_GRID_14_REFRESH
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM G_GRID_14_REFRESH .
  CALL METHOD G_GRID_14->REFRESH_TABLE_DISPLAY
    EXPORTING
      I_SOFT_REFRESH = ' '.

  CALL METHOD CL_GUI_CFW=>FLUSH.
ENDFORM.                    " G_GRID_14_REFRESH
*&---------------------------------------------------------------------*
*&      Form  EVENT_HANDLER_REGISTER_250
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM EVENT_HANDLER_REGISTER_250 .
* TOOLBAR 구성은 EVENT에서 한다.
  CREATE OBJECT G_EVENT_HANDLER_12.
*

*-Edit  이벤트 등록
  CALL METHOD G_GRID_12->REGISTER_EDIT_EVENT
    EXPORTING
      I_EVENT_ID = CL_GUI_ALV_GRID=>MC_EVT_MODIFIED.

  CALL METHOD G_GRID_12->REGISTER_EDIT_EVENT
    EXPORTING
      I_EVENT_ID = CL_GUI_ALV_GRID=>MC_EVT_ENTER.

* 툴바지정
*    SET HANDLER g_event_handler_5->handle_toolbar
*                                FOR g_grid_5.
* 툴바에 해당하는 이벤트 지정
*    SET HANDLER g_event_handler_5->handle_user_command
*                                FOR g_grid_5.
* DATA_CHANGED
*  SET HANDLER G_EVENT_HANDLER_12->HANDLE_DATA_CHANGED_15 FOR G_GRID_12.
*  SET HANDLER G_EVENT_HANDLER_12->HANDLE_DATA_CHANGED_FINISHED_1
*                                                  FOR G_GRID_12.
  SET HANDLER G_EVENT_HANDLER_12->HANDLE_HOTSPOT_CLICK_1 FOR G_GRID_12.

ENDFORM.                    " EVENT_HANDLER_REGISTER_250
*&---------------------------------------------------------------------*
*&      Form  HOTSPOT_CLICK_1
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_E_ROW_ID  text
*      -->P_E_COLUMN_ID  text
*----------------------------------------------------------------------*
FORM HOTSPOT_CLICK_1  USING    E_ROW_ID    TYPE LVC_S_ROW
                             E_COLUMN_ID TYPE LVC_S_COL.

  CASE E_COLUMN_ID-FIELDNAME.
    WHEN 'RCEPNO'.
      READ TABLE GT_250 INDEX E_ROW_ID.
      CHECK SY-SUBRC = 0.

      SET PARAMETER ID 'ZRCEPNO_GO' FIELD GT_250-RCEPNO.
      CALL TRANSACTION 'ZGTSDR1232'.
  ENDCASE.

ENDFORM.                    " HOTSPOT_CLICK_1
*&--------------------------------------------------------------------*
*&      Form  SELEKTION_BEARBEITEN_F41
*&--------------------------------------------------------------------*
*       text
*---------------------------------------------------------------------*
FORM SELEKTION_BEARBEITEN_F432 USING P_IQPK1CD
                                    MODE       TYPE CLIKE
                                    STEUER     TYPE CLIKE
                                    ICODEINDEX LIKE SY-INDEX.

  DATA: BEGIN OF LT_IQPK1CD OCCURS 10.
          INCLUDE STRUCTURE QPK1CD.
  DATA: END   OF LT_IQPK1CD.
*

  LT_IQPK1CD[]  =  P_IQPK1CD.

  LOOP AT LT_IQPK1CD.
    GS_100-COGRP2    =  LT_IQPK1CD-CODEGRUPPE.    "코드그룹
    GS_100-CONET2    =  LT_IQPK1CD-CODE.          "코드
*   riwo00-txtfe   =  lt_iqpk1cd-kurztextcd.
*   s_101-cogrpt   =  lt_iqpk1cd-kurztextgr.    "코드그룹 내역
    GS_100-CONETT2   =  LT_IQPK1CD-KURZTEXTCD.    "코드 내역
    GS_100-COKAT2    =  LT_IQPK1CD-KATALOGART.    "카타로그
    GS_100-COVER2    =  LT_IQPK1CD-VERSION.       "버전번호

    PERFORM DYNP_TEXT_YFE_F40
            USING  'GS_100-CONETT2'    GS_100-CONETT2  ICODEINDEX
                   'GS_100-COGRP2'     GS_100-COGRP2       "코드그룹
                   '  '              '  '
                   'GS_100-CONET2'     GS_100-CONET2.      "코드

  ENDLOOP.

  CALL FUNCTION 'SAPGUI_SET_FUNCTIONCODE'
    EXPORTING
      FUNCTIONCODE           = 'ENTE'
    EXCEPTIONS
      FUNCTION_NOT_SUPPORTED = 1
      OTHERS                 = 2.

ENDFORM.                    "SELEKTION_BEARBEITEN_F432
*
*
FORM DYNP_TEXT_YFE_F40 USING    UFIELD UTEXT  UINDEX
                                UFLGRP UFLGVAL
                                UFLTXT UFLTVAL
                                UFLCOD UFLCVAL.
*                               uflfqk uflfval
*                               uflfqt uflftval.   "결함클래스

  DATA: LIND    LIKE SY-INDEX VALUE 0.
  DATA: H_STEPL LIKE SY-STEPL.

  LIND = UINDEX.

*     check call from step-loop
  CALL FUNCTION 'DYNP_GET_STEPL'
    IMPORTING
      POVSTEPL = H_STEPL
    EXCEPTIONS
      OTHERS   = 01.

  IF NOT H_STEPL IS INITIAL.
    IF LIND = 0.
      GET CURSOR LINE LIND .
      CHECK LIND > 0.
    ENDIF.
  ELSE.
    LIND = 0.
  ENDIF.

  FIELD-SYMBOLS <F>.                   " Code
  FIELD-SYMBOLS <S>.                   " Codegruppe
  FIELD-SYMBOLS <T>.                   " Text Codegruppe
  FIELD-SYMBOLS <C>.                   " Code
*  FIELD-SYMBOLS <q>.                   " Fehlerklasse
*  FIELD-SYMBOLS <qt>.                  " Fehlerklassentext
  DATA: BEGIN OF LDYNPREAD OCCURS 0.
          INCLUDE STRUCTURE DYNPREAD.
  DATA: END   OF LDYNPREAD.
  REFRESH LDYNPREAD.

  ASSIGN UFIELD TO <F>.
  ASSIGN UFLGRP TO <S>.
  ASSIGN UFLTXT TO <T>.
  ASSIGN UFLCOD TO <C>.
*  ASSIGN uflfqk TO <q>.
*  ASSIGN uflfqt TO <qt>.

  LDYNPREAD-FIELDNAME = <F>.
  LDYNPREAD-STEPL      = LIND.
  LDYNPREAD-FIELDVALUE = UTEXT.
  APPEND LDYNPREAD.

*    Check for Codegruppe auf dem dynpro                             *
  LOOP AT SCREEN .
    IF SCREEN-NAME = <S>.
*    codegrup
      LDYNPREAD-FIELDNAME = <S>.
      LDYNPREAD-STEPL      = LIND.
      LDYNPREAD-FIELDVALUE = UFLGVAL.
      APPEND LDYNPREAD.

*    codegruptext
      IF  NOT  <T>  IS INITIAL.
        LDYNPREAD-FIELDNAME = <T>.
        LDYNPREAD-STEPL      = LIND.
        LDYNPREAD-FIELDVALUE = UFLTVAL.
        APPEND LDYNPREAD.
      ENDIF.

*    code
      LDYNPREAD-FIELDNAME = <C>.
      LDYNPREAD-STEPL      = LIND.
      LDYNPREAD-FIELDVALUE = UFLCVAL.
      APPEND LDYNPREAD.

***    Fehlerklasse und deren Wert
**      ldynpread-fieldname = <q>.
**      ldynpread-stepl      = lind.
**      ldynpread-fieldvalue = uflfval.
**      APPEND ldynpread.
**
***    Fehlerklassentext
**      ldynpread-fieldname = <qt>.
**      ldynpread-stepl      = lind.
**      ldynpread-fieldvalue = uflftval.
**      APPEND ldynpread.
      EXIT.
    ENDIF.
  ENDLOOP.

*    Unbelegte Feldnamen loeschen                                     *

  LOOP AT LDYNPREAD WHERE FIELDNAME = SPACE.
    DELETE LDYNPREAD.
  ENDLOOP.

*    Dynprofelder versorgen                                           *
  CALL FUNCTION 'DYNP_VALUES_UPDATE'
    EXPORTING
      DYNAME               = SY-REPID
      DYNUMB               = SY-DYNNR
    TABLES
      DYNPFIELDS           = LDYNPREAD
    EXCEPTIONS
      INVALID_ABAPWORKAREA = 01
      INVALID_DYNPROFIELD  = 02
      INVALID_DYNPRONAME   = 03
      INVALID_DYNPRONUMMER = 04
      INVALID_REQUEST      = 05
      NO_FIELDDESCRIPTION  = 06
      UNDEFIND_ERROR       = 07.
  IF SY-SUBRC = 0.
  ENDIF.

ENDFORM.                    " DYNP_TEXT_YFE_F40
*&---------------------------------------------------------------------*
*&      Form  TRANS_DATA_UPDAT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_7714   text
*----------------------------------------------------------------------*
FORM TRANS_DATA_UPDAT  USING    PT_TABLE.

  CASE PT_TABLE.

    WHEN 'ZQMT0011H'.
      PERFORM MODIFY_CHANGE_DATE_S100.


    WHEN 'ZQMT0011M'.
      PERFORM MODIFY_CHANGE_DATE_S100.
      PERFORM MODIFY_CHANGE_DATE_G100.

    WHEN 'ZQMT0012N'.
      PERFORM MODIFY_CHANGE_DATE_S100.
      PERFORM MODIFY_CHANGE_DATE_G100.
      PERFORM MODIFY_CHANGE_DATE_G120.


    WHEN 'ZQMT0012C'.
      PERFORM MODIFY_CHANGE_DATE_S100.
      PERFORM MODIFY_CHANGE_DATE_G100.
      PERFORM MODIFY_CHANGE_DATE_G120.
      PERFORM MODIFY_CHANGE_DATE_G240.

    WHEN 'ZQMT0016F'.
      PERFORM MODIFY_CHANGE_DATE_S100.


    WHEN 'ZQMT0015Q'.
      PERFORM MODIFY_CHANGE_DATE_S100.
      PERFORM MODIFY_CHANGE_DATE_G100.
      PERFORM MODIFY_CHANGE_DATE_G200.

    WHEN 'ZQMT0011B'.
      PERFORM MODIFY_CHANGE_DATE_S100.
      PERFORM MODIFY_CHANGE_DATE_G100.
      PERFORM MODIFY_CHANGE_DATE_G110.

    WHEN 'ZQMT0014S'.
      PERFORM MODIFY_CHANGE_DATE_S100.
      PERFORM MODIFY_CHANGE_DATE_G100.
      PERFORM MODIFY_CHANGE_DATE_G170.

    WHEN 'ZQMT0013C'.


  ENDCASE.

ENDFORM.                    " TRANS_DATA_UPDAT
*&---------------------------------------------------------------------*
*&      Form  MODIFY_CHANGE_DATE_S100
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM MODIFY_CHANGE_DATE_S100 .

  IF GS_100-ERDAT IS INITIAL.
    GS_100-AJAHR   = SY-DATUM(4).
    GS_100-ERDAT   = SY-DATUM.
    GS_100-ERZET   = SY-UZEIT.
    GS_100-ERNAM   = SY-UNAME.
  ELSE.
    GS_100-AENAM = SY-UNAME.
    GS_100-AEDAT = SY-DATUM.
    GS_100-AEZET = SY-UZEIT.
  ENDIF.

ENDFORM.                    " MODIFY_CHANGE_DATE_S100
*&---------------------------------------------------------------------*
*&      Form  MODIFY_CHANGE_DATE_G100
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM MODIFY_CHANGE_DATE_G100 .

  IF GT_100-ERDAT IS INITIAL.
    GT_100-ERDAT   = SY-DATUM.
    GT_100-ERZET   = SY-UZEIT.
    GT_100-ERNAM   = SY-UNAME.
  ELSE.
    GT_100-AENAM = SY-UNAME.
    GT_100-AEDAT = SY-DATUM.
    GT_100-AEZET = SY-UZEIT.
  ENDIF.

ENDFORM.                    " MODIFY_CHANGE_DATE_G100
*&---------------------------------------------------------------------*
*&      Form  MODIFY_CHANGE_DATE_G110
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM MODIFY_CHANGE_DATE_G110 .

  IF GT_110A-ERDAT IS INITIAL.
    GT_110A-ERDAT   = SY-DATUM.
    GT_110A-ERZET   = SY-UZEIT.
    GT_110A-ERNAM   = SY-UNAME.
  ELSE.
    GT_110A-AENAM = SY-UNAME.
    GT_110A-AEDAT = SY-DATUM.
    GT_110A-AEZET = SY-UZEIT.
  ENDIF.

ENDFORM.                    " MODIFY_CHANGE_DATE_G110
*&---------------------------------------------------------------------*
*&      Form  MODIFY_CHANGE_DATE_G120
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM MODIFY_CHANGE_DATE_G120 .

  IF GT_120A-ERDAT IS INITIAL.
    GT_120A-ERDAT   = SY-DATUM.
    GT_120A-ERZET   = SY-UZEIT.
    GT_120A-ERNAM   = SY-UNAME.
  ELSE.
    GT_120A-AENAM = SY-UNAME.
    GT_120A-AEDAT = SY-DATUM.
    GT_120A-AEZET = SY-UZEIT.
  ENDIF.

ENDFORM.                    " MODIFY_CHANGE_DATE_G120
*&---------------------------------------------------------------------*
*&      Form  INSERT_CUSTOM_CLAIM_0500
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM INSERT_CUSTOM_CLAIM_0500 .

* local variable
  DATA: LS_ZQMT0014S TYPE ZQMT0014S,   "영업문서
        LT_ZQMT0014S LIKE TABLE OF LS_ZQMT0014S.


* 저장할 데이터 없으면 skip
  CHECK NOT GT_140[] IS INITIAL.

* 영업문서 처리
  CLEAR: GT_140, LS_ZQMT0014S, LT_ZQMT0014S.

  LOOP AT GT_140.
    PERFORM TRANS_DATA_UPDAT USING 'ZQMT0014S'.

    MOVE-CORRESPONDING GT_140 TO LS_ZQMT0014S.

    APPEND LS_ZQMT0014S TO LT_ZQMT0014S.
    CLEAR: GT_140, LS_ZQMT0014S.
  ENDLOOP.

  MODIFY ZQMT0014S FROM TABLE LT_ZQMT0014S.
  IF SY-SUBRC = 0.
    CLEAR: GT_170_OLD[].
    GT_170_OLD[] = GT_170[].
    GV_SAVE_Y = 'X'.
  ELSE.
    CLEAR GV_SAVE_Y.
    ROLLBACK WORK.
  ENDIF.

ENDFORM.                    " INSERT_CUSTOM_CLAIM_0500
*&---------------------------------------------------------------------*
*&      Form  MODIFY_CHANGE_DATE_G170
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM MODIFY_CHANGE_DATE_G170 .

  IF GT_170-ERDAT IS INITIAL.
    GT_170-ERDAT   = SY-DATUM.
    GT_170-ERZET   = SY-UZEIT.
    GT_170-ERNAM   = SY-UNAME.
  ELSE.
    GT_170-AENAM = SY-UNAME.
    GT_170-AEDAT = SY-DATUM.
    GT_170-AEZET = SY-UZEIT.
  ENDIF.

ENDFORM.                    " MODIFY_CHANGE_DATE_G170
*&---------------------------------------------------------------------*
*&      Form  INSERT_CUSTOM_CLAIM_0600
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM INSERT_CUSTOM_CLAIM_0600 .

* local variable
  DATA: LS_ZQMT0015Q TYPE ZQMT0015Q,   "반품검사로트
        LT_ZQMT0015Q LIKE TABLE OF LS_ZQMT0015Q.


* 저장할 데이터 없으면 skip
  CHECK NOT GT_200[] IS INITIAL.

* 영업문서 처리
  CLEAR: GT_200, LS_ZQMT0015Q, LT_ZQMT0015Q.

  LOOP AT GT_200.
    PERFORM TRANS_DATA_UPDAT USING 'ZQMT0015Q'.

    MOVE-CORRESPONDING GT_200 TO LS_ZQMT0015Q.

    APPEND LS_ZQMT0015Q TO LT_ZQMT0015Q.
    CLEAR: GT_200, LS_ZQMT0015Q.
  ENDLOOP.

  MODIFY ZQMT0015Q FROM TABLE LT_ZQMT0015Q.
  IF SY-SUBRC = 0.
    CLEAR: GT_200_OLD[].
    GT_200_OLD[] = GT_200[].
    GV_SAVE_Y = 'X'.
  ELSE.
    CLEAR GV_SAVE_Y.
    ROLLBACK WORK.
  ENDIF.


ENDFORM.                    " INSERT_CUSTOM_CLAIM_0600
*&---------------------------------------------------------------------*
*&      Form  MODIFY_CHANGE_DATE_G200
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM MODIFY_CHANGE_DATE_G200 .

  IF GT_200-ERDAT IS INITIAL.
    GT_200-ERDAT   = SY-DATUM.
    GT_200-ERZET   = SY-UZEIT.
    GT_200-ERNAM   = SY-UNAME.
  ELSE.
    GT_200-AENAM = SY-UNAME.
    GT_200-AEDAT = SY-DATUM.
    GT_200-AEZET = SY-UZEIT.
  ENDIF.

ENDFORM.                    " MODIFY_CHANGE_DATE_G200
*&---------------------------------------------------------------------*
*&      Form  INSERT_CUSTOM_CLAIM_1100
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM INSERT_CUSTOM_CLAIM_1100 .
* local variable
  DATA : LS_ZQMT0012C TYPE ZQMT0012C,   "반품검사로트
         LT_ZQMT0012C LIKE TABLE OF LS_ZQMT0012C.
  DATA : LV_INDEX LIKE SY-TABIX.

  CLEAR   : GT_240_TC, LV_INDEX.
  REFRESH : GT_240_TC.

* 저장할 데이터 없으면 skip
  CHECK NOT GT_240[] IS INITIAL.

  LOOP AT GT_240 WHERE FTGRP = SPACE
                    OR FLTTP = SPACE.
    MESSAGE E001 WITH '원인그룹/코드를 입력하십시오.'.
  ENDLOOP.

* 영업문서 처리
  CLEAR: LS_ZQMT0012C, LT_ZQMT0012C.

  LOOP AT GT_240.

    PERFORM TRANS_DATA_UPDAT USING 'ZQMT0012C'.
    LV_INDEX = SY-TABIX.
    MODIFY GT_240 INDEX LV_INDEX.

    CLEAR: LS_ZQMT0012C.

    GT_240-FTKAT = '5'.
    GT_240-FLVER = '000001'.

    MOVE-CORRESPONDING GT_240 TO LS_ZQMT0012C.

    APPEND LS_ZQMT0012C TO LT_ZQMT0012C.
  ENDLOOP.

  MODIFY ZQMT0012C FROM TABLE LT_ZQMT0012C.
  IF SY-SUBRC = 0.
    CLEAR: GT_240_OLD[].
    GT_240_OLD[] = GT_240[].

    READ TABLE GT_230 WITH KEY MARK = 'X'.
    IF SY-SUBRC = 0.
      LOOP AT GT_240 WHERE RCEPNO = GV_RCEPNO
                       AND ZMATSEQ = GT_230-ZMATSEQ
                       AND ZBADSEQ = GT_230-ZBADSEQ.
        CLEAR GT_240_TC.
        MOVE-CORRESPONDING GT_240 TO GT_240_TC.
        APPEND GT_240_TC.
      ENDLOOP.
    ENDIF.

    GV_SAVE_Y = 'X'.
  ELSE.
    CLEAR GV_SAVE_Y.
    ROLLBACK WORK.
  ENDIF.


ENDFORM.                    " INSERT_CUSTOM_CLAIM_1100
*&---------------------------------------------------------------------*
*&      Form  MODIFY_CHANGE_DATE_G240
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM MODIFY_CHANGE_DATE_G240 .

  IF GT_240-ERDAT IS INITIAL.
    GT_240-ERDAT   = SY-DATUM.
    GT_240-ERZET   = SY-UZEIT.
    GT_240-ERNAM   = SY-UNAME.
  ELSE.
    GT_240-AENAM = SY-UNAME.
    GT_240-AEDAT = SY-DATUM.
    GT_240-AEZET = SY-UZEIT.
  ENDIF.

ENDFORM.                    " MODIFY_CHANGE_DATE_G240
*&---------------------------------------------------------------------*
*&      Form  UPDATE_0014S
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GV_RFUND  text
*----------------------------------------------------------------------*
FORM UPDATE_0014S  USING    P_RFUND.
  DATA : L_IDX     TYPE I,
         L_RCEPNO  TYPE ZRCEPNO,
         L_WERKS_M LIKE ZPPTIF31-WERKS.

  DELETE GT_140 WHERE VBELN = P_RFUND.

*--[START] C20121128_25674 BIS를 통한 주문 생성 개선
  CLEAR :  L_RCEPNO, L_WERKS_M.

  GET PARAMETER ID 'BIS_RCEPNO' FIELD L_RCEPNO.
  GET PARAMETER ID 'BIS_WERKS_M' FIELD L_WERKS_M.

  IF L_RCEPNO <> ''.
    GV_RCEPNO = L_RCEPNO.
  ENDIF.

  IF L_WERKS_M <> ''.
    GV_WERKS_M = L_WERKS_M.
  ENDIF.
*--[END] C20121128_25674 BIS를 통한 주문 생성 개선

  SELECT *
   APPENDING CORRESPONDING FIELDS OF TABLE GT_140
   FROM VBAP
   WHERE VBELN =  P_RFUND.

  LOOP AT GT_140 WHERE VBELN = P_RFUND.
    L_IDX = SY-TABIX.

    GT_140-STATUS = '1'.
    GT_140-RCEPNO = GV_RCEPNO.
    GT_140-ZMATSEQ = GV_ZMATSEQ.

    SELECT SINGLE AUART
      INTO GT_140-AUART
      FROM VBAK
     WHERE VBELN = GT_140-VBELN.

    PERFORM GET_BUKRS USING    GV_WERKS_M
                      CHANGING GT_140-BUKRS.

    SELECT SINGLE B~MAKTX
      INTO GT_140-MAKTX
      FROM MARA AS A
     INNER JOIN  MAKT AS B
        ON A~MATNR EQ B~MATNR
     WHERE A~MATNR EQ GT_140-MATNR   "자재번호
       AND B~SPRAS EQ SY-LANGU.

    PERFORM  GET_VBAK_RFUND_102  USING    GT_140-VBELN
                                          GT_140-POSNR
                                          GT_140-AUART
                              CHANGING    GT_140-VRKME
                                          GT_140-KWMENG
                                          GT_140-RFAMT
                                          GT_140-RFMEIN
                                          GT_140-ERATE
                                          GT_140-RMEIN
                                          GT_140-LVBELN
                                          GT_140-LPOSNR
                                          GT_140-FROM_FACTOR
                                          GT_140-LFIMG
                                          GT_140-NETPR
                                          GT_140-WAERK
                                          GT_140-ZMATSEQ.


    PERFORM MODIFY_LIST USING    GT_140-STATUS
                        CHANGING GT_140-LIGHTS
                                 GT_140-STATUST.

    PERFORM TRANS_DATA_UPDAT USING 'ZQMT0014S'.

    MODIFY GT_140 INDEX  L_IDX.
  ENDLOOP.


  READ TABLE GT_160 WITH KEY MARK = 'X'.
  IF SY-SUBRC = 0.
    CLEAR : GT_170, GT_170[],
            GV_RE, GV_ZREQ, GV_ZORQ, GV_ZFQ..
    LOOP AT GT_140 WHERE RCEPNO = GT_160-RCEPNO
                     AND ZMATSEQ = GT_160-ZMATSEQ.
      CLEAR GT_170.
      MOVE-CORRESPONDING GT_140 TO GT_170.
      APPEND GT_170.
    ENDLOOP.

  ENDIF.

  CALL FUNCTION 'Z_QM_RECOM_COST'
    EXPORTING
      I_RCEPNO = GS_100-RCEPNO        "접수번호
      I_WERKS  = GS_100-WERKS_H.      "자재플랜트

  PERFORM SAVE_COMPLAIN_DATA_1 USING 'X'.

  PERFORM REFRESH_TABLE_DATA.

ENDFORM.                    " UPDATE_0014S
*&---------------------------------------------------------------------*
*&      Form  BUILD_MAIL_DATA3
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_GV_FLG  text
*----------------------------------------------------------------------*
FORM BUILD_MAIL_DATA3  CHANGING P_FLG.
  DATA: LS_MSG  TYPE SO_TEXT255,
        LS_MSG1 TYPE SO_TEXT255,
        LS_MSG2 TYPE SO_TEXT255,
        LS_MSG3 TYPE SO_TEXT255,
        LS_MSG4 TYPE SO_TEXT255,
        LS_MSG5 TYPE SO_TEXT255,
        LS_MSG6 TYPE SO_TEXT255,
        LS_MSG7 TYPE SO_TEXT255,
        LS_LONG TYPE SO_TEXT255.


  DATA: LV_INDEX     TYPE I,
        LV_NAME      LIKE ZZPA0001-ENAME,
        LV_TTEXT     LIKE TSTCT-TTEXT,
        LV_MATNR     LIKE ZQMT0011M-MATNR,
        LV_RCEPNO    LIKE ZQMT0011H-RCEPNO,
        LV_KUNUM     LIKE ZQMT0011H-KUNUM,
        LV_ERDAT(10).

  CLEAR: GT_MESSAGE, LV_NAME,   LS_MSG ,    LS_MSG1,   LS_MSG2,
         LS_MSG3,    LS_MSG4,   LS_MSG5,    LS_MSG6,   LV_INDEX,
         LV_TTEXT,   LV_MATNR,  GV_SUBJECT, LS_LONG,   LV_RCEPNO,
         LV_ERDAT,   LV_KUNUM,  LS_MSG7.

  REFRESH: GT_MESSAGE.


*__접수번호
  %%ALPHA_CONV_OUT  GV_RCEPNO  LV_RCEPNO.

*__고객번호
  %%ALPHA_CONV_OUT  GS_100-KUNUM  LV_KUNUM.

*__접수자
  SELECT SINGLE ENAME
    INTO LV_NAME
    FROM ZZPA0001
   WHERE PERNR EQ GS_100-RCPERNR
     AND ENDDA >= SY-DATUM.

*__T-CODE 내역
  LV_TTEXT = '고객불만관리'.


*__접수일
  WRITE GS_100-RCEPDT TO LV_ERDAT.


  CONCATENATE '[Frm.' LV_NAME ']' '고객불만' LV_RCEPNO '번 접수'
            INTO GV_SUBJECT." SEPARATED BY SPACE.


  CONCATENATE
    '.' '&nbsp' '고 객 불 만 : ' '&nbsp' INTO LS_MSG1.
  CONCATENATE LS_MSG1
       LV_RCEPNO '번' '<br>'
                INTO LS_MSG1 SEPARATED BY SPACE.

  CONCATENATE
     '.'   '&nbsp'
     '접'  '&nbsp' '&nbsp' '&nbsp'
     '수'  '&nbsp' '&nbsp' '&nbsp'
     '일'  '&nbsp'
     ':'   '&nbsp' INTO LS_MSG7.
  CONCATENATE
  LS_MSG7 LV_ERDAT '<br>'
                   INTO LS_MSG7 SEPARATED BY SPACE.

  CONCATENATE
     '.' '&nbsp'
     '고' '&nbsp' '&nbsp' '&nbsp' '&nbsp' '&nbsp' '&nbsp' '&nbsp'
     '&nbsp' '&nbsp'
     '객' '&nbsp'
     ':'  '&nbsp' INTO LS_MSG2.
  CONCATENATE
      LS_MSG2 GS_100-KUNUMT '(' LV_KUNUM ')' '<br>'
                INTO LS_MSG2 SEPARATED BY SPACE.

  CONCATENATE
     '.' '&nbsp'
     '접' '&nbsp' '&nbsp' '&nbsp'
     '수' '&nbsp' '&nbsp' '&nbsp'
     '자' '&nbsp'
     ':' '&nbsp'  INTO LS_MSG3.
  CONCATENATE

     LS_MSG3 GS_100-RCPERNRT '(' GS_100-RCPERNR ')' '<br>'
                INTO LS_MSG3 SEPARATED BY SPACE.

  CONCATENATE
     '.' '&nbsp'
     '주' '&nbsp' '&nbsp' '&nbsp' '&nbsp' '&nbsp' '&nbsp' '&nbsp'
     '&nbsp' '&nbsp'
     '제' '&nbsp'
     ':'  '&nbsp' INTO LS_MSG4.
  CONCATENATE
    LS_MSG4 GS_100-QMTXT '<p>'
                INTO LS_MSG4 SEPARATED BY SPACE.

  CONCATENATE
     '* T-CODE :' '&nbsp' INTO LS_MSG5.

*->[가온전선]--------------------CHG S
  CONCATENATE
    LS_MSG5  'ZGTSDR1250' '(' LV_TTEXT ')' '<p>'
                INTO LS_MSG5 SEPARATED BY SPACE.
*  CONCATENATE
*    LS_MSG5  'ZQM2R0696' '(' LV_TTEXT ')' '<p>'
*                INTO LS_MSG5 SEPARATED BY SPACE.
*-<[가온전선]--------------------CHG E

  MAIL_MSG: '<html>',
            '<body>',
            TEXT-014,
            LS_MSG5,
            LS_MSG1,
            LS_MSG7,
            LS_MSG2,
            LS_MSG3,
            LS_MSG4,
            '. 불만내용 :<br>',
            '</body>',
            '</html>'.

  LOOP AT G_LINES1_O.
    CONCATENATE G_LINES1_O-TDLINE '<br>'
                  INTO LS_LONG SEPARATED BY SPACE.
    APPEND LS_LONG TO GT_MESSAGE.
    CLEAR LS_LONG.
  ENDLOOP.

  MAIL_MSG: '<html>',
            '<body>',
            '<p>',
            '. 고객요구사항 :<br>',
            '</body>',
            '</html>'.


  LOOP AT G_LINES2_O.
    CONCATENATE G_LINES2_O-TDLINE '<br>'
                  INTO LS_LONG SEPARATED BY SPACE.
    APPEND LS_LONG TO GT_MESSAGE.
    CLEAR LS_LONG.
  ENDLOOP.


  MAIL_MSG: '<html>',
            '<body>',
            '<p>',
            '끝.<br>',
            '</body>',
            '</html>'.

* EMAIL 내용 전송
  PERFORM SEND_MAIL3 USING P_FLG.

ENDFORM.                    " BUILD_MAIL_DATA3
*&---------------------------------------------------------------------*
*&      Form  SEND_MAIL3
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GV_FLAG  text
*----------------------------------------------------------------------*
FORM SEND_MAIL3  USING    P_FLG.

  DATA RESULT_TAB TYPE MATCH_RESULT_TAB.

  TRY.
      G_EMAIL = CL_BCS=>CREATE_PERSISTENT( ).

      G_EMAIL_BODY = CL_DOCUMENT_BCS=>CREATE_DOCUMENT(
                      I_TYPE    = 'HTM'
                      I_TEXT    = GT_MESSAGE
                      I_SUBJECT = GV_SUBJECT ).

*     첨부
*      PERFORM add_attachment USING g_email_body.

      G_EMAIL->SET_DOCUMENT( G_EMAIL_BODY ).

      G_RECEIVER =
      CL_CAM_ADDRESS_BCS=>CREATE_INTERNET_ADDRESS( GV_ADDRESS ).

      G_EMAIL->ADD_RECIPIENT( I_RECIPIENT = G_RECEIVER
                              I_EXPRESS   = 'X' ).

      G_EMAIL->SET_SEND_IMMEDIATELY( 'X' ).

      G_EMAIL->SEND( EXPORTING I_WITH_ERROR_SCREEN = 'X'
                     RECEIVING RESULT              = GV_SEND_RESULT ).


      MESSAGE S001 WITH '고객불만이 접수되었습니다.'.
      CLEAR P_FLG.
      COMMIT WORK.

    CATCH CX_BCS INTO G_EXCEPTION.
      P_FLG = 'X'.
      MESSAGE S001 DISPLAY LIKE 'E'
         WITH '메일전송에 실패하였습니다.'.
  ENDTRY.

ENDFORM.                    " SEND_MAIL3
*&---------------------------------------------------------------------*
*&      Form  CHECK_SCREEN
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM CHECK_SCREEN USING P_FLG.

  IF GS_100-RCEPNO IS INITIAL.
    %%POPUP_TO_CONFIRM_STEP
             '고객불만을 저장하여야 첨부파일을 생성할 수 있습니다.'
             '저장하시겠습니까?'
             '저장'.
    IF GV_ANSWER = 'J'.
      PERFORM SAVE_COMPLAIN_DATA USING 'X'.
      CLEAR P_FLG.
    ELSE.
      P_FLG = 'X'.
    ENDIF.
  ENDIF.

ENDFORM.                    " CHECK_SCREEN
*&---------------------------------------------------------------------*
*&      Form  BDC_CV01N
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM BDC_CV01N .

  DATA : L_CORDI(30)  TYPE C,
         L_DEPART(30) TYPE C,
         WS_HR        LIKE ZHRS032.


  CLEAR : WS_HR, L_CORDI, L_DEPART.

* 코디네이터 정보
  CONCATENATE GS_100-CORDINR ',' GS_100-CORDINRT INTO L_CORDI.
  WS_HR-PERNR = GS_100-CORDINR.

* 코디네이터 부서정보
  CALL FUNCTION 'ZHR_GET_BASIC_PERNR'
    EXPORTING
      PERNR     = WS_HR-PERNR
      BEGDA     = SY-DATUM
      ENDDA     = SY-DATUM
    IMPORTING
      ZHR_BASIC = WS_HR.

  CONCATENATE WS_HR-ORGEH ',' WS_HR-ORGTX  INTO L_DEPART.

  REFRESH : GT_BDC,  MESSTAB.
  CLEAR   : GT_BDC,  MESSTAB.

  PERFORM STORE_BDCDATA USING :
                 'X' 'SAPLCV110'              '0100',
                 ' ' 'BDC_CURSOR'             'DRAW-DOKNR',
                 ' ' 'BDC_OKCODE'             '/00',
                 ' ' 'DRAW-DOKNR'             ' ',
                 ' ' 'DRAW-DOKAR'             GV_DOKAR,
                 ' ' 'DRAW-DOKTL'             GC_DOKTL,
                 ' ' 'DRAW-DOKVR'             ' '.

  PERFORM STORE_BDCDATA USING :
                 'X' 'SAPLCV110'              '0101',
                 ' ' 'BDC_OKCODE'             '/00',
                 ' ' 'BDC_CURSOR'             'DRAT-DKTXT',
                 ' ' 'DRAT-DKTXT'             GS_100-QMTXT,
                 ' ' 'DRAW-BEGRU'             GV_BUKRS,
*                 ' ' 'TDWST-STABK'            'IA',
                 ' ' 'DRAW-DWNAM'             SY-UNAME .

  PERFORM STORE_BDCDATA USING :
                 'X' 'SAPLCV110'              '0101',
                 ' ' 'BDC_OKCODE'             '=CLASS'.
  PERFORM STORE_BDCDATA USING :
                 'X' 'SAPLCLCA'               '0602',
                 ' ' 'BDC_CURSOR'             'RMCLF-KLART',
                 ' ' 'BDC_OKCODE'             '=ENTE',
                 ' ' 'RMCLF-KLART'            '017'.

  PERFORM STORE_BDCDATA USING :
                 'X' 'SAPLCLFM'               '0500',
                 ' ' 'BDC_CURSOR'             'RMCLF-STATU(01)',
                 ' ' 'BDC_OKCODE'             '/00',
                 ' ' 'RMCLF-STDCL(01)'        'X',
                 ' ' 'RMCLF-CLASS(01)'        'QCS_CLASS'.

  PERFORM STORE_BDCDATA USING :
                 'X' 'SAPLCTMS'               '0109',
                 ' ' 'BDC_CURSOR'             'RCTMS-MWERT(06)',
                 ' ' 'BDC_OKCODE'             '/00',
                 ' ' 'RCTMS-MNAME(01)'        'QCS_CATEGORY',
                 ' ' 'RCTMS-MNAME(02)'        'QM_SPART',
                 ' ' 'RCTMS-MNAME(03)'        'DOC_CREATOR',
                 ' ' 'RCTMS-MNAME(04)'        'DOC_PART',
                 ' ' 'RCTMS-MNAME(05)'        'DOC_DATE',
*                 ' ' 'RCTMS-MNAME(06)'        'QM_DATE2',
                 ' ' 'RCTMS-MNAME(06)'        'QM_PART',
*                 ' ' 'RCTMS-MNAME(08)'        'DOC_APPROVAL',
*                 ' ' 'RCTMS-MNAME(07)'        'QM_CONTENT',
                 ' ' 'RCTMS-MNAME(07)'        'QM_COMPLAINT'.


  PERFORM STORE_BDCDATA USING :
                 ' ' 'RCTMS-MWERT(01)'         GC_CATEROGY,
                 ' ' 'RCTMS-MWERT(02)'         GT_100-SPGCD,
                 ' ' 'RCTMS-MWERT(03)'         L_CORDI,
                 ' ' 'RCTMS-MWERT(04)'         L_DEPART,
                 ' ' 'RCTMS-MWERT(05)'         SY-DATUM,
*                 ' ' 'RCTMS-MWERT(06)'        'QM_DATE2',
                 ' ' 'rctms-mwert(06)'         L_DEPART,
*                 ' ' 'RCTMS-MWERT(08)'        'DOC_APPROVAL',
*                 ' ' 'RCTMS-MWERT(07)'        'QM_CONTENT',
                 ' ' 'rctms-mwert(07)'         GS_100-RCEPNO.

*
  PERFORM STORE_BDCDATA USING :
                 'x' 'saplctms'               '0109',
                 ' ' 'bdc_cursor'             'rctms-mname(01)',
                 ' ' 'bdc_okcode'             '=back'.
*
  PERFORM STORE_BDCDATA USING :
                 'x' 'saplclfm'               '0500',
                 ' ' 'bdc_cursor'             'rmclf-stdcl(01)',
                 ' ' 'bdc_okcode'             '=ende'.

  PERFORM STORE_BDCDATA USING :
                 'x' 'saplcv110'               '0101',
                 ' ' 'bdc_okcode'             '=save'.
*
  CALL TRANSACTION 'CV01N' USING         GT_BDC
                           MODE          G_DIMODE
                           UPDATE        's'
                           MESSAGES INTO MESSTAB.

  GET PARAMETER ID 'CV1' FIELD GS_100-DOKNR.
  GET PARAMETER ID 'CV3' FIELD GS_100-DOKVR.

ENDFORM.                                                    " BDC_CV01N
*&---------------------------------------------------------------------*
*&      Form  EXEC_CV02N
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM EXEC_CV02N .

  IF GS_100-DOKNR IS INITIAL.
    MESSAGE E002 WITH '문서생성을 하지 않은 자료 입니다.'.
  ENDIF.

  UPDATE ZQMT0011H  SET DOKNR  = GS_100-DOKNR
                        DOKAR  = GV_DOKAR
                        DOKVR  = GS_100-DOKVR
                  WHERE RCEPNO = GV_RCEPNO.

  IF SY-SUBRC EQ 0.
    COMMIT WORK.
  ENDIF.

  SET PARAMETER ID 'CV1'   FIELD    GS_100-DOKNR .
  SET PARAMETER ID 'CV2'   FIELD    GV_DOKAR .
  SET PARAMETER ID 'CV3'   FIELD    GS_100-DOKVR .
  SET PARAMETER ID 'CV4'   FIELD    GC_DOKTL .
  CALL TRANSACTION 'CV02N' AND SKIP FIRST SCREEN.

ENDFORM.                    " EXEC_CV02N
*&---------------------------------------------------------------------*
*&      Form  EXEC_CV03N
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM EXEC_CV03N .

  IF GS_100-DOKNR IS INITIAL.
    MESSAGE E002 WITH '문서생성을 하지 않은 자료 입니다.'.
  ENDIF.

  SET PARAMETER ID 'CV1'   FIELD    GS_100-DOKNR .
  SET PARAMETER ID 'CV2'   FIELD    GV_DOKAR .
  SET PARAMETER ID 'CV3'   FIELD    GS_100-DOKVR .
  SET PARAMETER ID 'CV4'   FIELD    GC_DOKTL .
  CALL TRANSACTION 'CV03N' AND SKIP FIRST SCREEN.

ENDFORM.                    " EXEC_CV03N
*&---------------------------------------------------------------------*
*&      Form  EVENT_HANDLER_REGISTER_180
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM EVENT_HANDLER_REGISTER_180 .
* TOOLBAR 구성은 EVENT에서 한다.
  CREATE OBJECT G_EVENT_HANDLER_6.
*

*-Edit  이벤트 등록
  CALL METHOD G_GRID_6->REGISTER_EDIT_EVENT
    EXPORTING
      I_EVENT_ID = CL_GUI_ALV_GRID=>MC_EVT_MODIFIED.

  CALL METHOD G_GRID_6->REGISTER_EDIT_EVENT
    EXPORTING
      I_EVENT_ID = CL_GUI_ALV_GRID=>MC_EVT_ENTER.

* 툴바지정
  SET HANDLER G_EVENT_HANDLER_6->HANDLE_TOOLBAR_6
                              FOR G_GRID_6.
* 툴바에 해당하는 이벤트 지정
  SET HANDLER G_EVENT_HANDLER_6->HANDLE_USER_COMMAND_6
                              FOR G_GRID_6.
** DATA_CHANGED
*  SET HANDLER G_EVENT_HANDLER_6->HANDLE_DATA_CHANGED_16 FOR G_GRID_6.
  SET HANDLER G_EVENT_HANDLER_6->HANDLE_DATA_CHANGED_FINISHED16
                                                     FOR G_GRID_6.
  SET HANDLER G_EVENT_HANDLER_6->HANDLE_HOTSPOT_CLICK_16
                        FOR G_GRID_6.
ENDFORM.                    " EVENT_HANDLER_REGISTER_180
*&---------------------------------------------------------------------*
*&      Form  DATA_CHANGED_16
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_ER_DATA_CHANGED  text
*----------------------------------------------------------------------*
FORM DATA_CHANGED_16  USING    ER_DATA_CHANGED
                   TYPE REF TO  CL_ALV_CHANGED_DATA_PROTOCOL.
*
  DATA: LS_MOD_CELLS TYPE LVC_S_MODI,
        LS_CELLS     TYPE LVC_S_MODI,
        LS_FIELDCAT  TYPE LVC_S_FCAT.

  CLEAR: GT_180.

  LOOP AT ER_DATA_CHANGED->MT_GOOD_CELLS INTO LS_MOD_CELLS.

    READ TABLE GT_180 INDEX LS_MOD_CELLS-ROW_ID.

    GT_180-MARK = 'X'.

    MODIFY GT_180 INDEX LS_MOD_CELLS-ROW_ID.
  ENDLOOP.

ENDFORM.                    " DATA_CHANGED_16
*&---------------------------------------------------------------------*
*&      Form  EVENT_HANDLER_REGISTER_140
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM EVENT_HANDLER_REGISTER_140 .

* TOOLBAR 구성은 EVENT에서 한다.
  CREATE OBJECT G_EVENT_HANDLER_2.
*

*-Edit  이벤트 등록
  CALL METHOD G_GRID_2->REGISTER_EDIT_EVENT
    EXPORTING
      I_EVENT_ID = CL_GUI_ALV_GRID=>MC_EVT_MODIFIED.

  CALL METHOD G_GRID_2->REGISTER_EDIT_EVENT
    EXPORTING
      I_EVENT_ID = CL_GUI_ALV_GRID=>MC_EVT_ENTER.

* 툴바지정
*    SET HANDLER g_event_handler_5->handle_toolbar
*                                FOR g_grid_5.
* 툴바에 해당하는 이벤트 지정
*    SET HANDLER g_event_handler_5->handle_user_command
*                                FOR g_grid_5.
** DATA_CHANGED
  SET HANDLER G_EVENT_HANDLER_2->HANDLE_DATA_CHANGED_2 FOR G_GRID_2.
*  SET HANDLER G_EVENT_HANDLER_2->HANDLE_DATA_CHANGED_FINISHED_1
*                                                     FOR G_GRID_2.
  SET HANDLER G_EVENT_HANDLER_2->HANDLE_HOTSPOT_CLICK_5
                        FOR G_GRID_2.
ENDFORM.                    " EVENT_HANDLER_REGISTER_140
*&---------------------------------------------------------------------*
*&      Form  DATA_CHANGED_2
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_ER_DATA_CHANGED  text
*----------------------------------------------------------------------*
FORM DATA_CHANGED_2  USING    ER_DATA_CHANGED
                     TYPE REF TO CL_ALV_CHANGED_DATA_PROTOCOL.
*
  DATA: LS_MOD_CELLS TYPE LVC_S_MODI,
        LS_CELLS     TYPE LVC_S_MODI,
        LS_FIELDCAT  TYPE LVC_S_FCAT.

  CLEAR: GT_140, GS_140.
  LOOP AT ER_DATA_CHANGED->MT_GOOD_CELLS INTO LS_MOD_CELLS.
    READ TABLE GT_140 INDEX LS_MOD_CELLS-ROW_ID.
    MOVE-CORRESPONDING GT_140 TO GS_140.
  ENDLOOP.

  LOOP AT GT_140.
    IF LS_MOD_CELLS-ROW_ID NE SY-TABIX.
      GT_140-MARK = SPACE.
    ELSE.
      GT_140-MARK = 'X'.
    ENDIF.
    MODIFY GT_140.
  ENDLOOP.

ENDFORM.                    " DATA_CHANGED_2
*&---------------------------------------------------------------------*
*&      Form  EVENT_HANDLER_REGISTER_150
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM EVENT_HANDLER_REGISTER_150 .
* TOOLBAR 구성은 EVENT에서 한다.
  CREATE OBJECT G_EVENT_HANDLER_3.
*

*-Edit  이벤트 등록
  CALL METHOD G_GRID_3->REGISTER_EDIT_EVENT
    EXPORTING
      I_EVENT_ID = CL_GUI_ALV_GRID=>MC_EVT_MODIFIED.

  CALL METHOD G_GRID_3->REGISTER_EDIT_EVENT
    EXPORTING
      I_EVENT_ID = CL_GUI_ALV_GRID=>MC_EVT_ENTER.

* 툴바지정
*    SET HANDLER g_event_handler_5->handle_toolbar
*                                FOR g_grid_5.
* 툴바에 해당하는 이벤트 지정
*    SET HANDLER g_event_handler_5->handle_user_command
*                                FOR g_grid_5.
** DATA_CHANGED
  SET HANDLER G_EVENT_HANDLER_3->HANDLE_DATA_CHANGED_3 FOR G_GRID_3.
*  SET HANDLER G_EVENT_HANDLER_2->HANDLE_DATA_CHANGED_FINISHED_1
*                                                     FOR G_GRID_2.
  SET HANDLER G_EVENT_HANDLER_3->HANDLE_HOTSPOT_CLICK_3
                        FOR G_GRID_3.
ENDFORM.                    " EVENT_HANDLER_REGISTER_150
*&---------------------------------------------------------------------*
*&      Form  DATA_CHANGED_7
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_ER_DATA_CHANGED  text
*----------------------------------------------------------------------*
FORM DATA_CHANGED_7  USING    ER_DATA_CHANGED
                     TYPE REF TO CL_ALV_CHANGED_DATA_PROTOCOL.
*
  DATA: LS_MOD_CELLS TYPE LVC_S_MODI,
        LS_CELLS     TYPE LVC_S_MODI,
        LS_FIELDCAT  TYPE LVC_S_FCAT.

  CLEAR: GT_200, GS_200, GV_PRUEFLOS.

  LOOP AT ER_DATA_CHANGED->MT_GOOD_CELLS INTO LS_MOD_CELLS.
    READ TABLE GT_200 INDEX LS_MOD_CELLS-ROW_ID.
    MOVE-CORRESPONDING GT_200 TO GS_200.

    IF GS_200-PRUEFLOS NE SPACE.
      IF GT_200-MARK IS INITIAL.
        GV_PRUEFLOS = GS_200-PRUEFLOS.
      ELSE.
        CLEAR GV_PRUEFLOS.
      ENDIF.
    ENDIF.
  ENDLOOP.

  LOOP AT GT_200.
    IF LS_MOD_CELLS-ROW_ID NE SY-TABIX.
      GT_200-MARK = SPACE.
    ELSE.
      GT_200-MARK = 'X'.
    ENDIF.
    MODIFY GT_200.
  ENDLOOP.

ENDFORM.                    " DATA_CHANGED_7
*&---------------------------------------------------------------------*
*&      Form  SAVE_COMPLAIN_DATA_1
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_3784   text
*----------------------------------------------------------------------*
FORM SAVE_COMPLAIN_DATA_1  USING PV_FLAG .

  PERFORM SAVE_PROCESS_1 USING PV_FLAG.

ENDFORM.                    " SAVE_COMPLAIN_DATA_1
*&---------------------------------------------------------------------*
*&      Form  SAVE_PROCESS_1
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_PV_FLAG  text
*----------------------------------------------------------------------*
FORM SAVE_PROCESS_1  USING  PV_FLAG.

  CLEAR: GV_ANSWER.

  IF PV_FLAG IS INITIAL.
    %%POPUP_TO_CONFIRM_STEP '입력하신 Data를 저장하시겠습니까?'
                            ' '  '저장'.
  ELSE.
    GV_ANSWER = 'J'.
  ENDIF.

  IF GV_ANSWER = 'J'.
*  접수번호 생성
    GV_RCEPNO = GS_100-RCEPNO.

    IF  GV_RCEPNO  IS INITIAL.
      PERFORM  CLEATE_RECEIPT_NUMBER  CHANGING  GV_RCEPNO
                                                GV_FORM_FLG.

      IF  GV_FORM_FLG  IS INITIAL.
        PERFORM  INSERT_CUSTOM_CLAIM_100  USING  "P_SCRNM
                                                 GV_RCEPNO
                                       CHANGING  GV_FORM_FLG.
      ENDIF.
    ELSE.
      PERFORM MODIFY_CUSTOM_CLAIM_500  USING GV_RCEPNO
                                    CHANGING GV_FORM_FLG.

    ENDIF.
  ELSE.
    GV_FORM_FLG = 'X'.
  ENDIF.

ENDFORM.                    " SAVE_PROCESS_1
*&---------------------------------------------------------------------*
*&      Form  MODIFY_CUSTOM_CLAIM_500
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GV_RCEPNO  text
*      <--P_GV_FORM_FLG  text
*----------------------------------------------------------------------*
FORM MODIFY_CUSTOM_CLAIM_500  USING    P_RCEPNO
                              CHANGING P_FORM_FLG.

  PERFORM  INSERT_CUSTOM_CLAIM_0500.

  IF GV_SAVE_Y = 'X'.
    COMMIT WORK.
    MESSAGE S001 WITH '입력하신 Data가 저장되었습니다.'.
  ENDIF.

ENDFORM.                    " MODIFY_CUSTOM_CLAIM_500
*&---------------------------------------------------------------------*
*&      Form  SAVE_COMPLAIN_DATA_2
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_8350   text
*----------------------------------------------------------------------*
FORM SAVE_COMPLAIN_DATA_2  USING PV_FLAG .

  PERFORM SAVE_PROCESS_2 USING PV_FLAG.

ENDFORM.                    " SAVE_COMPLAIN_DATA_2
*&---------------------------------------------------------------------*
*&      Form  SAVE_PROCESS_2
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_PV_FLAG  text
*----------------------------------------------------------------------*
FORM SAVE_PROCESS_2  USING    PV_FLAG.

  CLEAR: GV_ANSWER.

  IF PV_FLAG IS INITIAL.
    %%POPUP_TO_CONFIRM_STEP '입력하신 Data를 저장하시겠습니까?'
                            ' '  '저장'.
  ELSE.
    GV_ANSWER = 'J'.
  ENDIF.

  IF GV_ANSWER = 'J'.
*  접수번호 생성
    GV_RCEPNO = GS_100-RCEPNO.

    IF  GV_RCEPNO  IS INITIAL.
      PERFORM  CLEATE_RECEIPT_NUMBER  CHANGING  GV_RCEPNO
                                                GV_FORM_FLG.

      IF  GV_FORM_FLG  IS INITIAL.
        PERFORM  INSERT_CUSTOM_CLAIM_100  USING  "P_SCRNM
                                                 GV_RCEPNO
                                       CHANGING  GV_FORM_FLG.
      ENDIF.
    ELSE.
      PERFORM MODIFY_CUSTOM_CLAIM_600  USING GV_RCEPNO
                                    CHANGING GV_FORM_FLG.

    ENDIF.
  ELSE.
    GV_FORM_FLG = 'X'.
  ENDIF.

ENDFORM.                    " SAVE_PROCESS_2
*&---------------------------------------------------------------------*
*&      Form  MODIFY_CUSTOM_CLAIM_600
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GV_RCEPNO  text
*      <--P_GV_FORM_FLG  text
*----------------------------------------------------------------------*
FORM MODIFY_CUSTOM_CLAIM_600  USING    P_RCEPNO
                              CHANGING P_FORM_FLG.

  PERFORM  INSERT_CUSTOM_CLAIM_0600.

  IF GV_SAVE_Y = 'X'.
    COMMIT WORK.
    MESSAGE S001 WITH '입력하신 Data가 저장되었습니다.'.
  ENDIF.

ENDFORM.                    " MODIFY_CUSTOM_CLAIM_600
*&---------------------------------------------------------------------*
*&      Form  GET_USER_NAME
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM GET_USER_NAME  USING    PV_UNAME
                             PV_NAMET.

  CLEAR : PV_NAMET.

  SELECT SINGLE NAME_TEXT
    INTO PV_NAMET
    FROM USR21 AS A
   INNER JOIN ADRP AS B
      ON A~PERSNUMBER = B~PERSNUMBER
   WHERE A~BNAME = PV_UNAME.

ENDFORM.                    " GET_USER_NAME

*&---------------------------------------------------------------------*
*&      Form  HOTSPOT_CLICK_3
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->E_ROW_ID     text
*      -->E_COLUMN_ID  text
*----------------------------------------------------------------------*
FORM HOTSPOT_CLICK_3  USING    E_ROW_ID    TYPE LVC_S_ROW
                             E_COLUMN_ID TYPE LVC_S_COL.

  CASE E_COLUMN_ID-FIELDNAME.
    WHEN 'PRUEFLOS'.
      READ TABLE GT_150 INDEX E_ROW_ID.
      CHECK SY-SUBRC = 0.

      SET PARAMETER ID 'QLS' FIELD GT_150-PRUEFLOS.
      CALL TRANSACTION 'QA03' AND SKIP FIRST SCREEN.
  ENDCASE.

ENDFORM.                    " HOTSPOT_CLICK_5


*&---------------------------------------------------------------------*
*&      Form  HOTSPOT_CLICK_5
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_E_ROW_ID  text
*      -->P_E_COLUMN_ID  text
*----------------------------------------------------------------------*
FORM HOTSPOT_CLICK_5  USING    E_ROW_ID    TYPE LVC_S_ROW
                             E_COLUMN_ID TYPE LVC_S_COL.

  CASE E_COLUMN_ID-FIELDNAME.
    WHEN 'VBELN'.
      READ TABLE GT_140 INDEX E_ROW_ID.
      CHECK SY-SUBRC = 0.

      SET PARAMETER ID 'AUN' FIELD GT_140-VBELN.
      CALL TRANSACTION 'VA03' AND SKIP FIRST SCREEN.

    WHEN 'LVBELN'.
      READ TABLE GT_140 INDEX E_ROW_ID.
      CHECK SY-SUBRC = 0.

      SET PARAMETER ID 'AUN' FIELD GT_140-LVBELN.
      CALL TRANSACTION 'VA03' AND SKIP FIRST SCREEN.

  ENDCASE.

ENDFORM.                    " HOTSPOT_CLICK_5
*&---------------------------------------------------------------------*
*&      Form  HOTSPOT_CLICK_6
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_E_ROW_ID  text
*      -->P_E_COLUMN_ID  text
*----------------------------------------------------------------------*
FORM HOTSPOT_CLICK_6  USING    E_ROW_ID    TYPE LVC_S_ROW
                             E_COLUMN_ID TYPE LVC_S_COL.

  CASE E_COLUMN_ID-FIELDNAME.
    WHEN 'VBELN'.
      READ TABLE GT_170 INDEX E_ROW_ID.
      CHECK SY-SUBRC = 0.

      SET PARAMETER ID 'AUN' FIELD GT_170-VBELN.
      CALL TRANSACTION 'VA03' AND SKIP FIRST SCREEN.

    WHEN 'LVBELN'.
      READ TABLE GT_170 INDEX E_ROW_ID.
      CHECK SY-SUBRC = 0.

      SET PARAMETER ID 'AUN' FIELD GT_170-LVBELN.
      CALL TRANSACTION 'VA03' AND SKIP FIRST SCREEN.

  ENDCASE.

ENDFORM.                    " HOTSPOT_CLICK_6
*&---------------------------------------------------------------------*
*&      Form  TOOLBAR_PROS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_E_OBJECT  text
*      -->P_E_INTERACTIVE  text
*----------------------------------------------------------------------*
FORM TOOLBAR_PROS  USING  E_OBJECT TYPE REF TO CL_ALV_EVENT_TOOLBAR_SET
                          E_INTERACTIVE.

  DATA: LS_TOOLBAR  TYPE STB_BUTTON.

  CLEAR LS_TOOLBAR.
* 구분자.
  LS_TOOLBAR-BUTN_TYPE = 3.
  APPEND LS_TOOLBAR    TO E_OBJECT->MT_TOOLBAR.
* 최신표시
  CLEAR LS_TOOLBAR.
  LS_TOOLBAR-FUNCTION  = 'REFR'."USER COMMAND FUCTION NAME
  LS_TOOLBAR-ICON      = ICON_REFRESH.
  LS_TOOLBAR-QUICKINFO = '최신표시'.
  LS_TOOLBAR-TEXT      = ' '.
  LS_TOOLBAR-DISABLED  = ' '.
  APPEND LS_TOOLBAR    TO E_OBJECT->MT_TOOLBAR.

ENDFORM.                    " TOOLBAR_PROS
*&---------------------------------------------------------------------*
*&      Form  TOOLBAR_PROS_6
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_E_OBJECT  text
*      -->P_E_INTERACTIVE  text
*----------------------------------------------------------------------*
FORM TOOLBAR_PROS_6 USING E_OBJECT TYPE REF TO CL_ALV_EVENT_TOOLBAR_SET
                          E_INTERACTIVE.

  DATA: LS_TOOLBAR  TYPE STB_BUTTON.

  CLEAR LS_TOOLBAR.
* 구분자.
  LS_TOOLBAR-BUTN_TYPE = 3.
  APPEND LS_TOOLBAR    TO E_OBJECT->MT_TOOLBAR.
* 최신표시
  CLEAR LS_TOOLBAR.
  LS_TOOLBAR-FUNCTION  = 'SALL6'."USER COMMAND FUCTION NAME
  LS_TOOLBAR-ICON      = '@4B@'.
  LS_TOOLBAR-QUICKINFO = '전체선택'.
  LS_TOOLBAR-TEXT      = ' '.
  LS_TOOLBAR-DISABLED  = ' '.
  APPEND LS_TOOLBAR    TO E_OBJECT->MT_TOOLBAR.

  CLEAR LS_TOOLBAR.
  LS_TOOLBAR-FUNCTION  = 'DALL6'."USER COMMAND FUCTION NAME
  LS_TOOLBAR-ICON      = '@4D@'.
  LS_TOOLBAR-QUICKINFO = '전체선택해제'.
  LS_TOOLBAR-TEXT      = ' '.
  LS_TOOLBAR-DISABLED  = ' '.
  APPEND LS_TOOLBAR    TO E_OBJECT->MT_TOOLBAR.

ENDFORM.                    " TOOLBAR_PROS_6
*&---------------------------------------------------------------------*
*&      Form  USER_COMMAND_PROS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_E_UCOMM  text
*----------------------------------------------------------------------*
FORM USER_COMMAND_PROS  USING    P_UCOMM.
  DATA : L_FLG TYPE C.

  CASE P_UCOMM.
*-  Refresh
    WHEN 'REFR'.
      PERFORM REFRESH_0014S USING GV_RCEPNO.
      PERFORM REFRESH_GRID_170.
    WHEN OTHERS.
  ENDCASE.


ENDFORM.                    " USER_COMMAND_PROS
*&---------------------------------------------------------------------*
*&      Form  USER_COMMAND_PROS_6
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_E_UCOMM  text
*----------------------------------------------------------------------*
FORM USER_COMMAND_PROS_6  USING    P_UCOMM.
  DATA : L_FLG TYPE C.

  CASE P_UCOMM.
*-  전체선택/해제
    WHEN 'SALL6' OR 'DALL6'.
      IF P_UCOMM = 'SALL6'.
        GT_180-MARK = 'X'.
      ELSE.
        CLEAR : GT_180-MARK.
      ENDIF.

      MODIFY GT_180 TRANSPORTING MARK
                    WHERE ZMATSEQ IS NOT INITIAL.
    WHEN OTHERS.
  ENDCASE.


ENDFORM.                    " USER_COMMAND_PROS_6
*&---------------------------------------------------------------------*
*&      Form  REFRESH_0014S
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GV_RCEPNO  text
*----------------------------------------------------------------------*
FORM REFRESH_0014S  USING    P_RCEPNO.
  DATA : LT_140 LIKE GT_140 OCCURS 0 WITH HEADER LINE.

  CLEAR : LT_140, GT_170.
  REFRESH : LT_140, GT_170.

*__영업문서 List
  SELECT *
    INTO CORRESPONDING FIELDS OF TABLE LT_140
    FROM ZQMT0014S
   WHERE RCEPNO = P_RCEPNO.

  IF GV_ZMATSEQ IS INITIAL.
    READ TABLE GT_160 WITH KEY MARK = 'X'.
    IF SY-SUBRC = 0.
      GV_ZMATSEQ = GT_160-ZMATSEQ.
    ENDIF.
  ENDIF.

  LOOP AT LT_140 WHERE ZMATSEQ = GV_ZMATSEQ.
    MOVE-CORRESPONDING LT_140 TO GT_170.

    PERFORM MODIFY_LIST USING    GT_170-STATUS
                        CHANGING GT_170-LIGHTS
                                 GT_170-STATUST.
    APPEND GT_170.      CLEAR GT_170.
  ENDLOOP.

ENDFORM.                    " REFRESH_0014S
*&---------------------------------------------------------------------*
*&      Form  TC_110_NEXT1
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM TC_100_NEXT1 .

  DATA : LV_IDX LIKE SY-TABIX.

  READ TABLE GT_100 WITH KEY MARK = 'X'.
  IF SY-SUBRC = 0.
    CLEAR GT_100-MARK.
    IF LV_IDX IS INITIAL.
      LV_IDX = SY-TABIX.
    ENDIF.
    MODIFY GT_100 INDEX LV_IDX
                  TRANSPORTING MARK.

    LV_IDX = LV_IDX + 1.

    READ TABLE GT_100 TRANSPORTING NO FIELDS INDEX LV_IDX.
    IF SY-SUBRC <> 0.
      MESSAGE S001 DISPLAY LIKE 'W'
         WITH '마지막 데이터입니다.'.

      LV_IDX = LV_IDX - 1.
    ENDIF.

    GT_100-MARK = 'X'.
    MODIFY GT_100 INDEX LV_IDX
                  TRANSPORTING MARK.
  ELSE.
    GT_100-MARK = 'X'.
    MODIFY GT_100 INDEX 1 TRANSPORTING MARK.
    PERFORM REFRESH_SCREEN_0310.

  ENDIF.

  PERFORM REFRESH_SCREEN_0310.

ENDFORM.                    " TC_110_NEXT1
*&---------------------------------------------------------------------*
*&      Form  TC_110_PREV1
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM TC_100_PREV1 .

  DATA : LV_IDX LIKE SY-TABIX.

  READ TABLE GT_100 WITH KEY MARK = 'X'.
  IF SY-SUBRC = 0.
    IF LV_IDX IS INITIAL.
      LV_IDX = SY-TABIX.
    ENDIF.

    IF LV_IDX > 1.
      CLEAR GT_100-MARK.
      MODIFY GT_100 INDEX LV_IDX
                    TRANSPORTING MARK.

      LV_IDX = LV_IDX - 1.
      GT_100-MARK = 'X'.
      MODIFY GT_100 INDEX LV_IDX
                    TRANSPORTING MARK.
    ENDIF.
  ENDIF.

  PERFORM REFRESH_SCREEN_0310.

ENDFORM.                    " TC_110_PREV1
*&---------------------------------------------------------------------*
*&      Form  GET_USRID1
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_ZQMS301_CPERNR  text
*      <--P_ZQMS301_CPERNRT  text
*----------------------------------------------------------------------*
FORM GET_USRID1  USING    PV_CPERNR
                 CHANGING PV_CPERNRT.

  CHECK PV_CPERNR IS NOT INITIAL.

  SELECT *
     FROM ZZPA0001  UP TO 1 ROWS
    WHERE PERNR = PV_CPERNR
      AND ENDDA = '99991231' .
  ENDSELECT.

  IF SY-SUBRC EQ 0.
    PV_CPERNRT = ZZPA0001-SNAME.
  ELSE.
    CLEAR PV_CPERNR.
    MESSAGE S001 WITH '생성자 사번을 확인할 수 없습니다.'
                      DISPLAY LIKE 'E'.
  ENDIF.

ENDFORM.                    " GET_USRID1
*&---------------------------------------------------------------------*
*&      Form  REFRESH_SCREEN_0310
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM REFRESH_SCREEN_0310 .

  READ TABLE GT_100 WITH KEY MARK = 'X'.
  IF SY-SUBRC = 0.
    CLEAR: GT_110, GT_110[], GT_110A,
           GT_120, GT_120[], GT_120A.

* 배치의 헤더를 설정한다.
    GS_101-ZMATSEQ  = GT_100-ZMATSEQ.          "자재Seq
    GS_101-MATNR    = GT_100-MATNR.            "자재번호
    GS_101-MAKTX    = GT_100-MAKTX.            "자재내역
    GS_101-KDAUF    = GT_100-KDAUF.            "판매오더
    GS_101-KZLOESCH = GT_100-KZLOESCH.         "삭제플래그
    GS_101-WERKS_M  = GT_100-WERKS_M.          "자재플랜트
    PERFORM GET_WERKST USING    GS_101-WERKS_M
                       CHANGING GS_101-WERKST. "플랜트명

* gt_110a 에서 일치하는 데이터를 가져온다.
    LOOP AT GT_110A WHERE RCEPNO  EQ GT_100-RCEPNO    "접수번호
                      AND ZMATSEQ EQ GT_100-ZMATSEQ.  "자재Seq
      GT_110 = GT_110A.
      APPEND GT_110.
      CLEAR: GT_110, GT_110A.
    ENDLOOP.

* gt_120a 에서 일치하는 데이터를 가져온다.
    LOOP AT GT_120A WHERE RCEPNO  EQ GT_100-RCEPNO    "접수번호
                      AND ZMATSEQ EQ GT_100-ZMATSEQ.  "자재Seq
      GT_120 = GT_120A.
      APPEND GT_120.
      CLEAR: GT_120, GT_120A.
    ENDLOOP.

  ENDIF.

ENDFORM.                    " REFRESH_SCREEN_0310
*&---------------------------------------------------------------------*
*&      Form  GET_AS_AMOUNT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM GET_AS_AMOUNT .
* local variable
  DATA: BEGIN OF LS_AMOUNT,
          ZFNAME(2),
          AMOUNT    TYPE Z_WOGXXX,
          SHKZG     LIKE ZQMT0016F-SHKZG,
        END OF LS_AMOUNT,
        LT_AMOUNT LIKE TABLE OF LS_AMOUNT,
*        ls_sum LIKE ls_amount,
        BEGIN OF LS_SUM ,
          ZFNAME(2),
          AMOUNT    TYPE Z_WOGXXX,
        END OF LS_SUM ,
        LT_SUM LIKE TABLE OF LS_SUM.
  DATA: LV_BUKRS     TYPE BUKRS,
        LV_FIELD(20),
        LV_INDEX(2)  TYPE N.
  FIELD-SYMBOLS: <LFS> TYPE ANY.

* 회사코드를 읽어온다.
  PERFORM GET_BUKRS  USING    GS_100-WERKS_H
                     CHANGING LV_BUKRS.
  CHECK NOT LV_BUKRS IS INITIAL.

* 금액을 읽어온다.
  SELECT B~FNAME A~WOGBTR A~SHKZG
    INTO TABLE LT_AMOUNT
    FROM ZQMT0016F AS A
   INNER JOIN ZQMT0017  AS B
      ON A~BUKRS  EQ B~BUKRS
     AND A~GJAHR  EQ B~GJAHR
     AND A~QCODE1 EQ B~QCODE1
     AND A~HKONT  EQ B~HKONT
   WHERE A~BUKRS  EQ LV_BUKRS            "회사코드
*     AND A~GJAHR  EQ GS_100-RCEPDT(4)    "회계연도
     AND A~DFLG   EQ SPACE
     AND A~RCEPNO EQ GS_100-RCEPNO.       "접수번호

* 금액의 누계를 구한다.
  LOOP AT LT_AMOUNT INTO LS_AMOUNT .
    IF  LS_AMOUNT-SHKZG = 'H'.
      LS_SUM-AMOUNT = LS_AMOUNT-AMOUNT * -1.
      LS_SUM-ZFNAME = LS_AMOUNT-ZFNAME.
    ELSE.
      LS_SUM = LS_AMOUNT.
    ENDIF.
    COLLECT LS_SUM INTO LT_SUM.
    CLEAR: LS_AMOUNT, LS_SUM.
  ENDLOOP.

* 금액을 화면필드에 넣어준다.
  LOOP AT LT_SUM INTO LS_SUM.
    LV_INDEX = LS_SUM-ZFNAME.
    CONCATENATE 'S_710-BEAMT' LV_INDEX INTO LV_FIELD.
    ASSIGN (LV_FIELD) TO <LFS>.
    <LFS> = LS_SUM-AMOUNT * 100.
    CLEAR: LS_SUM, LV_FIELD.
  ENDLOOP.



ENDFORM.                    " GET_AS_AMOUNT
*&---------------------------------------------------------------------*
*&      Form  CHECK_VKORG
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM CHECK_VKORG .

  DATA : LV_BUKRS TYPE BUKRS.

  CLEAR :  GV_FORM_FLG, LV_BUKRS.


*  SELECT COUNT(*)
*    FROM zqmt0014s
*    WHERE rcepno = gs_100-rcepno
*    AND auart EQ 'ZREQ'
*    AND dflg NE 'X'.
*  IF sy-subrc EQ 0.
*    MESSAGE s001 WITH
*              '이미 ZREQ 오더가 존재합니다.'
*               DISPLAY LIKE 'E'.
*    gv_form_flg = 'X'.
*    EXIT.
*  ENDIF.
*
*  SELECT COUNT(*)
*      FROM zqmt0014s
*      WHERE rcepno = gs_100-rcepno
*      AND auart EQ 'ZORQ'
*      AND dflg NE 'X'.
*  IF sy-subrc EQ 0.
*    MESSAGE s001 WITH
*              '이미 ZORQ 오더가 존재합니다.'
*               DISPLAY LIKE 'E'.
*    gv_form_flg = 'X'.
*    EXIT.
*  ENDIF.



  PERFORM GET_BUKRS  USING    GT_100-WERKS_M
                     CHANGING LV_BUKRS.

*__유통경로
  IF GS_100-VTWEG IS INITIAL.
    MESSAGE S001 WITH
              '제품군/영업팀/영업그룹/유통경로는 필수 입력사항입니다.'
               DISPLAY LIKE 'E'.
    GV_FORM_FLG = 'X'.
    EXIT.
  ENDIF.

*___제품군
  IF NOT GS_100-SPGCD IS INITIAL.
    SELECT SINGLE *
      FROM TVTA
     WHERE VKORG = LV_BUKRS
       AND VTWEG = GS_100-VTWEG
       AND SPART = GS_100-SPGCD.

    IF SY-SUBRC <> 0.
      MESSAGE S002 WITH '영업조직/유통경로에 지정되지 않은'
                        '제품군입니다.'
                        DISPLAY LIKE 'E'.
      GV_FORM_FLG = 'X'.
      EXIT.
    ENDIF.
  ELSE.
    MESSAGE S002 WITH
             '제품군/영업팀/영업그룹/유통경로는'
             '필수 입력사항입니다.'
             DISPLAY LIKE 'E'.
    GV_FORM_FLG = 'X'.
    EXIT.
  ENDIF.

*___영업팀
  IF NOT GS_100-VKBUR IS INITIAL.
    SELECT SINGLE *
      FROM TVKBZ
     WHERE VKORG = LV_BUKRS
       AND VTWEG = GS_100-VTWEG
       AND SPART = GS_100-SPGCD
       AND VKBUR = GS_100-VKBUR.

    IF SY-SUBRC <> 0.
      MESSAGE S001 WITH '영업영역에 지정되지 않은 영업팀입니다.'
                        DISPLAY LIKE 'E'.
      GV_FORM_FLG = 'X'.
      EXIT.
    ENDIF.
  ELSE.
    MESSAGE S002 WITH
             '제품군/영업팀/영업그룹/유통경로는'
             '필수 입력사항입니다.'
              DISPLAY LIKE 'E'.
    GV_FORM_FLG = 'X'.
    EXIT.
  ENDIF.

*__영업그룹
  IF NOT GS_100-VKGRP IS INITIAL.
    SELECT SINGLE *
      FROM TVBVK
     WHERE VKBUR = GS_100-VKBUR
       AND VKGRP = GS_100-VKGRP.

    IF SY-SUBRC <> 0.
      MESSAGE S001 WITH '영업팀에 지정되지 않은 영업그룹입니다.'
                         DISPLAY LIKE 'E'.
      GV_FORM_FLG = 'X'.
      EXIT.
    ENDIF.
  ELSE.
    MESSAGE S002 WITH
             '제품군/영업팀/영업그룹/유통경로는'
             '필수 입력사항입니다.'
             DISPLAY LIKE 'E'.
    GV_FORM_FLG = 'X'.
    EXIT.
  ENDIF.

*___고객
  CLEAR : GV_KALKS.

  IF NOT GS_100-KUNUM IS INITIAL.
    SELECT SINGLE KALKS
      INTO GV_KALKS
      FROM KNVV
     WHERE KUNNR = GS_100-KUNUM
       AND VKORG = LV_BUKRS
       AND VTWEG = GS_100-VTWEG
       AND SPART = GS_100-SPGCD.

    IF SY-SUBRC <> 0.
      MESSAGE S001 WITH '고객에 영업영역이 확정되지 않았습니다.'
                         DISPLAY LIKE 'E'.
      GV_FORM_FLG = 'X'.
      EXIT.
    ENDIF.
  ELSE.
    MESSAGE S001 WITH '판매처를 입력하지 않았습니다.'
                       DISPLAY LIKE 'E'.
    GV_FORM_FLG = 'X'.
    EXIT.
  ENDIF.

ENDFORM.                    " CHECK_VKORG
*&---------------------------------------------------------------------*
*&      Form  HOTSPOT_CLICK_7
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_E_ROW_ID  text
*      -->P_E_COLUMN_ID  text
*----------------------------------------------------------------------*
FORM HOTSPOT_CLICK_7  USING  E_ROW_ID    TYPE LVC_S_ROW
                             E_COLUMN_ID TYPE LVC_S_COL.

  CASE E_COLUMN_ID-FIELDNAME.
    WHEN 'PRUEFLOS'.
      READ TABLE GT_200 INDEX E_ROW_ID.
      CHECK SY-SUBRC = 0.

      SET PARAMETER ID 'QLS' FIELD GT_200-PRUEFLOS.
      CALL TRANSACTION 'QA03' AND SKIP FIRST SCREEN.
  ENDCASE.

ENDFORM.                    " HOTSPOT_CLICK_7
*&---------------------------------------------------------------------*
*&      Form  REFER_OBJECT_ITEMS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM REFER_OBJECT_ITEMS .
  DATA: L_CURSORFIELD(20)    TYPE  C.

  FIELD-SYMBOLS: <L_FS>.  " TYPE ANY.
*

  GET  CURSOR  FIELD  L_CURSORFIELD.
  ASSIGN GV_PRUEFLOS  TO  <L_FS>.
  IF  NOT  <L_FS>  IS INITIAL.
    CASE  L_CURSORFIELD.
      WHEN  'GV_PRUEFLOS'.
        SET    PARAMETER ID 'QLS'   FIELD  GV_PRUEFLOS.
        CALL   TRANSACTION  'QA02'  AND SKIP FIRST SCREEN.

        PERFORM UPDATE_QA USING GV_PRUEFLOS.
        PERFORM  REFRESH_GRID_200.

    ENDCASE.
  ENDIF.
ENDFORM.                    " REFER_OBJECT_ITEMS
*&---------------------------------------------------------------------*
*&      Form  CONET2_READ
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM CONET2_READ  USING    PV_CODE
                           PV_KURZTEXT.

  CLEAR : PV_KURZTEXT.

  SELECT SINGLE KURZTEXT
    INTO PV_KURZTEXT
    FROM QPCT
   WHERE KATALOGART = 'Q'
     AND CODEGRUPPE = 'LQ01'
     AND CODE       = PV_CODE
     AND SPRACHE    = SY-LANGU.

ENDFORM.                    " CONET2_READ
*&---------------------------------------------------------------------*
*&      Form  EVENT_HANDLER_REGISTER_1210
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM EVENT_HANDLER_REGISTER_1210 .

* TOOLBAR 구성은 EVENT에서 한다.
  CREATE OBJECT G_EVENT_HANDLER_11.

  SET HANDLER G_EVENT_HANDLER_11->HANDLE_HOTSPOT_CLICK_1210
                        FOR G_GRID_11.

ENDFORM.                    " EVENT_HANDLER_REGISTER_1210
*&---------------------------------------------------------------------*
*&      Form  GET_DATA_ZQMT0018M
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM GET_DATA_ZQMT0018M .

  CLEAR: GS_ZQMT0018M, GT_ZQMT0018M.
  SELECT * FROM ZQMT0018M
           INTO TABLE GT_ZQMT0018M
          WHERE RCEPNO EQ GS_100-RCEPNO.
*            AND dflg   EQ space.


ENDFORM.                    " GET_DATA_ZQMT0018M
*&---------------------------------------------------------------------*
*&      Form  MODIFY_FIELDCAT_960
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_GT_FIELDCAT960  text
*----------------------------------------------------------------------*
FORM MODIFY_FIELDCAT_960  CHANGING PT_FIELDCAT TYPE LVC_T_FCAT.

* local variable
  DATA: LS_FCAT TYPE LVC_S_FCAT.

  LOOP AT PT_FIELDCAT INTO LS_FCAT .
    CASE  LS_FCAT-FIELDNAME.
      WHEN  'MANDT' OR 'RCEPNO' OR 'BUKRS' OR 'BWART'
        OR 'CNAM' OR 'CNAMT' OR 'ZAEDAT_B' OR 'ZAEZET_B'.

        DELETE PT_FIELDCAT .
      WHEN  'CPERNR'  OR  'MBLNR'.
        LS_FCAT-EDIT     = 'X'.
        MODIFY PT_FIELDCAT FROM LS_FCAT INDEX SY-TABIX.
      WHEN   'DFLG'.
        LS_FCAT-EDIT     = 'X'.
        LS_FCAT-CHECKBOX     = 'X'.
        MODIFY PT_FIELDCAT FROM LS_FCAT INDEX SY-TABIX.


      WHEN OTHERS.
    ENDCASE.
    CLEAR: LS_FCAT.
  ENDLOOP.
ENDFORM.                    " MODIFY_FIELDCAT_960
*&---------------------------------------------------------------------*
*&      Form  EXE_960_SAVE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM EXE_960_SAVE .

  CLEAR GV_ANSWER .

  %%POPUP_TO_CONFIRM_STEP '입력하신 Data를 저장하시겠습니까?' ' '
  '저장'.


  IF GV_ANSWER = 'J'.
    PERFORM SAVE_ZQMT0018M.

  ENDIF.
ENDFORM.                    " EXE_960_SAVE
*&---------------------------------------------------------------------*
*&      Form  EXE_960_OKAY
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM EXE_960_OKAY .

  CLEAR GV_ANSWER .

  %%POPUP_TO_CONFIRM_STEP '변경한 데이터는 저장되지 않습니다. ' ' '
  '확인'.


  IF GV_ANSWER = 'J'.
    CLEAR : GT_ZQMT0018M[] , GS_ZQMT0018M .
    PERFORM OBJ_DESTROY CHANGING G_CUSTOM_C960
                             G_GRID_960.
    LEAVE TO SCREEN 0.
  ELSE.
    EXIT.
  ENDIF.

ENDFORM.                    " EXE_960_OKAY
*&---------------------------------------------------------------------*
*&      Form  PRO_LAYOUT_POPU_960
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GS_LAYOUT960  text
*----------------------------------------------------------------------*
FORM PRO_LAYOUT_POPU_960  USING    P_LAYOCAT TYPE LVC_S_LAYO.
  P_LAYOCAT-CWIDTH_OPT = 'X'.
  P_LAYOCAT-SEL_MODE = 'A'.
  P_LAYOCAT-BOX_FNAME = 'ZCHK'.
  P_LAYOCAT-SMALLTITLE = 'X'.

ENDFORM.                    " PRO_LAYOUT_POPU_960
*&---------------------------------------------------------------------*
*&      Form  EVENT_HANDLER_REGISTER_960
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM EVENT_HANDLER_REGISTER_960 .

* class 선언
  CREATE OBJECT G_EVENT_960.

* Edit  이벤트 등록
  CALL METHOD G_GRID_960->REGISTER_EDIT_EVENT
    EXPORTING
      I_EVENT_ID = CL_GUI_ALV_GRID=>MC_EVT_MODIFIED.

* set editable cells to ready for input
  CALL METHOD G_GRID_960->SET_READY_FOR_INPUT
    EXPORTING
      I_READY_FOR_INPUT = 1.


* DATA_CHANGED event
  SET HANDLER G_EVENT_960->HANDLE_DATA_CHANGED_960 FOR G_GRID_960.

ENDFORM.                    " EVENT_HANDLER_REGISTER_960
*&---------------------------------------------------------------------*
*&      Form  SAVE_ZQMT0018M
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM SAVE_ZQMT0018M .
*
  CLEAR GS_ZQMT0018M.
  READ TABLE GT_ZQMT0018M INTO  GS_ZQMT0018M WITH KEY MBLNR = ''.
  IF SY-SUBRC = 0.
    MESSAGE E001 WITH '문서 번호를 확인해주세요' .
    EXIT.
  ENDIF.

  READ TABLE GT_ZQMT0018M  INTO  GS_ZQMT0018M  WITH  KEY GJAHR = ''.
  IF SY-SUBRC = 0.
    MESSAGE E001 WITH '문서 번호를 확인해세요' .
    EXIT.
  ENDIF.

  READ TABLE GT_ZQMT0018M  INTO  GS_ZQMT0018M  WITH KEY CPERNR = ''.
  IF SY-SUBRC = 0.
    MESSAGE E001 WITH '사번을 확인해세요' .
    EXIT.
  ENDIF.

  READ TABLE GT_ZQMT0018M  INTO  GS_ZQMT0018M  WITH KEY CPERNRT = ''.
  IF SY-SUBRC = 0.
    MESSAGE E001 WITH '사원명을 확인해세요' .
    EXIT.
  ENDIF.

  DELETE FROM ZQMT0018M
  WHERE RCEPNO EQ GS_100-RCEPNO.


  CLEAR GS_ZQMT0018M.
  LOOP AT GT_ZQMT0018M INTO GS_ZQMT0018M.

    GS_ZQMT0018M-ERDAT = SY-DATUM.
    GS_ZQMT0018M-AEDAT  = SY-DATUM.

    INSERT    ZQMT0018M  FROM  GS_ZQMT0018M.

    CLEAR GS_ZQMT0018M.
  ENDLOOP.

  IF SY-SUBRC EQ 0.
    MESSAGE S001 WITH '자재문서를 정상적으로 저장하였습니다.'.
  ENDIF.
  CLEAR : GT_ZQMT0018M[] , GS_ZQMT0018M .
  PERFORM OBJ_DESTROY CHANGING G_CUSTOM_C960
                         G_GRID_960.
  LEAVE TO SCREEN 0.


ENDFORM.                    " SAVE_ZQMT0018M
*&---------------------------------------------------------------------*
*&      Form  CHECK_FAULTDETAIL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM CHECK_FAULTDETAIL .
  DATA : L_RCEPNO LIKE ZQMT0011B-RCEPNO.
*  불만제품에는 불만유형이 반드시 입력되어야함.
*  GT_100 : 불만제품정보,
* 고객불만(불만배치) ZQMT0011B  GT_110
*  고객불만(불만유형)ZQMT0012N  GT_120
  LOOP AT GT_100 .
*    READ TABLE GT_110  WITH KEY RCEPNO = GT_100-RCEPNO
*                               ZMATSEQ = GT_100-ZMATSEQ.
    SELECT SINGLE RCEPNO
      INTO L_RCEPNO
      FROM ZQMT0011B
     WHERE RCEPNO = GT_100-RCEPNO
       AND ZMATSEQ = GT_100-ZMATSEQ.

    IF SY-SUBRC <> 0.
*      MESSAGE E001 WITH TEXT-E23.
*  2012.11.02 수정 (C20121024_05510)
      CLEAR OK_SAVE.
      MESSAGE E001  WITH  '자재/불량정보 결함유형을 입력하세요.'
      DISPLAY LIKE 'I'.
    ENDIF.

*    READ TABLE GT_120  WITH KEY BUKRS = G_BUKRS
*                               RCEPNO = GT_100-RCEPNO
*                               ZMATSEQ = GT_100-ZMATSEQ.
    SELECT SINGLE RCEPNO
      INTO L_RCEPNO
      FROM ZQMT0012N
     WHERE RCEPNO = GT_100-RCEPNO
       AND ZMATSEQ = GT_100-ZMATSEQ
       AND BUKRS = G_BUKRS.
    IF SY-SUBRC <> 0.
*      MESSAGE E001 WITH TEXT-E23.
*  2012.11.02 수정 (C20121024_05510)
      CLEAR OK_SAVE.
      MESSAGE E001  WITH  '자재/불량정보 결함유형을 입력하세요.'
      DISPLAY LIKE 'I'.
    ENDIF.
  ENDLOOP.

ENDFORM.                    " CHECK_FAULTDETAIL
*&---------------------------------------------------------------------*
*&      Form  CHECK_SALES
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM CHECK_SALES .
* C20120417_91448 전표 생성 시 영업정보 체크
*GS_100-VKBUR  "영업팀
*GS_100-VKGRP  " 영업그룹
*GS_100-VTWEG "유통경로
*S_100-SPGCD  "제품군

  IF GS_100-VKBUR = ''.        "영업팀
    MESSAGE E003 WITH '개요에 있는 영업팀 정보를 입력하세요'.
  ELSEIF  GS_100-VKGRP = ''.   "영업그룹
    MESSAGE E003 WITH '개요에 있는 영업그룹 정보를 입력하세요'.
  ELSEIF  GS_100-VTWEG = ''.   "유통경로
    MESSAGE E003 WITH '개요에 있는 유통경로 정보를 입력하세요'.
  ELSEIF  GS_100-SPGCD = ''.   "제품군
    MESSAGE E003 WITH '개요에 있는 제품군 정보를 입력하세요'.
  ENDIF.


ENDFORM.                    " CHECK_SALES
*ENDFORM.                    " VKBUR_READ_CHANGE
*&---------------------------------------------------------------------*
*&      Form  VKBUR_READ_CHANGE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_VKBUR  text
*      <--P_VKBURT  text
*----------------------------------------------------------------------*
FORM VKBUR_READ_CHANGE  CHANGING VALUE(P_VKBUR)
                                 VALUE(P_VKBURT).

  IF G_BUKRS = ''.
    GET PARAMETER ID 'BUK' FIELD G_BUKRS.
  ENDIF.

*-  LSM에 한함
*-  ZLOCK 칼럼 추가 : Y 값은 비용제한함. N 값은 비용 제한 안함.
*-  더 이상 사용 안하는 영업팀도 당해로 등록할것임.
*-  신규 영업팀은 당해년도로 등록하고 더 이상 사용하지 않는 영업팀도 당해로 등록함.
*-  신규 영업팀은 ZLOCK 칼럼을 사용안함.
*-  미사용 영업팀 만 ZLOCK 칼럼을 사용하여 Y 면 통제, N 이면 통제 안함.

*  SELECT SINGLE VKBUR BEZEI
*    INTO (P_VKBUR, P_VKBURT)
*    FROM ZCOTA031
*   WHERE KOKRS = G_BUKRS
*     AND VKGRP = GS_100-VKGRP
*     AND GJAHR = GS_100-RCEPDT(4).

  IF G_BUKRS EQ '3000'. "LSM
    SELECT SINGLE VKBUR BEZEI
      INTO (P_VKBUR, P_VKBURT)
      FROM ZCOTA031
     WHERE KOKRS = G_BUKRS
       AND VKGRP = GS_100-VKGRP
       AND GJAHR = GS_100-RCEPDT(4)
       AND ZLOCK = ''. "매출/비용 제한필드 (공백:
  ELSE.
    SELECT SINGLE VKBUR BEZEI
      INTO (P_VKBUR, P_VKBURT)
      FROM ZCOTA031
     WHERE KOKRS = G_BUKRS
       AND VKGRP = GS_100-VKGRP
       AND GJAHR = GS_100-RCEPDT(4).

  ENDIF.

  IF  SY-SUBRC NE 0
    OR (  SY-SUBRC EQ 0 AND P_VKBUR EQ '' ).
    MESSAGE E002 WITH
    '선택한 영업그룹과 매핑된 영업팀 정보가 없습니다.'
    '영업그룹을 재 선택하세요.'.
  ENDIF.

ENDFORM.                    " VKBUR_READ_CHANGE
*&---------------------------------------------------------------------*
*&      Form  BDC_GLPOST_CREATE1
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_ZQMS301_RCEPNO  text
*----------------------------------------------------------------------*
FORM BDC_GLPOST_CREATE1  USING    VALUE(P_RCEPNO).
  DATA: LV_WRBTR(16),
        LV_WAERK     TYPE VBAK-WAERK,
        LS_EXCH_RATE TYPE BAPI1093_0,
        LV_FLG,
        LS_RETURN    TYPE BAPIRET1,
        LV_DEC       TYPE TCURX-CURRDEC,
        LV_RFAMT     TYPE ZQRFAMT,
        L_TCODE      LIKE SY-TCODE,
        LV_BELNR     LIKE BKPF-BELNR,
        LV_MONAT     LIKE BKPF-MONAT.

*//편철사업장 Logic 의 Data 선언
  DATA : LV_BUPLA LIKE ZFIT0064-BUPLA,
         L_PERNR  LIKE ZPA0105-PERNR,
         L_USRID  LIKE ZPA0105-USRID.

*//지급방법, 지급일 의 Data 선언
  DATA : LV_ZLSCH LIKE VBSEGK-ZLSCH,
         LV_ZFBDT LIKE VBSEGK-ZFBDT.

*//세금계산 의 Data 선언
  DATA : W_KSCHL   LIKE KONP-KSCHL, "조건유형
         TEXT4(50),
         W_KBETR   LIKE KONP-KBETR,
         G_RATE    LIKE KONP-KBETR.
  DATA : BEGIN OF IT_KSCHL OCCURS 0,
           KSCHL LIKE KONP-KSCHL,
         END OF IT_KSCHL.
  DATA : LV_WRBTR2(16).

*--{기능개선_49298 - 추가
  DATA : LV_ZZWRBTR(13) TYPE C.
  DATA : LV_ZZFWBAS(13) TYPE C.
  DATA : LV_STCD2 LIKE LFA1-STCD2.
  DATA : LV_LIFNR LIKE LFA1-LIFNR.
*--}기능개선_49298 2014.10.24

  CLEAR   : GT_BDC, MESSTAB, GT_ZFIT0066,
            LV_WRBTR, LV_WAERK, LS_EXCH_RATE, LV_FLG, LS_RETURN, LV_DEC,
            LV_RFAMT, L_TCODE, LV_BELNR, LV_MONAT,
            LV_BUPLA, L_PERNR, L_USRID, LV_ZLSCH, LV_ZFBDT, LV_WRBTR,
            LV_ZLSCH, LV_ZFBDT, W_KSCHL, TEXT4, W_KBETR, G_RATE,
            IT_KSCHL, IT_KSCHL[],
            LV_STCD2, LV_LIFNR. "기능개선_49298

  REFRESH : GT_BDC, MESSTAB, GT_ZFIT0066.

*// check
*->[가온전선]--------------------CHG S
  IF ZQMS301-BUPLA(1) NE '6'.
    MESSAGE I001 WITH '편철사업장은 6로 시작하는 것만 가능합니다.'.
    G_930_FORM_FLG = 'X'.
  ENDIF.

*  IF ZQMS301-BUKRS EQ '6000' AND ZQMS301-BUPLA(1) NE '1'.
*    MESSAGE I001 WITH '편철사업장은 1로 시작하는 것만 가능합니다.'.
*    G_930_FORM_FLG = 'X'.
*  ENDIF.
*
*  IF ZQMS301-BUKRS EQ '2000' AND ZQMS301-BUPLA(1) NE '2'.
*    MESSAGE I001 WITH '편철사업장은 2로 시작하는 것만 가능합니다.'.
*    G_930_FORM_FLG = 'X'.
*  ENDIF.
*
*  IF ZQMS301-BUKRS EQ '3000' AND ZQMS301-BUPLA(1) NE '3'.
*    MESSAGE I001 WITH '편철사업장은 3로 시작하는 것만 가능합니다.'.
*    G_930_FORM_FLG = 'X'.
*  ENDIF.
*-<[가온전선]--------------------CHG E

*//편철사업장 Logic
  L_PERNR = ZQMS301-CPERNR  .
  CALL FUNCTION 'Z_QM_GET_USERID'
    EXPORTING
      I_PERNR = L_PERNR
    IMPORTING
      E_USRID = L_USRID.

  IF L_USRID = ''.
    MESSAGE I001 WITH 'ID/직무 관리 프로그램에 SAP ID등록 바랍니다.'.
    G_930_FORM_FLG = 'X'.
  ENDIF.

  SELECT SINGLE BUPLA
    FROM ZFIT0064
    INTO LV_BUPLA
    WHERE BNAME = L_USRID.

  IF LV_BUPLA = ''.
    MESSAGE I001 WITH '편철사업장이 지정되어있지 않은 생성자 입니다'.
    G_930_FORM_FLG = 'X'.
  ENDIF.

  CHECK G_930_FORM_FLG EQ ''.

*--{자체개선_58376 수정 - LV_WRBTR -> LV_WRBTR301
*// BDC화면 입력 금액
  DATA : LV_WRBTR301(16).
  CLEAR : LV_WRBTR301.

  LV_WAERK = ZQMS301-WAERS.
  IF LV_WAERK IS NOT INITIAL.
    SELECT SINGLE CURRDEC
             INTO LV_DEC
             FROM TCURX
            WHERE CURRKEY EQ LV_WAERK.
    IF SY-SUBRC EQ 0.
      IF LV_DEC > 0.
        LV_WRBTR301 = ZQMS301-WRBTR * ( 100 / 10 ** LV_DEC ).
      ELSE.
        LV_WRBTR301 = ZQMS301-WRBTR * 100.
      ENDIF.
    ELSE.
      LV_WRBTR301 = ZQMS301-WRBTR.
    ENDIF.
  ENDIF.
  WRITE LV_WRBTR301 TO LV_WRBTR301 CURRENCY LV_WAERK.
*--}자체개선_58376 2014.12.24

*-- 부가세 종류(매출/매입) 구분
  CLEAR T007A.
  SELECT SINGLE * FROM T007A WHERE KALSM = 'TAXKR'  AND
                                   MWSKZ = ZQMS301-MWSKZ.
  IF SY-SUBRC = 0.
    IF T007A-MWART = 'A'.          " 매출부가세
      W_KSCHL = 'KROT'.
    ELSEIF T007A-MWART = 'V'.      " 매입부가세
      CLEAR: IT_KSCHL[], IT_KSCHL.
      SELECT KSCHL INTO TABLE IT_KSCHL
       FROM KONP WHERE KAPPL = 'TX'  AND
*                                        kschl = w_kschl  AND
                       MWSK1 = ZQMS301-MWSKZ.
      LOOP AT IT_KSCHL.
        IF IT_KSCHL-KSCHL+0(2) = 'KR'.
          W_KSCHL = IT_KSCHL-KSCHL.
          TEXT4+46(4) = W_KSCHL.
        ENDIF.
        IF ZFIT0066-ZZMWSKZ = 'V3'.
          W_KSCHL = 'KRIT'.
          TEXT4+46(4) = W_KSCHL.
        ENDIF.
      ENDLOOP.
    ENDIF.
  ENDIF.

*-- 세율을 가져온다....
*// v3인경우에는 다음과 같이 처리한다.

  SELECT SINGLE KBETR INTO W_KBETR
    FROM KONP WHERE KAPPL = 'TX'
     AND KSCHL = W_KSCHL
     AND MWSK1 = ZQMS301-MWSKZ.

  IF SY-SUBRC = 0.
    G_RATE = W_KBETR / 10.
    CLEAR : LV_WRBTR2.
    LV_WRBTR = ZQMS301-WRBTR.
    LV_WRBTR2 = LV_WRBTR.
    IF G_RATE <> 0.

      IF LV_WRBTR2 <> 0.
        GT_ZFIT0066-ZZFWBAS = ( LV_WRBTR2 / 11 )
                         - ( 5 / 1000 ).
        IF GT_ZFIT0066-ZZFWBAS < 0.
          GT_ZFIT0066-ZZFWBAS = 0.
        ENDIF.

        GT_ZFIT0066-ZZWRBTR =
        ( LV_WRBTR2 - GT_ZFIT0066-ZZFWBAS ).
      ENDIF.

      IF LV_WRBTR <> 0.
        GT_ZFIT0066-ZZFWBAS = ( LV_WRBTR / 11 )
                         - ( 5 / 1000 ) .
        IF GT_ZFIT0066-ZZFWBAS < 0.
          GT_ZFIT0066-ZZFWBAS = 0.
        ENDIF.

        GT_ZFIT0066-ZZWRBTR =
        ( LV_WRBTR - GT_ZFIT0066-ZZFWBAS ).

      ENDIF.


    ELSE.

      IF LV_WRBTR2 <> 0.
        GT_ZFIT0066-ZZWRBTR = LV_WRBTR2 .
      ENDIF.

      IF LV_WRBTR <> 0.
        GT_ZFIT0066-ZZWRBTR = LV_WRBTR .
      ENDIF.

      GT_ZFIT0066-ZZFWBAS = 0.

    ENDIF.

  ENDIF.

*// 손익센터
  SELECT SINGLE PRCTR INTO ZQMS301-PRCTR
                      FROM CSKS
                     WHERE KOKRS EQ ZQMS301-BUKRS
                       AND KOSTL EQ ZQMS301-KOSTL.

*--{기능개선_49298 - 추가
  CLEAR : LV_ZZWRBTR, LV_ZZFWBAS.
*--{자체개선_58376 - 수정
*  WRITE GT_ZFIT0066-ZZWRBTR TO LV_ZZWRBTR CURRENCY 'KRW'.
*  WRITE GT_ZFIT0066-ZZFWBAS TO LV_ZZFWBAS CURRENCY 'KRW'.
  WRITE GT_ZFIT0066-ZZWRBTR TO LV_ZZWRBTR CURRENCY ZQMS301-WAERS.
  WRITE GT_ZFIT0066-ZZFWBAS TO LV_ZZFWBAS CURRENCY ZQMS301-WAERS.
*--{자체개선_58376 2014.12.24

*--}기능개선_49298 2014.10.23

* BDC setting
  PERFORM STORE_BDCDATA   USING:
          'X'  'SAPLF040'          '0100',
          ' '  'BDC_OKCODE'        '/00',
          ' '  'BKPF-BLDAT'        ZQMS301-BLDAT,
          ' '  'BKPF-BLART'        ZQMS301-BLART,
          ' '  'BKPF-BUKRS'        ZQMS301-BUKRS,
          ' '  'BKPF-BUDAT'        ZQMS301-BUDAT,
          ' '  'BKPF-MONAT'        ZQMS301-MONAT,
          ' '  'BKPF-WAERS'        ZQMS301-WAERS,
          ' '  'BKPF-BKTXT'        ZQMS301-BKTXT,
          ' '  'RF05V-NEWBS'       ZQMS301-NEWBS2,
          ' '  'RF05V-NEWKO'       ZQMS301-NEWKO2.

  PERFORM STORE_BDCDATA   USING:
          'X'  'SAPLF040'          '0302',
          ' '  'BDC_OKCODE'        '/00',
          ' '  'BSEG-WRBTR'        LV_WRBTR301,        "금액
*          ' '  'BKPF-XMWST'        'X',             "세금계산
                                   "기능개선_49298
*          ' '  'BSEG-MWSKZ'        ZQMS301-MWSKZ,   "세금코드
          ' '  'BSEG-BUPLA'        ZQMS301-BUPLA,   "사업장
          ' '  'BSEG-GSBER'        ZQMS301-GSBER,   "사업영역
          ' '  'RF05V-NEWBS'       ZQMS301-NEWBS1,
          ' '  'RF05V-NEWKO'       ZQMS301-NEWKO1,
          ' '  'BSEG-SGTXT'        ZQMS301-BKTXT.   "아이템text

*--{기능개선_49298 - 추가
  IF G_RATE <> 0.
    IF ZQMS301-MWSKZ = 'VC' OR ZQMS301-MWSKZ = 'VD'
    OR ZQMS301-MWSKZ = 'VE' OR ZQMS301-MWSKZ = 'VF'.
      PERFORM STORE_BDCDATA   USING:
                      ' '  'BSEG-MWSKZ'        ZQMS301-MWSKZ.
      "세금코드
    ELSE.
      PERFORM STORE_BDCDATA   USING:
                     ' '  'BSEG-MWSKZ'        'V0'.   "세금코드
    ENDIF.
  ELSE.
    PERFORM STORE_BDCDATA   USING:
                ' '  'BSEG-MWSKZ'        ZQMS301-MWSKZ.   "세금코드
  ENDIF.
*--}기능개선_49298 2014.10.24

  IF GV_EMPFK IS NOT INITIAL.
    PERFORM STORE_BDCDATA   USING:
          ' '  'BSEG-EMPFB'         GV_EMPFK.       "대체수취인
  ENDIF.

  PERFORM STORE_BDCDATA   USING:
          'X'  'SAPLF040'          '0300',
          ' '  'BDC_OKCODE'        '=COBL_XERGO',

          ' '  'BSEG-WRBTR'        LV_ZZWRBTR,"LV_WRBTR,
          ' '  'BSEG-BUPLA'        ZQMS301-BUPLA,   "사업장
                                   "기능개선_49298
*          ' '  'BSEG-MWSKZ'        ZQMS301-MWSKZ,   "세금코드
          ' '  'BSEG-SGTXT'        ZQMS301-BKTXT.   "아이템text

*--{기능개선_49298 - 추가
  IF G_RATE <> 0.
    IF ZQMS301-MWSKZ = 'VC' OR ZQMS301-MWSKZ = 'VD'
    OR ZQMS301-MWSKZ = 'VE' OR ZQMS301-MWSKZ = 'VF'.
      PERFORM STORE_BDCDATA   USING:
                      ' '  'BSEG-MWSKZ'        ZQMS301-MWSKZ.
      "세금코드
    ELSE.
      PERFORM STORE_BDCDATA   USING:
                     ' '  'BSEG-MWSKZ'        'V0'.   "세금코드
    ENDIF.
  ELSE.
    PERFORM STORE_BDCDATA   USING:
                ' '  'BSEG-MWSKZ'        ZQMS301-MWSKZ.   "세금코드
  ENDIF.
*--}기능개선_49298 2014.10.24

*  PERFORM STORE_BDCDATA   USING:
*          'X'  'SAPLKACB'          '0002',
*          ' '  'BDC_OKCODE'        '=COBL_XERGO'.

  PERFORM STORE_BDCDATA   USING:
          'X'  'SAPLKEAK'          '0400',
          ' '  'BDC_OKCODE'        '=WEIT',
          ' '  'RKEAK-FIELD(02)'   ZQMS301-KUNUM,  "고객
          ' '  'RKEAK-FIELD(03)'   ZQMS301-WERKS,  "플랜트
          ' '  'RKEAK-FIELD(04)'   ZQMS301-MATNR,  "제품번호
          ' '  'RKEAK-FIELD(05)'   GS_100-SPGCD,   "제품군
          ' '  'RKEAK-FIELD(06)'   ZQMS301-PRCTR,  "손익센터
          ' '  'RKEAK-FIELD(07)'   ZQMS301-KOSTL,  "코스트센터
          ' '  'RKEAK-FIELD(08)'   ZQMS301-BUKRS,
                                   "ZQMS301-KUNUM, "영업조직
          ' '  'RKEAK-FIELD(09)'   GS_100-VTWEG,   "유통경로
          ' '  'RKEAK-FIELD(10)'   GS_100-VKBUR,   "영업팀
          ' '  'RKEAK-FIELD(11)'   GS_100-VKGRP.   "영업그룹

*--{기능개선_49298 - 추가

  IF GT_ZFIT0066-ZZFWBAS <> 0.
    PERFORM STORE_BDCDATA   USING:
                'X'    'SAPLF040'           '0300',
        ' '    'BDC_OKCODE'         '/00',
        ' '    'RF05V-NEWBS'        '40',
        ' '    'RF05V-NEWKO'        '1220101'.

    PERFORM STORE_BDCDATA   USING:
          'X'    'SAPLF040'           '0312',
          ' '    'BDC_OKCODE'         '=PBBP',
          ' '    'BSEG-WRBTR'         LV_ZZFWBAS,
          ' '    'BSEG-FWBAS'         LV_ZZWRBTR,
          ' '    'BSEG-MWSKZ'        ZQMS301-MWSKZ,   "세금코드
          ' '    'BSEG-BUPLA'         ZQMS301-BUPLA,
          ' '    'BSEG-GSBER'         ZQMS301-GSBER,
          ' '    'BSEG-SGTXT'         ZQMS301-BKTXT.
  ELSE.
    PERFORM STORE_BDCDATA   USING:
            'X'  'SAPLF040'          '0300',
            ' '  'BDC_OKCODE'        '=PBBP'.
  ENDIF.

  PERFORM STORE_BDCDATA   USING:
          'X'  'SAPLF040'          '0300',
          ' '  'BDC_OKCODE'        '=PBBP'.
*--}기능개선_49298 2014.10.24

*->[가온전선]--------------------CHG S
  "SAPMV45A userexit_save_document_prepare => check_qm 에서 IMPORT
  L_TCODE = 'ZGTSDR1250' .
*  L_TCODE = 'ZQM2R0696' .
*-<[가온전선]--------------------CHG E
  EXPORT L_TCODE TO MEMORY ID 'BDC_CALLER'.

  PERFORM BDC_TRANSACTION  USING     'FBV1'
                                     G_DIMODE
                           CHANGING  G_SUBRC.

  READ TABLE MESSTAB WITH KEY MSGTYP = 'I' MSGNR = '001'.

  IF SY-SUBRC EQ 0.
    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
      EXPORTING
        INPUT  = SY-MSGV1
      IMPORTING
        OUTPUT = LV_BELNR.
    COMMIT WORK.
    MESSAGE S003  WITH '임시전표' LV_BELNR '을(를) 생성하였습니다'.
  ELSE.
    DESCRIBE TABLE MESSTAB.
    READ TABLE MESSTAB INDEX SY-TFILL.
    IF SY-SUBRC EQ 0.
      MESSAGE ID MESSTAB-MSGID TYPE 'S' NUMBER MESSTAB-MSGNR.
    ENDIF.
    EXIT.
  ENDIF.

  IF LV_BELNR IS NOT INITIAL.


*//기간
    SELECT SINGLE MONAT
      FROM BKPF
      INTO LV_MONAT
      WHERE BELNR = LV_BELNR
      AND GJAHR = ZQMS301-BUDAT+0(4)
      AND BUKRS = ZQMS301-BUKRS.

*//지급일, 지급방법
    SELECT SINGLE ZLSCH ZFBDT
      FROM VBSEGK
      INTO (LV_ZLSCH, LV_ZFBDT)
      WHERE BELNR = LV_BELNR
      AND GJAHR = ZQMS301-BUDAT+0(4)
      AND BUKRS = ZQMS301-BUKRS.

*--{기능개선_49298
*//사업자 등록정보

    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
      EXPORTING
        INPUT  = ZQMS301-NEWKO2
      IMPORTING
        OUTPUT = LV_LIFNR.

    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
      EXPORTING
        INPUT  = LV_LIFNR
      IMPORTING
        OUTPUT = LV_LIFNR.

    SELECT SINGLE STCD2
      FROM LFA1
      INTO LV_STCD2
     WHERE LIFNR = LV_LIFNR.
*--}기능개선_49298 2014.10.29

    GT_ZFIT0066-BUKRS = ZQMS301-BUKRS.         "회사코드
    GT_ZFIT0066-GJAHR = ZQMS301-BUDAT+0(4).    "회계년도
    GT_ZFIT0066-BLDAT = ZQMS301-BLDAT.         "증빙일
    GT_ZFIT0066-INPUT_TYPE = 'ZZK'.            "입력유형
    GT_ZFIT0066-BSTAT = 'V'.                   "전표상태
    GT_ZFIT0066-BLART = ZQMS301-BLART.         "전표유형
    GT_ZFIT0066-BUDAT = ZQMS301-BUDAT.         "전기일
    GT_ZFIT0066-MONAT = LV_MONAT.              "기간
    GT_ZFIT0066-CPUDT = SY-DATLO.              "입력일
    GT_ZFIT0066-WAERS = ZQMS301-WAERS.         "통화
    GT_ZFIT0066-BKTXT = ZQMS301-BKTXT.         "TEXT
    GT_ZFIT0066-CPUTM = SY-UZEIT.              "입력시간
    GT_ZFIT0066-BNAME = SY-UNAME.              "사용자ID
    GT_ZFIT0066-BNAME2 = ZQMS301-CPERNR.       "사용자 사번
    GT_ZFIT0066-STAT = 'R'.                    "전표상태(확정요청)
    GT_ZFIT0066-BUPLA = LV_BUPLA.              "편철사업장
    GT_ZFIT0066-GSBER = ZQMS301-GSBER.         "사업영역
    GT_ZFIT0066-ZZBUSINESSNO = GV_EMPFK.       "대체수취인
    GT_ZFIT0066-ZZBUPLA = ZQMS301-BUPLA.       "사업장
    GT_ZFIT0066-ZZMWSKZ = ZQMS301-MWSKZ.       "세금코드
    GT_ZFIT0066-ZZKUNNR = ZQMS301-NEWKO2.      "공급업체 계정
    GT_ZFIT0066-ZZFBDT = LV_ZFBDT.             "지급일
    GT_ZFIT0066-ZZLSCH = LV_ZLSCH.             "지급방법
    GT_ZFIT0066-ZZPAYMENT_AMT = ZQMS301-WRBTR ."지급금액
    GT_ZFIT0066-ZZBUSINESSNO = LV_STCD2.       "사업자등록번호
    "기능개선_49298

    MOVE-CORRESPONDING GT_ZFIT0066 TO ZFIT0066.
    ZFIT0066-BELNR = LV_BELNR.

    MODIFY ZFIT0066.

    PERFORM UPDATE_BA1 USING ZQMS301-BUKRS
                            LV_BELNR
                            ZQMS301-BUDAT+0(4)
                            ZQMS301-CPERNR
                            ZQMS301-CPERNRT
                            ZQMS301-CNAM
                            ZQMS301-CNAMT.

    PERFORM GET_BA_LIST .
    PERFORM REFRESH_GRID_930.

  ENDIF.

ENDFORM.                    " BDC_GLPOST_CREATE1
*&---------------------------------------------------------------------*
*&      Form  BDC_GLPOST_CREATE1
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_ZQMS301_RCEPNO  text
*----------------------------------------------------------------------*
FORM BDC_GLPOST_CREATE1_NEW  TABLES PT_BBKPF STRUCTURE BBKPF
                                     PT_BBSEG STRUCTURE BBSEG
                               USING VALUE(P_RCEPNO).
  DATA: LV_WRBTR(16),
        LV_WAERK     TYPE VBAK-WAERK,
        LS_EXCH_RATE TYPE BAPI1093_0,
        LV_FLG,
        LS_RETURN    TYPE BAPIRET1,
        LV_DEC       TYPE TCURX-CURRDEC,
        LV_RFAMT     TYPE ZQRFAMT,
        L_TCODE      LIKE SY-TCODE,
        LV_BELNR     LIKE BKPF-BELNR,
        LV_MONAT     LIKE BKPF-MONAT,
        LV_MSG(100).

*//편철사업장 Logic 의 Data 선언
  DATA : LV_BUPLA LIKE ZFIT0064-BUPLA,
         L_PERNR  LIKE ZPA0105-PERNR,
         L_USRID  LIKE ZPA0105-USRID.

*//지급방법, 지급일 의 Data 선언
  DATA : LV_ZLSCH LIKE VBSEGK-ZLSCH,
         LV_ZFBDT LIKE VBSEGK-ZFBDT.

*//세금계산 의 Data 선언
  DATA : W_KSCHL   LIKE KONP-KSCHL, "조건유형
         TEXT4(50),
         W_KBETR   LIKE KONP-KBETR,
         G_RATE    LIKE KONP-KBETR.
  DATA : BEGIN OF IT_KSCHL OCCURS 0,
           KSCHL LIKE KONP-KSCHL,
         END OF IT_KSCHL.
  DATA : LV_WRBTR2(16).

*--{기능개선_49298 - 추가
  DATA : LV_ZZWRBTR(13) TYPE C.
  DATA : LV_ZZFWBAS(13) TYPE C.
  DATA : LV_STCD2 LIKE LFA1-STCD2.
  DATA : LV_LIFNR LIKE LFA1-LIFNR.
*--}기능개선_49298 2014.10.24

  CLEAR   : GT_BDC, MESSTAB, GT_ZFIT0066,
            LV_WRBTR, LV_WAERK, LS_EXCH_RATE, LV_FLG, LS_RETURN, LV_DEC,
            LV_RFAMT, L_TCODE, LV_BELNR, LV_MONAT,
            LV_BUPLA, L_PERNR, L_USRID, LV_ZLSCH, LV_ZFBDT, LV_WRBTR,
            LV_ZLSCH, LV_ZFBDT, W_KSCHL, TEXT4, W_KBETR, G_RATE,
            IT_KSCHL, IT_KSCHL[],
            LV_STCD2, LV_LIFNR. "기능개선_49298

  REFRESH : GT_BDC, MESSTAB, GT_ZFIT0066.

*// check
*->[가온전선]--------------------CHG S
  IF ZQMS301-BUPLA(1) NE '6'.
    MESSAGE I001 WITH '편철사업장은 6로 시작하는 것만 가능합니다.'.
    G_930_FORM_FLG = 'X'.
  ENDIF.


*  IF ZQMS301-BUKRS EQ '6000' AND ZQMS301-BUPLA(1) NE '1'.
*    MESSAGE I001 WITH '편철사업장은 1로 시작하는 것만 가능합니다.'.
*    G_930_FORM_FLG = 'X'.
*  ENDIF.
*
*  IF ZQMS301-BUKRS EQ '2000' AND ZQMS301-BUPLA(1) NE '2'.
*    MESSAGE I001 WITH '편철사업장은 2로 시작하는 것만 가능합니다.'.
*    G_930_FORM_FLG = 'X'.
*  ENDIF.
*
*  IF ZQMS301-BUKRS EQ '3000' AND ZQMS301-BUPLA(1) NE '3'.
*    MESSAGE I001 WITH '편철사업장은 3로 시작하는 것만 가능합니다.'.
*    G_930_FORM_FLG = 'X'.
*  ENDIF.
*-<[가온전선]--------------------CHG E

*//편철사업장 Logic
  L_PERNR = ZQMS301-CPERNR  .
  CALL FUNCTION 'Z_QM_GET_USERID'
    EXPORTING
      I_PERNR = L_PERNR
    IMPORTING
      E_USRID = L_USRID.

  IF L_USRID = ''.
    MESSAGE I001 WITH 'ID/직무 관리 프로그램에 SAP ID등록 바랍니다.'.
    G_930_FORM_FLG = 'X'.
  ENDIF.

  SELECT SINGLE BUPLA
    FROM ZFIT0064
    INTO LV_BUPLA
    WHERE BNAME = L_USRID.

  IF LV_BUPLA = ''.
    MESSAGE I001 WITH '편철사업장이 지정되어있지 않은 생성자 입니다'.
    G_930_FORM_FLG = 'X'.
  ENDIF.

  CHECK G_930_FORM_FLG EQ ''.

*--{자체개선_58376 수정 - LV_WRBTR -> LV_WRBTR301
*// BDC화면 입력 금액
  DATA : LV_WRBTR301(16).
  CLEAR : LV_WRBTR301.

  LV_WAERK = ZQMS301-WAERS.
  IF LV_WAERK IS NOT INITIAL.
    SELECT SINGLE CURRDEC
             INTO LV_DEC
             FROM TCURX
            WHERE CURRKEY EQ LV_WAERK.
    IF SY-SUBRC EQ 0.
      IF LV_DEC > 0.
        LV_WRBTR301 = ZQMS301-WRBTR * ( 100 / 10 ** LV_DEC ).
      ELSE.
        LV_WRBTR301 = ZQMS301-WRBTR * 100.
      ENDIF.
    ELSE.
      LV_WRBTR301 = ZQMS301-WRBTR.
    ENDIF.
  ENDIF.
  WRITE LV_WRBTR301 TO LV_WRBTR301 CURRENCY LV_WAERK.
*--}자체개선_58376 2014.12.24

*-- 부가세 종류(매출/매입) 구분
  CLEAR T007A.
  SELECT SINGLE * FROM T007A WHERE KALSM = 'TAXKR'  AND
                                   MWSKZ = ZQMS301-MWSKZ.
  IF SY-SUBRC = 0.
    IF T007A-MWART = 'A'.          " 매출부가세
      W_KSCHL = 'KROT'.
    ELSEIF T007A-MWART = 'V'.      " 매입부가세
      CLEAR: IT_KSCHL[], IT_KSCHL.
      SELECT KSCHL INTO TABLE IT_KSCHL
       FROM KONP WHERE KAPPL = 'TX'  AND
*                                        kschl = w_kschl  AND
                       MWSK1 = ZQMS301-MWSKZ.
      LOOP AT IT_KSCHL.
        IF IT_KSCHL-KSCHL+0(2) = 'KR'.
          W_KSCHL = IT_KSCHL-KSCHL.
          TEXT4+46(4) = W_KSCHL.
        ENDIF.
        IF ZFIT0066-ZZMWSKZ = 'V3'.
          W_KSCHL = 'KRIT'.
          TEXT4+46(4) = W_KSCHL.
        ENDIF.
      ENDLOOP.
    ENDIF.
  ENDIF.

*-- 세율을 가져온다....
*// v3인경우에는 다음과 같이 처리한다.

  SELECT SINGLE KBETR INTO W_KBETR
    FROM KONP WHERE KAPPL = 'TX'
     AND KSCHL = W_KSCHL
     AND MWSK1 = ZQMS301-MWSKZ.

  IF SY-SUBRC = 0.
    G_RATE = W_KBETR / 10.
    CLEAR : LV_WRBTR2.
    LV_WRBTR = ZQMS301-WRBTR.
    LV_WRBTR2 = LV_WRBTR.
    IF G_RATE <> 0.

      IF LV_WRBTR2 <> 0.
        GT_ZFIT0066-ZZFWBAS = ( LV_WRBTR2 / 11 )
                         - ( 5 / 1000 ).
        IF GT_ZFIT0066-ZZFWBAS < 0.
          GT_ZFIT0066-ZZFWBAS = 0.
        ENDIF.

        GT_ZFIT0066-ZZWRBTR =
        ( LV_WRBTR2 - GT_ZFIT0066-ZZFWBAS ).
      ENDIF.

      IF LV_WRBTR <> 0.
        GT_ZFIT0066-ZZFWBAS = ( LV_WRBTR / 11 )
                         - ( 5 / 1000 ) .
        IF GT_ZFIT0066-ZZFWBAS < 0.
          GT_ZFIT0066-ZZFWBAS = 0.
        ENDIF.

        GT_ZFIT0066-ZZWRBTR =
        ( LV_WRBTR - GT_ZFIT0066-ZZFWBAS ).

      ENDIF.


    ELSE.

      IF LV_WRBTR2 <> 0.
        GT_ZFIT0066-ZZWRBTR = LV_WRBTR2 .
      ENDIF.

      IF LV_WRBTR <> 0.
        GT_ZFIT0066-ZZWRBTR = LV_WRBTR .
      ENDIF.

      GT_ZFIT0066-ZZFWBAS = 0.

    ENDIF.

  ENDIF.

*// 손익센터
  SELECT SINGLE PRCTR INTO ZQMS301-PRCTR
                      FROM CSKS
                     WHERE KOKRS EQ ZQMS301-BUKRS
                       AND KOSTL EQ ZQMS301-KOSTL.

*--{기능개선_49298 - 추가
  CLEAR : LV_ZZWRBTR, LV_ZZFWBAS.
*--{자체개선_58376 - 수정
*  WRITE GT_ZFIT0066-ZZWRBTR TO LV_ZZWRBTR CURRENCY 'KRW'.
*  WRITE GT_ZFIT0066-ZZFWBAS TO LV_ZZFWBAS CURRENCY 'KRW'.
  WRITE GT_ZFIT0066-ZZWRBTR TO LV_ZZWRBTR CURRENCY ZQMS301-WAERS.
  WRITE GT_ZFIT0066-ZZFWBAS TO LV_ZZFWBAS CURRENCY ZQMS301-WAERS.
*--{자체개선_58376 2014.12.24

*--}기능개선_49298 2014.10.23


  CLEAR: PT_BBKPF[], PT_BBKPF, PT_BBSEG[], PT_BBSEG.

* 전표헤더정보
  PT_BBKPF-TCODE = 'FBV1'.
  PT_BBKPF-BLDAT = ZQMS301-BLDAT .
  PT_BBKPF-BLART = ZQMS301-BLART .
  PT_BBKPF-BUKRS = ZQMS301-BUKRS .
  PT_BBKPF-BUDAT = ZQMS301-BUDAT .
  PT_BBKPF-MONAT = ZQMS301-MONAT .
  PT_BBKPF-WAERS = ZQMS301-WAERS .
  PT_BBKPF-BKTXT = ZQMS301-BKTXT .
  APPEND PT_BBKPF.

* 라인아이템 1
  PT_BBSEG-NEWBS = ZQMS301-NEWBS2.
  PT_BBSEG-NEWKO = ZQMS301-NEWKO2.
  PT_BBSEG-WRBTR = LV_WRBTR301.      "금액
  PT_BBSEG-BUPLA = ZQMS301-BUPLA.    "사업장
  PT_BBSEG-GSBER = ZQMS301-GSBER.    "사업영역
  PT_BBSEG-SGTXT = ZQMS301-BKTXT.    "아이템text
*--{기능개선_49298 - 추가
  IF G_RATE <> 0.
    IF ZQMS301-MWSKZ = 'VC' OR ZQMS301-MWSKZ = 'VD'
    OR ZQMS301-MWSKZ = 'VE' OR ZQMS301-MWSKZ = 'VF'.
      PT_BBSEG-MWSKZ = ZQMS301-MWSKZ.    "세금코드
    ELSE.
      PT_BBSEG-MWSKZ = 'V0'.   "세금코드
    ENDIF.
  ELSE.
    PT_BBSEG-MWSKZ = ZQMS301-MWSKZ.    "세금코드
  ENDIF.
*--}기능개선_49298 2014.10.24

  IF GV_EMPFK IS NOT INITIAL.
    PT_BBSEG-EMPFB = GV_EMPFK.       "대체수취인
  ENDIF.
  APPEND PT_BBSEG. CLEAR PT_BBSEG.

* 라인아이템 2
  PT_BBSEG-NEWBS = ZQMS301-NEWBS1.
  PT_BBSEG-NEWKO = ZQMS301-NEWKO1.
  PT_BBSEG-WRBTR = LV_ZZWRBTR.       "금액
  PT_BBSEG-BUPLA = ZQMS301-BUPLA.    "사업장
  PT_BBSEG-SGTXT = ZQMS301-BKTXT.    "아이템text
*--{기능개선_49298 - 추가
  IF G_RATE <> 0.
    IF ZQMS301-MWSKZ = 'VC' OR ZQMS301-MWSKZ = 'VD'
    OR ZQMS301-MWSKZ = 'VE' OR ZQMS301-MWSKZ = 'VF'.
      PT_BBSEG-MWSKZ = ZQMS301-MWSKZ.    "세금코드
    ELSE.
      PT_BBSEG-MWSKZ = 'V0'.   "세금코드
    ENDIF.
  ELSE.
    PT_BBSEG-MWSKZ = ZQMS301-MWSKZ.    "세금코드
  ENDIF.
*--}기능개선_49298 2014.10.24

  PT_BBSEG-RKE_BUKRS      = ZQMS301-BUKRS .
  PT_BBSEG-RKE_KNDNR      = ZQMS301-KUNUM .  "고객
  PT_BBSEG-RKE_WERKS      = ZQMS301-WERKS .  "플랜트
  PT_BBSEG-RKE_ARTNR      = ZQMS301-MATNR .  "제품번호
  PT_BBSEG-RKE_SPART      = GS_100-SPGCD  .  "제품군
  PT_BBSEG-RKE_PRCTR      = ZQMS301-PRCTR .  "손익센터
  PT_BBSEG-RKE_COPA_KOSTL = ZQMS301-KOSTL .  "코스트센터
  PT_BBSEG-RKE_VKORG      = ZQMS301-BUKRS .  "영업조직
  PT_BBSEG-RKE_VTWEG      = GS_100-VTWEG  .  "유통경로
  PT_BBSEG-RKE_KMVKBU     = GS_100-VKBUR  .  "영업팀
*  PT_BBSEG-RKE_VKGRP     = GS_100-VKGRP .   "영업그룹
  PT_BBSEG-RKE_KMVKGR     = GS_100-VKGRP  .  "영업그룹
  APPEND PT_BBSEG. CLEAR PT_BBSEG.


* 라인아이템 3 세액
  IF GT_ZFIT0066-ZZFWBAS <> 0.
    PT_BBSEG-NEWBS = '40'.
    PT_BBSEG-NEWKO = '0001220101'.
    PT_BBSEG-WRBTR = LV_ZZFWBAS.
    PT_BBSEG-FWBAS = LV_ZZWRBTR.
    PT_BBSEG-MWSKZ = ZQMS301-MWSKZ.   "세금코드
    PT_BBSEG-BUPLA = ZQMS301-BUPLA.
    PT_BBSEG-GSBER = ZQMS301-GSBER.
    PT_BBSEG-SGTXT = ZQMS301-BKTXT.
  ENDIF.

*->[가온전선]--------------------CHG S
  "FI 유효성점검 'ZGGBR000 => UF112  FM 'ZFI_CHECK_QMCOST_ROL'에서 IMPORT
  L_TCODE = 'ZGTSDR1250' .
*  L_TCODE = 'ZQM2R0696' .
*-<[가온전선]--------------------CHG E
  EXPORT L_TCODE TO MEMORY ID 'BDC_CALLER'.

* 전표생성 펑션 Call
  CLEAR: LV_BELNR, LV_MSG.
  CALL FUNCTION 'ZFI_DOCUMENT_POSTING'
    EXPORTING
      I_BDC_MODE  = G_DIMODE
      I_MESSAGE   = ''
    IMPORTING
      E_BELNR     = LV_BELNR
      E_RESULTMSG = LV_MSG
    TABLES
      T_BBKPF     = PT_BBKPF
      T_BBSEG     = PT_BBSEG.

  IF NOT LV_BELNR IS INITIAL.
    MESSAGE S003  WITH '임시전표' LV_BELNR '을(를) 생성하였습니다'.
  ELSE.
    MESSAGE S001 WITH LV_MSG.   EXIT.
  ENDIF.

  IF LV_BELNR IS NOT INITIAL.


*//기간
    SELECT SINGLE MONAT
      FROM BKPF
      INTO LV_MONAT
      WHERE BELNR = LV_BELNR
      AND GJAHR = ZQMS301-BUDAT+0(4)
      AND BUKRS = ZQMS301-BUKRS.

*//지급일, 지급방법
    SELECT SINGLE ZLSCH ZFBDT
      FROM VBSEGK
      INTO (LV_ZLSCH, LV_ZFBDT)
      WHERE BELNR = LV_BELNR
      AND GJAHR = ZQMS301-BUDAT+0(4)
      AND BUKRS = ZQMS301-BUKRS.

*--{기능개선_49298
*//사업자 등록정보

    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
      EXPORTING
        INPUT  = ZQMS301-NEWKO2
      IMPORTING
        OUTPUT = LV_LIFNR.

    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
      EXPORTING
        INPUT  = LV_LIFNR
      IMPORTING
        OUTPUT = LV_LIFNR.

    SELECT SINGLE STCD2
      FROM LFA1
      INTO LV_STCD2
     WHERE LIFNR = LV_LIFNR.
*--}기능개선_49298 2014.10.29

    GT_ZFIT0066-BUKRS = ZQMS301-BUKRS.         "회사코드
    GT_ZFIT0066-GJAHR = ZQMS301-BUDAT+0(4).    "회계년도
    GT_ZFIT0066-BLDAT = ZQMS301-BLDAT.         "증빙일
    GT_ZFIT0066-INPUT_TYPE = 'ZZK'.            "입력유형
    GT_ZFIT0066-BSTAT = 'V'.                   "전표상태
    GT_ZFIT0066-BLART = ZQMS301-BLART.         "전표유형
    GT_ZFIT0066-BUDAT = ZQMS301-BUDAT.         "전기일
    GT_ZFIT0066-MONAT = LV_MONAT.              "기간
    GT_ZFIT0066-CPUDT = SY-DATLO.              "입력일
    GT_ZFIT0066-WAERS = ZQMS301-WAERS.         "통화
    GT_ZFIT0066-BKTXT = ZQMS301-BKTXT.         "TEXT
    GT_ZFIT0066-CPUTM = SY-UZEIT.              "입력시간
    GT_ZFIT0066-BNAME = SY-UNAME.              "사용자ID
    GT_ZFIT0066-BNAME2 = ZQMS301-CPERNR.       "사용자 사번
    GT_ZFIT0066-STAT = 'R'.                    "전표상태(확정요청)
    GT_ZFIT0066-BUPLA = LV_BUPLA.              "편철사업장
    GT_ZFIT0066-GSBER = ZQMS301-GSBER.         "사업영역
    GT_ZFIT0066-ZZBUSINESSNO = GV_EMPFK.       "대체수취인
    GT_ZFIT0066-ZZBUPLA = ZQMS301-BUPLA.       "사업장
    GT_ZFIT0066-ZZMWSKZ = ZQMS301-MWSKZ.       "세금코드
    GT_ZFIT0066-ZZKUNNR = ZQMS301-NEWKO2.      "공급업체 계정
    GT_ZFIT0066-ZZFBDT = LV_ZFBDT.             "지급일
    GT_ZFIT0066-ZZLSCH = LV_ZLSCH.             "지급방법
    GT_ZFIT0066-ZZPAYMENT_AMT = ZQMS301-WRBTR ."지급금액
    GT_ZFIT0066-ZZBUSINESSNO = LV_STCD2.       "사업자등록번호
    "기능개선_49298

    MOVE-CORRESPONDING GT_ZFIT0066 TO ZFIT0066.
    ZFIT0066-BELNR = LV_BELNR.

    MODIFY ZFIT0066.

    PERFORM UPDATE_BA1 USING ZQMS301-BUKRS
                            LV_BELNR
                            ZQMS301-BUDAT+0(4)
                            ZQMS301-CPERNR
                            ZQMS301-CPERNRT
                            ZQMS301-CNAM
                            ZQMS301-CNAMT.

    PERFORM GET_BA_LIST .
    PERFORM REFRESH_GRID_930.

  ENDIF.

ENDFORM.                    " BDC_GLPOST_CREATE1_NEW
*&---------------------------------------------------------------------*
*&      Form  CHECK_WBS
*&---------------------------------------------------------------------*
FORM CHECK_WBS .

  DATA : LS_PROJ  TYPE PROJ.

  DATA : LV_PSPHI LIKE PRHI-PSPHI.
  DATA : LV_POSID LIKE ZQMT0011H-POSID.

  CLEAR : LV_PSPHI, LV_POSID.
  CLEAR : GV_CHK_WBS.

  IF GS_100-POSID IS NOT INITIAL.

    CALL FUNCTION 'CONVERSION_EXIT_ABPSN_INPUT'
      EXPORTING
        INPUT  = GS_100-POSID
      IMPORTING
        OUTPUT = LV_POSID.


*__ WBS코드 존재여부 체크
    SELECT SINGLE *
      FROM PRPS
     WHERE POSID EQ LV_POSID.


    IF SY-SUBRC = 0.

      SELECT SINGLE *
        FROM PRHI
       WHERE POSNR EQ PRPS-PSPNR
         AND UP    EQ ''.
      IF SY-SUBRC = 0.
        CALL FUNCTION 'CONVERSION_EXIT_ABPSN_OUTPUT'
          EXPORTING
            INPUT  = LV_POSID
          IMPORTING
            OUTPUT = GS_100-POSID.
      ELSE.
        MESSAGE S398(00) WITH 'WBS코드가 적합하지 않습니다.'
        DISPLAY LIKE 'E'.
        GV_CHK_WBS = 'X'.
        EXIT.
      ENDIF.

    ELSE.
      MESSAGE S398(00) WITH 'WBS코드가 존재하지 않습니다.'
      DISPLAY LIKE 'E'.
      GV_CHK_WBS = 'X'.
      EXIT.
    ENDIF.

  ENDIF.

ENDFORM.                    " CHECK_WBS
*&---------------------------------------------------------------------*
*&      Form  CHECK_USER_DEP
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_USER_ID  text
*      -->P_CORDI_ID  text
*      <--P_CHK  text
*----------------------------------------------------------------------*
FORM CHECK_USER_DEP  USING  P_SY_USER_ID
                           P_USER_ID
                  CHANGING P_CHK.

  DATA : L_USER_DEP  TYPE NAME_TEXT,
         L_CORDI_DEP TYPE NAME_TEXT.
* LS전선의 경우,
* 로그인 사용자 ID의 부서명과
* 고객불만의 코디네이터 ID의 부서명이 동일한지 확인한다
  SELECT SINGLE NAME_TEXTC
           FROM USER_ADDR
           INTO L_USER_DEP
          WHERE BNAME EQ P_SY_USER_ID.

  SELECT SINGLE NAME_TEXTC
           FROM USER_ADDR
           INTO L_CORDI_DEP
          WHERE BNAME EQ P_USER_ID.

  IF L_USER_DEP EQ L_CORDI_DEP.
    P_CHK = 'X'.
  ELSE.
    P_CHK = ''.
*->[가온전선]--------------------CHG S
    IF GV_SUSER EQ GC_X.
*    IF SY-UNAME EQ 'ZLSGQM1' OR SY-UNAME EQ 'ZLSGQM2' OR
*        SY-UNAME EQ 'ZLSGPP1'.
*-<[가온전선]--------------------CHG E
      P_CHK = 'X'.
    ENDIF.
  ENDIF.

ENDFORM.                    " CHECK_CORDI
*&---------------------------------------------------------------------*
*&      Form  CHECK_USER_CC
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_SY_UNAME  text
*      -->P_G_CODI  text
*      <--P_G_CODI_CHK  text
*----------------------------------------------------------------------*
FORM CHECK_USER_CC  USING    P_SY_USER_ID
                             P_USER_ID
                    CHANGING P_CHK.

  DATA : L_SY_USER_CC LIKE USR21-KOSTL,
         L_USER_CC    LIKE USR21-KOSTL.
* LS전선의 경우,
* 로그인 사용자 ID의 CC와
* 고객불만의 코디네이터 ID의 CC가 동일한지 확인한다
  SELECT SINGLE KOSTL
           FROM USR21
           INTO L_SY_USER_CC
          WHERE BNAME EQ P_SY_USER_ID.

  SELECT SINGLE KOSTL
           FROM USR21
           INTO L_USER_CC
          WHERE BNAME EQ P_USER_ID.

  IF L_SY_USER_CC IS NOT INITIAL AND
       L_USER_CC IS NOT INITIAL AND
       L_SY_USER_CC EQ L_USER_CC.
    P_CHK = 'X'.
  ELSE.
    P_CHK = ''.
  ENDIF.

ENDFORM.                    " CHECK_USER_CC
*&---------------------------------------------------------------------*
*& Form CALL_GOS
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GC_E
*&---------------------------------------------------------------------*
FORM CALL_GOS  USING    P_MODE.
  DATA:
    LV_MODE     TYPE C LENGTH 1,
    LS_OBJECT   TYPE SIBFLPORB,
    LV_SGS_FLAG TYPE SGS_FLAG.

  LS_OBJECT-INSTID = GS_100-RCEPNO.
  LS_OBJECT-TYPEID = GC_TYPEID_A.
  LS_OBJECT-CATID  = GC_CATID_A.


  LV_MODE = P_MODE.

  CALL FUNCTION 'GOS_ATTACHMENT_LIST_POPUP'
    EXPORTING
      IS_OBJECT       = LS_OBJECT
      IP_MODE         = LV_MODE
    IMPORTING
      EP_SAVE_REQUEST = LV_SGS_FLAG.

  IF LV_SGS_FLAG IS NOT INITIAL.
    COMMIT WORK AND WAIT.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHECK_ATTACH
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CHECK_ATTACH .
  DATA: LV_RELTYPE  TYPE SRGBTBREL-RELTYPE,
        LV_INSTID_A TYPE SRGBTBREL-INSTID_A,
        LV_TYPEID_A TYPE SRGBTBREL-TYPEID_A,
        LV_CATID_A  TYPE SRGBTBREL-CATID_A.

  LV_INSTID_A = GS_100-RCEPNO.
  LV_TYPEID_A = GC_TYPEID_A.
  LV_CATID_A  = GC_CATID_A.

  SELECT SINGLE BRELGUID
    FROM SRGBTBREL
   WHERE INSTID_A EQ @LV_INSTID_A
     AND TYPEID_A EQ @LV_TYPEID_A
     AND CATID_A  EQ @LV_CATID_A
    INTO @DATA(LV_BRELGUID).
  IF SY-SUBRC EQ 0.
    GS_100-ATTCH = ICON_ATTACHMENT.
  ELSE.
    CLEAR GS_100-ATTCH.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHECK_SUSER
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CHECK_SUSER .
  CLEAR:GV_SUSER.

  SELECT SINGLE FLD_02
    INTO @DATA(LV_FLD_02)
    FROM ZGTPPT1010
   WHERE MODULE_KIND  EQ 'SD'
     AND CODEGRP      EQ '6003'
     AND FLD_01       EQ @G_BUKRS
     AND FLD_02       EQ @SY-UNAME.
  IF SY-SUBRC EQ 0.
    GV_SUSER = GC_X.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form F4_VKBUR
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- GS_100_VKBUR
*&---------------------------------------------------------------------*
FORM F4_VKBUR  CHANGING PV_VAL.
  DATA : LT_RETURN TYPE TABLE OF DDSHRETVAL WITH HEADER LINE.
  DATA : LT_DYNPREAD TYPE TABLE OF DYNPREAD,
         LS_DYNPREAD TYPE DYNPREAD.

  RANGES : LR_VKGRP FOR TVBVK-VKGRP.

  LS_DYNPREAD-FIELDNAME = 'GS_100-VKGRP'.
  APPEND LS_DYNPREAD TO LT_DYNPREAD.

  CALL FUNCTION 'DYNP_VALUES_READ'
    EXPORTING
      DYNAME     = SY-CPROG
      DYNUMB     = SY-DYNNR
    TABLES
      DYNPFIELDS = LT_DYNPREAD.

  READ TABLE LT_DYNPREAD INTO LS_DYNPREAD INDEX 1.
  IF SY-SUBRC = 0 AND LS_DYNPREAD-FIELDVALUE IS NOT INITIAL.
    APPEND VALUE #( SIGN = 'I' OPTION = 'EQ' LOW = LS_DYNPREAD-FIELDVALUE )
       TO LR_VKGRP.
  ENDIF.

  SELECT DISTINCT A~VKBUR,B~BEZEI,A~VKGRP,C~BEZEI AS VKGRP_TXT
    FROM TVKBZ AS H INNER JOIN TVBVK AS A
                    ON H~VKBUR = A~VKBUR
                    INNER JOIN TVKBT AS B
                    ON A~VKBUR = B~VKBUR AND
                       B~SPRAS = @SY-LANGU
                    INNER JOIN TVGRT AS C
                    ON A~VKGRP = C~VKGRP AND
                       C~SPRAS = @SY-LANGU
   WHERE H~VKORG EQ @G_BUKRS
     AND A~VKGRP IN @LR_VKGRP
    INTO TABLE @DATA(LT_VALUE).
  SORT LT_VALUE BY VKBUR VKGRP.
  DELETE ADJACENT DUPLICATES FROM LT_VALUE
                 COMPARING VKBUR VKGRP.


  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      RETFIELD        = 'VKBUR'
      VALUE_ORG       = 'S'
    TABLES
      VALUE_TAB       = LT_VALUE
      RETURN_TAB      = LT_RETURN
    EXCEPTIONS
      PARAMETER_ERROR = 1
      NO_VALUES_FOUND = 2
      OTHERS          = 3.
  IF SY-SUBRC EQ 0.
    READ TABLE LT_RETURN INDEX 1.
    IF SY-SUBRC EQ 0.
      PV_VAL = LT_RETURN-FIELDVAL.
    ENDIF.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form F4_VKGRP
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- GS_100_VKGRP
*&---------------------------------------------------------------------*
FORM F4_VKGRP  CHANGING PV_VAL.
  DATA : LT_RETURN TYPE TABLE OF DDSHRETVAL WITH HEADER LINE.
  DATA : LT_DYNPREAD TYPE TABLE OF DYNPREAD,
         LS_DYNPREAD TYPE DYNPREAD.

  RANGES : LR_VKBUR FOR TVBVK-VKBUR.

  LS_DYNPREAD-FIELDNAME = 'GS_100-VKBUR'.
  APPEND LS_DYNPREAD TO LT_DYNPREAD.

  CALL FUNCTION 'DYNP_VALUES_READ'
    EXPORTING
      DYNAME     = SY-CPROG
      DYNUMB     = SY-DYNNR
    TABLES
      DYNPFIELDS = LT_DYNPREAD.

  READ TABLE LT_DYNPREAD INTO LS_DYNPREAD INDEX 1.
  IF SY-SUBRC = 0 AND LS_DYNPREAD-FIELDVALUE IS NOT INITIAL.
    APPEND VALUE #( SIGN = 'I' OPTION = 'EQ' LOW = LS_DYNPREAD-FIELDVALUE )
       TO LR_VKBUR.
  ENDIF.

  SELECT DISTINCT A~VKBUR,B~BEZEI,A~VKGRP,C~BEZEI AS VKGRP_TXT
    FROM TVKBZ AS H INNER JOIN TVBVK AS A
                    ON H~VKBUR = A~VKBUR
                    INNER JOIN TVKBT AS B
                    ON A~VKBUR = B~VKBUR AND
                       B~SPRAS = @SY-LANGU
                    INNER JOIN TVGRT AS C
                    ON A~VKGRP = C~VKGRP AND
                       C~SPRAS = @SY-LANGU
   WHERE H~VKORG EQ @G_BUKRS
     AND H~VKBUR IN @LR_VKBUR
    INTO TABLE @DATA(LT_VALUE).
  SORT LT_VALUE BY VKBUR VKGRP.
  DELETE ADJACENT DUPLICATES FROM LT_VALUE
                 COMPARING VKBUR VKGRP.


  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      RETFIELD        = 'VKGRP'
      VALUE_ORG       = 'S'
    TABLES
      VALUE_TAB       = LT_VALUE
      RETURN_TAB      = LT_RETURN
    EXCEPTIONS
      PARAMETER_ERROR = 1
      NO_VALUES_FOUND = 2
      OTHERS          = 3.
  IF SY-SUBRC EQ 0.
    READ TABLE LT_RETURN INDEX 1.
    IF SY-SUBRC EQ 0.
      PV_VAL = LT_RETURN-FIELDVAL.
    ENDIF.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form F4_SPART
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- GS_100_SPART
*&---------------------------------------------------------------------*
FORM F4_SPART  CHANGING PV_VAL.
  DATA : LT_RETURN TYPE TABLE OF DDSHRETVAL WITH HEADER LINE.
  DATA : LT_DYNPREAD TYPE TABLE OF DYNPREAD,
         LS_DYNPREAD TYPE DYNPREAD.

  RANGES : LR_VTWEG FOR TVTA-VTWEG.

  LS_DYNPREAD-FIELDNAME = 'GS_100-VTWEG'.
  APPEND LS_DYNPREAD TO LT_DYNPREAD.

  CALL FUNCTION 'DYNP_VALUES_READ'
    EXPORTING
      DYNAME     = SY-CPROG
      DYNUMB     = SY-DYNNR
    TABLES
      DYNPFIELDS = LT_DYNPREAD.

  READ TABLE LT_DYNPREAD INTO LS_DYNPREAD INDEX 1.
  IF SY-SUBRC = 0 AND LS_DYNPREAD-FIELDVALUE IS NOT INITIAL.
    APPEND VALUE #( SIGN = 'I' OPTION = 'EQ' LOW = LS_DYNPREAD-FIELDVALUE )
       TO LR_VTWEG.
  ENDIF.

  SELECT A~VKORG,A~VTWEG,A~SPART,B~VTEXT
    FROM TVTA AS A INNER JOIN TSPAT AS B
                   ON A~SPART = B~SPART AND
                      B~SPRAS = @SY-LANGU
   WHERE A~VKORG EQ @G_BUKRS
     AND A~VTWEG IN @LR_VTWEG
    INTO TABLE @DATA(LT_VALUE).

  SORT LT_VALUE BY VKORG VTWEG SPART.
  DELETE ADJACENT DUPLICATES FROM LT_VALUE COMPARING VKORG VTWEG SPART.

  CHECK LT_VALUE[] IS NOT INITIAL.

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      RETFIELD        = 'SPART'
      VALUE_ORG       = 'S'
    TABLES
      VALUE_TAB       = LT_VALUE
      RETURN_TAB      = LT_RETURN
    EXCEPTIONS
      PARAMETER_ERROR = 1
      NO_VALUES_FOUND = 2
      OTHERS          = 3.
  IF SY-SUBRC EQ 0.
    READ TABLE LT_RETURN INDEX 1.
    IF SY-SUBRC EQ 0.
      PV_VAL = LT_RETURN-FIELDVAL.
    ENDIF.
  ENDIF.
ENDFORM.
