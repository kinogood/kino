*&---------------------------------------------------------------------*
*& Report ZGTTEST_002
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZGTTEST_002.

PARAMETERS: P_AUFNR LIKE AUFK-AUFNR OBLIGATORY.

*** Adding components to Production Order

DATA: LS_RETURN TYPE COXT_BAPIRETURN,
          LV_ERROR.

DATA: ls_storage_location  TYPE coxt_s_storage_location,
      ls_storage_locationx TYPE coxt_s_storage_locationx,
      ls_requ_quan         TYPE coxt_s_quantity,
      lv_operation         TYPE co_aplzl,
      lv_batch             TYPE coxt_batch,
      lv_batchx            TYPE coxt_batchx,
      lv_postp             TYPE postp,
      lv_sequence          TYPE plnfolge,
      lv_material          TYPE matnr,
      lv_positionno        TYPE positionno,
      lv_numc              TYPE numc4,
      lv_kdauf              TYPE COXT_KDAUF,
      lv_kdpos             TYPE COXT_KDPOS,
      lv_kdaufx ,
      lv_kdposx,
      lv_sobkz    TYPE sobkz,
      lv_sobkzx.

TYPES: BEGIN OF ty_resb_bt.
    INCLUDE TYPE resbb.
TYPES: indold     TYPE syst_tabix.
TYPES: no_req_upd TYPE syst_datar.
TYPES: END OF ty_resb_bt.

TYPES tt_resb_bt TYPE TABLE OF ty_resb_bt.

FIELD-SYMBOLS: <ft_resb_bt> TYPE tt_resb_bt,
               <fs_resb_bt> TYPE ty_resb_bt.

ls_storage_location-werks = '1306'.
ls_storage_locationx-werks = 'X'.

ls_storage_location-lgort = '2530'.
ls_storage_locationx-lgort = 'X'.

*lv_batch = '0000000001'.
*lv_batchx = 'X'.

ls_requ_quan-quantity = 1.
CALL FUNCTION 'UNIT_OF_MEASURE_ISO_TO_SAP'
  EXPORTING
    iso_code  = 'EA'
  IMPORTING
    sap_code  = ls_requ_quan-uom
  EXCEPTIONS
    not_found = 1
    OTHERS    = 2.
IF sy-subrc <> 0.
* Implement suitable error handling here
ENDIF.

lv_positionno = '0010'.
lv_postp = 'L'.
lv_material = '000000000006100505'.

SELECT SINGLE aufnr, aufpl INTO @DATA(ls_afko)
                               FROM afko
                               WHERE aufnr = @P_AUFNR.
IF sy-subrc EQ 0.
* Fetch operation to which it has to be assigned
  SELECT SINGLE aufpl, aplzl, plnfl INTO @DATA(ls_afvc)
                                    FROM afvc
                                    WHERE aufpl = @ls_afko-aufpl.
  IF sy-subrc EQ 0.
    lv_operation = ls_afvc-aplzl.
    lv_sequence = ls_afvc-plnfl.
  ENDIF.
ENDIF.

LV_SOBKZ = 'E'.
LV_SOBKZX = 'X'.
LV_KDAUF = '5111145766'.
LV_KDAUFX = 'X'.
LV_KDPOS = '3210'.
LV_KDPOSX = 'X'.

* BAPI to add components to Production Order
CALL FUNCTION 'CO_XT_COMPONENT_ADD'
  EXPORTING
    is_order_key         = P_AUFNR
    i_material           = lv_material
    is_requ_quan         = ls_requ_quan
    i_operation          = lv_operation
    i_sequence           = lv_sequence
    is_storage_location  = ls_storage_location
    is_storage_locationx = ls_storage_locationx
    i_batch              = lv_batch
    i_batchx             = lv_batchx
    i_postp              = lv_postp
    i_posno              = lv_positionno
    i_sobkz               = lv_sobkz
    i_sobkzx              = lv_sobkzx
    i_kdauf                = lv_kdauf
    i_kdaufx             = lv_kdaufx
    i_kdpos               = lv_kdpos
    i_kdposx             = lv_kdposx

  IMPORTING
    es_bapireturn        = ls_return
    e_error_occurred     = lv_error.
IF lv_error = space.
  CLEAR: lv_numc,
         ls_return.

* Modify POSNR via ASSIGN before DB update to correct the blank
* item number in Components due to incompatible types of I_POSNO
* (type CIF_R3RES-POSITIONNO) and RESB-POSNR
  ASSIGN ('(SAPLCOBC)RESB_BT[]') TO <ft_resb_bt>.
  LOOP AT <ft_resb_bt> ASSIGNING <fs_resb_bt>.
    lv_numc = sy-tabix * 10.
    <fs_resb_bt>-posnr = lv_numc.
    CLEAR lv_numc.
  ENDLOOP.

* Commit transaction
  CALL FUNCTION 'CO_XT_ORDER_PREPARE_COMMIT'
    IMPORTING
      es_bapireturn    = ls_return
      e_error_occurred = lv_error.

  IF ( ls_return-type = 'S' OR
     ls_return-type = 'W' OR
     ls_return-type = 'I' ) OR
     ls_return IS INITIAL.
* Commit data
    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'.
    CALL FUNCTION 'CO_XT_ORDER_INITIALIZE'.
  ELSE.
    CLEAR: lv_error,
           ls_return.
* Data Rollback
    CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
  ENDIF.
ELSE.
  CLEAR: lv_error,
         ls_return.
* Data Rollback
  CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
ENDIF.
