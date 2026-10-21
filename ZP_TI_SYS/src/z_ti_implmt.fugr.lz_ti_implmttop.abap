FUNCTION-POOL Z_TI_IMPLMT                MESSAGE-ID SV.


  INCLUDE LSVIMDAT                                . "general data decl.
  INCLUDE LZ_TI_IMPLMTT00                         . "view rel. data dcl.



TABLES: ttxit,
       *ttxit,
        t052.

*> Search Help용.
DATA : selectfield  LIKE help_info-fieldname,
       it_fields    LIKE help_value OCCURS 1 WITH HEADER LINE,
       select_value LIKE help_info-fldvalue,
       ld_tabix     LIKE sy-tabix.

DATA:  g_field(50),
       g_stepl      LIKE dynpread-stepl.

* 화면 필드 선언 -> 선택된 값을 화면 필드에 뿌려줄때 사용.
DATA:  scr_fields LIKE dynpread OCCURS 0 WITH HEADER LINE.
