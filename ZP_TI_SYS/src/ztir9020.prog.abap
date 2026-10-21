************************************************************************
*                                                                      *
* Title         : ZTIR9020                                             *
*                                                                      *
* Description   : [Report] 수입물품 미착현황 Report                    *
*                                                                      *
* Creation Date : 2004/02/28                                           *
*                                                                      *
* Author        : SeogBong, Kang                                       *
*                 Copyright ⓒ ASEG Co., LTD. All rights reserved.     *
************************************************************************
*                                                                      *
* Inputs        :                                                      *
*                                                                      *
* Outputs       :                                                      *
*                                                                      *
************************************************************************
*                                                                      *
* Processing Steps:                                                    *
*   1.                                                                 *
*                                                                      *
************************************************************************
*----------------------------------------------------------------------*
*                M O D I F I C A T I O N   L O G                       *
*----------------------------------------------------------------------*
* Date         Programmer       Transport#  Description                *
*----------------------------------------------------------------------*
*                                                                      *
*                                                                      *
************************************************************************
PROGRAM   ztir9020
          MESSAGE-ID zmti00
          NO STANDARD PAGE HEADING.

************************************************************************
* TYPES and TYPE-POOLS                                                 *
************************************************************************
TYPE-POOLS: slis.   "> Globale Type(ALV)

************************************************************************
* SAP Tables                                                           *
************************************************************************
TABLES: t001,      ">Company Codes
        t001w,     ">Plants/Branches
        t001k,     ">Valuation area
        t161,      ">Purchasing Document Types
        t134,      ">Material Types
        t134t,     ">Material Types Descriptions
        t024d,     ">MRP controllers
        mara,      ">General Material Data
        marc,      ">Plant Data for Material
        mard,      ">Storage Location Data for Material
        mslb,      ">Special Stocks with Vendor
        mbew,      ">Material Valuation
        march,     ">Plant Data for Material: History
        mardh,     ">Storage Location Data for Material: History
        mslbh,     ">Special Stocks with Vendor: History
        mbewh,     ">Material Valuation: History
        mkpf,      ">Header: Material Document
        mseg,      ">Document Segment: Material
        makt,      ">Material Descriptions
        marm,      ">Units of Measure for Material
        lfa1  ,    ">Vendor Master (General Section)
        lfb1  ,    ">Vendor Master (Company Code)
        t024e ,    ">Purchasing Organizations
        t024  ,    ">Purchasing Groups
        t163b ,    ">TEXT
        t163c ,    ">TEXT
        t685t ,    ">TEXT
        ekbz  ,    ">History per Purchasing Document: Delivery Costs
        ekbe  ,    ">History per Purchasing Document
        ekko,      ">Purchasing Document Header
        ekpo  ,    ">Purchasing Document Items
        ekkn,      ">Account Assignment in Purchasing Document
        dfies ,    ">DD Interface: Table Fields for DDIF_FIELDINFO_GET
        ztitrqk,  ">[Import] Document Header
        ztitrqp.  ">[Import] Document Items

************************************************************************
* User Include Define                                                  *
************************************************************************
** JS전선 회사코드 2007/04 KSH --------------------------------------
DATA: l_yn    type c.
INCLUDE zts_authorization_check. "AUTHORIZATION_CHECK
** JS전선 회사코드 2007/04 KSH --------------------------------------

************************************************************************
* CONSTANTS                                                            *
************************************************************************
CONSTANTS:
** JS전선 회사코드 2007/04 BY-MH.LEE -----------------
*    c_bukrs     LIKE t001-bukrs     VALUE '1000',   ">Company code
** JS전선 회사코드 2007/04 ---------------------------
    c_save(1)   TYPE  c             VALUE 'A'.


************************************************************************
* SELECT-OPTIONS / PARAMETERS                                          *
************************************************************************
SELECTION-SCREEN BEGIN OF BLOCK box1 WITH FRAME TITLE text-001.
SELECT-OPTIONS : s_bukrs  FOR t001-bukrs  ">Company code
                              NO-EXTENSION
                              NO INTERVALS
                              OBLIGATORY
                              MEMORY ID buk.
PARAMETERS:      p_budat  LIKE ekbe-budat   ">Posting date
                               OBLIGATORY.
SELECT-OPTIONS :
                 s_ekorg  FOR ekko-ekorg,  ">Purchase Organization
                 s_ekgrp  FOR ekko-ekgrp,  ">Purchase Group
                 s_ebeln  FOR ekko-ebeln,  ">Purchasing doc.
                 s_budat  FOR ekbe-budat   ">Posting date
                              NO-DISPLAY,
                 s_werks  FOR t001w-werks, ">Plant code
                 s_mtart  FOR mara-mtart,  ">Material type
                 s_matnr  FOR mara-matnr,  ">Material code
                 s_ebelp  FOR ekpo-ebelp,  ">Purchasing doc. items
                 s_lifnr  FOR ekko-lifnr,  ">Vendor
                 s_elikz  FOR ekpo-elikz,  ">"Delivery completed"
                 s_loekz  FOR ekpo-loekz.  ">Deletion indicator
SELECTION-SCREEN ULINE.
PARAMETERS:      p_delid  AS CHECKBOX    DEFAULT 'X'. ">
SELECTION-SCREEN ULINE.
PARAMETERS: p_full RADIOBUTTON GROUP ab1 DEFAULT 'X',
            p_list RADIOBUTTON GROUP ab1.
SELECTION-SCREEN ULINE.
PARAMETERS:      p_grp1   RADIOBUTTON GROUP grp1 DEFAULT 'X',
                 p_grp2   RADIOBUTTON GROUP grp1.
SELECTION-SCREEN END OF BLOCK box1.

*> Report variant
SELECTION-SCREEN: BEGIN OF BLOCK alv WITH FRAME TITLE text-003.
PARAMETERS: alv_def LIKE disvariant-variant.
SELECTION-SCREEN: END OF BLOCK alv.


************************************************************************
* Internal Tables                                                      *
************************************************************************
DATA: BEGIN OF organ OCCURS 0,
  werks LIKE t001w-werks,   "> Plant
  name1 LIKE t001w-name1,                                   "> Name1
  bwkey LIKE t001k-bwkey,   "> Valuation area
  bukrs LIKE t001k-bukrs,   "> Company code
  waers LIKE t001-waers,    "> Currency
END OF organ.

*>Material Valuation
DATA : BEGIN OF xitab OCCURS 0,
       mtart   LIKE mara-mtart,   ">Material Type
       mtbez   LIKE t134t-mtbez,
       werks   LIKE ekpo-werks,
       name1   LIKE t001w-name1,                            ">Name1
       lifnr   LIKE ekko-lifnr,
       name2   LIKE lfa1-name1,
       ebeln   LIKE ekko-ebeln,
       knumv   LIKE ekko-knumv,
       kalsm   LIKE ekko-kalsm,
       stafo   LIKE ekko-stafo,
       webre   LIKE ekpo-webre,
       ebelp   LIKE ekpo-ebelp,
       aufnr   LIKE ekkn-aufnr,
       matnr   LIKE ekpo-matnr,
       txz01   LIKE ekpo-txz01,
       waers   LIKE ekko-waers,
       hswae   LIKE ekbe-hswae,
       netwr   LIKE ekpo-netwr,
       brtwr   LIKE ekpo-brtwr,
       wrbtr   LIKE ekbe-wrbtr,
       dmbtr   LIKE ekbe-dmbtr,
       wemng   LIKE ekbes-wemng,
       remng   LIKE ekbes-remng,
       wewrt   LIKE ekbes-wewrt,  ">입고(현지통화)
       wewwr   LIKE ekbes-wewwr,  ">입고(외화)
       rewrt   LIKE ekbes-rewrt,  ">송장(현지통화)
       rewwr   LIKE ekbes-rewwr,  ">송장(외화).
       xmark   TYPE c,
       END   OF xitab.

DATA : BEGIN OF gs_main OCCURS 1.
        INCLUDE STRUCTURE xitab.
DATA:        dmb01   LIKE ekbe-dmbtr,
             dmb02   LIKE ekbe-dmbtr,
             dmb03   LIKE ekbe-dmbtr,
             dmb04   LIKE ekbe-dmbtr,
             dmb05   LIKE ekbe-dmbtr,
             dmb06   LIKE ekbe-dmbtr,
             dmb07   LIKE ekbe-dmbtr,
             dmb08   LIKE ekbe-dmbtr,
             dmb09   LIKE ekbe-dmbtr,
             dmb10   LIKE ekbe-dmbtr,
             dmb11   LIKE ekbe-dmbtr,
             dmb12   LIKE ekbe-dmbtr,
             dmb13   LIKE ekbe-dmbtr,
             dmb14   LIKE ekbe-dmbtr,
             dmb15   LIKE ekbe-dmbtr,
             dmb16   LIKE ekbe-dmbtr,
             dmb17   LIKE ekbe-dmbtr,
             dmb18   LIKE ekbe-dmbtr,
             dmb19   LIKE ekbe-dmbtr,
             dmb20   LIKE ekbe-dmbtr.
DATA:        wrb01   LIKE ekbe-wrbtr,
             wrb02   LIKE ekbe-wrbtr,
             wrb03   LIKE ekbe-wrbtr,
             wrb04   LIKE ekbe-wrbtr,
             wrb05   LIKE ekbe-wrbtr,
             wrb06   LIKE ekbe-wrbtr,
             wrb07   LIKE ekbe-wrbtr,
             wrb08   LIKE ekbe-wrbtr,
             wrb09   LIKE ekbe-wrbtr,
             wrb10   LIKE ekbe-wrbtr,
             wrb11   LIKE ekbe-wrbtr,
             wrb12   LIKE ekbe-wrbtr,
             wrb13   LIKE ekbe-wrbtr,
             wrb14   LIKE ekbe-wrbtr,
             wrb15   LIKE ekbe-wrbtr,
             wrb16   LIKE ekbe-wrbtr,
             wrb17   LIKE ekbe-wrbtr,
             wrb18   LIKE ekbe-wrbtr,
             wrb19   LIKE ekbe-wrbtr,
             wrb20   LIKE ekbe-wrbtr.
DATA:        color   TYPE slis_t_specialcol_alv,
     END   OF gs_main.
*> 자재 타입
DATA : BEGIN OF xt134t OCCURS 0,
       mtart           LIKE   t134t-mtart,
       mtbez           LIKE   t134t-mtbez.
DATA : END   OF xt134t.

*> 공급업체명
DATA : BEGIN OF xlfa1 OCCURS 0,
       lifnr           LIKE   lfa1-lifnr,
       name1           LIKE   lfa1-name1.
DATA : END   OF xlfa1.

*> CONDITION TYPE.
DATA: BEGIN OF xkschl OCCURS 0,
      kschl           LIKE   ekbz-kschl,
      vtext           LIKE   t685t-vtext,
      END   OF xkschl.

DATA BEGIN OF iekbe OCCURS 0.
        INCLUDE STRUCTURE ekbe.
DATA END OF iekbe.
DATA BEGIN OF iekbz OCCURS 0.
        INCLUDE STRUCTURE ekbz.
DATA END OF iekbz.

DATA BEGIN OF iekbes OCCURS 0.
        INCLUDE STRUCTURE ekbes.
DATA END OF iekbes.

DATA BEGIN OF iekbez OCCURS 0.
        INCLUDE STRUCTURE ekbez.
DATA END OF iekbez.

DATA BEGIN OF iekbnk OCCURS 0.
        INCLUDE STRUCTURE ekbnk.
DATA END OF iekbnk.

************************************************************************
* DATA Declarations                                                    *
************************************************************************
*---------------------------------------------------------------------
* Accumulators
*---------------------------------------------------------------------
*DATA:
*  BEGIN OF A,
*
*  END OF A.
*
*
*----------------------------------------------------------------------
* Switches
*----------------------------------------------------------------------
DATA: BEGIN OF fc_struct,
        tabname(7),
        fieldname(6),
        ref_tabname(29),
        ref_fieldname(6),
        no_out(1),
        cqindicator(1),
        cqfield(6),
      END OF fc_struct.

DATA: s_variant      LIKE  disvariant,
      s_var_usr      LIKE  disvariant.

*----------------------------------------------------------------------
* Work fields
*----------------------------------------------------------------------
DATA : gw_line       TYPE   i,             "Line counter
       gw_subrc      LIKE   sy-subrc,      "Return code
       gw_tabix      LIKE   sy-tabix,      "table index
       line1(3)      TYPE   n,             "LINE COUNT
       out_text(70)  TYPE   c,             "text field(display)
       g_err_mode    TYPE   c,
       line_cnt(02)  TYPE  n,
       last_cnt(02)  TYPE  n,
       last_cnt1(02) TYPE  n,
       field_name(20),
       field_name1(20).

* Global variables for handling ALV functionality
DATA: alv_keyinfo      TYPE slis_keyinfo_alv.
DATA: alv_variant      LIKE disvariant.
DATA: gs_layout        TYPE slis_layout_alv.
DATA: alv_repid        LIKE sy-repid.
DATA: alv_print        TYPE slis_print_alv.
DATA: st_sort          TYPE slis_sortinfo_alv.

DATA: t_alv_list       LIKE gs_main.

DATA: alv_detail_func(30).
DATA: fc       TYPE slis_t_fieldcat_alv,
      fc1      TYPE slis_t_fieldcat_alv,
      fcs      TYPE slis_fieldcat_alv,
      it_sort  TYPE slis_t_sortinfo_alv.

************************************************************************
* RANGES
************************************************************************
*RANGES:
*   XXXT FOR XXX-XXX OCCURS 1.

***********************************************************************
* FIELD-GROUPS
***********************************************************************
*FIELD-GROUPS:

***********************************************************************
* FIELD-SYMBOLS
***********************************************************************
FIELD-SYMBOLS: <fs>  TYPE ANY,
               <fsl> TYPE ANY,
               <fss> TYPE ANY.

FIELD-SYMBOLS: <gt_table> TYPE table.

************************************************************************
* MACRO DEFINE                                                         *
************************************************************************
DEFINE ac.
  clear:  fcs, fc_struct.
  fc_struct         = &1.
  fcs-tabname        = fc_struct-tabname.
  fcs-fieldname      = fc_struct-fieldname.
  fcs-ref_tabname    = fc_struct-ref_tabname.
  fcs-ref_fieldname  = fc_struct-ref_fieldname.
  fcs-no_out         = fc_struct-no_out.

  case fc_struct-cqindicator.
    when 'C'.
      fcs-cfieldname = fc_struct-cqfield.
    when 'Q'.
      fcs-qfieldname = fc_struct-cqfield.
  endcase.
  append fcs to fc.
END-OF-DEFINITION.

DEFINE ac_1.
  clear: fcs, fc_struct.
*  FC_STRUCT         = &1.
  fcs-tabname        = &1.
  fcs-fieldname      = &2.
  fcs-ref_tabname    = &3.
  fcs-ref_fieldname  = &4.
  fcs-no_out         = &5.

  case &6.
    when 'C'.
      fcs-cfieldname = &7.
    when 'Q'.
      fcs-qfieldname = &7.
  endcase.
  append fcs to fc.

END-OF-DEFINITION.

************************************************************************
*                                                                      *
* INITIALIZATION Event                                                 *
*                                                                      *
************************************************************************
INITIALIZATION.
  PERFORM  set_initial_data.
  PERFORM  set_alv_init.             ">Initialize ALV variable

************************************************************************
*                                                                      *
* AT SELECTION-SCREEN Events                                           *
*                                                                      *
************************************************************************
*>The layout determines the list format
AT SELECTION-SCREEN ON VALUE-REQUEST FOR alv_def.
  PERFORM exec_alv_f4.

AT SELECTION-SCREEN.
  PERFORM input_field_check.
  PERFORM alv_variant_check.
** JS전선 회사코드 2007/04 KSH --------------------------------------
*> AUTHORIZATION_CHECK
  PERFORM p1102_authorization_check USING s_bukrs-low.
** JS전선 회사코드 2007/04 KSH --------------------------------------

************************************************************************
*                                                                      *
* START-OF-SELECTION Event                                             *
*                                                                      *
************************************************************************
START-OF-SELECTION.
  PERFORM clearing_work_area.      ">Initialize internal table
  PERFORM read_organization_data.  ">get oranization data
*------------------------------------------------------
*> Get Import purchasing order
*------------------------------------------------------
  PERFORM  get_import_purchasing_order.
  CHECK g_err_mode NE 'Y'.

  PERFORM set_fieldcat_build.      ">Set ALV field category
  PERFORM create_dynamic_table.    ">
  PERFORM adjust_fieldcat.         ">Adjust ALV field category
  PERFORM get_data_for_display.    ">data select

************************************************************************
*                                                                      *
* END-OF-SELECTION Event                                               *
*                                                                      *
************************************************************************
END-OF-SELECTION.
  CHECK gw_line NE 0.
*>--------------------------------------------------------
*> PROGRESS INDICATOR DISPLAY.
*>  4.  LIST DISPLAY
*>--------------------------------------------------------
  line1 = 100.
  out_text = text-905.
  REPLACE '%99999%' WITH line1 INTO out_text.
  PERFORM set_progress_bar USING out_text line1.
  PERFORM set_colorize_build.       ">Set color
  PERFORM set_sort_field.           ">Set ALV sort fields
  PERFORM display_alv_list.         ">Call ALV Functions

************************************************************************
*                                                                      *
* TOP-OF-PAGE Event                                                    *
*                                                                      *
************************************************************************
TOP-OF-PAGE.

************************************************************************
*                                                                      *
* END-OF-PAGE Event                                                    *
*                                                                      *
************************************************************************
END-OF-PAGE.


************************************************************************
*                                                                      *
* TOP-OF-PAGE DURING LINE-SELECTION Event                              *
*                                                                      *
************************************************************************
TOP-OF-PAGE DURING LINE-SELECTION.


************************************************************************
*                                                                      *
* AT LINE-SELECTION Event                                              *
*                                                                      *
************************************************************************
AT LINE-SELECTION.


************************************************************************
*                                                                      *
* AT USER-COMMAND Event                                                *
*                                                                      *
************************************************************************
AT USER-COMMAND.


*eject
************************************************************************
*                                                                      *
* S U B R O U T I N E S                                                *
*                                                                      *
************************************************************************
*&---------------------------------------------------------------------*
*&      Form  SET_INITIAL_DATA
*&---------------------------------------------------------------------*
FORM set_initial_data.

  SET TITLEBAR 'T1000'.

** JS전선 회사코드 2007/04 BY-MH.LEE -----------------
*  FREE: s_bukrs.    CLEAR: s_bukrs.
*  s_bukrs-sign   = 'I'.
*  s_bukrs-option = 'EQ'.
*  s_bukrs-low    = c_bukrs.
*  APPEND s_bukrs.
** JS전선 회사코드 2007/04 ---------------------------

  FREE: p_budat.    CLEAR: p_budat.
  p_budat      = sy-datlo.
  p_budat+6(2) = '01'.

  CALL FUNCTION 'RP_LAST_DAY_OF_MONTHS'
    EXPORTING
      day_in            = p_budat
    IMPORTING
      last_day_of_month = p_budat
    EXCEPTIONS
      day_in_no_date    = 1
      OTHERS            = 2.
  IF sy-subrc NE 0.
    MESSAGE ID 'HRPADVE' TYPE 'E' NUMBER '013' WITH
    'RP_LAST_DAY_OF_MONTHS'.
  ENDIF.

  alv_repid = sy-repid.
  CLEAR s_variant.
  s_variant-report = sy-repid.

* Get default variant
  s_var_usr = s_variant.
  CALL FUNCTION 'REUSE_ALV_VARIANT_DEFAULT_GET'
    EXPORTING
      i_save     = c_save
    CHANGING
      cs_variant = s_var_usr
    EXCEPTIONS
      not_found  = 2.
  IF sy-subrc = 0.
    alv_def =  s_var_usr-variant.
  ENDIF.

ENDFORM.                    " SET_INITIAL_DATA

*&---------------------------------------------------------------------*
*&      Form  READ_ORGANIZATION_DATA
*&---------------------------------------------------------------------*
FORM read_organization_data.

  CLEAR: g_err_mode.

  line1    = 20.
  out_text = text-901.
  REPLACE '%99999%' WITH line1 INTO out_text.
  PERFORM set_progress_bar USING out_text line1.

* Get Plants, valuation areas and company codes.
  SELECT t001w~werks t001w~bwkey t001w~name1 t001k~bukrs t001~waers
    INTO CORRESPONDING FIELDS OF TABLE organ
    FROM ( t001w INNER JOIN t001k
           ON t001w~bwkey = t001k~bwkey )
           INNER JOIN t001
           ON t001k~bukrs EQ t001~bukrs
    WHERE t001w~werks IN s_werks
    AND   t001~bukrs  IN s_bukrs.
  IF sy-subrc NE 0.
    MESSAGE s912.     g_err_mode = 'Y'.   EXIT.
  ENDIF.

  SORT organ BY bukrs werks.

ENDFORM.                    " READ_ORGANIZATION_DATA
*&---------------------------------------------------------------------*
*&      Form  SET_PROGRESS_BAR
*&---------------------------------------------------------------------*
FORM set_progress_bar USING   text perc.

  CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
    EXPORTING
      percentage = perc
      text       = text.

ENDFORM.                    " SET_PROGRESS_BAR
*&---------------------------------------------------------------------*
*&      Form  INPUT_FIELD_CHECK
*&---------------------------------------------------------------------*
FORM input_field_check.

  DATA: l_bukrs   LIKE t001-bukrs,
        l_werks   LIKE t001w-werks,
        l_matnr   LIKE mara-matnr,
        l_mtart   LIKE t134-mtart,
        l_ebeln   LIKE ekko-ebeln,
        l_lifnr   LIKE lfa1-lifnr,
        l_ekorg   LIKE t024e-ekorg,
        l_ekgrp   LIKE t024-ekgrp.


* Company code
  SELECT bukrs INTO (l_bukrs)
               FROM t001 UP TO 1 ROWS WHERE bukrs IN s_bukrs.
  ENDSELECT.
  IF sy-subrc <> 0.
    PERFORM get_ftext(rddfie00) USING 'T001' 'BUKRS' sy-langu
                                CHANGING dfies gw_subrc.
    SET CURSOR FIELD 'S_BUKRS-LOW'.
    MESSAGE e348(m7) WITH dfies-scrtext_m.
  ENDIF.

* Plant
  READ TABLE s_bukrs INDEX 1 TRANSPORTING NO FIELDS.
  IF sy-subrc = 0.
    SELECT werks INTO (l_werks)
                 FROM t001w UP TO 1 ROWS WHERE werks IN s_werks.
    ENDSELECT.
    IF sy-subrc <> 0.
      PERFORM get_ftext(rddfie00) USING 'T001W' 'WERKS' sy-langu
                                  CHANGING dfies gw_subrc.
      SET CURSOR FIELD 'S_WERKS-LOW'.
      MESSAGE e348(m7) WITH dfies-scrtext_m.
    ENDIF.
  ENDIF.

* Material Type
  READ TABLE s_mtart INDEX 1 TRANSPORTING NO FIELDS.
  IF sy-subrc = 0.
    SELECT mtart INTO (l_mtart)
                 FROM t134 UP TO 1 ROWS WHERE mtart IN s_mtart.
    ENDSELECT.
    IF sy-subrc <> 0.
      PERFORM get_ftext(rddfie00) USING 'T134' 'MTART' sy-langu
                                  CHANGING dfies gw_subrc.
      SET CURSOR FIELD 'S_WERKS-LOW'.
      MESSAGE e348(m7) WITH dfies-scrtext_m.
    ENDIF.
  ENDIF.

* Material
  READ TABLE s_matnr INDEX 1 TRANSPORTING NO FIELDS.
  IF sy-subrc = 0.
    SELECT matnr INTO (l_matnr)
                 FROM mara UP TO 1 ROWS WHERE matnr IN s_matnr.
    ENDSELECT.
    IF sy-subrc <> 0.
      PERFORM get_ftext(rddfie00) USING 'MARA' 'MATNR' sy-langu
                                  CHANGING dfies gw_subrc.
      SET CURSOR FIELD 'S_MATNR-LOW'.
      MESSAGE e348(m7) WITH dfies-scrtext_m.
    ENDIF.
  ENDIF.

* Purchasing order
  READ TABLE s_ebeln INDEX 1 TRANSPORTING NO FIELDS.
  IF sy-subrc = 0.
    SELECT ebeln INTO (l_ebeln)
                 FROM ekko UP TO 1 ROWS WHERE ebeln IN s_ebeln.
    ENDSELECT.
    IF sy-subrc <> 0.
      PERFORM get_ftext(rddfie00) USING 'EKKO' 'EBELN' sy-langu
                                  CHANGING dfies gw_subrc.
      SET CURSOR FIELD 'S_EBELN-LOW'.
      MESSAGE e348(m7) WITH dfies-scrtext_m.
    ENDIF.

    READ TABLE s_ebelp INDEX 1 TRANSPORTING NO FIELDS.
    IF sy-subrc = 0.
      SELECT ebeln INTO (l_ebeln)
                   FROM ekpo UP TO 1 ROWS WHERE ebeln IN s_ebeln
                                          AND   ebelp IN s_ebelp.
      ENDSELECT.
      IF sy-subrc <> 0.
        PERFORM get_ftext(rddfie00) USING 'EKKO' 'EBELP' sy-langu
                                    CHANGING dfies gw_subrc.
        SET CURSOR FIELD 'S_EBELP-LOW'.
        MESSAGE e348(m7) WITH dfies-scrtext_m.
      ENDIF.
    ENDIF.
  ENDIF.

* Vendor
  READ TABLE s_lifnr INDEX 1 TRANSPORTING NO FIELDS.
  IF sy-subrc = 0.
    SELECT lifnr INTO (l_lifnr)
                 FROM lfb1 UP TO 1 ROWS WHERE lifnr IN s_lifnr
                                        AND   bukrs IN s_bukrs.
    ENDSELECT.
    IF sy-subrc <> 0.
      PERFORM get_ftext(rddfie00) USING 'LFA1' 'LIFNR' sy-langu
                                  CHANGING dfies gw_subrc.
      SET CURSOR FIELD 'S_LIFNR-LOW'.
      MESSAGE e348(m7) WITH dfies-scrtext_m.
    ENDIF.
  ENDIF.

* Purchase Organization
  READ TABLE s_ekorg INDEX 1 TRANSPORTING NO FIELDS.
  IF sy-subrc = 0.
    SELECT ekorg INTO (l_ekorg)
                 FROM t024e UP TO 1 ROWS WHERE ekorg IN s_ekorg.
    ENDSELECT.
    IF sy-subrc <> 0.
      PERFORM get_ftext(rddfie00) USING 'T024E' 'EKORG' sy-langu
                                  CHANGING dfies gw_subrc.
      SET CURSOR FIELD 'S_EKORG-LOW'.
      MESSAGE e348(m7) WITH dfies-scrtext_m.
    ENDIF.
  ENDIF.

* Purchase GROUP
  READ TABLE s_ekgrp INDEX 1 TRANSPORTING NO FIELDS.
  IF sy-subrc = 0.
    SELECT ekgrp INTO (l_ekgrp)
                 FROM t024 UP TO 1 ROWS WHERE ekgrp IN s_ekgrp.
    ENDSELECT.
    IF sy-subrc <> 0.
      PERFORM get_ftext(rddfie00) USING 'T024' 'EKGRP' sy-langu
                                  CHANGING dfies gw_subrc.
      SET CURSOR FIELD 'S_EKGRP-LOW'.
      MESSAGE e348(m7) WITH dfies-scrtext_m.
    ENDIF.
  ENDIF.

*>Posting date
  FREE: s_budat.    CLEAR: s_budat.
  s_budat-sign   = 'I'.
  s_budat-option = 'BT'.
  s_budat-low    = '00000000'.
  s_budat-high   = p_budat.
  APPEND s_budat.

ENDFORM.                    " INPUT_FIELD_CHECK
*&---------------------------------------------------------------------*
*&      Form  CLEARING_WORK_AREA
*&---------------------------------------------------------------------*
FORM clearing_work_area.

  FREE:  xitab,  organ, xkschl, xt134t, xlfa1.
  CLEAR: xitab,  organ, xkschl, xt134t, xlfa1.

  IF p_full EQ 'X'.
    alv_detail_func = 'REUSE_ALV_GRID_DISPLAY'.
  ELSE.
    alv_detail_func = 'REUSE_ALV_LIST_DISPLAY'.
  ENDIF.

ENDFORM.                    " CLEARING_WORK_AREA
*&---------------------------------------------------------------------*
*&      Form  GET_DATA_FOR_DISPLAY
*&---------------------------------------------------------------------*
FORM get_data_for_display.

  FIELD-SYMBOLS: <ls_table>.
  FIELD-SYMBOLS: <l_field1>.
  FIELD-SYMBOLS: <l_field2>.

  DATA: it_rsrange TYPE TABLE OF rsrange,
        ws_rsrange TYPE rsrange.

  DATA: l_wemng LIKE ekbes-wemng,
        l_remng LIKE ekbes-remng,
        l_wewrt LIKE ekbes-wewrt,
        l_arewr LIKE ekbes-arewr,
        l_rewrt LIKE ekbes-rewrt.

  ASSIGN LOCAL COPY OF INITIAL LINE OF <gt_table> TO <ls_table>.

  LOOP AT xitab.
    MOVE-CORRESPONDING xitab TO <ls_table>.
    IF NOT xitab-werks IS INITIAL.
      READ TABLE organ WITH KEY werks = xitab-werks BINARY SEARCH.
      IF sy-subrc EQ 0.
        ASSIGN COMPONENT 'NAME1' OF STRUCTURE
                                <ls_table> TO <l_field1>.
        ASSIGN COMPONENT 'HSWAE' OF STRUCTURE
                                <ls_table> TO <l_field2>.

        MOVE: organ-name1 TO <l_field1>,
              organ-waers TO <l_field2>.
      ENDIF.
    ENDIF.

    IF NOT xitab-mtart IS INITIAL.
      READ TABLE xt134t WITH KEY mtart = xitab-mtart.
      IF sy-subrc EQ 0.
        ASSIGN COMPONENT 'MTBEZ' OF STRUCTURE
                                <ls_table> TO <l_field1>.

        MOVE xt134t-mtbez TO <l_field1>.
      ENDIF.
    ELSE.
      ASSIGN COMPONENT 'MTART' OF STRUCTURE
                              <ls_table> TO <l_field1>.
      ASSIGN COMPONENT 'MTBEZ' OF STRUCTURE
                              <ls_table> TO <l_field2>.
      MOVE: space   TO  <l_field1>,
            space   TO  <l_field2>.
    ENDIF.

    IF NOT xitab-lifnr IS INITIAL.
"-> CCM : 2023.04.10 ZITCS4HDEV06 - sort 추가 작업.
      SORT xlfa1 by lifnr.
      READ TABLE xlfa1 WITH KEY lifnr = xitab-lifnr BINARY SEARCH.
      IF sy-subrc EQ 0.
        ASSIGN COMPONENT 'NAME2' OF STRUCTURE
                                <ls_table> TO <l_field1>.
        MOVE xlfa1-name1 TO <l_field1>.
      ENDIF.
    ENDIF.

    ASSIGN COMPONENT 'AUFNR' OF STRUCTURE
                            <ls_table> TO <l_field1>.
    CLEAR: <l_field1>.
    SELECT aufnr INTO <l_field1>
      FROM   ekkn UP TO 1 ROWS
      WHERE  ebeln EQ xitab-ebeln
      AND    ebelp EQ xitab-ebelp.
      EXIT.
    ENDSELECT.

    APPEND <ls_table> TO <gt_table>.
  ENDLOOP.

*  SORT <GT_TABLE> BY mtart ebeln ebelp.

* add auth check on company code.
  CLEAR: it_rsrange[].  FREE : it_rsrange.
  LOOP AT s_budat.
    MOVE-CORRESPONDING s_budat TO ws_rsrange.
    APPEND ws_rsrange TO it_rsrange.
  ENDLOOP.

*------------------------------------------------------
*> Get 구매문서별 이력(EKBE, EKBZ)
*------------------------------------------------------
  LOOP AT <gt_table> INTO <ls_table>.
    gw_tabix = sy-tabix.
    MOVE-CORRESPONDING <ls_table> TO gs_main.
* Read data for each PO position and create the output master table
    REFRESH: iekbe, iekbes, iekbez, iekbnk, iekbz.
    CLEAR: gs_main-xmark.
*    CALL FUNCTION 'ME_READ_HISTORY'
    CALL FUNCTION 'Z_TI_ME_READ_HISTORY'
      EXPORTING
        ebeln              = gs_main-ebeln
        ebelp              = gs_main-ebelp
        webre              = gs_main-webre
        i_bypassing_buffer = 'X'                            "388267
        i_refresh_buffer   = 'X'                            "388267
      TABLES
        xekbe              = iekbe
        xekbes             = iekbes
        xekbez             = iekbez
        xekbnk             = iekbnk
        xekbz              = iekbz
        budat              = it_rsrange.

* Goods receipts
    LOOP AT iekbes WHERE zekkn EQ space
                     AND ebelp EQ gs_main-ebelp.
      ADD iekbes-wemng TO gs_main-wemng.  ">입고
      ADD iekbes-remng TO gs_main-remng.  ">송장처리
      ADD iekbes-rewrt TO gs_main-rewrt.  ">입고금액(현지통화)
      ADD iekbes-wewwr TO gs_main-wewwr.  ">입고금액(외화)
      ADD iekbes-wewrt TO gs_main-wewrt.  ">송장금액(현지통화)
      ADD iekbes-rewwr TO gs_main-rewwr.  ">송장금액(외화)

      IF iekbes-rewrt <> iekbes-arewr.
        ADD      iekbes-rewrt TO   gs_main-wewrt.
        SUBTRACT iekbes-arewr FROM gs_main-wewrt.
      ENDIF.
      IF iekbes-rewwr <> iekbes-areww.
        ADD      iekbes-rewwr TO   gs_main-wewwr.
        SUBTRACT iekbes-areww FROM gs_main-wewwr.
      ENDIF.

    ENDLOOP.

    gs_main-dmbtr = gs_main-rewrt - gs_main-wewrt.

*    IF NOT ITAB-WRBTR IS INITIAL.
*      ITAB-XMARK = 'X'.
*    ENDIF.
    IF gs_main-dmbtr NE 0.
*    IF ITAB-WEMNG NE ITAB-REMNG.
      gs_main-xmark = 'X'.
    ENDIF.

*> 비용 합계.
    CONCATENATE 'GS_MAIN-DMB' last_cnt
                 INTO field_name.
    ASSIGN (field_name)  TO <fsl>.
*> 전 합계.
    CONCATENATE 'GS_MAIN-DMB' last_cnt1
                 INTO field_name.
    ASSIGN (field_name)  TO <fss>.

* Freight costs
    LOOP AT xkschl.
      line_cnt = sy-tabix.
      CONCATENATE 'GS_MAIN-DMB' line_cnt
                   INTO field_name.
      ASSIGN (field_name)  TO <fs>.

      CLEAR: l_wemng, l_remng, l_wewrt, l_rewrt, l_arewr.
      LOOP AT iekbz WHERE kschl EQ xkschl-kschl
                      AND ebelp EQ gs_main-ebelp.
        IF iekbz-shkzg = 'H'.
          iekbz-menge = - iekbz-menge.
          iekbz-dmbtr = - iekbz-dmbtr.
          iekbz-arewr = - iekbz-arewr.
        ENDIF.
        CASE iekbz-bewtp.
          WHEN 'F'.                                  " goods receipt
            SUBTRACT iekbz-menge FROM l_wemng.
*            SUBTRACT iekbz-dmbtr FROM L_wewrt.
            IF iekbz-arewr IS INITIAL.
              SUBTRACT iekbz-dmbtr FROM l_wewrt.
            ELSE.
              SUBTRACT iekbz-arewr FROM l_wewrt.
            ENDIF.
*         consider posting for account maintenance of the     "n480237
*         freight clearing account                            "n480237
          WHEN 'G' OR 'M' OR 'K'.            " invoice 326904 "n480237
            ADD iekbz-menge TO l_remng.
*            ADD iekbz-dmbtr TO L_rewrt.
            IF iekbz-arewr IS INITIAL.
              ADD iekbz-dmbtr TO l_rewrt.
            ELSE.
              ADD iekbz-arewr TO l_rewrt.
            ENDIF.
          WHEN 'P'.
            ADD iekbz-menge TO l_remng.
            ADD iekbz-arewr TO l_rewrt.
        ENDCASE.
      ENDLOOP.

      <fs> = l_rewrt - l_wewrt.
*      IF NOT <FS> IS INITIAL.
*        ITAB-XMARK = 'X'.
*      ENDIF.
      IF <fs> NE 0.
*      IF L_REMNG NE L_WEMNG.
        gs_main-xmark = 'X'.
      ENDIF.
      <fsl> = <fsl> + <fs>.
    ENDLOOP.
*    IF SY-SUBRC EQ 0.
    <fss> = <fsl> + gs_main-dmbtr.
*    ENDIF.
    MOVE-CORRESPONDING gs_main TO <ls_table>.
    MODIFY <gt_table> FROM <ls_table> INDEX gw_tabix.
  ENDLOOP.

*> 금액이 ZERO인 데이타 삭제.
  IF p_delid EQ space.
    LOOP AT <gt_table> INTO <ls_table>.
      gw_tabix = sy-tabix.
      MOVE-CORRESPONDING <ls_table> TO gs_main.
      IF gs_main-xmark EQ space.
        DELETE <gt_table> INDEX gw_tabix.
      ENDIF.
    ENDLOOP.
  ENDIF.

  DESCRIBE TABLE <gt_table> LINES gw_line.
  IF gw_line EQ 0.
    MESSAGE s902.
  ENDIF.

ENDFORM.                    " GET_DATA_FOR_DISPLAY
*&---------------------------------------------------------------------*
*&      Form  EXEC_ALV_F4
*&---------------------------------------------------------------------*
FORM exec_alv_f4.

  alv_repid = sy-repid.
  CLEAR: alv_variant.
  alv_variant-report = alv_repid.

  CALL FUNCTION 'REUSE_ALV_VARIANT_F4'
    EXPORTING
      is_variant = alv_variant
      i_save     = 'A'
    IMPORTING
      es_variant = alv_variant
    EXCEPTIONS
      not_found  = 2.
  IF sy-subrc = 2.
    MESSAGE ID sy-msgid TYPE 'S' NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ELSE.
    alv_def = alv_variant-variant.
  ENDIF.

ENDFORM.                    " EXEC_ALV_F4
*&---------------------------------------------------------------------*
*&      Form  SET_ALV_INIT
*&---------------------------------------------------------------------*
FORM set_alv_init.

  FREE:  it_sort, fc.
  CLEAR: alv_keyinfo, gs_layout, alv_print, fc.

* PRINTING SETTINGS
  gs_layout-get_selinfos = 'X'.
  gs_layout-group_change_edit = 'X'.

  alv_print-no_print_selinfos = 'X'.
  alv_print-no_coverpage = 'X'.
  alv_print-no_print_listinfos = 'X'.

ENDFORM.                    " SET_ALV_INIT
*&---------------------------------------------------------------------*
*&      Form  SET_FIELDCAT_BUILD
*&---------------------------------------------------------------------*
FORM set_fieldcat_build.

  DATA: color TYPE slis_t_specialcol_alv WITH HEADER LINE.

  FREE : fc.  CLEAR: fc.

  ac 'ITAB   MTART MARA                         MTART X'.
  ac 'ITAB   MTBEZ T134T                        MTBEZ X'.
  ac 'ITAB   WERKS T001W                        WERKS X'.
  ac 'ITAB   NAME1 T001W                        NAME1 X'.
  ac 'ITAB   LIFNR LFA1                         LIFNR X'.
  ac 'ITAB   NAME2 LFA1                         NAME1 X'.
  ac 'ITAB   EBELN EKKO                         EBELN '.
  ac 'ITAB   EBELP EKPO                         EBELP '.
  ac 'ITAB   MATNR EKPO                         MATNR '.
  ac 'ITAB   TXZ01 EKPO                         TXZ01 '.
  ac 'ITAB   AUFNR EKKN                         AUFNR X'.
  ac 'ITAB   WAERS EKKO                         WAERS X'.
  ac 'ITAB   HSWAE EKBE                         HSWAE  '.
  ac 'ITAB   NETWR EKPO                         NETWR XCWAERS'.

  ac 'ITAB   REWRT EKBES                        REWRT XCHSWAE'.
  ac 'ITAB   WEWRT EKBES                        WEWRT XCHSWAE'.

  ac 'ITAB   DMBTR BSEG                         DMBTR  CHSWAE'.
  ac 'ITAB   XMARK RGRWF                              X'.
  DESCRIBE TABLE fc LINES gw_line.
  READ TABLE fc INTO fcs INDEX gw_line.
  fcs-ref_fieldname = 'R_ZEROR_0'.
  MODIFY fc FROM fcs INDEX gw_line.

  fc1[] = fc[].

  ac 'ITAB   COLOR SLIS_T_SPECIALCOL_ALV              X'.

  DESCRIBE TABLE fc1 LINES gw_line.
  gw_line = gw_line - 1.
  READ TABLE fc1 INTO fcs INDEX gw_line.
  CLEAR: fcs-ref_tabname, fcs-ref_fieldname.
  CLEAR fcs-reptext_ddic.
  fcs-ddictxt   = 'M'.
  fcs-seltext_l = '미착물대'(202).
  fcs-seltext_m = '미착물대'(202).
  fcs-seltext_s = '미착물대'(202).
  fcs-outputlen = 18.
  MODIFY fc1 FROM fcs INDEX gw_line.

  LOOP AT xkschl.
    line_cnt = sy-tabix.
    CONCATENATE 'DMB' line_cnt
                 INTO field_name.
    ASSIGN field_name  TO <fs>.

    ac_1 'ITAB' <fs> 'BSEG' 'DMBTR' '' 'C' 'HSWAE'.

    DESCRIBE TABLE fc LINES gw_line.
    READ TABLE fc INTO fcs INDEX gw_line.
    CLEAR: fcs-ref_tabname, fcs-ref_fieldname.
    CLEAR fcs-reptext_ddic.
    fcs-ddictxt   = 'M'.
    fcs-seltext_l = xkschl-vtext.
    fcs-seltext_m = xkschl-vtext.
    fcs-seltext_s = xkschl-vtext.
    fcs-do_sum = 'X'.
    fcs-outputlen = 18.
*
    APPEND fcs TO fc1.
  ENDLOOP.

*> 비용합계
  CLEAR: field_name.
  UNASSIGN <fs>.
*  IF LAST_CNT NE 1.
  CONCATENATE 'DMB' last_cnt
               INTO field_name.
*    ASSIGN FIELD_NAME  TO <FS>.
  ac_1 'ITAB' field_name 'BSEG' 'DMBTR' '' 'C' 'HSWAE'.
  DESCRIBE TABLE fc LINES gw_line.
  READ TABLE fc INTO fcs INDEX gw_line.
  CLEAR fcs-reptext_ddic.
  fcs-ddictxt   = 'M'.
  fcs-seltext_l = '비용합계'(203).
  fcs-seltext_m = '비용합계'(203).
  fcs-seltext_s = '비용합계'(203).
  fcs-do_sum = 'X'.
  fcs-outputlen = 18.

  APPEND fcs TO fc1.
*  ENDIF.

  CONCATENATE 'DMB' last_cnt1
               INTO field_name1.
  ac_1 'ITAB' field_name1 'BSEG' 'DMBTR' '' 'C' 'HSWAE'.
  DESCRIBE TABLE fc LINES gw_line.
  READ TABLE fc INTO fcs INDEX gw_line.
  CLEAR fcs-reptext_ddic.
  fcs-ddictxt   = 'M'.
  fcs-seltext_l = '미착합계'(205).
  fcs-seltext_m = '미착합계'(205).
  fcs-seltext_s = '미착합계'(205).
  fcs-do_sum = 'X'.
  fcs-outputlen = 18.

  APPEND fcs TO fc1.

  LOOP AT fc1 INTO fcs.
    CASE fcs-fieldname.
      WHEN 'EBELN' OR 'MATNR'.
        fcs-hotspot = 'X'.
      WHEN 'DMBTR' OR 'WEBRT' OR 'REBRT'.
        fcs-do_sum = 'X'.
    ENDCASE.
    MODIFY fc1 FROM fcs.
  ENDLOOP.

ENDFORM.                    " SET_FIELDCAT_BUILD
*&---------------------------------------------------------------------*
*&      Form  DISPLAY_ALV_LIST
*&---------------------------------------------------------------------*
FORM display_alv_list.

  DATA: fc_detail TYPE slis_fieldcat_alv OCCURS 0 WITH HEADER LINE.
  DATA: variant_detail      LIKE disvariant.
  DATA: exit     TYPE slis_event_exit   OCCURS 0 WITH HEADER LINE.
  DATA: events   TYPE slis_alv_event    OCCURS 0 WITH HEADER LINE.
  DATA: groups   TYPE slis_sp_group_alv OCCURS 0 WITH HEADER LINE.

* The detail ALV may modify the list (sorting). If returned to the
* base list, the original list needs to be restored.
  REFRESH fc_detail.
  LOOP AT fc1 INTO fcs.
    MOVE-CORRESPONDING fcs TO fc_detail.
    CLEAR fc_detail-tabname.
    APPEND fc_detail.
  ENDLOOP.

  CLEAR variant_detail.
  variant_detail-report = alv_repid.
  variant_detail-handle = ' '.

  gs_layout-colwidth_optimize = 'X'.
  gs_layout-zebra             = 'X'.
*  S_LAYOUT-BOX_FIELDNAME     = 'BOX'.
*>color field define.
  gs_layout-coltab_fieldname  = 'COLOR'.
  gs_layout-group_change_edit = 'X'.
  gs_layout-f2code            = 'DISPLAY'.

  REFRESH exit.
  exit-ucomm = '&OL0'. exit-after = 'X'. APPEND exit.
  exit-ucomm = '&OLX'. APPEND exit.
  exit-ucomm = '&OAD'. APPEND exit.

*> event define.
  REFRESH events.
  events-name = slis_ev_top_of_page.
  events-form = 'TOP_OF_PAGE'.
  APPEND events.

*  events-name = slis_ev_subtotal_text.
*  events-form = slis_ev_subtotal_text.
*  APPEND events.
*
*> ALV reuse function call..
  CALL FUNCTION alv_detail_func
      EXPORTING
        i_callback_program       = alv_repid
        i_callback_pf_status_set = 'SET_ALV_STATUS'
        i_callback_user_command  = 'USER_ALV_COMMAND'
*     I_STRUCTURE_NAME               =
*     IT_EXCLUDING                   =
*     IT_SPECIAL_GROUPS              =
*     IT_FILTER                      =
*     IS_SEL_HIDE                    =
*     I_DEFAULT                      = 'X'
*     I_SAVE                         = ' '
*     IS_VARIANT                     =
      it_events                      = events[]
      it_event_exit                  = exit[]
*     IS_PRINT                       =
*     IS_REPREP_ID                   =
*     I_SCREEN_START_COLUMN          = 0
*     I_SCREEN_START_LINE            = 0
*     I_SCREEN_END_COLUMN            = 0
*     I_SCREEN_END_LINE              = 0
        it_fieldcat              = fc_detail[]
        it_sort                  = it_sort
*        I_DEFAULT                = 'X'
*        IS_VARIANT               = VARIANT_DETAIL
        is_variant               = alv_variant
        i_save                   = c_save
        is_layout                = gs_layout
        is_print                 = alv_print
*   IMPORTING
*     E_EXIT_CAUSED_BY_CALLER        =
*     ES_EXIT_CAUSED_BY_USER         =
      TABLES
        t_outtab                 = <gt_table>.

ENDFORM.                    " DISPLAY_ALV_LIST

*&---------------------------------------------------------------------*
*&      Form  SET_ALV_STATUS
*&---------------------------------------------------------------------*
FORM set_alv_status USING  extab TYPE slis_t_extab.

  SET TITLEBAR 'T1000'.

  APPEND 'ARCHIVE'   TO extab.
  APPEND '&VEXCEL'   TO extab.
  APPEND '&AQW'      TO extab.
  APPEND '&VCRYSTAL' TO extab.
  APPEND '&VGRID'    TO extab.
  APPEND '&EB9'      TO extab.
  APPEND '&CRDESIG'  TO extab.

  SET PF-STATUS 'STANDARD' EXCLUDING extab.

ENDFORM.                    " SET_ALV_STATUS

*&---------------------------------------------------------------------*
*&      Form  USER_ALV_COMMAND
*&---------------------------------------------------------------------*
FORM user_alv_command USING   r_ucomm      LIKE sy-ucomm
                              rs_selfield  TYPE slis_selfield.
*
  FIELD-SYMBOLS: <ls_table>.
  FIELD-SYMBOLS: <l_field1>.
  FIELD-SYMBOLS: <l_field2>.

  ASSIGN LOCAL COPY OF INITIAL LINE OF <gt_table> TO <ls_table>.

  CASE r_ucomm.
    WHEN 'MB5S'.
      READ TABLE <gt_table> INTO <ls_table>
                            INDEX rs_selfield-tabindex. "cursorposit.
      IF sy-subrc EQ 0.
        MOVE-CORRESPONDING <ls_table> TO xitab.
        SUBMIT rm07msal AND RETURN
          WITH ebeln = xitab-ebeln
          WITH ebelp = xitab-ebelp.
      ELSE.
        MESSAGE s903.
      ENDIF.
    WHEN 'MMBE'.
      READ TABLE <gt_table> INTO <ls_table>
                            INDEX rs_selfield-tabindex. "cursorposit.
      IF sy-subrc EQ 0.
        MOVE-CORRESPONDING <ls_table> TO xitab.
        SET PARAMETER ID 'MAT' FIELD xitab-matnr.
        SET PARAMETER ID 'WRK' FIELD xitab-werks.

        SET PARAMETER ID 'LAG' FIELD ''.
        SET PARAMETER ID 'CHA' FIELD ''.
        CALL TRANSACTION 'MMBE' AND SKIP FIRST SCREEN.
      ELSE.
        MESSAGE s903.
      ENDIF.
    WHEN 'MM03'.
      PERFORM material_master_display  USING rs_selfield.
*    WHEN 'ZTIH1'.    ">품목별 Hierarchy
*      READ TABLE <gt_table> INTO <ls_table>
*                            INDEX rs_selfield-tabindex. "cursorposit.
*      IF sy-subrc EQ 0.
*        MOVE-CORRESPONDING <ls_table> TO xitab.
*        PERFORM call_tocde_ZTIh1(ZTIr0000)
*                                 USING xitab-ebeln
*                                       xitab-ebelp.
*      ELSE.
*        MESSAGE s901.
*      ENDIF.
*    WHEN 'ZTIH2'.    ">수량별 진행현황.
*      READ TABLE <gt_table> INTO <ls_table>
*                            INDEX rs_selfield-tabindex. "cursorposit.
*      IF sy-subrc EQ 0.
*        MOVE-CORRESPONDING <ls_table> TO xitab.
*        PERFORM call_tocde_ZTIh2(sapmZTI01)
*                                 USING xitab-ebeln
*                                       xitab-ebelp.
*      ELSE.
*        MESSAGE s901.
*      ENDIF.
    WHEN 'PUOR'.
      PERFORM  purchase_order_display  USING rs_selfield.

    WHEN 'POHIST'.   " doubleclick.
      READ TABLE <gt_table> INTO <ls_table>
                            INDEX rs_selfield-tabindex. "cursorposit.
      IF sy-subrc EQ 0.
        MOVE-CORRESPONDING <ls_table> TO xitab.
        SUBMIT rm06ehbe AND RETURN
          WITH s_ebeln = xitab-ebeln
          WITH s_ebelp = xitab-ebelp
          WITH lesen    = 'Y'.
      ELSE.
        MESSAGE s903.
      ENDIF.
    WHEN 'DISPLAY'.                    " AUF DOPPELKLICK REAGIERIEN
      CHECK rs_selfield-tabindex GT 0.

      CASE rs_selfield-sel_tab_field.
        WHEN 'ITAB-MATNR'.   ">Material display.
          PERFORM material_master_display USING rs_selfield.
        WHEN 'ITAB-EBELN'.
          PERFORM  purchase_order_display USING rs_selfield.
        WHEN OTHERS.
          READ TABLE <gt_table> INTO <ls_table>
                                INDEX rs_selfield-tabindex. "cursorposit
          .
          IF sy-subrc EQ 0.
            MOVE-CORRESPONDING <ls_table> TO xitab.
            SUBMIT rm06ehbe AND RETURN
              WITH s_ebeln = xitab-ebeln
              WITH s_ebelp = xitab-ebelp
              WITH lesen    = 'Y'.
          ELSE.
            MESSAGE s903.
          ENDIF.
      ENDCASE.

  ENDCASE.
  CLEAR: r_ucomm, rs_selfield.

ENDFORM.                    " USER_ALV_COMMAND
*&---------------------------------------------------------------------*
*&      Form  ALV_VARIANT_CHECK
*&---------------------------------------------------------------------*
FORM alv_variant_check.

  alv_variant-report = alv_repid.
  alv_variant-variant = alv_def.
  IF NOT alv_def IS INITIAL.
    CALL FUNCTION 'REUSE_ALV_VARIANT_EXISTENCE'
      EXPORTING
        i_save     = 'A'
      CHANGING
        cs_variant = alv_variant
      EXCEPTIONS
        OTHERS     = 1.
    IF sy-subrc <> 0.
      MESSAGE e321(m7) WITH alv_def alv_repid.
    ENDIF.
  ENDIF.

ENDFORM.                    " ALV_VARIANT_CHECK
*&---------------------------------------------------------------------*
*&      Form  SET_SORT_FIELD
*&---------------------------------------------------------------------*
FORM set_sort_field.

  REFRESH: it_sort.

  CLEAR  st_sort.
  st_sort-spos = '01'.
  st_sort-fieldname = 'MTART'.
  st_sort-tabname   = 'ITAB'.
  st_sort-up        = 'X'.
*  ST_SORT-GROUP     = 'X'.
  st_sort-subtot    = 'X'.
*  ST_SORT-EXPA      = 'X'.
  APPEND st_sort TO it_sort.

  CLEAR  st_sort.
  st_sort-spos = '02'.
  st_sort-fieldname = 'MTBEZ'.
  st_sort-tabname   = 'ITAB'.
  st_sort-up        = 'X'.
*  ST_SORT-GROUP     = 'X'.
*  ST_SORT-SUBTOT    = 'X'.
*  ST_SORT-EXPA      = 'X'.
  APPEND st_sort TO it_sort.

  CLEAR  st_sort.
  st_sort-spos = '03'.
  st_sort-fieldname = 'EBELN'.
  st_sort-tabname   = 'ITAB'.
  st_sort-up        = 'X'.
*  ST_SORT-GROUP     = 'X'.
*  ST_SORT-SUBTOT    = 'X'.
*  ST_SORT-EXPA      = 'X'.
  APPEND st_sort TO it_sort.

ENDFORM.                    " SET_SORT_FIELD

*&---------------------------------------------------------------------*
*&      Form  TOP_OF_PAGE
*&---------------------------------------------------------------------*
FORM top_of_page.

  DATA: l_mode TYPE i.
  DATA: header TYPE slis_listheader OCCURS 0 WITH HEADER LINE.

  SET TITLEBAR 'T1000'.

  REFRESH header.

  header-typ = 'H'.
  IF p_grp1 EQ 'X'.
    header-info = '수입구매오더 미착현황'(999).
  ELSE.
    header-info = '전체구매오더 미착현황'(998).
  ENDIF.
  CLEAR: header-key.
  APPEND header.

  header-typ = 'S'.
*
*  LOOP AT ORGAN.
*    L_MODE = SY-TABIX MOD 9.
*    CASE L_MODE.
*      WHEN 1.
*        IF SY-TABIX EQ 1.
*          PERFORM get_ftext(rddfie00) USING 'T001W' 'WERKS' SY-LANGU
*                                      CHANGING dfies GW_SUBRC.
*          IF GW_SUBRC EQ 0.
*            HEADER-KEY = dfies-scrtext_m.
*          ELSE.
*            HEADER-KEY = TEXT-102.
*          ENDIF.
*        ELSE.
*          HEADER-TYP = 'S'.
*          CLEAR: HEADER-KEY.
*        ENDIF.
*        HEADER-INFO = ORGAN-WERKS.
*      WHEN 0.
*        CONCATENATE HEADER-INFO ',' ORGAN-WERKS INTO HEADER-INFO
*                    SEPARATED BY SPACE.
*        APPEND HEADER.
*      WHEN OTHERS.
*        CONCATENATE HEADER-INFO ',' ORGAN-WERKS INTO HEADER-INFO
*                    SEPARATED BY SPACE.
*    ENDCASE.
*  ENDLOOP.
*  IF L_MODE NE 0.
*    APPEND HEADER.
*  ENDIF.

** JS전선 회사코드 2007/04 KSH --------------------------------------
  DATA: l_butxt LIKE t001-butxt.
  CLEAR: l_butxt.
  SELECT SINGLE butxt FROM t001
                      INTO l_butxt
                     WHERE bukrs EQ s_bukrs-low.

  header-typ = 'S'.
  header-key = '회사코드 '.
  CONCATENATE s_bukrs-low l_butxt INTO header-info SEPARATED BY space.
  APPEND header.
  CLEAR: header.
** JS전선 회사코드 2007/04 KSH --------------------------------------

  header-key = '출력일자'(106).
  WRITE: sy-datlo TO header-info.
  APPEND header.

  CALL FUNCTION 'REUSE_ALV_COMMENTARY_WRITE'
    EXPORTING
      it_list_commentary = header[].

ENDFORM.    ">TOP_OF_PAGE

*---------------------------------------------------------------------*
*       Form  SUBTOTAL_TEXT                                           *
*---------------------------------------------------------------------*
FORM subtotal_text USING my_listhead LIKE t_alv_list
                         my_subtotal TYPE slis_subtot_text.

  CLEAR my_subtotal-display_text_for_subtotal.

  IF my_subtotal-criteria EQ 'MTART'.
    IF my_listhead-mtart IS INITIAL.
    ELSE.
      my_subtotal-display_text_for_subtotal = my_listhead-mtart.

      READ TABLE xt134t WITH KEY mtart = my_listhead-mtart.
      IF sy-subrc EQ 0.
        CONCATENATE my_subtotal-display_text_for_subtotal '- ('
                    xt134t-mtbez ')'
                    INTO my_subtotal-display_text_for_subtotal
                    SEPARATED BY space.
*          my_subtotal-display_text_for_subtotal = XT134T-MTBEZ.

      ENDIF.
    ENDIF.
  ENDIF.

ENDFORM.                    "SUBTOTAL_TEXT
*&---------------------------------------------------------------------*
*&      Form  GET_IMPORT_PURCHASING_ORDER
*&---------------------------------------------------------------------*
FORM get_import_purchasing_order.

  line1    = 20.
  out_text = text-902.
  REPLACE '%99999%' WITH line1 INTO out_text.
  PERFORM set_progress_bar USING out_text line1.

  IF p_grp1 EQ 'X'.
    SELECT  h~waers h~lifnr h~knumv h~kalsm h~stafo
            p~ebeln p~ebelp p~matnr p~txz01 p~mtart p~netwr p~brtwr
            p~werks p~webre
            v~name1 AS name2
            INTO CORRESPONDING FIELDS OF TABLE xitab
            FROM ekko AS h INNER JOIN ekpo AS p
                 ON   h~ebeln  EQ  p~ebeln
                 INNER JOIN ztitrqp AS i
                 ON   p~ebeln  EQ  i~ebeln
                 AND  p~ebelp  EQ  i~ebelp
                 INNER JOIN ztitrqk AS l
                 ON   i~reqno  EQ  l~reqno
                 AND  i~amdsq EQ  l~lstas
                 INNER JOIN lfa1 AS v
                 ON   h~lifnr  EQ  v~lifnr
            WHERE   h~bukrs    IN  s_bukrs
            AND     h~lifnr    IN  s_lifnr
            AND     p~werks    IN  s_werks
            AND     p~mtart    IN  s_mtart
            AND     p~matnr    IN  s_matnr
            AND     p~ebeln    IN  s_ebeln
            AND     p~ebelp    IN  s_ebelp
            AND     h~ekorg    IN  s_ekorg
            AND     h~ekgrp    IN  s_ekgrp
            AND     p~wepos    NE  space
            AND     p~repos    NE  space
            AND     p~weunb    EQ  space
            AND     p~elikz    IN  s_elikz
            AND     p~loekz    IN  s_loekz
            AND     h~loekz    IN  s_loekz
            GROUP BY h~waers h~lifnr h~knumv h~kalsm h~stafo
                     p~ebeln p~ebelp p~matnr p~txz01 p~mtart
                     p~netwr p~brtwr p~werks p~webre
                     v~name1.
  ELSE.
    SELECT  h~waers h~lifnr h~knumv h~kalsm h~stafo
            p~ebeln p~ebelp p~matnr p~txz01 p~mtart p~netwr p~brtwr
            p~werks p~webre
            v~name1 AS name2
            INTO CORRESPONDING FIELDS OF TABLE xitab
            FROM ekko AS h INNER JOIN ekpo AS p
                 ON   h~ebeln  EQ  p~ebeln
                 INNER JOIN lfa1 AS v
                 ON   h~lifnr  EQ  v~lifnr
            WHERE   h~bukrs    IN  s_bukrs
            AND     h~lifnr    IN  s_lifnr
            AND     p~werks    IN  s_werks
            AND     p~mtart    IN  s_mtart
            AND     p~matnr    IN  s_matnr
            AND     p~ebeln    IN  s_ebeln
            AND     p~ebelp    IN  s_ebelp
            AND     h~ekorg    IN  s_ekorg
            AND     h~ekgrp    IN  s_ekgrp
            AND     p~wepos    NE  space
            AND     p~repos    NE  space
            AND     p~weunb    EQ  space
            AND     p~elikz    IN  s_elikz
            AND     p~loekz    IN  s_loekz
            AND     h~loekz    IN  s_loekz
            GROUP BY h~waers h~lifnr h~knumv h~kalsm h~stafo
                     p~ebeln p~ebelp p~matnr p~txz01 p~mtart
                     p~netwr p~brtwr p~werks p~webre
                     v~name1.
  ENDIF.
  IF sy-subrc NE 0.
    MESSAGE s902.  g_err_mode = 'Y'.   EXIT.
  ENDIF.

*> 자재타입명
  SELECT * INTO CORRESPONDING FIELDS OF TABLE xt134t
           FROM    t134t
           FOR     ALL ENTRIES  IN  xitab
           WHERE   mtart        EQ  xitab-mtart
           AND     spras        EQ  sy-langu.
*> 공급업체
  SELECT * INTO CORRESPONDING FIELDS OF TABLE xlfa1
           FROM    lfa1
           FOR     ALL ENTRIES  IN  xitab
           WHERE   lifnr        EQ  xitab-lifnr.

  SELECT DISTINCT kschl
         INTO CORRESPONDING FIELDS OF TABLE xkschl
         FROM    ekbz
         FOR     ALL ENTRIES  IN  xitab
         WHERE   ebeln        EQ  xitab-ebeln
         AND     ebelp        EQ  xitab-ebelp
         AND     budat        IN  s_budat.

  LOOP AT xkschl.
    gw_tabix = sy-tabix.
    SELECT SINGLE vtext INTO xkschl-vtext
           FROM  t685t
           WHERE spras  EQ sy-langu
           AND   kvewe  EQ 'A'
           AND   kappl  EQ 'M'
           AND   kschl  EQ xkschl-kschl.
    MODIFY xkschl INDEX gw_tabix.
  ENDLOOP.

  SORT xkschl BY kschl.

  DESCRIBE TABLE xkschl LINES last_cnt.
  last_cnt  = last_cnt + 1.
  last_cnt1 = last_cnt + 1.

ENDFORM.                    " GET_IMPORT_PURCHASING_ORDER

*&---------------------------------------------------------------------*
*&      Form  PURCHASE_ORDER_DISPLAY
*&---------------------------------------------------------------------*
FORM purchase_order_display USING rs_selfield  TYPE slis_selfield.

  FIELD-SYMBOLS: <ls_table>.

  READ TABLE <gt_table> INTO <ls_table>
                        INDEX rs_selfield-tabindex. "cursorposit.
  IF sy-subrc EQ 0.
    MOVE-CORRESPONDING <ls_table> TO xitab.

    CALL FUNCTION 'ME_DISPLAY_PURCHASE_DOCUMENT'
      EXPORTING
        i_ebeln      = xitab-ebeln
        i_ebelp      = xitab-ebelp
        i_enjoy      = 'X'
      EXCEPTIONS
        not_found    = 1
        no_authority = 2
        invalid_call = 3
        OTHERS       = 4.
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.
  ELSE.
    MESSAGE s903.
  ENDIF.

ENDFORM.                    " PURCHASE_ORDER_DISPLAY
*&---------------------------------------------------------------------*
*&      Form  MATERIAL_MASTER_DISPLAY
*&---------------------------------------------------------------------*
FORM material_master_display USING rs_selfield  TYPE slis_selfield.

  FIELD-SYMBOLS: <ls_table>.

  READ TABLE <gt_table> INTO <ls_table>
                        INDEX rs_selfield-tabindex. "cursorposit.
  IF sy-subrc EQ 0.
    MOVE-CORRESPONDING <ls_table> TO xitab.

    READ TABLE organ WITH KEY werks = xitab-werks.

    SET PARAMETER ID 'MAT' FIELD xitab-matnr.
    SET PARAMETER ID 'BUK' FIELD organ-bukrs.
    SET PARAMETER ID 'WRK' FIELD xitab-werks.
    SET PARAMETER ID 'LAG' FIELD ''.
*  SET PARAMETER ID 'MXX' FIELD 'KDEALBSZXVPCFQG'.
    SET PARAMETER ID 'MXX' FIELD 'KDE'.

    CALL TRANSACTION 'MM03' AND SKIP  FIRST SCREEN.
  ELSE.
    MESSAGE s903.
  ENDIF.

ENDFORM.                    " MATERIAL_MASTER_DISPLAY
*&---------------------------------------------------------------------*
*&      Form  create_dynamic_table
*&---------------------------------------------------------------------*
FORM create_dynamic_table .

  DATA: lp_table        TYPE REF TO data.
  DATA: e_style_fname   TYPE lvc_fname.
  DATA: i_style_table   TYPE c.
  DATA: lt_fieldcat     TYPE lvc_t_fcat.

*  i_style_table = 'X'.
*  CALL FUNCTION 'LVC_FIELDCAT_COMPLETE'
*    EXPORTING
*      is_layout   = gs_layout_g
*    CHANGING
*      ct_fieldcat = it_fieldcat_g[].
*
*create_dynamic_table
  CLEAR lp_table.
  CALL METHOD z_ti_cl_alv_table_create=>create_dynamic_table_grid
    EXPORTING
      it_fieldcatalog = fc
*      i_style_table   = i_style_table
    IMPORTING
      ep_table        = lp_table.

  ASSIGN lp_table->* TO <gt_table>.

ENDFORM.                    " create_dynamic_table
*&---------------------------------------------------------------------*
*&      Form  set_colorize_build
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM set_colorize_build .

  FIELD-SYMBOLS: <lt_table> TYPE table.
  FIELD-SYMBOLS: <ls_table>.
  FIELD-SYMBOLS: <lt_color>.
  FIELD-SYMBOLS: <ls_color>.
  FIELD-SYMBOLS: <l_field> TYPE table.
  FIELD-SYMBOLS: <l_name>.
  FIELD-SYMBOLS: <l_col>.
  FIELD-SYMBOLS: <l_int>.

  ASSIGN LOCAL COPY OF INITIAL LINE OF <gt_table> TO <lt_table>.

  DATA: color TYPE slis_t_specialcol_alv WITH HEADER LINE.

*> colorize
  LOOP AT <gt_table> INTO <lt_table>.

    ASSIGN COMPONENT 'COLOR' OF STRUCTURE
                             <lt_table> TO <l_field>.

    ASSIGN LOCAL COPY OF INITIAL LINE OF <l_field> TO <ls_color>.

    ASSIGN COMPONENT 'COLOR-COL' OF STRUCTURE
                             <ls_color> TO <l_col>.
    ASSIGN COMPONENT 'COLOR-INT' OF STRUCTURE
                             <ls_color> TO <l_int>.
    ASSIGN COMPONENT 'FIELDNAME' OF STRUCTURE
                             <ls_color> TO <l_name>.
    <l_col> = 4.
    <l_int> = 0.
    <l_name> = 'MTART'.
    APPEND <ls_color> TO <l_field>.

    <l_name> = 'EBELN'.
    APPEND <ls_color> TO <l_field>.

    <l_name> = 'EBELP'.
    APPEND <ls_color> TO <l_field>.

    <l_name> = 'MATNR'.
    APPEND <ls_color> TO <l_field>.

    <l_name> = 'AUFNR'.
    APPEND <ls_color> TO <l_field>.

    <l_col> = 3.
    <l_int> = 0.
    <l_name> = field_name.
    APPEND <ls_color> TO <l_field>.

    <l_int> = 1.
    <l_name> = field_name1.
    APPEND <ls_color> TO <l_field>.

    MODIFY <gt_table> FROM <lt_table>.
  ENDLOOP.

ENDFORM.                    " set_colorize_build
*&---------------------------------------------------------------------*
*&      Form  ADJUST_fieldcat
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM adjust_fieldcat .

ENDFORM.                    " ADJUST_fieldcat
