************************************************************************
* Title         :  ZTIR9000I00                                         *
*                                                                      *
* Description   : LIV Simulation Funciton용 PAI Include                *
*                                                                      *
* Creation Date : 2003/08/22                                           *
*                                                                      *
* Author        : Seog bong, Kang                                      *
*                 Copyright ⓒ ASEG Co., LTD. All rights reserved.     *
************************************************************************
*----------------------------------------------------------------------*
*                M O D I F I C A T I O N   L O G                       *
*----------------------------------------------------------------------*
* Date         Programmer       Transport#  Description                *
*----------------------------------------------------------------------*
* dd-mmm-yyyy  xxxxxxxxxxxxxxx  DVPK9xxxxx  xxxxxxxxxxxxxxxxxxxxxxxxx  *
*                                                                      *
*                                                                      *
*----------------------------------------------------------------------*


*&---------------------------------------------------------------------*
*&      Module  EXIT_BEARBEITEN  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE exit_bearbeiten INPUT.

  SET SCREEN 0. LEAVE SCREEN.

ENDMODULE.                 " EXIT_BEARBEITEN  INPUT
*&---------------------------------------------------------------------*
*&      Module  user_command_scr6000  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_scr6000 INPUT.

  CHECK ok-code NE space.
  CLEAR g_simulation.

  CASE ok-code.
*------- back ------------------------------------------------------*
    WHEN fcoback.  ">뒤로.
      CLEAR ok-code.
      SET SCREEN 0. LEAVE SCREEN.
    WHEN fcobu.    ">전기.
      SET SCREEN 0. LEAVE SCREEN.
    WHEN fcowaer.
*      CASE kursanz.
*        WHEN 1.
*          EXIT.
** If the invoice is simulated at least in two currencies -> screen 1250
*        WHEN OTHERS.
*          PERFORM call_dynpro USING '1250'.
*          PERFORM saldo_bestimmen USING kurstyp.
*      ENDCASE.

  ENDCASE.

*> F2 Funtion key Event시 해당 필드의 정보 display
  PERFORM  double_click_event.

ENDMODULE.                 " user_command_scr6000  INPUT
*&---------------------------------------------------------------------*
*&      Module  fcode_exit_scr6010  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE fcode_exit_scr6010 INPUT.

  LEAVE TO SCREEN 0.

ENDMODULE.                 " fcode_exit_scr6010  INPUT
*&---------------------------------------------------------------------*
*&      Module  check_cancel_fields  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE check_cancel_fields INPUT.

  CHECK ok-code EQ 'ZTIOKAY'.

  IF ztisscrcom-stgrd  IS INITIAL.
    PERFORM  no_input_check USING 'ZTISSCRCOM' 'STGRD'  c_error.
  ENDIF.

  SELECT SINGLE *
    FROM t041c
   WHERE stgrd   EQ ztisscrcom-stgrd.
  IF sy-subrc    EQ c_zero AND
     t041c-xabwd EQ c_true.
    IF ztisscrcom-cbudat IS INITIAL.
      PERFORM  no_input_check USING 'ZTISSCRCOM' 'CBUDAT' c_error.
    ENDIF.
  ENDIF.

ENDMODULE.                 " check_cancel_fields  INPUT
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_scr6010  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_scr6010 INPUT.

  CASE ok-code.
    WHEN 'ZTIDISDOC'.
      PERFORM display_liv_document  USING  ztisscrcom-belnr
                                           ztisscrcom-gjahr
                                           ztisscrcom-bukrs.
    WHEN 'ZTIOKAY'.
      LEAVE TO SCREEN 0.
    WHEN 'ZTICANCEL'.
      LEAVE TO SCREEN 0.
    WHEN OTHERS.
  ENDCASE.

*> F2 Funtion key Event시 해당 필드의 정보 display
  PERFORM  double_click_event.

  CLEAR: ok-code.

ENDMODULE.                 " USER_COMMAND_scr6010  INPUT
