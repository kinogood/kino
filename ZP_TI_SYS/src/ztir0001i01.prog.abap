************************************************************************
* Title         :  ZTER6910I01                                         *
*                                                                      *
* Description   : T/T 미정리 리스트 관리 PAI Include                   *
*                                                                      *
* Creation Date : 2003/08/20                                           *
*                                                                      *
* Author        : Seog Bong, Kang                                      *
*                 Copyright ⓒ ASEG Co., LTD. All rights reserved.     *
************************************************************************
*&---------------------------------------------------------------------*
*&      Module  pai_scr2000  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE pai_scr2000 INPUT.

  CASE sy-ucomm.
    WHEN 'EXIT' OR 'CANC' OR 'BACK'.
      IF g_grid IS INITIAL.
        CALL METHOD g_grid->free.
      ENDIF.

      SET SCREEN 0.
      LEAVE SCREEN.
  ENDCASE.
  CLEAR: ok-code.

ENDMODULE.                 " pai_scr2000  INPUT
*&---------------------------------------------------------------------*
*&      Module  user_command_3000  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_3000 INPUT.

  CASE ok_code.
    WHEN 'ABBR'.
      SET SCREEN 0. LEAVE SCREEN.
    WHEN 'BU'.
      SET SCREEN 0. LEAVE SCREEN.
    WHEN OTHERS.
  ENDCASE.
  CLEAR:ok_code.

ENDMODULE.                 " user_command_3000  INPUT
*&---------------------------------------------------------------------*
*&      Module  pai_check_fields_scr3000  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE pai_check_fields_scr3000 INPUT.

  CHECK ok_code NE 'ABBR'.

*> 회사코드.
  IF ztisig04-bukrs IS INITIAL.
    PERFORM no_input_check(ztir0000) USING :
                                            'ZTISIG04' 'BUKRS' 'E'.
  ELSE.
    SELECT SINGLE *
      FROM t001
     WHERE bukrs EQ ztisig04-bukrs.
  ENDIF.

  IF ztisig04-lifnr IS INITIAL.
    PERFORM no_input_check(ztir0000) USING :
                                            'ZTISIG04' 'LIFNR' 'E'.
  ELSE.
    SELECT SINGLE name1
      INTO g_lifnrnm
      FROM lfa1
     WHERE lifnr EQ ztisig04-lifnr .

  ENDIF.

  IF ztisig04-waers IS INITIAL.
    PERFORM no_input_check(ztir0000) USING :
                                            'ZTISIG04' 'WAERS' 'E'.
  ENDIF.

*  IF ztisig04-tbbcd IS INITIAL.
*    PERFORM no_input_check(ztir0000) USING :
*                                            'ZTISIG04' 'TBBCD' 'E'.
*  ENDIF.
  IF ztisig04-tbbnm IS INITIAL.
    PERFORM no_input_check(ztir0000) USING :
                                            'ZTISIG04' 'TBBNM' 'E'.
  ENDIF.
  IF ztisig04-tbbbr IS INITIAL.
    PERFORM no_input_check(ztir0000) USING :
                                            'ZTISIG04' 'TBBBR' 'E'.
  ENDIF.
  IF ztisig04-tbban IS INITIAL.
    PERFORM no_input_check(ztir0000) USING :
                                            'ZTISIG04' 'TBBAN' 'E'.
  ENDIF.

*-- 구매처명이 변경되는 경우에 대비하여 무조건 최신 구매처명을 반영하도록 함
*  IF ztisig04-tbbam IS INITIAL.
    ztisig04-tbbam = g_lifnrnm.
*    PERFORM no_input_check(ztir0000) USING :
*                                            'ZTISIG04' 'TBBAM' 'E'.
*  ENDIF.
  IF ztisig04-tbbad2 IS INITIAL.
    PERFORM no_input_check(ztir0000) USING :
                                            'ZTISIG04' 'TBBAD2' 'E'.
  ENDIF.
  IF ztisig04-tbbad3 IS INITIAL.
    PERFORM no_input_check(ztir0000) USING :
                                            'ZTISIG04' 'TBBAD3' 'E'.
  ENDIF.
  IF ztisig04-tbbao IS INITIAL.
    PERFORM no_input_check(ztir0000) USING :
                                            'ZTISIG04' 'TBBAO' 'E'.
  ELSE.
    SELECT SINGLE landx50
      INTO g_landx
      FROM t005t
     WHERE land1 EQ ztisig04-tbbao
       AND spras EQ 'E'.
    IF sy-subrc NE 0.
      PERFORM no_input_check(ztir0000) USING :
                                              'ZTISIG04' 'TBBAO' 'E'.
    ENDIF.
  ENDIF.

*  IF NOT ztisig04-tibao IS INITIAL.
*    SELECT SINGLE landx50
*      INTO g_landy
*      FROM t005t
*     WHERE land1 EQ ztisig04-tibao
*       AND spras EQ 'E'.
*  ENDIF.

  IF ztisig04-cnam IS INITIAL.
    MOVE: sy-uname TO ztisig04-cnam,
          sy-datlo TO ztisig04-cdat,
          sy-timlo TO ztisig04-ctme.
  ENDIF.

  IF g_mode NE 'S'.
    MOVE: sy-uname TO ztisig04-unam,
          sy-datlo TO ztisig04-udat,
          sy-timlo TO ztisig04-utme.
  ENDIF.

  IF ztisig04-apvyn IS INITIAL.
    ztisig04-apvyn = 'A'.
  ENDIF.

ENDMODULE.                 " pai_check_fields_scr3000  INPUT
