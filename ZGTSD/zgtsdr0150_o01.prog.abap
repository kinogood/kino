*&---------------------------------------------------------------------*
*& Include          ZGTSDR0150_O01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Module STATUS_0100 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE status_0100 OUTPUT.
 SET PF-STATUS 'S100'.
 SET TITLEBAR 'T100'.
ENDMODULE.
*&---------------------------------------------------------------------*
*& Module CLEAR_OKCODE OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE clear_okcode OUTPUT.
  CLEAR: OK_CODE.
ENDMODULE.
*&---------------------------------------------------------------------*
*& Module INIT_ALV OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE init_alv OUTPUT.
  CHECK G_CON IS NOT BOUND.
  G_CON = NEW CL_GUI_DOCKING_CONTAINER( SIDE = CL_GUI_DOCKING_CONTAINER=>DOCK_AT_LEFT
                                        EXTENSION = 3000
                                        DYNNR = '0100'
                                        REPID = SY-REPID ).
  G_ALV = NEW CL_GUI_ALV_GRID( I_PARENT = G_CON ).

  PERFORM SET_ALV.

ENDMODULE.
*&---------------------------------------------------------------------*
*& Form SET_ALV
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_alv .
  DATA: LS_LAYO TYPE LVC_S_LAYO,
        LT_FCAT TYPE LVC_T_FCAT.


  CHECK G_ALV IS  BOUND.

  PERFORM SET_LAYOUT CHANGING LS_LAYO.
  PERFORM SET_FCAT   CHANGING LT_FCAT.
  PERFORM SET_EVENT.

  G_ALV->SET_TABLE_FOR_FIRST_DISPLAY(
    EXPORTING
      i_save                        = 'U'                 " Save Layout
      i_default                     = 'X'              " Default Display Variant
      is_layout                     = LS_LAYO                 " Layout
    CHANGING
      it_outtab                     = GT_DATA                 " Output Table
      it_fieldcatalog               = LT_FCAT                 " Field Catalog
    EXCEPTIONS
      invalid_parameter_combination = 1                " Wrong Parameter
      program_error                 = 2                " Program Errors
      too_many_lines                = 3                " Too many Rows in Ready for Input Grid
      others                        = 4
  ).
  IF SY-SUBRC <> 0.
*   MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*     WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_LAYOUT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- LS_LAYO
*&---------------------------------------------------------------------*
FORM set_layout  CHANGING PS_LAYO TYPE LVC_S_LAYO.
  PS_LAYO-CWIDTH_OPT = 'X'.
  PS_LAYO-ZEBRA = 'X'.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_FCAT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- LT_FCAT
*&---------------------------------------------------------------------*
FORM set_fcat  CHANGING PT_FCAT TYPE LVC_T_FCAT.
  DEFINE _L_FCAT.
    <LS_FCAT>-COLTEXT     = &1.
    <LS_FCAT>-KEY         = &2.
    <LS_FCAT>-COL_POS     = &3.
    <LS_FCAT>-JUST        = &4.
    <LS_FCAT>-NO_ZERO     = &5.
    <LS_FCAT>-F4AVAILABL  = &6.
    <LS_FCAT>-OUTPUTLEN   = &7.
    <LS_FCAT>-HOTSPOT     = &8.
    <LS_FCAT>-CFIELDNAME  = &9.
  END-OF-DEFINITION.

  CL_SALV_TABLE=>FACTORY( IMPORTING R_SALV_TABLE   = DATA(LRF_SALV)
                          CHANGING  T_TABLE        = GT_DATA ).

  PT_FCAT = CL_SALV_CONTROLLER_METADATA=>GET_LVC_FIELDCATALOG(
              R_COLUMNS      = LRF_SALV->GET_COLUMNS( )
              R_AGGREGATIONS = LRF_SALV->GET_AGGREGATIONS( ) ).

  LOOP AT pt_fcat ASSIGNING FIELD-SYMBOL(<ls_fcat>).
    CASE <ls_fcat>-fieldname.
      WHEN 'VKBUR'.               _l_fcat TEXT-001 'X' '01' 'C' ' ' ' ' '10' ' ' ' '.
*      WHEN 'BEZEI'.               _l_fcat TEXT-002 ' ' '02' ' ' ' ' ' ' '10' ' ' ' '.
*      WHEN 'VKGRP'.               _l_fcat TEXT-003 'X' '03' ' ' ' ' ' ' '10' ' ' ' '.
*      WHEN 'BEZEI2'.              _l_fcat TEXT-004 ' ' '04' ' ' ' ' ' ' '10' ' ' ' '.
      WHEN 'KUNNR'.               _l_fcat TEXT-005 'X' '02' 'C' ' ' ' ' '10' 'X' ' '.
      WHEN 'NAME1'.               _l_fcat TEXT-006 ' ' '03' ' ' ' ' ' ' '10' ' ' ' '.
      WHEN 'ZPJNO'.               _l_fcat TEXT-007 'X' '04' 'C' ' ' ' ' '10' ' ' ' '.
      WHEN 'ZPTXT'.               _l_fcat TEXT-008 ' ' '05' ' ' ' ' ' ' '10' ' ' ' '.
      WHEN 'ZZJOB_TYPE'.          _l_fcat TEXT-027 'X' '06' 'C' ' ' ' ' '10' ' ' ' '.
      WHEN 'FLD_03'.              _l_fcat TEXT-028 ' ' '07' ' ' ' ' ' ' '10' ' ' ' '.
      WHEN 'JOB_NO'.              _l_fcat TEXT-009 'X' '08' 'C' ' ' ' ' '10' 'X' ' '.
      WHEN 'JOB_NAME'.            _l_fcat TEXT-010 ' ' '10' ' ' ' ' ' ' '10' ' ' ' '.
      WHEN 'VBELN'.               _l_fcat TEXT-011 'X' '11' 'C' ' ' ' ' '10' 'X' ' '.
*      WHEN 'SPART'.               _l_fcat TEXT-012 ' ' '12' ' ' ' ' ' ' '10' ' ' ' '.
*      WHEN 'VTEXT'.               _l_fcat TEXT-025 ' ' '12' ' ' ' ' ' ' '10' ' ' ' '.
*      WHEN 'LFDAT'.               _l_fcat TEXT-013 ' ' '13' ' ' ' ' ' ' '10' ' ' ' '.
      WHEN 'ZBCF'.                _l_fcat TEXT-014 ' ' '12' 'C' ' ' ' ' '10' ' ' ' '.
      WHEN 'NETWRT'.              _l_fcat TEXT-024 ' ' '13' ' ' 'X' ' ' '10' ' ' 'WAERK'.
      WHEN 'NETWR'.               _l_fcat TEXT-026 ' ' '14' ' ' 'X' ' ' '10' ' ' 'WAERK'.
      WHEN 'ROHCOST'.             _l_fcat TEXT-015 ' ' '15' ' ' 'X' ' ' '10' ' ' 'WAERK'.
      WHEN 'SUBCONCOST'.          _l_fcat TEXT-016 ' ' '16' ' ' 'X' ' ' '10' ' ' 'WAERK'.
      WHEN 'INSULCOST'.           _l_fcat TEXT-017 ' ' '17' ' ' 'X' ' ' '10' ' ' 'WAERK'.
      WHEN 'CONDPRDCOST'.         _l_fcat TEXT-018 ' ' '18' ' ' 'X' ' ' '10' ' ' 'WAERK'.
      WHEN 'ASSYCOST'.            _l_fcat TEXT-019 ' ' '19' ' ' 'X' ' ' '10' ' ' 'WAERK'.
      WHEN 'COGM'.                _l_fcat TEXT-020 ' ' '20' ' ' ' ' ' ' '10' ' ' 'WAERK'.
      WHEN 'CMAMT'.               _l_fcat TEXT-021 ' ' '21' ' ' ' ' ' ' '10' ' ' 'WAERK'.
      WHEN 'CMRTE'.               _l_fcat TEXT-022 ' ' '22' ' ' ' ' ' ' '10' ' ' ' '.
      WHEN 'WAERK'.               _l_fcat TEXT-023 ' ' '23' 'C' 'X' ' ' '10' ' ' ' '.
      WHEN OTHERS.        <ls_fcat>-NO_OUT = abap_on.
    ENDCASE.
  ENDLOOP.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_EVENT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_event .
  CREATE OBJECT LCL_RECEIVER.

  SET HANDLER: LCL_RECEIVER->ON_HOTSPOT FOR G_ALV.
ENDFORM.
