FUNCTION z_ti_calc_customs_payment_date.
*"----------------------------------------------------------------------
*"*"Local interface:
*"  CHANGING
*"     VALUE(CH_ZTITCCK) LIKE  ZTITCCK STRUCTURE  ZTITCCK OPTIONAL
*"----------------------------------------------------------------------
  DATA: l_day(2)   TYPE   N.

  SELECT SINGLE *
    FROM t001w
   WHERE werks EQ ch_ztitcck-werks.
  IF sy-subrc NE 0.
    t001w-fabkl = 'KR'.
  ENDIF.

  IF NOT ch_ztitcck-cdrdt IS INITIAL.
**ZTITCCK-PAYDA
    CASE ch_ztitcck-carty.
      WHEN '43'.
        ch_ztitcck-payda = ch_ztitcck-cdrdt + 15.

        CALL FUNCTION 'END_OF_MONTH_DETERMINE'
          EXPORTING
            datum = ch_ztitcck-payda
          IMPORTING
            tt    = l_day.

        MOVE: l_day TO ch_ztitcck-payda+6(2).

        ch_ztitcck-payda = ch_ztitcck-payda + 1.

        CALL FUNCTION 'Z_TS_GET_NEXT_WORKING_DATE'
          EXPORTING
            im_factory_calendar = t001w-fabkl
            im_date             = ch_ztitcck-payda
            im_day              = -1
          IMPORTING
            ex_date             = ch_ztitcck-payda. "납부예정일.

      WHEN OTHERS.
        CALL FUNCTION 'Z_TS_GET_NEXT_WORKING_DATE'
          EXPORTING
            im_factory_calendar = t001w-fabkl
            im_date             = ch_ztitcck-cdrdt
            im_day              = 15
          IMPORTING
            ex_date             = ch_ztitcck-payda. "납부예정일.

    ENDCASE.


  ENDIF.


ENDFUNCTION.
