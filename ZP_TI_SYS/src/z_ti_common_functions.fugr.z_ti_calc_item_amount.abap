FUNCTION Z_TI_CALC_ITEM_AMOUNT.
*"--------------------------------------------------------------------
*"*"로컬인터페이스:
*"       IMPORTING
*"             VALUE(PEINH) TYPE  PEINH DEFAULT 1
*"             VALUE(BPUMZ) TYPE  BPUMZ DEFAULT 1
*"             VALUE(BPUMN) TYPE  BPUMN DEFAULT 1
*"             VALUE(MENGE) TYPE  MENGE_D
*"             VALUE(NETPR) TYPE  NETPR
*"       CHANGING
*"             REFERENCE(NETWR) TYPE  NETWR
*"--------------------------------------------------------------------
  CLEAR : netwr.

  IF peinh EQ 0.
    peinh = 1.
  ENDIF.

  IF bpumz EQ 0.
    bpumz = 1.
  ENDIF.
  IF bpumn EQ 0.
    bpumn = 1.
  ENDIF.

  netwr = ( menge * ( netpr / peinh ) ) *
           ( bpumz / bpumn ).

ENDFUNCTION.
