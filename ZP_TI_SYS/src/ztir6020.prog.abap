************************************************************************
*                                                                      *
* Title         : ZTIR6020                                             *
*                                                                      *
* Description   : [Report] L/G 현황 Report                             *
*                                                                      *
* Creation Date : 2004/02/23                                           *
*                                                                      *
* Author        : Seung Jun, Lee.                                      *
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
PROGRAM   ztir6020
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
        ztitrqk,  ">[Import] Document Header
        ztitrqs,  ">[Import] Document Status
        ztitrqp,  ">[Import] Document Items
        ztivrq02,  ">header + status Views
        ztitlg1,
        ztivlg01.


************************************************************************
* CONSTANTS                                                            *
************************************************************************
CONSTANTS:
** JS전선 회사코드 2007/04 --------------------------------------
*    c_bukrs     LIKE t001-bukrs     VALUE '1000',   ">Company code
** JS전선 회사코드 2007/04 --------------------------------------
    c_save(1)   TYPE  c             VALUE 'A'.

************************************************************************
* SELECT-OPTIONS / PARAMETERS                                          *
************************************************************************
SELECTION-SCREEN BEGIN OF BLOCK box1 WITH FRAME TITLE text-001.
SELECT-OPTIONS:
   s_bukrs  FOR ztivlg01-bukrs   "회사코드.
                     NO-EXTENSION NO INTERVALS OBLIGATORY
                     MEMORY ID buk ,
   s_ilgno  FOR ztivlg01-ilgno,  "L/G 관리번호
   s_iblno  FOR ztivlg01-iblno,  "B/L 관리번호
   s_glgno  FOR ztivlg01-glgno,  "인도승락서 번호
   s_glgdt  FOR ztivlg01-glgdt,  "발급일자
   s_galcd  FOR ztivlg01-galcd,  "신청서코드(해상/항공)
   s_galdt  FOR ztivlg01-galdt,  "신청일자
   s_docst  FOR ztivlg01-docst,  "문서상태
   s_sndst  FOR ztivlg01-sndst,  "EDI 송수신 상태
   s_cnam   FOR ztivlg01-cnam ,  "
   s_cdat   FOR ztivlg01-cdat ,  "
   s_unam   FOR ztivlg01-unam ,  "
   s_udat   FOR ztivlg01-udat .  "
SELECTION-SCREEN ULINE.
SELECT-OPTIONS:
   s_gapnm  FOR ztivlg01-gapnm,  "신청인 상호
   s_gapad1 FOR ztivlg01-gapad1, "신청인 주소
   s_gapad2 FOR ztivlg01-gapad2, "신청인 주소
   s_gbenm  FOR ztivlg01-gbenm,  "송화인 상호
   s_gbead1 FOR ztivlg01-gbead1, "송화인 주소
   s_gbead2 FOR ztivlg01-gbead2, "송화인 주소
   s_gnonm  FOR ztivlg01-gnonm,  "명의인 상호
   s_gnopr  FOR ztivlg01-gnopr,  "명의인 대표자
   s_gnoid  FOR ztivlg01-gnoid,  "명의인 전자서명
   s_gtcnm  FOR ztivlg01-gtcnm,  "운송회사 상호
   s_gtcad  FOR ztivlg01-gtcad,  "운송회사 주소
   s_gtcid  FOR ztivlg01-gtcid,  "운송회사 수발신인식별자
*   s_gconm1 FOR ztivlg01-gconm1, "수하인
*   s_gconm2 FOR ztivlg01-gconm2, "수하인
*   s_gconm3 FOR ztivlg01-gconm3, "수하인
   s_gcenm1 FOR ztivlg01-gcenm1, "인수예정자
   s_gcenm2 FOR ztivlg01-gcenm2, "인수예정자
   s_gcenm3 FOR ztivlg01-gcenm3, "인수예정자
   s_givatc FOR ztivlg01-givatc, "상업송장통화
   s_givat  FOR ztivlg01-givat,  "상업송장금액
   s_glcty  FOR ztivlg01-glcty,  "신용장/계약서
   s_glcno  FOR ztivlg01-glcno,  "신용장/계약서번호
   s_glcdt  FOR ztivlg01-glcdt,  "신용장개설일자
   s_gblty  FOR ztivlg01-gblty,  "선화증권/운송장
   s_gblno  FOR ztivlg01-gblno,  "선화증권/운송장번호
   s_gcarn  FOR ztivlg01-gcarn,  "항차/편명
   s_gvsln  FOR ztivlg01-gvsln,  "선명/기명
   s_gardt  FOR ztivlg01-gardt,  "도착(예정일)
   s_gbldt  FOR ztivlg01-gbldt,  "선화증권발급일자
   s_gshcd  FOR ztivlg01-gshcd,  "선적국가/출발국가
   s_gshnm  FOR ztivlg01-gshnm,  "선적지/출발지명
   s_gldcd  FOR ztivlg01-gldcd,  "도착국가
   s_gldnm  FOR ztivlg01-gldnm,  "도착지명
   s_gpkgnu FOR ztivlg01-gpkgnu, "포장단위
   s_gpkgn  FOR ztivlg01-gpkgn,  "포장수
   s_gpydc  FOR ztivlg01-gpydc,  "결제기간코드
   s_gpydt  FOR ztivlg01-gpydt,  "결제기간
   s_gibcd  FOR ztivlg01-gibcd,  "발급은행코드
   s_gibnm  FOR ztivlg01-gibnm,  "발급은행명
   s_gibbr  FOR ztivlg01-gibbr,  "발급은행지점명
   s_appun  FOR ztivlg01-appun MODIF ID req,     "개설의뢰 요청자.
   s_appdt  FOR ztivlg01-appdt MODIF ID req,     "개설의뢰 요청일.
   s_accun  FOR ztivlg01-accun MODIF ID apy,     "요청접수 담당자.
   s_accdt  FOR ztivlg01-accdt MODIF ID apy,     "요청접수일자.
   s_sndun  FOR ztivlg01-sndun MODIF ID sed,     "개설신청자.
   s_snddt  FOR ztivlg01-snddt MODIF ID sed,     "개설신청일.
   s_rcvun  FOR ztivlg01-rcvun MODIF ID opn,     "개설등록자.
   s_rcvdt  FOR ztivlg01-rcvdt MODIF ID opn,     "개설등록일자.
   s_ctme   FOR ztivlg01-ctme ,  "
   s_utme   FOR ztivlg01-utme .  ".
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
       line_cnt(02)    TYPE  n,
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

  SET TITLEBAR 'T1000' WITH '상태별 수입의뢰'.

** JS전선 회사코드 2007/04 --------------------------------------
*  FREE: s_bukrs.    CLEAR: s_bukrs.
*  s_bukrs-sign   = 'I'.
*  s_bukrs-option = 'EQ'.
*  s_bukrs-low    = c_bukrs.
*  APPEND s_bukrs.
** JS전선 회사코드 2007/04 --------------------------------------

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
    MESSAGE e348(m7) WITH text-102.
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

  RANGES: lr_docst   FOR   ztitrqs-docst OCCURS 1.

  FIELD-SYMBOLS: <ls_table>.
  FIELD-SYMBOLS: <l_field1>.
  FIELD-SYMBOLS: <l_field2>.

  REFRESH : <gt_table>.
*> PROGRESS Display.
  g_line1    = 30.
  g_out_text = '데이타를 검색 중입니다 %99999%%'(p01).
  REPLACE '%99999%' WITH g_line1 INTO g_out_text.
  PERFORM show_progress_bar(ztir0000) USING g_out_text g_line1.

  CLEAR lr_docst .
*  MOVE: 'I'     TO    lr_docst-sign,
*        'EQ'    TO    lr_docst-option.
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
*  CASE 'X'.
*    WHEN p_step1.	">의뢰대상
*      MOVE: space TO  lr_docst-low.    APPEND lr_docst .
*      MOVE: 'R'   TO  lr_docst-low.    APPEND lr_docst .
*    WHEN p_step2. ">접수대상
*      MOVE: 'C'   TO  lr_docst-low.    APPEND lr_docst .
*    WHEN p_step3. ">신청대상
*      MOVE: 'A'   TO  lr_docst-low.    APPEND lr_docst .
*      MOVE: 'W'   TO  lr_docst-low.    APPEND lr_docst .
*      MOVE: 'N'   TO  lr_docst-low.    APPEND lr_docst .
*    WHEN p_step4. ">개설의뢰 진행 중
*      MOVE: 'Y'   TO  lr_docst-low.    APPEND lr_docst .
*    WHEN p_step5. ">개설완료
*      MOVE: 'O'   TO  lr_docst-low.    APPEND lr_docst .
*  ENDCASE.

*> 수입의뢰 데이타 select.
  SELECT *
    INTO CORRESPONDING FIELDS OF TABLE <gt_table>
    FROM ztivlg01
   WHERE bukrs  IN s_bukrs
     AND ilgno  IN s_ilgno  "L/G 관리번호
     AND iblno  IN s_iblno  "B/L 관리번호
     AND glgno  IN s_glgno  "인도승락서 번호
     AND glgdt  IN s_glgdt  "발급일자
     AND gapnm  IN s_gapnm  "신청인 상호
     AND gapad1 IN s_gapad1 "신청인 주소
     AND gapad2 IN s_gapad2 "신청인 주소
     AND gbenm  IN s_gbenm  "송화인 상호
     AND gbead1 IN s_gbead1 "송화인 주소
     AND gbead2 IN s_gbead2 "송화인 주소
     AND gnonm  IN s_gnonm  "명의인 상호
     AND gnopr  IN s_gnopr  "명의인 대표자
     AND gnoid  IN s_gnoid  "명의인 전자서명
     AND gtcnm  IN s_gtcnm  "운송회사 상호
     AND gtcad  IN s_gtcad  "운송회사 주소
     AND gtcid  IN s_gtcid  "운송회사 수발신인식별자
*     AND gconm1 IN s_gconm1 "수하인
*     AND gconm2 IN s_gconm2 "수하인
*     AND gconm3 IN s_gconm3 "수하인
     AND gcenm1 IN s_gcenm1 "인수예정자
     AND gcenm2 IN s_gcenm2 "인수예정자
     AND gcenm3 IN s_gcenm3 "인수예정자
     AND galcd  IN s_galcd  "신청서코드(해상/항공)
     AND galdt  IN s_galdt  "신청일자
     AND givatc IN s_givatc "상업송장통화
     AND givat  IN s_givat  "상업송장금액
     AND glcty  IN s_glcty  "신용장/계약서
     AND glcno  IN s_glcno  "신용장/계약서번호
     AND glcdt  IN s_glcdt  "신용장개설일자
     AND gblty  IN s_gblty  "선화증권/운송장
     AND gblno  IN s_gblno  "선화증권/운송장번호
     AND gcarn  IN s_gcarn  "항차/편명
     AND gvsln  IN s_gvsln  "선명/기명
     AND gardt  IN s_gardt  "도착(예정일)
     AND gbldt  IN s_gbldt  "선화증권발급일자
     AND gshcd  IN s_gshcd  "선적국가/출발국가
     AND gshnm  IN s_gshnm  "선적지/출발지명
     AND gldcd  IN s_gldcd  "도착국가
     AND gldnm  IN s_gldnm  "도착지명
     AND gpkgnu IN s_gpkgnu "포장단위
     AND gpkgn  IN s_gpkgn  "포장수
     AND gpydc  IN s_gpydc  "결제기간코드
     AND gpydt  IN s_gpydt  "결제기간
     AND gibcd  IN s_gibcd  "발급은행코드
     AND gibnm  IN s_gibnm  "발급은행명
     AND gibbr  IN s_gibbr  "발급은행지점명
     AND docst  IN s_docst  "문서상태
     AND sndst  IN s_sndst  "EDI 송수신 상태
     AND appun  IN s_appun     "개설의뢰 요청자.
     AND appdt  IN s_appdt     "개설의뢰 요청일.
     AND accun  IN s_accun     "요청접수 담당자.
     AND accdt  IN s_accdt     "요청접수일자.
     AND sndun  IN s_sndun     "개설신청자.
     AND snddt  IN s_snddt     "개설신청일.
     AND rcvun  IN s_rcvun     "개설등록자.
     AND rcvdt  IN s_rcvdt     "개설등록일자.
     AND cnam   IN s_cnam  "
     AND cdat   IN s_cdat   "
     AND ctme   IN s_ctme   "
     AND unam   IN s_unam   "
     AND udat   IN s_udat   "
     AND utme   IN s_utme .  "
*     AND docst  in lr_docst.

  IF sy-subrc NE 0.
    MESSAGE s902.
  ENDIF.

  ASSIGN LOCAL COPY OF INITIAL LINE OF <gt_table> TO <ls_table>.

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
  ac 'ITAB   ILGNO ZTIVLG01                     ILGNO '.
  ac 'ITAB   IBLNO ZTIVLG01                     IBLNO '.
  ac 'ITAB   GLGNO ZTIVLG01                     GLGNO '.
  ac 'ITAB   GLGDT ZTIVLG01                     GLGDT '.
  ac 'ITAB   DOCST ZTIVLG01                     DOCST '.
  ac 'ITAB   SNDST ZTIVLG01                     SNDST '.
  ac 'ITAB   GIVAT ZTIVLG01                     GIVAT  CWAERS '.
  ac 'ITAB   GIVATCZTIVLG01                     GIVATC'.
  ac 'ITAB   GVSLN ZTIVLG01                     GVSLN '.
*  ac 'ITAB   USAMT ZTIVLG01                     USAMT  CUCURR '.
*  ac 'ITAB   UCURR ZTIVLG01                     UCURR '.
  ac 'ITAB   CNAM  ZTIVLG01                     CNAM  '.
  ac 'ITAB   UNAM  ZTIVLG01                     UNAM  '.

*> Create field catagory table
  CALL FUNCTION 'LVC_FIELDCATALOG_MERGE'
    EXPORTING
      i_structure_name       = 'ZTIVLG01'
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
      WHEN 'ILGNO' OR 'IBLNO'.
        fcs-hotspot = 'X'.
        fcs-key     = 'X'.
      WHEN 'GIVAT'.
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
*  CASE 'X'.
*    WHEN p_step1.	">의뢰대상
*      SET TITLEBAR 'T1000' WITH '수입의뢰 요청대상'.
*    WHEN p_step2. ">접수대상
*      SET TITLEBAR 'T1000' WITH '수입의뢰 접수대상'.
*    WHEN p_step3. ">신청대상
*      SET TITLEBAR 'T1000' WITH '수입의뢰 신청대상'.
*    WHEN p_step4. ">개설의뢰 진행 중
*      SET TITLEBAR 'T1000' WITH '수입의뢰 신청 진행 중'.
*    WHEN p_step5. ">개설완료
*      SET TITLEBAR 'T1000' WITH '수입의뢰 개설'.
*  ENDCASE.

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
*  CASE 'X'.
*    WHEN p_step1.	">의뢰대상
*      APPEND 'ZTIT005'  TO extab.
*      APPEND 'ZTIT006'  TO extab.
*    WHEN p_step2. ">접수대상
*      APPEND 'ZTIT002'  TO extab.
*      APPEND 'ZTIT006'  TO extab.
*    WHEN p_step3. ">신청대상
*      APPEND 'ZTIT002'  TO extab.
*      APPEND 'ZTIT005'  TO extab.
*    WHEN p_step4. ">개설의뢰 진행 중
*      APPEND 'ZTIT002'  TO extab.
*      APPEND 'ZTIT005'  TO extab.
*      APPEND 'ZTIT006'  TO extab.
*    WHEN p_step5. ">개설완료
*      APPEND 'ZTIT002'  TO extab.
*      APPEND 'ZTIT005'  TO extab.
*      APPEND 'ZTIT006'  TO extab.
*  ENDCASE.
  APPEND 'ZTIT002'  TO extab.
  APPEND 'ZTIT005'  TO extab.
  APPEND 'ZTIT006'  TO extab.
  SET PF-STATUS 'STANDARD' EXCLUDING extab.

ENDFORM.                    " SET_ALV_STATUS

*&---------------------------------------------------------------------*
*&      Form  USER_ALV_COMMAND
*&---------------------------------------------------------------------*
FORM user_alv_command USING   r_ucomm      LIKE sy-ucomm
                              rs_selfield  TYPE slis_selfield.
*
  DATA: l_count   TYPE i.
  DATA: l_subrc   LIKE sy-subrc.
  DATA: l_tcode   LIKE sy-tcode.
  FIELD-SYMBOLS: <ls_table>.
  FIELD-SYMBOLS: <l_field>.
  FIELD-SYMBOLS: <l_field1>.
  FIELD-SYMBOLS: <l_field2>.

  ASSIGN LOCAL COPY OF INITIAL LINE OF <gt_table> TO <ls_table>.

  CASE r_ucomm.
    WHEN 'ZTIT002' OR 'ZTIT005' OR 'ZTIT006'.
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
        REFRESH: bdcdata, it_msg.
        CLEAR: session.
        ctu_params-dismode  = 'N'. ">처리모드
        ctu_params-updmode  = 'S'. ">갱신모드
        ctu_params-cattmode = ' '. ">CATT 모드...
        ctu_params-defsize  = ' '. ">기본화면 크기
        ctu_params-racommit = 'X'.
        ctu_params-nobinpt  = ' ' .
        ctu_params-nobiend  = ' '.

        LOOP AT <gt_table> INTO   <ls_table>.
          IF <l_field> EQ 'X'.
*> 초기화면.
            ASSIGN COMPONENT 'REQNO' OF STRUCTURE
                                  <ls_table> TO <l_field1>.
            ASSIGN COMPONENT 'AMDSQ' OF STRUCTURE
                                  <ls_table> TO <l_field2>.

            PERFORM bdc_dynpro_build USING :
                   'X' 'ZTIR0000'          '0200',
                   ' ' 'ZTISSCRCOM-REQNO'  <l_field1>,
                   ' ' 'ZTISSCRCOM-AMDSQ'  <l_field2>,
                   ' ' 'ZTISSCRCOM-EBELN'  space,
                   ' ' 'ZTISSCRCOM-OPNNO'  space,
                   ' ' 'BDC_OKCODE'       '=ZTIENTER'.
*> 세부화면.
            PERFORM bdc_dynpro_build USING :
                   'X' 'ZTIR0000'          '2000'.

            IF r_ucomm EQ 'ZTIT002'.       ">의뢰요청.
              PERFORM bdc_dynpro_build USING :
                     ' ' 'BDC_OKCODE'       '=ZTIREQUEST'.
            ELSEIF r_ucomm EQ 'ZTIT005'.   ">접수.
              PERFORM bdc_dynpro_build USING :
                     ' ' 'BDC_OKCODE'       '=ZTIACCEPT'.
            ELSEIF r_ucomm EQ 'ZTIT006'.   ">신청.
              PERFORM bdc_dynpro_build USING :
                     ' ' 'BDC_OKCODE'       '=ZTISEND'.
            ENDIF.

            PERFORM bdc_dynpro_build USING :
                   'X' 'SAPLSPO1'          '0300',
                   ' ' 'BDC_OKCODE'       '=YES'.

            PERFORM bdc_transaction USING r_ucomm l_subrc.

            IF l_subrc EQ 0.
              IF r_ucomm EQ 'ZTIT002'.
                MESSAGE s121 WITH <l_field1>.
              ELSEIF r_ucomm EQ 'ZTIT005'.
                MESSAGE s122 WITH <l_field1>.
              ELSEIF r_ucomm EQ 'ZTIT006'.
                MESSAGE s123 WITH <l_field1>.
              ENDIF.
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

    WHEN 'DISPLAY' OR '&IC1'.    " AUF DOPPELKLICK REAGIERIEN

      CHECK rs_selfield-tabindex GT 0.

      READ TABLE <gt_table> INTO <ls_table> INDEX rs_selfield-tabindex.
      IF sy-subrc NE 0.
        MESSAGE s906.            EXIT.
      ENDIF.
      ASSIGN COMPONENT 'IBLNO' OF STRUCTURE
                            <ls_table> TO <l_field1>.
      ASSIGN COMPONENT 'ILGNO' OF STRUCTURE
                            <ls_table> TO <l_field2>.

      CASE rs_selfield-fieldname.
        WHEN 'REQNO' OR 'AMDSQ'.
          PERFORM display_import_document(ztir0000)
                               USING <l_field1> <l_field2> '00000'.

        WHEN 'IBLNO'.
          PERFORM display_bl_document(ztir0000)
                            USING <l_field1>
                                  ''.
        WHEN 'ILGNO'.
          SET PARAMETER ID 'ZTIILGNO' FIELD <l_field2>.
          CALL TRANSACTION 'ZTIT603' AND SKIP FIRST SCREEN.
*      gs_list-ilgno = <l_field>.
*
*      CHECK NOT gs_list-ilgno IS INITIAL.
*
*      SET PARAMETER ID 'ZTIILGNO' FIELD gs_list-ilgno.
*      CALL TRANSACTION 'ZTIT603' AND SKIP FIRST SCREEN.
        WHEN OTHERS.              ">해당작업수행..
      ENDCASE.
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
*          CASE 'X'.
*            WHEN p_step1.	">의뢰대상
*               l_tcode = 'ZTIT002'.
*            WHEN p_step2. ">접수대상
*              l_tcode = 'ZTIT005'.
*            WHEN p_step3. ">신청대상
*              l_tcode = 'ZTIT006'.
*            WHEN p_step4. ">개설의뢰 진행 중
*              l_tcode = 'ZTIT007'.
*            WHEN p_step5. ">개설완료
*              l_tcode = 'ZTIT008'.
*          ENDCASE.
*
*          PERFORM excute_import_document(ZTIr0000)
*                               USING <l_field1> <l_field2> l_tcode.
*          PERFORM get_data_for_display.    ">data select
*          rs_selfield-refresh = 'X'.
*      ENDCASE.
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
  header-info = 'L/G 현황'.
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
*  CASE 'X'.
*    WHEN p_step1.	">의뢰대상
*       header-info = '수입의뢰 요청대상 현황'.
*    WHEN p_step2. ">접수대상
*      header-info = '수입의뢰 접수대상 현황'.
*    WHEN p_step3. ">신청대상
*      header-info = '수입의뢰 신청대상 현황'.
*    WHEN p_step4. ">개설의뢰 진행 중
*      header-info = '개설의뢰 진행 중 현황'.
*    WHEN p_step5. ">개설완료
*      header-info = '수입개설 현황'.
*  ENDCASE.

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
    MESSAGE s901 WITH ' '.
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
              'ZTIVLG01'                  TO fcs-ref_tabname.
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
