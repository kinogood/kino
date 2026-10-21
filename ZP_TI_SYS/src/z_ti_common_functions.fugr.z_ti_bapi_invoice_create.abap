FUNCTION z_ti_bapi_invoice_create.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(HEADERDATA) LIKE  BAPI_INCINV_CREATE_HEADER STRUCTURE
*"        BAPI_INCINV_CREATE_HEADER
*"     VALUE(ADDRESSDATA) LIKE  BAPI_INCINV_CREATE_ADDRESSDATA
*"       STRUCTURE  BAPI_INCINV_CREATE_ADDRESSDATA OPTIONAL
*"     VALUE(OILDATA) LIKE  BAPI_INCINV_CREATE_OIL STRUCTURE
*"        BAPI_INCINV_CREATE_OIL OPTIONAL
*"     VALUE(EMPFB) LIKE  RBKP-EMPFB OPTIONAL
*"     VALUE(BUPLA) LIKE  RBKP-BUPLA OPTIONAL
*"     VALUE(SIMULATION) LIKE  BOOLE-BOOLE DEFAULT SPACE
*"  EXPORTING
*"     VALUE(INVOICEDOCNUMBER) LIKE  BAPI_INCINV_FLD-INV_DOC_NO
*"     VALUE(FISCALYEAR) LIKE  BAPI_INCINV_FLD-FISC_YEAR
*"  TABLES
*"      ITEMDATA STRUCTURE  BAPI_INCINV_CREATE_ITEM
*"      ACCOUNTINGDATA STRUCTURE  BAPI_INCINV_CREATE_ACCOUNT OPTIONAL
*"      GLACCOUNTDATA STRUCTURE  BAPI_INCINV_CREATE_GL_ACCOUNT OPTIONAL
*"      MATERIALDATA STRUCTURE  BAPI_INCINV_CREATE_MATERIAL OPTIONAL
*"      TAXDATA STRUCTURE  BAPI_INCINV_CREATE_TAX OPTIONAL
*"      WITHTAXDATA STRUCTURE  BAPI_INCINV_CREATE_WITHTAX OPTIONAL
*"      VENDORITEMSPLITDATA STRUCTURE  BAPI_INCINV_CREATE_VENDORSPLIT
*"       OPTIONAL
*"      RETURN STRUCTURE  BAPIRET2 OPTIONAL
*"      EXTENSIONIN STRUCTURE  BAPIPAREX OPTIONAL
*"      TM_ITEMDATA STRUCTURE  BAPI_INCINV_CREATE_TM_ITEM OPTIONAL
*"      NFMETALLITMS STRUCTURE  /NFM/BAPIDOCITM OPTIONAL
*"      ASSETDATA STRUCTURE  BAPI_INCINV_DETAIL_ASSET OPTIONAL
*"----------------------------------------------------------------------
************************************************************************
*                                                                      *
* Title         : Z_TI_BAPI_INVOICE_CREATE                             *
*                                                                      *
* Description   : [Function] Invoice Verification: Post Invoice        *
*                 1) LIV BAPIs function Copy & Modification            *
*                 - BAPI_INCOMINGINVOICE_CREATE Function Copy          *
*                 - Payee/Payer Import parameter field add             *
*                 - Payee/Payer field move insert                      *
*                 - 사업장 Import parameter field add                  *
*                 - 사업장 field move insert                           *
*                 - SIMULATION Import parameter field add              *
*                 - SIMULATION 기능추가                                *
*                                                                      *
* Creation Date : 2003/08/19                                           *
*                                                                      *
* Author        : SeogBong, Kang                                       *
*                                                                      *
************************************************************************
*                                                                      *
* Inputs        :                                                      *
*                                                                      *
* Outputs       :                                                      *
*                                                                      *
************************************************************************
*                                                                      *
* Processing Steps:                                                    *
*                                                                      *
************************************************************************
*----------------------------------------------------------------------*
*                M O D I F I C A T I O N   L O G                       *
*----------------------------------------------------------------------*
* Date         Programmer       Transport#  Description                *
*----------------------------------------------------------------------*
* dd-mmm-yyyy  xxxxxxxxxxxxxxx  DA3K9xxxxx  xxxxxxxxxxxxxxxxxxxxxxxxx  *
*                                                                      *
*                                                                      *
************************************************************************

  DATA:
    tab_frseg      TYPE mmcr_tfrseg,  " item data for MRM_INVOICE_CREATE
    tab_co         TYPE mmcr_tcobl_mrm,    " direct posting G/L account
    i_simulation   LIKE  boole-boole,
    tab_ma         TYPE mmcr_tma,          " direct posting material
    s_rbkpv        TYPE mrm_rbkpv,    " header data for MRM_INVOICE_CREATE
    f_belnr        LIKE rbkp_v-belnr,      " doc number of created invoice
    f_gjahr        LIKE rbkp_v-gjahr,      " fiscal year of created invoice
    f_subrc        LIKE sy-subrc,          " return code
    tab_ivext_bapi TYPE mrm_tab_ivext, " extension data NCF KH
    tab_asset      TYPE mmcr_tcobl_mrm. "MRM ANLA

  CLEAR:
      return,
      i_simulation.
  REFRESH:
      return.

*---------------------------------------------------------------------*
*     F_SUBRC = 0 --> ok, go on                                       *
*     F_SUBRC = 4 --> error, go on                                    *
*     F_SUBRC = 8 --> error, no processing                            *
*---------------------------------------------------------------------*

*--------------------------------------------------------------------*
* adjustment for long material number
*--------------------------------------------------------------------*
  DATA: ls_return TYPE bapiret2,
        ls_fnames TYPE cl_matnr_chk_mapper=>ts_matnr_bapi_fnames,
        lt_fnames TYPE cl_matnr_chk_mapper=>tt_matnr_bapi_fname.

  ls_fnames-int  = 'MATERIAL'.
  ls_fnames-ext  = 'MATERIAL_EXTERNAL'.
  ls_fnames-vers = 'MATERIAL_VERSION'.
  ls_fnames-guid = 'MATERIAL_GUID'.
  ls_fnames-long = 'MATERIAL_LONG'.
  INSERT ls_fnames INTO TABLE lt_fnames.
  cl_matnr_chk_mapper=>bapi_tables_conv_tab(
    EXPORTING
      iv_int_to_external       =     abap_false
      it_fnames                =     lt_fnames
    CHANGING
      ct_matnr                 =     materialdata[]
    EXCEPTIONS
      OTHERS                   = 1
  ).

  IF sy-subrc <> 0.
    f_subrc = 8.
    PERFORM bapireturn_fill USING sy-msgid
                                  sy-msgty
                                  sy-msgno
                                  sy-msgv1
                                  sy-msgv1
                                  sy-msgv1
                                  sy-msgv1
                         CHANGING return[].

  ENDIF.
* End of adjustment for long material number

* ZAEHK prolongiation - COND_COND_LONG is filled from COND_COUNT
  lcl_mrm_zaehk_mapping=>adjust_cond_count_long(
    CHANGING
      ct_itemdata = itemdata[]
  ).

* Additional TM checks + mapping to PO                      "1529851
  IF cl_ops_switch_check=>mm_sfws_tm( ) = abap_true.        "{TM EhP5e
    lcl_mrm_tm_services=>check_tm(
      EXPORTING
        it_tm_itemdata  = tm_itemdata[]
        it_materialdata = materialdata[]
      CHANGING
        ct_itemdata     = itemdata[]
        cv_subrc        = f_subrc
        ct_return       = return[] ).

    lcl_mrm_data_check=>check_tm_itemdata_tdt_rita(
      EXPORTING
        i_headerdata  = headerdata
        t_tm_itemdata = tm_itemdata[]
      CHANGING
        te_return     = return[]
        e_subrc       = f_subrc ).
  ENDIF.

************************************************************************
* Description   : LIV BAPIs function Copy & Modification               *
*                 - BAPI_INCOMINGINVOICE_CREATE Function Copy          *
*                 - Payee/Payer Import parameter field add             *
*                 - Payee/Payer field move insert                      *
*                 - 사업장 Import parameter field add                  *
*                 - 사업장 field move insert                           *
************************************************************************
**-----> BEGIN of INSERT
  headerdata-payee_payer = empfb.
**-----> END   of INSERT

  lcl_mrm_data_check=>importing_data_check(     "MRM ANLA
         EXPORTING
           t_itemdata            = itemdata[]
           t_accountingdata      = accountingdata[]
           t_taxdata             = taxdata[]
           t_withtaxdata         = withtaxdata[]
           t_vendoritemsplitdata = vendoritemsplitdata[]
           t_glaccountdata       = glaccountdata[]
           t_materialdata        = materialdata[]
           t_assetdata           = assetdata[]
           i_headerdata          = headerdata
           i_addressdata         = addressdata
           i_rbstat_new          = c_rbstat_posted
           i_belnr               = invoicedocnumber
           i_gjahr               = fiscalyear
         CHANGING
           te_return             = return[]
           e_subrc               = f_subrc ).

  CHECK f_subrc < 8.

* call badi MRM_BAPI_MAPPING                                    "NCF KH
  PERFORM mapping_ivext_create(saplmrm_bapi) TABLES    itemdata
                                             USING     extensionin[]
                                                       headerdata
                                             CHANGING  tab_ivext_bapi.

  PERFORM rbkpv_fill(saplmrm_bapi)   TABLES    itemdata
                                     USING     headerdata
                                               addressdata
                                               c_rbstat_posted
                                     CHANGING  s_rbkpv
                                               return[]
                                               f_subrc.

************************************************************************
* Description   : LIV BAPIs function Copy & Modification               *
*                 - BAPI_INCOMINGINVOICE_CREATE Function Copy          *
*                 - Payee/Payer Import parameter field add             *
*                 - Payee/Payer field move insert                      *
*                 - 사업장 Import parameter field add                  *
*                 - 사업장 field move insert                           *
************************************************************************
**-----> BEGIN of INSERT
** ASEG 강석봉 사장님 수정사항 - ML오류관련
* 사업장통합 전표 구성을 위해 수동으로 넘겼던 사업장 정보를
* 자재원장 오류 발생으로 인하여 logic수정하였음 20060929
************************************************************************
*  MOVE   empfb       TO s_rbkpv-empfb.   ">Payee/Payer
*  MOVE   bupla       TO s_rbkpv-bupla.   ">사업장.
** end ASEG수정
**-----> END   of INSERT

  CHECK f_subrc < 8.

* Do a final check of QR IBAN before proceed
  TRY.
      CALL FUNCTION 'GLO_CH_QRIBAN_VALIDATION'
        EXPORTING
          iv_headerdata  = headerdata
          iv_addressdata = addressdata
        CHANGING
          c_rbkpv        = s_rbkpv
        EXCEPTIONS
          bapi_error     = 1
          OTHERS         = 2.
      IF sy-subrc <> 0.
        f_subrc = 8.
        PERFORM bapireturn_fill USING sy-msgid
                                      sy-msgty
                                      sy-msgno
                                      sy-msgv1
                                      sy-msgv2
                                      sy-msgv3
                                      sy-msgv4
                             CHANGING return[].
      ENDIF.
    CATCH cx_root.
  ENDTRY.

**  Start of changes by MMV for eSOA supplie invoice
  data: xek08bn type table of ek08bn,
        ls_ek08bn type ek08bn,
        item_amount like itemdata-item_amount,
        changed type c.
  if oildata is initial.

    CALL FUNCTION 'GET_SUP_INV_OILDATA_IN'
      CHANGING
        LV_OILDATA       = oildata-FILTERTYPE
              .
*    if not oildata-FILTERTYPE is initial
*      and not oildata-FILTERTYPE = 'ALL'.
*   loop at itemdata.
*    if itemdata-cond_type is initial.
*     if not itemdata-PO_NUMBER is initial
*        and not itemdata-po_item is initial.
*    call function 'ME_READ_COND_INVOICE'
*      exporting
*       I_EBELN              = itemdata-PO_NUMBER
*       I_EBELP               = itemdata-po_item
*       I_EKKI               = 'X'
*       I_LIFNR              = ' '
*     TABLES
*       XEK08BN              = xek08bn
*     EXCEPTIONS
*       ENQUEUE_FAILED       = 1
*       OTHERS               = 2
*              .
*    if sy-subrc = 0.
**    read table xek08bn index 1 into ls_ek08bn.
**    if sy-subrc = 0.
**      itemdata-cond_type = ls_ek08bn-KSCHL.
**      modify itemdata index sy-tabix.
**    endif.
*      item_amount = itemdata-item_amount.
*      loop at xek08bn into ls_ek08bn.
*        itemdata-cond_type = ls_ek08bn-kschl.
*        if not ls_ek08bn-netwr is initial.
*        if  item_amount >  ls_ek08bn-netwr.
*        item_amount = item_amount - ls_ek08bn-netwr.
*        itemdata-item_amount = ls_ek08bn-netwr.
*        else.
*          itemdata-item_amount = item_amount.
*          clear item_amount.
*        endif.
*         if sy-tabix = 1.
*          modify itemdata from itemdata.
*          clear itemdata-item_amount.
*         else.
*           append itemdata.
*           clear itemdata-item_amount.
*          endif.
*          endif.
*       endloop.
*    endif.
*   endif.
*  endif.
*endloop.
*delete itemdata where item_amount is initial.
*endif.
endif.
**End of changes by MMV
*  perform oi_rbkpv_fill(saplmrm_bapi) using oildata
*                                   changing s_rbkpv
*                                            return[]
*                                            f_subrc.

  CHECK f_subrc < 12.


  PERFORM frseg_fill(saplmrm_bapi)   TABLES    itemdata
                                               accountingdata
                                     USING     s_rbkpv-waers
                                               s_rbkpv-tbtkz "1097704
                                     CHANGING  tab_frseg[]
                                               return[]
                                               f_subrc.

  CHECK f_subrc < 8.

  PERFORM co_fill(saplmrm_bapi)      TABLES    glaccountdata
                                     USING     s_rbkpv-waers
                                               s_rbkpv-blart "1796950 start
                                               s_rbkpv-bldat
                                               s_rbkpv-budat
                                               s_rbkpv-kursf "1796950 end
                                     CHANGING  tab_co[]
                                               return[]
                                               f_subrc.

  CHECK f_subrc < 8.

  PERFORM ma_fill(saplmrm_bapi)      TABLES    materialdata
                                     USING     s_rbkpv-waers
                                     CHANGING  tab_ma[]
                                               return[]
                                               f_subrc.

  CHECK f_subrc < 8.

  PERFORM rbtx_fill(saplmrm_bapi)    TABLES    taxdata
                                               withtaxdata
                                               vendoritemsplitdata
                                     USING     s_rbkpv-waers
                                               s_rbkpv-bukrs
                                               headerdata
                                     CHANGING  s_rbkpv-rbtx[]
                                               s_rbkpv-h_rbws[]
                                               s_rbkpv-h_rbvs[]
                                               return[]
                                               f_subrc.

* Mapping for S/4 Extensibility
  PERFORM invoice_ext_fields_convert(saplmrm_bapi)
                                     USING  extensionin[]
                                     CHANGING s_rbkpv
                                              tab_co[]
                                              tab_frseg[]
                                              return[]
                                              f_subrc.

  CHECK f_subrc = 0.

*{   INSERT         KA5K059933                                        1
* /NFM/ processing - C5007732
* transfer NFM data to memory
  CALL FUNCTION '/NFM/CA_BAPI_TRANSFER_DOCITM'
    EXPORTING
      im_doc_type_nfm = 'R'
      im_comp_code    = headerdata-comp_code
    TABLES
      t_nfmetallitms  = nfmetallitms
      t_return        = return.
* check if error occurred
  LOOP AT return TRANSPORTING NO FIELDS
                    WHERE type = 'E' OR
                          type = 'A'.
    EXIT.
  ENDLOOP.

IF NOT headerdata-simulation IS INITIAL or                   "2071221
   NOT simulation IS INITIAL.
  i_simulation = 'X'.
ENDIF.

  IF sy-subrc <> 0.
*
*}   INSERT
*
************************************************************************
* Description   : LIV BAPIs function Copy & Modification               *
*                 - BAPI_INCOMINGINVOICE_CREATE Function Copy          *
*                 - SIMULATION Import parameter field add              *
*                 - SIMULATION 기능추가                                *
************************************************************************
**-----> BEGIN of INSERT
*    LOOP AT tab_frseg INTO ls_frseg.
**      ls_frseg-efkor = '1'.
*      ls_frseg-efkor = '3'.
**      ls_frseg-ok    = 'X'.
*      MODIFY tab_frseg FROM ls_frseg.
*    ENDLOOP.

  lcl_mrm_utilities=>mrm_invoice_create_call(                      "MRM ANLA
     EXPORTING
         i_rbkpv       = s_rbkpv
         i_simulation  = i_simulation
         i_rbstat_new  = c_rbstat_posted
         i_stgrd       = space
         ti_ivext_bapi = tab_ivext_bapi
         ti_co         = tab_co
         ti_ma         = tab_ma
         it_asset      = tab_asset
      CHANGING
         ti_frseg      = tab_frseg
         e_belnr       = invoicedocnumber
         e_gjahr       = fiscalyear
         e_subrc       = f_subrc
         te_return     = return[] ).

* /NFM/ processing - C5007732
* /NFM/ outbound mapping (internal tables -> BAPI interface)
    CALL FUNCTION '/NFM/CA_BAPI_DOCITM_GET'
      TABLES
        t_nfmetallitms = nfmetallitms.
  ENDIF.                             "sy-subrc <> 0.

* Remove itemdata                                           "{TM EhP5e
  IF  cl_ops_switch_check=>mm_sfws_tm( ) = abap_true        "1529851
  AND lines( tm_itemdata ) > 0.
    REFRESH itemdata.
  ENDIF.                                                    "}TM EhP5e

*--------------------------------------------------------------------*
* adjustment for long material number
*--------------------------------------------------------------------*
  cl_matnr_chk_mapper=>bapi_tables_conv_tab( EXPORTING  iv_int_to_external       = abap_true
                                                        it_fnames                = lt_fnames
                                             CHANGING   ct_matnr                 = materialdata[]
                                             EXCEPTIONS OTHERS                   = 1 ).
  IF sy-subrc <> 0.
    f_subrc = 8.
    PERFORM bapireturn_fill USING sy-msgid
                                  sy-msgty
                                  sy-msgno
                                  sy-msgv1
                                  sy-msgv1
                                  sy-msgv1
                                  sy-msgv1
                         CHANGING return[].

  ENDIF.
* End of adjustment for long material number

ENDFUNCTION.
