*&---------------------------------------------------------------------*
*&  Include           ZSDR1001B                                        *
*&---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Form  BDC_DYNPRO
*&---------------------------------------------------------------------*
*        Start new screen                                              *
*----------------------------------------------------------------------*
*      -->I_PROGRAM  프로그램.
*      -->I_DYNPRO   화면번호.
*----------------------------------------------------------------------*
FORM BDC_DYNPRO USING I_PROGRAM TYPE BDCDATA-PROGRAM
                      I_DYNPRO  TYPE BDCDATA-DYNPRO.
  DATA LS_BDCDATA LIKE BDCDATA.
  CLEAR LS_BDCDATA.
  LS_BDCDATA-PROGRAM  = I_PROGRAM.
  LS_BDCDATA-DYNPRO   = I_DYNPRO.
  LS_BDCDATA-DYNBEGIN = 'X'.
  APPEND LS_BDCDATA TO GT_BDCDATA.
ENDFORM.                    "BDC_DYNPRO
*&---------------------------------------------------------------------*
*&      Form  BDC_FIELD
*&---------------------------------------------------------------------*
*        Insert field                                                  *
*----------------------------------------------------------------------*
*      -->I_FNAM  필드이름.
*      -->I_FVAL  필드값.
*----------------------------------------------------------------------*
FORM BDC_FIELD USING I_FNAM
                     I_FVAL.
  DATA: LS_BDCDATA LIKE BDCDATA,
        LC_NODATA.

*-> CCM : 17.10.2023 15:46:57 / ZLSGSD3
  IF I_FNAM = 'DKACB-FMORE'.
    LS_BDCDATA-FNAM = I_FNAM.
    LS_BDCDATA-FVAL = I_FVAL.
    CLEAR LS_BDCDATA-FVAL.
    APPEND LS_BDCDATA TO GT_BDCDATA.

  ELSEIF I_FVAL <> LC_NODATA OR I_FNAM = 'RF05A-XNOPS'.
    CLEAR LS_BDCDATA.
    LS_BDCDATA-FNAM = I_FNAM.
    LS_BDCDATA-FVAL = I_FVAL.
    APPEND LS_BDCDATA TO GT_BDCDATA.
  ENDIF.

** 기존 로직 주석 처리
*  IF i_fval <> lc_nodata OR i_fnam = 'RF05A-XNOPS'.
*    CLEAR ls_bdcdata.
*    ls_bdcdata-fnam = i_fnam.
*    ls_bdcdata-fval = i_fval.
*    APPEND ls_bdcdata TO gt_bdcdata.
*  ENDIF.
*<-

ENDFORM.                    "BDC_FIELD

*&---------------------------------------------------------------------*
*&      Form  execute_bdc_data
*&---------------------------------------------------------------------*
*  지급전표생성
*----------------------------------------------------------------------*
FORM EXECUTE_BDC_DATA .

  CLEAR  GT_BDCMSG.
  REFRESH  GT_BDCMSG.

  CLEAR : G_TMP2_T, G_TMP2_T[].

  DATA : LV_CNT   TYPE I,
         LV_FLAG,
         LV_FLAG2,
         LV_KUNNR LIKE KNA1-KUNNR,
         LV_LIFNR LIKE KNA1-LIFNR.

  CLEAR : LV_CNT, LV_FLAG, LV_FLAG2.
  REFRESH  GT_BDCDATA.

  LOOP AT G_ITEM_T WHERE BOX = 'X'.

** 지급전표 생성 완료 된것
    IF  G_ITEM_T-LIGHTS EQ C_CLIGHT.
      LV_FLAG = 'X'.
*        exit.
    ENDIF.

** 부가세지급전표 생성 완료 된것
    IF  G_ITEM_T-LIGHTS EQ C_BLIGHT.
      LV_FLAG2 = 'X'.
*        exit.
    ENDIF.

    LV_CNT  =  LV_CNT  +  1.

  ENDLOOP.

  IF  LV_CNT  >  1  OR
      LV_CNT  =  0.
    MESSAGE E001(ZSD1) WITH '지급요청은 한건씩 처리됩니다.'.
  ENDIF.

  IF  LV_FLAG  =  'X'.
    MESSAGE E001(ZSD1) WITH '지급요청이 이미 처리되었습니다.'.
  ENDIF.

  IF  LV_FLAG2  =  'X'.
    MESSAGE E001(ZSD1) WITH '이미 부가세지급전표가 생성된 건입니다.'.
  ENDIF.

  READ TABLE G_ITEM_T WITH KEY BOX = 'X'.

  IF  G_ITEM_T-R_WRBTR  <=  0.
    MESSAGE E001(ZSD1) WITH '지급가능금액을 확인하세요.'.
  ENDIF.

  LOOP AT G_ITEM_T WHERE BOX = 'X'.

    CLEAR : LV_KUNNR, LV_LIFNR.

    SELECT  SINGLE KUNNR
      INTO  LV_KUNNR
      FROM  VBAK
     WHERE  VBELN  =  G_ITEM_T-VBELN.

    IF  SY-SUBRC  EQ  0.
      SELECT  SINGLE LIFNR
        INTO  LV_LIFNR
        FROM  KNA1
       WHERE  KUNNR = LV_KUNNR.
    ENDIF.

    SELECT  BELNR2
      INTO  CORRESPONDING FIELDS OF TABLE G_TMP2_T
      FROM  ZSD0017T
     WHERE  KNUMA  =  G_ITEM_T-KNUMA
       AND  FBUDA  =  G_ITEM_T-FBUDA
       AND  VBELN  =  G_ITEM_T-VBELN
       AND  BELNR  =  G_ITEM_T-BELNR.
*       and  vbeln2 =  g_item_t-vbeln2.

** c_hkont 계정 결정 수정 written by choi seok won
    PERFORM CHANGE_HKONT.

    PERFORM CHECK_BDC_DATA USING LV_LIFNR.

  ENDLOOP.

  PERFORM CALL_MESSAGE_SCREEN.

ENDFORM.                    " execute_bdc_data

*&---------------------------------------------------------------------*
*&      Form  execute_bdc_data2
*&---------------------------------------------------------------------*
*  부가세지급전표생성
*----------------------------------------------------------------------*
FORM EXECUTE_BDC_DATA2 .

  CLEAR  GT_BDCMSG.
  REFRESH  GT_BDCMSG.

  CLEAR : G_TMP2_T, G_TMP2_T[].

  DATA : LV_CNT   TYPE I,
         LV_FLAG,
         LV_FLAG2,
         LV_FLAG3,
         LV_KUNNR LIKE KNA1-KUNNR,
         LV_LIFNR LIKE KNA1-LIFNR.

  CLEAR : LV_CNT, LV_FLAG, LV_FLAG2, LV_FLAG3.
  REFRESH  GT_BDCDATA.

  LOOP AT G_ITEM_T WHERE BOX = 'X'.

** 부가세지급전표 생성 완료여부 Check
    IF  G_ITEM_T-LIGHTS EQ C_BLIGHT.
      LV_FLAG = 'X'.
*        exit.
    ENDIF.

** 지급전표 생성 완료여부 Check
    IF  G_ITEM_T-LIGHTS EQ C_FLIGHT.
      LV_FLAG2 = 'X'.
*        exit.
    ENDIF.

** 대상 Agent Check.
    IF  G_ITEM_T-BONEM+0(2)  =  '38'  OR
        G_ITEM_T-BONEM+0(6)  =  '000038'.
      LV_FLAG3  =  'X'.
*        exit.
    ENDIF.

    LV_CNT  =  LV_CNT  +  1.

  ENDLOOP.

  IF  LV_CNT  >  1  OR
      LV_CNT  =  0.
    MESSAGE E001(ZSD1) WITH '지급요청은 한건씩 처리됩니다.'.
  ENDIF.

  IF  LV_FLAG  =  'X'.
    MESSAGE E001(ZSD1) WITH '부가세지급요청이 이미 처리되었습니다.'.
  ENDIF.

  IF  LV_FLAG2  =  'X'.
    MESSAGE E001(ZSD1) WITH '먼저 지급전표를 생성하세요.'.
  ENDIF.

  IF  LV_FLAG3  =  'X'.
*      clear g_item_t-box.
*      modify g_item_t transporting box where box = 'X'.
    MESSAGE E001(ZSD1) WITH '내수 Agent만 가능합니다.'.
  ENDIF.

  READ TABLE G_ITEM_T WITH KEY BOX = 'X'.

  IF  G_ITEM_T-R_BUGA  <=  0.
    MESSAGE E001(ZSD1) WITH '지급가능금액(Tax)을 확인하세요.'.
  ENDIF.

  LOOP AT G_ITEM_T WHERE BOX = 'X'.

    CLEAR : LV_KUNNR, LV_LIFNR.

    SELECT  SINGLE KUNNR
      INTO  LV_KUNNR
      FROM  VBAK
     WHERE  VBELN  =  G_ITEM_T-VBELN.

    IF  SY-SUBRC  EQ  0.
      SELECT  SINGLE LIFNR
        INTO  LV_LIFNR
        FROM  KNA1
       WHERE  KUNNR = LV_KUNNR.
    ENDIF.

** 부가세의 미지급/지급금액은 정산월 별 Agent별로 합산해서 미지급전표를
** 생성하기때문에 정산월/미지급전표번호를 가지고 구한다 : 2005-10-21
    SELECT  BUGA_BELNR AS BELNR2
      INTO  CORRESPONDING FIELDS OF TABLE G_TMP2_T
      FROM  ZSD0017T
     WHERE  FBUDA       =  G_ITEM_T-FBUDA
       AND  BUGA_BELNR2 =  G_ITEM_T-BUGA_BELNR
       AND  BUGA_BELNR  NE  ' '.


** c_hkont 계정 결정 수정 written by choi seok won
    PERFORM CHANGE_HKONT.

    PERFORM CHECK_BDC_DATA2 USING LV_LIFNR.

  ENDLOOP.

  PERFORM CALL_MESSAGE_SCREEN.

ENDFORM.                    " execute_bdc_data2

*&---------------------------------------------------------------------*
*&      Form  check_bdc_data
*&---------------------------------------------------------------------*
FORM CHECK_BDC_DATA  USING    P_LIFNR.

  DATA : L_WRBTR     LIKE BSID-WRBTR,
         L_WRBTR2    LIKE BSID-WRBTR,
         L_SUM_WRBTR LIKE BSID-WRBTR.
  DATA : G_RETURN_CODE TYPE C.
  CLEAR : L_WRBTR, L_WRBTR2, L_SUM_WRBTR, G_RETURN_CODE.

** 지급요청의 마지막여부 Check.

** 해당 미지급전표의 미지급금액 Sum.
  SELECT  SUM( WRBTR )
    INTO  L_WRBTR
    FROM  ZSD0016T
   WHERE  KNUMA  =  G_ITEM_T-KNUMA
     AND  FBUDA  =  G_ITEM_T-FBUDA
     AND  VBELN  =  G_ITEM_T-VBELN
     AND  BELNR  =  G_ITEM_T-BELNR.

** 해당 미지급전표의 지급금액 Sum.
  SELECT  SUM( WRBTR )
    INTO  L_WRBTR2
    FROM  ZSD0017T
   WHERE  KNUMA  =  G_ITEM_T-KNUMA
     AND  FBUDA  =  G_ITEM_T-FBUDA
     AND  VBELN  =  G_ITEM_T-VBELN
     AND  BELNR  =  G_ITEM_T-BELNR.

  L_SUM_WRBTR  =  L_WRBTR  -  L_WRBTR2.

** Request by 송준호K : 2005-09-29
** 대체수취인(구매처)관련된 처리로직 추가.
  PERFORM  REPLACE_PROCESS_RTN.

  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
    EXPORTING
      INPUT  = G_H_EMPFK
    IMPORTING
      OUTPUT = G_H_EMPFK.


* 지급가능 금액
  G_P_NETWR1 = G_ITEM_T-R_WRBTR.
  G_P_CURR   = G_ITEM_T-WAERS.

  PERFORM  REPLACE_R_WRBTR_RTN CHANGING G_RETURN_CODE.


  CHECK G_RETURN_CODE = 'X'.

** 계산된 금액과 지급가능금액이 같으면 마지막임.
  IF  L_SUM_WRBTR  =  G_ITEM_T-R_WRBTR.

    PERFORM FILL_FIELD_DATA_LAST USING P_LIFNR.
    PERFORM CALL_TRANSACTION_F-51.

  ELSE.

    PERFORM FILL_FIELD_DATA USING P_LIFNR.
    PERFORM CALL_TRANSACTION_F-51.

  ENDIF.

ENDFORM.                    " check_bdc_data

*&---------------------------------------------------------------------*
*&      Form  check_bdc_data2
*&---------------------------------------------------------------------*
FORM CHECK_BDC_DATA2  USING    P_LIFNR.

  DATA : L_WRBTR     LIKE BSID-WRBTR,
         L_WRBTR2    LIKE BSID-WRBTR,
         L_SUM_WRBTR LIKE BSID-WRBTR.
  CLEAR : L_WRBTR, L_WRBTR2, L_SUM_WRBTR.

** 지급요청의 마지막여부 Check.
** 부가세의 미지급/지급금액은 정산월 별 Agent별로 합산해서 미지급전표를
** 생성하기때문에 정산월/미지급전표번호를 가지고 구한다 : 2005-10-21

** 해당 부가세미지급전표의 미지급금액(Tax) Sum.
  SELECT  SUM( BUGA_AMNT )
    INTO  L_WRBTR
    FROM  ZSD0016T
   WHERE  FBUDA  =  G_ITEM_T-FBUDA
     AND  BUGA_BELNR  =  G_ITEM_T-BUGA_BELNR.

*    where  knuma  =  g_item_t-knuma
*      and  fbuda  =  g_item_t-fbuda
*      and  vbeln  =  g_item_t-vbeln
*      and  belnr  =  g_item_t-belnr.
**      and  buga_belnr  =  g_item_t-buga_belnr.

** 해당 부가세미지급전표의 지급금액(Tax) Sum.
  SELECT  SUM( BUGA_AMNT )
    INTO  L_WRBTR2
    FROM  ZSD0017T
   WHERE  FBUDA  =  G_ITEM_T-FBUDA
     AND  BUGA_BELNR2  =  G_ITEM_T-BUGA_BELNR.

*    where  knuma  =  g_item_t-knuma
*      and  fbuda  =  g_item_t-fbuda
*      and  vbeln  =  g_item_t-vbeln
*      and  belnr  =  g_item_t-belnr.
**      and  buga_belnr  =  g_item_t-buga_belnr.

  L_SUM_WRBTR  =  L_WRBTR  -  L_WRBTR2.

** 계산된 금액과 지급가능금액(Tax)이 같으면 마지막임.
  IF  L_SUM_WRBTR  =  G_ITEM_T-R_BUGA.

    PERFORM FILL_FIELD_DATA_LAST2 USING P_LIFNR.
    PERFORM CALL_TRANSACTION_F-51.

  ELSE.

    PERFORM FILL_FIELD_DATA2 USING P_LIFNR.
    PERFORM CALL_TRANSACTION_F-51.

  ENDIF.

ENDFORM.                    " check_bdc_data2

*&---------------------------------------------------------------------*
*&      Form  fill_field_data_last
*&---------------------------------------------------------------------*
FORM FILL_FIELD_DATA_LAST  USING    P_LIFNR.

  DATA : LV_NETWR(15),
         LV_NETWR_ORGN(15),
         LV_NETWR_BUGA(15),
         LV_TEMP           LIKE ZSDS002-NETWR,
         LV_NETWR2(15),
         LV_NETWR2_I       LIKE ZSDS002-NETWR,
         LV_TEMP2(15).
  DATA : LV_LIFNR     LIKE LFA1-LIFNR,
         LV_GSBER     LIKE BSEG-GSBER,
         LV_XBLNR(21).
  DATA : L_CNT             TYPE I,
         L_CNT2(2)         TYPE N,
         L_CURSOR_NAME(20).
  DATA : L_BELNR2_GJAHR(4).
  DATA : L_SUM_DMBTR LIKE BSEG-DMBTR.
  DATA : L_BELNR2_DMBTR LIKE BSEG-DMBTR.
  DATA : L_ADJUST_DMBTRX(14) TYPE P DECIMALS 0.
  DATA : L_ADJUST_DMBTR LIKE BSEG-DMBTR.
  DATA : LS_ADJUST_DMBTR(14).
  DATA : G_ITEM_T-R_WRBTR_TEMP LIKE ZSD0017T-WRBTR.
  DATA : G_ITEM_T-R_BUGA LIKE ZSD0017T-WRBTR.
  DATA : LS_ADJUST_DMBTRX(14).
  DATA : L_ADJUST_DMBTRX_BUGA(14) TYPE P DECIMALS 0.
  DATA : LS_ADJUST_DMBTR_BUGA(14).

  DATA: LV_FFACT LIKE TCURF-FFACT,        "기능개선 287676 - 추가
        LV_TFACT LIKE TCURF-TFACT.        "기능개선 287676 - 추가

  CLEAR : G_ITEM_T-R_WRBTR_TEMP.
  CLEAR : LV_TEMP, LV_TEMP2, LV_NETWR2, LV_GSBER, GV_LIFNR.
  CLEAR : L_CNT, L_CNT2, L_CURSOR_NAME.
  CLEAR : L_BELNR2_GJAHR, L_SUM_DMBTR, L_BELNR2_DMBTR,L_ADJUST_DMBTR.

** 사업영역
*>> START - Archiving 관련변경 04 -> 20080311
*-- 아카이브 체크를 한 경우에만 AS 테이블에서 정보를 가지고 온다.
  IF NOT P_ARCV IS INITIAL.
    SELECT  SINGLE GSBER
      INTO  LV_GSBER
      FROM  ZARIXFI1
     WHERE  BUKRS  =  PA_VKORG
      AND   BELNR  =  G_ITEM_T-BELNR
      AND   GJAHR  =  G_ITEM_T-FBUDA+0(4).
    IF SY-SUBRC <> 0.
*-- 아카이브 데이터가 없으면 BSEG 에서 데이터를 취득한다.
      SELECT  SINGLE GSBER
        INTO  LV_GSBER
        FROM  BSEG
       WHERE  BUKRS  =  PA_VKORG
        AND   BELNR  =  G_ITEM_T-BELNR
        AND   GJAHR  =  G_ITEM_T-FBUDA+0(4).
    ENDIF.

  ELSE.
    SELECT  SINGLE GSBER
      INTO  LV_GSBER
      FROM  BSEG
     WHERE  BUKRS  =  PA_VKORG
      AND   BELNR  =  G_ITEM_T-BELNR
      AND   GJAHR  =  G_ITEM_T-FBUDA+0(4).
  ENDIF.

**  select  single gsber
**    into  lv_gsber
**    from  bseg
**   where  BUKRS  =  pa_vkorg
**    and   belnr  =  g_item_t-belnr
**    and   GJAHR  =  g_item_t-fbuda+0(4).
*>> END   - Archiving 관련변경 04 -> 20080311

  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
    EXPORTING
      INPUT  = P_LIFNR
    IMPORTING
      OUTPUT = P_LIFNR.

  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
    EXPORTING
      INPUT  = G_ITEM_T-KNUMA
    IMPORTING
      OUTPUT = G_ITEM_T-KNUMA.

  IF  GV_UCOMM  =  'REQU'.
** 지급가능금액
    WRITE : G_ITEM_T-R_WRBTR TO LV_NETWR CURRENCY G_ITEM_T-WAERS.

*  elseif gv_ucomm  =  'REQU3'.
*
*    g_item_t-r_wrbtr_temp = g_item_t-r_wrbtr + ( g_item_t-r_wrbtr / 10
*)
*.
*
*    write : g_item_t-r_wrbtr_temp  to lv_netwr currency g_item_t-waers.


  ELSEIF GV_UCOMM  =  'REQU3'.

    G_ITEM_T-R_WRBTR_TEMP = ( G_ITEM_T-R_WRBTR * 100 )
                             + TRUNC( G_ITEM_T-R_WRBTR * 10 )  .

    G_ITEM_T-R_WRBTR_TEMP  = G_ITEM_T-R_WRBTR_TEMP / 100.

    G_ITEM_T-R_BUGA = ( G_ITEM_T-R_WRBTR_TEMP - G_ITEM_T-R_WRBTR ).

    WRITE : G_ITEM_T-R_WRBTR_TEMP  TO LV_NETWR CURRENCY G_ITEM_T-WAERS.
    WRITE : G_ITEM_T-R_WRBTR  TO LV_NETWR_ORGN CURRENCY G_ITEM_T-WAERS.
    WRITE : G_ITEM_T-R_BUGA  TO LV_NETWR_BUGA  CURRENCY G_ITEM_T-WAERS.

  ELSE.
** 지급가능금액(Tax)는 Currency Field가 아니기때문에..
    WRITE : G_ITEM_T-R_BUGA TO LV_NETWR.
  ENDIF.

  CALL FUNCTION 'RP_LAST_DAY_OF_MONTHS'
    EXPORTING
      DAY_IN            = PA_REQDT
    IMPORTING
      LAST_DAY_OF_MONTH = GV_LDATE.

*  clear : l_bldat.

*  select single BLDAT
*    into l_bldat
*    from bkpf
*   where BUKRS = '1000'
*     and BELNR = g_item_t-BELNR
*     and GJAHR = lv_year.
*
*** [START] BEFORE MODIFIED FOR COMPANY CODE **********************
*  select single PSWSL DMBTR WRBTR
*    into (l_PSWSL, l_DMBTR, l_WRBTR)
*    from bseg
*   where BUKRS = '1000'
*     and BELNR = g_item_t-BELNR
*     and GJAHR = lv_year
*     and SHKZG = 'H'.
*** [END] BEFORE MODIFIED FOR COMPANY CODE **********************
*  IF PA_VKORG = '1000'.
*    c_bupla = '110'.
*  ELSE.
*    c_bupla = '220'.
*  ENDIF.
*** [START] AFTER MODIFIED FOR COMPANY CODE **********************
*>> START - Archiving 관련변경 05 -> 20080311
*-- 아카이브 체크를 한 경우에만 AS 테이블에서 정보를 가지고 온다.
  IF NOT P_ARCV IS INITIAL.
    SELECT SINGLE PSWSL DMBTR WRBTR
      INTO (L_PSWSL, L_DMBTR, L_WRBTR)
      FROM ZARIXFI1
     WHERE BUKRS = PA_VKORG
       AND BELNR = G_ITEM_T-BELNR
       AND GJAHR = G_ITEM_T-FBUDA(4)
       AND SHKZG = 'H'.
    IF SY-SUBRC <> 0.
*-- 아카이브 데이터가 없으면 BSEG 에서 데이터를 취득한다.
      SELECT SINGLE PSWSL DMBTR WRBTR
        INTO (L_PSWSL, L_DMBTR, L_WRBTR)
        FROM BSEG
       WHERE BUKRS = PA_VKORG
         AND BELNR = G_ITEM_T-BELNR
         AND GJAHR = G_ITEM_T-FBUDA(4)
         AND SHKZG = 'H'.
    ENDIF.

  ELSE.
    SELECT SINGLE PSWSL DMBTR WRBTR
      INTO (L_PSWSL, L_DMBTR, L_WRBTR)
      FROM BSEG
     WHERE BUKRS = PA_VKORG
       AND BELNR = G_ITEM_T-BELNR
       AND GJAHR = G_ITEM_T-FBUDA(4)
       AND SHKZG = 'H'.
  ENDIF.

**  select single PSWSL DMBTR WRBTR
**    into (l_PSWSL, l_DMBTR, l_WRBTR)
**    from bseg
**   where BUKRS = PA_VKORG
**     and BELNR = g_item_t-BELNR
**     and GJAHR = lv_year
**     and SHKZG = 'H'.
*>> END   - Archiving 관련변경 05 -> 20080311
*** [END] AFTER MODIFIED FOR COMPANY CODE **********************

  CLEAR : GV_POINT,
          L_KURSF,
          LS_KURSF.

  PERFORM DECIMAL_POINT_COMPUTE USING L_PSWSL.

*{ 기능개선 287676 - 변경_S
  PERFORM GET_EXCHANGE_FACTOR USING    L_PSWSL
                                       'KRW'
                              CHANGING LV_FFACT
                                       LV_TFACT.

  L_KURSF = ( L_DMBTR * LV_FFACT ) / ( L_WRBTR * GV_POINT * LV_TFACT ).

*  l_KURSF = l_DMBTR / ( l_WRBTR * gv_point ) .
*} 기능개선 287676 - 변경_E

  LS_KURSF = L_KURSF.

  CONDENSE LS_KURSF.

** 미지급 전표 대상을 찾는다.
  SELECT  BELNR2 FBUDA2 FBUDA_BELNR2
    INTO  CORRESPONDING FIELDS OF TABLE GT_BELNR2
    FROM  ZSD0017T
   WHERE  FBUDA  =  G_ITEM_T-FBUDA
     AND  VBELN  =  G_ITEM_T-VBELN
     AND  BELNR  =  G_ITEM_T-BELNR.

  L_BELNR2_GJAHR = G_ITEM_T-FBUDA(4).

  IF SY-SUBRC = '4'.

    L_SUM_DMBTR = 0.

  ELSE.

    LOOP AT GT_BELNR2.
*** [START] BEFORE MODIFIED FOR COMPANY CODE **********************
*        select  single dmbtr
*          into  l_belnr2_dmbtr
*          from  bseg
*         where  bukrs  =  '1000'
*           and  belnr  =  gt_belnr2-belnr2
*           and  gjahr  =  gt_belnr2-FBUDA2(4)
*           and  SHKZG  =  'S' .
*** [END] BEFORE MODIFIED FOR COMPANY CODE **********************



*** [START] AFTER MODIFIED FOR COMPANY CODE **********************
*>> START - Archiving 관련변경 06 -> 20080311
*-- 아카이브 체크를 한 경우에만 AS 테이블에서 정보를 가지고 온다.
      IF NOT P_ARCV IS INITIAL.
        SELECT  SINGLE DMBTR
          INTO  L_BELNR2_DMBTR
          FROM  ZARIXFI1
         WHERE  BUKRS  =  PA_VKORG
           AND  BELNR  =  GT_BELNR2-BELNR2
           AND  GJAHR  =  GT_BELNR2-FBUDA2(4)
           AND  SHKZG  =  'S' .
        IF SY-SUBRC <> 0.
*-- 아카이브 데이터가 없으면 BSEG 에서 데이터를 취득한다.
          SELECT  SINGLE DMBTR
            INTO  L_BELNR2_DMBTR
            FROM  BSEG
           WHERE  BUKRS  =  PA_VKORG
             AND  BELNR  =  GT_BELNR2-BELNR2
             AND  GJAHR  =  GT_BELNR2-FBUDA2(4)
             AND  SHKZG  =  'S' .
        ENDIF.

      ELSE.
        SELECT  SINGLE DMBTR
          INTO  L_BELNR2_DMBTR
          FROM  BSEG
         WHERE  BUKRS  =  PA_VKORG
           AND  BELNR  =  GT_BELNR2-BELNR2
           AND  GJAHR  =  GT_BELNR2-FBUDA2(4)
           AND  SHKZG  =  'S' .
      ENDIF.

**      select  single dmbtr
**        into  l_belnr2_dmbtr
**        from  bseg
**       where  bukrs  =  pa_vkorg
**         and  belnr  =  gt_belnr2-belnr2
**         and  gjahr  =  gt_belnr2-FBUDA2(4)
**         and  SHKZG  =  'S' .
*>> END   - Archiving 관련변경 06 -> 20080311
*** [END] AFTER MODIFIED FOR COMPANY CODE **********************
      L_SUM_DMBTR = L_SUM_DMBTR + L_BELNR2_DMBTR.

    ENDLOOP.

  ENDIF.

  L_ADJUST_DMBTR =  L_DMBTR - L_SUM_DMBTR.

  IF GV_UCOMM  =  'REQU3' AND  G_ITEM_T-WAERS NE 'KRW'.

    L_ADJUST_DMBTRX_BUGA = ( L_ADJUST_DMBTRX / 10 ).
    LS_ADJUST_DMBTR_BUGA = L_ADJUST_DMBTRX_BUGA.

    L_ADJUST_DMBTR = L_ADJUST_DMBTR + ( L_ADJUST_DMBTR / 10 ).

  ENDIF.

  L_ADJUST_DMBTRX =  L_ADJUST_DMBTR * ( 1 / GV_POINT ).

  LS_ADJUST_DMBTR = L_ADJUST_DMBTRX.

  CONDENSE LS_ADJUST_DMBTR.

  CLEAR : GT_BDCDATA, GT_BDCDATA[].

  PERFORM BDC_DYNPRO      USING 'SAPMF05A' '0122'.
  PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                                'RF05A-NEWKO'.
  PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                '/00'.
  PERFORM BDC_FIELD       USING 'BKPF-BLDAT'
                                PA_REQDT.
  PERFORM BDC_FIELD       USING 'BKPF-BLART'
                                C_BLART.
  PERFORM BDC_FIELD       USING 'BKPF-BUKRS'
                                C_BUKRS.
  PERFORM BDC_FIELD       USING 'BKPF-BUDAT'
                                PA_REQDT.
  PERFORM BDC_FIELD       USING 'BKPF-WAERS'
                                G_ITEM_T-WAERS.
  PERFORM BDC_FIELD       USING 'BKPF-KURSF'
                                 LS_KURSF.
  PERFORM BDC_FIELD       USING 'RF05A-NEWBS'
                                '31'.
  PERFORM BDC_FIELD       USING 'RF05A-NEWKO'
                                P_LIFNR.
*  perform bdc_field       using 'BKPF-WWERT'
*                                l_bldat.


  PERFORM BDC_DYNPRO      USING 'SAPMF05A' '0302'.
  PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                                'BSEG-BUPLA'.
  PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                '=SL'.
  PERFORM BDC_FIELD       USING 'BSEG-WRBTR'
                                LV_NETWR.

  PERFORM BDC_FIELD       USING 'BSEG-EMPFB'
                                G_H_EMPFK.

** Add by SDC06 : 2005-04-13
  PERFORM BDC_FIELD       USING 'BSEG-GSBER'
                                LV_GSBER.
  PERFORM BDC_FIELD       USING 'BSEG-BUPLA'
                                C_BUPLA.
  PERFORM BDC_FIELD       USING 'BSEG-ZFBDT'
                                PA_REQDT.

  PERFORM BDC_DYNPRO      USING 'SAPMF05A' '0710'.
  PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                '=PA'.
  PERFORM BDC_FIELD       USING 'RF05A-AGKON'
                                P_LIFNR.
  PERFORM BDC_FIELD       USING 'RF05A-AGUMS'
                                C_UMSKZ.
  PERFORM BDC_FIELD       USING 'RF05A-XNOPS'
                                SPACE.
  PERFORM BDC_FIELD       USING 'RF05A-XPOS1(10)'           " 11->09
                                'X'.

  DESCRIBE TABLE G_TMP2_T LINES L_CNT.

  IF  L_CNT  =  0.

    PERFORM BDC_DYNPRO      USING 'SAPMF05A' '0731'.
    PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                                  'RF05A-SEL01(01)'.
    PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                  '=PA'.
    PERFORM BDC_FIELD       USING 'RF05A-SEL01(01)'
                            G_ITEM_T-BELNR.
    " 최초 미지급 전표번호

  ELSE.

    PERFORM BDC_DYNPRO      USING 'SAPMF05A' '0731'.
    PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                                  'RF05A-SEL01(01)'.
    PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                  '/00'.
    PERFORM BDC_FIELD       USING 'RF05A-SEL01(01)'
                            G_ITEM_T-BELNR.
    " 최초 미지급 전표번호

    LOOP AT G_TMP2_T.

      PERFORM BDC_DYNPRO      USING 'SAPMF05A' '0731'.
      PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                                    'RF05A-SEL01(01)'.
      PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                    '/00'.
      PERFORM BDC_FIELD       USING 'RF05A-SEL01(01)'
                              G_TMP2_T-BELNR2.

    ENDLOOP.

    PERFORM BDC_DYNPRO      USING 'SAPMF05A' '0731'.
    PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                                  'RF05A-SEL01(01)'.
    PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                  '=PA'.

*      do l_cnt times.
*
*        l_cnt2  =  l_cnt2  +  2.
*
*        concatenate  'DF05B-PSBET(' l_cnt2 ')'  into  l_cursor_name.
*
*        perform bdc_dynpro      using 'SAPDF05X' '3100'.
*        perform bdc_field       using 'BDC_OKCODE'
*                                      '=PI'.
*        perform bdc_field       using 'BDC_CURSOR'
*                                      l_cursor_name.
*
*      enddo.
*
  ENDIF.



  IF GV_UCOMM  =  'REQU3'.

    PERFORM BDC_DYNPRO      USING 'SAPDF05X' '3100'.
    PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                               '=BS'.
*  perform bdc_field    using 'DF05B-PSZAH(01)'
*                              lv_netwr_orgn.
    PERFORM BDC_FIELD    USING 'BDC_OKCODE'
                               '=AB'.
    PERFORM BDC_FIELD    USING 'RF05A-ABPOS'
                               '1'.
    PERFORM BDC_DYNPRO   USING 'SAPMF05A' '0700'.
    PERFORM BDC_FIELD    USING 'BDC_CURSOR'
                               'RF05A-NEWKO'.
    PERFORM BDC_FIELD    USING 'BDC_OKCODE'
                               '/00'.
    PERFORM BDC_FIELD    USING 'RF05A-NEWBS'
                               '40'.
    PERFORM BDC_FIELD    USING 'RF05A-NEWKO'
                               '1220101'.

    PERFORM BDC_DYNPRO   USING 'SAPMF05A' '0312'.

    PERFORM BDC_FIELD    USING 'BDC_CURSOR'
                               'BSEG-GSBER'.
    PERFORM BDC_FIELD    USING 'BDC_OKCODE'
                               '/00'.

    PERFORM BDC_FIELD    USING 'BSEG-WRBTR'
                               LV_NETWR_BUGA.

    PERFORM BDC_FIELD    USING 'BSEG-FWBAS'
                               LV_NETWR_ORGN.
*-> CCM : 17.10.2023 15:28:31 / ZLSGSD3
*- 추가 계정 X 처리 시 코딩 블록 팝업됨으로 INIT 처리
    PERFORM BDC_FIELD    USING 'DKACB-FMORE'
                                ' '.
*<-

    PERFORM BDC_FIELD    USING 'BSEG-MWSKZ'
                               'VA'.
    PERFORM BDC_FIELD    USING 'BSEG-BUPLA'
                               C_BUPLA.
    PERFORM BDC_FIELD    USING 'BSEG-GSBER'
                               LV_GSBER.
    PERFORM BDC_FIELD    USING 'BDC_CURSOR'
                               'BSEG-WRBTR'.
    PERFORM BDC_FIELD    USING 'BDC_OKCODE'
                               '=BS'.

    PERFORM BDC_DYNPRO      USING 'SAPMF05A' '0700'.
    PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                  '=BU'.

  ELSE.

    PERFORM BDC_DYNPRO      USING 'SAPDF05X' '3100'.
    PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                  '=BS'.
    PERFORM BDC_DYNPRO      USING 'SAPMF05A' '0700'.
    PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                  '=BU'.
  ENDIF.

ENDFORM.                    " fill_field_data_last

*&---------------------------------------------------------------------*
*&      Form  fill_field_data_last2
*&---------------------------------------------------------------------*
FORM FILL_FIELD_DATA_LAST2  USING    P_LIFNR.

  DATA : LV_NETWR(15),
         LV_TEMP       LIKE ZSDS002-NETWR,
         LV_NETWR2(15),
         LV_NETWR2_I   LIKE ZSDS002-NETWR,
         LV_TEMP2(15).
  DATA : LV_LIFNR     LIKE LFA1-LIFNR,
         LV_GSBER     LIKE BSEG-GSBER,
         LV_XBLNR(21).
  DATA : L_CNT             TYPE I,
         L_CNT2(2)         TYPE N,
         L_CURSOR_NAME(20).
  CLEAR : LV_TEMP, LV_TEMP2, LV_NETWR2, LV_GSBER, GV_LIFNR.
  CLEAR : L_CNT, L_CNT2, L_CURSOR_NAME.

*>> START - Archiving 관련변경 07 -> 20080311
*-- 아카이브 체크를 한 경우에만 AS 테이블에서 정보를 가지고 온다.
  IF NOT P_ARCV IS INITIAL.
    SELECT  SINGLE GSBER
      INTO  LV_GSBER
      FROM  ZARIXFI1
     WHERE  BUKRS  =  PA_VKORG
       AND  BELNR  =  G_ITEM_T-BELNR
       AND  GJAHR  =  G_ITEM_T-FBUDA+0(4).
    IF SY-SUBRC <> 0.
*-- 아카이브 데이터가 없으면 BSEG 에서 데이터를 취득한다.
      SELECT  SINGLE GSBER
        INTO  LV_GSBER
        FROM  BSEG
       WHERE  BUKRS  =  PA_VKORG
         AND  BELNR  =  G_ITEM_T-BELNR
         AND  GJAHR  =  G_ITEM_T-FBUDA+0(4).
    ENDIF.

  ELSE.
    SELECT  SINGLE GSBER
      INTO  LV_GSBER
      FROM  BSEG
     WHERE  BUKRS  =  PA_VKORG
       AND  BELNR  =  G_ITEM_T-BELNR
       AND  GJAHR  =  G_ITEM_T-FBUDA+0(4).
  ENDIF.
** 사업영역
**  select  single gsber
**    into  lv_gsber
**    from  bseg
**   where  BUKRS  =  pa_vkorg
**     and  belnr  =  g_item_t-belnr
**     and  gjahr  =  g_item_t-fbuda+0(4).
*>> END   - Archiving 관련변경 07 -> 20080311

  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
    EXPORTING
      INPUT  = P_LIFNR
    IMPORTING
      OUTPUT = P_LIFNR.

  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
    EXPORTING
      INPUT  = G_ITEM_T-KNUMA
    IMPORTING
      OUTPUT = G_ITEM_T-KNUMA.

  IF  GV_UCOMM  =  'REQU'.
** 지급가능금액
    WRITE : G_ITEM_T-R_WRBTR TO LV_NETWR CURRENCY G_ITEM_T-WAERS.
  ELSE.
** 지급가능금액(Tax)는 Currency Field가 아니기때문에..
    WRITE : G_ITEM_T-R_BUGA TO LV_NETWR.
  ENDIF.

  CALL FUNCTION 'RP_LAST_DAY_OF_MONTHS'
    EXPORTING
      DAY_IN            = PA_REQDT
    IMPORTING
      LAST_DAY_OF_MONTH = GV_LDATE.


  CLEAR : GT_BDCDATA, GT_BDCDATA[].

  PERFORM BDC_DYNPRO      USING 'SAPMF05A' '0122'.
  PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                                'RF05A-NEWKO'.
  PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                '/00'.
  PERFORM BDC_FIELD       USING 'BKPF-BLDAT'
                                PA_REQDT.
  PERFORM BDC_FIELD       USING 'BKPF-BLART'
                                C_BLART.
  PERFORM BDC_FIELD       USING 'BKPF-BUKRS'
                                C_BUKRS.
  PERFORM BDC_FIELD       USING 'BKPF-BUDAT'
                                PA_REQDT.
  PERFORM BDC_FIELD       USING 'BKPF-WAERS'
                                G_ITEM_T-K_WAERK.
  PERFORM BDC_FIELD       USING 'RF05A-NEWBS'
                                '31'.
  PERFORM BDC_FIELD       USING 'RF05A-NEWKO'
                                P_LIFNR.

  PERFORM BDC_DYNPRO      USING 'SAPMF05A' '0302'.
  PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                                'BSEG-BUPLA'.
  PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                '=SL'.
  PERFORM BDC_FIELD       USING 'BSEG-WRBTR'
                                LV_NETWR.
** Add by SDC06 : 2005-04-13
  PERFORM BDC_FIELD       USING 'BSEG-GSBER'
                                LV_GSBER.
  PERFORM BDC_FIELD       USING 'BSEG-BUPLA'
                                C_BUPLA.
  PERFORM BDC_FIELD       USING 'BSEG-ZFBDT'
                                PA_REQDT.

  PERFORM BDC_DYNPRO      USING 'SAPMF05A' '0710'.
  PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                '=PA'.
  PERFORM BDC_FIELD       USING 'RF05A-AGKON'
                                P_LIFNR.
  PERFORM BDC_FIELD       USING 'RF05A-AGUMS'
                                C_UMSKZ.
  PERFORM BDC_FIELD       USING 'RF05A-XNOPS'
                                SPACE.
  PERFORM BDC_FIELD       USING 'RF05A-XPOS1(10)'           " 11->09
                                'X'.

  DESCRIBE TABLE G_TMP2_T LINES L_CNT.

  IF  L_CNT  =  0.

    PERFORM BDC_DYNPRO      USING 'SAPMF05A' '0731'.
    PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                                  'RF05A-SEL01(01)'.
    PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                  '=PA'.
    PERFORM BDC_FIELD       USING 'RF05A-SEL01(01)'
                            G_ITEM_T-BUGA_BELNR.
    " 최초 부가세 미지급 전표번호

  ELSE.

    PERFORM BDC_DYNPRO      USING 'SAPMF05A' '0731'.
    PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                                  'RF05A-SEL01(01)'.
    PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                  '/00'.
    PERFORM BDC_FIELD       USING 'RF05A-SEL01(01)'
                            G_ITEM_T-BUGA_BELNR.
    " 최초 부가세 미지급 전표번호

    LOOP AT G_TMP2_T.

      PERFORM BDC_DYNPRO      USING 'SAPMF05A' '0731'.
      PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                                    'RF05A-SEL01(01)'.
      PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                    '/00'.
      PERFORM BDC_FIELD       USING 'RF05A-SEL01(01)'
                              G_TMP2_T-BELNR2.

    ENDLOOP.

    PERFORM BDC_DYNPRO      USING 'SAPMF05A' '0731'.
    PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                                  'RF05A-SEL01(01)'.
    PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                  '=PA'.

*      do l_cnt times.
*
*        l_cnt2  =  l_cnt2  +  2.
*
*        concatenate  'DF05B-PSBET(' l_cnt2 ')'  into  l_cursor_name.
*
*        perform bdc_dynpro      using 'SAPDF05X' '3100'.
*        perform bdc_field       using 'BDC_OKCODE'
*                                      '=PI'.
*        perform bdc_field       using 'BDC_CURSOR'
*                                      l_cursor_name.
*
*      enddo.

  ENDIF.

  PERFORM BDC_DYNPRO      USING 'SAPDF05X' '3100'.
  PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                '=BS'.

  PERFORM BDC_DYNPRO      USING 'SAPMF05A' '0700'.
  PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                '=BU'.

ENDFORM.                    " fill_field_data_last2

*&---------------------------------------------------------------------*
*&      Form  fill_field_data
*&---------------------------------------------------------------------*
FORM FILL_FIELD_DATA  USING    P_LIFNR.

  DATA : LV_NETWR(15),
         LV_NETWR_ORGN(15),
         LV_NETWR_BUGA(15),
         LV_TEMP           LIKE ZSDS002-NETWR,
         LV_NETWR2(15),
         LV_NETWR2_I       LIKE ZSDS002-NETWR,
         LV_TEMP2(15).
  DATA: LV_LIFNR     LIKE LFA1-LIFNR,
        LV_GSBER     LIKE BSEG-GSBER,
        LV_XBLNR(21).

  DATA : L_CNT             TYPE I,
         L_CNT2(2)         TYPE N,
         L_CURSOR_NAME(20).
  DATA : L_BELNR2_GJAHR(4).
  DATA : L_SUM_DMBTR LIKE BSEG-DMBTR.
  DATA : L_BELNR2_DMBTR LIKE BSEG-DMBTR.
  DATA : L_ADJUST_DMBTRX(14) TYPE P DECIMALS 0.
  DATA : L_ADJUST_DMBTR LIKE BSEG-DMBTR.
  DATA : LS_ADJUST_DMBTR(14).
  DATA : G_ITEM_T-R_WRBTR_TEMP LIKE ZSD0017T-WRBTR.
  DATA : G_ITEM_T-R_BUGA LIKE ZSD0017T-WRBTR.
  DATA : L_ADJUST_DMBTRX_BUGA(14) TYPE P DECIMALS 0.
  DATA : LS_ADJUST_DMBTR_BUGA(14).

  DATA: LV_FFACT LIKE TCURF-FFACT,        "기능개선 287676 - 추가
        LV_TFACT LIKE TCURF-TFACT.        "기능개선 287676 - 추가

  CLEAR : G_ITEM_T-R_WRBTR_TEMP.
  CLEAR : LV_TEMP, LV_TEMP2, LV_NETWR2, LV_GSBER, GV_LIFNR.
  CLEAR : L_CNT, L_CNT2, L_CURSOR_NAME.
  CLEAR : L_BELNR2_GJAHR, L_SUM_DMBTR, L_BELNR2_DMBTR,L_ADJUST_DMBTR.

** 사업영역
*>> START - Archiving 관련변경 08 -> 20080311
*-- 아카이브 체크를 한 경우에만 AS 테이블에서 정보를 가지고 온다.
  IF NOT P_ARCV IS INITIAL.
    SELECT  SINGLE GSBER
      INTO  LV_GSBER
      FROM  ZARIXFI1
     WHERE  BUKRS  =  PA_VKORG
       AND  BELNR  =  G_ITEM_T-BELNR
       AND  GJAHR  =  G_ITEM_T-FBUDA+0(4).
    IF SY-SUBRC <> 0.
*-- 아카이브 데이터가 없으면 BSEG 에서 데이터를 취득한다.
      SELECT  SINGLE GSBER
        INTO  LV_GSBER
        FROM  BSEG
       WHERE  BUKRS  =  PA_VKORG
         AND  BELNR  =  G_ITEM_T-BELNR
         AND  GJAHR  =  G_ITEM_T-FBUDA+0(4).
    ENDIF.

  ELSE.
    SELECT  SINGLE GSBER
      INTO  LV_GSBER
      FROM  BSEG
     WHERE  BUKRS  =  PA_VKORG
       AND  BELNR  =  G_ITEM_T-BELNR
       AND  GJAHR  =  G_ITEM_T-FBUDA+0(4).
  ENDIF.

**  select  single gsber
**    into  lv_gsber
**    from  bseg
**   where  BUKRS  =  pa_vkorg
**     and  belnr  =  g_item_t-belnr
**     and  gjahr  =  g_item_t-fbuda+0(4).
*>> END   - Archiving 관련변경 08 -> 20080311

  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
    EXPORTING
      INPUT  = P_LIFNR
    IMPORTING
      OUTPUT = P_LIFNR.

  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
    EXPORTING
      INPUT  = G_ITEM_T-KNUMA
    IMPORTING
      OUTPUT = G_ITEM_T-KNUMA.

  IF  GV_UCOMM  =  'REQU'.
** 지급가능금액
    WRITE : G_ITEM_T-R_WRBTR TO LV_NETWR CURRENCY G_ITEM_T-WAERS.

  ELSEIF GV_UCOMM  =  'REQU3'.

    G_ITEM_T-R_WRBTR_TEMP = ( G_ITEM_T-R_WRBTR * 100 )
                            + TRUNC( G_ITEM_T-R_WRBTR * 10 )  .

    G_ITEM_T-R_WRBTR_TEMP  = G_ITEM_T-R_WRBTR_TEMP / 100.
    G_ITEM_T-R_BUGA = G_ITEM_T-R_WRBTR_TEMP - G_ITEM_T-R_WRBTR.

    WRITE : G_ITEM_T-R_WRBTR_TEMP  TO LV_NETWR CURRENCY G_ITEM_T-WAERS.
    WRITE : G_ITEM_T-R_WRBTR  TO LV_NETWR_ORGN CURRENCY G_ITEM_T-WAERS.
    WRITE : G_ITEM_T-R_BUGA  TO LV_NETWR_BUGA  CURRENCY G_ITEM_T-WAERS.

  ELSE.
** 지급가능금액(Tax)는 Currency Field가 아니기때문에..
    WRITE : G_ITEM_T-R_BUGA TO LV_NETWR.
  ENDIF.

  CALL FUNCTION 'RP_LAST_DAY_OF_MONTHS'
    EXPORTING
      DAY_IN            = PA_REQDT
    IMPORTING
      LAST_DAY_OF_MONTH = GV_LDATE.

*  clear : l_bldat.
*
*  select single BLDAT
*    into l_bldat
*    from bkpf
*   where BUKRS = '1000'
*     and BELNR = g_item_t-BELNR
*     and GJAHR = lv_year.
*
*** [START] BEFORE MODIFIED FOR COMPANY CODE **********************
*  select single PSWSL DMBTR WRBTR
*    into (l_PSWSL, l_DMBTR, l_WRBTR)
*    from bseg
*   where BUKRS = '1000'
*     and BELNR = g_item_t-BELNR
*     and GJAHR = lv_year
*     and SHKZG = 'H'.
*** [END] BEFORE MODIFIED FOR COMPANY CODE **********************


*** [START] AFTER MODIFIED FOR COMPANY CODE **********************
*>> START - Archiving 관련변경 09 -> 20080311
*-- 아카이브 체크를 한 경우에만 AS 테이블에서 정보를 가지고 온다.
  IF NOT P_ARCV IS INITIAL.
    SELECT SINGLE PSWSL DMBTR WRBTR
      INTO (L_PSWSL, L_DMBTR, L_WRBTR)
      FROM ZARIXFI1
     WHERE BUKRS = PA_VKORG
       AND BELNR = G_ITEM_T-BELNR
       AND GJAHR = G_ITEM_T-FBUDA+0(4)
       AND SHKZG = 'H'.
    IF SY-SUBRC <> 0.
*-- 아카이브 데이터가 없으면 BSEG 에서 데이터를 취득한다.
      SELECT SINGLE PSWSL DMBTR WRBTR
        INTO (L_PSWSL, L_DMBTR, L_WRBTR)
        FROM BSEG
       WHERE BUKRS = PA_VKORG
         AND BELNR = G_ITEM_T-BELNR
         AND GJAHR = G_ITEM_T-FBUDA+0(4)
         AND SHKZG = 'H'.
    ENDIF.

  ELSE.
    SELECT SINGLE PSWSL DMBTR WRBTR
      INTO (L_PSWSL, L_DMBTR, L_WRBTR)
      FROM BSEG
     WHERE BUKRS = PA_VKORG
       AND BELNR = G_ITEM_T-BELNR
       AND GJAHR = G_ITEM_T-FBUDA+0(4)
       AND SHKZG = 'H'.
  ENDIF.

**  select single PSWSL DMBTR WRBTR
**    into (l_PSWSL, l_DMBTR, l_WRBTR)
**    from bseg
**   where BUKRS = pa_vkorg
**     and BELNR = g_item_t-BELNR
**     and GJAHR = lv_year
**     and SHKZG = 'H'.
*>> END   - Archiving 관련변경 09 -> 20080311
*** [END] AFTER MODIFIED FOR COMPANY CODE **********************
  CLEAR : GV_POINT,
         L_KURSF,
         LS_KURSF.

  PERFORM DECIMAL_POINT_COMPUTE USING L_PSWSL.

*{ 기능개선 287676 - 변경_S
  PERFORM GET_EXCHANGE_FACTOR USING    L_PSWSL
                                       'KRW'
                              CHANGING LV_FFACT
                                       LV_TFACT.

  L_KURSF = ( L_DMBTR * LV_FFACT ) / ( L_WRBTR * GV_POINT * LV_TFACT ).

*  l_KURSF = l_DMBTR / ( l_WRBTR * gv_point ) .
*} 기능개선 287676 - 변경_E

  LS_KURSF = L_KURSF.

  CONDENSE LS_KURSF.

** 지급 전표의 원화금액을 계산한다.
  L_ADJUST_DMBTR =  ( L_DMBTR / L_WRBTR ) * G_ITEM_T-R_WRBTR.

  IF GV_UCOMM  =  'REQU3' AND  G_ITEM_T-WAERS NE 'KRW'.

    L_ADJUST_DMBTRX_BUGA = ( L_ADJUST_DMBTR / 10 ).
    LS_ADJUST_DMBTR_BUGA = L_ADJUST_DMBTRX_BUGA.

    L_ADJUST_DMBTR = L_ADJUST_DMBTR + ( L_ADJUST_DMBTR / 10 ).

  ENDIF.

  L_ADJUST_DMBTRX =  L_ADJUST_DMBTR * ( 1 / GV_POINT ).

  LS_ADJUST_DMBTR = L_ADJUST_DMBTRX.

  CONDENSE LS_ADJUST_DMBTR.

  CLEAR : GT_BDCDATA, GT_BDCDATA[].

  PERFORM BDC_DYNPRO      USING 'SAPMF05A' '0122'.
  PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                                'RF05A-NEWKO'.
  PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                '/00'.
  PERFORM BDC_FIELD       USING 'BKPF-BLDAT'
                                PA_REQDT.
  PERFORM BDC_FIELD       USING 'BKPF-BLART'
                                C_BLART.
  PERFORM BDC_FIELD       USING 'BKPF-BUKRS'
                                C_BUKRS.
  PERFORM BDC_FIELD       USING 'BKPF-BUDAT'
                                PA_REQDT.
  PERFORM BDC_FIELD       USING 'BKPF-WAERS'
                                G_ITEM_T-WAERS.
  PERFORM BDC_FIELD       USING 'BKPF-KURSF'
                                 LS_KURSF.
  PERFORM BDC_FIELD       USING 'RF05A-NEWBS'
                                '31'.
  PERFORM BDC_FIELD       USING 'RF05A-NEWKO'
                                P_LIFNR.
*  perform bdc_field       using 'BKPF-WWERT'
*                                l_bldat.
*  perform bdc_field       using 'BKPF-KURSF'
*                                l_KURSF.


  PERFORM BDC_DYNPRO      USING 'SAPMF05A' '0302'.
  PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                                'BSEG-BUPLA'.
  PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                '=SL'.
  PERFORM BDC_FIELD       USING 'BSEG-WRBTR'
                                LV_NETWR.
** 원화금액을 입력한다.
*  if  g_item_t-waers ne 'KRW'.
*
*    perform bdc_field       using 'BSEG-DMBTR'
*                               ls_adjust_dmbtr.
*
*  endif.

  PERFORM BDC_FIELD       USING 'BSEG-EMPFB'
                                G_H_EMPFK.


** Add by SDC06 : 2005-04-13
  PERFORM BDC_FIELD       USING 'BSEG-GSBER'
                                LV_GSBER.
  PERFORM BDC_FIELD       USING 'BSEG-BUPLA'
                                C_BUPLA.
  PERFORM BDC_FIELD       USING 'BSEG-ZFBDT'
                                PA_REQDT.

  PERFORM BDC_DYNPRO      USING 'SAPMF05A' '0710'.
  PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                '=PA'.
  PERFORM BDC_FIELD       USING 'RF05A-AGKON'
                                P_LIFNR.
  PERFORM BDC_FIELD       USING 'RF05A-AGUMS'
                                C_UMSKZ.
  PERFORM BDC_FIELD       USING 'RF05A-XNOPS'
                                SPACE.
  PERFORM BDC_FIELD       USING 'RF05A-XPOS1(10)'
                                'X'.

  PERFORM BDC_DYNPRO      USING 'SAPMF05A' '0731'.
  PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                                'RF05A-SEL01(01)'.
  PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                '=PA'.
  PERFORM BDC_FIELD       USING 'RF05A-SEL01(01)'
                              G_ITEM_T-BELNR.
  " 최초 미지급 전표번호

  PERFORM BDC_DYNPRO      USING 'SAPDF05X' '3100'.
  PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                '=PART'.


  PERFORM BDC_DYNPRO      USING 'SAPDF05X' '3100'.
  PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                '/00'.
  PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                                'DF05B-PSZAH(01)'.

  IF GV_UCOMM  =  'REQU3'.

    PERFORM BDC_FIELD    USING 'DF05B-PSZAH(01)'
                                LV_NETWR_ORGN.
    PERFORM BDC_FIELD    USING 'BDC_OKCODE'
                               '=AB'.
    PERFORM BDC_FIELD    USING 'RF05A-ABPOS'
                               '1'.

    PERFORM BDC_DYNPRO   USING 'SAPMF05A' '0700'.
    PERFORM BDC_FIELD    USING 'BDC_CURSOR'
                               'RF05A-NEWKO'.
    PERFORM BDC_FIELD    USING 'BDC_OKCODE'
                               '/00'.
    PERFORM BDC_FIELD    USING 'RF05A-NEWBS'
                               '40'.
    PERFORM BDC_FIELD    USING 'RF05A-NEWKO'
                               '1220101'.

    PERFORM BDC_DYNPRO   USING 'SAPMF05A' '0312'.
    PERFORM BDC_FIELD    USING 'BDC_CURSOR'
                               'BSEG-GSBER'.
    PERFORM BDC_FIELD    USING 'BDC_OKCODE'
                               '/00'.
    PERFORM BDC_FIELD    USING 'BSEG-WRBTR'
                               LV_NETWR_BUGA.
    PERFORM BDC_FIELD    USING 'BSEG-FWBAS'
                               LV_NETWR_ORGN .

*-> CCM : 17.10.2023 15:25:47 / ZLSGSD3
* 추가 체크박스 INIT 처리 - X 시 코딩 블락 팝업됨.
    PERFORM BDC_FIELD    USING 'DKACB-FMORE'
                               ' '.
*<-

    PERFORM BDC_FIELD    USING 'BSEG-MWSKZ'
                               'VA'.
    PERFORM BDC_FIELD    USING 'BSEG-BUPLA'
                               C_BUPLA.
    PERFORM BDC_FIELD    USING 'BSEG-GSBER'
                               LV_GSBER.

    PERFORM BDC_FIELD    USING 'BDC_CURSOR'
                               'BSEG-WRBTR'.
    PERFORM BDC_FIELD    USING 'BDC_OKCODE'
                               '=BS'.


  ELSE.
    PERFORM BDC_FIELD       USING 'DF05B-PSZAH(01)'
                               LV_NETWR.
    PERFORM BDC_DYNPRO      USING 'SAPDF05X' '3100'.

    PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                               '=BS'.

  ENDIF.

  PERFORM BDC_DYNPRO      USING 'SAPMF05A' '0700'.
  PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                '=BU'.

ENDFORM.                    " fill_field_data

*&---------------------------------------------------------------------*
*&      Form  fill_field_data2
*&---------------------------------------------------------------------*
FORM FILL_FIELD_DATA2  USING    P_LIFNR.

  DATA : LV_NETWR(15),
         LV_TEMP       LIKE ZSDS002-NETWR,
         LV_NETWR2(15),
         LV_NETWR2_I   LIKE ZSDS002-NETWR,
         LV_TEMP2(15).
  DATA: LV_LIFNR     LIKE LFA1-LIFNR,
        LV_GSBER     LIKE BSEG-GSBER,
        LV_XBLNR(21).

  CLEAR : LV_TEMP, LV_TEMP2, LV_NETWR2, LV_GSBER, GV_LIFNR.

** 사업영역
*>> START - Archiving 관련변경 10 -> 20080311
*-- 아카이브 체크를 한 경우에만 AS 테이블에서 정보를 가지고 온다.
  IF NOT P_ARCV IS INITIAL.
    SELECT  SINGLE GSBER
      INTO  LV_GSBER
      FROM  ZARIXFI1
     WHERE  BUKRS  =  PA_VKORG
       AND  BELNR  =  G_ITEM_T-BELNR
       AND  GJAHR  =  G_ITEM_T-FBUDA+0(4).
    IF SY-SUBRC <> 0.
      SELECT  SINGLE GSBER
        INTO  LV_GSBER
        FROM  BSEG
       WHERE  BUKRS  =  PA_VKORG
         AND  BELNR  =  G_ITEM_T-BELNR
         AND  GJAHR  =  G_ITEM_T-FBUDA+0(4).
    ENDIF.

  ELSE.
    SELECT  SINGLE GSBER
      INTO  LV_GSBER
      FROM  BSEG
     WHERE  BUKRS  =  PA_VKORG
       AND  BELNR  =  G_ITEM_T-BELNR
       AND  GJAHR  =  G_ITEM_T-FBUDA+0(4).
  ENDIF.

**  select  single gsber
**    into  lv_gsber
**    from  bseg
**   where  BUKRS  =  pa_vkorg
**     and  belnr  =  g_item_t-belnr
**     and  gjahr  =  g_item_t-fbuda+0(4).
*>> END   - Archiving 관련변경 10 -> 20080311

  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
    EXPORTING
      INPUT  = P_LIFNR
    IMPORTING
      OUTPUT = P_LIFNR.

  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
    EXPORTING
      INPUT  = G_ITEM_T-KNUMA
    IMPORTING
      OUTPUT = G_ITEM_T-KNUMA.

  IF  GV_UCOMM  =  'REQU'.
** 지급가능금액
    WRITE : G_ITEM_T-R_WRBTR TO LV_NETWR CURRENCY G_ITEM_T-WAERS.
  ELSE.
** 지급가능금액(Tax)는 Currency Field가 아니기때문에..
    WRITE : G_ITEM_T-R_BUGA TO LV_NETWR.
  ENDIF.

  CALL FUNCTION 'RP_LAST_DAY_OF_MONTHS'
    EXPORTING
      DAY_IN            = PA_REQDT
    IMPORTING
      LAST_DAY_OF_MONTH = GV_LDATE.

  CLEAR : GT_BDCDATA, GT_BDCDATA[].

  PERFORM BDC_DYNPRO      USING 'SAPMF05A' '0122'.
  PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                                'RF05A-NEWKO'.
  PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                '/00'.
  PERFORM BDC_FIELD       USING 'BKPF-BLDAT'
                                PA_REQDT.
  PERFORM BDC_FIELD       USING 'BKPF-BLART'
                                C_BLART.
  PERFORM BDC_FIELD       USING 'BKPF-BUKRS'
                                C_BUKRS.
  PERFORM BDC_FIELD       USING 'BKPF-BUDAT'
                                PA_REQDT.
  PERFORM BDC_FIELD       USING 'BKPF-WAERS'
                                G_ITEM_T-K_WAERK.
  PERFORM BDC_FIELD       USING 'RF05A-NEWBS'
                                '31'.
  PERFORM BDC_FIELD       USING 'RF05A-NEWKO'
                                P_LIFNR.

  PERFORM BDC_DYNPRO      USING 'SAPMF05A' '0302'.
  PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                                'BSEG-BUPLA'.
  PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                '=SL'.
  PERFORM BDC_FIELD       USING 'BSEG-WRBTR'
                                LV_NETWR.
** Add by SDC06 : 2005-04-13
  PERFORM BDC_FIELD       USING 'BSEG-GSBER'
                                LV_GSBER.
  PERFORM BDC_FIELD       USING 'BSEG-BUPLA'
                                C_BUPLA.
  PERFORM BDC_FIELD       USING 'BSEG-ZFBDT'
                                PA_REQDT.

  PERFORM BDC_DYNPRO      USING 'SAPMF05A' '0710'.
  PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                '=PA'.
  PERFORM BDC_FIELD       USING 'RF05A-AGKON'
                                P_LIFNR.
  PERFORM BDC_FIELD       USING 'RF05A-AGUMS'
                                C_UMSKZ.
  PERFORM BDC_FIELD       USING 'RF05A-XNOPS'
                                SPACE.
  PERFORM BDC_FIELD       USING 'RF05A-XPOS1(10)'
                                'X'.

  PERFORM BDC_DYNPRO      USING 'SAPMF05A' '0731'.
  PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                                'RF05A-SEL01(01)'.
  PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                '=PA'.
  PERFORM BDC_FIELD       USING 'RF05A-SEL01(01)'
                              G_ITEM_T-BUGA_BELNR.
  " 최초 부가세 미지급 전표번호


  PERFORM BDC_DYNPRO      USING 'SAPDF05X' '3100'.
  PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                '=PART'.


  PERFORM BDC_DYNPRO      USING 'SAPDF05X' '3100'.
  PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                '/00'.
  PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                                'DF05B-PSZAH(01)'.
  PERFORM BDC_FIELD       USING 'DF05B-PSZAH(01)'
                                LV_NETWR.

  PERFORM BDC_DYNPRO      USING 'SAPDF05X' '3100'.
  PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                '=BS'.

  PERFORM BDC_DYNPRO      USING 'SAPMF05A' '0700'.
  PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                '=BU'.

ENDFORM.                    " fill_field_data2

*&---------------------------------------------------------------------*
*&      Form  call_transaction_f-51
*&---------------------------------------------------------------------*
FORM CALL_TRANSACTION_F-51 .

** BDC Detail Message.
  DATA: LT_BDCMSG TYPE TABLE OF BDCMSGCOLL WITH HEADER LINE.
  DATA: LC_VBELN TYPE LIKP-VBELN,
        LV_LAST.

  CLEAR : GV_BELNR.

  CALL TRANSACTION 'F-51' USING  GT_BDCDATA
                           UPDATE 'S'
                           MODE   P_MODE
                           MESSAGES INTO LT_BDCMSG.

  IF SY-SUBRC EQ 0.
    IF SY-MSGTY EQ 'S'  AND
       SY-MSGID EQ 'F5' AND
       SY-MSGNO EQ '312'.
      LOOP AT LT_BDCMSG WHERE MSGTYP EQ 'S'
                          AND MSGID EQ 'F5'
                          AND MSGNR EQ '312'.
        GV_BELNR = LT_BDCMSG-MSGV1.
      ENDLOOP.
    ENDIF.
  ENDIF.

  LOOP AT LT_BDCMSG.
    AT LAST.
      LV_LAST = 'X'.
    ENDAT.
    IF LV_LAST IS INITIAL.
      CASE LT_BDCMSG-MSGTYP.
        WHEN 'A' OR 'E' OR 'X'.
          CLEAR GT_BDCMSG.
          GT_BDCMSG-BELNR = GV_BELNR.
          GT_BDCMSG-UPDKZ = 'I'.
          MOVE-CORRESPONDING LT_BDCMSG TO GT_BDCMSG.
          APPEND GT_BDCMSG.
        WHEN 'W'.
          IF LT_BDCMSG-MSGNR NE '394'.
            CLEAR GT_BDCMSG.
            GT_BDCMSG-BELNR = GV_BELNR.
            GT_BDCMSG-UPDKZ = 'I'.
            MOVE-CORRESPONDING LT_BDCMSG TO GT_BDCMSG.
            APPEND GT_BDCMSG.
          ENDIF.
      ENDCASE.
    ELSE.
      CLEAR GT_BDCMSG.
      GT_BDCMSG-BELNR = GV_BELNR.
      GT_BDCMSG-UPDKZ = 'I'.
      MOVE-CORRESPONDING LT_BDCMSG TO GT_BDCMSG.
      APPEND GT_BDCMSG.
    ENDIF.
  ENDLOOP.

** CBO테이블 관리.
** 지급전표 생성여부 Check.
  CHECK NOT GV_BELNR IS INITIAL  AND
            GV_BELNR+0(2) EQ '12'.    " 전표번호의 Number Range

** 참고
*  ZSD0017T-BELNR / g_itab_t-belnr : 미지급전표번호
*  ZSD0017T-BELNR2 / g_itab_t-belnr2 : 지급전표번호
*  ZSD0017T-BUGA_BELNR / g_itab_t-buga_belnr2 : 부가세 미지급전표번호
*  ZSD0017T-BUGA_BELNR2 / g_itab_t-buga_belnr : 부가세 지급전표번호

  IF  GV_UCOMM  =  'REQU' OR GV_UCOMM  =  'REQU3'.     " 지급전표생성

    CLEAR : G_ZSD0017T.
    REFRESH : G_ZSD0017T.

    LOOP AT G_ITEM_T WHERE BOX = 'X'.

      MOVE-CORRESPONDING  G_ITEM_T  TO  G_ZSD0017T.

** 대금청구통화가 아닌 커미션통화를 Move한다.
      G_ZSD0017T-WAERK       =  G_ITEM_T-WAERS.
      G_ZSD0017T-BELNR2      =  GV_BELNR.
      G_ZSD0017T-BUGA_BELNR  =  SPACE.
*        g_zsd0017t-buga_belnr2  =  g_item_t-buga_belnr.
      G_ZSD0017T-WRBTR       =  G_ITEM_T-R_WRBTR.
      G_ZSD0017T-BUGA_AMNT   =  0.
      G_ZSD0017T-AEDAT       =  SY-DATUM.
      G_ZSD0017T-AENAM       =  SY-UNAME.
      G_ZSD0017T-FBUDA2      =  PA_REQDT(6).

      APPEND  G_ZSD0017T.
      CLEAR  G_ZSD0017T.

    ENDLOOP.

    MODIFY ZSD0017T FROM TABLE G_ZSD0017T.

  ELSEIF  GV_UCOMM  =  'REQU2'.     " 부가세지급전표생성

    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
      EXPORTING
        INPUT  = G_ITEM_T-KNUMA
      IMPORTING
        OUTPUT = G_ITEM_T-KNUMA.

    UPDATE  ZSD0017T
       SET  BUGA_BELNR   =  GV_BELNR
            BUGA_BELNR2  =  G_ITEM_T-BUGA_BELNR
            BUGA_AMNT    =  G_ITEM_T-R_BUGA
            FBUDA_BELNR2 =  PA_REQDT(6)
            AEDAT        =  SY-DATUM
            AENAM        =  SY-UNAME
     WHERE  KNUMA  =  G_ITEM_T-KNUMA
       AND  FBUDA  =  G_ITEM_T-FBUDA
       AND  VBELN  =  G_ITEM_T-VBELN
       AND  BELNR  =  G_ITEM_T-BELNR
       AND  VBELN2 =  G_ITEM_T-VBELN2
       AND  BELNR2 =  G_ITEM_T-BELNR2.

  ENDIF.

  IF  SY-SUBRC  EQ  0.
*      commit work.
    MESSAGE S000 WITH '저장을 완료하였습니다'.
  ELSE.
*      rollback work.
    MESSAGE S000 WITH '저장에 실패하였습니다'.
  ENDIF.

ENDFORM.                    " call_transaction_f-51

*&---------------------------------------------------------------------*
*&      Form  execute_bdc_fb08_data
*&---------------------------------------------------------------------*
FORM EXECUTE_BDC_FB08_DATA .

  REFRESH  GT_BDCMSG.

  DATA : LV_CNT   TYPE I,
         LV_FLAG,
         LV_FLAG2,
         LV_KUNNR LIKE KNA1-KUNNR,
         LV_LIFNR LIKE KNA1-LIFNR.

  CLEAR : LV_FLAG, LV_FLAG2, LV_CNT.
  REFRESH GT_BDCDATA.

  LOOP AT G_ITEM_T WHERE BOX = 'X'.

** 부가세지급전표 생성 완료여부 Check.
    IF  G_ITEM_T-LIGHTS EQ C_BLIGHT.
      LV_FLAG = 'X'.
*        exit.
    ENDIF.

** 지급전표 생성 완료여부 Check.
    IF  G_ITEM_T-LIGHTS EQ C_FLIGHT.
      LV_FLAG2 = 'X'.
*        exit.
    ENDIF.

    LV_CNT  =  LV_CNT  +  1.

  ENDLOOP.

  IF  LV_CNT  >  1  OR
      LV_CNT  =  0.
    MESSAGE E001(ZSD1) WITH '지급요청은 한건씩 처리됩니다.'.
    EXIT.
  ENDIF.

  IF  LV_FLAG  =  'X'.
    MESSAGE E001(ZSD1) WITH '부가세지급전표가 존재합니다.'.
    EXIT.
  ENDIF.

  IF  LV_FLAG2  =  'X'.
    MESSAGE E001(ZSD1) WITH '취소할 지급전표가 없습니다.'.
    EXIT.
  ENDIF.

  LOOP AT G_ITEM_T WHERE BOX = 'X'.

** 역분개 전표 생성 BDC 처리
    PERFORM FILL_FIELD_DATA_FB08.
    PERFORM CALL_TRANSACTION_FB08.

  ENDLOOP.

  PERFORM CALL_MESSAGE_SCREEN.

ENDFORM.                    " execute_bdc_fb08_data

*&---------------------------------------------------------------------*
*&      Form  fill_field_data_fb08
*&---------------------------------------------------------------------*
FORM FILL_FIELD_DATA_FB08 .

  PERFORM BDC_DYNPRO      USING 'SAPMF05A' '0105'.
  PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                                'UF05A-STGRD'.
  PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                '=BU'.
  PERFORM BDC_FIELD       USING 'RF05A-BELNS'
                                G_ITEM_T-BELNR2.
  PERFORM BDC_FIELD       USING 'BKPF-BUKRS'
                                C_BUKRS.
  PERFORM BDC_FIELD       USING 'RF05A-GJAHS'
                                SY-DATUM(4).
  PERFORM BDC_FIELD       USING 'UF05A-STGRD'
                                '01'.

ENDFORM.                    " fill_field_data_fb08

*&---------------------------------------------------------------------*
*&      Form  execute_bdc_fb08_data2
*&---------------------------------------------------------------------*
FORM EXECUTE_BDC_FB08_DATA2 .

  REFRESH  GT_BDCMSG.

  DATA : LV_CNT   TYPE I,
         LV_FLAG,
         LV_FLAG2,
         LV_KUNNR LIKE KNA1-KUNNR,
         LV_LIFNR LIKE KNA1-LIFNR.

  CLEAR : LV_FLAG, LV_FLAG2, LV_CNT.
  REFRESH GT_BDCDATA.

  LOOP AT G_ITEM_T WHERE BOX = 'X'.

** 부가세지급전표 생성 완료여부 Check
    IF  G_ITEM_T-LIGHTS EQ C_CLIGHT.
      LV_FLAG = 'X'.
*        exit.
    ENDIF.

** 지급전표 생성 완료여부 Check.
    IF  G_ITEM_T-LIGHTS EQ C_FLIGHT.
      LV_FLAG2 = 'X'.
*        exit.
    ENDIF.

    LV_CNT  =  LV_CNT  +  1.

  ENDLOOP.

  IF  LV_CNT  >  1  OR
      LV_CNT  =  0.
    MESSAGE E001(ZSD1) WITH '지급요청은 한건씩 처리됩니다.'.
    EXIT.
  ENDIF.

  IF  LV_FLAG  =  'X'.
    MESSAGE E001(ZSD1) WITH '취소할 부가세지급전표가 없습니다.'.
    EXIT.
  ENDIF.

  IF  LV_FLAG2  =  'X'.
    MESSAGE E001(ZSD1) WITH 'Data를 확인하세요.'.
    EXIT.
  ENDIF.

  LOOP AT G_ITEM_T WHERE BOX = 'X'.

** 역분개 전표 생성 BDC 처리
    PERFORM FILL_FIELD_DATA_FB08_2.
    PERFORM CALL_TRANSACTION_FB08.

  ENDLOOP.

  PERFORM CALL_MESSAGE_SCREEN.

ENDFORM.                    " execute_bdc_fb08_data2

*&---------------------------------------------------------------------*
*&      Form  fill_field_data_fb08_2
*&---------------------------------------------------------------------*
FORM FILL_FIELD_DATA_FB08_2 .

  PERFORM BDC_DYNPRO      USING 'SAPMF05A' '0105'.
  PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                                'UF05A-STGRD'.
  PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                '=BU'.
  PERFORM BDC_FIELD       USING 'RF05A-BELNS'
                                G_ITEM_T-BUGA_BELNR2.
  PERFORM BDC_FIELD       USING 'BKPF-BUKRS'
                                C_BUKRS.
  PERFORM BDC_FIELD       USING 'RF05A-GJAHS'
                                SY-DATUM(4).
  PERFORM BDC_FIELD       USING 'UF05A-STGRD'
                                '01'.

ENDFORM.                    " fill_field_data_fb08_2

*&---------------------------------------------------------------------*
*&      Form  call_transaction_fb08
*&---------------------------------------------------------------------*
FORM CALL_TRANSACTION_FB08 .

** BDC Detail Message.
  DATA: LT_BDCMSG TYPE TABLE OF BDCMSGCOLL WITH HEADER LINE.
  DATA: LC_VBELN TYPE LIKP-VBELN,
        LV_LAST.

  CLEAR : GV_BELNR.

  CALL TRANSACTION 'FB08' USING  GT_BDCDATA
                           UPDATE 'S'
                           MODE   P_MODE
                           MESSAGES INTO LT_BDCMSG.

  IF SY-SUBRC EQ 0.
    IF SY-MSGTY EQ 'S'  AND
       SY-MSGID EQ 'F5' AND
       SY-MSGNO EQ '312'.
      LOOP AT LT_BDCMSG WHERE MSGTYP EQ 'S'
                          AND MSGID EQ 'F5'
                          AND MSGNR EQ '312'.
        GV_BELNR = LT_BDCMSG-MSGV1.
      ENDLOOP.
    ENDIF.
  ENDIF.

  LOOP AT LT_BDCMSG.
    AT LAST.
      LV_LAST = 'X'.
    ENDAT.
    IF LV_LAST IS INITIAL.
      CASE LT_BDCMSG-MSGTYP.
        WHEN 'A' OR 'E' OR 'X'.
          CLEAR GT_BDCMSG.
          GT_BDCMSG-BELNR = GV_BELNR.
          GT_BDCMSG-UPDKZ = 'I'.
          MOVE-CORRESPONDING LT_BDCMSG TO GT_BDCMSG.
          APPEND GT_BDCMSG.
        WHEN 'W'.
          IF LT_BDCMSG-MSGNR NE '394'.
            CLEAR GT_BDCMSG.
            GT_BDCMSG-BELNR = GV_BELNR.
            GT_BDCMSG-UPDKZ = 'I'.
            MOVE-CORRESPONDING LT_BDCMSG TO GT_BDCMSG.
            APPEND GT_BDCMSG.
          ENDIF.
      ENDCASE.
    ELSE.
      CLEAR GT_BDCMSG.
      GT_BDCMSG-BELNR = GV_BELNR.
      GT_BDCMSG-UPDKZ = 'I'.
      MOVE-CORRESPONDING LT_BDCMSG TO GT_BDCMSG.
      APPEND GT_BDCMSG.
    ENDIF.
  ENDLOOP.

** CBO테이블 관리.
** 지급전표 생성여부 Check.
  CHECK NOT GV_BELNR IS INITIAL  AND
            GV_BELNR+0(2) EQ '14'.    " 취소전표번호의 Number Range

  IF  GV_UCOMM  =  'FB08'.     " 지급전표취소

    DELETE
      FROM  ZSD0017T
     WHERE  BELNR2  =  G_ITEM_T-BELNR2.

  ELSEIF  GV_UCOMM  =  'FB08_2'.     " 부가세지급전표취소

    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
      EXPORTING
        INPUT  = G_ITEM_T-KNUMA
      IMPORTING
        OUTPUT = G_ITEM_T-KNUMA.

    UPDATE  ZSD0017T
       SET  BUGA_BELNR  =  SPACE
            BUGA_AMNT   =  0
            FBUDA_BELNR2 = SPACE
            AEDAT  =  SY-DATUM
            AENAM  =  SY-UNAME
     WHERE  KNUMA  =  G_ITEM_T-KNUMA
       AND  FBUDA  =  G_ITEM_T-FBUDA
       AND  VBELN  =  G_ITEM_T-VBELN
       AND  BELNR  =  G_ITEM_T-BELNR
       AND  VBELN2 =  G_ITEM_T-VBELN2
       AND  BELNR2 =  G_ITEM_T-BELNR2.

  ENDIF.

  IF  SY-SUBRC  EQ  0.
*      commit work.
    MESSAGE S000 WITH '저장을 완료하였습니다'.
  ELSE.
*      rollback work.
    MESSAGE S000 WITH '저장에 실패하였습니다'.
  ENDIF.

ENDFORM.                    " call_transaction_fb08
*&---------------------------------------------------------------------*
*&      Form  change_hkont
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM CHANGE_HKONT .

*  DATA : LS_KTOKD LIKE KNA1-KTOKD.
*  CLEAR: LS_KTOKD.
  DATA : LS_VTWEG LIKE KONA-VTWEG.
  CLEAR: LS_VTWEG.

*-[SRM2103-07506_S
  IF PA_VKORG = '3000'.
* 계약의 유통경로와 판매오더의 유통경로는 동일.
    SELECT SINGLE VTWEG
      INTO LS_VTWEG
*-> CCM : 17.10.2023 09:53:47 / ZLSGSD3
      FROM ZKONA  "Table 수정
*      FROM KONA
*<-
      WHERE KNUMA = G_ITEM_T-KNUMA.

    IF LS_VTWEG = '10'.
      C_HKONT = '6310317'.
    ELSE.
      C_HKONT = '6430101'.
    ENDIF.
  ELSE.
    C_HKONT = '6430101'.
  ENDIF.

* 기존 로직 주석 처리
*  IF PA_SPART+0(1) = '7'.
*
*    SELECT SINGLE KTOKD
*            INTO  LS_KTOKD
*            FROM  KNA1
*           WHERE  KUNNR = G_ITEM_T-BONEM.
*
*    IF LS_KTOKD = '0094'.
*      C_HKONT  = '6310317'.
*    ELSE.
*      C_HKONT  = '6430101'.
*    ENDIF.
*
*  ELSE.
*    C_HKONT  = '6430101'.
*  ENDIF.
*]-SRM2103-07506_E

ENDFORM.                    " change_hkont
*&---------------------------------------------------------------------*
*&      Form  execute_bdc_data_requ3
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM EXECUTE_BDC_DATA_REQU3 .

  CLEAR  GT_BDCMSG.
  REFRESH  GT_BDCMSG.

  CLEAR : G_TMP2_T, G_TMP2_T[].

  DATA : LV_CNT   TYPE I,
         LV_FLAG,
         LV_FLAG2,
         LV_KUNNR LIKE KNA1-KUNNR,
         LV_LIFNR LIKE KNA1-LIFNR.

  CLEAR : LV_CNT, LV_FLAG, LV_FLAG2.
  REFRESH  GT_BDCDATA.

  LOOP AT G_ITEM_T WHERE BOX = 'X'.

** 지급전표 생성 완료 된것
    IF  G_ITEM_T-LIGHTS EQ C_CLIGHT.
      LV_FLAG = 'X'.
*        exit.
    ENDIF.

** 부가세지급전표 생성 완료 된것
    IF  G_ITEM_T-LIGHTS EQ C_BLIGHT.
      LV_FLAG2 = 'X'.
*        exit.
    ENDIF.

    LV_CNT  =  LV_CNT  +  1.

  ENDLOOP.

  IF  LV_CNT  >  1  OR
      LV_CNT  =  0.
    MESSAGE E001(ZSD1) WITH '지급요청은 한건씩 처리됩니다.'.
  ENDIF.

  IF  LV_FLAG  =  'X'.
    MESSAGE E001(ZSD1) WITH '지급요청이 이미 처리되었습니다.'.
  ENDIF.

  IF  LV_FLAG2  =  'X'.
    MESSAGE E001(ZSD1) WITH '이미 부가세지급전표가 생성된 건입니다.'.
  ENDIF.

  READ TABLE G_ITEM_T WITH KEY BOX = 'X'.

  IF  G_ITEM_T-R_WRBTR  <=  0.
    MESSAGE E001(ZSD1) WITH '지급가능금액을 확인하세요.'.
  ENDIF.

  LOOP AT G_ITEM_T WHERE BOX = 'X'.

    CLEAR : LV_KUNNR, LV_LIFNR.

    SELECT  SINGLE KUNNR
      INTO  LV_KUNNR
      FROM  VBAK
     WHERE  VBELN  =  G_ITEM_T-VBELN.

    IF  SY-SUBRC  EQ  0.
      SELECT  SINGLE LIFNR
        INTO  LV_LIFNR
        FROM  KNA1
       WHERE  KUNNR = LV_KUNNR.
    ENDIF.

    SELECT  BELNR2
      INTO  CORRESPONDING FIELDS OF TABLE G_TMP2_T
      FROM  ZSD0017T
     WHERE  KNUMA  =  G_ITEM_T-KNUMA
       AND  FBUDA  =  G_ITEM_T-FBUDA
       AND  VBELN  =  G_ITEM_T-VBELN
       AND  BELNR  =  G_ITEM_T-BELNR.
*       and  vbeln2 =  g_item_t-vbeln2.


    SELECT SINGLE BUGA_BELNR2
      INTO LS_BUGA_BELNR2
      FROM  ZSD0017T
     WHERE  KNUMA  =  G_ITEM_T-KNUMA
       AND  FBUDA  =  G_ITEM_T-FBUDA
       AND  VBELN  =  G_ITEM_T-VBELN
       AND  BELNR  =  G_ITEM_T-BELNR.



    IF NOT LS_BUGA_BELNR2 IS INITIAL.
      MESSAGE E001(ZSD1) WITH '미지급부가세 전표가 있습니다.'.
    ENDIF.

** c_hkont 계정 결정 수정 written by choi seok won
    PERFORM CHANGE_HKONT.

    PERFORM CHECK_BDC_DATA_REQU3 USING LV_LIFNR.

  ENDLOOP.

  PERFORM CALL_MESSAGE_SCREEN.

ENDFORM.                    " execute_bdc_data_requ3
*&---------------------------------------------------------------------*
*&      Form  check_bdc_data_requ3
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_LV_LIFNR  text
*----------------------------------------------------------------------*
FORM CHECK_BDC_DATA_REQU3  USING    P_LIFNR.

  DATA : L_WRBTR     LIKE BSID-WRBTR,
         L_WRBTR2    LIKE BSID-WRBTR,
         L_SUM_WRBTR LIKE BSID-WRBTR.
  DATA : G_RETURN_CODE TYPE C.
  CLEAR : L_WRBTR, L_WRBTR2, L_SUM_WRBTR, G_RETURN_CODE.

** 지급요청의 마지막여부 Check.

** 해당 미지급전표의 미지급금액 Sum.
  SELECT  SUM( WRBTR )
    INTO  L_WRBTR
    FROM  ZSD0016T
   WHERE  KNUMA  =  G_ITEM_T-KNUMA
     AND  FBUDA  =  G_ITEM_T-FBUDA
     AND  VBELN  =  G_ITEM_T-VBELN
     AND  BELNR  =  G_ITEM_T-BELNR.

** 해당 미지급전표의 지급금액 Sum.
  SELECT  SUM( WRBTR )
    INTO  L_WRBTR2
    FROM  ZSD0017T
   WHERE  KNUMA  =  G_ITEM_T-KNUMA
     AND  FBUDA  =  G_ITEM_T-FBUDA
     AND  VBELN  =  G_ITEM_T-VBELN
     AND  BELNR  =  G_ITEM_T-BELNR.

  L_SUM_WRBTR  =  L_WRBTR  -  L_WRBTR2.

** Request by 송준호K : 2005-09-29
** 대체수취인(구매처)관련된 처리로직 추가.
*================================
  PERFORM  REPLACE_PROCESS_RTN.

  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
    EXPORTING
      INPUT  = G_H_EMPFK
    IMPORTING
      OUTPUT = G_H_EMPFK.
*================================


** Requested by 변상일K : 2007-07-26
*================================
  G_P_NETWR1 = G_ITEM_T-R_WRBTR.
  G_P_CURR   = G_ITEM_T-WAERS.

  PERFORM  REPLACE_R_WRBTR_RTN CHANGING G_RETURN_CODE.
*================================

  CHECK G_RETURN_CODE = 'X'.

** 계산된 금액과 지급가능금액이 같으면 마지막임.
  IF  L_SUM_WRBTR  =  G_ITEM_T-R_WRBTR.

    PERFORM FILL_FIELD_DATA_LAST USING P_LIFNR.
    PERFORM CALL_TRANSACTION_F-51.

  ELSE.

    PERFORM FILL_FIELD_DATA USING P_LIFNR.
    PERFORM CALL_TRANSACTION_F-51.

  ENDIF.

ENDFORM.                    " check_bdc_data_requ3
*&---------------------------------------------------------------------*
*&      Module  STATUS_5000  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE STATUS_5000 OUTPUT.

  SET PF-STATUS '5000'.
  SET TITLEBAR '5000'.

  READ TABLE G_ITEM_T WITH KEY BOX = 'X'.

ENDMODULE.                 " STATUS_5000  OUTPUT
