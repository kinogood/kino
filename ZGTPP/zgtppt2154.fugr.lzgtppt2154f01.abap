*----------------------------------------------------------------------*
***INCLUDE LZGTPPT2154F01.
*----------------------------------------------------------------------*
FORM get_dgmat_t.

  SELECT SINGLE maktx
    INTO zgtppt2154-dgmat_t
    FROM makt
   WHERE matnr  EQ zgtppt2154-dgmat
     AND spras  EQ sy-langu.

ENDFORM.
