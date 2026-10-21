"Name: \IC:FM07MEM0_MENGE_UMRECHNEN\EX:MENGE_UMRECHNEN_01\EI
ENHANCEMENT 0 ZEI_FM07MEM0_MENGE_UMRECHNEN.

  CHECK t158-trtyp = h AND NOT vm07m-xstor = zwei.

  "Factor batch 확인
  IF mseg-umwrk cp '6*'.
    select count(*)
      from marc
     where werks = mseg-werks
       and matnr = mseg-ummat
       and dpcbt = 'A'.
      IF sy-subrc = 0.
        "수량 환산 금지
        dm07m-xnocon = 'X'.
      ENDIF.
  ENDIF.

ENDENHANCEMENT.
