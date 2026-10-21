*&---------------------------------------------------------------------*
*& Report ZGTTEST_001
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZGTTEST_001.

*** Deleting Components from Production Order

DATA: LS_RETURN TYPE COXT_BAPIRETURN.

PARAMETERS : P_AUFNR LIKE AUFK-AUFNR OBLIGATORY.

DATA: lt_resbkeys TYPE coxt_t_resbdel,
          lt_return   TYPE STANDARD TABLE OF bapiret2,
          lv_error    TYPE flag,
          lv_rsnum TYPE resb-rsnum.

* Fetch existing components of given Production Order
SELECT rsnum, rspos INTO TABLE @DATA(lt_resb)
                    FROM resb
                    WHERE aufnr = @P_AUFNR.  " Previously created order
IF sy-subrc EQ 0.
  lt_resbkeys = CORRESPONDING #( lt_resb ).
ENDIF.

*DATA: LV_OBJNR TYPE JSTO-OBJNR.
*
*CLEAR: LV_RSNUM, LV_OBJNR.
*SELECT SINGLE RSNUM
*     INTO @LV_RSNUM
*     FROM RESB
*   WHERE AUFNR = @P_AUFNR.
*
*SELECT SINGLE OBJNR
*     INTO @LV_OBJNR
*     FROM RESB
*   WHERE AUFNR = @P_AUFNR.
*
*
*  IF LV_RSNUM IS NOT INITIAL AND LV_OBJNR IS NOT INITIAL.
*    DELETE FROM RESB
*      WHERE RSNUM = LV_RSNUM .
*
*    IF SY-SUBRC = 0.
*
*      DELETE FROM JSTO
*      WHERE OBJNR = LV_OBJNR.
*
*      IF SY-SUBRC = 0.
*
*        DELETE FROM RSPSP
*        WHERE RSNUM = LV_RSNUM .
*
*        IF SY-SUBRC = 0.
*          COMMIT WORK.
*        ENDIF.
*      ENDIF.
*    ELSE.
*      ROLLBACK WORK.
*    ENDIF.
*
*  ENDIF.


IF NOT lt_resbkeys[] IS INITIAL.
* BAPI to delete the components of Production Order
  CALL FUNCTION 'CO_XT_COMPONENTS_DELETE'
    EXPORTING
      it_resbkeys_to_delete = lt_resbkeys
    IMPORTING
      e_error_occurred      = lv_error
    TABLES
      ct_bapireturn         = lt_return
    EXCEPTIONS
      delete_failed         = 1
      OTHERS                = 2.

  CALL FUNCTION 'CO_IT_SET_FLG_ITAB_NEW'.
  IF lv_error = space.
    CALL FUNCTION 'CO_XT_ORDER_PREPARE_COMMIT'
      IMPORTING
        es_bapireturn    = ls_return
        e_error_occurred = lv_error.
    IF ( ls_return-type = 'S' OR
         ls_return-type = 'W' OR
         ls_return-type = 'I' ) OR
         ls_return IS INITIAL.
*      CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'.
*      CALL FUNCTION 'CO_XT_ORDER_INITIALIZE'.

        COMMIT WORK AND WAIT.

    ELSE.
      CLEAR: lv_error,
             ls_return.
      CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
    ENDIF.
  ELSE.
    CLEAR lv_error.
    CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
  ENDIF.
ENDIF.
