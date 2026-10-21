*&---------------------------------------------------------------------*
*& Include          ZGTLER1120F02
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  same_batch_modi_na_CHK
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM SAME_BATCH_MODI_NA_CHK .

  LOOP AT GL_LIPS.
    IF GL_LIPS-ITEM1 = GV_ITEM1.
      GL_LIPS-XSORT = '1'.
    ELSE.
      GL_LIPS-XSORT = '2'.
    ENDIF.
    MODIFY GL_LIPS TRANSPORTING XSORT .
  ENDLOOP.

*/지정되어 있던것과 아닌것을 분리하여, modify 한다.
  LOOP AT GT_NASG WHERE CHK = 'X'.
    LOOP AT GL_VEPO WHERE EXIDV = GT_NASG-EXIDV
                      AND PLACE = 'N'.
      CLEAR: GV_VEMNG, GV_FLAG.

      IF GL_VEPO-ORGIN = 'N'.
        LOOP AT GL_LIPS WHERE MATNR = GL_VEPO-MATNR
                          AND SOBKZ = GL_VEPO-SOBKZ
                          AND SONUM = GL_VEPO-SONUM
                          AND CHARG = GL_VEPO-CHARG
                          AND ITEM1 = GV_ITEM1
                          AND CALCU = ' '.
          PERFORM CALCULATE_LIPS USING '1' GV_RETURN.
          IF GV_RETURN = 'X'.
            EXIT.
          ENDIF.
        ENDLOOP.
      ELSE.
        LOOP AT GL_LIPS WHERE MATNR = GL_VEPO-MATNR
                          AND VBELN = GL_VEPO-VBELN  "
                          AND POSNR = GL_VEPO-POSNR  "
                          AND SOBKZ = GL_VEPO-SOBKZ
                          AND SONUM = GL_VEPO-SONUM
                          AND CHARG = GL_VEPO-CHARG
                          AND ITEM1 = GV_ITEM1
                          AND CALCU = ' '.
          PERFORM CALCULATE_LIPS USING '1' GV_RETURN.
          IF GV_RETURN = 'X'.
            EXIT.
          ENDIF.
        ENDLOOP.
      ENDIF.

      IF SY-SUBRC = 0 AND GV_FLAG = ' '.
        GL_VEPO-VBELN = P_VBELN.
        GL_VEPO-POSNR = GL_LIPS-POSNR.
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


ENDFORM.                    " same_batch_modi_na_CHK
*&---------------------------------------------------------------------*
*&      Form  batch_append_na_CHK
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM BATCH_APPEND_NA_CHK .

  LOOP AT GT_NASG WHERE CHK = 'X'.
    LOOP AT GL_VEPO WHERE EXIDV = GT_NASG-EXIDV
                      AND PLACE = 'N'.
      CLEAR: GV_VEMNG, GV_FLAG.
*      IF gl_vepo-orgin = 'N'.
      LOOP AT GL_LIPS WHERE MATNR = GL_VEPO-MATNR
                        AND SOBKZ = GL_VEPO-SOBKZ
                        AND SONUM = GL_VEPO-SONUM
                        AND XCHPF = 'X'
                        AND SUB   = '1'
                        AND ITEM1 = GV_ITEM1
                        AND CALCU = ' '.
        PERFORM CALCULATE_LIPS USING '2' GV_RETURN.
        IF GV_RETURN = 'X'.
          EXIT.
        ENDIF.
      ENDLOOP.
*      ELSE.
*        LOOP AT gl_lips WHERE matnr = gl_vepo-matnr
*                          AND sobkz = gl_vepo-sobkz
*                          AND sonum = gl_vepo-sonum
*                          AND xchpf = 'X'
*                          AND sub   = '1'
*                          AND item1 = gv_item1
*                          AND vbeln = gl_vepo-vbeln  "
*                          AND posnr = gl_vepo-posnr  "
*                          AND calcu = ' '.
*          PERFORM calculate_lips USING '1'.
*        ENDLOOP.
*      ENDIF.

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

ENDFORM.                    " batch_append_na_CHK
*&---------------------------------------------------------------------*
*&      Form  CALL_TCODE_HUMO
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GT_ASSG_EXIDV  text
*----------------------------------------------------------------------*
FORM CALL_TCODE_HUMO  USING    P_EXIDV.

  CALL FUNCTION 'Z_LE_HUMO'
    EXPORTING
      I_EXIDV = P_EXIDV
      I_MODE  = 'E'
* IMPORTING
*     RETURN  =
*     ZMESSAGE       =
    .

ENDFORM.                    " CALL_TCODE_HUMO
*&---------------------------------------------------------------------*
*&      Form  check_baesu
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_XT_NASG_DELQTY  text
*      -->P_XT_NASG_LENGTH  text
*----------------------------------------------------------------------*
FORM CHECK_BAESU  USING    P_DELQTY
                           P_LENGTH.

  GV_DIV = P_DELQTY DIV P_LENGTH.

  GV_DELQTY = GV_DIV * P_LENGTH.

  IF GV_DELQTY <> P_DELQTY.
    MESSAGE E000 WITH
      '조장 제품은 배수로 지정되어야 합니다'.
  ENDIF.

ENDFORM.                    " check_baesu
*&---------------------------------------------------------------------*
*&      Form  go_co09
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM GO_CO09 .

  DATA: LV_BERID TYPE BERID.

  READ TABLE GL_LIPS WITH KEY CHK = 'X'.
  IF SY-SUBRC = 0.
    LV_BERID = GL_LIPS-WERKS.
    IF GL_LIPS-SOBKZ = 'E'.
      CALL FUNCTION 'Z_LE_CO09'
        EXPORTING
          I_MATNR = GL_LIPS-MATNR
          I_WERKS = GL_LIPS-WERKS
          I_BERID = LV_BERID
          I_PRREG = 'BE'
          I_VGBEL = GL_LIPS-VGBEL
          I_VGPOS = GL_LIPS-VGPOS
          I_MODE  = 'E'
* IMPORTING
*         MBLNR   =
*         RETURN  =
*         ZMESSAGE       =
        .
    ELSE.
      CALL FUNCTION 'Z_LE_CO09'
        EXPORTING
          I_MATNR = GL_LIPS-MATNR
          I_WERKS = GL_LIPS-WERKS
          I_BERID = LV_BERID
          I_PRREG = 'B'
*         i_vgbel = gl_lips-vgbel
*         i_vgpos = gl_lips-vgpos
          I_MODE  = 'E'
* IMPORTING
*         MBLNR   =
*         RETURN  =
*         ZMESSAGE       =
        .
    ENDIF.
  ENDIF.

*****************************************************
*  READ TABLE gl_lips WITH KEY chk = 'X'.
*  IF sy-subrc = 0.
*    SET PARAMETER ID 'MAT' FIELD gl_lips-matnr.
*    SET PARAMETER ID 'WRK' FIELD gl_lips-werks.
*    SET PARAMETER ID 'BERID' FIELD gl_lips-werks.
*    IF gl_lips-sobkz = 'E'.
*      SET PARAMETER ID 'PRR' FIELD 'BE'.
*      SET PARAMETER ID 'AUN' FIELD gl_lips-vgbel.
*      SET PARAMETER ID 'AUP' FIELD gl_lips-vgpos.
*    ELSE.
*      SET PARAMETER ID 'PRR' FIELD 'B'.
*    ENDIF.
*
*    CALL TRANSACTION 'CO09'
*                 AND SKIP  FIRST SCREEN.
*  ENDIF.

ENDFORM.                                                    " go_co09
*&---------------------------------------------------------------------*
*&      Form  check_over_assign
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM CHECK_OVER_ASSIGN .

  DATA: BEGIN OF LT_POJANG OCCURS 0,
          MATNR LIKE LIPS-MATNR,
          SOBKZ LIKE LIPS-SOBKZ,
          VEMNG LIKE VEPO-VEMNG,
        END OF LT_POJANG.

  DATA: LT_SUB LIKE LT_POJANG OCCURS 0 WITH HEADER LINE.

  LOOP AT GT_NASG WHERE CHK = 'X'.
    LOOP AT GL_VEPO WHERE EXIDV = GT_NASG-EXIDV
                      AND PLACE = 'N'.
      LT_POJANG-MATNR = GL_VEPO-MATNR.
      LT_POJANG-SOBKZ = GL_VEPO-SOBKZ.
      LT_POJANG-VEMNG = GL_VEPO-VEMNG.
      COLLECT LT_POJANG. CLEAR: LT_POJANG.
    ENDLOOP.
  ENDLOOP.

  LOOP AT GL_VEPO WHERE PLACE = 'A'
                    AND FIXED = ' '.
    LT_POJANG-MATNR = GL_VEPO-MATNR.
    LT_POJANG-SOBKZ = GL_VEPO-SOBKZ.
    LT_POJANG-VEMNG = GL_VEPO-VEMNG.
    COLLECT LT_POJANG. CLEAR: LT_POJANG.
  ENDLOOP.

  LOOP AT GL_LIPS WHERE SUB   = '1'
                    AND FIXED = ' '.
    LT_SUB-MATNR = GL_LIPS-MATNR.
    LT_SUB-SOBKZ = GL_LIPS-SOBKZ.
    LT_SUB-VEMNG = GL_LIPS-JISIQTY.
    COLLECT LT_SUB. CLEAR: LT_SUB.
  ENDLOOP.

  CLEAR: GV_FLAG.
  LOOP AT LT_POJANG.
    READ TABLE LT_SUB WITH KEY MATNR = LT_POJANG-MATNR
                               SOBKZ = LT_POJANG-SOBKZ.
    IF SY-SUBRC = 0.
      IF LT_POJANG-VEMNG > LT_SUB-VEMNG.
        MESSAGE I001 WITH LT_POJANG-MATNR
                          '포장수량이 지시수량보다 큽니다'.
        GV_FLAG = 'X'.
      ENDIF.
    ENDIF.
  ENDLOOP.

  IF GV_FLAG = 'X'.
    LEAVE SCREEN.
  ENDIF.

ENDFORM.                    " check_over_assign
*&---------------------------------------------------------------------*
*&      Form  check_cannot_assign
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM CHECK_CANNOT_ASSIGN .

  LOOP AT GT_NASG WHERE CHK = 'X'.
    SELECT * INTO CORRESPONDING FIELDS OF TABLE ET_VEKP
       FROM VEKP
      WHERE EXIDV = GT_NASG-EXIDV.

    CHECK NOT ET_VEKP[] IS INITIAL.

    SELECT * INTO CORRESPONDING FIELDS OF TABLE ET_VEPO
       FROM VEPO
        FOR ALL ENTRIES IN ET_VEKP
      WHERE VENUM = ET_VEKP-VENUM.

    DELETE ET_VEPO WHERE MATNR = ' '.

    LOOP AT ET_VEPO.
      READ TABLE GL_LIPS WITH KEY MATNR = ET_VEPO-MATNR.
      IF SY-SUBRC <> 0.
        MESSAGE I001 WITH GT_NASG-EXIDV
             '지정할수 없는 품목이 있습니다'.
        LEAVE SCREEN.
      ENDIF.
    ENDLOOP.
  ENDLOOP.

ENDFORM.                    " check_cannot_assign
*&---------------------------------------------------------------------*
*&      Form  prepare_dataset_hu
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM PREPARE_DATASET_HU .

  DATA: WA_LIPS1 LIKE GL_LIPS OCCURS 0 WITH HEADER LINE.
  DATA: WA_LIPS2 LIKE GL_LIPS OCCURS 0 WITH HEADER LINE.

  CLEAR: GT_TAB1[], GT_TAB1,
         GT_TAB2[], GT_TAB2,
         GT_TAB3[], GT_TAB3.
  CLEAR: GT_TAB4[], GT_TAB4,
         GT_TAB5[], GT_TAB5,
         GT_TAB6[], GT_TAB6.
  CLEAR: GT_TAB8[], GT_TAB8.

  WA_LIPS[] = GL_LIPS[].

* GL_LIPS 와 CL_LIPS  비교
  LOOP AT GL_LIPS WHERE SUB = '1'.
    CLEAR: WA_LIPS1[], WA_LIPS2[].
    LOOP AT WA_LIPS WHERE ITEM1 = GL_LIPS-ITEM1
                      AND SUB   = '2'.
      MOVE-CORRESPONDING WA_LIPS TO WA_LIPS1.
      APPEND WA_LIPS1.
    ENDLOOP.

    LOOP AT CL_LIPS WHERE ITEM1 = GL_LIPS-ITEM1
                      AND SUB   = '2'.
      MOVE-CORRESPONDING WA_LIPS TO WA_LIPS2.
      APPEND WA_LIPS2.
    ENDLOOP.

    IF WA_LIPS1[] <> WA_LIPS2[].
      GT_TAB4-POSNR = GL_LIPS-ITEM1.
      COLLECT GT_TAB4.

      GT_TAB1-POSNR = GL_LIPS-ITEM1.
      GT_TAB1-LFIMG = GL_LIPS-JISIQTY.
      GT_TAB1-VRKME = GL_LIPS-VRKME.
      COLLECT GT_TAB1. CLEAR: GT_TAB1.

      LOOP AT WA_LIPS1.
        GT_TAB2-UECHA = WA_LIPS1-ITEM1.
        GT_TAB2-LGORT = WA_LIPS1-LGORT.
        GT_TAB2-CHARG = WA_LIPS1-CHARG.
        GT_TAB2-LFIMG = WA_LIPS1-DELQTY.
        GT_TAB2-VRKME = WA_LIPS1-VRKME.
        APPEND GT_TAB2.  CLEAR: GT_TAB2.
      ENDLOOP.
    ENDIF.
  ENDLOOP.

*
  LOOP AT GL_VEPO WHERE PLACE = 'A'.
    GT_TAB3-EXIDV = GL_VEPO-EXIDV.
    COLLECT GT_TAB3.
  ENDLOOP.

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

ENDFORM.                    " prepare_dataset_hu
*&---------------------------------------------------------------------*
*&      Form  calculate_lips
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM CALCULATE_LIPS USING P_XX P_RT.

  CLEAR: P_RT.

  WA_LIPS[] = GL_LIPS[].

* 지정된 수량의 합
  CLEAR: GV_DELQTY, GV_DELQTY, GV_SUM_DELQTY.
  LOOP AT WA_LIPS WHERE ITEM1 = GL_LIPS-ITEM1.
    ADD WA_LIPS-DELQTY  TO GV_DELQTY.
  ENDLOOP.
  GV_SUM_DELQTY = GV_DELQTY + GL_VEPO-VEMNG.

* 상위 품목의 지시수량
  READ TABLE WA_LIPS WITH KEY ITEM1 = GL_LIPS-ITEM1
                              SUB   = '1'.

  CLEAR: GV_FLAG.
  IF GV_DELQTY => WA_LIPS-JISIQTY.
    GV_FLAG = 'X'.
  ENDIF.
  CHECK NOT GV_FLAG = 'X'.

  IF P_XX = '1'.
    IF WA_LIPS-JISIQTY > GV_SUM_DELQTY.
      GV_VEMNG       = GL_VEPO-VEMNG.  "지정수량
      GL_LIPS-DELQTY = GL_LIPS-DELQTY + GV_VEMNG.
      GL_LIPS-CALCU  = ' '.
    ELSE.
      GV_VEMNG       = WA_LIPS-JISIQTY - GV_DELQTY.
      GL_LIPS-DELQTY = GL_LIPS-DELQTY + GV_VEMNG.
      GL_LIPS-CALCU  = 'X'.
    ENDIF.
  ELSE.
    IF GL_LIPS-JISIQTY > GV_SUM_DELQTY.
      GV_VEMNG       = GL_VEPO-VEMNG.  "지정수량
      GL_LIPS-CALCU  = ' '.
    ELSE.
      GV_VEMNG       = GL_LIPS-JISIQTY - GV_DELQTY.
      GL_LIPS-CALCU  = 'X'.
    ENDIF.
  ENDIF.

  MODIFY GL_LIPS.

  P_RT = 'X'.

ENDFORM.                    " calculate_lips
*&---------------------------------------------------------------------*
*&      Form  get_data_pojang_disconect_1
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM GET_DATA_POJANG_DISCONECT_1 .

*/ 포장풀기: 지정->미지정
  LOOP AT GL_VEPO WHERE ORGIN = 'A'
                    AND PLACE = 'N'.
    READ TABLE GL_LIPS WITH KEY ITEM1 = GL_VEPO-ITEM1
                                XCHPF = 'X'.   "배치사용
    IF SY-SUBRC = 0.
      GT_TAB5-UECHA = GL_VEPO-ITEM1.
      GT_TAB5-POSNR = GL_VEPO-POSNR.
      COLLECT GT_TAB5.

      GT_TAB4-POSNR = GL_VEPO-ITEM1.
      COLLECT GT_TAB4.
    ELSE.
      GT_TAB4-POSNR = GL_VEPO-ITEM1.
      COLLECT GT_TAB4.
    ENDIF.

    GT_TAB6-EXIDV = GL_VEPO-EXIDV.
    COLLECT GT_TAB6.
  ENDLOOP.

* 동일한 배치에 엎어치는 경우.
  LOOP AT GL_VEPO WHERE ORGIN = 'N'
                    AND PLACE = 'A'
                    AND POSNR <> '000000'
                    AND CHARG <> ' '.
    GT_TAB5-UECHA = GL_VEPO-ITEM1.
    GT_TAB5-POSNR = GL_VEPO-POSNR.
    COLLECT GT_TAB5.

    GT_TAB4-POSNR = GL_VEPO-ITEM1.
    COLLECT GT_TAB4.
  ENDLOOP.

* 수량 modify
  LOOP AT GT_TAB5.
    READ TABLE GL_LIPS WITH KEY POSNR = GT_TAB5-POSNR.
    IF SY-SUBRC = 0 .
      GT_TAB5-LFIMG = GL_LIPS-DELQTY.
    ELSE.
      GT_TAB5-LFIMG = 0.
    ENDIF.
    MODIFY GT_TAB5 TRANSPORTING LFIMG.
  ENDLOOP.

*/ 포장하기: 미지정->지정 => 배치가 추가로 지정되는 경우만.
  LOOP AT GL_VEPO WHERE ORGIN = 'N'
                    AND PLACE = 'A'
                    AND POSNR = '000000'
                    AND CHARG <> ' '.
    GT_TAB2-UECHA = GL_VEPO-ITEM1.
    GT_TAB2-POSNR = GL_VEPO-POSNR.
    GT_TAB2-LFIMG = GL_VEPO-VEMNG.
    GT_TAB2-CHARG = GL_VEPO-CHARG.

    READ TABLE GL_LIPS WITH KEY UECHA = GL_VEPO-ITEM1.
    GT_TAB2-VRKME = GL_LIPS-VRKME.
    GT_TAB2-LGORT = GL_LIPS-LGORT.
    COLLECT GT_TAB2.

    GT_TAB1-POSNR = GL_VEPO-ITEM1.
    GT_TAB1-VRKME = GL_LIPS-VRKME.
    COLLECT GT_TAB1.
  ENDLOOP.

* 배치미사용: 미지정->지정
  LOOP AT GL_VEPO WHERE ORGIN = 'N'
                    AND PLACE = 'A'
                    AND POSNR = '000000'
                    AND CHARG = ' '.
    READ TABLE GL_LIPS WITH KEY UECHA = GL_VEPO-ITEM1.
    GT_TAB1-POSNR = GL_VEPO-ITEM1.
*    gt_tab1-lfimg = gl_vepo-vemng.
    GT_TAB1-VRKME = GL_LIPS-VRKME.
    COLLECT GT_TAB1.
  ENDLOOP.

  LOOP AT GT_TAB1.
    READ TABLE GL_LIPS WITH KEY ITEM1 = GT_TAB1-POSNR
                                SUB   = '1'.
    IF SY-SUBRC = 0.
      GT_TAB1-LFIMG = GL_LIPS-JISIQTY.
      MODIFY GT_TAB1.
    ENDIF.
  ENDLOOP.

  LOOP AT GL_VEPO WHERE ORGIN = 'N'
                    AND PLACE = 'A'.
    GT_TAB3-EXIDV = GL_VEPO-EXIDV.
    COLLECT GT_TAB3.
  ENDLOOP.

ENDFORM.                    " get_data_pojang_disconect_1
*&---------------------------------------------------------------------*
*&      Form  get_data_pojang_conect_1
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM GET_DATA_POJANG_CONECT_1 .

ENDFORM.                    " get_data_pojang_conect_1
*&---------------------------------------------------------------------*
*&      Form  enquene_lock_do
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GT_LIKP_VBELN  text
*----------------------------------------------------------------------*
FORM ENQUENE_DO  USING    P_VBELN.

* 2005.12.08 temp
*+++++++++++++++++++++++++++++++++++*
  DATA: LV_MSGCODE(100).

  CLEAR: GV_FLAG.

  CALL FUNCTION 'ENQUEUE_EVVBLKE'
    EXPORTING
      VBELN          = P_VBELN
    EXCEPTIONS
      FOREIGN_LOCK   = 2
      SYSTEM_FAILURE = 3.
  CASE SY-SUBRC.
    WHEN 0.

    WHEN 2.
      CONCATENATE '납품문서' P_VBELN '사용자' SY-MSGV1
       '현재 처리중입니다' INTO LV_MSGCODE SEPARATED BY SPACE.
      GV_FLAG = 'X'.
      MESSAGE I001 WITH LV_MSGCODE.
      LEAVE SCREEN.
    WHEN OTHERS.
  ENDCASE.

  IF GV_FLAG = ' '.
    SELECT DISTINCT (FTAB)
      INTO CORRESPONDING FIELDS OF TABLE GT_AUN
      FROM LIPS
     WHERE VBELN = P_VBELN.

    LOOP AT GT_AUN.
      CALL FUNCTION 'ENQUEUE_EVVBAKE'
        EXPORTING
          VBELN  = GT_AUN-VGBEL
        EXCEPTIONS
          OTHERS = 3.
      IF SY-SUBRC <> 0.
        CONCATENATE '주문오더' GT_AUN-VGBEL '사용자' SY-MSGV1
         '현재 처리중입니다' INTO LV_MSGCODE SEPARATED BY SPACE.
        MESSAGE I001 WITH LV_MSGCODE.
        GV_FLAG = 'X'.
        LEAVE SCREEN.
        EXIT.
      ENDIF.
    ENDLOOP.
  ENDIF.

ENDFORM.                    " enquene_lock_do
*&---------------------------------------------------------------------*
*&      Form  dequeue_lock_do
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_P_VBELN  text
*----------------------------------------------------------------------*
FORM DEQUEUE_DO  USING    P_VBELN.

ENDFORM.                    " dequeue_lock_do
*&---------------------------------------------------------------------*
*&      Form  dequeue_lock_all
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM DEQUEUE_ALL .

* 2005.12.08 temp
  CALL FUNCTION 'DEQUEUE_ALL'.

ENDFORM.                    " dequeue_lock_all
*&---------------------------------------------------------------------*
*&      Form  ENQUEUE_HU
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GT_NASG_EXIDV  text
*----------------------------------------------------------------------*
FORM ENQUEUE_HU  USING    P_EXIDV.

* 2005.12.08 temp
  DATA: LS_VEKP   TYPE VEKPVB.
  DATA: LV_MSGCODE(100).
  DATA: LV_EXIDV  LIKE VEKP-EXIDV.

  SELECT SINGLE VENUM INTO LS_VEKP-VENUM FROM VEKP
    WHERE EXIDV = P_EXIDV.

  CALL FUNCTION 'ENQUEUE_EVVEKPE'
    EXPORTING
      VENUM  = LS_VEKP-VENUM
    EXCEPTIONS
      OTHERS = 3.
  IF SY-SUBRC <> 0.
    PERFORM EXIT_ALPHA_OUTPUT USING P_EXIDV
                           CHANGING LV_EXIDV.

    CONCATENATE '포장번호' LV_EXIDV '사용자' SY-MSGV1
     '현재 처리중입니다' INTO LV_MSGCODE SEPARATED BY SPACE.

    MESSAGE I001 WITH LV_MSGCODE.
    GV_FLAG = 'X'.
  ENDIF.

ENDFORM.                    " ENQUEUE_HU
*&---------------------------------------------------------------------*
*&      Form  exit_alpha_output
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_P_EXIDV  text
*      <--P_LV_EXIDV  text
*----------------------------------------------------------------------*
FORM EXIT_ALPHA_OUTPUT  USING    P_IN
                        CHANGING P_OUT.

  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
    EXPORTING
      INPUT  = P_IN
    IMPORTING
      OUTPUT = P_OUT.

ENDFORM.                    " exit_alpha_output
*&---------------------------------------------------------------------*
*&      Form  DEQUEUE_HU
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GT_ASSG_EXIDV  text
*----------------------------------------------------------------------*
FORM DEQUEUE_HU  USING    P_EXIDV.

* 2005.12.08 temp
*  DATA: lv_venum TYPE venum.
*
*  SELECT SINGLE venum INTO lv_venum FROM vekp
*    WHERE exidv = p_exidv.
*
*  CALL FUNCTION 'DEQUEUE_EVVEKPE'
*    EXPORTING
*      mandt = sy-mandt
*      venum = lv_venum.

ENDFORM.                    " DEQUEUE_HU
*&---------------------------------------------------------------------*
*&      Form  CHECK_SCREEN_MODIFY
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM CHECK_SCREEN_MODIFY.


  LOOP AT SCREEN.

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

ENDFORM.                    " CHECK_SCREEN_MODIFY
*&---------------------------------------------------------------------*
*&      Form  authority_check
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM AUTHORITY_CHECK .
  DATA: GT_TVST  LIKE TVST OCCURS 0 WITH HEADER LINE,
        LV_SUBRC LIKE SY-SUBRC.

  SELECT *
    INTO TABLE GT_TVST
    FROM TVST
   WHERE VSTEL IN S_VSTEL.

  LOOP  AT  GT_TVST.
    CLEAR : LV_SUBRC.
    CALL FUNCTION 'ZGTLE_AUTHORIZATION_CHECK'"'Z_LE_AUTHORIZATION_CHECK'
      EXPORTING
        I_VSTEL = GT_TVST-VSTEL
        I_TYPE  = '3'
      IMPORTING
        E_SUBRC = LV_SUBRC.

    IF LV_SUBRC <> 0.
      MESSAGE E002 WITH '출하지점에 대한 권한이 없습니다'
                        GT_TVST-VSTEL.
    ENDIF.
  ENDLOOP.

ENDFORM.                    " authority_check
*&---------------------------------------------------------------------*
*&      Form  ASSIGN_SERNR
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM ASSIGN_SERNR .
  PERFORM MAKE_PICKING_DATA.
  PERFORM ASSIGN_VBELN_SERNR.
ENDFORM.                    " ASSIGN_SERNR
*&---------------------------------------------------------------------*
*&      Form  ASSIGN_VBELN_SERNR
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM ASSIGN_VBELN_SERNR .
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

  DATA : L_SERNP      LIKE MARC-SERNP VALUE ' ',
         L_MATNR      LIKE LIPS-MATNR,
         L_WERKS      LIKE LIPS-WERKS,
         L_CHARG      LIKE LIPS-CHARG,
         L_UECHA      LIKE LIPS-UECHA,
         L_POSNR      LIKE LIPS-POSNR,
         L_MULTI1(20),
         L_MULTI2(20),
         L_MULTI3(20),
         L_MULTI4(20),
         KOSTA        LIKE LIPS-KOSTA,
         L_SEQ        TYPE N,
         L_SEQ1       TYPE N,
         L_SEQ2       TYPE N.

*{ 기능개선 157076 - 추가
  DATA : LV_SERNR   LIKE EQUI-SERNR.
*} 기능개선 157076 - 추가

  CLEAR : BDCDATA,BDCDATA[].
  PERFORM DYNPRO USING:
  'X'    'SAPMV50A'              '4004',
  ' '    'BDC_CURSOR'            'LIKP-VBELN',
  ' '    'LIKP-VBELN'	         P_VBELN,
  ' '    'BDC_OKCODE'            '/00'.

  LOOP AT GT_TAB2.

    SELECT SINGLE MATNR WERKS CHARG UECHA
    INTO   (L_MATNR, L_WERKS, L_CHARG, L_UECHA)
    FROM   LIPS
    WHERE  VBELN = P_VBELN
    AND    POSNR = GT_TAB2-POSNR.

    SELECT SINGLE KOSTA INTO KOSTA
    FROM   LIPS
    WHERE  VBELN = P_VBELN
    AND    POSNR IN (
                      SELECT POSNR
                      FROM   LIPS
                      WHERE  VBELN = P_VBELN
                      AND    UECHA = L_UECHA
                      )
    AND    KOSTA <> 'C'.

* 하위 납품들이 전부 피킹완료 될 경우
    IF SY-SUBRC <> 0.

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
*{ 기능개선 157076 - 추가
          PERFORM GET_SERNR_FOR_CHARG USING L_MATNR
                                            L_CHARG
                                            LV_SERNR.
*} 기능개선 157076 - 추가

          SELECT COUNT(*)
          INTO   L_SEQ1
          FROM   LIPS
          WHERE  VBELN  = P_VBELN
          AND    UECHA  = L_UECHA
          AND    POSNR <= GT_TAB2-POSNR.

          L_SEQ = L_UECHA+4(1).
          L_SEQ1 = L_SEQ1 + 1.
          L_SEQ2 = L_SEQ2 + 1.


          CONCATENATE '=CHPL_T0'           L_SEQ2       INTO L_MULTI1.
          CONCATENATE 'RV50A-CHMULT(0'     L_SEQ   ')'  INTO L_MULTI2.
          CONCATENATE 'LIPS-POSNR(0'       L_SEQ1  ')'  INTO L_MULTI3.
          CONCATENATE 'RV50A-LIPS_SELKZ(0' L_SEQ1  ')'  INTO L_MULTI4.

*          PERFORM DYNPRO USING:
*                  'X'    'SAPMV50A'               '4004',
*                  ' '    'BDC_CURSOR'            'LIKP-VBELN',
*                  ' '    'LIKP-VBELN'         P_VBELN,
*                  ' '    'BDC_OKCODE'            '/00'.

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

          PERFORM DYNPRO USING:
                'X' 'SAPMV50A'                  '1000',
                ' ' 'BDC_OKCODE'                '=POPO_T'.   "품목찾기

          PERFORM DYNPRO USING:
                'X' 'SAPMV50A'                  '0111',
                ' ' 'BDC_OKCODE'                '=WEIT',     "ENTER
                ' ' 'RV50A-POSNR'               GT_TAB2-POSNR.  "

          PERFORM DYNPRO USING:
                'X'    'SAPMV50A'               '1000',
                  ' '  'BDC_OKCODE'             '=PSER_T'.
*                  ' '    L_MULTI4               'X'.

          PERFORM DYNPRO USING:
                  'X'    'SAPLIPW1'              '0300',
                  ' '    'BDC_CURSOR'            'RIPW0-SERNR(01)',
                  ' '    'BDC_OKCODE'            '=RWS',
*{ 기능개선 157076 - 변경
                  ' '    'RIPW0-SERNR(01)'       LV_SERNR.
*                  ' '    'RIPW0-SERNR(01)'       L_CHARG.
*} 기능개선 157076 - 변경

*          PERFORM DYNPRO USING:
*          'X'    'SAPMV50A'              '1000',
*          ' '    'BDC_OKCODE'            '=SICH_T'.

*          CALL TRANSACTION 'VL02N' USING BDCDATA
*                           MODE bdc_mode UPDATE 'S'
*                           MESSAGES INTO MESSTAB.

        ENDIF.

      ENDIF.

    ENDIF.

  ENDLOOP.

  PERFORM DYNPRO USING:
  'X'    'SAPMV50A'              '1000',
  ' '    'BDC_OKCODE'            '=SICH_T'.

  PERFORM DEQUEUE_ALL.

  CALL TRANSACTION 'VL02N' USING BDCDATA
       MODE BDC_MODE UPDATE 'S'
       MESSAGES INTO MESSTAB.

* CSR번호: C2006080801000000259 수정끝
**************************************
ENDFORM.                    " ASSIGN_VBELN_SERNR

* [START] CSR NO : C20080422_54645
*&---------------------------------------------------------------------*
*&      Form  SORT_ASC
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM SORT_ASC .
  SORT XT_NASG BY CHARG ASCENDING.
ENDFORM.                    " SORT_ASC
*&---------------------------------------------------------------------*
*&      Form  SORT_DESC
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM SORT_DESC .
  SORT XT_NASG BY CHARG DESCENDING.
ENDFORM.                    " SORT_DESC
* [END]   CSR NO : C20080422_54645

*&---------------------------------------------------------------------*
*&      Form  CALL_MSC2N
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM CALL_MSC2N .

* 만약 2건 이상일 경우 오류 발생시킴
  DATA : L_COUNT TYPE I.
  LOOP AT XT_NASG WHERE CHK = 'X'.
    L_COUNT = L_COUNT + 1.
  ENDLOOP.

  IF L_COUNT = 1.
*    DELETE FROM MEMORY ID WRK.
    READ TABLE XT_NASG WITH KEY CHK = 'X'.
    CLEAR : BDCDATA,BDCDATA[].
    PERFORM DYNPRO USING:
    'X'    'SAPLCHRG'              '1000',
    ' '    'BDC_OKCODE'            '=ENTR',
    ' '    'BDC_SUBSCR'            'SAPLCHRG',
    ' '    'BDC_CURSOR'	           'DFBATCH-CHARG',
    ' '    'DFBATCH-MATNR'         XT_NASG-MATNR,
    ' '    'DFBATCH-CHARG'         XT_NASG-CHARG,
    ' '    'DFBATCH-WERKS'         ' ',
    ' '    'DFBATCH-LGORT'         ' ',
    ' '    'BDC_SUBSCR'            'SAPLCHRG'.

    PERFORM DYNPRO USING:
    'X'    'SAPLCHRG'              '1000',
    ' '    'BDC_OKCODE'	         '=CLAS'.

    CALL TRANSACTION 'MSC2N' USING BDCDATA
                MODE 'A' UPDATE 'S'
                MESSAGES INTO MESSTAB.

    IF SY-SUBRC = 0.
* / 배치특성(정렬순서: CU72)
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

        SELECT SINGLE MTART XCHAR
        INTO   (LV_MTART, LV_XCHAR)
        FROM   MARA AS A INNER JOIN MARC AS C
            ON A~MATNR = C~MATNR
        WHERE  A~MATNR = XL_NASG-MATNR
        AND    C~WERKS = '3602'.

* 트랙터 제품군이고 MFER이고 뱃치사용자재만 체크
        IF S_VSTEL-LOW >= 'M620' AND S_VSTEL-LOW <= 'M629'
           AND LV_MTART = 'MFER' AND LV_XCHAR = 'X'.

          READ TABLE GT_AUSP WITH KEY ATNAM = 'PD_AM_EG_NO'.
          IF SY-SUBRC <> 0.
            CLEAR : GT_AUSP.
            GT_AUSP-ATNAM = 'PD_AM_EG_NO'.
            GT_AUSP-POSNR = '001'.
            APPEND GT_AUSP.
          ENDIF.

          READ TABLE GT_AUSP WITH KEY ATNAM = 'PD_AM_TM_NO'.
          IF SY-SUBRC <> 0.
            CLEAR : GT_AUSP.
            GT_AUSP-ATNAM = 'PD_AM_TM_NO'.
            GT_AUSP-POSNR = '002'.
            APPEND GT_AUSP.
          ENDIF.

          READ TABLE GT_AUSP WITH KEY ATNAM = 'PD_AM_CHASSIS_NO'.
          IF SY-SUBRC <> 0.
            CLEAR : GT_AUSP.
            GT_AUSP-ATNAM = 'PD_AM_CHASSIS_NO'.
            GT_AUSP-POSNR = '003'.
            APPEND GT_AUSP.
          ENDIF.

        ENDIF.

        SORT GT_AUSP BY POSNR.
        LOOP AT GT_AUSP.
          CONCATENATE LV_COL_ATWRT GT_AUSP-ATWRT ';'
            INTO LV_COL_ATWRT. "SEPARATED BY ';'.
        ENDLOOP.

        XL_NASG-CHART = LV_COL_ATWRT+0(99).
        MODIFY XL_NASG.

      ENDLOOP.
    ELSE.
      MESSAGE S000 WITH '뱃치특성이 변경되지 않았습니다.'.
    ENDIF.

  ELSE.
    MESSAGE S000 WITH '선택한 내역이 없거나 두품목이상을 선택했습니다.'.
  ENDIF.

  CLEAR : L_COUNT.
ENDFORM.                    " CALL_MSC2N
*&---------------------------------------------------------------------*
*&      Form  CHECK_BATCH
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM CHECK_BATCH .
* 트랙터 출하지점의 경우 피킹시
* 특성값중 엔진번호가 없으면 피킹처리 않되고 메세지 발생,
* 밋션번호.샤시번호가 1개라도 없으면 메세지발생 후 피킹은 처리
  DATA : LV_MTART LIKE MARA-MTART.
  DATA : LV_XCHAR LIKE MARC-XCHAR.

  DATA : CHAR_EN(40), CHAR_TM(40), CHAR_SA(40), CHAR_ET(40).

  LOOP AT XL_ASSG.
    SELECT SINGLE MTART XCHAR
    INTO   (LV_MTART, LV_XCHAR)
    FROM   MARA AS A INNER JOIN MARC AS C
        ON A~MATNR = C~MATNR
    WHERE  A~MATNR = XL_ASSG-MATNR
    AND    C~WERKS = '3602'.

*   트랙터 제품군이고 MFER이고 뱃치사용자재만 체크
    IF S_VSTEL-LOW >= 'M620' AND S_VSTEL-LOW <= 'M629'
       AND LV_MTART = 'MFER' AND LV_XCHAR = 'X'.

      SPLIT XL_ASSG-CHART AT ';' INTO:
      CHAR_EN CHAR_TM CHAR_SA CHAR_ET.

      IF CHAR_EN IS INITIAL.
        MESSAGE E002 WITH
        XL_ASSG-MATNR XL_ASSG-CHARG '엔진번호 미등록.'.
      ELSE.
        IF CHAR_TM IS INITIAL.
          MESSAGE W002 WITH
          XL_ASSG-MATNR XL_ASSG-CHARG 'TM번호 미등록.'.
        ENDIF.

*-[SRM2206-13540_S
** 트랙터 샤시 특성 사용하지 않음에 따라 비활성화 처리
*        IF CHAR_SA IS INITIAL.
*          MESSAGE W002 WITH XL_ASSG-MATNR
*          XL_ASSG-CHARG '샤시번호 미등록.'.
*        ENDIF.
*]-SRM2206-13540_E

      ENDIF.
    ENDIF.
  ENDLOOP.

ENDFORM.                    " CHECK_BATCH
*&---------------------------------------------------------------------*
*&      Form  select_all
*&---------------------------------------------------------------------*
FORM SELECT_ALL.

  LOOP AT XT_NASG WHERE CHK = ''.
    XT_NASG-CHK = 'X'.
    MODIFY XT_NASG TRANSPORTING CHK.
  ENDLOOP.

ENDFORM.                    " select_all
*&---------------------------------------------------------------------*
*&      Form  deselect_all
*&---------------------------------------------------------------------*
FORM DESELECT_ALL.

  LOOP AT XT_NASG WHERE CHK = 'X'.
    XT_NASG-CHK = ''.
    MODIFY XT_NASG TRANSPORTING CHK.
  ENDLOOP.

ENDFORM.                    " deselect_all
*&---------------------------------------------------------------------*
*&      Form  MAKE_PICKING_DATA_200_1
*&---------------------------------------------------------------------*
*       기능개선 91460 - 추가
*----------------------------------------------------------------------*
FORM MAKE_PICKING_DATA_200_1 .
  DATA: LT_VBFA   LIKE VBFA OCCURS 0 WITH HEADER LINE,
        LT_VBFA_S LIKE VBFA OCCURS 0 WITH HEADER LINE.

  DATA: LS_VBFA     LIKE VBFA.

  DATA: LV_UECHA     LIKE LIPS-UECHA,
        LV_MENGE(20).

  CLEAR   : BDCDATA, MESSTAB, LT_VBFA, LT_VBFA_S.
  REFRESH : BDCDATA, MESSTAB, LT_VBFA, LT_VBFA_S.

  SELECT *
    INTO TABLE LT_VBFA
    FROM VBFA
   WHERE VBELV   = P_VBELN
     AND VBTYP_N IN ('X', 'Q').

  LOOP AT LT_VBFA.
    CLEAR : LT_VBFA_S.

    MOVE-CORRESPONDING LT_VBFA TO LT_VBFA_S.

    CLEAR : LT_VBFA_S-VBELN, LT_VBFA_S-POSNN,
            LT_VBFA_S-ERDAT, LT_VBFA_S-ERZET.

    COLLECT LT_VBFA_S.
  ENDLOOP.

  PERFORM DYNPRO USING :
                  'X' 'SAPMV50A'             '4004',
                  ' ' 'BDC_OKCODE'           '/00',
                  ' ' 'LIKP-VBELN'           P_VBELN,

                  'X' 'SAPMV50A'             '1000',
                  ' ' 'BDC_OKCODE'           '=T\02'.  "피킹탭

  LOOP AT LT_VBFA_S WHERE VBTYP_N = 'X'.
    READ TABLE LT_VBFA_S INTO LS_VBFA WITH KEY VBELV   = LT_VBFA_S-VBELV
                                               POSNV   = LT_VBFA_S-POSNV
                                               VBTYP_N = 'Q'.

*___피킹수량과 포장지정수량이 다른 경우만 실행
    CHECK SY-SUBRC <> 0 OR LT_VBFA_S-RFMNG <> LS_VBFA-RFMNG.

*___배치분할 품목여부
    CLEAR : LV_UECHA.

    WRITE : LT_VBFA_S-RFMNG TO LV_MENGE UNIT LT_VBFA_S-MEINS
                                        NO-GROUPING.
    CONDENSE LV_MENGE.

    SELECT SINGLE UECHA
      INTO LV_UECHA
      FROM LIPS
     WHERE VBELN = LT_VBFA_S-VBELV
       AND POSNR = LT_VBFA_S-POSNV.

    IF LV_UECHA IS NOT INITIAL.
      PERFORM DYNPRO USING :
                  'X' 'SAPMV50A'             '1000',
                  ' ' 'BDC_OKCODE'           '=POPO_T',  "품목선택

                  'X' 'SAPMV50A'             '0111',
                  ' ' 'BDC_OKCODE'           '=WEIT',
                  ' ' 'RV50A-POSNR'          LV_UECHA,

                  'X' 'SAPMV50A'             '1000',
                  ' ' 'BDC_OKCODE'           '=CHPL_T01', "배치 펼치기
                  ' ' 'RV50A-LIPS_SELKZ(01)' 'X',

                  'X' 'SAPMV50A'             '1000',
                  ' ' 'BDC_OKCODE'           '=POPO_T',  "품목선택

                  'X' 'SAPMV50A'             '0111',
                  ' ' 'BDC_OKCODE'           '=WEIT',
                  ' ' 'RV50A-POSNR'          LT_VBFA_S-POSNV,

                  'X' 'SAPMV50A'             '1000',
                  ' ' 'BDC_OKCODE'           '/00',
                  ' ' 'LIPSD-PIKMG(01)'      LV_MENGE,

                  'X' 'SAPMV50A'             '1000',
                  ' ' 'BDC_OKCODE'           '=BACK_T'.
    ELSE.
*___배치분할이 아닌 경우
      PERFORM DYNPRO USING :
                  'X' 'SAPMV50A'             '1000',
                  ' ' 'BDC_OKCODE'           '=POPO_T',  "품목선택

                  'X' 'SAPMV50A'             '0111',
                  ' ' 'BDC_OKCODE'           '=WEIT',
                  ' ' 'RV50A-POSNR'          LT_VBFA_S-POSNV,

                  'X' 'SAPMV50A'             '1000',
                  ' ' 'BDC_OKCODE'           '/00',
                  ' ' 'LIPSD-PIKMG(01)'      LV_MENGE.
    ENDIF.
  ENDLOOP.

  PERFORM DYNPRO USING :
                  'X' 'SAPMV50A'             '1000',
                  ' ' 'BDC_OKCODE'           '=SICH_T'.

ENDFORM.                    " MAKE_PICKING_DATA_200_1
*&---------------------------------------------------------------------*
*&      Form  CALL_TRANSACTION_VL02N
*&---------------------------------------------------------------------*
*       기능개선 91460 - 추가
*----------------------------------------------------------------------*
FORM CALL_TRANSACTION_VL02N .
  DATA: LV_VBELN    LIKE LIKP-VBELN.

  DATA: LV_MESSAGE(200),
        LV_TEXT1(30),
        LV_TEXT2(30),
        LV_TEXT3(30),
        LV_TEXT4(30).

  CALL TRANSACTION 'VL02N' USING         BDCDATA
                           MODE BDC_MODE UPDATE 'S'
                           MESSAGES INTO MESSTAB.

  READ TABLE MESSTAB WITH KEY MSGID = 'VL'
                              MSGNR = '311'.
  IF SY-SUBRC <> 0.
    MESSAGE I004 WITH '피킹 저장 시 에러가 발생하였습니다.'
                      '피킹 정보를 확인하십시오.'.
  ENDIF.

ENDFORM.                    " CALL_TRANSACTION_VL02N
*&---------------------------------------------------------------------*
*&      Form  MAKE_PICKING_DATA_300_1
*&---------------------------------------------------------------------*
*       기능개선 91460 - 추가
*----------------------------------------------------------------------*
FORM MAKE_PICKING_DATA_300_1 .
  DATA: LT_VBFA LIKE VBFA OCCURS 0 WITH HEADER LINE,
        LT_LIPS LIKE LIPS OCCURS 0 WITH HEADER LINE.

  DATA: LV_MENGE(20).

  CLEAR   : BDCDATA, MESSTAB, LT_VBFA, LT_LIPS.
  REFRESH : BDCDATA, MESSTAB, LT_VBFA, LT_LIPS.

  SELECT *
    INTO TABLE LT_VBFA
    FROM VBFA
   WHERE VBELV   = P_VBELN
     AND VBTYP_N = 'Q'.

  SELECT *
    INTO TABLE LT_LIPS
    FROM LIPS
   WHERE VBELN = P_VBELN.

  PERFORM DYNPRO USING :
                  'X' 'SAPMV50A'             '4004',
                  ' ' 'BDC_OKCODE'           '/00',
                  ' ' 'LIKP-VBELN'           P_VBELN,

                  'X' 'SAPMV50A'             '1000',
                  ' ' 'BDC_OKCODE'           '=T\02'.  "피킹탭

  LOOP AT LT_LIPS WHERE XCHPF = 'X'.
*___배치분할 품목 또는 모품목이면서 배치번호가 있는 품목인 경우 실행
    CHECK LT_LIPS-UECHA IS NOT INITIAL OR
        ( LT_LIPS-UECHA IS INITIAL AND LT_LIPS-CHARG IS NOT INITIAL ).

    READ TABLE LT_LIPS WITH KEY VBELN   = LT_VBFA-VBELV
                                POSNR   = LT_VBFA-POSNV.

*___피킹수량과 납품수량 다른 경우만 실행
    CHECK SY-SUBRC <> 0 OR LT_VBFA-RFMNG <> LT_LIPS-LFIMG.

    WRITE : LT_LIPS-LFIMG TO LV_MENGE UNIT LT_LIPS-VRKME
                                      NO-GROUPING.
    CONDENSE LV_MENGE.

    IF LT_LIPS-UECHA IS NOT INITIAL.
      PERFORM DYNPRO USING :
                  'X' 'SAPMV50A'             '1000',
                  ' ' 'BDC_OKCODE'           '=POPO_T',  "품목선택

                  'X' 'SAPMV50A'             '0111',
                  ' ' 'BDC_OKCODE'           '=WEIT',
                  ' ' 'RV50A-POSNR'          LT_LIPS-UECHA,

                  'X' 'SAPMV50A'             '1000',
                  ' ' 'BDC_OKCODE'           '=CHPL_T01', "배치 펼치기
                  ' ' 'RV50A-LIPS_SELKZ(01)' 'X',

                  'X' 'SAPMV50A'             '1000',
                  ' ' 'BDC_OKCODE'           '=POPO_T',  "품목선택

                  'X' 'SAPMV50A'             '0111',
                  ' ' 'BDC_OKCODE'           '=WEIT',
                  ' ' 'RV50A-POSNR'          LT_LIPS-POSNR,

                  'X' 'SAPMV50A'             '1000',
                  ' ' 'BDC_OKCODE'           '/00',
                  ' ' 'LIPSD-PIKMG(01)'      LV_MENGE,

                  'X' 'SAPMV50A'             '1000',
                  ' ' 'BDC_OKCODE'           '=BACK_T'.
    ELSE.
*___배치분할이 아닌 경우
      PERFORM DYNPRO USING :
                  'X' 'SAPMV50A'             '1000',
                  ' ' 'BDC_OKCODE'           '=POPO_T',  "품목선택

                  'X' 'SAPMV50A'             '0111',
                  ' ' 'BDC_OKCODE'           '=WEIT',
                  ' ' 'RV50A-POSNR'          LT_LIPS-POSNR,

                  'X' 'SAPMV50A'             '1000',
                  ' ' 'BDC_OKCODE'           '/00',
                  ' ' 'LIPSD-PIKMG(01)'      LV_MENGE.
    ENDIF.
  ENDLOOP.

  PERFORM DYNPRO USING :
                  'X' 'SAPMV50A'             '1000',
                  ' ' 'BDC_OKCODE'           '=SICH_T'.

ENDFORM.                    " MAKE_PICKING_DATA_300_1
*&---------------------------------------------------------------------*
*&      Form  COPY_QUANTITY
*&---------------------------------------------------------------------*
*       기능개선 145969 - 추가
*----------------------------------------------------------------------*
FORM COPY_QUANTITY .
  DATA: LV_FLAG.

  CLEAR : LV_FLAG.

*___복사대상 존재 여부 점검
  LOOP AT GT_LIPS WHERE POSNR IS NOT INITIAL.
    IF GT_LIPS-JISIQTY <> GT_LIPS-DELQTY AND
       GT_LIPS-DELQTY  IS NOT INITIAL.
      LV_FLAG = 'X'.
    ENDIF.
  ENDLOOP.

  CHECK LV_FLAG IS NOT INITIAL.

  PERFORM POP_UP_CONFIRM(ZLER0004)
    USING '< 확인 >'
          '재고지정 수량을 납품지시 수량으로' &
          '복사 하시겠읍니까?'
 CHANGING GV_RETURN.

  IF GV_RETURN = 'J'.
    LOOP AT GT_LIPS WHERE POSNR IS NOT INITIAL.
      IF GT_LIPS-JISIQTY <> GT_LIPS-DELQTY.
*        GT_LIPS-JISIQTY = GT_LIPS-DELQTY.
*
*        MODIFY GT_LIPS.

        IF NOT GT_LIPS-LENGTH IS INITIAL.
          GL_LIPS-FACTOR = GT_LIPS-DELQTY / GT_LIPS-LENGTH.
        ENDIF.

        GL_LIPS-JISIQTY = GT_LIPS-DELQTY .

        MODIFY GL_LIPS TRANSPORTING JISIQTY FACTOR
                              WHERE POSNR = GT_LIPS-POSNR.
      ENDIF.
    ENDLOOP.
  ELSE.
    MESSAGE S004 WITH '작업이 취소되었습니다.'.
  ENDIF.

ENDFORM.                    " COPY_QUANTITY
*&---------------------------------------------------------------------*
*&      Form  get_sernr_for_charg
*&---------------------------------------------------------------------*
*       기능개선 157076 - 추가
*----------------------------------------------------------------------*
FORM GET_SERNR_FOR_CHARG  USING   PV_MATNR
                                  PV_CHARG
                                  PV_SERNR.

  CHECK PV_MATNR IS NOT INITIAL AND
      ( PV_CHARG IS NOT INITIAL OR PV_SERNR IS NOT INITIAL ).

  CALL FUNCTION 'Z_PP_GET_AM_CHARG_SERNR'
    EXPORTING
      I_MATNR = PV_MATNR
      I_CHARG = PV_CHARG
      I_SERNR = PV_SERNR
    IMPORTING
      E_CHARG = PV_CHARG
      E_SERNR = PV_SERNR.

ENDFORM.                    " get_sernr_for_charg
*&---------------------------------------------------------------------*
*&      Form  CHECK_PDI_INSPECTION
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_XT_ASSG_MATNR  text
*      -->P_XT_ASSG_CHARG  text
*      -->P_XT_ASSG_ICON2  text
*      -->P_XT_ASSG_PDIDT  text
*----------------------------------------------------------------------*
FORM CHECK_PDI_INSPECTION            USING    PI_MATNR
                                              PI_CHARG
                                              PE_ICON2
                                              PE_PDIDT.

*  CLEAR: PE_ICON2, PE_PDIDT.
*  DATA : LV_MATNR LIKE MARA-MATNR.
*
*  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
*    EXPORTING
*      INPUT  = PI_MATNR
*    IMPORTING
*      OUTPUT = LV_MATNR.
*
*  SELECT SINGLE PDIDT
*           INTO PE_PDIDT
*           FROM ZQMT1065
*                WHERE MATNR = LV_MATNR
*                  AND CHARG = PI_CHARG.
*  IF SY-SUBRC = 0.
*    PE_ICON2 = ICON_LED_GREEN.
*  ELSE.
*    PE_ICON2 = ICON_LED_RED.
*  ENDIF.

ENDFORM.                    " CHECK_PDI_INSPECTION
*&---------------------------------------------------------------------*
*&      Form  HIDE_TC
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM HIDE_TC  TABLES   PT_COLS STRUCTURE T_COLUMN
              USING    VALUE(P_INVS).

  PT_COLS-INVISIBLE = P_INVS.

  IF SY-DYNNR = '0100'.
    MODIFY PT_COLS TRANSPORTING INVISIBLE
                   WHERE SCREEN-NAME = 'GT_LIKP-MATGR'.
  ELSEIF SY-DYNNR = '0300'.
    MODIFY PT_COLS TRANSPORTING INVISIBLE
                   WHERE SCREEN-NAME = 'GT_LIPS-MATGR'.
  ENDIF.

ENDFORM.                    " HIDE_TC
*&---------------------------------------------------------------------*
*& Form GET_OTHER_DATA_COLLECTIVELY
*&---------------------------------------------------------------------*
*& SRM2403-04408 - 추가
*&---------------------------------------------------------------------*
FORM GET_OTHER_DATA_COLLECTIVELY .

  REFRESH : GR_ATNAMO, GT_ORDS,  GT_ORDVALS.

*___오더 특성
  GR_ATNAMO = VALUE #( BASE GR_ATNAMO
                         SIGN = 'I' OPTION = 'EQ'
                         ( LOW = BA_LENGTH          )
                         ( LOW = SO_PACKAGING_CAT   )
                         ( LOW = SO_PACKAGING       )
                         ( LOW = SO_LENGTH          )
                         ( LOW = BA_PD_TB_PRINT_APP )
                         ( LOW = SO_GRADE ) ).

  IF GT_LIKP-LFART = 'NL'.
    GT_ORDS = VALUE #( BASE GT_ORDS
                        FOR LW_LIPS IN GL_LIPS
                          WHERE ( SUB = '1' AND VGBEL IS NOT INITIAL )
                          ( EBELN = LW_LIPS-VGBEL
                            EBELP = LW_LIPS-VGPOS ) ).
  ELSE.
    GT_ORDS = VALUE #( BASE GT_ORDS
                        FOR LW_LIPS IN GL_LIPS
                          WHERE ( SUB = '1' AND VGBEL IS NOT INITIAL )
                          ( VBELN = LW_LIPS-VGBEL
                            POSNV = LW_LIPS-VGPOS ) ).
  ENDIF.

*___오더 특성
  CALL FUNCTION 'Z_GET_CHAR_OF_ORDER'
    EXPORTING
      IR_ATNAM = GR_ATNAMO
    TABLES
      IT_ORDS  = GT_ORDS
      ET_VALS  = GT_ORDVALS.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form F4_VSTEL
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&---------------------------------------------------------------------*
FORM F4_VSTEL  USING   PV_FNAME.

  SELECT DISTINCT B~VSTEL,C~VTEXT
    FROM TVKWZ AS A INNER JOIN TVSWZ AS B
                    ON A~WERKS = B~WERKS
                    INNER JOIN TVSTT AS C
                    ON B~VSTEL = C~VSTEL AND
                       C~SPRAS = @SY-LANGU
   WHERE A~VKORG EQ @GC_VKORG_6000
    INTO TABLE @DATA(LT_VALUE).
  SORT LT_VALUE BY VSTEL.
  CHECK LT_VALUE[] IS NOT INITIAL.

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      RETFIELD        = 'VSTEL'
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
*& Form F4_LGORT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&---------------------------------------------------------------------*
FORM F4_LGORT  USING  PV_FNAME.

  SELECT DISTINCT A~WERKS,B~NAME1,C~LGORT,C~LGOBE
    FROM TVKWZ AS A INNER JOIN T001W AS B
                    ON A~WERKS = B~WERKS
                    INNER JOIN T001L AS C
                    ON B~WERKS = C~WERKS
   WHERE A~VKORG EQ @GC_VKORG_6000
    INTO TABLE @DATA(LT_VALUE).
  SORT LT_VALUE BY WERKS.
  CHECK LT_VALUE[] IS NOT INITIAL.

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      RETFIELD        = 'LGORT'
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
*& Form F4_VTWEG
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&---------------------------------------------------------------------*
FORM F4_VTWEG  USING   PV_FNAME.

  SELECT A~VKORG,A~VTWEG,B~VTEXT
    FROM TVKOV AS A INNER JOIN TVTWT AS B
                    ON A~VTWEG = B~VTWEG AND
                       B~SPRAS = @SY-LANGU
   WHERE A~VKORG EQ @GC_VKORG_6000
    INTO TABLE @DATA(LT_VALUE).
  SORT LT_VALUE BY VKORG VTWEG.
  CHECK LT_VALUE[] IS NOT INITIAL.

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      RETFIELD        = 'VTWEG'
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
*& Form F4_SPART
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&---------------------------------------------------------------------*
FORM F4_SPART  USING  PV_FNAME.

  SELECT VKORG,VTWEG,SPART
    FROM TVTA
   WHERE VKORG EQ @GC_VKORG_6000
    INTO TABLE @DATA(LT_VALUE).

  SORT LT_VALUE BY VKORG VTWEG SPART.
  DELETE ADJACENT DUPLICATES FROM LT_VALUE COMPARING VKORG VTWEG SPART.

  CHECK LT_VALUE[] IS NOT INITIAL.

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      RETFIELD        = 'SPART'
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
