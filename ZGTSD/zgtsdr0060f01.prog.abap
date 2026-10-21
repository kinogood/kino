*&---------------------------------------------------------------------*
*& Include          ZGTSDR0060F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form set_initialization
*&---------------------------------------------------------------------*
*& Initialization 값 구성
*&---------------------------------------------------------------------*
FORM SET_INITIALIZATION .

  CLEAR : P_SPART.

*-- 제품군 기본값 구성
  P_SPART = GC_SPART-60.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form screen_output_1000
*&---------------------------------------------------------------------*
*& Screen 1000 출력 정보 제어
*&---------------------------------------------------------------------*
FORM SCREEN_OUTPUT_1000 .

  LOOP AT SCREEN.
*-- 필수필드 정보 구성
    IF SCREEN-GROUP1 EQ 'G01'.
      SCREEN-REQUIRED   = '2'.
    ENDIF.

    IF ( SCREEN-GROUP1 EQ 'D01' OR SCREEN-GROUP1 EQ 'D02' ) AND
       SCREEN-NAME CP '*-LOW'.
      SCREEN-REQUIRED   = '2'.
    ENDIF.

*-- 제품군 조회모드 구성
    IF SCREEN-GROUP1 EQ 'G02'.
      SCREEN-INPUT      = 0.
    ENDIF.

*-- 시작업 생산요청 생성/조회 Radio Buttion 기준 화면 정보 구성
    CASE ABAP_TRUE.
      WHEN P_CRTE.          " 생성
        IF SCREEN-GROUP1 EQ 'D02' OR SCREEN-GROUP1 EQ 'G04'.
          SCREEN-ACTIVE = 0.
        ENDIF.
      WHEN P_SEARCH.        " 조회
        IF SCREEN-GROUP1 EQ 'D01' OR SCREEN-GROUP1 EQ 'G03'.
          SCREEN-ACTIVE = 0.
        ENDIF.
    ENDCASE.

    MODIFY SCREEN.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form chk_req_value_for_vkorg
*&---------------------------------------------------------------------*
*& 영업조직 필수값 체크
*&---------------------------------------------------------------------*
*&      --> PV_VKORG    : 영업조직 조회조건 입력 값 정보
*&---------------------------------------------------------------------*
FORM CHK_REQ_VALUE_FOR_VKORG  USING    PV_VKORG.

  CHECK SY-UCOMM EQ 'ONLI' AND
        PV_VKORG IS INITIAL.

*-- 조회조건 없이 실행시 오류 메세지 구성
  MESSAGE E278(00) WITH '영업 조직'(E01).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form chk_req_value_for_zpjno
*&---------------------------------------------------------------------*
*& 프로젝트 필수값 체크
*&---------------------------------------------------------------------*
*&      --> PV_ZPJNO    : 프로젝트 입력 값 정보
*&---------------------------------------------------------------------*
FORM CHK_REQ_VALUE_FOR_ZPJNO  USING    PV_ZPJNO TYPE ZPJNO.

  CHECK SY-UCOMM EQ 'ONLI' AND
        PV_ZPJNO IS INITIAL.

*-- 조회조건 없이 실행시 오류 메세지 구성
  MESSAGE E278(00) WITH '프로젝트'(E02).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form chk_req_value_for_erdt1
*&---------------------------------------------------------------------*
*& 시작업제번 생성일 필수값 체크
*&---------------------------------------------------------------------*
*&      --> PT_ERDT1   : 생성일 입력 정보
*&---------------------------------------------------------------------*
FORM CHK_REQ_VALUE_FOR_ERDT1  USING    PT_ERDT1  TYPE FRE_ERDAT_RTTY.

  CHECK SY-UCOMM   EQ 'ONLI'    AND
        P_CRTE     EQ ABAP_TRUE AND
        PT_ERDT1[] IS INITIAL.

*-- 조회조건 없이 실행시 오류 메세지 구성
  MESSAGE E278(00) WITH '시작업제번 생성일'(E03).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form chk_req_value_for_erdt2
*&---------------------------------------------------------------------*
*& 시작업요청 생성일 필수값 체크
*&---------------------------------------------------------------------*
*&      --> PT_ERDT2   : 생성일 입력 정보
*&---------------------------------------------------------------------*
FORM CHK_REQ_VALUE_FOR_ERDT2  USING    PT_ERDT2 TYPE FRE_ERDAT_RTTY.

  CHECK SY-UCOMM   EQ 'ONLI'    AND
        P_SEARCH   EQ ABAP_TRUE AND
        PT_ERDT2[] IS INITIAL.

*-- 조회조건 없이 실행시 오류 메세지 구성
  MESSAGE E278(00) WITH '시작업요청 생성일'(E04).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form chk_value_for_pjno
*&---------------------------------------------------------------------*
*& 조회조건 영업조직, 프로젝트 정보 기준 정합성 확인
*&---------------------------------------------------------------------*
FORM CHK_VALUE_FOR_PJNO .

  DATA : LR_ZPJNO TYPE RANGE OF ZPJNO.

  CLEAR : GV_VKBUR,
          LR_ZPJNO.

  IF P_ZPJNO IS NOT INITIAL.
    APPEND VALUE #(
                    SIGN   = GC_SIGN-I
                    OPTION = GC_OPTN-EQ
                    LOW    = P_ZPJNO
                  ) TO LR_ZPJNO.
  ENDIF.

  CHECK SY-UCOMM EQ 'ONLI'.

*-- 영업조직, 프로젝트 간 종속성 확인
  SELECT SINGLE A~ZVKBUR
    FROM ZSD0106T AS A INNER JOIN TVKBZ AS B
                          ON A~ZVKBUR EQ B~VKBUR
   WHERE A~ZPJNO  IN @LR_ZPJNO
     AND B~SPART  EQ @P_SPART
     AND B~VKORG  EQ @P_VKORG
     AND A~ZVKGRP EQ @GC_VKGRP-172
     AND A~ZVKBUR EQ @GC_VKBUR-1710

    INTO @GV_VKBUR.

  CHECK SY-SUBRC NE 0.
  MESSAGE E400.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form select_data
*&---------------------------------------------------------------------*
*& 조회조건 기준 해당 정보 Select
*&---------------------------------------------------------------------*
FORM SELECT_DATA .

  DATA : LS_HEAD TYPE GTY_HEAD,
         LS_ITEM TYPE GTY_0065.

  DATA : LR_ZSTAT TYPE RANGE OF ZGTE_ZSTAT,
         LR_ZPJNO TYPE RANGE OF ZPJNO.

  CLEAR : GT_HEAD,  GT_ITEM, GT_ITEM_ALL,
          LR_ZSTAT, LR_ZPJNO,
          GV_SYSID.

  IF P_ZPJNO IS NOT INITIAL.
    APPEND VALUE #(
                    SIGN   = GC_SIGN-I
                    OPTION = GC_OPTN-EQ
                    LOW    = P_ZPJNO
                  ) TO LR_ZPJNO.
  ENDIF.

*-- 1. 조직정보 기준 송신 System 확인
  CALL FUNCTION 'ZGTSD_GET_TARGETSYS'
    EXPORTING
      I_VKBUR = GV_VKBUR
    IMPORTING
      E_SYSID = GV_SYSID.

*-- Radio Buttion 기준 값 Select
  CASE ABAP_TRUE.
    WHEN P_CRTE.            " 생성

      APPEND VALUE #(
                      SIGN   = GC_SIGN-I
                      OPTION = GC_OPTN-NE
                      LOW    = 'S'
                    ) TO LR_ZSTAT.

      SELECT A~ZSYSTEM_ID,    A~MREQNO,      A~ZPJNO,      A~JOB_NO,  A~POSNR,
             A~ITEM_KEY,      A~JOB_NAME,    A~ZDELV_DATE, A~MATNR,   A~MAKTX,
             A~WERKS,         A~KWMENG,      A~MEINS,      A~ORD_LEN, A~ORD_WGT,
             A~VOLTAGE_CD,    A~PROD_TYPE,   A~WIRE_CNT,   A~AMPHERE, A~COND_MTRL,
             A~DUCT_MTRL_EST, A~GROUND_TYPE, A~IPGRADE,    A~CONDTW,  A~GRSPEC,
             A~STDNAME,       A~SERIALNO,    A~ECOPTYPE,   A~N_WIRE_TYPE,
             A~BRKMD,         A~FRAMPH,      A~OPMTHD,     A~PHTAP,   A~VBELN,
             A~CHR_KEY,       A~ERDAT,       A~ZSTAT,      A~ZMSG,

             B~ZAPPROVE_USERID,  B~ZAPPROVE_DATE

        FROM ZGTSDT0065 AS A INNER JOIN ZGTEDT2121 AS B
                                ON A~ZSYSTEM_ID EQ B~ZSYSTEM_ID
                               AND A~JOB_NO     EQ B~ZJOB_NO
                               AND A~ZPJNO      EQ B~ZPJT_NO

                             INNER JOIN ZSD0106T AS C
                                ON A~ZPJNO      EQ C~ZPJNO

       WHERE A~ZSYSTEM_ID EQ @GV_SYSID
         AND A~ZPJNO      IN @LR_ZPJNO
         AND A~JOB_NO     IN @S_JOBNO
         AND A~ERDAT      IN @S_ERDT1
         AND ( A~VBELN    IS INITIAL OR
               A~VBELN    EQ @ABAP_FALSE )
         AND A~ZSTAT      IN @LR_ZSTAT
         AND C~ZGUBUN     EQ 'S'

      ORDER BY A~ZPJNO, A~JOB_NO, A~POSNR

       INTO TABLE @DATA(LT_MAIN).

    WHEN P_SEARCH.          " 조회

*-- 조회 Option 라디오 버튼 기준 Range 값 구성
      CASE ABAP_TRUE.
        WHEN P_ALL.         " 전체조회
          CLEAR LR_ZSTAT.

        WHEN P_SUCCS.       " 성공
          APPEND VALUE #(
                          SIGN   = GC_SIGN-I
                          OPTION = GC_OPTN-EQ
                          LOW    = 'S'
                        ) TO LR_ZSTAT.

        WHEN P_FAIL.        " 실패
          APPEND VALUE #(
                          SIGN   = GC_SIGN-I
                          OPTION = GC_OPTN-EQ
                          LOW    = 'E'
                        ) TO LR_ZSTAT.
      ENDCASE.

      SELECT A~ZSYSTEM_ID,    A~MREQNO,      A~ZPJNO,      A~JOB_NO,  A~POSNR,
             A~ITEM_KEY,      A~JOB_NAME,    A~ZDELV_DATE, A~MATNR,   A~MAKTX,
             A~WERKS,         A~KWMENG,      A~MEINS,      A~ORD_LEN, A~ORD_WGT,
             A~VOLTAGE_CD,    A~PROD_TYPE,   A~WIRE_CNT,   A~AMPHERE, A~COND_MTRL,
             A~DUCT_MTRL_EST, A~GROUND_TYPE, A~IPGRADE,    A~CONDTW,  A~GRSPEC,
             A~STDNAME,       A~SERIALNO,    A~ECOPTYPE,   A~N_WIRE_TYPE,
             A~BRKMD,         A~FRAMPH,      A~OPMTHD,     A~PHTAP,   A~VBELN,
             A~CHR_KEY,       A~ERDAT,       A~ZSTAT,      A~ZMSG,

             B~ZAPPROVE_USERID,  B~ZAPPROVE_DATE

        FROM ZGTSDT0065 AS A INNER JOIN ZGTEDT2121 AS B
                                ON A~ZSYSTEM_ID EQ B~ZSYSTEM_ID
                               AND A~JOB_NO     EQ B~ZJOB_NO
                               AND A~ZPJNO      EQ B~ZPJT_NO

                             INNER JOIN ZSD0106T AS C
                                ON A~ZPJNO EQ C~ZPJNO

       WHERE A~ZSYSTEM_ID EQ @GV_SYSID
         AND A~ZPJNO      IN @LR_ZPJNO
         AND A~JOB_NO     IN @S_JOBNO
         AND A~AEDAT      IN @S_ERDT2
         AND A~ZSTAT      IN @LR_ZSTAT
         AND C~ZGUBUN     EQ 'S'

       ORDER BY A~ZPJNO, A~JOB_NO, A~POSNR

       INTO TABLE @LT_MAIN.

  ENDCASE.

  CHECK LT_MAIN[] IS NOT INITIAL.

*-- 2. 조회정보 기준 Header / Item 전체 리스트 정보 구성
  DATA(LT_BASE) = LT_MAIN[].

  DELETE ADJACENT DUPLICATES FROM LT_BASE
                             COMPARING ZPJNO JOB_NO.

  LOOP AT LT_BASE INTO DATA(LS_BASE).
    CLEAR LS_HEAD.
*-- 2-1. Header 정보 구성
    CLEAR : LS_HEAD.

    LS_HEAD = VALUE #(
                      VKORG     = P_VKORG                           " 영업조직
                      ZPJNO     = LS_BASE-ZPJNO                     " 프로젝트
                      JOB_NO    = LS_BASE-JOB_NO                    " 제조지시번호
                      JOB_NAME  = LS_BASE-JOB_NAME                  " 제조지시명
                      PROD_ID   = LS_BASE-PROD_TYPE                 " 제품구분
                      WIRECNT   = LS_BASE-WIRE_CNT                  " 상
                      VOLTAGE   = LS_BASE-VOLTAGE_CD                " 전압
                      CONDMTRL  = LS_BASE-COND_MTRL                 " 도체재질
                      DUCTMTRL  = LS_BASE-DUCT_MTRL_EST             " 덕트재질
                      GRNDTYP   = LS_BASE-GROUND_TYPE               " 접지
                      AMPHERE   = LS_BASE-AMPHERE                   " 전류세기
                      IPGRADE   = LS_BASE-IPGRADE                   " IP
                      VBELN     = LS_BASE-VBELN                     " 생산요청번호
                      ZAPRV_ID  = LS_BASE-ZAPPROVE_USERID           " 설계승인자
                      ZAPRV_DAT = LS_BASE-ZAPPROVE_DATE             " 설계승인일

                      ZSTAT     = COND #( WHEN P_SEARCH EQ ABAP_TRUE
                                            THEN LS_BASE-ZSTAT      " 성공/실패
                                          ELSE ABAP_FALSE )
                      ZREMARK   = LS_BASE-ZMSG                      " 비고
                     ).

    LS_HEAD-STAT = COND #( WHEN LS_HEAD-ZSTAT IS INITIAL OR
                                LS_HEAD-ZSTAT EQ ABAP_FALSE  THEN ICON_LED_YELLOW
                           WHEN LS_HEAD-ZSTAT EQ 'S' AND
                                LS_HEAD-VBELN IS NOT INITIAL THEN ICON_LED_GREEN
                           WHEN LS_HEAD-ZSTAT EQ 'E'         THEN ICON_LED_RED
                           ELSE ICON_LED_INACTIVE
                         ).

    APPEND LS_HEAD TO GT_HEAD.

    READ TABLE LT_MAIN WITH KEY ZPJNO  = LS_BASE-ZPJNO
                                JOB_NO = LS_BASE-JOB_NO
                       BINARY SEARCH TRANSPORTING NO FIELDS.
    IF SY-SUBRC EQ 0.
      LOOP AT LT_MAIN INTO DATA(LS_MAIN)
                      FROM SY-TABIX.
        IF LS_MAIN-ZPJNO  NE LS_BASE-ZPJNO OR
           LS_MAIN-JOB_NO NE LS_BASE-JOB_NO.
          EXIT.
        ENDIF.

*-- 2-2 Item 전체 리스트 정보 구성
        CLEAR LS_ITEM.

        LS_ITEM = CORRESPONDING #( LS_MAIN ).

        CALL FUNCTION 'CONVERSION_EXIT_MATN1_INPUT'
          EXPORTING
            INPUT        = LS_MAIN-MATNR
          IMPORTING
            OUTPUT       = LS_ITEM-MATNR
          EXCEPTIONS
            LENGTH_ERROR = 1
            OTHERS       = 2.

        APPEND LS_ITEM TO GT_ITEM_ALL.

      ENDLOOP.
    ENDIF.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form init_class_alv_info_0100
*&---------------------------------------------------------------------*
*& Screen 0100 Class ALV 구성
*&---------------------------------------------------------------------*
FORM INIT_CLASS_ALV_INFO_0100 .

  IF GO_DOCK_CONT_0100 IS NOT BOUND.
*-- ALV Docking Container & ALV Grid 정보 구성
    PERFORM CRTE_OBJT_GRID_0100     CHANGING GO_DOCK_CONT_0100
                                             GO_GRID_HEAD
                                             GO_GRID_ITEM.

*-----------------------------------------------------------------------
*-- Header ALV 정보 구성
*-----------------------------------------------------------------------
    IF GO_GRID_HEAD IS BOUND.
*-- Header Layout 구성
      PERFORM SET_LAYOUT_HEAD       CHANGING GS_LAYO_HEAD.

*-- Header 예외 Toolbar 정보 구성
      PERFORM SET_EXCLUDE_HEAD      CHANGING GT_EXCL_HEAD.

*-- Header Fieldcatalog 정보 구성
      PERFORM SET_FCAT_F_HEAD       CHANGING GT_FCAT_HEAD.

*-- Header ALV Event 정보 구성
      PERFORM SET_EVENT_HANDLER     USING    GO_GRID_HEAD
                                    CHANGING GO_EVENT_HANDLER.
*-- Header ALV Display
      PERFORM DISP_ALV_GRID_HEAD    USING    GO_GRID_HEAD.
    ENDIF.

*-----------------------------------------------------------------------
*-- Item ALV 정보 구성
*-----------------------------------------------------------------------
    IF GO_GRID_ITEM IS BOUND.
*-- Item Layout 구성
      PERFORM SET_LAYOUT_ITEM       CHANGING GS_LAYO_ITEM.

*-- Item 예외 Toolbar 정보 구성
      PERFORM SET_EXCLUDE_ITEM      CHANGING GT_EXCL_ITEM.

*-- Item Fieldcatalog 정보 구성
      PERFORM SET_FCAT_F_ITEM      CHANGING GT_FCAT_ITEM.

*-- Item ALV Event 정보 구성
      PERFORM SET_EVENT_HANDLER     USING    GO_GRID_ITEM
                                    CHANGING GO_EVENT_HANDLER.
*-- Item ALV Display
      PERFORM DISP_ALV_GRID_ITEM    USING    GO_GRID_ITEM.
    ENDIF.
  ELSE.

*-- ALV Refresh 수행
    IF GO_GRID_HEAD IS BOUND.
      PERFORM REFRESH_ALV_DISP      USING    GO_GRID_HEAD
                                             ABAP_FALSE.
    ENDIF.

    IF GO_GRID_ITEM IS BOUND.
      PERFORM REFRESH_ALV_DISP      USING    GO_GRID_ITEM
                                             ABAP_FALSE.
    ENDIF.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form crte_objt_grid_0100
*&---------------------------------------------------------------------*
*&  Screen 0100 Class ALV Docking Container & Grid 정보 생성
*&---------------------------------------------------------------------*
*&      <-- PO_DOCK_CONT  : 해당 Docking Container 생성 정보 리턴
*&      <-- PO_GRID_HEAD  : Header ALV Grid 생성 정보 리턴
*&      <-- PO_GRID_ITEM  : Item ALV Grid 생성 정보 리턴
*&---------------------------------------------------------------------*
FORM CRTE_OBJT_GRID_0100  CHANGING PO_DOCK_CONT TYPE REF TO CL_GUI_DOCKING_CONTAINER
                                   PO_GRID_HEAD TYPE REF TO CL_GUI_ALV_GRID
                                   PO_GRID_ITEM TYPE REF TO CL_GUI_ALV_GRID.
*-----------------------------------------------------------------------
*-- 1. Docking Container 생성
*-----------------------------------------------------------------------
  CREATE OBJECT PO_DOCK_CONT
    EXPORTING
      REPID     = SY-CPROG
      DYNNR     = SY-DYNNR
      SIDE      = PO_DOCK_CONT->DOCK_AT_TOP
      EXTENSION = 1500.

*-----------------------------------------------------------------------
*-- 2. 2 Row Split & Grid 구성
*-----------------------------------------------------------------------
*-- 2-1. 2-Row 분할 생성
  CREATE OBJECT GO_SPLT_0100
    EXPORTING
      PARENT  = PO_DOCK_CONT
      ROWS    = 2
      COLUMNS = 1.

*-- 2-2. Header ALV Container 구성
  CALL METHOD GO_SPLT_0100->GET_CONTAINER
    EXPORTING
      ROW       = 1
      COLUMN    = 1
    RECEIVING
      CONTAINER = GO_GUI_CONT_HEAD.

*-- 2-3. Item ALV Container 구성
  CALL METHOD GO_SPLT_0100->GET_CONTAINER
    EXPORTING
      ROW       = 2
      COLUMN    = 1
    RECEIVING
      CONTAINER = GO_GUI_CONT_ITEM.

*-- 2-4. Split Header ALV 높이 조정
  CALL METHOD GO_SPLT_0100->SET_ROW_HEIGHT
    EXPORTING
      ID     = 1
      HEIGHT = 45.

*-- 2-5. Head ALV Grid 구성
  CREATE OBJECT PO_GRID_HEAD
    EXPORTING
      I_PARENT = GO_GUI_CONT_HEAD.

*-- 2-6. Item ALV Grid 구성
  CREATE OBJECT PO_GRID_ITEM
    EXPORTING
      I_PARENT = GO_GUI_CONT_ITEM.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_layout_head
*&---------------------------------------------------------------------*
*& Screen 0100 Header ALV Layout 정보 구성
*&---------------------------------------------------------------------*
*&      <-- PS_LAYOUT   : 해당 Layout 구성 정보 리턴
*&---------------------------------------------------------------------*
FORM SET_LAYOUT_HEAD  CHANGING PS_LAYOUT   TYPE LVC_S_LAYO.

  CLEAR : PS_LAYOUT.

  PS_LAYOUT = VALUE #(
                      GRID_TITLE = '시작업생산요청 제번 정보'(T04)
*                      cwidth_opt = abap_true
                      SEL_MODE   = |C|
                      ZEBRA      = ABAP_TRUE
                     ).
ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_exclude_head
*&---------------------------------------------------------------------*
*& Screen 0100 Header ALV Toolbar 예외 버튼 정보 구성
*&---------------------------------------------------------------------*
*&      <-- PT_EXCLUDE  : 예외 정보 리턴
*&---------------------------------------------------------------------*
FORM SET_EXCLUDE_HEAD  CHANGING PT_EXCLUDE TYPE UI_FUNCTIONS.

  PERFORM ADD_EXCLUDE_TOOLBAR       TABLES   PT_EXCLUDE[]
                                    USING  : CL_GUI_ALV_GRID=>MC_FC_LOC_UNDO,
                                             CL_GUI_ALV_GRID=>MC_FC_AUF,
                                             CL_GUI_ALV_GRID=>MC_FC_CHECK,
                                             CL_GUI_ALV_GRID=>MC_FC_LOC_PASTE,
                                             CL_GUI_ALV_GRID=>MC_FC_LOC_COPY,
                                             CL_GUI_ALV_GRID=>MC_FC_AVERAGE,
                                             CL_GUI_ALV_GRID=>MC_FC_GRAPH,
                                             CL_GUI_ALV_GRID=>MC_FC_INFO,
                                             CL_GUI_ALV_GRID=>MC_FC_LOC_COPY_ROW,
                                             CL_GUI_ALV_GRID=>MC_FC_LOC_CUT,
                                             CL_GUI_ALV_GRID=>MC_FC_LOC_DELETE_ROW,
                                             CL_GUI_ALV_GRID=>MC_FC_LOC_INSERT_ROW,
                                             CL_GUI_ALV_GRID=>MC_FC_LOC_APPEND_ROW,
                                             CL_GUI_ALV_GRID=>MC_FC_LOC_PASTE,
                                             CL_GUI_ALV_GRID=>MC_FC_LOC_PASTE_NEW_ROW,
                                             CL_GUI_ALV_GRID=>MC_FC_REFRESH.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form add_exclude_toolbar
*&---------------------------------------------------------------------*
*& Class ALV Toolbar 예외 버튼 정보 추가
*&---------------------------------------------------------------------*
*&      <-- PT_EXCLUDE  : 해당 예외 버튼 정보 추가
*&      --> PV_VALUE    : 예외 버튼 정보
*&---------------------------------------------------------------------*
FORM ADD_EXCLUDE_TOOLBAR  TABLES   PT_EXCLUDE
                          USING    PV_VALUE.

  DATA : LS_EXCL TYPE UI_FUNC.

  LS_EXCL = PV_VALUE.

  APPEND LS_EXCL TO PT_EXCLUDE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_fcat_f_head
*&---------------------------------------------------------------------*
*& Screen Header ALV Fieldcatalog 정보 구성
*&---------------------------------------------------------------------*
*&      <-- PT_FCAT  : 해당 Fieldcatalog 정보 리턴
*&---------------------------------------------------------------------*
FORM SET_FCAT_F_HEAD  CHANGING PT_FCAT TYPE LVC_T_FCAT.

*-- 1. 해당 Internal Table 정보 기준 Fieldcatlog 정보 구성
  PERFORM INIT_FCAT_FROM_ITAB       USING    GT_HEAD
                                    CHANGING PT_FCAT.

*-- 2. 추가 정보 구성
  LOOP AT PT_FCAT ASSIGNING FIELD-SYMBOL(<LS_FCAT>).
    CASE <LS_FCAT>-FIELDNAME.
      WHEN 'CHECK'.
        <LS_FCAT>-OUTPUTLEN = 4.
        <LS_FCAT>-CHECKBOX  = ABAP_TRUE.
        <LS_FCAT>-EDIT      = ABAP_TRUE.
        <LS_FCAT>-COLTEXT   = '선택'(F03).
        <LS_FCAT>-SCRTEXT_L = '선택'(F03).
        <LS_FCAT>-SCRTEXT_M = '선택'(F03).
        <LS_FCAT>-SCRTEXT_S = '선택'(F03).

      WHEN 'STAT'.
        <LS_FCAT>-ICON      = ABAP_TRUE.
        <LS_FCAT>-COLTEXT   = '상태'(F02).
        <LS_FCAT>-SCRTEXT_L = '상태'(F02).
        <LS_FCAT>-SCRTEXT_M = '상태'(F02).
        <LS_FCAT>-SCRTEXT_S = '상태'(F02).

      WHEN 'VKORG'.
        <LS_FCAT>-OUTPUTLEN = 8.

      WHEN 'VBELN'.
        <LS_FCAT>-OUTPUTLEN = 12.
        <LS_FCAT>-COLTEXT   = '시작업생산요청번호'(F04).
        <LS_FCAT>-SCRTEXT_L = '시작업생산요청번호'(F04).
        <LS_FCAT>-SCRTEXT_M = '시작업생산요청번호'(F04).
        <LS_FCAT>-SCRTEXT_S = '시작업생산요청번호'(F04).

      WHEN 'PROD_ID'.
        <LS_FCAT>-OUTPUTLEN = 8.

      WHEN 'VOLTAGE' OR 'CONDMTRL' OR 'DUCTMTRL' OR 'GRNDTYP'.
        <LS_FCAT>-OUTPUTLEN = 8.

      WHEN 'IPGRADE'.
        <LS_FCAT>-OUTPUTLEN = 4.
        <LS_FCAT>-COLTEXT   = 'IP'(F05).
        <LS_FCAT>-SCRTEXT_L = 'IP'(F05).
        <LS_FCAT>-SCRTEXT_M = 'IP'(F05).
        <LS_FCAT>-SCRTEXT_S = 'IP'(F05).

      WHEN 'ZREMARK'.
        <LS_FCAT>-OUTPUTLEN = 40.
        <LS_FCAT>-EMPHASIZE = 'C300'.
        <LS_FCAT>-COLTEXT   = '비고'(F01).
        <LS_FCAT>-SCRTEXT_L = '비고'(F01).
        <LS_FCAT>-SCRTEXT_M = '비고'(F01).
        <LS_FCAT>-SCRTEXT_S = '비고'(F01).

      WHEN 'JOB_NAME'.
        <LS_FCAT>-OUTPUTLEN = 40.

      WHEN 'ZAPRV_ID' OR 'ZAPRV_DAT' OR 'ZSTAT'.
        <LS_FCAT>-NO_OUT    = ABAP_TRUE.
      WHEN OTHERS.
    ENDCASE.

  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form init_fcat_from_itab
*&---------------------------------------------------------------------*
*& 해당 Internal Table 정보 기준 LVC Fieldcatalog 정보 구성
*&---------------------------------------------------------------------*
*&      --> PT_TAB   : 해당 Internal Table 정보
*&      <-- PT_FCAT  : 해당 Fieldcatalog 정보 리턴
*&---------------------------------------------------------------------*
FORM INIT_FCAT_FROM_ITAB  USING    PT_TAB
                          CHANGING PT_FCAT  TYPE LVC_T_FCAT.

  LOOP AT CL_SALV_DDIC=>GET_BY_DATA( PT_TAB ) INTO DATA(LS_DFIES).
    DATA(LS_FCAT) = CORRESPONDING LVC_S_FCAT( LS_DFIES MAPPING KEY = KEYFLAG ).

    LS_FCAT-COL_POS     = SY-TABIX.             " ALV 출력 열 기본값 구성

    IF LS_FCAT-DATATYPE EQ 'CLNT'.              " Client 필드 구성
      LS_FCAT-TECH      = ABAP_TRUE.
    ENDIF.

*-- 참조 필드 정보 구성
    IF LS_DFIES-LFIELDNAME IS NOT INITIAL.
      LS_FCAT-REF_TABLE = LS_DFIES-PRECFIELD.
      LS_FCAT-REF_FIELD = LS_DFIES-LFIELDNAME.
    ELSE.
      LS_FCAT-REF_TABLE = LS_DFIES-REFTABLE.
      LS_FCAT-REF_FIELD = LS_DFIES-REFFIELD.
    ENDIF.

*-- 수량 / 금액 필드 정보 구성
    IF LS_DFIES-REFTABLE EQ LS_DFIES-PRECFIELD AND
       LS_DFIES-REFFIELD IS NOT INITIAL.
      CASE LS_FCAT-DATATYPE.
        WHEN 'CURR'.        " 금액
          LS_FCAT-CFIELDNAME = LS_DFIES-REFFIELD.
        WHEN 'QUAN'.        " 수량
          LS_FCAT-QFIELDNAME = LS_DFIES-REFFIELD.
      ENDCASE.
    ENDIF.

*-- 누락 필드명 정보 구성
    IF LS_FCAT-COLTEXT   IS INITIAL AND
       LS_FCAT-REPTEXT   IS INITIAL AND
       LS_FCAT-SCRTEXT_L IS INITIAL AND
       LS_FCAT-SCRTEXT_M IS INITIAL AND
       LS_FCAT-SCRTEXT_S IS INITIAL.
      LS_FCAT-COLTEXT = LS_DFIES-FIELDTEXT.
    ENDIF.

    IF LS_DFIES-LFIELDNAME IS NOT INITIAL.
      CLEAR LS_FCAT-ROLLNAME.
    ENDIF.
    APPEND LS_FCAT TO PT_FCAT.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_event_handler
*&---------------------------------------------------------------------*
*& Screen 0100 Class ALV Event 정보 구성
*&---------------------------------------------------------------------*
*&      --> PO_GRID   : 해당 ALV Grid 정보
*&      <-- PO_EVENT  : 해당 ALV Event 구현 정보 리턴
*&---------------------------------------------------------------------*
FORM SET_EVENT_HANDLER  USING    PO_GRID  TYPE REF TO CL_GUI_ALV_GRID
                        CHANGING PO_EVENT TYPE REF TO LCL_EVENT_HANDLER.

  IF PO_EVENT IS NOT BOUND.
    CREATE OBJECT PO_EVENT.
  ENDIF.

*-- ALV Grid 별 Event 정보 구성
  CASE PO_GRID.
    WHEN GO_GRID_HEAD.
      SET HANDLER PO_EVENT->HANDLE_DOUBLE_CLICK           FOR PO_GRID.
    WHEN GO_GRID_ITEM.

  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form disp_alv_grid_head
*&---------------------------------------------------------------------*
*& Screen 0100 Header ALV Display
*&---------------------------------------------------------------------*
*&      --> PO_GRID  : 해당 ALV Grid 정보
*&---------------------------------------------------------------------*
FORM DISP_ALV_GRID_HEAD  USING    PO_GRID TYPE REF TO CL_GUI_ALV_GRID.

  DATA : LV_EDIT TYPE I.

  CLEAR : GS_VARI_HEAD.
*-- Haader ALV Varient 기본 정보 구성
  GS_VARI_HEAD = VALUE #(
                          REPORT   = SY-CPROG
                          USERNAME = SY-UNAME
                          HANDLE   = 1
                        ).

*-- ALV Display 수행
  CALL METHOD PO_GRID->SET_TABLE_FOR_FIRST_DISPLAY
    EXPORTING
      IS_LAYOUT            = GS_LAYO_HEAD
      IT_TOOLBAR_EXCLUDING = GT_EXCL_HEAD
      IS_VARIANT           = GS_VARI_HEAD
      I_SAVE               = 'A'
    CHANGING
      IT_OUTTAB            = GT_HEAD[]
      IT_FIELDCATALOG      = GT_FCAT_HEAD.

*-- 생성 / 조회 기준 Edit 기능 구성
  LV_EDIT = COND #( WHEN P_CRTE EQ ABAP_TRUE THEN 1
                    ELSE 0 ).

  CALL METHOD PO_GRID->SET_READY_FOR_INPUT
    EXPORTING
      I_READY_FOR_INPUT = LV_EDIT.

  CALL METHOD PO_GRID->REGISTER_EDIT_EVENT
    EXPORTING
      I_EVENT_ID = CL_GUI_ALV_GRID=>MC_EVT_MODIFIED.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_layout_item
*&---------------------------------------------------------------------*
*& Screen 0100 Header ALV Layout 정보 구성
*&---------------------------------------------------------------------*
*&      <-- PS_LAYOUT   : 해당 Layout 구성 정보 리턴
*&---------------------------------------------------------------------*
FORM SET_LAYOUT_ITEM  CHANGING PS_LAYOUT   TYPE LVC_S_LAYO.

  CLEAR : PS_LAYOUT.

  PS_LAYOUT = VALUE #(
                      GRID_TITLE = '시작업생산요청 제번 세부정보'(T05)
*                      cwidth_opt = abap_true
                      SEL_MODE   = |B|
                      ZEBRA      = ABAP_TRUE

                     ).
ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_exclude_item
*&---------------------------------------------------------------------*
*& Screen 0100 Item ALV Toolbar 예외 버튼 정보 구성
*&---------------------------------------------------------------------*
*&      <-- PT_EXCLUDE  : 예외 정보 리턴
*&---------------------------------------------------------------------*
FORM SET_EXCLUDE_ITEM  CHANGING PT_EXCLUDE TYPE UI_FUNCTIONS.

  PERFORM ADD_EXCLUDE_TOOLBAR       TABLES   PT_EXCLUDE[]
                                    USING  : CL_GUI_ALV_GRID=>MC_FC_LOC_UNDO,
                                             CL_GUI_ALV_GRID=>MC_FC_AUF,
                                             CL_GUI_ALV_GRID=>MC_FC_CHECK,
                                             CL_GUI_ALV_GRID=>MC_FC_LOC_PASTE,
                                             CL_GUI_ALV_GRID=>MC_FC_LOC_COPY,
                                             CL_GUI_ALV_GRID=>MC_FC_AVERAGE,
                                             CL_GUI_ALV_GRID=>MC_FC_GRAPH,
                                             CL_GUI_ALV_GRID=>MC_FC_INFO,
                                             CL_GUI_ALV_GRID=>MC_FC_LOC_COPY_ROW,
                                             CL_GUI_ALV_GRID=>MC_FC_LOC_CUT,
                                             CL_GUI_ALV_GRID=>MC_FC_LOC_DELETE_ROW,
                                             CL_GUI_ALV_GRID=>MC_FC_LOC_INSERT_ROW,
                                             CL_GUI_ALV_GRID=>MC_FC_LOC_APPEND_ROW,
                                             CL_GUI_ALV_GRID=>MC_FC_LOC_PASTE,
                                             CL_GUI_ALV_GRID=>MC_FC_LOC_PASTE_NEW_ROW,
                                             CL_GUI_ALV_GRID=>MC_FC_REFRESH.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_fcat_f_item
*&---------------------------------------------------------------------*
*& Screen Item ALV Fieldcatalog 정보 구성
*&---------------------------------------------------------------------*
*&      <-- PT_FCAT  : 해당 Fieldcatalog 정보 리턴
*&---------------------------------------------------------------------*
FORM SET_FCAT_F_ITEM  CHANGING PT_FCAT TYPE LVC_T_FCAT.

*-- 1. 해당 Internal Table 정보 기준 Fieldcatlog 정보 구성
  PERFORM INIT_FCAT_FROM_ITAB       USING    GT_ITEM
                                    CHANGING PT_FCAT.

*-- 2. 추가 정보 구성
  LOOP AT PT_FCAT ASSIGNING FIELD-SYMBOL(<LS_FCAT>).
    CASE <LS_FCAT>-FIELDNAME.
      WHEN 'MAKTX'.
        <LS_FCAT>-EMPHASIZE = 'C500'.
        <LS_FCAT>-COLTEXT   = '자재명'(F06).
        <LS_FCAT>-SCRTEXT_L = '자재명'(F06).
        <LS_FCAT>-SCRTEXT_M = '자재명'(F06).
        <LS_FCAT>-SCRTEXT_S = '자재명'(F06).

      WHEN 'MEINS' OR 'LEN_UNIT' OR 'WGT_UNIT'.
        <LS_FCAT>-COLTEXT   = '단위'(F07).
        <LS_FCAT>-SCRTEXT_L = '단위'(F07).
        <LS_FCAT>-SCRTEXT_M = '단위'(F07).
        <LS_FCAT>-SCRTEXT_S = '단위'(F07).

      WHEN OTHERS.
    ENDCASE.

  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form disp_alv_grid_item
*&---------------------------------------------------------------------*
*& Screen 0100 Item ALV Display
*&---------------------------------------------------------------------*
*&      --> PO_GRID  : 해당 ALV Grid 정보
*&---------------------------------------------------------------------*
FORM DISP_ALV_GRID_ITEM  USING    PO_GRID TYPE REF TO CL_GUI_ALV_GRID.

  CLEAR : GS_VARI_ITEM.
*-- Haader ALV Varient 기본 정보 구성
  GS_VARI_ITEM = VALUE #(
                          REPORT   = SY-CPROG
                          USERNAME = SY-UNAME
                          HANDLE   = 2
                        ).

*-- ALV Display 수행
  CALL METHOD PO_GRID->SET_TABLE_FOR_FIRST_DISPLAY
    EXPORTING
      IS_LAYOUT            = GS_LAYO_ITEM
      IT_TOOLBAR_EXCLUDING = GT_EXCL_ITEM
      IS_VARIANT           = GS_VARI_ITEM
      I_SAVE               = 'A'
    CHANGING
      IT_OUTTAB            = GT_ITEM[]
      IT_FIELDCATALOG      = GT_FCAT_ITEM.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form refresh_alv_disp
*&---------------------------------------------------------------------*
*& Class ALV Refresh 수행
*&---------------------------------------------------------------------*
*&      --> PO_GRID  : 해당 ALV Grid 정보
*&      --> PV_RESET : 해당 Layout Re Set Flag
*&---------------------------------------------------------------------*
FORM REFRESH_ALV_DISP  USING    PO_GRID  TYPE REF TO CL_GUI_ALV_GRID
                                PV_RESET TYPE CHAR01.

  DATA : LS_STBL   TYPE LVC_S_STBL,

         LS_LAYOUT TYPE LVC_S_LAYO.

  LS_STBL = VALUE #(
                    ROW = ABAP_TRUE
                    COL = ABAP_TRUE
                   ).

  IF PV_RESET EQ ABAP_TRUE.
*-- LAyout Re Set 수행시
    CALL METHOD PO_GRID->GET_FRONTEND_LAYOUT
      IMPORTING
        ES_LAYOUT = LS_LAYOUT.

    CALL METHOD PO_GRID->SET_FRONTEND_LAYOUT
      EXPORTING
        IS_LAYOUT = LS_LAYOUT.

  ENDIF.

  CALL METHOD PO_GRID->REFRESH_TABLE_DISPLAY
    EXPORTING
      IS_STABLE = LS_STBL
    EXCEPTIONS
      FINISHED  = 1
      OTHERS    = 2.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form clear_alv_info
*&---------------------------------------------------------------------*
*& Class ALV 선언 정보 & 해당 변수 초기화
*&---------------------------------------------------------------------*
FORM CLEAR_ALV_INFO .

  CALL METHOD GO_DOCK_CONT_0100->FREE.

  CLEAR : GO_DOCK_CONT_0100, GO_SPLT_0100,     GO_EVENT_HANDLER,
          GO_GUI_CONT_HEAD,  GO_GUI_CONT_ITEM, GO_GRID_HEAD, GO_GRID_ITEM.

  CALL METHOD CL_GUI_CFW=>FLUSH.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form double_click_0100
*&---------------------------------------------------------------------*
*& Screen 0100 Class ALV Double Click 이벤트 수행
*&---------------------------------------------------------------------*
*&      --> PO_SENDER   : 해당 ALV Grid 정보
*&      --> PS_ROW      : 해당 Row 정보
*&      --> PS_COLUMN   : 해당 필드 정보
*&      --> PS_ROW_NO   : 해당 Row ID 정보
*&---------------------------------------------------------------------*
FORM DOUBLE_CLICK_0100  USING    PO_SENDER  TYPE REF TO CL_GUI_ALV_GRID
                                 PS_ROW     TYPE LVC_S_ROW
                                 PS_COLUMN  TYPE LVC_S_COL
                                 PS_ROW_NO  TYPE LVC_S_ROID.

  CASE PO_SENDER.
    WHEN GO_GRID_HEAD.      " Header
      CASE PS_COLUMN-FIELDNAME.
        WHEN 'JOB_NO'.      " 제조지시번호
          READ TABLE GT_HEAD INDEX PS_ROW_NO-ROW_ID
                             INTO DATA(LS_HEAD).

          PERFORM GET_ITEM_ALV_LIST USING    LS_HEAD-JOB_NO
                                    CHANGING GT_ITEM.
*-- Item ALV Refresh 수행
          PERFORM REFRESH_ALV_DISP  USING    GO_GRID_ITEM
                                             ABAP_TRUE.
      ENDCASE.

    WHEN GO_GRID_ITEM.      " Item

  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_item_alv_list
*&---------------------------------------------------------------------*
*& 해당 제조지시 번호 기준 Item 출력 정보 구성
*&---------------------------------------------------------------------*
*&      --> PV_JOB_NO  : Header 기준 선택된 제조지시 번호
*&      <-- PT_ITEM    : 해당 Item 출력정보 리턴
*&---------------------------------------------------------------------*
FORM GET_ITEM_ALV_LIST  USING    PV_JOB_NO  TYPE ZGTE_BD_JOBNO
                        CHANGING PT_ITEM    TYPE GTY_T_ITEM.

  CLEAR : PT_ITEM.

  SELECT A~*,
         @GC_MEINS-M  AS LEN_UNIT,
         @GC_MEINS-KG AS WGT_UNIT

    FROM @GT_ITEM_ALL AS A
   WHERE A~JOB_NO EQ @PV_JOB_NO

    INTO CORRESPONDING FIELDS OF TABLE @PT_ITEM.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form crte_quot_crte
*&---------------------------------------------------------------------*
*& 선택된 항목기준 시작업생산요청 생성
*&---------------------------------------------------------------------*
FORM CRTE_QUOT_CRTE .

  DATA : LV_ANSWER TYPE CHAR01.

  CLEAR LV_ANSWER.
*-----------------------------------------------------------------------
*-- 1. 선택 항목 정합성 체크 수행
*-----------------------------------------------------------------------
*-- 1-1. Check Box 선택 여부 확인
  SELECT SINGLE @ABAP_TRUE
    FROM @GT_HEAD AS A
   WHERE A~CHECK EQ @ABAP_TRUE

    INTO @DATA(LV_FLAG).

  IF SY-SUBRC NE 0.
*-- 선택한 시작업생산요청 없는경우 메세지 처리 & Exit
    MESSAGE S401 DISPLAY LIKE 'E'.
    EXIT.
  ENDIF.

*-- 1-2. 선택된 시작업생산요청 정합성 확인
  SELECT SINGLE @ABAP_TRUE
    FROM @GT_HEAD AS A
   WHERE A~CHECK EQ @ABAP_TRUE
     AND A~STAT  NE @ICON_LED_YELLOW

    INTO @LV_FLAG.

  IF SY-SUBRC EQ 0.
*-- 생성할수 없는 대상 선택된 경우 오류 메세지 처리 & Exit
    MESSAGE S402 DISPLAY LIKE 'E'.
    EXIT.
  ENDIF.

*-- 1-3. 생성여부 Popup 창 수행

  CALL FUNCTION 'POPUP_TO_CONFIRM'
    EXPORTING
      TITLEBAR              = '시작업생산요청'(T06)
      TEXT_QUESTION         = '시작업생산요청을 생성 하시겠습니까?'(M01)
      TEXT_BUTTON_1         = 'Yes'
      TEXT_BUTTON_2         = 'No'
      DISPLAY_CANCEL_BUTTON = ABAP_FALSE
    IMPORTING
      ANSWER                = LV_ANSWER
    EXCEPTIONS
      TEXT_NOT_FOUND        = 1
      OTHERS                = 2.

  IF LV_ANSWER NE '1'.
*-- 취소 메세지 처리 & Exit
    MESSAGE S050.
    EXIT.
  ENDIF.

*-----------------------------------------------------------------------
*-- 2. 시작업생산요청 BAPI 수행
*-----------------------------------------------------------------------
  PERFORM CRTE_CUST_QUOT_FOR_WORK   USING    GT_ITEM_ALL
                                    CHANGING GT_HEAD.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form crte_cust_quot_for_work
*&---------------------------------------------------------------------*
*& 시작업생산요청 BAPI 수행
*&---------------------------------------------------------------------*
*&      --> PT_ITEM   : 해당 Item 정보
*&      <-- PT_HEAD   : BAPI 수행 정보 & 결과 리턴
*&---------------------------------------------------------------------*
FORM CRTE_CUST_QUOT_FOR_WORK  USING    PT_ITEM  TYPE GTY_T_0065
                              CHANGING PT_HEAD  TYPE GTY_T_HEAD.

  CONSTANTS : LC_001 TYPE KLASSENART VALUE '001',
              LC_KEB TYPE BEDAE      VALUE 'KEB'.

  DATA : LS_CNT      TYPE GTY_RST_CNT,

         LS_HEADER   TYPE BAPISDHD1,
         LS_HEADERX  TYPE BAPISDHD1X,
         LS_ITEM_LST TYPE GTY_0065,

         LT_PARTNER  TYPE CMP_T_PARNR,
         LT_ITEM     TYPE BAPISDITM_TT,
         LT_ITEMX    TYPE CRMT_BAPISDITMX_T,
         LT_SCHL     TYPE CMP_T_SCHDL,
         LT_SCHLX    TYPE OIJ_BAPISCHDLX_T,
         LT_COND     TYPE VLC_BAPICOND_T,
         LT_CONDX    TYPE CRMT_BAPICONDX_T,
         LT_REF      TYPE BAPICUCFG_T,
         LT_INST     TYPE BAPICUINS_T,
         LT_VAL      TYPE BAPICUVAL_T,
         LT_EX_IN    TYPE BAPIPAREX_T,
         LT_RETURN   TYPE BAPIRET2_TT,

         LT_HEAD     TYPE GTY_T_HEAD,

         LV_EFLG     TYPE CHAR01,
         LV_VBELN    TYPE VBELN_VA,
         LV_CONFIG   TYPE CUX_CFG_ID,
         LV_INST_ID  TYPE CU_INST_ID,
         LV_ATNAM    TYPE ATNAM,
         LV_MSG      TYPE ZO_MESSAGE,

         LV_VALUE    TYPE CUX_VALUE40.

  CLEAR LS_CNT.
*-----------------------------------------------------------------------
*-- 1. BAPI 수행 추가 정보 Select
*-----------------------------------------------------------------------
*-- 1-1. Header 기준 선택 정보 구성
  SELECT A~STAT,  A~VKORG,  A~ZPJNO,  A~JOB_NO

    FROM @PT_HEAD AS A
   WHERE A~CHECK EQ @ABAP_TRUE
     AND A~STAT  EQ @ICON_LED_YELLOW

   ORDER BY A~VKORG, A~ZPJNO, A~JOB_NO

    INTO CORRESPONDING FIELDS OF TABLE @LT_HEAD.

  CHECK LT_HEAD[] IS NOT INITIAL.

*-- 1-2. 자재코드 기준 특정 정보 Select
  WITH +MAT_INFO AS ( SELECT A~MATNR
                        FROM @PT_ITEM AS A
                       GROUP BY A~MATNR )

    SELECT B~MATNR,  A~ATINN,  A~ATWRT

      FROM AUSP AS A INNER JOIN +MAT_INFO AS B
                        ON A~OBJEK EQ B~MATNR
     WHERE A~KLART EQ @LC_001

     ORDER BY B~MATNR

      INTO TABLE @DATA(LT_AUSP).

*-- 1-3. 특성값 정보 Select
  SELECT A~FLD_03 AS FNAME,
         A~FLD_04 AS CHARC

    FROM ZGTPPT1010 AS A
   WHERE A~MODULE_KIND EQ 'SD'
     AND A~CODEGRP     EQ '0063'
     AND A~FLD_01      EQ @GV_SYSID

    INTO TABLE @DATA(LT_CHARC).

*-- 1-4. 구성형 자재 정보 Select
  WITH +MAT_INFO AS ( SELECT A~WERKS, A~MATNR
                        FROM @PT_ITEM AS A
                       GROUP BY A~WERKS, A~MATNR )

    SELECT A~WERKS,  A~MATNR,  A~STDPD

      FROM MARC AS A INNER JOIN +MAT_INFO AS B
                        ON A~WERKS EQ B~WERKS
                       AND A~MATNR EQ B~MATNR
      ORDER BY A~WERKS, A~MATNR

       INTO TABLE @DATA(LT_MARC).

*-----------------------------------------------------------------------
*-- 2. BAPI 수행 Import 값 구성
*-----------------------------------------------------------------------
  LOOP AT LT_HEAD INTO DATA(LS_HEAD).
    CLEAR : LV_VBELN, LV_EFLG,
            LS_HEADER,  LS_HEADERX,
            LT_PARTNER, LT_ITEM,    LT_ITEMX, LT_SCHL, LT_SCHLX, LT_REF, LT_INST,
            LT_COND,    LT_CONDX,
            LT_VAL,     LT_EX_IN,   LT_RETURN.

*-- 2-1.  Header 정보 구성
    PERFORM INT_HEADER_INFO         USING    LS_HEAD
                                    CHANGING LS_HEADER
                                             LS_HEADERX.

*-- 2-2. Partner 정보 구성
    PERFORM INIT_PARTNER_INFO       CHANGING LT_PARTNER.

*-- 2-3. Header 추가필드 정보 구성
    PERFORM INIT_EXTENSION_HEAD     USING    LS_HEAD
                                    CHANGING LT_EX_IN.

*-- 2-4. Item 정보 기준 구성
    SELECT A~*
      FROM @PT_ITEM AS A
     WHERE A~ZPJNO  EQ @LS_HEAD-ZPJNO
       AND A~JOB_NO EQ @LS_HEAD-JOB_NO

      INTO CORRESPONDING FIELDS OF @LS_ITEM_LST.

      ADD 1 TO LV_CONFIG.
      LV_INST_ID = 1.

      READ TABLE LT_MARC WITH KEY WERKS = LS_ITEM_LST-WERKS
                                  MATNR = LS_ITEM_LST-MATNR
                         INTO DATA(LS_MARC).
      IF SY-SUBRC NE 0.
        CLEAR LS_MARC.
      ENDIF.

*-- 2-4-1. Item 정보 구성
      APPEND VALUE #(
                      ITM_NUMBER    = LS_ITEM_LST-POSNR
                      MATERIAL      = LS_ITEM_LST-MATNR
                      PLANT         = LS_ITEM_LST-WERKS
                      TARGET_QTY    = LS_ITEM_LST-KWMENG
                      TARGET_QU     = LS_ITEM_LST-MEINS
                      REQMTS_TYP    = LC_KEB
                      PO_ITM_NO     = LS_ITEM_LST-POSNR
                    ) TO LT_ITEM.

      APPEND VALUE #(
                      ITM_NUMBER    = LS_ITEM_LST-POSNR
                      MATERIAL      = ABAP_TRUE
                      PLANT         = ABAP_TRUE
                      TARGET_QTY    = ABAP_TRUE
                      TARGET_QU     = ABAP_TRUE
                      REQMTS_TYP    = ABAP_TRUE
                      PO_ITM_NO     = ABAP_TRUE
                    ) TO LT_ITEMX.

*-- 2-4-2. Schedule Line 정보 구성
      APPEND VALUE #(
                      ITM_NUMBER    = LS_ITEM_LST-POSNR
                      SCHED_LINE    = 1
                      DATE_TYPE     = '1'
                      REQ_QTY       = LS_ITEM_LST-KWMENG
                    ) TO LT_SCHL.

      APPEND VALUE #(
                      ITM_NUMBER    = LS_ITEM_LST-POSNR
                      SCHED_LINE    = 1
                      DATE_TYPE     = ABAP_TRUE
                      REQ_QTY       = ABAP_TRUE
                    ) TO LT_SCHLX.

*-- 2-4-3. Reference Data 정보 구성
      CONDENSE : LS_MARC-STDPD.
      APPEND VALUE #(
                      POSEX         = LS_ITEM_LST-POSNR
                      CONFIG_ID     = LV_CONFIG
                      ROOT_ID       = LV_INST_ID
                      SCE           = ABAP_FALSE
                      KBNAME        = LS_MARC-STDPD
                      KBVERSION     = '001'
                    ) TO LT_REF.

*-- 2-4-4, Instances 정보 구성
      APPEND VALUE #(
                      CONFIG_ID     = LV_CONFIG
                      INST_ID       = LV_INST_ID
                      OBJ_TYPE      = 'MARA'
                      CLASS_TYPE    = '300'
                      OBJ_KEY       = LS_MARC-STDPD
                    ) TO LT_INST.

*-- 2-4-5. Characteristic Values 정보 구성
*      READ TABLE lt_ausp WITH KEY matnr = ls_item_lst-matnr
*                         BINARY SEARCH TRANSPORTING NO FIELDS.
*      IF sy-subrc EQ 0.
**-- 자재코드 기준 특성 정보 구성
*        LOOP AT lt_ausp INTO DATA(ls_ausp)
*                        FROM sy-tabix.
*          IF ls_ausp-matnr NE ls_item_lst-matnr.
*            EXIT.
*          ENDIF.
*
*          CALL FUNCTION 'CONVERSION_EXIT_ATINN_OUTPUT'
*            EXPORTING
*              input  = ls_ausp-atinn
*            IMPORTING
*              output = lv_atnam.
*
*          APPEND VALUE #(
*                          config_id = lv_config
*                          inst_id   = lv_inst_id
*                          charc     = lv_atnam
*                          value     = ls_ausp-atwrt
*                        ) TO lt_val.
*        ENDLOOP.
*      ENDIF.

*-- 공통코드 정보 기준 특성 정보 구성
      LOOP AT LT_CHARC INTO DATA(LS_CHARC).
        ASSIGN COMPONENT LS_CHARC-FNAME OF STRUCTURE LS_ITEM_LST TO FIELD-SYMBOL(<LV_VAL>).
        CHECK <LV_VAL> IS ASSIGNED.

        LV_VALUE = |{ <LV_VAL> ALPHA = OUT }|.
        CONDENSE : LV_VALUE.

        APPEND VALUE #(
                        CONFIG_ID   = LV_CONFIG
                        INST_ID     = LV_INST_ID
                        CHARC       = LS_CHARC-CHARC
                        VALUE       = LV_VALUE
                      ) TO LT_VAL.

        IF <LV_VAL> IS ASSIGNED.
          UNASSIGN <LV_VAL>.
        ENDIF.
      ENDLOOP.
    ENDSELECT.

*-----------------------------------------------------------------------
*-- 3. BAPI : BAPI_QUOTATION_CREATEFROMDATA2 수행
*-----------------------------------------------------------------------
    CALL FUNCTION 'BAPI_QUOTATION_CREATEFROMDATA2'
      EXPORTING
        QUOTATION_HEADER_IN      = LS_HEADER
        QUOTATION_HEADER_INX     = LS_HEADERX
      IMPORTING
        SALESDOCUMENT            = LV_VBELN
      TABLES
        RETURN                   = LT_RETURN
        QUOTATION_ITEMS_IN       = LT_ITEM
        QUOTATION_ITEMS_INX      = LT_ITEMX
        QUOTATION_PARTNERS       = LT_PARTNER
        QUOTATION_SCHEDULES_IN   = LT_SCHL
        QUOTATION_SCHEDULES_INX  = LT_SCHLX
        QUOTATION_CONDITIONS_IN  = LT_COND
        QUOTATION_CONDITIONS_INX = LT_CONDX
        QUOTATION_CFGS_REF       = LT_REF
        QUOTATION_CFGS_INST      = LT_INST
        QUOTATION_CFGS_VALUE     = LT_VAL
        EXTENSIONIN              = LT_EX_IN.

    IF LV_VBELN IS NOT INITIAL.
      READ TABLE LT_RETURN WITH KEY TYPE = 'S'
                           INTO DATA(LS_RETURN).

*-- 성공인 경우 제조지시 상태 변경 수행
      PERFORM BD_WORK_DATA_STAT     USING    LV_VBELN
                                             LS_HEAD-JOB_NO
                                    CHANGING LV_EFLG
                                             LV_MSG.

      IF LV_EFLG EQ ABAP_TRUE.
        LS_RETURN-TYPE    = 'E'.
        LS_RETURN-MESSAGE = LV_MSG.
      ENDIF.
    ELSE.
*-- 실패인 경우 Rollback Work & 오류 메세지 정보 Read
      READ TABLE LT_RETURN WITH KEY TYPE = 'E'
                           INTO LS_RETURN.
      LV_EFLG = ABAP_TRUE.
    ENDIF.

*-----------------------------------------------------------------------
*-- 4. 처리 결과 기준 DB Update 수행
*-----------------------------------------------------------------------
    TRY.
        UPDATE : ZGTSDT0065 SET VBELN   = LV_VBELN
                                ZSTAT   = LS_RETURN-TYPE
                                ZMSG    = LS_RETURN-MESSAGE
                                AEDAT   = SY-DATUM
                                AEZEIT  = SY-UZEIT
                                AENAM   = SY-UNAME
                                AEDATLO = SY-DATLO
                                AETIMLO = SY-TIMLO
                            WHERE ZSYSTEM_ID EQ GV_SYSID
                              AND ZPJNO      EQ LS_HEAD-ZPJNO
                              AND JOB_NO     EQ LS_HEAD-JOB_NO.
      CATCH CX_SY_OPEN_SQL_DB INTO DATA(LO_SQL_DB).
        LS_RETURN-MESSAGE  = LO_SQL_DB->GET_TEXT( ).
        LS_RETURN-TYPE     = 'E'.
        LV_EFLG            = ABAP_TRUE.
    ENDTRY.

    IF LV_EFLG NE ABAP_TRUE.
*-- 성공인 경우 추가 DB Update
      TRY.
          UPDATE : ZGTSDT0066 SET VBELN   = LV_VBELN
                                  AEDAT   = SY-DATUM
                                  AEZEIT  = SY-UZEIT
                                  AENAM   = SY-UNAME
                                  AEDATLO = SY-DATLO
                                  AETIMLO = SY-TIMLO
                            WHERE ZSYSTEM_ID EQ GV_SYSID
                              AND JOB_NO     EQ LS_HEAD-JOB_NO,

          ZGTSDT0067 SET VBELN   = LV_VBELN
                         AEDAT   = SY-DATUM
                         AEZEIT  = SY-UZEIT
                         AENAM   = SY-UNAME
                         AEDATLO = SY-DATLO
                         AETIMLO = SY-TIMLO
                     WHERE ZSYSTEM_ID EQ GV_SYSID
                       AND JOB_NO     EQ LS_HEAD-JOB_NO.
        CATCH CX_SY_OPEN_SQL_DB INTO LO_SQL_DB.
          LS_RETURN-MESSAGE  = LO_SQL_DB->GET_TEXT( ).
          LS_RETURN-TYPE     = 'E'.
          LV_EFLG            = ABAP_TRUE.
      ENDTRY.
    ENDIF.

*-- 처리 결과에 따른 Commit Work / Rollback 수행
    IF LV_EFLG EQ ABAP_TRUE.
      CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.

    ELSE.
      CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
        EXPORTING
          WAIT = ABAP_TRUE.

    ENDIF.

*-- 처리 결과 화면 갱신
    READ TABLE PT_HEAD WITH KEY ZPJNO  = LS_HEAD-ZPJNO
                                JOB_NO = LS_HEAD-JOB_NO
                       ASSIGNING FIELD-SYMBOL(<LS_HEAD>).
    IF SY-SUBRC EQ 0.
      <LS_HEAD>-ZSTAT   = LS_RETURN-TYPE.
      <LS_HEAD>-ZREMARK = LS_RETURN-MESSAGE.
      <LS_HEAD>-VBELN   = LV_VBELN.
      <LS_HEAD>-STAT    = COND #( WHEN LS_RETURN-TYPE EQ 'S' THEN ICON_LED_GREEN
                                  ELSE ICON_LED_RED ).
    ENDIF.

  ENDLOOP.

*-- 처리 결과 메세지 구성
  DESCRIBE TABLE PT_HEAD LINES LS_CNT-TOTAL.

  SELECT SINGLE COUNT( * ) AS S_CNT
    FROM @PT_HEAD AS A
   WHERE A~ZSTAT EQ 'S'

    INTO @LS_CNT-S_CNT.

  SELECT SINGLE COUNT( * ) AS F_CNT
   FROM @PT_HEAD AS A
  WHERE A~ZSTAT EQ 'E'

   INTO @LS_CNT-F_CNT.

  DATA : LV_TOTAL TYPE CHAR10,
         LV_SCNT  TYPE CHAR10,
         LV_FCNT  TYPE CHAR10.

  WRITE : LS_CNT-TOTAL TO LV_TOTAL,
          LS_CNT-S_CNT TO LV_SCNT,
          LS_CNT-F_CNT TO LV_FCNT.

  CONDENSE : LV_TOTAL, LV_SCNT, LV_FCNT.

  MESSAGE S051 WITH LV_TOTAL LV_SCNT LV_FCNT.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form int_header_info
*&---------------------------------------------------------------------*
*& BAPI : BAPI_QUOTATION_CREATEFROMDATA2 Header 정보 구성
*&---------------------------------------------------------------------*
*&      --> PS_HEAD    : 해당 시작업생산요청 정보
*&      <-- PS_HEADER  : Header 구정 정보 리턴
*&      <-- PS_HEADERX : Header 입력 필드 정보 리턴
*&---------------------------------------------------------------------*
FORM INT_HEADER_INFO  USING    PS_HEAD    TYPE GTY_HEAD
                      CHANGING PS_HEADER  TYPE BAPISDHD1
                               PS_HEADERX TYPE BAPISDHD1X.

  PS_HEADER = VALUE #(
                      DOC_TYPE   = GC_AUART-ZIRP                    " 오더 유형
                      SALES_ORG  = PS_HEAD-VKORG                    " 영업조직
                      DISTR_CHAN = GC_VTWEG-10                      " 유통경로
                      DIVISION   = GC_SPART-60                      " 제품군
                      SALES_GRP  = GC_VKGRP-172                     " 영업 구륩
                      SALES_OFF  = GC_VKBUR-1710                    " 영업팀
                      PURCH_NO_C = PS_HEAD-JOB_NO                   " 제조지시번호
                      CSTCNDGRP4 = GC_KDKG4-4D                      " 고객조건그룹 4
                     ).

  PS_HEADERX = VALUE #(
                       UPDATEFLAG  = 'I'                            " 갱신지시자
                       DOC_TYPE    = COND #( WHEN PS_HEADER-DOC_TYPE    IS NOT INITIAL THEN ABAP_TRUE
                                             ELSE ABAP_FALSE )      " 오더 유형
                       SALES_ORG   = COND #( WHEN PS_HEADER-SALES_ORG   IS NOT INITIAL THEN ABAP_TRUE
                                             ELSE ABAP_FALSE )      " 영업조직
                       DISTR_CHAN  = COND #( WHEN PS_HEADER-DISTR_CHAN  IS NOT INITIAL THEN ABAP_TRUE
                                             ELSE ABAP_FALSE )      " 유통 경로
                       DIVISION    = COND #( WHEN PS_HEADER-DIVISION    IS NOT INITIAL THEN ABAP_TRUE
                                             ELSE ABAP_FALSE )      " 제품군
                       SALES_GRP   = COND #( WHEN PS_HEADER-SALES_GRP   IS NOT INITIAL THEN ABAP_TRUE
                                             ELSE ABAP_FALSE )      " 영업 그룹
                       SALES_OFF   = COND #( WHEN PS_HEADER-SALES_OFF   IS NOT INITIAL THEN ABAP_TRUE
                                             ELSE ABAP_FALSE )      " 영업팀
                       PURCH_NO_C  = COND #( WHEN PS_HEADER-PURCH_NO_C  IS NOT INITIAL THEN ABAP_TRUE
                                             ELSE ABAP_FALSE )      " 제조지시번호
                       CSTCNDGRP4  = ABAP_TRUE                      " 고객조건그룹 4
                      ).
ENDFORM.
*&---------------------------------------------------------------------*
*& Form init_partner_info
*&---------------------------------------------------------------------*
*&  BAPI : BAPI_QUOTATION_CREATEFROMDATA2 Partner 정보 구성
*&---------------------------------------------------------------------*
*&      <-- PT_PARTNER  : Partner 정보 리턴
*&---------------------------------------------------------------------*
FORM INIT_PARTNER_INFO  CHANGING PT_PARTNER TYPE CMP_T_PARNR.

  PT_PARTNER[] = VALUE #(
*-- 판매처 정보 구성
                         (
                           PARTN_ROLE  = GC_PARVW-AG
                           PARTN_NUMB  = GC_KUNNR-106022
                           TITLE       = |COMPANY|
                           NAME        = |엘에스전선(주)구미공장|
                           CITY        = |구미|
                           COUNTRY     = |KR|
                         )
*-- 납품처 정보 구성
                         (
                           PARTN_ROLE  = GC_PARVW-WE
                           PARTN_NUMB  = GC_KUNNR-106022
                           TITLE       = |COMPANY|
                           NAME        = |엘에스전선(주)구미공장|
                           CITY        = |구미|
                           COUNTRY     = |KR|
                          )
*-- 지급처 정보 구성
                          (
                            PARTN_ROLE  = GC_PARVW-RG
                            PARTN_NUMB  = GC_KUNNR-106022
                            TITLE       = |COMPANY|
                            NAME        = |엘에스전선(주)구미공장|
                            CITY        = |구미|
                            COUNTRY     = |KR|
                          )
                        ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form init_extension_head
*&---------------------------------------------------------------------*
*&  BAPI : BAPI_QUOTATION_CREATEFROMDATA2 Header 확장필드 정보 구성
*&---------------------------------------------------------------------*
*&      --> PS_HEAD    : Header 정보
*&      <-- PT_EX_IN   : 확장필드 정보 리턴
*&---------------------------------------------------------------------*
FORM INIT_EXTENSION_HEAD  USING    PS_HEAD   TYPE GTY_HEAD
                          CHANGING PT_EX_IN  TYPE BAPIPAREX_T.

  DATA : LS_BAPE_VBAK  TYPE BAPE_VBAK,
         LS_BAPE_VBAKX TYPE BAPE_VBAKX,

         LS_EX_IN      TYPE BAPIPAREX.

  CLEAR : LS_BAPE_VBAK, LS_BAPE_VBAKX.
*-----------------------------------------------------------------------
*-- 입력 필드 정보 값 대입
*-----------------------------------------------------------------------
*-- 프로젝트 번호 정보 구성
  LS_BAPE_VBAK-ZPJNO  = PS_HEAD-ZPJNO.
  LS_BAPE_VBAKX-ZPJNO = ABAP_TRUE.

*-----------------------------------------------------------------------
*-- 추가 필드 입력 전체 정보 구성
*-----------------------------------------------------------------------
*-- 생성 정보 구성
  CLEAR LS_EX_IN.
  LS_EX_IN-STRUCTURE = |BAPE_VBAK|.
  LS_EX_IN+30        = LS_BAPE_VBAK.

  APPEND LS_EX_IN TO PT_EX_IN.

*-- 생성 필드 정보 구성
  CLEAR LS_EX_IN.
  LS_EX_IN-STRUCTURE = |BAPE_VBAKX|.
  LS_EX_IN+30        = LS_BAPE_VBAKX.

  APPEND LS_EX_IN TO PT_EX_IN.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form bd_work_data_stat
*&---------------------------------------------------------------------*
*& 제조지시상태 변경 수행
*&---------------------------------------------------------------------*
*&      --> PV_VBELN   : 해당 판매오더 정보
*&      --> PV_JOB_NO  : 제조지시번호 정보
*&      <-- PV_EFLG    : 오류 발생시 'X' 리턴
*&      <-- PV_MSG     : 메세지 정보 리턴
*&---------------------------------------------------------------------*
FORM BD_WORK_DATA_STAT  USING    PV_VBELN    TYPE VBELN_VA
                                 PV_JOB_NO   TYPE ZGTE_BD_JOBNO
                        CHANGING PV_EFLG     TYPE CHAR01
                                 PV_MSG      TYPE ZO_MESSAGE.

  DATA : LV_ZJOB_NO      TYPE CHAR30,
         LV_RESULT       TYPE ZO_RESULT,
         LV_ZERP_STAT    TYPE ZGTESTAT_P,
         LV_ZERP_MESSAGE TYPE ZGTEMSG_P.

  CONSTANTS : LC_ZPGM    TYPE TEXT20 VALUE 'ZGTSDR0060',
              LC_ZMODULE TYPE CHAR02 VALUE 'SD',
              LC_STAT    TYPE CHAR02 VALUE 'S1',
              LC_SYSID   TYPE CHAR04 VALUE 'KBDM',
              LC_MOD     TYPE CHAR01 VALUE 'C',
              LC_WERKS   TYPE CHAR04 VALUE '1306'.


  CLEAR : LV_ZJOB_NO, LV_RESULT, PV_MSG, PV_EFLG, LV_ZERP_STAT, LV_ZERP_MESSAGE.

  LV_ZJOB_NO = PV_JOB_NO.
  TRY.
      CALL FUNCTION 'ZGTED_BD_WORK_DATA_STATUS'
        EXPORTING
          I_ZMODULE             = LC_ZMODULE
          I_ZPROGRAM            = LC_ZPGM
          I_ZWERKS              = LC_WERKS
          I_ZJOB_NO             = LV_ZJOB_NO
          I_ZSTATUS             = LC_STAT
          I_VBELN               = PV_VBELN
        IMPORTING
          ZO_RESULT             = LV_RESULT
          ZO_MESSAGE            = PV_MSG
        EXCEPTIONS
          SYSTEM_FAILURE        = 1
          COMMUNICATION_FAILURE = 2
          ILLEGALNAME           = 3
          OTHERS                = 4.
    CATCH CX_ROOT INTO DATA(LO_ERR).
      DATA(LV_MSG) = LO_ERR->GET_TEXT( ).
      LV_ZERP_STAT = ZGTSD_E.
      LV_ZERP_MESSAGE = 'ED 상태변경 Function DUMP 발생'.

      PERFORM BD_LOG_UPDATE USING  LC_SYSID
                                   LV_RESULT
                                   LV_MSG
                                   LV_ZERP_STAT
                                   LV_ZERP_MESSAGE
                                   LC_ZMODULE
                                   LC_ZPGM
                                   LC_WERKS
                                   LV_ZJOB_NO
                                   PV_VBELN
                                   ' '
                                   LC_STAT
                                   LC_MOD.
  ENDTRY.

  IF LV_RESULT NE |00|.
*-- 오류 발생시 'X' 리턴
    PV_EFLG = ABAP_TRUE.
    LV_ZERP_STAT = ZGTSD_E.
    LV_ZERP_MESSAGE = '시작업생산요청 생성결과 MES 전송 실패'.
  ELSE.
    LV_ZERP_STAT = ZGTSD_S.
    LV_ZERP_MESSAGE = '시작업생산요청 생성결과 MES 전송 성공'.
  ENDIF.

  PERFORM BD_LOG_UPDATE USING  LC_SYSID
                               LV_RESULT
                               PV_MSG
                               LV_ZERP_STAT
                               LV_ZERP_MESSAGE
                               LC_ZMODULE
                               LC_ZPGM
                               LC_WERKS
                               LV_ZJOB_NO
                               PV_VBELN
                               ' '
                               LC_STAT
                               LC_MOD.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form run_batch_job
*&---------------------------------------------------------------------*
*& 조회조건 기준 Batch Job 수행
*&---------------------------------------------------------------------*
FORM RUN_BATCH_JOB .

  DATA : LS_HEAD TYPE GTY_HEAD.
*-- 조회조건 기준 시작업생산요청 대상 정보 구성
  LS_HEAD-CHECK = ABAP_TRUE.

  MODIFY GT_HEAD FROM LS_HEAD
                 TRANSPORTING CHECK
                 WHERE STAT EQ ICON_LED_YELLOW.

*-- 시작업생산요청 수행
  PERFORM CRTE_CUST_QUOT_FOR_WORK   USING    GT_ITEM_ALL
                                    CHANGING GT_HEAD.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form bd_log_update
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LV_SYSID
*&      --> LV_RESULT
*&      --> LV_MSG
*&      --> LV_JOB_NO
*&      --> PV_VBELN
*&---------------------------------------------------------------------*
FORM BD_LOG_UPDATE  USING    PV_SYSID
                             PV_RESULT
                             PV_MSG
                             PV_ERP_RSLT
                             PV_ERP_MSG
                             PV_ZMODULE
                             PV_ZPGM
                             PV_WERKS
                             PV_JOBNO
                             PV_VBELN
                             PV_ABSTK
                             PV_JOB_STAT
                             PV_TRTYP.

  DATA : LS_9000 TYPE ZGTSDT9000.

  GET TIME STAMP FIELD LS_9000-ZIFKEY.
  LS_9000-ZIFRFC       = 'ZGTED_BD_WORK_DATA_STATUS'.
  LS_9000-ZSYSTEM_ID   = PV_SYSID.
  LS_9000-ZVALUE01     = PV_ZMODULE.
  LS_9000-ZVALUE02     = PV_ZPGM.
  LS_9000-ZVALUE03     = PV_WERKS.
  LS_9000-ZVALUE04     = PV_JOBNO.
  LS_9000-ZVALUE05     = PV_VBELN.
  LS_9000-ZVALUE06     = PV_ABSTK.
  LS_9000-ZVALUE07     = PV_JOB_STAT.
  LS_9000-ZVALUE08     = PV_TRTYP.
  LS_9000-ZSTAT        = PV_RESULT.
  LS_9000-ZMESSAGE     = PV_MSG.
  LS_9000-ZERP_STAT    = PV_ERP_RSLT.
  LS_9000-ZERP_MESSAGE = PV_ERP_MSG.
  LS_9000-IFDAT        = SY-DATUM.
  LS_9000-IFTIM        = SY-TIMLO.
  LS_9000-IFNAM        = SY-UNAME.
  LS_9000-ERNAM        = SY-UNAME.
  LS_9000-ERDAT        = SY-DATUM.
  LS_9000-ERZEIT       = SY-UZEIT.
  LS_9000-ERDATLO      = SY-DATLO.
  LS_9000-ERTIMLO      = SY-TIMLO.
  LS_9000-ERTCODE      = SY-TCODE.

  MODIFY ZGTSDT9000 FROM LS_9000.

ENDFORM.
