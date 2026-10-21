*&---------------------------------------------------------------------*
*&  Include           MZLE0001I01                                      *
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  exit  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE EXIT INPUT.

  CLEAR TM_TRUNO.

*{ 기능개선 239718 - 추가
  CASE OK_CODE.
    WHEN 'BACK' OR 'EXIT' OR 'CANC'.
      CLEAR : OK_CODE.

      LEAVE TO SCREEN 0.

  ENDCASE.
*} 기능개선 239718 - 추가

ENDMODULE.                 " exit  INPUT
*&---------------------------------------------------------------------*
*&      Module  user_command_0100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_0100 INPUT.

  CASE OK_CODE.
    WHEN 'SAVE'.
      PERFORM SAVE.
    WHEN 'REFR'.
      CLEAR: WA, GT_LIST[], GT_LIST, GV_CHAN.
      WA-IV_TYPE    = GV_IV_TYPE.
      WA-IV_TYPE_NM = GV_IV_TYPE_NM.
      WA-BUKRS      = GV_BUKRS.
    WHEN 'APPL'.
      IF GV_APNUM = '2'.
        CALL SCREEN 0110 STARTING AT 23 2 ENDING AT 47 4.
      ELSE.
        CALL SCREEN 0120 STARTING AT 23 2 ENDING AT 47 3.
      ENDIF.
    WHEN 'DELE'.
      DELETE GT_LIST WHERE CHK = 'X'.
    WHEN 'TONG'.
      PERFORM TONGMUN.
    WHEN 'SEARCH'.
      PERFORM GET_MI_MATNR_ISSUE.
    WHEN 'IWRK' OR 'RWRK'.
      PERFORM SET_IO_WERKS.

*    WHEN 'CHAN'.
*      CLEAR: wa, gt_list[], gt_list.
*      gv_chan = 'X'.
*    WHEN 'ENTR'.
*      IF gv_chan = 'X'.
*        SELECT SINGLE * FROM zlet0005
*           WHERE iv_no = wa-iv_no
*             AND reqst = 'X'.
*        IF sy-subrc = 0.
*          MOVE-CORRESPONDING zlet0005 TO wa.
*        ELSE.
*          MESSAGE s000 WITH
*           '해당하는 통문번호가 없습니다'.
*        ENDIF.
*      ENDIF.
    WHEN 'BACK' .
      LEAVE TO SCREEN 0.
  ENDCASE.

ENDMODULE.                 " user_command_0100  INPUT
*&---------------------------------------------------------------------*
*&      Module  f4_iv_type  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE F4_IV_TYPE INPUT.

*  PERFORM get_f4_iv_type USING wa-iv_type.

ENDMODULE.                 " f4_iv_type  INPUT
*&---------------------------------------------------------------------*
*&      Module  f4_pernr  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE F4_PERNR INPUT.

  PERFORM GET_F4_PERNR  USING ' '
                              WA-BUKRS
                              WA-WERKS
                              WA-IV_TYPE
                              WA-PERNR.

ENDMODULE.                 " f4_pernr  INPUT
*&---------------------------------------------------------------------*
*&      Module  INPUT_WERKS  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE INPUT_WERKS INPUT.

*  IF NOT wa-werks IS INITIAL.
*    SELECT SINGLE name1 INTO wa-werks_t
*      FROM t001w
*     WHERE werks = wa-werks.
*    IF sy-subrc <> 0.
*      MESSAGE e000 WITH
*       '존재하지 않는 플랜트입니다'.
*    ENDIF.
*  ELSE.
*    CLEAR: wa-werks_t.
*  ENDIF.111

  PERFORM GET_WERKS_DESC USING WA-WERKS WA-WERKS_T.

  IF WA-WERKS IS NOT INITIAL
    AND WA-WERKS_T IS INITIAL.
    MESSAGE E001 WITH '존재하지 않는 플랜트입니다'.
  ENDIF.

*{S SRM2209-05218 23.09.2022 10:33:02
  SELECT SINGLE MANDT
    INTO SY-MANDT
    FROM ZLET0071
    WHERE WERKS = WA-WERKS.
  IF SY-SUBRC = 0.
    GV_LGORT_FLAG = 'X'.
  ELSE.
    CLEAR : GV_LGORT_FLAG.
  ENDIF.
*}E SRM2209-05218


ENDMODULE.                 " INPUT_WERKS  INPUT
*&---------------------------------------------------------------------*
*&      Module  INPUT_IV_TYPE  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE INPUT_IV_TYPE INPUT.

*  IF NOT wa-iv_type IS INITIAL.
*    SELECT SINGLE iv_type_nm INTO wa-iv_type_nm
*      FROM zlet0007
*     WHERE gubun = 'MA'
*       AND iv_type LIKE 'E__'
*       AND iv_type = wa-iv_type.
*    IF sy-subrc <> 0.
*      MESSAGE e000 WITH
*       '존재하지 않는 통문유형입니다'.
*    ENDIF.
*
*    IF wa-iv_type = 'E03'. "    부스탁트
*      wa-return_yn = ' '.
**      LOOP AT SCREEN.
**        CASE screen-name.
**          WHEN 'WA-RETURN_YN'.
**            screen-input = 0.
**            MODIFY SCREEN.
**        ENDCASE.
**      ENDLOOP.
*    ENDIF.
*  ELSE.
*    CLEAR: wa-iv_type_nm.
*  ENDIF.

ENDMODULE.                 " INPUT_IV_TYPE  INPUT
*&---------------------------------------------------------------------*
*&      Module  INPUT_KUNNR  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE INPUT_KUNNR INPUT.

  IF NOT WA-KUNNR IS INITIAL.
    SELECT SINGLE NAME1 ORT01 STRAS
      INTO (WA-KUNNR_T, WA-ORT01, WA-STRAS)
      FROM LFA1
     WHERE LIFNR = WA-KUNNR.
    IF SY-SUBRC <> 0.
      GV_ADDRS = 'X'.
      CLEAR: WA-KUNNR_T, WA-ORT01, WA-STRAS, WA-ADDRS.
      IF WA-BUKRS = '1000'.
        MESSAGE E000 WITH
         '존재하지 않는 거래처입니다'.
      ENDIF.
    ELSE.
*-{자체개선 51966 - 엠트론 주소창 활성화
      IF WA-BUKRS = 1000.
        GV_ADDRS = ''.
      ELSEIF WA-BUKRS = 3000.
        WA-CHANGE = 'X'.
      ENDIF.
*-}자체개선 51966_2014.11.05
      CONCATENATE WA-ORT01 WA-STRAS INTO WA-ADDRS.
    ENDIF.
  ELSE.
    CLEAR: WA-KUNNR_T. "wa-ort01, wa-stras, wa-addrs, gv_addrs.
  ENDIF.

ENDMODULE.                 " INPUT_KUNNR  INPUT
*&---------------------------------------------------------------------*
*&      Module  INPUT_PERNR  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE INPUT_PERNR INPUT.

  IF NOT WA-PERNR IS INITIAL.
    SELECT SINGLE ENAME ORGEH
      INTO (WA-ENAME, WA-ORGEH)
      FROM ZZPA0001
     WHERE BEGDA <= SY-DATUM
       AND ENDDA >= SY-DATUM
       AND PERNR =  WA-PERNR
       AND PERSG =  '1'.      "재직자 - 기능개선 239718 - 추가
    .
    IF SY-SUBRC <> 0.
      MESSAGE E000(ZLE1) WITH '존재하지 않는 사원입니다'.
    ELSE.
      SELECT SINGLE ORGTX
        INTO WA-ORGTX
        FROM T527X
       WHERE SPRSL = '3'
         AND ORGEH = WA-ORGEH
         AND BEGDA <= SY-DATUM
         AND ENDDA >= SY-DATUM.
    ENDIF.
  ELSE.
    CLEAR: WA-ENAME, WA-ORGTX, WA-ORGEH.
  ENDIF.

ENDMODULE.                 " INPUT_PERNR  INPUT
*&---------------------------------------------------------------------*
*&      Module  input_pai  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE INPUT_PAI INPUT.

  MODIFY GT_LIST INDEX  TC01-CURRENT_LINE.
  IF SY-SUBRC <> 0.
    GT_LIST-DMBTR = GT_LIST-DMBTR / 100.
    APPEND GT_LIST.
  ENDIF.


ENDMODULE.                 " input_pai  INPUT
*&---------------------------------------------------------------------*
*&      Module  DMBTR  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE DMBTR INPUT.

  GT_LIST-WAERS = 'KRW'.

ENDMODULE.                 " DMBTR  INPUT
*&---------------------------------------------------------------------*
*&      Module  F4_TRUCK_NO  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE F4_TRUCK_NO INPUT.

*  PERFORM f4_trnum(zler0020) USING wa-truck_no.

ENDMODULE.                 " F4_TRUCK_NO  INPUT
*&---------------------------------------------------------------------*
*&      Module  wa_mod  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE WA_MOD INPUT.

*  CLEAR ZLET0017.
*  IF TM_TRUNO = WA-TRUCK_NO.
*       SELECT SINGLE * FROM ZLET0017 WHERE TRNUM EQ WA-TRUCK_NO.
*       CHECK SY-SUBRC = 0.
*       IF WA-DRIVER_NM = ' '.
*         WA-DRIVER_NM = ZLET0017-DRNAM.
*       ENDIF.
*       IF WA-DRIVER_TELNO = ' '.
*         WA-DRIVER_TELNO = ZLET0017-DRPHO.
*       ENDIF.
*  ELSE.
*    IF WA-TRUCK_NO <> ' '.
*       TM_TRUNO = WA-TRUCK_NO.
*       SELECT SINGLE * FROM ZLET0017 WHERE TRNUM EQ WA-TRUCK_NO.
*       IF SY-SUBRC = 0.
*         WA-DRIVER_NM    = ZLET0017-DRNAM.
*         WA-DRIVER_TELNO = ZLET0017-DRPHO.
*       ELSE.
**         CLEAR: WA-DRIVER_NM, WA-DRIVER_TELNO.
*       ENDIF.
*    ELSE.
**      CLEAR: WA-DRIVER_NM, WA-DRIVER_TELNO.
*    ENDIF.
*  ENDIF.
ENDMODULE.                 " wa_mod  INPUT
*&---------------------------------------------------------------------*
*&      Module  INPUTT_UMWRK  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE INPUTT_UMWRK INPUT.

  IF NOT WA-UMWRK IS INITIAL.
    SELECT SINGLE NAME1 INTO WA-UMWRK_T
      FROM T001W
     WHERE WERKS = WA-UMWRK.
    IF SY-SUBRC <> 0.
      MESSAGE E000 WITH
       '존재하지 않는 플랜트입니다'.
    ENDIF.
  ELSE.
    CLEAR: WA-UMWRK_T.
  ENDIF.

ENDMODULE.                 " INPUTT_UMWRK  INPUT
*&---------------------------------------------------------------------*
*&      Module  INPUT_KUNNR1  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE INPUT_KUNNR1 INPUT.

  IF NOT WA-KUNNR1 IS INITIAL.
    SELECT SINGLE NAME1 ORT01 STRAS
      INTO (WA-KUNNR1_T, WA-ORT01, WA-STRAS)
      FROM KNA1
     WHERE KUNNR = WA-KUNNR1.
    IF SY-SUBRC <> 0.
      GV_ADDRS = 'X'.
      CLEAR: WA-KUNNR1_T, WA-ORT01, WA-STRAS, WA-ADDRS.
      IF WA-BUKRS = '1000'.
        MESSAGE E000 WITH
         '존재하지 않는 거래처입니다'.
      ENDIF.
    ELSE.
*-{자체개선 51966 - 엠트론 주소창 활성화
      IF WA-BUKRS = 1000.
        GV_ADDRS = ''.
      ELSEIF WA-BUKRS = 3000.
        WA-CHANGE = 'X'.
      ENDIF.
*-}자체개선 51966_2014.11.05
      CONCATENATE WA-ORT01 WA-STRAS INTO WA-ADDRS.
    ENDIF.
  ELSE.
    CLEAR: WA-KUNNR1_T. "wa-ort01, wa-stras, wa-addrs, gv_addrs.
  ENDIF.


ENDMODULE.                 " INPUT_KUNNR1  INPUT
*&---------------------------------------------------------------------*
*&      Module  CHECK_KUNNR  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE CHECK_KUNNR INPUT.

  IF NOT WA-KUNNR IS INITIAL AND
     NOT WA-KUNNR1 IS INITIAL.
    MESSAGE E000 WITH
    '구매처 또는 납품처 중 하나를 입력하세요'.
  ELSEIF WA-KUNNR IS INITIAL AND
         WA-KUNNR1 IS INITIAL.
    CLEAR: WA-ORT01, WA-STRAS, WA-ADDRS, GV_ADDRS.
  ENDIF.
ENDMODULE.                 " CHECK_KUNNR  INPUT
*&---------------------------------------------------------------------*
*&      Module  f4_bzarea  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE F4_BZAREA INPUT.

  PERFORM GET_F4_BZAREA USING WA-BZAREA.

ENDMODULE.                 " f4_bzarea  INPUT
*&---------------------------------------------------------------------*
*&      Module  INPUT_WA_BZAREA  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE INPUT_WA_BZAREA INPUT.
  IF ( WA-WERKS >= 1600 AND WA-WERKS <= 1609 ) OR
     ( WA-WERKS >= 1781 AND WA-WERKS <= 1789 ) OR
     ( WA-WERKS >= 3600 AND WA-WERKS <= 3609 ) OR
     ( WA-WERKS >= 3781 AND WA-WERKS <= 3789 )     .
    IF WA-BZAREA IS INITIAL OR WA-BZAREA = '5000' OR
       WA-BZAREA =  '5100'  OR WA-BZAREA = '5200' OR
       WA-BZAREA = '5300'.
    ELSE.
      MESSAGE E000(ZLE1) WITH
      '기계사업부 이외의 사업장을 변경할 수 없습니다.'.
    ENDIF.
  ENDIF.

*{S SRM2209-05218 23.09.2022 10:36:30
  IF GV_LGORT_FLAG = 'X' AND WA-BZAREA IS NOT INITIAL..
    SELECT SINGLE  BZAREA_T
      INTO (WA-BZAREA_T)
      FROM ZLET0071
     WHERE BZAREA = WA-BZAREA.
    IF SY-SUBRC <> 0 .

      SELECT SINGLE  BZAREA_T
        INTO (WA-BZAREA_T)
        FROM ZLET0034
       WHERE BZAREA = WA-BZAREA
        AND    WERKS = WA-WERKS.
      IF SY-SUBRC <> 0 ..
        MESSAGE E000(ZLE1) WITH
       '사업장 정보가 맞지 않습니다.'.
      ENDIF.
    ENDIF.
  ENDIF.
*}E SRM2209-05218


ENDMODULE.                 " INPUT_WA_BZAREA  INPUT
*&---------------------------------------------------------------------*
*&      Module  INPUT_POSNR  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE INPUT_POSNR INPUT.
  DATA : LV_ERROR,
       : LT_MATNR_MI LIKE ZPPS800 OCCURS 0 WITH HEADER LINE.
  IF WA-VBELN IS INITIAL.
    MESSAGE W000(ZLE1) WITH '판매오더번호를 넣어주십시오.'.
  ELSEIF WA-POSNR IS INITIAL.
    MESSAGE W000(ZLE1) WITH '판매오더 품목번호를 넣어주십시오.'.
  ELSEIF WA-WERKS IS INITIAL.
    MESSAGE W000(ZLE1) WITH '플랜트를 넣어주십시오.'.
  ELSE.
    CALL FUNCTION 'Z_PP_MI_MATNR_ISSUE'
      EXPORTING
        LV_VBELN    = WA-VBELN
        LV_POSNR    = WA-POSNR
        LV_WERKS    = WA-WERKS
      IMPORTING
        EV_ERROR    = LV_ERROR
      TABLES
        GT_MATNR_MI = LT_MATNR_MI.
    IF LV_ERROR = 0.
      LOOP AT LT_MATNR_MI.
        GT_LIST-MAKTX    = LT_MATNR_MI-MAKTX.
        GT_LIST-LFIMG    = LT_MATNR_MI-ENMNG.
        GT_LIST-MTR_UNIT = LT_MATNR_MI-MEINS.
        APPEND GT_LIST.
      ENDLOOP.
    ELSE.
* 에러 '1' : 판매오더번호 미존재
*      '2' : 판매오더는 존재하다 전부 출고하여 통문 데이타 없음 Table
      IF LV_ERROR = '1'.
        MESSAGE I000(ZLE1) WITH '판매오더가 존재하지 않습니다.'.
        CLEAR : GT_LIST,GT_LIST[].
      ELSEIF LV_ERROR = '2'.
        MESSAGE I000(ZLE1) WITH '출고 완료 되었습니다.'.
        CLEAR : GT_LIST,GT_LIST[].
      ELSE.
        MESSAGE I000(ZLE1) WITH '기타오류가 발생하였습니다.'.
        CLEAR : GT_LIST,GT_LIST[].
      ENDIF.
    ENDIF.
  ENDIF.

ENDMODULE.                 " INPUT_POSNR  INPUT
*&---------------------------------------------------------------------*
*&      Module  INPUT_WA_BZAREA  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE INPUT_MATNR INPUT.

*{ 기능개선 276257 - 추가
  CLEAR : GT_LIST-MAKTX.

  IF GT_LIST-MATNR IS NOT INITIAL.
    SELECT SINGLE MAKTX
      INTO GT_LIST-MAKTX
      FROM MAKT
     WHERE MATNR = GT_LIST-MATNR
       AND SPRAS = SY-LANGU.

    IF SY-SUBRC <> 0.
      MESSAGE E004 WITH '자재코드' GT_LIST-MATNR
                        '이(가) 존재하지 않습니다.'.
    ENDIF.
  ENDIF.





*} 기능개선 276257 - 추가

*  data lv_matnr like mseg-matnr.
*
*  if wa-werks is initial.
*     MESSAGE s000 WITH '플랜트를 입력하세여.'.
*     clear gt_list-matnr.
*     exit.
*  endif.
*
*
*  check not wa-werks is initial.
*
*  clear: gt_mard.
*
*  call function 'CONVERSION_EXIT_ALPHA_INPUT'
*  exporting
*    input  = gt_list-matnr
*  importing
*    output = lv_matnr.
*
*  select single meins
*    into gt_list-mtr_unit
*    from mara
*   where matnr eq lv_matnr.
*
*  if sy-subrc ne 0.
*     MESSAGE s000 WITH '제품코드를 확인하세요.'.
*     clear gt_list-matnr.
*     exit.
*  endif.
*
**자재명
*  select single maktx
*    into gt_list-maktx
*    from makt
*   where matnr eq lv_matnr.
*
*
*  select *
*    into corresponding fields of table gt_mard
*    from mard
*   where matnr eq lv_matnr
*     and WERKS eq wa-werks.
*
*  if gt_mard[] is initial.
*     MESSAGE s000 WITH '해당제품 재고가 존재하지 않습니다.'.
*     clear gt_list-matnr.
*     exit.
*  endif.
*
*  loop at gt_mard.
*
*    move gt_mard-lgort to gt_list-lgort.
*    move gt_mard-labst to gt_list-labst.
*    append gt_list.
*
*  endloop.
*
*  read table gt_list index  tc01-current_line.


ENDMODULE.                 " INPUT_WA_BZAREA  INPUT
*&---------------------------------------------------------------------*
*&      Module  INPUT_WA_BZAREA  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE INPUT_LFIMG INPUT.


*{ 기능개선 307461 - S
  CHECK WA-IV_TYPE EQ 'E13'.
  IF GT_LIST-LABST = 0.
    GT_LIST-LFIMG = 0.
    MESSAGE E000 WITH
  '재고가 부족합니다. 다시 입력하세요'.
  ELSEIF GT_LIST-LFIMG > GT_LIST-LABST.
    GT_LIST-LFIMG = 0.
    MESSAGE E000 WITH
   '재고 보다 많을수 없습니다. 다시 입력하세요'.
  ENDIF.

*{ 기능개선 307461 - E

ENDMODULE.                 " INPUT_WA_BZAREA  INPUT
*&---------------------------------------------------------------------*
*&      Module  INPUT_BUKRS  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE INPUT_BUKRS INPUT.

*  PERFORM GET_BUKRS_DESC USING WA-BUKRS WA-BUTXT.
*
*  IF WA-BUTXT IS INITIAL.
*    MESSAGE E001 WITH '존재하지 않는 회사코드입니다'.
*  ENDIF.

ENDMODULE.                 " INPUT_BUKRS  INPUT
*&---------------------------------------------------------------------*
*&      Module  CHECK_BUKRS  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE CHECK_BUKRS INPUT.

  IF WA-BUKRS IS NOT INITIAL AND
     WA-WERKS IS NOT INITIAL.
    PERFORM CHECK_BUKRS_WERKS USING WA-BUKRS WA-WERKS.

*{S SRM2209-05218 23.09.2022 10:31:09
    IF  GV_LGORT_FLAG = 'X'.
      CLEAR : WA-BZAREA.
      CLEAR : WA-BZAREA_T.
    ELSE.
*}

      SELECT SINGLE BZAREA BZAREA_T
        INTO (WA-BZAREA, WA-BZAREA_T)
        FROM ZLET0034
       WHERE WERKS = WA-WERKS.
    ENDIF.

    IF WA-BZAREA IS INITIAL AND GV_LGORT_FLAG IS INITIAL..
      MESSAGE E004 WITH '플랜트' WA-WERKS
                        '에 해당하는 사업장을 찾지 못했습니다.'
                        '관리자에게 문의하십시오.'.
    ENDIF.
  ENDIF.

ENDMODULE.                 " CHECK_BUKRS  INPUT
*&---------------------------------------------------------------------*
*&      Module  F4_WA-BUKRS  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE F4_WA-BUKRS INPUT.

*  PERFORM F4HELP_BUKRS USING WA-BUKRS WA-BUTXT.

ENDMODULE.                 " F4_WA-BUKRS  INPUT
*&---------------------------------------------------------------------*
*&      Module  F4_WA-WERKS  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE F4_WA-WERKS INPUT.

  PERFORM F4HELP_WERKS USING WA-BUKRS WA-WERKS.

ENDMODULE.                 " F4_WA-WERKS  INPUT
*&---------------------------------------------------------------------*
*&      Module  GET_CURSOR  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE GET_CURSOR INPUT.

  CLEAR: G_CURSOR_FIELD, I_CURSOR_LINE.
  GET CURSOR FIELD G_CURSOR_FIELD LINE I_CURSOR_LINE.

ENDMODULE.                 " GET_CURSOR  INPUT
*&---------------------------------------------------------------------*
*&      Module  input_app_id1  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE INPUT_APP_ID1 INPUT.
*-{기능개선73039-추가
  DATA  : LV_BNAME LIKE USR02-BNAME.
  CLEAR : LV_BNAME.
*-}기능개선73039_2015.04.02

  IF WA_0110-APP_ID1 IS NOT INITIAL.
    SELECT SINGLE ENAME
      FROM ZZPA0001
      INTO WA_0110-APP_NM1
      WHERE PERNR =  WA_0110-APP_ID1
        AND BUKRS =  WA-BUKRS
        AND ENDDA >= SY-DATUM
        AND BEGDA <= SY-DATUM
        AND PERSG =  '1'.      "재직자 - 기능개선 239718 - 추가

    IF SY-SUBRC <> 0.
      MESSAGE E000 WITH '존재하지 않는 사원입니다'.
    ENDIF.

*-{기능개선73039-추가
    SELECT SINGLE BNAME
      FROM USR02
      INTO LV_BNAME
     WHERE BNAME = WA_0110-APP_ID1
       AND CLASS = 'PUSER'.

    IF SY-SUBRC <> 0.
      MESSAGE E000 WITH '개인ID를 소유한 사용자를 선택해주세요.'.
    ENDIF.
*-}기능개선73039_2015.04.02

*{ 기능개선 239718 - 추가
    SELECT SINGLE PERNR
      INTO WA_0110-APP_ID1
      FROM ZLET0083
     WHERE BUKRS  = WA-BUKRS
       AND BZAREA = WA-BZAREA
       AND PERNR  = WA_0110-APP_ID1
       AND LVORM  = ' '.

    IF SY-SUBRC <> 0.
      MESSAGE E000 WITH '합의자로 등록되지 않은 사용자입니다.'.
    ENDIF.
*} 기능개선 239718 - 추가

  ELSE.
    CLEAR: WA_0110-APP_ID1, WA_0110-APP_NM1.
  ENDIF.

ENDMODULE.                 " input_app_id1  INPUT
*&---------------------------------------------------------------------*
*&      Module  input_app_id2  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE INPUT_APP_ID2 INPUT.

  CLEAR : LV_BNAME.                    "기능개선73039-추가

  IF WA_0110-APP_ID2 IS NOT INITIAL.
    SELECT SINGLE ENAME
      FROM ZZPA0001
      INTO WA_0110-APP_NM2
      WHERE PERNR =  WA_0110-APP_ID2
        AND BUKRS =  WA-BUKRS
        AND ENDDA >= SY-DATUM
        AND BEGDA <= SY-DATUM
        AND PERSG =  '1'.      "재직자 - 기능개선 239718 - 추가

    IF SY-SUBRC <> 0.
      MESSAGE E000 WITH '존재하지 않는 사원입니다'.
    ENDIF.

*-{기능개선73039-추가
    SELECT SINGLE BNAME
      FROM USR02
      INTO LV_BNAME
     WHERE BNAME = WA_0110-APP_ID2
       AND CLASS = 'PUSER'.

    IF SY-SUBRC <> 0.
*-{U1 승인자 체크로직 추가(통문결재 등록자도 가능)
      SELECT SINGLE UNAME FROM ZLET0014
        INTO LV_BNAME
       WHERE UNAME = WA_0110-APP_ID2.
      IF SY-SUBRC NE 0.
        MESSAGE E000 WITH
                '개인ID 혹은 결재자로 등록된 사용자를 선택해주세요.'.
      ENDIF.
*-}U1
    ENDIF.
*-}기능개선73039_2015.04.02

  ELSE.
    CLEAR: WA_0110-APP_ID2, WA_0110-APP_NM2.
  ENDIF.

ENDMODULE.                 " input_app_id2  INPUT
*&---------------------------------------------------------------------*
*&      Module  user_command_0110  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_0110 INPUT.

  CASE SY-UCOMM.
    WHEN 'SAVE'.
      IF GV_APNUM = '2' AND WA_0110-APP_ID1 IS INITIAL.
        MESSAGE S000 DISPLAY LIKE 'E' WITH '합의자를 입력하십시오'.
        LEAVE SCREEN.
      ENDIF.
      IF WA_0110-APP_ID2 IS INITIAL.
        MESSAGE S000 DISPLAY LIKE 'E' WITH '승인자를 입력하십시오'.
        LEAVE SCREEN.
      ENDIF.
      IF GV_APNUM = '2'.
        CONCATENATE '합의자:' WA_0110-APP_NM1  INTO WA-APPLINE.
        CONCATENATE WA-APPLINE '/' '승인자:'   INTO WA-APPLINE
                                               SEPARATED BY SPACE.
        CONCATENATE WA-APPLINE WA_0110-APP_NM2 INTO WA-APPLINE.
      ELSE.
        CONCATENATE '승인자:' WA_0110-APP_NM2  INTO WA-APPLINE.
      ENDIF.
      LEAVE TO SCREEN 0.
    WHEN 'EXIT'.
      CLEAR WA_0110.
      CLEAR WA-APPLINE.
      LEAVE TO SCREEN 0.
  ENDCASE.

ENDMODULE.                 " user_command_0110  INPUT
*&---------------------------------------------------------------------*
*&      Module  f4_app_id1  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE F4_APP_ID1 INPUT.

  PERFORM GET_F4_PERNR(SAPMZLE0001) USING '1'     "합의
                                          WA-BUKRS
                                          WA-WERKS
                                          WA-IV_TYPE
                                          WA_0110-APP_ID1.

ENDMODULE.                 " f4_app_id1  INPUT
*&---------------------------------------------------------------------*
*&      Module  f4_app_id2  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE F4_APP_ID2 INPUT.

  PERFORM GET_F4_PERNR(SAPMZLE0001) USING '2'     "승인
                                          WA-BUKRS
                                          WA-WERKS
                                          WA-IV_TYPE
                                          WA_0110-APP_ID2.

ENDMODULE.                 " f4_app_id2  INPUT
*&---------------------------------------------------------------------*
*&      Module  INPUT_WA_CHANGE  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE INPUT_WA_CHANGE INPUT.


*   IF WA-KUNNR1 IS NOT INITIAL.
*     WA-CHANGE = ''.
*      MESSAGE e000 WITH
*       '납품처 데이터를 지워주세요.'.
*   ENDIF.


ENDMODULE.                 " INPUT_WA_CHANGE  INPUT
*&---------------------------------------------------------------------*
*&      Module  CHECK_REQNO  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE CHECK_REQNO INPUT.

  PERFORM GET_TRANSPORTATION_REQ_DATA.

ENDMODULE.                 " CHECK_REQNO  INPUT
*&---------------------------------------------------------------------*
*&      Module  F4HELP_REQNO  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE F4HELP_REQNO INPUT.

  PERFORM F4HELP_REQNO.

ENDMODULE.                 " F4HELP_REQNO  INPUT
*&---------------------------------------------------------------------*
*&      Module  LGORT  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE LGORT INPUT.

  DATA : LT_LIST LIKE GT_LIST OCCURS 0  WITH HEADER LINE .

  CHECK WA-IV_TYPE EQ 'E13'.

  CLEAR : LT_LIST, LT_LIST[].
  LT_LIST[] = GT_LIST[].


  IF GT_LIST-LGORT = '1180'.
    MESSAGE E000 WITH
  '1180창고는 지정이 불가능 합니다.'.
  ENDIF.

  DATA: LV_MENGE1 LIKE  GT_LIST-MENGE_RE,
        LV_MENGE2 LIKE GT_LIST-MENGE_RE.
* 창고재고
  SELECT SINGLE LABST
    INTO GT_LIST-MENGE_ST
    FROM MARD
   WHERE MATNR EQ GT_LIST-MATNR
     AND WERKS EQ WA-WERKS
    AND  LGORT EQ GT_LIST-LGORT.

  IF SY-SUBRC <> 0 .
    GT_LIST-MENGE_ST = 0.
  ENDIF.
*예약재고
  CLEAR : LV_MENGE1,  LV_MENGE2.
  SELECT SINGLE SUM( BDMNG ) SUM( ENMNG )
    INTO (LV_MENGE1 , LV_MENGE2)
    FROM RESB
   WHERE MATNR EQ GT_LIST-MATNR
    AND WERKS EQ WA-WERKS
    AND  LGORT EQ GT_LIST-LGORT
    AND KZEAR NE 'X'
    AND XLOEK NE 'X'
    AND ( BDART = 'AR' OR  BDART = 'MR' ) .
*    and Xwaok = 'X'.

  GT_LIST-MENGE_RE = LV_MENGE1 -   LV_MENGE2.
** 기등록된 재고 .
*  loop at lt_list where  LGORT EQ GT_LIST-LGORT
*                    and  matnr eq gt_list-matnr .
*    GT_LIST-MENGE_RE = GT_LIST-MENGE_RE + lt_list-lfimg.
*    endloop.
* 가용 재고


*  GT_LIST-LABST = GT_LIST-MENGE_ST - GT_LIST-MENGE_RE.
  GT_LIST-LABST = GT_LIST-MENGE_ST.


  CHECK WA-IV_TYPE EQ 'E13'.
  IF GT_LIST-LABST = 0.
    GT_LIST-LFIMG = 0.
    MESSAGE E000 WITH
  '재고가 부족합니다. 다시 입력하세요'.
  ELSEIF GT_LIST-LFIMG > GT_LIST-LABST.
    GT_LIST-LFIMG = 0.
    MESSAGE E000 WITH
   '재고 보다 많을수 없습니다. 다시 입력하세요'.
  ENDIF.


ENDMODULE.                 " LGORT  INPUT
*&---------------------------------------------------------------------*
*&      Module  SCREEN_MODIFY_0100  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE SCREEN_MODIFY_0100 OUTPUT.


**{S SRM2209-05218 23.09.2022 10:19:10
  LOOP AT SCREEN.
    IF GV_BUKRS = '3000' AND SCREEN-GROUP1 = 'S1'.
      IF GV_LGORT_FLAG = 'X'.
        SCREEN-INPUT = '1'.
      ELSE.
        SCREEN-INPUT = '0'.
      ENDIF.
      MODIFY SCREEN.
    ENDIF.
  ENDLOOP.
*}E



ENDMODULE.                 " SCREEN_MODIFY_0100  OUTPUT
