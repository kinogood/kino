*&---------------------------------------------------------------------*
*& Include          ZGTLER2100F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form initialization
*&---------------------------------------------------------------------*
FORM initialization .

**
* 납품출고일
  IF s_wadat[] IS INITIAL.
    s_wadat[] = VALUE #( ( sign = 'I'  option = 'BT'
                           low  = |{ sy-datum+0(6) }| && |{ '01' }|
                           high = sy-datum ) ).
  ENDIF.

* 전기일자
  IF p_budat IS INITIAL.
    p_budat = sy-datum.
  ENDIF.

**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form modify_screen_1000
*&---------------------------------------------------------------------*
FORM modify_screen_1000 .

**
  LOOP AT SCREEN.

    IF     screen-group1 = 'ORG'.
      screen-input = 0.
      MODIFY SCREEN.

    ELSEIF screen-group1 = 'SC1'.
      IF rb2 = 'X'.
        screen-active = 0.
        MODIFY SCREEN.
      ELSE.
        screen-active = 1.
        MODIFY SCREEN.
      ENDIF.

    ENDIF.

  ENDLOOP.

**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form authority_check
*&---------------------------------------------------------------------*
FORM authority_check .

  DATA: lv_subrc LIKE sy-subrc,
        lv_type  TYPE char1.

**
  SELECT *  INTO TABLE @DATA(lt_tvst)
    FROM tvst  WHERE vstel IN @s_vstel.

  CLEAR: lv_type .
  lv_type = '3'.

  LOOP AT lt_tvst  INTO DATA(ls_tvst).

    CLEAR : lv_subrc.
    CALL FUNCTION 'Z_LE_AUTHORIZATION_CHECK'
      EXPORTING
        i_vstel = ls_tvst-vstel
        i_type  = lv_type
      IMPORTING
        e_subrc = lv_subrc.

    IF lv_subrc <> 0.
*     출하지점 &1에 대한 권한이 없습니다.
      MESSAGE e019 WITH ls_tvst-vstel.
      EXIT.
    ENDIF.

  ENDLOOP.

**
  FREE: lt_tvst.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form f4_werks
*&---------------------------------------------------------------------*
FORM f4_werks  CHANGING pe_werks.

  DATA: lt_return  TYPE TABLE OF ddshretval.

**
  SELECT b~werks, b~name1
    FROM t001k AS a  INNER JOIN t001w AS b
                     ON a~bwkey = b~bwkey
   WHERE a~bukrs = '6000'
    INTO TABLE @DATA(lt_werks).

  CHECK: lt_werks[] IS NOT INITIAL.

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      retfield        = 'WERKS'
      dynpprog        = sy-cprog
      dynpnr          = sy-dynnr
*     dynprofield     = pe_werks
      value_org       = 'S'
    TABLES
      value_tab       = lt_werks
      return_tab      = lt_return
    EXCEPTIONS
      parameter_error = 1
      no_values_found = 2
      OTHERS          = 3.

  pe_werks = VALUE #( lt_return[ 1 ]-fieldval  OPTIONAL ).

**
  FREE: lt_werks, lt_return.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form f4_vstel
*&---------------------------------------------------------------------*
FORM f4_vstel  CHANGING pe_vstel.

  DATA: lt_return TYPE TABLE OF ddshretval,
        lt_dynp   TYPE TABLE OF dynpread,

        lr_werks  TYPE RANGE OF werks_d.

**
  _clear: lr_werks.
  IF s_werks[] IS NOT INITIAL.
    lr_werks[] = CORRESPONDING #( s_werks[] ).
  ELSE.

    _clear: lt_dynp.
    lt_dynp = VALUE #( ( fieldname = 'S_WERKS-LOW' )
                       ( fieldname = 'S_WERKS-HIGH' ) ).

    CALL FUNCTION 'DYNP_VALUES_READ'
      EXPORTING
        dyname               = sy-cprog
        dynumb               = sy-dynnr
        request              = 'A'
      TABLES
        dynpfields           = lt_dynp
      EXCEPTIONS
        invalid_abapworkarea = 1
        invalid_dynprofield  = 2
        invalid_dynproname   = 3
        invalid_dynpronummer = 4
        invalid_request      = 5
        no_fielddescription  = 6
        invalid_parameter    = 7
        undefind_error       = 8
        double_conversion    = 9
        stepl_not_found      = 10
        OTHERS               = 11.

    DATA(lv_werks_l) = VALUE #( lt_dynp[ fieldname = 'S_WERKS-LOW' ]-fieldvalue
                                OPTIONAL ).
    DATA(lv_werks_h) = VALUE #( lt_dynp[ fieldname = 'S_WERKS-HIGH' ]-fieldvalue
                                OPTIONAL ).
    IF     lv_werks_l IS NOT INITIAL AND
           lv_werks_h IS NOT INITIAL.
      lr_werks = VALUE #( ( sign = 'I'        option = 'BT'
                            low  = lv_werks_l high   = lv_werks_h ) ).

    ELSEIF lv_werks_l IS NOT INITIAL AND
           lv_werks_h IS INITIAL.
      lr_werks = VALUE #( ( sign = 'I'  option = 'EQ'
                            low  = lv_werks_l ) ).

    ELSEIF lv_werks_l IS INITIAL AND
           lv_werks_h IS NOT INITIAL.
      lr_werks = VALUE #( ( sign = 'I'  option = 'EQ'
                            low  = lv_werks_h ) ).

    ENDIF.

  ENDIF.

  CHECK: lr_werks[] IS NOT INITIAL.

  SELECT a~werks, a~vstel, b~vtext
    FROM tvswz AS a  INNER JOIN tvstt AS b
                     ON  a~vstel EQ b~vstel
                     AND b~spras EQ @sy-langu
   WHERE a~werks IN @lr_werks
    INTO TABLE @DATA(lt_vstel).


  CHECK: lt_vstel[] IS NOT INITIAL.

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      retfield        = 'VSTEL'
      dynpprog        = sy-cprog
      dynpnr          = sy-dynnr
      value_org       = 'S'
    TABLES
      value_tab       = lt_vstel
      return_tab      = lt_return
    EXCEPTIONS
      parameter_error = 1
      no_values_found = 2
      OTHERS          = 3.

  pe_vstel = VALUE #( lt_return[ 1 ]-fieldval  OPTIONAL ).

**
  FREE: lt_vstel, lt_return.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form start_process
*&---------------------------------------------------------------------*
FORM start_process .

**
  CLEAR: gv_error.

  PERFORM get_data.

  PERFORM make_head_item_data.

**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form get_data
*&---------------------------------------------------------------------*
FORM get_data .

  DATA: lr_route  TYPE RANGE OF route.

**
  _clear: lr_route.
  lr_route = VALUE #( ( sign = 'I'  option = 'CP'
                        low  = '*001' ) ).

  _clear: gt_data.
* 납품 Header/Detail 에서 발췌 Option에 맞게 Data를 발췌한다.
  SELECT a~vbeln, a~vstel, a~lfdat, a~kodat,
         a~route, a~kunnr, a~kunag, a~wadat,
         a~ablad, a~wadat_ist,
         b~zmigo, b~posnr, b~matnr, b~charg,
         CASE b~werks  WHEN '6500' THEN '6591'
                       WHEN '6600' THEN '6691'
         END AS werks,
         b~lgort, b~meins, b~lfimg,
         b~vrkme, b~vgbel, b~vgpos, b~xchar,
         b~ntgew, b~brgew, b~gewei, b~volum,
         b~voleh, b~uecha, b~zmblnr
    FROM likp AS a  INNER JOIN lips AS b
                    ON a~vbeln EQ b~vbeln
   WHERE a~vstel     IN @s_vstel       "출하지점/입고지점
     AND a~vkorg     IN @s_vkorg       "영업조직
     AND a~vbeln     IN @s_vbeln       "납품문서
     AND a~wadat_ist IN @s_wadat
     AND a~kunnr     IN @s_kunnr       "납품처
     AND a~kunag     IN @s_kunag       "판매처
     AND a~route     IN @lr_route
     AND a~wbstk     EQ 'C'            "출고전기 된놈
     AND b~vgbel     IN @s_ternr
     AND b~werks     IN @s_werks
    INTO CORRESPONDING FIELDS OF TABLE @gt_data.

* 대상제외
  SORT: gt_data BY vbeln posnr.
* Batch 가 존재하는 품목
  DELETE: gt_data WHERE xchar = 'X'
                    AND charg = ' '.

  IF rb1 = 'X'.
*   기입고 된 납품제외
    DELETE: gt_data WHERE zmigo = 'X'.
  ELSE.
*   취소시 입고된 납품만
    DELETE: gt_data WHERE zmigo = ' '.
  ENDIF.

**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form make_head_item_data
*&---------------------------------------------------------------------*
FORM make_head_item_data .

  DATA: ls_item  LIKE gt_item.
**
  CHECK: gt_data[] IS NOT INITIAL.

  DATA(lt_data) = gt_data[].

* ZCS 주문번호 확인
  SELECT b~vgbel, b~vgpos, b~vbeln, b~posnr
    FROM @lt_data AS a  INNER JOIN vbap AS b
                        ON  a~vgbel EQ b~vgbel
                        AND b~vgpos EQ b~vgpos
   WHERE b~pstyv EQ 'ZCS'
     AND b~abgru EQ @space
    INTO TABLE @DATA(lt_va).

  IF lt_va[] IS NOT INITIAL.

    SORT: lt_va BY vgbel vgpos.
    DELETE ADJACENT DUPLICATES FROM lt_va COMPARING vgbel vgpos.

*   Check MSKA
    SELECT a~vbeln, a~posnr,
           b~matnr, b~charg, b~kalab
      FROM @lt_va AS a  INNER JOIN mska AS b
                        ON  a~vbeln EQ b~vbeln
                        AND a~posnr EQ b~posnr
      INTO TABLE @DATA(lt_mska).

  ENDIF.

* 자재 품명
  SELECT a~matnr, b~maktx
    FROM @lt_data AS a  INNER JOIN makt AS b
                        ON  a~matnr EQ b~matnr
                        AND b~spras EQ @sy-langu
    INTO TABLE @DATA(lt_makt).

* Picking 수량
  SELECT a~vbeln, a~posnr, b~rfmng
    FROM @lt_data AS a  INNER JOIN vbfa AS b
                        ON  a~vbeln   EQ b~vbelv
                        AND a~posnr   EQ b~posnv
                        AND b~vbtyp_n EQ 'Q'
    INTO TABLE @DATA(lt_vbfa).

  _clear: gt_head, gt_item, gt_item_temp.

** =======================================================================
**  -- [1] 납품문서별 저장위치(LGORT) 상이 여부 사전 검증
** =======================================================================
  TYPES: BEGIN OF ty_diff,
           vbeln TYPE vbeln_vl,
           flag  TYPE char1,
         END OF ty_diff.
  DATA lt_diff_lgort TYPE STANDARD TABLE OF ty_diff.

  LOOP AT gt_data INTO DATA(ls_chk_data)
                  GROUP BY ( vbeln = ls_chk_data-vbeln )
                  ASSIGNING FIELD-SYMBOL(<group>).

    DATA(lv_diff)       = space.
    DATA(lv_base_lgort) = space.
    DATA(lv_is_first)   = abap_true.

    LOOP AT GROUP <group> ASSIGNING FIELD-SYMBOL(<member>).
      IF lv_is_first EQ abap_true.
        lv_base_lgort = <member>-lgort.
        lv_is_first   = abap_false.
      ELSEIF <member>-lgort <> lv_base_lgort.
        lv_diff = 'X'.
        EXIT.
      ENDIF.
    ENDLOOP.

    IF lv_diff EQ 'X'.
      APPEND VALUE #( vbeln = <group>-vbeln
                      flag  = lv_diff ) TO lt_diff_lgort.
    ENDIF.
  ENDLOOP.

  SORT lt_diff_lgort BY vbeln.

**  =======================================================================
**  -- [2] 메인 데이터 생성 루프
**  =======================================================================
  LOOP AT gt_data  INTO DATA(ls_data).

    CLEAR: ls_item.
    MOVE-CORRESPONDING: ls_data TO ls_item.

**  Header
    DATA(ls_temp) = ls_data.

    AT END OF vbeln.

      " 사전 검증 테이블을 조회하여 해당 납품문서의 lgort가 서로 다른지 판별
      READ TABLE lt_diff_lgort TRANSPORTING NO FIELDS
                               WITH KEY vbeln = ls_temp-vbeln
                               BINARY SEARCH.
      DATA(lv_flg) = COND #( WHEN sy-subrc EQ 0 THEN abap_true ELSE abap_false ).

      APPEND VALUE #( BASE CORRESPONDING #( ls_temp )
                      checkbox = COND #( WHEN rb1 = 'X'
                                         THEN 'X'
                                         ELSE ' ' )
                      serks    = ls_temp-werks

                      " lv_flg가 true(상이한 항목 존재)이면 space, 아니면 기존 lgort 할당
                      sgort    = COND #( WHEN lv_flg EQ abap_true
                                         THEN space
                                         ELSE ls_temp-lgort )
                     ) TO gt_head.
    ENDAT.

**  Item
*   색상, 조장, 조장수
    PERFORM get_color_jojan     USING    ls_temp-vgbel
                                         ls_temp-vgpos
                                         ls_temp-matnr
                                         ls_temp-werks
                                         ls_temp-lfimg
                                CHANGING ls_item-jojan
                                         ls_item-color
                                         ls_item-jojsu.

*   자재 품명
    ls_item-maktx = VALUE #( lt_makt[ matnr = ls_item-matnr ]-maktx
                             OPTIONAL ).

*   Picking 수량
    ls_item-menge = VALUE #( lt_vbfa[ vbeln = ls_item-vbeln
                                      posnr = ls_item-posnr ]-rfmng
                             OPTIONAL ).

*   ZCS 주문번호 확인
    DATA(lv_cnt) = REDUCE i( INIT x = 0  FOR ls_wa IN lt_va
                                         WHERE ( vgbel = ls_item-vgbel AND
                                                 vgpos = ls_item-vgpos )
                             NEXT x = x + 1 ).

    IF lv_cnt > 1.

      READ TABLE lt_va  INTO DATA(ls_va)
                        WITH KEY vgbel = ls_item-vgbel
                                 vgpos = ls_item-vgpos
                        BINARY SEARCH.
      IF sy-subrc = 0.
        LOOP AT lt_va INTO ls_va  FROM sy-tabix.
          IF ls_va-vgbel = ls_item-vgbel AND
             ls_va-vgpos = ls_item-vgpos.

            IF     rb1 = 'X'.
              DATA(ls_mska) = VALUE #( lt_mska[ vbeln = ls_va-vbeln
                                                posnr = ls_va-posnr ]
                                       OPTIONAL ).
              IF ls_mska IS INITIAL.
                DATA(lv_chk) = 'X'.
              ENDIF.

            ELSEIF rb2 = 'X'.
              CLEAR: ls_mska, lv_chk.
              ls_mska = VALUE #( lt_mska[ vbeln = ls_va-vbeln
                                          posnr = ls_va-posnr
                                          matnr = ls_item-matnr
                                          charg = ls_item-charg ]
                                 OPTIONAL ).
              IF ls_mska IS NOT INITIAL.
                lv_chk = 'X'.
              ENDIF.

            ENDIF.

            IF lv_chk IS NOT INITIAL.

              ls_item-kdauf = ls_va-vbeln.
              ls_item-kdpos = ls_va-posnr.

              APPEND ls_item TO gt_item_temp.

            ENDIF.

          ELSE.
            EXIT.
          ENDIF.
        ENDLOOP.
      ENDIF.

    ELSE.
      CLEAR: ls_va.
      ls_va = VALUE #( lt_va[ vgbel = ls_item-vgbel
                              vgpos = ls_item-vgpos ]
                       OPTIONAL ).
      ls_item-kdauf = ls_va-vbeln.
      ls_item-kdpos = ls_va-posnr.

      APPEND ls_item TO gt_item_temp.

    ENDIF.

  ENDLOOP.

**
  FREE: lt_data, lt_va, lt_mska, lt_makt, lt_vbfa.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form get_color_jojan
*&---------------------------------------------------------------------*
FORM get_color_jojan  USING    pi_vgbel
                               pi_vgpos
                               pi_matnr
                               pi_werks
                               pi_lfimg
                      CHANGING pe_jojan
                               pe_color
                               pe_jojsu.

  DATA: lt_list    LIKE zles001    OCCURS 0 WITH HEADER LINE.

**
  _clear: lt_list.
  CALL FUNCTION 'Z_LE_GET_CHARACTERISTIC'
    EXPORTING
      i_vbeln            = pi_vgbel
      i_posnr            = pi_vgpos
      i_object           = pi_matnr
      i_werks            = pi_werks
    TABLES
      gt_list            = lt_list
    EXCEPTIONS
      instance_not_found = 1
      OTHERS             = 4.

* 조장
  pe_jojan = VALUE #( lt_list[ atnam = so_length ]-atwrt
                      OPTIONAL ).

* 조장수
  IF pe_jojan IS NOT INITIAL.
    pe_jojsu = pi_lfimg / pe_jojan.
  ENDIF.

* 색상
  pe_color = VALUE #( lt_list[ atnam = so_color ]-atwrt
                      OPTIONAL ).

**
  FREE: lt_list.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form end_process
*&---------------------------------------------------------------------*
FORM end_process .

**
  CHECK: gv_error IS INITIAL.

  CLEAR: gv_line.
  DESCRIBE TABLE gt_head LINES gv_line.
  IF gv_line > 0.
    CALL SCREEN 100.

  ELSE.
*   조건에 맞는 DATA가 없습니다.
    MESSAGE s018  DISPLAY LIKE 'E'.

  ENDIF.

**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form refresh_data_get
*&---------------------------------------------------------------------*
FORM refresh_data_get.

**
  CHECK: gv_error IS INITIAL.

  PERFORM get_data.

  PERFORM make_head_item_data.

**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form start_gi_process
*&---------------------------------------------------------------------*
FORM start_gi_process  USING  pi_ucomm.

**
  CLEAR: gv_error.

  PERFORM check_select_data       USING    pi_ucomm
                                  CHANGING gv_error.

* Item 확인없이 처리할 경우
  IF gt_item[] IS INITIAL.
    PERFORM make_detail_list      USING    pi_ucomm
                                  CHANGING gv_error.
  ENDIF.

  PERFORM start_goodmvt_create    USING    pi_ucomm
                                  CHANGING gv_error.

*
*  IF gv_error IS INITIAL.
  IF gt_mtab[] IS NOT INITIAL.
    CALL FUNCTION 'Z_LE_POPUP_TO_ERROR_MESSAGE'
      TABLES
        msg_tab = gt_mtab.

    EXIT.
  ENDIF.

**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form check_select_data
*&---------------------------------------------------------------------*
FORM check_select_data   USING    pi_ucomm
                         CHANGING pe_error.

**
  CHECK: pe_error IS INITIAL.

  DATA(ls_chk) = VALUE #( gt_head[ checkbox = 'X' ]  OPTIONAL ).
  IF ls_chk IS INITIAL.
    pe_error = 'X'.
*   처리할 데이타를 선택 하세요.
    MESSAGE s004  DISPLAY LIKE 'E'.
    EXIT.

  ELSE.

** 저장위치가 서로 다른 아이템이 있을 경우
** 헤더 저장위치를 빈값으로 제안하기 때문에 주석처리

*    IF pi_ucomm = 'GI'.               "입고(MIGO)
*      CLEAR: ls_chk.
*      ls_chk = VALUE #( gt_head[ checkbox = 'X'
*                                 sgort    = '' ]  OPTIONAL ).
*      IF ls_chk IS NOT INITIAL.
*        pe_error = 'X'.
**       입고저장위치가 지정되지 않았습니다.
*        MESSAGE s000  WITH TEXT-e02  DISPLAY LIKE 'E'.
*        EXIT.
*      ENDIF.
*
*    ENDIF.

  ENDIF.

**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form start_goodmvt_create
*&---------------------------------------------------------------------*
FORM start_goodmvt_create  USING    pi_ucomm
                           CHANGING pe_error.

  DATA: lv_err(1),

        BEGIN OF lt_target OCCURS 0,
          vbeln LIKE lips-vbeln,    "납품번호
          uecha LIKE lips-uecha,
        END OF lt_target.

**
  CHECK: pe_error IS INITIAL.

  DATA(lt_item) = gt_item[].
  SORT: lt_item BY vbeln uecha posnr.

  _clear: gt_mtab.
  LOOP AT gt_head  INTO DATA(ls_head)
                   WHERE checkbox = 'X'.

*   Check logic.
    CLEAR: lv_err.
    PERFORM check_before_bapi      USING    ls_head
                                   CHANGING lv_err.
    IF lv_err IS NOT INITIAL.
      CONTINUE.
    ENDIF.

*   Start
    _clear: lt_target.
    lt_target[] = VALUE #( FOR ls_wa IN lt_item
                               WHERE ( vbeln = ls_head-vbeln )
                           ( vbeln = ls_wa-vbeln
                             uecha = ls_wa-uecha ) ).

    IF lt_target[] IS NOT INITIAL.

      SORT lt_target BY vbeln uecha.
      DELETE ADJACENT DUPLICATES FROM lt_target COMPARING vbeln uecha.

      _clear: gt_stab.
      LOOP AT lt_target  INTO DATA(ls_target).

*       BAPI Goodmvt.
        PERFORM start_goodmvt_bapi    USING  ls_head
                                             ls_target-vbeln
                                             ls_target-uecha.
*       Update LIPS ZMIGO
        PERFORM update_lips_zmigo     USING  pi_ucomm
                                             ls_target-vbeln
                                             ls_target-uecha.
*        Update Millca Length in Batch Characteristic
        PERFORM update_batch_millca_length.
      ENDLOOP.

    ENDIF.

  ENDLOOP.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form check_before_bapi
*&---------------------------------------------------------------------*
FORM check_before_bapi  USING    ps_head   LIKE gt_head
                        CHANGING pe_err.

  DATA: lv_msg  LIKE zles009-msgtx.

**
  CHECK: pe_err  IS INITIAL,
         ps_head IS NOT INITIAL.

* 선택된 건중 한건이라도 실제 출고전기일자와 입고전기일자가
* 일치하지 않을 경우 오류 메세지 발생시킴
  IF ps_head-wadat_ist <> p_budat AND
     p_exe IS INITIAL.

    CLEAR: lv_msg.
*   &VBELN 출고전기일자: & 입고전기일자: & 전기일자 상이, 전기일자를 변경하세요.
    DATA(lv_wadat_c) = |{ ps_head-wadat_ist  DATE = USER }|.
    DATA(lv_budat_c) = |{ p_budat            DATE = USER }|.

    lv_msg = |{ ps_head-vbeln } | &&
             |{ '출고전기일자:' } | && |{ lv_wadat_c }| && ',' &&
             | { '입고전기일자:' } | && |{ lv_budat_c }| && | { TEXT-t03 }|.

    APPEND VALUE #( msgtx = lv_msg ) TO gt_mtab.

    pe_err = 'X'.
    EXIT.

  ENDIF.

* ZCS(보관품출고) Order Check.
  IF ps_head-zcsfg = 'X'.

    CLEAR: lv_msg.
*   -> ZCS Order가 2개 이상! 보관입고할 수 없습니다.
    lv_msg = |{ ps_head-vbeln } | && |{ TEXT-t04 }|.

    APPEND VALUE #( msgtx = lv_msg ) TO gt_mtab.

    pe_err = 'X'.
    EXIT.

  ENDIF.

**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form start_goodmvt_bapi
*&---------------------------------------------------------------------*
FORM start_goodmvt_bapi  USING    ps_head   LIKE gt_head
                                  pi_vbeln
                                  pi_uecha.

  DATA: ls_head      LIKE bapi2017_gm_head_01,
        ls_hret      LIKE bapi2017_gm_head_ret,
        ls_code      LIKE bapi2017_gm_code,
        lt_bapi_item LIKE bapi2017_gm_item_create  OCCURS 0 WITH HEADER LINE,
        lt_bapi_seri LIKE bapi2017_gm_serialnumber OCCURS 0 WITH HEADER LINE,
        lt_return    LIKE bapiret2                 OCCURS 0 WITH HEADER LINE,

        lv_line      LIKE bapi2017_gm_item_create-line_id,
        lv_mblpo     LIKE bapi2017_gm_serialnumber-matdoc_itm,
        lv_meins     LIKE mara-meins,
        lv_xchpf     LIKE mara-xchpf.

**
  CHECK: pi_vbeln IS NOT INITIAL AND
         pi_uecha IS NOT INITIAL.

* Set Target Data.
  DATA(lt_item) = gt_item[].
  SORT lt_item BY vbeln uecha posnr.

  _clear: gt_bapi_tab.
  gt_bapi_tab[] = VALUE #( FOR ls_wa IN lt_item
                               WHERE ( vbeln = pi_vbeln AND
                                       uecha = pi_uecha )
                           ( VALUE #( BASE CORRESPONDING #( ls_wa )
                                      serks = ps_head-serks   "미고 BDC 플랜트
                                      sgort = COND #( WHEN ps_head-sgort EQ abap_false
                                                          THEN ls_wa-lgort
                                                          ELSE ps_head-sgort )   "미고 BDC 저장위치
                                     )
                            )
                          ).

  CHECK: gt_bapi_tab[] IS NOT INITIAL.

  _clear: lt_bapi_item, lt_bapi_seri, lt_return.
  CLEAR: ls_head, ls_code, ls_hret.

*___전기일/증빙일/텍스트
  ls_head-pstng_date = p_budat.
  ls_head-doc_date   = p_budat.
  ls_head-header_txt = sy-tcode.

*___자재이동 트랜잭션 지정
  ls_code-gm_code    = '05'.    "기타입고(MB1C) - T158G

* Make Bapi data.
  CLEAR: lv_line, lv_mblpo.
  LOOP AT gt_bapi_tab  INTO DATA(ls_tab).

    CLEAR: lv_meins.
    SELECT SINGLE meins, xchpf
      INTO ( @lv_meins, @lv_xchpf )
      FROM mara  WHERE matnr = @ls_tab-matnr.

*___자재이동 정보
    PERFORM make_move_item_tab    TABLES  lt_bapi_item
                                  USING   ls_tab
                                          ps_head-vstel
                                          lv_meins
                                          lv_line.

*___일련번호
    PERFORM make_serial_tab    TABLES lt_bapi_seri
                               USING  ls_tab
                                      lv_xchpf
                                      lv_mblpo.

  ENDLOOP.

*___자재이동 BAPI CALL
  CALL FUNCTION 'BAPI_GOODSMVT_CREATE'
    EXPORTING
      goodsmvt_header       = ls_head
      goodsmvt_code         = ls_code
    IMPORTING
      goodsmvt_headret      = ls_hret
    TABLES
      goodsmvt_item         = lt_bapi_item
      goodsmvt_serialnumber = lt_bapi_seri
      return                = lt_return.

  PERFORM set_movement_result   TABLES  lt_return
                                USING   ls_hret
                                        ps_head.

  IF line_exists( lt_return[ type = 'E'] ).
    CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.

    CLEAR gv_error.
    gv_error = abap_true.
  ELSE.
    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      EXPORTING
        wait = 'X'.


*  꼬리표 Table 데이터 Insert
    LOOP AT lt_bapi_item ASSIGNING FIELD-SYMBOL(<lfs_item>).
      CALL FUNCTION 'CONVERSION_EXIT_MATN1_INPUT'
        EXPORTING
          input  = <lfs_item>-material
        IMPORTING
          output = <lfs_item>-material.
    ENDLOOP.

* 기존 꼬리표 데이터 추출
    DATA:ls_zppt0001 TYPE zppt0001,
         lt_zppt0001 TYPE STANDARD TABLE OF zppt0001.
    DATA(lt_tmp) = lt_bapi_item[].

    SELECT DISTINCT
      a~plant AS werks,
      MAX( b~aufnr ) AS aufnr,
      MAX( b~tagnr ) AS tagnr,
      MAX( b~rueck ) AS rueck,
      MAX( b~rmzhl ) AS rmzhl,
      b~charg,
      b~matnr

   FROM @lt_tmp AS a INNER JOIN zppt0001 AS b
                        ON  a~material EQ b~matnr
                        AND a~batch    EQ b~charg
    GROUP BY a~plant, b~charg, b~matnr
     INTO TABLE @DATA(lt_tagnr).

    SORT lt_tagnr BY werks aufnr tagnr rueck rmzhl.

* 꼬리표 데이터 6591 플랜트 정보 추가
    IF lt_tagnr[] IS NOT INITIAL.
      LOOP AT lt_tagnr INTO DATA(ls_tagnr).
        CLEAR: ls_zppt0001.
        ls_zppt0001         = CORRESPONDING #( ls_tagnr ).

        ls_zppt0001-mblnr   = ls_hret-mat_doc.
        ls_zppt0001-grindat = ls_head-pstng_date.
        ls_zppt0001-grintim = COND #( WHEN ls_head-pr_uname IS NOT INITIAL
                                           THEN ls_head-pr_uname
                                           ELSE sy-uname ).

        APPEND ls_zppt0001 TO lt_zppt0001.
      ENDLOOP.
    ENDIF.

* 꼬리표 테이블 Modify
    IF lt_zppt0001[] IS NOT INITIAL.
      MODIFY zppt0001 FROM TABLE lt_zppt0001.

      IF sy-subrc EQ 0.
        COMMIT WORK.
      ELSE.
        ROLLBACK WORK.
      ENDIF.
    ENDIF.

  ENDIF.
**
  FREE: lt_item, lt_bapi_item, lt_bapi_seri,
        lt_return, lt_zppt0001.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form make_move_item_tab
*&---------------------------------------------------------------------*
FORM make_move_item_tab  TABLES   pt_item   STRUCTURE bapi2017_gm_item_create
                         USING    ps_tab    LIKE gt_bapi_tab
                                  pi_vstel
                                  pi_meins
                                  pi_line.

**
  CHECK: ps_tab IS NOT INITIAL.

  pi_line  = pi_line  + 1.
  APPEND VALUE #( material       = ps_tab-matnr
                  plant          = ps_tab-serks
                  stge_loc       = ps_tab-sgort
                  batch          = ps_tab-charg
                  move_type      = '901'
                  entry_qnt      = ps_tab-lfimg
                  entry_uom      = COND #( WHEN pi_vstel+0(1) = 'J'
                                                THEN ps_tab-vrkme
                                                ELSE pi_meins
                                          )
                  spec_stock     = 'E'
                  val_sales_ord  = ps_tab-kdauf
                  val_s_ord_item = ps_tab-kdpos
                  line_id        = pi_line
                 ) TO pt_item.

**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form make_serial_tab
*&---------------------------------------------------------------------*
FORM make_serial_tab  TABLES   pt_seri  STRUCTURE bapi2017_gm_serialnumber
                      USING    ps_tab   LIKE gt_bapi_tab
                               pi_xchpf
                               pi_mblpo.

  DATA: lv_sernr    LIKE equi-sernr.

**
  CHECK: ps_tab   IS NOT INITIAL,
         pi_xchpf EQ 'X'.

  SELECT SINGLE sernp  INTO @DATA(lv_sernp)
    FROM marc  WHERE matnr EQ @ps_tab-matnr
                 AND werks EQ @ps_tab-serks.

  IF sy-subrc = 0 AND lv_sernp <> 'ZSD1'.

    CLEAR: lv_sernr.
    IF ps_tab-werks = '3602' .
      CALL FUNCTION 'Z_PP_GET_AM_CHARG_SERNR'
        EXPORTING
          i_matnr = ps_tab-matnr
          i_charg = ps_tab-charg
        IMPORTING
          e_sernr = lv_sernr.
    ELSE.
      lv_sernr = ps_tab-charg.
    ENDIF.

    pi_mblpo = pi_mblpo + 1.
    APPEND VALUE #( matdoc_itm = pi_mblpo
                    serialno   = lv_sernr
                   ) TO pt_seri.

  ENDIF.

**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form set_movement_result
*&---------------------------------------------------------------------*
FORM set_movement_result  TABLES   pt_return STRUCTURE bapiret2
                          USING    ps_hret   LIKE bapi2017_gm_head_ret
                                   ps_head   LIKE gt_head.

**
  IF ps_hret-mat_doc IS NOT INITIAL.
    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      EXPORTING
        wait = 'X'.

*   S: &vbeln, &uecha 보관입고 되었습니다.
    gt_mtab = VALUE #( BASE gt_mtab
                       FOR ls_tab  IN gt_bapi_tab
                       ( msgtx = |{ 'S:' }| && | { ls_tab-vbeln }| &&
                                 | { ls_tab-uecha }| && |{ TEXT-t05 }| )
                      ).

    gt_stab[] = VALUE #( BASE gt_stab[]
                         FOR ls_stab IN gt_bapi_tab
                         ( VALUE #( BASE CORRESPONDING #( ls_stab )
                           zmblnr = ps_hret-mat_doc )
                          )
                        ).

  ELSE.
    CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.

    gv_error = 'X'.

    DATA(ls_return) = VALUE #( pt_return[ type = 'X' ]  OPTIONAL ).
    IF ls_return IS INITIAL.
      ls_return = VALUE #( pt_return[ type = 'A' ]  OPTIONAL ).
      IF ls_return IS INITIAL.
        ls_return = VALUE #( pt_return[ type = 'E' ]  OPTIONAL ).
        IF ls_return IS INITIAL.
          ls_return = VALUE #( pt_return[ type = 'I' ]  OPTIONAL ).
          IF ls_return IS INITIAL.
            ls_return = VALUE #( pt_return[ type = 'W' ]  OPTIONAL ).
            IF ls_return IS INITIAL.
              ls_return = VALUE #( pt_return[ 1 ]  OPTIONAL ).
            ENDIF.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.

    gt_mtab = VALUE #( BASE gt_mtab
                       ( msgtx = COND #( WHEN ls_return-number = '046'
                                              THEN |{ 'E:' }| && | { ls_return-message }|
                                              ELSE |{ 'E:' }| && | { ps_head-vbeln }| &&
                                                   | { ls_return-message }| )
                        )
                      ).

  ENDIF.

**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form update_lips_zmigo
*&---------------------------------------------------------------------*
FORM update_lips_zmigo  USING    pi_ucomm
                                 pi_vbeln
                                 pi_uecha.

  DATA: lv_zmigo  LIKE lips-zmigo,
        lv_zmblnr LIKE lips-zmblnr.

**
  DATA(ls_stab) = VALUE #( gt_stab[ vbeln = pi_vbeln
                                    uecha = pi_uecha ]
                           OPTIONAL ).

  IF ls_stab IS NOT INITIAL.

    CLEAR: lv_zmigo, lv_zmblnr.
    lv_zmigo  = COND #( WHEN pi_ucomm = 'GI'    " 입고(MIGO)
                             THEN 'X'
                        WHEN pi_ucomm = 'GT'    " 취소(MBST)
                             THEN ' ' ).
    lv_zmblnr = COND #( WHEN pi_ucomm = 'GI'    " 입고(MIGO)
                             THEN ls_stab-zmblnr
                        WHEN pi_ucomm = 'GT'    " 취소(MBST)
                             THEN ' ' ).

    LOOP AT gt_item  INTO DATA(ls_item)
                     WHERE vbeln = pi_vbeln
                       AND uecha = pi_uecha.

      UPDATE lips  SET zmigo  = lv_zmigo
                       zmblnr = lv_zmblnr
                 WHERE vbeln = ls_item-vbeln
                   AND posnr = ls_item-posnr.

    ENDLOOP.

    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      EXPORTING
        wait = 'X'.

  ENDIF.

**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form get_lgort_from_f4
*&---------------------------------------------------------------------*
FORM get_lgort_from_f4  USING    pi_werks
                        CHANGING pe_lgort.

  DATA: lt_return TYPE TABLE OF ddshretval.

**
  CHECK: pi_werks IS NOT INITIAL.

  SELECT werks, lgort, lgobe  INTO TABLE @DATA(lt_lgort)
    FROM t001l  WHERE werks EQ @pi_werks.

  CHECK: lt_lgort[] IS NOT INITIAL.

  _clear: lt_return.
  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      retfield        = 'LGORT'
      dynpprog        = sy-cprog
      dynpnr          = sy-dynnr
      value_org       = 'S'
    TABLES
      value_tab       = lt_lgort
      return_tab      = lt_return
    EXCEPTIONS
      parameter_error = 1
      no_values_found = 2
      OTHERS          = 3.

  pe_lgort = VALUE #( lt_return[ 1 ]-fieldval  OPTIONAL ).

**
  FREE: lt_lgort, lt_return.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form input_sgort_multi_lines
*&---------------------------------------------------------------------*
FORM input_sgort_multi_lines  USING   pi_ucomm.

**
  PERFORM check_select_data    USING    pi_ucomm
                               CHANGING gv_error.

  CHECK: gv_error IS INITIAL.

  CLEAR: gs_sgort.
  DATA(lv_werks) = VALUE #( gt_head[ checkbox = 'X' ]-serks
                            OPTIONAL ).

  SELECT SINGLE werks, name1
    FROM t001w  WHERE werks EQ @lv_werks
    INTO CORRESPONDING FIELDS OF @gs_sgort.

  CALL SCREEN 200  STARTING AT  5  5.

  CALL METHOD cl_gui_cfw=>set_new_ok_code
    EXPORTING
      new_code = 'ENTR'.

**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form set_lgort_name
*&---------------------------------------------------------------------*
FORM set_lgort_name  USING    pi_lgort
                     CHANGING pe_lgobe.

**
  IF pi_lgort IS NOT INITIAL.
    SELECT SINGLE lgobe  INTO @pe_lgobe
      FROM t001l  WHERE lgort EQ @pi_lgort.

  ELSE.
    CLEAR: pe_lgobe.

  ENDIF.

**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form set_input_lgort
*&---------------------------------------------------------------------*
FORM set_input_lgort  USING    pi_lgort
                      CHANGING pe_error.

**
  IF pi_lgort IS NOT INITIAL.
    MODIFY gt_head FROM VALUE #( sgort = pi_lgort )
                   TRANSPORTING sgort
                   WHERE checkbox = 'X'.
  ELSE.
    MESSAGE i000 WITH TEXT-e01 .
    pe_error = 'X'.

  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form set_detail_item_list
*&---------------------------------------------------------------------*
FORM set_detail_item_list  USING    pi_ucomm.

**
  CHECK: gv_error IS INITIAL.

  PERFORM check_select_data       USING    pi_ucomm
                                  CHANGING gv_error.

  PERFORM make_detail_list        USING    pi_ucomm
                                  CHANGING gv_error.

**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form make_detail_list
*&---------------------------------------------------------------------*
FORM make_detail_list  USING    pi_ucomm
                       CHANGING pe_error.

**
  CHECK: pe_error IS INITIAL.

  _clear: gt_item.
  LOOP AT gt_head  INTO DATA(ls_head)
                   WHERE checkbox = 'X'.

    gt_item[] = VALUE #( BASE gt_item[]
                         FOR ls_wa IN gt_item_temp
                             WHERE ( vbeln = ls_head-vbeln )
                         ( CORRESPONDING #( ls_wa ) )
                        ).

  ENDLOOP.

  IF gt_item[] IS INITIAL.
    pe_error = 'X'.
*   조건에 맞는 DATA가 없습니다.
    MESSAGE s018  DISPLAY LIKE 'E'.
  ENDIF.

**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form select_control
*&---------------------------------------------------------------------*
FORM select_control  USING    pi_ucomm.

  DATA: lv_chk(1).

**
  MODIFY gt_head  FROM  VALUE #( checkbox = COND #( WHEN pi_ucomm = 'ALL'
                                                         THEN 'X'
                                                    WHEN pi_ucomm = 'DALL'
                                                         THEN ' ' )
                                )
                        TRANSPORTING checkbox
                        WHERE vbeln NE space.

**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form start_canc_process
*&---------------------------------------------------------------------*
FORM start_canc_process  USING    pi_ucomm.

**
  CLEAR: gv_error.

  PERFORM check_select_data       USING    pi_ucomm
                                  CHANGING gv_error.

* Item 확인없이 처리할 경우
  IF gt_item[] IS INITIAL.
    PERFORM make_detail_list      USING    pi_ucomm
                                  CHANGING gv_error.
  ENDIF.

  PERFORM start_goodmvt_cancel    USING    pi_ucomm
                                  CHANGING gv_error.
*
  IF gv_error IS INITIAL.
    CALL FUNCTION 'Z_LE_POPUP_TO_ERROR_MESSAGE'
      TABLES
        msg_tab = gt_mtab.

    EXIT.
  ENDIF.

**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form start_goodmvt_cancel
*&---------------------------------------------------------------------*
FORM start_goodmvt_cancel      USING    pi_ucomm
                               CHANGING pe_error.

  DATA: BEGIN OF lt_canc OCCURS 0,
          vbeln  LIKE lips-vbeln,
          uecha  LIKE lips-uecha,
          zmblnr LIKE mseg-mblnr,
        END OF lt_canc.

**
  CHECK: pe_error IS INITIAL.

  _clear: gt_mtab, lt_canc.
  LOOP AT gt_head  INTO DATA(ls_head)
                   WHERE checkbox = 'X'.

    lt_canc[] = VALUE #( BASE lt_canc[]
                         FOR ls_wa  IN gt_item
                             WHERE ( vbeln = ls_head-vbeln )
                         ( CORRESPONDING #( ls_wa ) )
                        ).
  ENDLOOP.

  IF lt_canc[] IS NOT INITIAL.

    _clear: gt_stab.
    LOOP AT lt_canc  INTO DATA(ls_canc).

      PERFORM start_goodmvt_canc_bapi   USING  ls_canc-vbeln
                                               ls_canc-uecha
                                               ls_canc-zmblnr
                                               p_budat.

*     Update LIPS ZMIGO
      PERFORM update_lips_zmigo         USING  pi_ucomm
                                               ls_canc-vbeln
                                               ls_canc-uecha.

      PERFORM update_batch_millca_length.

    ENDLOOP.

  ELSE.
    pe_error = 'X'.
*   입고취소 대상 Data가 없습니다.
    MESSAGE s000 WITH TEXT-e03  DISPLAY LIKE 'E'.
    EXIT.
  ENDIF.

**
  FREE: lt_canc.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form start_goodmvt_canc_bapi
*&---------------------------------------------------------------------*
FORM start_goodmvt_canc_bapi  USING    pi_vbeln
                                       pi_uecha
                                       pi_mblnr
                                       pi_budat.

  DATA : lv_year   LIKE mseg-mjahr,

         ls_cancel LIKE bapi2017_gm_head_ret,
         lt_return LIKE TABLE OF bapiret2.

**
  CHECK: pi_mblnr IS NOT INITIAL,
         pi_budat IS NOT INITIAL.

  CLEAR: lv_year.
  lv_year = pi_budat(4).

  CLEAR: ls_cancel.
  _clear: lt_return.

  CALL FUNCTION 'BAPI_GOODSMVT_CANCEL'
    EXPORTING
      materialdocument    = pi_mblnr
      matdocumentyear     = lv_year
      goodsmvt_pstng_date = pi_budat
    IMPORTING
      goodsmvt_headret    = ls_cancel  "취소전표정보
    TABLES
      return              = lt_return.

  PERFORM set_movement_canc_result   TABLES  lt_return
                                     USING   pi_vbeln
                                             pi_uecha.
  IF line_exists( lt_return[ type = 'E' ] ).
    CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.

    CLEAR gv_error.
    gv_error = abap_true.
  ELSE.
    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      EXPORTING
        wait = 'X'.
  ENDIF.
**
  FREE: lt_return.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form set_movement_canc_result
*&---------------------------------------------------------------------*
FORM set_movement_canc_result  TABLES   pt_return STRUCTURE bapiret2
                               USING    pi_vbeln
                                        pi_uecha.

  DATA: lv_msg(200).

**
  DATA(ls_return) = VALUE #( pt_return[ type = 'E' ]
                             OPTIONAL ).

  IF ls_return IS INITIAL.

    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      EXPORTING
        wait = 'X'.

*   S: &vbeln, &uecha 취소 되었습니다.
    gt_mtab = VALUE #( BASE gt_mtab
                       ( msgtx = |{ 'S:' }| && | { pi_vbeln }| &&
                                 | { TEXT-t06 }| )
                      ).

    gt_stab[] = VALUE #( BASE gt_stab[]
                         ( vbeln = pi_vbeln
                           uecha = pi_uecha )
                        ).

  ELSE.

    CLEAR: lv_msg.
    PERFORM build_message_text  USING    ls_return-id
                                         ls_return-number
                                         ls_return-message_v1
                                         ls_return-message_v2
                                         ls_return-message_v3
                                         ls_return-message_v4
                                CHANGING lv_msg.

    DATA(lv_msgno) = sy-msgno.

*   E04 : 보관주문에 대해 출고전기가 되어 취소불가능합니다.
    gt_mtab = VALUE #( BASE gt_mtab
                       ( msgtx = COND #( WHEN lv_msgno = '046'
                                              THEN |{ 'E:' }| && | { lv_msg }|
                                         WHEN lv_msgno = '105'
                                              THEN |{ 'E:' }| && | { pi_vbeln }| &&
                                              | { pi_uecha }| && | { TEXT-e04 }|
                                         ELSE |{ 'E:' }| && | { pi_vbeln }| &&
                                              | { pi_uecha }| && | { lv_msg }| )
                        )
                      ).

  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form build_message_text
*&---------------------------------------------------------------------*
FORM build_message_text  USING    pi_msgid
                                  pi_msgno
                                  pi_msgv1
                                  pi_msgv2
                                  pi_msgv3
                                  pi_msgv4
                         CHANGING pe_msg.

**
  CALL FUNCTION 'MESSAGE_TEXT_BUILD'
    EXPORTING
      msgid               = pi_msgid
      msgnr               = pi_msgno
      msgv1               = pi_msgv1
      msgv2               = pi_msgv2
      msgv3               = pi_msgv3
      msgv4               = pi_msgv4
    IMPORTING
      message_text_output = pe_msg.

**

ENDFORM.
*&---------------------------------------------------------------------*
*& Form update_batch_millca_length
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM update_batch_millca_length .

  DATA: lt_return  TYPE TABLE OF bapiret2,
        lv_class   TYPE klah-class,
        lt_valnum  TYPE TABLE OF bapi1003_alloc_values_num,
        ls_valnum  TYPE bapi1003_alloc_values_num,
        lt_valchar TYPE TABLE OF bapi1003_alloc_values_char,
        ls_valchar TYPE bapi1003_alloc_values_char,
        lt_valcurr TYPE TABLE OF bapi1003_alloc_values_curr,
        lv_status  TYPE bapi1003_key-status.

  DATA: lv_tmstmp  TYPE timestampl,
        lt_log     TYPE TABLE OF zgtsdt1120,
        ls_log     TYPE zgtsdt1120,
        lv_err_flg TYPE abap_bool.

  CHECK: gv_error EQ abap_false.

  " Factor Batch 대상 자재코드/Batch 번호 추출
  DATA(lt_tmp) = gt_item[].
  SELECT a~matnr, a~werks, a~charg, b~dpcbt
    FROM @lt_tmp AS a INNER JOIN marc AS b
                   ON a~matnr EQ b~matnr
                  AND a~werks EQ b~werks
   WHERE b~dpcbt EQ 'A'
     AND a~charg NE @abap_false
   GROUP BY a~matnr, a~werks, a~charg, b~dpcbt
    INTO TABLE @DATA(lt_charg).

  " 조회된 대상이 있을 때만 하위 로직 수행
  IF lt_charg[] IS NOT INITIAL.

    " ASIS Factor Batch의 SAP_MILLCA_LENGTH
    SELECT a~matnr, a~charg, a~werks,
           b~atflv AS length,
           CAST( b~atflv AS CHAR( 15 ) ) AS length_c
      FROM @lt_charg AS a INNER JOIN zgtsd_cv_get_vcofbatch AS b
                          ON a~matnr EQ b~matnr
                         AND a~werks EQ b~werks
                         AND a~charg EQ b~charg
     WHERE atnam EQ 'SAP_MILLCA_LENGTH'
      INTO TABLE @DATA(lt_length).

    SORT: lt_charg  BY matnr werks charg dpcbt,
          lt_length BY matnr charg werks length.

*    Charg 값을 SAP_MILLCA_LENGTH 로 업데이트
    LOOP AT lt_charg ASSIGNING FIELD-SYMBOL(<lfs_charg>).
      CLEAR: lt_valnum, lt_valchar, lt_valcurr.

*     현재 클래스 023의 SAP_MILLCA_LENGTH 값
      DATA(ls_len) = VALUE #( lt_length[ matnr = <lfs_charg>-matnr
                                        charg = <lfs_charg>-charg
                                        werks = <lfs_charg>-werks ] OPTIONAL ).

      IF <lfs_charg>-charg EQ ls_len-length_c.
        CONTINUE.
      ELSE.
        " CLASS번호
        CLEAR: lv_class.
        CALL FUNCTION 'CLFC_BATCH_ALLOCATION_TO_CLASS'
          EXPORTING
            material           = <lfs_charg>-matnr " G/I자재
            plant              = <lfs_charg>-werks " 플랜트
            classtype          = '023'             " 클래스유형(배치)
          IMPORTING
            class              = lv_class
          EXCEPTIONS
            no_class_found     = 1
            no_classtype_found = 2
            OTHERS             = 3.

        CHECK lv_class IS NOT INITIAL.

        CLEAR: ls_valnum.
        ls_valnum-charact = 'SAP_MILLCA_LENGTH_SUB'.
        ls_valnum-value_from = '0'.
        APPEND ls_valnum TO lt_valnum.

        CLEAR: ls_valnum.
        ls_valnum-charact = 'SAP_MILLCA_LENGTH'.
        ls_valnum-value_from = <lfs_charg>-charg.
        APPEND ls_valnum TO lt_valnum.

        " - 배치 특성 업데이트(펑션 호출)
        SELECT SINGLE cuobj_bm
          INTO @DATA(lv_objkey)
          FROM mch1
         WHERE matnr = @<lfs_charg>-matnr
           AND charg = @<lfs_charg>-charg.

        CLEAR : lt_return.
        CALL FUNCTION 'BAPI_OBJCL_CHANGE_KEY'
          EXPORTING
            clobjectkey         = lv_objkey
            classnum            = lv_class
          IMPORTING
            classif_status      = lv_status
          TABLES
            allocvaluesnum_new  = lt_valnum
            allocvalueschar_new = lt_valchar
            allocvaluescurr_new = lt_valcurr
            return              = lt_return.

        GET TIME STAMP FIELD lv_tmstmp.

*      변경 결과 처리
        CLEAR: lv_err_flg.
        IF line_exists( lt_return[ type = 'E' ] ).
          lv_err_flg = abap_true.
          DATA(ls_msg) = VALUE #( lt_return[ type = 'E' ] OPTIONAL ).
        ELSE.
          ls_msg = VALUE #( lt_return[ type = 'S' ] OPTIONAL ).
        ENDIF.

        IF lv_err_flg EQ abap_true.
          CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
        ELSE.
          CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
            EXPORTING
              wait = 'X'.
        ENDIF.

*      로그 저장 정보 구성
        CLEAR ls_log.
        ls_log = VALUE #( tmstmp          = lv_tmstmp
                          matnr           = <lfs_charg>-matnr
                          charg           = <lfs_charg>-charg
                          werks           = <lfs_charg>-werks
                          length_old_char = |{ CONV decfloat34( ls_len-length ) }|
                          length_new_char = <lfs_charg>-charg
                          length_old      = ls_len-length
                          length_new      = <lfs_charg>-charg
                          mtype           = ls_msg-type
                          msg             = ls_msg-message
                          erdat           = sy-datlo
                          ernam           = sy-uname
                          erzet           = sy-timlo ).
        APPEND ls_log TO lt_log.

      ENDIF.
    ENDLOOP.

* 처리 결과 저장
    IF lt_log[] IS NOT INITIAL.
      MODIFY zgtsdt1120 FROM TABLE lt_log.
      COMMIT WORK.
    ENDIF.

  ENDIF.


ENDFORM.
