************************************************************************
*                                                                      *
* Title         : ZTIR2030                                             *
*                                                                      *
* Description   : [Report] 선적서류 상태별 현황 List                   *
*                                                                      *
* Creation Date : 2003/09/29                                           *
*                                                                      *
* Author        : Seog Bong, Kang                                      *
*                Copyright ⓒ ASEG Co., LTD. All rights reserved.      *
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
PROGRAM   ztir2030
          MESSAGE-ID zmti00
          NO STANDARD PAGE HEADING.

************************************************************************
* TYPES and TYPE-POOLS                                                 *
************************************************************************
TYPE-POOLS: slis.   "> Globale Type(ALV)

************************************************************************
* User Included                                                        *
************************************************************************
INCLUDE zts_reuse_bdc_subroutine_f00.
** JS전선 회사코드 2007/04 KSH --------------------------------------
DATA: l_yn    type c.
INCLUDE zts_authorization_check. "AUTHORIZATION_CHECK
** JS전선 회사코드 2007/04 KSH --------------------------------------

************************************************************************
* Internal Tables                                                      *
************************************************************************

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
        ztitig00,  ">[TraSys] 회사별 프로세스 정의.
        ztitblk,   ">[Import] Bill of Lading Header table
        ztitblp,   ">[Import] Bill of Lading Items table
        ztitrqk,   ">[Import] Document Header
        ztitrqs,   ">[Import] Document Status
        ztitrqp,   ">[Import] Document Items
        ztisscrcom,">수출입시스템 Screen용 Structure(공용).
        spop,      ">POPUP_TO_CONFIRM_... function 모듈 팝업화면 필드.
        ztivrq02,  ">header + status Views
        ztitip1,   ">적하 보험  MAIN (APPCIV/CIPADV)
        ztitip2,   ">적하부보 보험조건
        ztitip3,   ">수입보험구상관리
        ztitip4,   ">적하 보험 배서내역 table
        ztivip00,  ">적하보험 Views <수입의뢰 item까지>
        ztivip01.  ">적하보험 Views <수입의뢰 status>

************************************************************************
* CONSTANTS                                                            *
************************************************************************
CONSTANTS:
** JS전선 회사코드 2007/04 KSH --------------------------------------
*    c_bukrs     LIKE t001-bukrs     VALUE '1000',   ">Company code
** JS전선 회사코드 2007/04 KSH --------------------------------------
    c_save(1)   TYPE  c             VALUE 'A'.


************************************************************************
* SELECT-OPTIONS / PARAMETERS                                          *
************************************************************************
SELECTION-SCREEN BEGIN OF BLOCK box1 WITH FRAME TITLE text-001.
SELECT-OPTIONS:
  s_bukrs  FOR ztitrqk-bukrs 	           "회사코드.
                    NO-EXTENSION NO INTERVALS OBLIGATORY
                    MEMORY ID buk
                    MODIF  ID iog ,
  s_ekorg  FOR ztitblk-ekorg MODIF ID iog,                  "4구매조직.
  s_ekgrp  FOR ztitblk-ekgrp MODIF ID iog,                  "3구매그룹.
  s_ebeln  FOR ztitblp-ebeln MODIF ID iog,   "10구매전표번호.
  s_iblno  FOR ztitblk-iblno MODIF ID iog	    "B/L 관리번호.
                              MEMORY ID ztiiblno,
  s_reqno  FOR ztitblp-reqno MODIF ID iog,   "10수입의뢰 관리번호.
  s_blnum  FOR ztitblk-blnum MODIF ID iog,   "25B/L 번호.
  s_sdrlt  FOR ztitblk-sdrlt MODIF ID iog,   "선적서류송부처.
  s_werks  FOR ztitblk-werks MODIF ID iog,   "플랜트.
  s_bldty  FOR ztitblk-bldty MODIF ID iog,                  "1문서종류.
  s_rptty  FOR ztitblk-rptty MODIF ID iog.   "1수입신고구분.


SELECTION-SCREEN ULINE.
PARAMETERS: p_step1 RADIOBUTTON GROUP ab1,
            p_step2 RADIOBUTTON GROUP ab1,
            p_step3 RADIOBUTTON GROUP ab1,
            p_step4 RADIOBUTTON GROUP ab1,
            p_step5 RADIOBUTTON GROUP ab1 DEFAULT 'X'.
SELECTION-SCREEN ULINE.

SELECT-OPTIONS:
  s_lifnr  FOR ztitblk-lifnr MODIF ID iog,   "10공급업체 계정번호.
  s_bletd  FOR ztitblk-bletd MODIF ID iog,   "8ETD(출발 예정 시각).
  s_bleta  FOR ztitblk-bleta MODIF ID iog,   "8ETA(도착 예정 시각).
  s_fwdty  FOR ztitblk-fwdty MODIF ID iog,   "1운송 방법.
  s_waers  FOR ztitblk-waers MODIF ID iog,                  "5통화키.
  s_lgayn  FOR ztitblk-lgayn MODIF ID iog,   "LG대상여부.
  s_iblit  FOR ztitblp-iblit MODIF ID iog,   "5B/L 품목번호.
  s_ndfty  FOR ztitblp-ndfty MODIF ID iog,   "1무환품 종류.
  s_ebelp  FOR ztitblp-ebelp MODIF ID iog,   "5구매문서 품목번호.
  s_reqit  FOR ztitblp-reqit MODIF ID iog,   "5수입의뢰 품목번호.
  s_cnam   FOR ztitblp-cnam  MODIF ID iog,                  "12작성인.
  s_cdat   FOR ztitblp-cdat  MODIF ID iog,                  "8생성일.
  s_ctme   FOR ztitblp-ctme  MODIF ID iog,                  "6생성시간.
  s_unam   FOR ztitblp-unam  MODIF ID iog,   "12최종변경인.
  s_udat   FOR ztitblp-udat  MODIF ID iog,                  "8변경일.
  s_utme   FOR ztitblp-utme  MODIF ID iog.   "6최종변경시간.
SELECTION-SCREEN ULINE.
PARAMETERS: p_full RADIOBUTTON GROUP ab2 DEFAULT 'X',
            p_list RADIOBUTTON GROUP ab2.
SELECTION-SCREEN END OF BLOCK box1.

*> Report variant
SELECTION-SCREEN: BEGIN OF BLOCK alv WITH FRAME TITLE text-003.
PARAMETERS: alv_def LIKE disvariant-variant.
SELECTION-SCREEN: END OF BLOCK alv.


************************************************************************
* Internal Tables                                                      *
************************************************************************
*> 공급업체명
DATA : BEGIN OF xlfa1 OCCURS 0,
       lifnr           LIKE   lfa1-lifnr,
       name1           LIKE   lfa1-name1.
DATA : END   OF xlfa1.


DATA: it_fieldcat_g TYPE lvc_t_fcat,
      gs_fieldcat_g LIKE LINE OF it_fieldcat_g.

*---------------------------------------------------------------------*
*> Message dialog box용                                               *
*---------------------------------------------------------------------*
DATA: BEGIN OF it_msg  OCCURS 0.
        INCLUDE STRUCTURE ztismessage.
DATA: END   OF it_msg.

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
DATA : g_line          TYPE   i,             "Line counter
       g_subrc         LIKE   sy-subrc,      "Return code
       g_tabix         LIKE   sy-tabix,      "table index
       g_line1(3)      TYPE   n,             "LINE COUNT
       g_out_text(70)  TYPE   c,             "text field(display)
       g_err_mode      TYPE   c,
       line_cnt(02)    TYPE   n,
       ok-code         LIKE   sy-ucomm,
       field_name(20),
       field_name1(20).

* Global variables for handling ALV functionality
DATA: alv_keyinfo      TYPE slis_keyinfo_alv.
DATA: alv_variant      LIKE disvariant.
DATA: gs_layout        TYPE slis_layout_alv.
DATA: alv_repid        LIKE sy-repid.
DATA: alv_print        TYPE slis_print_alv.
DATA: st_sort          TYPE slis_sortinfo_alv.

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
  PERFORM set_fieldcat_build.      ">Set ALV field category
  PERFORM create_dynamic_table.    ">
  PERFORM get_data_for_display.    ">data select

************************************************************************
*                                                                      *
* END-OF-SELECTION Event                                               *
*                                                                      *
************************************************************************
END-OF-SELECTION.
  CHECK g_line NE 0.
*>--------------------------------------------------------
*> PROGRESS INDICATOR DISPLAY.
*>  4.  LIST DISPLAY
*>--------------------------------------------------------
  g_line1 = 100.
  g_out_text = text-905.
  REPLACE '%99999%' WITH g_line1 INTO g_out_text.
  PERFORM set_progress_bar USING g_out_text g_line1.
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

  SET TITLEBAR 'T1000' WITH '상태별 선적서류'.

** JS전선 회사코드 2007/04 KSH --------------------------------------
*  FREE: s_bukrs.    CLEAR: s_bukrs.
*  s_bukrs-sign   = 'I'.
*  s_bukrs-option = 'EQ'.
*  s_bukrs-low    = c_bukrs.
*  APPEND s_bukrs.
** JS전선 회사코드 2007/04 KSH --------------------------------------

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
                                CHANGING dfies g_subrc.
    SET CURSOR FIELD 'S_BUKRS-LOW'.
    MESSAGE e348(m7) WITH dfies-scrtext_m.
  ENDIF.

*> 수입 IMG Setting
  SELECT SINGLE *
    FROM ztitig00
   WHERE bukrs EQ l_bukrs.
  IF sy-subrc NE 0.
    MESSAGE e035 WITH l_bukrs.
  ENDIF.

  CASE 'X'.
    WHEN p_step2.  ">선적서류송부.
      IF ztitig00-blpcs NE 'A'.
        MESSAGE e244.
      ENDIF.
    WHEN p_step3.  ">실입항 입력.
      IF NOT ( ztitig00-blpcs EQ 'A' OR
               ztitig00-blpcs EQ 'B' ).
        MESSAGE e245.
      ENDIF.
    WHEN p_step4.  ">통관요청.
      IF ztitig00-ccrpc EQ space.
        MESSAGE e242.
      ENDIF.
  ENDCASE.
* Vendor
  READ TABLE s_lifnr INDEX 1 TRANSPORTING NO FIELDS.
  IF sy-subrc = 0.
    SELECT lifnr INTO (l_lifnr)
                 FROM lfb1 UP TO 1 ROWS WHERE lifnr IN s_lifnr
                                        AND   bukrs IN s_bukrs.
    ENDSELECT.
    IF sy-subrc <> 0.
      PERFORM get_ftext(rddfie00) USING 'LFA1' 'LIFNR' sy-langu
                                  CHANGING dfies g_subrc.
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
                                  CHANGING dfies g_subrc.
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
                                  CHANGING dfies g_subrc.
      SET CURSOR FIELD 'S_EKGRP-LOW'.
      MESSAGE e348(m7) WITH dfies-scrtext_m.
    ENDIF.
  ENDIF.

ENDFORM.                    " INPUT_FIELD_CHECK
*&---------------------------------------------------------------------*
*&      Form  CLEARING_WORK_AREA
*&---------------------------------------------------------------------*
FORM clearing_work_area.

  FREE:  xlfa1.
  CLEAR: xlfa1.

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

  DATA:   l_count    TYPE  i.
  RANGES: lr_bldst   FOR   ztitblk-bldst OCCURS 1.

  FIELD-SYMBOLS: <ls_table>.
  FIELD-SYMBOLS: <l_field1>.
  FIELD-SYMBOLS: <l_field2>.

  REFRESH : <gt_table>.
*> PROGRESS Display.
  g_line1    = 30.
  g_out_text = '데이타를 검색 중입니다 %99999%%'(p01).
  REPLACE '%99999%' WITH g_line1 INTO g_out_text.
  PERFORM show_progress_bar(ztir0000) USING g_out_text g_line1.

  CLEAR lr_bldst .
  MOVE: 'I'     TO    lr_bldst-sign,
        'EQ'    TO    lr_bldst-option.
  CASE 'X'.
    WHEN p_step1. ">선적예정정보.
      MOVE: 'A'   TO  lr_bldst-low.    APPEND lr_bldst .
    WHEN p_step2. ">송부처 등록.
      MOVE: 'B'   TO  lr_bldst-low.    APPEND lr_bldst .
    WHEN p_step3. ">실입항 입력.
      MOVE: 'D'   TO  lr_bldst-low.    APPEND lr_bldst .
    WHEN p_step4. ">통관요청.
      MOVE: 'E'   TO  lr_bldst-low.    APPEND lr_bldst .
      MOVE: 'F'   TO  lr_bldst-low.    APPEND lr_bldst .
    WHEN p_step5. ">전체.
      REFRESH lr_bldst .
  ENDCASE.

*> 수입의뢰 데이타 select.
  SELECT *
    INTO CORRESPONDING FIELDS OF TABLE <gt_table>
    FROM ztitblk
       WHERE bukrs  IN s_bukrs  "회사코드.
         AND iblno  IN s_iblno
         AND bldst  IN lr_bldst
         AND sdrlt  IN s_sdrlt
         AND werks  IN s_werks
         AND blnum  IN s_blnum  "25B/L 번호.
         AND bldty  IN s_bldty                              "1문서종류.
         AND rptty  IN s_rptty  "1수입신고구분.
         AND ekorg  IN s_ekorg                              "4구매조직.
         AND ekgrp  IN s_ekgrp                              "3구매그룹.
         AND lifnr  IN s_lifnr  "10공급업체 계정번호.
         AND bletd  IN s_bletd  "8ETD(출발 예정 시각).
         AND bleta  IN s_bleta  "8ETA(도착 예정 시각).
         AND fwdty  IN s_fwdty  "1운송 방법.
         AND waers  IN s_waers                              "5통화키.
         AND lgayn  IN s_lgayn  "LG대상여부.
         AND cnam   IN s_cnam                               "12작성인.
         AND cdat   IN s_cdat                               "8생성일.
         AND ctme   IN s_ctme                               "6생성시간.
         AND unam   IN s_unam   "12최종변경인.
         AND udat   IN s_udat                               "8변경일.
         AND utme   IN s_utme.  "6최종변경시간.

  IF sy-subrc NE 0.
    MESSAGE s902.
  ENDIF.

  ASSIGN LOCAL COPY OF INITIAL LINE OF <gt_table> TO <ls_table>.
*  FIELD-SYMBOLS: <ls_table>.
  FIELD-SYMBOLS: <l_field3>.
  FIELD-SYMBOLS: <l_field4>.
  FIELD-SYMBOLS: <l_field5>.
  FIELD-SYMBOLS: <l_field6>.
  FIELD-SYMBOLS: <l_field7>.

  DATA: l_ddtext LIKE dd07t-ddtext,
        l_txz01  LIKE ekpo-txz01.

  LOOP AT <gt_table> INTO <ls_table>.
    g_tabix = sy-tabix.
    ASSIGN COMPONENT 'BLDST' OF STRUCTURE
                        <ls_table> TO <l_field1>.

    ASSIGN COMPONENT 'DDTEXT' OF STRUCTURE
                        <ls_table> TO <l_field2>.

    ASSIGN COMPONENT 'EBELN' OF STRUCTURE
                        <ls_table> TO <l_field3>.

    ASSIGN COMPONENT 'TXZ01' OF STRUCTURE
                        <ls_table> TO <l_field4>.

    ASSIGN COMPONENT 'REQNO' OF STRUCTURE
                        <ls_table> TO <l_field5>.

    ASSIGN COMPONENT 'IBLNO' OF STRUCTURE
                        <ls_table> TO <l_field6>.

    ASSIGN COMPONENT 'OPNNO' OF STRUCTURE
                        <ls_table> TO <l_field7>.


    SELECT ebeln reqno txz01
      INTO (<l_field3>, <l_field5>, <l_field4>)
      FROM ztitblp UP TO 1 ROWS
     WHERE iblno EQ  <l_field6>
       AND iblit IN  s_iblit
       AND ebeln IN  s_ebeln
       AND ebelp IN  s_ebelp
       AND reqno IN  s_reqno
       AND reqit IN  s_reqit
       AND ndfty IN  s_ndfty.
    ENDSELECT.
    IF sy-subrc NE 0.
      DELETE <gt_table> INDEX g_tabix.
      CONTINUE.
    ENDIF.

    SELECT opnno
      INTO <l_field7>
      FROM ztivrq00
     WHERE reqno  EQ <l_field5>.
    ENDSELECT.

    PERFORM  get_domain_value_text(ztir0000) USING 'ZTIBLDST'
                                                   <l_field1>
                                                   <l_field2>.
    MODIFY <gt_table> FROM <ls_table>.

  ENDLOOP.


  DESCRIBE TABLE <gt_table> LINES g_line.
  IF g_line EQ 0.
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

  ac 'ITAB   BOX   ZTISRQIT                     FLAG  X'.

  ac 'ITAB   BLDST ZTIVBL00                     BLDST X '.
  ac 'ITAB   DDTEXTDD07T                        DDTEXT'.

  ac 'ITAB   BLNUM ZTIVBL00                     BLNUM '.
  ac 'ITAB   IBLNO ZTIVBL00                     IBLNO  '.
  ac 'ITAB   BLDAT ZTIVBL00                     BLDAT  '.

  ac 'ITAB   EBELN ZTIVBL00                     EBELN '.
  ac 'ITAB   BLCNT ZTIVBL00                     BLCNT '.
  ac 'ITAB   OPNNO ZTIVRQ00                     OPNNO '.
  ac 'ITAB   REQNO ZTIVRQ00                     REQNO X'.
*> 공급업체.
  ac 'ITAB   LIFNR ZTIVRQ00                     LIFNR '.
  ac 'ITAB   NAME1 LFA1                         NAME1 '.

  ac 'ITAB   IVSLN ZTIVBL00                     IVSLN '.
  ac 'ITAB   FLAND ZTIVBL00                     FLAND '.
  ac 'ITAB   FPORT ZTIVBL00                     FPORT '.
  ac 'ITAB   PLLOD ZTIVBL00                     PLLOD X'.
  ac 'ITAB   TLAND ZTIVBL00                     TLAND X '.
  ac 'ITAB   TPORT ZTIVBL00                     TPORT X '.
  ac 'ITAB   PLTRN ZTIVBL00                     PLTRN X '.

  ac 'ITAB   TXZ01 ZTIVBL00                     TXZ01  '.
  ac 'ITAB   WAERS ZTIVBL00                     WAERS  '.
  ac 'ITAB   IVAMT ZTIVBL00                     IVAMT  CWAERS'.

  ac 'ITAB   INCO1 ZTIVBL00                     INCO1  '.
  ac 'ITAB   BLETD ZTIVBL00                     BLETD  '.
  ac 'ITAB   BLETA ZTIVBL00                     BLETA  '.
  ac 'ITAB   INBDT ZTIVBL00                     INBDT  '.

*> Create field catagory table
  CALL FUNCTION 'LVC_FIELDCATALOG_MERGE'
    EXPORTING
      i_structure_name       = 'ZTIVBL00'
      i_client_never_display = 'X'
    CHANGING
      ct_fieldcat            = it_fieldcat_g[].

*>Adjust ALV field category
  PERFORM adjust_fieldcat.         ">Adjust ALV field category

  fc1[] = fc[].

  ac 'ITAB   COLOR SLIS_T_SPECIALCOL_ALV              X'.

  LOOP AT fc1 INTO fcs.
    CLEAR: fcs-key .
    CASE fcs-fieldname.
      WHEN 'BLNUM'.
        fcs-hotspot = 'X'.
        fcs-key     = 'X'.
      WHEN 'IBLNO'.
        fcs-hotspot = 'X'.
        fcs-key     = 'X'.
      WHEN 'DDTEXT'.
        fcs-seltext_l     = '문서상태'.
        fcs-seltext_m     = '문서상태'.
        fcs-seltext_s     = '문서상태'.
        CLEAR fcs-ref_fieldname.
      WHEN OTHERS.
*        CLEAR : fcs-no_out.
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


  CASE 'X'.
    WHEN p_step1. ">의뢰대상
      SET TITLEBAR 'T1000' WITH '선적예정정보 대상'.
    WHEN p_step2. ">접수대상
      SET TITLEBAR 'T1000' WITH '송부처 입력'.
    WHEN p_step3. ">신청대상
      SET TITLEBAR 'T1000' WITH '실입항 입력'.
    WHEN p_step4. ">전체
      SET TITLEBAR 'T1000' WITH '통관요청'.
    WHEN p_step5. ">전체
      SET TITLEBAR 'T1000' WITH '전체'.
  ENDCASE.

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
  gs_layout-box_fieldname     = 'BOX'.
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


  APPEND 'ARCHIVE'   TO extab.
  APPEND '&VEXCEL'   TO extab.
  APPEND '&AQW'      TO extab.
  APPEND '&VCRYSTAL' TO extab.
  APPEND '&VGRID'    TO extab.
  APPEND '&EB9'      TO extab.
  APPEND '&CRDESIG'  TO extab.
*----------------------------------------------------------------------
*  : 의뢰대상
*C : 수입의뢰
*A : 접수완료
*W : 신청서작성
*Y : 개설신청
*N : 개설취소
*O : 개설완료
*R : 접수반려
*----------------------------------------------------------------------
  CASE 'X'.
    WHEN p_step1.	">의뢰대상
      APPEND 'ZTIT002'  TO extab.
      APPEND 'ZTIT005'  TO extab.
      APPEND 'ZTIT207'  TO extab.

    WHEN p_step2. ">신청대상
*      APPEND 'ZTIT002'  TO extab.
*      APPEND 'ZTIT005'  TO extab.
      APPEND 'ZTIT207'  TO extab.
    WHEN p_step3. ">개설의뢰 진행 중
      APPEND 'ZTIT002'  TO extab.
      APPEND 'ZTIT005'  TO extab.
    WHEN p_step4. ">완료
      APPEND 'ZTIT002'  TO extab.
      APPEND 'ZTIT005'  TO extab.
      APPEND 'ZTIT207'  TO extab.
    WHEN p_step5. ">전체.
*      APPEND 'ZTIT002'  TO extab.
*      APPEND 'ZTIT005'  TO extab.
      APPEND 'ZTIT207'  TO extab.
  ENDCASE.

  SET PF-STATUS 'STANDARD' EXCLUDING extab.

ENDFORM.                    " SET_ALV_STATUS

*&---------------------------------------------------------------------*
*&      Form  USER_ALV_COMMAND
*&---------------------------------------------------------------------*
FORM user_alv_command USING   r_ucomm      LIKE sy-ucomm
                              rs_selfield  TYPE slis_selfield.
*
  DATA: l_count   TYPE i.
  DATA: l_index   TYPE i.
  DATA: l_answer  TYPE c.
  DATA: l_subrc   LIKE sy-subrc.
  DATA: l_tcode   LIKE sy-tcode.
  DATA: l_date(10).

  DATA : BEGIN OF it_prt_doc  OCCURS 0.
          INCLUDE STRUCTURE ztss_prt_documents.
  DATA : END   OF it_prt_doc.

  DATA : BEGIN OF it_ztsprtctl  OCCURS 0.
          INCLUDE STRUCTURE ztssprtctl.
  DATA : END   OF it_ztsprtctl.

  DATA: lt_seldoc LIKE zts_docno OCCURS 0 WITH HEADER LINE.

  FIELD-SYMBOLS: <ls_table>.
  FIELD-SYMBOLS: <l_field>.
  FIELD-SYMBOLS: <l_field1>.
  FIELD-SYMBOLS: <l_field2>.
  FIELD-SYMBOLS: <l_field3>.

  ASSIGN LOCAL COPY OF INITIAL LINE OF <gt_table> TO <ls_table>.

  CASE r_ucomm.
    WHEN 'ZTITRPT'.   ">선적서류송부통지서.
      ASSIGN COMPONENT 'BOX'   OF STRUCTURE <ls_table> TO <l_field>.
      ASSIGN COMPONENT 'IBLNO' OF STRUCTURE <ls_table> TO <l_field1>.
      CLEAR: l_count.
      REFRESH: lt_seldoc.
      LOOP AT <gt_table> INTO   <ls_table>.
        IF <l_field> EQ 'X'.
          lt_seldoc-docno = <l_field1>.  APPEND lt_seldoc.
          ADD 1 TO l_count.
        ENDIF.
      ENDLOOP.
      IF l_count EQ 0.
        MESSAGE s903.
      ENDIF.
      IF it_ztsprtctl[] IS INITIAL.
        REFRESH : it_ztsprtctl.
        CLEAR: it_ztsprtctl.

        LOOP AT it_ztsprtctl.
          MOVE sy-langu      TO    it_ztsprtctl-spras.
          MODIFY it_ztsprtctl INDEX sy-tabix.
        ENDLOOP.

        DESCRIBE TABLE it_ztsprtctl LINES g_line.
        IF g_line EQ 0.
          CLEAR: it_ztsprtctl.
          MOVE: t001-land1    TO    it_ztsprtctl-land1,
                sy-langu      TO    it_ztsprtctl-spras.
          APPEND it_ztsprtctl.
        ENDIF.
      ENDIF.

      CALL FUNCTION 'Z_TS_OUTPUTS_DOCUMENT_BY_TABLE'
        EXPORTING
          im_imexi            = 'I'
          im_docty            = 'BL'
          im_repid            = 'ZTIR2000'
          im_rread            = 'X'
        IMPORTING
          ex_answer           = l_answer
        TABLES
          ct_prtctl           = it_ztsprtctl
          ct_prt_doc          = it_prt_doc
          ct_docno            = lt_seldoc
        EXCEPTIONS
          no_output_documents = 1
          OTHERS              = 2.
      IF sy-subrc <> 0.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      ENDIF.

    WHEN 'ZTIT207'.   ">통관요청.
      ASSIGN COMPONENT 'BOX' OF STRUCTURE
                               <ls_table> TO <l_field>.
      CLEAR: l_count.
      LOOP AT <gt_table> INTO   <ls_table>.
        IF <l_field> EQ 'X'.
          ADD 1 TO l_count.
        ENDIF.
      ENDLOOP.
      IF l_count EQ 0.
        MESSAGE s903.
      ELSE.
        CLEAR: ok-code.
        ztisscrcom-ccrda  =  sy-datlo + 1.

        spop-textline1 = '선택된 선적서류들을 통관요청 합니다.'.
        spop-textline2 = '일괄로 통관요청을 하시겠습니까?'.

        CALL SCREEN  2000 STARTING AT 01    01.

        CHECK ok-code EQ 'ZTIOKAY'.

        REFRESH: bdcdata, it_msg.
        CLEAR: session.
        ctu_params-dismode  = 'E'. ">처리모드
        ctu_params-updmode  = 'S'. ">갱신모드
        ctu_params-cattmode = ' '. ">CATT 모드...
        ctu_params-defsize  = ' '. ">기본화면 크기
        ctu_params-racommit = 'X'.
        ctu_params-nobinpt  = ' ' .
        ctu_params-nobiend  = ' '.

        LOOP AT <gt_table> INTO   <ls_table>.
          IF <l_field> EQ 'X'.
*> 초기화면.
            ASSIGN COMPONENT 'IBLNO' OF STRUCTURE
                                  <ls_table> TO <l_field1>.

            PERFORM bdc_dynpro_build USING :
                   'X' 'ZTIR2000'          '0200',
                   ' ' 'ZTISSCRCOM-IBLNO'  <l_field1>,
                   ' ' 'BDC_OKCODE'       '=ZTIENTER'.
*> 세부화면.
            WRITE: ztisscrcom-ccrda TO l_date.
            PERFORM bdc_dynpro_build USING :
                   'X' 'ZTIR2000'          '2000',
                   ' ' 'ZTITBLK-CCRDA'     l_date,
                   ' ' 'BDC_OKCODE'       '=ZTIRECV'.

            PERFORM bdc_dynpro_build USING :
                   'X' 'SAPLSPO1'          '0300',
                   ' ' 'BDC_OKCODE'       '=YES'.

            PERFORM bdc_transaction USING 'ZTIT207' l_subrc.

            IF l_subrc EQ 0.
              LOOP AT messtab WHERE msgtyp EQ 'E'.
                MOVE : messtab-msgtyp  TO it_msg-msgty,
                       messtab-msgid   TO it_msg-msgid,
                       messtab-msgnr   TO it_msg-msgno,
                       messtab-msgv1   TO it_msg-msgv1,
                       messtab-msgv2   TO it_msg-msgv2,
                       messtab-msgv3   TO it_msg-msgv3,
                       messtab-msgv4   TO it_msg-msgv4,
                       <l_field1>      TO it_msg-refno.
                APPEND it_msg.
              ENDLOOP.
              IF sy-subrc NE 0.
                MESSAGE s247 WITH <l_field1>.
                MOVE:  sy-msgid   TO  it_msg-msgid,
                       sy-msgty   TO  it_msg-msgty,
                       sy-msgno   TO  it_msg-msgno,
                       sy-msgv1   TO  it_msg-msgv1,
                       sy-msgv2   TO  it_msg-msgv2,
                       sy-msgv3   TO  it_msg-msgv3,
                       sy-msgv4   TO  it_msg-msgv4,
                       <l_field1> TO  it_msg-refno.
                APPEND it_msg.
              ENDIF.
            ELSE.
              LOOP AT messtab WHERE msgtyp EQ 'E'.
                MOVE : messtab-msgtyp  TO it_msg-msgty,
                       messtab-msgid   TO it_msg-msgid,
                       messtab-msgnr   TO it_msg-msgno,
                       messtab-msgv1   TO it_msg-msgv1,
                       messtab-msgv2   TO it_msg-msgv2,
                       messtab-msgv3   TO it_msg-msgv3,
                       messtab-msgv4   TO it_msg-msgv4,
                       <l_field1>      TO it_msg-refno.
                APPEND it_msg.
              ENDLOOP.
              IF sy-subrc NE 0.
                MESSAGE s926.
                MOVE:  sy-msgid   TO  it_msg-msgid,
                       'E'        TO  it_msg-msgty,
                       sy-msgno   TO  it_msg-msgno,
                       sy-msgv1   TO  it_msg-msgv1,
                       sy-msgv2   TO  it_msg-msgv2,
                       sy-msgv3   TO  it_msg-msgv3,
                       sy-msgv4   TO  it_msg-msgv4,
                       <l_field1> TO  it_msg-refno.
                APPEND it_msg.
              ENDIF.
            ENDIF.
          ENDIF.
        ENDLOOP.
        DESCRIBE TABLE it_msg LINES g_line.
        IF g_line GT 0.
          CALL FUNCTION 'Z_TI_POPUP_TO_ERROR_MESSAGE'
            EXPORTING
              xdocno_show = 'X'
            TABLES
              xmsg        = it_msg.
        ENDIF.
        PERFORM get_data_for_display.    ">data select
        rs_selfield-refresh = 'X'.

      ENDIF.

    WHEN 'ZTIT005'.
      ASSIGN COMPONENT 'BOX' OF STRUCTURE
                               <ls_table> TO <l_field>.
      CLEAR: l_count.
      LOOP AT <gt_table> INTO   <ls_table>.
        IF <l_field> EQ 'X'.
          ADD 1 TO l_count.
        ENDIF.
      ENDLOOP.
      IF l_count EQ 0.
        MESSAGE s903.
      ELSE.
        PERFORM set_initail_ip_batchdata.

        REFRESH: bdcdata, it_msg.
        CLEAR: session.
        ctu_params-dismode  = 'A'. ">처리모드
        ctu_params-updmode  = 'S'. ">갱신모드
        ctu_params-cattmode = ' '. ">CATT 모드...
        ctu_params-defsize  = ' '. ">기본화면 크기
        ctu_params-racommit = 'X'.
        ctu_params-nobinpt  = ' ' .
        ctu_params-nobiend  = ' '.
*
        LOOP AT <gt_table> INTO   <ls_table>.
          IF <l_field> EQ 'X'.
*> 초기화면.
            ASSIGN COMPONENT 'REQNO' OF STRUCTURE
                                  <ls_table> TO <l_field1>.
*            ASSIGN COMPONENT 'AMDSQ' OF STRUCTURE
*                                  <ls_table> TO <l_field2>.

            PERFORM bdc_dynpro_build USING :
                   'X' 'ZTIR1000'          '0100',
                   ' ' 'ZTISSCRCOM-REQNO'  <l_field1>,
                   ' ' 'BDC_OKCODE'       '=ZTIENTER'.
*> 세부화면.
            PERFORM bdc_dynpro_build USING :
                   'X' 'ZTIR1000'         '2000'.

            PERFORM bdc_dynpro_build USING :
                   ' ' 'BDC_OKCODE'       '=ZTIREQUEST'.

            PERFORM bdc_dynpro_build USING :
                   'X' 'SAPLSPO1'         '0300',
                   ' ' 'BDC_OKCODE'       '=YES'.

            PERFORM bdc_transaction USING 'ZTIT101' l_subrc.

            IF l_subrc EQ 0.
              MESSAGE s121 WITH <l_field1>.
              MOVE:  sy-msgid   TO  it_msg-msgid,
                     sy-msgty   TO  it_msg-msgty,
                     sy-msgno   TO  it_msg-msgno,
                     sy-msgv1   TO  it_msg-msgv1,
                     sy-msgv2   TO  it_msg-msgv2,
                     sy-msgv3   TO  it_msg-msgv3,
                     sy-msgv4   TO  it_msg-msgv4,
                     <l_field1> TO  it_msg-refno.
              APPEND it_msg.
            ELSE.
              LOOP AT messtab WHERE msgtyp EQ 'E'.
                MOVE : messtab-msgtyp  TO it_msg-msgty,
                       messtab-msgid   TO it_msg-msgid,
                       messtab-msgnr   TO it_msg-msgno,
                       messtab-msgv1   TO it_msg-msgv1,
                       messtab-msgv2   TO it_msg-msgv2,
                       messtab-msgv3   TO it_msg-msgv3,
                       messtab-msgv4   TO it_msg-msgv4,
                       <l_field1>      TO it_msg-refno.
                APPEND it_msg.
              ENDLOOP.
              IF sy-subrc NE 0.
                MESSAGE s926.
                MOVE:  sy-msgid   TO  it_msg-msgid,
                       'E'        TO  it_msg-msgty,
                       sy-msgno   TO  it_msg-msgno,
                       sy-msgv1   TO  it_msg-msgv1,
                       sy-msgv2   TO  it_msg-msgv2,
                       sy-msgv3   TO  it_msg-msgv3,
                       sy-msgv4   TO  it_msg-msgv4,
                       <l_field1> TO  it_msg-refno.
                APPEND it_msg.
              ENDIF.
            ENDIF.
          ENDIF.
        ENDLOOP.
        DESCRIBE TABLE it_msg LINES g_line.
        IF g_line GT 0.
          CALL FUNCTION 'Z_TI_POPUP_TO_ERROR_MESSAGE'
            EXPORTING
              xdocno_show = 'X'
            TABLES
              xmsg        = it_msg.
        ENDIF.
        PERFORM get_data_for_display.    ">data select
        rs_selfield-refresh = 'X'.
      ENDIF.

    WHEN 'ZTIT002'.
      ASSIGN COMPONENT 'BOX' OF STRUCTURE
                               <ls_table> TO <l_field>.
      CLEAR: l_count.
      LOOP AT <gt_table> INTO   <ls_table>.
        IF <l_field> EQ 'X'.
          ADD 1 TO l_count.
          l_index = sy-tabix.
        ENDIF.
      ENDLOOP.
      IF l_count NE 1.
        MESSAGE s903.
      ELSE.
        READ TABLE <gt_table> INTO   <ls_table>
                              INDEX l_index.

        ASSIGN COMPONENT 'REQNO' OF STRUCTURE
                              <ls_table> TO <l_field1>.
*        ASSIGN COMPONENT 'AMDSQ' OF STRUCTURE
*                              <ls_table> TO <l_field2>.
        SET PARAMETER ID 'ZTIREQNO' FIELD <l_field1>.
*          SET PARAMETER ID 'ZTIAMDSQ' FIELD <l_field2>.
        CALL TRANSACTION 'ZTIT101' AND SKIP FIRST SCREEN .
        PERFORM get_data_for_display.    ">data select
        rs_selfield-refresh = 'X'.
      ENDIF.

    WHEN 'DISPLAY' OR '&IC1'.    " AUF DOPPELKLICK REAGIERIEN
      CHECK rs_selfield-tabindex GT 0.

      READ TABLE <gt_table> INTO <ls_table> INDEX rs_selfield-tabindex.
      IF sy-subrc NE 0.
        MESSAGE s906.            EXIT.
      ENDIF.

      ASSIGN COMPONENT 'IBLNO' OF STRUCTURE
                            <ls_table> TO <l_field1>.

      CASE rs_selfield-fieldname.
        WHEN 'IBLNO'.
          SET PARAMETER ID 'ZTIIBLNO' FIELD <l_field1>.
          CALL TRANSACTION 'ZTIT203' AND SKIP FIRST SCREEN.
        WHEN 'OPNNO' OR 'REQNO'.
          ASSIGN COMPONENT 'REQNO' OF STRUCTURE
                            <ls_table> TO <l_field1>.
          SELECT SINGLE *
            FROM ztitrqk
           WHERE reqno  EQ  <l_field1>.
          IF sy-subrc EQ 0.
            PERFORM excute_import_document(ztir0000)
                                 USING <l_field1> ztitrqk-lstas
                                       'ZTIT003'.
          ENDIF.
        WHEN OTHERS.              ">해당작업수행..
          SET PARAMETER ID 'ZTIIBLNO' FIELD <l_field1>.
          CASE 'X'.
            WHEN p_step1.
              CALL TRANSACTION 'ZTIT205' AND SKIP FIRST SCREEN.
            WHEN p_step2.
              CALL TRANSACTION 'ZTIT206' AND SKIP FIRST SCREEN.
            WHEN p_step3.
              CALL TRANSACTION 'ZTIT207' AND SKIP FIRST SCREEN.
            WHEN p_step4.
              CALL TRANSACTION 'ZTIT431' AND SKIP FIRST SCREEN.
            WHEN p_step5.
              CALL TRANSACTION 'ZTIT203' AND SKIP FIRST SCREEN.
          ENDCASE.
          IF p_step5 NE 'X'.
            PERFORM get_data_for_display.    ">data select
            rs_selfield-refresh = 'X'.
          ENDIF.
      ENDCASE.

  ENDCASE.
  CLEAR: r_ucomm.

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

*  CLEAR  st_sort.
*  st_sort-spos = '01'.
*  st_sort-fieldname = 'REQNO'.
*  st_sort-tabname   = '<GT_TABLE>'.
*  st_sort-up        = 'X'.
**  ST_SORT-GROUP     = 'X'.
*  st_sort-subtot    = 'X'.
**  ST_SORT-EXPA      = 'X'.
*  APPEND st_sort TO it_sort.
*
*  CLEAR  st_sort.
*  st_sort-spos = '02'.
*  st_sort-fieldname = 'MTBEZ'.
*  st_sort-tabname   = 'ITAB'.
*  st_sort-up        = 'X'.
**  ST_SORT-GROUP     = 'X'.
**  ST_SORT-SUBTOT    = 'X'.
**  ST_SORT-EXPA      = 'X'.
*  APPEND st_sort TO it_sort.
*
*  CLEAR  st_sort.
*  st_sort-spos = '03'.
*  st_sort-fieldname = 'EBELN'.
*  st_sort-tabname   = 'ITAB'.
*  st_sort-up        = 'X'.
**  ST_SORT-GROUP     = 'X'.
**  ST_SORT-SUBTOT    = 'X'.
**  ST_SORT-EXPA      = 'X'.
*  APPEND st_sort TO it_sort.

ENDFORM.                    " SET_SORT_FIELD

*&---------------------------------------------------------------------*
*&      Form  TOP_OF_PAGE
*&---------------------------------------------------------------------*
FORM top_of_page.

  DATA: l_mode TYPE i.
  DATA: header TYPE slis_listheader OCCURS 0 WITH HEADER LINE.

  REFRESH header.

  header-typ = 'H'.
  CASE 'X'.
    WHEN p_step1.
      header-info = '선적예정정보 현황'.
    WHEN p_step2.
      header-info = '선적서류 송부 현황'.
    WHEN p_step3.
      header-info = '실입항 입력 현황'.
    WHEN p_step4.
      header-info = '통관요청된 현황'.
    WHEN p_step5.
      header-info = '전체 현황'.
  ENDCASE.

  CLEAR: header-key.
  APPEND header.

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

  header-typ = 'S'.
  header-key = '출력일자'(106).
  WRITE: sy-datlo TO header-info.
  APPEND header.

  CALL FUNCTION 'REUSE_ALV_COMMENTARY_WRITE'
    EXPORTING
      it_list_commentary = header[].

ENDFORM.    ">TOP_OF_PAGE
*&---------------------------------------------------------------------*
*&      Form  MATERIAL_MASTER_DISPLAY
*&---------------------------------------------------------------------*
FORM material_master_display USING rs_selfield  TYPE slis_selfield.

  FIELD-SYMBOLS: <ls_table>.

  READ TABLE <gt_table> INTO <ls_table>
                        INDEX rs_selfield-tabindex. "cursorposit.
  IF sy-subrc EQ 0.
*    MOVE-CORRESPONDING <ls_table> TO xitab.
*
*    READ TABLE organ WITH KEY werks = xitab-werks.
*
*    SET PARAMETER ID 'MAT' FIELD xitab-matnr.
*    SET PARAMETER ID 'BUK' FIELD organ-bukrs.
*    SET PARAMETER ID 'WRK' FIELD xitab-werks.
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
    <l_name> = 'REQTY'.
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

  FIELD-SYMBOLS: <ls_table>,
                 <l_field>.

  DATA: lt_fieldcat_g TYPE lvc_t_fcat.

*>Internal table에 존재하지 않는 필드.
  LOOP AT it_fieldcat_g INTO gs_fieldcat_g.
    READ TABLE fc INTO fcs WITH KEY fieldname = gs_fieldcat_g-fieldname.
    IF sy-subrc NE 0.
      IF NOT gs_fieldcat_g-fieldname IS INITIAL AND
         gs_fieldcat_g-fieldname     NE 'MANDT'.
        MOVE-CORRESPONDING  gs_fieldcat_g TO fcs.
        MOVE: gs_fieldcat_g-fieldname     TO fcs-ref_fieldname,
              'ZTIVBL00'                  TO fcs-ref_tabname.
        CLEAR: fcs-key.
        fcs-no_out = 'X'.
        APPEND fcs TO fc.
      ENDIF.
    ENDIF.
    DESCRIBE TABLE fc LINES g_line.
    IF g_line GT 50.
      EXIT.
    ENDIF.
  ENDLOOP.

ENDFORM.                    " ADJUST_fieldcat
*&---------------------------------------------------------------------*
*&      Form  SET_INITAIL_IP_BATCHDATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM set_initail_ip_batchdata .

ENDFORM.                    " SET_INITAIL_IP_BATCHDATA
*&---------------------------------------------------------------------*
*&      Module  pbo_status_2000  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE pbo_status_2000 OUTPUT.

  SET PF-STATUS '2000'.
  SET TITLEBAR  'T2000'.

  CLEAR: ok-code.

ENDMODULE.                 " pbo_status_2000  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  fcode_exit_scr2000  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE fcode_exit_scr2000 INPUT.

  LEAVE TO SCREEN 0.

ENDMODULE.                 " fcode_exit_scr2000  INPUT
*&---------------------------------------------------------------------*
*&      Module  check_input_fields  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE check_input_fields INPUT.

  CHECK ok-code EQ 'ZTIOKAY'.

  IF ztisscrcom-ccrda IS INITIAL.
    PERFORM  no_input_check(ztir0000) USING 'ZTISSCRCOM'
                                            'CCRDA' 'E'.
  ENDIF.

ENDMODULE.                 " check_input_fields  INPUT
*&---------------------------------------------------------------------*
*&      Module  user_command_scr2000  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_scr2000 INPUT.

  CASE ok-code.
    WHEN 'ZTIOKAY'.
      LEAVE TO SCREEN 0.
    WHEN 'ZTICANCEL'.
      LEAVE TO SCREEN 0.
    WHEN OTHERS.
  ENDCASE.

ENDMODULE.                 " user_command_scr2000  INPUT
