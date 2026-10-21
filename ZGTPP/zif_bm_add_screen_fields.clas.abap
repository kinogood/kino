class ZIF_BM_ADD_SCREEN_FIELDS definition
  public
  final
  create public .

public section.

  interfaces IF_BADI_INTERFACE .
  interfaces IF_BM_ADD_SCREEN_FIELDS .

  class-data GS_MCHA type MCHA .
  class-data GV_SKIP_PAI type XFELD .
  class-data GV_AKTYP type AKTYP .
protected section.
private section.
ENDCLASS.



CLASS ZIF_BM_ADD_SCREEN_FIELDS IMPLEMENTATION.


  METHOD IF_BM_ADD_SCREEN_FIELDS~AFTER_CUSTOM_SCREEN_PAI.

*** Data transfer from customer screen to batch data.
*** (ex. MCHA-ZZXXX, MCHA-ZZYYY and MCH1-ZZXXX, MCH1-ZZYYY)
*** Note: Customer append structures must be added in both MCHA and MCH1 tables.

*    MOVE gs_mcha TO es_mcha.

    CALL FUNCTION 'ZGTPP99_9901_PAI'
      IMPORTING
        ES_MCHA = ES_MCHA.

  ENDMETHOD.


  METHOD if_bm_add_screen_fields~before_custom_subscreen_pai.

    MOVE iv_skip_pai TO gv_skip_pai.
*  MOVE iv_ok_code  to gv_ok_code.


  ENDMETHOD.


  METHOD IF_BM_ADD_SCREEN_FIELDS~BEFORE_CUSTOM_SUBSCREEN_PBO.

*** Data transfer from batch data to customer screen.
*** (ex. MCHA-ZZDATS, MCHA-ZZCHAR and MCH1-ZZDATS, MCH1-ZZCHAR)
*** Note: Customer append structures must be added in both MCHA and MCH1 tables.

*    MOVE is_mcha  TO gs_mcha.
*    MOVE iv_aktyp TO gv_aktyp.

    IF SY-TCODE = 'MSC3N'.
      CALL FUNCTION 'ZGTPP99_9901_PBO'
        EXPORTING
          IS_MCHA  = IS_MCHA
          IV_AKTYP = 'A'.
    ELSE.
      CALL FUNCTION 'ZGTPP99_9901_PBO'
        EXPORTING
          IS_MCHA  = IS_MCHA
          IV_AKTYP = IV_AKTYP.
    ENDIF.

  ENDMETHOD.


  METHOD if_bm_add_screen_fields~check_data_changed.

*** Check if data was changed when additional fields come from custom table (ex. ZTAB)
*** Returning parameter CV_SAVE_CUST_DATA should be 'X' in case changes occurred.


*** Example ---------------------------------------------
*    DATA ls_ztab TYPE ztab.
*
*    SELECT SINGLE * FROM ztab
*                    INTO ls_ztab
*                    WHERE matnr = is_mcha-matnr AND
*                          charg = is_mcha-charg AND
*                          werks = is_mcha-werks.
*    IF sy-subrc <> 0.
*      "Entry does not exist
*      cv_save_cust_data = abap_true. "Save modifications
*    ELSE.
*      IF ls_ztab <> gs_ztab.
*        cv_save_cust_data = abap_true. "Save modifications
*      ELSE.
*        cv_save_cust_data = abap_false. "Do not save modifications
*      ENDIF.
*    ENDIF.
*** -----------------------------------------------------

  ENDMETHOD.


  METHOD if_bm_add_screen_fields~initialize_data.

*** Initialize global data defined in the BADI implementation

    CLEAR gs_mcha.
    "CLEAR gs_ztab. "In case the additional fields come from custom table

  ENDMETHOD.


  METHOD if_bm_add_screen_fields~read_data.

*** Read data from the database when additional fields come from custom table (ex. ZTAB)
*** A new attribute needs to created (ex. GS_ZTAB as static/public)
*** MATNR, CHARG, WERKS, LGORT are fields from the header of MSCxN transactions that could
*** be used to search on customer table (ex. ZTAB)


*** Example ---------------------------------------------
*  SELECT SINGLE * FROM ztab
*                  INTO gs_ztab
*                  WHERE matnr = iv_matnr AND
*                        charg = iv_charg.
*  IF sy-subrc <> 0.
*    "Entry does not exist
*  ENDIF.
*** -----------------------------------------------------

  ENDMETHOD.


  METHOD if_bm_add_screen_fields~save_data.

*** Save data in the database with an UPDATE TASK function module when additional fields come from custom table (ex. ZTAB)
*** A new attribute needs to be created (ex. GS_ZTAB as static/public)
*** Key fields from MCHA could be used here getting data from IS_MCHA



*** Example ---------------------------------------------
*    IF gs_ztab IS NOT INITIAL.
*
*      gs_ztab-matnr = is_mcha-matnr. "MCHA Key field
*      gs_ztab-charg = is_mcha-charg. "MCHA Key field
*      gs_ztab-werks = is_mcha-werks. "MCHA Key field
*
*      CALL FUNCTION 'Z_CUSTOMER_BATCH_SAVE' IN UPDATE TASK
*        EXPORTING
*          is_ztab = gs_ztab.
*    ENDIF.
*** -----------------------------------------------------


  ENDMETHOD.


  METHOD IF_BM_ADD_SCREEN_FIELDS~SET_TABSTRIP_NAME.

    IF SY-LANGU EQ '3'.
      EV_NAME = '추가필드'.
    ELSE.
      EV_NAME = 'AdditionalField'.
    ENDIF.

  ENDMETHOD.
ENDCLASS.
