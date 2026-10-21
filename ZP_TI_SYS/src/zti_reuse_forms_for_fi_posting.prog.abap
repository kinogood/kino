************************************************************************
* Title         : ZTI_REUSE_FORMS_FOR_FI_POSTING                       *
*                                                                      *
* Description   : 수입 공용 Top Include                                *
*                 수입제비용 Interface용                               *
*                                                                      *
* Creation Date : 2005/02/11                                           *
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
************************************************************************
CLASS LCL_EVENT_RECEIVER DEFINITION DEFERRED.

DATA: EVENT_RECEIVER TYPE REF TO LCL_EVENT_RECEIVER.

************************************************************************
* CLASSES: Definition                                                  *
************************************************************************
CLASS LCL_EVENT_RECEIVER DEFINITION.
  PUBLIC SECTION.
    METHODS:
      HANDLE_HOTSPOT_CLICK
         FOR EVENT HOTSPOT_CLICK OF CL_GUI_ALV_GRID
              IMPORTING E_ROW_ID
                        E_COLUMN_ID
                        ES_ROW_NO,

      HANDLE_DATA_CHANGED
         FOR EVENT DATA_CHANGED OF CL_GUI_ALV_GRID
             IMPORTING ER_DATA_CHANGED,

      HANDLE_DATA_CHANGED_FINISHED
          FOR EVENT DATA_CHANGED_FINISHED OF CL_GUI_ALV_GRID
              IMPORTING E_MODIFIED SENDER,

      HANDLE_DOUBLE_CLICK
           FOR EVENT DOUBLE_CLICK OF CL_GUI_ALV_GRID
               IMPORTING E_ROW E_COLUMN,

      HANDLE_BUTTON_CLICK
           FOR EVENT BUTTON_CLICK OF CL_GUI_ALV_GRID
               IMPORTING ES_COL_ID ES_ROW_NO,

      HANDLE_USER_COMMAND
           FOR EVENT USER_COMMAND OF CL_GUI_ALV_GRID
               IMPORTING E_UCOMM,

      HANDLE_BEFORE_USER_COMMAND
            FOR EVENT BEFORE_USER_COMMAND OF CL_GUI_ALV_GRID
                IMPORTING E_UCOMM,

      HANDLE_AFTER_USER_COMMAND
            FOR EVENT AFTER_USER_COMMAND OF CL_GUI_ALV_GRID
                IMPORTING E_UCOMM,

      HANDLE_CONTEXT_MENU_REQUEST
           FOR EVENT CONTEXT_MENU_REQUEST OF CL_GUI_ALV_GRID
               IMPORTING E_OBJECT,

      HANDLE_TOOLBAR
           FOR EVENT TOOLBAR OF CL_GUI_ALV_GRID
               IMPORTING E_OBJECT E_INTERACTIVE,
*               IMPORTING sender e_object e_interactive,

      HANDLE_PRINT_TOP_OF_PAGE
           FOR EVENT PRINT_TOP_OF_PAGE OF CL_GUI_ALV_GRID,

      HANDLE_PRINT_TOP_OF_LIST
           FOR EVENT PRINT_TOP_OF_LIST OF CL_GUI_ALV_GRID,

      HANDLE_PRINT_END_OF_PAGE
           FOR EVENT PRINT_END_OF_PAGE OF CL_GUI_ALV_GRID,

      HANDLE_PRINT_END_OF_LIST
           FOR EVENT PRINT_END_OF_LIST OF CL_GUI_ALV_GRID,

      HANDLE_TOP_OF_PAGE
           FOR EVENT TOP_OF_PAGE OF CL_GUI_ALV_GRID
               IMPORTING E_DYNDOC_ID,

      HANDLE_END_OF_LIST
           FOR EVENT END_OF_LIST OF CL_GUI_ALV_GRID
               IMPORTING E_DYNDOC_ID.

ENDCLASS.                    "lcl_event_receiver DEFINITION

************************************************************************
* CLASSES: IMPLEMENTATION                                              *
************************************************************************
CLASS LCL_EVENT_RECEIVER IMPLEMENTATION.

  METHOD HANDLE_HOTSPOT_CLICK.
    PERFORM HANDLE_HOTSPOT_CLICK IN PROGRAM (G_REPID)
                                 USING E_ROW_ID E_COLUMN_ID.
  ENDMETHOD.                    "hotspot_click

  METHOD HANDLE_DATA_CHANGED.
    PERFORM HANDLE_DATA_CHANGED IN PROGRAM (G_REPID)
                                USING ER_DATA_CHANGED.
  ENDMETHOD.                    "handle_data_changed

  METHOD HANDLE_DATA_CHANGED_FINISHED.
    PERFORM  HANDLE_DATA_CHANGED_FINISHED IN PROGRAM (G_REPID)
                  USING E_MODIFIED SENDER.
  ENDMETHOD.                    "handle_data_changed_finished

  METHOD HANDLE_DOUBLE_CLICK.
    PERFORM  HANDLE_DOUBLE_CLICK IN PROGRAM (G_REPID)
                                 USING E_ROW E_COLUMN.
  ENDMETHOD.                    "handle_double_click

  METHOD HANDLE_BUTTON_CLICK.
    PERFORM  HANDLE_BUTTON_CLICK IN PROGRAM (G_REPID)
                                 USING ES_COL_ID ES_ROW_NO.
  ENDMETHOD.                    "handle_button_click

  METHOD HANDLE_USER_COMMAND.
    PERFORM  HANDLE_USER_COMMAND_GRID IN PROGRAM (G_REPID)
                                      USING E_UCOMM.
  ENDMETHOD.                    "handle_user_command

  METHOD HANDLE_BEFORE_USER_COMMAND.
    PERFORM  HANDLE_BEFORE_USER_COMM IN PROGRAM (G_REPID)
                                     USING E_UCOMM.
  ENDMETHOD.                    "handle_before_user_command

  METHOD HANDLE_AFTER_USER_COMMAND.
    PERFORM  HANDLE_AFTER_USER_COMM IN PROGRAM (G_REPID)
                                    USING E_UCOMM.
  ENDMETHOD.                    "handle_after_user_command

  METHOD HANDLE_CONTEXT_MENU_REQUEST.
    PERFORM  HANDLE_CONTEXT_MENU IN PROGRAM (G_REPID)
                                 USING E_OBJECT.
  ENDMETHOD.                    "handle_context_menu_request

  METHOD HANDLE_TOOLBAR.
    PERFORM  HANDLE_TOOLBAR IN PROGRAM (G_REPID)
*                            USING e_object.
                            USING  E_OBJECT E_INTERACTIVE.
  ENDMETHOD.                    "handle_toolbar

  METHOD HANDLE_PRINT_TOP_OF_PAGE.
    PERFORM  HANDLE_PRINT_TOP_OF_PAGE IN PROGRAM (G_REPID).
  ENDMETHOD.                    "handle_print_top_of_page

  METHOD HANDLE_PRINT_TOP_OF_LIST.
    PERFORM  HANDLE_PRINT_TOP_OF_LIST IN PROGRAM (G_REPID).
  ENDMETHOD.                    "handle_print_top_of_list

  METHOD HANDLE_PRINT_END_OF_PAGE.
    PERFORM  HANDLE_PRINT_END_OF_PAGE IN PROGRAM (G_REPID).
  ENDMETHOD.                    "handle_print_end_of_page

  METHOD HANDLE_PRINT_END_OF_LIST.
    PERFORM  HANDLE_PRINT_END_OF_LIST IN PROGRAM (G_REPID).
  ENDMETHOD.                    "handle_print_end_of_list

  METHOD HANDLE_TOP_OF_PAGE.
    PERFORM  HANDLE_TOP_OF_PAGE IN PROGRAM (G_REPID) USING E_DYNDOC_ID.
  ENDMETHOD.                    "handle_top_of_page

  METHOD HANDLE_END_OF_LIST.
    PERFORM  HANDLE_END_OF_LIST IN PROGRAM (G_REPID) USING E_DYNDOC_ID.
  ENDMETHOD.                    "handle_end_of_list

ENDCLASS.                    "lcl_event_receiver IMPLEMENTATION



*-> 데이타 선언부...
DATA : IT_ZTITCSK   LIKE ZTISCSK
                          OCCURS 10 WITH HEADER LINE,
       IT_ZTITCSP   LIKE ZTISCSIT
                          OCCURS 10 WITH HEADER LINE,
       IT_ZTITCSO   LIKE ZTITCSO
                          OCCURS 10 WITH HEADER LINE.


DATA: BEGIN OF IT_COLLECT  OCCURS 2,
      BLART    TYPE BLART,
      LIFNR    TYPE LIFNR,
      BUPLA    TYPE BUPLA,
      MWSKZ    TYPE MWSKZ,
      WRBTR    TYPE WRBTR,
      DMBTR    TYPE DMBTR,
      WMWST    TYPE WMWST,
      FWBAS    TYPE FWBAS,
      WAERS    TYPE WAERS,
      HWAER    TYPE HWAER,
      CSTYP    TYPE ZTICSTYP,
      VORGANG  TYPE MRM_VORGANG,
      ZFBDT    TYPE DZFBDT,
      CSCTY    TYPE ZTICSCTY,
      END   OF IT_COLLECT.

DATA: G_VALID TYPE C,
      GT_ROW_NO TYPE LVC_T_ROID WITH HEADER LINE.

TABLES: FAEDE.  ">만기일결정에 대한 전송구조.

*&---------------------------------------------------------------------*
*&      Form  set_posting_data_initial
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM SET_POSTING_DATA_INITIAL .

  REFRESH: IT_COLLECT, IT_MSG, IT_ZTITCSK, IT_ZTITCSP, IT_ZTITCSO.

  CLEAR: IT_COLLECT, IT_MSG, ZTISSCRCOM-ITCNT,
         IT_ZTITCSK, IT_ZTITCSP, IT_ZTITCSO.

*> Message Initialize
  CALL FUNCTION 'MESSAGES_INITIALIZE'
    EXPORTING
      RESET = 'X'.

ENDFORM.                    " set_posting_data_initial
*&---------------------------------------------------------------------*
*&      Form  get_posting_type
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM GET_POSTING_TYPE  USING    P_COUNT P_MONSC  P_ANSWER.

  CLEAR: P_MONSC, P_ANSWER.

  IF P_COUNT EQ 1.
    ZTISSCRCOM-MONSC = 'S'.
    P_ANSWER         = 'Y'.
  ELSE.
    CALL FUNCTION 'Z_TI_COST_DOCUMENT_TYPE_POPUP'
      IMPORTING
        P_ANSWER = P_ANSWER
        P_MONSC  = P_MONSC.
  ENDIF.

ENDFORM.                    " get_posting_type
*&---------------------------------------------------------------------*
*&      Form  display_error_message
*&---------------------------------------------------------------------*
FORM DISPLAY_ERROR_MESSAGE .

  DESCRIBE TABLE IT_MSG LINES G_LINE.
  IF G_LINE GT 0.
*    IF g_line EQ 1.
*      READ TABLE it_msg INDEX 1.
*      IF sy-subrc EQ 0.
*        IF it_msg-msgty EQ 'E'.
*          MESSAGE ID     it_msg-msgid TYPE 'S'
*                  NUMBER it_msg-msgno
*                  WITH   it_msg-msgv1  it_msg-msgv2
*                         it_msg-msgv3  it_msg-msgv4.
*          g_line = 0.
*        ELSE.
*          MESSAGE ID     it_msg-msgid TYPE 'S'
*                  NUMBER it_msg-msgno
*                  WITH   it_msg-msgv1  it_msg-msgv2
*                         it_msg-msgv3  it_msg-msgv4.
*          g_line = 1.
*        ENDIF.
*      ENDIF.
*    ELSE.
    CALL FUNCTION 'Z_TI_POPUP_TO_ERROR_MESSAGE'
      EXPORTING
        XDOCNO_SHOW = 'X'
      TABLES
        XMSG        = IT_MSG.
*    ENDIF.
  ENDIF.

*
  DESCRIBE TABLE IT_MSG LINES G_LINE.
  IF G_LINE GT 0.
    CALL FUNCTION 'Z_TI_POPUP_TO_ERROR_MESSAGE'
      EXPORTING
        XDOCNO_SHOW = ' '
      TABLES
        XMSG        = IT_MSG.
  ENDIF.
*
ENDFORM.                    " display_error_message
*&---------------------------------------------------------------------*
*&      Form  set_header_data_by_collect
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM SET_HEADER_DATA_BY_COLLECT  USING    P_ICSNO  P_EXPGR.

  DATA: L_CSTCT TYPE ZTICSTCT.

  CLEAR: IT_ZTITCSK.

*> Default Value Setting
  CLEAR: L_CSTCT.
  CASE P_EXPGR.
    WHEN 'L'.    ">수입의뢰비용.
      L_CSTCT = 'B'.
    WHEN 'I'.    ">적하보험비용.
      L_CSTCT = 'H'.
    WHEN 'B'.    ">선적관련비용.
      L_CSTCT = 'M'.
    WHEN 'C'.    ">수입통관비용.
      L_CSTCT = 'N'.
    WHEN 'T'.    ">관세전가액(기납증).
      L_CSTCT = 'T'.
    WHEN 'V'.    ">부가세.
  ENDCASE.

  IF NOT L_CSTCT IS INITIAL.
    SELECT SINGLE *
      FROM ZTITIG07
     WHERE BUKRS EQ T001-BUKRS
       AND CSTCT EQ L_CSTCT.
    IF SY-SUBRC EQ 0.
      IF IT_ZTITCSK-BLART IS INITIAL.
        IF NOT ZTITIG07-BLART IS INITIAL.
          IT_ZTITCSK-BLART = ZTITIG07-BLART.
        ENDIF.
      ENDIF.
      IF IT_ZTITCSK-MWSKZ IS INITIAL.
        IF NOT ZTITIG07-MWSKZ IS INITIAL.
          IT_ZTITCSK-MWSKZ = ZTITIG07-MWSKZ.
        ENDIF.
      ENDIF.
      IF IT_ZTITCSK-ZTERM IS INITIAL.
        IF NOT ZTITIG07-ZTERM IS INITIAL.
          IT_ZTITCSK-ZTERM = ZTITIG07-ZTERM.
        ENDIF.
      ENDIF.
      IF IT_ZTITCSK-ZLSPR IS INITIAL.
        IF NOT ZTITIG07-ZLSPR IS INITIAL.
          IT_ZTITCSK-ZLSPR = ZTITIG07-ZLSPR.
        ENDIF.
      ENDIF.
      IF IT_ZTITCSK-ZLSCH IS INITIAL.
        IF NOT ZTITIG07-ZLSCH IS INITIAL.
          IT_ZTITCSK-ZLSCH = ZTITIG07-ZLSCH.
        ENDIF.
      ENDIF.
      IF IT_ZTITCSK-UZAWE IS INITIAL.
        IF NOT ZTITIG07-UZAWE IS INITIAL.
          IT_ZTITCSK-UZAWE = ZTITIG07-UZAWE.
        ENDIF.
      ENDIF.
      IF IT_ZTITCSK-BUPLA IS INITIAL.
        IF NOT ZTITIG07-BUPLA IS INITIAL.
          IT_ZTITCSK-BUPLA = ZTITIG07-BUPLA.
        ENDIF.
      ENDIF.
      IF IT_ZTITCSK-GSBER IS INITIAL.
        IF NOT ZTITIG07-GSBER IS INITIAL.
          IT_ZTITCSK-GSBER = ZTITIG07-GSBER.
        ENDIF.
      ENDIF.
      IF IT_ZTITCSK-CSTYP IS INITIAL.
        IF NOT ZTITIG07-CSTYP IS INITIAL.
          IT_ZTITCSK-CSTYP = ZTITIG07-CSTYP.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDIF.

*>>>
  IT_ZTITCSK-BUKRS = T001-BUKRS.       ">회사코드.
  IT_ZTITCSK-ICSNO = P_ICSNO.          ">수출비용 문서번호.
  IT_ZTITCSK-CSTYP = IT_COLLECT-CSTYP. ">차변/대변메모 지시자
  IT_ZTITCSK-VORGANG = IT_COLLECT-VORGANG. ">전기방법.
  IT_ZTITCSK-GJAHR = SY-DATLO(4).      ">회계연도
*    it_ZTITCSK-belnr   회계전표번호
  IT_ZTITCSK-MONAT = SY-DATLO+4(2).    ">회계기간.
  IT_ZTITCSK-BLART = IT_COLLECT-BLART. ">전표유형.
  IT_ZTITCSK-BUPLA = IT_COLLECT-BUPLA. ">사업장.
*    it_ZTITCSK-gsber =   사업영역
  IT_ZTITCSK-BUDAT = SY-DATLO.         ">전표의 전기일.
  IT_ZTITCSK-BLDAT = SY-DATLO.         ">전표증빙일.
*    it_ZTITCSK-zterm   지급조건키
*    it_ZTITCSK-zfbdt   만기계산기준일
*    it_ZTITCSK-netdt   순액지급 만기일
*    it_ZTITCSK-zbd1t   현금할인기간 1
*    it_ZTITCSK-zbd2t   현금 할인기간 2
*    it_ZTITCSK-zbd3t   순액지급조건기간
*    it_ZTITCSK-zbd1p   현금할인율 1
*    it_ZTITCSK-zbd2p   두번째 현금할인율
  IT_ZTITCSK-MWSKZ = IT_COLLECT-MWSKZ. ">부가가치세코드.
  IT_ZTITCSK-WAERS = IT_COLLECT-WAERS. ">통화키.
*    it_ZTITCSK-kursf   환율
*    it_ZTITCSK-wwert   환산일
*    it_ZTITCSK-saknr = it_collect-  g/l 계정번호
  IT_ZTITCSK-LIFNR = IT_COLLECT-LIFNR. ">구매처계정번호.
*    it_ZTITCSK-empfk   수취인으로 허용되는 구매처
*    it_ZTITCSK-akont =   총계정원장에서 조정계정
  IT_ZTITCSK-WRBTR = IT_COLLECT-WRBTR. ">전표통화금액.
  IT_ZTITCSK-DMBTR = IT_COLLECT-DMBTR. ">현지통화금액.
  IT_ZTITCSK-HWAER = IT_COLLECT-HWAER. ">현지통화.
  IT_ZTITCSK-WMWST = IT_COLLECT-WMWST. ">전표통화세액
  IT_ZTITCSK-FWBAS = IT_COLLECT-FWBAS. ">과세표준액
*    it_ZTITCSK-ptdcl = it_collect-  전기방법
*    it_ZTITCSK-dstrb   비용배부방법
*    it_ZTITCSK-xblnr   참조전표번호
*    it_ZTITCSK-bktxt   전표헤더텍스트
*    it_ZTITCSK-zlspr   지급보류키
*    it_ZTITCSK-zlsch   지급방법
*    it_ZTITCSK-uzawe   지급방법보충
*    it_ZTITCSK-zuonr   지정번호
*    it_ZTITCSK-sgtxt   항목텍스트
*    it_ZTITCSK-xref1   거래처참조키
*    it_ZTITCSK-xref2   거래처참조키
*    it_ZTITCSK-xref3   개별항목참조키
*    it_ZTITCSK-filkd   지점계정이름
*    it_ZTITCSK-bvtyp   거래처은행유형
*    it_ZTITCSK-lponr   최종품목번호
  IT_ZTITCSK-EXPGR = P_EXPGR.  ">비용그룹.
  IT_ZTITCSK-FLAG  = 'X'.  ">일반표시.

  CALL FUNCTION 'FI_VENDOR_DATA'
    EXPORTING
      I_BUKRS = IT_ZTITCSK-BUKRS
      I_LIFNR = IT_ZTITCSK-LIFNR
    IMPORTING
      E_KRED  = VF_KRED.

  IT_ZTITCSK-XCPDK = VF_KRED-XCPDK.
  IT_ZTITCSK-NAME1 = VF_KRED-NAME1.
  IT_ZTITCSK-AKONT = VF_KRED-AKONT.

*-{ 기능개선 281197 - 항공 국내 영세율 일때 사업자등록번호
  IF T001-BUKRS = '1000'.
    IF P_EXPGR = 'B'. "선적관련비용
      IF GS_DISP-EXPCD EQ 'AIR'. ">항공.
        IT_ZTITCSK-ZUONR = VF_KRED-STCD2.
      ENDIF.
    ENDIF.
  ENDIF.
*-} 기능개선 281197

  IF IT_ZTITCSK-ZTERM IS INITIAL.
    IT_ZTITCSK-ZTERM = VF_KRED-ZTERM.
  ENDIF.

  CALL FUNCTION 'FI_TERMS_OF_PAYMENT_PROPOSE'
    EXPORTING
      I_BLDAT = IT_ZTITCSK-BLDAT
      I_BUDAT = IT_ZTITCSK-BUDAT
      I_CPUDT = SY-DATLO
*        i_zfbdt = ZTITCSK-zfbdt
      I_ZTERM = IT_ZTITCSK-ZTERM
    IMPORTING
      E_ZBD1T = IT_ZTITCSK-ZBD1T
      E_ZBD1P = IT_ZTITCSK-ZBD1P
      E_ZBD2T = IT_ZTITCSK-ZBD2T
      E_ZBD2P = IT_ZTITCSK-ZBD2P
      E_ZBD3T = IT_ZTITCSK-ZBD3T
      E_ZLSCH = IT_ZTITCSK-ZLSCH
      E_ZSCHF = IT_ZTITCSK-ZLSPR
      E_ZFBDT = IT_ZTITCSK-ZFBDT
    EXCEPTIONS
      TERMS_NOT_FOUND = 4.
  IF SY-SUBRC NE 0.
*    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
    MESSAGE ID SY-MSGID TYPE 'I' NUMBER SY-MSGNO
            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

  CLEAR: FAEDE.

  FAEDE-SHKZG = 'H'.
  FAEDE-KOART = 'K'.
  FAEDE-ZFBDT = IT_ZTITCSK-ZFBDT.
  FAEDE-ZBD1T = IT_ZTITCSK-ZBD1T.
  FAEDE-ZBD2T = IT_ZTITCSK-ZBD2T.
  FAEDE-ZBD3T = IT_ZTITCSK-ZBD3T.
*  faede-rebzg = space.
*  faede-rebzt = bseg-rebzt.
  FAEDE-BLDAT = IT_ZTITCSK-BLDAT.

  CALL FUNCTION 'DETERMINE_DUE_DATE'
    EXPORTING
      I_FAEDE = FAEDE
    IMPORTING
      E_FAEDE = FAEDE
    EXCEPTIONS
      OTHERS  = 1.

  IT_ZTITCSK-NETDT = FAEDE-NETDT.

  APPEND IT_ZTITCSK.

ENDFORM.                    " set_header_data_by_collect
*&---------------------------------------------------------------------*
*&      Form  set_item_data
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM SET_ITEM_DATA  USING    P_ICSNO
                             P_ICSSQ
                             P_EXPGR.
  CLEAR: IT_ZTITCSP.

  IT_ZTITCSP-BUKRS = T001-BUKRS.     "<회사코드.
  IT_ZTITCSP-ICSNO = P_ICSNO.        "<수출비용 문서번호.
  IT_ZTITCSP-ICSSQ = P_ICSSQ.        "<비용문서의 품목.
*  it_ZTITCSP-cStyp = GS_DISP-cStyp. "<차변/대변메모 지시
  IT_ZTITCSP-EXPGR = P_EXPGR.        "<비용그룹.
  IT_ZTITCSP-EXPCD = GS_DISP-EXPCD. "<수출비용코드.
  IT_ZTITCSP-EXPTX = GS_DISP-EXPTX. "<수출비용코드.
  IT_ZTITCSP-DOCNM = GS_DISP-DOCNM. "<수출비용코드.
  IT_ZTITCSP-REFNO = GS_DISP-REFNO. "<관련문서번호.
  IT_ZTITCSP-AMDSQ = GS_DISP-AMDSQ. "<Amend sequence.
  IT_ZTITCSP-WRBTR = GS_DISP-WRBTR. "<전표통화금액.
  IT_ZTITCSP-WMWST = GS_DISP-WMWST. "<전표통화세액.
  IT_ZTITCSP-DMBTR = GS_DISP-DMBTR. "<현지통화금액.
  IT_ZTITCSP-FWBAS = GS_DISP-FWBAS. "<전표통화로 표시된
  IT_ZTITCSP-MWSKZ = GS_DISP-MWSKZ. "<부가가치세코드.
*  it_ztitcsp-MONCT =
  IT_ZTITCSP-CCUKY = GS_DISP-CCUKY.
  IT_ZTITCSP-MOACG = GS_DISP-MOACG.
  IT_ZTITCSP-PCDRA = GS_DISP-PCDRA.
  IT_ZTITCSP-APDAY = GS_DISP-APDAY.
  IT_ZTITCSP-APFRD = GS_DISP-APFRD.
  IT_ZTITCSP-APEND = GS_DISP-APEND.
  IT_ZTITCSP-KURSF = GS_DISP-KURSF.
*it_ZTITCSP-KOSTL = GS_DISP-kostl. "<코스트센터.
*it_ZTITCSP-PRCTR = GS_DISP-prctr. "<손익센터.
*it_ZTITCSP-PSPNR. "<작업분석구조 요소
*it_ZTITCSP-ZUONR. "<지정번호.
*it_ZTITCSP-SGTXT. "<항목텍스트.
*  it_ZTITCSP-saknr = GS_DISP-saknr. "<G/L 계정번호.
*it_ZTITCSP-CSCTY = GS_DISP-. "<비용성격.
*it_ZTITCSP-CSTCL. "<지정 비용.
*it_ZTITCSP-CCUKY. "<대상통화.
*it_ZTITCSP-MOACG. "<대상금액.
*it_ZTITCSP-PCDRA. "<적용요율.
*it_ZTITCSP-APDAY. "<적용일수.
*it_ZTITCSP-APFRD. "<기간(FROM).
*it_ZTITCSP-APEND. "<기간(TO).
  IT_ZTITCSP-BUPLA = GS_DISP-BUPLA. "<사업장.
*it_ZTITCSP-AFTFG. "<사후관리 반영여부.
  IT_ZTITCSP-FINNO = GS_DISP-FINNO.
  IT_ZTITCSP-FBSEQ = GS_DISP-FBSEQ.
  APPEND IT_ZTITCSP.

ENDFORM.                    " set_item_data
*&---------------------------------------------------------------------*
*&      Form  build_fi_document
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM BUILD_FI_DOCUMENT  USING  P_EXPGR   TYPE ZTIEXPGR
                               P_MONSC   TYPE ZTIMONSC.

  CLEAR: G_SUCCESS, G_ERROR, G_ANSWER.

  CALL FUNCTION 'Z_TI_SET_POST_DATA_FOR_COST'
    EXPORTING
      IM_BUKRS      = T001-BUKRS
      IM_EXPGR      = P_EXPGR
      IM_FIXED_DATE = SPACE
      IM_MONSC      = P_MONSC
    IMPORTING
      EX_ANSWER     = G_ANSWER
      EX_SUCCESS    = G_SUCCESS
      EX_ERROR      = G_ERROR
    TABLES
      CT_ZTITCSK    = IT_ZTITCSK
      CT_ZTITCSP    = IT_ZTITCSP
      CT_ZTITCSO    = IT_ZTITCSO
    EXCEPTIONS
      NOT_POSTING   = 1
      OTHERS        = 2.
  IF SY-SUBRC <> 0.
    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ELSE.
    IF G_ANSWER NE 'Y'.
      MESSAGE S900.
    ENDIF.
  ENDIF.

ENDFORM.                    " build_fi_document
*&---------------------------------------------------------------------*

*&      Form  set_header_data_by_individual
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM SET_HEADER_DATA_BY_INDIVIDUAL  USING    P_ICSNO
                                             P_EXPGR.
  DATA: L_CSTCT TYPE ZTICSTCT.

  CLEAR: IT_ZTITCSK.

*> Default Value Setting
  CLEAR: L_CSTCT.
  CASE P_EXPGR.
    WHEN 'L'.    ">수입의뢰비용.
      L_CSTCT = 'B'.
    WHEN 'I'.    ">적하보험비용.
      L_CSTCT = 'H'.
    WHEN 'B'.    ">선적관련비용.
      L_CSTCT = 'M'.
    WHEN 'C'.    ">수입통관비용.
      L_CSTCT = 'N'.
    WHEN 'T'.    ">관세전가액(기납증).
      L_CSTCT = 'T'.
    WHEN 'V'.    ">부가세.
  ENDCASE.


  IT_ZTITCSK-BUKRS = T001-BUKRS.       ">회사코드.
  IT_ZTITCSK-ICSNO = P_ICSNO.          ">수출비용 문서번호.
  IT_ZTITCSK-CSTYP = GS_DISP-CSTYP.
  IT_ZTITCSK-VORGANG = GS_DISP-VORGANG.
*  it_ztitcsk-cdtyp = it_table-cdtyp. ">차변/대변메모 지시자
*  it_ztitcsk-posty = it_table-posty. ">전기방법.
  IT_ZTITCSK-GJAHR = SY-DATLO(4).      ">회계연도
*    it_ZTITCSK-belnr   회계전표번호
  IT_ZTITCSK-MONAT = SY-DATLO+4(2).    ">회계기간.
  IT_ZTITCSK-BLART = GS_DISP-BLART. ">전표유형.
  IT_ZTITCSK-BUPLA = GS_DISP-BUPLA. ">사업장.
*    it_ZTITCSK-gsber =   사업영역
  IT_ZTITCSK-BUDAT = SY-DATLO.         ">전표의 전기일.
  IT_ZTITCSK-BLDAT = SY-DATLO.         ">전표증빙일.
*    it_ZTITCSK-zterm   지급조건키
*    it_ZTITCSK-zfbdt   만기계산기준일
*    it_ZTITCSK-netdt   순액지급 만기일
*    it_ZTITCSK-zbd1t   현금할인기간 1
*    it_ZTITCSK-zbd2t   현금 할인기간 2
*    it_ZTITCSK-zbd3t   순액지급조건기간
*    it_ZTITCSK-zbd1p   현금할인율 1
*    it_ZTITCSK-zbd2p   두번째 현금할인율
  IT_ZTITCSK-MWSKZ = GS_DISP-MWSKZ. ">부가가치세코드.
  IT_ZTITCSK-WAERS = GS_DISP-WAERS. ">통화키.
*    it_ZTITCSK-kursf   환율
*    it_ZTITCSK-wwert   환산일
*    it_ZTITCSK-saknr = it_collect-  g/l 계정번호
  IT_ZTITCSK-LIFNR = GS_DISP-LIFNR. ">구매처계정번호.
*    it_ZTITCSK-empfk   수취인으로 허용되는 구매처
*    it_ZTITCSK-akont =   총계정원장에서 조정계정
  IT_ZTITCSK-WRBTR = GS_DISP-WRBTR. ">전표통화금액.
  IT_ZTITCSK-DMBTR = GS_DISP-DMBTR. ">현지통화금액.
  IT_ZTITCSK-HWAER = GS_DISP-HWAER. ">현지통화.
  IT_ZTITCSK-WMWST = GS_DISP-WMWST. ">전표통화세액
  IT_ZTITCSK-FWBAS = GS_DISP-FWBAS. ">과세표준액
*    it_ZTITCSK-ptdcl = it_collect-  전기방법
*    it_ZTITCSK-dstrb   비용배부방법
*    it_ZTITCSK-xblnr   참조전표번호
*    it_ZTITCSK-bktxt   전표헤더텍스트
*    it_ZTITCSK-zlspr   지급보류키
*    it_ZTITCSK-zlsch   지급방법
*    it_ZTITCSK-uzawe   지급방법보충
*    it_ZTITCSK-zuonr   지정번호
*    it_ZTITCSK-sgtxt   항목텍스트
*    it_ZTITCSK-xref1   거래처참조키
*    it_ZTITCSK-xref2   거래처참조키
*    it_ZTITCSK-xref3   개별항목참조키
*    it_ZTITCSK-filkd   지점계정이름
*    it_ZTITCSK-bvtyp   거래처은행유형
*    it_ZTITCSK-lponr   최종품목번호
  IT_ZTITCSK-EXPGR = P_EXPGR.  ">비용그룹.
  IT_ZTITCSK-FLAG  = 'X'.  ">일반표시.

  CASE P_EXPGR.
    WHEN 'L'. ">수출 은행관련비용.
      L_CSTCT = 'A'.
    WHEN 'I'. ">수출 적하보험료.
      L_CSTCT = 'B'.
    WHEN 'B'. ">수출 B/L(AWB) 관련비용.
      L_CSTCT = 'C'.
    WHEN 'C'. ">수출 통관관련비용.
      L_CSTCT = 'D'.
    WHEN 'N'. ">수출 Nego관련비용.
      L_CSTCT = 'E'.
*    when 'F'. ">COMMISSION 관련비용.
*    when 'G'. ">단기수출보험료  .
    WHEN OTHERS.
  ENDCASE.

  SELECT SINGLE *
    FROM ZTITIG07
   WHERE BUKRS EQ T001-BUKRS
     AND CSTCT EQ L_CSTCT.
*
  IF NOT L_CSTCT IS INITIAL.
    SELECT SINGLE *
      FROM ZTITIG07
     WHERE BUKRS EQ T001-BUKRS
       AND CSTCT EQ L_CSTCT.
    IF SY-SUBRC EQ 0.
      IF NOT ZTITIG07-BLART IS INITIAL.
        IT_ZTITCSK-BLART = ZTITIG07-BLART.
      ENDIF.
      IF NOT ZTITIG07-MWSKZ IS INITIAL.
        IT_ZTITCSK-MWSKZ = ZTITIG07-MWSKZ.
      ENDIF.
      IF NOT ZTITIG07-ZTERM IS INITIAL.
        IT_ZTITCSK-ZTERM = ZTITIG07-ZTERM.
      ENDIF.
      IF NOT ZTITIG07-ZLSPR IS INITIAL.
        IT_ZTITCSK-ZLSPR = ZTITIG07-ZLSPR.
      ENDIF.
      IF NOT ZTITIG07-ZLSCH IS INITIAL.
        IT_ZTITCSK-ZLSCH = ZTITIG07-ZLSCH.
      ENDIF.
      IF NOT ZTITIG07-UZAWE IS INITIAL.
        IT_ZTITCSK-UZAWE = ZTITIG07-UZAWE.
      ENDIF.
      IF NOT ZTITIG07-BUPLA IS INITIAL.
        IT_ZTITCSK-BUPLA = ZTITIG07-BUPLA.
      ENDIF.
      IF NOT ZTITIG07-GSBER IS INITIAL.
        IT_ZTITCSK-GSBER = ZTITIG07-GSBER.
      ENDIF.
      IF NOT ZTITIG07-CSTYP IS INITIAL.
        IT_ZTITCSK-CSTYP = ZTITIG07-CSTYP.
      ENDIF.
    ENDIF.
  ENDIF.

  CALL FUNCTION 'FI_VENDOR_DATA'
    EXPORTING
      I_BUKRS = IT_ZTITCSK-BUKRS
      I_LIFNR = IT_ZTITCSK-LIFNR
    IMPORTING
      E_KRED  = VF_KRED.

  IT_ZTITCSK-XCPDK = VF_KRED-XCPDK.
  IT_ZTITCSK-NAME1 = VF_KRED-NAME1.

*-{ 기능개선 281197 - 항공 국내 영세율 일때 사업자등록번호
  IF T001-BUKRS = '1000'.
    IF P_EXPGR = 'B'. "선적관련비용
      IF GS_DISP-EXPCD EQ 'AIR'. ">항공.
        IT_ZTITCSK-ZUONR = VF_KRED-STCD2.
      ENDIF.
    ENDIF.
  ENDIF.
*-} 기능개선 281197

  IF IT_ZTITCSK-ZTERM IS INITIAL.
    IT_ZTITCSK-ZTERM = VF_KRED-ZTERM.
  ENDIF.

  CALL FUNCTION 'FI_TERMS_OF_PAYMENT_PROPOSE'
    EXPORTING
      I_BLDAT = IT_ZTITCSK-BLDAT
      I_BUDAT = IT_ZTITCSK-BUDAT
      I_CPUDT = SY-DATLO
*        i_zfbdt = ZTITCSK-zfbdt
      I_ZTERM = IT_ZTITCSK-ZTERM
    IMPORTING
      E_ZBD1T = IT_ZTITCSK-ZBD1T
      E_ZBD1P = IT_ZTITCSK-ZBD1P
      E_ZBD2T = IT_ZTITCSK-ZBD2T
      E_ZBD2P = IT_ZTITCSK-ZBD2P
      E_ZBD3T = IT_ZTITCSK-ZBD3T
      E_ZLSCH = IT_ZTITCSK-ZLSCH
      E_ZSCHF = IT_ZTITCSK-ZLSPR
      E_ZFBDT = IT_ZTITCSK-ZFBDT.

  CLEAR: FAEDE.

  FAEDE-SHKZG = 'H'.
  FAEDE-KOART = 'K'.
  FAEDE-ZFBDT = IT_ZTITCSK-ZFBDT.
  FAEDE-ZBD1T = IT_ZTITCSK-ZBD1T.
  FAEDE-ZBD2T = IT_ZTITCSK-ZBD2T.
  FAEDE-ZBD3T = IT_ZTITCSK-ZBD3T.
*  faede-rebzg = space.
*  faede-rebzt = bseg-rebzt.
  FAEDE-BLDAT = IT_ZTITCSK-BLDAT.

  CALL FUNCTION 'DETERMINE_DUE_DATE'
    EXPORTING
      I_FAEDE = FAEDE
    IMPORTING
      E_FAEDE = FAEDE
    EXCEPTIONS
      OTHERS  = 1.

  IT_ZTITCSK-NETDT = FAEDE-NETDT.

  APPEND IT_ZTITCSK.

ENDFORM.                    " set_header_data_by_individual
*&---------------------------------------------------------------------*
*&      Form  set_return_message_FILL
*&---------------------------------------------------------------------*
FORM SET_RETURN_MESSAGE_FILL USING P_MSGTY.

  MOVE:  SY-MSGID  TO  IT_MSG-MSGID,
         P_MSGTY   TO  IT_MSG-MSGTY,
         SY-MSGNO  TO  IT_MSG-MSGNO,
         SY-MSGV1  TO  IT_MSG-MSGV1,
         SY-MSGV2  TO  IT_MSG-MSGV2,
         SY-MSGV3  TO  IT_MSG-MSGV3,
         SY-MSGV4  TO  IT_MSG-MSGV4.

  COLLECT IT_MSG.

ENDFORM.                    " set_return_message_FILL
