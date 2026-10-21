FUNCTION z_ti_calc_customs_charges.
*"----------------------------------------------------------------------
*"*"Local interface:
*"  CHANGING
*"     VALUE(CH_ZTITCRK) LIKE  ZTITCRK STRUCTURE  ZTITCRK OPTIONAL
*"----------------------------------------------------------------------

  CHECK NOT ch_ztitcrk-state IS INITIAL.

*> B/L HEADER SELECT.
  SELECT SINGLE *
    FROM ztitblk
   WHERE iblno EQ ch_ztitcrk-iblno.

*>> 통관수수료 COMPUTE.
  CLEAR  : ztstig8.
  SELECT SINGLE *
    FROM ztstig8
   WHERE bukrs     EQ   ch_ztitcrk-bukrs
     AND csaty     EQ   ch_ztitcrk-csaty
     AND cipty     EQ   ch_ztitcrk-cipty
     AND epart     EQ   ch_ztitcrk-state
     AND gdatu     EQ   ( SELECT MAX( gdatu )
                           FROM ztstig8
                          WHERE bukrs     EQ   ch_ztitcrk-bukrs
                            AND csaty     EQ   ch_ztitcrk-csaty
                            AND cipty     EQ   ch_ztitcrk-cipty
                            AND epart     EQ   ch_ztitcrk-state ).
  IF sy-subrc NE 0.
    SELECT *
      FROM ztstig8 UP TO 1 ROWS
     WHERE bukrs     EQ   ch_ztitcrk-bukrs
       AND epart     EQ   ch_ztitcrk-state
       AND gdatu     EQ   ( SELECT MAX( gdatu )
                             FROM ztstig8
                            WHERE bukrs     EQ   ch_ztitcrk-bukrs
                              AND epart     EQ   ch_ztitcrk-state ).
    ENDSELECT.
  ENDIF.

  CLEAR ch_ztitcrk-cchcg.

  IF sy-subrc EQ 0.
    IF ztstig8-fixam IS INITIAL.
      ch_ztitcrk-cchcg = ztstig8-crate * ch_ztitcrk-ccuak.

      IF ch_ztitcrk-cchcg < ztstig8-minam.
        MOVE ztstig8-minam TO ch_ztitcrk-cchcg.
      ENDIF.

      IF ch_ztitcrk-cchcg > ztstig8-maxam.
        MOVE ztstig8-maxam TO ch_ztitcrk-cchcg.
      ENDIF.

      ch_ztitcrk-cchcg = ch_ztitcrk-cchcg * 100.
      ch_ztitcrk-cchcg = TRUNC( ch_ztitcrk-cchcg / 10 ) * 10.
      ch_ztitcrk-cchcg = ch_ztitcrk-cchcg / 100.
    ELSE.
      ch_ztitcrk-cchcg = ztstig8-fixam.
    ENDIF.

*> 무환일 경우만.. 정액금액 적용함.
    IF ztitblk-bldty EQ 'S'.
      IF ztstig8-ndtam > 0.
        MOVE ztstig8-ndtam TO ch_ztitcrk-cchcg.
      ENDIF.
    ENDIF.
  ELSE.
    MESSAGE  s562.
  ENDIF.

ENDFUNCTION.
