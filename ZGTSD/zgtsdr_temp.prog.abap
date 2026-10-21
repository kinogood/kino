*&---------------------------------------------------------------------*
*& Report ZGTSDR_TEMP
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*​
*& 모듈        : SD.
*& 프로그램 ID : ZGTSDR_TEMP.
*& 프로그램 명 : [GT] Sales Order 특성값 Mig.
*& 개요   :
*& 생성일 : 2026.07.01.​
*& 생성자 : ZGODEV05.
*&---------------------------------------------------------------------*​
*& 외부 호출 프로그램 개요   :
*& 타 시스템 인터페이스 개요 : ​
*&---------------------------------------------------------------------*​
*& 프로그램 수정이력​
*&---------------------------------------------------------------------*​
*& 수정일  :​ 2026.07.01.
*& 수정자  :​ ZGODEV05.
*& 수정개요: Create.
*&---------------------------------------------------------------------*

REPORT zgtsdr_temp  MESSAGE-ID zgtsd01.

*&---------------------------------------------------------------------*
*& TOP.
*&---------------------------------------------------------------------*
DEFINE _clear.
  REFRESH &1.    CLEAR: &1.
END-OF-DEFINITION.

DATA: lv_cnt(4) TYPE i,
      lv_chg(1),
      lv_posnr  LIKE vbap-posnr.

TABLES: vbak.

DATA: BEGIN OF ls_result,
        vbeln   LIKE vbak-vbeln,
        posnr   LIKE vbap-posnr,
        matnr   LIKE vbap-matnr,
        atnam   LIKE cabn-atnam,
        before  LIKE ausp-atwrt,
        after   LIKE ausp-atwrt,
        type    LIKE bapiret2-type,
        message LIKE bapiret2-message,
      END OF ls_result,
      lt_result LIKE TABLE OF ls_result.

DATA: lt_log  TYPE TABLE OF zgtsdttest.

DATA: lv_vbeln      LIKE bapivbeln-vbeln,

      ls_headx      TYPE bapisdh1x,
      lt_return     TYPE TABLE OF bapiret2   WITH HEADER LINE,

      ls_bapi_view  TYPE order_view,
      lt_sales_key  TYPE TABLE OF sales_key  WITH HEADER LINE,
      lt_item       TYPE TABLE OF bapisditm WITH HEADER LINE,
      lt_itemx      TYPE TABLE OF bapisditmx WITH HEADER LINE,
      lt_bapicucfgm TYPE TABLE OF bapicucfgm WITH HEADER LINE,
      lt_bapicuinsm TYPE TABLE OF bapicuinsm WITH HEADER LINE
                       WITH NON-UNIQUE SORTED KEY k_key
                                COMPONENTS config_id inst_id,
      lt_bapicuprtm TYPE TABLE OF bapicuprtm WITH HEADER LINE
                       WITH NON-UNIQUE SORTED KEY k_key
                                COMPONENTS config_id inst_id,
      lt_bapicuvalm TYPE TABLE OF bapicuvalm WITH HEADER LINE
                       WITH NON-UNIQUE SORTED KEY k_key
                                COMPONENTS config_id inst_id charc,
      lt_ref        TYPE TABLE OF bapicucfg WITH HEADER LINE,
      lt_inst       TYPE TABLE OF bapicuins WITH HEADER LINE,
*       gt_part       TYPE TABLE OF bapicuprt WITH HEADER LINE,
      lt_value      TYPE TABLE OF bapicuval WITH HEADER LINE,

      ls_ref        TYPE bapicucfg,
      ls_value      TYPE bapicuval.

*&---------------------------------------------------------------------*
*& Select-Option.
*&---------------------------------------------------------------------*
SELECT-OPTIONS: s_vbeln  FOR vbak-vbeln .

*&---------------------------------------------------------------------*
*& Start Process.
*&---------------------------------------------------------------------*
* 1) 대상 조회.
SELECT DISTINCT a~vbeln, a~posnr, a~matnr,
                a~color, a~stripe_color, a~stripe_cnt, a~specno,
                a~zspart
  FROM zgtsd_cv_get_vcofso AS a  INNER JOIN mara AS b
                                 ON  a~matnr EQ b~matnr
                                 INNER JOIN vbap AS c
                                 ON  a~vbeln EQ c~vbeln
                                 AND a~posnr EQ c~posnr
                                 AND c~gbsta EQ 'A'
 WHERE a~vbeln IN @s_vbeln
   AND a~vkorg EQ '6000'
   AND b~lvorm NE 'X'
   AND c~abgru EQ @space  " 거부사유 걸린 항목은 특성값을 변경 할수없다.
 ORDER BY a~vbeln, a~posnr
  INTO TABLE @DATA(lt_so_chr).

*SELECT DISTINCT a~vbeln,
*                CAST( a~posnr AS CHAR( 6 ) ) AS posnr, a~matnr,
*                a~pkgmatnr, a~pkg_drum, a~cmsta
*  FROM zgtsd_cv_get_vcofso AS a  INNER JOIN mara AS b
*                                 ON  a~matnr EQ b~matnr
*                                 INNER JOIN vbap AS c
*                                 ON  a~vbeln EQ c~vbeln
*                                 AND a~posnr EQ c~posnr
*                                 AND c~gbsta EQ 'A'
* WHERE a~vbeln IN @s_vbeln
*   AND a~vkorg EQ '6000'
*   AND b~lvorm NE 'X'
*   AND c~abgru EQ @space  " 거부사유 걸린 항목은 특성값을 변경 할수없다.
** ORDER BY a~vbeln, a~posnr
*  INTO TABLE @DATA(lt_so_chr).

*LOOP AT lt_so_chr ASSIGNING FIELD-SYMBOL(<lfs_data>).
*  <lfs_data>-posnr = |{ <lfs_data>-posnr ALPHA = OUT }|.
*
**  CALL FUNCTION 'CONVERSION_EXIT_MATN1_OUTPUT'
**    EXPORTING
**      input         = <lfs_data>-matnr
**   IMPORTING
**     OUTPUT        = <lfs_data>-matnr.
*
*ENDLOOP.

SORT : lt_so_chr BY vbeln posnr.

IF lt_so_chr[] IS NOT INITIAL.

  SELECT a~matnr,
         b~atwrt AS mat_color,
         c~atwrt AS matstripe_color,
         d~atwrt AS matstripe_cnt,
         e~atwrt AS matspecno,
         f~atwrt AS matspart_gaon
    FROM @lt_so_chr AS a LEFT OUTER JOIN zgtsd_i_materialcharacteristic AS b
                                     ON  a~matnr = b~matnr
                                     AND b~atnam = 'PD_CA_COLOR_BASE'
                          LEFT OUTER JOIN zgtsd_i_materialcharacteristic AS c
                                     ON  a~matnr = c~matnr
                                     AND c~atnam = 'PD_CA_COLOR_STRIPE'
                          LEFT OUTER JOIN zgtsd_i_materialcharacteristic AS d
                                     ON  a~matnr = d~matnr
                                     AND d~atnam = 'PD_CA_COLOR_STRIPE_NO'
                          LEFT OUTER JOIN zgtsd_i_materialcharacteristic AS e
                                     ON  a~matnr = e~matnr
                                     AND e~atnam = 'PD_CA_SPEC_NO'
                          LEFT OUTER JOIN zgtsd_i_materialcharacteristic AS f
                                     ON  a~matnr = f~matnr
                                     AND f~atnam = 'MS-AUSP-ZSPART'
    INTO TABLE @DATA(lt_mat_chr).


  IF lt_mat_chr[] IS NOT INITIAL.
    SORT: lt_mat_chr BY matnr.
  ENDIF.

*  SELECT CAST( zkey1   AS CHAR( 10 ) )    AS vbeln,        " vbap-vbeln (CHAR 10)
*           CAST( zkey2   AS CHAR( 6 ) )   AS posnr,        " vbap-posnr (NUMC 6)
*
*           zkey4               AS pkgmatnr,       " mara-matnr (Data Element)
*           zkey5               AS pkg_drum,       " mara-matnr (Data Element)
*           CAST( zvalue1 AS CHAR( 2 ) )  AS cmsta    " CHAR 2 명시적 변환
*      FROM zgtsdttest
*      WHERE zkey3 = 'PACKMARK'
*      INTO TABLE @DATA(lt_mat_chr).


*  IF lt_mat_chr[] IS NOT INITIAL.
*    SORT: lt_mat_chr BY vbeln posnr.
*  ENDIF.

ENDIF.

* 1) 차이점 Check.
CLEAR: lv_cnt, lv_chg.
_clear: lt_result.
IF lt_so_chr[]  IS NOT INITIAL AND
   lt_mat_chr[] IS NOT INITIAL.

  LOOP AT lt_so_chr  INTO DATA(ls_so_chr).

    CLEAR: lv_chg, ls_result.

    DATA(ls_mat_chr) = VALUE #( lt_mat_chr[ matnr = ls_so_chr-matnr ]
                                OPTIONAL ).

*   PD_CA_COLOR_BASE
    IF ls_mat_chr-mat_color       IS NOT INITIAL.
      IF ls_so_chr-color NE ls_mat_chr-mat_color.
        lv_chg = 'X'.
        APPEND VALUE #( vbeln  = ls_so_chr-vbeln
                        posnr  = ls_so_chr-posnr
                        matnr  = ls_so_chr-matnr
                        atnam  = 'PD_CA_COLOR_BASE'
                        before = ls_so_chr-color
                        after  = ls_mat_chr-mat_color ) TO lt_result.
      ENDIF.
    ENDIF.
*   PD_CA_COLOR_STRIPE
    IF ls_mat_chr-matstripe_color IS NOT INITIAL.
      IF ls_so_chr-stripe_color NE ls_mat_chr-matstripe_color.
        lv_chg = 'X'.
        APPEND VALUE #( vbeln  = ls_so_chr-vbeln
                        posnr  = ls_so_chr-posnr
                        matnr  = ls_so_chr-matnr
                        atnam  = 'PD_CA_COLOR_STRIPE'
                        before = ls_so_chr-stripe_color
                        after  = ls_mat_chr-matstripe_color ) TO lt_result.
      ENDIF.
    ENDIF.
*   PD_CA_COLOR_STRIPE_NO
    IF ls_mat_chr-matstripe_cnt   IS NOT INITIAL.
      IF ls_so_chr-stripe_cnt NE ls_mat_chr-matstripe_cnt.
        lv_chg = 'X'.
        APPEND VALUE #( vbeln  = ls_so_chr-vbeln
                        posnr  = ls_so_chr-posnr
                        matnr  = ls_so_chr-matnr
                        atnam  = 'PD_CA_COLOR_STRIPE_NO'
                        before = ls_so_chr-stripe_cnt
                        after  = ls_mat_chr-matstripe_cnt ) TO lt_result.
      ENDIF.
    ENDIF.
*   PD_CA_SPEC_NO
    IF ls_mat_chr-matspecno       IS NOT INITIAL.
      IF ls_so_chr-specno NE ls_mat_chr-matspecno.
        lv_chg = 'X'.
        APPEND VALUE #( vbeln  = ls_so_chr-vbeln
                        posnr  = ls_so_chr-posnr
                        matnr  = ls_so_chr-matnr
                        atnam  = 'PD_CA_SPEC_NO'
                        before = ls_so_chr-specno
                        after  = ls_mat_chr-matspecno ) TO lt_result.
      ENDIF.
    ENDIF.

*   MS-AUSP-ZSPART
    IF ls_mat_chr-matspart_gaon       IS NOT INITIAL.
      IF ls_so_chr-zspart NE ls_mat_chr-matspart_gaon.
        lv_chg = 'X'.
        APPEND VALUE #( vbeln  = ls_so_chr-vbeln
                        posnr  = ls_so_chr-posnr
                        matnr  = ls_so_chr-matnr
                        atnam  = 'MS-AUSP-ZSPART'
                        before = ls_so_chr-zspart
                        after  = ls_mat_chr-matspart_gaon ) TO lt_result.
      ENDIF.
    ENDIF.


*    DATA(ls_mat_chr) = VALUE #( lt_mat_chr[ vbeln = ls_so_chr-vbeln
*                                           posnr = ls_so_chr-posnr ]
*                                OPTIONAL ).

*    READ TABLE lt_mat_chr INTO DATA(ls_mat_chr) WITH KEY vbeln = ls_so_chr-vbeln
*                                                          posnr = ls_so_chr-posnr.
*    IF sy-subrc NE 0.
*      CONTINUE.
*    ELSE.
*
*      IF ls_mat_chr-pkgmatnr       IS NOT INITIAL.
*        IF ls_so_chr-pkgmatnr NE ls_mat_chr-pkgmatnr.
*          lv_chg = 'X'.
*          APPEND VALUE #( vbeln  = ls_so_chr-vbeln
*                          posnr  = ls_so_chr-posnr
*                          matnr  = ls_so_chr-matnr
*                          atnam  = 'SAP_MILLCA_PACKAGING'
*                          before = space
*                          after  = ls_mat_chr-pkgmatnr ) TO lt_result.
*        ENDIF.
*      ENDIF.
*
*
*      IF ls_mat_chr-pkg_drum       IS NOT INITIAL.
*        IF ls_so_chr-pkg_drum NE ls_mat_chr-pkg_drum.
*          lv_chg = 'X'.
*          APPEND VALUE #( vbeln  = ls_so_chr-vbeln
*                          posnr  = ls_so_chr-posnr
*                          matnr  = ls_so_chr-matnr
*                          atnam  = 'PD_CA_PACKING_DM'
*                          before = space
*                          after  = ls_mat_chr-pkg_drum ) TO lt_result.
*        ENDIF.
*      ENDIF.
*
*      IF ls_mat_chr-cmsta       IS NOT INITIAL.
*        IF ls_so_chr-cmsta NE ls_mat_chr-cmsta.
*          lv_chg = 'X'.
*          APPEND VALUE #( vbeln  = ls_so_chr-vbeln
*                          posnr  = ls_so_chr-posnr
*                          matnr  = ls_so_chr-matnr
*                          atnam  = 'PD_CA_PACKMARK_STATUS'
*                          before = space
*                          after  = ls_mat_chr-cmsta ) TO lt_result.
*        ENDIF.
*      ENDIF.
*      CLEAR ls_mat_chr.
*    ENDIF.


    IF lv_chg = 'X'.
      lv_cnt = lv_cnt + 1.
    ENDIF.

  ENDLOOP.

ENDIF.

IF lt_result[] IS INITIAL.
  WRITE:/ '처리 대상이 없습니다!'.
ELSE.

  WRITE:/ '건수:', lv_cnt.
  WRITE:/.
  DATA(lt_vbeln) = lt_result[].
  SORT: lt_vbeln  BY vbeln,
        lt_result BY vbeln posnr.
  DELETE ADJACENT DUPLICATES FROM lt_vbeln COMPARING vbeln.

* 3) Sales Order Info Get.
  _clear: lt_sales_key.
  lt_sales_key[] = CORRESPONDING #( lt_vbeln[] ).

  CLEAR: ls_bapi_view.
  ls_bapi_view = VALUE #( configure  = 'X'
                        ).

  _clear: lt_bapicucfgm, lt_bapicuinsm,
          lt_bapicuprtm, lt_bapicuvalm.
  CALL FUNCTION 'BAPISDORDER_GETDETAILEDLIST'
    EXPORTING
      i_bapi_view           = ls_bapi_view
    TABLES
      sales_documents       = lt_sales_key[]
      order_cfgs_cucfgs_out = lt_bapicucfgm[]
      order_cfgs_cuins_out  = lt_bapicuinsm[]
      order_cfgs_cuprts_out = lt_bapicuprtm[]
      order_cfgs_cuvals_out = lt_bapicuvalm[].

* 4) Change Sales Order Chr.
  LOOP AT lt_vbeln  INTO DATA(ls_vbeln).

    _clear: lt_ref,  lt_inst, lt_value,
            lt_item, lt_itemx.

    CLEAR: ls_result.
    READ TABLE lt_result  INTO ls_result
                          WITH KEY vbeln = ls_vbeln-vbeln
                          BINARY SEARCH.
    IF sy-subrc = 0.

      WRITE:/ ls_vbeln-vbeln.

      CLEAR: lv_posnr.
      LOOP AT lt_result  INTO ls_result  FROM sy-tabix.
        IF ls_result-vbeln = ls_vbeln-vbeln.

          DATA(lv_before) = condense( ls_result-before ).
          DATA(lv_after)  = condense( ls_result-after ).
          WRITE:/ ls_result-posnr, ls_result-matnr,
                  ls_result-atnam, '변경전:', lv_before, '변경후:', lv_after.

**        특성값 구성
          DATA(ls_cucfgs) = VALUE #( lt_bapicucfgm[ sd_doc = ls_result-vbeln
                                                    posex  = ls_result-posnr ]
                                     OPTIONAL ).

          IF ls_cucfgs IS NOT INITIAL.

            CLEAR: ls_ref.
            ls_ref = CORRESPONDING #( ls_cucfgs ).
            APPEND ls_ref  TO lt_ref.

            IF lv_posnr NE ls_result-posnr.

              lv_posnr = ls_result-posnr.
              lt_value[] = VALUE #( BASE lt_value[]
                                    FOR ls_cuvalm  IN lt_bapicuvalm
                                        WHERE ( config_id EQ ls_cucfgs-config_id )
                                    ( VALUE #( BASE CORRESPONDING #( ls_cuvalm )
                                               charc = ls_cuvalm-charc
                                              )
                                     )
                                   ).

              APPEND VALUE #( itm_number = ls_result-posnr
                              po_itm_no  = ls_result-posnr
                             ) TO lt_item.
              APPEND VALUE #( itm_number = ls_result-posnr
                              po_itm_no  = 'X'
                              updateflag = 'U'
                             ) TO lt_itemx.
            ENDIF.

            DATA(ls_cuval) = VALUE #( lt_bapicuvalm[ config_id = ls_cucfgs-config_id
                                                     inst_id   = ls_cucfgs-root_id
                                                     charc     = ls_result-atnam ]
                                      OPTIONAL ).
            IF ls_cuval IS NOT INITIAL.

              DELETE: lt_value WHERE config_id EQ ls_cucfgs-config_id
                                 AND charc     EQ ls_result-atnam.

              CLEAR ls_value.
              MOVE-CORRESPONDING ls_cuval TO ls_value.
              ls_value-value     = ls_result-after.
              CONDENSE: ls_value-value.
              ls_value-value_long = ls_value-value.
              APPEND: ls_value  TO lt_value.

            ELSE.

              APPEND VALUE #( config_id  = ls_cucfgs-config_id
                              inst_id    = ls_cucfgs-root_id
                              charc      = ls_result-atnam
                              value      = ls_result-after
                              value_long = ls_result-after
                             ) TO lt_value.

            ENDIF.

          ENDIF.

        ELSE.
          EXIT.
        ENDIF.
      ENDLOOP.

    ENDIF.

**  특성값 변경
    IF lt_value[] IS NOT INITIAL.

      CLEAR: lv_vbeln, ls_headx.
      _clear: lt_return.

      SORT: lt_item  BY itm_number,
            lt_itemx BY itm_number.
      DELETE ADJACENT DUPLICATES FROM: lt_item  COMPARING itm_number,
                                       lt_itemx COMPARING itm_number.

      lv_vbeln            = ls_vbeln-vbeln.
      ls_headx-updateflag = 'U'.

      lt_inst[] = CORRESPONDING #( lt_bapicuinsm[] ).

      CALL FUNCTION 'BAPI_SALESORDER_CHANGE'
        EXPORTING
          salesdocument    = lv_vbeln
          order_header_inx = ls_headx
        TABLES
          return           = lt_return[]
          order_item_in    = lt_item[]
          order_item_inx   = lt_itemx[]
          order_cfgs_ref   = lt_ref[]
          order_cfgs_inst  = lt_inst[]
          order_cfgs_value = lt_value[].

      DATA(ls_return) = VALUE #( lt_return[ type = 'E' ]  OPTIONAL ).
      IF ls_return IS INITIAL.
        CLEAR: ls_return.
        ls_return = VALUE #( lt_return[ type = 'A' ]  OPTIONAL ).
      ENDIF.

      IF ls_return IS NOT INITIAL.
        MODIFY lt_result  FROM VALUE #( type    = 'E'
                                        message = ls_return-message )
                          TRANSPORTING type message
                          WHERE vbeln = lv_vbeln.
        WRITE:/ 'E:', ls_return-message.

        CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.

      ELSE.
        MODIFY lt_result  FROM VALUE #( type    = 'S'
                                        message = '특성값 성공' )
                          TRANSPORTING type message
                          WHERE vbeln = lv_vbeln.

        WRITE:/ 'S: 특성값 성공'.

        CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
          EXPORTING
            wait = 'X'.
      ENDIF.

      WRITE:/.

    ENDIF.

  ENDLOOP.

* Log Set.
  _clear: lt_log.
  lt_log[] = VALUE #( FOR ls_wa  IN lt_result
                      ( zkey1   = ls_wa-vbeln
                        zkey2   = ls_wa-posnr
                        zkey3   = ls_wa-atnam
                        zkey4   = ls_wa-matnr
                        zvalue1 = ls_wa-before
                        zvalue2 = ls_wa-after
                        zvalue3 = ls_wa-type
                        zvalue4 = ls_wa-message
                       )
                     ).

  IF lt_log[] IS NOT INITIAL.
    MODIFY zgtsdttest  FROM TABLE lt_log[].
  ENDIF.

ENDIF.

**
FREE: lt_so_chr, lt_mat_chr.
