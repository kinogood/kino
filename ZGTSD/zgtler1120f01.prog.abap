*&---------------------------------------------------------------------*
*& Include          ZGTLER1120F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  initialization
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM INITIALIZATION .

  CLEAR: S_ERDAT[], S_ERDAT.

  CONCATENATE SY-DATUM+0(6) '01' INTO S_ERDAT-LOW.
  S_ERDAT-SIGN   = 'I'.
  S_ERDAT-OPTION = 'EQ'.
  S_ERDAT-HIGH   = SY-DATUM.
  APPEND S_ERDAT.

  REFRESH: R_LFART.
  PERFORM APPEND_LFART USING:
     'LF', 'LF7', 'ZLF7', 'LF8', 'LF9', 'LF10', 'NL' ,
     'LF4','LF2','ZLFS'.


  APPEND 'VBELN'  TO FTAB.
  APPEND 'VGBEL'  TO FTAB.

  "저장위치
  APPEND VALUE #( SIGN = 'I' OPTION = 'EQ' LOW = GC_LGORT_3410 )
      TO S_LGORT.
  APPEND VALUE #( SIGN = 'I' OPTION = 'EQ' LOW = GC_LGORT_3420 )
      TO S_LGORT.
  APPEND VALUE #( SIGN = 'I' OPTION = 'EQ' LOW = GC_LGORT_3430 )
      TO S_LGORT.

  PERFORM CHECK_SCREEN_MODIFY.
ENDFORM.                    " initialization
*&---------------------------------------------------------------------*
*&      Form  get_field_text
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM GET_FIELD_TEXT .

*출하지점
  PERFORM GET_VSTEL_TEXT(ZLER0002)   USING S_VSTEL-LOW
                        CHANGING PT_VSTEL.

*제품군(SPG)
  PERFORM GET_SPART_TEXT(ZLER0002)   USING S_SPART-LOW
                        CHANGING PT_SPART.

*납품처
  PERFORM GET_KUNNR_TEXT   USING S_KUNNR-LOW
                        CHANGING PT_KUNNR.

*판매처
  PERFORM GET_KUNNR_TEXT   USING S_KUNAG-LOW
                        CHANGING PT_KUNAG.

ENDFORM.                    " get_field_text
*&---------------------------------------------------------------------*
*&      Form  selection_screen_modify
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM SELECTION_SCREEN_MODIFY .

  LOOP AT SCREEN.
    CASE SCREEN-GROUP1.
      WHEN 'A'.
        SCREEN-INPUT  = 0.
        SCREEN-DISPLAY_3D = '0'.
        SCREEN-INTENSIFIED = 1.
    ENDCASE.

    IF SCREEN-NAME = 'PA_IMODE'.
      SCREEN-ACTIVE    = 0.
      SCREEN-INPUT     = 0.
      SCREEN-INVISIBLE = 1.
    ENDIF.

    IF SCREEN-NAME = '%_PA_IMODE_%_APP_%-TEXT'.
      SCREEN-ACTIVE    = 0.
      SCREEN-INPUT     = 0.
      SCREEN-INVISIBLE = 1.
    ENDIF.

    MODIFY SCREEN.
  ENDLOOP.

ENDFORM.                    " selection_screen_modify
*&---------------------------------------------------------------------*
*&      Form  data_query
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GT_LIKP  text
*      -->P_R_VBELN  text
*----------------------------------------------------------------------*
FORM DATA_QUERY  TABLES   PT_LIKP  LIKE GT_LIKP[]
                          PR_VBELN LIKE R_VBELN[].


  BDC_MODE =  PA_IMODE.

  SELECT K~VBELN
         K~KUNNR
         K~KUNAG
         K~ERDAT
         K~ERNAM
         K~WADAT_IST AS WADAT
         K~WADAT AS WADAT2
         K~ROUTE
         K~KOSTK
         K~CMGST
         K~LFART
         K~VSART
         K~VSTEL
*        ex~fidno

     INTO CORRESPONDING FIELDS OF TABLE PT_LIKP
     FROM LIKP AS K INNER JOIN LIPS AS P
                    ON K~VBELN = P~VBELN
*                    LEFT OUTER JOIN ztetfdp AS ex
*                    ON k~vbeln = ex~vbeln

      WHERE K~ERDAT IN S_ERDAT
        AND K~WADAT IN S_WADAT
        AND K~VSTEL IN S_VSTEL
        AND K~VKORG EQ GC_VKORG_6000
        AND K~KUNAG IN S_KUNAG
        AND K~KUNNR IN S_KUNNR
        AND K~VBELN IN S_VBELN
        AND K~VBELN IN PR_VBELN
        AND K~LIFSK NE GC_LIFSK_G3       "적송
        AND P~VTWEG IN S_VTWEG
        AND P~WERKS IN S_WERKS
        AND P~LGORT IN S_LGORT
        AND K~ROUTE IN S_ROUTE
        AND P~LGORT NE GC_LGORT_3499     "적송
        AND P~ZZVBELN_JS EQ SPACE        "적송
        AND K~WBSTK <> 'C'
        AND K~LIFSK EQ SPACE
        AND ( K~LFART LIKE 'LF%'  OR
              K~LFART LIKE 'ZLF%' OR
              K~LFART = 'NL' )
        AND NOT EXISTS ( SELECT VBELN              "적송
                           FROM ZGTSDT9110
                          WHERE VBELN EQ K~VBELN
                            AND LOEVM EQ SPACE    ).



  SORT PT_LIKP.
  DELETE ADJACENT DUPLICATES FROM PT_LIKP.


  DELETE PT_LIKP WHERE LFART = 'LF3'.

  IF NOT S_SPART[] IS INITIAL.
    LOOP AT PT_LIKP.
      SELECT SINGLE MANDT INTO SY-MANDT FROM LIPS
        WHERE VBELN = PT_LIKP-VBELN
          AND SPART IN S_SPART.
      IF SY-SUBRC <> 0.
        DELETE PT_LIKP. CONTINUE.
      ENDIF.
    ENDLOOP.
  ENDIF.

*/ data ~ modify
  CHECK NOT PT_LIKP[] IS INITIAL.

  DATA: LT_LIKP  LIKE LIKP  OCCURS 0 WITH HEADER LINE.
  DATA: LT_KNA1  LIKE KNA1  OCCURS 0 WITH HEADER LINE.
  DATA: LT_TVROT LIKE TVROT OCCURS 0 WITH HEADER LINE.
  DATA: LV_WERKS LIKE LIPS-WERKS. "SRM2202-09416

** 납품처
*  SELECT * INTO TABLE lt_kna1
*    FROM kna1
*     FOR ALL ENTRIES IN pt_likp
*   WHERE kunnr = pt_likp-kunnr.
* 운송경로
  SELECT * INTO TABLE LT_TVROT
    FROM TVROT
   WHERE SPRAS = SY-LANGU.

  SORT LT_KNA1 .
  SORT LT_TVROT.

*-거래명세서 : ZLET0006
  DATA(LT_TEMP) = PT_LIKP[].
  SORT LT_TEMP BY VBELN.
  DELETE ADJACENT DUPLICATES FROM LT_TEMP COMPARING VBELN.


  IF LT_TEMP[] IS NOT INITIAL.

*- 수출문서
    SELECT A~VBELN
      FROM @LT_TEMP AS A INNER JOIN ZTETFDP AS B
                         ON A~VBELN EQ B~VBELN
     GROUP BY A~VBELN
     INTO TABLE @DATA(LT_EX).

    SORT LT_EX BY VBELN.
    DELETE ADJACENT DUPLICATES FROM LT_EX COMPARING VBELN.

*    SELECT DISTINCT a~vbeln, a~iv_no, b~out_yn
*      FROM zlet0006 AS a INNER JOIN zlet0005 AS b
*                         ON a~iv_no = b~iv_no
*       FOR ALL ENTRIES IN @lt_temp
*     WHERE a~vbeln EQ @lt_temp-vbeln
*       AND b~iv_cancel_yn EQ @abap_false
*      INTO TABLE @DATA(lt_zlet0006).
*    SORT lt_zlet0006 BY vbeln.
*- 거래명세서
    SELECT DISTINCT VBELN, IV_NO, OUT_YN
      FROM ZGTSD_I_VALID_INV_ITEM
      FOR ALL ENTRIES IN @LT_TEMP
     WHERE VBELN EQ @LT_TEMP-VBELN
      INTO TABLE @DATA(LT_ZLET0006).
    SORT LT_ZLET0006 BY VBELN.
  ENDIF.

*-선적문서
  CLEAR:LT_TEMP[].
  LT_TEMP[] = PT_LIKP[].
  SORT LT_TEMP BY VBELN.
  DELETE ADJACENT DUPLICATES FROM LT_TEMP COMPARING VBELN.
  IF LT_TEMP[] IS NOT INITIAL.
    SELECT A~TKNUM,A~VBELN,B~SHTYP
      FROM VTTP AS A INNER JOIN VTTK AS B
                     ON A~TKNUM = B~TKNUM
       FOR ALL ENTRIES IN @LT_TEMP
     WHERE A~VBELN EQ @LT_TEMP-VBELN
       AND B~SHTYP NE 'Z103'
      INTO TABLE @DATA(LT_VTTP).
    SORT LT_VTTP BY VBELN TKNUM.
  ENDIF.

  CLEAR: GV_TRACTOR.
  LOOP AT PT_LIKP.
    DATA(LV_INDEX) = SY-TABIX.

*** ADD BY HKSEO 2019.02.13
    IF ( PT_LIKP-VSTEL  >= 'M620'   AND
         PT_LIKP-VSTEL  <= 'M629' )  OR
       ( PT_LIKP-VSTEL   = 'M676' ).
      GV_TRACTOR  = 'X'.
    ENDIF.
***

* 판매처
    SELECT SINGLE NAME1 INTO PT_LIKP-KUNAG_T FROM KNA1
      WHERE KUNNR = PT_LIKP-KUNAG.
** 거래처
    DATA: LV_ADRNR  LIKE VBPA-ADRNR.

    SELECT SINGLE ADRNR INTO LV_ADRNR
       FROM VBPA
      WHERE VBELN = PT_LIKP-VBELN
        AND POSNR = '000000'
        AND PARVW = 'WE'.
    SELECT SINGLE NAME1 INTO PT_LIKP-KUNNR_T
       FROM ADRC
      WHERE ADDRNUMBER = LV_ADRNR.

*    READ TABLE lt_kna1  WITH KEY kunnr = pt_likp-kunnr
*              BINARY SEARCH.
*    IF sy-subrc = 0.
*      pt_likp-kunnr_t = lt_kna1-name1.
*    ENDIF.
* 운송경로
    READ TABLE LT_TVROT WITH KEY ROUTE = PT_LIKP-ROUTE
             BINARY SEARCH.
    IF SY-SUBRC = 0.
      PT_LIKP-ROUTE_T = LT_TVROT-BEZEI.
    ENDIF.

    SELECT SINGLE BEZEI INTO PT_LIKP-VSART_T FROM T173T
      WHERE SPRAS = '3'
        AND VSART = PT_LIKP-VSART.

    PT_LIKP-WADAT_IST = SY-DATUM.


* [START] CSR No : C20091028_48918
* BCKOO 091209 TABLE Control화면(첫화면)에 자재코드,자재명 추가
    SELECT SINGLE MATNR ARKTX WERKS "SRM2202-09416 플랜트 추가
                  VGBEL
      INTO (PT_LIKP-MATNR, PT_LIKP-ARKTX, LV_WERKS, PT_LIKP-VGBEL )
      FROM LIPS
     WHERE VBELN = PT_LIKP-VBELN.

* [END]   CSR No : C20091028_48918

*{ SRM2202-09416 - s
    SELECT SINGLE MATGR INTO PT_LIKP-MATGR
      FROM MARC
     WHERE MATNR = PT_LIKP-MATNR
       AND WERKS = LV_WERKS.
*} SRM2202-09416 - e

*   거래명세서 번호
*    pt_likp-iv_no = VALUE #( lt_zlet0006[ vbeln = pt_likp-vbeln ]-iv_no OPTIONAL ).
    DATA(LS_IV) = VALUE #( LT_ZLET0006[ VBELN = PT_LIKP-VBELN ] OPTIONAL ).
    IF LS_IV-IV_NO IN S_IVNUM.
      PT_LIKP-IV_NO = LS_IV-IV_NO.
      PT_LIKP-OUT_YN = COND #( WHEN LS_IV-OUT_YN IS NOT INITIAL
                                 THEN 'O' ELSE SPACE ).
    ELSE.
      DELETE PT_LIKP INDEX LV_INDEX.
      CONTINUE.
    ENDIF.

*   선적번호
    READ TABLE LT_VTTP INTO DATA(LS_VTTP) WITH KEY VBELN = PT_LIKP-VBELN
                                          BINARY SEARCH.
    IF SY-SUBRC EQ 0.
      PT_LIKP-TKNUM = LS_VTTP-TKNUM.
    ENDIF.

    IF NOT PT_LIKP-TKNUM IN S_TKNUM.
      DELETE PT_LIKP INDEX LV_INDEX.
      CONTINUE.
    ENDIF.

*   L/C 등록 여부

    SELECT SINGLE A~KDKG4, B~VTWEG INTO ( @DATA(LV_LC), @DATA(LV_VTWEG) )
      FROM VBKD AS A INNER JOIN VBAK AS B
                     ON A~VBELN = B~VBELN
     WHERE A~VBELN EQ @PT_LIKP-VGBEL
       AND A~POSNR EQ '000000'.

    IF LV_VTWEG EQ '50' OR LV_LC EQ '4S'.
      READ TABLE LT_EX INTO DATA(LS_EX) WITH KEY VBELN = PT_LIKP-VBELN.
      IF SY-SUBRC EQ 0.
        PT_LIKP-FIDNO = 'O'.
      ELSE.
        PT_LIKP-FIDNO = 'X'.
      ENDIF.
*      pt_likp-fidno = COND #( WHEN pt_likp-fidno IS NOT INITIAL THEN 'O'
*                             ELSE 'X' ).
    ENDIF.

    MODIFY PT_LIKP.

    CLEAR:LV_INDEX,LS_IV,LS_VTTP.
  ENDLOOP.

  SORT PT_LIKP .

*** ADD BY HKSEO 2019.02.14  PDI 필드는 트렉터에서만 볼수 있도록 셋팅.
  IF  GV_TRACTOR  = 'X'.
    UPDATE TCVIEW  SET: TCINVISIBL  = ''
                  WHERE TCPROGRAM   = SY-REPID
*                    AND TCUSER      = SY-UNAME
                    AND ( TCFIELDNAM  = 'XT_NASG-ICON2'
                       OR TCFIELDNAM  = 'XT_ASSG-ICON2' )
                    .
  ELSE.
    UPDATE TCVIEW  SET: TCINVISIBL  = 'X'
                  WHERE TCPROGRAM   = SY-REPID
*                    AND TCUSER      = SY-UNAME
                    AND ( TCFIELDNAM  = 'XT_NASG-ICON2'
                       OR TCFIELDNAM  = 'XT_ASSG-ICON2' )
                    .
  ENDIF.
  COMMIT WORK.
***

  FREE:LT_TEMP,LS_IV,LS_VTTP,LT_ZLET0006.
ENDFORM.                    " data_query
*&---------------------------------------------------------------------*
*&      Form  get_kunnr_text
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_S_KUNNR_LOW  text
*      <--P_PT_KUNNR  text
*----------------------------------------------------------------------*
FORM GET_KUNNR_TEXT  USING    P_KUNNR
                     CHANGING P_NAME.

  SELECT SINGLE NAME1 INTO P_NAME
    FROM KNA1
   WHERE KUNNR = P_KUNNR.


ENDFORM.                    " get_kunnr_text
*&---------------------------------------------------------------------*
*&      Form  get_route_text
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GT_LIKP_ROUTE  text
*      <--P_GT_LIKP_ROUTE_T  text
*----------------------------------------------------------------------*
FORM GET_ROUTE_TEXT  USING    P_ROUTE
                     CHANGING P_ROUTE_T.

  SELECT SINGLE BEZEI INTO P_ROUTE_T FROM TVROT
    WHERE ROUTE = P_ROUTE
      AND SPRAS = SY-LANGU.
  IF SY-SUBRC <> 0.
    MESSAGE E000 WITH '존재하지 않는 ROUTE입니다.'.
  ENDIF.


ENDFORM.                    " get_route_text
*&---------------------------------------------------------------------*
*&      Form  refresh
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM REFRESH .

  CLEAR: GT_LIKP[], GT_LIKP, R_VBELN[], R_VBELN.
  PERFORM DATA_QUERY TABLES GT_LIKP
                            R_VBELN.

ENDFORM.                    " refresh
*&---------------------------------------------------------------------*
*&      Form  sort_likp
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM SORT_LIKP .

  DATA: LV_FIELD(30).
  LV_FIELD = G_CURSOR_FIELD+8(12).

  IF SAVE_OK = 'ASCD'.
    SORT GT_LIKP BY (LV_FIELD) ASCENDING.
  ELSE.
    SORT GT_LIKP BY (LV_FIELD) DESCENDING.
  ENDIF.

ENDFORM.                    " sort_likp
*&---------------------------------------------------------------------*
*&      Form  get_detail
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM GET_DETAIL .

  REFRESH: CONTROL 'TC02' FROM SCREEN '0200',
           CONTROL 'TC12' FROM SCREEN '0300',
           CONTROL 'TC03' FROM SCREEN '0200',
           CONTROL 'TC13' FROM SCREEN '0300',
           CONTROL 'TC04' FROM SCREEN '0200',
           CONTROL 'TC14' FROM SCREEN '0300'.

  DATA: LV_WERKS LIKE LIPS-WERKS,
        LV_LGORT LIKE LIPS-LGORT.

  CLEAR: LV_XHUPF, LV_WERKS, LV_LGORT, P_QIQTY, P_VRKME,
         GV_SERIAL.                "기능개선 157076 - 추가

  REFRESH: GT_SHIP.
  CLEAR  : GT_SHIP.

*/ read gt_lips index.
  IF GV_SAVE_FLAG = ' '.
    I_CURSOR_LINE = TC01-CURRENT_LINE + I_CURSOR_LINE - 1.
    READ TABLE GT_LIKP INDEX I_CURSOR_LINE.
    GV_LINE = I_CURSOR_LINE.
  ELSE.
    READ TABLE GT_LIKP INDEX GV_LINE.
    GV_SAVE_FLAG = 'X'.
  ENDIF.

*/ lock
  PERFORM ENQUENE_DO USING GT_LIKP-VBELN.

*/ WMS 창고는 관련없음.
  PERFORM CHECK_WMS_STORAGE.

*/ DEFAULT VALUE SET
  PERFORM DEFAULT_VALUE_SET.

*/ HU 사용, 미사용 구분
  SELECT SINGLE WERKS LGORT
    INTO (LV_WERKS, LV_LGORT) FROM LIPS
   WHERE VBELN = GT_LIKP-VBELN
     AND LGORT <> ' '.
  IF SY-SUBRC = 0.
    SELECT SINGLE XHUPF INTO LV_XHUPF FROM T001L
      WHERE WERKS = LV_WERKS
        AND LGORT = LV_LGORT.
    IF SY-SUBRC = 0.
      IF GT_LIKP-CMGST = 'B' OR
         GT_LIKP-CMGST = 'C'.
        MESSAGE I000 WITH '여신보류되었습니다'.
      ENDIF.

      IF LV_XHUPF = 'X'.
        PERFORM MAKE_DATA_HU.
*      CALL SCREEN 200.
      ELSE.
        PERFORM MAKE_DATA_HU_NO.
*      CALL SCREEN 300.
      ENDIF.
    ELSE.
      PERFORM MAKE_DATA_HU_NO.
      LV_XHUPF = ' '.
*   MESSAGE s000 WITH '품목이 없습니다'.
    ENDIF.
  ELSE.
    PERFORM MAKE_DATA_HU_NO.
    LV_XHUPF = ' '.
  ENDIF.

ENDFORM.                    " get_detail
*&---------------------------------------------------------------------*
*&      Form  CHECK_WMS_STORAGE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM CHECK_WMS_STORAGE .

  DATA: LT_LIPS LIKE LIPS OCCURS 0 WITH HEADER LINE.

  SELECT * INTO CORRESPONDING FIELDS OF TABLE LT_LIPS
   FROM LIPS
  WHERE VBELN = GT_LIKP-VBELN.   "p_vbeln.

  LOOP AT LT_LIPS .
    SELECT SINGLE MANDT INTO SY-MANDT FROM T320
      WHERE WERKS = LT_LIPS-WERKS
        AND LGORT = LT_LIPS-LGORT.
    IF SY-SUBRC = 0.
      PERFORM DEQUEUE_ALL.
      MESSAGE I000 WITH
       'WMS 창고입니다. 관련사항 없습니다'.
      LEAVE SCREEN.
    ENDIF.
  ENDLOOP.

ENDFORM.                    " CHECK_WMS_STORAGE
*&---------------------------------------------------------------------*
*&      Form  DEFAULT_VALUE_SET
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM DEFAULT_VALUE_SET .

  P_VBELN       = GT_LIKP-VBELN.
  P_KOSTK       = GT_LIKP-KOSTK.
  P_KUNNR       = GT_LIKP-KUNNR.
  P_KUNNR_T     = GT_LIKP-KUNNR_T.
  P_KUNAG       = GT_LIKP-KUNAG.
  P_KUNAG_T     = GT_LIKP-KUNAG_T.
  P_WADAT_IST   = GT_LIKP-WADAT_IST.
  TVROT-ROUTE   = GT_LIKP-ROUTE.
  TVROT-BEZEI   = GT_LIKP-ROUTE_T.
  T173T-VSART   = GT_LIKP-VSART.
  T173T-BEZEI   = GT_LIKP-VSART_T.

  P_WADAT   = GT_LIKP-WADAT2.

ENDFORM.                    " DEFAULT_VALUE_SET
*&---------------------------------------------------------------------*
*&      Form  MAKE_DATA_HU
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM MAKE_DATA_HU .

*/ select ~ lips
  SELECT * INTO CORRESPONDING FIELDS OF TABLE GL_LIPS
    FROM LIPS
   WHERE VBELN = P_VBELN.

*/ 품목상태
  PERFORM GET_STATUS_LIPS.

*/ 지시수량(jisiqty): 현재납품수량,
*  지정수량(delqty) : 배치사용(배치지정수량), 배치미사용(포장수량)
  PERFORM GET_JISIQTY_DELQTY.

*/ 미결수량, 납품가능량
  PERFORM GET_MIGUL_LFIMG.

*/ 제품특성
  PERFORM GET_SO_CHARACTERISTIC.

*/ SHIPPING NO
  PERFORM READ_TEXT_SHIP_NO.

*/ 포장정보
  PERFORM GET_GL_VEPO_HU.

*/ 배치특성(정렬순서: CU72)
  PERFORM BATCH_SORT_CHAR_200.

*/ 단위환산: 판매단위와 재고단위가 다를 경우.
  PERFORM CONVERSION_UNIT_200.

*/ 지정수량
  PERFORM GET_DELQTY_200.

*/ 지정할수 없는 품목이 있는지, 점검.
*  PERFORM cannot_assign.

* 모두 지정되었는지 점검: 모두 지정되엇으면, 피킹 가능
  PERFORM CHECK_PICKING_POSSIBE.

  CL_LIPS[] = GL_LIPS[].
  CL_VEPO[] = GL_VEPO[].


ENDFORM.                    " MAKE_DATA_HU
*&---------------------------------------------------------------------*
*&      Form  set_gt_lips
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM SET_GT_LIPS .

  SORT GL_LIPS BY ITEM1  "상위 OR 하위 품목 ( '1' OR '2' )
                  SUB
                  POSNR. "품목.

*/ 미지정수량
  WA_LIPS[] = GL_LIPS[].
  LOOP AT GL_LIPS WHERE SUB = '1'.
* 지시수량
    CLEAR: GV_JISIQTY, GV_DELQTY.
    LOOP AT WA_LIPS WHERE ITEM1 = GL_LIPS-ITEM1.
      ADD WA_LIPS-JISIQTY TO GV_JISIQTY.
      ADD WA_LIPS-DELQTY  TO GV_DELQTY.
    ENDLOOP.

* 미지정수량
    GL_LIPS-NDELQTY = GV_JISIQTY - GV_DELQTY.
    MODIFY GL_LIPS TRANSPORTING NDELQTY.
  ENDLOOP.

* 납품미지정재고에 헤더에 있는 미지정재고 수량을 할당
  READ TABLE GL_LIPS WITH KEY CHK = 'X'.
  LOOP AT XT_NASG WHERE ITEM1 = GL_LIPS-ITEM1
                   AND LABST > 0.
    IF GL_LIPS-NDELQTY < XT_NASG-LABST.
      XT_NASG-DELQTY = GL_LIPS-NDELQTY.
      MODIFY XT_NASG.
    ELSE.
      XT_NASG-DELQTY = XT_NASG-LABST.
      MODIFY XT_NASG.
    ENDIF.
  ENDLOOP.

* 20070613 SDB03 BonChan Koo
* 전선 조장 제상품일경우 납품미지정 재고의 재고수량에
* 동일 조장 재고에만 디폴트 지정조장수/수량체크
* 재고 정렬순서 : 동일조장>큰조장>작은조장순으로(동일순위는 배치순으로)

*  IF S_VSTEL-LOW = '1400' OR
*     S_VSTEL-LOW = '1500' OR
*     S_VSTEL-LOW = '1600' OR
*     S_VSTEL-LOW = '3100' OR
*     S_VSTEL-LOW = '3200' OR
*     S_VSTEL-LOW = '3600' OR
*     S_VSTEL-LOW = '4400' OR
*     S_VSTEL-LOW = 'J100' OR
*     S_VSTEL-LOW = 'J200' .


* 20081212 BCKOO
* 전선제품의 경우 현재 자재유형 mcfe,mcha인경우 디폴트 재고지정
*대상수량을 뿌려줌
* MCFE, MCHA 이외의 수탁임가공 제품에 대해서도 조장관리하는경우 발생
* 따라서 현재 자재유형으로 전선제품유무 체크를 주문특성의 조장에 값이
*있는경우로 변경
* CSR NUMBER : C20081119_60343
*  DATA : lv_atwrt  TYPE atwrt.
*  clear : lv_atwrt.
*  CALL FUNCTION 'Z_LE_GET_BATCH_CHARACTERISTIC'
*    EXPORTING
*      i_object = gl_lips-matnr
*      i_charg  = gl_lips-charg
*      i_atnam  = 'SAP_MILLCA_LENGTH'
*    IMPORTING
*      e_atwrt  = lv_atwrt.
*
*  if lv_atwrt is not initial.
*  if gl_lips-mtart = 'MCFE' or gl_lips-mtart = 'MCHA'.
  IF GL_LIPS-LENGTH > 0.

    LOOP AT XT_NASG.

*  CALL FUNCTION 'Z_LE_GET_BATCH_CHARACTERISTIC'
*    EXPORTING
*      i_object = gl_lips-matnr
*      i_charg  = gl_lips-charg
*      i_atnam  = 'SAP_MILLCA_LENGTH'
*    IMPORTING
*      e_atwrt  = lv_atwrt.


*      IF XT_NASG-LENGTH = GT_LIPS-LENGTH AND
*         XT_NASG-FACTOR = GT_LIPS-FACTOR.
      IF XT_NASG-LENGTH = GL_LIPS-LENGTH.
        IF XT_NASG-DELQTY IS INITIAL.
          CLEAR : XT_NASG-FACTOR1.
          MODIFY XT_NASG.

* Factor뱃치일경우 재고 조장수가 납품조장수보다 많을 경우
* 납품조장수 기준으로 디폴트값 셋팅
        ELSEIF XT_NASG-FACTOR > GL_LIPS-FACTOR.
          XT_NASG-FACTOR1 = GL_LIPS-FACTOR.
          MODIFY XT_NASG.
        ENDIF.
* 실제 조장수가 소수점을 가진 경우 소수점 절사
        IF XT_NASG-FACTOR1 <> 1.
          XT_NASG-FACTOR1 = FLOOR( XT_NASG-FACTOR1 ).
          IF XT_NASG-FACTOR1 < 1.
            CLEAR : XT_NASG-DELQTY.
          ENDIF.
          MODIFY XT_NASG.
        ENDIF.
      ELSE.
        CLEAR : XT_NASG-FACTOR1, XT_NASG-DELQTY.
        MODIFY XT_NASG.
      ENDIF.
* 같은 재고가 있다하더라도 미지정 재고 수량이 0이면 디폴트값은 0
      IF GL_LIPS-NDELQTY = 0.
        CLEAR : XT_NASG-FACTOR1, XT_NASG-DELQTY.
        MODIFY XT_NASG.
      ENDIF.

* C20081010_41314 BCKOO
* 081014
* 전선 조장 제품 디폴트 지정 대상수량을 조장의 배수 값으로 변경
* 일부 수량 재조 지정시 디폴프 지정대상수량은 납품수량보다 같거나 작아야
* 함
      DATA : LV_DELQTY LIKE XT_NASG-DELQTY.
      DATA : LV_LENGTH LIKE XT_NASG-LENGTH.
      DATA : LV_FACTOR LIKE XT_NASG-FACTOR.

      LV_DELQTY = XT_NASG-LENGTH * XT_NASG-FACTOR1.
      IF LV_DELQTY > XT_NASG-DELQTY.
        DO.
          XT_NASG-FACTOR1 = XT_NASG-FACTOR1 - 1.
          LV_DELQTY = XT_NASG-LENGTH * XT_NASG-FACTOR1.
          IF LV_DELQTY <= XT_NASG-DELQTY OR XT_NASG-FACTOR1 <= 0.
            XT_NASG-DELQTY = LV_DELQTY.
            MODIFY XT_NASG.
            EXIT.
          ENDIF.
        ENDDO.
*        lv_factor = xt_nasg-delqty / xt_nasg-length.
*        lv_factor = ceil( lv_factor ).
*        xt_nasg-factor1 = lv_factor.
*        xt_nasg-delqty = xt_nasg-length * lv_factor.
*        modify xt_nasg.
      ELSE.
        XT_NASG-DELQTY = XT_NASG-LENGTH * XT_NASG-FACTOR1.
        MODIFY XT_NASG.
      ENDIF.

    ENDLOOP.

    SORT XT_NASG BY DELQTY DESCENDING CHARG.
  ENDIF.
*  ENDIF.
* 20070613

  GT_LIPS[] = GL_LIPS[].

* 접기일때, 하위품목을 없앤다
  LOOP AT GT_LIPS WHERE ICON1 = C_ICON1.
    DELETE GT_LIPS WHERE ITEM1  = GT_LIPS-ITEM1
                     AND SUB    = '2'.
  ENDLOOP.

* 접기에서 데이타 집계
  LOOP AT GT_LIPS WHERE ICON1 = C_ICON1.
    CLEAR: GV_JISIQTY, GV_DELQTY.
    LOOP AT GL_LIPS WHERE ITEM1 = GT_LIPS-ITEM1.
*      ADD gl_lips-jisiqty TO gv_jisiqty.
      ADD GL_LIPS-DELQTY  TO GV_DELQTY.
    ENDLOOP.

*    gt_lips-jisiqty = gv_jisiqty.
    GT_LIPS-DELQTY  = GV_DELQTY.
    MODIFY GT_LIPS TRANSPORTING DELQTY .
  ENDLOOP.

  IF P_KOSTK = 'C'.
    P_KOSTK_T = '피킹완료'.
  ELSE.
    P_KOSTK_T = '피킹미완료'.

    LOOP AT SCREEN.
      CASE SCREEN-NAME .
        WHEN 'P_WADAT_IST'.
          SCREEN-INPUT = 0.
          MODIFY SCREEN.
      ENDCASE.
    ENDLOOP.
  ENDIF.

*-[CHG]-폭/약경/드럼무게,총중량-----------------------------S
  LOOP AT GT_LIPS ASSIGNING FIELD-SYMBOL(<FS_LIPS>).
    "폭/드럼
    "약경/드럼
    "드럼무게/개
    PERFORM GET_CBM_DATA CHANGING <FS_LIPS>.
    "총 중량(드럼포함)
    PERFORM GET_TOTAL_WEIGHT CHANGING <FS_LIPS>.
  ENDLOOP.
*-[CHG]-폭/약경/드럼무게,총중량-----------------------------E

* 20070430 Bon-Chan Koo
* 피킹완료,일련번호 미지정 = 출고전기 버튼 비활성,일련번호 버튼활성
* 피킹완료,일련번호지정 = 출고전기 버튼 활성,일련번호 버튼비활성

  IF S_VSTEL-LOW >= 'M600' AND S_VSTEL-LOW <= 'M799'.

    DATA : L_SERNP  LIKE MARC-SERNP VALUE ' '.
    DATA : LT_SER01 LIKE SER01 OCCURS 0 WITH HEADER LINE.
    DATA : L_POSNR  LIKE LIPS-POSNR.

    SELECT *
    INTO   TABLE LT_SER01
    FROM   SER01
    WHERE  LIEF_NR = GT_LIPS-VBELN.

    SORT LT_SER01 BY POSNR.

    LOOP AT GT_LIPS.
      SELECT SINGLE XCHPF FROM MARA
      INTO   L_SERNP
      WHERE  MATNR = GL_LIPS-MATNR
      AND    XCHPF = 'X'.
* 배치번호 사용유무 체크 / + SRM2202-09416 - 자재그루핑 추가
      IF SY-SUBRC = 0 .
        SELECT SINGLE SERNP MATGR FROM MARC
        INTO   (L_SERNP, GT_LIPS-MATGR)
        WHERE  MATNR = GL_LIPS-MATNR
        AND    WERKS = GL_LIPS-WERKS
        AND    SERNP <> ' '.
* 일련번호 사용유무 체크
        IF SY-SUBRC = 0.
          SELECT POSNR INTO L_POSNR
          FROM   LIPS
          WHERE  VBELN = GT_LIPS-VBELN
          AND    UECHA = GT_LIPS-POSNR.
            READ TABLE LT_SER01 WITH KEY POSNR = L_POSNR.
            IF SY-SUBRC <> 0.
              G_CHECK = 'X'.
            ENDIF.
          ENDSELECT.
        ENDIF.
* SRM2202-09416 자재그루핑 필드 추가
      ELSEIF GL_LIPS-WERKS = '3602'. "배치사용 안하고 플랜트3602
        SELECT SINGLE MATGR FROM MARC
        INTO   GT_LIPS-MATGR
        WHERE  MATNR = GL_LIPS-MATNR
        AND    WERKS = GL_LIPS-WERKS.
* SRM2202-09416
      ENDIF.
      MODIFY GT_LIPS TRANSPORTING MATGR. " SRM2202-09416
    ENDLOOP.
    CLEAR : L_SERNP,L_POSNR,LT_SER01,LT_SER01[].
  ENDIF.
ENDFORM.                    " set_gt_lips
*&---------------------------------------------------------------------*
*&      Form  get_so_characteristic
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM GET_SO_CHARACTERISTIC .
  DATA: PV_EBELN LIKE EKPO-EBELN.
  DATA: PV_EBELP LIKE EKPO-EBELP,
        LV_ATINN TYPE ATINN.

  DATA: LS_RETURN TYPE BAPIRET2_T.
  DATA: LT_CHAR   LIKE E1CUVAL OCCURS 0 WITH HEADER LINE.
  DATA: PV_LENGTH LIKE ZPPT0001-MGVRG.

  IF P_NEW = 'X'.

**특성값 컨버전
*    CALL FUNCTION 'CONVERSION_EXIT_ATINN_INPUT'
*      EXPORTING
*        input  = 'ZBT_AA_GRADE'
*      IMPORTING
*        output = lv_atinn.

    PERFORM GET_OTHER_DATA_COLLECTIVELY.

** 소재 사업부 SCR 8.0mm 등급
    DATA(LT_LIPS) = GL_LIPS[].

    SELECT A~MATNR, A~CHARG, A~WERKS, A~LGORT, B~ATWRT
      FROM @LT_LIPS AS A INNER JOIN ZGTSD_CV_GET_VCOFBATCH AS B
                            ON A~MATNR EQ B~MATNR
                           AND A~CHARG EQ B~CHARG
                           AND A~WERKS EQ B~WERKS
                           AND A~LGORT EQ B~LGORT
                           AND B~ATNAM EQ 'PD_CA_GRADE'
    INTO TABLE @DATA(LT_GRADE).

    SORT LT_GRADE BY MATNR CHARG WERKS LGORT ATWRT.

    LOOP AT GL_LIPS ASSIGNING FIELD-SYMBOL(<LFS_LIPS>)
                                    WHERE CHARG IS NOT INITIAL.

      READ TABLE LT_GRADE INTO DATA(LS_GRADE) WITH KEY MATNR = <LFS_LIPS>-MATNR
                                                       CHARG = <LFS_LIPS>-CHARG
                                                       WERKS = <LFS_LIPS>-WERKS
                                                       LGORT = <LFS_LIPS>-LGORT.
      IF SY-SUBRC EQ 0.
        <LFS_LIPS>-GRADE = LS_GRADE-ATWRT.
      ENDIF.

    ENDLOOP.


    LOOP AT GL_LIPS WHERE SUB = '1'.
      IF GT_LIKP-LFART = 'NL'.
**        READ TABLE gt_ords INTO DATA(wa_ords)
**                           WITH KEY ebeln = gl_lips-vgbel
**                                    ebelp = gl_lips-vgpos
**                                    BINARY SEARCH.
**        IF sy-subrc = 0.
***___조장
**          READ TABLE gt_ordvals INTO DATA(wa_ovals)
**                                WITH KEY objek = wa_ords-objek
**                                         atnam = ba_length
**                                         BINARY SEARCH.
**          IF sy-subrc = 0.
**            gl_lips-length = wa_ovals-atwrt.
**          ENDIF.
**
***___포장구분
**          READ TABLE gt_ordvals INTO wa_ovals
**                                WITH KEY objek = wa_ords-objek
**                                         atnam = so_packaging_cat
**                                         BINARY SEARCH.
**          IF sy-subrc = 0.
**            gl_lips-packaging_cat = wa_ovals-atwrt.
**          ENDIF.
*
***___릴 유형
**          READ TABLE gt_ordvals INTO wa_ovals
**                                WITH KEY objek = wa_ords-objek
**                                         atnam = so_packaging
**                                         BINARY SEARCH.
**          IF sy-subrc = 0.
**            gl_lips-packaging = wa_ovals-atwrt.
**          ENDIF.
*        ENDIF.

        SELECT SINGLE WAERS
          INTO GL_LIPS-WAERK
          FROM MSEG
         WHERE EBELN = GL_LIPS-VGBEL
           AND EBELP = GL_LIPS-VGPOS.
      ELSE.
        READ TABLE GT_ORDS INTO DATA(WA_ORDS)
                           WITH KEY VBELN = GL_LIPS-VGBEL
                                    POSNV = GL_LIPS-VGPOS
                                    BINARY SEARCH.
        IF SY-SUBRC = 0.
*___조장
          READ TABLE GT_ORDVALS INTO DATA(WA_OVALS)
                                WITH KEY OBJEK = WA_ORDS-OBJEK
                                         ATNAM = SO_LENGTH
                                         BINARY SEARCH.
          IF SY-SUBRC = 0.
            GL_LIPS-LENGTH = WA_OVALS-ATWRT.
          ENDIF.

**___포장구분
*          READ TABLE gt_ordvals INTO wa_ovals
*                                WITH KEY objek = wa_ords-objek
*                                         atnam = so_packaging_cat
*                                         BINARY SEARCH.
*          IF sy-subrc = 0.
*            gl_lips-packaging_cat = wa_ovals-atwrt.
*          ENDIF.

**___릴 유형
*          READ TABLE gt_ordvals INTO wa_ovals
*                                WITH KEY objek = wa_ords-objek
*                                         atnam = so_packaging
*                                         BINARY SEARCH.
*          IF sy-subrc = 0.
*            gl_lips-packaging = wa_ovals-atwrt.
*          ENDIF.
*
**___튜브 프린트
*          READ TABLE gt_ordvals INTO wa_ovals
*                                WITH KEY objek = wa_ords-objek
*                                         atnam = ba_pd_tb_print_app
*                                         BINARY SEARCH.
*          IF sy-subrc = 0.
*            gl_lips-tb_print = wa_ovals-atwrt.
*          ENDIF.

        ENDIF.

        SELECT SINGLE WAERK
          INTO GL_LIPS-WAERK
          FROM VBAP
         WHERE VBELN = GL_LIPS-VGBEL
           AND POSNR = GL_LIPS-VGPOS.
      ENDIF.

*   조장수
      IF NOT GL_LIPS-LENGTH IS INITIAL.
        GL_LIPS-FACTOR = GL_LIPS-JISIQTY / GL_LIPS-LENGTH.
      ENDIF.

      MODIFY GL_LIPS.
    ENDLOOP.
  ELSE.
    LOOP AT GL_LIPS WHERE SUB = '1'.
      IF GT_LIKP-LFART = 'NL'.
*        REFRESH: lt_char.
*        CLEAR  : lt_char, ls_return, pv_length. "pv_factor.
**& 특성값 가져오기........................
*        pv_ebeln = gl_lips-vgbel.
*        pv_ebelp = gl_lips-vgpos.
*
*        CALL FUNCTION 'ZMM_EKPO_SPEC_GET'
*          EXPORTING
*            ebeln                        = pv_ebeln
*            ebelp                        = pv_ebelp
*          IMPORTING
*            et_return                    = ls_return
*          TABLES
*            t_e1cuval                    = lt_char
*          EXCEPTIONS
*            instance_not_found           = 1
*            internal_error               = 2
*            instance_is_a_classification = 3
*            OTHERS                       = 4.
*
*        IF NOT lt_char[] IS INITIAL.
** 조장
*          READ TABLE lt_char WITH KEY charc = 'SAP_MILLCA_LENGTH'.
*          IF sy-subrc = 0.
*            PERFORM char_fltp_conversion USING lt_char-value
*                                      CHANGING pv_length.
*            gl_lips-length = pv_length.
*          ENDIF.
** 포장구분
*          READ TABLE lt_char WITH KEY charc = so_packaging_cat.
*          IF sy-subrc = 0.
*            gl_lips-packaging_cat = lt_char-value.
*          ENDIF.
** 릴 유형
*          READ TABLE lt_char WITH KEY charc = so_packaging.
*          IF sy-subrc = 0.
*            gl_lips-packaging = lt_char-value.
*          ENDIF.
*        ENDIF.
*        SELECT SINGLE waers INTO gl_lips-waerk
*        FROM mseg
*           WHERE ebeln = gl_lips-vgbel
*             AND ebelp = gl_lips-vgpos.

      ELSE.
        REFRESH: GT_CHAR. CLEAR: GT_CHAR.
        PERFORM GET_CHARACTERISTIC(ZLER0001) TABLES GT_CHAR
                                   USING GL_LIPS-VGBEL
                                         GL_LIPS-VGPOS
                                         GL_LIPS-WERKS
                                         GL_LIPS-MATNR.
        IF NOT GT_CHAR[] IS INITIAL.
* 조장
          READ TABLE GT_CHAR WITH KEY ATNAM = SO_LENGTH.
          IF SY-SUBRC = 0.
            GL_LIPS-LENGTH = GT_CHAR-ATWRT.
          ENDIF.
*      READ TABLE gt_char WITH KEY atnam = so_factor.
*      IF sy-subrc = 0.
*        gl_lips-factor = gt_char-atwrt.
*      ENDIF.
** 포장구분
*          READ TABLE gt_char WITH KEY atnam = so_packaging_cat.
*          IF sy-subrc = 0.
*            gl_lips-packaging_cat = gt_char-atwrt.
*          ENDIF.
** 릴 유형
*          READ TABLE gt_char WITH KEY atnam = so_packaging.
*          IF sy-subrc = 0.
*            gl_lips-packaging = gt_char-atwrt.
*          ENDIF.
** 튜브 프린트
*          READ TABLE gt_char WITH KEY  atnam = 'PD_TB_PRINT_APP'.
*          IF sy-subrc = 0.
*            gl_lips-tb_print = gt_char-atwrt.
*          ENDIF.
        ENDIF.

        SELECT SINGLE WAERK INTO GL_LIPS-WAERK
        FROM VBAP
           WHERE VBELN = GL_LIPS-VGBEL
             AND POSNR = GL_LIPS-VGPOS.
      ENDIF.

* 조장수
      IF NOT GL_LIPS-LENGTH IS INITIAL.
        GL_LIPS-FACTOR = GL_LIPS-JISIQTY / GL_LIPS-LENGTH.
      ENDIF.

      MODIFY GL_LIPS.
    ENDLOOP.
  ENDIF.

ENDFORM.                    " get_so_characteristic
*&---------------------------------------------------------------------*
*&      Form  get_status_lips
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM GET_STATUS_LIPS .

  WA_LIPS[] = GL_LIPS[].
  LOOP AT GL_LIPS.
    IF GL_LIPS-UECHA IS INITIAL.
      GL_LIPS-SUB   = '1'.
      GL_LIPS-ITEM1 = GL_LIPS-POSNR.
      READ TABLE WA_LIPS WITH KEY UECHA = GL_LIPS-POSNR.
      IF SY-SUBRC = 0.
        GL_LIPS-ICON1 = C_ICON1.
      ENDIF.
    ELSE.
      GL_LIPS-SUB   = '2'.
      GL_LIPS-ITEM1 = GL_LIPS-UECHA.
    ENDIF.

*{ 기능개선 157076 - 추가
*___일련번호 프로파일
*    SELECT SINGLE sernp
*      INTO gl_lips-sernp
*      FROM marc
*     WHERE matnr = gl_lips-matnr
*       AND werks = gl_lips-werks.
*
*    IF gl_lips-sernp IS NOT INITIAL.
*      gv_serial = 'X'.
*
*      PERFORM get_sernr_for_charg USING gl_lips-matnr
*                                        gl_lips-charg
*                                        gl_lips-sernr_m.
*    ENDIF.
*} 기능개선 157076 - 추가

    MODIFY GL_LIPS.
  ENDLOOP.

ENDFORM.                    " get_status_lips
*&---------------------------------------------------------------------*
*&      Form  collaps_or_expand
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM COLLAPS_OR_EXPAND .

  IF SAVE_OK = 'EXPD'.
    I_CURSOR_LINE = TC02-CURRENT_LINE + I_CURSOR_LINE - 1.
  ELSEIF SAVE_OK = 'EXPD1'.
    I_CURSOR_LINE = TC12-CURRENT_LINE + I_CURSOR_LINE - 1.
  ENDIF.

  READ TABLE GT_LIPS INDEX I_CURSOR_LINE.

  CASE G_CURSOR_FIELD.
    WHEN 'GT_LIPS-ICON1'.
      IF     GT_LIPS-ICON1 = '@3S@'.        "EXPAND
        GL_LIPS-ICON1 = C_ICON2.
        MODIFY GL_LIPS TRANSPORTING ICON1
            WHERE VBELN = GT_LIPS-VBELN
              AND POSNR = GT_LIPS-POSNR
              AND SUB   = '1'.
      ELSEIF GT_LIPS-ICON1 = '@3T@'.        "COLLAPSE
        GL_LIPS-ICON1 = C_ICON1.
        MODIFY GL_LIPS TRANSPORTING ICON1
            WHERE VBELN = GT_LIPS-VBELN
              AND POSNR = GT_LIPS-POSNR
              AND SUB   = '1'.
      ENDIF.
  ENDCASE.

ENDFORM.                    " collaps_or_expand
*&---------------------------------------------------------------------*
*&      Form  modify_screen_sub_1
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM MODIFY_SCREEN_SUB_1 .

  IF GT_LIPS-CHK = 'X'.
    LOOP AT SCREEN.
      CASE SCREEN-NAME .
        WHEN 'GT_LIPS-MATNR'   OR 'GT_LIPS-ARKTX' OR
             'GT_LIPS-WERKS'   OR 'GT_LIPS-LGORT' OR
             'GT_LIPS-LFIMG'   OR 'GT_LIPS-VRKME' OR
             'GT_LIPS-JISIQTY' OR 'GT_LIPS-FACTOR' OR
             'GT_LIPS-DELQTY'  OR 'GT_LIPS-LENGTH' OR
             'GT_LIPS-AVQTY'   OR 'GT_LIPS-SOBKZ' OR
             'GT_LIPS-WAERK'   OR 'GT_LIPS-POSNR' OR
             'GT_LIPS-UEBTO'   OR 'GT_LIPS-UEBTK' OR
             'GT_LIPS-PACKAGING_CAT' OR 'GT_LIPS-PACKAGING' OR
             'GT_LIPS-TB_PRINT' OR
             'GT_LIPS-VGBEL'   OR 'GT_LIPS-VGPOS' OR
             'GT_LIPS-SHIPPING_NO' OR 'GT_LIPS-MIGUL'.

          SCREEN-INTENSIFIED = 1.

      ENDCASE.
      MODIFY SCREEN.
    ENDLOOP.
  ENDIF.

*  IF ( gt_lips-lfimg = gt_lips-delqty ).
*    LOOP AT SCREEN.
*      CASE screen-name .
*        WHEN 'GT_LIPS-JISIQTY' OR 'GT_LIPS-FACTOR'.
*          screen-input  = 0.
*      ENDCASE.
*      MODIFY SCREEN.
*    ENDLOOP.
*  ENDIF.

* 조장이 없으면, 조장수는 OUTPUT FIELD
  IF GT_LIPS-LENGTH IS INITIAL.
    LOOP AT SCREEN.
      CASE SCREEN-NAME .
        WHEN 'GT_LIPS-FACTOR'.
          SCREEN-INPUT  = 0.
      ENDCASE.
      MODIFY SCREEN.
    ENDLOOP.
  ENDIF.

* 리드프레임은 SHIPPING NO 입력가능
  IF GT_LIPS-LGORT = '3501' .
    LOOP AT SCREEN.
      CASE SCREEN-NAME.
        WHEN 'GT_LIPS-SHIPPING_NO'.
          SCREEN-INPUT  = 1.
      ENDCASE.
      MODIFY SCREEN.
    ENDLOOP.
  ENDIF.

*-{자체개선101435-추가
*__미지정재고 수량 0일때 조장수 및 납품지시수량 변경 금지
  IF GT_LIPS-NDELQTY = 0.
    LOOP AT SCREEN.
      CASE SCREEN-NAME.
        WHEN 'GT_LIPS-FACTOR' OR 'GT_LIPS-JISIQTY'.
          SCREEN-INPUT = 0.
      ENDCASE.
      MODIFY SCREEN.
    ENDLOOP.
  ENDIF.
*-}자체개선101435_2015.11.03

*{ SRM2202-09416 - s   플랜트3602시에만 자재그루핑(형식명 필드) 보여주기
  DATA : LV_WERKS LIKE LIPS-WERKS.

  SELECT SINGLE WERKS
    INTO LV_WERKS FROM LIPS
   WHERE VBELN = GT_LIKP-VBELN.

  IF LV_WERKS NE '3602'.
    PERFORM HIDE_TC TABLES TC12-COLS
                    USING '1'.
  ENDIF.
*} SRM2202-09416 - e

ENDFORM.                    " modify_screen_sub_1
*&---------------------------------------------------------------------*
*&      Form  modify_screen_sub_2
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM MODIFY_SCREEN_SUB_2 .

  LOOP AT SCREEN.
    CASE SCREEN-NAME .
      WHEN 'GT_LIPS-CHK'.
        SCREEN-INPUT  = 0.
        SCREEN-ACTIVE = 0.
      WHEN 'GT_LIPS-JISIQTY' OR 'GT_LIPS-LFIMG' OR
           'GT_LIPS-FACTOR'.
        SCREEN-INPUT  = 0.
        SCREEN-INVISIBLE = 1.
      WHEN 'GT_LIPS-VGBEL' OR 'GT_LIPS-VGPOS' OR
           'GT_LIPS-MIGUL' OR 'GT_LIPS-LFIMG' OR
           'GT_LIPS-UEBTO' OR 'GT_LIPS-JISIQTY' OR
           'GT_LIPS-LENGTH' OR 'GT_LIPS-FACTOR' OR
           'GT_LIPS-AVQTY'  OR
           'GT_LIPS-PACKAGING_CAT' OR 'GT_LIPS-PACKAGING' OR
           'GT_LIPS-WAERK' OR 'GT_LIPS-SHIPPING_NO' OR
           'GT_LIPS-NDELQTY'.
        SCREEN-INVISIBLE = 1.
    ENDCASE.
    MODIFY SCREEN.
  ENDLOOP.

  IF GT_LIPS-POSNR IS INITIAL.
    LOOP AT SCREEN.
      CASE SCREEN-NAME .
        WHEN 'GT_LIPS-POSNR'.
          SCREEN-INVISIBLE = 1.
      ENDCASE.
      MODIFY SCREEN.
    ENDLOOP.
  ENDIF.

*{ SRM2202-09416 - s   플랜트3602시에만 자재그루핑(형식명 필드) 보여주기
  DATA : LV_WERKS LIKE LIPS-WERKS.

  SELECT SINGLE WERKS
    INTO LV_WERKS FROM LIPS
   WHERE VBELN = GT_LIKP-VBELN.

  IF LV_WERKS NE '3602'.
    PERFORM HIDE_TC TABLES TC12-COLS
                    USING '1'.
  ENDIF.
*} SRM2202-09416 - e

ENDFORM.                    " modify_screen_sub_2
*&---------------------------------------------------------------------*
*&      Form  get_jisiqty_delqty
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM GET_JISIQTY_DELQTY_MODI .

*/ 지시수량(jisiqty): 현재납품수량,
*  지정수량(delqty) : 배치사용(배치지정수량), 배치미사용(포장수량)

*/ 배치사용
  LOOP AT GL_LIPS. " WHERE xchpf = 'X'.
    IF GL_LIPS-SUB = '1'.
      GL_LIPS-JISIQTY = GL_LIPS-LFIMG.
    ELSE.
      GL_LIPS-JISIQTY = GL_LIPS-LFIMG.
      GL_LIPS-DELQTY  = GL_LIPS-LFIMG.
    ENDIF.
    GL_LIPS-LFIMG    = 0.
    MODIFY GL_LIPS TRANSPORTING LFIMG DELQTY JISIQTY.
  ENDLOOP.

*/ 배치미사용-일반재고
  LOOP AT GL_LIPS WHERE XCHPF = ' '
                    AND SOBKZ = ' '.
    SELECT SUM( VEMNG ) INTO GL_LIPS-DELQTY FROM VEPO
      WHERE VBELN = GL_LIPS-VBELN
        AND POSNR = GL_LIPS-POSNR.

    MODIFY GL_LIPS TRANSPORTING DELQTY.
  ENDLOOP.

*/ 배치미사용-특별재고
  DATA: LV_SONUM LIKE VEPO-SONUM.
  LOOP AT GL_LIPS WHERE XCHPF = ' '
                    AND SOBKZ = 'E'.
    CONCATENATE GL_LIPS-VGBEL GL_LIPS-VGPOS INTO LV_SONUM.

    SELECT SUM( VEMNG ) INTO GL_LIPS-DELQTY FROM VEPO
      WHERE VBELN = GL_LIPS-VBELN
        AND POSNR = GL_LIPS-POSNR
        AND SONUM = LV_SONUM.

    MODIFY GL_LIPS TRANSPORTING DELQTY.
  ENDLOOP.


ENDFORM.                    " get_jisiqty_delqty
*&---------------------------------------------------------------------*
*&      Form  GET_MIGUL_LFIMG
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM GET_MIGUL_LFIMG .

  WA_LIPS[] = GL_LIPS[].

  LOOP AT GL_LIPS WHERE SUB = '1'.
    CLEAR: GV_LFIMG, GV_KWMENG, GV_LFIMG1,GV_AVALQTY, GV_LFIMG,
           GV_LFIMG1, GV_LFIMG2, GV_QTY1, GV_QTY2, GV_QTY3,
           GV_LABST, GV_LABST1, GV_LABST2, GV_OVERQTY.
********************// 1.가용재고 수량 ***********************
* 현재고수량
    IF GL_LIPS-SOBKZ <> 'E'.
      PERFORM CURRENT_QTY USING GV_AVALQTY.
    ELSE.
      PERFORM CURRENT_QTY_E USING GV_AVALQTY.
    ENDIF.

* 납품생성수량 (GI 안된것).
    IF GL_LIPS-SOBKZ <> 'E'.
      PERFORM NO_GI_DELIVERY USING GV_LABST.
    ELSE.
      PERFORM NO_GI_DELIVERY_E USING GV_LABST.
    ENDIF.

* 현재 납품문서의 납품수량
    PERFORM OWN_ITSELF_QTY TABLES WA_LIPS
                           USING GV_LFIMG.

* < 가용재고 수량 >
    GL_LIPS-AVQTY = GV_AVALQTY - GV_LABST + GV_LFIMG.

* 만약, 가용재고수량이 납품수량보다 작으면,
* 가용재고수량은 납품수량으로 한다.
    IF GL_LIPS-AVQTY < GL_LIPS-JISIQTY.
      GL_LIPS-AVQTY = GL_LIPS-JISIQTY.
    ENDIF.
*****************// 2.미결수량: *******************************
*   SALES ORDER 수량 - 납품수량 합 + 현재 납품문서의 납품수량
* SALES ORDER 수량
    PERFORM SALES_ORDER_QTY USING GV_KWMENG.

* SALES ORDER 로 생성된 납품수량 합
    PERFORM DELIVERI_QTY_SUM USING GV_LFIMG1.

* < 미결수량 >
*  GL_LIPS-MIGUL = GV_KWMENG  -  GV_LFIMG1.
    GL_LIPS-MIGUL = GV_KWMENG  -  GV_LFIMG1 + GV_LFIMG.

****************// 3.납품가능량 *******************************
* 초과허용수량
    GV_OVERQTY = ( GV_KWMENG * GL_LIPS-UEBTO ) / 100.
    IF GL_LIPS-UEBTK = 'X'.  "무제한허용
      GL_LIPS-LFIMG = GL_LIPS-AVQTY .
    ELSE.
      GV_QTY2 = GL_LIPS-MIGUL + GV_OVERQTY.
      IF GV_QTY2 > GL_LIPS-AVQTY.
        GL_LIPS-LFIMG = GL_LIPS-AVQTY .
      ELSE.
        GL_LIPS-LFIMG = GV_QTY2.
      ENDIF.
    ENDIF.

    MODIFY GL_LIPS TRANSPORTING LFIMG AVQTY MIGUL.
  ENDLOOP.




************************************************
*  wa_lips[] = gl_lips[].
*
*  LOOP AT gl_lips WHERE sub = '1'.
*    CLEAR: gv_lfimg, gv_kwmeng, gv_lfimg1,gv_avalqty, gv_lfimg,
*           gv_lfimg1, gv_lfimg2, gv_qty1, gv_qty2, gv_qty3,
*           gv_labst, gv_labst1, gv_labst2, gv_overqty.
*    IF gl_lips-lgort <> ' '.
** 현재고 수량
*      IF gl_lips-sobkz <> 'E'.
*        PERFORM current_qty USING gv_avalqty.
*      ELSE.
*        PERFORM current_qty_e USING gv_avalqty.
*      ENDIF.
*      IF gl_lips-meins <> gl_lips-vrkme.
*        gv_avalqty =  gv_avalqty * gl_lips-umvkn / gl_lips-umvkz.
*      ENDIF.
** 미출고된 납품수량 합 (저장위치 있는 것 + 없는것)
*      IF gl_lips-sobkz <> 'E'.
*        PERFORM no_gi_delivery USING gv_labst.
*      ELSE.
*        PERFORM no_gi_delivery_e USING gv_labst.
*      ENDIF.
*      IF gv_labst > gv_avalqty.
*        gv_qty3 = gv_labst - gv_avalqty .
*      ENDIF.
** 총재고 재고수량(플랜트+자재)
*      IF gl_lips-sobkz <> 'E'.
*        PERFORM werks_matnr_qty USING gv_lfimg2.
*      ELSE.
*        PERFORM werks_matnr_qty_e USING gv_lfimg2.
*      ENDIF.
** 자신이 갖고 있는 수량
*      PERFORM own_itself_qty TABLES wa_lips
*                             USING gv_lfimg.
**/ 현재 가용가능한 수량(저장위치가 있는 경우)
*      gv_qty1 = gv_lfimg2 - gv_labst .
**      GV_QTY1 = gv_avalqty - gv_labst + gv_lfimg.
*      IF gv_qty1 <= 0.
*        gv_qty1 = 0.
*      ENDIF.
*      gl_lips-avqty = gv_avalqty -  gv_labst  +
*                      gv_qty1 + gv_lfimg .
**      gl_lips-avqty = gv_avalqty -  gv_labst  +
**                      gv_qty1 + gv_lfimg + gv_qty3.
*
*    ELSE.
**/ 현재 가용가능한 수량(저장위치가 없는 경우)-HU 미사용에서
** 총재고 재고수량(플랜트+자재)
*      IF gl_lips-sobkz <> 'E'.
*        PERFORM werks_matnr_qty USING gv_lfimg2.
*      ELSE.
*        PERFORM werks_matnr_qty_e USING gv_lfimg2.
*      ENDIF.
** 미출고된 납품수량 합 (저장위치 있는 것 + 없는것)
*      IF gl_lips-sobkz <> 'E'.
*        PERFORM no_gi_delivery USING gv_labst.
*      ELSE.
*        PERFORM no_gi_delivery_e USING gv_labst.
*      ENDIF.
** 자신이 갖고 있는 수량
*      PERFORM own_itself_qty TABLES wa_lips
*                             USING gv_lfimg.
*      gl_lips-avqty = gv_lfimg2 - gv_labst + gv_lfimg.
*    ENDIF.
*
**/ 미결수량
** SALES ORDER 수량
*    PERFORM sales_order_qty USING gv_kwmeng.
** SALES ORDER 로 생성된 납품수량 합
*    PERFORM deliveri_qty_sum USING gv_lfimg1.
*    gl_lips-migul = gv_kwmeng  -  gv_lfimg1 + gv_lfimg.
** 초과허용수량
*    gv_overqty = ( gv_kwmeng * gl_lips-uebto ) / 100.
*
****/ <납품가능량> ****
*    IF gl_lips-uebtk = 'X'.  "무제한허용
*      gl_lips-lfimg = gl_lips-avqty .
*    ELSE.
*      gv_qty2 = gl_lips-migul + gv_overqty.
*      IF gv_qty2 > gl_lips-avqty.
*        gl_lips-lfimg = gl_lips-avqty .
*      ELSE.
*        gl_lips-lfimg = gv_qty2.
*      ENDIF.
*    ENDIF.
*
*    MODIFY gl_lips TRANSPORTING lfimg avqty migul.
*  ENDLOOP.

ENDFORM.                    " GET_MIGUL_LFIMG
*&---------------------------------------------------------------------*
*&      Form  current_qty
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GV_AVALQTY  text
*----------------------------------------------------------------------*
FORM CURRENT_QTY  USING    P_QTY.

  IF GL_LIPS-LGORT = ' '.
    SELECT SINGLE SUM( LABST ) INTO P_QTY FROM MARD
      WHERE MATNR = GL_LIPS-MATNR
        AND WERKS = GL_LIPS-WERKS.
  ELSE.
    SELECT SINGLE LABST INTO P_QTY FROM MARD
      WHERE MATNR = GL_LIPS-MATNR
        AND WERKS = GL_LIPS-WERKS
        AND LGORT = GL_LIPS-LGORT.
  ENDIF.

ENDFORM.                    " current_qty
*&---------------------------------------------------------------------*
*&      Form  current_qty_e
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GV_AVALQTY  text
*----------------------------------------------------------------------*
FORM CURRENT_QTY_E  USING    P_QTY.

  IF GL_LIPS-LGORT = ' '.
    SELECT SINGLE SUM( KALAB ) INTO P_QTY FROM MSKA
      WHERE MATNR = GL_LIPS-MATNR
        AND WERKS = GL_LIPS-WERKS
*      AND lgort = gl_lips-lgort
        AND SOBKZ = 'E'
        AND VBELN = GL_LIPS-VGBEL
        AND POSNR = GL_LIPS-VGPOS.
  ELSE.
    SELECT SINGLE SUM( KALAB ) INTO P_QTY FROM MSKA
      WHERE MATNR = GL_LIPS-MATNR
        AND WERKS = GL_LIPS-WERKS
        AND LGORT = GL_LIPS-LGORT
        AND SOBKZ = 'E'
        AND VBELN = GL_LIPS-VGBEL
        AND POSNR = GL_LIPS-VGPOS.
  ENDIF.

ENDFORM.                    " current_qty_e
*&---------------------------------------------------------------------*
*&      Form  no_gi_delivery
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GV_LABST  text
*----------------------------------------------------------------------*
FORM NO_GI_DELIVERY  USING    P_LABST.

  SELECT SUM( P~LFIMG )
    INTO GV_LABST1
    FROM LIPS AS P
*   INNER JOIN VBUK AS K
*      ON P~VBELN = K~VBELN
   INNER JOIN LIKP AS T
      ON P~VBELN = T~VBELN
   WHERE P~WERKS = GL_LIPS-WERKS
     AND P~LGORT = GL_LIPS-LGORT
     AND P~MATNR = GL_LIPS-MATNR
     AND P~SOBKZ = GL_LIPS-SOBKZ
     AND T~LFART IN R_LFART
     AND T~WBSTK <> 'C'.

  SELECT SUM( P~LFIMG )
    INTO GV_LABST2
    FROM LIPS AS P
*   INNER JOIN VBUK AS K
*      ON P~VBELN = K~VBELN
   INNER JOIN LIKP AS T
      ON P~VBELN = T~VBELN
   WHERE P~WERKS = GL_LIPS-WERKS
     AND P~LGORT = ' '
     AND P~MATNR = GL_LIPS-MATNR
     AND P~SOBKZ = GL_LIPS-SOBKZ
     AND T~LFART IN R_LFART
     AND T~WBSTK <> 'C'.

  P_LABST = GV_LABST1 + GV_LABST2.


ENDFORM.                    " no_gi_delivery
*&---------------------------------------------------------------------*
*&      Form  no_gi_delivery_e
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GV_LABST  text
*----------------------------------------------------------------------*
FORM NO_GI_DELIVERY_E  USING    P_LABST.

  SELECT SUM( P~LFIMG )
    INTO GV_LABST1
    FROM LIPS AS P
*   INNER JOIN VBUK AS K
*      ON P~VBELN = K~VBELN
   INNER JOIN LIKP AS T
      ON P~VBELN = T~VBELN
   WHERE P~WERKS = GL_LIPS-WERKS
     AND P~LGORT = GL_LIPS-LGORT
     AND P~MATNR = GL_LIPS-MATNR
     AND P~SOBKZ = GL_LIPS-SOBKZ
     AND P~VGBEL = GL_LIPS-VGBEL
     AND P~VGPOS = GL_LIPS-VGPOS
     AND T~LFART IN R_LFART
     AND T~WBSTK <> 'C'.

  SELECT SUM( P~LFIMG )
    INTO GV_LABST2
    FROM LIPS AS P
*   INNER JOIN VBUK AS K
*      ON P~VBELN = K~VBELN
   INNER JOIN LIKP AS T
      ON P~VBELN = T~VBELN
   WHERE P~WERKS = GL_LIPS-WERKS
     AND P~LGORT = ' '
     AND P~MATNR = GL_LIPS-MATNR
     AND P~SOBKZ = GL_LIPS-SOBKZ
     AND P~VGBEL = GL_LIPS-VGBEL
     AND P~VGPOS = GL_LIPS-VGPOS
     AND T~LFART IN R_LFART
     AND T~WBSTK <> 'C'.

  P_LABST = GV_LABST1 + GV_LABST2.


ENDFORM.                    " no_gi_delivery_e
*&---------------------------------------------------------------------*
*&      Form  werks_matnr_qty
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GV_LFIMG2  text
*----------------------------------------------------------------------*
FORM WERKS_MATNR_QTY  USING    P_LFIMG2.

  IF GL_LIPS-LGORT = ' '.
    SELECT SINGLE SUM( LABST ) INTO P_LFIMG2 FROM MARD
      WHERE MATNR = GL_LIPS-MATNR
        AND WERKS = GL_LIPS-WERKS.
  ELSE.
    SELECT SINGLE SUM( LABST ) INTO P_LFIMG2 FROM MARD
      WHERE MATNR = GL_LIPS-MATNR
        AND WERKS = GL_LIPS-WERKS
        AND LGORT = GL_LIPS-LGORT.
  ENDIF.

ENDFORM.                    " werks_matnr_qty
*&---------------------------------------------------------------------*
*&      Form  werks_matnr_qty_e
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GV_LFIMG2  text
*----------------------------------------------------------------------*
FORM WERKS_MATNR_QTY_E  USING    P_LFIMG2.

  SELECT SINGLE SUM( KALAB ) INTO P_LFIMG2 FROM MSKA
    WHERE MATNR = GL_LIPS-MATNR
      AND WERKS = GL_LIPS-WERKS
*      AND lgort = gl_lips-lgort
      AND SOBKZ = 'E'
      AND VBELN = GL_LIPS-VGBEL
      AND POSNR = GL_LIPS-POSNR.


ENDFORM.                    " werks_matnr_qty_e
*&---------------------------------------------------------------------*
*&      Form  own_itself_qty
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_WA_LIPS  text
*      -->P_GV_LFIMG  text
*----------------------------------------------------------------------*
FORM OWN_ITSELF_QTY  TABLES   PT_LIPS LIKE GL_LIPS[]
                     USING    P_LFIMG.

  LOOP AT PT_LIPS WHERE ITEM1 = GL_LIPS-ITEM1.
    ADD  PT_LIPS-JISIQTY   TO P_LFIMG.
  ENDLOOP.


ENDFORM.                    " own_itself_qty
*&---------------------------------------------------------------------*
*&      Form  sales_order_qty
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GV_KWMENG  text
*----------------------------------------------------------------------*
FORM SALES_ORDER_QTY  USING    P_KWMENG.

  IF GT_LIKP-LFART = 'NL'.
    SELECT SINGLE MENGE INTO P_KWMENG   FROM EKPO
      WHERE EBELN = GL_LIPS-VGBEL
        AND EBELP = GL_LIPS-VGPOS.
  ELSE.
    SELECT SINGLE KWMENG INTO P_KWMENG  FROM VBAP
       WHERE VBELN = GL_LIPS-VGBEL
         AND POSNR = GL_LIPS-VGPOS.
  ENDIF.

ENDFORM.                    " sales_order_qty
*&---------------------------------------------------------------------*
*&      Form  deliveri_qty_sum
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GV_LFIMG1  text
*----------------------------------------------------------------------*
FORM DELIVERI_QTY_SUM  USING    P_LFIMG1.

  SELECT SUM( P~LFIMG ) INTO P_LFIMG1
     FROM LIPS AS P INNER JOIN LIKP AS K
       ON P~VBELN = K~VBELN
     WHERE P~VGBEL = GL_LIPS-VGBEL
       AND P~VGPOS = GL_LIPS-VGPOS
       AND K~LFART IN R_LFART.


ENDFORM.                    " deliveri_qty_sum
*---------------------------------------------------------------------*
*&      Form  display_assg_nasg
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM DISPLAY_ASSG_NASG .
  DATA: LV_VENUM   LIKE VEKP-VENUM.

  REFRESH: "CONTROL 'TC02' FROM SCREEN '0200',
           "CONTROL 'TC12' FROM SCREEN '0300',
           CONTROL 'TC03' FROM SCREEN '0200',
           CONTROL 'TC13' FROM SCREEN '0300',
           CONTROL 'TC04' FROM SCREEN '0200',
           CONTROL 'TC14' FROM SCREEN '0300'.

  CLEAR: GT_ASSG[], GT_ASSG, GT_NASG[], GT_NASG.
  READ TABLE GL_LIPS WITH KEY CHK = 'X'.
  IF SY-SUBRC = 0.
    P_QIQTY = GL_LIPS-QIQTY.
    P_VRKME = GL_LIPS-VRKME.

* 중복지정
    GL_VEPO-ICON2 = ' '.
    MODIFY GL_VEPO TRANSPORTING ICON2 WHERE ICON2 <> ' '.

    WA_VEPO[] = GL_VEPO[].
    LOOP AT GL_VEPO .
      LOOP AT WA_VEPO WHERE EXIDV = GL_VEPO-EXIDV
                        AND ITEM1 <> GL_VEPO-ITEM1.
      ENDLOOP.
      IF SY-SUBRC = 0.
        GL_VEPO-ICON2 = 'D'.
        MODIFY GL_VEPO TRANSPORTING ICON2.
      ENDIF.
    ENDLOOP.

* 중복지정
    LOOP AT GL_VEPO .
      CLEAR: GV_FLAG.
      LOOP AT WA_VEPO WHERE EXIDV = GL_VEPO-EXIDV  AND
                          ( MATNR <> GL_VEPO-MATNR OR
                            WERKS <> GL_VEPO-WERKS OR
                            LGORT <> GL_VEPO-LGORT OR
                            SOBKZ <> GL_VEPO-SOBKZ ).
        GV_FLAG = 'X'.
        EXIT.
      ENDLOOP.
      IF GV_FLAG = 'X'.
        GL_VEPO-ICON2 = 'D'.
        MODIFY GL_VEPO.
      ENDIF.
    ENDLOOP.

    LOOP AT GL_VEPO WHERE MATNR = GL_LIPS-MATNR
                      AND SOBKZ = GL_LIPS-SOBKZ
                      AND SONUM = GL_LIPS-SONUM
                      AND PLACE = 'A'
                      AND ITEM1 = GL_LIPS-ITEM1.
      MOVE-CORRESPONDING GL_VEPO TO GT_ASSG.
      COLLECT GT_ASSG.
    ENDLOOP.

    LOOP AT GL_VEPO WHERE MATNR = GL_LIPS-MATNR
                      AND SOBKZ = GL_LIPS-SOBKZ
                      AND SONUM = GL_LIPS-SONUM
                      AND PLACE = 'N'.
      MOVE-CORRESPONDING GL_VEPO TO GT_NASG.
      COLLECT GT_NASG.
    ENDLOOP.
  ENDIF.

  LOOP AT GL_LIPS WHERE SOBKZ <> ' '.
    CONCATENATE GL_LIPS-VGBEL GL_LIPS-VGPOS
           INTO GL_LIPS-SONUM.

    CONDENSE GL_LIPS-SONUM.

    MODIFY GL_LIPS.
  ENDLOOP.

  LOOP AT GT_NASG.
    READ TABLE GL_VEPO WITH KEY EXIDV = GT_NASG-EXIDV.

    IF GL_VEPO-EXTNL = 'X'.
      SELECT SINGLE VENUM
        INTO LV_VENUM
        FROM VEKP
       WHERE EXIDV  =  GT_NASG-EXIDV
         AND STATUS <> '0060'.

      SELECT * INTO CORRESPONDING FIELDS OF TABLE ET_VEKP
         FROM VEKP
        WHERE UEVEL = LV_VENUM.
    ELSE.
      SELECT * INTO CORRESPONDING FIELDS OF TABLE ET_VEKP
         FROM VEKP
        WHERE EXIDV = GT_NASG-EXIDV.
    ENDIF.

    CHECK NOT ET_VEKP[] IS INITIAL.

    SELECT * INTO CORRESPONDING FIELDS OF TABLE ET_VEPO
       FROM VEPO
        FOR ALL ENTRIES IN ET_VEKP
      WHERE VENUM = ET_VEKP-VENUM.

    DELETE ET_VEPO WHERE MATNR = ' '.

    CLEAR: GV_FLAG.
    LOOP AT ET_VEPO.
      READ TABLE GL_LIPS WITH KEY MATNR = ET_VEPO-MATNR
                                  SONUM = ET_VEPO-SONUM.
      IF SY-SUBRC <> 0.
        GV_FLAG = 'X'.
        EXIT.
      ENDIF.
    ENDLOOP.
    IF GV_FLAG = 'X'.
      GT_NASG-ICON3 = C_ICON3.
      MODIFY GT_NASG TRANSPORTING ICON3.
    ENDIF.
  ENDLOOP.

  SORT GT_NASG BY EXIDV.
  SORT GT_ASSG BY EXIDV.



ENDFORM.                    " display_assg_nasg
*&---------------------------------------------------------------------*
*&      Form  move_left_200
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM MOVE_LEFT_200 .

  READ TABLE GL_LIPS WITH KEY CHK = 'X'.
  GV_ITEM1 = GL_LIPS-ITEM1.

*/ Error check
  PERFORM ERROR_CHECK_BEFORE_MOVE_1.

*/ Lock HU
  CLEAR: GV_FLAG.
  LOOP AT GT_NASG WHERE CHK = 'X'.
    PERFORM ENQUEUE_HU USING GT_NASG-EXIDV.
  ENDLOOP.
  IF GV_FLAG = 'X'.
    LEAVE SCREEN.
  ENDIF.

*/ 상단의 지정수량 반영
  PERFORM ASSIGN_GL_LIPS_DELQTY_200.

  PERFORM DISPLAY_ASSG_NASG.


ENDFORM.                    " move_left_200
*&---------------------------------------------------------------------*
*&      Form  move_right_200
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM MOVE_RIGHT_200 .

  READ TABLE GL_LIPS WITH KEY CHK = 'X'.
  CLEAR: GV_FLAG.
  IF GL_LIPS-FIXED = 'X'.
    MESSAGE I000 WITH
     '상위품목에 이미 배치지정 되었습니다'.
    GV_FLAG = 'X'.
  ENDIF.
  IF GV_FLAG = 'X'.
    LEAVE SCREEN.
  ENDIF.

  LOOP AT GT_ASSG WHERE CHK = 'X'.
    PERFORM DEQUEUE_HU USING GT_ASSG-EXIDV.
  ENDLOOP.

*/ 상단의 지정수량 반영
  PERFORM ASSIGN_GL_LIPS_DELQTY_200_1.

  PERFORM DISPLAY_ASSG_NASG.

ENDFORM.                    " move_right_200
*&---------------------------------------------------------------------*
*&      Form  error_check_before_move_1
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM ERROR_CHECK_BEFORE_MOVE_1 .

*  DATA: ls_vekp TYPE vekpvb.
*
*  CALL FUNCTION 'HU_ENQUEUE'
*    EXPORTING
*      if_with_le   = space
*    CHANGING
*      cs_header    = ls_vekp
*    EXCEPTIONS
*      foreign_lock = 01
*      OTHERS       = 99.
*  IF NOT sy-subrc IS INITIAL.
**        ef_rcode = 4.
**        write ls_vekp-exidv to lf_msgv1 using edit mask '==ALPHA'.
**       message e007(hufunctions) with ls_vekp-exidv.
**        perform set_hu_msg using    ls_vekp-exidv 'HUFUNCTIONS' 'E'
**                                    '007' lf_msgv1 space space space
**                           changing et_messages.
**        continue.
*  ENDIF.

*/
  CLEAR: GV_FLAG.
  IF GL_LIPS-FIXED = 'X'.
    MESSAGE I000 WITH
     '상위품목에 이미 배치지정 되었습니다'.
    GV_FLAG = 'X'.
  ENDIF.
  IF GV_FLAG = 'X'.
    LEAVE SCREEN.
  ENDIF.
*/
  CLEAR: GV_FLAG.
  IF GL_LIPS-NDELQTY = 0.
    MESSAGE I001 WITH '모두 지정되었습니다'.
    GV_FLAG = 'X'.
  ENDIF.

  IF GV_FLAG = 'X'.
    LEAVE SCREEN.
  ENDIF.

*/ 지정할수 없는 품목이 있습니다.
*  PERFORM check_cannot_assign.

*/ 포장수량이 지시수량을 초과할수 없다.
  PERFORM CHECK_OVER_ASSIGN.



ENDFORM.                    " error_check_before_move_1
*&---------------------------------------------------------------------*
*&      Form  make_data_hu_NO
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM MAKE_DATA_HU_NO .

*/ select ~ lips
*  SELECT * INTO CORRESPONDING FIELDS OF TABLE gl_lips
*    FROM lips
*   WHERE vbeln = p_vbeln.

  SELECT A~*, C~NAME1 INTO CORRESPONDING FIELDS OF TABLE @GL_LIPS
    FROM LIPS AS A INNER JOIN LIKP AS B
                    ON A~VBELN EQ B~VBELN
                   INNER JOIN KNA1 AS C
                    ON B~KUNAG EQ C~KUNNR
   WHERE A~VBELN = @P_VBELN.

*/ 납품유형이 'NL'일 경우 STO의 초과납품 무한초과 납품 허용값을 찾아서
*/ 적용.
  DATA : LV_LFART LIKE LIKP-LFART.

  SELECT SINGLE LFART INTO LV_LFART
  FROM   LIKP
  WHERE VBELN = P_VBELN.
  IF LV_LFART = 'NL'.
    LOOP AT GL_LIPS.
      SELECT SINGLE UEBTO UEBTK
      INTO   (GL_LIPS-UEBTO, GL_LIPS-UEBTK)
      FROM   EKPO
      WHERE  EBELN = GL_LIPS-VGBEL
      AND    EBELP = GL_LIPS-VGPOS.
      MODIFY GL_LIPS.
    ENDLOOP.
    CLEAR LV_LFART.
  ENDIF.


*/ 품목상태 및 일련번호(기계번호)
  PERFORM GET_STATUS_LIPS.

*/ 지시수량(jisiqty): 현재납품수량,
*  지정수량(delqty) : 배치사용(배치지정수량), 배치미사용(포장수량)
*  PERFORM get_jisiqty_delqty.
  PERFORM GET_JISIQTY_DELQTY.

*/ 미결수량, 납품가능량
  PERFORM GET_MIGUL_LFIMG.

*/ 제품특성
  PERFORM GET_SO_CHARACTERISTIC.

*/
  PERFORM GET_XL_NASG.

*  단위 변환을 위 FORM문에서 처리하고 아래는 막음 by J.Y.Lee 05/31/2011
*  PERFORM CONVERSION_UNIT_NASG_300.

*/
  PERFORM GET_XL_ASSG.

*/ 단위환산: 판매단위와 재고단위가 다를 경우.
  PERFORM CONVERSION_UNIT_ASSG_300.
*PERFORM conversion_unit_300.
*/ 지정수량: 배치미사용
  PERFORM GET_DELQTY_300.

  CL_NASG[] = XL_NASG[].
  CL_ASSG[] = XL_ASSG[].
  CLEAR: CL_LIPS[], CL_LIPS.
  LOOP AT GL_LIPS WHERE SUB = '1'.
    MOVE-CORRESPONDING GL_LIPS  TO CL_LIPS.
    APPEND CL_LIPS.
  ENDLOOP.

* 모두 지정되었는지 점검: 모두 지정되엇으면, 피킹 가능
  PERFORM CHECK_PICKING_POSSIBE.


ENDFORM.                    " make_data_hu_NO
*&---------------------------------------------------------------------*
*&      Form  get_xbatch
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM GET_XBATCH .

  REFRESH: "CONTROL 'TC02' FROM SCREEN '0200',
           "CONTROL 'TC12' FROM SCREEN '0300',
           CONTROL 'TC03' FROM SCREEN '0200',
           CONTROL 'TC13' FROM SCREEN '0300',
           CONTROL 'TC04' FROM SCREEN '0200',
           CONTROL 'TC14' FROM SCREEN '0300'.

  CLEAR: XT_ASSG[], XT_ASSG, XT_NASG[], XT_NASG.
  READ TABLE GL_LIPS WITH KEY CHK = 'X'.
  CHECK SY-SUBRC = 0.

  P_QIQTY = GL_LIPS-QIQTY.
  P_VRKME = GL_LIPS-VRKME.

  LOOP AT XL_NASG WHERE ITEM1 = GL_LIPS-ITEM1
                    AND LABST > 0.
    MOVE-CORRESPONDING XL_NASG  TO XT_NASG.

    XT_NASG-DELQTY = XT_NASG-LABST.
    IF NOT XT_NASG-LENGTH IS INITIAL.
      XT_NASG-FACTOR  = XT_NASG-LABST  / XT_NASG-LENGTH.
      XT_NASG-FACTOR1 = XT_NASG-DELQTY / XT_NASG-LENGTH.
    ENDIF.

* 납품미지정재고에 헤더에 있는 미지정재고 수량을 할당
    IF GL_LIPS-NDELQTY < XT_NASG-DELQTY.
      XT_NASG-DELQTY = GL_LIPS-NDELQTY.
    ELSE.
      XT_NASG-DELQTY = XT_NASG-LABST.
    ENDIF.

**** S ADD BY HKSEO 20190201 QMS Project
*    IF GL_LIPS-XCHPF IS NOT INITIAL.
*      PERFORM CHECK_PDI_INSPECTION  USING XT_NASG-MATNR
*                                          XT_NASG-CHARG
*                                          XT_NASG-ICON2
*                                          XT_NASG-PDIDT.
*    ENDIF.
*** E ADD BY HKSEO 20190201 QMS Project

**->출하지점이 M620인경우 IMC 필드추가 2020.09.22 ZLSGAP1  CHM2009-00380
*    IF GT_LIKP-VSTEL = 'M620'.
*      SELECT SINGLE MANDT
*        INTO SY-MANDT
*        FROM ZSDT9500
*       WHERE DMARK     = SPACE
*         AND VBELN     = GL_LIPS-VBELN
*         AND POSNR     = GL_LIPS-POSNR
*         AND SERIAL_NO = XL_NASG-CHARG.
*      IF SY-SUBRC = 0.
*        XT_NASG-ICON_IMC = ICON_LED_GREEN.
*      ELSE.
*        CLEAR XT_NASG-ICON_IMC.
*      ENDIF.
*    ENDIF.
**<-

*--------------------------------------------------------------------*
**-- 26.10 XL_ASSG(기처리) 에 존재하는 배치인 경우 제외할수 있도록
*--------------------------------------------------------------------*
    READ TABLE XL_ASSG TRANSPORTING NO FIELDS WITH KEY CHARG = XT_NASG-CHARG
                                                       MATNR = XT_NASG-MATNR.
    IF SY-SUBRC EQ 0.
      CLEAR XT_NASG. CONTINUE.
    ENDIF.
*--------------------------------------------------------------------*

    APPEND XT_NASG.
  ENDLOOP.

  LOOP AT XL_ASSG WHERE ITEM1 = GL_LIPS-ITEM1
                    AND LABST > 0.
    MOVE-CORRESPONDING XL_ASSG  TO XT_ASSG.

    IF NOT XT_ASSG-LENGTH IS INITIAL.
      XT_ASSG-FACTOR = XT_ASSG-LABST / XT_ASSG-LENGTH.
    ENDIF.

**** S ADD BY HKSEO 20190201 QMS Project
*    IF XT_ASSG-XCHPF IS NOT INITIAL.
*      PERFORM CHECK_PDI_INSPECTION  USING XT_ASSG-MATNR
*                                          XT_ASSG-CHARG
*                                          XT_ASSG-ICON2
*                                          XT_ASSG-PDIDT.
*    ENDIF.
**** E ADD BY HKSEO 20190201 QMS Project

    APPEND XT_ASSG.
  ENDLOOP.

  SORT XT_ASSG BY CHARG.
  SORT XT_NASG BY CHARG.

ENDFORM.                    " get_xbatch
*&---------------------------------------------------------------------*
*&      Form  get_batch_characteristic
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_XL_NASG_MATNR  text
*      -->P_XL_NASG_CHARG  text
*      -->P_BA_LENGTH  text
*      <--P_GV_LENGTH  text
*----------------------------------------------------------------------*
FORM GET_BATCH_CHARACTERISTIC  USING    P_MATNR
                                        P_CHARG
                                        P_CHAR
                            CHANGING    E_ATWRT.

  CALL FUNCTION 'Z_LE_GET_BATCH_CHARACTERISTIC'
    EXPORTING
      I_OBJECT = P_MATNR
      I_CHARG  = P_CHARG
      I_ATNAM  = P_CHAR
    IMPORTING
      E_ATWRT  = E_ATWRT.


ENDFORM.                    " get_batch_characteristic
*&---------------------------------------------------------------------*
*&      Form  move_left_300
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM MOVE_LEFT_300 .

*/ ERROR CHECK
  PERFORM ERROR_CHECK_LEFT_300.

*/ 상단의 지정수량 반영
  PERFORM ASSIGN_GL_LIPS_DELQTY.

*/ 미지정 수량의 감소
  PERFORM DECREASE_LABST TABLES XT_NASG XL_NASG.

*/ 지정 수량의 증가
  PERFORM INCREASE_LABST TABLES XT_NASG XL_ASSG.

*/ 자신에 지정된 수량은 가용수량에서 빼준다.
  LOOP AT XT_NASG WHERE CHK = 'X'.
    LOOP AT XL_NASG WHERE MATNR = XT_NASG-MATNR
                      AND CHARG = XT_NASG-CHARG
                      AND ITEM1 <> XT_NASG-ITEM1.
* 080709 BCKOO
* MTO의 경우 기존 재고에다가 지정된 재고의 경우
* 남아있는 MTO재고에다가 -처리를 하기 때문에 수량이 줄어듬
      IF XL_NASG-SOBKZ <> 'E'.
        XL_NASG-LABST = XL_NASG-LABST - XT_NASG-DELQTY.
        MODIFY XL_NASG TRANSPORTING LABST.
      ENDIF.

    ENDLOOP.
  ENDLOOP.

*/ 미지정,지정 데이타 발췌
  PERFORM GET_XBATCH.



ENDFORM.                    " move_left_300
*&---------------------------------------------------------------------*
*&      Form  move_right_300
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM MOVE_RIGHT_300 .

*/ 상위품목에 배치지정된거는 데이타 고정
  READ TABLE GL_LIPS WITH KEY CHK = 'X'.
  CLEAR: GV_FLAG.
  IF GL_LIPS-FIXED = 'X'.
    MESSAGE I000 WITH
     '상위품목에 이미 배치지정 되었습니다'.
    GV_FLAG = 'X'.
  ENDIF.
  IF GV_FLAG = 'X'.
    LEAVE SCREEN.
  ENDIF.

*/ 상단의 지정수량 반영
  PERFORM ASSIGN_GL_LIPS_DELQTY_1.

*/ 지정 수량의 감소
  PERFORM DECREASE_LABST TABLES XT_ASSG XL_ASSG.

*/ 미지정 수량의 증가
  PERFORM INCREASE_LABST TABLES XT_ASSG XL_NASG.

*/ 자신에 지정된 수량은 가용수량에서 더해준다.
  LOOP AT XT_ASSG WHERE CHK = 'X'.
    LOOP AT XL_NASG WHERE MATNR = XT_ASSG-MATNR
                      AND CHARG = XT_ASSG-CHARG
                      AND ITEM1 <> XT_ASSG-ITEM1.
      XL_NASG-LABST = XL_NASG-LABST + XT_ASSG-DELQTY.
      MODIFY XL_NASG TRANSPORTING LABST.
    ENDLOOP.
  ENDLOOP.


*/ 미지정,지정 데이타 발췌
  PERFORM GET_XBATCH.


ENDFORM.                    " move_right_300
*&---------------------------------------------------------------------*
*&      Form  GET_BATCH_USE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM GET_BATCH_USE .
*{ 기능개선 91460 - 추가
  DATA: BEGIN OF LT_2100 OCCURS 0,
          AUFNR LIKE ZPPT2100-AUFNR,
        END   OF LT_2100.

  DATA: LV_VBELN LIKE MSKA-VBELN,
        LV_POSNR LIKE MSKA-POSNR,
        LV_FLAG.
*} 기능개선 91460 - 추가

  DATA : LT_DATA LIKE STANDARD TABLE OF GT_LIPS.
  CLEAR : LT_DATA[].

  SELECT * FROM MCHB
    WHERE MATNR = GL_LIPS-MATNR
      AND WERKS = GL_LIPS-WERKS
      AND LGORT = GL_LIPS-LGORT
      AND CLABS > 0.
    XL_NASG-ITEM1  = GL_LIPS-ITEM1.
    XL_NASG-POSNR  = GL_LIPS-POSNR.
    XL_NASG-MATNR  = GL_LIPS-MATNR.
    XL_NASG-CHARG  = MCHB-CHARG.
    XL_NASG-VRKME  = GL_LIPS-VRKME.
    XL_NASG-LABST  = MCHB-CLABS.
    XL_NASG-XCHPF  = 'X'.
    XL_NASG-WERKS = GL_LIPS-WERKS.
    COLLECT XL_NASG.
  ENDSELECT.

  LT_DATA[] = GL_LIPS[].

  " 1. 메인 데이터 조회 (특성값 뷰 제외)
  " 루프 내 매핑 검증을 위해 LIKP의 KUNAG(고객번호) 필드를 포함하여 조회
  SELECT A~ITEM1, A~POSNR, A~VRKME, A~WERKS, A~MATNR,
         C~LGORT, C~CLABS AS LABST, C~CHARG,
         B~KUNAG, " 매핑을 위한 임시 필드
         @ABAP_TRUE AS XCHPF
    FROM @LT_DATA AS A INNER JOIN LIKP AS B
                           ON A~VBELN EQ B~VBELN
                       INNER JOIN MCHB AS C
                         ON A~MATNR EQ C~MATNR
                        AND A~WERKS EQ C~WERKS
                        AND A~LGORT EQ C~LGORT
                        AND C~CLABS GT 0
                       INNER JOIN MARA AS E
                         ON A~MATNR EQ E~MATNR
   WHERE E~SPART EQ '10' "SCR 8.0mm
     AND C~LGORT LIKE '34%'
     AND A~LFIMG > 0
    INTO TABLE @DATA(LT_MAIN).

  IF LT_MAIN[] IS NOT INITIAL.

    " 2. 특성값(Batch Characteristic) 데이터 별도 조회
    SELECT MATNR, CHARG, ATWRT
      FROM ZGTSD_CV_GET_VCOFBATCH
       FOR ALL ENTRIES IN @LT_MAIN
     WHERE MATNR EQ @LT_MAIN-MATNR
       AND CHARG EQ @LT_MAIN-CHARG
       AND ATNAM EQ 'PD_CA_CUSTOMER_CODE'
      INTO TABLE @DATA(LT_BATCH).

    SORT LT_BATCH BY MATNR CHARG.

    LOOP AT LT_MAIN ASSIGNING FIELD-SYMBOL(<FS_MAIN>).

      READ TABLE LT_BATCH INTO DATA(LS_BATCH)
                          WITH KEY MATNR = <FS_MAIN>-MATNR
                                   CHARG = <FS_MAIN>-CHARG BINARY SEARCH.

      IF SY-SUBRC EQ 0.
        DATA(LV_ATWRT_IN) = CONV KUNNR( |{ LS_BATCH-ATWRT ALPHA = IN }| ).

        IF <FS_MAIN>-KUNAG NE LV_ATWRT_IN.
          DELETE LT_MAIN.
        ENDIF.
      ELSE.
        DELETE LT_MAIN.
      ENDIF.

    ENDLOOP.
  ENDIF.

  " 4. 최종 결과를 원본 목적지로 전달
  " (CORRESPONDING 구문에 의해 매핑용으로 추가했던 kunag 필드는 자동 제외됨)
  IF LT_MAIN[] IS NOT INITIAL.
    CLEAR : XL_NASG[].
    MOVE-CORRESPONDING LT_MAIN[] TO XL_NASG[].
  ENDIF.

*{기능개선  234896 s/n추가
  LOOP AT XL_NASG.
*    SELECT SINGLE EQUNR
*      INTO XL_NASG-EQUNR
*      FROM EQUI
*      WHERE MATNR = XL_NASG-MATNR
*      AND   CHARGE = XL_NASG-CHARG.

    SELECT SINGLE TAGNR
      INTO XL_NASG-EQUNR
      FROM ZPPT0001
      WHERE WERKS = GL_LIPS-WERKS
      AND CHARG = XL_NASG-CHARG
      AND MATNR = XL_NASG-MATNR.

    MODIFY XL_NASG. CLEAR : XL_NASG.
  ENDLOOP.

*기능개선  234896 s/n추가}

*{ 기능개선 91460 - 추가
*___출하지점 'M410', 플랜트 '3402', 저장위치 '3610'인 경우
*   'ZPPT2100' 또는 'ZMMTI26M' 테이블에 미포장 상태로 있으면
*   조회대상에서 제외
*  IF sy-uname      <> 'ZLSGLSC' AND
*     'M410'        IN s_vstel  AND
*     gl_lips-werks =  '3402'   AND
*     gl_lips-lgort =  '3610'.
*    LOOP AT xl_nasg.
*      CLEAR   : lt_2100.
*      REFRESH : lt_2100.
*
*      SELECT aufnr
*        INTO TABLE lt_2100
*        FROM zppt2100
*       WHERE charg   = xl_nasg-charg
*         AND plnbez  = xl_nasg-matnr
*         AND werks   = gl_lips-werks
*         AND lgort   = gl_lips-lgort
*         AND pkind   = ' '
*         AND stokz   = ' '       "역분개(취소)
*         AND pkcan   = ' '.      "포장취소
*
*      IF sy-subrc = 0.
*        CLEAR : lv_flag.
*
*        LOOP AT lt_2100.
*          CLEAR : lv_vbeln, lv_posnr.
*
*          SELECT SINGLE kdauf
*                        kdpos
*            INTO (lv_vbeln, lv_posnr)
*            FROM afpo
*           WHERE aufnr = lt_2100-aufnr.
*
*          IF lv_vbeln IS INITIAL AND lv_posnr IS INITIAL.
*            lv_flag = 'X'.
*            EXIT.
*          ENDIF.
*        ENDLOOP.
*
*        IF lv_flag = 'X'.
*          DELETE xl_nasg.
*          CONTINUE.
*        ENDIF.
*      ENDIF.
*
*      SELECT SINGLE matnr
*        INTO xl_nasg-matnr
*        FROM zmmti26m
*       WHERE werks = gl_lips-werks
*         AND lgort = gl_lips-lgort
*         AND matnr = xl_nasg-matnr
*         AND charg = xl_nasg-charg
*         AND sobkz = ' '
*         AND sonum = ' '
*         AND flag  <> 'X'
*         AND belnr <> ' '
*         AND loevm <> 'D'.      "삭제
*
*      IF sy-subrc = 0.
*        DELETE xl_nasg.
*        CONTINUE.
*      ENDIF.
*    ENDLOOP.
*  ENDIF.
*} 기능개선 91460 - 추가

ENDFORM.                    " GET_BATCH_USE
*&---------------------------------------------------------------------*
*&      Form  GET_BATCH_NO_USE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM GET_BATCH_NO_USE .
*{ 기능개선 91460 - 추가
  DATA: BEGIN OF LT_2100 OCCURS 0,
          AUFNR LIKE ZPPT2100-AUFNR,
          VEMNG LIKE ZPPT2100-VEMNG,
          MEINS LIKE ZPPT2100-MEINS,
        END   OF LT_2100.

  DATA: LV_VBELN LIKE MSKA-VBELN,
        LV_POSNR LIKE MSKA-POSNR,
        LV_VEMNG LIKE ZPPT2100-VEMNG,
        LV_MEINS LIKE ZPPT2100-MEINS.
*} 기능개선 91460 - 추가

  XL_NASG-ITEM1  = GL_LIPS-ITEM1.
  XL_NASG-POSNR  = GL_LIPS-POSNR.
  XL_NASG-MATNR  = GL_LIPS-MATNR.
  XL_NASG-VRKME  = GL_LIPS-VRKME.
  SELECT SINGLE LABST INTO XL_NASG-LABST FROM MARD
    WHERE MATNR = GL_LIPS-MATNR
      AND WERKS = GL_LIPS-WERKS
      AND LGORT = GL_LIPS-LGORT.
*  xl_nasg-labst  = gl_lips-lfimg.
  XL_NASG-XCHPF  = ' '.
  COLLECT XL_NASG.

*{ 기능개선 91460 - 추가
*___출하지점 'M410', 플랜트 '3402', 저장위치 '3610'인 경우
*   'ZPPT2100' 또는 'ZMMTI26M' 테이블에 미포장 상태로 있으면
*   조회대상에서 제외
*  IF sy-uname      <> 'ZLSGLE' AND
*     'M410'        IN s_vstel  AND
*     gl_lips-werks =  '3402'   AND
*     gl_lips-lgort =  '3610'.
*    LOOP AT xl_nasg.
*      CLEAR   : lt_2100.
*      REFRESH : lt_2100.
*
*      SELECT aufnr
*             vemng
*             meins
*        INTO TABLE lt_2100
*        FROM zppt2100
*       WHERE charg   = ' '
*         AND plnbez  = xl_nasg-matnr
*         AND werks   = gl_lips-werks
*         AND lgort   = gl_lips-lgort
*         AND pkind   = ' '
*         AND stokz   = ' '       "역분개(취소)
*         AND pkcan   = ' '.      "포장취소
*
*      LOOP AT lt_2100.
*        CLEAR : lv_vbeln, lv_posnr.
*
*        SELECT SINGLE kdauf
*                      kdpos
*          INTO (lv_vbeln, lv_posnr)
*          FROM afpo
*         WHERE aufnr = lt_2100-aufnr.
*
*        IF lv_vbeln IS INITIAL AND lv_posnr IS INITIAL.
*          IF xl_nasg-labst > lt_2100-vemng.
*            xl_nasg-labst = xl_nasg-labst - lt_2100-vemng.
*          ELSE.
*            CLEAR : xl_nasg-labst.
*          ENDIF.
*        ENDIF.
*      ENDLOOP.
*
*      SELECT zlfimg1
*              meins
*        INTO (lv_vemng, lv_meins)
*        FROM zmmti26m
*       WHERE werks = gl_lips-werks
*         AND lgort = gl_lips-lgort
*         AND matnr = xl_nasg-matnr
*         AND charg = ' '
*         AND sobkz = ' '
*         AND sonum = ' '
*         AND flag  <> 'X'
*         AND belnr <> ' '
*         AND loevm <> 'D'.      "삭제
*
*        IF xl_nasg-labst > lv_vemng.
*          xl_nasg-labst = xl_nasg-labst - lv_vemng.
*        ELSE.
*          CLEAR : xl_nasg-labst.
*        ENDIF.
*
*      ENDSELECT.
*
*      MODIFY xl_nasg.
*    ENDLOOP.
*  ENDIF.
*} 기능개선 91460 - 추가

ENDFORM.                    " GET_BATCH_NO_USE
*&---------------------------------------------------------------------*
*&      Form  GET_E_BATCH_USE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM GET_E_BATCH_USE .
*{ 기능개선 91460 - 추가
  DATA: BEGIN OF LT_2100 OCCURS 0,
          AUFNR LIKE ZPPT2100-AUFNR,
        END   OF LT_2100.

  DATA: LV_VBELN LIKE MSKA-VBELN,
        LV_POSNR LIKE MSKA-POSNR,
        LV_SONUM LIKE ZMMTI26M-SONUM,
        LV_FLAG.
*} 기능개선 91460 - 추가

  SELECT * FROM MSKA
   WHERE MATNR = GL_LIPS-MATNR
     AND WERKS = GL_LIPS-WERKS
     AND LGORT = GL_LIPS-LGORT
     AND SOBKZ = GL_LIPS-SOBKZ
     AND VBELN = GL_LIPS-VGBEL
     AND POSNR = GL_LIPS-VGPOS.

    XL_NASG-ITEM1 = GL_LIPS-ITEM1.
    XL_NASG-POSNR = GL_LIPS-POSNR.
    XL_NASG-MATNR = GL_LIPS-MATNR.
    XL_NASG-CHARG = MSKA-CHARG.
    XL_NASG-VRKME = GL_LIPS-VRKME.
    XL_NASG-LABST = MSKA-KALAB.
    XL_NASG-SOBKZ = MSKA-SOBKZ.
    XL_NASG-VGBEL = MSKA-VBELN.
    XL_NASG-VGPOS = MSKA-POSNR.
    XL_NASG-XCHPF = 'X'.
    COLLECT XL_NASG.

  ENDSELECT.


*{기능개선  234896 s/n추가
  LOOP AT XL_NASG.
*    SELECT SINGLE EQUNR
*      INTO XL_NASG-EQUNR
*      FROM EQUI
*      WHERE MATNR = XL_NASG-MATNR
*      AND   CHARGE = XL_NASG-CHARG.
    SELECT SINGLE TAGNR
      INTO XL_NASG-EQUNR
      FROM ZPPT0001
      WHERE WERKS = GL_LIPS-WERKS
      AND CHARG = XL_NASG-CHARG
      AND MATNR = XL_NASG-MATNR.


    MODIFY XL_NASG. CLEAR : XL_NASG.
  ENDLOOP.

*기능개선  234896 s/n추가}


*{ 기능개선 91460 - 추가
*___출하지점 'M410', 플랜트 '3402', 저장위치 '3610'인 경우
*   'ZPPT2100' 또는 'ZMMTI26M' 테이블에 미포장 상태로 있으면
*   조회대상에서 제외
*  IF sy-uname      <> 'ZLSGLE' AND
*     'M410'        IN s_vstel  AND
*     gl_lips-werks =  '3402'   AND
*     gl_lips-lgort =  '3610'.
*    LOOP AT xl_nasg.
*      CLEAR   : lt_2100.
*      REFRESH : lt_2100.
*
*      SELECT aufnr
*        INTO TABLE lt_2100
*        FROM zppt2100
*       WHERE charg   = xl_nasg-charg
*         AND plnbez  = xl_nasg-matnr
*         AND werks   = gl_lips-werks
*         AND lgort   = gl_lips-lgort
*         AND pkind   = ' '
*         AND stokz   = ' '       "역분개(취소)
*         AND pkcan   = ' '.      "포장취소
*
*      IF sy-subrc = 0.
*        LOOP AT lt_2100.
*          CLEAR : lv_vbeln, lv_posnr.
*
*          SELECT SINGLE kdauf
*                        kdpos
*            INTO (lv_vbeln, lv_posnr)
*            FROM afpo
*           WHERE aufnr = lt_2100-aufnr.
*
*          IF lv_vbeln = gl_lips-vgbel AND lv_posnr = gl_lips-vgpos.
*            lv_flag = 'X'.
*            EXIT.
*          ENDIF.
*        ENDLOOP.
*
*        IF lv_flag = 'X'.
*          DELETE xl_nasg.
*          CONTINUE.
*        ENDIF.
*      ENDIF.
*
*      CONCATENATE gl_lips-vgbel gl_lips-vgpos INTO lv_sonum.
*
*      SELECT SINGLE matnr
*        INTO xl_nasg-matnr
*        FROM zmmti26m
*       WHERE werks = gl_lips-werks
*         AND lgort = gl_lips-lgort
*         AND matnr = xl_nasg-matnr
*         AND charg = xl_nasg-charg
*         AND sobkz = gl_lips-sobkz
*         AND sonum = lv_sonum
*         AND flag  <> 'X'
*         AND belnr <> ' '
*         AND loevm <> 'D'.      "삭제
*
*      IF sy-subrc = 0.
*        DELETE xl_nasg.
*        CONTINUE.
*      ENDIF.
*    ENDLOOP.
*  ENDIF.
*} 기능개선 91460 - 추가

ENDFORM.                    " GET_E_BATCH_USE
*&---------------------------------------------------------------------*
*&      Form  GET_E_BATCH_NO_USE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM GET_E_BATCH_NO_USE .
*{ 기능개선 91460 - 추가
  DATA: BEGIN OF LT_2100 OCCURS 0,
          AUFNR LIKE ZPPT2100-AUFNR,
          VEMNG LIKE ZPPT2100-VEMNG,
          MEINS LIKE ZPPT2100-MEINS,
        END   OF LT_2100.

  DATA: LV_VBELN LIKE MSKA-VBELN,
        LV_POSNR LIKE MSKA-POSNR,
        LV_SONUM LIKE ZMMTI26M-SONUM,
        LV_VEMNG LIKE ZPPT2100-VEMNG,
        LV_MEINS LIKE ZPPT2100-MEINS.
*} 기능개선 91460 - 추가

  XL_NASG-ITEM1  = GL_LIPS-ITEM1.
  XL_NASG-POSNR  = GL_LIPS-POSNR.
  XL_NASG-MATNR  = GL_LIPS-MATNR.
  XL_NASG-VRKME  = GL_LIPS-VRKME.
  XL_NASG-SOBKZ  = GL_LIPS-SOBKZ.
  SELECT SINGLE KALAB INTO XL_NASG-LABST FROM MSKA
    WHERE MATNR = GL_LIPS-MATNR
      AND WERKS = GL_LIPS-WERKS
      AND LGORT = GL_LIPS-LGORT
      AND SOBKZ = GL_LIPS-SOBKZ
      AND VBELN = GL_LIPS-VGBEL
      AND POSNR = GL_LIPS-VGPOS.

*  xl_nasg-labst  = gl_lips-lfimg.
  XL_NASG-XCHPF  = ' '.
  COLLECT XL_NASG.

*{ 기능개선 91460 - 추가
*___출하지점 'M410', 플랜트 '3402', 저장위치 '3610'인 경우
*   'ZPPT2100' 또는 'ZMMTI26M' 테이블에 미포장 상태로 있으면
*   조회대상에서 제외
*  IF sy-uname      <> 'ZLSGLE' AND
*     'M410'        IN s_vstel  AND
*     gl_lips-werks =  '3402'   AND
*     gl_lips-lgort =  '3610'.
*    LOOP AT xl_nasg.
*      CLEAR   : lt_2100.
*      REFRESH : lt_2100.
*
*      SELECT aufnr
*             vemng
*             meins
*        INTO TABLE lt_2100
*        FROM zppt2100
*       WHERE charg   = ' '
*         AND plnbez  = xl_nasg-matnr
*         AND werks   = gl_lips-werks
*         AND lgort   = gl_lips-lgort
*         AND pkind   = ' '
*         AND stokz   = ' '       "역분개(취소)
*         AND pkcan   = ' '.      "포장취소
*
*      LOOP AT lt_2100.
*        CLEAR : lv_vbeln, lv_posnr.
*
*        SELECT SINGLE kdauf
*                      kdpos
*          INTO (lv_vbeln, lv_posnr)
*          FROM afpo
*         WHERE aufnr = lt_2100-aufnr.
*
*        IF lv_vbeln = gl_lips-vgbel AND lv_posnr = gl_lips-vgpos.
*          IF xl_nasg-labst > lv_vemng.
*            xl_nasg-labst = xl_nasg-labst - lv_vemng.
*          ELSE.
*            CLEAR : xl_nasg-labst.
*          ENDIF.
*        ENDIF.
*      ENDLOOP.
*
*      CONCATENATE gl_lips-vgbel gl_lips-vgpos INTO lv_sonum.
*
*      SELECT zlfimg1
*              meins
*        INTO (lv_vemng, lv_meins)
*        FROM zmmti26m
*       WHERE werks = gl_lips-werks
*         AND lgort = gl_lips-lgort
*         AND matnr = xl_nasg-matnr
*         AND charg = ' '
*         AND sobkz = gl_lips-sobkz
*         AND sonum = lv_sonum
*         AND flag  <> 'X'
*         AND belnr <> ' '
*         AND loevm <> 'D'.      "삭제
*        IF xl_nasg-labst > lv_vemng.
*          xl_nasg-labst = xl_nasg-labst - lv_vemng.
*        ELSE.
*          CLEAR : xl_nasg-labst.
*        ENDIF.
*      ENDSELECT.
*
*      MODIFY xl_nasg.
*    ENDLOOP.
*  ENDIF.
*} 기능개선 91460 - 추가

ENDFORM.                    " GET_E_BATCH_NO_USE
* 배치 모두선택 기능을 먼저 추가하기 위해 막아놓고 반영함 by J.Y.Lee
**&---------------------------------------------------------------------
*
**&      Form  GET_W_BATCH_USE
**&---------------------------------------------------------------------
*
**       text
**----------------------------------------------------------------------
*
**  -->  p1        text
**  <--  p2        text
**----------------------------------------------------------------------
*
*FORM GET_W_BATCH_USE .
*
*  SELECT * FROM MSKU
*   WHERE MATNR = GL_LIPS-MATNR
*     AND WERKS = GL_LIPS-WERKS
*     AND SOBKZ = GL_LIPS-SOBKZ
*     AND KULAB >= 0.
**     AND KUNNR = GL_LIPS-KUNNR.
*
*    XL_NASG-ITEM1 = GL_LIPS-ITEM1.
*    XL_NASG-POSNR = GL_LIPS-POSNR.
*    XL_NASG-MATNR = GL_LIPS-MATNR.
*    XL_NASG-CHARG = MSKU-CHARG.
*    XL_NASG-VRKME = GL_LIPS-VRKME.
*    XL_NASG-LABST = MSKU-KULAB.
*    XL_NASG-SOBKZ = MSKU-SOBKZ.
*    XL_NASG-XCHPF = 'X'.
*    COLLECT XL_NASG.
*
*  ENDSELECT.
*
*ENDFORM.                    " GET_W_BATCH_USE
**&---------------------------------------------------------------------
*
**&      Form  GET_W_BATCH_NO_USE
**&---------------------------------------------------------------------
*
**       text
**----------------------------------------------------------------------
*
**  -->  p1        text
**  <--  p2        text
**----------------------------------------------------------------------
*
*FORM GET_W_BATCH_NO_USE .
*
*  XL_NASG-ITEM1  = GL_LIPS-ITEM1.
*  XL_NASG-POSNR  = GL_LIPS-POSNR.
*  XL_NASG-MATNR  = GL_LIPS-MATNR.
*  XL_NASG-VRKME  = GL_LIPS-VRKME.
*  XL_NASG-SOBKZ  = GL_LIPS-SOBKZ.
*  SELECT SINGLE KALAB INTO XL_NASG-LABST FROM MSKA
*    WHERE MATNR = GL_LIPS-MATNR
*      AND WERKS = GL_LIPS-WERKS
*      AND LGORT = GL_LIPS-LGORT
*      AND SOBKZ = GL_LIPS-SOBKZ
*      AND VBELN = GL_LIPS-VGBEL
*      AND POSNR = GL_LIPS-VGPOS.
*
**  xl_nasg-labst  = gl_lips-lfimg.
*  XL_NASG-XCHPF  = ' '.
*  COLLECT XL_NASG.
*
*ENDFORM.                    " GET_W_BATCH_NO_USE
*&---------------------------------------------------------------------*
*&      Form  GET_XL_NASG
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM GET_XL_NASG .

  CLEAR: XL_NASG[], XL_NASG, XT_NASG[], XT_NASG.

*/ ------> 미지정
  LOOP AT GL_LIPS WHERE SUB = '1'.
    IF GL_LIPS-SOBKZ = ' '.
      IF GL_LIPS-XCHPF = 'X'.
*/ 1. 일반재고-배치사용
        PERFORM GET_BATCH_USE.
      ELSE.
*/ 2. 일반재고-배치미사용
        PERFORM GET_BATCH_NO_USE.
      ENDIF.
* 배치 모두선택 기능을 먼저 추가하기 위해 막아놓고 반영함 by J.Y.Lee
** 위탁재고 재고 지정 추가
*    ELSEIF GL_LIPS-SOBKZ = 'W'.
*      IF GL_LIPS-XCHPF = 'X'.
**/ 1. 위탁재고-배치사용
*        PERFORM GET_W_BATCH_USE.
*      ELSE.
**/ 2. 위탁재고-배치미사용
*        PERFORM GET_W_BATCH_NO_USE.
*      ENDIF.
    ELSE.
      IF GL_LIPS-XCHPF = 'X'.
*/ 3. 특별재고-배치사용
        PERFORM GET_E_BATCH_USE.
      ELSE.
*/ 4. 특별재고-배치미사용
        PERFORM GET_E_BATCH_NO_USE.
      ENDIF.
    ENDIF.
    CLEAR: XL_NASG.
  ENDLOOP.

  DATA(LT_FOR) = XL_NASG[].
  SORT LT_FOR BY MATNR CHARG WERKS .
  DELETE ADJACENT DUPLICATES FROM LT_FOR COMPARING MATNR CHARG WERKS .
  IF LT_FOR[] IS NOT INITIAL.

    SELECT * INTO TABLE @DATA(LT_SOGR)
      FROM ZGTSD_CV_GET_VCOFBATCH
       FOR ALL ENTRIES IN @LT_FOR
     WHERE MATNR = @LT_FOR-MATNR
       AND CHARG = @LT_FOR-CHARG
       AND WERKS = @LT_FOR-WERKS
*       AND LGORT = @LT_FOR-LGORT
       AND ATNAM = 'PD_CA_GRADE'.
    SORT LT_SOGR BY MATNR CHARG WERKS.

    SELECT A~*
      FROM ZGTSD_CV_GET_VCOFBATCH AS A INNER JOIN MARA AS B
                                       ON A~MATNR EQ B~MATNR
                                       AND B~SPART EQ '10'
       FOR ALL ENTRIES IN @LT_FOR
     WHERE A~MATNR = @LT_FOR-MATNR
       AND A~CHARG = @LT_FOR-CHARG
       AND A~WERKS = @LT_FOR-WERKS
*       AND LGORT = @LT_FOR-LGORT
       AND A~ATNAM = 'PD_CA_CUSTOMER_CODE'  "SCR 8.0mm 거래처 Batch Characteristic
      INTO TABLE @DATA(LT_SOCUST).
    SORT LT_SOCUST BY MATNR CHARG WERKS.

  ENDIF.

*/ BATCH 조장
  LOOP AT XL_NASG.
    CLEAR: GV_LENGTH.
    PERFORM GET_BATCH_CHARACTERISTIC
        USING: XL_NASG-MATNR XL_NASG-CHARG
               BA_LENGTH
     CHANGING: GV_LENGTH.

    XL_NASG-LENGTH = GV_LENGTH.
*    xl_nasg-delqty = xl_nasg-labst.

*   자재의 기본단위와 판매단위가 다를 경우 다른 납품의 재고지정건이
*   미지정 재고로 표기되는 오류 수정 by J.Y.Lee 05/31/2011
*   Request by 허경도D
    READ TABLE GL_LIPS WITH KEY ITEM1 = XL_NASG-ITEM1.
    IF SY-SUBRC = 0.

      IF GL_LIPS-MEINS <> GL_LIPS-VRKME.
        IF GL_LIPS-UMVKZ IS NOT INITIAL.
          XL_NASG-LENGTH = XL_NASG-LENGTH * GL_LIPS-UMVKN / GL_LIPS-UMVKZ.
          XL_NASG-LABST  = XL_NASG-LABST  * GL_LIPS-UMVKN / GL_LIPS-UMVKZ.
        ENDIF.
      ENDIF.

*등급
      READ TABLE LT_SOGR INTO DATA(LS_GR) WITH KEY MATNR = XL_NASG-MATNR
                                                   CHARG = XL_NASG-CHARG
                                                   WERKS = XL_NASG-WERKS BINARY SEARCH.
      IF SY-SUBRC = 0.
        XL_NASG-GRADE = LS_GR-ATWRT.
      ENDIF.


* 거래처
      READ TABLE LT_SOCUST INTO DATA(LS_CUST) WITH KEY MATNR = XL_NASG-MATNR
                                                       CHARG = XL_NASG-CHARG
                                                       WERKS = XL_NASG-WERKS BINARY SEARCH.
      IF SY-SUBRC = 0.
        DATA : LV_KUNNR TYPE KNA1-NAME1.
        CLEAR : LV_KUNNR.

        LV_KUNNR = LS_CUST-ATWRT.
        LV_KUNNR = CONV KUNNR( |{ LV_KUNNR  ALPHA = IN }| ).

        SELECT SINGLE NAME1 INTO @DATA(LV_NAME1)
          FROM KNA1
         WHERE KUNNR = @LV_KUNNR.

        IF LV_NAME1 IS NOT INITIAL.
          XL_NASG-NAME1 = LV_NAME1.
        ENDIF.

      ENDIF.
    ENDIF.

    MODIFY XL_NASG.
  ENDLOOP.

*************************************************
* CSR번호: C2006080801000000259 일련번호 자동지정
* 수정일 : 20060903 수정자: Koo Bon-Chan
* 내역 :
* 납품미지정 재고 추출 로직변경
* 피킹시 MTO, MTS 재고를 구분하여 각기 지정된 재고 수량만 가져옴
* -> 쿼리에 특별재고조건 추가
*************************************************

*** 배치사용재고는 다른 납품에 지정된 납품수량을 빼준다
  LOOP AT XL_NASG WHERE XCHPF = 'X'
                    AND SOBKZ NE 'E'.
    CLEAR: GV_LABST1.
    READ TABLE GL_LIPS WITH KEY ITEM1 = XL_NASG-ITEM1.

    SELECT SUM( P~LFIMG )
      INTO GV_LABST1
      FROM LIPS AS P
**     INNER JOIN VBUK AS K
**        ON P~VBELN = K~VBELN
     INNER JOIN LIKP AS A
        ON P~VBELN = A~VBELN
     INNER JOIN MARC AS B
        ON P~MATNR EQ B~MATNR
       AND P~WERKS EQ B~WERKS
     WHERE P~WERKS = GL_LIPS-WERKS
       AND P~LGORT = GL_LIPS-LGORT
       AND P~MATNR = GL_LIPS-MATNR
       AND P~CHARG = XL_NASG-CHARG
*       AND p~vbeln <> gl_lips-vbeln3
       AND B~DPCBT NE 'A'
**       AND a~wbstk <> 'C'                " 가온 소재 SCR 8.0mm 는 Service 출고만 하기 때문에
       AND P~SOBKZ = GL_LIPS-SOBKZ    " 특별재고 지정부분 추가
       AND A~LFART IN ('LF', 'LF4', 'LF7', 'LF8', 'LF9',
                       'LF10', 'NL')     .

    XL_NASG-LABST =  XL_NASG-LABST - GV_LABST1.

    MODIFY XL_NASG.
  ENDLOOP.

** 배치미사용재고는 다른 납품에 지정된 피킹수량을 빼준다
  LOOP AT XL_NASG WHERE XCHPF = ' '.
    CLEAR: GV_LABST1.
    READ TABLE GL_LIPS WITH KEY ITEM1 = XL_NASG-ITEM1.
    IF GL_LIPS-SOBKZ = 'E'.

    ELSE.
      SELECT SUM( V~RFMNG )
        INTO GV_LABST1
        FROM VBFA AS V
       INNER JOIN LIPS AS P
          ON V~VBELV = P~VBELN
         AND V~POSNV = P~POSNR
       INNER JOIN LIKP AS K
          ON P~VBELN = K~VBELN
       WHERE P~WERKS = GL_LIPS-WERKS
         AND P~LGORT = GL_LIPS-LGORT
         AND P~MATNR = GL_LIPS-MATNR
*         AND p~charg = xl_nasg-charg
         AND P~VBELN <> GL_LIPS-VBELN
         AND K~WBSTK <> 'C'
         AND P~SOBKZ = GL_LIPS-SOBKZ    " 특별재고 지정부분 추가
         AND V~VBTYP_N = 'Q'.
    ENDIF.

    XL_NASG-LABST =  XL_NASG-LABST - GV_LABST1.

    MODIFY XL_NASG.
  ENDLOOP.

*/ 자신에 지정된 수량은 가용수량에서 빼준다.
  LOOP AT XL_NASG. "WHERE chk = 'X'.
    CLEAR: GV_DELQTY.
    LOOP AT GL_LIPS WHERE MATNR = XL_NASG-MATNR
                      AND CHARG = XL_NASG-CHARG
                      AND ITEM1 <> XL_NASG-ITEM1.
      ADD GL_LIPS-DELQTY   TO GV_DELQTY.
    ENDLOOP.
    XL_NASG-LABST = XL_NASG-LABST - GV_DELQTY.
*    MODIFY XL_NASG TRANSPORTING LABST.
  ENDLOOP.

*/ 배치특성(정렬순서: CU72)
  REFRESH: GT_KSML.
  LOOP AT GL_LIPS WHERE SUB = '1'.
    PERFORM GET_SORT_BATCH_CHARACTERISTIC USING GL_LIPS-MATNR.
  ENDLOOP.

  LOOP AT XL_NASG.
* 배치특성을 구하고, 정렬순서와 비교하여 순번을 매겨서
* 재정렬한다.
    REFRESH: GT_AUSP.
    PERFORM BATCH_CHARACTERISTIC TABLES GT_AUSP
                                 USING XL_NASG-MATNR
                                       XL_NASG-CHARG.
    CLEAR: LV_COL_ATWRT.

    DATA : LV_MTART LIKE MARA-MTART.
    DATA : LV_XCHAR LIKE MARC-XCHAR.

*    SELECT SINGLE mtart xchar
*    INTO   (lv_mtart, lv_xchar)
*    FROM   mara AS a INNER JOIN marc AS c
*        ON a~matnr = c~matnr
*    WHERE  a~matnr = xl_nasg-matnr
*    AND    c~werks = '3602'.

** 트랙터 제품군이고 MFER이고 뱃치사용자재만 체크
*    IF s_vstel-low >= 'M620' AND s_vstel-low <= 'M629'
*       AND lv_mtart = 'MFER' AND lv_xchar = 'X'.
*
*      READ TABLE gt_ausp WITH KEY atnam = 'PD_AM_EG_NO'.
*      IF sy-subrc <> 0.
*        CLEAR : gt_ausp.
*        gt_ausp-atnam = 'PD_AM_EG_NO'.
*        gt_ausp-posnr = '001'.
*        APPEND gt_ausp.
*      ENDIF.
*
*      READ TABLE gt_ausp WITH KEY atnam = 'PD_AM_TM_NO'.
*      IF sy-subrc <> 0.
*        CLEAR : gt_ausp.
*        gt_ausp-atnam = 'PD_AM_TM_NO'.
*        gt_ausp-posnr = '002'.
*        APPEND gt_ausp.
*      ENDIF.
*
*      READ TABLE gt_ausp WITH KEY atnam = 'PD_AM_CHASSIS_NO'.
*      IF sy-subrc <> 0.
*        CLEAR : gt_ausp.
*        gt_ausp-atnam = 'PD_AM_CHASSIS_NO'.
*        gt_ausp-posnr = '003'.
*        APPEND gt_ausp.
*      ENDIF.
*
*    ENDIF.

    SORT GT_AUSP BY POSNR.
    LOOP AT GT_AUSP.
      CONCATENATE LV_COL_ATWRT GT_AUSP-ATWRT ';'
        INTO LV_COL_ATWRT. " SEPARATED BY ';'.
    ENDLOOP.

    XL_NASG-CHART = LV_COL_ATWRT+0(99).
    MODIFY XL_NASG.

  ENDLOOP.

ENDFORM.                    " GET_XL_NASG
*&---------------------------------------------------------------------*
*&      Form  GET_XL_ASSG
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM GET_XL_ASSG .

  CLEAR: XL_ASSG[], XL_ASSG, XT_ASSG[], XT_ASSG.

  LOOP AT GL_LIPS WHERE XCHPF = 'X'
                    AND CHARG <> ' '.
    SELECT SINGLE * FROM LIPS WHERE VBELN = GL_LIPS-VBELN
                                AND POSNR = GL_LIPS-POSNR.

    XL_ASSG-ITEM1  = GL_LIPS-ITEM1.
    XL_ASSG-POSNR  = GL_LIPS-POSNR.
    XL_ASSG-MATNR  = GL_LIPS-MATNR.
    XL_ASSG-CHARG  = GL_LIPS-CHARG.
    XL_ASSG-VRKME  = GL_LIPS-VRKME.
    XL_ASSG-LABST  = LIPS-LFIMG.
    XL_ASSG-SOBKZ  = GL_LIPS-SOBKZ.
    XL_ASSG-XCHPF  = GL_LIPS-XCHPF.
*    xl_assg-vgbel  = gl_lips-vgbel.
*    xl_assg-vgpos  = gl_lips-vgpos.
    XL_ASSG-WERKS = GL_LIPS-WERKS.
    COLLECT XL_ASSG.  CLEAR: XL_ASSG.
  ENDLOOP.

  LOOP AT GL_LIPS WHERE XCHPF = ' '
                    AND SUB   = '1'.
    XL_ASSG-ITEM1  = GL_LIPS-ITEM1.
    XL_ASSG-POSNR  = GL_LIPS-POSNR.
    XL_ASSG-MATNR  = GL_LIPS-MATNR.
    XL_ASSG-CHARG  = GL_LIPS-CHARG.
    XL_ASSG-VRKME  = GL_LIPS-VRKME.
*   Picking 수량
    SELECT SINGLE RFMNG INTO XL_ASSG-LABST FROM VBFA
                       WHERE VBELV   = GL_LIPS-VBELN
                         AND POSNV   = GL_LIPS-POSNR
                         AND VBTYP_N = 'Q'.

*    xl_assg-labst  = gl_lips-lfimg.
    XL_ASSG-SOBKZ  = GL_LIPS-SOBKZ.
    XL_ASSG-XCHPF  = GL_LIPS-XCHPF.
*    xl_assg-vgbel  = gl_lips-vgbel.
*    xl_assg-vgpos  = gl_lips-vgpos.
    COLLECT XL_ASSG. CLEAR: XL_ASSG.
  ENDLOOP.

  DATA(LT_FOR) = XL_ASSG[].
  SORT LT_FOR BY MATNR CHARG WERKS .
  DELETE ADJACENT DUPLICATES FROM LT_FOR COMPARING MATNR CHARG WERKS .
  IF LT_FOR[] IS NOT INITIAL.

    SELECT * INTO TABLE @DATA(LT_SOGR)
      FROM ZGTSD_CV_GET_VCOFBATCH
       FOR ALL ENTRIES IN @LT_FOR
     WHERE MATNR = @LT_FOR-MATNR
       AND CHARG = @LT_FOR-CHARG
       AND WERKS = @LT_FOR-WERKS
*       AND LGORT = @LT_FOR-LGORT
       AND ATNAM = 'PD_CA_GRADE'.
    SORT LT_SOGR BY MATNR CHARG WERKS.

    SELECT A~*
      FROM ZGTSD_CV_GET_VCOFBATCH AS A INNER JOIN MARA AS B
                                       ON A~MATNR EQ B~MATNR
                                       AND B~SPART EQ '10'
       FOR ALL ENTRIES IN @LT_FOR
     WHERE A~MATNR = @LT_FOR-MATNR
       AND A~CHARG = @LT_FOR-CHARG
       AND A~WERKS = @LT_FOR-WERKS
*       AND LGORT = @LT_FOR-LGORT
       AND A~ATNAM = 'PD_CA_CUSTOMER_CODE'  "SCR 8.0mm 거래처 Batch Characteristic
      INTO TABLE @DATA(LT_SOCUST).
    SORT LT_SOCUST BY MATNR CHARG WERKS.

  ENDIF.

  LOOP AT XL_ASSG.
*    SELECT SINGLE EQUNR
*      INTO XL_ASSG-EQUNR
*      FROM EQUI
*      WHERE MATNR = XL_ASSG-MATNR
*      AND   CHARGE = XL_ASSG-CHARG.
    SELECT SINGLE TAGNR
      INTO XL_ASSG-EQUNR
      FROM ZPPT0001
      WHERE WERKS = XL_ASSG-WERKS
      AND CHARG = XL_ASSG-CHARG
      AND MATNR = XL_ASSG-MATNR.

*등급
    READ TABLE LT_SOGR INTO DATA(LS_GR) WITH KEY MATNR = XL_ASSG-MATNR
                                                 CHARG = XL_ASSG-CHARG
                                                 WERKS = XL_ASSG-WERKS BINARY SEARCH.
    IF SY-SUBRC = 0.
      XL_ASSG-GRADE = LS_GR-ATWRT.
    ENDIF.


* 거래처
    READ TABLE LT_SOCUST INTO DATA(LS_CUST) WITH KEY MATNR = XL_ASSG-MATNR
                                                     CHARG = XL_ASSG-CHARG
                                                     WERKS = XL_ASSG-WERKS BINARY SEARCH.
    IF SY-SUBRC = 0.
      DATA(LV_KUNNR) = CONV KUNNR( |{ LS_CUST-ATWRT ALPHA = IN }| ).

      SELECT SINGLE NAME1
        FROM KNA1
       WHERE KUNNR = @LV_KUNNR
        INTO @DATA(LV_NAME1).

      IF LV_NAME1 IS NOT INITIAL.
        XL_ASSG-NAME1 = LV_NAME1.
      ENDIF.

    ENDIF.

    MODIFY XL_ASSG. CLEAR : XL_ASSG.
  ENDLOOP.


* 가용수량 - 재고지정수량(동일제품일 경우)
* BonChan Koo 080821 MTO재고 두개 이상 품목이 있을 시
* 처음 재고만 가지고 재고수량 판단해 비지정 수량
* 가져오지 못하는 문제 수정
  LOOP AT XL_NASG. "WHERE XCHPF = 'X'.
    CLEAR: GV_DELQTY.
    IF XL_NASG-SOBKZ IS INITIAL.
      LOOP AT XL_ASSG WHERE MATNR = XL_NASG-MATNR
                        AND CHARG = XL_NASG-CHARG.
        GV_DELQTY = GV_DELQTY + XL_ASSG-LABST.
      ENDLOOP.
      IF SY-SUBRC = 0.
        XL_NASG-LABST = XL_NASG-LABST - GV_DELQTY.
        MODIFY XL_NASG TRANSPORTING LABST.
      ENDIF.
    ELSE.
      LOOP AT XL_ASSG WHERE MATNR = XL_NASG-MATNR
                        AND CHARG = XL_NASG-CHARG
                        AND ITEM1 = XL_NASG-ITEM1.
        GV_DELQTY = GV_DELQTY + XL_ASSG-LABST.
      ENDLOOP.
      IF SY-SUBRC = 0.
        XL_NASG-LABST = XL_NASG-LABST - GV_DELQTY.
        MODIFY XL_NASG TRANSPORTING LABST.
      ENDIF.
    ENDIF.
  ENDLOOP.
*  LOOP AT XL_NASG. "WHERE XCHPF = 'X'.
*    CLEAR: GV_DELQTY.
*    LOOP AT XL_ASSG WHERE MATNR = XL_NASG-MATNR
*                      AND CHARG = XL_NASG-CHARG.
*    GV_DELQTY = GV_DELQTY + XL_ASSG-LABST.
*    ENDLOOP.
*    IF SY-SUBRC = 0.
*      XL_NASG-LABST = XL_NASG-LABST - GV_DELQTY.
*      MODIFY XL_NASG TRANSPORTING LABST.
*    ENDIF.
*  ENDLOOP.

** 구버젼(전체 체크해서 수량계산)
*  LOOP AT XL_NASG. "WHERE XCHPF = 'X'.
*    READ TABLE XL_ASSG WITH KEY ITEM1 = XL_NASG-ITEM1
*                                CHARG = XL_NASG-CHARG.
*    IF SY-SUBRC = 0.
*      XL_NASG-LABST = XL_NASG-LABST - XL_ASSG-LABST.
*      MODIFY XL_NASG TRANSPORTING LABST.
*    ENDIF.
*  ENDLOOP.

*  LOOP AT xl_nasg WHERE XCHPF = ' '.
*    READ TABLE xl_assg WITH KEY item1 = xl_nasg-item1.
*    IF sy-subrc = 0.
*      xl_nasg-labst = xl_nasg-labst - xl_assg-labst.
*      MODIFY xl_nasg.
*    ENDIF.
*  ENDLOOP.

  DELETE XL_NASG WHERE LABST = 0.

*/ BATCH 조장
  LOOP AT XL_ASSG.
    CLEAR: GV_LENGTH.
    PERFORM GET_BATCH_CHARACTERISTIC
        USING: XL_ASSG-MATNR XL_ASSG-CHARG
               BA_LENGTH
     CHANGING: GV_LENGTH.

    XL_ASSG-LENGTH = GV_LENGTH.
    MODIFY XL_ASSG.
  ENDLOOP.

  LOOP AT XL_ASSG.
* 배치특성을 구하고, 정렬순서와 비교하여 순번을 매겨서
* 재정렬한다.
    REFRESH: GT_AUSP.
    PERFORM BATCH_CHARACTERISTIC TABLES GT_AUSP
                                 USING XL_ASSG-MATNR
                                       XL_ASSG-CHARG.
    CLEAR: LV_COL_ATWRT.

    DATA : LV_MTART LIKE MARA-MTART.
    DATA : LV_XCHAR LIKE MARC-XCHAR.



    SORT GT_AUSP BY POSNR.
    LOOP AT GT_AUSP.
      CONCATENATE LV_COL_ATWRT GT_AUSP-ATWRT ';'
        INTO LV_COL_ATWRT." SEPARATED BY ';'.
    ENDLOOP.

    XL_ASSG-CHART = LV_COL_ATWRT+0(99).
    MODIFY XL_ASSG.

  ENDLOOP.

ENDFORM.                    " GET_XL_ASSG
*&---------------------------------------------------------------------*
*&      Form  get_sort_batch_characteristic
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_XL_NASG_MATNR  text
*----------------------------------------------------------------------*
FORM GET_SORT_BATCH_CHARACTERISTIC  USING    P_MATNR.

  DATA: L_OBJNO LIKE INOB-CUOBJ.  "TYPE CUOBJ.
  DATA: L_OBJECT  LIKE KSSK-OBJEK.
  DATA: L_CLINT   TYPE CLINT.
  DATA: L_CLASS   LIKE KLAH-CLASS.

*/ 자재의 클라스를 구하고, 앞에 S를 붙인다.
  CLEAR: L_OBJNO.
  L_OBJECT = P_MATNR.

  CALL FUNCTION 'CUOB_GET_NUMBER'
    EXPORTING
      CLASS_TYPE       = '023'
      OBJECT_ID        = L_OBJECT
      TABLE            = 'MARA'
*     I_READ_DB_FIRST  = ' '
    IMPORTING
      OBJECT_NUMBER    = L_OBJNO
    EXCEPTIONS
      LOCK_PROBLEM     = 1
      OBJECT_NOT_FOUND = 2
      OTHERS           = 3.
  IF SY-SUBRC = 0.
    CLEAR: L_CLINT.
    SELECT SINGLE CLINT INTO L_CLINT FROM KSSK
      WHERE OBJEK = L_OBJNO
        AND KLART = '023'.

    CLEAR: L_CLASS.
    SELECT SINGLE CLASS INTO L_CLASS FROM KLAH
      WHERE CLINT = L_CLINT.

    CONCATENATE 'S' L_CLASS INTO L_CLASS .

    CLEAR: L_CLINT.
    SELECT SINGLE CLINT INTO L_CLINT FROM KLAH
      WHERE KLART = '040'
        AND CLASS = L_CLASS.

    SELECT * APPENDING CORRESPONDING FIELDS OF TABLE GT_KSML
      FROM KSML
     WHERE CLINT = L_CLINT.


* CONVERSION_EXIT_ATINN_INPUT
* CONVERSION_EXIT_ATINN_OUTPUT
  ENDIF.
*/ KSML-CLINT을 읽으면, 된다.

ENDFORM.                    " get_sort_batch_characteristic
*&---------------------------------------------------------------------*
*&      Form  batch_characteristic
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GT_AUSP  text
*      -->P_XL_LIPS_MATNR  text
*      -->P_XL_LIPS_CHARG  text
*----------------------------------------------------------------------*
FORM BATCH_CHARACTERISTIC  TABLES   PT_AUSP LIKE GT_AUSP[]
                           USING    P_MATNR
                                    P_CHARG.

  DATA: L_OBJEK LIKE KSSK-OBJEK,  "TYPE OBJNUM,
        L_OBJNO LIKE INOB-CUOBJ,  "TYPE CUOBJ,
        OBJEK   LIKE AUSP-OBJEK.  "TYPE OBJNUM.

  CONCATENATE P_MATNR P_CHARG INTO L_OBJEK.

  CALL FUNCTION 'CUOB_GET_NUMBER'
    EXPORTING
      CLASS_TYPE       = '023'
      OBJECT_ID        = L_OBJEK
      TABLE            = 'MCH1'
    IMPORTING
      OBJECT_NUMBER    = L_OBJNO
    EXCEPTIONS
      LOCK_PROBLEM     = 1
      OBJECT_NOT_FOUND = 2
      OTHERS           = 3.

  IF SY-SUBRC = 0.
    OBJEK = L_OBJNO.

    SELECT * INTO TABLE PT_AUSP
    FROM   AUSP
    WHERE  OBJEK = OBJEK
      AND  KLART = '023'.
    IF SY-SUBRC = 0.
      LOOP AT PT_AUSP.
        READ TABLE GT_KSML WITH KEY IMERK = PT_AUSP-ATINN.
        IF SY-SUBRC = 0.
          PT_AUSP-POSNR = GT_KSML-POSNR.

          PERFORM CONVERSION_EXIT_ATINN_OUTPUT
                    USING PT_AUSP-ATINN
                 CHANGING PT_AUSP-ATNAM.
          MODIFY PT_AUSP.
        ELSE.
          DELETE PT_AUSP.
        ENDIF.
      ENDLOOP.
    ENDIF.
  ENDIF.

  DATA: LV_VALUE(13) TYPE P DECIMALS 3.
  DATA: LV_VALUE_CHAR(30).
  DATA: LV_DATE LIKE SY-DATUM.

  LOOP AT PT_AUSP.
    CASE PT_AUSP-ATNAM.
      WHEN 'SD_MILLCA_LENGTH_VKRME' OR
           'SAP_MILLCA_LENGTH'      OR
           'SAP_MILLCA_LENGTH_SUB'  OR
           'SAP_MILLCA_FACTOR'      OR
           'BT_AA_NET_WEIGHT'       OR   "개별중량
           'BT_AA_GRS_WEIGHT'       .    "총중량
        LV_VALUE = PT_AUSP-ATFLV.
        PT_AUSP-ATWRT = LV_VALUE.
      WHEN 'BT_AA_PROD_DATE'.
        LV_VALUE  = PT_AUSP-ATFLV.
        LV_VALUE_CHAR = LV_VALUE.
        SHIFT LV_VALUE_CHAR LEFT DELETING LEADING SPACE.
        LV_DATE  = LV_VALUE_CHAR+0(8).
        PT_AUSP-ATWRT = LV_DATE.
      WHEN OTHERS.

    ENDCASE.

    SHIFT PT_AUSP-ATWRT LEFT DELETING LEADING SPACE.
    MODIFY PT_AUSP.
  ENDLOOP.


ENDFORM.                    " batch_characteristic
*&---------------------------------------------------------------------*
*&      Form  conversion_exit_atinn_output
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_PT_AUSP_ATINN  text
*      <--P_PT_AUSP_ATNAM  text
*----------------------------------------------------------------------*
FORM CONVERSION_EXIT_ATINN_OUTPUT  USING    P_ATINN
                                   CHANGING P_ATNAM.

  CALL FUNCTION 'CONVERSION_EXIT_ATINN_OUTPUT'
    EXPORTING
      INPUT  = P_ATINN
    IMPORTING
      OUTPUT = P_ATNAM.

ENDFORM.                    " conversion_exit_atinn_output
*&---------------------------------------------------------------------*
*&      Form  decrease_labst
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_XT_NASG  text
*      -->P_XL_NASG  text
*----------------------------------------------------------------------*
FORM DECREASE_LABST  TABLES   PT_BTCH LIKE XT_NASG[]
                              PL_BTCH LIKE XL_NASG[].

  LOOP AT PT_BTCH WHERE CHK = 'X'.
    LOOP AT PL_BTCH WHERE ITEM1 = PT_BTCH-ITEM1
                      AND CHARG = PT_BTCH-CHARG.
      PL_BTCH-LABST = PL_BTCH-LABST - PT_BTCH-DELQTY.
      MODIFY PL_BTCH.
    ENDLOOP.
  ENDLOOP.


ENDFORM.                    " decrease_labst
*&---------------------------------------------------------------------*
*&      Form  increase_labst
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_XT_NASG  text
*      -->P_XL_NASG  text
*----------------------------------------------------------------------*
FORM INCREASE_LABST  TABLES   PT_BTCH LIKE XT_NASG[]
                              PL_BTCH LIKE XL_NASG[].

  LOOP AT PT_BTCH WHERE CHK = 'X'.
    LOOP AT PL_BTCH WHERE ITEM1 = PT_BTCH-ITEM1
                      AND CHARG = PT_BTCH-CHARG.
      PL_BTCH-LABST = PL_BTCH-LABST + PT_BTCH-DELQTY.
      PL_BTCH-CHART  = PT_BTCH-CHART.
      MODIFY PL_BTCH.
    ENDLOOP.
    IF SY-SUBRC <> 0.
      PL_BTCH-ITEM1  = PT_BTCH-ITEM1.
      PL_BTCH-POSNR  = PT_BTCH-POSNR.
      PL_BTCH-MATNR  = PT_BTCH-MATNR.
      PL_BTCH-CHARG  = PT_BTCH-CHARG.
      PL_BTCH-NAME1  = PT_BTCH-NAME1.
      PL_BTCH-GRADE  = PT_BTCH-GRADE.
      PL_BTCH-LENGTH = PT_BTCH-LENGTH.
      PL_BTCH-CHART  = PT_BTCH-CHART.
      PL_BTCH-LABST  = PT_BTCH-DELQTY.
      PL_BTCH-VRKME  = PT_BTCH-VRKME.
      PL_BTCH-XCHPF  = PT_BTCH-XCHPF.
      PL_BTCH-EQUNR  = PT_BTCH-EQUNR.
      APPEND PL_BTCH.
    ENDIF.
  ENDLOOP.

ENDFORM.                    " increase_labst
*&---------------------------------------------------------------------*
*&      Form  ASSIGN_GL_LIPS_DELQTY
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM ASSIGN_GL_LIPS_DELQTY .

  WA_LIPS[] = GL_LIPS[].

  LOOP AT XT_NASG WHERE CHK = 'X'.
    CLEAR: GV_DELQTY.
    LOOP AT GL_LIPS WHERE ITEM1 = XT_NASG-ITEM1
                      AND CHARG = XT_NASG-CHARG.
      GL_LIPS-DELQTY = GL_LIPS-DELQTY + XT_NASG-DELQTY.
      MODIFY GL_LIPS.
    ENDLOOP.
    IF SY-SUBRC <> 0.

      LOOP AT GL_LIPS WHERE ICON1 = ' '
                        AND SUB   = '1'
                        AND ITEM1 = XT_NASG-ITEM1.
        GL_LIPS-ICON1   = C_ICON1.
        MODIFY GL_LIPS TRANSPORTING ICON1.
      ENDLOOP.

      READ TABLE WA_LIPS WITH KEY ITEM1 = XT_NASG-ITEM1.
      MOVE-CORRESPONDING WA_LIPS TO GL_LIPS.
      GL_LIPS-CHK     = ' '.
      GL_LIPS-SUB     = '2'.
      GL_LIPS-POSNR   = ' '.
      GL_LIPS-CHARG   = XT_NASG-CHARG.
      GL_LIPS-DELQTY  = XT_NASG-DELQTY.
      GL_LIPS-GRADE   = XT_NASG-GRADE.
      GL_LIPS-NAME1   = XT_NASG-NAME1.
      GL_LIPS-LFIMG   = ' '.
      GL_LIPS-JISIQTY = ' '.
      GL_LIPS-ICON1   = ' '.
      APPEND GL_LIPS.
    ENDIF.
  ENDLOOP.

ENDFORM.                    " ASSIGN_GL_LIPS_DELQTY
*&---------------------------------------------------------------------*
*&      Form  assign_gl_lips_delqty_1
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM ASSIGN_GL_LIPS_DELQTY_1 .

  LOOP AT XT_ASSG WHERE CHK = 'X'.
    LOOP AT GL_LIPS WHERE ITEM1 = XT_ASSG-ITEM1
                      AND CHARG = XT_ASSG-CHARG.
      GL_LIPS-DELQTY = GL_LIPS-DELQTY - XT_ASSG-DELQTY.
      MODIFY GL_LIPS TRANSPORTING DELQTY .
    ENDLOOP.

    DELETE GL_LIPS WHERE DELQTY = 0
                     AND SUB    = '2'
                     AND ITEM1  = XT_ASSG-ITEM1.

    LOOP AT GL_LIPS WHERE ITEM1 = XT_ASSG-ITEM1
                      AND SUB   = '2'.
    ENDLOOP.
    IF SY-SUBRC <> 0.
      LOOP AT GL_LIPS WHERE ITEM1 = XT_ASSG-ITEM1
                        AND SUB   = '1'.
        GL_LIPS-ICON1   = ' '.
        MODIFY GL_LIPS TRANSPORTING ICON1.
      ENDLOOP.
    ENDIF.
  ENDLOOP.


ENDFORM.                    " assign_gl_lips_delqty_1
*&---------------------------------------------------------------------*
*&      Form  get_jisiqty_delqty_1
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM GET_JISIQTY_DELQTY .

*/ 지시수량(jisiqty): 현재납품수량,
*  지정수량(delqty) : 배치사용(배치지정수량), 배치미사용(포장수량)

*/
  LOOP AT GL_LIPS .
    IF GL_LIPS-SUB = '1'.
      GL_LIPS-JISIQTY = GL_LIPS-LFIMG.
*      gl_lips-delqty  = gl_lips-lfimg.
    ELSE.
      GL_LIPS-JISIQTY = GL_LIPS-LFIMG.
      GL_LIPS-DELQTY  = GL_LIPS-LFIMG.
    ENDIF.

    IF GL_LIPS-XCHPF = ' '.
      GL_LIPS-DELQTY = GL_LIPS-LFIMG.
    ENDIF.
    GL_LIPS-LFIMG    = 0.

    MODIFY GL_LIPS TRANSPORTING LFIMG DELQTY JISIQTY.
  ENDLOOP.

  WA_LIPS[] = GL_LIPS[].

  LOOP AT GL_LIPS WHERE SUB = '1'.
* 지시수량
    CLEAR: GV_JISIQTY, GV_DELQTY.
    LOOP AT WA_LIPS WHERE ITEM1 = GL_LIPS-ITEM1.
      ADD WA_LIPS-JISIQTY TO GV_JISIQTY.
*      ADD wa_lips-delqty  TO gv_delqty.
    ENDLOOP.
    GL_LIPS-JISIQTY = GV_JISIQTY.

* 미지정수량
*    gl_lips-ndelqty = gl_lips-jisiqty - gv_delqty.

*// QI 재고
    IF GL_LIPS-SOBKZ = ' '.
      IF GL_LIPS-XCHPF = 'X'.
*/ 1. 일반재고-배치사용: MCHB
        SELECT SUM( CINSM ) INTO GL_LIPS-QIQTY FROM MCHB
          WHERE MATNR = GL_LIPS-MATNR
            AND WERKS = GL_LIPS-WERKS
            AND LGORT = GL_LIPS-LGORT.
      ELSE.
*/ 2. 일반재고-배치미사용: MARD
        SELECT SINGLE INSME INTO GL_LIPS-QIQTY FROM MARD
          WHERE MATNR = GL_LIPS-MATNR
            AND WERKS = GL_LIPS-WERKS
            AND LGORT = GL_LIPS-LGORT.
      ENDIF.
    ELSE.
      IF GL_LIPS-XCHPF = 'X'.
*/ 3. 특별재고-배치사용: MSKA
        SELECT SUM( KAINS ) INTO GL_LIPS-QIQTY FROM MSKA
         WHERE MATNR = GL_LIPS-MATNR
           AND WERKS = GL_LIPS-WERKS
           AND LGORT = GL_LIPS-LGORT
           AND SOBKZ = GL_LIPS-SOBKZ
           AND VBELN = GL_LIPS-VGBEL
           AND POSNR = GL_LIPS-VGPOS.
      ELSE.
*/ 4. 특별재고-배치미사용: MSKA
        SELECT SINGLE KAINS INTO GL_LIPS-QIQTY FROM MSKA
          WHERE MATNR = GL_LIPS-MATNR
            AND WERKS = GL_LIPS-WERKS
            AND LGORT = GL_LIPS-LGORT
            AND SOBKZ = GL_LIPS-SOBKZ
            AND VBELN = GL_LIPS-VGBEL
            AND POSNR = GL_LIPS-VGPOS.
      ENDIF.
    ENDIF.

    IF GL_LIPS-MEINS <> GL_LIPS-VRKME.
      IF NOT GL_LIPS-UMVKZ IS INITIAL.
        GL_LIPS-QIQTY =
          GL_LIPS-QIQTY * GL_LIPS-UMVKN / GL_LIPS-UMVKZ.
      ENDIF.
    ENDIF.

    MODIFY GL_LIPS TRANSPORTING JISIQTY NDELQTY QIQTY.
  ENDLOOP.

  LOOP AT GL_LIPS WHERE SUB = '2'.
    GL_LIPS-JISIQTY = 0.
    MODIFY GL_LIPS TRANSPORTING JISIQTY.
  ENDLOOP.


ENDFORM.                    " get_jisiqty_delqty_1
*&---------------------------------------------------------------------*
*&      Form  save_300
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM SAVE_300.

  PERFORM POP_UP_CONFIRM(ZLER0004) USING '< 확인 >'
                               '저장하시겠습니까?'
                      CHANGING GV_RETURN.

  CHECK GV_RETURN = 'J'.

  PERFORM PREPARE_SAVE_300.

  PERFORM BDC_RUN_VL02N_300
    USING P_WADAT_IST TVROT-ROUTE T173T-VSART P_WADAT.


ENDFORM.                                                    " save_300
*&---------------------------------------------------------------------*
*&      Form  prepare_save_300
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM PREPARE_SAVE_300 .


*/ 추가대상
  REFRESH: GT_TAB11, GT_TAB8.
  CLEAR  : GT_TAB11, GT_TAB8.

**/배치미사용
  LOOP AT XL_ASSG WHERE XCHPF = ' '.
    READ TABLE CL_ASSG WITH KEY POSNR = XL_ASSG-POSNR.
    IF SY-SUBRC <> 0.
      READ TABLE GL_LIPS WITH KEY ITEM1 = XL_ASSG-ITEM1
                                  SUB   = '1'.
      GT_TAB8-POSNR = XL_ASSG-POSNR.
      GT_TAB8-LFIMG = GL_LIPS-JISIQTY.
*      gt_tab8-pikmg = xl_assg-labst.
      GT_TAB8-PIKMG = GL_LIPS-DELQTY.
      GT_TAB8-VRKME = GL_LIPS-VRKME.
      APPEND GT_TAB8.
    ENDIF.
  ENDLOOP.

  LOOP AT CL_ASSG WHERE XCHPF = ' '.
    READ TABLE XL_ASSG WITH KEY ITEM1 = CL_ASSG-ITEM1
                                POSNR = CL_ASSG-POSNR.
    IF SY-SUBRC = 0.
      IF CL_ASSG-LABST <> XL_ASSG-LABST.  "수량변경
        READ TABLE GL_LIPS WITH KEY ITEM1 = XL_ASSG-ITEM1
                                    SUB   = '1'.
        GT_TAB8-POSNR = XL_ASSG-POSNR.
        GT_TAB8-LFIMG = GL_LIPS-JISIQTY.
*        gt_tab8-pikmg = xl_assg-labst.
        GT_TAB8-PIKMG = GL_LIPS-DELQTY.
        GT_TAB8-VRKME = GL_LIPS-VRKME.
        APPEND GT_TAB8.
      ENDIF.
    ENDIF.
  ENDLOOP.

**/ 납품수량변경
  LOOP AT GL_LIPS WHERE SUB = '1'
                    AND XCHPF = ' '.
    LOOP AT CL_LIPS WHERE POSNR =    GL_LIPS-POSNR
                      AND JISIQTY <> GL_LIPS-JISIQTY.
    ENDLOOP.
    IF SY-SUBRC = 0.
      LOOP AT GT_TAB8 WHERE POSNR = GL_LIPS-POSNR.
        GT_TAB8-LFIMG = GL_LIPS-JISIQTY.
        GT_TAB8-PIKMG = GL_LIPS-DELQTY.
        MODIFY GT_TAB8 TRANSPORTING LFIMG.
      ENDLOOP.
      IF SY-SUBRC <> 0.
        GT_TAB8-POSNR = GL_LIPS-POSNR.
        GT_TAB8-LFIMG = GL_LIPS-JISIQTY.
        GT_TAB8-PIKMG = GL_LIPS-DELQTY.
        GT_TAB8-VRKME = GL_LIPS-VRKME.
        APPEND GT_TAB8.
      ENDIF.
    ENDIF.
  ENDLOOP.

**/ 납품수량변경
  LOOP AT GL_LIPS WHERE SUB = '1'
                    AND XCHPF = 'X'.
    LOOP AT CL_LIPS WHERE POSNR =    GL_LIPS-POSNR
                      AND JISIQTY <> GL_LIPS-JISIQTY.
    ENDLOOP.
    IF SY-SUBRC = 0.
      LOOP AT GT_TAB8 WHERE POSNR = GL_LIPS-POSNR.
        GT_TAB8-LFIMG = GL_LIPS-JISIQTY.
        MODIFY GT_TAB8 TRANSPORTING LFIMG.
      ENDLOOP.
      IF SY-SUBRC <> 0.
        GT_TAB8-POSNR = GL_LIPS-POSNR.
        GT_TAB8-LFIMG = GL_LIPS-JISIQTY.
        GT_TAB8-PIKMG = 0.
        GT_TAB8-VRKME = GL_LIPS-VRKME.
        APPEND GT_TAB8.
      ENDIF.
    ENDIF.
  ENDLOOP.

**/ 배치사용
  LOOP AT XL_ASSG WHERE XCHPF = 'X'.
    READ TABLE CL_ASSG WITH KEY POSNR = XL_ASSG-POSNR.
    IF SY-SUBRC <> 0.
      READ TABLE GL_LIPS WITH KEY ITEM1 = XL_ASSG-ITEM1.
      GT_TAB11-UECHA = XL_ASSG-ITEM1.
      GT_TAB11-CHARG = XL_ASSG-CHARG.
      GT_TAB11-LGORT = GL_LIPS-LGORT.
      GT_TAB11-LFIMG = XL_ASSG-LABST.
      GT_TAB11-VRKME = GL_LIPS-VRKME.
      GT_TAB11-APD   = 'X'.
      APPEND GT_TAB11.
    ENDIF.
  ENDLOOP.

*/ 추가,삭제 대상
  LOOP AT CL_ASSG WHERE XCHPF = 'X'.
    READ TABLE XL_ASSG WITH KEY ITEM1 = CL_ASSG-ITEM1
                                POSNR = CL_ASSG-POSNR.
    IF SY-SUBRC = 0.
      IF CL_ASSG-LABST <> XL_ASSG-LABST.  "수량변경
        READ TABLE GL_LIPS WITH KEY ITEM1 = XL_ASSG-ITEM1.
        GT_TAB11-UECHA = XL_ASSG-ITEM1.
        GT_TAB11-POSNR = XL_ASSG-POSNR.
        GT_TAB11-CHARG = XL_ASSG-CHARG.
        GT_TAB11-LGORT = GL_LIPS-LGORT.
        GT_TAB11-LFIMG = XL_ASSG-LABST.
        GT_TAB11-VRKME = GL_LIPS-VRKME.
        IF NOT GT_TAB11-LFIMG IS INITIAL.
          GT_TAB11-APD   = 'X'.
        ENDIF .
        GT_TAB11-DEL   = 'X'.
        APPEND GT_TAB11.
      ENDIF.
    ENDIF.
  ENDLOOP.

  LOOP AT GT_TAB11 WHERE LFIMG = 0.
    GT_TAB11-APD   = ' '.
    GT_TAB11-DEL   = 'X'.
    MODIFY GT_TAB11.
  ENDLOOP.

ENDFORM.                    " prepare_save_300
*&---------------------------------------------------------------------*
*&      Form  bdc_run_VL02N_300
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM BDC_RUN_VL02N_300 USING V_WADAT V_ROUTE V_VSART V_WADAT2.

  CLEAR: GV_RESULT, GV_MSG.

  PERFORM DEQUEUE_ALL.


*************************************************
* CSR번호: C2006080801000000260 일련번호 자동해제
* 수정일 : 20060820 수정자: Koo Bon-Chan

* 내역 :
* 자재가 배치번호와 일련번호 동시 사용시 적용
* 배치번호 사용유무 CHECK : MARA-XCHPF
* 일련번호 사용유무 CHECK : MARC-SERNP에 프로파일이 지정되어 있는 경우
* 피킹저장 후 배치번호 자동지정 해제 시 프로그램 로직 변경
*  1. 일련번호 지정 전부해제
*  2. 배체해제 반영
*  3. 피킹지정 CLICK시 일련번호 전부 배치번호와 동일하게 재 지정

  DATA : L_SERNP      LIKE MARC-SERNP VALUE ' ',
         L_MATNR      LIKE LIPS-MATNR,
         L_WERKS      LIKE LIPS-WERKS,
         L_CHARG      LIKE LIPS-CHARG,
         L_UECHA      LIKE LIPS-UECHA,
         L_POSNR      LIKE LIPS-POSNR,
         L_ANZSN      LIKE LIPS-ANZSN,
         L_MULTI1(20),
         L_MULTI2(20),
         L_MULTI3(20),
         L_MULTI4(20),
         KOSTA        LIKE LIPS-KOSTA,
         L_SEQ        TYPE N,
         L_SEQ1       TYPE N,
         L_SEQ2       TYPE N,
         L_MSGTY      LIKE SY-MSGTY VALUE 'S'.
  DATA : BEGIN OF LT_TAB OCCURS 0,
           VBELN LIKE LIPS-VBELN,
           POSNR LIKE LIPS-POSNR,
         END OF LT_TAB.

  CLEAR : BDCDATA,BDCDATA[],LT_TAB,LT_TAB[].
  PERFORM ENQUENE_DO USING P_VBELN.


  LOOP AT GT_TAB11 WHERE DEL = 'X'.

    SELECT VBELN POSNR
    APPENDING TABLE LT_TAB
    FROM   LIPS
    WHERE  VBELN =  P_VBELN
    AND    CHARG <> ' '
    AND    UECHA IN ( SELECT UECHA
                      FROM   LIPS
                      WHERE  VBELN = P_VBELN
                      AND    POSNR = GT_TAB11-POSNR
                    ).
  ENDLOOP.

*  SORT LT_TAB.
  DELETE ADJACENT DUPLICATES FROM LT_TAB.

  PERFORM DYNPRO USING:
  'X'    'SAPMV50A'              '4004',
  ' '    'BDC_CURSOR'            'LIKP-VBELN',
  ' '    'LIKP-VBELN'	         P_VBELN,
  ' '    'BDC_OKCODE'            '/00'.

  LOOP AT GT_TAB11.

    SELECT SINGLE MATNR WERKS CHARG UECHA
    INTO   (L_MATNR, L_WERKS, L_CHARG, L_UECHA)
    FROM   LIPS
    WHERE  VBELN = P_VBELN
    AND    POSNR = GT_TAB11-POSNR.

    SELECT SINGLE XCHPF FROM MARA
    INTO   L_SERNP
    WHERE  MATNR = L_MATNR
    AND    XCHPF = 'X'.

* 배치번호 사용유무 체크
    IF SY-SUBRC = 0 .

      SELECT SINGLE SERNP FROM MARC
      INTO   L_SERNP
      WHERE  MATNR = L_MATNR
      AND    WERKS = L_WERKS
      AND    SERNP <> ' '.

* 일련번호 사용유무 체크
      IF SY-SUBRC = 0.

        SELECT COUNT(*)
        INTO   L_SEQ1
        FROM   LIPS
        WHERE  VBELN  = P_VBELN
        AND    UECHA  = L_UECHA
        AND    POSNR <= GT_TAB11-POSNR.

        L_SEQ = L_UECHA+4(1).
        L_SEQ1 = L_SEQ1 + 1.
        L_SEQ2 = L_SEQ2 + 1.
        CONCATENATE '=CHPL_T0'           L_SEQ2       INTO L_MULTI1.
        CONCATENATE 'RV50A-CHMULT(0'     L_SEQ   ')'  INTO L_MULTI2.
        CONCATENATE 'LIPS-POSNR(0'       L_SEQ1  ')'  INTO L_MULTI3.
        CONCATENATE 'RV50A-LIPS_SELKZ(0' L_SEQ1  ')'  INTO L_MULTI4.


*        PERFORM DYNPRO USING:
*          'X'    'SAPMV50A'              '4004',
*          ' '    'BDC_CURSOR'            'LIKP-VBELN',
*          ' '    'LIKP-VBELN'              P_VBELN,
*          ' '    'BDC_OKCODE'            '/00'.

        IF L_POSNR NE L_UECHA OR SY-TABIX EQ 1.

          IF SY-TABIX NE 1.

            PERFORM DYNPRO USING:
              'X'    'SAPMV50A'              '1000',
              ' '    'BDC_OKCODE'            '=BACK_T'.

          ENDIF.

          PERFORM DYNPRO USING:
            'X'    'SAPMV50A'              '1000',
              ' '    'BDC_OKCODE'            L_MULTI1,
              ' '    'BDC_CURSOR'            L_MULTI2.

          L_POSNR = L_UECHA.

        ENDIF.

*        PERFORM DYNPRO USING:
*          'X'    'SAPMV50A'              '1000',
*          ' '    'BDC_OKCODE'            L_MULTI1,
*          ' '    'BDC_CURSOR'            L_MULTI2.

        PERFORM DYNPRO USING:
              'X' 'SAPMV50A'              '1000',
              ' ' 'BDC_OKCODE'            '=POPO_T'.      "품목찾기

        PERFORM DYNPRO USING:
              'X' 'SAPMV50A'              '0111',
              ' ' 'BDC_OKCODE'            '=WEIT',        "ENTER
              ' ' 'RV50A-POSNR'           GT_TAB11-POSNR.  "

        PERFORM DYNPRO USING:
            'X'    'SAPMV50A'         '1000',
                ' '    'BDC_OKCODE'       '=PSER_T'.
*                ' '    L_MULTI4           'X'.


        PERFORM DYNPRO USING:
                'X'    'SAPLIPW1'              '0300',
                ' '    'BDC_CURSOR'            'RIPW0-SERNR(01)',
                ' '    'BDC_OKCODE'            '=RWS',
                ' '    'RIPW0-SERNR(01)'       ' '.

        SELECT SINGLE ANZSN
        INTO   L_ANZSN
        FROM   LIPS
        WHERE  VBELN  = P_VBELN
        AND    POSNR  = GT_TAB11-POSNR.

        IF L_ANZSN > 0.

          PERFORM DYNPRO USING:
                  'X'    'SAPLSPO1'	           '0200',
                  ' '    'BDC_OKCODE'	           '=YES'.
        ENDIF.


*        PERFORM DYNPRO USING:
*                      'X'    'SAPMV50A'              '1000',
*                      ' '    'BDC_OKCODE'            '=SICH_T'.
*
*
*        CALL TRANSACTION 'VL02N' USING BDCDATA
*                               MODE bdc_mode UPDATE 'S'
*                               MESSAGES INTO MESSTAB.



      ENDIF.

    ENDIF.

  ENDLOOP.

  PERFORM DYNPRO USING:
  'X'    'SAPMV50A'              '1000',
  ' '    'BDC_OKCODE'            '=SICH_T'.

  PERFORM DEQUEUE_ALL.

*  CALL TRANSACTION 'VL02N' USING BDCDATA
*       MODE bdc_mode UPDATE 'S'
*       MESSAGES INTO MESSTAB.


  L_MSGTY = SY-MSGTY.
  L_MSGTY = 'S'.
* CSR번호: C2006080820000000260 수정끝
**************************************.
  IF L_MSGTY = 'S'.
    IF S_VSTEL-LOW BETWEEN 'M600' AND 'M799'.
      CALL FUNCTION 'Z_LE_VL02N_BATCH4_SERNR'
        EXPORTING
          I_VBELN  = P_VBELN
          I_WAST   = ' '
          I_WADAT  = V_WADAT
          I_ROUTE  = V_ROUTE
          I_VSART  = V_VSART
          I_WADAT2 = V_WADAT2
          I_MODE   = BDC_MODE
        IMPORTING
          RETURN   = GV_RESULT
          ZMESSAGE = GV_MSG
        TABLES
          IT_DATA  = GT_TAB11
          PT_DATA8 = GT_TAB8.
    ELSE.
      CALL FUNCTION 'Z_LE_VL02N_BATCH4'
        EXPORTING
          I_VBELN  = P_VBELN
          I_WAST   = ' '
          I_WADAT  = V_WADAT
          I_ROUTE  = V_ROUTE
          I_VSART  = V_VSART
          I_MODE   = BDC_MODE
        IMPORTING
          RETURN   = GV_RESULT
          ZMESSAGE = GV_MSG
        TABLES
          IT_DATA  = GT_TAB11
          PT_DATA8 = GT_TAB8.

*{ 기능개선 91460 - 추가
*___배치지정 저장 후 피킹 실행
      PERFORM MAKE_PICKING_DATA_300_1.

      PERFORM CALL_TRANSACTION_VL02N.
*} 기능개선 91460 - 추가
    ENDIF.

    IF GV_RESULT = 'S'.
*  / SAVE SHIPPING NO. - LONG TEXT
      PERFORM SAVE_SHIPPING_NO .

      CLEAR: R_VBELN[], R_VBELN, ET_LIKP[], ET_LIKP.
      PERFORM GET_RANGE_VBELN USING P_VBELN.
      PERFORM DATA_QUERY TABLES ET_LIKP
                                R_VBELN.
      LOOP AT ET_LIKP.
        LOOP AT GT_LIKP WHERE VBELN = ET_LIKP-VBELN.
          MOVE-CORRESPONDING ET_LIKP TO GT_LIKP.
          GT_LIKP-WADAT_IST = SY-DATUM.
          MODIFY GT_LIKP .
        ENDLOOP.
      ENDLOOP.

      GV_SAVE_FLAG = 'X'.
      PERFORM GET_DETAIL.
      MESSAGE S001 WITH P_VBELN '저장하였습니다'.
    ELSE.
      MESSAGE I002 WITH P_VBELN GV_MSG '저장하지 못했습니다'.
      LEAVE TO SCREEN 100.
    ENDIF.

  ELSE.
    MESSAGE I002 WITH P_VBELN GV_MSG '저장하지 못했습니다(일련번호)'.
    LEAVE TO SCREEN 100.
  ENDIF.

ENDFORM.                    " bdc_run_VL02N_300
*&---------------------------------------------------------------------*
*&      Form  ERROR_CHECK_LEFT_300
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM ERROR_CHECK_LEFT_300 .

*/ 상위품목에 배치지정된거는 데이타 고정
  READ TABLE GL_LIPS WITH KEY CHK = 'X'.
  CLEAR: GV_FLAG.
  IF GL_LIPS-FIXED = 'X'.
    MESSAGE I000 WITH
     '상위품목에 이미 배치지정 되었습니다'.
    GV_FLAG = 'X'.
  ENDIF.
  IF GV_FLAG = 'X'.
    LEAVE SCREEN.
  ENDIF.

  CLEAR: GV_DELQTY, GV_JISIQTY.
  LOOP AT XT_NASG WHERE CHK = 'X'.
    ADD XT_NASG-DELQTY  TO GV_DELQTY.
  ENDLOOP.
  LOOP AT XT_ASSG.
    ADD XT_ASSG-LABST   TO GV_DELQTY.
  ENDLOOP.

  READ TABLE GL_LIPS WITH KEY CHK = 'X'.
  LOOP AT GL_LIPS WHERE ITEM1 = GL_LIPS-ITEM1.
    ADD GL_LIPS-JISIQTY  TO GV_JISIQTY.
  ENDLOOP.

* 070615 SDB03 허경도대리님요청
* 메세지 변경
* 지정수량 초과시 오류 메세지에 납품 수량이 얼마인데
* 지정수량이 얼마여서 얼마 초과 한다는 메세지
  DATA : LV_QTY LIKE GV_DELQTY.
  IF GV_DELQTY > GV_JISIQTY.
    LV_QTY     = GV_DELQTY - GV_JISIQTY.
    MESSAGE I024 WITH GV_JISIQTY GV_DELQTY LV_QTY.
    CLEAR : LV_QTY.
    LEAVE SCREEN.
  ENDIF.

ENDFORM.                    " ERROR_CHECK_LEFT_300
*&---------------------------------------------------------------------*
*&      Form  check_picking_possibe
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM CHECK_PICKING_POSSIBE .

  CLEAR: P_KOSTK, OK_PICKING, GV_JISIQTY, GV_DELQTY.
  LOOP AT GL_LIPS.
    ADD GL_LIPS-JISIQTY  TO  GV_JISIQTY.
    ADD GL_LIPS-DELQTY   TO  GV_DELQTY.
  ENDLOOP.

  IF GV_JISIQTY = GV_DELQTY.
    OK_PICKING = 'X'.
  ENDIF.

  P_KOSTK = GT_LIKP-KOSTK.

  IF P_KOSTK = 'A'.
    P_KOSTK_T = '미처리'.
  ELSEIF P_KOSTK = 'B'.
    P_KOSTK_T = '부분처리'.
  ELSEIF P_KOSTK = 'C'.
    P_KOSTK_T = '피킹완료'.
  ELSEIF P_KOSTK = ' '.
    P_KOSTK_T = '피킹 관련 없음'.
  ENDIF.

ENDFORM.                    " check_picking_possibe
*&---------------------------------------------------------------------*
*&      Form  get_range_vbeln
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_P_VBELN  text
*----------------------------------------------------------------------*
FORM GET_RANGE_VBELN  USING    P_VBELN.

  R_VBELN-SIGN   = 'I'.
  R_VBELN-OPTION = 'EQ'.
  R_VBELN-LOW    = P_VBELN.
  APPEND R_VBELN.
ENDFORM.                    " get_range_vbeln
*&---------------------------------------------------------------------*
*&      Form  picking
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM PICKING .

  PERFORM ERROR_CHECK_PICKING.

  PERFORM POP_UP_CONFIRM(ZLER0004) USING '< 확인 >'
                               '피킹 하시겠습니까?'
                      CHANGING GV_RETURN.
  CHECK GV_RETURN = 'J'.

  PERFORM MAKE_PICKING_DATA.

* 기계 트랙터 제품군 뱃치특성 체크 위한 Subroutine
  PERFORM CHECK_BATCH.

  PERFORM BDC_RUN_PICKING
    USING P_WADAT_IST TVROT-ROUTE T173T-VSART.

ENDFORM.                    " picking
*&---------------------------------------------------------------------*
*&      Form  error_check_picking
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM ERROR_CHECK_PICKING .

ENDFORM.                    " error_check_picking
*&---------------------------------------------------------------------*
*&      Form  make_picking_data
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM MAKE_PICKING_DATA .

  CLEAR: GT_TAB1[], GT_TAB1.
  LOOP AT GL_LIPS WHERE SUB = '1'.
*                    AND xchpf = 'X'.
    GT_TAB1-POSNR = GL_LIPS-POSNR.
    GT_TAB1-PIKMG = GL_LIPS-DELQTY.
    APPEND GT_TAB1.
  ENDLOOP.

*  DELETE gt_tab1 WHERE pikmg = 0.

  CLEAR: GT_TAB2[], GT_TAB2.
  LOOP AT GL_LIPS WHERE SUB = '2'.
*                    AND xchpf = 'X'.
    GT_TAB2-UECHA = GL_LIPS-ITEM1.
    GT_TAB2-POSNR = GL_LIPS-POSNR.
    GT_TAB2-CHARG = GL_LIPS-CHARG.
    GT_TAB2-VRKME = GL_LIPS-VRKME.
    GT_TAB2-PIKMG = GL_LIPS-DELQTY.
    APPEND GT_TAB2.
  ENDLOOP.

ENDFORM.                    " make_picking_data
*&---------------------------------------------------------------------*
*&      Form  bdc_run_picking
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_TVROT_ROUTE  text
*      -->P_T173T_VSART  text
*----------------------------------------------------------------------*
FORM BDC_RUN_PICKING  USING   V_WADAT V_ROUTE V_VSART.

  CLEAR: GV_RESULT, GV_MSG.

  PERFORM DEQUEUE_ALL.

  IF S_VSTEL-LOW >= 'M600' AND S_VSTEL-LOW <= 'M799'.
    CALL FUNCTION 'Z_LE_VL02N_SERNR'
      EXPORTING
        I_VBELN  = P_VBELN
        I_WADAT  = V_WADAT
        I_ROUTE  = V_ROUTE
        I_VSART  = V_VSART
        I_MODE   = BDC_MODE
      IMPORTING
        RETURN   = GV_RESULT
        ZMESSAGE = GV_MSG
      TABLES
        PT_DATA1 = GT_TAB1
        PT_DATA2 = GT_TAB2.
  ELSE.
    CALL FUNCTION 'Z_LE_VL02N_PICKING'
      EXPORTING
        I_VBELN  = P_VBELN
        I_WADAT  = V_WADAT
        I_ROUTE  = V_ROUTE
        I_VSART  = V_VSART
        I_MODE   = BDC_MODE
      IMPORTING
        RETURN   = GV_RESULT
        ZMESSAGE = GV_MSG
      TABLES
        PT_DATA1 = GT_TAB1
        PT_DATA2 = GT_TAB2.
  ENDIF.



*************************************************
* CSR번호: C2006080801000000259 일련번호 자동지정
* 수정일 : 20060808 수정자: Koo Bon-Chan

* 내역 :
* 자재가 배치번호와 일련번호 동시 사용시 적용
* 배치번호 사용유무 CHECK : MARA-XCHPF
* 일련번호 사용유무 CHECK : MARC-SERNP에 프로파일이 지정되어 있는 경우
* 납품수량 = 피킹수량 일 경우 피킹 저장시 배치번호와 동일하게
* 일련번호 자동지정
* 납품수량 > 피킹수량 인 경우 피킹 저장시 미 반영하고 추후
* 납품수량 = 피킹수량으로 납품 수정시 적용.

  PERFORM ENQUENE_DO USING P_VBELN.

*  DATA : L_SERNP LIKE MARC-SERNP VALUE ' ',
*         L_MATNR LIKE LIPS-MATNR,
*         L_WERKS LIKE LIPS-WERKS,
*         L_CHARG LIKE LIPS-CHARG,
*         L_UECHA LIKE LIPS-UECHA,
*         L_POSNR LIKE LIPS-POSNR,
*         L_MULTI1(20),
*         L_MULTI2(20),
*         L_MULTI3(20),
*         L_MULTI4(20),
*         KOSTA   LIKE VBUP-KOSTA,
*         L_SEQ   TYPE N,
*         L_SEQ1  TYPE N,
*         L_SEQ2  TYPE N.
*
*  CLEAR : BDCDATA,BDCDATA[].
*  PERFORM DYNPRO USING:
*  'X'    'SAPMV50A'              '4004',
*  ' '    'BDC_CURSOR'            'LIKP-VBELN',
*  ' '    'LIKP-VBELN'           P_VBELN,
*  ' '    'BDC_OKCODE'            '/00'.

*  LOOP AT GT_TAB2.
*
*    SELECT SINGLE MATNR WERKS CHARG UECHA
*    INTO   (L_MATNR, L_WERKS, L_CHARG, L_UECHA)
*    FROM   LIPS
*    WHERE  VBELN = P_VBELN
*    AND    POSNR = GT_TAB2-POSNR.
*
*    SELECT SINGLE KOSTA INTO KOSTA
*    FROM   VBUP
*    WHERE  VBELN = P_VBELN
*    AND    POSNR IN (
*                      SELECT POSNR
*                      FROM   LIPS
*                      WHERE  VBELN = P_VBELN
*                      AND    UECHA = L_UECHA
*                      )
*    AND    KOSTA <> 'C'.
*
** 하위 납품들이 전부 피킹완료 될 경우
*    IF SY-SUBRC <> 0.
*
*      SELECT SINGLE XCHPF FROM MARA
*      INTO   L_SERNP
*      WHERE  MATNR = L_MATNR
*      AND    XCHPF = 'X'.
*
** 배치번호 사용유무 체크
*      IF SY-SUBRC = 0 .
*
*        SELECT SINGLE SERNP FROM MARC
*        INTO   L_SERNP
*        WHERE  MATNR = L_MATNR
*        AND    WERKS = L_WERKS
*        AND    SERNP <> ' '.
*
** 일련번호 사용유무 체크
*        IF SY-SUBRC = 0.
*
*          SELECT COUNT(*)
*          INTO   L_SEQ1
*          FROM   LIPS
*          WHERE  VBELN  = P_VBELN
*          AND    UECHA  = L_UECHA
*          AND    POSNR <= GT_TAB2-POSNR.
*
*          L_SEQ = L_UECHA+4(1).
*          L_SEQ1 = L_SEQ1 + 1.
*          L_SEQ2 = L_SEQ2 + 1.
*
*
*          CONCATENATE '=CHPL_T0'           L_SEQ2       INTO L_MULTI1.
*          CONCATENATE 'RV50A-CHMULT(0'     L_SEQ   ')'  INTO L_MULTI2.
*          CONCATENATE 'LIPS-POSNR(0'       L_SEQ1  ')'  INTO L_MULTI3.
*          CONCATENATE 'RV50A-LIPS_SELKZ(0' L_SEQ1  ')'  INTO L_MULTI4.
*
**          PERFORM DYNPRO USING:
**                  'X'    'SAPMV50A'               '4004',
**                  ' '    'BDC_CURSOR'            'LIKP-VBELN',
**                  ' '    'LIKP-VBELN'	       P_VBELN,
**                  ' '    'BDC_OKCODE'            '/00'.
*
*          IF L_POSNR NE L_UECHA OR SY-TABIX EQ 1.
*
*            IF SY-TABIX NE 1.
*
*              PERFORM DYNPRO USING:
*                'X'    'SAPMV50A'              '1000',
*                ' '    'BDC_OKCODE'            '=BACK_T'.
*
*            ENDIF.
*            PERFORM DYNPRO USING:
*  	          'X'    'SAPMV50A'              '1000',
*                ' '    'BDC_OKCODE'            L_MULTI1,
*                ' '    'BDC_CURSOR'            L_MULTI2.
*            L_POSNR = L_UECHA.
*          ENDIF.
*
*          PERFORM dynpro USING:
*                'X' 'SAPMV50A'                  '1000',
*                ' ' 'BDC_OKCODE'                '=POPO_T'.   "품목찾기
*
*          PERFORM dynpro USING:
*                'X' 'SAPMV50A'                  '0111',
*                ' ' 'BDC_OKCODE'                '=WEIT',     "ENTER
*                ' ' 'RV50A-POSNR'               GT_TAB2-POSNR.  "
*
*          PERFORM DYNPRO USING:
*    	          'X'    'SAPMV50A'               '1000',
*                  ' '  'BDC_OKCODE'             '=PSER_T'.
**                  ' '    L_MULTI4               'X'.
*
*          PERFORM DYNPRO USING:
*                  'X'    'SAPLIPW1'              '0200',
*                  ' '    'BDC_CURSOR'            'RIPW0-SERNR(01)',
*                  ' '    'BDC_OKCODE'            '=RWS',
*                  ' '    'RIPW0-SERNR(01)'       L_CHARG.

**          PERFORM DYNPRO USING:
**          'X'    'SAPMV50A'              '1000',
**          ' '    'BDC_OKCODE'            '=SICH_T'.

*          CALL TRANSACTION 'VL02N' USING BDCDATA
*                           MODE bdc_mode UPDATE 'S'
*                           MESSAGES INTO MESSTAB.
*
*        ENDIF.
*
*      ENDIF.
*
*    ENDIF.
*
*  ENDLOOP.
*
*  PERFORM DYNPRO USING:
*  'X'    'SAPMV50A'              '1000',
*  ' '    'BDC_OKCODE'            '=SICH_T'.

  PERFORM DEQUEUE_ALL.

*  CALL TRANSACTION 'VL02N' USING BDCDATA
*       MODE BDC_MODE UPDATE 'S'
*       MESSAGES INTO MESSTAB.

* CSR번호: C2006080801000000259 수정끝
**************************************


  IF GV_RESULT = 'S'.

    CLEAR: R_VBELN[], R_VBELN, ET_LIKP[], ET_LIKP.
    PERFORM GET_RANGE_VBELN USING P_VBELN.
    PERFORM DATA_QUERY TABLES ET_LIKP
                              R_VBELN.
    LOOP AT ET_LIKP.
      LOOP AT GT_LIKP WHERE VBELN = ET_LIKP-VBELN.
        MOVE-CORRESPONDING ET_LIKP TO GT_LIKP.
        GT_LIKP-WADAT_IST = SY-DATUM.
        MODIFY GT_LIKP .
      ENDLOOP.
    ENDLOOP.

    GV_SAVE_FLAG = 'X'.
    PERFORM GET_DETAIL.

    MESSAGE S001 WITH P_VBELN '피킹하였습니다'.
  ELSE.
    MESSAGE I002 WITH P_VBELN GV_MSG.
    LEAVE TO SCREEN 100.
  ENDIF.

ENDFORM.                    " bdc_run_picking
*&---------------------------------------------------------------------*
*&      Form  dynpro
*&---------------------------------------------------------------------*
FORM DYNPRO  USING    DYNBEGIN NAME VALUE.

  CLEAR  BDCDATA.

  IF DYNBEGIN = 'X'.
    MOVE:  'X'   TO  BDCDATA-DYNBEGIN,
           NAME  TO  BDCDATA-PROGRAM,
           VALUE TO  BDCDATA-DYNPRO.
  ELSE.
    MOVE:
           NAME  TO  BDCDATA-FNAM,
           VALUE TO  BDCDATA-FVAL.
  ENDIF.

  APPEND BDCDATA.

ENDFORM.                    " dynpro
*&---------------------------------------------------------------------*
*&      Form  wast1
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM WAST1 .

  PERFORM POP_UP_CONFIRM(ZLER0004) USING '< 확인 >'
                               '출고전기 하시겠습니까?'
                      CHANGING GV_RETURN.
  CHECK GV_RETURN = 'J'.

  PERFORM FUNC_WAST USING GT_LIKP-VBELN
                          TVROT-ROUTE
                          P_WADAT_IST
                          T173T-VSART.

  IF GV_RESULT = 'S'.
    MESSAGE S000 WITH '출고전기 하였습니다'.
    DELETE GT_LIKP WHERE VBELN = P_VBELN.
    LEAVE TO SCREEN 100.
  ELSE.
    MESSAGE I001 WITH '오류:' GV_MSG.
    LEAVE TO SCREEN 100.
  ENDIF.

ENDFORM.                                                    " wast1
*&---------------------------------------------------------------------*
*&      Form  func_wast
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GT_LIKP_VBELN  text
*      -->P_TVROT_ROUTE  text
*      -->P_P_WADAT_IST  text
*      -->P_T173T_VSART  text
*----------------------------------------------------------------------*
FORM FUNC_WAST  USING    P_VBELN
                         P_ROUTE
                         P_WADAT
                         P_VSART.

  CLEAR: GV_RESULT, GV_MSG.

  PERFORM DEQUEUE_ALL.

  CALL FUNCTION 'Z_LE_VL02N_GI'
    EXPORTING
      VBELN     = P_VBELN
      ROUTE     = P_ROUTE
      WADAT_IST = P_WADAT
      VSART     = P_VSART
      I_MODE    = BDC_MODE
    IMPORTING
      RETURN    = GV_RESULT
      ZMESSAGE  = GV_MSG.

  IF GV_RESULT EQ 'S'.
    PERFORM UPDATE_FACTOR_BATCH USING P_VBELN.
  ENDIF.

ENDFORM.                    " func_wast
*&---------------------------------------------------------------------*
*&      Form  delivery_delete
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM DELIVERY_DELETE USING HU_USE.

  PERFORM CHECK_TKNUM.

  PERFORM POP_UP_CONFIRM(ZLER0004) USING '< 삭제여부확인 >'
                               '납품 삭제하시겠습니까?'
                      CHANGING GV_RETURN.
  CHECK GV_RETURN = 'J'.

  PERFORM CHECK_TKNUM.

  PERFORM DEQUEUE_ALL.

  CALL FUNCTION 'Z_LE_VL02N_DELETE'
    EXPORTING
      VBELN    = P_VBELN
      HU_USE   = HU_USE
      I_MODE   = BDC_MODE
    IMPORTING
      RETURN   = GV_RESULT
      ZMESSAGE = GV_MSG.
*    tables
*      it_tab   = gt_delt.

  IF GV_RESULT = 'S'.
    DELETE GT_LIKP WHERE VBELN = P_VBELN.
    MESSAGE S001 WITH P_VBELN '삭제하였습니다'.
    LEAVE TO SCREEN 100.
  ELSE.
    MESSAGE I002 WITH P_VBELN '삭제하지 못했습니다' GV_MSG.
    LEAVE TO SCREEN 100.
  ENDIF.

ENDFORM.                    " delivery_delete
*&---------------------------------------------------------------------*
*&      Form  check_tknum
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM CHECK_TKNUM .

* 통문 완료 여부 확인
  SELECT SINGLE @ABAP_TRUE INTO @DATA(LV_FLG)
    FROM ZLET0006 AS A INNER JOIN ZLET0005 AS B
                        ON A~IV_NO EQ B~IV_NO
   WHERE A~VBELN EQ @P_VBELN
     AND B~OUT_YN EQ @ABAP_TRUE.

  IF LV_FLG IS NOT INITIAL.
    MESSAGE S029.
    LEAVE SCREEN.
  ENDIF.

* 거래명세서 발행여부 확인
  SELECT SINGLE A~IV_NO INTO @DATA(LV_IVNO)
    FROM ZLET0006 AS A INNER JOIN ZLET0005 AS B
                        ON A~IV_NO EQ B~IV_NO
   WHERE A~VBELN EQ @P_VBELN
     AND B~IV_CANCEL_YN EQ @ABAP_FALSE.

  IF LV_IVNO IS NOT INITIAL.
    MESSAGE S028 WITH LV_IVNO.
    LEAVE SCREEN.
  ENDIF.

* Shipment 존재 확인
  DATA: LV_TKNUM LIKE VTTP-TKNUM.

  CLEAR: LV_TKNUM.
  SELECT SINGLE TKNUM INTO LV_TKNUM FROM VTTP
    WHERE VBELN = P_VBELN.
  IF SY-SUBRC = 0.
    MESSAGE S017 WITH LV_TKNUM.
    LEAVE SCREEN.
  ENDIF.

ENDFORM.                    " check_tknum
*&---------------------------------------------------------------------*
*&      Form  pick1
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM PICK1 .

  I_CURSOR_LINE = TC01-CURRENT_LINE + I_CURSOR_LINE - 1.
  READ TABLE GT_LIKP INDEX I_CURSOR_LINE.

  CASE G_CURSOR_FIELD.
    WHEN 'GT_LIKP-VBELN'.
      SET PARAMETER ID 'VL' FIELD GT_LIKP-VBELN.
      CALL TRANSACTION 'VL03N'
                    AND SKIP  FIRST SCREEN.

    WHEN 'GT_LIKP-VGBEL'.
      SET PARAMETER ID 'AUN' FIELD GT_LIKP-VGBEL.
      CALL TRANSACTION 'VA03' WITH AUTHORITY-CHECK AND SKIP FIRST SCREEN.

    WHEN 'GT_LIKP-TKNUM'.
      IF GT_LIKP-TKNUM IS NOT INITIAL.
        SET PARAMETER ID 'TNR' FIELD GT_LIKP-TKNUM.
        CALL TRANSACTION 'VT03N' WITH AUTHORITY-CHECK AND SKIP FIRST SCREEN.
      ENDIF.
  ENDCASE.


ENDFORM.                                                    " pick1
*&---------------------------------------------------------------------*
*&      Form  assign_gl_lips_delqty_200
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM ASSIGN_GL_LIPS_DELQTY_200 .

  REFRESH: WA_VEPO, WA_LIPS1.
  CLEAR  : WA_VEPO, WA_LIPS1.

  WA_LIPS2[] = GL_LIPS[].

*/ < #1. 자신의 상위품목부터 assign >
*  SORT gl_vepo BY exidv.
*/ 동일 배치 품목이 있을때, 먼저 MODI.
  PERFORM SAME_BATCH_MODI_NA_CHK.

*  SORT gl_vepo BY exidv.
*/ 동일 배치가 없을때, APPEND
  PERFORM BATCH_APPEND_NA_CHK.

*/ < #2. 자신의 상위품목부터 assign 하고,남은 부분 assign >
*  SORT gl_vepo BY exidv.
  PERFORM SAME_BATCH_MODI_NA.

*  SORT gl_vepo BY exidv.
*/ 동일 배치가 없을때, APPEND
  PERFORM BATCH_APPEND_NA.

*  SORT gl_vepo BY exidv.

  DELETE GL_LIPS WHERE DELQTY = 0
                   AND SUB    = '2'.

*/ ICON SETTING
  WA_LIPS2[] = GL_LIPS[].

  LOOP AT GL_LIPS WHERE ICON1 = ' '
                    AND SUB   = '1'.
    READ TABLE WA_LIPS2 WITH KEY ITEM1 = GL_LIPS-ITEM1
                                 SUB   = '2'.
    IF SY-SUBRC = 0.
      GL_LIPS-ICON1 = C_ICON1.
      MODIFY GL_LIPS TRANSPORTING ICON1.
    ENDIF.
  ENDLOOP.

  GL_LIPS-CALCU = ' '.
  MODIFY GL_LIPS TRANSPORTING CALCU WHERE CALCU = 'X'.

ENDFORM.                    " assign_gl_lips_delqty_200
*&---------------------------------------------------------------------*
*&      Form  get_GL_VEPO_hu
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM GET_GL_VEPO_HU .

  DATA: LV_UEVEL   LIKE VEKP-UEVEL.

  DATA: BEGIN OF LT_ITAB OCCURS 0,
          WERKS LIKE LIPS-WERKS,
          LGORT LIKE LIPS-LGORT,
          MATNR LIKE LIPS-MATNR,
          SOBKZ LIKE LIPS-SOBKZ,
        END OF LT_ITAB.

  CLEAR: GT_VEPO[], GT_VEPO, GL_VEPO[], GL_VEPO,
         GT_NASG[], GT_NASG, GT_ASSG[], GT_ASSG.

  LOOP AT GL_LIPS WHERE SUB = '1'.
    MOVE-CORRESPONDING GL_LIPS  TO LT_ITAB.
    COLLECT LT_ITAB.
  ENDLOOP.

  LOOP AT LT_ITAB .
    SELECT *  FROM VEPO
     WHERE WERKS = LT_ITAB-WERKS
       AND LGORT = LT_ITAB-LGORT
       AND MATNR = LT_ITAB-MATNR
       AND SOBKZ = LT_ITAB-SOBKZ.
      MOVE-CORRESPONDING VEPO  TO GT_VEPO.
      APPEND GT_VEPO.
    ENDSELECT.
  ENDLOOP.

  LOOP AT GT_VEPO.
    CLEAR : GL_VEPO-EXTNL.

* 다른 납품에 지정되어 있는것 제외
    SELECT SINGLE MANDT INTO SY-MANDT FROM LIKP
      WHERE VBELN = GT_VEPO-VBELN
        AND LFART <> 'LR'.

    IF SY-SUBRC = 0.
      IF P_VBELN <> GT_VEPO-VBELN.
        CONTINUE.
      ENDIF.
      MOVE-CORRESPONDING GT_VEPO TO GL_VEPO.

*      SELECT SINGLE EXIDV ERDAT
*        INTO (GL_VEPO-EXIDV, GL_VEPO-ERDAT)
*        FROM VEKP
*       WHERE VENUM = GT_VEPO-VENUM
*         AND VPOBJ = '01'  "시스템상태-실제있음
*         AND STATUS IN ('0020', '0030').
*      IF SY-SUBRC <> 0.
*        CONTINUE.
*      ENDIF.

      SELECT SINGLE EXIDV ERDAT UEVEL
        INTO (GL_VEPO-EXIDV, GL_VEPO-ERDAT, LV_UEVEL)
        FROM VEKP
       WHERE VENUM = GT_VEPO-VENUM
         AND VPOBJ = '01'  "시스템상태-실제있음
         AND STATUS IN ('0020', '0030').
      IF SY-SUBRC = 0.
        IF LV_UEVEL IS NOT INITIAL.
          GL_VEPO-EXTNL = 'X'.

          SELECT SINGLE EXIDV ERDAT
            INTO (GL_VEPO-EXIDV, GL_VEPO-ERDAT)
            FROM VEKP
           WHERE VENUM = LV_UEVEL.
        ENDIF.
      ELSE.
        CONTINUE.
      ENDIF.

      SELECT SINGLE UECHA INTO GL_VEPO-ITEM1 FROM LIPS
        WHERE VBELN = GL_VEPO-VBELN
          AND POSNR = GL_VEPO-POSNR
          AND UECHA <> '000000'.
      IF SY-SUBRC <> 0.
        SELECT SINGLE POSNR INTO GL_VEPO-ITEM1 FROM LIPS
          WHERE VBELN = GL_VEPO-VBELN
            AND POSNR = GL_VEPO-POSNR
            AND UECHA = '000000'.
      ENDIF.

      GL_VEPO-PLACE = 'A'.
      GL_VEPO-ORGIN = 'A'.
    ELSE.
      MOVE-CORRESPONDING GT_VEPO TO GL_VEPO.

*      SELECT SINGLE EXIDV ERDAT
*        INTO (GL_VEPO-EXIDV, GL_VEPO-ERDAT)
*        FROM VEKP
*       WHERE VENUM = GT_VEPO-VENUM
*         AND VPOBJ  IN ('05', '06', '12')
*         AND STATUS IN ('0020', '0030').
*      IF SY-SUBRC <> 0.
*        CONTINUE.
*      ENDIF.

      SELECT SINGLE EXIDV ERDAT UEVEL
        INTO (GL_VEPO-EXIDV, GL_VEPO-ERDAT, LV_UEVEL)
        FROM VEKP
       WHERE VENUM = GT_VEPO-VENUM
         AND VPOBJ  IN ('05', '06', '12')
         AND STATUS IN ('0020', '0030').
      IF SY-SUBRC = 0.
        IF LV_UEVEL IS NOT INITIAL.
          GL_VEPO-EXTNL = 'X'.

          SELECT SINGLE EXIDV ERDAT
            INTO (GL_VEPO-EXIDV, GL_VEPO-ERDAT)
            FROM VEKP
           WHERE VENUM = LV_UEVEL.
        ENDIF.
      ELSE.
        CONTINUE.
      ENDIF.

      GL_VEPO-PLACE = 'N'.
      GL_VEPO-ORGIN = 'N'.
      GL_VEPO-VBELN = ' '.
      GL_VEPO-POSNR = ' '.
    ENDIF.
    COLLECT GL_VEPO.
  ENDLOOP.

** 중복지정
**  DATA: wa_vepo LIKE gl_vepo OCCURS 0 WITH HEADER LINE.
*  wa_vepo[] = gl_vepo[].
*  LOOP AT gl_vepo .
*    CLEAR: gv_flag.
*    LOOP AT wa_vepo WHERE exidv = gl_vepo-exidv  AND
*                        ( matnr <> gl_vepo-matnr OR
*                          werks <> gl_vepo-werks OR
*                          lgort <> gl_vepo-lgort OR
*                          sobkz <> gl_vepo-sobkz ).
*      gv_flag = 'X'.
*      EXIT.
*    ENDLOOP.
*    IF gv_flag = 'X'.
*      gl_vepo-icon2 = 'D'.
*      MODIFY gl_vepo.
*    ENDIF.
*  ENDLOOP.


ENDFORM.                    " get_GL_VEPO_hu
*&---------------------------------------------------------------------*
*&      Form  assign_gl_lips_delqty_200_1
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM ASSIGN_GL_LIPS_DELQTY_200_1 .

  CLEAR: WA_VEPO[], WA_VEPO.

* 원래 지정되어 있던것과 미지정에서 온것들을 구분하여 modify한다.
* item1/posnr/vbeln 값 처리.
  SORT GL_VEPO BY EXIDV.
  LOOP AT GT_ASSG WHERE CHK = 'X'.
    LOOP AT GL_VEPO WHERE EXIDV = GT_ASSG-EXIDV
                      AND PLACE = 'A'.
      IF GL_VEPO-ORGIN = 'A'.
        LOOP AT GL_LIPS WHERE MATNR = GL_VEPO-MATNR
                          AND SOBKZ = GL_VEPO-SOBKZ
                          AND SONUM = GL_VEPO-SONUM
                          AND CHARG = GL_VEPO-CHARG
                          AND ITEM1 = GL_VEPO-ITEM1
                          AND VBELN = GL_VEPO-VBELN
                          AND POSNR = GL_VEPO-POSNR.  "?
          GL_LIPS-DELQTY = GL_LIPS-DELQTY - GL_VEPO-VEMNG.
          MODIFY GL_LIPS.
          EXIT.
        ENDLOOP.
      ELSE.
        LOOP AT GL_LIPS WHERE MATNR = GL_VEPO-MATNR
                          AND SOBKZ = GL_VEPO-SOBKZ
                          AND SONUM = GL_VEPO-SONUM
                          AND CHARG = GL_VEPO-CHARG
                          AND ITEM1 = GL_VEPO-ITEM1.
          GL_LIPS-DELQTY = GL_LIPS-DELQTY - GL_VEPO-VEMNG.
          MODIFY GL_LIPS.
          EXIT.
        ENDLOOP.
      ENDIF.

      IF SY-SUBRC = 0.
        DELETE GL_VEPO.

        MOVE-CORRESPONDING GL_VEPO   TO WA_VEPO.
*        wa_vepo-item1 = ' '.                        "?
        WA_VEPO-PLACE = 'N'.
        APPEND WA_VEPO.
      ENDIF.
    ENDLOOP.
  ENDLOOP.

  DELETE GL_LIPS WHERE SUB = '2'
                   AND DELQTY = 0.

  LOOP AT WA_VEPO.
    MOVE-CORRESPONDING WA_VEPO  TO GL_VEPO.
    COLLECT GL_VEPO.  CLEAR: GL_VEPO.
  ENDLOOP.

*/ ICON SETTING
  WA_LIPS2[] = GL_LIPS[].

  LOOP AT GL_LIPS WHERE ICON1 <> ' '
                    AND SUB   = '1'.
    READ TABLE WA_LIPS2 WITH KEY ITEM1 = GL_LIPS-ITEM1
                                 SUB   = '2'.
    IF SY-SUBRC <> 0.
      GL_LIPS-ICON1 = ' '.
      MODIFY GL_LIPS TRANSPORTING ICON1.
    ENDIF.
  ENDLOOP.

ENDFORM.                    " assign_gl_lips_delqty_200_1
*&---------------------------------------------------------------------*
*&      Form  save_200
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM SAVE_200 .

  PERFORM POP_UP_CONFIRM(ZLER0004) USING '< 확인 >'
                               '저장하시겠읍니까?'
                      CHANGING GV_RETURN.

  CHECK GV_RETURN = 'J'.

*  PERFORM prepare_dataset_hu.

  PERFORM PREPARE_SAVE_200.

  PERFORM BDC_RUN_HU
     USING P_WADAT_IST TVROT-ROUTE T173T-VSART.

ENDFORM.                                                    " save_200
*&---------------------------------------------------------------------*
*&      Form  prepare_save_200
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM PREPARE_SAVE_200 .

  CLEAR: GT_TAB1[], GT_TAB1,
         GT_TAB2[], GT_TAB2,
         GT_TAB3[], GT_TAB3.
  CLEAR: GT_TAB4[], GT_TAB4,
         GT_TAB5[], GT_TAB5,
         GT_TAB6[], GT_TAB6.

  SORT GL_VEPO BY EXIDV.
*/ 포장풀기
*  PERFORM get_data_pojang_disconect_1.
  PERFORM GET_DATA_POJANG_DISCONECT.

*/ 포장하기
*  PERFORM get_data_pojang_conect_1.
  PERFORM GET_DATA_POJANG_CONECT.

*/ #3. 지시수량
  PERFORM GET_DATA_JISIQTY.

ENDFORM.                    " prepare_save_200
*&---------------------------------------------------------------------*
*&      Form  get_data_pojang_conect
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM GET_DATA_POJANG_CONECT .

  LOOP AT GL_LIPS WHERE SUB = '2'.
    READ TABLE CL_LIPS WITH KEY ITEM1 = GL_LIPS-ITEM1
                                POSNR = GL_LIPS-POSNR.
*                                charg = gl_lips-charg.
    IF SY-SUBRC = 0.
*/ 동일 품목에 동일한 배치이나, 지정수량이 다른 경우.
*      IF cl_lips-delqty <> gl_lips-delqty.
*        SELECT SINGLE posnr INTO gt_tab2-posnr FROM lips
*          WHERE vbeln = p_vbeln
*            AND uecha = gl_lips-item1
*            AND charg = gl_lips-charg.
*        gt_tab2-uecha = gl_lips-item1.
*        gt_tab2-lgort = gl_lips-lgort.
*        gt_tab2-charg = gl_lips-charg.
*        gt_tab2-lfimg = gl_lips-delqty.
*        gt_tab2-vrkme = gl_lips-vrkme.
*        APPEND gt_tab2.   CLEAR: gt_tab2.
*
*        gt_tab1-posnr = gl_lips-item1.
*        gt_tab1-vrkme = gl_lips-vrkme.
*        COLLECT gt_tab1. CLEAR: gt_tab1.
*      ENDIF.
    ELSE.
      GT_TAB2-UECHA = GL_LIPS-ITEM1.
      GT_TAB2-LGORT = GL_LIPS-LGORT.
      GT_TAB2-CHARG = GL_LIPS-CHARG.
      GT_TAB2-LFIMG = GL_LIPS-DELQTY.
      GT_TAB2-VRKME = GL_LIPS-VRKME.
      APPEND GT_TAB2.  CLEAR: GT_TAB2.

      GT_TAB1-POSNR = GL_LIPS-ITEM1.
      GT_TAB1-VRKME = GL_LIPS-VRKME.
      COLLECT GT_TAB1. CLEAR: GT_TAB1.
    ENDIF.
  ENDLOOP.

  LOOP AT GT_TAB1.
    READ TABLE GL_LIPS WITH KEY POSNR = GT_TAB1-POSNR
                                SUB   = '1'.
    IF SY-SUBRC = 0.
      GT_TAB1-LFIMG = GL_LIPS-JISIQTY.
      MODIFY GT_TAB1.
    ENDIF.
  ENDLOOP.

  LOOP AT GL_VEPO WHERE PLACE = 'A'.
    READ TABLE CL_VEPO WITH KEY EXIDV = GL_VEPO-EXIDV
                                PLACE = 'N'.
    IF SY-SUBRC = 0.
      GT_TAB3-EXIDV = GL_VEPO-EXIDV.
      COLLECT GT_TAB3.
    ENDIF.
  ENDLOOP.





********************************************************
*  loop at gl_lips where xchpf = 'X'.
*    read table cl_lips with key posnr = gl_lips-posnr.
*    if sy-subrc = 0.
**      IF cl_lips-delqty <> gl_lips-delqty.
*** 삭제,추가
**        gt_tab1-posnr = gl_lips-item1.
**        gt_tab1-vrkme = gl_lips-vrkme.
**        COLLECT gt_tab1. CLEAR: gt_tab1.
**
**        IF gl_lips-xchpf = 'X'.
**          gt_tab2-uecha = gl_lips-item1.
**          gt_tab2-posnr = gl_lips-posnr.
**          gt_tab2-lgort = gl_lips-lgort.
**          gt_tab2-charg = gl_lips-charg.
**          gt_tab2-lfimg = gl_lips-delqty.
**          gt_tab2-vrkme = gl_lips-vrkme.
**          APPEND gt_tab2.
**        ENDIF.
**      ENDIF.
*    else.
*      gt_tab1-posnr = gl_lips-item1.
*      gt_tab1-vrkme = gl_lips-vrkme.
*      collect gt_tab1. clear: gt_tab1.
*
*      if gl_lips-xchpf = 'X'.
*        gt_tab2-uecha = gl_lips-item1.
*        gt_tab2-posnr = gl_lips-posnr.
*        gt_tab2-lgort = gl_lips-lgort.
*        gt_tab2-charg = gl_lips-charg.
*        gt_tab2-lfimg = gl_lips-delqty.
*        gt_tab2-vrkme = gl_lips-vrkme.
*        append gt_tab2.
*      endif.
*    endif.
*  endloop.
*
*  loop at gt_tab1.
*    read table gl_lips with key posnr = gt_tab1-posnr
*                                sub   = '1'.
*    if sy-subrc = 0.
*      gt_tab1-lfimg = gl_lips-jisiqty.
*      modify gt_tab1.
*    endif.
*  endloop.
*
*  LOOP AT gl_vepo WHERE place = 'N'.
*    READ TABLE cl_vepo WITH KEY exidv = gl_vepo-exidv
*                                place = 'A'.
*    IF sy-subrc = 0.
*      gt_tab6-exidv = gl_vepo-exidv.
*      COLLECT gt_tab6.
*    ENDIF.
*  ENDLOOP.

ENDFORM.                    " get_data_pojang_conect
*&---------------------------------------------------------------------*
*&      Form  get_data_pojang_disconect
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM GET_DATA_POJANG_DISCONECT .

  LOOP AT CL_LIPS WHERE SUB = '2'.
    READ TABLE GL_LIPS WITH KEY ITEM1 = CL_LIPS-ITEM1
                                POSNR = CL_LIPS-POSNR.
*                                charg = cl_lips-charg.
    IF SY-SUBRC = 0.
      IF CL_LIPS-DELQTY <> GL_LIPS-DELQTY.
        GT_TAB4-POSNR = CL_LIPS-ITEM1.
        COLLECT GT_TAB4.

        GT_TAB5-UECHA = CL_LIPS-ITEM1.
        GT_TAB5-POSNR = CL_LIPS-POSNR.
        GT_TAB5-LFIMG = GL_LIPS-DELQTY.
        APPEND GT_TAB5.
      ENDIF.
    ELSE.
      GT_TAB4-POSNR = CL_LIPS-ITEM1.
      COLLECT GT_TAB4.

      GT_TAB5-UECHA = CL_LIPS-ITEM1.
      GT_TAB5-POSNR = CL_LIPS-POSNR.
      GT_TAB5-LFIMG = 0.
      APPEND GT_TAB5.
    ENDIF.
  ENDLOOP.
*
  LOOP AT CL_LIPS WHERE SUB = '1'
                    AND ( XCHPF = ' ' OR FIXED = 'X' ).
    READ TABLE GL_LIPS WITH KEY ITEM1 = CL_LIPS-ITEM1.
    IF SY-SUBRC = 0.
      IF CL_LIPS-DELQTY <> GL_LIPS-DELQTY.
        GT_TAB4-POSNR = CL_LIPS-ITEM1.
        COLLECT GT_TAB4.  CLEAR: GT_TAB4.
      ENDIF.
    ENDIF.
  ENDLOOP.
*

  LOOP AT GL_VEPO WHERE PLACE = 'N'.
    READ TABLE CL_VEPO WITH KEY EXIDV = GL_VEPO-EXIDV
                                PLACE = 'A'.
    IF SY-SUBRC = 0.
      GT_TAB6-EXIDV = GL_VEPO-EXIDV.
      COLLECT GT_TAB6.
    ENDIF.
  ENDLOOP.


ENDFORM.                    " get_data_pojang_disconect
*&---------------------------------------------------------------------*
*&      Form  bdc_run_hu
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_TVROT_ROUTE  text
*      -->P_T173T_VSART  text
*----------------------------------------------------------------------*
FORM BDC_RUN_HU  USING   V_WADAT V_ROUTE V_VSART.

  PERFORM DEQUEUE_ALL.

  CALL FUNCTION 'Z_LE_VL02N_POJANG2'
    EXPORTING
      I_VBELN  = P_VBELN
      I_WADAT  = V_WADAT
      I_ROUTE  = V_ROUTE
      I_VSART  = V_VSART
      I_MODE   = BDC_MODE
    IMPORTING
      RETURN   = GV_RESULT
      ZMESSAGE = GV_MSG
    TABLES
      PT_DATA1 = GT_TAB1
      PT_DATA2 = GT_TAB2
      PT_DATA3 = GT_TAB3
      PT_DATA4 = GT_TAB4
      PT_DATA5 = GT_TAB5
      PT_DATA6 = GT_TAB6
      PT_DATA7 = GT_TAB7
      PT_DATA8 = GT_TAB8.
  IF GV_RESULT = 'S'.
*/ SAVE SHIPPING NO. - LONG TEXT
    PERFORM SAVE_SHIPPING_NO .

*{ 기능개선 91460 - 추가
*___배치지정 저장 후 피킹 실행
    PERFORM MAKE_PICKING_DATA_200_1.

    PERFORM CALL_TRANSACTION_VL02N.
*} 기능개선 91460 - 추가

*    perform enqueue_rock using p_vbeln.

    CLEAR: R_VBELN[], R_VBELN, ET_LIKP[], ET_LIKP.
    PERFORM GET_RANGE_VBELN USING P_VBELN.
    PERFORM DATA_QUERY TABLES ET_LIKP
                              R_VBELN.
    LOOP AT ET_LIKP.
      LOOP AT GT_LIKP WHERE VBELN = ET_LIKP-VBELN.
        MOVE-CORRESPONDING ET_LIKP TO GT_LIKP.
        GT_LIKP-WADAT_IST = SY-DATUM.
        MODIFY GT_LIKP .
      ENDLOOP.
    ENDLOOP.

    GV_SAVE_FLAG = 'X'.
    PERFORM GET_DETAIL.

*    LEAVE TO SCREEN 100.
    MESSAGE S001 WITH P_VBELN '저장하였습니다'.
  ELSE.
    MESSAGE I002 WITH P_VBELN GV_MSG '저장하지 못했습니다'.
    LEAVE TO SCREEN 100.
  ENDIF.

ENDFORM.                    " bdc_run_hu
*&---------------------------------------------------------------------*
*&      Form  get_data_jisiqty
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM GET_DATA_JISIQTY .

  CLEAR: GT_TAB8[], GT_TAB8.

  LOOP AT GL_LIPS WHERE SUB = '1'.
    LOOP AT CL_LIPS WHERE SUB = '1'
                      AND ITEM1 = GL_LIPS-ITEM1
                      AND JISIQTY <> GL_LIPS-JISIQTY.
      GT_TAB8-POSNR = GL_LIPS-POSNR.
      GT_TAB8-LFIMG = GL_LIPS-JISIQTY.
      GT_TAB8-VRKME = GL_LIPS-VRKME.
      APPEND GT_TAB8.
    ENDLOOP.
  ENDLOOP.

*  LOOP AT gt_tab8.
*    READ TABLE gt_tab1 WITH KEY posnr = gt_tab8-posnr.
*    IF sy-subrc = 0.
*      DELETE gt_tab8. CONTINUE.
*    ENDIF.
*    READ TABLE gt_tab4 WITH KEY posnr = gt_tab8-posnr.
*    IF sy-subrc = 0.
*      DELETE gt_tab8. CONTINUE.
*    ENDIF.
*  ENDLOOP.

ENDFORM.                    " get_data_jisiqty
*&---------------------------------------------------------------------*
*&      Form  save_shipping_no
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM SAVE_SHIPPING_NO .

  DATA : BEGIN OF LT_TH OCCURS 10.
           INCLUDE STRUCTURE THEAD.
  DATA : END   OF LT_TH.

  DATA : BEGIN OF LT_TL OCCURS 10.
           INCLUDE STRUCTURE TLINE.
  DATA : END OF LT_TL.

  DATA  FUNCTION_UPDATE(1) TYPE C VALUE 'U'.

  REFRESH: LT_TL, LT_TH.
  CLEAR  : LT_TL, LT_TH.


  LOOP AT GT_SHIP.
    REFRESH: LT_TL.
    CLEAR  : LT_TL.

    GV_OBJECT    = 'VBBP'.
    GV_OBJECT_ID = 'Z990'.

    LT_TH-TDOBJECT = GV_OBJECT.
    CONCATENATE GT_SHIP-VBELN GT_SHIP-POSNR INTO GV_VBELN.
    LT_TH-TDNAME   = GV_VBELN.     "
    LT_TH-TDID     = GV_OBJECT_ID.   "'001'. " Text ID
    LT_TH-TDSPRAS  = SY-LANGU.
    LT_TL-TDFORMAT = '*'.
    LT_TL-TDLINE = GT_SHIP-SHIPPING_NO.
    APPEND LT_TL.

    CALL FUNCTION 'SAVE_TEXT'
      EXPORTING
        CLIENT          = SY-MANDT
        HEADER          = LT_TH
        SAVEMODE_DIRECT = 'X'
      IMPORTING
        FUNCTION        = FUNCTION_UPDATE
        NEWHEADER       = LT_TH
      TABLES
        LINES           = LT_TL
      EXCEPTIONS
        ID              = 1
        LANGUAGE        = 2
        NAME            = 3
        OBJECT          = 4
        OTHERS          = 5.
    IF SY-SUBRC <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    ENDIF.
  ENDLOOP.

  REFRESH: GT_SHIP.
  CLEAR  : GT_SHIP.

ENDFORM.                    " save_shipping_no
*&---------------------------------------------------------------------*
*&      Form  READ_TEXT_SHIP_NO
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM READ_TEXT_SHIP_NO .

  GV_OBJECT    = 'VBBP'.
  GV_OBJECT_ID = 'Z990'.

  LOOP AT GL_LIPS WHERE SUB = '1'.
    REFRESH: GT_TLINE. CLEAR: GT_TLINE.
    CONCATENATE GL_LIPS-VBELN GL_LIPS-POSNR INTO GV_VBELN.
    PERFORM READ_ORDER_LONG_TEXT(ZLER0001)
         TABLES GT_TLINE[]
         USING GV_OBJECT_ID  GV_VBELN GV_OBJECT.
    READ TABLE GT_TLINE INDEX 1.
    IF SY-SUBRC = 0.
      GL_LIPS-SHIPPING_NO = GT_TLINE-TDLINE.
    ENDIF.
    MODIFY GL_LIPS.
  ENDLOOP.

ENDFORM.                    " READ_TEXT_SHIP_NO
*&---------------------------------------------------------------------*
*&      Form  APPEND_LFART
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_0077   text
*----------------------------------------------------------------------*
FORM APPEND_LFART  USING    P_XX.

  R_LFART-SIGN   = 'I'.
  R_LFART-OPTION = 'EQ'.
  R_LFART-LOW    = P_XX.
  APPEND R_LFART.

ENDFORM.                    " APPEND_LFART
*&---------------------------------------------------------------------*
*&      Form  char_fltp_conversion
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_LT_CHAR_VALUE  text
*      <--P_PV_LENGTH  text
*----------------------------------------------------------------------*
FORM CHAR_FLTP_CONVERSION  USING    PV_VALUE_S
                           CHANGING PV_VALUE_P.

  DATA: LV_FLTP     LIKE RSCVP-VALU1,
        LV_PACK(16) TYPE P DECIMALS 3.

  CALL FUNCTION 'CHAR_FLTP_CONVERSION'
    EXPORTING
      STRING          = PV_VALUE_S
    IMPORTING
      FLSTR           = LV_FLTP
*&      ivalu           = x_ival
    EXCEPTIONS
      STRING_NOT_FLTP = 1.

  PV_VALUE_P = LV_FLTP.

ENDFORM.                    " char_fltp_conversion
*&---------------------------------------------------------------------*
*&      Form  GET_DELQTY_200
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM GET_DELQTY_200 .

  LOOP AT GL_LIPS WHERE XCHPF = ' '.
    CLEAR: GV_VEMNG.
    LOOP AT GL_VEPO WHERE ITEM1 = GL_LIPS-ITEM1.
      ADD GL_VEPO-VEMNG  TO GV_VEMNG.
    ENDLOOP.
    GL_LIPS-DELQTY = GV_VEMNG.
    MODIFY GL_LIPS TRANSPORTING DELQTY.
  ENDLOOP.

* 2005.12.08 - 상위품목에 배치 지정.
* Requested by 허.
* - 상위품목에 배치가 바로 붙는 경우는 포장,포장해체 불가.
* - 피킹만 할수 있도록.
  LOOP AT GL_LIPS WHERE SUB = '1'
                    AND XCHPF = 'X'
                    AND CHARG <> ' '.
    CLEAR: GV_VEMNG.
    LOOP AT GL_VEPO WHERE ITEM1 = GL_LIPS-ITEM1.
      ADD GL_VEPO-VEMNG  TO GV_VEMNG.
    ENDLOOP.
    GL_LIPS-DELQTY = GV_VEMNG.
    GL_LIPS-FIXED  = 'X'.
    MODIFY GL_LIPS TRANSPORTING DELQTY FIXED.

    LOOP AT GL_VEPO WHERE VBELN = GL_LIPS-VBELN
                      AND POSNR = GL_LIPS-ITEM1.
      GL_VEPO-FIXED = 'X'.
      MODIFY GL_VEPO TRANSPORTING FIXED.
    ENDLOOP.
  ENDLOOP.

**********************************************
*  CLEAR: wa_lips[], wa_lips.
*  LOOP AT gl_lips WHERE sub = '1'
*                    AND xchpf = 'X'
*                    AND charg <> ' '.
*    MOVE-CORRESPONDING gl_lips TO wa_lips.
*    APPEND wa_lips.
*
*    gl_lips-charg = ' '.
*    gl_lips-icon1 = c_icon1.
*    MODIFY gl_lips TRANSPORTING charg icon1.
*  ENDLOOP.
*
*  SORT GL_VEPO BY EXIDV.
*  LOOP AT wa_lips.
*    CLEAR: gv_vemng.
*    LOOP AT gl_vepo WHERE item1 = wa_lips-item1.
*      ADD gl_vepo-vemng  TO gv_vemng.
*    ENDLOOP.
*    wa_lips-delqty = gv_vemng.
*    MODIFY wa_lips TRANSPORTING delqty.
*  ENDLOOP.
*
*  LOOP AT wa_lips.
*    MOVE-CORRESPONDING wa_lips TO gl_lips.
*    gl_lips-ndelqty = 0.
*    gl_lips-jisiqty = 0.
*    gl_lips-migul   = 0.
*    gl_lips-avqty   = 0.
*    gl_lips-lfimg   = 0.
*    gl_lips-qiqty   = 0.
*    gl_lips-sub = '2'.
*    APPEND gl_lips.
*  ENDLOOP.

ENDFORM.                    " GET_DELQTY_200
*&---------------------------------------------------------------------*
*&      Form  GET_DELQTY_300
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM GET_DELQTY_300 .

* 2005.12.08 - 상위품목에 배치 지정.
* Requested by 허.
* - 상위품목에 배치가 바로 붙는 경우는 포장,포장해체 불가.
* - 피킹만 할수 있도록.
  LOOP AT GL_LIPS WHERE SUB = '1'
                    AND XCHPF = 'X'
                    AND CHARG <> ' '.
    GL_LIPS-FIXED  = 'X'.
    GL_LIPS-DELQTY = GL_LIPS-JISIQTY.
    MODIFY GL_LIPS TRANSPORTING FIXED DELQTY.
  ENDLOOP.

  LOOP AT GL_LIPS WHERE XCHPF = ' '.
    SELECT SINGLE RFMNG INTO GL_LIPS-DELQTY FROM VBFA
                       WHERE VBELV   = GL_LIPS-VBELN
                         AND POSNV   = GL_LIPS-POSNR
                         AND VBTYP_N = 'Q'.
    IF SY-SUBRC <> 0.
      GL_LIPS-DELQTY = 0.
    ENDIF.
    MODIFY GL_LIPS  TRANSPORTING DELQTY.
  ENDLOOP.

ENDFORM.                    " GET_DELQTY_300
*&---------------------------------------------------------------------*
*&      Form  REFRESH_DETAIL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM REFRESH_DETAIL .

  PERFORM DEQUEUE_ALL.

  CLEAR: R_VBELN[], R_VBELN, ET_LIKP[], ET_LIKP.
  PERFORM GET_RANGE_VBELN USING P_VBELN.
  PERFORM DATA_QUERY TABLES ET_LIKP
                            R_VBELN.
  LOOP AT ET_LIKP.
    LOOP AT GT_LIKP WHERE VBELN = ET_LIKP-VBELN.
      MOVE-CORRESPONDING ET_LIKP TO GT_LIKP.
      GT_LIKP-WADAT_IST = SY-DATUM.
      MODIFY GT_LIKP .
    ENDLOOP.
  ENDLOOP.

  GV_SAVE_FLAG = 'X'.
  PERFORM GET_DETAIL.

ENDFORM.                    " REFRESH_DETAIL
*&---------------------------------------------------------------------*
*&      Form  conversion_unit_200
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM CONVERSION_UNIT_200 .

  LOOP AT GL_VEPO.
    READ TABLE GL_LIPS WITH KEY MATNR = GL_VEPO-MATNR
                                SOBKZ = GL_VEPO-SOBKZ.
    IF SY-SUBRC = 0.
      IF GL_VEPO-VEMEH <> GL_LIPS-VRKME.
        IF NOT GL_LIPS-UMVKZ IS INITIAL.
          GL_VEPO-VEMNG = GL_VEPO-VEMNG * GL_LIPS-UMVKN / GL_LIPS-UMVKZ.
          GL_VEPO-VEMEH = GL_LIPS-VRKME.
          MODIFY GL_VEPO TRANSPORTING VEMNG VEMEH.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDLOOP.


ENDFORM.                    " conversion_unit_200
*&---------------------------------------------------------------------*
*&      Form  get_batch_info
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM GET_BATCH_INFO .

  DATA: LV_FIELD(30).

*  lv_field = g_cursor_field+0(7).
  LV_FIELD = G_CURSOR_FIELD+0(15).
  READ TABLE GL_LIPS WITH KEY CHK = 'X'.
  IF LV_FIELD = 'GT_ASSG-VEMNG'.
    I_CURSOR_LINE = TC03-CURRENT_LINE + I_CURSOR_LINE - 1.
    READ TABLE GT_ASSG INDEX I_CURSOR_LINE.
    CHECK SY-SUBRC = 0.
    CLEAR: GT_DETL[].
    LOOP AT GL_VEPO WHERE EXIDV = GT_ASSG-EXIDV
                      AND MATNR = GL_LIPS-MATNR
                      AND SOBKZ = GL_LIPS-SOBKZ
                      AND SONUM = GL_LIPS-SONUM.
      MOVE-CORRESPONDING GL_VEPO  TO GT_DETL.
      COLLECT GT_DETL.
    ENDLOOP.

    CALL SCREEN 210 STARTING AT 1  20
                    ENDING   AT 30 28.

  ELSEIF LV_FIELD = 'GT_NASG-VEMNG'.
    I_CURSOR_LINE = TC04-CURRENT_LINE + I_CURSOR_LINE - 1.
    READ TABLE GT_NASG INDEX I_CURSOR_LINE.
    CHECK SY-SUBRC = 0.
    CLEAR: GT_DETL[].
    LOOP AT GL_VEPO WHERE EXIDV = GT_NASG-EXIDV
                      AND MATNR = GL_LIPS-MATNR
                      AND SOBKZ = GL_LIPS-SOBKZ
                      AND SONUM = GL_LIPS-SONUM.
      MOVE-CORRESPONDING GL_VEPO  TO GT_DETL.
      COLLECT GT_DETL.
    ENDLOOP.

    CALL SCREEN 210 STARTING AT 1  20
                    ENDING   AT 30 28.

  ELSEIF LV_FIELD = 'GT_ASSG-EXIDV'.
    I_CURSOR_LINE = TC03-CURRENT_LINE + I_CURSOR_LINE - 1.
    READ TABLE GT_ASSG INDEX I_CURSOR_LINE.
    CHECK SY-SUBRC = 0.
    PERFORM CALL_TCODE_HUMO USING GT_ASSG-EXIDV.

  ELSEIF LV_FIELD = 'GT_NASG-EXIDV'.
    I_CURSOR_LINE = TC04-CURRENT_LINE + I_CURSOR_LINE - 1.
    READ TABLE GT_NASG INDEX I_CURSOR_LINE.
    CHECK SY-SUBRC = 0.
    PERFORM CALL_TCODE_HUMO USING GT_NASG-EXIDV.

  ELSEIF LV_FIELD = 'GT_LIPS-MATNR'.
    IF SY-DYNNR = '0200'.
      I_CURSOR_LINE = TC02-CURRENT_LINE + I_CURSOR_LINE - 1.
    ELSEIF SY-DYNNR = '0300'.
      I_CURSOR_LINE = TC12-CURRENT_LINE + I_CURSOR_LINE - 1.
    ENDIF.

    READ TABLE GT_LIPS INDEX I_CURSOR_LINE.
    CHECK SY-SUBRC = 0.
    SET PARAMETER ID 'MAT' FIELD GT_LIPS-MATNR.
    CALL TRANSACTION 'MM03'.

  ELSEIF LV_FIELD = 'GT_LIPS-VGBEL'.
    IF SY-DYNNR = '0200'.
      I_CURSOR_LINE = TC02-CURRENT_LINE + I_CURSOR_LINE - 1.
    ELSEIF SY-DYNNR = '0300'.
      I_CURSOR_LINE = TC12-CURRENT_LINE + I_CURSOR_LINE - 1.
    ENDIF.

    READ TABLE GT_LIPS INDEX I_CURSOR_LINE.
    CHECK SY-SUBRC = 0.
    IF GT_LIKP-LFART = 'NL'.
      SET PARAMETER ID 'BES' FIELD GT_LIPS-VGBEL.
      CALL TRANSACTION 'ME23N'.
    ELSE.
      SET PARAMETER ID 'AUN' FIELD GT_LIPS-VGBEL.
      CALL TRANSACTION 'VA03' AND SKIP  FIRST SCREEN.
    ENDIF.

  ELSEIF LV_FIELD = 'P_VBELN'.
    SET PARAMETER ID 'VL' FIELD P_VBELN.
    CALL TRANSACTION 'VL03N'
                  AND SKIP  FIRST SCREEN.


  ENDIF.

ENDFORM.                    " get_batch_info
*&---------------------------------------------------------------------*
*&      Form  BATCH_SORT_CHAR_200
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM BATCH_SORT_CHAR_200 .

*/ 배치특성(정렬순서: CU72)
  REFRESH: GT_KSML.
  LOOP AT GL_LIPS WHERE SUB = '1'.
    PERFORM GET_SORT_BATCH_CHARACTERISTIC USING GL_LIPS-MATNR.
  ENDLOOP.

  LOOP AT GL_VEPO.
* 배치특성을 구하고, 정렬순서와 비교하여 순번을 매겨서
* 재정렬한다.
    REFRESH: GT_AUSP.
    PERFORM BATCH_CHARACTERISTIC TABLES GT_AUSP
                                 USING GL_VEPO-MATNR
                                       GL_VEPO-CHARG.
    CLEAR: LV_COL_ATWRT.
    SORT GT_AUSP BY POSNR.
    LOOP AT GT_AUSP.
      CONCATENATE LV_COL_ATWRT GT_AUSP-ATWRT ';'
        INTO LV_COL_ATWRT." SEPARATED BY ';'.
    ENDLOOP.

    GL_VEPO-CHART = LV_COL_ATWRT+1(99).
    MODIFY GL_VEPO.
  ENDLOOP.


ENDFORM.                    " BATCH_SORT_CHAR_200
*&---------------------------------------------------------------------*
*&      Form  CANNOT_ASSIGN
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM CANNOT_ASSIGN .



ENDFORM.                    " CANNOT_ASSIGN
*&---------------------------------------------------------------------*
*&      Form  conversion_unit_300
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM CONVERSION_UNIT_300 .

  LOOP AT XL_NASG.
    READ TABLE GL_LIPS WITH KEY ITEM1 = XL_NASG-ITEM1.
    IF SY-SUBRC = 0.
      IF GL_LIPS-MEINS <> GL_LIPS-VRKME.
        IF NOT GL_LIPS-UMVKZ IS INITIAL.
          XL_NASG-LENGTH =
            XL_NASG-LENGTH * GL_LIPS-UMVKN / GL_LIPS-UMVKZ.
          XL_NASG-LABST =
            XL_NASG-LABST * GL_LIPS-UMVKN / GL_LIPS-UMVKZ.

          MODIFY XL_NASG TRANSPORTING LENGTH LABST.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDLOOP.

  LOOP AT XL_ASSG.
    READ TABLE GL_LIPS WITH KEY ITEM1 = XL_ASSG-ITEM1.
    IF SY-SUBRC = 0.
      IF GL_LIPS-MEINS <> GL_LIPS-VRKME.
        IF NOT GL_LIPS-UMVKZ IS INITIAL.
          XL_ASSG-LENGTH =
            XL_ASSG-LENGTH * GL_LIPS-UMVKN / GL_LIPS-UMVKZ.
*          xl_assg-labst =
*            xl_assg-labst * gl_lips-umvkn / gl_lips-umvkz.

          MODIFY XL_ASSG TRANSPORTING LENGTH LABST.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDLOOP.

ENDFORM.                    " conversion_unit_300
*&---------------------------------------------------------------------*
*&      Form  GO_MMBE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM GO_MMBE .

  READ TABLE GL_LIPS WITH KEY CHK = 'X'.
  IF SY-SUBRC = 0.
    SET PARAMETER ID 'MAT' FIELD GL_LIPS-MATNR.
    SET PARAMETER ID 'WRK' FIELD GL_LIPS-WERKS.
    SET PARAMETER ID 'LAG' FIELD GL_LIPS-LGORT.
    SET PARAMETER ID 'MMBE_ME' FIELD GL_LIPS-VRKME.
    CALL TRANSACTION 'MMBE'.
  ENDIF.

ENDFORM.                    " GO_MMBE
*&---------------------------------------------------------------------*
*&      Form  conversion_unit_nasg_300
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM CONVERSION_UNIT_NASG_300 .

  LOOP AT XL_NASG.
    READ TABLE GL_LIPS WITH KEY ITEM1 = XL_NASG-ITEM1.
    IF SY-SUBRC = 0.
      IF GL_LIPS-MEINS <> GL_LIPS-VRKME.
        IF NOT GL_LIPS-UMVKZ IS INITIAL.
          XL_NASG-LENGTH =
            XL_NASG-LENGTH * GL_LIPS-UMVKN / GL_LIPS-UMVKZ.
          XL_NASG-LABST =
            XL_NASG-LABST * GL_LIPS-UMVKN / GL_LIPS-UMVKZ.

          MODIFY XL_NASG TRANSPORTING LENGTH LABST.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDLOOP.

ENDFORM.                    " conversion_unit_nasg_300
*&---------------------------------------------------------------------*
*&      Form  conversion_unit_assg_300
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM CONVERSION_UNIT_ASSG_300 .

  LOOP AT XL_ASSG.
    READ TABLE GL_LIPS WITH KEY ITEM1 = XL_ASSG-ITEM1.
    IF SY-SUBRC = 0.
      IF GL_LIPS-MEINS <> GL_LIPS-VRKME.
        IF NOT GL_LIPS-UMVKZ IS INITIAL.
          XL_ASSG-LENGTH =
            XL_ASSG-LENGTH * GL_LIPS-UMVKN / GL_LIPS-UMVKZ.
*          xl_assg-labst =
*            xl_assg-labst * gl_lips-umvkn / gl_lips-umvkz.

          MODIFY XL_ASSG TRANSPORTING LENGTH LABST.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDLOOP.

ENDFORM.                    " conversion_unit_assg_300
*&---------------------------------------------------------------------*
*&      Form  picking_200
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM PICKING_200 .

  PERFORM ERROR_CHECK_PICKING.

  PERFORM POP_UP_CONFIRM(ZLER0004) USING '< 확인 >'
                               '피킹 하시겠읍니까?'
                      CHANGING GV_RETURN.
  CHECK GV_RETURN = 'J'.

  PERFORM MAKE_PICKING_DATA_200.

  PERFORM BDC_RUN_PICKING
    USING P_WADAT_IST TVROT-ROUTE T173T-VSART.

ENDFORM.                    " picking_200
*&---------------------------------------------------------------------*
*&      Form  make_picking_data_200
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM MAKE_PICKING_DATA_200 .

  CLEAR: GT_TAB1[], GT_TAB1.
  LOOP AT GL_LIPS WHERE SUB = '1'.
*                    AND xchpf = 'X'.
    GT_TAB1-POSNR = GL_LIPS-POSNR.
    GT_TAB1-PIKMG = GL_LIPS-DELQTY.
    APPEND GT_TAB1.
  ENDLOOP.

*  DELETE gt_tab1 WHERE pikmg = 0.

  CLEAR: GT_TAB2[], GT_TAB2.
  LOOP AT GL_LIPS WHERE SUB = '2'.
*                    AND xchpf = 'X'.
    GT_TAB2-UECHA = GL_LIPS-ITEM1.
    GT_TAB2-POSNR = GL_LIPS-POSNR.
    GT_TAB2-CHARG = GL_LIPS-CHARG.
    GT_TAB2-VRKME = GL_LIPS-VRKME.
    GT_TAB2-PIKMG = GL_LIPS-DELQTY.
    APPEND GT_TAB2.
  ENDLOOP.

ENDFORM.                    " make_picking_data_200
*&---------------------------------------------------------------------*
*&      Form  WAST
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM WAST .

  PERFORM CHECK_BEFORE_WAST.

  DATA: GV_RETURN.

  PERFORM POP_UP_CONFIRM(ZLER0004) USING '< 확인 >'
                               '출고전기 하시겠습니까?'
                      CHANGING GV_RETURN.
  CHECK GV_RETURN = 'J'.

  DATA: LT_MSG LIKE ZLES009 OCCURS 0 WITH HEADER LINE.

  CLEAR: LT_MSG[], LT_MSG, R_VBELN[], R_VBELN.

  LOOP AT GT_LIKP WHERE CHK  = 'X'.

    PERFORM FUNC_WAST USING GT_LIKP-VBELN
                            GT_LIKP-ROUTE
                            GT_LIKP-WADAT_IST
                            GT_LIKP-VSART.
    IF GV_RESULT = 'S'.
      PERFORM GET_RANGE_VBELN USING GT_LIKP-VBELN.

      CONCATENATE GT_LIKP-VBELN ':출고전기 하였습니다'
         INTO LT_MSG-MSGTX .
      DELETE GT_LIKP.
    ELSE.
      CONCATENATE GT_LIKP-VBELN ':출고전기에러:' GV_MSG
         INTO LT_MSG-MSGTX .
    ENDIF.
    APPEND LT_MSG.
  ENDLOOP.

  IF NOT LT_MSG[] IS INITIAL.
    CALL FUNCTION 'Z_LE_POPUP_TO_ERROR_MESSAGE'
      TABLES
        MSG_TAB = LT_MSG.
  ENDIF.

ENDFORM.                    " WAST
*&---------------------------------------------------------------------*
*&      Form  check_before_wast
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM CHECK_BEFORE_WAST .

  LOOP AT GT_LIKP WHERE CHK = 'X'.
* WMS 창고는 관련없음.
    PERFORM NO_EXEC_WMS USING GT_LIKP-VBELN.
  ENDLOOP.

  CLEAR: GV_FLAG.
  LOOP AT GT_LIKP WHERE CHK = 'X'.
    IF GT_LIKP-WADAT_IST IS INITIAL.
      MESSAGE I001 WITH GT_LIKP-VBELN '실제출고일을 입력하세여'.
      GV_FLAG = 'X'.
    ENDIF.

    IF S_VSTEL-LOW <> 'J100' AND S_VSTEL-LOW <> 'J200'.
      IF S_VSTEL-LOW <= '6000' OR S_VSTEL-LOW >= '7999'.
        IF GT_LIKP-ROUTE IS INITIAL.
          MESSAGE I001 WITH GT_LIKP-VBELN '운송경로를 입력하세여'.
          GV_FLAG = 'X'.
        ENDIF.
      ENDIF.
    ENDIF.

  ENDLOOP.
  IF SY-SUBRC <> 0.
    GV_FLAG = 'X'.
    MESSAGE S000 WITH 'G/I 대상 납품을 선택하세여'.
  ENDIF.
  IF GV_FLAG = 'X'.
    LEAVE SCREEN.
  ENDIF.

ENDFORM.                    " check_before_wast
*&---------------------------------------------------------------------*
*&      Form  no_exec_wms
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GT_LIKP_VBELN  text
*----------------------------------------------------------------------*
FORM NO_EXEC_WMS  USING    P_VBELN.

  DATA: LT_LIPS LIKE LIPS OCCURS 0 WITH HEADER LINE.

  SELECT * INTO CORRESPONDING FIELDS OF TABLE LT_LIPS
   FROM LIPS
  WHERE VBELN = P_VBELN.

  LOOP AT LT_LIPS .
    SELECT SINGLE MANDT INTO SY-MANDT FROM T320
      WHERE WERKS = LT_LIPS-WERKS
        AND LGORT = LT_LIPS-LGORT.
    IF SY-SUBRC = 0.
      MESSAGE I000 WITH
       'WMS 창고입니다. 관련사항 없습니다'.
      LEAVE SCREEN.
    ENDIF.
  ENDLOOP.


ENDFORM.                    " no_exec_wms
*&---------------------------------------------------------------------*
*&      Form  SAME_BATCH_MODI_NA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM SAME_BATCH_MODI_NA .

  LOOP AT GT_NASG WHERE CHK = 'X'.
    LOOP AT GL_VEPO WHERE EXIDV = GT_NASG-EXIDV
                      AND PLACE = 'N'.
      CLEAR: GV_VEMNG, GV_FLAG.
      LOOP AT GL_LIPS WHERE MATNR = GL_VEPO-MATNR
                        AND SOBKZ = GL_VEPO-SOBKZ
                        AND SONUM = GL_VEPO-SONUM
                        AND CHARG = GL_VEPO-CHARG
                        AND FIXED = ' '
                        AND CALCU = ' '.
        PERFORM CALCULATE_LIPS USING '1' GV_RETURN.
        IF GV_RETURN = 'X'.
          EXIT.
        ENDIF.
      ENDLOOP.

      IF SY-SUBRC = 0 AND GV_FLAG = ' '.
        GL_VEPO-VEMNG = GL_VEPO-VEMNG - GV_VEMNG.
        MODIFY GL_VEPO.

        CLEAR: WA_VEPO[], WA_VEPO.
        MOVE-CORRESPONDING GL_VEPO   TO WA_VEPO.
        WA_VEPO-PLACE = 'A'.
        WA_VEPO-VEMNG = GV_VEMNG.
        WA_VEPO-ITEM1 = GL_LIPS-ITEM1.
        APPEND WA_VEPO.

        LOOP AT WA_VEPO.
          MOVE-CORRESPONDING WA_VEPO  TO GL_VEPO.
          APPEND GL_VEPO.
        ENDLOOP.

        DELETE GL_VEPO WHERE VEMNG = 0.

      ENDIF.
    ENDLOOP.
  ENDLOOP.


ENDFORM.                    " SAME_BATCH_MODI_NA
*&---------------------------------------------------------------------*
*&      Form  BATCH_APPEND_NA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM BATCH_APPEND_NA .

  LOOP AT GT_NASG WHERE CHK = 'X'.
    LOOP AT GL_VEPO WHERE EXIDV = GT_NASG-EXIDV
                      AND ORGIN = 'A'
                      AND PLACE = 'N'.
      CLEAR: GV_VEMNG, GV_FLAG.
      LOOP AT GL_LIPS WHERE MATNR = GL_VEPO-MATNR
                        AND SOBKZ = GL_VEPO-SOBKZ
                        AND SONUM = GL_VEPO-SONUM
                        AND ITEM1 = GL_VEPO-ITEM1
                        AND XCHPF = 'X'
                        AND SUB   = '1'
                        AND FIXED = ' '
                        AND CALCU = ' '.
        PERFORM CALCULATE_LIPS USING '2' GV_RETURN.
        IF GV_RETURN = 'X'.
          EXIT.
        ENDIF.
      ENDLOOP.

      IF SY-SUBRC = 0 AND GV_FLAG = ' '.
        DELETE GL_VEPO.

        CLEAR: WA_VEPO[], WA_VEPO.
        MOVE-CORRESPONDING GL_VEPO   TO WA_VEPO.
        WA_VEPO-VEMNG = GL_VEPO-VEMNG - GV_VEMNG.  "미지정수량
        APPEND WA_VEPO.

        WA_VEPO-PLACE = 'A'.
        WA_VEPO-VEMNG = GV_VEMNG.                  "지정수량
        WA_VEPO-ITEM1 = GL_LIPS-ITEM1.
        APPEND WA_VEPO.

        DELETE WA_VEPO WHERE VEMNG = 0.

        LOOP AT WA_VEPO.
          MOVE-CORRESPONDING WA_VEPO  TO GL_VEPO.
          APPEND GL_VEPO.
        ENDLOOP.

        CLEAR: WA_LIPS1[], WA_LIPS1.
        WA_LIPS1-VBELN  = GL_VEPO-VBELN.
        WA_LIPS1-POSNR  = GL_VEPO-POSNR.
        WA_LIPS1-WERKS  = GL_LIPS-WERKS.
        WA_LIPS1-LGORT  = GL_LIPS-LGORT.
        WA_LIPS1-MATNR  = GL_LIPS-MATNR.
        WA_LIPS1-SOBKZ  = GL_LIPS-SOBKZ.
        WA_LIPS1-SONUM  = GL_LIPS-SONUM.
        WA_LIPS1-ITEM1  = GL_LIPS-ITEM1.
        WA_LIPS1-VRKME  = GL_LIPS-VRKME.
        WA_LIPS1-ARKTX  = GL_LIPS-ARKTX.
        WA_LIPS1-SUB    = '2'.
        WA_LIPS1-CHARG  = GL_VEPO-CHARG.
        WA_LIPS1-DELQTY = GV_VEMNG.

*{ 기능개선 145969 - 추가
        IF GL_LIPS-SOBKZ IS NOT INITIAL.
          WA_LIPS1-VGBEL = GL_LIPS-SONUM(10).
          WA_LIPS1-VGPOS = GL_LIPS-SONUM+10(6).
        ENDIF.
*} 기능개선 145969 - 추가

        APPEND WA_LIPS1.

        LOOP AT WA_LIPS1.
          MOVE-CORRESPONDING WA_LIPS1  TO GL_LIPS.
          COLLECT GL_LIPS.
        ENDLOOP.

      ENDIF.
    ENDLOOP.
  ENDLOOP.

  LOOP AT GT_NASG WHERE CHK = 'X'.
    LOOP AT GL_VEPO WHERE EXIDV = GT_NASG-EXIDV
                      AND ORGIN = 'N'
                      AND PLACE = 'N'.
      CLEAR: GV_VEMNG, GV_FLAG.
      LOOP AT GL_LIPS WHERE MATNR = GL_VEPO-MATNR
                        AND SOBKZ = GL_VEPO-SOBKZ
                        AND SONUM = GL_VEPO-SONUM
*                        and item1 = gl_vepo-item1
                        AND XCHPF = 'X'
                        AND SUB   = '1'
                        AND FIXED = ' '
                        AND CALCU = ' '.
        PERFORM CALCULATE_LIPS USING '2' GV_RETURN.
        IF GV_RETURN = 'X'.
          EXIT.
        ENDIF.
      ENDLOOP.

      IF SY-SUBRC = 0 AND GV_FLAG = ' '.
        DELETE GL_VEPO.

        CLEAR: WA_VEPO[], WA_VEPO.
        MOVE-CORRESPONDING GL_VEPO   TO WA_VEPO.
        WA_VEPO-VEMNG = GL_VEPO-VEMNG - GV_VEMNG.  "미지정수량
        APPEND WA_VEPO.

        WA_VEPO-PLACE = 'A'.
        WA_VEPO-VEMNG = GV_VEMNG.                  "지정수량
        WA_VEPO-ITEM1 = GL_LIPS-ITEM1.
        APPEND WA_VEPO.

        DELETE WA_VEPO WHERE VEMNG = 0.

        LOOP AT WA_VEPO.
          MOVE-CORRESPONDING WA_VEPO  TO GL_VEPO.
          APPEND GL_VEPO.
        ENDLOOP.

        CLEAR: WA_LIPS1[], WA_LIPS1.
        WA_LIPS1-VBELN  = GL_VEPO-VBELN.
        WA_LIPS1-POSNR  = GL_VEPO-POSNR.
        WA_LIPS1-WERKS  = GL_LIPS-WERKS.
        WA_LIPS1-LGORT  = GL_LIPS-LGORT.
        WA_LIPS1-MATNR  = GL_LIPS-MATNR.
        WA_LIPS1-SOBKZ  = GL_LIPS-SOBKZ.
        WA_LIPS1-SONUM  = GL_LIPS-SONUM.
        WA_LIPS1-ITEM1  = GL_LIPS-ITEM1.
        WA_LIPS1-VRKME  = GL_LIPS-VRKME.
        WA_LIPS1-ARKTX  = GL_LIPS-ARKTX.
        WA_LIPS1-SUB    = '2'.
        WA_LIPS1-CHARG  = GL_VEPO-CHARG.
        WA_LIPS1-DELQTY = GV_VEMNG.

*{ 기능개선 145969 - 추가
        IF GL_LIPS-SOBKZ IS NOT INITIAL.
          WA_LIPS1-VGBEL = GL_LIPS-SONUM(10).
          WA_LIPS1-VGPOS = GL_LIPS-SONUM+10(6).
        ENDIF.
*} 기능개선 145969 - 추가

        APPEND WA_LIPS1.

        LOOP AT WA_LIPS1.
          MOVE-CORRESPONDING WA_LIPS1  TO GL_LIPS.
          COLLECT GL_LIPS.
        ENDLOOP.

      ENDIF.
    ENDLOOP.
  ENDLOOP.

ENDFORM.                    " BATCH_APPEND_NA
*&---------------------------------------------------------------------*
*& Form GET_CBM_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- <FS_LIPS>
*&---------------------------------------------------------------------*
FORM GET_CBM_DATA  CHANGING PS_LIPS LIKE GT_LIPS.
  DATA: LT_TAB TYPE TABLE OF ZGTEDSIF0034.

  CHECK PS_LIPS-VGBEL IS NOT INITIAL.

  APPEND VALUE #( VBELN = PS_LIPS-VGBEL
                  POSNR = PS_LIPS-VGPOS
                 ) TO LT_TAB.

  CALL FUNCTION 'ZGTED_SELECT_CBM_DATA'
    TABLES
      OT_OUTPUT = LT_TAB.

  DATA(LS_TAB) = VALUE #( LT_TAB[ 1 ] OPTIONAL ).

  CHECK LS_TAB-MSG_TYPE NE 'E'.

  "폭/드럼
  PS_LIPS-OUT_WID = LS_TAB-OUT_WID.

  "약경/드럼
  PS_LIPS-PLAN_DIA = LS_TAB-BARREL_DIA.

  "드럼무게/개
  PS_LIPS-DR_WEIGHT = LS_TAB-BRGEW.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_TOTAL_WEIGHT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- <FS_LIPS>
*&---------------------------------------------------------------------*
FORM GET_TOTAL_WEIGHT  CHANGING PS_LIPS LIKE GT_LIPS.
  DATA : LV_MENGE    TYPE LIPS-LFIMG,
         LV_INDQTY   TYPE ZLET0401-INDQTY,
         LV_NTGEW_DR TYPE MARA-NTGEW,
         LV_NTGEW_MM TYPE MARA-NTGEW.
  DATA:  LV_MEINS_KG TYPE MEINS  VALUE 'KG'.



*-제품중량
  SELECT SINGLE MEINS,NTGEW,GEWEI
    FROM MARA
   WHERE MATNR EQ @PS_LIPS-MATNR
    INTO @DATA(LS_MARA).

  LV_MENGE = PS_LIPS-JISIQTY.

  "자재 기본단위로 변경
  IF PS_LIPS-VRKME NE LS_MARA-MEINS.

    LV_MENGE = ZGTSD_CL_COMMON2=>MD_CONVERT_MATERIAL_UNIT( IV_MATNR = PS_LIPS-MATNR
                                                           IV_IN_ME = PS_LIPS-VRKME
                                                           IV_OT_ME = PS_LIPS-MEINS
                                                           IV_MENGE = LV_MENGE        ).

  ENDIF.

  LV_NTGEW_MM = LS_MARA-NTGEW * LV_MENGE.

  "중량단위 'KG'
  IF LS_MARA-GEWEI NE LV_MEINS_KG.
    LV_NTGEW_MM = ZGTSD_CL_COMMON2=>MD_CONVERT_MATERIAL_UNIT( IV_MATNR = PS_LIPS-MATNR
                                                              IV_IN_ME = LS_MARA-GEWEI
                                                              IV_OT_ME = LV_MEINS_KG
                                                              IV_MENGE = LV_NTGEW_MM        ).
  ENDIF.

*-총중량(드럼포함) : 드럼무게/개 + 제품중량
  PS_LIPS-BRGEW_DR = ( PS_LIPS-DR_WEIGHT * LV_INDQTY ) + LV_NTGEW_MM.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form update_factor_batch
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_VBELN
*&      --> P_WADAT
*&---------------------------------------------------------------------*
FORM UPDATE_FACTOR_BATCH  USING    P_VBELN.

  DATA: LT_RETURN  TYPE TABLE OF BAPIRET2,
        LV_CLASS   TYPE KLAH-CLASS,
        LT_VALNUM  TYPE TABLE OF BAPI1003_ALLOC_VALUES_NUM,
        LS_VALNUM  TYPE BAPI1003_ALLOC_VALUES_NUM,
        LT_VALCHAR TYPE TABLE OF BAPI1003_ALLOC_VALUES_CHAR,
        LS_VALCHAR TYPE BAPI1003_ALLOC_VALUES_CHAR,
        LT_VALCURR TYPE TABLE OF BAPI1003_ALLOC_VALUES_CURR,
        LV_STATUS  TYPE BAPI1003_KEY-STATUS.

  DATA: LV_TMSTMP  TYPE TIMESTAMPL,
        LT_LOG     TYPE TABLE OF ZGTSDT1120,
        LS_LOG     TYPE ZGTSDT1120,
        LV_ERR_FLG TYPE ABAP_BOOL.

  " Factor Batch 대상 자재코드/Batch 번호 추출
  SELECT A~VBELN, A~MATNR, A~WERKS, A~CHARG, B~DPCBT
    FROM LIPS AS A INNER JOIN MARC AS B
                   ON A~MATNR EQ B~MATNR
                  AND A~WERKS EQ B~WERKS
   WHERE B~DPCBT EQ 'A'
     AND A~CHARG NE @ABAP_FALSE
     AND A~VBELN EQ @P_VBELN
   GROUP BY A~VBELN, A~MATNR, A~WERKS, A~CHARG, B~DPCBT
    INTO TABLE @DATA(LT_CHARG).

  " 조회된 대상이 있을 때만 하위 로직 수행
  IF LT_CHARG[] IS NOT INITIAL.

    " ASIS Factor Batch의 SAP_MILLCA_LENGTH
    SELECT A~MATNR, A~CHARG, A~WERKS,
           B~ATFLV AS LENGTH,
           CAST( B~ATFLV AS CHAR( 15 ) ) AS LENGTH_C
      FROM @LT_CHARG AS A INNER JOIN ZGTSD_CV_GET_VCOFBATCH AS B
                          ON A~MATNR EQ B~MATNR
                         AND A~WERKS EQ B~WERKS
                         AND A~CHARG EQ B~CHARG
     WHERE ATNAM EQ 'SAP_MILLCA_LENGTH'
      INTO TABLE @DATA(LT_LENGTH).

    SORT: LT_CHARG  BY VBELN MATNR WERKS CHARG DPCBT,
          LT_LENGTH BY MATNR CHARG WERKS LENGTH.

*    Charg 값을 SAP_MILLCA_LENGTH 로 업데이트
    LOOP AT LT_CHARG ASSIGNING FIELD-SYMBOL(<LFS_CHARG>).
      CLEAR: LT_VALNUM, LT_VALCHAR, LT_VALCURR.

*     현재 클래스 023의 SAP_MILLCA_LENGTH 값
      DATA(LS_LEN) = VALUE #( LT_LENGTH[ MATNR = <LFS_CHARG>-MATNR
                                        CHARG = <LFS_CHARG>-CHARG
                                        WERKS = <LFS_CHARG>-WERKS ] OPTIONAL ).

      IF <LFS_CHARG>-CHARG EQ LS_LEN-LENGTH_C.
        CONTINUE.
      ELSE.
        " CLASS번호
        CLEAR: LV_CLASS.
        CALL FUNCTION 'CLFC_BATCH_ALLOCATION_TO_CLASS'
          EXPORTING
            MATERIAL           = <LFS_CHARG>-MATNR " G/I자재
            PLANT              = <LFS_CHARG>-WERKS " 플랜트
            CLASSTYPE          = '023'             " 클래스유형(배치)
          IMPORTING
            CLASS              = LV_CLASS
          EXCEPTIONS
            NO_CLASS_FOUND     = 1
            NO_CLASSTYPE_FOUND = 2
            OTHERS             = 3.

        CHECK LV_CLASS IS NOT INITIAL.

        CLEAR: LS_VALNUM.
        LS_VALNUM-CHARACT = 'SAP_MILLCA_LENGTH_SUB'.
        LS_VALNUM-VALUE_FROM = '0'.
        APPEND LS_VALNUM TO LT_VALNUM.

        CLEAR: LS_VALNUM.
        LS_VALNUM-CHARACT = 'SAP_MILLCA_LENGTH'.
        LS_VALNUM-VALUE_FROM = <LFS_CHARG>-CHARG.
        APPEND LS_VALNUM TO LT_VALNUM.

        " - 배치 특성 업데이트(펑션 호출)
        SELECT SINGLE CUOBJ_BM
          INTO @DATA(LV_OBJKEY)
          FROM MCH1
         WHERE MATNR = @<LFS_CHARG>-MATNR
           AND CHARG = @<LFS_CHARG>-CHARG.

        CLEAR : LT_RETURN.
        CALL FUNCTION 'BAPI_OBJCL_CHANGE_KEY'
          EXPORTING
            CLOBJECTKEY         = LV_OBJKEY
            CLASSNUM            = LV_CLASS
          IMPORTING
            CLASSIF_STATUS      = LV_STATUS
          TABLES
            ALLOCVALUESNUM_NEW  = LT_VALNUM
            ALLOCVALUESCHAR_NEW = LT_VALCHAR
            ALLOCVALUESCURR_NEW = LT_VALCURR
            RETURN              = LT_RETURN.

        GET TIME STAMP FIELD LV_TMSTMP.

*      변경 결과 처리
        CLEAR: LV_ERR_FLG.
        IF LINE_EXISTS( LT_RETURN[ TYPE = 'E' ] ).
          LV_ERR_FLG = ABAP_TRUE.
          DATA(LS_MSG) = VALUE #( LT_RETURN[ TYPE = 'E' ] OPTIONAL ).
        ELSE.
          LS_MSG = VALUE #( LT_RETURN[ TYPE = 'S' ] OPTIONAL ).
        ENDIF.

        IF LV_ERR_FLG EQ ABAP_TRUE.
          CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
        ELSE.
          CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
            EXPORTING
              WAIT = 'X'.
        ENDIF.

*      로그 저장 정보 구성
        CLEAR LS_LOG.
        LS_LOG = VALUE #( TMSTMP          = LV_TMSTMP
                          MATNR           = <LFS_CHARG>-MATNR
                          CHARG           = <LFS_CHARG>-CHARG
                          WERKS           = <LFS_CHARG>-WERKS
                          LENGTH_OLD_CHAR = |{ CONV DECFLOAT34( LS_LEN-LENGTH ) }|
                          LENGTH_NEW_CHAR = <LFS_CHARG>-CHARG
                          LENGTH_OLD      = LS_LEN-LENGTH
                          LENGTH_NEW      = <LFS_CHARG>-CHARG
                          MTYPE           = LS_MSG-TYPE
                          MSG             = LS_MSG-MESSAGE
                          ERDAT           = SY-DATLO
                          ERNAM           = SY-UNAME
                          ERZET           = SY-TIMLO ).
        APPEND LS_LOG TO LT_LOG.

      ENDIF.
    ENDLOOP.

* 처리 결과 저장
    IF LT_LOG[] IS NOT INITIAL.
      MODIFY ZGTSDT1120 FROM TABLE LT_LOG.
      COMMIT WORK.
    ENDIF.

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form F4_WERKS
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&---------------------------------------------------------------------*
FORM F4_WERKS  USING    PV_FNAME.

  SELECT DISTINCT A~WERKS,B~NAME1
    FROM TVKWZ AS A INNER JOIN T001W AS B
                    ON A~WERKS = B~WERKS

   WHERE A~VKORG EQ @GC_VKORG_6000
    INTO TABLE @DATA(LT_VALUE).
  SORT LT_VALUE BY WERKS.
  CHECK LT_VALUE[] IS NOT INITIAL.

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      RETFIELD        = 'WERKS'
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
