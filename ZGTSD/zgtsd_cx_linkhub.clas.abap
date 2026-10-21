class ZGTSD_CX_LINKHUB definition
  public
  inheriting from CX_STATIC_CHECK
  final
  create public .

public section.

  data CODE type I read-only .
  data MESSAGE type STRING read-only .

  methods CONSTRUCTOR
    importing
      !TEXTID like TEXTID optional
      !PREVIOUS like PREVIOUS optional
      !CODE type I optional
      !MESSAGE type STRING optional .
protected section.
private section.
ENDCLASS.



CLASS ZGTSD_CX_LINKHUB IMPLEMENTATION.


  method CONSTRUCTOR.
CALL METHOD SUPER->CONSTRUCTOR
EXPORTING
TEXTID = TEXTID
PREVIOUS = PREVIOUS
.
me->CODE = CODE .
me->MESSAGE = MESSAGE .
  endmethod.
ENDCLASS.
