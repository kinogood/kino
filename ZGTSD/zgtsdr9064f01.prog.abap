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
FORM initialization .

  CLEAR: s_erdat[], s_erdat.

  CONCATENATE sy-datum+0(6) '01' INTO s_erdat-low.
  s_erdat-sign   = 'I'.
  s_erdat-option = 'EQ'.
  s_erdat-high   = sy-datum.
  APPEND s_erdat.

  REFRESH: r_lfart.
  PERFORM append_lfart USING:
     'ZLF3'.

  APPEND 'VBELN'  TO ftab.
  APPEND 'VGBEL'  TO ftab.

  "저장위치
  APPEND VALUE #( sign = 'I' option = 'EQ' low = '3499' )
      TO s_lgort.
*  APPEND VALUE #( sign = 'I' option = 'EQ' low = gc_lgort_3410 )
*      TO s_lgort.
*  APPEND VALUE #( sign = 'I' option = 'EQ' low = gc_lgort_3420 )
*      TO s_lgort.

  PERFORM check_screen_modify.
ENDFORM.                    " initialization
*&---------------------------------------------------------------------*
*&      Form  get_field_text
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_field_text .

*출하지점
  PERFORM get_vstel_text(zler0002)   USING s_vstel-low
                        CHANGING pt_vstel.

*제품군(SPG)
  PERFORM get_spart_text(zler0002)   USING s_spart-low
                        CHANGING pt_spart.

*납품처
  PERFORM get_kunnr_text   USING s_kunnr-low
                        CHANGING pt_kunnr.

*판매처
  PERFORM get_kunnr_text   USING s_kunag-low
                        CHANGING pt_kunag.

ENDFORM.                    " get_field_text
*&---------------------------------------------------------------------*
*&      Form  selection_screen_modify
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM selection_screen_modify .

  LOOP AT SCREEN.
    CASE screen-group1.
      WHEN 'A'.
        screen-input  = 0.
        screen-display_3d = '0'.
        screen-intensified = 1.
    ENDCASE.

    IF screen-name = 'PA_IMODE'.
      screen-active    = 0.
      screen-input     = 0.
      screen-invisible = 1.
    ENDIF.

    IF screen-name = '%_PA_IMODE_%_APP_%-TEXT'.
      screen-active    = 0.
      screen-input     = 0.
      screen-invisible = 1.
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
FORM data_query  TABLES   pt_likp  LIKE gt_likp[]
                          pr_vbeln LIKE r_vbeln[].


  bdc_mode =  pa_imode.

  SELECT k~vbeln
         k~kunnr
         k~kunag
         k~erdat
         k~ernam
         k~wadat_ist AS wadat
         k~wadat AS wadat2
         k~route
         k~kostk
         k~cmgst
         k~lfart
         k~vsart
         k~vstel
     INTO CORRESPONDING FIELDS OF TABLE pt_likp
     FROM likp AS k INNER JOIN lips AS p
                    ON k~vbeln = p~vbeln

      WHERE k~erdat IN s_erdat
        AND k~wadat IN s_wadat
        AND k~vstel IN s_vstel
        AND k~vkorg EQ gc_vkorg_6000
        AND k~kunag IN s_kunag
        AND k~kunnr IN s_kunnr
        AND k~vbeln IN s_vbeln
        AND k~vbeln IN pr_vbeln
*        AND k~lifsk NE gc_lifsk_g3       "적송
        AND p~vtweg IN s_vtweg
        AND p~lgort IN s_lgort
*        AND p~lgort NE gc_lgort_3499     "적송
*        AND p~zzvbeln_js EQ space        "적송
        AND k~wbstk <> 'C'
        AND K~LFART IN R_LFART.
*        AND ( k~lfart LIKE 'LF%'  OR
*              k~lfart LIKE 'ZLF%' OR
*              k~lfart = 'NL' )
*        AND NOT EXISTS ( SELECT vbeln              "적송
*                           FROM zgtsdt9110
*                          WHERE vbeln EQ k~vbeln
*                            AND loevm EQ space    ).



  SORT pt_likp.
  DELETE ADJACENT DUPLICATES FROM pt_likp.


  DELETE pt_likp WHERE lfart = 'LF3'.

  IF NOT s_spart[] IS INITIAL.
    LOOP AT pt_likp.
      SELECT SINGLE mandt INTO sy-mandt FROM lips
        WHERE vbeln = pt_likp-vbeln
          AND spart IN s_spart.
      IF sy-subrc <> 0.
        DELETE pt_likp. CONTINUE.
      ENDIF.
    ENDLOOP.
  ENDIF.

*/ data ~ modify
  CHECK NOT pt_likp[] IS INITIAL.

  DATA: lt_likp  LIKE likp  OCCURS 0 WITH HEADER LINE.
  DATA: lt_kna1  LIKE kna1  OCCURS 0 WITH HEADER LINE.
  DATA: lt_tvrot LIKE tvrot OCCURS 0 WITH HEADER LINE.
  DATA: lv_werks LIKE lips-werks. "SRM2202-09416

** 납품처
*  SELECT * INTO TABLE lt_kna1
*    FROM kna1
*     FOR ALL ENTRIES IN pt_likp
*   WHERE kunnr = pt_likp-kunnr.
* 운송경로
  SELECT * INTO TABLE lt_tvrot
    FROM tvrot
   WHERE spras = sy-langu.

  SORT lt_kna1 .
  SORT lt_tvrot.

*-거래명세서 : ZLET0006
  DATA(lt_temp) = pt_likp[].
  SORT lt_temp BY vbeln.
  DELETE ADJACENT DUPLICATES FROM lt_temp COMPARING vbeln.
  IF lt_temp[] IS NOT INITIAL.
    SELECT DISTINCT vbeln,iv_no
      FROM zlet0006
       FOR ALL ENTRIES IN @lt_temp
     WHERE vbeln EQ @lt_temp-vbeln
      INTO TABLE @DATA(lt_zlet0006).
    SORT lt_zlet0006 BY vbeln.
  ENDIF.

  CLEAR: gv_tractor.
  LOOP AT pt_likp.

*** ADD BY HKSEO 2019.02.13
    IF ( pt_likp-vstel  >= 'M620'   AND
         pt_likp-vstel  <= 'M629' )  OR
       ( pt_likp-vstel   = 'M676' ).
      gv_tractor  = 'X'.
    ENDIF.
***

* 판매처
    SELECT SINGLE name1 INTO pt_likp-kunag_t FROM kna1
      WHERE kunnr = pt_likp-kunag.
** 거래처
    DATA: lv_adrnr  LIKE vbpa-adrnr.

    SELECT SINGLE adrnr INTO lv_adrnr
       FROM vbpa
      WHERE vbeln = pt_likp-vbeln
        AND posnr = '000000'
        AND parvw = 'WE'.
    SELECT SINGLE name1 INTO pt_likp-kunnr_t
       FROM adrc
      WHERE addrnumber = lv_adrnr.

*    READ TABLE lt_kna1  WITH KEY kunnr = pt_likp-kunnr
*              BINARY SEARCH.
*    IF sy-subrc = 0.
*      pt_likp-kunnr_t = lt_kna1-name1.
*    ENDIF.
* 운송경로
    READ TABLE lt_tvrot WITH KEY route = pt_likp-route
             BINARY SEARCH.
    IF sy-subrc = 0.
      pt_likp-route_t = lt_tvrot-bezei.
    ENDIF.

    SELECT SINGLE bezei INTO pt_likp-vsart_t FROM t173t
      WHERE spras = '3'
        AND vsart = pt_likp-vsart.

    pt_likp-wadat_ist = sy-datum.


* [START] CSR No : C20091028_48918
* BCKOO 091209 TABLE Control화면(첫화면)에 자재코드,자재명 추가
    SELECT SINGLE matnr arktx werks "SRM2202-09416 플랜트 추가
                  vgbel
      INTO (pt_likp-matnr, pt_likp-arktx, lv_werks, pt_likp-vgbel)
      FROM lips
     WHERE vbeln = pt_likp-vbeln.

* [END]   CSR No : C20091028_48918

*{ SRM2202-09416 - s
    SELECT SINGLE matgr INTO pt_likp-matgr
      FROM marc
     WHERE matnr = pt_likp-matnr
       AND werks = lv_werks.
*} SRM2202-09416 - e

*   거래명세서 번호
    pt_likp-iv_no = VALUE #( lt_zlet0006[ vbeln = pt_likp-vbeln ]-iv_no OPTIONAL ).

    MODIFY pt_likp.
  ENDLOOP.

  SORT pt_likp .

*** ADD BY HKSEO 2019.02.14  PDI 필드는 트렉터에서만 볼수 있도록 셋팅.
  IF  gv_tractor  = 'X'.
    UPDATE tcview  SET: tcinvisibl  = ''
                  WHERE tcprogram   = sy-repid
*                    AND TCUSER      = SY-UNAME
                    AND ( tcfieldnam  = 'XT_NASG-ICON2'
                       OR tcfieldnam  = 'XT_ASSG-ICON2' )
                    .
  ELSE.
    UPDATE tcview  SET: tcinvisibl  = 'X'
                  WHERE tcprogram   = sy-repid
*                    AND TCUSER      = SY-UNAME
                    AND ( tcfieldnam  = 'XT_NASG-ICON2'
                       OR tcfieldnam  = 'XT_ASSG-ICON2' )
                    .
  ENDIF.
  COMMIT WORK.
***

ENDFORM.                    " data_query
*&---------------------------------------------------------------------*
*&      Form  get_kunnr_text
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_S_KUNNR_LOW  text
*      <--P_PT_KUNNR  text
*----------------------------------------------------------------------*
FORM get_kunnr_text  USING    p_kunnr
                     CHANGING p_name.

  SELECT SINGLE name1 INTO p_name
    FROM kna1
   WHERE kunnr = p_kunnr.


ENDFORM.                    " get_kunnr_text
*&---------------------------------------------------------------------*
*&      Form  get_route_text
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GT_LIKP_ROUTE  text
*      <--P_GT_LIKP_ROUTE_T  text
*----------------------------------------------------------------------*
FORM get_route_text  USING    p_route
                     CHANGING p_route_t.

  SELECT SINGLE bezei INTO p_route_t FROM tvrot
    WHERE route = p_route
      AND spras = sy-langu.
  IF sy-subrc <> 0.
    MESSAGE e000 WITH '존재하지 않는 ROUTE입니다.'.
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
FORM refresh .

  CLEAR: gt_likp[], gt_likp, r_vbeln[], r_vbeln.
  PERFORM data_query TABLES gt_likp
                            r_vbeln.

ENDFORM.                    " refresh
*&---------------------------------------------------------------------*
*&      Form  sort_likp
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM sort_likp .

  DATA: lv_field(30).
  lv_field = g_cursor_field+8(12).

  IF save_ok = 'ASCD'.
    SORT gt_likp BY (lv_field) ASCENDING.
  ELSE.
    SORT gt_likp BY (lv_field) DESCENDING.
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
FORM get_detail .

  REFRESH: CONTROL 'TC02' FROM SCREEN '0200',
           CONTROL 'TC12' FROM SCREEN '0300',
           CONTROL 'TC03' FROM SCREEN '0200',
           CONTROL 'TC13' FROM SCREEN '0300',
           CONTROL 'TC04' FROM SCREEN '0200',
           CONTROL 'TC14' FROM SCREEN '0300'.

  DATA: lv_werks LIKE lips-werks,
        lv_lgort LIKE lips-lgort.

  CLEAR: lv_xhupf, lv_werks, lv_lgort, p_qiqty, p_vrkme,
         gv_serial.                "기능개선 157076 - 추가

  REFRESH: gt_ship.
  CLEAR  : gt_ship.

*/ read gt_lips index.
  IF gv_save_flag = ' '.
    i_cursor_line = tc01-current_line + i_cursor_line - 1.
    READ TABLE gt_likp INDEX i_cursor_line.
    gv_line = i_cursor_line.
  ELSE.
    READ TABLE gt_likp INDEX gv_line.
    gv_save_flag = 'X'.
  ENDIF.

*/ lock
  PERFORM enquene_do USING gt_likp-vbeln.

*/ WMS 창고는 관련없음.
  PERFORM check_wms_storage.

*/ DEFAULT VALUE SET
  PERFORM default_value_set.

*/ HU 사용, 미사용 구분
  SELECT SINGLE werks lgort
    INTO (lv_werks, lv_lgort) FROM lips
   WHERE vbeln = gt_likp-vbeln
     AND lgort <> ' '.
  IF sy-subrc = 0.
    SELECT SINGLE xhupf INTO lv_xhupf FROM t001l
      WHERE werks = lv_werks
        AND lgort = lv_lgort.
    IF sy-subrc = 0.
      IF gt_likp-cmgst = 'B' OR
         gt_likp-cmgst = 'C'.
        MESSAGE i000 WITH '여신보류되었습니다'.
      ENDIF.

      IF lv_xhupf = 'X'.
        PERFORM make_data_hu.
*      CALL SCREEN 200.
      ELSE.
        PERFORM make_data_hu_no.
*      CALL SCREEN 300.
      ENDIF.
    ELSE.
      PERFORM make_data_hu_no.
      lv_xhupf = ' '.
*   MESSAGE s000 WITH '품목이 없습니다'.
    ENDIF.
  ELSE.
    PERFORM make_data_hu_no.
    lv_xhupf = ' '.
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
FORM check_wms_storage .

  DATA: lt_lips LIKE lips OCCURS 0 WITH HEADER LINE.

  SELECT * INTO CORRESPONDING FIELDS OF TABLE lt_lips
   FROM lips
  WHERE vbeln = gt_likp-vbeln.   "p_vbeln.

  LOOP AT lt_lips .
    SELECT SINGLE mandt INTO sy-mandt FROM t320
      WHERE werks = lt_lips-werks
        AND lgort = lt_lips-lgort.
    IF sy-subrc = 0.
      PERFORM dequeue_all.
      MESSAGE i000 WITH
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
FORM default_value_set .

  p_vbeln       = gt_likp-vbeln.
  p_kostk       = gt_likp-kostk.
  p_kunnr       = gt_likp-kunnr.
  p_kunnr_t     = gt_likp-kunnr_t.
  p_kunag       = gt_likp-kunag.
  p_kunag_t     = gt_likp-kunag_t.
  p_wadat_ist   = gt_likp-wadat_ist.
  tvrot-route   = gt_likp-route.
  tvrot-bezei   = gt_likp-route_t.
  t173t-vsart   = gt_likp-vsart.
  t173t-bezei   = gt_likp-vsart_t.

  p_wadat   = gt_likp-wadat2.

ENDFORM.                    " DEFAULT_VALUE_SET
*&---------------------------------------------------------------------*
*&      Form  MAKE_DATA_HU
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM make_data_hu .

*/ select ~ lips
  SELECT * INTO CORRESPONDING FIELDS OF TABLE gl_lips
    FROM lips
   WHERE vbeln = p_vbeln.

*/ 품목상태
  PERFORM get_status_lips.

*/ 지시수량(jisiqty): 현재납품수량,
*  지정수량(delqty) : 배치사용(배치지정수량), 배치미사용(포장수량)
  PERFORM get_jisiqty_delqty.

*/ 미결수량, 납품가능량
  PERFORM get_migul_lfimg.

*/ 제품특성
  PERFORM get_so_characteristic.

*/ SHIPPING NO
  PERFORM read_text_ship_no.

*/ 포장정보
  PERFORM get_gl_vepo_hu.

*/ 배치특성(정렬순서: CU72)
  PERFORM batch_sort_char_200.

*/ 단위환산: 판매단위와 재고단위가 다를 경우.
  PERFORM conversion_unit_200.

*/ 지정수량
  PERFORM get_delqty_200.

*/ 지정할수 없는 품목이 있는지, 점검.
*  PERFORM cannot_assign.

* 모두 지정되었는지 점검: 모두 지정되엇으면, 피킹 가능
  PERFORM check_picking_possibe.

  cl_lips[] = gl_lips[].
  cl_vepo[] = gl_vepo[].


ENDFORM.                    " MAKE_DATA_HU
*&---------------------------------------------------------------------*
*&      Form  set_gt_lips
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM set_gt_lips .

  SORT gl_lips BY item1  "상위 OR 하위 품목 ( '1' OR '2' )
                  sub
                  posnr. "품목.

*/ 미지정수량
  wa_lips[] = gl_lips[].
  LOOP AT gl_lips WHERE sub = '1'.
* 지시수량
    CLEAR: gv_jisiqty, gv_delqty.
    LOOP AT wa_lips WHERE item1 = gl_lips-item1.
      ADD wa_lips-jisiqty TO gv_jisiqty.
      ADD wa_lips-delqty  TO gv_delqty.
    ENDLOOP.

* 미지정수량
    gl_lips-ndelqty = gv_jisiqty - gv_delqty.
    MODIFY gl_lips TRANSPORTING ndelqty.
  ENDLOOP.

* 납품미지정재고에 헤더에 있는 미지정재고 수량을 할당
  READ TABLE gl_lips WITH KEY chk = 'X'.
  LOOP AT xt_nasg WHERE item1 = gl_lips-item1
                   AND labst > 0.
    IF gl_lips-ndelqty < xt_nasg-labst.
      xt_nasg-delqty = gl_lips-ndelqty.
      MODIFY xt_nasg.
    ELSE.
      xt_nasg-delqty = xt_nasg-labst.
      MODIFY xt_nasg.
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
  IF gl_lips-length > 0.

    LOOP AT xt_nasg.

*  CALL FUNCTION 'Z_LE_GET_BATCH_CHARACTERISTIC'
*    EXPORTING
*      i_object = gl_lips-matnr
*      i_charg  = gl_lips-charg
*      i_atnam  = 'SAP_MILLCA_LENGTH'
*    IMPORTING
*      e_atwrt  = lv_atwrt.


*      IF XT_NASG-LENGTH = GT_LIPS-LENGTH AND
*         XT_NASG-FACTOR = GT_LIPS-FACTOR.
      IF xt_nasg-length = gl_lips-length.
        IF xt_nasg-delqty IS INITIAL.
          CLEAR : xt_nasg-factor1.
          MODIFY xt_nasg.

* Factor뱃치일경우 재고 조장수가 납품조장수보다 많을 경우
* 납품조장수 기준으로 디폴트값 셋팅
        ELSEIF xt_nasg-factor > gl_lips-factor.
          xt_nasg-factor1 = gl_lips-factor.
          MODIFY xt_nasg.
        ENDIF.
* 실제 조장수가 소수점을 가진 경우 소수점 절사
        IF xt_nasg-factor1 <> 1.
          xt_nasg-factor1 = floor( xt_nasg-factor1 ).
          IF xt_nasg-factor1 < 1.
            CLEAR : xt_nasg-delqty.
          ENDIF.
          MODIFY xt_nasg.
        ENDIF.
      ELSE.
        CLEAR : xt_nasg-factor1, xt_nasg-delqty.
        MODIFY xt_nasg.
      ENDIF.
* 같은 재고가 있다하더라도 미지정 재고 수량이 0이면 디폴트값은 0
      IF gl_lips-ndelqty = 0.
        CLEAR : xt_nasg-factor1, xt_nasg-delqty.
        MODIFY xt_nasg.
      ENDIF.

* C20081010_41314 BCKOO
* 081014
* 전선 조장 제품 디폴트 지정 대상수량을 조장의 배수 값으로 변경
* 일부 수량 재조 지정시 디폴프 지정대상수량은 납품수량보다 같거나 작아야
* 함
      DATA : lv_delqty LIKE xt_nasg-delqty.
      DATA : lv_length LIKE xt_nasg-length.
      DATA : lv_factor LIKE xt_nasg-factor.

      lv_delqty = xt_nasg-length * xt_nasg-factor1.
      IF lv_delqty > xt_nasg-delqty.
        DO.
          xt_nasg-factor1 = xt_nasg-factor1 - 1.
          lv_delqty = xt_nasg-length * xt_nasg-factor1.
          IF lv_delqty <= xt_nasg-delqty OR xt_nasg-factor1 <= 0.
            xt_nasg-delqty = lv_delqty.
            MODIFY xt_nasg.
            EXIT.
          ENDIF.
        ENDDO.
*        lv_factor = xt_nasg-delqty / xt_nasg-length.
*        lv_factor = ceil( lv_factor ).
*        xt_nasg-factor1 = lv_factor.
*        xt_nasg-delqty = xt_nasg-length * lv_factor.
*        modify xt_nasg.
      ELSE.
        xt_nasg-delqty = xt_nasg-length * xt_nasg-factor1.
        MODIFY xt_nasg.
      ENDIF.

    ENDLOOP.

    SORT xt_nasg BY delqty DESCENDING charg.
  ENDIF.
*  ENDIF.
* 20070613

  gt_lips[] = gl_lips[].

* 접기일때, 하위품목을 없앤다
  LOOP AT gt_lips WHERE icon1 = c_icon1.
    DELETE gt_lips WHERE item1  = gt_lips-item1
                     AND sub    = '2'.
  ENDLOOP.

* 접기에서 데이타 집계
  LOOP AT gt_lips WHERE icon1 = c_icon1.
    CLEAR: gv_jisiqty, gv_delqty.
    LOOP AT gl_lips WHERE item1 = gt_lips-item1.
*      ADD gl_lips-jisiqty TO gv_jisiqty.
      ADD gl_lips-delqty  TO gv_delqty.
    ENDLOOP.

*    gt_lips-jisiqty = gv_jisiqty.
    gt_lips-delqty  = gv_delqty.
    MODIFY gt_lips TRANSPORTING delqty .
  ENDLOOP.

  IF p_kostk = 'C'.
    p_kostk_t = '피킹완료'.
  ELSE.
    p_kostk_t = '피킹미완료'.

    LOOP AT SCREEN.
      CASE screen-name .
        WHEN 'P_WADAT_IST'.
          screen-input = 0.
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

  IF s_vstel-low >= 'M600' AND s_vstel-low <= 'M799'.

    DATA : l_sernp  LIKE marc-sernp VALUE ' '.
    DATA : lt_ser01 LIKE ser01 OCCURS 0 WITH HEADER LINE.
    DATA : l_posnr  LIKE lips-posnr.

    SELECT *
    INTO   TABLE lt_ser01
    FROM   ser01
    WHERE  lief_nr = gt_lips-vbeln.

    SORT lt_ser01 BY posnr.

    LOOP AT gt_lips.
      SELECT SINGLE xchpf FROM mara
      INTO   l_sernp
      WHERE  matnr = gl_lips-matnr
      AND    xchpf = 'X'.
* 배치번호 사용유무 체크 / + SRM2202-09416 - 자재그루핑 추가
      IF sy-subrc = 0 .
        SELECT SINGLE sernp matgr FROM marc
        INTO   (l_sernp, gt_lips-matgr)
        WHERE  matnr = gl_lips-matnr
        AND    werks = gl_lips-werks
        AND    sernp <> ' '.
* 일련번호 사용유무 체크
        IF sy-subrc = 0.
          SELECT posnr INTO l_posnr
          FROM   lips
          WHERE  vbeln = gt_lips-vbeln
          AND    uecha = gt_lips-posnr.
            READ TABLE lt_ser01 WITH KEY posnr = l_posnr.
            IF sy-subrc <> 0.
              g_check = 'X'.
            ENDIF.
          ENDSELECT.
        ENDIF.
* SRM2202-09416 자재그루핑 필드 추가
      ELSEIF gl_lips-werks = '3602'. "배치사용 안하고 플랜트3602
        SELECT SINGLE matgr FROM marc
        INTO   gt_lips-matgr
        WHERE  matnr = gl_lips-matnr
        AND    werks = gl_lips-werks.
* SRM2202-09416
      ENDIF.
      MODIFY gt_lips TRANSPORTING matgr. " SRM2202-09416
    ENDLOOP.
    CLEAR : l_sernp,l_posnr,lt_ser01,lt_ser01[].
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
FORM get_so_characteristic .
  DATA: pv_ebeln LIKE ekpo-ebeln.
  DATA: pv_ebelp LIKE ekpo-ebelp,
        lv_atinn TYPE atinn.

  DATA: ls_return TYPE bapiret2_t.
  DATA: lt_char   LIKE e1cuval OCCURS 0 WITH HEADER LINE.
  DATA: pv_length LIKE zppt0001-mgvrg.

  IF p_new = 'X'.

**특성값 컨버전
*    CALL FUNCTION 'CONVERSION_EXIT_ATINN_INPUT'
*      EXPORTING
*        input  = 'ZBT_AA_GRADE'
*      IMPORTING
*        output = lv_atinn.

    PERFORM get_other_data_collectively.

    LOOP AT gl_lips WHERE sub = '1'.
      IF gt_likp-lfart = 'NL'.
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

        SELECT SINGLE waers
          INTO gl_lips-waerk
          FROM mseg
         WHERE ebeln = gl_lips-vgbel
           AND ebelp = gl_lips-vgpos.
      ELSE.
        READ TABLE gt_ords INTO DATA(wa_ords)
                           WITH KEY vbeln = gl_lips-vgbel
                                    posnv = gl_lips-vgpos
                                    BINARY SEARCH.
        IF sy-subrc = 0.
*___조장
          READ TABLE gt_ordvals INTO DATA(wa_ovals)
                                WITH KEY objek = wa_ords-objek
                                         atnam = so_length
                                         BINARY SEARCH.
          IF sy-subrc = 0.
            gl_lips-length = wa_ovals-atwrt.
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

**___소재 등급
*          READ TABLE gt_ordvals INTO wa_ovals
*                                WITH KEY objek = wa_ords-objek
*                                         atnam = so_grade
*                                         BINARY SEARCH.
*          IF sy-subrc = 0.
**            GL_LIPS-GRADE = WA_OVALS-ATWRT.
*            SELECT SINGLE atwtb INTO @gl_lips-grade
*              FROM cawnt
*             WHERE atinn = @lv_atinn
*               AND atzhl = @wa_ovals-atwrt
*               AND spras = @sy-langu.
*          ENDIF.

        ENDIF.

        SELECT SINGLE waerk
          INTO gl_lips-waerk
          FROM vbap
         WHERE vbeln = gl_lips-vgbel
           AND posnr = gl_lips-vgpos.
      ENDIF.

*   조장수
      IF NOT gl_lips-length IS INITIAL.
        gl_lips-factor = gl_lips-jisiqty / gl_lips-length.
      ENDIF.

      MODIFY gl_lips.
    ENDLOOP.
  ELSE.
    LOOP AT gl_lips WHERE sub = '1'.
      IF gt_likp-lfart = 'NL'.
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
        REFRESH: gt_char. CLEAR: gt_char.
        PERFORM get_characteristic(zler0001) TABLES gt_char
                                   USING gl_lips-vgbel
                                         gl_lips-vgpos
                                         gl_lips-werks
                                         gl_lips-matnr.
        IF NOT gt_char[] IS INITIAL.
* 조장
          READ TABLE gt_char WITH KEY atnam = so_length.
          IF sy-subrc = 0.
            gl_lips-length = gt_char-atwrt.
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

        SELECT SINGLE waerk INTO gl_lips-waerk
        FROM vbap
           WHERE vbeln = gl_lips-vgbel
             AND posnr = gl_lips-vgpos.
      ENDIF.

* 조장수
      IF NOT gl_lips-length IS INITIAL.
        gl_lips-factor = gl_lips-jisiqty / gl_lips-length.
      ENDIF.

      MODIFY gl_lips.
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
FORM get_status_lips .

  wa_lips[] = gl_lips[].
  LOOP AT gl_lips.
    IF gl_lips-uecha IS INITIAL.
      gl_lips-sub   = '1'.
      gl_lips-item1 = gl_lips-posnr.
      READ TABLE wa_lips WITH KEY uecha = gl_lips-posnr.
      IF sy-subrc = 0.
        gl_lips-icon1 = c_icon1.
      ENDIF.
    ELSE.
      gl_lips-sub   = '2'.
      gl_lips-item1 = gl_lips-uecha.
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

    MODIFY gl_lips.
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
FORM collaps_or_expand .

  IF save_ok = 'EXPD'.
    i_cursor_line = tc02-current_line + i_cursor_line - 1.
  ELSEIF save_ok = 'EXPD1'.
    i_cursor_line = tc12-current_line + i_cursor_line - 1.
  ENDIF.

  READ TABLE gt_lips INDEX i_cursor_line.

  CASE g_cursor_field.
    WHEN 'GT_LIPS-ICON1'.
      IF     gt_lips-icon1 = '@3S@'.        "EXPAND
        gl_lips-icon1 = c_icon2.
        MODIFY gl_lips TRANSPORTING icon1
            WHERE vbeln = gt_lips-vbeln
              AND posnr = gt_lips-posnr
              AND sub   = '1'.
      ELSEIF gt_lips-icon1 = '@3T@'.        "COLLAPSE
        gl_lips-icon1 = c_icon1.
        MODIFY gl_lips TRANSPORTING icon1
            WHERE vbeln = gt_lips-vbeln
              AND posnr = gt_lips-posnr
              AND sub   = '1'.
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
FORM modify_screen_sub_1 .

  IF gt_lips-chk = 'X'.
    LOOP AT SCREEN.
      CASE screen-name .
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

          screen-intensified = 1.

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
  IF gt_lips-length IS INITIAL.
    LOOP AT SCREEN.
      CASE screen-name .
        WHEN 'GT_LIPS-FACTOR'.
          screen-input  = 0.
      ENDCASE.
      MODIFY SCREEN.
    ENDLOOP.
  ENDIF.

* 리드프레임은 SHIPPING NO 입력가능
  IF gt_lips-lgort = '3501' .
    LOOP AT SCREEN.
      CASE screen-name.
        WHEN 'GT_LIPS-SHIPPING_NO'.
          screen-input  = 1.
      ENDCASE.
      MODIFY SCREEN.
    ENDLOOP.
  ENDIF.

*-{자체개선101435-추가
*__미지정재고 수량 0일때 조장수 및 납품지시수량 변경 금지
  IF gt_lips-ndelqty = 0.
    LOOP AT SCREEN.
      CASE screen-name.
        WHEN 'GT_LIPS-FACTOR' OR 'GT_LIPS-JISIQTY'.
          screen-input = 0.
      ENDCASE.
      MODIFY SCREEN.
    ENDLOOP.
  ENDIF.
*-}자체개선101435_2015.11.03

*{ SRM2202-09416 - s   플랜트3602시에만 자재그루핑(형식명 필드) 보여주기
  DATA : lv_werks LIKE lips-werks.

  SELECT SINGLE werks
    INTO lv_werks FROM lips
   WHERE vbeln = gt_likp-vbeln.

  IF lv_werks NE '3602'.
    PERFORM hide_tc TABLES tc12-cols
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
FORM modify_screen_sub_2 .

  LOOP AT SCREEN.
    CASE screen-name .
      WHEN 'GT_LIPS-CHK'.
        screen-input  = 0.
        screen-active = 0.
      WHEN 'GT_LIPS-JISIQTY' OR 'GT_LIPS-LFIMG' OR
           'GT_LIPS-FACTOR'.
        screen-input  = 0.
        screen-invisible = 1.
      WHEN 'GT_LIPS-VGBEL' OR 'GT_LIPS-VGPOS' OR
           'GT_LIPS-MIGUL' OR 'GT_LIPS-LFIMG' OR
           'GT_LIPS-UEBTO' OR 'GT_LIPS-JISIQTY' OR
           'GT_LIPS-LENGTH' OR 'GT_LIPS-FACTOR' OR
           'GT_LIPS-AVQTY'  OR
           'GT_LIPS-PACKAGING_CAT' OR 'GT_LIPS-PACKAGING' OR
           'GT_LIPS-WAERK' OR 'GT_LIPS-SHIPPING_NO' OR
           'GT_LIPS-NDELQTY'.
        screen-invisible = 1.
    ENDCASE.
    MODIFY SCREEN.
  ENDLOOP.

  IF gt_lips-posnr IS INITIAL.
    LOOP AT SCREEN.
      CASE screen-name .
        WHEN 'GT_LIPS-POSNR'.
          screen-invisible = 1.
      ENDCASE.
      MODIFY SCREEN.
    ENDLOOP.
  ENDIF.

*{ SRM2202-09416 - s   플랜트3602시에만 자재그루핑(형식명 필드) 보여주기
  DATA : lv_werks LIKE lips-werks.

  SELECT SINGLE werks
    INTO lv_werks FROM lips
   WHERE vbeln = gt_likp-vbeln.

  IF lv_werks NE '3602'.
    PERFORM hide_tc TABLES tc12-cols
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
FORM get_jisiqty_delqty_modi .

*/ 지시수량(jisiqty): 현재납품수량,
*  지정수량(delqty) : 배치사용(배치지정수량), 배치미사용(포장수량)

*/ 배치사용
  LOOP AT gl_lips. " WHERE xchpf = 'X'.
    IF gl_lips-sub = '1'.
      gl_lips-jisiqty = gl_lips-lfimg.
    ELSE.
      gl_lips-jisiqty = gl_lips-lfimg.
      gl_lips-delqty  = gl_lips-lfimg.
    ENDIF.
    gl_lips-lfimg    = 0.
    MODIFY gl_lips TRANSPORTING lfimg delqty jisiqty.
  ENDLOOP.

*/ 배치미사용-일반재고
  LOOP AT gl_lips WHERE xchpf = ' '
                    AND sobkz = ' '.
    SELECT SUM( vemng ) INTO gl_lips-delqty FROM vepo
      WHERE vbeln = gl_lips-vbeln
        AND posnr = gl_lips-posnr.

    MODIFY gl_lips TRANSPORTING delqty.
  ENDLOOP.

*/ 배치미사용-특별재고
  DATA: lv_sonum LIKE vepo-sonum.
  LOOP AT gl_lips WHERE xchpf = ' '
                    AND sobkz = 'E'.
    CONCATENATE gl_lips-vgbel gl_lips-vgpos INTO lv_sonum.

    SELECT SUM( vemng ) INTO gl_lips-delqty FROM vepo
      WHERE vbeln = gl_lips-vbeln
        AND posnr = gl_lips-posnr
        AND sonum = lv_sonum.

    MODIFY gl_lips TRANSPORTING delqty.
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
FORM get_migul_lfimg .

  wa_lips[] = gl_lips[].

  LOOP AT gl_lips WHERE sub = '1'.
    CLEAR: gv_lfimg, gv_kwmeng, gv_lfimg1,gv_avalqty, gv_lfimg,
           gv_lfimg1, gv_lfimg2, gv_qty1, gv_qty2, gv_qty3,
           gv_labst, gv_labst1, gv_labst2, gv_overqty.
********************// 1.가용재고 수량 ***********************
* 현재고수량
    IF gl_lips-sobkz <> 'E'.
      PERFORM current_qty USING gv_avalqty.
    ELSE.
      PERFORM current_qty_e USING gv_avalqty.
    ENDIF.

* 납품생성수량 (GI 안된것).
    IF gl_lips-sobkz <> 'E'.
      PERFORM no_gi_delivery USING gv_labst.
    ELSE.
      PERFORM no_gi_delivery_e USING gv_labst.
    ENDIF.

* 현재 납품문서의 납품수량
    PERFORM own_itself_qty TABLES wa_lips
                           USING gv_lfimg.

* < 가용재고 수량 >
    gl_lips-avqty = gv_avalqty - gv_labst + gv_lfimg.

* 만약, 가용재고수량이 납품수량보다 작으면,
* 가용재고수량은 납품수량으로 한다.
    IF gl_lips-avqty < gl_lips-jisiqty.
      gl_lips-avqty = gl_lips-jisiqty.
    ENDIF.
*****************// 2.미결수량: *******************************
*   SALES ORDER 수량 - 납품수량 합 + 현재 납품문서의 납품수량
* SALES ORDER 수량
    PERFORM sales_order_qty USING gv_kwmeng.

* SALES ORDER 로 생성된 납품수량 합
    PERFORM deliveri_qty_sum USING gv_lfimg1.

* < 미결수량 >
    gl_lips-migul = gv_kwmeng  -  gv_lfimg1 + gv_lfimg.

****************// 3.납품가능량 *******************************
* 초과허용수량
    gv_overqty = ( gv_kwmeng * gl_lips-uebto ) / 100.
    IF gl_lips-uebtk = 'X'.  "무제한허용
      gl_lips-lfimg = gl_lips-avqty .
    ELSE.
      gv_qty2 = gl_lips-migul + gv_overqty.
      IF gv_qty2 > gl_lips-avqty.
        gl_lips-lfimg = gl_lips-avqty .
      ELSE.
        gl_lips-lfimg = gv_qty2.
      ENDIF.
    ENDIF.

    MODIFY gl_lips TRANSPORTING lfimg avqty migul.
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
FORM current_qty  USING    p_qty.

  IF gl_lips-lgort = ' '.
    SELECT SINGLE SUM( labst ) INTO p_qty FROM mard
      WHERE matnr = gl_lips-matnr
        AND werks = gl_lips-werks.
  ELSE.
    SELECT SINGLE labst INTO p_qty FROM mard
      WHERE matnr = gl_lips-matnr
        AND werks = gl_lips-werks
        AND lgort = gl_lips-lgort.
  ENDIF.

ENDFORM.                    " current_qty
*&---------------------------------------------------------------------*
*&      Form  current_qty_e
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GV_AVALQTY  text
*----------------------------------------------------------------------*
FORM current_qty_e  USING    p_qty.

  IF gl_lips-lgort = ' '.
    SELECT SINGLE SUM( kalab ) INTO p_qty FROM mska
      WHERE matnr = gl_lips-matnr
        AND werks = gl_lips-werks
*      AND lgort = gl_lips-lgort
        AND sobkz = 'E'
        AND vbeln = gl_lips-vgbel
        AND posnr = gl_lips-vgpos.
  ELSE.
    SELECT SINGLE SUM( kalab ) INTO p_qty FROM mska
      WHERE matnr = gl_lips-matnr
        AND werks = gl_lips-werks
        AND lgort = gl_lips-lgort
        AND sobkz = 'E'
        AND vbeln = gl_lips-vgbel
        AND posnr = gl_lips-vgpos.
  ENDIF.

ENDFORM.                    " current_qty_e
*&---------------------------------------------------------------------*
*&      Form  no_gi_delivery
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GV_LABST  text
*----------------------------------------------------------------------*
FORM no_gi_delivery  USING    p_labst.

  SELECT SUM( p~lfimg )
    INTO gv_labst1
    FROM lips AS p
*   INNER JOIN VBUK AS K
*      ON P~VBELN = K~VBELN
   INNER JOIN likp AS t
      ON p~vbeln = t~vbeln
   WHERE p~werks = gl_lips-werks
     AND p~lgort = gl_lips-lgort
     AND p~matnr = gl_lips-matnr
     AND p~sobkz = gl_lips-sobkz
     AND t~lfart IN r_lfart
     AND t~wbstk <> 'C'.

  SELECT SUM( p~lfimg )
    INTO gv_labst2
    FROM lips AS p
*   INNER JOIN VBUK AS K
*      ON P~VBELN = K~VBELN
   INNER JOIN likp AS t
      ON p~vbeln = t~vbeln
   WHERE p~werks = gl_lips-werks
     AND p~lgort = ' '
     AND p~matnr = gl_lips-matnr
     AND p~sobkz = gl_lips-sobkz
     AND t~lfart IN r_lfart
     AND t~wbstk <> 'C'.

  p_labst = gv_labst1 + gv_labst2.


ENDFORM.                    " no_gi_delivery
*&---------------------------------------------------------------------*
*&      Form  no_gi_delivery_e
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GV_LABST  text
*----------------------------------------------------------------------*
FORM no_gi_delivery_e  USING    p_labst.

  SELECT SUM( p~lfimg )
    INTO gv_labst1
    FROM lips AS p
*   INNER JOIN VBUK AS K
*      ON P~VBELN = K~VBELN
   INNER JOIN likp AS t
      ON p~vbeln = t~vbeln
   WHERE p~werks = gl_lips-werks
     AND p~lgort = gl_lips-lgort
     AND p~matnr = gl_lips-matnr
     AND p~sobkz = gl_lips-sobkz
     AND p~vgbel = gl_lips-vgbel
     AND p~vgpos = gl_lips-vgpos
     AND t~lfart IN r_lfart
     AND t~wbstk <> 'C'.

  SELECT SUM( p~lfimg )
    INTO gv_labst2
    FROM lips AS p
*   INNER JOIN VBUK AS K
*      ON P~VBELN = K~VBELN
   INNER JOIN likp AS t
      ON p~vbeln = t~vbeln
   WHERE p~werks = gl_lips-werks
     AND p~lgort = ' '
     AND p~matnr = gl_lips-matnr
     AND p~sobkz = gl_lips-sobkz
     AND p~vgbel = gl_lips-vgbel
     AND p~vgpos = gl_lips-vgpos
     AND t~lfart IN r_lfart
     AND t~wbstk <> 'C'.

  p_labst = gv_labst1 + gv_labst2.


ENDFORM.                    " no_gi_delivery_e
*&---------------------------------------------------------------------*
*&      Form  werks_matnr_qty
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GV_LFIMG2  text
*----------------------------------------------------------------------*
FORM werks_matnr_qty  USING    p_lfimg2.

  IF gl_lips-lgort = ' '.
    SELECT SINGLE SUM( labst ) INTO p_lfimg2 FROM mard
      WHERE matnr = gl_lips-matnr
        AND werks = gl_lips-werks.
  ELSE.
    SELECT SINGLE SUM( labst ) INTO p_lfimg2 FROM mard
      WHERE matnr = gl_lips-matnr
        AND werks = gl_lips-werks
        AND lgort = gl_lips-lgort.
  ENDIF.

ENDFORM.                    " werks_matnr_qty
*&---------------------------------------------------------------------*
*&      Form  werks_matnr_qty_e
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GV_LFIMG2  text
*----------------------------------------------------------------------*
FORM werks_matnr_qty_e  USING    p_lfimg2.

  SELECT SINGLE SUM( kalab ) INTO p_lfimg2 FROM mska
    WHERE matnr = gl_lips-matnr
      AND werks = gl_lips-werks
*      AND lgort = gl_lips-lgort
      AND sobkz = 'E'
      AND vbeln = gl_lips-vgbel
      AND posnr = gl_lips-posnr.


ENDFORM.                    " werks_matnr_qty_e
*&---------------------------------------------------------------------*
*&      Form  own_itself_qty
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_WA_LIPS  text
*      -->P_GV_LFIMG  text
*----------------------------------------------------------------------*
FORM own_itself_qty  TABLES   pt_lips LIKE gl_lips[]
                     USING    p_lfimg.

  LOOP AT pt_lips WHERE item1 = gl_lips-item1.
    ADD  pt_lips-jisiqty   TO p_lfimg.
  ENDLOOP.


ENDFORM.                    " own_itself_qty
*&---------------------------------------------------------------------*
*&      Form  sales_order_qty
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GV_KWMENG  text
*----------------------------------------------------------------------*
FORM sales_order_qty  USING    p_kwmeng.

  IF gt_likp-lfart = 'NL'.
    SELECT SINGLE menge INTO p_kwmeng   FROM ekpo
      WHERE ebeln = gl_lips-vgbel
        AND ebelp = gl_lips-vgpos.
  ELSE.
    SELECT SINGLE kwmeng INTO p_kwmeng  FROM vbap
       WHERE vbeln = gl_lips-vgbel
         AND posnr = gl_lips-vgpos.
  ENDIF.

ENDFORM.                    " sales_order_qty
*&---------------------------------------------------------------------*
*&      Form  deliveri_qty_sum
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GV_LFIMG1  text
*----------------------------------------------------------------------*
FORM deliveri_qty_sum  USING    p_lfimg1.

  SELECT SUM( p~lfimg ) INTO p_lfimg1
     FROM lips AS p INNER JOIN likp AS k
       ON p~vbeln = k~vbeln
     WHERE p~vgbel = gl_lips-vgbel
       AND p~vgpos = gl_lips-vgpos
       AND k~lfart IN r_lfart.


ENDFORM.                    " deliveri_qty_sum
*---------------------------------------------------------------------*
*&      Form  display_assg_nasg
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM display_assg_nasg .
  DATA: lv_venum   LIKE vekp-venum.

  REFRESH: "CONTROL 'TC02' FROM SCREEN '0200',
           "CONTROL 'TC12' FROM SCREEN '0300',
           CONTROL 'TC03' FROM SCREEN '0200',
           CONTROL 'TC13' FROM SCREEN '0300',
           CONTROL 'TC04' FROM SCREEN '0200',
           CONTROL 'TC14' FROM SCREEN '0300'.

  CLEAR: gt_assg[], gt_assg, gt_nasg[], gt_nasg.
  READ TABLE gl_lips WITH KEY chk = 'X'.
  IF sy-subrc = 0.
    p_qiqty = gl_lips-qiqty.
    p_vrkme = gl_lips-vrkme.

* 중복지정
    gl_vepo-icon2 = ' '.
    MODIFY gl_vepo TRANSPORTING icon2 WHERE icon2 <> ' '.

    wa_vepo[] = gl_vepo[].
    LOOP AT gl_vepo .
      LOOP AT wa_vepo WHERE exidv = gl_vepo-exidv
                        AND item1 <> gl_vepo-item1.
      ENDLOOP.
      IF sy-subrc = 0.
        gl_vepo-icon2 = 'D'.
        MODIFY gl_vepo TRANSPORTING icon2.
      ENDIF.
    ENDLOOP.

* 중복지정
    LOOP AT gl_vepo .
      CLEAR: gv_flag.
      LOOP AT wa_vepo WHERE exidv = gl_vepo-exidv  AND
                          ( matnr <> gl_vepo-matnr OR
                            werks <> gl_vepo-werks OR
                            lgort <> gl_vepo-lgort OR
                            sobkz <> gl_vepo-sobkz ).
        gv_flag = 'X'.
        EXIT.
      ENDLOOP.
      IF gv_flag = 'X'.
        gl_vepo-icon2 = 'D'.
        MODIFY gl_vepo.
      ENDIF.
    ENDLOOP.

    LOOP AT gl_vepo WHERE matnr = gl_lips-matnr
                      AND sobkz = gl_lips-sobkz
                      AND sonum = gl_lips-sonum
                      AND place = 'A'
                      AND item1 = gl_lips-item1.
      MOVE-CORRESPONDING gl_vepo TO gt_assg.
      COLLECT gt_assg.
    ENDLOOP.

    LOOP AT gl_vepo WHERE matnr = gl_lips-matnr
                      AND sobkz = gl_lips-sobkz
                      AND sonum = gl_lips-sonum
                      AND place = 'N'.
      MOVE-CORRESPONDING gl_vepo TO gt_nasg.
      COLLECT gt_nasg.
    ENDLOOP.
  ENDIF.

  LOOP AT gl_lips WHERE sobkz <> ' '.
    CONCATENATE gl_lips-vgbel gl_lips-vgpos
           INTO gl_lips-sonum.

    CONDENSE gl_lips-sonum.

    MODIFY gl_lips.
  ENDLOOP.

  LOOP AT gt_nasg.
    READ TABLE gl_vepo WITH KEY exidv = gt_nasg-exidv.

    IF gl_vepo-extnl = 'X'.
      SELECT SINGLE venum
        INTO lv_venum
        FROM vekp
       WHERE exidv  =  gt_nasg-exidv
         AND status <> '0060'.

      SELECT * INTO CORRESPONDING FIELDS OF TABLE et_vekp
         FROM vekp
        WHERE uevel = lv_venum.
    ELSE.
      SELECT * INTO CORRESPONDING FIELDS OF TABLE et_vekp
         FROM vekp
        WHERE exidv = gt_nasg-exidv.
    ENDIF.

    CHECK NOT et_vekp[] IS INITIAL.

    SELECT * INTO CORRESPONDING FIELDS OF TABLE et_vepo
       FROM vepo
        FOR ALL ENTRIES IN et_vekp
      WHERE venum = et_vekp-venum.

    DELETE et_vepo WHERE matnr = ' '.

    CLEAR: gv_flag.
    LOOP AT et_vepo.
      READ TABLE gl_lips WITH KEY matnr = et_vepo-matnr
                                  sonum = et_vepo-sonum.
      IF sy-subrc <> 0.
        gv_flag = 'X'.
        EXIT.
      ENDIF.
    ENDLOOP.
    IF gv_flag = 'X'.
      gt_nasg-icon3 = c_icon3.
      MODIFY gt_nasg TRANSPORTING icon3.
    ENDIF.
  ENDLOOP.

  SORT gt_nasg BY exidv.
  SORT gt_assg BY exidv.



ENDFORM.                    " display_assg_nasg
*&---------------------------------------------------------------------*
*&      Form  move_left_200
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM move_left_200 .

  READ TABLE gl_lips WITH KEY chk = 'X'.
  gv_item1 = gl_lips-item1.

*/ Error check
  PERFORM error_check_before_move_1.

*/ Lock HU
  CLEAR: gv_flag.
  LOOP AT gt_nasg WHERE chk = 'X'.
    PERFORM enqueue_hu USING gt_nasg-exidv.
  ENDLOOP.
  IF gv_flag = 'X'.
    LEAVE SCREEN.
  ENDIF.

*/ 상단의 지정수량 반영
  PERFORM assign_gl_lips_delqty_200.

  PERFORM display_assg_nasg.


ENDFORM.                    " move_left_200
*&---------------------------------------------------------------------*
*&      Form  move_right_200
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM move_right_200 .

  READ TABLE gl_lips WITH KEY chk = 'X'.
  CLEAR: gv_flag.
  IF gl_lips-fixed = 'X'.
    MESSAGE i000 WITH
     '상위품목에 이미 배치지정 되었습니다'.
    gv_flag = 'X'.
  ENDIF.
  IF gv_flag = 'X'.
    LEAVE SCREEN.
  ENDIF.

  LOOP AT gt_assg WHERE chk = 'X'.
    PERFORM dequeue_hu USING gt_assg-exidv.
  ENDLOOP.

*/ 상단의 지정수량 반영
  PERFORM assign_gl_lips_delqty_200_1.

  PERFORM display_assg_nasg.

ENDFORM.                    " move_right_200
*&---------------------------------------------------------------------*
*&      Form  error_check_before_move_1
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM error_check_before_move_1 .

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
  CLEAR: gv_flag.
  IF gl_lips-fixed = 'X'.
    MESSAGE i000 WITH
     '상위품목에 이미 배치지정 되었습니다'.
    gv_flag = 'X'.
  ENDIF.
  IF gv_flag = 'X'.
    LEAVE SCREEN.
  ENDIF.
*/
  CLEAR: gv_flag.
  IF gl_lips-ndelqty = 0.
    MESSAGE i001 WITH '모두 지정되었습니다'.
    gv_flag = 'X'.
  ENDIF.

  IF gv_flag = 'X'.
    LEAVE SCREEN.
  ENDIF.

*/ 지정할수 없는 품목이 있습니다.
*  PERFORM check_cannot_assign.

*/ 포장수량이 지시수량을 초과할수 없다.
  PERFORM check_over_assign.



ENDFORM.                    " error_check_before_move_1
*&---------------------------------------------------------------------*
*&      Form  make_data_hu_NO
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM make_data_hu_no .

*/ select ~ lips
*  SELECT * INTO CORRESPONDING FIELDS OF TABLE gl_lips
*    FROM lips
*   WHERE vbeln = p_vbeln.

  SELECT a~*, c~name1 INTO CORRESPONDING FIELDS OF TABLE @gl_lips
    FROM lips as a inner join likp as b
                    on a~vbeln eq b~vbeln
                   inner join kna1 as c
                    on b~kunag eq c~kunnr
   WHERE a~vbeln = @p_vbeln.

*/ 납품유형이 'NL'일 경우 STO의 초과납품 무한초과 납품 허용값을 찾아서
*/ 적용.
  DATA : lv_lfart LIKE likp-lfart.

  SELECT SINGLE lfart INTO lv_lfart
  FROM   likp
  WHERE vbeln = p_vbeln.
  IF lv_lfart = 'NL'.
    LOOP AT gl_lips.
      SELECT SINGLE uebto uebtk
      INTO   (gl_lips-uebto, gl_lips-uebtk)
      FROM   ekpo
      WHERE  ebeln = gl_lips-vgbel
      AND    ebelp = gl_lips-vgpos.
      MODIFY gl_lips.
    ENDLOOP.
    CLEAR lv_lfart.
  ENDIF.


*/ 품목상태 및 일련번호(기계번호)
  PERFORM get_status_lips.

*/ 지시수량(jisiqty): 현재납품수량,
*  지정수량(delqty) : 배치사용(배치지정수량), 배치미사용(포장수량)
*  PERFORM get_jisiqty_delqty.
  PERFORM get_jisiqty_delqty.

*/ 미결수량, 납품가능량
  PERFORM get_migul_lfimg.

*/ 제품특성
  PERFORM get_so_characteristic.

*/
  PERFORM get_xl_nasg.

*  단위 변환을 위 FORM문에서 처리하고 아래는 막음 by J.Y.Lee 05/31/2011
*  PERFORM CONVERSION_UNIT_NASG_300.

*/
  PERFORM get_xl_assg.

*/ 단위환산: 판매단위와 재고단위가 다를 경우.
  PERFORM conversion_unit_assg_300.
*PERFORM conversion_unit_300.
*/ 지정수량: 배치미사용
  PERFORM get_delqty_300.

  cl_nasg[] = xl_nasg[].
  cl_assg[] = xl_assg[].
  CLEAR: cl_lips[], cl_lips.
  LOOP AT gl_lips WHERE sub = '1'.
    MOVE-CORRESPONDING gl_lips  TO cl_lips.
    APPEND cl_lips.
  ENDLOOP.

* 모두 지정되었는지 점검: 모두 지정되엇으면, 피킹 가능
  PERFORM check_picking_possibe.


ENDFORM.                    " make_data_hu_NO
*&---------------------------------------------------------------------*
*&      Form  get_xbatch
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_xbatch .

  REFRESH: "CONTROL 'TC02' FROM SCREEN '0200',
           "CONTROL 'TC12' FROM SCREEN '0300',
           CONTROL 'TC03' FROM SCREEN '0200',
           CONTROL 'TC13' FROM SCREEN '0300',
           CONTROL 'TC04' FROM SCREEN '0200',
           CONTROL 'TC14' FROM SCREEN '0300'.

  CLEAR: xt_assg[], xt_assg, xt_nasg[], xt_nasg.
  READ TABLE gl_lips WITH KEY chk = 'X'.
  CHECK sy-subrc = 0.

  p_qiqty = gl_lips-qiqty.
  p_vrkme = gl_lips-vrkme.

  LOOP AT xl_nasg WHERE item1 = gl_lips-item1
                    AND labst > 0.
    MOVE-CORRESPONDING xl_nasg  TO xt_nasg.

    xt_nasg-delqty = xt_nasg-labst.
    IF NOT xt_nasg-length IS INITIAL.
      xt_nasg-factor  = xt_nasg-labst  / xt_nasg-length.
      xt_nasg-factor1 = xt_nasg-delqty / xt_nasg-length.
    ENDIF.

* 납품미지정재고에 헤더에 있는 미지정재고 수량을 할당
    IF gl_lips-ndelqty < xt_nasg-delqty.
      xt_nasg-delqty = gl_lips-ndelqty.
    ELSE.
      xt_nasg-delqty = xt_nasg-labst.
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

    APPEND xt_nasg.
  ENDLOOP.

  LOOP AT xl_assg WHERE item1 = gl_lips-item1
                    AND labst > 0.
    MOVE-CORRESPONDING xl_assg  TO xt_assg.

    IF NOT xt_assg-length IS INITIAL.
      xt_assg-factor = xt_assg-labst / xt_assg-length.
    ENDIF.

**** S ADD BY HKSEO 20190201 QMS Project
*    IF XT_ASSG-XCHPF IS NOT INITIAL.
*      PERFORM CHECK_PDI_INSPECTION  USING XT_ASSG-MATNR
*                                          XT_ASSG-CHARG
*                                          XT_ASSG-ICON2
*                                          XT_ASSG-PDIDT.
*    ENDIF.
**** E ADD BY HKSEO 20190201 QMS Project

    APPEND xt_assg.
  ENDLOOP.

  SORT xt_assg BY charg.
  SORT xt_nasg BY charg.

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
FORM get_batch_characteristic  USING    p_matnr
                                        p_charg
                                        p_char
                            CHANGING    e_atwrt.

  CALL FUNCTION 'Z_LE_GET_BATCH_CHARACTERISTIC'
    EXPORTING
      i_object = p_matnr
      i_charg  = p_charg
      i_atnam  = p_char
    IMPORTING
      e_atwrt  = e_atwrt.


ENDFORM.                    " get_batch_characteristic
*&---------------------------------------------------------------------*
*&      Form  move_left_300
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM move_left_300 .

*/ ERROR CHECK
  PERFORM error_check_left_300.

*/ 상단의 지정수량 반영
  PERFORM assign_gl_lips_delqty.

*/ 미지정 수량의 감소
  PERFORM decrease_labst TABLES xt_nasg xl_nasg.

*/ 지정 수량의 증가
  PERFORM increase_labst TABLES xt_nasg xl_assg.

*/ 자신에 지정된 수량은 가용수량에서 빼준다.
  LOOP AT xt_nasg WHERE chk = 'X'.
    LOOP AT xl_nasg WHERE matnr = xt_nasg-matnr
                      AND charg = xt_nasg-charg
                      AND item1 <> xt_nasg-item1.
* 080709 BCKOO
* MTO의 경우 기존 재고에다가 지정된 재고의 경우
* 남아있는 MTO재고에다가 -처리를 하기 때문에 수량이 줄어듬
      IF xl_nasg-sobkz <> 'E'.
        xl_nasg-labst = xl_nasg-labst - xt_nasg-delqty.
        MODIFY xl_nasg TRANSPORTING labst.
      ENDIF.

    ENDLOOP.
  ENDLOOP.

*/ 미지정,지정 데이타 발췌
  PERFORM get_xbatch.



ENDFORM.                    " move_left_300
*&---------------------------------------------------------------------*
*&      Form  move_right_300
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM move_right_300 .

*/ 상위품목에 배치지정된거는 데이타 고정
  READ TABLE gl_lips WITH KEY chk = 'X'.
  CLEAR: gv_flag.
  IF gl_lips-fixed = 'X'.
    MESSAGE i000 WITH
     '상위품목에 이미 배치지정 되었습니다'.
    gv_flag = 'X'.
  ENDIF.
  IF gv_flag = 'X'.
    LEAVE SCREEN.
  ENDIF.

*/ 상단의 지정수량 반영
  PERFORM assign_gl_lips_delqty_1.

*/ 지정 수량의 감소
  PERFORM decrease_labst TABLES xt_assg xl_assg.

*/ 미지정 수량의 증가
  PERFORM increase_labst TABLES xt_assg xl_nasg.

*/ 자신에 지정된 수량은 가용수량에서 더해준다.
  LOOP AT xt_assg WHERE chk = 'X'.
    LOOP AT xl_nasg WHERE matnr = xt_assg-matnr
                      AND charg = xt_assg-charg
                      AND item1 <> xt_assg-item1.
      xl_nasg-labst = xl_nasg-labst + xt_assg-delqty.
      MODIFY xl_nasg TRANSPORTING labst.
    ENDLOOP.
  ENDLOOP.


*/ 미지정,지정 데이타 발췌
  PERFORM get_xbatch.


ENDFORM.                    " move_right_300
*&---------------------------------------------------------------------*
*&      Form  GET_BATCH_USE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_batch_use .
*{ 기능개선 91460 - 추가
  DATA: BEGIN OF lt_2100 OCCURS 0,
          aufnr LIKE zppt2100-aufnr,
        END   OF lt_2100.

  DATA: lv_vbeln LIKE mska-vbeln,
        lv_posnr LIKE mska-posnr,
        lv_flag.
*} 기능개선 91460 - 추가

  DATA : lt_data LIKE STANDARD TABLE OF gt_lips.
  CLEAR : lt_data[].

  SELECT * FROM mchb
    WHERE matnr = gl_lips-matnr
      AND werks = gl_lips-werks
      AND lgort = gl_lips-lgort
      AND clabs > 0.
    xl_nasg-item1  = gl_lips-item1.
    xl_nasg-posnr  = gl_lips-posnr.
    xl_nasg-matnr  = gl_lips-matnr.
    xl_nasg-charg  = mchb-charg.
    xl_nasg-vrkme  = gl_lips-vrkme.
    xl_nasg-labst  = mchb-clabs.
    xl_nasg-xchpf  = 'X'.
    xl_nasg-werks = gl_lips-werks.
    COLLECT xl_nasg.
  ENDSELECT.

  lt_data[] = gl_lips[].

" 1. 메인 데이터 조회 (특성값 뷰 제외)
  " 루프 내 매핑 검증을 위해 LIKP의 KUNAG(고객번호) 필드를 포함하여 조회
  SELECT a~item1, a~posnr, a~vrkme, a~werks, a~matnr,
         c~lgort, c~clabs as labst, c~charg,
         b~kunag, " 매핑을 위한 임시 필드
         @abap_true AS xchpf
    FROM @lt_data AS a INNER JOIN likp AS b
                           ON a~vbeln EQ b~vbeln
                       INNER JOIN mchb AS c
                         ON a~matnr EQ c~matnr
                        AND a~werks EQ c~werks
                        AND a~lgort EQ c~lgort
                        AND c~clabs GT 0
                       INNER JOIN mara AS e
                         ON a~matnr EQ e~matnr
   WHERE e~spart EQ '10' "SCR 8.0mm
     AND c~lgort LIKE '34%'
     AND a~lfimg > 0
    INTO TABLE @DATA(lt_main).

  IF lt_main[] IS NOT INITIAL.

    " 2. 특성값(Batch Characteristic) 데이터 별도 조회
    SELECT matnr, charg, atwrt
      FROM zgtsd_cv_get_vcofbatch
       FOR ALL ENTRIES IN @lt_main
     WHERE matnr EQ @lt_main-matnr
       AND charg EQ @lt_main-charg
       AND atnam EQ 'PD_CA_CUSTOMER_CODE'
      INTO TABLE @DATA(lt_batch).

    " 이진 탐색(Binary Search)을 위한 정렬
    SORT lt_batch BY matnr charg.

    " 3. ABAP 루프를 통해 수동 매핑 및 포맷 불일치 해소 (INNER JOIN 효과)
    LOOP AT lt_main ASSIGNING FIELD-SYMBOL(<fs_main>).

      READ TABLE lt_batch INTO DATA(ls_batch)
                          WITH KEY matnr = <fs_main>-matnr
                                   charg = <fs_main>-charg BINARY SEARCH.

      IF sy-subrc EQ 0.
        " 특성값(ATWRT)을 DB 고객번호(KUNAG)와 동등하게 비교하기 위해 10자리(선행 '0' 포함)로 변환
        DATA(lv_atwrt_in) = CONV kunnr( |{ ls_batch-atwrt ALPHA = IN }| ).

        " 포맷을 맞춘 후 값 비교 (불일치 시 해당 행 삭제)
        IF <fs_main>-kunag NE lv_atwrt_in.
          DELETE lt_main.
        ENDIF.
      ELSE.
        " 조인 대상 특성값이 없는 경우 삭제
        DELETE lt_main.
      ENDIF.

    ENDLOOP.
  ENDIF.

  " 4. 최종 결과를 원본 목적지로 전달
  " (CORRESPONDING 구문에 의해 매핑용으로 추가했던 kunag 필드는 자동 제외됨)
  IF lt_main[] IS NOT INITIAL.
    CLEAR : xl_nasg[].
    MOVE-CORRESPONDING lt_main[] TO xl_nasg[].
  ENDIF.

*{기능개선  234896 s/n추가
  LOOP AT xl_nasg.
*    SELECT SINGLE EQUNR
*      INTO XL_NASG-EQUNR
*      FROM EQUI
*      WHERE MATNR = XL_NASG-MATNR
*      AND   CHARGE = XL_NASG-CHARG.

    SELECT SINGLE tagnr
      INTO xl_nasg-equnr
      FROM zppt0001
      WHERE werks = gl_lips-werks
      AND charg = xl_nasg-charg
      AND matnr = xl_nasg-matnr.

    MODIFY xl_nasg. CLEAR : xl_nasg.
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
FORM get_batch_no_use .
*{ 기능개선 91460 - 추가
  DATA: BEGIN OF lt_2100 OCCURS 0,
          aufnr LIKE zppt2100-aufnr,
          vemng LIKE zppt2100-vemng,
          meins LIKE zppt2100-meins,
        END   OF lt_2100.

  DATA: lv_vbeln LIKE mska-vbeln,
        lv_posnr LIKE mska-posnr,
        lv_vemng LIKE zppt2100-vemng,
        lv_meins LIKE zppt2100-meins.
*} 기능개선 91460 - 추가

  xl_nasg-item1  = gl_lips-item1.
  xl_nasg-posnr  = gl_lips-posnr.
  xl_nasg-matnr  = gl_lips-matnr.
  xl_nasg-vrkme  = gl_lips-vrkme.
  SELECT SINGLE labst INTO xl_nasg-labst FROM mard
    WHERE matnr = gl_lips-matnr
      AND werks = gl_lips-werks
      AND lgort = gl_lips-lgort.
*  xl_nasg-labst  = gl_lips-lfimg.
  xl_nasg-xchpf  = ' '.
  COLLECT xl_nasg.

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
FORM get_e_batch_use .
*{ 기능개선 91460 - 추가
  DATA: BEGIN OF lt_2100 OCCURS 0,
          aufnr LIKE zppt2100-aufnr,
        END   OF lt_2100.

  DATA: lv_vbeln LIKE mska-vbeln,
        lv_posnr LIKE mska-posnr,
        lv_sonum LIKE zmmti26m-sonum,
        lv_flag.
*} 기능개선 91460 - 추가

  SELECT * FROM mska
   WHERE matnr = gl_lips-matnr
     AND werks = gl_lips-werks
     AND lgort = gl_lips-lgort
     AND sobkz = gl_lips-sobkz
     AND vbeln = gl_lips-vgbel
     AND posnr = gl_lips-vgpos.

    xl_nasg-item1 = gl_lips-item1.
    xl_nasg-posnr = gl_lips-posnr.
    xl_nasg-matnr = gl_lips-matnr.
    xl_nasg-charg = mska-charg.
    xl_nasg-vrkme = gl_lips-vrkme.
    xl_nasg-labst = mska-kalab.
    xl_nasg-sobkz = mska-sobkz.
    xl_nasg-vgbel = mska-vbeln.
    xl_nasg-vgpos = mska-posnr.
    xl_nasg-xchpf = 'X'.
    COLLECT xl_nasg.

  ENDSELECT.


*{기능개선  234896 s/n추가
  LOOP AT xl_nasg.
*    SELECT SINGLE EQUNR
*      INTO XL_NASG-EQUNR
*      FROM EQUI
*      WHERE MATNR = XL_NASG-MATNR
*      AND   CHARGE = XL_NASG-CHARG.
    SELECT SINGLE tagnr
      INTO xl_nasg-equnr
      FROM zppt0001
      WHERE werks = gl_lips-werks
      AND charg = xl_nasg-charg
      AND matnr = xl_nasg-matnr.


    MODIFY xl_nasg. CLEAR : xl_nasg.
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
FORM get_e_batch_no_use .
*{ 기능개선 91460 - 추가
  DATA: BEGIN OF lt_2100 OCCURS 0,
          aufnr LIKE zppt2100-aufnr,
          vemng LIKE zppt2100-vemng,
          meins LIKE zppt2100-meins,
        END   OF lt_2100.

  DATA: lv_vbeln LIKE mska-vbeln,
        lv_posnr LIKE mska-posnr,
        lv_sonum LIKE zmmti26m-sonum,
        lv_vemng LIKE zppt2100-vemng,
        lv_meins LIKE zppt2100-meins.
*} 기능개선 91460 - 추가

  xl_nasg-item1  = gl_lips-item1.
  xl_nasg-posnr  = gl_lips-posnr.
  xl_nasg-matnr  = gl_lips-matnr.
  xl_nasg-vrkme  = gl_lips-vrkme.
  xl_nasg-sobkz  = gl_lips-sobkz.
  SELECT SINGLE kalab INTO xl_nasg-labst FROM mska
    WHERE matnr = gl_lips-matnr
      AND werks = gl_lips-werks
      AND lgort = gl_lips-lgort
      AND sobkz = gl_lips-sobkz
      AND vbeln = gl_lips-vgbel
      AND posnr = gl_lips-vgpos.

*  xl_nasg-labst  = gl_lips-lfimg.
  xl_nasg-xchpf  = ' '.
  COLLECT xl_nasg.

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
FORM get_xl_nasg .

  CLEAR: xl_nasg[], xl_nasg, xt_nasg[], xt_nasg.

*/ ------> 미지정
  LOOP AT gl_lips WHERE sub = '1'.
    IF gl_lips-sobkz = ' '.
      IF gl_lips-xchpf = 'X'.
*/ 1. 일반재고-배치사용
        PERFORM get_batch_use.
      ELSE.
*/ 2. 일반재고-배치미사용
        PERFORM get_batch_no_use.
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
      IF gl_lips-xchpf = 'X'.
*/ 3. 특별재고-배치사용
        PERFORM get_e_batch_use.
      ELSE.
*/ 4. 특별재고-배치미사용
        PERFORM get_e_batch_no_use.
      ENDIF.
    ENDIF.
    CLEAR: xl_nasg.
  ENDLOOP.

  DATA(lt_for) = xl_nasg[].
  SORT lt_for BY matnr charg werks .
  DELETE ADJACENT DUPLICATES FROM lt_for COMPARING matnr charg werks .
  IF lt_for[] IS NOT INITIAL.

    SELECT * INTO TABLE @DATA(lt_sogr)
      FROM zgtsd_cv_get_vcofbatch
       FOR ALL ENTRIES IN @lt_for
     WHERE matnr = @lt_for-matnr
       AND charg = @lt_for-charg
       AND werks = @lt_for-werks
*       AND LGORT = @LT_FOR-LGORT
       AND atnam = 'PD_CA_GRADE'.
    SORT lt_sogr BY matnr charg werks.

    SELECT a~*
      FROM zgtsd_cv_get_vcofbatch AS a INNER JOIN mara AS b
                                       ON a~matnr EQ b~matnr
                                       AND b~spart EQ '10'
       FOR ALL ENTRIES IN @lt_for
     WHERE a~matnr = @lt_for-matnr
       AND a~charg = @lt_for-charg
       AND a~werks = @lt_for-werks
*       AND LGORT = @LT_FOR-LGORT
       AND a~atnam = 'PD_CA_CUSTOMER_CODE'  "SCR 8.0mm 거래처 Batch Characteristic
      INTO TABLE @DATA(lt_socust).
    SORT lt_socust BY matnr charg werks.

  ENDIF.

*/ BATCH 조장
  LOOP AT xl_nasg.
    CLEAR: gv_length.
    PERFORM get_batch_characteristic
        USING: xl_nasg-matnr xl_nasg-charg
               ba_length
     CHANGING: gv_length.

    xl_nasg-length = gv_length.
*    xl_nasg-delqty = xl_nasg-labst.

*   자재의 기본단위와 판매단위가 다를 경우 다른 납품의 재고지정건이
*   미지정 재고로 표기되는 오류 수정 by J.Y.Lee 05/31/2011
*   Request by 허경도D
    READ TABLE gl_lips WITH KEY item1 = xl_nasg-item1.
    IF sy-subrc = 0.

      IF gl_lips-meins <> gl_lips-vrkme.
        IF gl_lips-umvkz IS NOT INITIAL.
          xl_nasg-length = xl_nasg-length * gl_lips-umvkn / gl_lips-umvkz.
          xl_nasg-labst  = xl_nasg-labst  * gl_lips-umvkn / gl_lips-umvkz.
        ENDIF.
      ENDIF.

*등급
      READ TABLE lt_sogr INTO DATA(ls_gr) WITH KEY matnr = xl_nasg-matnr
                                                   charg = xl_nasg-charg
                                                   werks = xl_nasg-werks BINARY SEARCH.
      IF sy-subrc = 0.
        xl_nasg-grade = ls_gr-grade_t.
      ENDIF.


* 거래처
      READ TABLE lt_socust INTO DATA(ls_cust) WITH KEY matnr = xl_nasg-matnr
                                                       charg = xl_nasg-charg
                                                       werks = xl_nasg-werks BINARY SEARCH.
      IF sy-subrc = 0.
        DATA : lv_kunnr TYPE kna1-name1.
        CLEAR : lv_kunnr.

        lv_kunnr = ls_cust-atwrt.
        lv_kunnr = CONV kunnr( |{ lv_kunnr  ALPHA = IN }| ).

        SELECT SINGLE name1 INTO @DATA(lv_name1)
          FROM kna1
         WHERE kunnr = @lv_kunnr.

        IF lv_name1 IS NOT INITIAL.
          xl_nasg-name1 = lv_name1.
        ENDIF.

      ENDIF.
    ENDIF.

    MODIFY xl_nasg.
  ENDLOOP.

*************************************************
* CSR번호: C2006080801000000259 일련번호 자동지정
* 수정일 : 20060903 수정자: Koo Bon-Chan
* 내역 :
* 납품미지정 재고 추출 로직변경
* 피킹시 MTO, MTS 재고를 구분하여 각기 지정된 재고 수량만 가져옴
* -> 쿼리에 특별재고조건 추가
*************************************************

* 배치사용재고는 다른 납품에 지정된 납품수량을 빼준다
  LOOP AT xl_nasg WHERE xchpf = 'X'.
    CLEAR: gv_labst1.
    READ TABLE gl_lips WITH KEY item1 = xl_nasg-item1.

    SELECT SUM( p~lfimg )
      INTO gv_labst1
      FROM lips AS p
*     INNER JOIN VBUK AS K
*        ON P~VBELN = K~VBELN
     INNER JOIN likp AS a
        ON p~vbeln = a~vbeln
     WHERE p~werks = gl_lips-werks
       AND p~lgort = gl_lips-lgort
       AND p~matnr = gl_lips-matnr
       AND p~charg = xl_nasg-charg
       AND p~vbeln <> gl_lips-vbeln
*       AND a~wbstk <> 'C'                " 가온 소재 SCR 8.0mm 는 Service 출고만 하기 때문에
       AND p~sobkz = gl_lips-sobkz    " 특별재고 지정부분 추가
       AND a~lfart IN ('LF', 'LF4', 'LF7', 'LF8', 'LF9',
                       'LF10', 'NL')     .

    xl_nasg-labst =  xl_nasg-labst - gv_labst1.

    MODIFY xl_nasg.
  ENDLOOP.

* 배치미사용재고는 다른 납품에 지정된 피킹수량을 빼준다
  LOOP AT xl_nasg WHERE xchpf = ' '.
    CLEAR: gv_labst1.
    READ TABLE gl_lips WITH KEY item1 = xl_nasg-item1.
    IF gl_lips-sobkz = 'E'.

    ELSE.
      SELECT SUM( v~rfmng )
        INTO gv_labst1
        FROM vbfa AS v
       INNER JOIN lips AS p
          ON v~vbelv = p~vbeln
         AND v~posnv = p~posnr
       INNER JOIN likp AS k
          ON p~vbeln = k~vbeln
       WHERE p~werks = gl_lips-werks
         AND p~lgort = gl_lips-lgort
         AND p~matnr = gl_lips-matnr
*         AND p~charg = xl_nasg-charg
         AND p~vbeln <> gl_lips-vbeln
         AND k~wbstk <> 'C'
         AND p~sobkz = gl_lips-sobkz    " 특별재고 지정부분 추가
         AND v~vbtyp_n = 'Q'.
    ENDIF.

    xl_nasg-labst =  xl_nasg-labst - gv_labst1.

    MODIFY xl_nasg.
  ENDLOOP.

*/ 자신에 지정된 수량은 가용수량에서 빼준다.
  LOOP AT xl_nasg. "WHERE chk = 'X'.
    CLEAR: gv_delqty.
    LOOP AT gl_lips WHERE matnr = xl_nasg-matnr
                      AND charg = xl_nasg-charg
                      AND item1 <> xl_nasg-item1.
      ADD gl_lips-delqty   TO gv_delqty.
    ENDLOOP.
    xl_nasg-labst = xl_nasg-labst - gv_delqty.
*    MODIFY XL_NASG TRANSPORTING LABST.
  ENDLOOP.

*/ 배치특성(정렬순서: CU72)
  REFRESH: gt_ksml.
  LOOP AT gl_lips WHERE sub = '1'.
    PERFORM get_sort_batch_characteristic USING gl_lips-matnr.
  ENDLOOP.

  LOOP AT xl_nasg.
* 배치특성을 구하고, 정렬순서와 비교하여 순번을 매겨서
* 재정렬한다.
    REFRESH: gt_ausp.
    PERFORM batch_characteristic TABLES gt_ausp
                                 USING xl_nasg-matnr
                                       xl_nasg-charg.
    CLEAR: lv_col_atwrt.

    DATA : lv_mtart LIKE mara-mtart.
    DATA : lv_xchar LIKE marc-xchar.

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

    SORT gt_ausp BY posnr.
    LOOP AT gt_ausp.
      CONCATENATE lv_col_atwrt gt_ausp-atwrt ';'
        INTO lv_col_atwrt. " SEPARATED BY ';'.
    ENDLOOP.

    xl_nasg-chart = lv_col_atwrt+0(99).
    MODIFY xl_nasg.

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
FORM get_xl_assg .

  CLEAR: xl_assg[], xl_assg, xt_assg[], xt_assg.

  LOOP AT gl_lips WHERE xchpf = 'X'
                    AND charg <> ' '.
    SELECT SINGLE * FROM lips WHERE vbeln = gl_lips-vbeln
                                AND posnr = gl_lips-posnr.

    xl_assg-item1  = gl_lips-item1.
    xl_assg-posnr  = gl_lips-posnr.
    xl_assg-matnr  = gl_lips-matnr.
    xl_assg-charg  = gl_lips-charg.
    xl_assg-vrkme  = gl_lips-vrkme.
    xl_assg-labst  = lips-lfimg.
    xl_assg-sobkz  = gl_lips-sobkz.
    xl_assg-xchpf  = gl_lips-xchpf.
*    xl_assg-vgbel  = gl_lips-vgbel.
*    xl_assg-vgpos  = gl_lips-vgpos.
    xl_assg-werks = gl_lips-werks.
    COLLECT xl_assg.  CLEAR: xl_assg.
  ENDLOOP.

  LOOP AT gl_lips WHERE xchpf = ' '
                    AND sub   = '1'.
    xl_assg-item1  = gl_lips-item1.
    xl_assg-posnr  = gl_lips-posnr.
    xl_assg-matnr  = gl_lips-matnr.
    xl_assg-charg  = gl_lips-charg.
    xl_assg-vrkme  = gl_lips-vrkme.
*   Picking 수량
    SELECT SINGLE rfmng INTO xl_assg-labst FROM vbfa
                       WHERE vbelv   = gl_lips-vbeln
                         AND posnv   = gl_lips-posnr
                         AND vbtyp_n = 'Q'.

*    xl_assg-labst  = gl_lips-lfimg.
    xl_assg-sobkz  = gl_lips-sobkz.
    xl_assg-xchpf  = gl_lips-xchpf.
*    xl_assg-vgbel  = gl_lips-vgbel.
*    xl_assg-vgpos  = gl_lips-vgpos.
    COLLECT xl_assg. CLEAR: xl_assg.
  ENDLOOP.

  DATA(lt_for) = xl_assg[].
  SORT lt_for BY matnr charg werks .
  DELETE ADJACENT DUPLICATES FROM lt_for COMPARING matnr charg werks .
  IF lt_for[] IS NOT INITIAL.

    SELECT * INTO TABLE @DATA(lt_sogr)
      FROM zgtsd_cv_get_vcofbatch
       FOR ALL ENTRIES IN @lt_for
     WHERE matnr = @lt_for-matnr
       AND charg = @lt_for-charg
       AND werks = @lt_for-werks
*       AND LGORT = @LT_FOR-LGORT
       AND atnam = 'PD_CA_GRADE'.
    SORT lt_sogr BY matnr charg werks.

    SELECT a~*
      FROM zgtsd_cv_get_vcofbatch AS a INNER JOIN mara AS b
                                       ON a~matnr EQ b~matnr
                                       AND b~spart EQ '10'
       FOR ALL ENTRIES IN @lt_for
     WHERE a~matnr = @lt_for-matnr
       AND a~charg = @lt_for-charg
       AND a~werks = @lt_for-werks
*       AND LGORT = @LT_FOR-LGORT
       AND a~atnam = 'PD_CA_CUSTOMER_CODE'  "SCR 8.0mm 거래처 Batch Characteristic
      INTO TABLE @DATA(lt_socust).
    SORT lt_socust BY matnr charg werks.

  ENDIF.

  LOOP AT xl_assg.
*    SELECT SINGLE EQUNR
*      INTO XL_ASSG-EQUNR
*      FROM EQUI
*      WHERE MATNR = XL_ASSG-MATNR
*      AND   CHARGE = XL_ASSG-CHARG.
    SELECT SINGLE tagnr
      INTO xl_assg-equnr
      FROM zppt0001
      WHERE werks = xl_assg-werks
      AND charg = xl_assg-charg
      AND matnr = xl_assg-matnr.

*등급
    READ TABLE lt_sogr INTO DATA(ls_gr) WITH KEY matnr = xl_assg-matnr
                                                 charg = xl_assg-charg
                                                 werks = xl_assg-werks BINARY SEARCH.
    IF sy-subrc = 0.
      xl_nasg-grade = ls_gr-atwrt.
    ENDIF.


* 거래처
    READ TABLE lt_socust INTO DATA(ls_cust) WITH KEY matnr = xl_assg-matnr
                                                     charg = xl_assg-charg
                                                     werks = xl_assg-werks BINARY SEARCH.
    IF sy-subrc = 0.
      DATA(lv_kunnr) = CONV kunnr( |{ ls_cust-atwrt ALPHA = IN }| ).

      SELECT SINGLE name1
        FROM kna1
       WHERE kunnr = @lv_kunnr
        INTO @DATA(lv_name1).

      IF lv_name1 IS NOT INITIAL.
      xl_assg-name1 = lv_name1.
    ENDIF.

  ENDIF.

  MODIFY xl_assg. CLEAR : xl_assg.
ENDLOOP.


* 가용수량 - 재고지정수량(동일제품일 경우)
* BonChan Koo 080821 MTO재고 두개 이상 품목이 있을 시
* 처음 재고만 가지고 재고수량 판단해 비지정 수량
* 가져오지 못하는 문제 수정
LOOP AT xl_nasg. "WHERE XCHPF = 'X'.
  CLEAR: gv_delqty.
  IF xl_nasg-sobkz IS INITIAL.
    LOOP AT xl_assg WHERE matnr = xl_nasg-matnr
                      AND charg = xl_nasg-charg.
      gv_delqty = gv_delqty + xl_assg-labst.
    ENDLOOP.
    IF sy-subrc = 0.
      xl_nasg-labst = xl_nasg-labst - gv_delqty.
      MODIFY xl_nasg TRANSPORTING labst.
    ENDIF.
  ELSE.
    LOOP AT xl_assg WHERE matnr = xl_nasg-matnr
                      AND charg = xl_nasg-charg
                      AND item1 = xl_nasg-item1.
      gv_delqty = gv_delqty + xl_assg-labst.
    ENDLOOP.
    IF sy-subrc = 0.
      xl_nasg-labst = xl_nasg-labst - gv_delqty.
      MODIFY xl_nasg TRANSPORTING labst.
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

DELETE xl_nasg WHERE labst = 0.

*/ BATCH 조장
LOOP AT xl_assg.
  CLEAR: gv_length.
  PERFORM get_batch_characteristic
      USING: xl_assg-matnr xl_assg-charg
             ba_length
   CHANGING: gv_length.

  xl_assg-length = gv_length.
  MODIFY xl_assg.
ENDLOOP.

LOOP AT xl_assg.
* 배치특성을 구하고, 정렬순서와 비교하여 순번을 매겨서
* 재정렬한다.
  REFRESH: gt_ausp.
  PERFORM batch_characteristic TABLES gt_ausp
                               USING xl_assg-matnr
                                     xl_assg-charg.
  CLEAR: lv_col_atwrt.

  DATA : lv_mtart LIKE mara-mtart.
  DATA : lv_xchar LIKE marc-xchar.



  SORT gt_ausp BY posnr.
  LOOP AT gt_ausp.
    CONCATENATE lv_col_atwrt gt_ausp-atwrt ';'
      INTO lv_col_atwrt." SEPARATED BY ';'.
  ENDLOOP.

  xl_assg-chart = lv_col_atwrt+0(99).
  MODIFY xl_assg.

ENDLOOP.

ENDFORM.                    " GET_XL_ASSG
*&---------------------------------------------------------------------*
*&      Form  get_sort_batch_characteristic
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_XL_NASG_MATNR  text
*----------------------------------------------------------------------*
FORM get_sort_batch_characteristic  USING    p_matnr.

  DATA: l_objno LIKE inob-cuobj.  "TYPE CUOBJ.
  DATA: l_object  LIKE kssk-objek.
  DATA: l_clint   TYPE clint.
  DATA: l_class   LIKE klah-class.

*/ 자재의 클라스를 구하고, 앞에 S를 붙인다.
  CLEAR: l_objno.
  l_object = p_matnr.

  CALL FUNCTION 'CUOB_GET_NUMBER'
    EXPORTING
      class_type       = '023'
      object_id        = l_object
      table            = 'MARA'
*     I_READ_DB_FIRST  = ' '
    IMPORTING
      object_number    = l_objno
    EXCEPTIONS
      lock_problem     = 1
      object_not_found = 2
      OTHERS           = 3.
  IF sy-subrc = 0.
    CLEAR: l_clint.
    SELECT SINGLE clint INTO l_clint FROM kssk
      WHERE objek = l_objno
        AND klart = '023'.

      CLEAR: l_class.
      SELECT SINGLE class INTO l_class FROM klah
        WHERE clint = l_clint.

        CONCATENATE 'S' l_class INTO l_class .

        CLEAR: l_clint.
        SELECT SINGLE clint INTO l_clint FROM klah
          WHERE klart = '040'
            AND class = l_class.

          SELECT * APPENDING CORRESPONDING FIELDS OF TABLE gt_ksml
            FROM ksml
           WHERE clint = l_clint.


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
FORM batch_characteristic  TABLES   pt_ausp LIKE gt_ausp[]
                           USING    p_matnr
                                    p_charg.

  DATA: l_objek LIKE kssk-objek,  "TYPE OBJNUM,
        l_objno LIKE inob-cuobj,  "TYPE CUOBJ,
        objek   LIKE ausp-objek.  "TYPE OBJNUM.

  CONCATENATE p_matnr p_charg INTO l_objek.

  CALL FUNCTION 'CUOB_GET_NUMBER'
    EXPORTING
      class_type       = '023'
      object_id        = l_objek
      table            = 'MCH1'
    IMPORTING
      object_number    = l_objno
    EXCEPTIONS
      lock_problem     = 1
      object_not_found = 2
      OTHERS           = 3.

  IF sy-subrc = 0.
    objek = l_objno.

    SELECT * INTO TABLE pt_ausp
    FROM   ausp
    WHERE  objek = objek
      AND  klart = '023'.
      IF sy-subrc = 0.
        LOOP AT pt_ausp.
          READ TABLE gt_ksml WITH KEY imerk = pt_ausp-atinn.
          IF sy-subrc = 0.
            pt_ausp-posnr = gt_ksml-posnr.

            PERFORM conversion_exit_atinn_output
                      USING pt_ausp-atinn
                   CHANGING pt_ausp-atnam.
            MODIFY pt_ausp.
          ELSE.
            DELETE pt_ausp.
          ENDIF.
        ENDLOOP.
      ENDIF.
    ENDIF.

    DATA: lv_value(13) TYPE p DECIMALS 3.
    DATA: lv_value_char(30).
    DATA: lv_date LIKE sy-datum.

    LOOP AT pt_ausp.
      CASE pt_ausp-atnam.
        WHEN 'SD_MILLCA_LENGTH_VKRME' OR
             'SAP_MILLCA_LENGTH'      OR
             'SAP_MILLCA_LENGTH_SUB'  OR
             'SAP_MILLCA_FACTOR'      OR
             'BT_AA_NET_WEIGHT'       OR   "개별중량
             'BT_AA_GRS_WEIGHT'       .    "총중량
          lv_value = pt_ausp-atflv.
          pt_ausp-atwrt = lv_value.
        WHEN 'BT_AA_PROD_DATE'.
          lv_value  = pt_ausp-atflv.
          lv_value_char = lv_value.
          SHIFT lv_value_char LEFT DELETING LEADING space.
          lv_date  = lv_value_char+0(8).
          pt_ausp-atwrt = lv_date.
        WHEN OTHERS.

      ENDCASE.

      SHIFT pt_ausp-atwrt LEFT DELETING LEADING space.
      MODIFY pt_ausp.
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
FORM conversion_exit_atinn_output  USING    p_atinn
                                   CHANGING p_atnam.

  CALL FUNCTION 'CONVERSION_EXIT_ATINN_OUTPUT'
    EXPORTING
      input  = p_atinn
    IMPORTING
      output = p_atnam.

ENDFORM.                    " conversion_exit_atinn_output
*&---------------------------------------------------------------------*
*&      Form  decrease_labst
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_XT_NASG  text
*      -->P_XL_NASG  text
*----------------------------------------------------------------------*
FORM decrease_labst  TABLES   pt_btch LIKE xt_nasg[]
                              pl_btch LIKE xl_nasg[].

  LOOP AT pt_btch WHERE chk = 'X'.
    LOOP AT pl_btch WHERE item1 = pt_btch-item1
                      AND charg = pt_btch-charg.
      pl_btch-labst = pl_btch-labst - pt_btch-delqty.
      MODIFY pl_btch.
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
FORM increase_labst  TABLES   pt_btch LIKE xt_nasg[]
                              pl_btch LIKE xl_nasg[].

  LOOP AT pt_btch WHERE chk = 'X'.
    LOOP AT pl_btch WHERE item1 = pt_btch-item1
                      AND charg = pt_btch-charg.
      pl_btch-labst = pl_btch-labst + pt_btch-delqty.
      pl_btch-chart  = pt_btch-chart.
      MODIFY pl_btch.
    ENDLOOP.
    IF sy-subrc <> 0.
      pl_btch-item1  = pt_btch-item1.
      pl_btch-posnr  = pt_btch-posnr.
      pl_btch-matnr  = pt_btch-matnr.
      pl_btch-charg  = pt_btch-charg.
      pl_btch-name1  = pt_btch-name1.
      pl_btch-grade  = pt_btch-grade.
      pl_btch-length = pt_btch-length.
      pl_btch-chart  = pt_btch-chart.
      pl_btch-labst  = pt_btch-delqty.
      pl_btch-vrkme  = pt_btch-vrkme.
      pl_btch-xchpf  = pt_btch-xchpf.
      pl_btch-equnr  = pt_btch-equnr.
      APPEND pl_btch.
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
FORM assign_gl_lips_delqty .

  wa_lips[] = gl_lips[].

  LOOP AT xt_nasg WHERE chk = 'X'.
    CLEAR: gv_delqty.
    LOOP AT gl_lips WHERE item1 = xt_nasg-item1
                      AND charg = xt_nasg-charg.
      gl_lips-delqty = gl_lips-delqty + xt_nasg-delqty.
      MODIFY gl_lips.
    ENDLOOP.
    IF sy-subrc <> 0.

      LOOP AT gl_lips WHERE icon1 = ' '
                        AND sub   = '1'
                        AND item1 = xt_nasg-item1.
        gl_lips-icon1   = c_icon1.
        MODIFY gl_lips TRANSPORTING icon1.
      ENDLOOP.

      READ TABLE wa_lips WITH KEY item1 = xt_nasg-item1.
      MOVE-CORRESPONDING wa_lips TO gl_lips.
      gl_lips-chk     = ' '.
      gl_lips-sub     = '2'.
      gl_lips-posnr   = ' '.
      gl_lips-charg   = xt_nasg-charg.
      gl_lips-delqty  = xt_nasg-delqty.
      gl_lips-grade   = xt_nasg-grade.
      gl_lips-lfimg   = ' '.
      gl_lips-jisiqty = ' '.
      gl_lips-icon1   = ' '.
      APPEND gl_lips.
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
FORM assign_gl_lips_delqty_1 .

  LOOP AT xt_assg WHERE chk = 'X'.
    LOOP AT gl_lips WHERE item1 = xt_assg-item1
                      AND charg = xt_assg-charg.
      gl_lips-delqty = gl_lips-delqty - xt_assg-delqty.
      MODIFY gl_lips TRANSPORTING delqty .
    ENDLOOP.

    DELETE gl_lips WHERE delqty = 0
                     AND sub    = '2'
                     AND item1  = xt_assg-item1.

    LOOP AT gl_lips WHERE item1 = xt_assg-item1
                      AND sub   = '2'.
    ENDLOOP.
    IF sy-subrc <> 0.
      LOOP AT gl_lips WHERE item1 = xt_assg-item1
                        AND sub   = '1'.
        gl_lips-icon1   = ' '.
        MODIFY gl_lips TRANSPORTING icon1.
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
FORM get_jisiqty_delqty .

*/ 지시수량(jisiqty): 현재납품수량,
*  지정수량(delqty) : 배치사용(배치지정수량), 배치미사용(포장수량)

*/
  LOOP AT gl_lips .
    IF gl_lips-sub = '1'.
      gl_lips-jisiqty = gl_lips-lfimg.
*      gl_lips-delqty  = gl_lips-lfimg.
    ELSE.
      gl_lips-jisiqty = gl_lips-lfimg.
      gl_lips-delqty  = gl_lips-lfimg.
    ENDIF.

    IF gl_lips-xchpf = ' '.
      gl_lips-delqty = gl_lips-lfimg.
    ENDIF.
    gl_lips-lfimg    = 0.

    MODIFY gl_lips TRANSPORTING lfimg delqty jisiqty.
  ENDLOOP.

  wa_lips[] = gl_lips[].

  LOOP AT gl_lips WHERE sub = '1'.
* 지시수량
    CLEAR: gv_jisiqty, gv_delqty.
    LOOP AT wa_lips WHERE item1 = gl_lips-item1.
      ADD wa_lips-jisiqty TO gv_jisiqty.
*      ADD wa_lips-delqty  TO gv_delqty.
    ENDLOOP.
    gl_lips-jisiqty = gv_jisiqty.

* 미지정수량
*    gl_lips-ndelqty = gl_lips-jisiqty - gv_delqty.

*// QI 재고
    IF gl_lips-sobkz = ' '.
      IF gl_lips-xchpf = 'X'.
*/ 1. 일반재고-배치사용: MCHB
        SELECT SUM( cinsm ) INTO gl_lips-qiqty FROM mchb
          WHERE matnr = gl_lips-matnr
            AND werks = gl_lips-werks
            AND lgort = gl_lips-lgort.
        ELSE.
*/ 2. 일반재고-배치미사용: MARD
          SELECT SINGLE insme INTO gl_lips-qiqty FROM mard
            WHERE matnr = gl_lips-matnr
              AND werks = gl_lips-werks
              AND lgort = gl_lips-lgort.
          ENDIF.
        ELSE.
          IF gl_lips-xchpf = 'X'.
*/ 3. 특별재고-배치사용: MSKA
            SELECT SUM( kains ) INTO gl_lips-qiqty FROM mska
             WHERE matnr = gl_lips-matnr
               AND werks = gl_lips-werks
               AND lgort = gl_lips-lgort
               AND sobkz = gl_lips-sobkz
               AND vbeln = gl_lips-vgbel
               AND posnr = gl_lips-vgpos.
            ELSE.
*/ 4. 특별재고-배치미사용: MSKA
              SELECT SINGLE kains INTO gl_lips-qiqty FROM mska
                WHERE matnr = gl_lips-matnr
                  AND werks = gl_lips-werks
                  AND lgort = gl_lips-lgort
                  AND sobkz = gl_lips-sobkz
                  AND vbeln = gl_lips-vgbel
                  AND posnr = gl_lips-vgpos.
              ENDIF.
            ENDIF.

            IF gl_lips-meins <> gl_lips-vrkme.
              IF NOT gl_lips-umvkz IS INITIAL.
                gl_lips-qiqty =
                  gl_lips-qiqty * gl_lips-umvkn / gl_lips-umvkz.
              ENDIF.
            ENDIF.

            MODIFY gl_lips TRANSPORTING jisiqty ndelqty qiqty.
          ENDLOOP.

          LOOP AT gl_lips WHERE sub = '2'.
            gl_lips-jisiqty = 0.
            MODIFY gl_lips TRANSPORTING jisiqty.
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
FORM save_300.

  PERFORM pop_up_confirm(zler0004) USING '< 확인 >'
                               '저장하시겠습니까?'
                      CHANGING gv_return.

  CHECK gv_return = 'J'.

  PERFORM prepare_save_300.

  PERFORM bdc_run_vl02n_300
    USING p_wadat_ist tvrot-route t173t-vsart p_wadat.


ENDFORM.                                                    " save_300
*&---------------------------------------------------------------------*
*&      Form  prepare_save_300
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM prepare_save_300 .


*/ 추가대상
  REFRESH: gt_tab11, gt_tab8.
  CLEAR  : gt_tab11, gt_tab8.

**/배치미사용
  LOOP AT xl_assg WHERE xchpf = ' '.
    READ TABLE cl_assg WITH KEY posnr = xl_assg-posnr.
    IF sy-subrc <> 0.
      READ TABLE gl_lips WITH KEY item1 = xl_assg-item1
                                  sub   = '1'.
      gt_tab8-posnr = xl_assg-posnr.
      gt_tab8-lfimg = gl_lips-jisiqty.
*      gt_tab8-pikmg = xl_assg-labst.
      gt_tab8-pikmg = gl_lips-delqty.
      gt_tab8-vrkme = gl_lips-vrkme.
      APPEND gt_tab8.
    ENDIF.
  ENDLOOP.

  LOOP AT cl_assg WHERE xchpf = ' '.
    READ TABLE xl_assg WITH KEY item1 = cl_assg-item1
                                posnr = cl_assg-posnr.
    IF sy-subrc = 0.
      IF cl_assg-labst <> xl_assg-labst.  "수량변경
        READ TABLE gl_lips WITH KEY item1 = xl_assg-item1
                                    sub   = '1'.
        gt_tab8-posnr = xl_assg-posnr.
        gt_tab8-lfimg = gl_lips-jisiqty.
*        gt_tab8-pikmg = xl_assg-labst.
        gt_tab8-pikmg = gl_lips-delqty.
        gt_tab8-vrkme = gl_lips-vrkme.
        APPEND gt_tab8.
      ENDIF.
    ENDIF.
  ENDLOOP.

**/ 납품수량변경
  LOOP AT gl_lips WHERE sub = '1'
                    AND xchpf = ' '.
    LOOP AT cl_lips WHERE posnr =    gl_lips-posnr
                      AND jisiqty <> gl_lips-jisiqty.
    ENDLOOP.
    IF sy-subrc = 0.
      LOOP AT gt_tab8 WHERE posnr = gl_lips-posnr.
        gt_tab8-lfimg = gl_lips-jisiqty.
        gt_tab8-pikmg = gl_lips-delqty.
        MODIFY gt_tab8 TRANSPORTING lfimg.
      ENDLOOP.
      IF sy-subrc <> 0.
        gt_tab8-posnr = gl_lips-posnr.
        gt_tab8-lfimg = gl_lips-jisiqty.
        gt_tab8-pikmg = gl_lips-delqty.
        gt_tab8-vrkme = gl_lips-vrkme.
        APPEND gt_tab8.
      ENDIF.
    ENDIF.
  ENDLOOP.

**/ 납품수량변경
  LOOP AT gl_lips WHERE sub = '1'
                    AND xchpf = 'X'.
    LOOP AT cl_lips WHERE posnr =    gl_lips-posnr
                      AND jisiqty <> gl_lips-jisiqty.
    ENDLOOP.
    IF sy-subrc = 0.
      LOOP AT gt_tab8 WHERE posnr = gl_lips-posnr.
        gt_tab8-lfimg = gl_lips-jisiqty.
        MODIFY gt_tab8 TRANSPORTING lfimg.
      ENDLOOP.
      IF sy-subrc <> 0.
        gt_tab8-posnr = gl_lips-posnr.
        gt_tab8-lfimg = gl_lips-jisiqty.
        gt_tab8-pikmg = 0.
        gt_tab8-vrkme = gl_lips-vrkme.
        APPEND gt_tab8.
      ENDIF.
    ENDIF.
  ENDLOOP.

**/ 배치사용
  LOOP AT xl_assg WHERE xchpf = 'X'.
    READ TABLE cl_assg WITH KEY posnr = xl_assg-posnr.
    IF sy-subrc <> 0.
      READ TABLE gl_lips WITH KEY item1 = xl_assg-item1.
      gt_tab11-uecha = xl_assg-item1.
      gt_tab11-charg = xl_assg-charg.
      gt_tab11-lgort = gl_lips-lgort.
      gt_tab11-lfimg = xl_assg-labst.
      gt_tab11-vrkme = gl_lips-vrkme.
      gt_tab11-apd   = 'X'.
      APPEND gt_tab11.
    ENDIF.
  ENDLOOP.

*/ 추가,삭제 대상
  LOOP AT cl_assg WHERE xchpf = 'X'.
    READ TABLE xl_assg WITH KEY item1 = cl_assg-item1
                                posnr = cl_assg-posnr.
    IF sy-subrc = 0.
      IF cl_assg-labst <> xl_assg-labst.  "수량변경
        READ TABLE gl_lips WITH KEY item1 = xl_assg-item1.
        gt_tab11-uecha = xl_assg-item1.
        gt_tab11-posnr = xl_assg-posnr.
        gt_tab11-charg = xl_assg-charg.
        gt_tab11-lgort = gl_lips-lgort.
        gt_tab11-lfimg = xl_assg-labst.
        gt_tab11-vrkme = gl_lips-vrkme.
        IF NOT gt_tab11-lfimg IS INITIAL.
          gt_tab11-apd   = 'X'.
        ENDIF .
        gt_tab11-del   = 'X'.
        APPEND gt_tab11.
      ENDIF.
    ENDIF.
  ENDLOOP.

  LOOP AT gt_tab11 WHERE lfimg = 0.
    gt_tab11-apd   = ' '.
    gt_tab11-del   = 'X'.
    MODIFY gt_tab11.
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
FORM bdc_run_vl02n_300 USING v_wadat v_route v_vsart v_wadat2.

  CLEAR: gv_result, gv_msg.

  PERFORM dequeue_all.


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

  DATA : l_sernp      LIKE marc-sernp VALUE ' ',
         l_matnr      LIKE lips-matnr,
         l_werks      LIKE lips-werks,
         l_charg      LIKE lips-charg,
         l_uecha      LIKE lips-uecha,
         l_posnr      LIKE lips-posnr,
         l_anzsn      LIKE lips-anzsn,
         l_multi1(20),
         l_multi2(20),
         l_multi3(20),
         l_multi4(20),
         kosta        LIKE lips-kosta,
         l_seq        TYPE n,
         l_seq1       TYPE n,
         l_seq2       TYPE n,
         l_msgty      LIKE sy-msgty VALUE 'S'.
  DATA : BEGIN OF lt_tab OCCURS 0,
           vbeln LIKE lips-vbeln,
           posnr LIKE lips-posnr,
         END OF lt_tab.

  CLEAR : bdcdata,bdcdata[],lt_tab,lt_tab[].
  PERFORM enquene_do USING p_vbeln.


  LOOP AT gt_tab11 WHERE del = 'X'.

    SELECT vbeln posnr
    APPENDING TABLE lt_tab
    FROM   lips
    WHERE  vbeln =  p_vbeln
    AND    charg <> ' '
    AND    uecha IN ( SELECT uecha
                      FROM   lips
                      WHERE  vbeln = p_vbeln
                      AND    posnr = gt_tab11-posnr
                    ).
    ENDLOOP.

*  SORT LT_TAB.
    DELETE ADJACENT DUPLICATES FROM lt_tab.

    PERFORM dynpro USING:
    'X'    'SAPMV50A'              '4004',
    ' '    'BDC_CURSOR'            'LIKP-VBELN',
    ' '    'LIKP-VBELN'	         p_vbeln,
    ' '    'BDC_OKCODE'            '/00'.

    LOOP AT gt_tab11.

      SELECT SINGLE matnr werks charg uecha
      INTO   (l_matnr, l_werks, l_charg, l_uecha)
      FROM   lips
      WHERE  vbeln = p_vbeln
      AND    posnr = gt_tab11-posnr.

        SELECT SINGLE xchpf FROM mara
        INTO   l_sernp
        WHERE  matnr = l_matnr
        AND    xchpf = 'X'.

* 배치번호 사용유무 체크
          IF sy-subrc = 0 .

            SELECT SINGLE sernp FROM marc
            INTO   l_sernp
            WHERE  matnr = l_matnr
            AND    werks = l_werks
            AND    sernp <> ' '.

* 일련번호 사용유무 체크
              IF sy-subrc = 0.

                SELECT COUNT(*)
                INTO   l_seq1
                FROM   lips
                WHERE  vbeln  = p_vbeln
                AND    uecha  = l_uecha
                AND    posnr <= gt_tab11-posnr.

                  l_seq = l_uecha+4(1).
                  l_seq1 = l_seq1 + 1.
                  l_seq2 = l_seq2 + 1.
                  CONCATENATE '=CHPL_T0'           l_seq2       INTO l_multi1.
                  CONCATENATE 'RV50A-CHMULT(0'     l_seq   ')'  INTO l_multi2.
                  CONCATENATE 'LIPS-POSNR(0'       l_seq1  ')'  INTO l_multi3.
                  CONCATENATE 'RV50A-LIPS_SELKZ(0' l_seq1  ')'  INTO l_multi4.


*        PERFORM DYNPRO USING:
*          'X'    'SAPMV50A'              '4004',
*          ' '    'BDC_CURSOR'            'LIKP-VBELN',
*          ' '    'LIKP-VBELN'              P_VBELN,
*          ' '    'BDC_OKCODE'            '/00'.

                  IF l_posnr NE l_uecha OR sy-tabix EQ 1.

                    IF sy-tabix NE 1.

                      PERFORM dynpro USING:
                        'X'    'SAPMV50A'              '1000',
                        ' '    'BDC_OKCODE'            '=BACK_T'.

                    ENDIF.

                    PERFORM dynpro USING:
                      'X'    'SAPMV50A'              '1000',
                        ' '    'BDC_OKCODE'            l_multi1,
                        ' '    'BDC_CURSOR'            l_multi2.

                    l_posnr = l_uecha.

                  ENDIF.

*        PERFORM DYNPRO USING:
*          'X'    'SAPMV50A'              '1000',
*          ' '    'BDC_OKCODE'            L_MULTI1,
*          ' '    'BDC_CURSOR'            L_MULTI2.

                  PERFORM dynpro USING:
                        'X' 'SAPMV50A'              '1000',
                        ' ' 'BDC_OKCODE'            '=POPO_T'.      "품목찾기

                  PERFORM dynpro USING:
                        'X' 'SAPMV50A'              '0111',
                        ' ' 'BDC_OKCODE'            '=WEIT',        "ENTER
                        ' ' 'RV50A-POSNR'           gt_tab11-posnr.  "

                  PERFORM dynpro USING:
                      'X'    'SAPMV50A'         '1000',
                          ' '    'BDC_OKCODE'       '=PSER_T'.
*                ' '    L_MULTI4           'X'.


                  PERFORM dynpro USING:
                          'X'    'SAPLIPW1'              '0300',
                          ' '    'BDC_CURSOR'            'RIPW0-SERNR(01)',
                          ' '    'BDC_OKCODE'            '=RWS',
                          ' '    'RIPW0-SERNR(01)'       ' '.

                  SELECT SINGLE anzsn
                  INTO   l_anzsn
                  FROM   lips
                  WHERE  vbeln  = p_vbeln
                  AND    posnr  = gt_tab11-posnr.

                    IF l_anzsn > 0.

                      PERFORM dynpro USING:
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

              PERFORM dynpro USING:
              'X'    'SAPMV50A'              '1000',
              ' '    'BDC_OKCODE'            '=SICH_T'.

              PERFORM dequeue_all.

*  CALL TRANSACTION 'VL02N' USING BDCDATA
*       MODE bdc_mode UPDATE 'S'
*       MESSAGES INTO MESSTAB.


              l_msgty = sy-msgty.
              l_msgty = 'S'.
* CSR번호: C2006080820000000260 수정끝
**************************************.
              IF l_msgty = 'S'.
                IF s_vstel-low BETWEEN 'M600' AND 'M799'.
                  CALL FUNCTION 'Z_LE_VL02N_BATCH4_SERNR'
                    EXPORTING
                      i_vbeln  = p_vbeln
                      i_wast   = ' '
                      i_wadat  = v_wadat
                      i_route  = v_route
                      i_vsart  = v_vsart
                      i_wadat2 = v_wadat2
                      i_mode   = bdc_mode
                    IMPORTING
                      return   = gv_result
                      zmessage = gv_msg
                    TABLES
                      it_data  = gt_tab11
                      pt_data8 = gt_tab8.
                ELSE.
                  CALL FUNCTION 'Z_LE_VL02N_BATCH4'
                    EXPORTING
                      i_vbeln  = p_vbeln
                      i_wast   = ' '
                      i_wadat  = v_wadat
                      i_route  = v_route
                      i_vsart  = v_vsart
                      i_mode   = bdc_mode
                    IMPORTING
                      return   = gv_result
                      zmessage = gv_msg
                    TABLES
                      it_data  = gt_tab11
                      pt_data8 = gt_tab8.

**{ 기능개선 91460 - 추가
**___배치지정 저장 후 피킹 실행
*                  PERFORM make_picking_data_300_1.
*
*                  PERFORM call_transaction_vl02n.
**} 기능개선 91460 - 추가
                ENDIF.

                IF gv_result = 'S'.
*  / SAVE SHIPPING NO. - LONG TEXT
                  PERFORM save_shipping_no .

                  CLEAR: r_vbeln[], r_vbeln, et_likp[], et_likp.
                  PERFORM get_range_vbeln USING p_vbeln.
                  PERFORM data_query TABLES et_likp
                                            r_vbeln.
                  LOOP AT et_likp.
                    LOOP AT gt_likp WHERE vbeln = et_likp-vbeln.
                      MOVE-CORRESPONDING et_likp TO gt_likp.
                      gt_likp-wadat_ist = sy-datum.
                      MODIFY gt_likp .
                    ENDLOOP.
                  ENDLOOP.

                  gv_save_flag = 'X'.
                  PERFORM get_detail.
                  MESSAGE s001 WITH p_vbeln '저장하였습니다'.
                ELSE.
                  MESSAGE i002 WITH p_vbeln gv_msg '저장하지 못했습니다'.
                  LEAVE TO SCREEN 100.
                ENDIF.

              ELSE.
                MESSAGE i002 WITH p_vbeln gv_msg '저장하지 못했습니다(일련번호)'.
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
FORM error_check_left_300 .

*/ 상위품목에 배치지정된거는 데이타 고정
  READ TABLE gl_lips WITH KEY chk = 'X'.
  CLEAR: gv_flag.
  IF gl_lips-fixed = 'X'.
    MESSAGE i000 WITH
     '상위품목에 이미 배치지정 되었습니다'.
    gv_flag = 'X'.
  ENDIF.
  IF gv_flag = 'X'.
    LEAVE SCREEN.
  ENDIF.

  CLEAR: gv_delqty, gv_jisiqty.
  LOOP AT xt_nasg WHERE chk = 'X'.
    ADD xt_nasg-delqty  TO gv_delqty.
  ENDLOOP.
  LOOP AT xt_assg.
    ADD xt_assg-labst   TO gv_delqty.
  ENDLOOP.

  READ TABLE gl_lips WITH KEY chk = 'X'.
  LOOP AT gl_lips WHERE item1 = gl_lips-item1.
    ADD gl_lips-jisiqty  TO gv_jisiqty.
  ENDLOOP.

* 070615 SDB03 허경도대리님요청
* 메세지 변경
* 지정수량 초과시 오류 메세지에 납품 수량이 얼마인데
* 지정수량이 얼마여서 얼마 초과 한다는 메세지
  DATA : lv_qty LIKE gv_delqty.
  IF gv_delqty > gv_jisiqty.
    lv_qty     = gv_delqty - gv_jisiqty.
    MESSAGE i024 WITH gv_jisiqty gv_delqty lv_qty.
    CLEAR : lv_qty.
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
FORM check_picking_possibe .

  CLEAR: p_kostk, ok_picking, gv_jisiqty, gv_delqty.
  LOOP AT gl_lips.
    ADD gl_lips-jisiqty  TO  gv_jisiqty.
    ADD gl_lips-delqty   TO  gv_delqty.
  ENDLOOP.

  IF gv_jisiqty = gv_delqty.
    ok_picking = 'X'.
  ENDIF.

  p_kostk = gt_likp-kostk.

  IF p_kostk = 'A'.
    p_kostk_t = '미처리'.
  ELSEIF p_kostk = 'B'.
    p_kostk_t = '부분처리'.
  ELSEIF p_kostk = 'C'.
    p_kostk_t = '피킹완료'.
  ELSEIF p_kostk = ' '.
    p_kostk_t = '피킹 관련 없음'.
  ENDIF.

ENDFORM.                    " check_picking_possibe
*&---------------------------------------------------------------------*
*&      Form  get_range_vbeln
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_P_VBELN  text
*----------------------------------------------------------------------*
FORM get_range_vbeln  USING    p_vbeln.

  r_vbeln-sign   = 'I'.
  r_vbeln-option = 'EQ'.
  r_vbeln-low    = p_vbeln.
  APPEND r_vbeln.
ENDFORM.                    " get_range_vbeln
*&---------------------------------------------------------------------*
*&      Form  picking
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM picking .

  PERFORM error_check_picking.

  PERFORM pop_up_confirm(zler0004) USING '< 확인 >'
                               '피킹 하시겠습니까?'
                      CHANGING gv_return.
  CHECK gv_return = 'J'.

  PERFORM make_picking_data.

* 기계 트랙터 제품군 뱃치특성 체크 위한 Subroutine
  PERFORM check_batch.

  PERFORM bdc_run_picking
    USING p_wadat_ist tvrot-route t173t-vsart.

ENDFORM.                    " picking
*&---------------------------------------------------------------------*
*&      Form  error_check_picking
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM error_check_picking .

ENDFORM.                    " error_check_picking
*&---------------------------------------------------------------------*
*&      Form  make_picking_data
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM make_picking_data .

  CLEAR: gt_tab1[], gt_tab1.
  LOOP AT gl_lips WHERE sub = '1'.
*                    AND xchpf = 'X'.
    gt_tab1-posnr = gl_lips-posnr.
    gt_tab1-pikmg = gl_lips-delqty.
    APPEND gt_tab1.
  ENDLOOP.

*  DELETE gt_tab1 WHERE pikmg = 0.

  CLEAR: gt_tab2[], gt_tab2.
  LOOP AT gl_lips WHERE sub = '2'.
*                    AND xchpf = 'X'.
    gt_tab2-uecha = gl_lips-item1.
    gt_tab2-posnr = gl_lips-posnr.
    gt_tab2-charg = gl_lips-charg.
    gt_tab2-vrkme = gl_lips-vrkme.
    gt_tab2-pikmg = gl_lips-delqty.
    APPEND gt_tab2.
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
FORM bdc_run_picking  USING   v_wadat v_route v_vsart.

  CLEAR: gv_result, gv_msg.

  PERFORM dequeue_all.

  IF s_vstel-low >= 'M600' AND s_vstel-low <= 'M799'.
    CALL FUNCTION 'Z_LE_VL02N_SERNR'
      EXPORTING
        i_vbeln  = p_vbeln
        i_wadat  = v_wadat
        i_route  = v_route
        i_vsart  = v_vsart
        i_mode   = bdc_mode
      IMPORTING
        return   = gv_result
        zmessage = gv_msg
      TABLES
        pt_data1 = gt_tab1
        pt_data2 = gt_tab2.
  ELSE.
    CALL FUNCTION 'Z_LE_VL02N_PICKING'
      EXPORTING
        i_vbeln  = p_vbeln
        i_wadat  = v_wadat
        i_route  = v_route
        i_vsart  = v_vsart
        i_mode   = bdc_mode
      IMPORTING
        return   = gv_result
        zmessage = gv_msg
      TABLES
        pt_data1 = gt_tab1
        pt_data2 = gt_tab2.
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

  PERFORM enquene_do USING p_vbeln.

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

  PERFORM dequeue_all.

*  CALL TRANSACTION 'VL02N' USING BDCDATA
*       MODE BDC_MODE UPDATE 'S'
*       MESSAGES INTO MESSTAB.

* CSR번호: C2006080801000000259 수정끝
**************************************


  IF gv_result = 'S'.

    CLEAR: r_vbeln[], r_vbeln, et_likp[], et_likp.
    PERFORM get_range_vbeln USING p_vbeln.
    PERFORM data_query TABLES et_likp
                              r_vbeln.
    LOOP AT et_likp.
      LOOP AT gt_likp WHERE vbeln = et_likp-vbeln.
        MOVE-CORRESPONDING et_likp TO gt_likp.
        gt_likp-wadat_ist = sy-datum.
        MODIFY gt_likp .
      ENDLOOP.
    ENDLOOP.

    gv_save_flag = 'X'.
    PERFORM get_detail.

    MESSAGE s001 WITH p_vbeln '피킹하였습니다'.
  ELSE.
    MESSAGE i002 WITH p_vbeln gv_msg.
    LEAVE TO SCREEN 100.
  ENDIF.

ENDFORM.                    " bdc_run_picking
*&---------------------------------------------------------------------*
*&      Form  dynpro
*&---------------------------------------------------------------------*
FORM dynpro  USING    dynbegin name value.

  CLEAR  bdcdata.

  IF dynbegin = 'X'.
    MOVE:  'X'   TO  bdcdata-dynbegin,
           name  TO  bdcdata-program,
           value TO  bdcdata-dynpro.
  ELSE.
    MOVE:
           name  TO  bdcdata-fnam,
           value TO  bdcdata-fval.
  ENDIF.

  APPEND bdcdata.

ENDFORM.                    " dynpro
*&---------------------------------------------------------------------*
*&      Form  wast1
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM wast1 .

  PERFORM pop_up_confirm(zler0004) USING '< 확인 >'
                               '출고전기 하시겠습니까?'
                      CHANGING gv_return.
  CHECK gv_return = 'J'.

  PERFORM func_wast USING gt_likp-vbeln
                          tvrot-route
                          p_wadat_ist
                          t173t-vsart.

  IF gv_result = 'S'.
    MESSAGE s000 WITH '출고전기 하였습니다'.
    DELETE gt_likp WHERE vbeln = p_vbeln.
    LEAVE TO SCREEN 100.
  ELSE.
    MESSAGE i001 WITH '오류:' gv_msg.
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
FORM func_wast  USING    p_vbeln
                         p_route
                         p_wadat
                         p_vsart.

  CLEAR: gv_result, gv_msg.

  PERFORM dequeue_all.

  CALL FUNCTION 'Z_LE_VL02N_GI'
    EXPORTING
      vbeln     = p_vbeln
      route     = p_route
      wadat_ist = p_wadat
      vsart     = p_vsart
      i_mode    = bdc_mode
    IMPORTING
      return    = gv_result
      zmessage  = gv_msg.


ENDFORM.                    " func_wast
*&---------------------------------------------------------------------*
*&      Form  delivery_delete
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM delivery_delete USING hu_use.

  PERFORM check_tknum.

  PERFORM pop_up_confirm(zler0004) USING '< 삭제여부확인 >'
                               '납품 삭제하시겠읍니까?'
                      CHANGING gv_return.
  CHECK gv_return = 'J'.

  PERFORM check_tknum.

  PERFORM dequeue_all.

  CALL FUNCTION 'Z_LE_VL02N_DELETE'
    EXPORTING
      vbeln    = p_vbeln
      hu_use   = hu_use
      i_mode   = bdc_mode
    IMPORTING
      return   = gv_result
      zmessage = gv_msg.
*    tables
*      it_tab   = gt_delt.

  IF gv_result = 'S'.
    DELETE gt_likp WHERE vbeln = p_vbeln.
    MESSAGE s001 WITH p_vbeln '삭제하였습니다'.
    LEAVE TO SCREEN 100.
  ELSE.
    MESSAGE i002 WITH p_vbeln '삭제하지 못했습니다' gv_msg.
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
FORM check_tknum .

  DATA: lv_tknum LIKE vttp-tknum.

  CLEAR: lv_tknum.
  SELECT SINGLE tknum INTO lv_tknum FROM vttp
    WHERE vbeln = p_vbeln.
    IF sy-subrc = 0.
      MESSAGE s017 WITH lv_tknum.
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
FORM pick1 .

  i_cursor_line = tc01-current_line + i_cursor_line - 1.
  READ TABLE gt_likp INDEX i_cursor_line.

  CASE g_cursor_field.
    WHEN 'GT_LIKP-VBELN'.
      SET PARAMETER ID 'VL' FIELD gt_likp-vbeln.
      CALL TRANSACTION 'VL03N'
                    AND SKIP  FIRST SCREEN.

    WHEN 'GT_LIKP-VGBEL'.
      SET PARAMETER ID 'AUN' FIELD gt_likp-vgbel.
      CALL TRANSACTION 'VA03' WITH AUTHORITY-CHECK AND SKIP FIRST SCREEN.
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
FORM assign_gl_lips_delqty_200 .

  REFRESH: wa_vepo, wa_lips1.
  CLEAR  : wa_vepo, wa_lips1.

  wa_lips2[] = gl_lips[].

*/ < #1. 자신의 상위품목부터 assign >
*  SORT gl_vepo BY exidv.
*/ 동일 배치 품목이 있을때, 먼저 MODI.
  PERFORM same_batch_modi_na_chk.

*  SORT gl_vepo BY exidv.
*/ 동일 배치가 없을때, APPEND
  PERFORM batch_append_na_chk.

*/ < #2. 자신의 상위품목부터 assign 하고,남은 부분 assign >
*  SORT gl_vepo BY exidv.
  PERFORM same_batch_modi_na.

*  SORT gl_vepo BY exidv.
*/ 동일 배치가 없을때, APPEND
  PERFORM batch_append_na.

*  SORT gl_vepo BY exidv.

  DELETE gl_lips WHERE delqty = 0
                   AND sub    = '2'.

*/ ICON SETTING
  wa_lips2[] = gl_lips[].

  LOOP AT gl_lips WHERE icon1 = ' '
                    AND sub   = '1'.
    READ TABLE wa_lips2 WITH KEY item1 = gl_lips-item1
                                 sub   = '2'.
    IF sy-subrc = 0.
      gl_lips-icon1 = c_icon1.
      MODIFY gl_lips TRANSPORTING icon1.
    ENDIF.
  ENDLOOP.

  gl_lips-calcu = ' '.
  MODIFY gl_lips TRANSPORTING calcu WHERE calcu = 'X'.

ENDFORM.                    " assign_gl_lips_delqty_200
*&---------------------------------------------------------------------*
*&      Form  get_GL_VEPO_hu
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_gl_vepo_hu .

  DATA: lv_uevel   LIKE vekp-uevel.

  DATA: BEGIN OF lt_itab OCCURS 0,
          werks LIKE lips-werks,
          lgort LIKE lips-lgort,
          matnr LIKE lips-matnr,
          sobkz LIKE lips-sobkz,
        END OF lt_itab.

  CLEAR: gt_vepo[], gt_vepo, gl_vepo[], gl_vepo,
         gt_nasg[], gt_nasg, gt_assg[], gt_assg.

  LOOP AT gl_lips WHERE sub = '1'.
    MOVE-CORRESPONDING gl_lips  TO lt_itab.
    COLLECT lt_itab.
  ENDLOOP.

  LOOP AT lt_itab .
    SELECT *  FROM vepo
     WHERE werks = lt_itab-werks
       AND lgort = lt_itab-lgort
       AND matnr = lt_itab-matnr
       AND sobkz = lt_itab-sobkz.
      MOVE-CORRESPONDING vepo  TO gt_vepo.
      APPEND gt_vepo.
    ENDSELECT.
  ENDLOOP.

  LOOP AT gt_vepo.
    CLEAR : gl_vepo-extnl.

* 다른 납품에 지정되어 있는것 제외
    SELECT SINGLE mandt INTO sy-mandt FROM likp
      WHERE vbeln = gt_vepo-vbeln
        AND lfart <> 'LR'.

      IF sy-subrc = 0.
        IF p_vbeln <> gt_vepo-vbeln.
          CONTINUE.
        ENDIF.
        MOVE-CORRESPONDING gt_vepo TO gl_vepo.

*      SELECT SINGLE EXIDV ERDAT
*        INTO (GL_VEPO-EXIDV, GL_VEPO-ERDAT)
*        FROM VEKP
*       WHERE VENUM = GT_VEPO-VENUM
*         AND VPOBJ = '01'  "시스템상태-실제있음
*         AND STATUS IN ('0020', '0030').
*      IF SY-SUBRC <> 0.
*        CONTINUE.
*      ENDIF.

        SELECT SINGLE exidv erdat uevel
          INTO (gl_vepo-exidv, gl_vepo-erdat, lv_uevel)
          FROM vekp
         WHERE venum = gt_vepo-venum
           AND vpobj = '01'  "시스템상태-실제있음
           AND status IN ('0020', '0030').
          IF sy-subrc = 0.
            IF lv_uevel IS NOT INITIAL.
              gl_vepo-extnl = 'X'.

              SELECT SINGLE exidv erdat
                INTO (gl_vepo-exidv, gl_vepo-erdat)
                FROM vekp
               WHERE venum = lv_uevel.
              ENDIF.
            ELSE.
              CONTINUE.
            ENDIF.

            SELECT SINGLE uecha INTO gl_vepo-item1 FROM lips
              WHERE vbeln = gl_vepo-vbeln
                AND posnr = gl_vepo-posnr
                AND uecha <> '000000'.
              IF sy-subrc <> 0.
                SELECT SINGLE posnr INTO gl_vepo-item1 FROM lips
                  WHERE vbeln = gl_vepo-vbeln
                    AND posnr = gl_vepo-posnr
                    AND uecha = '000000'.
                ENDIF.

                gl_vepo-place = 'A'.
                gl_vepo-orgin = 'A'.
              ELSE.
                MOVE-CORRESPONDING gt_vepo TO gl_vepo.

*      SELECT SINGLE EXIDV ERDAT
*        INTO (GL_VEPO-EXIDV, GL_VEPO-ERDAT)
*        FROM VEKP
*       WHERE VENUM = GT_VEPO-VENUM
*         AND VPOBJ  IN ('05', '06', '12')
*         AND STATUS IN ('0020', '0030').
*      IF SY-SUBRC <> 0.
*        CONTINUE.
*      ENDIF.

                SELECT SINGLE exidv erdat uevel
                  INTO (gl_vepo-exidv, gl_vepo-erdat, lv_uevel)
                  FROM vekp
                 WHERE venum = gt_vepo-venum
                   AND vpobj  IN ('05', '06', '12')
                   AND status IN ('0020', '0030').
                  IF sy-subrc = 0.
                    IF lv_uevel IS NOT INITIAL.
                      gl_vepo-extnl = 'X'.

                      SELECT SINGLE exidv erdat
                        INTO (gl_vepo-exidv, gl_vepo-erdat)
                        FROM vekp
                       WHERE venum = lv_uevel.
                      ENDIF.
                    ELSE.
                      CONTINUE.
                    ENDIF.

                    gl_vepo-place = 'N'.
                    gl_vepo-orgin = 'N'.
                    gl_vepo-vbeln = ' '.
                    gl_vepo-posnr = ' '.
                  ENDIF.
                  COLLECT gl_vepo.
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
FORM assign_gl_lips_delqty_200_1 .

  CLEAR: wa_vepo[], wa_vepo.

* 원래 지정되어 있던것과 미지정에서 온것들을 구분하여 modify한다.
* item1/posnr/vbeln 값 처리.
  SORT gl_vepo BY exidv.
  LOOP AT gt_assg WHERE chk = 'X'.
    LOOP AT gl_vepo WHERE exidv = gt_assg-exidv
                      AND place = 'A'.
      IF gl_vepo-orgin = 'A'.
        LOOP AT gl_lips WHERE matnr = gl_vepo-matnr
                          AND sobkz = gl_vepo-sobkz
                          AND sonum = gl_vepo-sonum
                          AND charg = gl_vepo-charg
                          AND item1 = gl_vepo-item1
                          AND vbeln = gl_vepo-vbeln
                          AND posnr = gl_vepo-posnr.  "?
          gl_lips-delqty = gl_lips-delqty - gl_vepo-vemng.
          MODIFY gl_lips.
          EXIT.
        ENDLOOP.
      ELSE.
        LOOP AT gl_lips WHERE matnr = gl_vepo-matnr
                          AND sobkz = gl_vepo-sobkz
                          AND sonum = gl_vepo-sonum
                          AND charg = gl_vepo-charg
                          AND item1 = gl_vepo-item1.
          gl_lips-delqty = gl_lips-delqty - gl_vepo-vemng.
          MODIFY gl_lips.
          EXIT.
        ENDLOOP.
      ENDIF.

      IF sy-subrc = 0.
        DELETE gl_vepo.

        MOVE-CORRESPONDING gl_vepo   TO wa_vepo.
*        wa_vepo-item1 = ' '.                        "?
        wa_vepo-place = 'N'.
        APPEND wa_vepo.
      ENDIF.
    ENDLOOP.
  ENDLOOP.

  DELETE gl_lips WHERE sub = '2'
                   AND delqty = 0.

  LOOP AT wa_vepo.
    MOVE-CORRESPONDING wa_vepo  TO gl_vepo.
    COLLECT gl_vepo.  CLEAR: gl_vepo.
  ENDLOOP.

*/ ICON SETTING
  wa_lips2[] = gl_lips[].

  LOOP AT gl_lips WHERE icon1 <> ' '
                    AND sub   = '1'.
    READ TABLE wa_lips2 WITH KEY item1 = gl_lips-item1
                                 sub   = '2'.
    IF sy-subrc <> 0.
      gl_lips-icon1 = ' '.
      MODIFY gl_lips TRANSPORTING icon1.
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
FORM save_200 .

  PERFORM pop_up_confirm(zler0004) USING '< 확인 >'
                               '저장하시겠읍니까?'
                      CHANGING gv_return.

  CHECK gv_return = 'J'.

*  PERFORM prepare_dataset_hu.

  PERFORM prepare_save_200.

  PERFORM bdc_run_hu
     USING p_wadat_ist tvrot-route t173t-vsart.

ENDFORM.                                                    " save_200
*&---------------------------------------------------------------------*
*&      Form  prepare_save_200
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM prepare_save_200 .

  CLEAR: gt_tab1[], gt_tab1,
         gt_tab2[], gt_tab2,
         gt_tab3[], gt_tab3.
  CLEAR: gt_tab4[], gt_tab4,
         gt_tab5[], gt_tab5,
         gt_tab6[], gt_tab6.

  SORT gl_vepo BY exidv.
*/ 포장풀기
*  PERFORM get_data_pojang_disconect_1.
  PERFORM get_data_pojang_disconect.

*/ 포장하기
*  PERFORM get_data_pojang_conect_1.
  PERFORM get_data_pojang_conect.

*/ #3. 지시수량
  PERFORM get_data_jisiqty.

ENDFORM.                    " prepare_save_200
*&---------------------------------------------------------------------*
*&      Form  get_data_pojang_conect
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_data_pojang_conect .

  LOOP AT gl_lips WHERE sub = '2'.
    READ TABLE cl_lips WITH KEY item1 = gl_lips-item1
                                posnr = gl_lips-posnr.
*                                charg = gl_lips-charg.
    IF sy-subrc = 0.
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
      gt_tab2-uecha = gl_lips-item1.
      gt_tab2-lgort = gl_lips-lgort.
      gt_tab2-charg = gl_lips-charg.
      gt_tab2-lfimg = gl_lips-delqty.
      gt_tab2-vrkme = gl_lips-vrkme.
      APPEND gt_tab2.  CLEAR: gt_tab2.

      gt_tab1-posnr = gl_lips-item1.
      gt_tab1-vrkme = gl_lips-vrkme.
      COLLECT gt_tab1. CLEAR: gt_tab1.
    ENDIF.
  ENDLOOP.

  LOOP AT gt_tab1.
    READ TABLE gl_lips WITH KEY posnr = gt_tab1-posnr
                                sub   = '1'.
    IF sy-subrc = 0.
      gt_tab1-lfimg = gl_lips-jisiqty.
      MODIFY gt_tab1.
    ENDIF.
  ENDLOOP.

  LOOP AT gl_vepo WHERE place = 'A'.
    READ TABLE cl_vepo WITH KEY exidv = gl_vepo-exidv
                                place = 'N'.
    IF sy-subrc = 0.
      gt_tab3-exidv = gl_vepo-exidv.
      COLLECT gt_tab3.
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
FORM get_data_pojang_disconect .

  LOOP AT cl_lips WHERE sub = '2'.
    READ TABLE gl_lips WITH KEY item1 = cl_lips-item1
                                posnr = cl_lips-posnr.
*                                charg = cl_lips-charg.
    IF sy-subrc = 0.
      IF cl_lips-delqty <> gl_lips-delqty.
        gt_tab4-posnr = cl_lips-item1.
        COLLECT gt_tab4.

        gt_tab5-uecha = cl_lips-item1.
        gt_tab5-posnr = cl_lips-posnr.
        gt_tab5-lfimg = gl_lips-delqty.
        APPEND gt_tab5.
      ENDIF.
    ELSE.
      gt_tab4-posnr = cl_lips-item1.
      COLLECT gt_tab4.

      gt_tab5-uecha = cl_lips-item1.
      gt_tab5-posnr = cl_lips-posnr.
      gt_tab5-lfimg = 0.
      APPEND gt_tab5.
    ENDIF.
  ENDLOOP.
*
  LOOP AT cl_lips WHERE sub = '1'
                    AND ( xchpf = ' ' OR fixed = 'X' ).
    READ TABLE gl_lips WITH KEY item1 = cl_lips-item1.
    IF sy-subrc = 0.
      IF cl_lips-delqty <> gl_lips-delqty.
        gt_tab4-posnr = cl_lips-item1.
        COLLECT gt_tab4.  CLEAR: gt_tab4.
      ENDIF.
    ENDIF.
  ENDLOOP.
*

  LOOP AT gl_vepo WHERE place = 'N'.
    READ TABLE cl_vepo WITH KEY exidv = gl_vepo-exidv
                                place = 'A'.
    IF sy-subrc = 0.
      gt_tab6-exidv = gl_vepo-exidv.
      COLLECT gt_tab6.
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
FORM bdc_run_hu  USING   v_wadat v_route v_vsart.

  PERFORM dequeue_all.

  CALL FUNCTION 'Z_LE_VL02N_POJANG2'
    EXPORTING
      i_vbeln  = p_vbeln
      i_wadat  = v_wadat
      i_route  = v_route
      i_vsart  = v_vsart
      i_mode   = bdc_mode
    IMPORTING
      return   = gv_result
      zmessage = gv_msg
    TABLES
      pt_data1 = gt_tab1
      pt_data2 = gt_tab2
      pt_data3 = gt_tab3
      pt_data4 = gt_tab4
      pt_data5 = gt_tab5
      pt_data6 = gt_tab6
      pt_data7 = gt_tab7
      pt_data8 = gt_tab8.
  IF gv_result = 'S'.
*/ SAVE SHIPPING NO. - LONG TEXT
    PERFORM save_shipping_no .

*{ 기능개선 91460 - 추가
*___배치지정 저장 후 피킹 실행
    PERFORM make_picking_data_200_1.

    PERFORM call_transaction_vl02n.
*} 기능개선 91460 - 추가

*    perform enqueue_rock using p_vbeln.

    CLEAR: r_vbeln[], r_vbeln, et_likp[], et_likp.
    PERFORM get_range_vbeln USING p_vbeln.
    PERFORM data_query TABLES et_likp
                              r_vbeln.
    LOOP AT et_likp.
      LOOP AT gt_likp WHERE vbeln = et_likp-vbeln.
        MOVE-CORRESPONDING et_likp TO gt_likp.
        gt_likp-wadat_ist = sy-datum.
        MODIFY gt_likp .
      ENDLOOP.
    ENDLOOP.

    gv_save_flag = 'X'.
    PERFORM get_detail.

*    LEAVE TO SCREEN 100.
    MESSAGE s001 WITH p_vbeln '저장하였습니다'.
  ELSE.
    MESSAGE i002 WITH p_vbeln gv_msg '저장하지 못했습니다'.
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
FORM get_data_jisiqty .

  CLEAR: gt_tab8[], gt_tab8.

  LOOP AT gl_lips WHERE sub = '1'.
    LOOP AT cl_lips WHERE sub = '1'
                      AND item1 = gl_lips-item1
                      AND jisiqty <> gl_lips-jisiqty.
      gt_tab8-posnr = gl_lips-posnr.
      gt_tab8-lfimg = gl_lips-jisiqty.
      gt_tab8-vrkme = gl_lips-vrkme.
      APPEND gt_tab8.
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
FORM save_shipping_no .

  DATA : BEGIN OF lt_th OCCURS 10.
           INCLUDE STRUCTURE thead.
  DATA : END   OF lt_th.

  DATA : BEGIN OF lt_tl OCCURS 10.
           INCLUDE STRUCTURE tline.
  DATA : END OF lt_tl.

  DATA  function_update(1) TYPE c VALUE 'U'.

  REFRESH: lt_tl, lt_th.
  CLEAR  : lt_tl, lt_th.


  LOOP AT gt_ship.
    REFRESH: lt_tl.
    CLEAR  : lt_tl.

    gv_object    = 'VBBP'.
    gv_object_id = 'Z990'.

    lt_th-tdobject = gv_object.
    CONCATENATE gt_ship-vbeln gt_ship-posnr INTO gv_vbeln.
    lt_th-tdname   = gv_vbeln.     "
    lt_th-tdid     = gv_object_id.   "'001'. " Text ID
    lt_th-tdspras  = sy-langu.
    lt_tl-tdformat = '*'.
    lt_tl-tdline = gt_ship-shipping_no.
    APPEND lt_tl.

    CALL FUNCTION 'SAVE_TEXT'
      EXPORTING
        client          = sy-mandt
        header          = lt_th
        savemode_direct = 'X'
      IMPORTING
        function        = function_update
        newheader       = lt_th
      TABLES
        lines           = lt_tl
      EXCEPTIONS
        id              = 1
        language        = 2
        name            = 3
        object          = 4
        OTHERS          = 5.
    IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    ENDIF.
  ENDLOOP.

  REFRESH: gt_ship.
  CLEAR  : gt_ship.

ENDFORM.                    " save_shipping_no
*&---------------------------------------------------------------------*
*&      Form  READ_TEXT_SHIP_NO
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM read_text_ship_no .

  gv_object    = 'VBBP'.
  gv_object_id = 'Z990'.

  LOOP AT gl_lips WHERE sub = '1'.
    REFRESH: gt_tline. CLEAR: gt_tline.
    CONCATENATE gl_lips-vbeln gl_lips-posnr INTO gv_vbeln.
    PERFORM read_order_long_text(zler0001)
         TABLES gt_tline[]
         USING gv_object_id  gv_vbeln gv_object.
    READ TABLE gt_tline INDEX 1.
    IF sy-subrc = 0.
      gl_lips-shipping_no = gt_tline-tdline.
    ENDIF.
    MODIFY gl_lips.
  ENDLOOP.

ENDFORM.                    " READ_TEXT_SHIP_NO
*&---------------------------------------------------------------------*
*&      Form  APPEND_LFART
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_0077   text
*----------------------------------------------------------------------*
FORM append_lfart  USING    p_xx.

  r_lfart-sign   = 'I'.
  r_lfart-option = 'EQ'.
  r_lfart-low    = p_xx.
  APPEND r_lfart.

ENDFORM.                    " APPEND_LFART
*&---------------------------------------------------------------------*
*&      Form  char_fltp_conversion
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_LT_CHAR_VALUE  text
*      <--P_PV_LENGTH  text
*----------------------------------------------------------------------*
FORM char_fltp_conversion  USING    pv_value_s
                           CHANGING pv_value_p.

  DATA: lv_fltp     LIKE rscvp-valu1,
        lv_pack(16) TYPE p DECIMALS 3.

  CALL FUNCTION 'CHAR_FLTP_CONVERSION'
    EXPORTING
      string          = pv_value_s
    IMPORTING
      flstr           = lv_fltp
*&      ivalu           = x_ival
    EXCEPTIONS
      string_not_fltp = 1.

  pv_value_p = lv_fltp.

ENDFORM.                    " char_fltp_conversion
*&---------------------------------------------------------------------*
*&      Form  GET_DELQTY_200
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_delqty_200 .

  LOOP AT gl_lips WHERE xchpf = ' '.
    CLEAR: gv_vemng.
    LOOP AT gl_vepo WHERE item1 = gl_lips-item1.
      ADD gl_vepo-vemng  TO gv_vemng.
    ENDLOOP.
    gl_lips-delqty = gv_vemng.
    MODIFY gl_lips TRANSPORTING delqty.
  ENDLOOP.

* 2005.12.08 - 상위품목에 배치 지정.
* Requested by 허.
* - 상위품목에 배치가 바로 붙는 경우는 포장,포장해체 불가.
* - 피킹만 할수 있도록.
  LOOP AT gl_lips WHERE sub = '1'
                    AND xchpf = 'X'
                    AND charg <> ' '.
    CLEAR: gv_vemng.
    LOOP AT gl_vepo WHERE item1 = gl_lips-item1.
      ADD gl_vepo-vemng  TO gv_vemng.
    ENDLOOP.
    gl_lips-delqty = gv_vemng.
    gl_lips-fixed  = 'X'.
    MODIFY gl_lips TRANSPORTING delqty fixed.

    LOOP AT gl_vepo WHERE vbeln = gl_lips-vbeln
                      AND posnr = gl_lips-item1.
      gl_vepo-fixed = 'X'.
      MODIFY gl_vepo TRANSPORTING fixed.
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
FORM get_delqty_300 .

* 2005.12.08 - 상위품목에 배치 지정.
* Requested by 허.
* - 상위품목에 배치가 바로 붙는 경우는 포장,포장해체 불가.
* - 피킹만 할수 있도록.
  LOOP AT gl_lips WHERE sub = '1'
                    AND xchpf = 'X'
                    AND charg <> ' '.
    gl_lips-fixed  = 'X'.
    gl_lips-delqty = gl_lips-jisiqty.
    MODIFY gl_lips TRANSPORTING fixed delqty.
  ENDLOOP.

  LOOP AT gl_lips WHERE xchpf = ' '.
    SELECT SINGLE rfmng INTO gl_lips-delqty FROM vbfa
                       WHERE vbelv   = gl_lips-vbeln
                         AND posnv   = gl_lips-posnr
                         AND vbtyp_n = 'Q'.
      IF sy-subrc <> 0.
        gl_lips-delqty = 0.
      ENDIF.
      MODIFY gl_lips  TRANSPORTING delqty.
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
FORM refresh_detail .

  PERFORM dequeue_all.

  CLEAR: r_vbeln[], r_vbeln, et_likp[], et_likp.
  PERFORM get_range_vbeln USING p_vbeln.
  PERFORM data_query TABLES et_likp
                            r_vbeln.
  LOOP AT et_likp.
    LOOP AT gt_likp WHERE vbeln = et_likp-vbeln.
      MOVE-CORRESPONDING et_likp TO gt_likp.
      gt_likp-wadat_ist = sy-datum.
      MODIFY gt_likp .
    ENDLOOP.
  ENDLOOP.

  gv_save_flag = 'X'.
  PERFORM get_detail.

ENDFORM.                    " REFRESH_DETAIL
*&---------------------------------------------------------------------*
*&      Form  conversion_unit_200
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM conversion_unit_200 .

  LOOP AT gl_vepo.
    READ TABLE gl_lips WITH KEY matnr = gl_vepo-matnr
                                sobkz = gl_vepo-sobkz.
    IF sy-subrc = 0.
      IF gl_vepo-vemeh <> gl_lips-vrkme.
        IF NOT gl_lips-umvkz IS INITIAL.
          gl_vepo-vemng = gl_vepo-vemng * gl_lips-umvkn / gl_lips-umvkz.
          gl_vepo-vemeh = gl_lips-vrkme.
          MODIFY gl_vepo TRANSPORTING vemng vemeh.
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
FORM get_batch_info .

  DATA: lv_field(30).

*  lv_field = g_cursor_field+0(7).
  lv_field = g_cursor_field+0(15).
  READ TABLE gl_lips WITH KEY chk = 'X'.
  IF lv_field = 'GT_ASSG-VEMNG'.
    i_cursor_line = tc03-current_line + i_cursor_line - 1.
    READ TABLE gt_assg INDEX i_cursor_line.
    CHECK sy-subrc = 0.
    CLEAR: gt_detl[].
    LOOP AT gl_vepo WHERE exidv = gt_assg-exidv
                      AND matnr = gl_lips-matnr
                      AND sobkz = gl_lips-sobkz
                      AND sonum = gl_lips-sonum.
      MOVE-CORRESPONDING gl_vepo  TO gt_detl.
      COLLECT gt_detl.
    ENDLOOP.

    CALL SCREEN 210 STARTING AT 1  20
                    ENDING   AT 30 28.

  ELSEIF lv_field = 'GT_NASG-VEMNG'.
    i_cursor_line = tc04-current_line + i_cursor_line - 1.
    READ TABLE gt_nasg INDEX i_cursor_line.
    CHECK sy-subrc = 0.
    CLEAR: gt_detl[].
    LOOP AT gl_vepo WHERE exidv = gt_nasg-exidv
                      AND matnr = gl_lips-matnr
                      AND sobkz = gl_lips-sobkz
                      AND sonum = gl_lips-sonum.
      MOVE-CORRESPONDING gl_vepo  TO gt_detl.
      COLLECT gt_detl.
    ENDLOOP.

    CALL SCREEN 210 STARTING AT 1  20
                    ENDING   AT 30 28.

  ELSEIF lv_field = 'GT_ASSG-EXIDV'.
    i_cursor_line = tc03-current_line + i_cursor_line - 1.
    READ TABLE gt_assg INDEX i_cursor_line.
    CHECK sy-subrc = 0.
    PERFORM call_tcode_humo USING gt_assg-exidv.

  ELSEIF lv_field = 'GT_NASG-EXIDV'.
    i_cursor_line = tc04-current_line + i_cursor_line - 1.
    READ TABLE gt_nasg INDEX i_cursor_line.
    CHECK sy-subrc = 0.
    PERFORM call_tcode_humo USING gt_nasg-exidv.

  ELSEIF lv_field = 'GT_LIPS-MATNR'.
    IF sy-dynnr = '0200'.
      i_cursor_line = tc02-current_line + i_cursor_line - 1.
    ELSEIF sy-dynnr = '0300'.
      i_cursor_line = tc12-current_line + i_cursor_line - 1.
    ENDIF.

    READ TABLE gt_lips INDEX i_cursor_line.
    CHECK sy-subrc = 0.
    SET PARAMETER ID 'MAT' FIELD gt_lips-matnr.
    CALL TRANSACTION 'MM03'.

  ELSEIF lv_field = 'GT_LIPS-VGBEL'.
    IF sy-dynnr = '0200'.
      i_cursor_line = tc02-current_line + i_cursor_line - 1.
    ELSEIF sy-dynnr = '0300'.
      i_cursor_line = tc12-current_line + i_cursor_line - 1.
    ENDIF.

    READ TABLE gt_lips INDEX i_cursor_line.
    CHECK sy-subrc = 0.
    IF gt_likp-lfart = 'NL'.
      SET PARAMETER ID 'BES' FIELD gt_lips-vgbel.
      CALL TRANSACTION 'ME23N'.
    ELSE.
      SET PARAMETER ID 'AUN' FIELD gt_lips-vgbel.
      CALL TRANSACTION 'VA03' AND SKIP  FIRST SCREEN.
    ENDIF.

  ELSEIF lv_field = 'P_VBELN'.
    SET PARAMETER ID 'VL' FIELD p_vbeln.
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
FORM batch_sort_char_200 .

*/ 배치특성(정렬순서: CU72)
  REFRESH: gt_ksml.
  LOOP AT gl_lips WHERE sub = '1'.
    PERFORM get_sort_batch_characteristic USING gl_lips-matnr.
  ENDLOOP.

  LOOP AT gl_vepo.
* 배치특성을 구하고, 정렬순서와 비교하여 순번을 매겨서
* 재정렬한다.
    REFRESH: gt_ausp.
    PERFORM batch_characteristic TABLES gt_ausp
                                 USING gl_vepo-matnr
                                       gl_vepo-charg.
    CLEAR: lv_col_atwrt.
    SORT gt_ausp BY posnr.
    LOOP AT gt_ausp.
      CONCATENATE lv_col_atwrt gt_ausp-atwrt ';'
        INTO lv_col_atwrt." SEPARATED BY ';'.
    ENDLOOP.

    gl_vepo-chart = lv_col_atwrt+1(99).
    MODIFY gl_vepo.
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
FORM cannot_assign .



ENDFORM.                    " CANNOT_ASSIGN
*&---------------------------------------------------------------------*
*&      Form  conversion_unit_300
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM conversion_unit_300 .

  LOOP AT xl_nasg.
    READ TABLE gl_lips WITH KEY item1 = xl_nasg-item1.
    IF sy-subrc = 0.
      IF gl_lips-meins <> gl_lips-vrkme.
        IF NOT gl_lips-umvkz IS INITIAL.
          xl_nasg-length =
            xl_nasg-length * gl_lips-umvkn / gl_lips-umvkz.
          xl_nasg-labst =
            xl_nasg-labst * gl_lips-umvkn / gl_lips-umvkz.

          MODIFY xl_nasg TRANSPORTING length labst.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDLOOP.

  LOOP AT xl_assg.
    READ TABLE gl_lips WITH KEY item1 = xl_assg-item1.
    IF sy-subrc = 0.
      IF gl_lips-meins <> gl_lips-vrkme.
        IF NOT gl_lips-umvkz IS INITIAL.
          xl_assg-length =
            xl_assg-length * gl_lips-umvkn / gl_lips-umvkz.
*          xl_assg-labst =
*            xl_assg-labst * gl_lips-umvkn / gl_lips-umvkz.

          MODIFY xl_assg TRANSPORTING length labst.
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
FORM go_mmbe .

  READ TABLE gl_lips WITH KEY chk = 'X'.
  IF sy-subrc = 0.
    SET PARAMETER ID 'MAT' FIELD gl_lips-matnr.
    SET PARAMETER ID 'WRK' FIELD gl_lips-werks.
    SET PARAMETER ID 'LAG' FIELD gl_lips-lgort.
    SET PARAMETER ID 'MMBE_ME' FIELD gl_lips-vrkme.
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
FORM conversion_unit_nasg_300 .

  LOOP AT xl_nasg.
    READ TABLE gl_lips WITH KEY item1 = xl_nasg-item1.
    IF sy-subrc = 0.
      IF gl_lips-meins <> gl_lips-vrkme.
        IF NOT gl_lips-umvkz IS INITIAL.
          xl_nasg-length =
            xl_nasg-length * gl_lips-umvkn / gl_lips-umvkz.
          xl_nasg-labst =
            xl_nasg-labst * gl_lips-umvkn / gl_lips-umvkz.

          MODIFY xl_nasg TRANSPORTING length labst.
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
FORM conversion_unit_assg_300 .

  LOOP AT xl_assg.
    READ TABLE gl_lips WITH KEY item1 = xl_assg-item1.
    IF sy-subrc = 0.
      IF gl_lips-meins <> gl_lips-vrkme.
        IF NOT gl_lips-umvkz IS INITIAL.
          xl_assg-length =
            xl_assg-length * gl_lips-umvkn / gl_lips-umvkz.
*          xl_assg-labst =
*            xl_assg-labst * gl_lips-umvkn / gl_lips-umvkz.

          MODIFY xl_assg TRANSPORTING length labst.
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
FORM picking_200 .

  PERFORM error_check_picking.

  PERFORM pop_up_confirm(zler0004) USING '< 확인 >'
                               '피킹 하시겠읍니까?'
                      CHANGING gv_return.
  CHECK gv_return = 'J'.

  PERFORM make_picking_data_200.

  PERFORM bdc_run_picking
    USING p_wadat_ist tvrot-route t173t-vsart.

ENDFORM.                    " picking_200
*&---------------------------------------------------------------------*
*&      Form  make_picking_data_200
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM make_picking_data_200 .

  CLEAR: gt_tab1[], gt_tab1.
  LOOP AT gl_lips WHERE sub = '1'.
*                    AND xchpf = 'X'.
    gt_tab1-posnr = gl_lips-posnr.
    gt_tab1-pikmg = gl_lips-delqty.
    APPEND gt_tab1.
  ENDLOOP.

*  DELETE gt_tab1 WHERE pikmg = 0.

  CLEAR: gt_tab2[], gt_tab2.
  LOOP AT gl_lips WHERE sub = '2'.
*                    AND xchpf = 'X'.
    gt_tab2-uecha = gl_lips-item1.
    gt_tab2-posnr = gl_lips-posnr.
    gt_tab2-charg = gl_lips-charg.
    gt_tab2-vrkme = gl_lips-vrkme.
    gt_tab2-pikmg = gl_lips-delqty.
    APPEND gt_tab2.
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
FORM wast .

  PERFORM check_before_wast.

  DATA: gv_return.

  PERFORM pop_up_confirm(zler0004) USING '< 확인 >'
                               '출고전기 하시겠습니까?'
                      CHANGING gv_return.
  CHECK gv_return = 'J'.

  DATA: lt_msg LIKE zles009 OCCURS 0 WITH HEADER LINE.

  CLEAR: lt_msg[], lt_msg, r_vbeln[], r_vbeln.

  LOOP AT gt_likp WHERE chk  = 'X'.

    PERFORM func_wast USING gt_likp-vbeln
                            gt_likp-route
                            gt_likp-wadat_ist
                            gt_likp-vsart.
    IF gv_result = 'S'.
      PERFORM get_range_vbeln USING gt_likp-vbeln.

      CONCATENATE gt_likp-vbeln ':출고전기 하였습니다'
         INTO lt_msg-msgtx .
      DELETE gt_likp.
    ELSE.
      CONCATENATE gt_likp-vbeln ':출고전기에러:' gv_msg
         INTO lt_msg-msgtx .
    ENDIF.
    APPEND lt_msg.
  ENDLOOP.

  IF NOT lt_msg[] IS INITIAL.
    CALL FUNCTION 'Z_LE_POPUP_TO_ERROR_MESSAGE'
      TABLES
        msg_tab = lt_msg.
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
FORM check_before_wast .

  LOOP AT gt_likp WHERE chk = 'X'.
* WMS 창고는 관련없음.
    PERFORM no_exec_wms USING gt_likp-vbeln.
  ENDLOOP.

  CLEAR: gv_flag.
  LOOP AT gt_likp WHERE chk = 'X'.
    IF gt_likp-wadat_ist IS INITIAL.
      MESSAGE i001 WITH gt_likp-vbeln '실제출고일을 입력하세여'.
      gv_flag = 'X'.
    ENDIF.

    IF s_vstel-low <> 'J100' AND s_vstel-low <> 'J200'.
      IF s_vstel-low <= '6000' OR s_vstel-low >= '7999'.
        IF gt_likp-route IS INITIAL.
          MESSAGE i001 WITH gt_likp-vbeln '운송경로를 입력하세여'.
          gv_flag = 'X'.
        ENDIF.
      ENDIF.
    ENDIF.

  ENDLOOP.
  IF sy-subrc <> 0.
    gv_flag = 'X'.
    MESSAGE s000 WITH 'G/I 대상 납품을 선택하세여'.
  ENDIF.
  IF gv_flag = 'X'.
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
FORM no_exec_wms  USING    p_vbeln.

  DATA: lt_lips LIKE lips OCCURS 0 WITH HEADER LINE.

  SELECT * INTO CORRESPONDING FIELDS OF TABLE lt_lips
   FROM lips
  WHERE vbeln = p_vbeln.

    LOOP AT lt_lips .
      SELECT SINGLE mandt INTO sy-mandt FROM t320
        WHERE werks = lt_lips-werks
          AND lgort = lt_lips-lgort.
        IF sy-subrc = 0.
          MESSAGE i000 WITH
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
FORM same_batch_modi_na .

  LOOP AT gt_nasg WHERE chk = 'X'.
    LOOP AT gl_vepo WHERE exidv = gt_nasg-exidv
                      AND place = 'N'.
      CLEAR: gv_vemng, gv_flag.
      LOOP AT gl_lips WHERE matnr = gl_vepo-matnr
                        AND sobkz = gl_vepo-sobkz
                        AND sonum = gl_vepo-sonum
                        AND charg = gl_vepo-charg
                        AND fixed = ' '
                        AND calcu = ' '.
        PERFORM calculate_lips USING '1' gv_return.
        IF gv_return = 'X'.
          EXIT.
        ENDIF.
      ENDLOOP.

      IF sy-subrc = 0 AND gv_flag = ' '.
        gl_vepo-vemng = gl_vepo-vemng - gv_vemng.
        MODIFY gl_vepo.

        CLEAR: wa_vepo[], wa_vepo.
        MOVE-CORRESPONDING gl_vepo   TO wa_vepo.
        wa_vepo-place = 'A'.
        wa_vepo-vemng = gv_vemng.
        wa_vepo-item1 = gl_lips-item1.
        APPEND wa_vepo.

        LOOP AT wa_vepo.
          MOVE-CORRESPONDING wa_vepo  TO gl_vepo.
          APPEND gl_vepo.
        ENDLOOP.

        DELETE gl_vepo WHERE vemng = 0.

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
FORM batch_append_na .

  LOOP AT gt_nasg WHERE chk = 'X'.
    LOOP AT gl_vepo WHERE exidv = gt_nasg-exidv
                      AND orgin = 'A'
                      AND place = 'N'.
      CLEAR: gv_vemng, gv_flag.
      LOOP AT gl_lips WHERE matnr = gl_vepo-matnr
                        AND sobkz = gl_vepo-sobkz
                        AND sonum = gl_vepo-sonum
                        AND item1 = gl_vepo-item1
                        AND xchpf = 'X'
                        AND sub   = '1'
                        AND fixed = ' '
                        AND calcu = ' '.
        PERFORM calculate_lips USING '2' gv_return.
        IF gv_return = 'X'.
          EXIT.
        ENDIF.
      ENDLOOP.

      IF sy-subrc = 0 AND gv_flag = ' '.
        DELETE gl_vepo.

        CLEAR: wa_vepo[], wa_vepo.
        MOVE-CORRESPONDING gl_vepo   TO wa_vepo.
        wa_vepo-vemng = gl_vepo-vemng - gv_vemng.  "미지정수량
        APPEND wa_vepo.

        wa_vepo-place = 'A'.
        wa_vepo-vemng = gv_vemng.                  "지정수량
        wa_vepo-item1 = gl_lips-item1.
        APPEND wa_vepo.

        DELETE wa_vepo WHERE vemng = 0.

        LOOP AT wa_vepo.
          MOVE-CORRESPONDING wa_vepo  TO gl_vepo.
          APPEND gl_vepo.
        ENDLOOP.

        CLEAR: wa_lips1[], wa_lips1.
        wa_lips1-vbeln  = gl_vepo-vbeln.
        wa_lips1-posnr  = gl_vepo-posnr.
        wa_lips1-werks  = gl_lips-werks.
        wa_lips1-lgort  = gl_lips-lgort.
        wa_lips1-matnr  = gl_lips-matnr.
        wa_lips1-sobkz  = gl_lips-sobkz.
        wa_lips1-sonum  = gl_lips-sonum.
        wa_lips1-item1  = gl_lips-item1.
        wa_lips1-vrkme  = gl_lips-vrkme.
        wa_lips1-arktx  = gl_lips-arktx.
        wa_lips1-sub    = '2'.
        wa_lips1-charg  = gl_vepo-charg.
        wa_lips1-delqty = gv_vemng.

*{ 기능개선 145969 - 추가
        IF gl_lips-sobkz IS NOT INITIAL.
          wa_lips1-vgbel = gl_lips-sonum(10).
          wa_lips1-vgpos = gl_lips-sonum+10(6).
        ENDIF.
*} 기능개선 145969 - 추가

        APPEND wa_lips1.

        LOOP AT wa_lips1.
          MOVE-CORRESPONDING wa_lips1  TO gl_lips.
          COLLECT gl_lips.
        ENDLOOP.

      ENDIF.
    ENDLOOP.
  ENDLOOP.

  LOOP AT gt_nasg WHERE chk = 'X'.
    LOOP AT gl_vepo WHERE exidv = gt_nasg-exidv
                      AND orgin = 'N'
                      AND place = 'N'.
      CLEAR: gv_vemng, gv_flag.
      LOOP AT gl_lips WHERE matnr = gl_vepo-matnr
                        AND sobkz = gl_vepo-sobkz
                        AND sonum = gl_vepo-sonum
*                        and item1 = gl_vepo-item1
                        AND xchpf = 'X'
                        AND sub   = '1'
                        AND fixed = ' '
                        AND calcu = ' '.
        PERFORM calculate_lips USING '2' gv_return.
        IF gv_return = 'X'.
          EXIT.
        ENDIF.
      ENDLOOP.

      IF sy-subrc = 0 AND gv_flag = ' '.
        DELETE gl_vepo.

        CLEAR: wa_vepo[], wa_vepo.
        MOVE-CORRESPONDING gl_vepo   TO wa_vepo.
        wa_vepo-vemng = gl_vepo-vemng - gv_vemng.  "미지정수량
        APPEND wa_vepo.

        wa_vepo-place = 'A'.
        wa_vepo-vemng = gv_vemng.                  "지정수량
        wa_vepo-item1 = gl_lips-item1.
        APPEND wa_vepo.

        DELETE wa_vepo WHERE vemng = 0.

        LOOP AT wa_vepo.
          MOVE-CORRESPONDING wa_vepo  TO gl_vepo.
          APPEND gl_vepo.
        ENDLOOP.

        CLEAR: wa_lips1[], wa_lips1.
        wa_lips1-vbeln  = gl_vepo-vbeln.
        wa_lips1-posnr  = gl_vepo-posnr.
        wa_lips1-werks  = gl_lips-werks.
        wa_lips1-lgort  = gl_lips-lgort.
        wa_lips1-matnr  = gl_lips-matnr.
        wa_lips1-sobkz  = gl_lips-sobkz.
        wa_lips1-sonum  = gl_lips-sonum.
        wa_lips1-item1  = gl_lips-item1.
        wa_lips1-vrkme  = gl_lips-vrkme.
        wa_lips1-arktx  = gl_lips-arktx.
        wa_lips1-sub    = '2'.
        wa_lips1-charg  = gl_vepo-charg.
        wa_lips1-delqty = gv_vemng.

*{ 기능개선 145969 - 추가
        IF gl_lips-sobkz IS NOT INITIAL.
          wa_lips1-vgbel = gl_lips-sonum(10).
          wa_lips1-vgpos = gl_lips-sonum+10(6).
        ENDIF.
*} 기능개선 145969 - 추가

        APPEND wa_lips1.

        LOOP AT wa_lips1.
          MOVE-CORRESPONDING wa_lips1  TO gl_lips.
          COLLECT gl_lips.
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
