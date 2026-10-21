*&---------------------------------------------------------------------*
*&  Include           MZLE0002I02                                      *
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  INPUT_WA_IV_TYPE  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE INPUT_WA_IV_TYPE INPUT.

*  IF NOT wa-iv_type IS INITIAL.
*    SELECT SINGLE iv_type_nm INTO wa-iv_type_nm
*      FROM zlet0007
*     WHERE gubun = 'MA'
*       AND iv_type LIKE 'C__'
*       AND iv_type = wa-iv_type.
*    IF sy-subrc <> 0.
*      MESSAGE e000(ZLE1) WITH
*       '존재하지 않는 통문유형입니다'.
*    ENDIF.
*  ELSE.
*    CLEAR: wa-iv_type_nm.
*  ENDIF.
ENDMODULE.                 " INPUT_WA_IV_TYPE  INPUT
*&---------------------------------------------------------------------*
*&      Module  INPUT_WA_KUNNER  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE INPUT_WA_KUNNR INPUT.

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

*
*  IF NOT wa-kunnr IS INITIAL.
*    SELECT SINGLE name1 ort01 stras
*      INTO (wa-kunnr_t, wa-ort01, wa-stras)
*      FROM lfa1
*     WHERE LIFNR = wa-kunnr.
*    IF sy-subrc <> 0.
**      MESSAGE e000(ZLE1) WITH
**       '존재하지 않는 거래처입니다'.
*    ELSE.
**      CONCATENATE wa-ort01 wa-stras INTO wa-addrs.
*    ENDIF.
*  ELSE.
**    CLEAR: wa-kunnr_t, wa-ort01, wa-stras, wa-addrs .
*  ENDIF.

ENDMODULE.                 " INPUT_WA_KUNNER  INPUT
*&---------------------------------------------------------------------*
*&      Module  INPUT_WA_PERNR  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE INPUT_WA_PERNR INPUT.

  IF NOT WA-PERNR IS INITIAL.
    SELECT SINGLE ENAME ORGEH
      INTO (WA-ENAME, WA-ORGEH)
      FROM ZZPA0001
     WHERE BEGDA <= SY-DATUM
       AND ENDDA >= SY-DATUM
       AND PERNR =  WA-PERNR
       AND PERSG =  '1'.      "재직자 - 기능개선 239718 - 추가.

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

ENDMODULE.                 " INPUT_WA_PERNR  INPUT
*&---------------------------------------------------------------------*
*&      Module  INPUT_PAI  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE INPUT_PAI INPUT.

  DATA : LV_DEAKT LIKE ANLA-DEAKT.
  CLEAR : LV_DEAKT.

*{ SRM2203-07882 - s
  IF WA-BUKRS = '3000' AND GT_OUT-ASSET_NO IS NOT INITIAL.

    SELECT SINGLE ANLN1 DEAKT
      INTO (GT_OUT-ASSET_NO, LV_DEAKT)
      FROM ANLA
     WHERE ANLN1 EQ GT_OUT-ASSET_NO
       AND BUKRS EQ WA-BUKRS
       AND XLOEV NE 'X'.

    IF SY-SUBRC <> 0.
      MESSAGE E000(ZLE1)
      WITH '회사코드3000에 존재하지 않는 자산코드입니다'.
*-[SRM2209-06389_S
    ELSE.
      IF LV_DEAKT IS NOT INITIAL.
        IF LV_DEAKT < WA-CREATE_DATE.
          MESSAGE E002(ZLE1)
          WITH '자산 '
                GT_OUT-ASSET_NO
               '는 비활성 상태로 통문증 발행이 불가합니다.'.
        ENDIF.
      ENDIF.
*]-SRM2209-06389_E
    ENDIF.

  ENDIF.
*} SRM2203-07882 - e

  MODIFY GT_OUT INDEX  TC01-CURRENT_LINE.
  IF SY-SUBRC <> 0.
*    IF GV_BUKRS = '3000'  AND GV_IV_TYPE = 'C05'.
*      IF GT_OUT-GDLGRP IS NOT INITIAL AND  GT_OUT-GDLGRP_TXT IS NOT INITIAL.
*        APPEND GT_OUT.
*      ENDIF.
*
*    ELSE.

    APPEND GT_OUT.
*    ENDIF.
  ENDIF.

ENDMODULE.                 " INPUT_PAI  INPUT
*&---------------------------------------------------------------------*
*&      Module  exit  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE EXIT INPUT.

  CLEAR TM_TRUNO.
  LEAVE TO SCREEN 0.

ENDMODULE.                 " exit  INPUT
*&---------------------------------------------------------------------*
*&      Module  f4_iv_type  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE F4_IV_TYPE INPUT.

*  PERFORM get_f4_iv_type_FI USING WA-IV_TYPE.

ENDMODULE.                 " f4_iv_type  INPUT
*&---------------------------------------------------------------------*
*&      Module  f4_pernr  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE F4_PERNR INPUT.

  PERFORM GET_F4_PERNR(SAPMZLE0001) USING ' '
                                          WA-BUKRS
                                          WA-WERKS
                                          WA-IV_TYPE
                                          WA-PERNR.

ENDMODULE.                 " f4_pernr  INPUT
*&---------------------------------------------------------------------*
*&      Form  get_f4_iv_type_FI
*&---------------------------------------------------------------------*
FORM GET_F4_IV_TYPE_FI  USING P_TYPE.

  DATA: BEGIN OF POV_TYPE OCCURS 0,
         IV_TYPE      LIKE ZLET0007-IV_TYPE,
         IV_TYPE_NM   LIKE ZLET0007-IV_TYPE_NM,
        END OF POV_TYPE.

  CLEAR: POV_TYPE[], POV_TYPE.

  SELECT * INTO CORRESPONDING FIELDS OF TABLE POV_TYPE
    FROM ZLET0007
   WHERE GUBUN = 'MA'
     AND IV_TYPE LIKE 'C__'.

  FIELDTAB-TABNAME   = 'ZLET0007'.
  FIELDTAB-FIELDNAME = 'IV_TYPE'.
  FIELDTAB-SELECTFLAG = 'X'.
  APPEND FIELDTAB.

  FIELDTAB-TABNAME   = 'ZLET0007'.
  FIELDTAB-FIELDNAME = 'IV_TYPE_NM'.
  FIELDTAB-SELECTFLAG = ' '.
  APPEND FIELDTAB.

  LOOP AT POV_TYPE.
    VALUETAB-VALUE = POV_TYPE-IV_TYPE.
    APPEND VALUETAB.
    VALUETAB-VALUE = POV_TYPE-IV_TYPE_NM.
    APPEND VALUETAB.
  ENDLOOP.

  CALL FUNCTION 'HELP_VALUES_GET_WITH_TABLE_EXT'
       EXPORTING
            DISPLAY       = ' '
*            fieldname     = 'NAME1'
       IMPORTING
            INDEX         = J
     TABLES
            FIELDS        = FIELDTAB
            SELECT_VALUES = I_HELP_VTAB
            VALUETAB      = VALUETAB.

  IF J > 0.
    READ TABLE POV_TYPE INDEX J.
    P_TYPE = POV_TYPE-IV_TYPE.
  ENDIF.
  REFRESH : FIELDTAB, VALUETAB, POV_TYPE.
  CLEAR   : J,FIELDTAB, VALUETAB, POV_TYPE.
ENDFORM.                    " get_f4_iv_type_FI
*&---------------------------------------------------------------------*
*&      Module  TC01_MODIFY  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE TC01_MODIFY INPUT.

*  CLEAR ZLET0017.
*  IF TM_TRUNO = WA-TRUCK_NO.
*       SELECT SINGLE * FROM ZLET0017 WHERE TRNUM EQ WA-TRUCK_NO.
*       CHECK SY-SUBRC = 0.
*       IF WA-DRIVER_NM = ' '.
*         WA-DRIVER_NM = ZLET0017-DRNAM.
*       ENDIF.
*       IF WA-DRPHO = ' '.
*         WA-DRPHO = ZLET0017-DRPHO.
*       ENDIF.
*  ELSE.
*    IF WA-TRUCK_NO <> ' '.
*       TM_TRUNO = WA-TRUCK_NO.
*       SELECT SINGLE * FROM ZLET0017 WHERE TRNUM EQ WA-TRUCK_NO.
*       IF SY-SUBRC = 0.
*         WA-DRIVER_NM = ZLET0017-DRNAM.
*         WA-DRPHO     = ZLET0017-DRPHO.
*       ELSE.
**         CLEAR: WA-DRIVER_NM.
*       ENDIF.
*    ELSE.
**      CLEAR: WA-DRIVER_NM
*    ENDIF.
*  ENDIF.

ENDMODULE.                 " TC01_MODIFY  INPUT
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_0100 INPUT.

  CASE SY-UCOMM.
    WHEN 'REFR'.
*     재설정 Refresh
      REFRESH: GT_OUT.
      CLEAR: GT_OUT, WA.
      WA-IV_TYPE    = GV_IV_TYPE.
      WA-IV_TYPE_NM = GV_IV_TYPE_NM.
      WA-BUKRS      = GV_BUKRS.
    WHEN 'APPL'.
      CALL SCREEN 0110 STARTING AT 23 2 ENDING AT 47 4.
    WHEN 'SAVE'.
*     FI 기타통문 저장
      PERFORM DATA_SAVE.
    WHEN ' '.
*     Field Discription
      PERFORM DATA_MODIFY.
    WHEN 'DELE'.
*     Line Delete
      DELETE GT_OUT WHERE CHK = 'X'.
*/ EDIT FROM BY G.T.JUNG AT 2016.11.16
    WHEN 'FILE'.
      PERFORM FILE_UPLOAD.

*/ EDIT END
  ENDCASE.

ENDMODULE.                 " USER_COMMAND_0100  INPUT
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
*&      Module  F4_TRUCK_NO  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE F4_TRUCK_NO INPUT.

*  PERFORM F4_TRNUM(ZLER0020) USING WA-TRUCK_NO.

ENDMODULE.                 " F4_TRUCK_NO  INPUT
*&---------------------------------------------------------------------*
*&      Module  input_werks  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE INPUT_WERKS INPUT.

*  if not wa-werks is initial.
*    select single name1 into wa-werks_t
*      from t001w
*     where werks = wa-werks.
*    if sy-subrc <> 0.
*      message e000 with
*       '존재하지 않는 플랜트입니다'.
*    endif.
*  else.
*    clear: wa-werks_t.
*  endif.

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

ENDMODULE.                 " input_werks  INPUT
*&---------------------------------------------------------------------*
*&      Module  check_kunnr  INPUT
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

ENDMODULE.                 " check_kunnr  INPUT
*&---------------------------------------------------------------------*
*&      Module  input_wa_kunnr1  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE INPUT_WA_KUNNR1 INPUT.

  IF NOT WA-KUNNR1 IS INITIAL.
    SELECT SINGLE NAME1 ORT01 STRAS
      INTO (WA-KUNNR1_T, WA-ORT01, WA-STRAS)
      FROM KNA1
     WHERE KUNNR = WA-KUNNR1.
    IF SY-SUBRC <> 0.
*      GV_ADDRS = 'X'.
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

ENDMODULE.                 " input_wa_kunnr1  INPUT
*&---------------------------------------------------------------------*
*&      Module  F4_BZAREA  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE F4_BZAREA INPUT.

  PERFORM GET_F4_BZAREA USING WA-BZAREA.

ENDMODULE.                 " F4_BZAREA  INPUT
*&---------------------------------------------------------------------*
*&      Module  INPUT_WA_BZAREA  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE INPUT_WA_BZAREA INPUT.

  DATA : LV_BZAREA LIKE ZLET0034-BZAREA.

  IF ( WA-WERKS >= 1600 AND WA-WERKS <= 1609 ) OR
     ( WA-WERKS >= 1781 AND WA-WERKS <= 1789 ).
    IF WA-BZAREA IS INITIAL OR
       WA-BZAREA = '5000'   OR WA-BZAREA = '5100'.
    ELSE.
      MESSAGE E000(ZLE1) WITH
      '기계사업부 이외의 사업장을 변경할 수 없습니다.'.
    ENDIF.
  ENDIF.

*  IF ( WA-WERKS >= 1600 AND WA-WERKS <= 1609 ) OR
*     ( WA-WERKS >= 1781 AND WA-WERKS <= 1789 ).
*     IF WA-BZAREA IS INITIAL OR
*        WA-BZAREA = '5000'   OR WA-BZAREA = '5100'.
*     ELSE.
*       MESSAGE e000(ZLE1) WITH
*       '기계사업부 이외의 사업장을 변경할 수 없습니다.'.
*     ENDIF.
*  ELSE.

*     SELECT SINGLE BZAREA INTO LV_BZAREA
*     FROM   ZLET0034
*     WHERE  WERKS = WA-WERKS.
*
*     IF SY-SUBRC = 0.
*       IF WA-BZAREA IS NOT INITIAL AND WA-BZAREA <> LV_BZAREA.
*          CLEAR : LV_BZAREA,WA-BZAREA.
*          MESSAGE e000(ZLE1) WITH
*         '기계사업부만 사업장을 변경할 수 있습니다.'.
*       ENDIF.
*     ELSE.
*        MESSAGE e000(ZLE1) WITH
*       '사업장 정보가 맞지 않습니다.'.
*     ENDIF.

*  ENDIF.
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
*&      Module  INPUT_BUKRS  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE CHECK_BUKRS INPUT.




  IF WA-BUKRS IS NOT INITIAL AND
     WA-WERKS IS NOT INITIAL.
    PERFORM CHECK_BUKRS_WERKS USING WA-BUKRS WA-WERKS.

    IF ( WA-WERKS >= 1600 AND WA-WERKS <= 1609 ) OR
       ( WA-WERKS >= 1781 AND WA-WERKS <= 1789 ) OR
       ( WA-WERKS >= 3600 AND WA-WERKS <= 3609 ) OR
       ( WA-WERKS >= 3781 AND WA-WERKS <= 3789 ) .

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

*___ 기능개선 295184
      IF WA-WERKS = '3606' .
        WA-BZAREA = '5200'.
      ENDIF.
*___ 기능개선 295184

      IF WA-BZAREA IS INITIAL.
        WA-BZAREA = '5000'.
      ENDIF.
*{S SRM2209-05218 23.09.2022 10:31:09
      IF  GV_LGORT_FLAG = 'X'.
        CLEAR : WA-BZAREA.
        CLEAR : WA-BZAREA_T.
*        SELECT SINGLE BZAREA_T
*        INTO (WA-BZAREA_T)
*        FROM ZLET0071
*         WHERE WERKS = WA-WERKS.
      ELSE.

        SELECT SINGLE BZAREA BZAREA_T
          INTO (WA-BZAREA, WA-BZAREA_T)
          FROM ZLET0034
         WHERE WERKS = WA-WERKS.
      ENDIF.
*        SELECT SINGLE BZAREA BZAREA_T
*          INTO (WA-BZAREA, WA-BZAREA_T)
*          FROM ZLET0033
*         WHERE BZAREA = WA-BZAREA.
*}E SRM2209-05218

    ELSE. "전선 EVK
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

ENDMODULE.                 " INPUT_BUKRS  INPUT
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
       AND ENDDA >= SY-DATUM
       AND BEGDA <= SY-DATUM
       AND PERSG =  '1'.      "재직자 - 기능개선 239718 - 추가

    IF SY-SUBRC <> 0.
      MESSAGE E000 WITH '존재하지 않는 사번입니다'.
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
        AND ENDDA >= SY-DATUM
        AND BEGDA <= SY-DATUM
        AND PERSG =  '1'.      "재직자 - 기능개선 239718 - 추가

    IF SY-SUBRC <> 0.
      MESSAGE E000 WITH '존재하지 않는 사번입니다'.
    ENDIF.

*-{기능개선73039-추가
    SELECT SINGLE BNAME
      FROM USR02
      INTO LV_BNAME
     WHERE BNAME = WA_0110-APP_ID2
       AND CLASS = 'PUSER'.

    IF SY-SUBRC <> 0.
*-{U1 승인자 체크로직 추가(통문결재 등록자도 가능)
      SELECT SINGLE UNAME
        FROM ZLET0014
        INTO LV_BNAME
       WHERE UNAME = WA_0110-APP_ID2.
      IF SY-SUBRC NE 0.
        MESSAGE E000 WITH
        '개인ID 혹은 통문결재자로 등록된 사용자를 선택하세요'.
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
      IF WA_0110-APP_ID1 IS INITIAL.
        MESSAGE S000 DISPLAY LIKE 'E' WITH '합의자를 입력하십시오'.
        LEAVE SCREEN.
      ENDIF.
      IF WA_0110-APP_ID2 IS INITIAL.
        MESSAGE S000 DISPLAY LIKE 'E' WITH '승인자를 입력하십시오'.
        LEAVE SCREEN.
      ENDIF.
      CONCATENATE '합의자:' WA_0110-APP_NM1  INTO WA-APPLINE.
      CONCATENATE WA-APPLINE '/' '승인자:'   INTO WA-APPLINE
                                             SEPARATED BY SPACE.
      CONCATENATE WA-APPLINE WA_0110-APP_NM2 INTO WA-APPLINE.
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

*-{자체개선 51966 - 엠트론 주소창 활성화
*    WA-CHANGE = 'X'.
*    CLEAR: WA-KUNNR1_T. "wa-ort01, wa-stras, wa-addrs, gv_addrs.
  LOOP AT SCREEN.
    CASE SCREEN-NAME.
      WHEN 'WA-KUNNR1_T'.
        IF WA-CHANGE = 'X'.
          SCREEN-INPUT = 1.
          MODIFY SCREEN.
        ELSE.
          SCREEN-INPUT = 0.
          MODIFY SCREEN.
        ENDIF.
      WHEN 'WA-ADDRS'.
        IF WA-CHANGE = 'X'.
          SCREEN-INPUT = 1.
          MODIFY SCREEN.
        ELSE.
          SCREEN-INPUT = 0.
          MODIFY SCREEN.
        ENDIF.
    ENDCASE.
  ENDLOOP.


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
