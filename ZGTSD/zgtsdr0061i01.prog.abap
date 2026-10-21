*&---------------------------------------------------------------------*
*&  Include           ZSDR1040I01                                      *
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  get_zpjno  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE get_zpjno INPUT.

  PERFORM get_zpjno_data.

ENDMODULE.                 " get_zpjno  INPUT
*&---------------------------------------------------------------------*
*&      Module  check_zpjno  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE check_zpjno INPUT.

  DATA: string_1_type(4) TYPE c.

** Changed by 김성진K
** 수동생성을 없애므로 밑에 Logic은 필요없음.
*  check r02 eq 'X'.
*
*  if sy-ucomm eq 'SAVE'.
*
*    if not gs_zsd0106t-zpjno(1) is initial.
*      call function 'NUMERIC_CHECK'
*        exporting
*          string_in = gs_zsd0106t-zpjno(1)
*        importing
*          htype     = string_1_type.
*
*
*      if string_1_type eq 'NUMC'.
*       message e001 with '수동생성일때 첫번째글자를 문자로 해야합니다.'
*.
*      endif.
*    endif.
*
**    clear : zsd0106t.
**    select single * from zsd0106t where zpjno = gs_zsd0106t-zpjno.
**    if sy-subrc eq 0.
**      message e001 with '동일한 프로젝트 번호가 존재합니다.'.
**    endif.
*
*  endif.

ENDMODULE.                 " check_zpjno  INPUT

*&---------------------------------------------------------------------*
*&      Module  text_query  INPUT
*&---------------------------------------------------------------------*
*  판매처명 Query
*----------------------------------------------------------------------*
MODULE text_query INPUT.

  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
    EXPORTING
      input  = gs_zsd0106t-kunnr
    IMPORTING
      output = gs_zsd0106t-kunnr.

** 해당 영업영역의 거래선을 입력했는지 Check.
  SELECT  SINGLE *
    FROM  knvv
   WHERE  kunnr  =  gs_zsd0106t-kunnr.
*     AND  SPART  =  P_SPART.

  IF  sy-subrc  <>  0.
    MESSAGE e001 WITH '영업영역에 맞는 거래선코드를 입력하세요.'.
  ENDIF.

  SELECT  SINGLE name1
    INTO  g_name1
    FROM  kna1
   WHERE  kunnr  =  gs_zsd0106t-kunnr.

  IF  sy-subrc  <>  0.
    MESSAGE w001 WITH '거래선코드를 확인하세요.'.
  ENDIF.

  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
    EXPORTING
      input  = gs_zsd0106t-kunnr
    IMPORTING
      output = gs_zsd0106t-kunnr.

ENDMODULE.                 " text_query  INPUT
*&---------------------------------------------------------------------*
*&      Module  TEXT_QUERY1  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE text_query1 INPUT.

  SELECT SINGLE vtext
    INTO g_name2
    FROM tspat
   WHERE spras = sy-langu
     AND spart = gs_zsd0106t-zspart.

  IF  sy-subrc <> 0.
    MESSAGE e001 WITH '제품군을 확인하세요.'.
  ENDIF.

ENDMODULE.                 " TEXT_QUERY1  INPUT
*&---------------------------------------------------------------------*
*&      Module  TEXT_QUERY2  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE text_query2 INPUT.

  SELECT SINGLE bezei
    INTO g_name3
    FROM tvkbt
   WHERE spras = sy-langu
     AND vkbur = gs_zsd0106t-zvkbur.

  IF  sy-subrc <> 0.
    MESSAGE e001 WITH '영업팀을 확인하세요.'.
  ENDIF.

ENDMODULE.                 " TEXT_QUERY2  INPUT
*&---------------------------------------------------------------------*
*&      Module  TEXT_QUERY3  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE text_query3 INPUT.

  SELECT SINGLE bezei
    INTO g_name4
    FROM tvgrt
   WHERE spras = sy-langu
     AND vkgrp = gs_zsd0106t-zvkgrp.

  IF  sy-subrc <> 0.
    MESSAGE e001 WITH '영업팀을 확인하세요.'.
  ENDIF.

ENDMODULE.                 " TEXT_QUERY3  INPUT
*&---------------------------------------------------------------------*
*&      Module  F4_PERNR  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE f4_pernr INPUT.

  DATA: lt_t527x    LIKE t527x OCCURS 0 WITH HEADER LINE.

  DATA : j TYPE i.

  DATA: BEGIN OF pov_per OCCURS 0,
          pernr LIKE zzpa0001-pernr,
          ename LIKE zzpa0001-ename,
          orgeh LIKE t527x-orgeh,
          orgtx LIKE t527x-orgtx,
        END OF pov_per.

  CLEAR   : fieldtab, valuetab, pov_per,j.
  REFRESH : fieldtab, valuetab, pov_per.

  SELECT pernr
         ename
         orgeh
    INTO CORRESPONDING FIELDS OF TABLE pov_per
    FROM zzpa0001
   WHERE begda <= sy-datum
     AND endda >= sy-datum
*     AND BUKRS =  P_BUKRS
     AND persg =  '1'.          "재직자
  SORT pov_per BY pernr.


  CLEAR   : lt_t527x.
  REFRESH : lt_t527x.

  SELECT *
    INTO CORRESPONDING FIELDS OF TABLE lt_t527x
    FROM t527x
     FOR ALL ENTRIES IN pov_per
   WHERE sprsl =  sy-langu
     AND orgeh =  pov_per-orgeh
     AND begda <= sy-datum
     AND endda >= sy-datum.

  LOOP AT pov_per.
    READ TABLE lt_t527x WITH KEY orgeh = pov_per-orgeh.
    IF sy-subrc = 0.
      pov_per-orgtx = lt_t527x-orgtx.
      MODIFY pov_per.
    ENDIF.
  ENDLOOP.

  fieldtab-tabname    = 'ZZPA0001'.
  fieldtab-fieldname  = 'PERNR'.
  fieldtab-selectflag = 'X'.
  APPEND fieldtab.

  fieldtab-tabname    = 'ZZPA0001'.
  fieldtab-fieldname  = 'ENAME'.
  fieldtab-selectflag = ' '.
  APPEND fieldtab.

  fieldtab-tabname    = 'T527X'.
  fieldtab-fieldname  = 'ORGTX'.
  fieldtab-selectflag = ' '.
  APPEND fieldtab.

  LOOP AT pov_per.
    valuetab-value = pov_per-pernr.
    APPEND valuetab.
    valuetab-value = pov_per-ename.
    APPEND valuetab.
    valuetab-value = pov_per-orgtx.
    APPEND valuetab.
  ENDLOOP.

  CALL FUNCTION 'HELP_VALUES_GET_WITH_TABLE_EXT'
    EXPORTING
      display       = ' '
    IMPORTING
      index         = j
    TABLES
      fields        = fieldtab
      select_values = i_help_vtab
      valuetab      = valuetab.

  IF j > 0.
    READ TABLE pov_per INDEX j.
    IF sy-subrc = 0.
      gs_zsd0106t-pernr = pov_per-pernr.
    ENDIF.
  ENDIF.



ENDMODULE.                 " F4_PERNR  INPUT
*&---------------------------------------------------------------------*
*&      Module  TEXT_QUERY4  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE text_query4 INPUT.

  IF NOT gs_zsd0106t-pernr IS INITIAL.
    SELECT SINGLE ename
      INTO (g_name5)
      FROM zzpa0001
     WHERE begda <= sy-datum
       AND endda >= sy-datum
       AND pernr =  gs_zsd0106t-pernr
       AND persg =  '1'.      "재직자

    IF sy-subrc <> 0.
      MESSAGE e001 WITH '존재하지 않는 사원입니다'.
    ENDIF.
  ELSE.
    CLEAR: g_name5.
  ENDIF.

ENDMODULE.                 " TEXT_QUERY4  INPUT
*&---------------------------------------------------------------------*
*&      Module  INPUT_POSID  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE input_posid INPUT.


  IF gs_zsd0106ta-posid IS NOT INITIAL.

    CLEAR : gs_zsd0106ta-ps_psp_pnr.

* CB-50001 -> CB500001
    CALL FUNCTION 'CONVERSION_EXIT_PROJN_INPUT'             "#EC EXISTS
      EXPORTING
        input  = gs_zsd0106ta-posid
      IMPORTING
        output = gs_zsd0106ta-posid.

    SELECT SINGLE pspnr posid
      INTO (gs_zsd0106ta-ps_psp_pnr, gs_zsd0106ta-posid)
      FROM prps
     WHERE posid = gs_zsd0106ta-posid.


    IF sy-subrc EQ 0.
* CB050001 -> CB-50001
      CALL FUNCTION 'CONVERSION_EXIT_PROJN_OUTPUT'
        EXPORTING
          input  = gs_zsd0106ta-posid
        IMPORTING
          output = gs_zsd0106ta-posid.
* PS_PS_PNR 번호로 들어오면 여기서 가져오기
    ELSE.
      SELECT SINGLE pspnr posid
        INTO (gs_zsd0106ta-ps_psp_pnr, gs_zsd0106ta-posid)
        FROM prps
       WHERE pspnr = gs_zsd0106ta-posid.
      IF sy-subrc EQ 0.
* CB050001 -> CB-50001
        CALL FUNCTION 'CONVERSION_EXIT_PROJN_OUTPUT'
          EXPORTING
            input  = gs_zsd0106ta-posid
          IMPORTING
            output = gs_zsd0106ta-posid.
      ELSE.
        MESSAGE e001 WITH '존재하지 WBS 요소입니다'.
      ENDIF.
    ENDIF.

  ELSE.
    CLEAR : gs_zsd0106ta-ps_psp_pnr, gs_zsd0106ta-posid.

  ENDIF.
*--------------------------------------------------------------------*
*
** 00000001 -> CB-050001
*  CALL FUNCTION 'CONVERSION_EXIT_KONPR_OUTPUT'              "#EC EXISTS
*       EXPORTING
*            INPUT  = GS_ZSD0106TA-POSID
*       IMPORTING
*            OUTPUT = GS_ZSD0106TA-POSID.
*
* CB-050001 -> 000000001
*    CALL FUNCTION 'CONVERSION_EXIT_KONPR_INPUT'
*      EXPORTING
*        INPUT  = GS_ZSD0106TA-POSID
*      IMPORTING
*        OUTPUT = GS_ZSD0106TA-POSID.
*--------------------------------------------------------------------*


ENDMODULE.                 " INPUT_POSID  INPUT
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  F4_POSID  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE f4_posid INPUT.


  DATA: lt_t134g  LIKE t134g OCCURS 0 WITH HEADER LINE. "사업영역

*  DATA : J TYPE I.

  DATA: BEGIN OF pov_wbs OCCURS 0,
*         PSPNR      LIKE PRPS-PSPNR,
          posid LIKE prps-posid,
          post1 LIKE prps-post1,
*         SPART      LIKE T134G-SPART,
*         GSBER      LIKE T134G-GSBER,
*         ORGEH      LIKE T527X-ORGEH,
*         ORGTX      LIKE T527X-ORGTX,
        END OF pov_wbs.

  CLEAR : pov_wbs, pov_wbs[].

  SELECT *
    INTO CORRESPONDING FIELDS OF TABLE pov_wbs
    FROM prps
    UP TO 1000 ROWS.


  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'  "테이블 possible entry
    EXPORTING
      retfield        = 'POSID'
      dynpprog        = sy-cprog
      dynpnr          = sy-dynnr
      dynprofield     = 'GS_ZSD0106TA-POSID'
      value_org       = 'S'
    TABLES
      value_tab       = pov_wbs
    EXCEPTIONS
      parameter_error = 1
      no_values_found = 2
      OTHERS          = 3.




ENDMODULE.                 " F4_POSID  INPUT
