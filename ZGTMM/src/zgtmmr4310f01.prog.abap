*&---------------------------------------------------------------------*
*& Include          ZGTMMR4310F01
*&---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*& Form F_INITIALIZATION
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM f_initialization .

  "I/F 시스템
  DATA : lt_ifno TYPE vrm_values.

  " 1) SELECT FLD_01,FLD_02 INTO Internal Table IFSYST
*   FROM ZGTPPT1010 WHERE MODULE_KIND = 'PP' AND CODEGRP = '0010'.
* 2) IFSYST FLD_01,FLD_02 기준 중복 제거"
  SELECT DISTINCT
         fld_01 AS key,
         fld_02 AS text
    FROM zgtppt1010
    INTO CORRESPONDING FIELDS OF TABLE @lt_ifno
   WHERE module_kind EQ @gc_pp
    AND fld_01 IN ( 'KGPM', 'KGOM' )
   AND codegrp EQ @gc_0010.

  "값이 있는 경우
  IF lt_ifno[] IS NOT INITIAL.
    "정렬
    SORT lt_ifno BY key.
    CALL FUNCTION 'VRM_SET_VALUES'
      EXPORTING
        id     = 'P_IFSYT'
        values = lt_ifno.

    "기본 값 설정
    READ TABLE lt_ifno WITH KEY key = 'KGPM' TRANSPORTING NO FIELDS.
    IF sy-subrc EQ 0.
      p_ifsyt = 'KGPM'.
    ENDIF.
  ENDIF.


  "I/F Date
  IF s_ifdat[] IS INITIAL.
    s_ifdat[] = VALUE #( ( sign = 'I' option = 'BT' low = sy-datlo - 1  high = sy-datlo ) ).
  ENDIF.

  "납품 일자
  IF s_budat[] IS INITIAL.
    s_budat[] = VALUE #( ( sign = 'I' option = 'BT' low = sy-datlo - 1  high = sy-datlo ) ).
  ENDIF.

  "생성 일자
  IF s_cdate[] IS INITIAL.
    s_cdate[] = VALUE #( ( sign = 'I' option = 'BT' low = sy-datlo - 1  high = sy-datlo ) ).
  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_CHECK_FIELD_VALUE_1000
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM f_check_field_value_1000 .

  IF p_del EQ abap_true.
    "플랜트
    IF s_werks[] IS NOT INITIAL.
      SELECT SINGLE
        werks
        FROM t001w
        WHERE werks IN @s_werks
        INTO @DATA(lv_chk1).
      IF sy-subrc NE 0.
        MESSAGE e013 WITH TEXT-h13.
      ENDIF.
    ENDIF.

    "공급업체
    IF s_lifnr[] IS NOT INITIAL.
      SELECT SINGLE
        lifnr
        FROM lfa1
        WHERE lifnr IN @s_lifnr
        INTO @DATA(lv_chk2).
      IF sy-subrc NE 0.
        MESSAGE e013 WITH TEXT-h12.
      ENDIF.
    ENDIF.
  ENDIF.

  "구매오더
  IF s_ebeln[] IS NOT INITIAL.
    SELECT SINGLE
      ebeln
      FROM ekko
      WHERE ebeln IN @s_ebeln
      INTO @DATA(lv_chk3).
    IF sy-subrc NE 0.
      MESSAGE e013 WITH TEXT-h10.
    ENDIF.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& FORM CHECK_AUTH
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
FORM check_auth .

  IF s_werks[] IS NOT INITIAL.
    LOOP AT s_werks INTO DATA(ls_werks).
      AUTHORITY-CHECK OBJECT 'ZCBO_MM001'
                   ID 'WERKS' FIELD ls_werks-low.

      CHECK sy-subrc <> 0.

      SET CURSOR FIELD 'S_WERKS-LOW'.
      MESSAGE e106 WITH s_werks-low. "플랜트 [&] 작업권한을 확인하세요.
    ENDLOOP.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form F_SET_SCREEN_ATTR_1000
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM f_set_screen_attr_1000 .

  LOOP AT SCREEN.

    "활성화/비활성화
    CASE screen-group1.
      WHEN 'CPU' OR 'BAT'.
        IF p_ilog EQ abap_true.
          screen-active = 0.
        ELSE.
          screen-active = 1.
        ENDIF.

      WHEN 'IFD' OR  'FRC'.
        IF p_ilog EQ abap_true.
          screen-active = 1.
        ELSE.
          screen-active = 0.
        ENDIF.
    ENDCASE.

    "필수입력 표시
    CASE screen-group1.
      WHEN 'IFD'.
        IF screen-group3 EQ 'LOW'.
          screen-required = 2.
        ENDIF.

      WHEN 'IFS'.
        IF p_ilog EQ space.
          screen-required = 2.
        ENDIF.

*      WHEN 'LIF'.
*        IF SCREEN-GROUP3 EQ 'LOW' AND P_ILOG EQ ABAP_TRUE.
*          SCREEN-REQUIRED = 2.
*        ENDIF.
*
      WHEN 'WRK' OR 'BUD'.
        IF screen-group3 EQ 'LOW' AND p_ilog EQ space.
          screen-required = 2.
        ENDIF.
    ENDCASE.


    CASE screen-group1.
      WHEN 'LIF' OR 'BUD' OR 'DEL'.
        IF p_lab EQ abap_true.
          screen-active = 0.
        ELSE.
          screen-active = 1.
        ENDIF.

        " 2026.06.22 플랜트 전체 추가
*      WHEN 'WRK'.
*        IF P_LAB EQ ABAP_TRUE AND P_ILOG EQ ABAP_TRUE.
*          SCREEN-ACTIVE = 0.
*        ELSE.
*          SCREEN-ACTIVE = 1.
*        ENDIF.

      WHEN 'CDA'.
        IF p_lab EQ abap_true AND p_send EQ abap_true.
          screen-active = 1.
        ELSE.
          screen-active = 0.
        ENDIF.
    ENDCASE.


    MODIFY SCREEN.
  ENDLOOP.


ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_START_OF_SELECTION
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM f_start_of_selection .

  "필수 입력 값 점검
  PERFORM f_check_input_requ_values_1000.


  CASE abap_true.
    WHEN p_del. "납품문서
      PERFORM f_get_data_del.

    WHEN p_lab. "드럼라벨
      PERFORM f_get_data_lab.

  ENDCASE.




ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_CHECK_INPUT_REQU_VALUES_1000
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM f_check_input_requ_values_1000 .

  CASE abap_true.
    WHEN p_del. "납품서

      CASE abap_true.
        WHEN p_ilog. "I/F Log 조회
          IF s_ifdat[] IS INITIAL.
*        OR S_LIFNR[] IS INITIAL.
            MESSAGE s018 DISPLAY LIKE gc_e.
            LEAVE LIST-PROCESSING.
          ENDIF.
        WHEN p_send. "Data 전송
          IF p_ifsyt IS INITIAL
            OR s_werks[] IS INITIAL
            OR s_budat[] IS INITIAL.
            MESSAGE s018 DISPLAY LIKE gc_e.
            LEAVE LIST-PROCESSING.
          ENDIF.
      ENDCASE.

    WHEN p_lab. "드럼 라벨
      CASE abap_true.
        WHEN p_ilog. "I/F Log 조회
          IF s_ifdat[] IS INITIAL.
            MESSAGE s018 DISPLAY LIKE gc_e.
            LEAVE LIST-PROCESSING.
          ENDIF.
        WHEN p_send. "Data 전송
          IF p_ifsyt IS INITIAL
            OR s_cdate[] IS INITIAL.
            MESSAGE s018 DISPLAY LIKE gc_e.
            LEAVE LIST-PROCESSING.
          ENDIF.
      ENDCASE.

  ENDCASE.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_GET_GSRM_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM f_get_gsrm_data .

  "초기화
  CLEAR:
    gt_item[],
    gt_label[],
    gt_issue[].

  CLEAR:
    gt_top[],
    gt_mid[],
    gt_bot[].

*1)	 실행 조회조건 값을 기준으로 납품문서 저장 정보를 추출 (GT_DATA01)
*	Table : ZGTMMT4910
*	Select 조건  : DELNO,DELITEM,EBELN,EBELP,LIFNR,WERKS,LGORT,MATNR,MENGE,MEINS,BUDAT,EMLIF,LICHA,HSDAT,STATUS
*	WHERE조건
*	WERKS = 입력 플랜트
*	BUDAT = 입력 납품일자
*	SYSTEM_ID = 'KSRM'

  DATA lt_key TYPE HASHED TABLE OF ty_key WITH UNIQUE KEY system_id zifkey delno delitem werks.

  WITH
  +v_max AS (
      SELECT
      z1~system_id,
      z1~delno,
      z1~delitem,
      z1~werks,
      MAX( z1~zifkey ) AS zifkey
      FROM zgtmmt9410 AS z1
      WHERE z1~werks IN @s_werks
      AND z1~delno IN @s_delno
*      AND Z1~LIFNR IN @S_LIFNR
      AND z1~ebeln IN @s_ebeln
      AND z1~budat IN @s_budat
      AND z1~system_id EQ @gc_ksrm
      GROUP BY z1~system_id, z1~delno, z1~delitem, z1~werks
  )
  SELECT
      z1~delno,
      z1~delitem,
      z1~werks,
      z1~ebeln,
      z1~ebelp,
      ek~lifnr,
      ep~matnr,
      CASE WHEN mr~zzmaktx80 EQ @space THEN mt~maktx ELSE mr~zzmaktx80 END AS zzmaktx80,
      z1~lgort,
      z1~menge,
      z1~meins,
      z1~budat,
      z1~emlif,
      z1~licha,
      z1~hsdat,
      z1~status,
      z1~system_id,
      z1~zifkey,
      z1~deltype, "2026.08.14 납품서 유형 추가
      CASE ep~pstyp WHEN @gc_3 THEN @gc_a ELSE
          CASE WHEN mr~mtart IN ( @gc_mcfe, @gc_mcha ) THEN @gc_b ELSE @gc_c END END AS potype
    FROM +v_max AS v1
                INNER JOIN
           zgtmmt9410 AS z1 ON v1~system_id EQ z1~system_id
                                       AND v1~delno EQ z1~delno
                                       AND v1~delitem EQ z1~delitem
                                       AND v1~werks EQ z1~werks
                                       AND v1~zifkey EQ z1~zifkey
                INNER JOIN
           ekpo AS ep ON z1~ebeln EQ ep~ebeln
                            AND z1~ebelp EQ ep~ebelp
                INNER JOIN
           ekko AS ek ON ep~ebeln EQ ek~ebeln
                LEFT OUTER JOIN
           mara AS mr ON ep~matnr EQ mr~matnr
                LEFT OUTER JOIN
           makt AS mt ON ep~matnr EQ mt~matnr
                          AND mt~spras EQ @sy-langu
"전송성공한 납품서 제외
    WHERE ek~lifnr IN @s_lifnr
      AND NOT EXISTS (
       SELECT zz1~delno
        FROM zgtmmt9414 AS zz1
                    INNER JOIN
                zgtmmt9000 AS zz2 ON zz1~zifkey EQ zz2~zifkey
                                            AND zz1~system_id EQ zz2~system_id
        WHERE zz1~system_id EQ  @p_ifsyt
        AND zz1~delno EQ z1~delno
        AND zz2~zstat EQ @gc_s
        AND zz1~srmifkey EQ z1~zifkey
    )
    INTO CORRESPONDING FIELDS OF TABLE @gt_item.

* <-- 2026.08.11 ZGTMMT9410 DELTYPE = A/B 인 경우,
* EKPO, EKKO 참조하지 않고 SELECT하여 APPEND
  WITH
  +v_max AS (
      SELECT
      z1~system_id,
      z1~delno,
      z1~delitem,
      z1~werks,
      MAX( z1~zifkey ) AS zifkey
      FROM zgtmmt9410 AS z1
      WHERE z1~werks IN @s_werks
      AND z1~delno IN @s_delno
*      AND Z1~LIFNR IN @S_LIFNR
      AND z1~ebeln IN @s_ebeln
      AND z1~budat IN @s_budat
      AND z1~system_id EQ @gc_ksrm
      GROUP BY z1~system_id, z1~delno, z1~delitem, z1~werks
  )
  SELECT
      z1~delno,
      z1~delitem,
      z1~werks,
      z1~ebeln,
      z1~ebelp,
      z1~lgort,
      z1~menge,
      z1~meins,
      z1~budat,
      z1~emlif,
      z1~licha,
      z1~hsdat,
      z1~status,
      z1~system_id,
      z1~zifkey,
      z1~deltype, "2026.08.14 납품서 유형 추가
      @gc_b AS potype  "POTYPE은 B로 고정
    FROM +v_max AS v1
                INNER JOIN
           zgtmmt9410 AS z1 ON v1~system_id EQ z1~system_id
                                       AND v1~delno EQ z1~delno
                                       AND v1~delitem EQ z1~delitem
                                       AND v1~werks EQ z1~werks
                                       AND v1~zifkey EQ z1~zifkey
    WHERE z1~deltype NE @space  "DELTYPE에 값 있는 경우
    "전송성공한 납품서 제외
      AND NOT EXISTS (
       SELECT zz1~delno
        FROM zgtmmt9414 AS zz1
                    INNER JOIN
                zgtmmt9000 AS zz2 ON zz1~zifkey EQ zz2~zifkey
                                            AND zz1~system_id EQ zz2~system_id
        WHERE zz1~system_id EQ  @p_ifsyt
        AND zz1~delno EQ z1~delno
        AND zz2~zstat EQ @gc_s
        AND zz1~srmifkey EQ z1~zifkey
    )
    " 위 SELECT문에서 가져온 값 제외
    AND NOT EXISTS (
          SELECT 1
            FROM @gt_item AS ex
           WHERE ex~delno   EQ z1~delno
             AND ex~delitem EQ z1~delitem
        )
    APPENDING CORRESPONDING FIELDS OF TABLE @gt_item.

* --> 2026.08.11 ZGTMMT9410 DELTYPE = A/B 인 경우,
* EKPO, EKKO 참조하지 않고 SELECT하여 APPEND

*  CHECK SY-SUBRC EQ 0.
" 납품서 전체 미전송 오류수정
  CHECK gt_item[] IS NOT INITIAL.

  SELECT DISTINCT
    zz~system_id,
    zz~zifkey,
    zz~delno,
    zz~delitem,
    zz~werks
    FROM @gt_item AS zz
    INTO CORRESPONDING FIELDS OF TABLE @lt_key.

*	2) 	1)에서 추출한 DELNO, DELITEM 번호 기준으로 라벨정보, 납품 투입 자재 정보 추출
*   2-1) 라벨정보 (GT_DATA02)
*   Table : ZGTMMT4911
*   Select 조건  : DELNO,DELITEM,LABELNO,LABELITEM,MENGE,MEINS,PKG_QTY,PKG_UNIT,WERKS,LGORT,EBELN,EBELP
*   WHERE조건
*   WERKS, DELNO, DELITEM = 1)에서 추출한 DELNO, DELITEM, WERKS
*   SYSTEM_ID = 'KSRM'
  SELECT
    z1~delno,
    z1~delitem,
    z1~labelno,
    z1~labelitem,
    z1~werks,
    z1~ebeln,
    z1~ebelp,
    z1~lgort,
    z1~menge,
    z1~meins,
    z1~pkg_qty,
    z1~pkg_unit,
    @p_ifsyt AS system_id,
    z1~zifkey
    FROM zgtmmt9411 AS z1
                  INNER JOIN
              @lt_key AS zz ON z1~system_id EQ zz~system_id
                                  AND z1~zifkey EQ zz~zifkey
                                  AND z1~delno EQ zz~delno
                                  AND z1~delitem EQ zz~delitem
                                  AND z1~werks EQ zz~werks
    INTO CORRESPONDING FIELDS OF TABLE @gt_label.

*   2-2) 하위자재 투입 정보(GT_DATA03)
*   Table : ZGTMMT4912
*   Select 조건  : DELNO,DELITEM,WERKS,LGORT,LIFNR,IDNRK,CHARG,EBELN,EBELP,ISSUE_QTY,ISSUE_UNIT
*   WHERE조건
*   WERKS, DELNO, DELITEM = 1)에서 추출한 DELNO, DELITEM, WERKS
  SELECT
    z1~delno,
    z1~delitem,
    z1~werks,
    z1~lifnr,
    lf~name1,
    z1~idnrk,
    CASE WHEN mr~zzmaktx80 EQ @space THEN mt~maktx ELSE mr~zzmaktx80 END AS zzmaktx80,
    z1~charg,
    z1~issue_qty,
    z1~issue_unit,
    z1~ebeln,
    z1~ebelp,
    z1~lgort,
    @p_ifsyt AS system_id,
    z1~zifkey
    FROM zgtmmt9412 AS z1
                  INNER JOIN
              @lt_key AS zz ON z1~system_id EQ zz~system_id
                                  AND z1~zifkey EQ zz~zifkey
                                  AND z1~delno EQ zz~delno
                                  AND z1~delitem EQ zz~delitem
                                  AND z1~werks EQ zz~werks
                  LEFT OUTER JOIN
              mara AS mr ON z1~idnrk EQ mr~matnr
                  LEFT OUTER JOIN
              makt AS mt ON z1~idnrk EQ mt~matnr
                                AND mt~spras EQ @sy-langu
                  LEFT OUTER JOIN
              lfa1 AS lf ON z1~lifnr EQ lf~lifnr
    INTO CORRESPONDING FIELDS OF TABLE @gt_issue.

  "상단 데이터 설정
  gt_top[] = VALUE #( FOR <ls_item> IN gt_item
                       ( VALUE #( BASE CORRESPONDING #( <ls_item> )
*                                  ZIFKEY  = SPACE
                                  system_id = p_ifsyt ) ) ).

  CLEAR gt_item[].

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_END_OF_SELECTION
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM f_end_of_selection .

  CASE abap_true.
    WHEN p_del.
      "데이터가 없으면 메세지 처리
      IF gt_top[] IS INITIAL.
        MESSAGE s002 DISPLAY LIKE gc_e.
        LEAVE LIST-PROCESSING.
      ENDIF.

      "배치 체크인 경우 바로 전송
      IF p_send EQ abap_true AND p_bat EQ abap_true.
        "데이터 전송
        PERFORM f_send.
      ELSE.
        CHECK sy-batch NE abap_true. "배치 실행이 아닌 경우
        "Screen 100 이동
        CALL SCREEN 100.
      ENDIF.

    WHEN p_lab.

      "데이터가 없으면 메세지 처리
      IF gt_drum[] IS INITIAL.
        MESSAGE s002 DISPLAY LIKE gc_e.
        LEAVE LIST-PROCESSING.
      ENDIF.

      "배치 체크인 경우 바로 전송
      IF p_send EQ abap_true AND p_bat EQ abap_true.
        "데이터 전송
        PERFORM f_send_drum.
      ELSE.
        CHECK sy-batch NE abap_true. "배치 실행이 아닌 경우
        "Screen 100 이동
        CALL SCREEN 200.
      ENDIF.

  ENDCASE.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_GET_IF_LOG_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM f_get_if_log_data .

  "초기화
  CLEAR:
    gt_item[],
    gt_label[],
    gt_issue[].

  CLEAR:
    gt_top[],
    gt_mid[],
    gt_bot[].

  DATA:
    lr_system_id TYPE RANGE OF zgtmmt9000-system_id,
    lr_zstat     TYPE RANGE OF zgtmmt9000-zstat.

  "I/F 시스템
  IF p_ifsyt IS NOT INITIAL.
    lr_system_id = VALUE #( ( sign = 'I' option = 'EQ' low = p_ifsyt ) ).
  ENDIF.

  "상태
  IF p_frc NE abap_true.
    lr_zstat = VALUE #( ( sign = 'I' option = 'EQ' low = gc_e ) ).
  ENDIF.

*1)	 실행 조회조건 값을 기준으로 인터페이스 이력 테이블 정보 추출
*	이력 로그는 최종 데이터 기준으로 조회
*
*	Table : ZMMT9000
*	Select 조건  : ZIFNO,ZIFKEY,SYSTEM_ID,ZSTAT,MESSAGE,IFNAM
*	WHERE조건
*	SYSTEM_ID = 입력 조건 값
*	IFDAT = 입력 기간

*2) 인터페이스 이력 세부 정보 데이터 추출
*	Table : ZMMT9410
*	Select 조건  : DELNO,DELITEM,EBELN,EBELP,LIFNR,WERKS,LGORT,MATNR,MENGE,MEINS,BUDAT,EMLIF,LICHA,HSDAT,STATUS
*	WHERE조건
*	ZIFKEY, SYSTEM_ID = 1) 에서 추출한 Interface Key, System ID


  DATA lt_key TYPE HASHED TABLE OF ty_key WITH UNIQUE KEY system_id zifkey delno delitem werks.

  WITH
  +v_max AS (
      SELECT
      z1~system_id,
      z1~delno,
      z1~delitem,
      z1~werks,
      MAX( z1~zifkey ) AS zifkey
      FROM zgtmmt9414 AS z1
      WHERE z1~werks IN @s_werks
      AND z1~delno IN @s_delno
*      AND Z1~LIFNR IN @S_LIFNR
      AND z1~ebeln IN @s_ebeln
      AND z1~budat IN @s_budat
      AND z1~system_id IN @lr_system_id
      GROUP BY z1~system_id, z1~delno, z1~delitem, z1~werks
  )
  SELECT
      z0~zifno,
      z0~zifkey,
      z0~system_id,
      z0~zstat,
      z0~message,
      z0~ifnam,
      z1~delno,
      z1~delitem,
      z1~werks,
      z1~ebeln,
      z1~ebelp,
      ek~lifnr,
      ep~matnr,
      CASE WHEN mr~zzmaktx80 EQ @space THEN mt~maktx ELSE mr~zzmaktx80 END AS zzmaktx80,
      z1~lgort,
      z1~menge,
      z1~meins,
      z1~budat,
      z1~emlif,
      z1~licha,
      z1~hsdat,
      z1~status,
      z1~potype,
      z1~srmifkey
    FROM +v_max AS v1
                INNER JOIN
           zgtmmt9414 AS z1 ON v1~system_id EQ z1~system_id
                                       AND v1~delno EQ z1~delno
                                       AND v1~delitem EQ z1~delitem
                                       AND v1~werks EQ z1~werks
                                       AND v1~zifkey EQ z1~zifkey
                INNER JOIN
           zgtmmt9000 AS z0 ON z1~zifkey EQ z0~zifkey
                                       AND z1~system_id EQ z0~system_id
                                       AND z0~zifno EQ @gc_mm00032
                INNER JOIN
           ekpo AS ep ON z1~ebeln EQ ep~ebeln
                           AND z1~ebelp EQ ep~ebelp
                INNER JOIN
           ekko AS ek ON ep~ebeln EQ ek~ebeln
                LEFT OUTER JOIN
           mara AS mr ON ep~matnr EQ mr~matnr
                LEFT OUTER JOIN
           makt AS mt ON ep~matnr EQ mt~matnr
                          AND mt~spras EQ @sy-langu
    WHERE z0~zstat IN @lr_zstat "I/F 성공 데이터 포함
    AND ek~lifnr IN @s_lifnr
    INTO CORRESPONDING FIELDS OF TABLE @gt_top.

* <-- 2026.08.11 ZGTMMT9410 DELTYPE = A/B 인 경우,
* EKPO, EKKO 참조하지 않고 SELECT하여 APPEND
  WITH
  +v_max AS (
      SELECT
      z1~system_id,
      z1~delno,
      z1~delitem,
      z1~werks,
      MAX( z1~zifkey ) AS zifkey
      FROM zgtmmt9414 AS z1
      WHERE z1~werks IN @s_werks
      AND z1~delno IN @s_delno
*      AND Z1~LIFNR IN @S_LIFNR
      AND z1~ebeln IN @s_ebeln
      AND z1~budat IN @s_budat
      AND z1~system_id IN @lr_system_id
      GROUP BY z1~system_id, z1~delno, z1~delitem, z1~werks
  )
  SELECT
      z0~zifno,
      z0~zifkey,
      z0~system_id,
      z0~zstat,
      z0~message,
      z0~ifnam,
      z1~delno,
      z1~delitem,
      z1~werks,
      z1~ebeln,
      z1~ebelp,
      z1~lgort,
      z1~menge,
      z1~meins,
      z1~budat,
      z1~emlif,
      z1~licha,
      z1~hsdat,
      z1~status,
      z1~potype,
      z1~srmifkey
    FROM +v_max AS v1
                INNER JOIN
           zgtmmt9414 AS z1 ON v1~system_id EQ z1~system_id
                                       AND v1~delno EQ z1~delno
                                       AND v1~delitem EQ z1~delitem
                                       AND v1~werks EQ z1~werks
                                       AND v1~zifkey EQ z1~zifkey
                INNER JOIN
           zgtmmt9000 AS z0 ON z1~zifkey EQ z0~zifkey
                                       AND z1~system_id EQ z0~system_id
                                       AND z0~zifno EQ @gc_mm00032
    WHERE z0~zstat IN @lr_zstat "I/F 성공 데이터 포함
    " 위 SELECT 문 결과 제외
    AND NOT EXISTS (
          SELECT 1
            FROM @gt_top AS ex
           WHERE ex~delno   EQ z1~delno
             AND ex~delitem EQ z1~delitem
        )
    APPENDING CORRESPONDING FIELDS OF TABLE @gt_top.

* --> 2026.08.11 ZGTMMT9410 DELTYPE = A/B 인 경우,
* EKPO, EKKO 참조하지 않고 SELECT하여 APPEND

*  CHECK sy-subrc EQ 0.
 CHECK GT_ITEM[] IS NOT INITIAL.

  "시스템 내역
  SELECT DISTINCT
         fld_01,
         fld_02
    FROM zgtppt1010
   WHERE module_kind EQ @gc_pp
   AND codegrp EQ @gc_0010
   ORDER BY fld_01
   INTO TABLE @DATA(lt_txt).

  LOOP AT gt_top ASSIGNING FIELD-SYMBOL(<ls_top>).
    READ TABLE lt_txt ASSIGNING FIELD-SYMBOL(<ls_txt>) WITH KEY fld_01 = <ls_top>-system_id BINARY SEARCH.
    CHECK sy-subrc EQ 0.
    <ls_top>-system_txt = <ls_txt>-fld_02.
  ENDLOOP.

  "KEY
  SELECT DISTINCT
    zz~system_id,
    zz~zifkey,
    zz~delno,
    zz~delitem,
    zz~werks
    FROM @gt_top AS zz
    INTO CORRESPONDING FIELDS OF TABLE @lt_key.


*	Table : ZMMT9411
*	Select 조건  : DELNO,DELITEM,LABELNO,LABELITEM,MENGE,MEINS,PKG_QTY,PKG_UNIT,WERKS,LGORT,EBELN,EBELP
*	WHERE조건
*	ZIFKEY = 1) 에서 추출한 Interface Key, System ID
*
*	Table : ZMMT9412
*	Select 조건  : DELNO,DELITEM,WERKS,LGORT,LIFNR,IDNRK,CHARG,EBELN,EBELP,ISSUE_QTY,ISSUE_UNIT
*	WHERE조건
*	ZIFKEY = 1) 에서 추출한 Interface Key, System ID
*
*3) 자재내역, 공급업체 명, 시스템 명 추출
*	4-1) MARA-ZZMAKTX80 (값이 없는 경우 MAKTX)
*	4-2) LFA1-NAME1
*	4-3) ZGTPPT1010-FLD_02

  SELECT
    z1~delno,
    z1~delitem,
    z1~labelno,
    z1~labelitem,
    z1~werks,
    z1~ebeln,
    z1~ebelp,
    z1~lgort,
    z1~menge,
    z1~meins,
    z1~pkg_qty,
    z1~pkg_unit,
    z1~system_id,
    z1~zifkey
    FROM zgtmmt9411 AS z1
                  INNER JOIN
              @lt_key AS zz ON z1~system_id EQ zz~system_id
                                  AND z1~zifkey EQ zz~zifkey
                                  AND z1~delno EQ zz~delno
                                  AND z1~delitem EQ zz~delitem
                                  AND z1~werks EQ zz~werks
    INTO CORRESPONDING FIELDS OF TABLE @gt_label.

  SELECT
    z1~delno,
    z1~delitem,
    z1~werks,
    z1~lifnr,
    lf~name1,
    z1~idnrk,
    CASE WHEN mr~zzmaktx80 EQ @space THEN mt~maktx ELSE mr~zzmaktx80 END AS zzmaktx80,
    z1~charg,
    z1~issue_qty,
    z1~issue_unit,
    z1~ebeln,
    z1~ebelp,
    z1~lgort,
    z1~system_id,
    z1~zifkey
    FROM zgtmmt9412 AS z1
                  INNER JOIN
              @lt_key AS zz ON z1~system_id EQ zz~system_id
                                  AND z1~zifkey EQ zz~zifkey
                                  AND z1~delno EQ zz~delno
                                  AND z1~delitem EQ zz~delitem
                                  AND z1~werks EQ zz~werks
                  LEFT OUTER JOIN
              mara AS mr ON z1~idnrk EQ mr~matnr
                  LEFT OUTER JOIN
              makt AS mt ON z1~idnrk EQ mt~matnr
                                AND mt~spras EQ @sy-langu
                  LEFT OUTER JOIN
              lfa1 AS lf ON z1~lifnr EQ lf~lifnr
    INTO CORRESPONDING FIELDS OF TABLE @gt_issue.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_SEND
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM f_send .

  DATA:
    lv_cnt_s   TYPE int4,
    lv_cnt_e   TYPE int4,
    lv_cnt_run TYPE int4,
    lv_dest    TYPE zdest,
    lt_delno   TYPE ty_t_delno,
    lt_suc     TYPE ty_t_suc,
    lt_sys     TYPE ty_t_sys,
    lt_item    TYPE ty_t_item,
    lt_label   TYPE ty_t_label,
    lt_issue   TYPE ty_t_issue,
    lv_result  TYPE zo_result,
    lv_message TYPE zo_message.

  "선택 여부 점검
  PERFORM f_check_sel_data.

  "대상 시스템 설정
  PERFORM f_set_target_system_list CHANGING lt_sys.

  "배치 전송이 아닌 경우 확인 팝업
  IF ( sy-batch EQ space AND p_bat EQ space )
    OR p_ilog EQ abap_true.
    DATA lv_ans TYPE c LENGTH 1.
    CALL FUNCTION 'POPUP_TO_CONFIRM'
      EXPORTING
        titlebar      = TEXT-tt0
        text_question = TEXT-q01
      IMPORTING
        answer        = lv_ans.
    CHECK lv_ans EQ gc_1.
  ENDIF.

  "대상 시스템별 실행
  LOOP AT lt_sys ASSIGNING FIELD-SYMBOL(<ls_sys>).

    "전송 데이터 설정
    PERFORM f_set_send_data USING <ls_sys>-system_id CHANGING lt_item lt_label lt_issue lt_delno.

    "대상 Key 정렬
    SORT lt_delno BY delno srmifkey.

    "실행 건 계산
    lv_cnt_run = lines( lt_delno ) DIV gc_max.
    IF lines( lt_delno ) MOD gc_max NE 0.
      lv_cnt_run += 1.
    ENDIF.

*	 전송 성공한 이력이 있는 데이터 조회(납품문서 기준)
    PERFORM f_check_send_data USING <ls_sys>-system_id lt_delno CHANGING lt_suc.


    "분할 전송
    DO lv_cnt_run TIMES.
      "RFC 전송 실행
      PERFORM f_run_send_rfc USING sy-index
                                                             <ls_sys>-system_id
                                                             lt_delno
                                                             lt_item
                                                             lt_label
                                                             lt_issue
                                                             lt_suc
                                                   CHANGING lv_cnt_s lv_cnt_e.
    ENDDO.


  ENDLOOP.

  "메세지 처리
  "전체 데이터: &1 성공: &2 실패: &3
  DATA(lv_tot) = lv_cnt_s + lv_cnt_e.
  MESSAGE s073 WITH lv_tot lv_cnt_s lv_cnt_e.


ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_CHECK_SEL_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM f_check_sel_data .

  "데이터 점검
  IF ( sy-batch EQ space AND p_bat EQ space )
    OR p_ilog EQ abap_true.

    "선택 한 라인  없으면 오류
    DATA lt_row TYPE lvc_t_roid.
    CALL METHOD go_grid_top->get_selected_rows
      IMPORTING
        et_row_no = lt_row.
    DELETE lt_row WHERE row_id LE 0.
    IF lt_row[] IS INITIAL.
      MESSAGE e050.
    ENDIF.

  ELSE.

    "배치 실행인 경우 데이터 없으면 오류
    IF gt_top[] IS INITIAL.
*4-3) 전송 버튼 클릭시 선택 된 라인이 없으면 하단 에러 메시지 처리 "선택된 데이터가 없습니다."
      MESSAGE e050.
    ENDIF.

  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_SET_TARGET_SYSTEM_LIST
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- LT_SYS
*&---------------------------------------------------------------------*
FORM f_set_target_system_list  CHANGING ct_sys TYPE ty_t_sys.

  "초기화
  CLEAR ct_sys[].

  "전송 대상 시스템 설정
  IF p_send EQ abap_true.
    ct_sys[] = VALUE #( ( system_id = p_ifsyt ) ).
  ELSE.
    IF ( sy-batch EQ space AND p_bat EQ space ).

      "선택 한 라인 조회
      DATA lt_row TYPE lvc_t_roid.
      CALL METHOD go_grid_top->get_selected_rows
        IMPORTING
          et_row_no = lt_row.

      LOOP AT lt_row ASSIGNING FIELD-SYMBOL(<ls_row>).
        CHECK <ls_row>-row_id GT 0.
        READ TABLE gt_top ASSIGNING FIELD-SYMBOL(<ls_doc>) INDEX <ls_row>-row_id.
        CHECK sy-subrc EQ 0.
        ct_sys[] = VALUE #( BASE ct_sys[] ( system_id = <ls_doc>-system_id ) ).
      ENDLOOP.

      SORT ct_sys BY system_id.
      DELETE ADJACENT DUPLICATES FROM ct_sys COMPARING system_id.

    ELSE.

      "조회 된 전체 시스템
      SELECT DISTINCT zz~system_id
        FROM @gt_top AS zz
         INTO TABLE @ct_sys.

    ENDIF.

  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_SET_SEND_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> <LS_SYS>_SYSTEM_ID
*&      <-- LT_ITEM
*&      <-- LT_LABEL
*&      <-- LT_ISSUE
*&---------------------------------------------------------------------*
FORM f_set_send_data  USING    pv_system_id
                      CHANGING ct_item TYPE ty_t_item
                               ct_label TYPE ty_t_label
                               ct_issue TYPE ty_t_issue
                               ct_delno TYPE ty_t_delno.

  "초기화
  CLEAR:
    ct_delno[],
    ct_item[],
    ct_label[],
    ct_issue[].

  FIELD-SYMBOLS:
    <ls_item>  TYPE ty_item,
    <ls_label> TYPE ty_label,
    <ls_issue> TYPE ty_issue.

  IF ( sy-batch EQ space AND p_bat EQ space )
    OR p_ilog EQ abap_true.
    "선택 한 라인 조회
    DATA lt_row TYPE lvc_t_roid.
    CALL METHOD go_grid_top->get_selected_rows
      IMPORTING
        et_row_no = lt_row.

    "전송대상 납품문서 번호 설정
    LOOP AT lt_row ASSIGNING FIELD-SYMBOL(<ls_row>).
      CHECK <ls_row>-row_id GT 0.
      READ TABLE gt_top ASSIGNING FIELD-SYMBOL(<ls_top>) INDEX <ls_row>-row_id.
      CHECK sy-subrc EQ 0.

      "대상 시스템
      CHECK <ls_top>-system_id EQ pv_system_id.

      IF gv_okcode EQ 'SEND'. "전송인 경우
        CHECK <ls_top>-zstat NE gc_s. "성공이 아닌 것만 -> 재전송시에는 성공여부와 관계없이 전송
      ENDIF.

      READ TABLE ct_delno WITH KEY delno = <ls_top>-delno srmifkey = <ls_top>-zifkey TRANSPORTING NO FIELDS.
      CHECK sy-subrc NE 0.
      ct_delno = VALUE #( BASE ct_delno ( delno = <ls_top>-delno srmifkey = <ls_top>-zifkey ) ).

    ENDLOOP.

  ELSE.

    "배치 실행인 경우 전체 납품서 설정
    SELECT DISTINCT
      zz~delno,
      zz~zifkey AS srmifkey
      FROM @gt_top AS zz
      WHERE system_id EQ @pv_system_id
      INTO TABLE @ct_delno.

  ENDIF.


  "전송 대상이 있으면 진행
  CHECK ct_delno[] IS NOT INITIAL.

  LOOP AT ct_delno ASSIGNING FIELD-SYMBOL(<ls_delno>).

    "납품서
    SELECT
      zz~*
      FROM @gt_top AS zz
      WHERE zz~system_id EQ @pv_system_id
      AND zz~delno EQ @<ls_delno>-delno
      AND zz~zifkey EQ @<ls_delno>-srmifkey
      APPENDING TABLE @ct_item.

    "라벨
    SELECT
      zz~*
      FROM @gt_label AS zz
      WHERE zz~system_id EQ @pv_system_id
      AND zz~delno EQ @<ls_delno>-delno
      AND zz~zifkey EQ @<ls_delno>-srmifkey
      APPENDING TABLE @ct_label.

    "하위자재 출고
    SELECT
      zz~*
      FROM @gt_issue AS zz
      WHERE zz~system_id EQ @pv_system_id
      AND zz~delno EQ @<ls_delno>-delno
      AND zz~zifkey EQ @<ls_delno>-srmifkey
      APPENDING TABLE @ct_issue.

  ENDLOOP.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_RUN_SEND_RFC
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> SY_INDEX
*&      --> <LS_SYS>_SYSTEM_ID
*&      --> LT_DELNO
*&      --> LT_ITEM
*&      --> LT_LABEL
*&      --> LT_ISSUE
*&      <-- LV_CNT_S
*&      <-- LV_CNT_E
*&---------------------------------------------------------------------*
FORM f_run_send_rfc  USING pv_index
                              pv_system_id
                              pt_delno TYPE ty_t_delno
                              pt_item TYPE ty_t_item
                              pt_label TYPE ty_t_label
                              pt_issue TYPE ty_t_issue
                              pt_suc TYPE ty_t_suc
                     CHANGING cv_cnt_s
                              cv_cnt_e.

  DATA:
    lv_start_idx  TYPE int4,
    lv_end_idx    TYPE int4,
    lt_log_item   TYPE ty_t_item,
    lt_log_label  TYPE ty_t_label,
    lt_log_issue  TYPE ty_t_issue,

    lt_send_item  TYPE STANDARD TABLE OF zgtmms4002,
    lt_send_label TYPE STANDARD TABLE OF zgtmms4003,
    lt_send_issue TYPE STANDARD TABLE OF zgtmms4004,
    ls_send_item  TYPE zgtmms4002,
    ls_send_label TYPE zgtmms4003,
    ls_send_issue TYPE zgtmms4004.

  DATA:
    lv_dest    TYPE zdest,
    lv_result  TYPE zo_result,
    lv_message TYPE zo_message.

  "시작 Tabix
  lv_start_idx = pv_index - 1.
  lv_start_idx *= gc_max.
  lv_start_idx += 1.

  "종료 Tabix
  lv_end_idx = lv_start_idx + gc_max.

  "정렬
  SORT:
    pt_item BY zifkey delno delitem,
    pt_label BY zifkey delno delitem,
    pt_issue BY zifkey delno delitem.

  LOOP AT pt_delno ASSIGNING FIELD-SYMBOL(<ls_delno>) FROM lv_start_idx.
    "종료 Tab index 보다 크거나 같으면 종료
    IF sy-tabix GE lv_end_idx.
      EXIT.
    ENDIF.

    "이미 성공한 데이터가 있으면
    READ TABLE pt_suc WITH TABLE KEY system_id = pv_system_id
                                                        delno = <ls_delno>-delno
                                                        srmifkey = <ls_delno>-srmifkey TRANSPORTING NO FIELDS.
    IF sy-subrc EQ 0.
      cv_cnt_e += 1. "오류 추가
      CONTINUE.
    ENDIF.

    "라인추가 - 납품문서
    READ TABLE pt_item WITH KEY zifkey = <ls_delno>-srmifkey delno = <ls_delno>-delno BINARY SEARCH TRANSPORTING NO FIELDS.
    IF sy-subrc EQ 0.
      LOOP AT pt_item ASSIGNING FIELD-SYMBOL(<ls_item>) FROM sy-tabix.
        IF <ls_item>-delno NE <ls_delno>-delno
          OR <ls_item>-zifkey NE <ls_delno>-srmifkey.
          EXIT.
        ENDIF.

        PERFORM f_set_send_item_data USING <ls_item> CHANGING ls_send_item.
        lt_send_item[] = VALUE #( BASE lt_send_item ( ls_send_item ) ).
        lt_log_item[] = VALUE #( BASE lt_log_item ( <ls_item> ) ). "로그

      ENDLOOP.
    ENDIF.

    "라인추가 - 라벨
    READ TABLE pt_label WITH KEY zifkey = <ls_delno>-srmifkey delno = <ls_delno>-delno BINARY SEARCH TRANSPORTING NO FIELDS.
    IF sy-subrc EQ 0.
      LOOP AT pt_label ASSIGNING FIELD-SYMBOL(<ls_label>) FROM sy-tabix.
        IF <ls_label>-delno NE <ls_delno>-delno
          OR <ls_label>-zifkey NE <ls_delno>-srmifkey.
          EXIT.
        ENDIF.

        PERFORM f_set_send_label_data USING <ls_label> CHANGING ls_send_label.
        lt_send_label[] = VALUE #( BASE lt_send_label ( ls_send_label ) ).
        lt_log_label[] = VALUE #( BASE lt_log_label ( <ls_label> ) ). "로그

      ENDLOOP.
    ENDIF.


    "라인추가 - 출고
    READ TABLE pt_issue WITH KEY zifkey = <ls_delno>-srmifkey delno = <ls_delno>-delno BINARY SEARCH TRANSPORTING NO FIELDS.
    IF sy-subrc EQ 0.
      LOOP AT pt_issue ASSIGNING FIELD-SYMBOL(<ls_issue>) FROM sy-tabix.
        IF <ls_issue>-delno NE <ls_delno>-delno
          OR <ls_issue>-zifkey NE <ls_delno>-srmifkey.
          EXIT.
        ENDIF.

        PERFORM f_set_send_issue_data USING <ls_issue> CHANGING ls_send_issue.
        lt_send_issue[] = VALUE #( BASE lt_send_issue ( ls_send_issue ) ).
        lt_log_issue[] = VALUE #( BASE lt_log_issue ( <ls_issue> ) ). "로그

      ENDLOOP.
    ENDIF.

  ENDLOOP.

  "전송 대상이 있으면 진행
  CHECK lt_send_item[] IS NOT INITIAL.

*  DESTINATION 구분 관리용도로 ZGTPPT1010-CODEGRP = '0600' 으로 공통 마스터 추가해뒀습니다.
  CALL FUNCTION 'ZGTMM_IF_GET_DESTINATION'
    EXPORTING
      i_zifno = gc_mm00032
    IMPORTING
      e_zdest = lv_dest.

  CALL FUNCTION 'ZGTMM_IF_O_DELIVERY_INFO_SEND'
    DESTINATION lv_dest
    EXPORTING
      i_system_id = pv_system_id
    IMPORTING
      zo_result   = lv_result
      zo_message  = lv_message
    TABLES
      ot_item     = lt_send_item
      ot_label    = lt_send_label
      ot_issue    = lt_send_issue
    EXCEPTIONS
      OTHERS      = 1.

  IF sy-subrc NE 0.
    lv_result = gc_02.
  ENDIF.

  "메세지 처리
  IF lv_result EQ gc_00.
    "성공
    cv_cnt_s += lines( pt_delno ).
    lv_result = gc_s.
  ELSE.
    "오류
    cv_cnt_e += lines( pt_delno ).
    lv_result = gc_e  .
  ENDIF.

  "로그 저장
  PERFORM f_save_if_log USING lv_result lv_message pv_system_id lt_log_item lt_log_label lt_log_issue.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_SET_SEND_ITEM_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> <LS_ITEM>
*&      <-- LS_SEND_LABEL
*&---------------------------------------------------------------------*
FORM f_set_send_item_data  USING  ps_item TYPE ty_item
                           CHANGING cs_send_item TYPE zgtmms4002.

  cs_send_item = CORRESPONDING #( ps_item ).

  cs_send_item-ebeln = |{ cs_send_item-ebeln ALPHA = OUT }|.
  cs_send_item-ebelp = |{ cs_send_item-ebelp ALPHA = OUT }|.
  cs_send_item-emlif = |{ cs_send_item-emlif ALPHA = OUT }|.

  SHIFT cs_send_item-ebelp LEFT DELETING LEADING '0'.

  IF cs_send_item-hsdat IS INITIAL.
    cs_send_item-hsdat = space.
  ENDIF.

*<--2026.08.14 납품문서 유형 = B일때 플랜트 대체 로직 추가
* 코드마스터 기준으로 보관품 플랜트 -> 기준 플랜트로 변경
  IF cs_send_item-deltype EQ gc_b.
    SELECT SINGLE *
      FROM zgtppt1010
      WHERE module_kind = 'MM'
      AND codegrp EQ '0780'
      AND fld_01 EQ @cs_send_item-deltype
      AND fld_03 EQ @cs_send_item-werks
      INTO @DATA(ls_1010).

    IF sy-subrc EQ 0.
      cs_send_item-werks = ls_1010-fld_02.
    ENDIF.
  ENDIF.
*-->2026.08.14 납품문서 유형 = B일때 플랜트 대체 로직 추가

  CALL FUNCTION 'CONVERSION_EXIT_CUNIT_OUTPUT'
    EXPORTING
      input  = cs_send_item-meins
    IMPORTING
      output = cs_send_item-meins.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_SET_SEND_LABEL_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> <LS_LABEL>
*&      <-- LS_SEND_LABEL
*&---------------------------------------------------------------------*
FORM f_set_send_label_data  USING  ps_label TYPE ty_label
                           CHANGING cs_send_label TYPE zgtmms4003.

  cs_send_label = CORRESPONDING #( ps_label ).

  cs_send_label-ebeln = |{ cs_send_label-ebeln ALPHA = OUT }|.
  cs_send_label-ebelp = |{ cs_send_label-ebelp ALPHA = OUT }|.
  SHIFT cs_send_label-ebelp LEFT DELETING LEADING '0'.

  CALL FUNCTION 'CONVERSION_EXIT_CUNIT_OUTPUT'
    EXPORTING
      input  = cs_send_label-meins
    IMPORTING
      output = cs_send_label-meins.

  CALL FUNCTION 'CONVERSION_EXIT_CUNIT_OUTPUT'
    EXPORTING
      input  = cs_send_label-pkg_unit
    IMPORTING
      output = cs_send_label-pkg_unit.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_SET_SEND_ISSUE_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> <LS_ISSUE>
*&      <-- LS_SEND_LABEL
*&---------------------------------------------------------------------*
FORM f_set_send_issue_data  USING  ps_issue TYPE ty_issue
                           CHANGING cs_send_issue TYPE zgtmms4004.

  cs_send_issue = CORRESPONDING #( ps_issue ).

  cs_send_issue-ebeln = |{ cs_send_issue-ebeln ALPHA = OUT }|.
  cs_send_issue-ebelp = |{ cs_send_issue-ebelp ALPHA = OUT }|.
  cs_send_issue-lifnr = |{ cs_send_issue-lifnr ALPHA = OUT }|.

  SHIFT cs_send_issue-ebelp LEFT DELETING LEADING '0'.

  CALL FUNCTION 'CONVERSION_EXIT_MATN1_OUTPUT'
    EXPORTING
      input  = cs_send_issue-idnrk
    IMPORTING
      output = cs_send_issue-idnrk.

  CALL FUNCTION 'CONVERSION_EXIT_CUNIT_OUTPUT'
    EXPORTING
      input  = cs_send_issue-issue_unit
    IMPORTING
      output = cs_send_issue-issue_unit.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_SAVE_IF_LOG
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LV_RESULT
*&      --> LV_MESSAGE
*&      --> PV_SYSTEM_ID
*&      --> LT_LOG_ITEM
*&      --> LT_LOG_LABEL
*&      --> LT_LOG_ISSUE
*&---------------------------------------------------------------------*
FORM f_save_if_log  USING    pv_result
                             pv_message
                             pv_system_id
                             pt_log_item TYPE ty_t_item
                             pt_log_label TYPE ty_t_label
                             pt_log_issue TYPE ty_t_issue.


  DATA:
    ls_log       TYPE zgtmmt9000,
    lt_log_item  TYPE STANDARD TABLE OF zgtmmt9414,
    lt_log_label TYPE STANDARD TABLE OF zgtmmt9411,
    lt_log_issue TYPE STANDARD TABLE OF zgtmmt9412.


  GET TIME STAMP FIELD ls_log-zifkey.
  ls_log-zifno       = gc_mm00032.
  ls_log-system_id   = pv_system_id.
  ls_log-zstat       = pv_result.
  ls_log-message     = pv_message.
  ls_log-ifdat       = sy-datlo.
  ls_log-iftim       = sy-timlo.
  ls_log-ifnam       = sy-uname.
  ls_log-erdat       = sy-datum.
  ls_log-erdat_local = sy-datlo.
  ls_log-ertim       = sy-uzeit.
  ls_log-ertim_local = sy-timlo.
  ls_log-ernam       = sy-uname.

  lt_log_item[] = VALUE #( FOR <ls_log_item> IN pt_log_item
                       ( VALUE #( BASE CORRESPONDING #( <ls_log_item> )
                                  zifkey  = ls_log-zifkey
                                  srmifkey = <ls_log_item>-zifkey "SRM 에서 수신한 IF Key
                                  system_id = ls_log-system_id ) ) ).

  lt_log_label[] = VALUE #( FOR <ls_log_label> IN pt_log_label
                       ( VALUE #( BASE CORRESPONDING #( <ls_log_label> )
                                  zifkey  = ls_log-zifkey
                                  system_id = ls_log-system_id ) ) ).

  lt_log_issue[] = VALUE #( FOR <ls_log_issue> IN pt_log_issue
                       ( VALUE #( BASE CORRESPONDING #( <ls_log_issue> )
                                  zifkey  = ls_log-zifkey
                                  system_id = ls_log-system_id ) ) ).

  MODIFY zgtmmt9414 FROM TABLE lt_log_item.
  MODIFY zgtmmt9411 FROM TABLE lt_log_label.
  MODIFY zgtmmt9412 FROM TABLE lt_log_issue.
  MODIFY zgtmmt9000 FROM ls_log.
  COMMIT WORK.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_CHECK_SEND_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> <LS_SYS>_SYSTEM_ID
*&      --> LT_DELNO
*&      <-- LT_SUC
*&---------------------------------------------------------------------*
FORM f_check_send_data  USING    pv_system_id
                                 pt_delno TYPE ty_t_delno
                        CHANGING ct_suc TYPE ty_t_suc.

  CLEAR ct_suc[].

  SELECT DISTINCT
     zz1~system_id,
     zz0~delno,
     zz0~srmifkey
   FROM @pt_delno AS zz0
                INNER JOIN
            zgtmmt9414 AS zz1 ON zz0~delno EQ zz1~delno
                                            AND zz0~srmifkey EQ zz1~srmifkey
               INNER JOIN
            zgtmmt9000 AS zz2 ON zz1~zifkey EQ zz2~zifkey
                                       AND zz1~system_id EQ zz2~system_id
                                       AND zz2~zifno EQ @gc_mm00032
   WHERE zz1~system_id EQ  @pv_system_id
   AND zz2~zstat EQ @gc_s
   INTO TABLE @ct_suc.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_GET_DATA_DEL
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM f_get_data_del .

  "데이터 조회
  CASE abap_true.
    WHEN p_send. "CASE 1 : RADIO BUTTON = "Data 전송" 인 경우 Data Gathering

      "GSRM에서 받은 데이터 조회
      PERFORM f_get_gsrm_data.


    WHEN p_ilog. "로그조회

      "로그 데이터 조회
      PERFORM f_get_if_log_data.

  ENDCASE.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_GET_DATA_LAB
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM f_get_data_lab .

  "데이터 조회
  CASE abap_true.
    WHEN p_send.
      "GSRM에서 받은 데이터 조회
      PERFORM f_get_drum_data.

    WHEN p_ilog. "로그조회
      "로그 데이터 조회
      PERFORM f_get_if_log_drum_data.

  ENDCASE.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_GET_DRUM_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM f_get_drum_data .

  "초기화
  CLEAR:
    gt_drum[].

*1)	 실행 조회조건 값을 기준으로 드럼라벨 저장 정보를 추출 (GT_DATA04)
*	Table : ZGTMMT9415
*	Select 조건  : EBELN,EBELP,DR_LABELNO,ERFMG,ERFME
*	WHERE조건
*	IFDATE = 입력 수신 일자
*
*2)   조회된 데이터를 ALV 로 보여준다.
*
*3) Data Sorting
*	: EBELN, EBELP, DR_LABELNO 기준 오름차순

  WITH
    +v_max AS (
    "마지막 수신 받은 데이터
       SELECT
         z0~zifno,
         z0~system_id,
         z1~ebeln,
         z1~ebelp,
         z1~dr_labelno,
         MAX( z0~zifkey ) AS zifkey
         FROM zgtmmt9000 AS z0
                   INNER JOIN
                zgtmmt9415 AS z1 ON z0~zifkey EQ z1~zifkey
                                           AND z0~system_id EQ z1~system_id
         WHERE z0~zifno EQ @gc_mm00030 "수신
         AND z0~system_id EQ @gc_ksrm
         AND z0~ifdat IN @s_cdate
         AND z1~ebeln IN @s_ebeln
         GROUP BY z0~zifno, z0~system_id, z1~ebeln, z1~ebelp, z1~dr_labelno
    )
    SELECT
      @p_ifsyt AS system_id,
      z0~message,
      z0~ifnam,
      z1~ebeln,
      z1~ebelp,
      z1~dr_labelno,
      z1~erfmg,
      z1~erfme,
      z1~status,    "필드추가
      z0~zifkey AS srmifkey, "260526 SRM수신 IFKEY 필드 대상에 추가,
      ep~werks  "2026.06.22 플랜트 추가
      FROM +v_max AS v1
                INNER JOIN
             zgtmmt9000 AS z0 ON v1~zifno EQ z0~zifno
                                         AND v1~system_id EQ z0~system_id
                                         AND v1~zifkey EQ z0~zifkey
                INNER JOIN
             zgtmmt9415 AS z1 ON v1~zifkey EQ z1~zifkey
                                        AND v1~system_id EQ z1~system_id
                                        AND v1~ebeln EQ z1~ebeln
                                        AND v1~ebelp EQ z1~ebelp
                                        AND v1~dr_labelno EQ z1~dr_labelno
                INNER JOIN  " 2026.06.22 플랜트 추가
             ekpo AS ep ON v1~ebeln EQ ep~ebeln
                               AND v1~ebelp EQ ep~ebelp
    WHERE NOT EXISTS (
    "전송 성공한 데이터 제외
      SELECT @abap_true
        FROM zgtmmt9416 AS zz1
                    INNER JOIN
               zgtmmt9000 AS zz0 ON zz1~zifkey EQ zz0~zifkey
                                            AND zz1~system_id EQ zz0~system_id
        WHERE zz1~system_id EQ @p_ifsyt
        AND zz1~ebeln EQ z1~ebeln
        AND zz1~ebelp EQ z1~ebelp
        AND zz1~dr_labelno EQ z1~dr_labelno
        AND zz0~zifno EQ @gc_mm00033 "전송
        AND zz0~zstat EQ @gc_s
        AND zz1~srmifkey EQ z1~zifkey   "조건추가"
    )
    AND ep~werks IN @s_werks   "2026.06.22 플랜트 추가

    ORDER BY z1~ebeln, z1~ebelp, z1~dr_labelno
    INTO CORRESPONDING FIELDS OF TABLE @gt_drum.

  "시스템 내역
  SELECT DISTINCT
         fld_01,
         fld_02
    FROM zgtppt1010
   WHERE module_kind EQ @gc_pp
   AND codegrp EQ @gc_0010
   ORDER BY fld_01
   INTO TABLE @DATA(lt_txt).

  LOOP AT gt_drum ASSIGNING FIELD-SYMBOL(<ls_drum>).
    READ TABLE lt_txt ASSIGNING FIELD-SYMBOL(<ls_txt>) WITH KEY fld_01 = <ls_drum>-system_id BINARY SEARCH.
    CHECK sy-subrc EQ 0.
    <ls_drum>-system_txt = <ls_txt>-fld_02.
  ENDLOOP.


ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_GET_IF_LOG_DRUM_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM f_get_if_log_drum_data .

*1)	 실행 조회조건 값을 기준으로 인터페이스 이력 테이블 정보 추출
*	이력 로그는 최종 데이터 기준으로 조회
*
*	Table : ZMMT9000
*	Select 조건  : ZIFNO,ZIFKEY,SYSTEM_ID,ZSTAT,MESSAGE,IFNAM
*	WHERE조건
*	SYSTEM_ID = 입력 조건 값
*	IFDAT = 입력 기간
*
*
*2) 인터페이스 이력 정보 추출
*	Table : ZMMT9416
*	Select 조건  : EBELN,EBELP,DR_LAVELNO,ERFMG,ERFME
*	WHERE조건
*	ZIFKEY, SYSTEM_ID = 1) 에서 추출한 Interface Key, System ID
*
*	최종 전송 ZIFKEY 정보로 ALV 리스트로 보여줌

  "초기화
  CLEAR:
    gt_drum[].

  DATA:
    lr_system_id TYPE RANGE OF zgtmmt9000-system_id,
    lr_zstat     TYPE RANGE OF zgtmmt9000-zstat.

  "I/F 시스템
  IF p_ifsyt IS NOT INITIAL.
    lr_system_id = VALUE #( ( sign = 'I' option = 'EQ' low = p_ifsyt ) ).
  ENDIF.

  "상태
  IF p_frc NE abap_true.
    lr_zstat = VALUE #( ( sign = 'I' option = 'EQ' low = gc_e ) ).
  ENDIF.


  WITH
    +v_max AS (
    "마지막 전송 한 데이터
       SELECT
         z0~zifno,
         z0~system_id,
         z1~ebeln,
         z1~ebelp,
         z1~dr_labelno,
         MAX( z0~zifkey ) AS zifkey
         FROM zgtmmt9000 AS z0
                   INNER JOIN
                zgtmmt9416 AS z1 ON z0~zifkey EQ z1~zifkey
                                           AND z0~system_id EQ z1~system_id
         WHERE z0~zifno EQ @gc_mm00033 "전송
         AND z0~system_id IN @lr_system_id
         AND z0~ifdat IN @s_ifdat
         AND z1~ebeln IN @s_ebeln
         GROUP BY z0~zifno, z0~system_id, z1~ebeln, z1~ebelp, z1~dr_labelno
    )
    SELECT
      z0~zifno,
      z0~zifkey,
      z0~system_id,
      z0~zstat,
      z0~message,
      z0~ifnam,
      z1~ebeln,
      z1~ebelp,
      z1~dr_labelno,
      z1~erfmg,
      z1~erfme,
      z1~status,
      ep~werks " 2026.06.22 플랜트 추가
      FROM +v_max AS v1
                INNER JOIN
             zgtmmt9000 AS z0 ON v1~zifno EQ z0~zifno
                                         AND v1~system_id EQ z0~system_id
                                         AND v1~zifkey EQ z0~zifkey
                INNER JOIN
             zgtmmt9416 AS z1 ON v1~zifkey EQ z1~zifkey
                                        AND v1~system_id EQ z1~system_id
                                        AND v1~ebeln EQ z1~ebeln
                                        AND v1~ebelp EQ z1~ebelp
                                        AND v1~dr_labelno EQ z1~dr_labelno
                INNER JOIN  " 2026.06.22 플랜트 추가
             ekpo AS ep ON v1~ebeln EQ ep~ebeln
                               AND v1~ebelp EQ ep~ebelp

    WHERE z0~zstat IN @lr_zstat "I/F 성공 데이터 포함
        AND ep~werks IN @s_werks  " 2026.06.22 플랜트 추가
    ORDER BY z1~ebeln, z1~ebelp, z1~dr_labelno
    INTO CORRESPONDING FIELDS OF TABLE @gt_drum.

  "시스템 내역
  SELECT DISTINCT
         fld_01,
         fld_02
    FROM zgtppt1010
   WHERE module_kind EQ @gc_pp
   AND codegrp EQ @gc_0010
   ORDER BY fld_01
   INTO TABLE @DATA(lt_txt).

  LOOP AT gt_drum ASSIGNING FIELD-SYMBOL(<ls_drum>).
    READ TABLE lt_txt ASSIGNING FIELD-SYMBOL(<ls_txt>) WITH KEY fld_01 = <ls_drum>-system_id BINARY SEARCH.
    CHECK sy-subrc EQ 0.
    <ls_drum>-system_txt = <ls_txt>-fld_02.
  ENDLOOP.


ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_SEND_DRUM
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM f_send_drum .

  DATA:
    lt_drum    TYPE STANDARD TABLE OF ty_drum,
    lv_cnt_s   TYPE int4,
    lv_cnt_e   TYPE int4,
    lv_cnt_run TYPE int4,
    lv_dest    TYPE zdest,
    lt_sys     TYPE ty_t_sys,
    lt_suc     TYPE ty_t_drum_suc, "TY_DRUM_SUC,
    lv_result  TYPE zo_result,
    lv_message TYPE zo_message.

  "선택 여부 점검
  PERFORM f_check_sel_data_drum.

  "대상 시스템 설정
  PERFORM f_set_target_system_list_drum CHANGING lt_sys.

  "배치 전송이 아닌 경우 확인 팝업
  IF ( sy-batch EQ space AND p_bat EQ space )
    OR p_ilog EQ abap_true.
    DATA lv_ans TYPE c LENGTH 1.
    CALL FUNCTION 'POPUP_TO_CONFIRM'
      EXPORTING
        titlebar      = TEXT-tt0
        text_question = TEXT-q01
      IMPORTING
        answer        = lv_ans.
    CHECK lv_ans EQ gc_1.
  ENDIF.


  "대상 시스템별 실행
  LOOP AT lt_sys ASSIGNING FIELD-SYMBOL(<ls_sys>).

    "전송 데이터 설정
    PERFORM f_set_send_drum_data USING <ls_sys>-system_id CHANGING lt_drum.


    "대상 Key 정렬_2026.05.21
    SORT lt_drum BY dr_labelno srmifkey.

    "실행 건 계산
    lv_cnt_run = lines( lt_drum ) DIV gc_max.
    IF lines( lt_drum ) MOD gc_max NE 0.
      lv_cnt_run += 1.
    ENDIF.

*	 전송 성공한 이력이 있는 데이터 조회
*    PERFORM F_CHECK_SEND_DRUM_DATA USING <LS_SYS>-SYSTEM_ID LT_DRUM CHANGING LT_SUC. 2026.05.21
    PERFORM f_check_send_drum_data USING <ls_sys>-system_id lt_drum CHANGING lt_suc.

    "분할 전송
    DO lv_cnt_run TIMES.
      "RFC 전송 실행
      PERFORM f_run_send_drum_rfc USING sy-index
                                                             <ls_sys>-system_id
                                                              lt_drum
                                                              lt_suc
                                                   CHANGING lv_cnt_s lv_cnt_e.
    ENDDO.


  ENDLOOP.


  "메세지 처리
  "전체 데이터: &1 성공: &2 실패: &3
  DATA(lv_tot) = lv_cnt_s + lv_cnt_e.
  MESSAGE s073 WITH lv_tot lv_cnt_s lv_cnt_e.


ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_CHECK_SEL_DATA_DRUM
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM f_check_sel_data_drum .

  "데이터 점검
  IF ( sy-batch EQ space AND p_bat EQ space )
    OR p_ilog EQ abap_true.

    "선택 한 라인  없으면 오류
    DATA lt_row TYPE lvc_t_roid.
    CALL METHOD go_grid_200->get_selected_rows
      IMPORTING
        et_row_no = lt_row.
    DELETE lt_row WHERE row_id LE 0.
    IF lt_row[] IS INITIAL.
      MESSAGE e050.
    ENDIF.

  ELSE.

    "배치 실행인 경우 데이터 없으면 오류
    IF gt_drum[] IS INITIAL.
*4-3) 전송 버튼 클릭시 선택 된 라인이 없으면 하단 에러 메시지 처리 "선택된 데이터가 없습니다."
      MESSAGE e050.
    ENDIF.

  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_SET_TARGET_SYSTEM_LIST_DRUM
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- LT_SYS
*&---------------------------------------------------------------------*
FORM f_set_target_system_list_drum  CHANGING ct_sys TYPE ty_t_sys.

  "초기화
  CLEAR ct_sys[].

  "전송 대상 시스템 설정
  IF p_send EQ abap_true.
    ct_sys[] = VALUE #( ( system_id = p_ifsyt ) ).
  ELSE.
    IF ( sy-batch EQ space AND p_bat EQ space ).

      "선택 한 라인 조회
      DATA lt_row TYPE lvc_t_roid.
      CALL METHOD go_grid_200->get_selected_rows
        IMPORTING
          et_row_no = lt_row.

      LOOP AT lt_row ASSIGNING FIELD-SYMBOL(<ls_row>).
        CHECK <ls_row>-row_id GT 0.
        READ TABLE gt_drum ASSIGNING FIELD-SYMBOL(<ls_doc>) INDEX <ls_row>-row_id.
        CHECK sy-subrc EQ 0.
        ct_sys[] = VALUE #( BASE ct_sys[] ( system_id = <ls_doc>-system_id ) ).
      ENDLOOP.

      SORT ct_sys BY system_id.
      DELETE ADJACENT DUPLICATES FROM ct_sys COMPARING system_id.

    ELSE.

      "조회 된 전체 시스템
      SELECT DISTINCT zz~system_id
        FROM @gt_drum AS zz
         INTO TABLE @ct_sys.

    ENDIF.

  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_SET_SEND_DRUM_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> <LS_SYS>_SYSTEM_ID
*&      <-- LT_DRUM
*&---------------------------------------------------------------------*
FORM f_set_send_drum_data  USING    pv_system_id
                           CHANGING ct_drum TYPE ty_t_drum.

  CLEAR ct_drum[].

  IF ( sy-batch EQ space AND p_bat EQ space )
    OR p_ilog EQ abap_true.
    "선택 한 라인 조회
    DATA lt_row TYPE lvc_t_roid.
    CALL METHOD go_grid_200->get_selected_rows
      IMPORTING
        et_row_no = lt_row.

    "전송대상 납품문서 번호 설정
    LOOP AT lt_row ASSIGNING FIELD-SYMBOL(<ls_row>).
      CHECK <ls_row>-row_id GT 0.
      READ TABLE gt_drum ASSIGNING FIELD-SYMBOL(<ls_drum>) INDEX <ls_row>-row_id.
      CHECK sy-subrc EQ 0.

      "대상 시스템
      CHECK <ls_drum>-system_id EQ pv_system_id.

      IF gv_okcode EQ 'SEND'. "전송인 경우
        CHECK <ls_drum>-zstat NE gc_s. "성공이 아닌 것만 -> 재전송시에는 성공여부와 관계없이 전송
      ENDIF.

      APPEND <ls_drum> TO ct_drum.
    ENDLOOP.

  ELSE.

    "배치 실행인 경우 전체 납품서 설정
*    SELECT DISTINCT
*      *
*      FROM @GT_DRUM AS ZZ
*      WHERE SYSTEM_ID EQ @PV_SYSTEM_ID
*      INTO TABLE @CT_DRUM.
*2026.07.06 배치 실행 대상 SELECT 수정
    SELECT DISTINCT *
    FROM @gt_drum AS zz
    WHERE system_id EQ @pv_system_id
    INTO CORRESPONDING FIELDS OF TABLE @ct_drum.
  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_CHECK_SEND_DRUM_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> <LS_SYS>_SYSTEM_ID
*&      --> LT_DRUM
*&      <-- LT_SUC
*&---------------------------------------------------------------------*
FORM f_check_send_drum_data  USING    pv_system_id
                                      pt_drum TYPE ty_t_drum
                             CHANGING ct_suc TYPE ty_t_drum_suc.

  CLEAR ct_suc[].

  SELECT DISTINCT
     zz1~system_id,
     zz0~ebeln,
     zz0~ebelp,
     zz0~dr_labelno,
     zz0~srmifkey
   FROM @pt_drum AS zz0
                INNER JOIN
            zgtmmt9416 AS zz1 ON zz0~ebeln EQ zz1~ebeln
                                            AND zz0~ebelp EQ zz1~ebelp
                                            AND zz0~dr_labelno EQ zz1~dr_labelno
                                            AND zz0~srmifkey EQ zz1~srmifkey "260521 추가
               INNER JOIN
            zgtmmt9000 AS zz2 ON zz1~zifkey EQ zz2~zifkey
                                       AND zz1~system_id EQ zz2~system_id
                                       AND zz2~zifno EQ @gc_mm00033
   WHERE zz1~system_id EQ  @pv_system_id
   AND zz2~zstat EQ @gc_s
   INTO TABLE @ct_suc.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_RUN_SEND_DRUM_RFC
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> SY_INDEX
*&      --> <LS_SYS>_SYSTEM_ID
*&      --> LT_DRUM
*&      --> LT_SUC
*&      <-- LV_CNT_S
*&      <-- LV_CNT_E
*&---------------------------------------------------------------------*
FORM f_run_send_drum_rfc  USING    pv_index
                                   pv_system_id
                                   pt_drum TYPE ty_t_drum
                                   pt_suc TYPE ty_t_drum_suc
                          CHANGING cv_cnt_s
                                   cv_cnt_e.


  DATA:
    lv_start_idx TYPE int4,
    lv_end_idx   TYPE int4,
    lt_log_data  TYPE STANDARD TABLE OF ty_drum,
    lt_send_data TYPE STANDARD TABLE OF zgtmms4011,
    ls_send_data TYPE zgtmms4011.

  DATA:
    lv_dest    TYPE zdest,
    lv_result  TYPE zo_result,
    lv_message TYPE zo_message.

  "시작 Tabix
  lv_start_idx = pv_index - 1.
  lv_start_idx *= gc_max.
  lv_start_idx += 1.

  "종료 Tabix
  lv_end_idx = lv_start_idx + gc_max.

  LOOP AT pt_drum ASSIGNING FIELD-SYMBOL(<ls_drum>) FROM lv_start_idx.
    "종료 Tab index 보다 크거나 같으면 종료
    IF sy-tabix GE lv_end_idx.
      EXIT.
    ENDIF.

    "이미 성공한 데이터가 있으면
    READ TABLE pt_suc WITH KEY system_id = pv_system_id
                                                        ebeln = <ls_drum>-ebeln
                                                        ebelp = <ls_drum>-ebelp
                                                        dr_labelno = <ls_drum>-dr_labelno   "2026.05.21
                                                        srmifkey = <ls_drum>-srmifkey TRANSPORTING NO FIELDS.
    IF sy-subrc EQ 0.
      cv_cnt_e += 1. "오류 추가
      CONTINUE.
    ENDIF.

**<--2026.05.21 신규 로직 추가 주석처리
*    READ TABLE PT_DRUM WITH KEY ZIFKEY = <LS_DR_LABELNO>-SRMIFKEY  "2026.05.21 FS 수정
*                                                      DR_LABELNO = <LS_DR_LABELNO>-DR_LABELNO "2026.05.21 FS 수정
*                                                      BINARY SEARCH TRANSPORTING NO FIELDS.
*    IF SY-SUBRC EQ 0.
*      LOOP AT PT_DRUM ASSIGNING FIELD-SYMBOL(<LS_DRUM>) FROM SY-TABIX.
**      LOOP AT PT_DRUM ASSIGNING <LS_DRUM> FROM SY-TABIX.  "2026.05.21 FS 중복 생성 수정
*        IF <LS_DRUM>-DR_LABELNO NE <LSDR_LABELNO>-LABELNO
*          OR <LS_DRUM>-ZIFKEY NE <LS_LABELNO>-SRMIFKEY.
*          EXIT.
*        ENDIF.
**2026.05.21--> 신규 로직 추가 주석처리

    PERFORM f_set_send_drum_line_data USING <ls_drum> CHANGING ls_send_data.
    lt_send_data[] = VALUE #( BASE lt_send_data ( ls_send_data ) ).
    lt_log_data[] = VALUE #( BASE lt_log_data ( <ls_drum> ) ).

  ENDLOOP.

  "전송 대상이 있으면 진행
  CHECK lt_send_data[] IS NOT INITIAL.

*  DESTINATION 구분 관리용도로 ZGTPPT1010-CODEGRP = '0600' 으로 공통 마스터 추가해뒀습니다.
  CALL FUNCTION 'ZGTMM_IF_GET_DESTINATION'
    EXPORTING
      i_zifno = gc_mm00033
    IMPORTING
      e_zdest = lv_dest.

  CALL FUNCTION 'ZGTMM_IF_O_DRLABEL_SEND'
    DESTINATION lv_dest
    EXPORTING
      i_system_id = pv_system_id
    IMPORTING
      zo_result   = lv_result
      zo_message  = lv_message
    TABLES
      ot_drlabel  = lt_send_data
    EXCEPTIONS
      OTHERS      = 1.

  IF sy-subrc NE 0.
    lv_result = gc_02.
  ENDIF.

  "메세지 처리
  IF lv_result EQ gc_00.
    "성공
    cv_cnt_s += lines( lt_log_data ).
    lv_result = gc_s.
  ELSE.
    "오류
    cv_cnt_e += lines( lt_log_data ).
    lv_result = gc_e  .
  ENDIF.

  "로그 저장
  PERFORM f_save_drum_if_log USING lv_result lv_message pv_system_id lt_log_data.


ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_SET_SEND_DRUM_LINE_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> <LS_DRUM>
*&      <-- LS_SEND_DATA
*&---------------------------------------------------------------------*
FORM f_set_send_drum_line_data  USING  ps_drum TYPE ty_drum
                                CHANGING cs_send_data TYPE zgtmms4011.

  CLEAR cs_send_data.
  cs_send_data = CORRESPONDING #( ps_drum ).
  cs_send_data-ebeln = |{ cs_send_data-ebeln ALPHA = OUT }|.
  cs_send_data-ebelp = |{ cs_send_data-ebelp ALPHA = OUT }|.
  SHIFT cs_send_data-ebelp LEFT DELETING LEADING '0'.

  CALL FUNCTION 'CONVERSION_EXIT_CUNIT_OUTPUT'
    EXPORTING
      input  = cs_send_data-erfme
    IMPORTING
      output = cs_send_data-erfme.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_SAVE_DRUM_IF_LOG
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LV_RESULT
*&      --> LV_MESSAGE
*&      --> PV_SYSTEM_ID
*&      --> LT_LOG_DATA
*&---------------------------------------------------------------------*
FORM f_save_drum_if_log  USING    pv_result
                                  pv_message
                                  pv_system_id
                                  pt_log_data TYPE ty_t_drum.

  DATA:
    ls_log      TYPE zgtmmt9000,
    lt_log_data TYPE STANDARD TABLE OF zgtmmt9416.

  GET TIME STAMP FIELD ls_log-zifkey.
  ls_log-zifno       = gc_mm00033.
  ls_log-system_id   = pv_system_id.
  ls_log-zstat       = pv_result.
  ls_log-message     = pv_message.
  ls_log-ifdat       = sy-datlo.
  ls_log-iftim       = sy-timlo.
  ls_log-ifnam       = sy-uname.
  ls_log-erdat       = sy-datum.
  ls_log-erdat_local = sy-datlo.
  ls_log-ertim       = sy-uzeit.
  ls_log-ertim_local = sy-timlo.
  ls_log-ernam       = sy-uname.

  lt_log_data[] = VALUE #( FOR <ls_log_data> IN pt_log_data
                       ( VALUE #( BASE CORRESPONDING #( <ls_log_data> )
                                  zifkey  = ls_log-zifkey
                                  system_id = ls_log-system_id ) ) ).

  MODIFY zgtmmt9416 FROM TABLE lt_log_data.
  MODIFY zgtmmt9000 FROM ls_log.
  COMMIT WORK.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form F_AT_SCREEN_ON_WERKS
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM f_at_screen_on_werks .

  CHECK sy-ucomm EQ 'ONLI' AND p_send EQ abap_true. "실행 + 데이터 전송인 경우만 점검

  "필수 값 점검
  IF s_werks IS INITIAL.
    MESSAGE e278(00) WITH TEXT-h13.
    LEAVE LIST-PROCESSING.
  ENDIF.

ENDFORM.
