************************************************************************
* Title         :  ZTIR9000O00                                         *
*                                                                      *
* Description   : LIV Simulation Funciton용 PBO Include                *
*                                                                      *
* Creation Date : 2004/02/22                                           *
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
*&      Module  pbo_STATUS_6000  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE pbo_status_6000 OUTPUT.

  REFRESH excl.
  IF kursanz = 1.
    MOVE fcowaer TO excl-funktion.
    APPEND excl.
  ENDIF.
  IF rm08r-saldo NE 0.
    MOVE fcobu TO excl-funktion.
    APPEND excl.
    MOVE fcowaer TO excl-funktion.
    APPEND excl.
    MOVE fcocomp TO excl-funktion.
    APPEND excl.
  ENDIF.

  IF rbkpv-rbstat = c_rbstat_parked OR
     rbkpv-rbstat = c_rbstat_comple OR
     rbkpv-rbstat = c_rbstat_rele_pa.
    IF akt_typ = c_trtyp_h.
      MOVE fcobu TO excl-funktion.
      APPEND excl.
    ENDIF.
    SET PF-STATUS '6001' EXCLUDING excl.
  ELSE.
    SET PF-STATUS '6000' EXCLUDING excl.
  ENDIF.

  READ TABLE xcurr WITH KEY curtp = xacccr-curtp.
  SET TITLEBAR  'T6000' WITH xcurr-waers xcurr-curtp_text.

ENDMODULE.                 " pbo_STATUS_6000  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  TC_6000_PB_PREPARE  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE tc_6000_pb_prepare OUTPUT.

  DESCRIBE TABLE xaccit LINES tc_6000_pb-lines.

ENDMODULE.                 " TC_6000_PB_PREPARE  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  FILL_TC_6000_PB  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE fill_tc_6000_pb OUTPUT.

  PERFORM set_accit_fill.
  PERFORM set_acccr_fill.

ENDMODULE.                 " FILL_TC_6000_PB  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  MODIFY_SCREEN_SIMULATION  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE modify_screen_simulation OUTPUT.

  LOOP AT SCREEN.
    IF screen-name = 'ACCIT-EBELP'
      AND accit-ebelp IS INITIAL.
      screen-output = 0.
    ENDIF.
    IF screen-name = 'ACCIT-MENGE'
      AND accit-menge IS INITIAL.
      screen-output = 0.
    ENDIF.
    MODIFY SCREEN.
  ENDLOOP.

ENDMODULE.                 " MODIFY_SCREEN_SIMULATION  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  pbo_STATUS_6010  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE pbo_status_6010 OUTPUT.

  SET PF-STATUS '6010'.
  SET TITLEBAR  'T6010'.

ENDMODULE.                 " pbo_STATUS_6010  OUTPUT
