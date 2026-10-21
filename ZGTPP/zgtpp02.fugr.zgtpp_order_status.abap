FUNCTION zgtpp_order_status.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(I_AUFNR) TYPE  AUFK-AUFNR OPTIONAL
*"  EXPORTING
*"     VALUE(E_STATUS) TYPE  CHAR100
*"----------------------------------------------------------------------
  DATA : lv_status(100).
  CLEAR lv_status.

  IF i_aufnr IS NOT INITIAL.

    SELECT SINGLE objnr
      INTO @DATA(lv_objnr)
      FROM aufk
      WHERE aufnr = @i_aufnr.

    SELECT c~txt04
      INTO TABLE @DATA(lt_jestx)
      FROM jest AS a
      INNER JOIN tj02 AS b
            ON a~stat = b~istat
      INNER JOIN tj02t AS c
            ON a~stat = c~istat
      WHERE a~objnr = @lv_objnr
        AND a~inact = @space
        AND b~nodis = @space
        AND c~spras = @sy-langu.

*** 260728 PAYO 상태 추가
    SELECT c~txt04
      APPENDING CORRESPONDING FIELDS OF TABLE @lt_jestx
      FROM jest AS a
      INNER JOIN tj30 AS b
            ON a~stat = b~ESTAT
           AND b~STSMA = 'PPGT0001'
      INNER JOIN tj30t AS c
            ON B~Estat = C~ESTAT
           AND B~STSMA = C~STSMA
      WHERE a~objnr = @lv_objnr
        AND a~inact = @space
*        AND b~nodis = @space
        AND c~spras = @sy-langu.
*** 260728 PAYO 상태 추가

    LOOP AT lt_jestx INTO DATA(ls_jestx) WHERE txt04 IS NOT INITIAL.

      IF ls_jestx-txt04+0(1) = 'E' OR ls_jestx-txt04+0(1) = 'S'.

      ELSE.

        IF lv_status IS INITIAL.
          lv_status = ls_jestx-txt04.
        ELSE.
          lv_status = |{ lv_status }/{ ls_jestx-txt04 }|.
        ENDIF.

      ENDIF.

    ENDLOOP.

    e_status = lv_status.

  ENDIF.


ENDFUNCTION.
