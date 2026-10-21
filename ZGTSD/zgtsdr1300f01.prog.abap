*&---------------------------------------------------------------------*
*& Include          ZGTSDR1300F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form INITIALIZATION
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM INITIALIZATION .
  G_REPID = SY-REPID.
  G_SAVE = 'A'.   "The user may save all types of a layout

*-납품요청일
  PERFORM SET_DEFAULT_DATE.
*-유통경로/제품군
  PERFORM SET_DEFAULT_ORG.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SELECTION_SCREEN_OUTPUT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SELECTION_SCREEN_OUTPUT .
** Layout관련
  IF  DEFAULT  =  ' '.

    CLEAR DEF_LAYOUT.
    MOVE  G_REPID   TO  DEF_LAYOUT-REPORT.

    CALL FUNCTION 'LVC_VARIANT_DEFAULT_GET'
      EXPORTING
        I_SAVE     = G_SAVE
      CHANGING
        CS_VARIANT = DEF_LAYOUT
      EXCEPTIONS
        NOT_FOUND  = 2.

    IF  SY-SUBRC  =  2.
      IF  NOT P_VARI IS INITIAL.
        MESSAGE S001 WITH '레이아웃 기본세팅이 없습니다.'.
      ENDIF.
    ELSE.
      P_VARI  =  DEF_LAYOUT-VARIANT.
      DEFAULT  =  'X'.
    ENDIF.

  ENDIF.

  LOOP AT SCREEN.
    IF SCREEN-GROUP1 EQ 'ZM1'.
      SCREEN-ACTIVE = 0.
    ENDIF.
    MODIFY SCREEN.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SELECTION_SCREEN
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SELECTION_SCREEN .

  PERFORM  AUTHORITY_CHECK.

** Layout 입력안했을때 Default(기본) Layout Display.
  CLEAR SPEC_LAYOUT.

  IF  P_VARI IS INITIAL.
    MOVE  DEF_LAYOUT-VARIANT  TO  SPEC_LAYOUT-VARIANT.
  ELSE.
    MOVE  P_VARI  TO  SPEC_LAYOUT-VARIANT.
  ENDIF.

** 기본세팅이 없는 리스트도 있기때문에...
  CHECK SPEC_LAYOUT-VARIANT NE SPACE.

  MOVE  G_REPID  TO  SPEC_LAYOUT-REPORT.

  CALL FUNCTION 'LVC_VARIANT_EXISTENCE_CHECK'
    EXPORTING
      I_SAVE        = G_SAVE
    CHANGING
      CS_VARIANT    = SPEC_LAYOUT
    EXCEPTIONS
      WRONG_INPUT   = 1
      NOT_FOUND     = 2
      PROGRAM_ERROR = 3
      OTHERS        = 4.

  IF  SY-SUBRC <> 0.
    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
          WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  FILL_ITAB_OLD
*&---------------------------------------------------------------------*
*       DATA SELECT
*----------------------------------------------------------------------*
FORM FILL_ITAB_OLD.

  DATA : L_NAME LIKE  THEAD-TDNAME.

  DATA : BEGIN OF TTLINE OCCURS 50.
           INCLUDE STRUCTURE TLINE.
  DATA : END   OF TTLINE.
  RANGES LT_AUART FOR VBAK-AUART.

  PERFORM GET_ORDER_TYPE_RANGES TABLES LT_AUART.
  IF LT_AUART[] IS INITIAL.
    MESSAGE E004(ZLE1) WITH '정의된 오더유형이 없습니다'.
*    LEAVE TO transaction sy-tcode.
  ENDIF.

  SELECT  A~VBELN                           "영업문서
          B~POSNR                           "품목번호
          A~AUART                           "주문유형
          A~KUNNR                           "고객
          B~MATNR                           "자재
          B~PRODH                           "제품계층구조
          B~WERKS                           "플랜트
          A~VKORG                           "영업조직
          A~VTWEG                           "유통경로
*         a~vdatu                           "납품요청일
          D~EDATU AS VDATU                  "주문도착일(시스템납품일)
          B~KWMENG                          "오더수량
          B~KBMENG                          "확정수량
          B~ABGRU                           "거절사유
          A~SPART                           "제품군
          A~VKBUR                           "사업장
          A~VKGRP                           "영업그룹
          A~ERNAM                           "사용자ID
          A~KNUMV                           "문서조건번호
          A~ERDAT                           "오더생성일
          A~ERZET                           "입력시간
          B~VRKME                           "판매단위
          D~ETENR                           "일정라인
          D~EZEIT                           "주문도착시간
          D~MBDAT                           "자재가용일
          B~PSTYV                           "Item Category
          B~VSTEL                           "출하지점
          B~BRGEW                           "중량
          B~MATKL                           "자재그룹
          B~NETWR                           "오더금액
          A~AUGRU                           "오더사유
          B~NETPR                           "단가
          B~WAERK                           "통화
*-> S4HANA PJT : 14.06.2023 11:19:58 / ZLSGSD2

*          C~PERNR                           "영업사원
          C~LIFNR AS LIFNR
*<-
          A~ZPJNO                           "프로젝트No
          B~SPART AS SPART2                 "품목별제품군
          B~CUOBJ                           "조장수특성값
          B~SOBKZ
          B~XCHPF
          A~ZPROJECT                        "JS전선 호선...
          B~CHARG AS CHARG_V
   INTO CORRESPONDING FIELDS OF TABLE G_ITSO_T
   FROM VBAP AS B INNER JOIN VBAK AS A ON B~VBELN = A~VBELN
                  INNER JOIN VBEP AS D ON D~VBELN = B~VBELN
                                      AND D~POSNR = B~POSNR
                  INNER JOIN VBPA AS C ON C~VBELN = B~VBELN
                                      AND C~POSNR = '0'
                                      AND C~PARVW = 'VE'
  WHERE  A~ERDAT  IN  SO_ERDAT
    AND  A~AUART  IN  LT_AUART  "('TA','ZEXE','ZFS','ZPO','Z3RD',  "
                                " 'RE', 'ZREQ','ZORQ','ZFQ', 'ZKB' )
    AND  A~VBELN  IN  SO_VBELN
    AND  A~ZPJNO  IN  SO_ZPJNO
    AND  A~KUNNR  IN  SO_KUNNR
    AND  A~VKORG  =   PA_VKORG
    AND  A~VTWEG  IN  SO_VTWEG
    AND  A~SPART  IN  SO_SPART
    AND  A~VKBUR  IN  SO_VKBUR
    AND  A~VKGRP  IN  SO_VKGRP
    AND  B~WERKS  IN  SO_WERKS
    AND  B~MATNR  IN  SO_MATNR
    AND  A~ERNAM  IN  SO_ERNAM
*   and  a~vdatu  in  so_vdatu
    AND  D~EDATU  IN  SO_EDATU
    AND  B~VSTEL  IN  SO_VSTEL
    AND  B~MATKL  IN  SO_MATKL
    AND  B~SOBKZ  IN  R_SOBKZ           "mto,mts.
*-> S4HANA PJT : 14.06.2023 11:20:45 / ZLSGSD2
*    AND  C~PERNR  IN  SO_PERNR.         "영업사원
    AND  C~LIFNR  IN  SO_LIFNR.         "영업사원

*<-


  DESCRIBE TABLE G_ITSO_T LINES G_TOTCNT.

* 차후 영업/유통문서, NAME 등
  PERFORM GET_VBELN_OLD.

  IF PA_SPMON <> SPACE.
    PERFORM DELETE_ITAB.
  ENDIF.

  SORT G_ITAB_T BY VBELN POSNR VBELN_VL POSNR_VL.

  IF  NOT SO_KODAT-LOW IS INITIAL.
    PERFORM  CONDITION_QUERY1.
  ENDIF.

  IF  NOT SO_LDDAT-LOW IS INITIAL.
    PERFORM  CONDITION_QUERY2.
  ENDIF.

*> PROGRESS Display.
  G_LINEN    = 10.
  G_OUT_TEXT = '데이타를 검색 중입니다 %99999%%'.
  REPLACE '%99999%' WITH G_LINEN INTO G_OUT_TEXT.
  PERFORM SHOW_PROGRESS_BAR(ZSDR0230) USING G_OUT_TEXT G_LINEN.

* 선적생성일 가져오기
  PERFORM GET_ERDAT.

* 오더확정차이일 가져오기
  PERFORM GET_DIFF_DATE.

* 오더사유TEXT 가져오기
  PERFORM GET_BEZEI2.

* 특별재고파트너 가져오기
  PERFORM GET_KUNNR_SB.

* 생산계획일, 입고일 가져오기
  PERFORM GET_TABLE_AFPO.

*> PROGRESS Display.
  G_LINEN    = 30.
  G_OUT_TEXT = '데이타를 검색 중입니다 %99999%%'.
  REPLACE '%99999%' WITH G_LINEN INTO G_OUT_TEXT.
  PERFORM SHOW_PROGRESS_BAR(ZSDR0230) USING G_OUT_TEXT G_LINEN.



*--[START] C20130225_79371 order tracking 내에 포장재 번호 추가 요청_hoi
*TABLES :  ZEDS095.
  LOOP AT G_ITAB_T.

    SELECT SINGLE PACKING_DM
      INTO (G_ITAB_T-PACKING_DM)
      FROM ZEDT0230
     WHERE VBELN = G_ITAB_T-VBELN
       AND POSNR = G_ITAB_T-POSNR.

    SELECT SINGLE MAKTX
      INTO (G_ITAB_T-PACKING_DM_NM)
      FROM MAKT
     WHERE MATNR = G_ITAB_T-PACKING_DM.

*-{기능개선175813 - 추가
*__고객자재 정보 추가
    SELECT SINGLE KDMAT
      INTO G_ITAB_T-KDMAT
      FROM VBAP
     WHERE VBELN = G_ITAB_T-VBELN
       AND POSNR = G_ITAB_T-POSNR.
*-}기능개선175813_2016.12.29

*-{기능개선178174 -추가
    PERFORM GET_SOTEXT.         "판매오더 품목 테스트 가져오기
*-}기능개선178174_2017.01.12

*{ 기능개선 323173 - 추가_S
    PERFORM GET_LIFNR_NAME USING G_ITAB_T-LIFNR
                                 G_ITAB_T-ENAME.
*} 기능개선 323173 - 추가_E

    MODIFY G_ITAB_T.
  ENDLOOP.

*--[END] C20130225_79371 order tracking 내에 포장재 번호 추가 요청_hoi

  PERFORM GET_BSTKD.          "FILE번호 가져오기
  PERFORM GET_KOSTK.          "피킹관련성, 피킹설명 가져오기
  PERFORM GET_TKNUM2.         "준비구간선적번호 가져오기
  PERFORM GET_FKNUM.          "선적비용번호 가져오기
  PERFORM GET_CPUTM.          "G/I시간 가져오기
  PERFORM GET_VKBUR_TEXT.     "사업장명 가져오기
  PERFORM GET_VKGRP_TEXT.     "영업그룹명 가져오기
  PERFORM GET_WERKS_TEXT.     "플랜트명 가져오기
  PERFORM GET_VSTEL_TEXT.     "출하지점명 가져오기
  PERFORM GET_ROUTE_TEXT.     "운송경로명 가져오기
  PERFORM GET_KUNNR_SB_TEXT.  "특별재고파트너명 가져오기
  PERFORM GET_MATNR_ZZMAKT80. "상세 품명
  PERFORM GET_GRADE_DATA.     "등급

*[Start CSR: C20100928_44362]PJT&APPL명추가.
  PERFORM GET_PJTAPPL_TEXT.   " PJT&APPL명 가져오기
*[End CSR: C20100928_44362]

*> PROGRESS Display.
  G_LINEN    = 60.
  G_OUT_TEXT = '데이타를 검색 중입니다 %99999%%'.
  REPLACE '%99999%' WITH G_LINEN INTO G_OUT_TEXT.
  PERFORM SHOW_PROGRESS_BAR(ZSDR0230) USING G_OUT_TEXT G_LINEN.

* 조회조건(SELECT-OPTIONS)의 선적생성일이 아니면 DELETE
  IF NOT SO_ERDA2[] IS INITIAL.
    PERFORM DELETE_ERDAT.
  ENDIF.

* 조회조건(SELECT-OPTIONS)의 실제자재이동일(출고전기일)이 아니면 DELETE
  IF NOT SO_W_IST[] IS INITIAL.
    PERFORM DELETE_WADAT_IST.
  ENDIF.

* 조회조건(SELECT-OPTIONS)의 계획자재이동일(계획G.I)이 아니면 DELETE
  IF NOT SO_WADAT[] IS INITIAL.
    PERFORM DELETE_WADAT.
  ENDIF.

* 조회조건(SELECT-OPTIONS)의 선적번호가 아니면 DELETE
  IF NOT SO_TKNUM[] IS INITIAL.
    PERFORM DELETE_TKNUM.
  ENDIF.

* 조회조건(SELECT-OPTIONS)의 납품번호가 아니면 DELETE
  IF NOT SO_VBEL2[] IS INITIAL.
    PERFORM DELETE_VBELN_VL.
  ENDIF.

* 조회조건(SELECT-OPTIONS)의 차량번호가 아니면 DELETE
  IF NOT SO_SIGNI[] IS INITIAL.
    PERFORM DELETE_SIGNI.
  ENDIF.

* 조회조건(SELECT-OPTIONS)의 특별재고파트너가 아니면 DELETE
  IF NOT SO_KUNN2[] IS INITIAL.
    PERFORM DELETE_KUNNR_SB.
  ENDIF.

* 조회조건(SELECT-OPTIONS)의 전체상품이동상태가 아니면 DELETE
  IF NOT SO_WBSTK[] IS INITIAL.
    PERFORM DELETE_WBSTK.
  ENDIF.

* 조회조건(SELECT-OPTIONS)의 운송경로가 아니면 DELETE
  IF NOT SO_ROUTE[] IS INITIAL.
    PERFORM DELETE_ROUTE.
  ENDIF.

* 조회조건(SELECT-OPTIONS)의 운송계획지점이 아니면 DELETE
  IF NOT SO_TPLST[] IS INITIAL.
    PERFORM DELETE_TPLST.
  ENDIF.

* 조회조건(SELECT-OPTIONS)의 납품유형이 아니면 DELETE
  IF NOT SO_LFART[] IS INITIAL.
    PERFORM DELETE_LFART.
  ENDIF.

* 조회조건(SELECT-OPTIONS)의 저장위치이 아니면 DELETE
  IF NOT SO_LGORT[] IS INITIAL.
    PERFORM DELETE_LGORT.
  ENDIF.

*> PROGRESS Display.
  G_LINEN    = 90.
  G_OUT_TEXT = '데이타를 검색 중입니다 %99999%%'.
  REPLACE '%99999%' WITH G_LINEN INTO G_OUT_TEXT.
  PERFORM SHOW_PROGRESS_BAR(ZSDR0230) USING G_OUT_TEXT G_LINEN.

* 동량 계산
  PERFORM  CALC_NFM_QTY.

* 공정관련 Data Query(APO에서 가져온 Data임)
  PERFORM  APO_DATA_QUERY.

* 절단관련 Data Query(LE) : 2005-09-13
  PERFORM  LE_DATA_QUERY.

* 권선 사업부 요청으로 인한 현재고 수량 표시
  PERFORM  GET_STOCK.


  IF P_SUB IS NOT INITIAL.
    PERFORM SEND_RFC_DATA_TO_MES.
    EXIT.
  ENDIF.


*  READ TABLE G_ITAB_T INDEX 1.
*
*  IF  SY-SUBRC <> 0.
*    MESSAGE S000(ZSDM) WITH '조건에 해당하는 데이타가 없습니다.'.
*  ELSE.
*    PERFORM WRITE_ITAB.
*  ENDIF.

ENDFORM.                    " FILL_ITAB_OLD
*---------------------------------------------------------------------*
*      Form  USER COMMAND
*---------------------------------------------------------------------*
*      USER COMMAND 정의.
*---------------------------------------------------------------------*
FORM  USER_COMMAND USING P_UCOMM    LIKE SY-UCOMM
                         P_SELFIELD TYPE SLIS_SELFIELD.

  CASE P_UCOMM.

    WHEN '&IC1'.

      CASE P_SELFIELD-SEL_TAB_FIELD.

        WHEN 'G_ITAB_T-VBELN'.
          PERFORM CALL_VA03 USING  P_SELFIELD-VALUE.

        WHEN 'G_ITAB_T-VBELN_VL'.
          PERFORM CALL_VL03N USING  P_SELFIELD-VALUE.

        WHEN 'G_ITAB_T-TKNUM'.
          PERFORM CALL_VT03N USING  P_SELFIELD-VALUE.

        WHEN 'G_ITAB_T-TKNUM_SEA'.
          PERFORM CALL_VT03N USING  P_SELFIELD-VALUE.

        WHEN 'G_ITAB_T-VBELN_GI'.
          PERFORM CALL_MB03 USING  P_SELFIELD-VALUE.

        WHEN 'G_ITAB_T-VBELN_VF'.
          PERFORM CALL_VF03 USING  P_SELFIELD-VALUE.

        WHEN 'G_ITAB_T-FKNUM'.
          PERFORM CALL_VI03 USING  P_SELFIELD-VALUE.

      ENDCASE.

    WHEN 'VA02'.
      PERFORM  CALL_VA02.

    WHEN 'DETL'.        "실시간 진행 현황 조회
      PERFORM CALL_REAL_TIME_ORDER_TRACKING.

    WHEN 'EXI' OR 'CAC' OR 'BAC'.
      SET SCREEN 0. LEAVE SCREEN.

  ENDCASE.

ENDFORM.                    "user_command

*&---------------------------------------------------------------------*
*&      Form  AUTHORITY_CHECK
*&---------------------------------------------------------------------*
*       권한(ROLL) CHECK
*----------------------------------------------------------------------*
FORM AUTHORITY_CHECK.

  DATA: GT_TVTW  LIKE TVTW OCCURS 0 WITH HEADER LINE,
        GT_TSPA  LIKE TSPA OCCURS 0 WITH HEADER LINE,
        LV_SUBRC LIKE SY-SUBRC.

  CLEAR : LV_SUBRC.

  CALL FUNCTION 'ZGTSD_AUTHORIZATION_CHECK'
    EXPORTING
      I_VKORG = PA_VKORG
      I_TYPE  = '1'
    IMPORTING
      E_SUBRC = LV_SUBRC.

  IF LV_SUBRC <> 0.
    MESSAGE E002 WITH '영업조직에 대한 권한이 없읍니다'
                      PA_VKORG.
  ENDIF.

  SELECT *
    INTO TABLE GT_TVTW
    FROM TVTW
   WHERE VTWEG IN SO_VTWEG.

  LOOP  AT  GT_TVTW.
    CALL FUNCTION 'ZGTSD_AUTHORIZATION_CHECK'
      EXPORTING
        I_VTWEG = GT_TVTW-VTWEG
        I_TYPE  = '2'
      IMPORTING
        E_SUBRC = LV_SUBRC.

    IF LV_SUBRC <> 0.
      MESSAGE E002 WITH '유통채널에 대한 권한이 없읍니다'
                        GT_TVTW-VTWEG.
    ENDIF.
  ENDLOOP.

  SELECT *
    INTO TABLE GT_TSPA
    FROM TSPA
   WHERE SPART IN SO_SPART.

  LOOP  AT  GT_TSPA.
    CLEAR : LV_SUBRC.
    CALL FUNCTION 'ZGTSD_AUTHORIZATION_CHECK'
      EXPORTING
        I_SPART = GT_TSPA-SPART
        I_TYPE  = '3'
      IMPORTING
        E_SUBRC = LV_SUBRC.

    IF LV_SUBRC <> 0.
      MESSAGE E002 WITH '제품군에 대한 권한이 없읍니다'
                        GT_TSPA-SPART.
    ENDIF.
  ENDLOOP.

*-영업그룹
  SELECT VKGRP
    FROM TVKGR
   WHERE VKGRP IN @SO_VKGRP
    INTO TABLE @DATA(LT_VKGRP).
  IF SY-SUBRC NE 0.
    MESSAGE S001 WITH TEXT-M01 DISPLAY LIKE GC_E.
    LEAVE LIST-PROCESSING.
  ENDIF.

  LOOP AT LT_VKGRP INTO DATA(LS_VKGRP).
    CLEAR LV_SUBRC.
    CALL FUNCTION 'ZGTSD_AUTHORIZATION_CHECK'
        EXPORTING
          I_VKGRP = LS_VKGRP-VKGRP
          I_TYPE  = '7'
        IMPORTING
          E_SUBRC = LV_SUBRC.
    IF LV_SUBRC NE 0.
      MESSAGE S023(ZGTSD01) WITH LS_VKGRP-VKGRP DISPLAY LIKE GC_E.
      LEAVE LIST-PROCESSING.
    ENDIF.
  ENDLOOP.
ENDFORM.                    " AUTHORITY_CHECK

*&---------------------------------------------------------------------*
*&      Form  WRITE_ITAB
*&---------------------------------------------------------------------*
*       WRITE DATA
*----------------------------------------------------------------------*
FORM WRITE_ITAB.

* ALV 출력을 위한 HEADER및 FIELD SETTING
  PERFORM ALVPRN_BASIC.
  PERFORM ALVPRN_HEADER.
  PERFORM ALVPRN_FIELD.

* ALV DISPLAY
  PERFORM ALV_DISPLAY.

ENDFORM.                    " WRITE_ITAB

*&---------------------------------------------------------------------*
*&      Form  ALVPRN_BASIC
*&---------------------------------------------------------------------*
*       ALV를 실행하기위한 기본 정보 SETTING
*----------------------------------------------------------------------*
FORM ALVPRN_BASIC.

  CLEAR:   G_EVENTS_T, G_LAYOUT_S.
  REFRESH: G_EVENTS_T.

** 기본값 SETTING
  G_LAYOUT_S-DETAIL_POPUP      = 'X'.
  G_LAYOUT_S-ZEBRA             = 'X'.
  G_LAYOUT_S-BOX_FIELDNAME     = 'MARK'.
  G_LAYOUT_S-COLWIDTH_OPTIMIZE = 'X'.

* FORM문 발췌함수
  CALL FUNCTION 'REUSE_ALV_EVENTS_GET'
    EXPORTING
      I_LIST_TYPE = 0
    IMPORTING
      ET_EVENTS   = G_EVENTS_T.

* FORM문   생성
  PERFORM FORM_SETTING  TABLES G_EVENTS_T
                         USING : SLIS_EV_PF_STATUS_SET  C_STATUS_SET,
                                 SLIS_EV_USER_COMMAND   C_USER_COMMAND,
                                 SLIS_EV_TOP_OF_PAGE    C_TOP_OF_PAGE.

* PROGRAM  ID
  G_PROGRAM = SY-REPID.

ENDFORM.                    " ALVPRN_BASIC

*&---------------------------------------------------------------------*
*&      Form  ALVPRN_HEADER
*&---------------------------------------------------------------------*
*       ALV HEADER SETTING
*----------------------------------------------------------------------*
FORM ALVPRN_HEADER.

  DATA : L_DATA1(100),
         L_DATA2(100),
         L_DATA3(100),
         L_DATA4(100),
         L_DATA5(100).

  REFRESH G_LIST_TOP_OF_PAGE_T.
  PERFORM WRITE_DATA_CALC_RTN USING L_DATA1 L_DATA2 L_DATA3.
*                                    L_DATA4 L_DATA5.

  PERFORM HEADER_SETTING TABLES G_LIST_TOP_OF_PAGE_T
                          USING: 'S'  '조회기간   : ' L_DATA1,
                                 'S'  '영업조직   : ' L_DATA2,
                                 'S'  '제 품 군   : ' L_DATA3.

ENDFORM.                    " ALVPRN_HEADER

*&---------------------------------------------------------------------*
*&      Form  ALVPRN_FIELD
*&---------------------------------------------------------------------*
*       ALV HEADER SETTING
*----------------------------------------------------------------------*
FORM ALVPRN_FIELD.

  REFRESH: G_FIELD_T, G_FIELDCAT_T.

* FIELD발췌
  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
    EXPORTING
      I_PROGRAM_NAME     = G_PROGRAM
      I_INTERNAL_TABNAME = 'G_ITAB_T'
      I_INCLNAME         = G_PROGRAM
      I_BYPASSING_BUFFER = 'X'
    CHANGING
      CT_FIELDCAT        = G_FIELD_T[].

  PERFORM  FIELD_SETTING  TABLES G_FIELDCAT_T
                        USING: 'S' 'VBELN'       ' ',
                               ' ' 'SELTEXT_S'   '오더번호',
                               ' ' 'COL_POS'     '1',
                               'E' 'KEY'         'X'.
* FIELD선택
  PERFORM WRITE_FORM.

ENDFORM.                    " ALVPRN_FIELD

*&---------------------------------------------------------------------*
*&      Form  WRITE_FORM
*&---------------------------------------------------------------------*
*       초기 화면 구성
*----------------------------------------------------------------------*
FORM WRITE_FORM.

  CLEAR : G_POS.

  PERFORM  FIELD_SETTING  TABLES G_FIELDCAT_T
                           USING : 'S' 'POSNR'       '',
                                   ' ' 'SELTEXT_S'   '오더품목',
                                   'E' 'DDICTXT'     'S',

                                   'S' 'AUART'       '',
                                   ' ' 'SELTEXT_S'   '오더유형',
                                   'E' 'DDICTXT'     'S',

                                   'S' 'NAME1'       '',
                                   ' ' 'SELTEXT_S'   '거래선명',
                                   'E' 'DDICTXT'     'S',

                                   'S' 'NAME1_SH'    '',
                                   ' ' 'SELTEXT_S'   '인도처명',
                                   'E' 'DDICTXT'     'S',

                                   'S' 'MATNR'       '',
                                   ' ' 'SELTEXT_S'   '자재',
                                   'E' 'DDICTXT'     'S',

                                   'S' 'MAKTX'       '',
                                   ' ' 'SELTEXT_S'   '자재내역',
                                   'E' 'DDICTXT'     'S',

                                   'S' 'NETPR'        '',
                                   ' ' 'SELTEXT_S'   '단가',
                                   'E' 'DDICTXT'     'S',

                                   'S' 'WAERK'        '',
                                   ' ' 'SELTEXT_S'   '통화',
                                   'E' 'DDICTXT'     'S',

                                   'S' 'WERKS'       '',
                                   ' ' 'SELTEXT_S'   '플랜트',
                                   'E' 'DDICTXT'     'S',

                                   'S' 'VTWEG'       '',
                                   ' ' 'SELTEXT_S'   '유통경로',
                                   'E' 'DDICTXT'     'S',

                                   'S' 'VDATU'       '',
                                   ' ' 'SELTEXT_S'   '납품요청일',
                                   'E' 'DDICTXT'     'S',

                                   'S' 'KWMENG'       '',
                                   ' ' 'SELTEXT_S'   '오더수량',
                                   'E' 'DDICTXT'     'S',

                                   'S' 'VRKME'       '',
                                   ' ' 'SELTEXT_S'   '단위',
                                   'E' 'DDICTXT'     'S',

                                   'S' 'KBMENG'      '',
                                   ' ' 'SELTEXT_S'   '확정수량',
                                   'E' 'DDICTXT'     'S',

                                   'S' 'BEZEI'       '',
                                   ' ' 'SELTEXT_S'   '거절사유',
                                   'E' 'DDICTXT'     'S',

                                   'S' 'VBELN_VL'    '',
                                   ' ' 'SELTEXT_S'   '납품번호',
                                   'E' 'DDICTXT'     'S',

                                   'S' 'POSNR_VL'    '',
                                   ' ' 'SELTEXT_S'   '납품품목',
                                   'E' 'DDICTXT'     'S',

                                   'S' 'TKNUM'       '',
                                   ' ' 'SELTEXT_S'   '선적번호',
                                   'E' 'DDICTXT'     'S',

                                   'S' 'TKNUM_SEA'       '',
                                   ' ' 'SELTEXT_S'   '해상선적번호',
                                   'E' 'DDICTXT'     'S',

                                   'S' 'VBELN_GI'    '',
                                   ' ' 'SELTEXT_S'   '출고전기번호',
                                   'E' 'DDICTXT'     'S',

                                   'S' 'LFIMG'       '',
                                   ' ' 'SELTEXT_S'   '납품수량',
                                   'E' 'DDICTXT'     'S',

                                   'S' 'RFMNG'       '',
                                   ' ' 'SELTEXT_S'   '피킹수량',
                                   'E' 'DDICTXT'     'S',

                                   'S' 'WADAT_IST'   '',
                                   ' ' 'SELTEXT_S'   '출고전기일',
                                   'E' 'DDICTXT'     'S',

                                   'S' 'VBELN_VF'    '',
                                   ' ' 'SELTEXT_S'   '빌링번호',
                                   'E' 'DDICTXT'     'S',

                                   'S' 'VKBUR'       '',
                                   ' ' 'SELTEXT_S'   '사업장',
                                   'E' 'DDICTXT'     'S',

                                   'S' 'VKGRP'       '',
                                   ' ' 'SELTEXT_S'   '영업그룹',
                                   'E' 'DDICTXT'     'S',

                                   'S' 'LIFNR'       '',
                                   ' ' 'SELTEXT_S'   '영업사원',
                                   'E' 'DDICTXT'     'S',

*{ 기능개선 323173 - 추가_S
                                   'S' 'ENAME'       '',
                                   ' ' 'SELTEXT_S'   '영업사원명',
                                   'E' 'DDICTXT'     'S',
*} 기능개선 323173 - 추가_E

                                   'S' 'ERDAT'       '',
                                   ' ' 'SELTEXT_S'   '생성일',
                                   'E' 'DDICTXT'     'S',

                                   'S' 'ERZET'       '',
                                   ' ' 'SELTEXT_S'   '입력시간',
                                   'E' 'DDICTXT'     'S',

                                   'S' 'ERNAM'       '',
                                   ' ' 'SELTEXT_S'   '사용자ID',
                                   'E' 'DDICTXT'     'S',

                                   'S' 'PRODH'       '',
                                   ' ' 'SELTEXT_S'   '계층구조',
                                   'E' 'DDICTXT'     'S',

                                   'S' 'KODAT'       '',
                                   ' ' 'SELTEXT_S'   '납품생성일',
                                   'E' 'DDICTXT'     'S',

                                   'S' 'LDDAT'       '',
                                   ' ' 'SELTEXT_S'   '적하일',
                                   'E' 'DDICTXT'     'S',

                                   'S' 'EDATU'       '',
*                                  ' ' 'SELTEXT_S'   '주문도착일',
                                   ' ' 'SELTEXT_L'   '시스템납품일',
                                   'E' 'DDICTXT'     'L',

                                   'S' 'EZEIT'       '',
                                   ' ' 'SELTEXT_S'   '주문도착시간',
                                   'E' 'DDICTXT'     'S',

                                   'S' 'LFDAT'       '',
                                   ' ' 'SELTEXT_S'   '납품도착일',
                                   'E' 'DDICTXT'     'S',

                                   'S' 'LFUHR'       '',
                                   ' ' 'SELTEXT_S'   '납품도착시간',
                                   'E' 'DDICTXT'     'S',

                                   'S' 'WADAT'       '',
                                   ' ' 'SELTEXT_S'   '계획G.I',
                                   'E' 'DDICTXT'     'S',

                                   'S' 'PROD1'       '',
                                   ' ' 'SELTEXT_S'   'ProdHi-1',
                                   'E' 'DDICTXT'     'S',

                                   'S' 'PROD2'       '',
                                   ' ' 'SELTEXT_S'   'ProdHi-2',
                                   'E' 'DDICTXT'     'S',

                                   'S' 'PROD3'       '',
                                   ' ' 'SELTEXT_S'   'ProdHi-3',
                                   'E' 'DDICTXT'     'S',

                                   'S' 'PSTYV'       '',
                                   ' ' 'SELTEXT_S'   'Item Category',
                                   'E' 'DDICTXT'     'S',

                                   'S' 'FKDAT'       '',
                                   ' ' 'SELTEXT_S'   '빌링일자',
                                   'E' 'DDICTXT'     'S',

                                   'S' 'VSTEL'       '',
                                   ' ' 'SELTEXT_S'   '출하지점',
                                   'E' 'DDICTXT'     'S',

                                   'S' 'BRGEW'       '',
                                   ' ' 'SELTEXT_S'   '중량(KG)',
                                   'E' 'DDICTXT'     'S',

                                   'S' 'MBDAT'       '',
                                   ' ' 'SELTEXT_S'   '자재가용일',
                                   'E' 'DDICTXT'     'S',

                                   'S' 'MATKL'       '',
                                   ' ' 'SELTEXT_S'   '자재그룹',
                                   'E' 'DDICTXT'     'S',

                                   'S' 'ERDAT2'      '',
                                   ' ' 'SELTEXT_S'   '선적생성일',
                                   'E' 'DDICTXT'     'S',

                                   'S' 'SPART'       '',
                                   ' ' 'SELTEXT_S'   '제품군',
                                   'E' 'DDICTXT'     'S',

                                   'S' 'NETWR'       '',
                                   ' ' 'SELTEXT_S'   '금액',
                                   'E' 'DDICTXT'     'S',

                                   'S' 'DIFF_DATE'   '',
                                   ' ' 'SELTEXT_S'   '차이일',
                                   'E' 'DDICTXT'     'S',

                                   'S' 'BEZEI2'      '',
                                   ' ' 'SELTEXT_S'   '오더사유',
                                   'E' 'DDICTXT'     'S',

                                   'S' 'KUNNR_SB'    '',
                                   ' ' 'SELTEXT_S'   '특별재고파트너',
                                   'E' 'DDICTXT'     'S',

                                   'S' 'LTRMP'       '',
                                   ' ' 'SELTEXT_S'   '생산계획일',
                                   'E' 'DDICTXT'     'S',

                                   'S' 'LTRMI'       '',
                                   ' ' 'SELTEXT_S'   '입고일',
                                   'E' 'DDICTXT'     'S',

                                   'S' 'VKORG'       '',
                                   ' ' 'SELTEXT_S'   '영업조직',
                                   'E' 'DDICTXT'     'S',

                                   'S' 'LGORT'       '',
                                   ' ' 'SELTEXT_S'   '저장위치',
                                   'E' 'DDICTXT'     'S',

                                   'S' 'BSTKD'       '',
                                   ' ' 'SELTEXT_S'   '고객PO번호',"'FILE번호',
                                   'E' 'DDICTXT'     'S',

                                   'S' 'KOSTK'       '',
                                   ' ' 'SELTEXT_S'   '피킹관련성',
                                   'E' 'DDICTXT'     'S',

                                   'S' 'KOSTK_TEXT'  '',
                                   ' ' 'SELTEXT_S'   '피킹설명',
                                   'E' 'DDICTXT'     'S',

                                   'S' 'TKNUM2'      '',
                                   ' ' 'SELTEXT_S'   '준비구간선적번호',
                                   'E' 'DDICTXT'     'S',

                                   'S' 'FKNUM'       '',
                                   ' ' 'SELTEXT_S'   'Cost Doc.',"'선적비용번호',
                                   'E' 'DDICTXT'     'S',

                                   'S' 'ERZET2'      '',
                                   ' ' 'SELTEXT_S'   '납품생성시간',
                                   'E' 'DDICTXT'     'S',

                                   'S' 'KUNNR_SH'    '',
                                   ' ' 'SELTEXT_S'   '인도처',
                                   'E' 'DDICTXT'     'S',

                                   'S' 'WBSTK'       '',
                                   ' ' 'SELTEXT_S'   '전체상품이동상태',
                                   'E' 'DDICTXT'     'S',

                                   'S' 'ROUTE'       '',
                                   ' ' 'SELTEXT_S'   '운송경로',
                                   'E' 'DDICTXT'     'S',

                                   'S' 'LFART'       '',
                                   ' ' 'SELTEXT_S'   '납품유형',
                                   'E' 'DDICTXT'     'S',

                                   'S' 'ERZET3'      '',
                                   ' ' 'SELTEXT_S'   '선적생성시간',
                                   'E' 'DDICTXT'     'S',

                                   'S' 'UZDIS'       '',
                                   ' ' 'SELTEXT_S'   '계획시간',
                                   'E' 'DDICTXT'     'S',

                                   'S' 'UAREG'       '',
                                   ' ' 'SELTEXT_S'   '체크인시간',
                                   'E' 'DDICTXT'     'S',

                                   'S' 'BTGEW'       '',
                                   ' ' 'SELTEXT_S'   '납품중량',
                                   'E' 'DDICTXT'     'S',

                                   'S' 'KUNNR'       '',
                                   ' ' 'SELTEXT_S'   '거래선',
                                   'E' 'DDICTXT'     'S',

                                   'S' 'CPUTM'       '',
                                   ' ' 'SELTEXT_S'   'G/I시간',
                                   'E' 'DDICTXT'     'S',

                                   'S' 'VKBUR_TEXT'  '',
                                   ' ' 'SELTEXT_S'   '사업장명',
                                   'E' 'DDICTXT'     'S',

                                   'S' 'VKGRP_TEXT'  '',
                                   ' ' 'SELTEXT_S'   '영업그룹명',
                                   'E' 'DDICTXT'     'S',

                                   'S' 'WERKS_TEXT'  '',
                                   ' ' 'SELTEXT_S'   '플랜트명',
                                   'E' 'DDICTXT'     'S',

                                   'S' 'VSTEL_TEXT'  '',
                                   ' ' 'SELTEXT_S'   '출하지점명',
                                   'E' 'DDICTXT'     'S',

                                   'S' 'ROUTE_TEXT'  '',
                                   ' ' 'SELTEXT_S'   '운송경로명',
                                   'E' 'DDICTXT'     'S',

                                   'S' 'KUNNR_SB_TEXT' '',
                                   ' ' 'SELTEXT_S'   '특별재고파트너명',
                                   'E' 'DDICTXT'     'S',

                                   'S' 'VALUE1'      '',
                                   ' ' 'SELTEXT_S'   '조장수',
                                   'E' 'DDICTXT'     'S',

                                   'S' 'VALUE2'      '',
                                   ' ' 'SELTEXT_S'   '조장', "'개별길이',
                                   'E' 'DDICTXT'     'S',

                                   'S' 'VALUE3'      '',
                                   ' ' 'SELTEXT_S'   '색상',
                                   'E' 'DDICTXT'     'S',



*                                   'S' 'ORDID'       '',
*                                   ' ' 'SELTEXT_L'   '생산오더번호',
*                                   'E' 'DDICTXT'     'L',

* 20070912 곽태근 과장님 요청으로 아래내용 수정
* 오더트랙킹상에 생산오더번호 필드의 헤더를 ‘오더번호’로 변경
* 오더번호’ 필드의 값이 구매오더일 경우 해당라인의 판매오더번호와
* 품목번호로 구매오더번호와 품목번호를 찾아서
* 구매오더 품목의 시작/종료일을 조회하고,
* 이 값을 오더 트랙킹 레포트 상의
* 현공정 오더시작일, 현공정 오더종료일 필드에 대체해서 display해줌

                                   'S' 'ORDID'       '',
                                   ' ' 'SELTEXT_L'   '오더번호',
                                   'E' 'DDICTXT'     'L',

                                   'S' 'SOSTAT'      '',
                                   ' ' 'SELTEXT_L'   '판매오더시작일',
                                   'E' 'DDICTXT'     'L',

                                   'S' 'SOEND'       '',
                                   ' ' 'SELTEXT_L'   '판매오더종료일',
                                   'E' 'DDICTXT'     'L',

                                   'S' 'OPRTX'       '',
                                   ' ' 'SELTEXT_S'   '공정상황',
                                   'E' 'DDICTXT'     'S',

                                   'S' 'OPSTAT'      '',
                                   ' ' 'SELTEXT_L'   '현공정오더시작일',
                                   'E' 'DDICTXT'     'L',

                                   'S' 'OPEND'       '',
                                   ' ' 'SELTEXT_L'   '현공정오더완료일',
                                   'E' 'DDICTXT'     'L',

                                   'S' 'CHARG'       '',
                                   ' ' 'SELTEXT_S'   'Batch No',
                                   'E' 'DDICTXT'     'S',

                                   'S' 'MENGE'       '',
                                   ' ' 'SELTEXT_S'   '입고수량',
                                   'E' 'DDICTXT'     'S',

                                   'S' 'BUDAT'       '',
                                   ' ' 'SELTEXT_S'   '입고일',
                                   'E' 'DDICTXT'     'S',

                                   'S' 'DPTEN'       '',
                                   ' ' 'SELTEXT_S'   '선적종료계획',
                                   'E' 'DDICTXT'     'S',

                                   'S' 'UPTEN'       '',
                                   ' ' 'SELTEXT_S'   '선적종료계획시간',
                                   'E' 'DDICTXT'     'S',

                                   'S' 'VALUE4'      '',
                                   ' ' 'SELTEXT_S'   '입회검사유무',
                                   'E' 'DDICTXT'     'S',
*[C20100928_44362]20101014 명칭수정 : 프로젝트No => PJT&APPL 번호.
*                 PJT&APPL명 추가.
                                   'S' 'ZPJNO'       '',
                                   ' ' 'SELTEXT_L'   'PJT&APPL 번호',
                                   'E' 'DDICTXT'     'L',

                                   'S' 'ZPTXT'       '',
                                   ' ' 'SELTEXT_L'   'PJT&APPL명',
                                   'E' 'DDICTXT'     'L',
*[C20100928_44362]End of Change.
                                   'S' 'SPART2'      '',
                                   ' ' 'SELTEXT_L'   '품목별제품군',
                                   'E' 'DDICTXT'     'L',

                                   'S' 'VALUE5'      '',
                                   ' ' 'SELTEXT_S'   '절연선심식별',
                                   'E' 'DDICTXT'     'S',

                                   'S' 'ZLFIMG'      '',
                                   ' ' 'SELTEXT_S'   '절단지시수량',
                                   'E' 'DDICTXT'     'S',

                                   'S' 'JISIDAT'     '',
                                   ' ' 'SELTEXT_S'   '절단지시일',
                                   'E' 'DDICTXT'     'S',

                                   'S' 'CUTSDAT'     '',
                                   ' ' 'SELTEXT_S'   '절단완료일',
                                   'E' 'DDICTXT'     'S',

*{ SRM2404-07578 - s
                                   'S' 'VALUE6'     '',
                                   ' ' 'SELTEXT_S'   '튜브인쇄사양',
                                   'E' 'DDICTXT'     'S',
*} SRM2404-07578 - e

                                   'S' 'CU_QTY'     '',
                                   ' ' 'SELTEXT_M'   '주문 CU량(KG)',
                                   'E' 'DDICTXT'     'M',

                                   'S' 'AL_QTY'     '',
                                   ' ' 'SELTEXT_M'   '주문 AL량(KG)',
                                   'E' 'DDICTXT'     'M',

                                   'S' 'N_CLABS'     '',
                                   ' ' 'SELTEXT_M'   '현재고',
                                   ' ' 'JUST'        'R',
                                   'E' 'DDICTXT'     'M',

                                   'S' 'SOBKZ'       '',
                                   ' ' 'SELTEXT_M'   '특별재고',
                                   ' ' 'JUST'        'R',
                                   'E' 'DDICTXT'     'M',

                                   'S' 'ZPROJECT'     '',
                                   ' ' 'SELTEXT_M'   'Ship No.(호선)',
                                   'E' 'DDICTXT'     'M',

                                   'S' 'ZZMAKTX80'   '',
                                   ' ' 'SELTEXT_M'   '상세 품명',
                                   'E' 'DDICTXT'     'M',

* CSR Number : C20081226_77528 드럼번호 필드 추가
                                   'S' 'EMPST'   '',
                                   ' ' 'SELTEXT_M'   '드럼번호',
                                   'E' 'DDICTXT'     'M',
* CSR Number : C20081226_77528
*--[START] C20130225_79371 order tracking 내에 포장재 번호 추가 요청_hoi
                                   'S' 'PACKING_DM_NM'   '',
                                   ' ' 'SELTEXT_M'   '드럼포장재',
                                   'E' 'DDICTXT'     'M',
*--[END] C20130225_79371 order tracking 내에 포장재 번호 추가 요청_hoi

*-{기능개선175813 - 추가
                                   'S' 'KDMAT'       '',
                                   ' ' 'SELTEXT_S'   '고객자재',
                                   'E' 'DDICTXT'     'S',

                                   'S' 'BSTKD_E'     '',
                                   ' ' 'SELTEXT_S'   '납품처PO',
                                   'E' 'DDICTXT'     'S',

*                                   'S' 'POSEX_E'       '',
*                                   ' ' 'SELTEXT_S'   '납품처PO품목',
*                                   'E' 'DDICTXT'     'S',
*
*                                   'S' 'IHREZ_E'       '',
*                                   ' ' 'SELTEXT_S'   '사용자참조',
*                                   'E' 'DDICTXT'     'S',
*-}기능개선175813_2016.12.29
*-{기능개선178174 - 추가
                                   'S' 'SOTEXT'      '',
                                   ' ' 'SELTEXT_L'   '자재 판매 텍스트',
                                   'E' 'DDICTXT'     'S',
*-}기능개선178174_2017.01.12
*-- 기능개선 211276 - 지급처, 구매오더번호 추가 {
                                   'S' 'KUNNR_PY'       '',
                                   ' ' 'SELTEXT_S'   '지급처',
                                   'E' 'DDICTXT'     'S',

                                   'S' 'NAME1_PY'    '',
                                   ' ' 'SELTEXT_S'   '지급처명',
                                   'E' 'DDICTXT'     'S',
*-- } 기능개선 211276_2017.11.07

**-{기능개선 314340
                                   'S' 'ZTERM'       '',
                                   ' ' 'SELTEXT_S'   '지급조건',
                                   'E' 'DDICTXT'     'S',

                                   'S' 'TEXT1'       '',
                                   ' ' 'SELTEXT_S'   '지급조건명',
                                   'E' 'DDICTXT'     'S',

                                   'S' 'PRCTR'       '',
                                   ' ' 'SELTEXT_S'   '손익센터',
                                   'E' 'DDICTXT'     'S',

                                   'S' 'LAND1'       '',
                                   ' ' 'SELTEXT_S'   '고객국가',
                                   'E' 'DDICTXT'     'S',
*{ CHM2009-00236 - S
                                   'S' 'CHARG_V'       '',
                                   ' ' 'SELTEXT_S'   '오더배치',
                                   'E' 'DDICTXT'     'S',
*} CHM2009-00236 - E
**-} 기능개선 314340
                                   'S' 'SCR_GRADE'   '',
                                   ' ' 'SELTEXT_S'   '등급',
                                   ' ' 'SELTEXT_M'   '등급',
                                   ' ' 'SELTEXT_L'   '등급',
                                   ' ' 'REPTEXT_DDIC'   '등급',
                                   'E' 'DDICTXT'     'S',

                                   'S' 'VALUE7'   '',
                                   ' ' 'SELTEXT_S'   'Stripe',
                                   ' ' 'SELTEXT_M'   'Stripe',
                                   ' ' 'SELTEXT_L'   'Stripe',
                                   ' ' 'REPTEXT_DDIC'   'Stripe',
                                   'E' 'DDICTXT'     'S',

                                   'S' 'VALUE8'   '',
                                   ' ' 'SELTEXT_S'   '띄줄수',
                                   ' ' 'SELTEXT_M'   '띄줄수',
                                   ' ' 'SELTEXT_L'   '띄줄수',
                                   ' ' 'REPTEXT_DDIC'   '띄줄수',
                                   'E' 'DDICTXT'     'S'.

ENDFORM.                    " WRITE_FORM
*&---------------------------------------------------------------------*
*&      Form  ALV_DISPLAY
*&---------------------------------------------------------------------*
*       ALV DISPLAY
*----------------------------------------------------------------------*
FORM ALV_DISPLAY.

** Layout관련
  CLEAR  GS_VARIANT.
  MOVE-CORRESPONDING  SPEC_LAYOUT  TO  GS_VARIANT.

  G_SAVE = 'A'.

  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      I_CALLBACK_PROGRAM      = G_PROGRAM
      IS_LAYOUT               = G_LAYOUT_S
      I_SAVE                  = G_SAVE
      IS_VARIANT              = GS_VARIANT
      IT_EVENTS               = G_EVENTS_T[]
      IT_FIELDCAT             = G_FIELDCAT_T[]
      I_BYPASSING_BUFFER      = 'X'
      I_BUFFER_ACTIVE         = 'X'
    IMPORTING
      E_EXIT_CAUSED_BY_CALLER = G_EXIT_CAUSED_BY_CALLER
      ES_EXIT_CAUSED_BY_USER  = G_EXIT_CAUSED_BY_USER_S
    TABLES
      T_OUTTAB                = G_ITAB_T
    EXCEPTIONS
      PROGRAM_ERROR           = 1
      OTHERS                  = 2.


ENDFORM.                    " ALV_DISPLAY

*&---------------------------------------------------------------------*
*&      Form  WRITE_DATA_CALC_RTN
*&---------------------------------------------------------------------*
*       DESCRIPTION
*----------------------------------------------------------------------*
*      -->P_DATA1      생성일자
*      -->P_DATA2      영업조직
*      -->P_DATA2      제품군
*----------------------------------------------------------------------*
FORM WRITE_DATA_CALC_RTN USING    P_DATA1
                                  P_DATA2
                                  P_DATA3.
  DATA: LV_TEXT10(20),
        LV_TEXT20(20).

  IF SO_EDATU-LOW IS INITIAL AND
     SO_EDATU-HIGH IS INITIAL.
    P_DATA1 = '전체'.

  ELSE.

    IF NOT SO_EDATU-LOW IS INITIAL.
      WRITE: SO_EDATU-LOW TO LV_TEXT10 USING EDIT MASK '____.__.__'.
    ENDIF.
    IF NOT SO_EDATU-HIGH IS INITIAL.
      WRITE: SO_EDATU-HIGH TO LV_TEXT20 USING EDIT MASK '____.__.__'.
    ENDIF.

    P_DATA1 = |{ LV_TEXT10 } ~ { LV_TEXT20 }|.
  ENDIF.

**  if not so_vdatu-low is initial.
*  IF NOT SO_EDATU-LOW IS INITIAL.
**     p_data1 = so_vdatu-low .
*    P_DATA1 = SO_EDATU-LOW .
*  ELSE.
*    P_DATA1 = '전체'.
*  ENDIF.
*
**  if not so_vdatu-high is initial.
*  IF NOT SO_EDATU-HIGH IS INITIAL.
**     concatenate so_vdatu-low ' ~ ' so_vdatu-high into p_data1.
*    CONCATENATE SO_EDATU-LOW ' ~ ' SO_EDATU-HIGH INTO P_DATA1.
*  ENDIF.

  P_DATA2 = PA_VKORG.

*-제품군
  SELECT VKORG,VTWEG,SPART
    FROM TVTA
   WHERE VKORG EQ @PA_VKORG
     AND SPART IN @SO_SPART
    INTO TABLE @DATA(LT_VALUE).
  SORT LT_VALUE BY SPART.
  DELETE ADJACENT DUPLICATES FROM LT_VALUE COMPARING SPART.
  LOOP AT LT_VALUE INTO DATA(LS_VALUE).
    IF P_DATA3 IS NOT INITIAL.
      P_DATA3 = |{ P_DATA3 }/{ LS_VALUE-SPART }|.
    ELSE.
      P_DATA3 = LS_VALUE-SPART.
    ENDIF.
  ENDLOOP.
*  P_DATA3 = SO_SPART-LOW.

ENDFORM.                    " WRITE_DATA_CALC_RTN
*---------------------------------------------------------------------*
*      Form  TOP_OF_PAGE
*---------------------------------------------------------------------*
*      TOP의 로그 부분 SETTING.
*---------------------------------------------------------------------*
FORM TOP_OF_PAGE.

  CALL FUNCTION 'REUSE_ALV_COMMENTARY_WRITE'
    EXPORTING
      I_LOGO             = ' '
      IT_LIST_COMMENTARY = G_LIST_TOP_OF_PAGE_T.

ENDFORM.                    "top_of_page
*&---------------------------------------------------------------------*
*&      Form  PF_STATUS_SET
*&---------------------------------------------------------------------*
*       text : PF-STATUS 정해주는 로직.
*----------------------------------------------------------------------*
FORM PF_STATUS_SET USING P_RT_EXTAB TYPE SLIS_T_EXTAB.

  SET PF-STATUS '1000'.          "EXCLUDING RT_EXTAB.
  SET TITLEBAR  '1000'.

ENDFORM.                    " PF_STATUS_SET
*&---------------------------------------------------------------------*
*&      Form  BL_SELECT_RTN
*&---------------------------------------------------------------------*
*       BILLING 번호 SELECT
*----------------------------------------------------------------------*
FORM BL_SELECT_RTN.

*  if g_itso_t-auart = 'ZRE'  or g_itso_t-auart = 'ZREQ' or
*     g_itso_t-auart = 'ZKR'  or g_itso_t-auart = 'ZKR1' or
*     g_itso_t-auart = 'ZKR2' or g_itso_t-auart = 'ZEKR'.
  IF G_ITSO_T-AUART = 'RE' OR G_ITSO_T-AUART = 'ZREQ'.

    SELECT  SINGLE MAX( VBELN )  AS VBELN_VF   "빌링번호
      INTO  CORRESPONDING FIELDS OF G_ITDL_T
      FROM  VBFA
     WHERE  VBELV      =   G_ITDL_T-VBELN_VL
       AND  POSNV      =   G_ITDL_T-POSNR_VL
       AND  VBTYP_N    =   'O'.

  ELSE.

    SELECT  SINGLE MAX( VBELN )  AS VBELN_VF   "빌링번호
      INTO  CORRESPONDING FIELDS OF G_ITDL_T
      FROM  VBFA
     WHERE  VBELV      =   G_ITDL_T-VBELN_VL
       AND  POSNV      =   G_ITDL_T-POSNR_VL
       AND  VBTYP_N    =   'M'.

  ENDIF.

  SELECT  SINGLE FKDAT
    INTO  G_ITDL_T-FKDAT
    FROM  VBRK
   WHERE  VBELN  =  G_ITDL_T-VBELN_VF.

ENDFORM.                    " BL_SELECT_RTN

*&---------------------------------------------------------------------*
*&      Form  CALL_VA03
*&---------------------------------------------------------------------*
*       오더 상세조회
*----------------------------------------------------------------------*
FORM CALL_VA03 USING    P_VALUE.

* PARAMETER SETTING
  SET PARAMETER ID: 'AUN'    FIELD   P_VALUE.

*   CALL TRANSACTION
  CALL   TRANSACTION  'VA03' AND SKIP FIRST SCREEN.
  COMMIT WORK AND WAIT.

ENDFORM.                                                    " CALL_VA03

*&---------------------------------------------------------------------*
*&      Form  GI_SELECT_RTN
*&---------------------------------------------------------------------*
*       출고전기 번호
*----------------------------------------------------------------------*
FORM GI_SELECT_RTN.

  SELECT  SINGLE MAX( VBELN )  AS VBELN_GI          "출고전기번호
    INTO  CORRESPONDING FIELDS OF G_ITDL_T
    FROM  VBFA
   WHERE  VBELV      =   G_ITDL_T-VBELN_VL
     AND  VBTYP_N    =   'R'.

ENDFORM.                    " GI_SELECT_RTN

*&---------------------------------------------------------------------*
*&      Form  SH_SELECT_RTN
*&---------------------------------------------------------------------*
*       선적번호 SELECT
*----------------------------------------------------------------------*
FORM SH_SELECT_RTN.

  SELECT  SINGLE MAX( VBELN )  AS  TKNUM           "선적번호
    INTO  CORRESPONDING FIELDS OF G_ITDL_T
    FROM  VBFA
   WHERE  VBELV      =   G_ITDL_T-VBELN_VL
     AND  POSNV      =   '000000'
     AND  VBTYP_N    =   '8'.

ENDFORM.                    " SH_SELECT_RTN

*&---------------------------------------------------------------------*
*&      Form  CALL_VL03N
*&---------------------------------------------------------------------*
*       DELIVERY 조회
*----------------------------------------------------------------------*
FORM CALL_VL03N USING    P_VALUE.

  CHECK P_VALUE NE SPACE.

* PARAMETER SETTING
  SET PARAMETER ID: 'VL'    FIELD   P_VALUE.

* CALL TRANSACTION
  CALL   TRANSACTION  'VL03N' AND SKIP FIRST SCREEN.
  COMMIT WORK AND WAIT.

ENDFORM.                    " CALL_VL03N
*&---------------------------------------------------------------------*
*&      Form  CALL_VT03N
*&---------------------------------------------------------------------*
*       SHIPMENT 상세조회
*----------------------------------------------------------------------*
FORM CALL_VT03N USING    P_VALUE.

  CHECK P_VALUE NE SPACE.

* PARAMETER SETTING
  SET PARAMETER ID: 'TNR'    FIELD   P_VALUE.

* CALL TRANSACTION
  CALL   TRANSACTION  'VT03N' AND SKIP FIRST SCREEN.
  COMMIT WORK AND WAIT.

ENDFORM.                    " CALL_VT03N
*&---------------------------------------------------------------------*
*&      Form  CALL_MB03
*&---------------------------------------------------------------------*
*       출고전기 상세조회
*----------------------------------------------------------------------*
FORM CALL_MB03 USING    P_VALUE.

  CHECK P_VALUE NE SPACE.
*-> CCM : 12.04.2023 09:22:43 ZLSGSD5 - MB03 Function으로 변경
** PARAMETER SETTING
*  SET PARAMETER ID: 'MBN'    FIELD   P_VALUE.
*
** CALL TRANSACTION
*  CALL   TRANSACTION  'MB03' AND SKIP FIRST SCREEN.
*  COMMIT WORK AND WAIT.
  DATA : LV_MBLNR TYPE MBLNR.
  LV_MBLNR = P_VALUE.

  CALL FUNCTION 'MIGO_DIALOG'
    EXPORTING
      I_ACTION            = 'A04'
      I_REFDOC            = 'R02'
      I_NOTREE            = 'X'
      I_SKIP_FIRST_SCREEN = 'X'
      I_DEADEND           = 'X'
      I_OKCODE            = 'OK_GO'
      I_NEW_ROLLAREA      = 'X'
      I_MBLNR             = LV_MBLNR
*     i_mjahr             = lv_mjahr
    EXCEPTIONS
      ILLEGAL_COMBINATION = 1
      OTHERS              = 2.
*<-

ENDFORM.                                                    " CALL_MB03
*&---------------------------------------------------------------------*
*&      Form  CALL_VF03
*&---------------------------------------------------------------------*
*       BILLING 상세 조회
*----------------------------------------------------------------------*
FORM CALL_VF03 USING    P_VALUE.

  CHECK P_VALUE NE SPACE.

* PARAMETER SETTING
  SET PARAMETER ID: 'VF'    FIELD   P_VALUE.

* CALL TRANSACTION
  CALL   TRANSACTION  'VF03' AND SKIP FIRST SCREEN.
  COMMIT WORK AND WAIT.

ENDFORM.                                                    " CALL_VF03

*&---------------------------------------------------------------------*
*&      Form  value_request_vari
*&---------------------------------------------------------------------*
FORM VALUE_REQUEST_VARI .

  CLEAR G_LAYOUT.

  MOVE  G_REPID  TO  G_LAYOUT-REPORT.

  CALL FUNCTION 'LVC_VARIANT_F4'
    EXPORTING
      IS_VARIANT = G_LAYOUT
      I_SAVE     = G_SAVE
    IMPORTING
      E_EXIT     = G_EXIT
      ES_VARIANT = SPEC_LAYOUT
    EXCEPTIONS
      NOT_FOUND  = 1
      OTHERS     = 2.

  IF  SY-SUBRC NE 0.
    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
          WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ELSE.
    IF  G_EXIT NE 'X'.
** set name of layout on selection screen
      P_VARI  =  SPEC_LAYOUT-VARIANT.
    ENDIF.
  ENDIF.

ENDFORM.                    " value_request_vari

*&---------------------------------------------------------------------*
*&      Form  F4_FOR_SPART
*&---------------------------------------------------------------------*
*       제품군 POSSIBLE ENTRY
*----------------------------------------------------------------------*
FORM F4_FOR_SPART.
* 현재 화면에 들어와 있는 영업조직 읽어드림.
  CALL FUNCTION 'DYNP_VALUES_READ'
    EXPORTING
      DYNAME               = 'ZSDR0200'
      DYNUMB               = PA_VKORG
    TABLES
      DYNPFIELDS           = G_DYNPFIELDS_T
    EXCEPTIONS
      INVALID_ABAPWORKAREA = 1
      INVALID_DYNPROFIELD  = 2
      INVALID_DYNPRONAME   = 3
      INVALID_DYNPRONUMMER = 4
      INVALID_REQUEST      = 5
      NO_FIELDDESCRIPTION  = 6
      INVALID_PARAMETER    = 7
      UNDEFIND_ERROR       = 8
      DOUBLE_CONVERSION    = 9
      STEPL_NOT_FOUND      = 10
      OTHERS               = 11.

  READ TABLE G_DYNPFIELDS_T WITH KEY FIELDNAME = 'PA_VKORG'.

  IF SY-SUBRC = 0.
    PA_VKORG = G_DYNPFIELDS_T-FIELDVALUE.
  ELSE.
    MESSAGE E038.
  ENDIF.


*FILL INTERNAL TABLE FOR POSSIBLE ENTRY
  SELECT  DISTINCT A~SPART                  " 유통경로
                   B~VTEXT                  " 유통경로 TEXT
     FROM  TVTA AS A
    INNER JOIN  TSPAT AS B
       ON  A~SPART = B~SPART
     INTO  CORRESPONDING FIELDS OF TABLE G_VALUES2_T
    WHERE A~VKORG = PA_VKORG
      AND A~VTWEG LIKE '%'
      AND B~SPRAS = SY-LANGU.

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      RETFIELD        = 'SPART'
      DYNPPROG        = 'ZSDR0200'
      DYNPNR          = PA_VKORG
      DYNPROFIELD     = 'PA_SPART'
      WINDOW_TITLE    = '제품군'
      VALUE_ORG       = 'S'
    TABLES
      VALUE_TAB       = G_VALUES2_T
    EXCEPTIONS
      PARAMETER_ERROR = 1
      NO_VALUES_FOUND = 2
      OTHERS          = 3.

  IF SY-SUBRC <> 0.

    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.

  ENDIF.

ENDFORM.                    " F4_FOR_SPART
*&---------------------------------------------------------------------*
*&      Form  DELETE_ITAB
*&---------------------------------------------------------------------*
*       해당 출고전기일만 제외하고 삭제
*----------------------------------------------------------------------*
FORM DELETE_ITAB.

  LOOP AT G_ITAB_T.

    IF G_ITAB_T-WADAT_IST(6) <> PA_SPMON.

      DELETE G_ITAB_T.
      CLEAR  G_ITAB_T.

    ENDIF.

  ENDLOOP.

ENDFORM.                    " DELETE_ITAB

*&---------------------------------------------------------------------*
*&      Form  GET_VBELN
*&---------------------------------------------------------------------*
*       차후 영업/유통문서, 거래선명 등.
*----------------------------------------------------------------------*
FORM GET_VBELN.

  LOOP AT G_ITSO_T.
*___제품계층구조(1,2,3)명
    PERFORM GET_PRODH_DESC USING: G_ITSO_T-PRODH(8)
                                  G_ITSO_T-PROD1,

                                  G_ITSO_T-PRODH(14)
                                  G_ITSO_T-PROD2,

                                  G_ITSO_T-PRODH(18)
                                  G_ITSO_T-PROD3.

*___인도처
    PERFORM GET_PARTNER_NAME USING G_ITSO_T-VBELN
                                   G_ITSO_T-POSNR
                                   'WE'
                                   G_ITSO_T-KUNNR_SH
                                   G_ITSO_T-NAME1_SH.

*___인도처 검색조건 처리
    IF PA_KUNWE <> SPACE AND G_ITSO_T-KUNNR_SH <> PA_KUNWE.
      DELETE G_ITSO_T.
      CONTINUE.
    ENDIF.

*___지급처
    PERFORM GET_PARTNER_NAME USING G_ITSO_T-VBELN
                                   G_ITSO_T-POSNR
                                   'RG'
                                   G_ITSO_T-KUNNR_PY
                                   G_ITSO_T-NAME1_PY.

*___지급처 검색조건 처리
    IF PA_KUNRG <> SPACE AND G_ITSO_T-KUNNR_PY <> PA_KUNRG.
      DELETE G_ITSO_T.
      CONTINUE.
    ENDIF.

*___마지막날
    PERFORM GET_LAST_DELIVERY_DATE USING G_ITSO_T-VBELN
                                         G_ITSO_T-POSNR
                                         G_ITSO_T-EDATU.

*___거래선명
    PERFORM GET_PARTNER_NAME USING G_ITSO_T-VBELN
                                   G_ITSO_T-POSNR
                                   'RG'
                                   G_ITSO_T-KUNNR
                                   G_ITSO_T-NAME1.

*___자재내역
    PERFORM GET_MATNR_DESC USING G_ITSO_T-MATNR
                                 G_ITSO_T-MAKTX.

*___거절사유
    PERFORM GET_ABGRU_DESC USING G_ITSO_T-ABGRU
                                 G_ITSO_T-BEZEI.

*___제품계층구조 1 LEVEL
    G_ITSO_T-PRODH = G_ITSO_T-PRODH(4).

*___오더특성 - 조장수/개별길이/색상/입회검사유무
    PERFORM QUERY_CHAR_VALUE_RTN.

*___납품 데이타 SELECT
    PERFORM DN_SELECT_RTN.

*___진행율표시
    ADD  1   TO  G_CNT.
    G_RATIO = G_CNT * 100 / G_TOTCNT.
    PERFORM  PROGRESS_INDICATOR.
  ENDLOOP.

*___납품일정라인에 따른 Gethering
  DELETE G_ITAB_T WHERE ETENR NE '0001'.

ENDFORM.                    " GET_VBELN
*&---------------------------------------------------------------------*
*&      Form  GET_VBELN_OLD
*&---------------------------------------------------------------------*
*       차후 영업/유통문서, 거래선명 등.
*----------------------------------------------------------------------*
FORM GET_VBELN_OLD.

  DATA : L_PROD1(5), L_PROD2(10), L_PROD3(18),
         L_ADRNR LIKE VBPA-ADRNR.
  CLEAR : L_PROD1, L_PROD2, L_PROD3, L_ADRNR.

  DATA : L_ETENR  LIKE VBEP-ETENR.

  LOOP AT G_ITSO_T.

* 제품계층구조(1,2,3)명 Query
    IF  G_ITSO_T-PRODH  <>  SPACE.

      L_PROD1  =  G_ITSO_T-PRODH(5).
      L_PROD2  =  G_ITSO_T-PRODH(10).
      L_PROD3  =  G_ITSO_T-PRODH(18).

      SELECT  SINGLE VTEXT            " 제품계층구조1
        INTO  G_ITSO_T-PROD1
        FROM  T179T
       WHERE  SPRAS  =  '3'
         AND  PRODH  =  L_PROD1.

      SELECT  SINGLE VTEXT            " 제품계층구조2
        INTO  G_ITSO_T-PROD2
        FROM  T179T
       WHERE  SPRAS  =  '3'
         AND  PRODH  =  L_PROD2.

      SELECT  SINGLE VTEXT            " 제품계층구조3
        INTO  G_ITSO_T-PROD3
        FROM  T179T
       WHERE  SPRAS  =  '3'
         AND  PRODH  =  L_PROD3.

    ELSE.

      G_ITSO_T-PROD1  =  SPACE.
      G_ITSO_T-PROD2  =  SPACE.
      G_ITSO_T-PROD3  =  SPACE.

    ENDIF.

**  인도처
    SELECT  SINGLE
            KUNNR AS KUNNR_SH
            ADRNR
      INTO  CORRESPONDING FIELDS OF G_ITSO_T
      FROM  VBPA
     WHERE  VBELN = G_ITSO_T-VBELN
       AND  POSNR = G_ITSO_T-POSNR
       AND  PARVW = 'WE'.

    IF  SY-SUBRC <> 0.

      SELECT  SINGLE
              KUNNR AS KUNNR_SH
              ADRNR
        INTO  CORRESPONDING FIELDS OF G_ITSO_T
        FROM  VBPA
       WHERE  VBELN = G_ITSO_T-VBELN
         AND  POSNR = '0'
         AND  PARVW = 'WE'.

    ENDIF.

**  인도처 검색조건 처리
    IF  PA_KUNWE <> SPACE.

      IF  G_ITSO_T-KUNNR_SH <> PA_KUNWE.

        DELETE G_ITSO_T.
        CLEAR  G_ITSO_T.

        CONTINUE.

      ENDIF.

    ENDIF.

**  인도처명
    SELECT SINGLE NAME1 AS NAME1_SH
      INTO CORRESPONDING FIELDS OF G_ITSO_T
      FROM ADRC
     WHERE ADDRNUMBER = G_ITSO_T-ADRNR
       AND DATE_FROM  = '00010101'
       AND NATION     = ' '.

*-- 기능개선 211276 - 지급처, 구매오더번호 추가 {
**  지급처
    SELECT  SINGLE
            KUNNR AS KUNNR_PY
            ADRNR
      INTO  CORRESPONDING FIELDS OF G_ITSO_T
      FROM  VBPA
     WHERE  VBELN = G_ITSO_T-VBELN
       AND  POSNR = G_ITSO_T-POSNR
       AND  PARVW = 'RG'.

    IF  SY-SUBRC <> 0.

      SELECT  SINGLE
              KUNNR AS KUNNR_PY
              ADRNR
        INTO  CORRESPONDING FIELDS OF G_ITSO_T
        FROM  VBPA
       WHERE  VBELN = G_ITSO_T-VBELN
         AND  POSNR = '0'
         AND  PARVW = 'RG'.

    ENDIF.

**  지급처 검색조건 처리
    IF  PA_KUNRG <> SPACE.

      IF  G_ITSO_T-KUNNR_PY <> PA_KUNRG.

        DELETE G_ITSO_T.
        CLEAR  G_ITSO_T.

        CONTINUE.

      ENDIF.

    ENDIF.

**  지급처명
    SELECT SINGLE NAME1 AS NAME1_PY
      INTO CORRESPONDING FIELDS OF G_ITSO_T
      FROM ADRC
     WHERE ADDRNUMBER = G_ITSO_T-ADRNR
       AND DATE_FROM  = '00010101'
       AND NATION     = ' '.

*-- } 기능개선 211276_2017.11.07

***  첫날
*    select  min( etenr )
*      into l_etenr
*      from  vbep
*     where  vbeln = g_itso_t-vbeln
*       and  posnr = g_itso_t-posnr
*       and  wmeng > 0 .
*
***  주문도착일시/자재가용일 Query
*    select  single edatu ezeit mbdat
*      into  corresponding fields of g_itso_t
*      from  vbep
*     where  vbeln  =  g_itso_t-vbeln
*       and  posnr  =  g_itso_t-posnr
*       and  etenr  =  l_etenr.

**  마지막날
    SELECT  SINGLE EDATU
      INTO  CORRESPONDING FIELDS OF G_ITSO_T
      FROM  VBEP
     WHERE  VBELN = G_ITSO_T-VBELN
       AND  POSNR = G_ITSO_T-POSNR
       AND  ETENR = ( SELECT  MAX( ETENR )
                        FROM  VBEP
                       WHERE  VBELN = G_ITSO_T-VBELN
                         AND  POSNR = G_ITSO_T-POSNR ).

**  거래선명
    IF  G_ITSO_T-KUNNR  =  'DOMESTIC'.

      SELECT  SINGLE ADRNR
        INTO  L_ADRNR
        FROM  VBPA
       WHERE  VBELN = G_ITSO_T-VBELN
         AND  POSNR = '0'
         AND  PARVW = 'AG'.

      SELECT SINGLE NAME1
        INTO CORRESPONDING FIELDS OF G_ITSO_T
        FROM ADRC
       WHERE ADDRNUMBER = L_ADRNR
         AND DATE_FROM  = '00010101'
         AND NATION     = ' '.

    ELSE.

      SELECT  SINGLE  NAME1
        INTO  CORRESPONDING FIELDS OF G_ITSO_T
        FROM  KNA1
       WHERE  KUNNR = G_ITSO_T-KUNNR.

    ENDIF.

**  자재내역
    SELECT  SINGLE  MAKTX
      INTO  CORRESPONDING FIELDS OF G_ITSO_T
      FROM  MAKT
     WHERE  MATNR = G_ITSO_T-MATNR.

**  거절사유
    IF G_ITSO_T-ABGRU <> ' '.

      SELECT SINGLE BEZEI
        INTO CORRESPONDING FIELDS OF G_ITSO_T
        FROM TVAGT
       WHERE SPRAS = SY-LANGU
         AND ABGRU = G_ITSO_T-ABGRU.

    ENDIF.

**  제품계층구조 1 LEVEL
    G_ITSO_T-PRODH = G_ITSO_T-PRODH+0(5).

**  조장수/개별길이/색상/입회검사유무
    PERFORM  QUERY_CHAR_VALUE_RTN_OLD.

**  납품 데이타 SELECT
    PERFORM DN_SELECT_RTN.

**  진행율표시
    ADD  1   TO  G_CNT.
    G_RATIO = G_CNT * 100 / G_TOTCNT.
    PERFORM  PROGRESS_INDICATOR.


  ENDLOOP.

** 납품일정라인에 따른 Gethering
  DELETE G_ITAB_T WHERE ETENR NE '0001'.

ENDFORM.                    " GET_VBELN_OLD
*&---------------------------------------------------------------------*
*&      Form  EX_SELECT_RTN
*&---------------------------------------------------------------------*
*       수출선적
*----------------------------------------------------------------------*
FORM EX_SELECT_RTN.

  SELECT  SINGLE MAX( VBELN )  AS  TKNUM           "수출선적번호
    INTO  CORRESPONDING FIELDS OF G_ITDL_T
    FROM  VBFA
   WHERE  VBELV      =   G_ITDL_T-VBELN_VL
     AND  POSNV      =   '000000'
     AND  VBTYP_N    =   '8'.

ENDFORM.                    " EX_SELECT_RTN

*&---------------------------------------------------------------------*
*&      Form  DN_SELECT_RTN
*&---------------------------------------------------------------------*
*       DELIVERY데이타 SELECT
*----------------------------------------------------------------------*
FORM DN_SELECT_RTN.

  CLEAR   G_ITDL_T.
  REFRESH G_ITDL_T.

  DATA : BEGIN OF L_BATCH_T OCCURS 0,
           VBELN LIKE LIPS-VBELN,             " 납품문서
           POSNR LIKE LIPS-POSNR,             " 품목번호
           RFMNG LIKE VBFA-RFMNG,             " 피킹수량
         END OF L_BATCH_T.

  DATA : BEGIN OF L_TEMP_T OCCURS 0,
           VBELN LIKE LIPS-VBELN,             " 납품문서
           POSNR LIKE LIPS-POSNR,             " 품목번호
           RFMNG LIKE VBFA-RFMNG,             " 피킹수량
           PLMIN LIKE VBFA-PLMIN,             "
         END OF L_TEMP_T.

  DATA : L_RFSUM LIKE VBFA-RFMNG,           " 피킹수량 합계
         L_RFMNG LIKE VBFA-RFMNG.           " 피킹수량

*  if g_itso_t-auart = 'ZRE'  or g_itso_t-auart = 'ZREQ' or
*     g_itso_t-auart = 'ZKR'  or g_itso_t-auart = 'ZKR1' or
*     g_itso_t-auart = 'ZKR2' or g_itso_t-auart = 'ZEKR'.
  IF  G_ITSO_T-AUART = 'RE'  OR  G_ITSO_T-AUART = 'ZREQ'.

    SELECT   VBELN    AS  VBELN_VL       "반품납품번호
             POSNN    AS  POSNR_VL       "반품납품품목
             APPENDING CORRESPONDING FIELDS OF TABLE G_ITDL_T
       FROM  VBFA
      WHERE  VBELV      =   G_ITSO_T-VBELN
        AND  POSNV      =   G_ITSO_T-POSNR
        AND  VBTYP_N    =   'T'
        AND  POSNN   LIKE  '0%'.

  ELSE.

    SELECT  VBELN     AS  VBELN_VL       "납품번호
            POSNN     AS  POSNR_VL       "납품품목
            APPENDING  CORRESPONDING FIELDS OF TABLE G_ITDL_T
      FROM  VBFA
     WHERE  VBELV      =   G_ITSO_T-VBELN
       AND  POSNV      =   G_ITSO_T-POSNR
       AND  VBTYP_N    =   'J'
       AND  POSNN   LIKE  '0%'
       AND  BWART      =   '601'.

    IF  SY-SUBRC <> 0.

      SELECT  VBELN     AS  VBELN_VL     "납품번호
              POSNN     AS  POSNR_VL     "납품품목
              APPENDING CORRESPONDING FIELDS OF TABLE G_ITDL_T
        FROM  VBFA
       WHERE  VBELV      =   G_ITSO_T-VBELN
         AND  POSNV      =   G_ITSO_T-POSNR
         AND  VBTYP_N    =   'J'
         AND  POSNN   LIKE  '0%'.

    ENDIF.

  ENDIF.

  IF  SY-SUBRC = 0.

    LOOP AT G_ITDL_T.

      SELECT  SINGLE  LIKP~WADAT_IST            "출고전기일
                      LIPS~LFIMG                "납품수량
                      LIKP~KODAT                "납품생성일
                      LIKP~LDDAT                "적하일
                      LIKP~LFDAT                "납품도착일
                      LIKP~LFUHR                "납품도착시간
                      LIKP~WADAT                "계획G.I
                      LIPS~LGORT                "저장위치
                      LIKP~ERZET    AS ERZET2   "납품생성시간
                      LIKP~ROUTE                "운송경로
                      LIKP~LFART                "납품유형
                      LIKP~BTGEW                "납품중량
                      LIKP~KOSTK                "피킹상태
                      LIKP~WBSTK                "출고전기상태
        INTO  CORRESPONDING FIELDS OF G_ITDL_T
        FROM  LIPS  INNER  JOIN  LIKP  ON LIPS~VBELN  =  LIKP~VBELN
       WHERE  LIPS~VBELN   =   G_ITDL_T-VBELN_VL
         AND  LIPS~POSNR   =   G_ITDL_T-POSNR_VL.

      IF G_ITDL_T-LFIMG = 0.

        SELECT SUM( LFIMG ) AS LFIMG
          INTO  CORRESPONDING FIELDS OF G_ITDL_T
          FROM  LIPS
         WHERE  VBELN      =   G_ITDL_T-VBELN_VL
           AND  UECHA      =   G_ITDL_T-POSNR_VL.

      ENDIF.

      SELECT SINGLE SUM( RFMNG ) AS RFMNG        "피킹수량
        INTO CORRESPONDING FIELDS OF G_ITDL_T
        FROM VBFA
       WHERE VBELV   = G_ITDL_T-VBELN_VL
         AND POSNV   = G_ITDL_T-POSNR_VL
         AND VBTYP_N = 'Q'.

      IF G_ITDL_T-RFMNG = 0.

        CLEAR : L_BATCH_T.
        FREE  : L_BATCH_T.
        CLEAR : L_RFSUM, L_RFMNG.

        SELECT  VBELN POSNR
          APPENDING  CORRESPONDING FIELDS OF TABLE L_BATCH_T
          FROM  LIPS
         WHERE  VBELN      =   G_ITDL_T-VBELN_VL
           AND  UECHA      =   G_ITDL_T-POSNR_VL.

        LOOP AT L_BATCH_T.

          SELECT SINGLE RFMNG
            INTO L_RFMNG
            FROM VBFA
           WHERE VBELV   = L_BATCH_T-VBELN
             AND POSNV   = L_BATCH_T-POSNR
             AND VBTYP_N = 'Q'.

          L_RFSUM = L_RFSUM + L_RFMNG.

        ENDLOOP.

        G_ITDL_T-RFMNG = L_RFSUM.

      ELSE.

        IF G_ITDL_T-RFMNG <> G_ITDL_T-LFIMG.

          SELECT RFMNG PLMIN
            APPENDING CORRESPONDING FIELDS OF TABLE L_TEMP_T
            FROM VBFA
           WHERE VBELV   = G_ITDL_T-VBELN_VL
             AND POSNV   = G_ITDL_T-POSNR_VL
             AND VBTYP_N = 'Q'.

          LOOP AT L_TEMP_T.

            IF L_TEMP_T-PLMIN = '-'.
              L_RFSUM = L_RFSUM - L_TEMP_T-RFMNG.
            ELSE.
              L_RFSUM = L_RFSUM + L_TEMP_T-RFMNG.
            ENDIF.

          ENDLOOP.

          G_ITDL_T-RFMNG = L_RFSUM.

        ENDIF.

      ENDIF.

**    출고전기번호
      PERFORM GI_SELECT_RTN.

**    BILLING 번호
      PERFORM BL_SELECT_RTN.

**    선적번호(LG Cable은 오더유형과는 무관함)
*      if g_itso_t-auart = 'ZOR' or g_itso_t-auart = 'ZKB' or
*         g_itso_t-auart = 'ZRE' or g_itso_t-auart = 'ZFD' or
*         g_itso_t-auart = 'ZFDC' or g_itso_t-auart = 'ZI01' or
*         g_itso_t-auart = 'ZI03' or g_itso_t-auart = 'ZI04' or
*         g_itso_t-auart = 'ZMM'.
      PERFORM SH_SELECT_RTN.
*      endif.

**    수출선적
      IF G_ITSO_T-VTWEG = '50'.
        PERFORM EX_SELECT_RTN.
      ENDIF.

      MOVE-CORRESPONDING G_ITSO_T TO G_ITAB_T.
      MOVE-CORRESPONDING G_ITDL_T TO G_ITAB_T.

      APPEND G_ITAB_T.
      CLEAR  G_ITAB_T.

    ENDLOOP.

  ELSE.

    MOVE-CORRESPONDING G_ITSO_T TO G_ITAB_T.

    IF  G_ITSO_T-AUART  =  'CR'  OR
        G_ITSO_T-AUART  =  'ZCR'.

      SELECT  SINGLE MAX( VBELN )  AS VBELN_VF   "빌링번호
        INTO  G_ITAB_T-VBELN_VF
        FROM  VBFA
       WHERE  VBELV      =   G_ITSO_T-VBELN
         AND  POSNV      =   G_ITSO_T-POSNR
         AND  VBTYP_N    =   'O'.

    ELSEIF  G_ITSO_T-AUART  =  'DR'  OR
            G_ITSO_T-AUART  =  'ZDR'.

      SELECT  SINGLE MAX( VBELN )  AS VBELN_VF   "빌링번호
        INTO  G_ITAB_T-VBELN_VF
        FROM  VBFA
       WHERE  VBELV      =   G_ITSO_T-VBELN
         AND  POSNV      =   G_ITSO_T-POSNR
         AND  VBTYP_N    =   'P'.

    ELSE.

      SELECT  SINGLE MAX( VBELN )  AS VBELN_VF   "빌링번호
        INTO  G_ITAB_T-VBELN_VF
        FROM  VBFA
       WHERE  VBELV      =   G_ITSO_T-VBELN
         AND  POSNV      =   G_ITSO_T-POSNR
         AND  VBTYP_N    =   'M'.

    ENDIF.

    SELECT  SINGLE FKDAT
      INTO  G_ITAB_T-FKDAT
      FROM  VBRK
     WHERE  VBELN  =  G_ITAB_T-VBELN_VF.


    APPEND G_ITAB_T.
    CLEAR  G_ITAB_T.

  ENDIF.

ENDFORM.                    " DN_SELECT_RTN
*&---------------------------------------------------------------------*
*&      Form  condition_query1
*&---------------------------------------------------------------------*
* Condition Check
*----------------------------------------------------------------------*
FORM CONDITION_QUERY1.

  LOOP AT G_ITAB_T.

    SELECT  SINGLE *
      FROM  LIKP
     WHERE  VBELN  EQ  G_ITAB_T-VBELN_VL
       AND  KODAT  IN  SO_KODAT.

    IF  SY-SUBRC  <>  0.
      DELETE  G_ITAB_T.
    ENDIF.

  ENDLOOP.

ENDFORM.                    " condition_query1

*&---------------------------------------------------------------------*
*&      Form  condition_query2
*&---------------------------------------------------------------------*
* Condition Check
*----------------------------------------------------------------------*
FORM CONDITION_QUERY2.

  LOOP AT G_ITAB_T.

    SELECT  SINGLE *
      FROM  LIKP
     WHERE  VBELN  EQ  G_ITAB_T-VBELN_VL
       AND  LDDAT  IN  SO_LDDAT.

    IF  SY-SUBRC  <>  0.
      DELETE  G_ITAB_T.
    ENDIF.

  ENDLOOP.

ENDFORM.                    " condition_query2

*&---------------------------------------------------------------------*
*&      Form  SCREEN_MODIFY
*&---------------------------------------------------------------------*
FORM SCREEN_MODIFY.

*  LOOP AT SCREEN.
*
*    IF  SCREEN-GROUP1 = 'A'.
*        SCREEN-INPUT = 0.
*        SCREEN-INTENSIFIED = 1.
*    ENDIF.
*
*    MODIFY SCREEN.
*
*  ENDLOOP.

ENDFORM.                    " SCREEN_MODIFY

*&---------------------------------------------------------------------*
*&      Form  GET_ERDAT
*&---------------------------------------------------------------------*
*       선적생성일 가져오기
*----------------------------------------------------------------------*
FORM GET_ERDAT.

  LOOP AT G_ITAB_T.

    SELECT SINGLE
           ERDAT              "선적생성일
           SIGNI              "차량번호
           TPLST              "운송계획지점
           ERZET              "선적생성시간
           UZDIS              "계획시간
           UAREG              "체크인시간
           DPTEN              "선적종료계획
           UPTEN              "선적종료계획시간
      INTO (G_ITAB_T-ERDAT2,
            G_ITAB_T-SIGNI,
            G_ITAB_T-TPLST,
            G_ITAB_T-ERZET3,
            G_ITAB_T-UZDIS,
            G_ITAB_T-UAREG,
            G_ITAB_T-DPTEN,
            G_ITAB_T-UPTEN)
      FROM VTTK
     WHERE TKNUM = G_ITAB_T-TKNUM.

    IF SY-SUBRC = 0.
      MODIFY G_ITAB_T.
    ENDIF.

  ENDLOOP.

ENDFORM.                    " GET_ERDAT

*&---------------------------------------------------------------------*
*&      Form  GET_DIFF_DATE
*&---------------------------------------------------------------------*
*      오더확정차이일 가져오기
*----------------------------------------------------------------------*
FORM GET_DIFF_DATE.

  LOOP AT G_ITAB_T.

*   오더확정차이일 = 주문도착일, 확정일 - 생성일
    G_ITAB_T-DIFF_DATE = G_ITAB_T-EDATU - G_ITAB_T-ERDAT.

    IF G_ITAB_T-DIFF_DATE < 0.
      G_ITAB_T-DIFF_DATE = 0.
    ENDIF.

    MODIFY G_ITAB_T.

  ENDLOOP.

ENDFORM.                    " GET_DIFF_DATE

*&---------------------------------------------------------------------*
*&      Form  GET_KUNNR_SB
*&---------------------------------------------------------------------*
*       특별재고파트너 가져오기
*----------------------------------------------------------------------*
FORM GET_KUNNR_SB.

  LOOP AT G_ITAB_T.

    SELECT SINGLE KUNNR
      INTO G_ITAB_T-KUNNR_SB
      FROM VBPA
     WHERE VBELN = G_ITAB_T-VBELN
       AND POSNR = G_ITAB_T-POSNR
       AND PARVW = 'SB'.

    IF SY-SUBRC <> 0.

      SELECT SINGLE KUNNR
        INTO G_ITAB_T-KUNNR_SB
        FROM VBPA
       WHERE VBELN = G_ITAB_T-VBELN
         AND POSNR = '0'
         AND PARVW = 'SB'.

    ENDIF.

    MODIFY G_ITAB_T.

  ENDLOOP.

ENDFORM.                    " GET_KUNNR_SB

*&---------------------------------------------------------------------*
*&      Form  GET_BEZEI2
*&---------------------------------------------------------------------*
*       오더사유TEXT 가져오기
*----------------------------------------------------------------------*
FORM GET_BEZEI2.

  LOOP AT G_ITAB_T.

    SELECT SINGLE BEZEI
      INTO G_ITAB_T-BEZEI2
      FROM TVAUT
     WHERE SPRAS = '3'
       AND AUGRU = G_ITAB_T-AUGRU.

    IF SY-SUBRC = 0.
      MODIFY G_ITAB_T.
    ENDIF.

  ENDLOOP.

ENDFORM.                    " GET_BEZEI2

*&---------------------------------------------------------------------*
*&      Form  GET_TABLE_AFPO
*&---------------------------------------------------------------------*
* 생산계획일, 입고일 가져오기
*----------------------------------------------------------------------*
FORM GET_TABLE_AFPO.
  DATA: BEGIN OF LT_AFPO OCCURS 0,
          KDAUF LIKE AFPO-KDAUF,
          KDPOS LIKE AFPO-KDPOS,
          AUFNR LIKE AFPO-AUFNR,
          POSNR LIKE AFPO-POSNR,
          LTRMP LIKE AFPO-LTRMP,
          LTRMI LIKE AFPO-LTRMI,
        END   OF LT_AFPO.

  CHECK G_ITAB_T[] IS NOT INITIAL.

  SELECT *
    INTO CORRESPONDING FIELDS OF TABLE LT_AFPO
    FROM AFPO
     FOR ALL ENTRIES IN G_ITAB_T
   WHERE KDAUF = G_ITAB_T-VBELN
     AND KDPOS = G_ITAB_T-POSNR.

  SORT LT_AFPO BY KDAUF KDPOS AUFNR POSNR.

  LOOP AT G_ITAB_T.
    READ TABLE LT_AFPO WITH KEY KDAUF = G_ITAB_T-VBELN
                                KDPOS = G_ITAB_T-POSNR
                                BINARY SEARCH.
    IF SY-SUBRC = 0.
      G_ITAB_T-LTRMP = LT_AFPO-LTRMP.   "생산계획일
      G_ITAB_T-LTRMI = LT_AFPO-LTRMI.   "입고일

      MODIFY G_ITAB_T.
    ENDIF.
  ENDLOOP.

ENDFORM.                    " GET_TABLE_AFPO

*&---------------------------------------------------------------------*
*&      Form  GET_BSTKD
*&---------------------------------------------------------------------*
*       FILE번호 가져오기
*----------------------------------------------------------------------*
FORM GET_BSTKD.

  LOOP AT G_ITAB_T.
*-{기능개선175813 - 수정
*-{기능개선 314340 -수정 : ZTERM 추가
    SELECT SINGLE BSTKD EMPST BSTKD_E ZTERM    "FILE번호
* CSR Number : C20081226_77528 드럼 번호 필드 추가
      INTO (G_ITAB_T-BSTKD,   G_ITAB_T-EMPST,
            G_ITAB_T-BSTKD_E, G_ITAB_T-ZTERM)
*-}기능개선 314340
* CSR Number : C20081226_77528
      FROM VBKD
     WHERE VBELN = G_ITAB_T-VBELN
       AND POSNR = G_ITAB_T-POSNR.
*-}기능개선175813_2016.12.29


    IF  SY-SUBRC  NE  0.

      SELECT SINGLE BSTKD ZTERM             "FILE번호
        INTO (G_ITAB_T-BSTKD, G_ITAB_T-ZTERM)
        FROM VBKD
       WHERE VBELN = G_ITAB_T-VBELN
         AND POSNR = '0'.

      IF  SY-SUBRC  NE  0.
        G_ITAB_T-BSTKD  =  SPACE.
      ENDIF.

    ENDIF.

**-{기능개선 314340
**  지급조건명
    SELECT  SINGLE  TEXT1
      INTO  G_ITAB_T-TEXT1
      FROM  T052U
     WHERE  ZTERM = G_ITAB_T-ZTERM.

**  손익센터
    SELECT  SINGLE  PRCTR
      INTO  G_ITAB_T-PRCTR
      FROM  VBAP
     WHERE  VBELN = G_ITAB_T-VBELN
       AND  POSNR = G_ITAB_T-POSNR.

**  고객 국가
    SELECT  SINGLE  LAND1
      INTO  G_ITAB_T-LAND1
      FROM  KNA1
     WHERE  KUNNR = G_ITSO_T-KUNNR.
**-} 기능개선 314340

**  PO번호 검색조건 처리
    IF PA_BSTKD <> SPACE.

      IF  G_ITAB_T-BSTKD <> PA_BSTKD.

        DELETE G_ITAB_T.
        CLEAR  G_ITAB_T.

        CONTINUE.

      ENDIF.

    ENDIF.


    MODIFY G_ITAB_T.

  ENDLOOP.

ENDFORM.                    " GET_BSTKD

*&---------------------------------------------------------------------*
*&      Form  GET_KOSTK
*&---------------------------------------------------------------------*
*       피킹관련성, 피킹설명 가져오기
*----------------------------------------------------------------------*
FORM GET_KOSTK.

  LOOP AT G_ITAB_T.
*-> CCM : 12.04.2023 08:36:55 ZLSGSD5 - VBUK 필드 변경
    SELECT SINGLE
           D~KOSTK             "피킹관련성
           A~WBSTK             "전체상품이동상태
      INTO (G_ITAB_T-KOSTK,
            G_ITAB_T-WBSTK)
      FROM VBAK AS A
      INNER JOIN VBAP AS B ON
      A~VBELN = B~VBELN
      INNER JOIN LIPS AS C ON
      B~VBELN = C~VGBEL AND
      B~POSNR = C~VGPOS
      INNER JOIN LIKP AS D ON
      C~VBELN = D~VBELN
     WHERE A~VBELN = G_ITAB_T-VBELN.
*<-
    IF  G_ITAB_T-KOSTK = ' '.
      G_ITAB_T-KOSTK_TEXT = '관련없음'.
    ELSEIF G_ITAB_T-KOSTK = 'A'.
      G_ITAB_T-KOSTK_TEXT = '미처리'.
    ELSEIF G_ITAB_T-KOSTK = 'B'.
      G_ITAB_T-KOSTK_TEXT = '부분적으로 처리했음'.
    ELSEIF G_ITAB_T-KOSTK = 'C'.
      G_ITAB_T-KOSTK_TEXT = '완전처리'.
    ENDIF.

    MODIFY G_ITAB_T.

  ENDLOOP.

ENDFORM.                    " GET_KOSTK

*&---------------------------------------------------------------------*
*&      Form  GET_TKNUM2
*&---------------------------------------------------------------------*
*       준비구간선적번호 가져오기
*----------------------------------------------------------------------*
FORM GET_TKNUM2.

  LOOP AT G_ITAB_T.

    SELECT SINGLE
           B~TKNUM
           B~TPNUM
      INTO (G_ITAB_T-TKNUM2,
            G_ITAB_T-TPNUM2)
      FROM VTTK AS A INNER JOIN VTTP AS B ON A~TKNUM = B~TKNUM
     WHERE B~VBELN =  G_ITAB_T-VBELN_VL
       AND A~SHTYP = 'Z400'.

    IF SY-SUBRC = 0.
      MODIFY G_ITAB_T.
    ENDIF.

  ENDLOOP.

ENDFORM.                    " GET_TKNUM2

*&---------------------------------------------------------------------*
*&      Form  GET_FKNUM
*&---------------------------------------------------------------------*
*       선적비용번호 가져오기
*----------------------------------------------------------------------*
FORM GET_FKNUM.

  LOOP AT G_ITAB_T.

    SELECT SINGLE FKNUM
      INTO G_ITAB_T-FKNUM
      FROM VFKP
     WHERE REBEL = G_ITAB_T-TKNUM2
       AND REPOS = G_ITAB_T-TPNUM2.

    IF SY-SUBRC = 0.
      MODIFY G_ITAB_T.
    ENDIF.

  ENDLOOP.

ENDFORM.                    " GET_FKNUM

*&---------------------------------------------------------------------*
*&      Form  DELETE_ERDAT
*&---------------------------------------------------------------------*
*       조회조건(SELECT-OPTIONS)의 선적생성일이 아니면 DELETE
*----------------------------------------------------------------------*
FORM DELETE_ERDAT.

  CLEAR : G_TMP_T, G_TMP_T[].

  LOOP AT G_ITAB_T.
    MOVE-CORRESPONDING  G_ITAB_T  TO  G_TMP_T.
    APPEND  G_TMP_T.
    CLEAR  G_TMP_T.
  ENDLOOP.

  CLEAR : G_ITAB_T, G_ITAB_T[].

  LOOP AT SO_ERDA2.

    IF  SO_ERDA2-HIGH = '00000000'.

      LOOP AT G_TMP_T WHERE ERDAT2 = SO_ERDA2-LOW.

        MOVE-CORRESPONDING  G_TMP_T  TO  G_ITAB_T.
        APPEND  G_ITAB_T.
        CLEAR  G_ITAB_T.

      ENDLOOP.

    ELSE.

      LOOP AT G_TMP_T WHERE ERDAT2 >= SO_ERDA2-LOW
                        AND ERDAT2 <= SO_ERDA2-HIGH.

        MOVE-CORRESPONDING  G_TMP_T  TO  G_ITAB_T.
        APPEND  G_ITAB_T.
        CLEAR  G_ITAB_T.

      ENDLOOP.

    ENDIF.

  ENDLOOP.

*  loop at g_itab_t.
*
*    loop at so_erda2.
*
*      if so_erda2-high = '00000000'.
*
*        if g_itab_t-erdat2 = so_erda2-low.
*        else.
*          delete g_itab_t.
*        endif.
*
*      else.
*
*        if g_itab_t-erdat2 >= so_erda2-low and
*           g_itab_t-erdat2 <= so_erda2-high.
*        else.
*          delete g_itab_t.
*        endif.
*
*      endif.
*
*    endloop.
*
*  endloop.

ENDFORM.                    " DELETE_ERDAT

*&---------------------------------------------------------------------*
*&      Form  DELETE_WADAT_IST
*&---------------------------------------------------------------------*
* 조회조건(SELECT-OPTIONS)의 실제자재이동일(출고전기일)이 아니면 DELETE
*----------------------------------------------------------------------*
FORM DELETE_WADAT_IST.

  CLEAR : G_TMP_T, G_TMP_T[].

  LOOP AT G_ITAB_T.
    MOVE-CORRESPONDING  G_ITAB_T  TO  G_TMP_T.
    APPEND  G_TMP_T.
    CLEAR  G_TMP_T.
  ENDLOOP.

  CLEAR : G_ITAB_T, G_ITAB_T[].

  LOOP AT SO_W_IST.

    IF  SO_W_IST-HIGH = '00000000'.

      LOOP AT G_TMP_T WHERE WADAT_IST = SO_W_IST-LOW.

        MOVE-CORRESPONDING  G_TMP_T  TO  G_ITAB_T.
        APPEND  G_ITAB_T.
        CLEAR  G_ITAB_T.

      ENDLOOP.

    ELSE.

      LOOP AT G_TMP_T WHERE WADAT_IST >= SO_W_IST-LOW
                        AND WADAT_IST <= SO_W_IST-HIGH.

        MOVE-CORRESPONDING  G_TMP_T  TO  G_ITAB_T.
        APPEND  G_ITAB_T.
        CLEAR  G_ITAB_T.

      ENDLOOP.

    ENDIF.

  ENDLOOP.

*  loop at g_itab_t.
*
*    loop at so_w_ist.
*
*      if so_w_ist-high = '00000000'.
*
*        if g_itab_t-wadat_ist = so_w_ist-low.
*        else.
*          delete g_itab_t.
*        endif.
*
*      else.
*
*        if g_itab_t-wadat_ist >= so_w_ist-low and
*           g_itab_t-wadat_ist <= so_w_ist-high.
*        else.
*          delete g_itab_t.
*        endif.
*
*      endif.
*
*    endloop.
*
*  endloop.

ENDFORM.                    " DELETE_WADAT_IST

*&---------------------------------------------------------------------*
*&      Form  DELETE_WADAT
*&---------------------------------------------------------------------*
* 조회조건(SELECT-OPTIONS)의 계획자재이동일(계획G.I)이 아니면 DELETE
*----------------------------------------------------------------------*
FORM DELETE_WADAT.

  CLEAR : G_TMP_T, G_TMP_T[].

  LOOP AT G_ITAB_T.
    MOVE-CORRESPONDING  G_ITAB_T  TO  G_TMP_T.
    APPEND  G_TMP_T.
    CLEAR  G_TMP_T.
  ENDLOOP.

  CLEAR : G_ITAB_T, G_ITAB_T[].

  LOOP AT SO_WADAT.

    IF  SO_WADAT-HIGH = '00000000'.

      LOOP AT G_TMP_T WHERE WADAT = SO_WADAT-LOW.

        MOVE-CORRESPONDING  G_TMP_T  TO  G_ITAB_T.
        APPEND  G_ITAB_T.
        CLEAR  G_ITAB_T.

      ENDLOOP.

    ELSE.

      LOOP AT G_TMP_T WHERE WADAT >= SO_WADAT-LOW
                        AND WADAT <= SO_WADAT-HIGH.

        MOVE-CORRESPONDING  G_TMP_T  TO  G_ITAB_T.
        APPEND  G_ITAB_T.
        CLEAR  G_ITAB_T.

      ENDLOOP.

    ENDIF.

  ENDLOOP.

*  loop at g_itab_t.
*
*    loop at so_wadat.
*
*      if so_wadat-high = '00000000'.
*
*        if g_itab_t-wadat = so_wadat-low.
*        else.
*          delete g_itab_t.
*        endif.
*
*      else.
*
*        if g_itab_t-wadat >= so_wadat-low and
*           g_itab_t-wadat <= so_wadat-high.
*        else.
*          delete g_itab_t.
*        endif.
*
*      endif.
*
*    endloop.
*
*  endloop.

ENDFORM.                    " DELETE_WADAT

*&---------------------------------------------------------------------*
*&      Form  DELETE_TKNUM
*&---------------------------------------------------------------------*
*       조회조건(SELECT-OPTIONS)의 선적번호가 아니면 DELETE
*----------------------------------------------------------------------*
FORM DELETE_TKNUM.

  CLEAR : G_TMP_T, G_TMP_T[].

  LOOP AT G_ITAB_T.
    MOVE-CORRESPONDING  G_ITAB_T  TO  G_TMP_T.
    APPEND  G_TMP_T.
    CLEAR  G_TMP_T.
  ENDLOOP.

  CLEAR : G_ITAB_T, G_ITAB_T[].

  LOOP AT SO_TKNUM.

    IF  SO_TKNUM-HIGH = ' '.

      LOOP AT G_TMP_T WHERE TKNUM = SO_TKNUM-LOW.

        MOVE-CORRESPONDING  G_TMP_T  TO  G_ITAB_T.
        APPEND  G_ITAB_T.
        CLEAR  G_ITAB_T.

      ENDLOOP.

    ELSE.

      LOOP AT G_TMP_T WHERE TKNUM >= SO_TKNUM-LOW
                        AND TKNUM <= SO_TKNUM-HIGH.

        MOVE-CORRESPONDING  G_TMP_T  TO  G_ITAB_T.
        APPEND  G_ITAB_T.
        CLEAR  G_ITAB_T.

      ENDLOOP.

    ENDIF.

  ENDLOOP.

*  loop at g_itab_t.
*
*    loop at so_tknum.
*
*      if so_tknum-high = ' '.
*
*        if g_itab_t-tknum = so_tknum-low.
*        else.
*          delete g_itab_t.
*        endif.
*
*      else.
*
*        if g_itab_t-tknum >= so_tknum-low and
*           g_itab_t-tknum <= so_tknum-high.
*        else.
*          delete g_itab_t.
*        endif.
*
*      endif.
*
*    endloop.
*
*  endloop.

ENDFORM.                    " DELETE_TKNUM

*&---------------------------------------------------------------------*
*&      Form  DELETE_VBELN_VL
*&---------------------------------------------------------------------*
*       조회조건(SELECT-OPTIONS)의 납품번호가 아니면 DELETE
*----------------------------------------------------------------------*
FORM DELETE_VBELN_VL.

  CLEAR : G_TMP_T, G_TMP_T[].

  LOOP AT G_ITAB_T.
    MOVE-CORRESPONDING  G_ITAB_T  TO  G_TMP_T.
    APPEND  G_TMP_T.
    CLEAR  G_TMP_T.
  ENDLOOP.

  CLEAR : G_ITAB_T, G_ITAB_T[].

  LOOP AT SO_VBEL2.

    IF  SO_VBEL2-HIGH = ' '.

      LOOP AT G_TMP_T WHERE VBELN_VL = SO_VBEL2-LOW.

        MOVE-CORRESPONDING  G_TMP_T  TO  G_ITAB_T.
        APPEND  G_ITAB_T.
        CLEAR  G_ITAB_T.

      ENDLOOP.

    ELSE.

      LOOP AT G_TMP_T WHERE VBELN_VL >= SO_VBEL2-LOW
                        AND VBELN_VL <= SO_VBEL2-HIGH.

        MOVE-CORRESPONDING  G_TMP_T  TO  G_ITAB_T.
        APPEND  G_ITAB_T.
        CLEAR  G_ITAB_T.

      ENDLOOP.

    ENDIF.

  ENDLOOP.

*  loop at g_itab_t.
*
*    loop at so_vbel2.
*
*      if so_vbel2-high = ' '.
*
*        if g_itab_t-vbeln_vl = so_vbel2-low.
*        else.
*          delete g_itab_t.
*        endif.
*
*      else.
*
*        if g_itab_t-vbeln_vl >= so_vbel2-low and
*           g_itab_t-vbeln_vl <= so_vbel2-high.
*        else.
*          delete g_itab_t.
*        endif.
*
*      endif.
*
*    endloop.
*
*  endloop.

ENDFORM.                    " DELETE_VBELN_VL

*&---------------------------------------------------------------------*
*&      Form  DELETE_SIGNI
*&---------------------------------------------------------------------*
*       조회조건(SELECT-OPTIONS)의 차량번호가 아니면 DELETE
*----------------------------------------------------------------------*
FORM DELETE_SIGNI.

  CLEAR : G_TMP_T, G_TMP_T[].

  LOOP AT G_ITAB_T.
    MOVE-CORRESPONDING  G_ITAB_T  TO  G_TMP_T.
    APPEND  G_TMP_T.
    CLEAR  G_TMP_T.
  ENDLOOP.

  CLEAR : G_ITAB_T, G_ITAB_T[].

  LOOP AT SO_SIGNI.

    IF  SO_SIGNI-HIGH = ' '.

      LOOP AT G_TMP_T WHERE SIGNI = SO_SIGNI-LOW.

        MOVE-CORRESPONDING  G_TMP_T  TO  G_ITAB_T.
        APPEND  G_ITAB_T.
        CLEAR  G_ITAB_T.

      ENDLOOP.

    ELSE.

      LOOP AT G_TMP_T WHERE SIGNI >= SO_SIGNI-LOW
                        AND SIGNI <= SO_SIGNI-HIGH.

        MOVE-CORRESPONDING  G_TMP_T  TO  G_ITAB_T.
        APPEND  G_ITAB_T.
        CLEAR  G_ITAB_T.

      ENDLOOP.

    ENDIF.

  ENDLOOP.

*  loop at g_itab_t.
*
*    loop at so_signi.
*
*      if so_signi-high = ' '.
*
*        if g_itab_t-signi = so_signi-low.
*        else.
*          delete g_itab_t.
*        endif.
*
*      else.
*
*        if g_itab_t-signi >= so_signi-low and
*           g_itab_t-signi <= so_signi-high.
*        else.
*          delete g_itab_t.
*        endif.
*
*      endif.
*
*    endloop.
*
*  endloop.

ENDFORM.                    " DELETE_SIGNI

*&---------------------------------------------------------------------*
*&      Form  DELETE_KUNNR_SB
*&---------------------------------------------------------------------*
*       조회조건(SELECT-OPTIONS)의 특별재고파트너가 아니면 DELETE
*----------------------------------------------------------------------*
FORM DELETE_KUNNR_SB.

  CLEAR : G_TMP_T, G_TMP_T[].

  LOOP AT G_ITAB_T.
    MOVE-CORRESPONDING  G_ITAB_T  TO  G_TMP_T.
    APPEND  G_TMP_T.
    CLEAR  G_TMP_T.
  ENDLOOP.

  CLEAR : G_ITAB_T, G_ITAB_T[].

  LOOP AT SO_KUNN2.

    IF  SO_KUNN2-HIGH = ' '.

      LOOP AT G_TMP_T WHERE KUNNR_SB = SO_KUNN2-LOW.

        MOVE-CORRESPONDING  G_TMP_T  TO  G_ITAB_T.
        APPEND  G_ITAB_T.
        CLEAR  G_ITAB_T.

      ENDLOOP.

    ELSE.

      LOOP AT G_TMP_T WHERE KUNNR_SB >= SO_KUNN2-LOW
                        AND KUNNR_SB <= SO_KUNN2-HIGH.

        MOVE-CORRESPONDING  G_TMP_T  TO  G_ITAB_T.
        APPEND  G_ITAB_T.
        CLEAR  G_ITAB_T.

      ENDLOOP.

    ENDIF.

  ENDLOOP.

*  loop at g_itab_t.
*
*    loop at so_kunn2.
*
*      if so_kunn2-high = ' '.
*
*        if g_itab_t-kunnr_sb = so_kunn2-low.
*        else.
*          delete g_itab_t.
*        endif.
*
*      else.
*
*        if g_itab_t-kunnr_sb >= so_kunn2-low and
*           g_itab_t-kunnr_sb <= so_kunn2-high.
*        else.
*          delete g_itab_t.
*        endif.
*
*      endif.
*
*    endloop.
*
*  endloop.

ENDFORM.                    " DELETE_KUNNR_SB
*&---------------------------------------------------------------------*
*&      Form  DELETE_WBSTK
*&---------------------------------------------------------------------*
*       조회조건(SELECT-OPTIONS)의 전체상품이동상태가 아니면 DELETE
*----------------------------------------------------------------------*
FORM DELETE_WBSTK.

  CLEAR : G_TMP_T, G_TMP_T[].

  LOOP AT G_ITAB_T.
    MOVE-CORRESPONDING  G_ITAB_T  TO  G_TMP_T.
    APPEND  G_TMP_T.
    CLEAR  G_TMP_T.
  ENDLOOP.

  CLEAR : G_ITAB_T, G_ITAB_T[].

  LOOP AT SO_WBSTK.

    IF  SO_WBSTK-HIGH = ' '.

      LOOP AT G_TMP_T WHERE WBSTK = SO_WBSTK-LOW.

        MOVE-CORRESPONDING  G_TMP_T  TO  G_ITAB_T.
        APPEND  G_ITAB_T.
        CLEAR  G_ITAB_T.

      ENDLOOP.

    ELSE.

      LOOP AT G_TMP_T WHERE WBSTK >= SO_WBSTK-LOW
                        AND WBSTK <= SO_WBSTK-HIGH.

        MOVE-CORRESPONDING  G_TMP_T  TO  G_ITAB_T.
        APPEND  G_ITAB_T.
        CLEAR  G_ITAB_T.

      ENDLOOP.

    ENDIF.

  ENDLOOP.

*  loop at g_itab_t.
*
*    loop at so_wbstk.
*
*      if so_wbstk-high = ' '.
*
*        if g_itab_t-wbstk = so_wbstk-low.
*        else.
*          delete g_itab_t.
*        endif.
*
*      else.
*
*        if g_itab_t-wbstk >= so_wbstk-low and
*           g_itab_t-wbstk <= so_wbstk-high.
*        else.
*          delete g_itab_t.
*        endif.
*
*      endif.
*
*    endloop.
*
*  endloop.

ENDFORM.                    " DELETE_WBSTK

*&---------------------------------------------------------------------*
*&      Form  DELETE_ROUTE
*&---------------------------------------------------------------------*
*       조회조건(SELECT-OPTIONS)의 운송경로가 아니면 DELETE
*----------------------------------------------------------------------*
FORM DELETE_ROUTE.

  CLEAR : G_TMP_T, G_TMP_T[].

  LOOP AT G_ITAB_T.
    MOVE-CORRESPONDING  G_ITAB_T  TO  G_TMP_T.
    APPEND  G_TMP_T.
    CLEAR  G_TMP_T.
  ENDLOOP.

  CLEAR : G_ITAB_T, G_ITAB_T[].

  LOOP AT SO_ROUTE.

    IF  SO_ROUTE-HIGH = ' '.

      LOOP AT G_TMP_T WHERE ROUTE = SO_ROUTE-LOW.

        MOVE-CORRESPONDING  G_TMP_T  TO  G_ITAB_T.
        APPEND  G_ITAB_T.
        CLEAR  G_ITAB_T.

      ENDLOOP.

    ELSE.

      LOOP AT G_TMP_T WHERE ROUTE >= SO_ROUTE-LOW
                        AND ROUTE <= SO_ROUTE-HIGH.

        MOVE-CORRESPONDING  G_TMP_T  TO  G_ITAB_T.
        APPEND  G_ITAB_T.
        CLEAR  G_ITAB_T.

      ENDLOOP.

    ENDIF.

  ENDLOOP.

*  loop at g_itab_t.
*
*    loop at so_route.
*
*      if so_route-high = ' '.
*
*        if g_itab_t-route = so_route-low.
*        else.
*          delete g_itab_t.
*        endif.
*
*      else.
*
*        if g_itab_t-route >= so_route-low and
*           g_itab_t-route <= so_route-high.
*        else.
*          delete g_itab_t.
*        endif.
*
*      endif.
*
*    endloop.
*
*  endloop.

ENDFORM.                    " DELETE_ROUTE

*&---------------------------------------------------------------------*
*&      Form  DELETE_TPLST
*&---------------------------------------------------------------------*
*       조회조건(SELECT-OPTIONS)의 운송계획지점이 아니면 DELETE
*----------------------------------------------------------------------*
FORM DELETE_TPLST.

  CLEAR : G_TMP_T, G_TMP_T[].

  LOOP AT G_ITAB_T.
    MOVE-CORRESPONDING  G_ITAB_T  TO  G_TMP_T.
    APPEND  G_TMP_T.
    CLEAR  G_TMP_T.
  ENDLOOP.

  CLEAR : G_ITAB_T, G_ITAB_T[].

  LOOP AT SO_TPLST.

    IF  SO_TPLST-HIGH = ' '.

      LOOP AT G_TMP_T WHERE TPLST = SO_TPLST-LOW.

        MOVE-CORRESPONDING  G_TMP_T  TO  G_ITAB_T.
        APPEND  G_ITAB_T.
        CLEAR  G_ITAB_T.

      ENDLOOP.

    ELSE.

      LOOP AT G_TMP_T WHERE TPLST >= SO_TPLST-LOW
                        AND TPLST <= SO_TPLST-HIGH.

        MOVE-CORRESPONDING  G_TMP_T  TO  G_ITAB_T.
        APPEND  G_ITAB_T.
        CLEAR  G_ITAB_T.

      ENDLOOP.

    ENDIF.

  ENDLOOP.

*  loop at g_itab_t.
*
*    loop at so_tplst.
*
*      if so_tplst-high = ' '.
*
*        if g_itab_t-tplst = so_tplst-low.
*        else.
*          delete g_itab_t.
*        endif.
*
*      else.
*
*        if g_itab_t-tplst >= so_tplst-low and
*           g_itab_t-tplst <= so_tplst-high.
*        else.
*          delete g_itab_t.
*        endif.
*
*      endif.
*
*    endloop.
*
*  endloop.

ENDFORM.                    " DELETE_TPLST

*&---------------------------------------------------------------------*
*&      Form  DELETE_LFART
*&---------------------------------------------------------------------*
*       조회조건(SELECT-OPTIONS)의 납품유형이 아니면 DELETE
*----------------------------------------------------------------------*
FORM DELETE_LFART.

  CLEAR : G_TMP_T, G_TMP_T[].

  LOOP AT G_ITAB_T.
    MOVE-CORRESPONDING  G_ITAB_T  TO  G_TMP_T.
    APPEND  G_TMP_T.
    CLEAR  G_TMP_T.
  ENDLOOP.

  CLEAR : G_ITAB_T, G_ITAB_T[].

  LOOP AT SO_LFART.

    IF  SO_LFART-HIGH = ' '.

      LOOP AT G_TMP_T WHERE LFART = SO_LFART-LOW.

        MOVE-CORRESPONDING  G_TMP_T  TO  G_ITAB_T.
        APPEND  G_ITAB_T.
        CLEAR  G_ITAB_T.

      ENDLOOP.

    ELSE.

      LOOP AT G_TMP_T WHERE LFART >= SO_LFART-LOW
                        AND LFART <= SO_LFART-HIGH.

        MOVE-CORRESPONDING  G_TMP_T  TO  G_ITAB_T.
        APPEND  G_ITAB_T.
        CLEAR  G_ITAB_T.

      ENDLOOP.

    ENDIF.

  ENDLOOP.

*  loop at g_itab_t.
*
*    loop at so_lfart.
*
*      if so_lfart-high = ' '.
*
*        if g_itab_t-lfart = so_lfart-low.
*        else.
*          delete g_itab_t.
*        endif.
*
*      else.
*
*        if g_itab_t-lfart >= so_lfart-low and
*           g_itab_t-lfart <= so_lfart-high.
*        else.
*          delete g_itab_t.
*        endif.
*
*      endif.
*
*    endloop.
*
*  endloop.

ENDFORM.                    " DELETE_LFART

*&---------------------------------------------------------------------*
*&      Form  DELETE_LGORT
*&---------------------------------------------------------------------*
*       조회조건(SELECT-OPTIONS)의 저장위치이 아니면 DELETE
*----------------------------------------------------------------------*
FORM DELETE_LGORT.

  CLEAR : G_TMP_T, G_TMP_T[].

  LOOP AT G_ITAB_T.
    MOVE-CORRESPONDING  G_ITAB_T  TO  G_TMP_T.
    APPEND  G_TMP_T.
    CLEAR  G_TMP_T.
  ENDLOOP.

  CLEAR : G_ITAB_T, G_ITAB_T[].

  LOOP AT SO_LGORT.

    IF  SO_LGORT-HIGH = ' '.

      LOOP AT G_TMP_T WHERE LGORT = SO_LGORT-LOW.

        MOVE-CORRESPONDING  G_TMP_T  TO  G_ITAB_T.
        APPEND  G_ITAB_T.
        CLEAR  G_ITAB_T.

      ENDLOOP.

    ELSE.

      LOOP AT G_TMP_T WHERE LGORT >= SO_LGORT-LOW
                        AND LGORT <= SO_LGORT-HIGH.

        MOVE-CORRESPONDING  G_TMP_T  TO  G_ITAB_T.
        APPEND  G_ITAB_T.
        CLEAR  G_ITAB_T.

      ENDLOOP.

    ENDIF.

  ENDLOOP.

*  loop at g_itab_t.
*
*    loop at so_lgort.
*
*      if so_lgort-high = ' '.
*
*        if g_itab_t-lgort = so_lgort-low.
*        else.
*          delete g_itab_t.
*        endif.
*
*      else.
*
*        if g_itab_t-lgort >= so_lgort-low and
*           g_itab_t-lgort <= so_lgort-high.
*        else.
*          delete g_itab_t.
*        endif.
*
*      endif.
*
*    endloop.
*
*  endloop.

ENDFORM.                    " DELETE_LGORT

*&---------------------------------------------------------------------*
*&      Form  GET_CPUTM
*&---------------------------------------------------------------------*
*       G/I시간 가져오기
*----------------------------------------------------------------------*
FORM GET_CPUTM.

  LOOP AT G_ITAB_T WHERE VBELN_GI <> ' '.

    SELECT SINGLE CPUTM
      INTO G_ITAB_T-CPUTM
      FROM MKPF
     WHERE MBLNR = G_ITAB_T-VBELN_GI.

    IF SY-SUBRC = 0.
      MODIFY G_ITAB_T.
    ENDIF.

  ENDLOOP.

ENDFORM.                    " GET_CPUTM

*&---------------------------------------------------------------------*
*&      Form  GET_VKBUR_TEXT
*&---------------------------------------------------------------------*
*       사업장명 가져오기
*----------------------------------------------------------------------*
FORM GET_VKBUR_TEXT.

  LOOP AT G_ITAB_T.

    SELECT SINGLE BEZEI
      INTO G_ITAB_T-VKBUR_TEXT
      FROM TVKBT
     WHERE SPRAS = '3'
       AND VKBUR = G_ITAB_T-VKBUR.

    IF SY-SUBRC = 0.
      MODIFY G_ITAB_T.
    ENDIF.

  ENDLOOP.

ENDFORM.                    " GET_VKBUR_TEXT

*&---------------------------------------------------------------------*
*&      Form  GET_VKGRP_TEXT
*&---------------------------------------------------------------------*
*       영업그룹명 가져오기
*----------------------------------------------------------------------*
FORM GET_VKGRP_TEXT.

  LOOP AT G_ITAB_T.

    SELECT SINGLE BEZEI
      INTO G_ITAB_T-VKGRP_TEXT
      FROM TVGRT
     WHERE SPRAS = '3'
       AND VKGRP = G_ITAB_T-VKGRP.

    IF SY-SUBRC = 0.
      MODIFY G_ITAB_T.
    ENDIF.

  ENDLOOP.

ENDFORM.                    " GET_VKGRP_TEXT

*&---------------------------------------------------------------------*
*&      Form  GET_WERKS_TEXT
*&---------------------------------------------------------------------*
*       플랜트명 가져오기
*----------------------------------------------------------------------*
FORM GET_WERKS_TEXT.

  LOOP AT G_ITAB_T.

    SELECT SINGLE NAME1
      INTO G_ITAB_T-WERKS_TEXT
      FROM T001W
     WHERE SPRAS = '3'
       AND WERKS = G_ITAB_T-WERKS.

    IF SY-SUBRC = 0.
      MODIFY G_ITAB_T.
    ENDIF.

  ENDLOOP.

ENDFORM.                    " GET_WERKS_TEXT

*&---------------------------------------------------------------------*
*&      Form  GET_VSTEL_TEXT
*&---------------------------------------------------------------------*
*       출하지점명 가져오기
*----------------------------------------------------------------------*
FORM GET_VSTEL_TEXT.

  LOOP AT G_ITAB_T.

    SELECT SINGLE VTEXT
      INTO G_ITAB_T-VSTEL_TEXT
      FROM TVSTT
     WHERE SPRAS = '3'
       AND VSTEL = G_ITAB_T-VSTEL.

    IF SY-SUBRC = 0.
      MODIFY G_ITAB_T.
    ENDIF.

  ENDLOOP.

ENDFORM.                    " GET_VSTEL_TEXT

*&---------------------------------------------------------------------*
*&      Form  GET_ROUTE_TEXT
*&---------------------------------------------------------------------*
*       운송경로명 가져오기
*----------------------------------------------------------------------*
FORM GET_ROUTE_TEXT.

  LOOP AT G_ITAB_T.

    SELECT SINGLE BEZEI
      INTO G_ITAB_T-ROUTE_TEXT
      FROM TVROT
     WHERE SPRAS = '3'
       AND ROUTE = G_ITAB_T-ROUTE.

    IF SY-SUBRC = 0.
      MODIFY G_ITAB_T.
    ENDIF.

  ENDLOOP.

ENDFORM.                    " GET_ROUTE_TEXT

*&---------------------------------------------------------------------*
*&      Form  GET_KUNNR_SB_TEXT
*&---------------------------------------------------------------------*
*  특별재고파트너명 가져오기
*----------------------------------------------------------------------*
FORM GET_KUNNR_SB_TEXT.

  LOOP AT G_ITAB_T WHERE KUNNR_SB <> ' '.

    SELECT SINGLE NAME1
      INTO G_ITAB_T-KUNNR_SB_TEXT
      FROM KNA1
     WHERE KUNNR = G_ITAB_T-KUNNR_SB.

    IF SY-SUBRC = 0.
      MODIFY G_ITAB_T.
    ENDIF.

  ENDLOOP.

ENDFORM.                    " GET_KUNNR_SB_TEXT

*&---------------------------------------------------------------------*
*&      Form  query_char_value_rtn_old
*&---------------------------------------------------------------------*
FORM QUERY_CHAR_VALUE_RTN_OLD .

  DATA : BEGIN OF L_VALUE_T OCCURS 0.
           INCLUDE STRUCTURE CUXE1CUVAL.
  DATA : END OF L_VALUE_T.

*-} 기능개선61827_수정
*  CHECK NOT G_ITSO_T-CUOBJ IS INITIAL.
  IF G_ITSO_T-CUOBJ IS NOT INITIAL
    OR G_ITSO_T-SPART = '24'.
*-} 기능개선61827_2015.01.27

    CALL FUNCTION 'MILL_SE_GET_CHAR_AND_VALUE'
      EXPORTING
        INSTANCE                = G_ITSO_T-CUOBJ
        IF_RECALC_FATTR         = 'X'
*       IF_CREATION_MODE        = ' '
*       IF_ACTIVE_AND_ERROR     =
*   IMPORTING
*       NEW_INSTANCE            =
      TABLES
        ET_VALUE                = L_VALUE_T
*   CHANGING
*       CF_ANZEIGEN             = ' '
*       CX_FATTR                =
      EXCEPTIONS
        MATERIAL_HAS_NO_PROFIL  = 1
        NO_CONFIGURATION_PARAMS = 2
        FATAL_ERROR             = 3
        OTHERS                  = 4.
    IF  SY-SUBRC  <>  0.
      MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    ENDIF.

** 조장수
*  read table l_value_t with key config_id = '000001'
*                                inst_id = '00000001'
*                                charc = 'SAP_MILLCA_FACTOR'.
    CLEAR  L_VALUE_T.
    READ TABLE L_VALUE_T WITH KEY CHARC = 'SAP_MILLCA_FACTOR'.

    IF  SY-SUBRC  =  0.
*      G_ITSO_T-VALUE1  =  L_VALUE_T-VALUE. "01.02.2024 16:08:42
      G_ITSO_T-VALUE1  =  L_VALUE_T-VALUE_LONG. "01.02.2024 16:08:42

*
    ENDIF.

** 조장(개별길이)
*  read table l_value_t with key config_id = '000001'
*                                inst_id = '00000001'
*                                charc = 'SAP_MILLCA_LENGTH'.
*  read table l_value_t with key charc = 'SAP_MILLCA_LENGTH'.
*  read table l_value_t with key charc = 'SD_MILLCA_LENGTH_VKRME'.
    CLEAR  L_VALUE_T.
    READ TABLE L_VALUE_T WITH KEY CHARC = 'SAP_LENGTH_VKRME'.

    IF  SY-SUBRC  =  0.
*      G_ITSO_T-VALUE2  =  L_VALUE_T-VALUE. "01.02.2024 16:07:29
      G_ITSO_T-VALUE2  =  L_VALUE_T-VALUE_LONG. "01.02.2024 16:07:29
    ENDIF.

** 색상
    CLEAR  L_VALUE_T.
    READ TABLE L_VALUE_T WITH KEY CHARC = 'PD_CA_COLOR_BASE'.

    IF  SY-SUBRC  =  0.
*      G_ITSO_T-VALUE3  =  L_VALUE_T-VALUE."01.02.2024 16:07:40
      G_ITSO_T-VALUE3  =  L_VALUE_T-VALUE_LONG."01.02.2024 16:07:40
    ENDIF.

** 입회검사유무
    CLEAR  L_VALUE_T.
    READ TABLE L_VALUE_T WITH KEY CHARC = 'PD_AA_WITNESS_INSPECTION'.

    IF  SY-SUBRC  =  0.
*      G_ITSO_T-VALUE4  =  L_VALUE_T-VALUE."01.02.2024 16:08:06
      G_ITSO_T-VALUE4  =  L_VALUE_T-VALUE_LONG."01.02.2024 16:08:06

*
    ENDIF.

** 절연선심식별
    CLEAR  L_VALUE_T.
    READ TABLE L_VALUE_T WITH KEY CHARC = 'PD_CA_INS_IDEN_CODE'.

    IF  SY-SUBRC  =  0.
*      G_ITSO_T-VALUE5  =  L_VALUE_T-VALUE. "01.02.2024 16:08:21  /
      G_ITSO_T-VALUE5  =  L_VALUE_T-VALUE_LONG. "01.02.2024 16:08:21

*
*-} 기능개선61827_추가
    ELSEIF SY-SUBRC <> 0 AND G_ITSO_T-SPART = '24'.

      PERFORM GET_INS_IDEN.

    ENDIF.

*{ SRM2404-07578 - s 튜브인쇄사양 추가
    CLEAR  L_VALUE_T.
    READ TABLE L_VALUE_T WITH KEY CHARC = 'PD_TB_PRINT_APP'.

    IF  SY-SUBRC  =  0.
      G_ITSO_T-VALUE6  =  L_VALUE_T-VALUE_LONG.

    ENDIF.
*} SRM2404-07578 - e

  ENDIF.
*-} 기능개선61827_2015.01.27


ENDFORM.                    " query_char_value_rtn_old

*&---------------------------------------------------------------------*
*&      Form  progress_indicator
*&---------------------------------------------------------------------*
FORM PROGRESS_INDICATOR .

  G_MSG(3)  =  G_RATIO.
  G_MSG+4  =  '%'.
  G_MSG+7(20)  =  ' Data Loading....'.

  CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
    EXPORTING
      PERCENTAGE = G_RATIO
      TEXT       = G_MSG
    EXCEPTIONS
      OTHERS     = 1.

ENDFORM.                    " progress_indicator

*&---------------------------------------------------------------------*
*&      Form  apo_data_query
*&---------------------------------------------------------------------*
FORM APO_DATA_QUERY .

  DATA : L_LFSTA LIKE VBUP-LFSTA,
         L_CLABS LIKE MCHB-CLABS,
         L_MATNR LIKE MARA-MATNR.

*-- 이전전기 여부 확인 정보  Select
  DATA : LT_CHKTAB LIKE TABLE OF G_ITAB_T WITH EMPTY KEY,

         LV_DDTEXT TYPE DDTEXT,
         LV_DDVAL  TYPE DOMVALUE_L.

  LT_CHKTAB[] = CORRESPONDING #( G_ITAB_T[] ).

  WITH +KEY_INFO AS ( SELECT A~VBELN, A~POSNR
                        FROM @LT_CHKTAB AS A
                       WHERE A~SPART EQ '60'    "--> 부스덕트 한정
                       GROUP BY A~VBELN, A~POSNR )

    SELECT A~VBELN,  A~POSNR,  A~ZSTAT

      FROM ZGTSDT0065 AS A INNER JOIN +KEY_INFO AS B
                              ON A~VBELN EQ B~VBELN
                             AND A~POSNR EQ B~POSNR
     WHERE A~ZSTAT EQ 'T'                       "--> 이전전기 완료 항목

     ORDER BY A~VBELN, A~POSNR

      INTO TABLE @DATA(LT_0065).

  CLEAR : G_ITAB_T.

  LOOP AT G_ITAB_T.

    CLEAR : L_LFSTA, L_MATNR.

    L_MATNR = G_ITAB_T-MATNR.

    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
      EXPORTING
        INPUT  = G_ITAB_T-MATNR
      IMPORTING
        OUTPUT = G_ITAB_T-MATNR.

*/    APO 공정정보
    SELECT  SINGLE
            ORDID  SOSTAT SOEND OPRTX
            OPSTAT OPEND CHARG MENGE
      INTO (G_ITAB_T-ORDID,
            G_ITAB_T-SOSTAT,
            G_ITAB_T-SOEND,
            G_ITAB_T-OPRTX,
            G_ITAB_T-OPSTAT,
            G_ITAB_T-OPEND,
            G_ITAB_T-CHARG,
            G_ITAB_T-MENGE)
      FROM  ZSD0098T
     WHERE  VBELN = G_ITAB_T-VBELN
       AND  POSNR = G_ITAB_T-POSNR.

    IF  SY-SUBRC  =  0.

* JS전선일경우만 해당
* 070912 SDB03 곽태근 과장님 요청
* 오더번호(ordid) 필드의 값이 구매오더일 경우 현공정 오더시작일,
* 현공정 오더종료일을 구매오더 시작일/종료일로 변경
* 시작일은 구매오더 증빙일
* 종료일은 구매오더 품목 납품일
      IF G_ITAB_T-VSTEL+0(1) = 'J'.
        SELECT SINGLE MANDT INTO SY-MANDT
        FROM   EKKO
        WHERE  EBELN = G_ITAB_T-ORDID.
        IF  SY-SUBRC = 0.
          SELECT SINGLE T~EINDT INTO G_ITAB_T-OPEND
          FROM   EKET AS T INNER JOIN EKKN AS N
            ON   T~EBELN = N~EBELN
           AND  T~EBELP = N~EBELP
          WHERE  N~VBELN = G_ITAB_T-VBELN
          AND    N~VBELP = G_ITAB_T-POSNR.
          IF SY-SUBRC = 0.
            SELECT SINGLE BEDAT INTO G_ITAB_T-OPSTAT
            FROM   EKKO
            WHERE  EBELN = G_ITAB_T-ORDID.
          ENDIF.
        ENDIF.
      ENDIF.
* 여기까지 추가

      IF  G_ITAB_T-OPRTX  =  '계획중' AND
          G_ITAB_T-MATNR+0(1)  =  '3'.    " 상품
        G_ITAB_T-OPRTX  =  '상품대상'.
      ENDIF.

*        * 입고일을 가져온다.
      SELECT  SINGLE BUDAT
        INTO  G_ITAB_T-BUDAT
        FROM  MATDOC
        WHERE CHARG  =  G_ITAB_T-CHARG.

    ENDIF.

    IF  NOT G_ITAB_T-VBELN_VL IS INITIAL AND
        NOT G_ITAB_T-VBELN_GI IS INITIAL .

*-> CCM : 12.04.2023 09:02:41 ZLSGSD5 - VBUP 필드 변경
      SELECT  SINGLE LFSTA
        INTO  L_LFSTA
*        FROM  VBUP
        FROM  VBAP
       WHERE  VBELN  =  G_ITAB_T-VBELN
         AND  POSNR  =  G_ITAB_T-POSNR.
*<-
      IF  L_LFSTA  =  'A'  OR
          L_LFSTA  =  'B'.
        G_ITAB_T-OPRTX  =  '주문부분출하완료'.
      ELSEIF  L_LFSTA  =  'C'.
        G_ITAB_T-OPRTX  =  '전체주문출고완료'.
      ENDIF.

    ELSEIF G_ITAB_T-SOBKZ = 'E' .
      CLEAR L_CLABS.

*/    특별재고(MTO)
      SELECT SUM( KALAB ) INTO L_CLABS FROM MSKA
       WHERE MATNR = L_MATNR
         AND WERKS = G_ITAB_T-WERKS
*             AND LGORT = g_itab_t-lgort
         AND SOBKZ = G_ITAB_T-SOBKZ
         AND VBELN = G_ITAB_T-VBELN
         AND POSNR = G_ITAB_T-POSNR.

      IF L_CLABS  > 0.
        G_ITAB_T-OPRTX  =  '재고입고'.
      ENDIF.
    ENDIF.

*-- 이전전기 여부 구성
    READ TABLE LT_0065 WITH KEY VBELN = G_ITAB_T-VBELN
                                POSNR = G_ITAB_T-POSNR
                       INTO DATA(LS_0065).
    IF SY-SUBRC EQ 0.
      CLEAR LV_DDTEXT.
      LV_DDVAL = LS_0065-ZSTAT.

      CALL FUNCTION 'DOMAIN_VALUE_GET'
        EXPORTING
          I_DOMNAME  = 'ZGTD_ZSTAT'
          I_DOMVALUE = LV_DDVAL
        IMPORTING
          E_DDTEXT   = LV_DDTEXT
        EXCEPTIONS
          NOT_EXIST  = 1
          OTHERS     = 2.

      G_ITAB_T-OPRTX  = LV_DDTEXT.
    ENDIF.

    MODIFY  G_ITAB_T.

    CLEAR : G_ITAB_T.

  ENDLOOP.


** Direct Call은 막고 하루의 Gap으로 조회한다.
*data: begin of l_order_t occurs 0,
*        vbeln like vbak-vbeln,
*      end of l_order_t.
*
*data: begin of l_list_t occurs 0.
*        include structure zsd0098t.
*data: end of l_list_t.
*
*data : l_dest(10),
*       l_dest2(10),
*       l_cnt type i.
*clear : l_order_t, l_order_t[], l_list_t, l_list_t[], l_dest, l_dest2.
*
*  loop at g_itab_t.
*    l_order_t-vbeln  =  g_itab_t-vbeln.
*    append  l_order_t.
*    clear  l_order_t.
*  endloop.
*
*  delete adjacent duplicates from l_order_t.
*
*** R3 Destination
*  select  single logsys
*    into  l_dest2
*    from  t000
*   where  mandt  =  sy-mandt.
*
*** APO Destination
*  select  single logsys
*    into  l_dest
*    from  cifopmode client specified
*   where  mandt  =  sy-mandt.
*
**  if  sy-sysid  =  'R3T'.
**      l_dest  =  'APTCLNT710'.
**  elseif  sy-sysid  =  'R3Q'.
**      l_dest  =  'APQCLNT100'.
**  elseif  sy-sysid  =  'R3P'.
**      l_dest  =  'APPCLNT100'.
**  endif.
*
*** APO RFC Call
*  call function  'Z_PD_ORDER_AVL_DATE_GET1'
*    destination  l_dest
*    exporting
*        logical_system =  l_dest2
*    tables
*        order_keys_in  =  l_order_t
*        tracking_et    =  l_list_t
*    exceptions
*        lc_connect_failed     =  1
*        no_valid_sales_order  =  2
*        bapi_error            =  3
*        lc_error              =  4.
*
*  describe table l_list_t lines l_cnt.
*
*  if  l_cnt  >  0.
*
*      clear g_itab_t.
*
*      loop at g_itab_t.
*
*        read table l_list_t with key vbeln = g_itab_t-vbeln
*                                     posnr = g_itab_t-posnr.
*
*        if  sy-subrc  =  0.
*
*            g_itab_t-ordid  =  l_list_t-ordid.
*            g_itab_t-sostat =  l_list_t-sostat.
*            g_itab_t-soend  =  l_list_t-soend.
*            g_itab_t-oprtx  =  l_list_t-oprtx.
*            g_itab_t-opstat =  l_list_t-opstat.
*            g_itab_t-opend  =  l_list_t-opend.
*            g_itab_t-charg  =  l_list_t-charg.
*            g_itab_t-menge  =  l_list_t-menge.
*
*            modify  g_itab_t.
*            clear  g_itab_t.
*
*        endif.
*
*      endloop.
*
*  endif.

ENDFORM.                    " apo_data_query

*&---------------------------------------------------------------------*
*&      Form  call_va02
*&---------------------------------------------------------------------*
FORM CALL_VA02 .

  DATA : L_CNT TYPE I.

  LOOP AT G_ITAB_T WHERE MARK = 'X'.
    L_CNT  =  L_CNT  +  1.
  ENDLOOP.

  IF  L_CNT  <  1  OR
      L_CNT  >  1.
    MESSAGE E001 WITH '하나의 Record를 선택하세요.'.
  ENDIF.

  READ TABLE G_ITAB_T WITH KEY MARK = 'X'.

* PARAMETER SETTING
  SET PARAMETER ID: 'AUN'    FIELD   G_ITAB_T-VBELN.

*   CALL TRANSACTION
  CALL   TRANSACTION  'VA02' AND SKIP FIRST SCREEN.
  COMMIT WORK AND WAIT.

ENDFORM.                                                    " call_va02
*&---------------------------------------------------------------------*
*&      Form  get_order_type_ranges
*&---------------------------------------------------------------------*
*  ZSDT0900의 ORDER TYPE에 존재하는 값과 INPUT의 ORDER TYPE의 값 및
*  조회조건을 비교하여 QUERY할 ORDER TYPE을 선정하기 위한 작업.
*  전제 : 입력한 ORDER TYPE은 그대로 보여줘야 함.
*           -> internal table을 따로 사용하여 처리함.
*----------------------------------------------------------------------*
FORM GET_ORDER_TYPE_RANGES TABLES PT_AUART STRUCTURE RANGE_C4.

*... Check predefined possible entries for sales order type
*    Only possible, the values of DB table 'ZSDT0900'
  SELECT AUART AS LOW
    INTO CORRESPONDING FIELDS OF TABLE PT_AUART
    FROM ZSDT0900
   WHERE AUART    IN SO_AUART
     AND PGM_NAME =  'ZSD1R0020' .

  PT_AUART-SIGN   = 'I'.
  PT_AUART-OPTION = 'EQ'.
  MODIFY PT_AUART TRANSPORTING SIGN OPTION
                  WHERE LOW IS NOT INITIAL.

ENDFORM.                    " get_order_type_ranges
*&---------------------------------------------------------------------*
*&      Form  value_request_auart
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM VALUE_REQUEST_AUART  USING    VALUE(P_AUART).

*... F4 search help for order type
  DATA: BEGIN OF LT_VALUE OCCURS 1,
          AUART LIKE TVAK-AUART,           "Order type
          BEZEI LIKE TVAKT-BEZEI,          "Order type description
        END OF LT_VALUE.

*... custmizing table ZSDT0900
*    being able to custmize at t-code 'ZSD1V4001'

  SELECT ZSDT0900~AUART TVAKT~BEZEI
        INTO CORRESPONDING FIELDS OF TABLE LT_VALUE
        FROM ZSDT0900 INNER JOIN TVAKT ON ZSDT0900~AUART = TVAKT~AUART
        WHERE ZSDT0900~PGM_NAME = 'ZSD1R0020'
          AND TVAKT~SPRAS = SY-LANGU.

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      RETFIELD    = 'AUART'
      DYNPPROG    = 'ZSDR0200'
      DYNPNR      = PA_VKORG
      DYNPROFIELD = P_AUART
      VALUE_ORG   = 'S'
    TABLES
      VALUE_TAB   = LT_VALUE
    EXCEPTIONS
      OTHERS      = 1.
ENDFORM.                    " value_request_auart

*&---------------------------------------------------------------------*
*&      Form  le_data_query
*&---------------------------------------------------------------------*
FORM LE_DATA_QUERY .

  CLEAR : G_ITAB_T.

  LOOP AT G_ITAB_T.

** 절단수량
    SELECT  SUM( LFIMG )
      INTO  G_ITAB_T-ZLFIMG
      FROM  ZLET0002
     WHERE  VBELN  =  G_ITAB_T-VBELN_VL
       AND  UECHA  =  G_ITAB_T-POSNR_VL
       AND  JISIR  =  '1'.

** 절단지시일
    SELECT  MAX( JISIDAT )
      INTO  G_ITAB_T-JISIDAT
      FROM  ZLET0002
     WHERE  VBELN  =  G_ITAB_T-VBELN_VL
       AND  UECHA  =  G_ITAB_T-POSNR_VL
       AND  JISIR  =  '1'.

** 절단완료일
    SELECT  MAX( CUTSDAT )
      INTO  G_ITAB_T-CUTSDAT
      FROM  ZLET0002
     WHERE  VBELN  =  G_ITAB_T-VBELN_VL
       AND  UECHA  =  G_ITAB_T-POSNR_VL
       AND  CUTSR  =  '1'.

    MODIFY  G_ITAB_T.
    CLEAR  G_ITAB_T.

  ENDLOOP.

ENDFORM.                    " le_data_query
*&---------------------------------------------------------------------*
*&      Form  fill_sobkz
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM FILL_SOBKZ .

  CASE 'X'.
    WHEN R02.                   " mto
      R_SOBKZ-SIGN = 'I'.
      R_SOBKZ-OPTION = 'EQ'.
      R_SOBKZ-LOW = 'E'.
      APPEND R_SOBKZ.
    WHEN R03.                   " mts
      R_SOBKZ-SIGN = 'I'.
      R_SOBKZ-OPTION = 'EQ'.
      R_SOBKZ-LOW = ' '.
      APPEND R_SOBKZ.
    WHEN OTHERS.                " mto+mts
      REFRESH R_SOBKZ. CLEAR R_SOBKZ.
  ENDCASE.

ENDFORM.                    " fill_sobkz
*&---------------------------------------------------------------------*
*&      Form  CALC_NFM_QTY
*&---------------------------------------------------------------------*
FORM CALC_NFM_QTY .

  CLEAR : G_ITAB_T.

  LOOP AT G_ITAB_T.

    IF G_ITAB_T-SPART+0(1) < '5'.

      CALL FUNCTION 'ZSD_CALC_NFM_QTY'
        EXPORTING
          I_VKORG  = G_ITAB_T-VKORG
          I_VTWEG  = G_ITAB_T-VTWEG
          I_MATNR  = G_ITAB_T-MATNR
          I_VRKME  = G_ITAB_T-VRKME
          I_KWMENG = G_ITAB_T-KWMENG "오더수량
        IMPORTING
          E_CUQTY  = G_ITAB_T-CU_QTY
          E_ALQTY  = G_ITAB_T-AL_QTY.
    ENDIF.

    MODIFY  G_ITAB_T.
    CLEAR  G_ITAB_T.

  ENDLOOP.

ENDFORM.                    " CALC_NFM_QTY
*&---------------------------------------------------------------------*
*&      Form  GET_STOCK
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM GET_STOCK .

  CLEAR : G_ITAB_T.

  LOOP AT G_ITAB_T.

    IF G_ITAB_T-SOBKZ = ' '.
      IF G_ITAB_T-XCHPF = 'X'.
*/ 1. 일반재고-배치사용: MCHB
        SELECT SUM( CLABS ) INTO G_ITAB_T-CLABS FROM MCHB
          WHERE MATNR = G_ITAB_T-MATNR
            AND WERKS = G_ITAB_T-WERKS.
*            AND LGORT = g_itab_t-lgort.
      ELSE.
*/ 2. 일반재고-배치미사용: MARD
        SELECT SINGLE LABST INTO G_ITAB_T-CLABS FROM MARD
          WHERE MATNR = G_ITAB_T-MATNR
            AND WERKS = G_ITAB_T-WERKS.
*            AND LGORT = g_itab_t-lgort.
      ENDIF.
    ELSE.
      IF G_ITAB_T-XCHPF = 'X'.
*/ 3. 특별재고-배치사용: MSKA
        SELECT SUM( KALAB ) INTO G_ITAB_T-CLABS FROM MSKA
         WHERE MATNR = G_ITAB_T-MATNR
           AND WERKS = G_ITAB_T-WERKS
           AND LGORT = G_ITAB_T-LGORT
           AND SOBKZ = G_ITAB_T-SOBKZ
           AND VBELN = G_ITAB_T-VBELN
           AND POSNR = G_ITAB_T-POSNR.
      ELSE.
*/ 4. 특별재고-배치미사용: MSKA
        SELECT SINGLE KALAB INTO G_ITAB_T-CLABS FROM MSKA
          WHERE MATNR = G_ITAB_T-MATNR
            AND WERKS = G_ITAB_T-WERKS
            AND LGORT = G_ITAB_T-LGORT
            AND SOBKZ = G_ITAB_T-SOBKZ
            AND VBELN = G_ITAB_T-VBELN
            AND POSNR = G_ITAB_T-POSNR.
      ENDIF.
    ENDIF.

    G_ITAB_T-N_CLABS = G_ITAB_T-CLABS.
    MODIFY  G_ITAB_T.
    CLEAR  G_ITAB_T.
  ENDLOOP.

ENDFORM.                    " GET_STOCK
*&---------------------------------------------------------------------*
*&      Form  GET_MATNR_ZZMAKT80
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM GET_MATNR_ZZMAKT80 .

  LOOP AT G_ITAB_T WHERE MATNR <> ' '.
    SELECT SINGLE ZZMAKTX80
      INTO G_ITAB_T-ZZMAKTX80
      FROM MARA
     WHERE MATNR = G_ITAB_T-MATNR.
    IF SY-SUBRC = 0.
      MODIFY G_ITAB_T.
    ENDIF.
  ENDLOOP.

ENDFORM.                    " GET_MATNR_ZZMAKT80
*&---------------------------------------------------------------------*
*&      Form  CALL_REAL_TIME_ORDER_TRACKING
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM CALL_REAL_TIME_ORDER_TRACKING .
  DATA: LT_RSPARAMS  LIKE RSPARAMS OCCURS 0 WITH HEADER LINE.

  DATA: LV_CNT       TYPE I.

  CLEAR   : LT_RSPARAMS, LV_CNT.
  REFRESH : LT_RSPARAMS.

  LOOP AT G_ITAB_T WHERE MARK = 'X'.
    LV_CNT  =  LV_CNT  +  1.
  ENDLOOP.

  IF  LV_CNT  <>  1.
    MESSAGE E001 WITH '하나의 Record를 선택하세요.'.
  ENDIF.

*___영업조직
  CLEAR : LT_RSPARAMS.
  LT_RSPARAMS-SELNAME = 'PA_VKORG'.
  LT_RSPARAMS-KIND    = 'P'.
  LT_RSPARAMS-LOW     = G_ITAB_T-VKORG.
  APPEND LT_RSPARAMS.

*___유통경로
  CLEAR : LT_RSPARAMS.
  LT_RSPARAMS-SELNAME = 'PA_VTWEG'.
  LT_RSPARAMS-KIND    = 'P'.
  LT_RSPARAMS-LOW     = G_ITAB_T-VTWEG.
  APPEND LT_RSPARAMS.

*___제품군
  CLEAR : LT_RSPARAMS.
  LT_RSPARAMS-SELNAME = 'SO_SPART'.
  LT_RSPARAMS-KIND    = 'S'.
  LT_RSPARAMS-SIGN    = 'I'.
  LT_RSPARAMS-OPTION  = 'EQ'.
  LT_RSPARAMS-LOW     = G_ITAB_T-SPART.
  APPEND LT_RSPARAMS.

*___판매처
  CLEAR : LT_RSPARAMS.
  LT_RSPARAMS-SELNAME = 'PA_KUNNR'.
  LT_RSPARAMS-KIND    = 'P'.
  LT_RSPARAMS-LOW     = G_ITAB_T-KUNNR.
  APPEND LT_RSPARAMS.

*___판매오더
  CLEAR : LT_RSPARAMS.
  LT_RSPARAMS-SELNAME = 'PA_VBELN'.
  LT_RSPARAMS-KIND    = 'P'.
  LT_RSPARAMS-LOW     = G_ITAB_T-VBELN.
  APPEND LT_RSPARAMS.

*___오더 트래킹 - 실시간 리포트 호출
  SUBMIT ZSDR0201 WITH SELECTION-TABLE LT_RSPARAMS
                  AND  RETURN.

ENDFORM.                    " CALL_REAL_TIME_ORDER_TRACKING

*&---------------------------------------------------------------------*
*&      Form  GET_PJTAPPL_TEXT
*&---------------------------------------------------------------------*
FORM GET_PJTAPPL_TEXT .

  LOOP AT G_ITAB_T WHERE ZPJNO <> ' '.

    SELECT SINGLE ZPTXT
      INTO G_ITAB_T-ZPTXT
      FROM ZSD0106T
     WHERE ZPJNO = G_ITAB_T-ZPJNO.

    IF SY-SUBRC = 0.
      MODIFY G_ITAB_T.
    ENDIF.

  ENDLOOP.

ENDFORM.                    " GET_PJTAPPL_TEXT
*&---------------------------------------------------------------------*
*&      Form  GET_INS_IDEN
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM GET_INS_IDEN .

  DATA : LV_SUL_NO  LIKE ZEDT1000-SUL_NO,
         LV_MAX_REV LIKE ZEDT1000-REV_SEQ.

  SELECT SINGLE SUL_NO REV_SEQ
    INTO (LV_SUL_NO, LV_MAX_REV)
    FROM ZEDT1000
   WHERE NEW_MATNR = G_ITSO_T-MATNR
     AND REV_SEQ = ( SELECT MAX( REV_SEQ )
                       FROM ZEDT1000
                      WHERE NEW_MATNR = G_ITSO_T-MATNR ).

  IF SY-SUBRC = 0 .

    SELECT SINGLE DATA_CHAR
      INTO G_ITSO_T-VALUE5
      FROM ZEDV009
     WHERE SUL_NO = LV_SUL_NO
       AND REV_SEQ = LV_MAX_REV
       AND ATTRIBUTE = 'COLOR'
       AND GONG_CD = 'INS'
       AND JACK_CD = 'CVI'.
  ENDIF.

ENDFORM.                    " GET_INS_IDEN
*&---------------------------------------------------------------------*
*&      Form  GET_SOTEXT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM GET_SOTEXT .

  DATA : LV_TDNAME(16),
         LV_POSNR LIKE VBAP-POSNR.

  CLEAR   : TDTEXT, LV_TDNAME, LV_POSNR.
  REFRESH : TDTEXT.

  CONCATENATE G_ITAB_T-VBELN G_ITAB_T-POSNR INTO LV_TDNAME.

  CLEAR WA_THEAD.
  WA_THEAD-TDID = '0001'.
  WA_THEAD-TDNAME = LV_TDNAME.
  WA_THEAD-TDOBJECT = 'VBBP'.
  WA_THEAD-TDSPRAS  = SY-LANGU.

  CALL FUNCTION 'READ_TEXT'
    EXPORTING
*     CLIENT                  = SY-MANDT
      ID                      = WA_THEAD-TDID
      LANGUAGE                = WA_THEAD-TDSPRAS
      NAME                    = WA_THEAD-TDNAME
      OBJECT                  = WA_THEAD-TDOBJECT
*     ARCHIVE_HANDLE          = 0
*     LOCAL_CAT               = ' '
*    IMPORTING
*     HEADER                  = WA_THEAD
    TABLES
*     lines                   = it_long
      LINES                   = TDTEXT
    EXCEPTIONS
      ID                      = 1
      LANGUAGE                = 2
      NAME                    = 3
      NOT_FOUND               = 4
      OBJECT                  = 5
      REFERENCE_CHECK         = 6
      WRONG_ACCESS_TO_ARCHIVE = 7
      OTHERS                  = 8.

  IF SY-SUBRC = 0.
    LOOP AT TDTEXT.
      IF SY-TABIX = 1.
        G_ITAB_T-SOTEXT = TDTEXT-TDLINE.
      ELSE.
        CONCATENATE G_ITAB_T-SOTEXT '/' TDTEXT-TDLINE
        INTO G_ITAB_T-SOTEXT.
      ENDIF.
    ENDLOOP.
  ENDIF.

ENDFORM.                    " GET_SOTEXT
*&---------------------------------------------------------------------*
*&      Form  GET_PERNR_NAME
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM GET_LIFNR_NAME  USING    PV_LIFNR
                              PV_ENAME.

  CLEAR : PV_ENAME.

*  SELECT SINGLE ename
*    INTO pv_ename
*    FROM pa0001
*   WHERE pernr =  pv_pernr
*     AND endda <= sy-datum
*     AND begda >= sy-datum.
*
*  IF sy-subrc <> 0.
*    SELECT SINGLE ename
*      INTO pv_ename
*      FROM pa0001
*     WHERE pernr =  pv_pernr.
*  ENDIF.
*  IF pv_ename IS INITIAL.
  SELECT SINGLE NAME1
    INTO PV_ENAME
    FROM LFA1
   WHERE LIFNR =  PV_LIFNR.
*  ENDIF.

ENDFORM.                    " GET_PERNR_NAME
*&---------------------------------------------------------------------*
*&      Form  SEND_RFC_DATA_TO_MES
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM SEND_RFC_DATA_TO_MES .


  DATA : LT_DATA LIKE TABLE OF ZMMS220 WITH HEADER LINE.

*-> CCM : 19.04.2023 13:31:28 ZLSGSD5 - MATNR 자릿수 변경
  LOOP AT G_ITAB_T .
    CLEAR LT_DATA.
*    MOVE-CORRESPONDING G_ITAB_T  TO LT_DATA .
    LT_DATA = CORRESPONDING #( G_ITAB_T EXCEPT MATNR ).
    LT_DATA-MATNR  = CONV MATNR18( G_ITAB_T-MATNR ).
    LT_DATA-ERDAT2 = LT_DATA-ERDAT.
    APPEND LT_DATA.
  ENDLOOP.
*<-

  PERFORM SET_MEMORY IN PROGRAM SAPLZMM45 IF FOUND
            TABLES  LT_DATA
            USING  'ZSDR0200' .

ENDFORM.                    " SEND_RFC_DATA_TO_MES
*&---------------------------------------------------------------------*
*& Form GET_OTHER_DATA_COLLECTIVELY
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM GET_OTHER_DATA_COLLECTIVELY .

  CHECK G_ITSO_T[] IS NOT INITIAL.

  REFRESH : GR_ATNAMO, GT_ORDS,  GT_ORDVALS,
            GT_VBPA,   GT_MARA,  GT_TVAGT,
            GT_T179T.

*___마지막납품일
  SELECT VBELN
         POSNR
         EDATU
    INTO TABLE GT_VBEP
    FROM VBEP
     FOR ALL ENTRIES IN G_ITSO_T
   WHERE VBELN = G_ITSO_T-VBELN
     AND POSNR = G_ITSO_T-POSNR
     AND ETENR = ( SELECT MAX( ETENR )
                     FROM VBEP
                    WHERE VBELN = G_ITSO_T-VBELN
                      AND POSNR = G_ITSO_T-POSNR ).

  SORT GT_VBEP BY VBELN POSNR.

*___파트너 - 판매처/납품처/지급처/특별재고파트너/영업사원
  SELECT A~VBELN
         A~POSNR
         A~PARVW
         A~KUNNR
         A~LIFNR
         A~ADRNR
         B~NAME1
         C~NAME1 AS NAME2
         D~NAME1 AS NAMAD
    INTO TABLE GT_VBPA
    FROM VBPA AS A
    LEFT OUTER JOIN KNA1 AS B
      ON A~KUNNR = B~KUNNR
    LEFT OUTER JOIN LFA1 AS C
      ON A~LIFNR = C~LIFNR
    LEFT OUTER JOIN ADRC AS D
      ON A~ADRNR     =  D~ADDRNUMBER
     AND D~DATE_FROM <= SY-DATUM
     AND D~NATION    =  ' '
     FOR ALL ENTRIES IN G_ITSO_T
   WHERE VBELN =   G_ITSO_T-VBELN
     AND PARVW IN ('AG', 'WE', 'RG', 'SB', 'VE').

  SORT GT_VBPA BY VBELN POSNR PARVW.

*___자재내역
  SELECT A~MATNR
         A~ZZMAKTX80
         B~MAKTX
    INTO TABLE GT_MARA
    FROM MARA AS A
   INNER JOIN MAKT AS B
      ON A~MATNR = B~MATNR
     AND B~SPRAS = SY-LANGU
     FOR ALL ENTRIES IN G_ITSO_T
   WHERE A~MATNR = G_ITSO_T-MATNR.

  SORT GT_MARA BY MATNR.

*___거절사유
  SELECT ABGRU
         BEZEI
    INTO TABLE GT_TVAGT
    FROM TVAGT
     FOR ALL ENTRIES IN G_ITSO_T
   WHERE SPRAS = SY-LANGU
     AND ABGRU = G_ITSO_T-ABGRU.

  SORT GT_TVAGT BY ABGRU.

*___제품계층구조
  SELECT PRODH
         VTEXT
    INTO TABLE GT_T179T
    FROM T179T
     FOR ALL ENTRIES IN G_ITSO_T
   WHERE PRODH = G_ITSO_T-PRODH.

  SORT GT_T179T BY PRODH.

*___오더 특성
  GR_ATNAMO = VALUE #( BASE GR_ATNAMO
                         SIGN = 'I' OPTION = 'EQ'
                         ( LOW = 'SAP_MILLCA_FACTOR'        )
                         ( LOW = 'SAP_LENGTH_VKRME'         )
                         ( LOW = 'PD_CA_COLOR_BASE'         )
                         ( LOW = 'PD_AA_WITNESS_INSPECTION' )
                         ( LOW = 'PD_CA_INS_IDEN_CODE'      )
                         ( LOW = 'PD_TB_PRINT_APP'          )
                         ( LOW = 'PD_CA_COLOR_STRIPE'       )
                         ( LOW = 'PD_CA_COLOR_STRIPE_NO'    )

                          ).

  GT_ORDS   = VALUE #( BASE GT_ORDS
                        FOR LW_DATA IN G_ITSO_T
                          WHERE ( VBELN IS NOT INITIAL )
                          ( VBELN = LW_DATA-VBELN
                            POSNV = LW_DATA-POSNR ) ).

*___오더 특성
  CALL FUNCTION 'Z_GET_CHAR_OF_ORDER'
    EXPORTING
      IR_ATNAM = GR_ATNAMO
    TABLES
      IT_ORDS  = GT_ORDS
      ET_VALS  = GT_ORDVALS.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_OTHER_DATA_COLLECTIVELY_2
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM GET_OTHER_DATA_COLLECTIVELY_2 .

  CHECK G_ITAB_T[] IS NOT INITIAL.

  REFRESH : GT_VTTK,  GT_VTTP,  GT_VFKP,
            GT_AFPO,  GT_VBKD,  GT_T052U,
            GT_0230,  GT_KNA1,  GT_TVAUT,
            GT_MKPF,  GT_TVKBT, GT_TVGRT,
            GT_T001W, GT_TVSTT, GT_TVROT,
            GT_0106.

*___선적정보
  SELECT TKNUM
         ERDAT              "선적생성일
         SIGNI              "차량번호
         TPLST              "운송계획지점
         ERZET              "선적생성시간
         UZDIS              "계획시간
         UAREG              "체크인시간
         DPTEN              "선적종료계획
         UPTEN
    INTO CORRESPONDING FIELDS OF TABLE GT_VTTK
    FROM VTTK
     FOR ALL ENTRIES IN G_ITAB_T
   WHERE TKNUM = G_ITAB_T-TKNUM.

  SORT GT_VTTK BY TKNUM.

*___준비구간 선적번호
  SELECT B~VBELN
         B~TKNUM
         B~TPNUM
         A~SHTYP
    INTO TABLE GT_VTTP
    FROM VTTK AS A
   INNER JOIN VTTP AS B
      ON A~TKNUM = B~TKNUM
     FOR ALL ENTRIES IN G_ITAB_T
   WHERE B~VBELN = G_ITAB_T-VBELN_VL.
*     AND A~SHTYP = 'Z400'.

  SORT GT_VTTP BY VBELN.

  IF GT_VTTP[] IS NOT INITIAL.
*___선적비용번호
    SELECT REBEL
           REPOS
           FKNUM
      INTO TABLE GT_VFKP
      FROM VFKP
       FOR ALL ENTRIES IN GT_VTTP
     WHERE REBEL = GT_VTTP-TKNUM.

    SORT GT_VFKP BY REBEL REPOS.
  ENDIF.

*___오더사유
  SELECT AUGRU
         BEZEI
    INTO CORRESPONDING FIELDS OF TABLE GT_TVAUT
    FROM TVAUT
     FOR ALL ENTRIES IN G_ITAB_T
   WHERE SPRAS = SY-LANGU
     AND AUGRU = G_ITAB_T-AUGRU.

  SORT GT_TVAUT BY AUGRU.

*___포장재
  SELECT A~VBELN
         A~POSNR
         A~PACKING_DM
         B~MAKTX
    INTO TABLE GT_0230
    FROM ZEDT0230 AS A
   INNER JOIN MAKT AS B
      ON A~PACKING_DM = B~MATNR
     AND B~SPRAS      = SY-LANGU
     FOR ALL ENTRIES IN G_ITAB_T
   WHERE A~VBELN = G_ITAB_T-VBELN
     AND A~POSNR = G_ITAB_T-POSNR.

  SORT GT_0230 BY VBELN POSNR.

*___생산계획일/입고일
  SELECT *
    INTO CORRESPONDING FIELDS OF TABLE GT_AFPO
    FROM AFPO
     FOR ALL ENTRIES IN G_ITAB_T
   WHERE KDAUF = G_ITAB_T-VBELN
     AND KDPOS = G_ITAB_T-POSNR.

  SORT GT_AFPO BY KDAUF KDPOS AUFNR POSNR.

*___Business Data
  SELECT VBELN
         POSNR
         BSTKD
         EMPST
         BSTKD_E
         ZTERM
    INTO TABLE GT_VBKD
    FROM VBKD
     FOR ALL ENTRIES IN G_ITAB_T
   WHERE VBELN = G_ITAB_T-VBELN.

  SORT GT_VBKD BY VBELN POSNR.

  IF GT_VBKD[] IS NOT INITIAL.
*___지급조건
    SELECT ZTERM
           TEXT1
      INTO TABLE GT_T052U
      FROM T052U
       FOR ALL ENTRIES IN GT_VBKD
     WHERE ZTERM = GT_VBKD-ZTERM.

    SORT GT_T052U BY ZTERM.
  ENDIF.

*___고객정보
  SELECT KUNNR
         LAND1
    INTO TABLE GT_KNA1
    FROM KNA1
     FOR ALL ENTRIES IN G_ITAB_T
   WHERE KUNNR = G_ITAB_T-KUNNR.

  SORT GT_KNA1 BY KUNNR.

*___출고전기시간
  SELECT MBLNR
         MJAHR
         CPUTM
    INTO TABLE GT_MKPF
    FROM MKPF
     FOR ALL ENTRIES IN G_ITAB_T
   WHERE MBLNR = G_ITAB_T-VBELN_GI
     AND MJAHR = G_ITAB_T-WADAT_IST(4).

  SORT GT_MKPF BY MBLNR MJAHR.

*___영업팀
  SELECT *
    INTO TABLE GT_TVKBT
    FROM TVKBT
     FOR ALL ENTRIES IN G_ITAB_T
   WHERE SPRAS = SY-LANGU
     AND VKBUR = G_ITAB_T-VKBUR.

  SORT GT_TVKBT BY VKBUR.

*___영업그룹
  SELECT *
    INTO TABLE GT_TVGRT
    FROM TVGRT
     FOR ALL ENTRIES IN G_ITAB_T
   WHERE SPRAS = SY-LANGU
     AND VKGRP = G_ITAB_T-VKGRP.

  SORT GT_TVGRT BY VKGRP.

*___플랜트
  SELECT WERKS
         NAME1
    INTO TABLE GT_T001W
    FROM T001W
     FOR ALL ENTRIES IN G_ITAB_T
   WHERE WERKS = G_ITAB_T-WERKS.

  SORT GT_T001W BY WERKS.

*___출하지점
  SELECT *
    INTO TABLE GT_TVSTT
    FROM TVSTT
     FOR ALL ENTRIES IN G_ITAB_T
   WHERE SPRAS = SY-LANGU
     AND VSTEL = G_ITAB_T-VSTEL.

  SORT GT_TVSTT BY VSTEL.

*___운송경로명
  SELECT ROUTE
         BEZEI
    INTO TABLE GT_TVROT
    FROM TVROT
     FOR ALL ENTRIES IN G_ITAB_T
   WHERE ROUTE = G_ITAB_T-ROUTE.

  SORT GT_TVROT BY ROUTE.

*___Project 명
  SELECT ZPJNO
         ZPTXT
    INTO TABLE GT_0106
    FROM ZSD0106T
     FOR ALL ENTRIES IN G_ITAB_T
   WHERE ZPJNO = G_ITAB_T-ZPJNO.

  SORT GT_0106 BY ZPJNO.

*___ grdae 등급
  DATA LV_ATINN  TYPE ATINN.

  CALL FUNCTION 'CONVERSION_EXIT_ATINN_INPUT'
    EXPORTING
      INPUT  = 'ZBT_AA_GRADE'
    IMPORTING
      OUTPUT = LV_ATINN.

  SELECT VBELN,
         POSNR,
         WERKS,
         ATWRT AS SCR_GRADE
    INTO TABLE @GT_GRADE
    FROM ZGTMM_CV_BD_GET_VCOFSO
     FOR ALL ENTRIES IN @G_ITAB_T
   WHERE VBELN EQ @G_ITAB_T-VBELN
     AND POSNR EQ @G_ITAB_T-POSNR
     AND WERKS EQ @G_ITAB_T-WERKS
     AND ATINN EQ @LV_ATINN.

  SORT GT_GRADE BY VBELN POSNR WERKS.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  FILL_ITAB
*&---------------------------------------------------------------------*
*       DATA SELECT
*----------------------------------------------------------------------*
FORM FILL_ITAB.
  RANGES: LT_AUART  FOR  VBAK-AUART.

  PERFORM GET_ORDER_TYPE_RANGES TABLES LT_AUART.
  IF LT_AUART[] IS INITIAL.
    MESSAGE E004(ZLE1) WITH '정의된 오더유형이 없습니다'.
  ENDIF.

  SELECT  A~VBELN                           "영업문서
          B~POSNR                           "품목번호
          A~AUART                           "주문유형
          A~KUNNR                           "고객
          B~MATNR                           "자재
          B~PRODH                           "제품계층구조
          B~WERKS                           "플랜트
          A~VKORG                           "영업조직
          A~VTWEG                           "유통경로
          D~EDATU AS VDATU                  "주문도착일(시스템납품일)
          B~KWMENG                          "오더수량
          B~KBMENG                          "확정수량
          B~ABGRU                           "거절사유
          A~SPART                           "제품군
          A~VKBUR                           "사업장
          A~VKGRP                           "영업그룹
          A~ERNAM                           "사용자ID
          A~KNUMV                           "문서조건번호
          A~ERDAT                           "오더생성일
          A~ERZET                           "입력시간
          B~VRKME                           "판매단위
          D~ETENR                           "일정라인
          D~EZEIT                           "주문도착시간
          D~MBDAT                           "자재가용일
          B~PSTYV                           "ITEM CATEGORY
          B~VSTEL                           "출하지점
          B~BRGEW                           "중량
          B~MATKL                           "자재그룹
          B~NETWR                           "오더금액
          A~AUGRU                           "오더사유
          B~NETPR                           "단가
          B~WAERK                           "통화
          C~LIFNR                           "영업사원
          A~ZPJNO                           "프로젝트NO
          B~SPART AS SPART2                 "품목별제품군
          B~CUOBJ                           "조장수특성값
          B~SOBKZ
          B~XCHPF
          A~ZPROJECT                        "JS전선 호선...
          B~CHARG AS CHARG_V
          B~KDMAT                           "고객자재코드
          B~PRCTR                           "손익센터
   INTO CORRESPONDING FIELDS OF TABLE G_ITSO_T
   FROM VBAP AS B
  INNER JOIN VBAK AS A
     ON B~VBELN = A~VBELN
  INNER JOIN VBEP AS D
     ON D~VBELN = B~VBELN
    AND D~POSNR = B~POSNR
  INNER JOIN VBPA AS C
     ON C~VBELN = B~VBELN
    AND C~POSNR = '000000'
    AND C~PARVW = 'VE'
  WHERE A~ERDAT  IN  SO_ERDAT
    AND A~AUART  IN  LT_AUART
    AND A~VBELN  IN  SO_VBELN
    AND A~ZPJNO  IN  SO_ZPJNO
    AND A~KUNNR  IN  SO_KUNNR
    AND A~VKORG  =   PA_VKORG
    AND A~VTWEG  IN  SO_VTWEG
    AND A~SPART  IN  SO_SPART
    AND A~VKBUR  IN  SO_VKBUR
    AND A~VKGRP  IN  SO_VKGRP
    AND B~WERKS  IN  SO_WERKS
    AND B~MATNR  IN  SO_MATNR
    AND A~ERNAM  IN  SO_ERNAM
*   AND A~VDATU  IN  SO_VDATU
    AND D~EDATU  IN  SO_EDATU
    AND B~VSTEL  IN  SO_VSTEL
    AND B~MATKL  IN  SO_MATKL
    AND B~SOBKZ  IN  R_SOBKZ           "MTO,MTS.
*    AND C~PERNR  IN  SO_PERNR.         "영업사원
    AND C~LIFNR  IN  SO_LIFNR.         "영업사원

  DESCRIBE TABLE G_ITSO_T LINES G_TOTCNT.

  PERFORM GET_OTHER_DATA_COLLECTIVELY .

*___차후 영업/유통문서, NAME 등
  PERFORM GET_VBELN.

  IF PA_SPMON IS NOT INITIAL.
    DELETE G_ITAB_T WHERE WADAT_IST(6) <> PA_SPMON.
  ENDIF.

  DELETE G_ITAB_T WHERE KODAT NOT IN SO_KODAT
                     OR LDDAT NOT IN SO_LDDAT.

  SORT G_ITAB_T BY VBELN POSNR VBELN_VL POSNR_VL.

*> PROGRESS Display.
  G_LINEN    = 10.
  G_OUT_TEXT = '데이타를 검색 중입니다 %99999%%'.
  REPLACE '%99999%' WITH G_LINEN INTO G_OUT_TEXT.
  PERFORM SHOW_PROGRESS_BAR(ZSDR0230) USING G_OUT_TEXT G_LINEN.

  PERFORM GET_OTHER_DATA_COLLECTIVELY_2.

  LOOP AT G_ITAB_T.
*___선적정보
    READ TABLE GT_VTTK WITH KEY TKNUM = G_ITAB_T-TKNUM
                                BINARY SEARCH.
    IF SY-SUBRC = 0.
      G_ITAB_T-ERDAT2 = GT_VTTK-ERDAT.       "선적생성일
      G_ITAB_T-SIGNI  = GT_VTTK-SIGNI.       "차량번호
      G_ITAB_T-TPLST  = GT_VTTK-TPLST.       "운송계획지점
      G_ITAB_T-ERZET3 = GT_VTTK-ERZET.       "선적생성시간
      G_ITAB_T-UZDIS  = GT_VTTK-UZDIS.       "계획시간
      G_ITAB_T-UAREG  = GT_VTTK-UAREG.       "체크인시간
      G_ITAB_T-DPTEN  = GT_VTTK-DPTEN.       "선적종료계획
      G_ITAB_T-UPTEN  = GT_VTTK-UPTEN.       "선적종료계획시간
    ENDIF.

    READ TABLE GT_0230 WITH KEY VBELN = G_ITAB_T-VBELN
                                POSNR = G_ITAB_T-POSNR
                                BINARY SEARCH.
    IF SY-SUBRC = 0.
      G_ITAB_T-PACKING_DM    = GT_0230-PACKING_DM.
      G_ITAB_T-PACKING_DM_NM = GT_0230-MAKTX.
    ENDIF.

    PERFORM GET_SOTEXT.         "판매오더 품목 테스트

*___영업사원명
    PERFORM GET_PARTNER_NAME USING G_ITAB_T-VBELN
                                   G_ITAB_T-POSNR
                                   'VE'
                                   G_ITAB_T-LIFNR
                                   G_ITAB_T-ENAME.

*___오더확정차이일 = 주문도착일, 확정일 - 생성일
    G_ITAB_T-DIFF_DATE = G_ITAB_T-EDATU - G_ITAB_T-ERDAT.

    IF G_ITAB_T-DIFF_DATE < 0.
      G_ITAB_T-DIFF_DATE = 0.
    ENDIF.

*___오더사유
    READ TABLE GT_TVAUT WITH KEY AUGRU = G_ITAB_T-AUGRU
                                 BINARY SEARCH.
    IF SY-SUBRC = 0.
      G_ITAB_T-BEZEI2 = GT_TVAUT-BEZEI.
    ENDIF.

*___특별재고파트너 가져오기
    PERFORM GET_PARTNER_NAME USING G_ITAB_T-VBELN
                                   G_ITAB_T-POSNR
                                   'SB'
                                   G_ITAB_T-KUNNR_SB
                                   G_ITAB_T-KUNNR_SB_TEXT.

*___생산계획일/입고일
    READ TABLE GT_AFPO WITH KEY KDAUF = G_ITAB_T-VBELN
                                KDPOS = G_ITAB_T-POSNR
                                BINARY SEARCH.
    IF SY-SUBRC = 0.
      G_ITAB_T-LTRMP = GT_AFPO-LTRMP.   "생산계획일
      G_ITAB_T-LTRMI = GT_AFPO-LTRMI.   "입고일
    ENDIF.

    MODIFY G_ITAB_T.
  ENDLOOP.

*> PROGRESS DISPLAY.
  G_LINEN    = 30.
  G_OUT_TEXT = '데이타를 검색 중입니다 %99999%%'.
  REPLACE '%99999%' WITH G_LINEN INTO G_OUT_TEXT.
  PERFORM SHOW_PROGRESS_BAR(ZSDR0230) USING G_OUT_TEXT G_LINEN.

  LOOP AT G_ITAB_T.
*___FILE 번호
    READ TABLE GT_VBKD WITH KEY VBELN = G_ITAB_T-VBELN
                                POSNR = G_ITAB_T-POSNR
                                BINARY SEARCH.
    IF SY-SUBRC <> 0.
      READ TABLE GT_VBKD WITH KEY VBELN = G_ITAB_T-VBELN
                                  POSNR = '000000'
                                  BINARY SEARCH.
    ENDIF.

    IF SY-SUBRC = 0.
      G_ITAB_T-BSTKD = GT_VBKD-BSTKD.
      G_ITAB_T-ZTERM = GT_VBKD-ZTERM.

      IF GT_VBKD-POSNR IS NOT INITIAL.
        G_ITAB_T-EMPST   = GT_VBKD-EMPST.
        G_ITAB_T-BSTKD_E = GT_VBKD-BSTKD_E.
      ENDIF.
    ENDIF.

*___PO번호 검색조건 처리
    IF PA_BSTKD <> SPACE AND G_ITAB_T-BSTKD <> PA_BSTKD.
      DELETE G_ITAB_T.
      CONTINUE.
    ENDIF.

*___지급조건
    READ TABLE GT_T052U WITH KEY ZTERM = G_ITAB_T-ZTERM
                                 BINARY SEARCH.
    IF SY-SUBRC = 0.
      G_ITAB_T-TEXT1 = GT_T052U-TEXT1.
    ENDIF.

*___고객국가
    READ TABLE GT_KNA1 WITH KEY KUNNR = G_ITAB_T-KUNNR
                                BINARY SEARCH.
    IF SY-SUBRC = 0.
      G_ITAB_T-LAND1 = GT_KNA1-LAND1.
    ENDIF.

*___피킹상태
    G_ITAB_T-KOSTK_TEXT = SWITCH #( G_ITAB_T-KOSTK
                                    WHEN 'A' THEN '미처리'
                                    WHEN 'B' THEN '부분적으로 처리했음'
                                    WHEN 'C' THEN '완전처리'
                                    ELSE          '관련없음' ).

*___준비구간선적번호
    READ TABLE GT_VTTP WITH KEY VBELN = G_ITAB_T-VBELN_VL
                                BINARY SEARCH.
    IF SY-SUBRC = 0.
      G_ITAB_T-TKNUM2 = GT_VTTP-TKNUM.
      G_ITAB_T-TPNUM2 = GT_VTTP-TPNUM.

*___선적비용번호
      READ TABLE GT_VFKP WITH KEY REBEL = G_ITAB_T-TKNUM2
*                                  REPOS = G_ITAB_T-TPNUM2
                                  BINARY SEARCH.
      IF SY-SUBRC = 0.
        G_ITAB_T-FKNUM = GT_VFKP-FKNUM.
      ENDIF.
    ENDIF.

*___출고전기시간
    READ TABLE GT_MKPF WITH KEY MBLNR = G_ITAB_T-VBELN_GI
                                MJAHR = G_ITAB_T-WADAT_IST(4)
                                BINARY SEARCH.
    IF SY-SUBRC = 0.
      G_ITAB_T-CPUTM = GT_MKPF-CPUTM.
    ENDIF.

*___사업장명
    READ TABLE GT_TVKBT WITH KEY VKBUR = G_ITAB_T-VKBUR
                                 BINARY SEARCH.
    IF SY-SUBRC = 0.
      G_ITAB_T-VKBUR_TEXT = GT_TVKBT-BEZEI.
    ENDIF.

*___영업그룹명
    READ TABLE GT_TVGRT WITH KEY VKGRP = G_ITAB_T-VKGRP
                                 BINARY SEARCH.
    IF SY-SUBRC = 0.
      G_ITAB_T-VKGRP_TEXT = GT_TVGRT-BEZEI.
    ENDIF.

*___플랜트명
    READ TABLE GT_T001W WITH KEY WERKS = G_ITAB_T-WERKS
                                 BINARY SEARCH.
    IF SY-SUBRC = 0.
      G_ITAB_T-WERKS_TEXT = GT_T001W-NAME1.
    ENDIF.

*___출하지점명
    READ TABLE GT_TVSTT WITH KEY VSTEL = G_ITAB_T-VSTEL
                                 BINARY SEARCH.
    IF SY-SUBRC = 0.
      G_ITAB_T-VSTEL_TEXT = GT_TVSTT-VTEXT.
    ENDIF.

*___운송경로명
    READ TABLE GT_TVROT WITH KEY ROUTE = G_ITAB_T-ROUTE
                                 BINARY SEARCH.
    IF SY-SUBRC = 0.
      G_ITAB_T-ROUTE_TEXT = GT_TVROT-BEZEI.
    ENDIF.

*___상세 품명
    READ TABLE GT_MARA WITH KEY MATNR = G_ITAB_T-MATNR
                                BINARY SEARCH.
    IF SY-SUBRC = 0.
      G_ITAB_T-ZZMAKTX80 = GT_MARA-ZZMAKTX80.
    ENDIF.

*___Project 명
    READ TABLE GT_0106 WITH KEY ZPJNO = G_ITAB_T-ZPJNO
                                BINARY SEARCH.
    IF SY-SUBRC = 0.
      G_ITAB_T-ZPTXT = GT_0106-ZPTXT.
    ENDIF.

*___등급 추가
    READ TABLE GT_GRADE WITH KEY VBELN = G_ITAB_T-VBELN
                                 POSNR = G_ITAB_T-POSNR
                                 WERKS = G_ITAB_T-WERKS
                                 BINARY SEARCH.
    IF SY-SUBRC = 0.
      G_ITAB_T-SCR_GRADE = GT_GRADE-SCR_GRADE.
    ENDIF.

    MODIFY G_ITAB_T.
  ENDLOOP.

*> PROGRESS Display.
  G_LINEN    = 60.
  G_OUT_TEXT = '데이타를 검색 중입니다 %99999%%'.
  REPLACE '%99999%' WITH G_LINEN INTO G_OUT_TEXT.
  PERFORM SHOW_PROGRESS_BAR(ZSDR0230) USING G_OUT_TEXT G_LINEN.

* 조회조건(SELECT-OPTIONS)의 선적생성일이 아니면 DELETE
  IF NOT SO_ERDA2[] IS INITIAL.
    PERFORM DELETE_ERDAT.
  ENDIF.

* 조회조건(SELECT-OPTIONS)의 실제자재이동일(출고전기일)이 아니면 DELETE
  IF NOT SO_W_IST[] IS INITIAL.
    PERFORM DELETE_WADAT_IST.
  ENDIF.

* 조회조건(SELECT-OPTIONS)의 계획자재이동일(계획G.I)이 아니면 DELETE
  IF NOT SO_WADAT[] IS INITIAL.
    PERFORM DELETE_WADAT.
  ENDIF.

* 조회조건(SELECT-OPTIONS)의 선적번호가 아니면 DELETE
  IF NOT SO_TKNUM[] IS INITIAL.
    PERFORM DELETE_TKNUM.
  ENDIF.

* 조회조건(SELECT-OPTIONS)의 납품번호가 아니면 DELETE
  IF NOT SO_VBEL2[] IS INITIAL.
    PERFORM DELETE_VBELN_VL.
  ENDIF.

* 조회조건(SELECT-OPTIONS)의 차량번호가 아니면 DELETE
  IF NOT SO_SIGNI[] IS INITIAL.
    PERFORM DELETE_SIGNI.
  ENDIF.

* 조회조건(SELECT-OPTIONS)의 특별재고파트너가 아니면 DELETE
  IF NOT SO_KUNN2[] IS INITIAL.
    PERFORM DELETE_KUNNR_SB.
  ENDIF.

* 조회조건(SELECT-OPTIONS)의 전체상품이동상태가 아니면 DELETE
  IF NOT SO_WBSTK[] IS INITIAL.
    PERFORM DELETE_WBSTK.
  ENDIF.

* 조회조건(SELECT-OPTIONS)의 운송경로가 아니면 DELETE
  IF NOT SO_ROUTE[] IS INITIAL.
    PERFORM DELETE_ROUTE.
  ENDIF.

* 조회조건(SELECT-OPTIONS)의 운송계획지점이 아니면 DELETE
  IF NOT SO_TPLST[] IS INITIAL.
    PERFORM DELETE_TPLST.
  ENDIF.

* 조회조건(SELECT-OPTIONS)의 납품유형이 아니면 DELETE
  IF NOT SO_LFART[] IS INITIAL.
    PERFORM DELETE_LFART.
  ENDIF.

* 조회조건(SELECT-OPTIONS)의 저장위치이 아니면 DELETE
  IF NOT SO_LGORT[] IS INITIAL.
    PERFORM DELETE_LGORT.
  ENDIF.

*> PROGRESS Display.
  G_LINEN    = 90.
  G_OUT_TEXT = '데이타를 검색 중입니다 %99999%%'.
  REPLACE '%99999%' WITH G_LINEN INTO G_OUT_TEXT.
  PERFORM SHOW_PROGRESS_BAR(ZSDR0230) USING G_OUT_TEXT G_LINEN.

* 동량 계산
  PERFORM  CALC_NFM_QTY.

* 공정관련 Data Query(APO에서 가져온 Data임)
  PERFORM  APO_DATA_QUERY.

* 절단관련 Data Query(LE) : 2005-09-13
  PERFORM  LE_DATA_QUERY.

* 권선 사업부 요청으로 인한 현재고 수량 표시
  PERFORM  GET_STOCK.

* 해상선적번호
  PERFORM SET_TKNUM_SEA.


  IF P_SUB IS NOT INITIAL.
    PERFORM SEND_RFC_DATA_TO_MES.
    EXIT.
  ENDIF.


*  READ TABLE G_ITAB_T INDEX 1.
*
*  IF  SY-SUBRC <> 0.
*    MESSAGE S000(ZSDM) WITH '조건에 해당하는 데이타가 없습니다.'.
*  ELSE.
*    PERFORM WRITE_ITAB.
*  ENDIF.

ENDFORM.                    " FILL_ITAB
*&---------------------------------------------------------------------*
*&      Form  query_char_value_rtn
*&---------------------------------------------------------------------*
FORM QUERY_CHAR_VALUE_RTN .

  CHECK G_ITSO_T-CUOBJ IS NOT INITIAL OR
        G_ITSO_T-SPART = '24'.

  READ TABLE GT_ORDS INTO DATA(WA_ORDS)
                     WITH KEY VBELN = G_ITSO_T-VBELN
                              POSNV = G_ITSO_T-POSNR
                              BINARY SEARCH.
  IF SY-SUBRC = 0.
* 조장수
    READ TABLE GT_ORDVALS INTO DATA(WA_OVALS)
                          WITH KEY OBJEK = WA_ORDS-OBJEK
                                   ATNAM = 'SAP_MILLCA_FACTOR'
                                   BINARY SEARCH.
    IF SY-SUBRC = 0.
      G_ITSO_T-VALUE1 = WA_OVALS-ATWRT.
    ENDIF.

* 조장(개별길이)
    READ TABLE GT_ORDVALS INTO WA_OVALS
                          WITH KEY OBJEK = WA_ORDS-OBJEK
                                   ATNAM = 'SAP_LENGTH_VKRME'
                                   BINARY SEARCH.
    IF SY-SUBRC = 0.
      G_ITSO_T-VALUE2 = WA_OVALS-ATWRT.
    ENDIF.

* 색상
    READ TABLE GT_ORDVALS INTO WA_OVALS
                          WITH KEY OBJEK = WA_ORDS-OBJEK
                                   ATNAM = 'PD_CA_COLOR_BASE'
                                   BINARY SEARCH.
    IF SY-SUBRC = 0.
      G_ITSO_T-VALUE3 = WA_OVALS-ATWRT.
    ENDIF.

* 입회검사유무
    READ TABLE GT_ORDVALS INTO WA_OVALS
                          WITH KEY OBJEK = WA_ORDS-OBJEK
                                   ATNAM = 'PD_AA_WITNESS_INSPECTION'
                                   BINARY SEARCH.
    IF SY-SUBRC = 0.
      G_ITSO_T-VALUE4 = WA_OVALS-ATWRT.
    ENDIF.

* 절연선심식별
    READ TABLE GT_ORDVALS INTO WA_OVALS
                          WITH KEY OBJEK = WA_ORDS-OBJEK
                                   ATNAM = 'PD_CA_INS_IDEN_CODE'
                                   BINARY SEARCH.
    IF SY-SUBRC = 0.
      G_ITSO_T-VALUE5 = WA_OVALS-ATWRT.
    ELSEIF G_ITSO_T-SPART = '24'.
      PERFORM GET_INS_IDEN.
    ENDIF.


* 튜브 인쇄사양
    READ TABLE GT_ORDVALS INTO WA_OVALS
                          WITH KEY OBJEK = WA_ORDS-OBJEK
                                   ATNAM = 'PD_TB_PRINT_APP'
                                   BINARY SEARCH.
    IF SY-SUBRC = 0.
      G_ITSO_T-VALUE6 = WA_OVALS-ATWRT.
    ENDIF.

*   STRIPE
    READ TABLE GT_ORDVALS INTO WA_OVALS
                          WITH KEY OBJEK = WA_ORDS-OBJEK
                                   ATNAM = 'PD_CA_COLOR_STRIPE'
                                   BINARY SEARCH.
    IF SY-SUBRC = 0.
      G_ITSO_T-VALUE7 = WA_OVALS-ATWRT.
    ENDIF.

*   띄줄수
    READ TABLE GT_ORDVALS INTO WA_OVALS
                          WITH KEY OBJEK = WA_ORDS-OBJEK
                                   ATNAM = 'PD_CA_COLOR_STRIPE_NO'
                                   BINARY SEARCH.
    IF SY-SUBRC = 0.
      G_ITSO_T-VALUE8 = WA_OVALS-ATWRT.
    ENDIF.
  ENDIF.

ENDFORM.                    " query_char_value_rtn
*&---------------------------------------------------------------------*
*& Form GET_PRODH_DESC
*&---------------------------------------------------------------------*
*& SRM2404-10815 - 추가
*&---------------------------------------------------------------------*
FORM GET_PRODH_DESC  USING    PV_PRODH
                     CHANGING PV_VTEXT.

  CLEAR : PV_VTEXT.

  CHECK PV_PRODH IS NOT INITIAL.

  READ TABLE GT_T179T WITH KEY PRODH = PV_PRODH
                               BINARY SEARCH.
  IF SY-SUBRC <> 0.
    CLEAR : GT_T179T.

    GT_T179T-PRODH = PV_PRODH.

    SELECT SINGLE VTEXT
      INTO GT_T179T-VTEXT
      FROM T179T
     WHERE SPRAS = SY-LANGU
       AND PRODH = GT_T179T-PRODH.

    APPEND GT_T179T.

    SORT GT_T179T BY PRODH.
  ENDIF.

  IF SY-SUBRC = 0.
    PV_VTEXT = GT_T179T-VTEXT.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form  GET_PARTNER_NAME
*&---------------------------------------------------------------------*
*& SRM2404-10815 - 추가
*&---------------------------------------------------------------------*
FORM GET_PARTNER_NAME  USING    PV_VBELN
                                PV_POSNR
                                PV_PARVW
                       CHANGING PV_KUNNR
                                PV_NAME1.

  READ TABLE GT_VBPA WITH KEY VBELN = PV_VBELN
                              POSNR = PV_POSNR
                              PARVW = PV_PARVW
                              BINARY SEARCH.
  IF SY-SUBRC <> 0.
    READ TABLE GT_VBPA WITH KEY VBELN = PV_VBELN
                                POSNR = '000000'
                                PARVW = PV_PARVW
                                BINARY SEARCH.
  ENDIF.

  IF SY-SUBRC = 0.
    IF GT_VBPA-KUNNR IS NOT INITIAL.
      PV_KUNNR = GT_VBPA-KUNNR.
      IF GT_VBPA-NAMAD IS NOT INITIAL.
        PV_NAME1 = GT_VBPA-NAMAD.
      ELSE.
        PV_NAME1 = GT_VBPA-NAME1.
      ENDIF.
    ELSE.
      PV_KUNNR = GT_VBPA-LIFNR.
      IF GT_VBPA-NAMAD IS NOT INITIAL.
        PV_NAME1 = GT_VBPA-NAMAD.
      ELSE.
        PV_NAME1 = GT_VBPA-NAME2.
      ENDIF.
    ENDIF.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_LAST_DELIVERY_DATE
*&---------------------------------------------------------------------*
*& SRM2404-10815 - 추가
*&---------------------------------------------------------------------*
FORM GET_LAST_DELIVERY_DATE  USING    PV_VBELN
                                      PV_POSNR
                             CHANGING PV_EDATU.

  READ TABLE GT_VBEP WITH KEY VBELN = PV_VBELN
                              POSNR = PV_POSNR
                              BINARY SEARCH.
  IF SY-SUBRC <> 0.
    CLEAR : GT_VBEP.

    GT_VBEP-VBELN = PV_VBELN.
    GT_VBEP-POSNR = PV_POSNR.

    SELECT SINGLE EDATU
      INTO GT_VBEP-EDATU
      FROM VBEP
     WHERE VBELN = PV_VBELN
       AND POSNR = PV_POSNR
       AND ETENR = ( SELECT MAX( ETENR )
                       FROM VBEP
                      WHERE VBELN = PV_VBELN
                        AND POSNR = PV_POSNR ).

    APPEND GT_VBEP.

    SORT GT_VBEP BY VBELN POSNR.
  ENDIF.

  IF SY-SUBRC = 0.
    PV_EDATU = GT_VBEP-EDATU.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_MATNR_DESC
*&---------------------------------------------------------------------*
*& SRM2404-10815 - 추가
*&---------------------------------------------------------------------*
FORM GET_MATNR_DESC  USING    PV_MATNR
                     CHANGING PV_MAKTX.

  READ TABLE GT_MARA WITH KEY MATNR = PV_MATNR
                              BINARY SEARCH.
  IF SY-SUBRC <> 0.
    CLEAR : GT_MARA.

    GT_MARA-MATNR = PV_MATNR.

    SELECT SINGLE B~MAKTX
      INTO GT_MARA-MAKTX
      FROM MARA AS A
     INNER JOIN MAKT AS B
        ON A~MATNR = B~MATNR
       AND B~SPRAS = SY-LANGU
     WHERE A~MATNR = PV_MATNR.

    APPEND GT_MARA.

    SORT GT_MARA BY MATNR.
  ENDIF.

  IF SY-SUBRC = 0.
    PV_MAKTX = GT_MARA-MAKTX.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_ABGRU_DESC
*&---------------------------------------------------------------------*
*& SRM2404-10815 - 추가
*&---------------------------------------------------------------------*
FORM GET_ABGRU_DESC  USING    PV_ABGRU
                     CHANGING PV_BEZEI.

  CLEAR : PV_BEZEI.

  CHECK PV_ABGRU IS NOT INITIAL.

  READ TABLE GT_TVAGT WITH KEY ABGRU = PV_ABGRU
                               BINARY SEARCH.
  IF SY-SUBRC <> 0.
    CLEAR : GT_TVAGT.

    GT_TVAGT-ABGRU = PV_ABGRU.

    SELECT SINGLE BEZEI
      INTO GT_TVAGT-BEZEI
      FROM TVAGT
     WHERE SPRAS = SY-LANGU
       AND ABGRU = PV_ABGRU.

    APPEND GT_TVAGT.

    SORT GT_TVAGT BY ABGRU.
  ENDIF.

  IF SY-SUBRC = 0.
    PV_BEZEI = GT_TVAGT-BEZEI.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_grade_data
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM GET_GRADE_DATA .

  CHECK G_ITAB_T[] IS NOT INITIAL.

  DATA LV_ATINN  TYPE ATINN.
  DATA: BEGIN OF LT_GRADE OCCURS 0,
          VBELN     TYPE VBELN,
          POSNR     TYPE POSNR,
          WERKS     TYPE WERKS_D,
          SCR_GRADE TYPE ATWRT,
        END   OF LT_GRADE.

  CALL FUNCTION 'CONVERSION_EXIT_ATINN_INPUT'
    EXPORTING
      INPUT  = 'ZBT_AA_GRADE'
    IMPORTING
      OUTPUT = LV_ATINN.


  SELECT VBELN,
         POSNR,
         WERKS,
         ATWRT AS SCR_GRADE
    INTO TABLE @LT_GRADE
    FROM ZGTMM_CV_BD_GET_VCOFSO
     FOR ALL ENTRIES IN @G_ITAB_T
   WHERE VBELN EQ @G_ITAB_T-VBELN
     AND POSNR EQ @G_ITAB_T-POSNR
     AND WERKS EQ @G_ITAB_T-WERKS
     AND ATINN EQ @LV_ATINN.

  SORT LT_GRADE BY VBELN POSNR WERKS.

  CHECK LT_GRADE[] IS NOT INITIAL.

  LOOP AT G_ITAB_T.

*___등급 추가
    READ TABLE LT_GRADE WITH KEY VBELN = G_ITAB_T-VBELN
                                 POSNR = G_ITAB_T-POSNR
                                 WERKS = G_ITAB_T-WERKS
                                 BINARY SEARCH.
    IF SY-SUBRC = 0.
      G_ITAB_T-SCR_GRADE = LT_GRADE-SCR_GRADE.
    ENDIF.

    MODIFY G_ITAB_T.

  ENDLOOP.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_DEFAULT_DATE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_DEFAULT_DATE .
  DATA: LV_DATE_FR TYPE SY-DATUM,
        LV_DATE_TO TYPE SY-DATUM.

  LV_DATE_FR = SY-DATLO.
  LV_DATE_FR+6(2) = '01'.

  LV_DATE_TO = LV_DATE_FR.
  LV_DATE_TO = ZGTSD_CL_COMMON2=>GET_LAST_DAY_MONTH( IV_DATE = LV_DATE_TO ).
  LV_DATE_TO = LV_DATE_TO + 1.
  LV_DATE_TO = ZGTSD_CL_COMMON2=>GET_LAST_DAY_MONTH( IV_DATE = LV_DATE_TO ).

  APPEND VALUE #( SIGN = 'I' OPTION = 'BT'
                  LOW  = LV_DATE_FR HIGH = LV_DATE_TO )
      TO SO_EDATU.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_DEFAULT_ORG
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_DEFAULT_ORG .
*-유통경로
  APPEND VALUE #( SIGN = 'I' OPTION = 'BT'
                  LOW = GC_VTWEG_10 HIGH = GC_VTWEG_50 )
      TO SO_VTWEG.

*-제품군
  APPEND VALUE #( SIGN = 'I' OPTION = 'EQ'  LOW = GC_SPART_3C ) TO SO_SPART.
  APPEND VALUE #( SIGN = 'I' OPTION = 'EQ'  LOW = GC_SPART_4C ) TO SO_SPART.
  APPEND VALUE #( SIGN = 'I' OPTION = 'EQ'  LOW = GC_SPART_90 ) TO SO_SPART.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form MAIN
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM MAIN .
** mto, mts 관련 라디오 버튼 값에 따라 특별재고 지시자의 값을 넣어줌
  PERFORM FILL_SOBKZ.

*  IF P_NEW = 'X'.
    PERFORM FILL_ITAB.           "DATA SELECT
*  ELSE.
*    PERFORM FILL_ITAB_OLD.       "DATA SELECT
*  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form DISPLAY
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM DISPLAY .
  READ TABLE G_ITAB_T INDEX 1.

  IF  SY-SUBRC <> 0.
    MESSAGE S004 WITH '조건에 해당하는 데이타가 없습니다.'.
  ELSE.
    PERFORM WRITE_ITAB.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form F4_VKBUR
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&---------------------------------------------------------------------*
FORM F4_VKBUR  USING    PV_FNAME.

  SELECT DISTINCT A~VKBUR,B~BEZEI
    FROM TVKBZ AS A INNER JOIN TVKBT AS B
                    ON A~VKBUR = B~VKBUR

   WHERE A~VKORG EQ @PA_VKORG
    INTO TABLE @DATA(LT_VALUE).
  SORT LT_VALUE BY VKBUR.
  CHECK LT_VALUE[] IS NOT INITIAL.

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      RETFIELD        = 'VKBUR'
      DYNPPROG        = SY-CPROG
      DYNPNR          = SY-DYNNR
      DYNPROFIELD     = PV_FNAME
      VALUE_ORG       = 'S'
    TABLES
      VALUE_TAB       = LT_VALUE
    EXCEPTIONS
      PARAMETER_ERROR = 1
      NO_VALUES_FOUND = 2
      OTHERS          = 3.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form F4_VKGRP
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&---------------------------------------------------------------------*
FORM F4_VKGRP  USING   PV_FNAME.
  RANGES: LR_VKBUR FOR VBAK-VKBUR.

  LR_VKBUR[] = CORRESPONDING #( SO_VKBUR[] ).

  SELECT DISTINCT A~VKBUR,B~BEZEI,A~VKGRP,C~BEZEI AS VKGRP_TXT
    FROM TVKBZ AS H INNER JOIN TVBVK AS A
                    ON H~VKBUR = A~VKBUR
                    INNER JOIN TVKBT AS B
                    ON A~VKBUR = B~VKBUR AND
                       B~SPRAS = @SY-LANGU
                    INNER JOIN TVGRT AS C
                    ON A~VKGRP = C~VKGRP AND
                       C~SPRAS = @SY-LANGU
   WHERE H~VKORG EQ @PA_VKORG
     AND A~VKBUR IN @LR_VKBUR
    INTO TABLE @DATA(LT_VALUE).

  SORT LT_VALUE BY VKBUR.

  CHECK LT_VALUE[] IS NOT INITIAL.

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      RETFIELD        = 'VKGRP'
      DYNPPROG        = SY-CPROG
      DYNPNR          = SY-DYNNR
      DYNPROFIELD     = PV_FNAME
      VALUE_ORG       = 'S'
    TABLES
      VALUE_TAB       = LT_VALUE
    EXCEPTIONS
      PARAMETER_ERROR = 1
      NO_VALUES_FOUND = 2
      OTHERS          = 3.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CALL_VI03
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_SELFIELD_VALUE
*&---------------------------------------------------------------------*
FORM CALL_VI03  USING    P_VALUE.

  CHECK P_VALUE NE SPACE.

* PARAMETER SETTING
  SET PARAMETER ID: 'FKK'    FIELD   P_VALUE.

* CALL TRANSACTION
  CALL   TRANSACTION  'VI03' WITH AUTHORITY-CHECK AND SKIP FIRST SCREEN.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_TKNUM_SEA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_TKNUM_SEA .
  CLEAR: GT_VTTK_SEA,GT_VTTK_SEA[].

  CHECK G_ITAB_T[] IS NOT INITIAL.

  DATA(LT_TEMP) = G_ITAB_T[].
  DELETE LT_TEMP WHERE VBELN_VL IS INITIAL.
  SORT LT_TEMP BY VBELN_VL.
  DELETE ADJACENT DUPLICATES FROM LT_TEMP COMPARING VBELN_VL.
  CHECK LT_TEMP[] IS NOT INITIAL.

  SELECT A~VBELN,A~TKNUM,B~SHTYP,
         C~VSBED
    FROM VTTP AS A INNER JOIN VTTK AS B
                   ON A~TKNUM = B~TKNUM AND
                      B~SHTYP = 'Z103'
                   INNER JOIN LIKP AS C
                   ON A~VBELN = C~VBELN
     FOR ALL ENTRIES IN @LT_TEMP
   WHERE A~VBELN EQ @LT_TEMP-VBELN_VL
     AND C~VSBED IN ('03','04')
    INTO CORRESPONDING FIELDS OF TABLE @GT_VTTK_SEA.
  SORT GT_VTTK_SEA BY VBELN TKNUM.

  IF GT_VTTK_SEA[] IS NOT INITIAL.
    LOOP AT G_ITAB_T ASSIGNING FIELD-SYMBOL(<FS_LINE>) WHERE VBELN_VL IS NOT INITIAL.
      READ TABLE GT_VTTK_SEA INTO DATA(LS_VTTK) WITH KEY VBELN =  <FS_LINE>-VBELN_VL
                                                BINARY SEARCH.
      IF SY-SUBRC EQ 0.
        <FS_LINE>-TKNUM_SEA = LS_VTTK-TKNUM.
      ENDIF.
    ENDLOOP.

  ENDIF.

  FREE:LT_TEMP.
ENDFORM.
