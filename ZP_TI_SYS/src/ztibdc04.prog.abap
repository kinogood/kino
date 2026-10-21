************************************************************************
* Title         :  ZTIBDC04                                            *
*                                                                      *
* Description   : [BDC] 선급금 물대등록 Upload                         *
*                                                                      *
* Creation Date : 2004/04/26                                           *
*                                                                      *
* Author        : Seog Bong, Kang                                      *
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
* 1.                                                                   *
* 2.                                                                   *
*                                                                      *
************************************************************************
*----------------------------------------------------------------------*
*                M O D I F I C A T I O N   L O G                       *
*----------------------------------------------------------------------*
* Date         Programmer       Transport#  Description                *
*----------------------------------------------------------------------*
* dd-mmm-yyyy  xxxxxxxxxxxxxxx  DVPK9xxxxx  xxxxxxxxxxxxxxxxxxxxxxxxx  *
*                                                                      *
*                                                                      *
************************************************************************
REPORT  ztibdc04       MESSAGE-ID zmmi
                       NO STANDARD PAGE HEADING.



************************************************************************
* TYPES and TYPE-POOLS                                                 *
************************************************************************
TYPE-POOLS: slis,   "> Globale Type(ALV)
            kkblo.

************************************************************************
* SAP Included                                                         *
************************************************************************
INCLUDE: <icon>,
         appl_log.   ">

************************************************************************
* SAP Tables                                                           *
************************************************************************
TABLES: ztitrqk,
        ztitrqs,
        ztitrqp,
        ztittt1,
        ztitblk,
        ztitblp,
        ztitivk,
        ztitivp,
        ztitivh,
        ztitivv,
        ztivrq00,
        ztivbl00,
        t001,
        dd04t,
        t604,
        ekko,
        ekpo,
        dfies .    ">DD Interface: Table Fields for DDIF_FIELDINFO_GET

************************************************************************
* Internal Tables                                                      *
************************************************************************
DATA: BEGIN OF it_fieldname OCCURS 0,
      fieldname   LIKE  dd03l-fieldname,
      END   OF it_fieldname.

*---------------------------------------------------------------------*
*> Message dialog box용                                               *
*---------------------------------------------------------------------*
DATA: BEGIN OF it_msg  OCCURS 0.
        INCLUDE STRUCTURE ztismessage.
DATA: END   OF it_msg.

DATA: BEGIN OF it_msg_list  OCCURS 0.
        INCLUDE STRUCTURE ztismessage.
DATA: END   OF it_msg_list.


TYPES:  BEGIN OF ty_upload,
*> HEADER
        blnum(25),            "B/L 번호.
        ivnum(20),            "Invoice Numner.
        opnno(20),            "개설문서번호.
        ivamp(20),            "미착금액(외화)
        ivwon(20),            "미착금액(원화).
        waers(05),            "Currnecy
        wwert(10),            "적용일자.
        kursf(12),            "적용환율.
*> ITEM
        ebeln(10),            "구매문서.
        ebelp(05),            "구매문서 품목번호.
        ivamt(20),            "품목별 금액.
        ivmng(17),            "품목별 수량.

        iblno(10),            "B/L 관리번호.
        iblit(05),            "B/L 품목번호.
        END   OF ty_upload.

DATA:  gs_upload   TYPE ty_upload.

DATA: gt_upload_list  LIKE gs_upload OCCURS 0 WITH HEADER LINE,
      gt_upload_title LIKE gs_upload OCCURS 0 WITH HEADER LINE,
      gs_upload_list  LIKE gs_upload.

DATA: BEGIN OF gs_download.
        INCLUDE STRUCTURE gs_upload.
DATA: reqno(10),            "수입의뢰 관리번호.
      reqit(05),            "수입의뢰 품목번호.
      ivono(10),            "송장관리번호.
      rblgp(05),            "송장품번.
      msgty      TYPE  bapi_mtype,
      msgtx      TYPE  bapi_msg,
      END   OF gs_download.

DATA: gt_download  LIKE gs_download OCCURS 0 WITH HEADER LINE.


DATA : BEGIN OF xztitivp OCCURS 0.
        INCLUDE STRUCTURE vztitivp.
DATA : END   OF xztitivp.


DATA: g_menget(18)     TYPE c,
      g_post_chk       TYPE c,
      g_wrbtr1(21)     TYPE c,
      g_wrbtr2(21)     TYPE c.


*      gs_down_t LIKE gs_list2 OCCURS 0 WITH HEADER LINE.
************************************************************************
* SAP Include Define                                                   *
************************************************************************
INCLUDE : <icon>,
          <symbol>.

************************************************************************
* SAP Tables                                                           *
************************************************************************
TABLES: icon.         "아이콘 테이블

************************************************************************
* SAP Views                                                            *
************************************************************************

************************************************************************
* CONSTANTS                                                            *
************************************************************************
*CONSTANTS:

************************************************************************
* DATA Declarations                                                    *
************************************************************************
* Global variables for handling ALV functionality
DATA: it_fieldcat_g TYPE lvc_t_fcat,
      gs_fieldcat_g LIKE LINE OF it_fieldcat_g.

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

DATA : gs_selfield TYPE slis_selfield.
DATA : gt_fieldcat TYPE slis_t_fieldcat_alv,
       gs_events   TYPE slis_alv_event,
       gt_events   TYPE slis_t_event,
       gs_gridset  TYPE lvc_s_glay.

************************************************************************
* DATA Declarations                                                    *
************************************************************************
DATA: g_repid             LIKE sy-repid.

DATA: gs_variante         LIKE disvariant,
      gs_def_variante     LIKE disvariant,
      g_variant_exit(1)   TYPE c,
      g_variant_save(1)   TYPE c,
      g_variant_def(1)    TYPE c.

DATA: g_tabix             LIKE sy-tabix,
      u_tabix             LIKE sy-tabix,
      g_index             LIKE sy-index,
      g_subrc             LIKE sy-subrc,
      g_answer            TYPE c,
      g_process           TYPE c,
      g_count             TYPE i,
      g_cnt               TYPE i,
      g_wrbtr             TYPE wrbtr,
      g_wmwst             TYPE wmwst,
      ok_code             LIKE sy-ucomm,
      g_line              TYPE i,
      b_line              TYPE i,
      g_success           TYPE i,
      g_error             TYPE i,
      g_linen(3)          TYPE n,
      g_out_text(70)      TYPE c,
      p_mode(1),
      g_text_amount(30).

DATA: file_path(1200),
      file_name(1200),
      p_down              LIKE rlgrap-filename,
      p_sdown             LIKE rlgrap-filename.

*---------------------------------------------------------------------*
*> BAPI Function용 변수.
*---------------------------------------------------------------------*
DATA: headerdata       LIKE bapi_incinv_create_header,
      invoicedocnumber LIKE bapi_incinv_fld-inv_doc_no,
      fiscalyear       LIKE bapi_incinv_fld-fisc_year,
      addressdata      LIKE bapi_incinv_create_addressdata.

*-------------------------------------------------
*> Item Data in Invoice
*> Account Assignment Data in Invoice
*> Tax Code in Invoice
*> Withholding Tax Data in Incoming Invoice
*> Vendor Split in Incoming Invoice
*> Return Messages
*-------------------------------------------------
DATA: itemdata         LIKE bapi_incinv_create_item
                            OCCURS 10 WITH HEADER LINE,
      accountingdata   LIKE bapi_incinv_create_account
                            OCCURS 10 WITH HEADER LINE,
      glaccountdata    LIKE bapi_incinv_create_gl_account
                            OCCURS 10 WITH HEADER LINE,
      materialdata     LIKE bapi_incinv_create_material
                            OCCURS 10 WITH HEADER LINE,
      taxdata          LIKE bapi_incinv_create_tax
                            OCCURS 10 WITH HEADER LINE,
      withtaxdata      LIKE bapi_incinv_create_withtax
                            OCCURS 10 WITH HEADER LINE,
      vendoritemsplitdata LIKE bapi_incinv_create_vendorsplit
                            OCCURS 10 WITH HEADER LINE,
      return           LIKE bapiret2
                            OCCURS 10 WITH HEADER LINE.

************************************************************************
* SELECT-OPTIONS / PARAMETERS                                          *
************************************************************************
SELECTION-SCREEN BEGIN OF BLOCK blk1 WITH FRAME.
PARAMETERS: p_upload  LIKE rlgrap-filename             " UPLOAD File
                      DEFAULT 'C:\upload\OPEN_IV.xls'
                                                       OBLIGATORY,
            p_lifnr   LIKE lfa1-lifnr
                      DEFAULT '0000199999'             OBLIGATORY,
            p_mwskz   LIKE ztitivk-mwskz
                      DEFAULT 'ZZ'                     OBLIGATORY,
*            p_budat   LIKE sy-datum   DEFAULT sy-datum OBLIGATORY,
*            p_bldat   LIKE sy-datum   DEFAULT sy-datum OBLIGATORY.
            p_budat   LIKE sy-datum   DEFAULT '20040731' OBLIGATORY,
            p_bldat   LIKE sy-datum   DEFAULT '20040731' OBLIGATORY.
SELECTION-SCREEN SKIP 1.
PARAMETERS: p_header    AS CHECKBOX  DEFAULT  'X'.

SELECTION-SCREEN SKIP 1.
SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT 1(79) text-010.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT 1(79) text-011.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT 1(79) text-012.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT 1(79) text-013.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT 1(79) text-014.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT 1(79) text-015.
SELECTION-SCREEN END OF LINE.

SELECTION-SCREEN SKIP 1.
SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT 1(78) text-030.
SELECTION-SCREEN END OF LINE.

SELECTION-SCREEN END OF BLOCK blk1.

***********************************************************************
* FIELD-SYMBOLS
***********************************************************************
DATA: BEGIN OF fc_struct,
        tabname(7),
        fieldname(6),
        ref_tabname(29),
        ref_fieldname(6),
        no_out(1),
        cqindicator(1),
        cqfield(6),
      END OF fc_struct.

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

*submit

************************************************************************
* INITIALIZATION Event                                                 *
************************************************************************
INITIALIZATION.
  PERFORM p1000_alv_fields_initial.
  PERFORM p1001_initialization.

************************************************************************
* AT SELECTION-SCREEN Events                                           *
************************************************************************
AT SELECTION-SCREEN  ON VALUE-REQUEST FOR p_upload.
  PERFORM filename_get_up USING 'P_UPLOAD'.

************************************************************************
* START-OF-SELECTION Event                                             *
************************************************************************
START-OF-SELECTION.
*> Excel Data Upload.
  PERFORM p2000_data_upload.       ">File Upload
  PERFORM set_fieldcat_build.      ">Set ALV field category
  PERFORM create_dynamic_table.    ">Create dynamic table

************************************************************************
* END-OF-SELECTION Event                                               *
************************************************************************
END-OF-SELECTION.

  IF NOT g_line IS INITIAL.
    PERFORM get_data_for_display.    ">data Check
    PERFORM get_alv_event_list.      ">Get ALV Event
    PERFORM set_event_form           ">Set ALV Use-event
            USING : slis_ev_data_changed  slis_ev_data_changed.
    PERFORM p3500_sort_table_build .
*> PROGRESS Display.
    g_linen    = 90.
    g_out_text = '리스트를 구성 중입니다 %99999%%'(p03).
    REPLACE '%99999%'(p99) WITH g_linen INTO g_out_text.
    PERFORM show_progress_bar USING g_out_text g_linen.
    PERFORM display_alv_function.
  ENDIF.

************************************************************************
* TOP-OF-PAGE Event                                                    *
************************************************************************
TOP-OF-PAGE.

************************************************************************
* END-OF-PAGE Event                                                    *
************************************************************************
END-OF-PAGE.

************************************************************************
* TOP-OF-PAGE DURING LINE-SELECTION Event                              *
************************************************************************
TOP-OF-PAGE DURING LINE-SELECTION.

************************************************************************
* AT LINE-SELECTION Event                                              *
************************************************************************
AT LINE-SELECTION.

************************************************************************
* AT USER-COMMAND Event                                                *
************************************************************************
AT USER-COMMAND.

************************************************************************
*                                                                      *
* S U B R O U T I N E S                                                *
*                                                                      *
************************************************************************
*&---------------------------------------------------------------------*
*&      Form  p1000_alv_fields_initial
*&---------------------------------------------------------------------*
FORM p1000_alv_fields_initial.

  FREE:  it_sort, fc.
  CLEAR: alv_keyinfo, gs_layout, alv_print, fc, gs_gridset.

*
  g_repid = alv_repid = sy-repid.

* PRINTING SETTINGS
  gs_layout-get_selinfos = 'X'.
  gs_layout-group_change_edit = 'X'.
  gs_layout-confirmation_prompt = 'X'.

  alv_print-no_print_selinfos = 'X'.
  alv_print-no_coverpage = 'X'.
  alv_print-no_print_listinfos = 'X'.

  gs_gridset-edt_cll_cb = 'X'.

ENDFORM.                    " p1000_alv_fields_initial
*&---------------------------------------------------------------------*
*&      Form  p1001_initialization
*&---------------------------------------------------------------------*
FORM p1001_initialization .

  SET TITLEBAR 'T1000'.

ENDFORM.                    " p1001_initialization

*&---------------------------------------------------------------------*
*&      Form  3010_insert_field_category
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM 3010_insert_field_category  USING  p_section
                                        p_fname
                                        p_value.

  DATA l_col(40).
  FIELD-SYMBOLS <l_fs>.

  IF p_section = 'S'.
    CLEAR gs_fieldcat_g.
  ENDIF.

* 속성 MOVE
  CONCATENATE 'GS_FIELDCAT_G-' p_fname  INTO l_col.

  ASSIGN      (l_col)         TO       <l_fs>.
  MOVE         p_value        TO       <l_fs>.

  IF p_section = 'E'.
    INSERT gs_fieldcat_g INTO it_fieldcat_g INDEX 1.
  ENDIF.
*  IF p_section = 'E'.
*    APPEND gs_fieldcat_g TO it_fieldcat_g.
*  ENDIF.
ENDFORM.                    " 3010_insert_field_category

*&---------------------------------------------------------------------*
*&      Form  p3500_sort_table_build
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM p3500_sort_table_build .

*  REFRESH: it_sort.
*
*  CLEAR  st_sort.
*  st_sort-spos = '01'.
*  st_sort-fieldname = 'EBELN'.
*  st_sort-tabname   = 'IT_LIST'.
*  st_sort-up        = 'X'.
**  ST_SORT-GROUP     = 'X'.
**  st_sort-subtot    = 'X'.
**  ST_SORT-EXPA      = 'X'.
*  APPEND st_sort TO it_sort.
**
*  CLEAR  st_sort.
*  st_sort-spos = '02'.
*  st_sort-fieldname = 'EBELP'.
*  st_sort-tabname   = 'IT_LIST'.
*  st_sort-up        = 'X'.
***  ST_SORT-GROUP     = 'X'.
***  ST_SORT-SUBTOT    = 'X'.
***  ST_SORT-EXPA      = 'X'.
*  APPEND st_sort TO it_sort.

ENDFORM.                    " p3500_sort_table_build
*&---------------------------------------------------------------------*
*&      Form  process_check
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_4909   text
*      -->P_4910   text
*      -->P_4911   text
*      -->P_G_ANSWER  text
*----------------------------------------------------------------------*
FORM process_check  USING  p_txt1
                            p_txt2
                            p_tit
                  CHANGING  p_g_answer.

* 작업여부 확인 - 아니오 또는 취소일경우는 작업을 진행시키지 않음.
  CALL FUNCTION 'POPUP_TO_DECIDE'
    EXPORTING
       defaultoption           = '1'
       textline1               =  p_txt1
       textline2               =  p_txt2
*      TEXTLINE3               = ' '
      text_option1             = 'Yes'
      text_option2             = 'No'
*      ICON_TEXT_OPTION1       = ' '
*      ICON_TEXT_OPTION2       = ' '
      titel                    = p_tit
*      START_COLUMN            = 25
*      START_ROW               = 6
*      CANCEL_DISPLAY          = 'X'
     IMPORTING
       answer                  = p_g_answer.

ENDFORM.                    " process_check
*&---------------------------------------------------------------------*
*&      Form  show_progress_bar
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_G_OUT_TEXT  text
*      -->P_G_LINEN  text
*----------------------------------------------------------------------*
FORM show_progress_bar  USING    text
                                 perc.
  CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
    EXPORTING
      percentage = perc
      text       = text.
ENDFORM.                    " show_progress_bar
*&---------------------------------------------------------------------*
*&      Form  filename_get_up
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_0717   text
*----------------------------------------------------------------------*
FORM filename_get_up USING p_fname.
  DATA : l_name(80).
  CALL FUNCTION 'WS_FILENAME_GET'
    EXPORTING
      def_path         = 'C:\'
      mask             = ',*.*,*.*.'
      mode             = 'O'
    IMPORTING
      filename         = l_name
    EXCEPTIONS
      inv_winsys       = 1
      no_batch         = 1
      selection_cancel = 1
      selection_error  = 1.
  IF sy-subrc = 0.
    IF p_fname = 'P_UPLOAD'.
      p_upload = l_name.
    ELSE.
*      p_down = l_name.
    ENDIF.
  ENDIF.
ENDFORM.                    " FILENAME_GET_UP
*&---------------------------------------------------------------------*
*&      Form  p2000_data_upload
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM p2000_data_upload .

*  DATA:it_excl LIKE alsmex_tabline OCCURS 0 WITH HEADER LINE,
  DATA:it_excl LIKE ztisexcel OCCURS 0 WITH HEADER LINE,
       l_subrc LIKE sy-subrc.

*> PROGRESS Display.
  g_linen    = 30.
  g_out_text = 'Excel 파일을 읽는 중입니다 %99999%%'(p01).
  REPLACE '%99999%' WITH g_linen INTO g_out_text.
  PERFORM show_progress_bar USING g_out_text g_linen.

  FIELD-SYMBOLS <fs>.

*  CALL FUNCTION 'ALSM_EXCEL_TO_INTERNAL_TABLE'
*    EXPORTING
*      filename                = p_upload
*      i_begin_col             = 1
*      i_begin_row             = 1
*      i_end_col               = 50
*      i_end_row               = 65536
*    TABLES
*      intern                  = it_excl
*    EXCEPTIONS
*      inconsistent_parameters = 1
*      upload_ole              = 2
*      OTHERS                  = 3.

  CALL FUNCTION 'Z_TS_KCD_EXCEL_OLE_TO_INT_CONV'
    EXPORTING
      filename                = p_upload
      i_begin_col             = 1
      i_begin_row             = 1
      i_end_col               = 40
      i_end_row               = 65536
    TABLES
      intern                  = it_excl
    EXCEPTIONS
      inconsistent_parameters = 1
      upload_ole              = 2
      OTHERS                  = 3.


  CLEAR: gt_upload_list[], gt_upload_title.
  SORT it_excl BY row col.
  LOOP AT it_excl.
    CLEAR: l_subrc.
    IF it_excl-row = 1.
      IF p_header EQ 'X'.
        l_subrc = 4.
        ASSIGN COMPONENT it_excl-col OF STRUCTURE gt_download TO <fs>.
      ELSE.
        ASSIGN COMPONENT it_excl-col OF STRUCTURE
                         gt_upload_list  TO <fs>.
        l_subrc = sy-subrc.
      ENDIF.
    ELSE.
      ASSIGN COMPONENT it_excl-col OF STRUCTURE gt_upload_list TO <fs>.
      l_subrc = sy-subrc.
    ENDIF.
*    IF l_subrc EQ 0.
    <fs> = it_excl-value.
*    ENDIF.
*> Row의 마지막일 경우.
    AT END OF row.
      IF it_excl-row = 1.
        IF p_header NE 'X'.
          APPEND gt_upload_list.   CLEAR gt_upload_list.
        ELSE.
          APPEND gt_download.  CLEAR gt_download.
        ENDIF.
      ELSE.
        APPEND gt_upload_list.   CLEAR gt_upload_list.
      ENDIF.
    ENDAT.
  ENDLOOP.

  DESCRIBE TABLE gt_upload_list LINES g_line.
  IF g_line EQ 0.
    MESSAGE s997 WITH 'Upload된 파일' p_upload '에 데이터가 없습니다.'.
  ENDIF.

ENDFORM.                    " p2000_data_upload
*&---------------------------------------------------------------------*
*&      Form  set_fieldcat_build
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM set_fieldcat_build .

  DATA: color TYPE slis_t_specialcol_alv WITH HEADER LINE.

  FREE : fc.  CLEAR: fc.

  ac 'ITAB   ICON  ZTISLCCS                     ICON  '.
  ac 'ITAB   LOGNO ZTISMESSAGE                  LOGNO X'.
  ac 'ITAB   CHECK ZTITRQST                     FWDTY X'.
  ac 'ITAB   IVMNGLZTISIVIT                     IVMNGLXQMEINS'.

  ac 'ITAB   INCO1 ZTITBLK                      INCO1 X'.
  ac 'ITAB   LIFNR ZTITBLK                      LIFNR X'.
  ac 'ITAB   BUKRS ZTITBLK                      BUKRS X'.
  ac 'ITAB   EKORG ZTITBLK                      EKORG X'.
  ac 'ITAB   EKGRP ZTITBLK                      EKGRP X'.

  ac 'ITAB   MENGE EKPO                         MENGE X'.
  ac 'ITAB   BLMNG ZTITBLP                      BLMNG XQMEINS'.
  ac 'ITAB   RQMNG ZTITBLP                      RQMNG XQMEINS'.
  ac 'ITAB   NETPR ZTITBLP                      NETPR XCWAERS'.
  ac 'ITAB   NETWR ZTITBLP                      NETWR XCWAERS'.
  ac 'ITAB   BPUMZ ZTITBLP                      BPUMZ X'.
  ac 'ITAB   BPUMN ZTITBLP                      BPUMN X'.
  ac 'ITAB   PEINH ZTITBLP                      PEINH X'.
  ac 'ITAB   BPRME ZTITBLP                      BPRME X'.
  ac 'ITAB   MATNR ZTITBLP                      MATNR X'.
  ac 'ITAB   TXZ01 ZTITBLP                      TXZ01 X'.
  ac 'ITAB   STAWN ZTISBL_DUE_LIST              STAWN X'.
  ac 'ITAB   WERKS ZTITBLP                      WERKS X'.
  ac 'ITAB   LGORT ZTITBLP                      LGORT X'.
  ac 'ITAB   ZTERM ZTITIVK                      ZTERM X'.



  ac 'ITAB   BLNUM ZTITBLK                      BLNUM  '.
  ac 'ITAB   IVNUM ZTITIVK                      IVNUM  '.
  ac 'ITAB   OPNNO ZTIVRQ04                     OPNNO  '.
  ac 'ITAB   EBELN ZTITBLP                      EBELN  '.
  ac 'ITAB   EBELP ZTITBLP                      EBELP  '.
  ac 'ITAB   REQNO ZTITBLP                      REQNO  '.
  ac 'ITAB   REQIT ZTITBLP                      REQIT  '.
  ac 'ITAB   IBLNO ZTITBLP                      IBLNO  '.
  ac 'ITAB   IBLIT ZTITBLP                      IBLIT  '.
  ac 'ITAB   IVAMP ZTITIVK                      IVAMP  CWAERS'.
  ac 'ITAB   WAERS ZTITIVK                      WAERS  '.
  ac 'ITAB   KURSF ZTITIVK                      KURSF  '.


*> ITEM
  ac 'ITAB   IVMNG ZTISIVIT                     IVMNG  QMEINS'.
  ac 'ITAB   IVAMT ZTISIVIT                     IVAMT  CWAERS'.
  ac 'ITAB   MEINS ZTISIVIT                     MEINS  '.
*  ac 'ITAB   REFWR ZTISIVIT                     REFWR  CWAERS  '.

  ac 'ITAB   IVONO ZTISIVIT                     IVONO  '.
  ac 'ITAB   RBLGP ZTISIVIT                     RBLGP  '.

  fc1[] = fc[].

  ac 'ITAB   COLOR SLIS_T_SPECIALCOL_ALV              X'.

  LOOP AT fc1 INTO fcs.
    CLEAR: fcs-key .
    CASE fcs-fieldname.
      WHEN 'REQNO' OR 'REQIT' OR 'MEINS' OR 'LAND1' OR
           'GEWEI' OR 'VOLEH' OR 'WAERS' OR
           'IBLNO' OR 'IBLIT' OR 'IVONO' OR 'RBLGP'.
*        fcs-hotspot = 'X'.
*        fcs-key     = 'X'.
        CLEAR fcs-edit.
      WHEN 'EBELP' OR 'EBELN' OR 'OPNNO'.
*        fcs-hotspot = 'X'.
        fcs-key     = 'X'.
        fcs-edit    = 'X'.
      WHEN 'SMAMT'.
        fcs-do_sum  = 'X'.
        fcs-edit    = 'X'.
      WHEN 'NOTYE'.
        fcs-key       = 'X'.
        fcs-seltext_l = '미착 IV 대상'.
        fcs-seltext_m = 'IV 대상'.
        fcs-seltext_s = 'IV 대상'.
        fcs-ddictxt   = 'S'.
        fcs-icon      = 'X'.
        CLEAR fcs-edit.
      WHEN 'ICON'.
        fcs-key       = 'X'.
        fcs-seltext_l = '상태'.
        fcs-seltext_m = '상태'.
        fcs-seltext_s = '상태'.
        fcs-ddictxt   = 'S'.
        fcs-icon      = 'X'.
        CLEAR fcs-edit.
      WHEN OTHERS.
        fcs-edit      = 'X'.
    ENDCASE.
    MODIFY fc1 FROM fcs.
  ENDLOOP.

ENDFORM.                    " set_fieldcat_build
*&---------------------------------------------------------------------*
*&      Form  create_dynamic_table
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
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
*&      Form  get_data_for_display
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM get_data_for_display .

  DATA: l_logno   TYPE balognr.

  FIELD-SYMBOLS: <gs_table>.
  FIELD-SYMBOLS: <l_field>.
  FIELD-SYMBOLS: <l_field1>.
  FIELD-SYMBOLS: <l_field2>.
  FIELD-SYMBOLS: <l_field3>.


*  perform  create_log  CHANGING g_log_data-s_loghandle.

*> PROGRESS Display.
  g_linen    = 70.
  g_out_text = '데이타를 점검 중입니다 %99999%%'(p01).
  REPLACE '%99999%' WITH g_linen INTO g_out_text.
  PERFORM show_progress_bar(ztir0000) USING g_out_text g_linen.

  REFRESH : <gt_table>.

  ASSIGN LOCAL COPY OF INITIAL LINE OF <gt_table> TO <gs_table>.

  ASSIGN COMPONENT 'LOGNO' OF STRUCTURE <gs_table> TO <l_field>.

  FREE : it_fieldname.
  PERFORM build_fields_table USING : 'ZTITIVK' <gs_table>,
                                     'ZTISIVIT' <gs_table>,
                                     'ZTITBLK' <gs_table>,
                                     'ZTITRQST' <gs_table>.
  REFRESH: it_msg.
  CLEAR: l_logno.

  LOOP AT gt_upload_list.
    CLEAR: <gs_table>.

*> Upload file to Internal table
    PERFORM move_upload_to_internal_table USING  <gs_table>.

*> Internal Log Number Setting.
    ADD 1 TO l_logno.
    <l_field> = l_logno.

*> Fill Other fields
    PERFORM set_others_fields             USING  <gs_table>
                                                 'X'.
    IF NOT <gs_table> IS INITIAL.
      APPEND <gs_table> TO <gt_table> .
    ENDIF.
  ENDLOOP.

ENDFORM.                    " get_data_for_display
*&---------------------------------------------------------------------*
*&      Form  get_alv_event_list
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM get_alv_event_list .

  CALL FUNCTION 'REUSE_ALV_EVENTS_GET'
    EXPORTING
      i_list_type = 0
    IMPORTING
      et_events   = gt_events.

ENDFORM.                    " get_alv_event_list
*&---------------------------------------------------------------------*
*&      Form  set_event_form
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM set_event_form USING    p_event
                             p_form.
  CLEAR gs_events.
  READ TABLE gt_events WITH KEY name = p_event
                       INTO gs_events.
  IF sy-subrc = 0.
    gs_events-form = p_form.
    MODIFY gt_events FROM gs_events INDEX sy-tabix.
  ELSE.
    gs_events-name = p_event.
    gs_events-form = p_form.
    APPEND gs_events TO gt_events.
  ENDIF.

ENDFORM.                    " set_event_form
*&---------------------------------------------------------------------*
*&      Form  display_alv_function
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM display_alv_function .

  DATA: fc_detail TYPE slis_fieldcat_alv OCCURS 0 WITH HEADER LINE.
  DATA: variant_detail      LIKE disvariant.
  DATA: exit     TYPE slis_event_exit   OCCURS 0 WITH HEADER LINE.
  DATA: events   TYPE slis_alv_event    OCCURS 0 WITH HEADER LINE.
  DATA: groups   TYPE slis_sp_group_alv OCCURS 0 WITH HEADER LINE.

  SET TITLEBAR 'T1000'.

* The detail ALV may modify the list (sorting). If returned to the
* base list, the original list needs to be restored.
  REFRESH fc_detail.
  LOOP AT fc1 INTO fcs.
    MOVE-CORRESPONDING fcs TO fc_detail.
    CLEAR fc_detail-tabname.
    APPEND fc_detail.
  ENDLOOP.

  CLEAR variant_detail.
  variant_detail-report = sy-repid.
  variant_detail-handle = ' '.

*  gs_layout-colwidth_optimize = 'X'.
*  gs_layout-zebra             = 'X'.
*  gs_layout-box_fieldname     = 'BOX'.
*>color field define.
  gs_layout-coltab_fieldname  = 'COLOR'.
  gs_layout-group_change_edit = 'X'.
  gs_layout-f2code            = 'DISPLAY'.

  REFRESH exit.
  exit-ucomm = '&OL0'. exit-after = 'X'. APPEND exit.
  exit-ucomm = '&OLX'. APPEND exit.
  exit-ucomm = '&OAD'. APPEND exit.

*> ALV reuse function call..
  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
      EXPORTING
        i_callback_program       = alv_repid
        i_callback_pf_status_set = 'SET_ALV_STATUS'
        i_callback_user_command  = 'USER_ALV_COMMAND'
        i_callback_top_of_page   = 'TOP_OF_PAGE'
        i_grid_settings          = gs_gridset
*     I_STRUCTURE_NAME               =
*     IT_EXCLUDING                   =
*     IT_SPECIAL_GROUPS              =
*     IT_FILTER                      =
*     IS_SEL_HIDE                    =
*     I_DEFAULT                      = 'X'
*     I_SAVE                         = ' '
*     IS_VARIANT                     =
      it_events                      = gt_events[]
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
        i_save                   = 'A'
        is_layout                = gs_layout
        is_print                 = alv_print
*   IMPORTING
*     E_EXIT_CAUSED_BY_CALLER        =
*     ES_EXIT_CAUSED_BY_USER         =
      TABLES
        t_outtab                 = <gt_table>.



ENDFORM.                    " display_alv_function

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

  SET PF-STATUS 'STANDARD' EXCLUDING extab.

ENDFORM.                    " SET_ALV_STATUS

*&---------------------------------------------------------------------*
*&      Form  TOP_OF_PAGE
*&---------------------------------------------------------------------*
FORM top_of_page.

  DATA: l_mode TYPE i.
  DATA: header TYPE slis_listheader OCCURS 0 WITH HEADER LINE.

  REFRESH header.

  header-typ  = 'H'.
  header-info = '미착물대 Upload( Migration용 ) '.
  CLEAR: header-key.
  APPEND header.

  header-typ = 'S'.
  header-key = '출력일자'(106).
  WRITE: sy-datlo TO header-info.
  APPEND header.

  CALL FUNCTION 'REUSE_ALV_COMMENTARY_WRITE'
    EXPORTING
      it_list_commentary = header[].

ENDFORM.    ">TOP_OF_PAGE

*&---------------------------------------------------------------------*
*&      Form  USER_ALV_COMMAND
*&---------------------------------------------------------------------*
FORM user_alv_command USING   r_ucomm      LIKE sy-ucomm
                              rs_selfield  TYPE slis_selfield.
*
  DATA: l_count   TYPE i.
  DATA: l_count_s TYPE i.
  DATA: sum_item_amount(20),
        sum_difference(20),
        gross_amount(20),
        item_amount(20),
        ref_doc_no(20).
  DATA: l_tabix   LIKE sy-tabix.
  DATA: d_tabix   LIKE sy-tabix.
  DATA: l_subrc   LIKE sy-subrc.
  DATA: l_tcode   LIKE sy-tcode.
  DATA: l_reqno   TYPE ztireqno.
  DATA: l_amdsq   TYPE ztiamdsq.
  DATA: l_lcono   TYPE ztireqno.

  DATA: lt_fc     TYPE kkblo_t_fieldcat,
        ls_fc     TYPE kkblo_fieldcat.

  DATA: BEGIN OF lt_ivnum OCCURS 0,
        ivnum     TYPE ztiivnum,
        END   OF lt_ivnum.

  DATA: BEGIN OF lt_err_ivnum OCCURS 0,
        ivnum     TYPE ztiivnum,
        END   OF lt_err_ivnum.


  FIELD-SYMBOLS: <gs_table>,
                 <l_field>,
                 <l_field1>,
                 <l_field2>,
                 <l_opnno>,
                 <l_blnum>,
                 <l_ivnum>,
                 <l_ebeln>,
                 <l_ebelp>,
                 <l_ivono>,
                 <l_rblgp>,
                 <l_iblno>,
                 <l_iblit>,
                 <l_reqno>,
                 <l_reqit>,
                 <l_ivamp>,
                 <l_ivmng>,
                 <l_icon>,
                 <l_kursf>.

  ASSIGN LOCAL COPY OF INITIAL LINE OF <gt_table> TO <gs_table>.

  CLEAR gt_download.

  CASE r_ucomm.
    WHEN 'ZTIUPLOAD'.
      ASSIGN COMPONENT 'CHECK' OF STRUCTURE
                            <gs_table> TO <l_field>.
      ASSIGN COMPONENT 'IVONO' OF STRUCTURE
                            <gs_table> TO <l_ivono>.
      ASSIGN COMPONENT 'RBLGP' OF STRUCTURE
                            <gs_table> TO <l_rblgp>.
      ASSIGN COMPONENT 'IVNUM' OF STRUCTURE
                            <gs_table> TO <l_ivnum>.
      ASSIGN COMPONENT 'EBELN' OF STRUCTURE
                            <gs_table> TO <l_ebeln>.
      ASSIGN COMPONENT 'EBELP' OF STRUCTURE
                            <gs_table> TO <l_ebelp>.
      ASSIGN COMPONENT 'REQNO' OF STRUCTURE
                            <gs_table> TO <l_reqno>.
      ASSIGN COMPONENT 'REQIT' OF STRUCTURE
                            <gs_table> TO <l_reqit>.
      ASSIGN COMPONENT 'IBLNO' OF STRUCTURE
                            <gs_table> TO <l_iblno>.
      ASSIGN COMPONENT 'IBLIT' OF STRUCTURE
                            <gs_table> TO <l_iblit>.
      ASSIGN COMPONENT 'OPNNO' OF STRUCTURE
                            <gs_table> TO <l_opnno>.
      ASSIGN COMPONENT 'BLNUM' OF STRUCTURE
                            <gs_table> TO <l_blnum>.
      ASSIGN COMPONENT 'KURSF' OF STRUCTURE
                            <gs_table> TO <l_kursf>.

      ASSIGN COMPONENT 'ICON' OF STRUCTURE
                            <gs_table> TO <l_icon>.

      CLEAR: l_count, g_post_chk, l_count_s.

      LOOP AT <gt_table> INTO <gs_table>.
*> 오류 인보이스 번호 Collect.
        IF <l_field> EQ 'E'.
          ADD 1 TO l_count.
          d_tabix = sy-tabix.
          IF <l_blnum> IS INITIAL.
            lt_err_ivnum-ivnum = <l_opnno>.
          ELSE.
            lt_err_ivnum-ivnum = <l_ivnum>.
          ENDIF.
          COLLECT lt_err_ivnum.
        ELSE.
*> 정상 인보이스 번호 Collect.
          IF NOT <l_ivono> IS INITIAL.
            g_post_chk = 'X'.
          ENDIF.
          IF <l_blnum> IS INITIAL.
            lt_ivnum-ivnum = <l_opnno>.
          ELSE.
            lt_ivnum-ivnum = <l_ivnum>.
          ENDIF.
          COLLECT lt_ivnum.
        ENDIF.
      ENDLOOP.

*> 오류 인보이스 번호 삭제.
      LOOP AT lt_err_ivnum.
        DELETE lt_ivnum WHERE ivnum = lt_err_ivnum-ivnum.
      ENDLOOP.

      IF l_count NE 0.
*        MESSAGE i957.   EXIT.
        MESSAGE i957.
      ENDIF.

      IF g_post_chk EQ 'X'.
        MESSAGE i958.  EXIT.
      ENDIF.

*> 오류부터 Log 생성.
      ASSIGN COMPONENT 'LOGNO' OF STRUCTURE
                            <gs_table> TO <l_field1>.

      LOOP AT lt_err_ivnum.
        CLEAR: l_count, l_tabix.
        REFRESH : xztitivp.

        LOOP AT <gt_table> INTO <gs_table>.
          IF <l_field> EQ 'E'.
            l_tabix = sy-tabix.
          ENDIF.
          IF <l_ivnum> IS INITIAL.
            IF <l_opnno> EQ lt_err_ivnum-ivnum AND
               <l_blnum> IS INITIAL.
              ADD 1 TO l_count.

              CLEAR  ztitivk.

              MOVE-CORRESPONDING : <gs_table> TO ztitivk.
              MOVE: 'P'                       TO ztitivk-prpyn.
              MOVE-CORRESPONDING <gs_table> TO xztitivp.
              xztitivp-mandt = sy-mandt.
              xztitivp-rblgp = l_count.
              xztitivp-tbtkz = space.
              xztitivp-mwskz = p_mwskz.
              xztitivp-refwr = xztitivp-ivamt.
              xztitivp-remng = xztitivp-ivmng.
              APPEND xztitivp.
            ENDIF.
          ELSE.
            IF <l_ivnum> EQ lt_err_ivnum-ivnum.
              ADD 1 TO l_count.

              CLEAR  ztitivk.

              MOVE-CORRESPONDING : <gs_table> TO ztitivk.
              MOVE: 'I'                       TO ztitivk-prpyn.
              MOVE-CORRESPONDING <gs_table> TO xztitivp.
              xztitivp-mandt = sy-mandt.
              xztitivp-rblgp = l_count.
              xztitivp-tbtkz = space.
              xztitivp-mwskz = p_mwskz.
              xztitivp-refwr = xztitivp-ivamt.
              xztitivp-remng = xztitivp-ivmng.
              APPEND xztitivp.
            ENDIF.
          ENDIF.
          ztitivk-lponr = l_count.
        ENDLOOP.
        READ TABLE <gt_table> INTO <gs_table> INDEX l_tabix.
        IF sy-subrc NE 0.
          MESSAGE s957.
        ELSE.
          READ TABLE it_msg WITH KEY logno = <l_field1>.
          IF sy-subrc EQ 0.
            MESSAGE ID it_msg-msgid TYPE 'S' NUMBER it_msg-msgno
                    WITH it_msg-msgv1 it_msg-msgv2
                         it_msg-msgv3 it_msg-msgv4.
          ELSE.
            MESSAGE s957.
          ENDIF.
        ENDIF.
        PERFORM  set_upload_log  USING  'E'
                                        l_lcono
                                        lt_err_ivnum-ivnum
                                        <l_ebeln>
                                        <l_ebelp>.
      ENDLOOP.

*> 정상 파일 Upload.
      LOOP AT lt_ivnum.
        CLEAR: l_count.
        REFRESH : xztitivp.

        LOOP AT <gt_table> INTO <gs_table>.
          IF <l_ivnum> IS INITIAL.
            IF <l_opnno> EQ lt_ivnum-ivnum AND
               <l_blnum> IS INITIAL.
              ADD 1 TO l_count.

              CLEAR  ztitivk.

              MOVE-CORRESPONDING : <gs_table> TO ztitivk.
              MOVE: 'P'                       TO ztitivk-prpyn.
              MOVE-CORRESPONDING <gs_table> TO xztitivp.
              xztitivp-mandt = sy-mandt.
              xztitivp-rblgp = l_count.
              xztitivp-tbtkz = space.
              xztitivp-mwskz = p_mwskz.
              xztitivp-refwr = xztitivp-ivamt.
              xztitivp-remng = xztitivp-ivmng.
              APPEND xztitivp.
            ENDIF.
          ELSE.
            IF <l_ivnum> EQ lt_ivnum-ivnum.
              ADD 1 TO l_count.

              CLEAR  ztitivk.

              MOVE-CORRESPONDING : <gs_table> TO ztitivk.
              MOVE: 'I'                       TO ztitivk-prpyn.
              MOVE-CORRESPONDING <gs_table> TO xztitivp.
              xztitivp-mandt = sy-mandt.
              xztitivp-rblgp = l_count.
              xztitivp-tbtkz = space.
              xztitivp-mwskz = p_mwskz.
              xztitivp-refwr = xztitivp-ivamt.
              xztitivp-remng = xztitivp-ivmng.
              APPEND xztitivp.
            ENDIF.
          ENDIF.
          ztitivk-lponr = l_count.
        ENDLOOP.

        IF l_count GT 0.
*>Set Header 데이타 .
          PERFORM set_invoice_header_data  USING lt_ivnum-ivnum.

*> Set posting용 데이타 Move
          PERFORM  set_invoice_data.

*> begin work.
          SET UPDATE TASK LOCAL.

*> Bapi Functions Call.
          PERFORM  call_bapi_function.

          IF invoicedocnumber IS INITIAL.        "> ERROR
            ROLLBACK WORK.
            LOOP AT return.
              MESSAGE ID return-id TYPE 'S'  NUMBER return-number
                        WITH   return-message_v1  return-message_v2
                               return-message_v3  return-message_v4.
            ENDLOOP.
            IF sy-subrc NE 0.
              MESSAGE s851.
            ENDIF.

            LOOP AT <gt_table> INTO <gs_table>.
              l_tabix = sy-tabix.
              IF ztitivk-prpyn EQ 'P'.
                IF <l_opnno> EQ lt_ivnum-ivnum AND
                   <l_blnum> IS INITIAL.
                  <l_icon> = icon_red_light.
                  MODIFY <gt_table> FROM <gs_table> INDEX l_tabix.
                ENDIF.
              ELSE.
                IF <l_ivnum> EQ lt_ivnum-ivnum.
                  <l_icon> = icon_red_light.
                  MODIFY <gt_table> FROM <gs_table> INDEX l_tabix.
                ENDIF.
              ENDIF.
            ENDLOOP.

            PERFORM  set_upload_log  USING  'E'
                                            l_lcono
                                            lt_ivnum-ivnum
                                            <l_ebeln>
                                            <l_ebelp>.

            CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
            CONTINUE.
          ENDIF.

          CALL FUNCTION 'Z_TI_GET_NUMBER_NEXT'
            EXPORTING
              zmpty    = 'IV'
            IMPORTING
              lcono    = l_lcono
            EXCEPTIONS
              not_type = 1
              OTHERS   = 2.
          IF sy-subrc <> 0.
            ROLLBACK WORK.
*            MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            MESSAGE ID sy-msgid TYPE 'S' NUMBER sy-msgno
                    WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
            PERFORM  set_upload_log  USING  'E'
                                            l_lcono
                                            lt_ivnum-ivnum
                                            <l_ebeln>
                                            <l_ebelp>.
            CONTINUE.
          ENDIF.

*> Header table modify
          MOVE: l_lcono          TO ztitivk-ivono,
                invoicedocnumber TO ztitivk-belnr,
                'P'              TO ztitivk-livst.

          MODIFY ztitivk.
          IF sy-subrc NE 0.
            MESSAGE s912.
            PERFORM  set_upload_log  USING  'E'
                                            l_lcono
                                            lt_ivnum-ivnum
                                            <l_ebeln>
                                            <l_ebelp>.
            ROLLBACK WORK.   CONTINUE.
          ENDIF.

          LOOP AT xztitivp.
            xztitivp-ivono = ztitivk-ivono.
            xztitivp-cnam  = sy-uname.
            xztitivp-cdat  = sy-datlo.
            xztitivp-ctme  = sy-timlo.
            xztitivp-unam  = sy-uname.
            xztitivp-udat  = sy-datlo.
            xztitivp-utme  = sy-timlo.
            MODIFY xztitivp.
          ENDLOOP.
          MODIFY ztitivp FROM TABLE xztitivp.
          IF sy-subrc NE 0.
            MESSAGE s912.
            PERFORM  set_upload_log  USING  'E'
                                            l_lcono
                                            lt_ivnum-ivnum
                                            <l_ebeln>
                                            <l_ebelp>.
            ROLLBACK WORK.   CONTINUE.
          ENDIF.

*> History table Update.
          CLEAR: ztitivh.
          SELECT MAX( ivseq )
            INTO ztitivh-ivseq
            FROM ztitivh
           WHERE ivono    EQ   ztitivk-ivono.

          ADD 1 TO  ztitivh-ivseq.
          MOVE : sy-mandt           TO     ztitivh-mandt,
                 'H'                TO     ztitivh-shkzg,
                 ztitivk-bldat     TO     ztitivh-budat,
                 ztitivk-budat     TO     ztitivh-bldat,
                 ztitivk-ivono     TO     ztitivh-ivono,
                 ztitivk-waers     TO     ztitivh-waers,
*                 ZTITIVK-dmbtr     TO     ZTItivh-dmbtr,
                 ztitivk-blart     TO     ztitivh-blart,
                 ztitivk-ivamp     TO     ztitivh-ivamp,
                 ztitivk-vorgang   TO     ztitivh-vorgang,
                 sy-uname           TO     ztitivh-cnam,
                 sy-datlo           TO     ztitivh-cdat,
                 sy-timlo           TO     ztitivh-ctme,
                 fiscalyear         TO     ztitivh-gjahr,
                 invoicedocnumber   TO     ztitivh-belnr,
                 ''                 TO     ztitivh-cbudat,
                 ''                 TO     ztitivh-cgjahr,
                 ''                 TO     ztitivh-cbelnr.
          INSERT ztitivh.
          IF sy-subrc NE 0.
            ROLLBACK WORK.
            MESSAGE s912.
            PERFORM  set_upload_log  USING  'E'
                                            l_lcono
                                            lt_ivnum-ivnum
                                            <l_ebeln>
                                            <l_ebelp>.
            CONTINUE.
          ENDIF.

          LOOP AT <gt_table> INTO <gs_table>.
            l_tabix = sy-tabix.
            IF ztitivk-prpyn EQ 'P'.
              IF <l_opnno> EQ lt_ivnum-ivnum AND
                 <l_blnum> IS INITIAL.
                READ TABLE xztitivp WITH KEY ebeln = <l_ebeln>
                                              ebelp = <l_ebelp>
                                              reqno = <l_reqno>
                                              reqit = <l_reqit>
                                              iblno = space.
                IF sy-subrc EQ 0.
                  <l_ivono> = xztitivp-ivono.
                  <l_rblgp> = xztitivp-rblgp.
                  MODIFY <gt_table> FROM <gs_table> INDEX l_tabix.
                ENDIF.
              ENDIF.
            ELSE.
              IF <l_ivnum> EQ lt_ivnum-ivnum.
                READ TABLE xztitivp WITH KEY ebeln = <l_ebeln>
                                              ebelp = <l_ebelp>
                                              reqno = <l_reqno>
                                              reqit = <l_reqit>
                                              iblno = <l_iblno>
                                              iblit = <l_iblit>.
                IF sy-subrc EQ 0.
                  <l_ivono> = xztitivp-ivono.
                  <l_rblgp> = xztitivp-rblgp.
                  MODIFY <gt_table> FROM <gs_table> INDEX l_tabix.
                ENDIF.
              ENDIF.
            ENDIF.
          ENDLOOP.
          MESSAGE s314 WITH l_lcono.
          PERFORM  set_upload_log  USING  'S'
                                          l_lcono
                                          lt_ivnum-ivnum
                                          <l_ebeln>
                                          <l_ebelp>.

          CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'.
          COMMIT WORK.

        ENDIF.

      ENDLOOP.

      PERFORM split_path(oaall) USING p_upload file_path file_name.

      CONCATENATE file_path '\' '미착물대_Upload_Log_' sy-datlo
                  sy-timlo '.XLS' INTO p_down.

      CALL FUNCTION 'WS_DOWNLOAD'
        EXPORTING
          filename                = p_down
          filetype                = 'DAT'
        TABLES
          data_tab                = gt_download
        EXCEPTIONS
          file_open_error         = 1
          file_write_error        = 2
          invalid_filesize        = 3
          invalid_type            = 4
          no_batch                = 5
          unknown_error           = 6
          invalid_table_width     = 7
          gui_refuse_filetransfer = 8
          customer_error          = 9
          OTHERS                  = 10.

      IF sy-subrc <> 0.
        MESSAGE ID sy-msgid TYPE 'W' NUMBER sy-msgno
                WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      ELSE.
        MESSAGE i999 WITH
        '미착물대 생성완료 결과를 다운로드 하였습니다!!!'.
      ENDIF.

      rs_selfield-refresh = 'X'.

    WHEN 'DISPLAY' OR '&IC1'.    " AUF DOPPELKLICK REAGIERIEN
      CHECK rs_selfield-tabindex GT 0.

      IF  rs_selfield-fieldname  =  'IVONO'  AND
          NOT rs_selfield-value  IS  INITIAL.
        SET  PARAMETER  ID  'ZTIIVONO'  FIELD  rs_selfield-value.
        SET  PARAMETER  ID  'ZTIIBLNO'  FIELD  space.
        CALL  TRANSACTION  'ZTIT303'  AND SKIP   FIRST  SCREEN.
        EXIT.
      ENDIF.

      READ TABLE <gt_table> INTO <gs_table> INDEX rs_selfield-tabindex.
      IF sy-subrc NE 0.
        MESSAGE s906.            EXIT.
      ENDIF.
      ASSIGN COMPONENT 'LOGNO' OF STRUCTURE
                            <gs_table> TO <l_field1>.
      REFRESH: it_msg_list.
      LOOP AT it_msg WHERE logno EQ <l_field1>.
        MOVE-CORRESPONDING it_msg TO it_msg_list.
        APPEND it_msg_list.
      ENDLOOP.

      DESCRIBE TABLE it_msg_list LINES g_line.
      IF g_line GT 0.
        CALL FUNCTION 'Z_TI_POPUP_TO_ERROR_MESSAGE'
          EXPORTING
            xdocno_show = 'X'
          TABLES
            xmsg        = it_msg_list.
      ELSE.
        MESSAGE s911.
      ENDIF.
    WHEN 'DSJJ'.
      ASSIGN COMPONENT 'BLNUM' OF STRUCTURE
                           <gs_table> TO <l_blnum>.
      ASSIGN COMPONENT 'IVAMP' OF STRUCTURE
                           <gs_table> TO <l_ivamp>.
      ASSIGN COMPONENT 'IVMNG' OF STRUCTURE
                           <gs_table> TO <l_ivmng>.
      LOOP AT <gt_table> INTO <gs_table>.
        l_tabix = sy-tabix.
        sum_item_amount = sum_item_amount + <l_ivmng>.
        gross_amount = <l_ivamp>.
        item_amount = <l_ivmng>.
        ref_doc_no = <l_blnum>.

        AT END OF <l_blnum> .
          READ  TABLE  <gt_table>  INDEX   l_tabix  INTO  <gs_table>.
          IF gross_amount NE sum_item_amount.
            sum_difference = gross_amount - sum_item_amount.
            item_amount = item_amount + sum_difference.
            <l_ivmng>  =  item_amount.
            MODIFY <gt_table>  FROM <gs_table> .
            CLEAR: sum_item_amount,
                   gross_amount,
                   item_amount,
                   sum_difference,
                   ref_doc_no.
          ENDIF.
        ENDAT.
      ENDLOOP.

  ENDCASE.
  CLEAR: r_ucomm.

ENDFORM.                    " USER_ALV_COMMAND
*&---------------------------------------------------------------------*
*&      Form  move_upload_to_internal_table
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM move_upload_to_internal_table USING p_to_table.

  DATA: l_htype   LIKE dd01v-datatype.

  FIELD-SYMBOLS: <l_field_from>.
  FIELD-SYMBOLS: <l_field_to>.

  LOOP AT it_fieldname.
    ASSIGN COMPONENT it_fieldname-fieldname OF STRUCTURE
                     gt_upload_list TO <l_field_from>.
    IF sy-subrc EQ 0.
      ASSIGN COMPONENT it_fieldname-fieldname OF STRUCTURE
                     p_to_table     TO <l_field_to>.
      IF sy-subrc EQ 0.
        CONCATENATE <l_field_from> space INTO <l_field_from>.
        CALL FUNCTION 'Z_TI_NUMBER_CHECK'
          EXPORTING
            string_in   = <l_field_from>
            change_mode = space
          IMPORTING
            string_out  = <l_field_from>
            htype       = l_htype.
        IF l_htype EQ 'NUMC'.
          PERFORM set_write_no_mask(ztir0000) USING <l_field_from>.
        ENDIF.
        MOVE <l_field_from> TO <l_field_to>.
      ENDIF.
    ENDIF.
  ENDLOOP.

ENDFORM.                    " move_upload_to_internal_table
*&---------------------------------------------------------------------*
*&      Form  build_fields_table
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM build_fields_table  USING    p_tabname LIKE dd03l-tabname
                                  p_to_table.


  DATA: BEGIN OF lt_fieldname OCCURS 0,
        fieldname   LIKE  dd03l-fieldname,
        END   OF lt_fieldname.

  FIELD-SYMBOLS: <l_field_from>.
  FIELD-SYMBOLS: <l_field_to>.

  SELECT fieldname
    INTO CORRESPONDING FIELDS OF TABLE lt_fieldname
    FROM dd03l
   WHERE tabname  EQ  p_tabname .

  IF sy-subrc EQ 0.
    LOOP AT lt_fieldname.
      ASSIGN COMPONENT lt_fieldname-fieldname OF STRUCTURE
                       gt_upload_list TO <l_field_from>.
      IF sy-subrc EQ 0.
        ASSIGN COMPONENT lt_fieldname-fieldname OF STRUCTURE
                       p_to_table     TO <l_field_to>.
        IF sy-subrc EQ 0.
          it_fieldname-fieldname = lt_fieldname-fieldname.
          APPEND it_fieldname.
        ENDIF.
      ENDIF.
    ENDLOOP.
  ENDIF.

ENDFORM.                    " build_fields_table
*&---------------------------------------------------------------------*
*&      Form  set_others_fields
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM set_others_fields  USING    p_table   p_first_mode.

  DATA: l_ebeln       TYPE ebeln,
        l_ebelp       TYPE ebelp,
        l_reqno       TYPE ztireqno,
        l_reqit       TYPE ztireqit,
        l_blnum       TYPE ztiblnum,
        l_iblno       TYPE ztiiblno,
        l_iblit       TYPE ztiiblit,
        l_opnno       TYPE ztiopnno,
        l_rqmng       TYPE ztirqmng,
        l_blmng       TYPE ztiblmng,
        l_blmngl      TYPE ztiblmngi,
        l_blmngs      TYPE ztiblmngs,
        l_ivmngl      TYPE ztiivmngi,
        l_ivmngs      TYPE ztiivmngs,
        l_string      TYPE string,
        l_ctocd       TYPE ztictocd,
        l_reqty       TYPE ztireqty,
        l_subrc       LIKE sy-subrc,
        l_waers       LIKE tcurc-waers,
        l_ucurr       LIKE tcurc-waers,
        l_wrbtr       LIKE bapicurr-bapicurr,
        l_dtype       LIKE dd01v-datatype.

  FIELD-SYMBOLS: <l_field_from>,
                 <l_field_to>,
                 <l_field_icon>,
                 <l_blnum>,
                 <l_iblno>,
                 <l_iblit>,
                 <l_reqno>,
                 <l_reqit>,
                 <l_field>,
                 <l_fieldt>,
                 <l_menget>,
                 <l_meinst>,
                 <l_menge>,
                 <l_rqmng>,
                 <l_ivmng>,
                 <l_blmng>,
                 <l_meins>,
                 <l_waers>,
                 <l_netwr>,
                 <l_netpr>,
                 <l_refwr>,
                 <l_peinh>,
                 <l_bpumz>,
                 <l_bpumn>,
                 <l_wrbtr>,
                 <l_days>,
                 <l_field1>,
                 <l_field2>,
                 <l_logno>,
                 <l_field_error>.

  ASSIGN COMPONENT 'ICON'  OF STRUCTURE p_table TO <l_field_icon>.
  ASSIGN COMPONENT 'CHECK' OF STRUCTURE p_table TO <l_field_error>.
  ASSIGN COMPONENT 'LOGNO' OF STRUCTURE p_table TO <l_logno>.

  ASSIGN COMPONENT 'EBELN' OF STRUCTURE p_table TO <l_field1>.
  ASSIGN COMPONENT 'EBELP' OF STRUCTURE p_table TO <l_field2>.
  ASSIGN COMPONENT 'OPNNO' OF STRUCTURE p_table TO <l_field>.

  IF  NOT  <l_field>  IS INITIAL.
    TRANSLATE  <l_field>  TO  UPPER CASE.
  ENDIF.

  l_ebeln = <l_field1>.
  l_ebelp = <l_field2>.
  l_opnno = <l_field>.

  ASSIGN COMPONENT 'RQMNG' OF STRUCTURE p_table TO <l_rqmng>.
  ASSIGN COMPONENT 'BLMNG' OF STRUCTURE p_table TO <l_blmng>.
  ASSIGN COMPONENT 'IVMNG' OF STRUCTURE p_table TO <l_ivmng>.
  ASSIGN COMPONENT 'REFWR' OF STRUCTURE p_table TO <l_refwr>.

  ASSIGN COMPONENT 'MENGE' OF STRUCTURE p_table TO <l_menge>.
  ASSIGN COMPONENT 'MEINS' OF STRUCTURE p_table TO <l_meins>.

  ASSIGN COMPONENT 'NETPR' OF STRUCTURE p_table TO <l_netpr>.
  ASSIGN COMPONENT 'BPUMZ' OF STRUCTURE p_table TO <l_bpumz>.
  ASSIGN COMPONENT 'BPUMN' OF STRUCTURE p_table TO <l_bpumn>.
  ASSIGN COMPONENT 'PEINH' OF STRUCTURE p_table TO <l_peinh>.
  ASSIGN COMPONENT 'NETWR' OF STRUCTURE p_table TO <l_netwr>.

  ASSIGN COMPONENT 'REQNO' OF STRUCTURE p_table TO <l_reqno>.
  ASSIGN COMPONENT 'REQIT' OF STRUCTURE p_table TO <l_reqit>.
  l_reqno = <l_reqno>.
  l_reqit = <l_reqit>.

  ASSIGN COMPONENT 'IBLNO' OF STRUCTURE p_table TO <l_iblno>.
  ASSIGN COMPONENT 'IBLIT' OF STRUCTURE p_table TO <l_iblit>.
  ASSIGN COMPONENT 'BLNUM' OF STRUCTURE p_table TO <l_blnum>.

  IF  NOT  <l_blnum> IS INITIAL.
    TRANSLATE  <l_blnum>  TO  UPPER CASE.
  ENDIF.

  l_blnum = <l_blnum>.

  CLEAR: <l_field_error>.

*> 구매오더번호 체크.
  IF l_ebeln IS INITIAL .
    <l_field_error> = 'E'.
    PERFORM no_input_check IN PROGRAM ('ZTIR0000')
                           USING 'EKKO' 'EBELN' 'S'.
    PERFORM set_return_message USING 'E' <l_logno>
                                         <l_field1> <l_field2>.
  ENDIF.

*> 구매오더 품목번호 체크.
  IF l_ebelp IS INITIAL.
    <l_field_error> = 'E'.
    PERFORM no_input_check IN PROGRAM ('ZTIR0000')
                           USING 'EKPO' 'EBELP' 'S'.
    PERFORM set_return_message USING 'E' <l_logno>
                                         <l_field1> <l_field2>.
  ENDIF.

*> 구매문서 Check.
  IF NOT l_ebeln IS INITIAL AND
     NOT l_ebelp IS INITIAL.

    SELECT SINGLE *
      FROM ekko
     WHERE ebeln EQ l_ebeln.

    IF sy-subrc EQ 0.
      SELECT SINGLE *
        FROM t001
       WHERE bukrs EQ ekko-bukrs.

      ASSIGN COMPONENT 'BUKRS' OF STRUCTURE p_table TO <l_field>.
      <l_field> = ekko-bukrs.

      ASSIGN COMPONENT 'EKORG' OF STRUCTURE p_table TO <l_field>.
      <l_field> = ekko-ekorg.

      ASSIGN COMPONENT 'EKGRP' OF STRUCTURE p_table TO <l_field>.
      <l_field> = ekko-ekgrp.

      ASSIGN COMPONENT 'INCO1' OF STRUCTURE p_table TO <l_field>.
      <l_field> = ekko-inco1.

      ASSIGN COMPONENT 'LIFNR' OF STRUCTURE p_table TO <l_field>.
      <l_field> = p_lifnr.

      ASSIGN COMPONENT 'ZTERM' OF STRUCTURE p_table TO <l_field>.
      <l_field> = ekko-zterm.

      SELECT SINGLE *
        FROM ekpo
       WHERE ebeln EQ l_ebeln
         AND ebelp EQ l_ebelp.

      IF sy-subrc EQ 0.
        <l_menge> = ekpo-menge.
        <l_meins> = ekpo-meins.
        <l_netpr> = ekpo-netpr.
        <l_bpumz> = ekpo-bpumz.
        <l_bpumn> = ekpo-bpumn.
        <l_peinh> = ekpo-peinh.
        ASSIGN COMPONENT 'MATNR' OF STRUCTURE p_table TO <l_field>.
        <l_field> = ekpo-matnr.
        ASSIGN COMPONENT 'TXZ01' OF STRUCTURE p_table TO <l_field>.
        <l_field> = ekpo-txz01.
        ASSIGN COMPONENT 'WERKS' OF STRUCTURE p_table TO <l_field>.
        <l_field> = ekpo-werks.
        ASSIGN COMPONENT 'LGORT' OF STRUCTURE p_table TO <l_field>.
        <l_field> = ekpo-lgort.
        ASSIGN COMPONENT 'BPRME' OF STRUCTURE p_table TO <l_field>.
        <l_field> = ekpo-bprme.

        IF NOT ekpo-loekz IS INITIAL.
          <l_field_error> = 'E'.
          MESSAGE s713(me) WITH l_ebeln l_ebelp ekpo-loekz.
          PERFORM set_return_message USING 'E' <l_logno>
                                               l_ebeln l_ebelp.
        ENDIF.
*> B/L 이 존재할 경우,
        IF NOT l_blnum IS INITIAL.
          SELECT *
            FROM ztivbl00 UP TO 1 ROWS
           WHERE blnum EQ l_blnum
             AND ebeln EQ l_ebeln
             AND ebelp EQ l_ebelp.

          ENDSELECT.
          IF sy-subrc EQ 0.
            <l_blmng> = ztivbl00-blmng.
            <l_iblno> = ztivbl00-iblno.
            <l_iblit> = ztivbl00-iblit.
            <l_reqno> = ztivbl00-reqno.
            <l_reqit> = ztivbl00-reqit.

            SELECT SUM( ivmng )
              INTO l_ivmngs
              FROM ztiviv00
             WHERE ebeln EQ l_ebeln
               AND ebelp EQ l_ebelp
               AND iblno EQ ztivbl00-iblno
               AND iblit EQ ztivbl00-iblit
               AND reqno EQ ztivrq00-reqno
               AND reqit EQ ztivrq00-reqit.
            l_ivmngl = <l_blmng> - l_ivmngs.

*> 2004.8.5 삭제
*            IF <l_ivmng> GT l_ivmngl.
*              <l_field_error> = 'E'.
*              WRITE l_ivmngl TO g_menget(15) UNIT <l_meins>.
*              CONCATENATE g_menget <l_meins> INTO g_menget.
*              MESSAGE s301 WITH g_menget.
*              PERFORM set_return_message USING 'E' <l_logno>
*                                                   l_ebeln l_ebelp.
*            ENDIF.
            IF <l_ivmng> EQ l_ivmngl.
              ASSIGN COMPONENT 'EREKZ'
                               OF STRUCTURE p_table TO <l_field>.
              <l_field> = 'X'.
            ENDIF.
          ELSE.
            <l_field_error> = 'E'.
            MESSAGE s960 WITH l_ebeln l_ebelp l_blnum.
            PERFORM set_return_message USING 'E' <l_logno>
                                                 l_ebeln l_ebelp.
          ENDIF.
        ENDIF.
**수입개설번호	구매오더 	품번
        IF l_opnno IS INITIAL.
          <l_field_error> = 'E'.
          PERFORM no_input_check IN PROGRAM ('ZTIR0000')
                                 USING 'ZTITRQST' 'OPNNO' 'S'.
          PERFORM set_return_message USING 'E' <l_logno>
                                               l_ebeln l_ebelp.
        ELSEIF l_blnum IS INITIAL.
          SELECT *
            FROM ztivrq00 UP TO 1 ROWS
           WHERE opnno EQ l_opnno
             AND ebeln EQ l_ebeln
             AND ebelp EQ l_ebelp.
          ENDSELECT.
          IF sy-subrc EQ 0.
            <l_rqmng> = ztivrq00-rqmng.
            <l_reqno> = ztivrq00-reqno.
            <l_reqit> = ztivrq00-reqit.

            SELECT SUM( ivmng )
              INTO l_ivmngs
              FROM ztiviv00
             WHERE ebeln EQ l_ebeln
               AND ebelp EQ l_ebelp
               AND reqno EQ ztivrq00-reqno
               AND reqit EQ ztivrq00-reqit
               AND iblno EQ space.
            l_ivmngl = <l_rqmng> - l_ivmngs.
            IF <l_ivmng> GT l_ivmngl.
              <l_field_error> = 'E'.
              WRITE l_ivmngl TO g_menget(15) UNIT <l_meins>.
              CONCATENATE g_menget <l_meins> INTO g_menget.
              MESSAGE s324 WITH g_menget.
              PERFORM set_return_message USING 'E' <l_logno>
                                                   l_ebeln l_ebelp.
            ENDIF.
            IF <l_ivmng> EQ l_ivmngl.
              ASSIGN COMPONENT 'EREKZ'
                               OF STRUCTURE p_table TO <l_field>.
              <l_field> = 'X'.
            ENDIF.
          ELSE.
            <l_field_error> = 'E'.
            MESSAGE s959 WITH l_ebeln l_ebelp l_opnno.
            PERFORM set_return_message USING 'E' <l_logno>
                                                 l_ebeln l_ebelp.
          ENDIF.
        ENDIF.
*>
      ELSE.
        <l_field_error> = 'E'.
        MESSAGE s706(me) WITH l_ebeln l_ebelp.
        PERFORM set_return_message USING 'E' <l_logno>
                                             l_ebeln l_ebelp.
      ENDIF.
    ELSE.
      <l_field_error> = 'E'.
      MESSAGE s701(me) WITH l_ebeln.
      PERFORM set_return_message USING 'E' <l_logno>
                                           l_ebeln l_ebelp.
    ENDIF.
  ENDIF.

*>통화단위.
  ASSIGN COMPONENT 'WAERS' OF STRUCTURE p_table TO <l_waers>.
  IF <l_waers> IS INITIAL.
    <l_field_error> = 'E'.
    PERFORM no_input_check IN PROGRAM ('ZTIR0000')
                           USING 'ZTITIVK' 'WAERS' 'S'.
    PERFORM set_return_message USING 'E' <l_logno>
                                         l_ebeln l_ebelp.
  ELSE.
    PERFORM check_checktable_value USING 'TCURC' 'WAERS' 'WAERS'
                                         <l_waers> l_subrc.
    IF l_subrc NE 0.
      <l_field_error> = 'E'.
      PERFORM set_return_message USING 'E' <l_logno>
                                           l_ebeln l_ebelp.
    ENDIF.
  ENDIF.

*> 미착 IV 금액.
  ASSIGN COMPONENT 'IVAMP' OF STRUCTURE p_table TO <l_field>.
  IF <l_field> IS INITIAL.
    <l_field_error> = 'E'.
    PERFORM no_input_check IN PROGRAM ('ZTIR0000')
                           USING 'ZTITIVK' 'IVAMP' 'S'.
    PERFORM set_return_message USING 'E' <l_logno>
                                         l_ebeln l_ebelp.
  ELSE.
    l_string = <l_field>.
    PERFORM check_number_values  USING 'ZTIIVAMP' l_string 'S' l_subrc.
    IF l_subrc EQ 0.
      IF p_first_mode EQ 'X'.
        l_waers = <l_waers>.
        l_wrbtr = <l_field>.
        CALL FUNCTION 'BAPI_CURRENCY_CONV_TO_INTERNAL'
          EXPORTING
            currency             = l_waers
            amount_external      = l_wrbtr
            max_number_of_digits = 18
          IMPORTING
            amount_internal      = <l_field>.
      ENDIF.
    ELSE.
      <l_field_error> = 'E'.
      PERFORM set_return_message USING 'E' <l_logno>
                                           l_ebeln l_ebelp.
    ENDIF.
  ENDIF.

*> 미착 품목 IV 금액.
  ASSIGN COMPONENT 'IVAMT' OF STRUCTURE p_table TO <l_wrbtr>.
  IF <l_wrbtr> IS INITIAL.
    <l_field_error> = 'E'.
    PERFORM no_input_check IN PROGRAM ('ZTIR0000')
                           USING 'ZTITBLIV' 'IVAMT' 'S'.
    PERFORM set_return_message USING 'E' <l_logno>
                                         l_ebeln l_ebelp.
  ELSE.
    l_string = <l_wrbtr>.
    PERFORM check_number_values  USING 'ZTIIVAMT' l_string 'S' l_subrc.
    IF l_subrc EQ 0.
      IF p_first_mode EQ 'X'.
        l_waers = <l_waers>.
        l_wrbtr = <l_wrbtr>.
        CALL FUNCTION 'BAPI_CURRENCY_CONV_TO_INTERNAL'
          EXPORTING
            currency             = l_waers
            amount_external      = l_wrbtr
            max_number_of_digits = 18
          IMPORTING
            amount_internal      = <l_wrbtr>.
      ENDIF.
    ELSE.
      <l_field_error> = 'E'.
      PERFORM set_return_message USING 'E' <l_logno>
                                           l_ebeln l_ebelp.
    ENDIF.
  ENDIF.

*> 오류 체크.
  IF <l_field_error> EQ 'E'.
    <l_field_icon> = icon_red_light.
  ELSE.
    <l_field_icon> = icon_green_light.
  ENDIF.

ENDFORM.                    " set_others_fields
*&---------------------------------------------------------------------*
*&      Form  set_return_message
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM set_return_message  USING    p_msgty
                                  p_logno
                                  p_refno
                                  p_refit.

  MOVE:  p_refno   TO  it_msg-refno,
         p_refit   TO  it_msg-refit,
         p_logno   TO  it_msg-logno,
         sy-msgid  TO  it_msg-msgid,
         p_msgty   TO  it_msg-msgty,
         sy-msgno  TO  it_msg-msgno,
         sy-msgv1  TO  it_msg-msgv1,
         sy-msgv2  TO  it_msg-msgv2,
         sy-msgv3  TO  it_msg-msgv3,
         sy-msgv4  TO  it_msg-msgv4.

  COLLECT it_msg.

*    perform log_msg_add using sy-msgid
*                              p_msgty
*                              sy-msgno
*                              sy-msgv1
*                              sy-msgv2
*                              sy-msgv3
*                              sy-msgv4.
*

ENDFORM.                    " set_return_message

*&--------------------------------------------------------------------*
*&      Form  data_changed
*&--------------------------------------------------------------------*
*       text
*---------------------------------------------------------------------*
FORM data_changed USING rr_data_changed
                            TYPE REF TO cl_alv_changed_data_protocol.

  DATA : ls_mod_cells TYPE lvc_s_modi,
         ls_cells     TYPE lvc_s_modi,
         l_matnr      LIKE mara-matnr.

  LOOP AT rr_data_changed->mt_good_cells INTO ls_mod_cells.
    CASE ls_mod_cells-fieldname.
      WHEN 'ICON'  OR 'MEINS' OR 'REQNO' OR 'REQIT' OR
           'WAERS' OR 'IBLNO' OR 'IBLIT' OR 'GEWEI' OR
           'VOLEH' OR 'IVONO' OR 'RBLGP'.
      WHEN OTHERS.
        PERFORM mark_changed USING rr_data_changed ls_mod_cells.
    ENDCASE.
  ENDLOOP.

ENDFORM.                    "data_changed

*&--------------------------------------------------------------------*
*&      Form  mark_changed
*&--------------------------------------------------------------------*
FORM mark_changed  USING
      rr_data_changed TYPE REF TO cl_alv_changed_data_protocol
                                  rs_mod_cells TYPE lvc_s_modi.
  FIELD-SYMBOLS: <gs_table>.
  FIELD-SYMBOLS: <l_field>.
  FIELD-SYMBOLS: <l_field1>.

  ASSIGN LOCAL COPY OF INITIAL LINE OF <gt_table> TO <gs_table>.

*  READ TABLE <gt_table> INTO <gs_table> INDEX rs_mod_cells-tabix.
  READ TABLE <gt_table> INTO <gs_table> INDEX rs_mod_cells-row_id.
  IF sy-subrc EQ 0.
    ASSIGN COMPONENT 'LOGNO' OF STRUCTURE <gs_table> TO <l_field>.

    DELETE it_msg WHERE logno EQ <l_field>.

    ASSIGN COMPONENT rs_mod_cells-fieldname
                     OF STRUCTURE <gs_table> TO <l_field1>.

    CALL METHOD rr_data_changed->get_cell_value
      EXPORTING
        i_row_id    = rs_mod_cells-row_id
        i_fieldname = rs_mod_cells-fieldname
      IMPORTING
        e_value     = <l_field1>.

*> Fill Other fields
    PERFORM set_others_fields             USING  <gs_table>  space.

    MODIFY <gt_table> FROM <gs_table> INDEX rs_mod_cells-row_id.

    ASSIGN COMPONENT 'ICON'  OF STRUCTURE <gs_table> TO <l_field>.

    CALL METHOD rr_data_changed->modify_cell
      EXPORTING
        i_row_id    = rs_mod_cells-row_id
        i_fieldname = 'ICON'
        i_value     = <l_field>.

    ASSIGN COMPONENT 'MEINS' OF STRUCTURE <gs_table> TO <l_field>.
    CALL METHOD rr_data_changed->modify_cell
      EXPORTING
        i_row_id    = rs_mod_cells-row_id
        i_fieldname = 'MEINS'
        i_value     = <l_field>.

    ASSIGN COMPONENT 'REQNO' OF STRUCTURE <gs_table> TO <l_field>.
    CALL METHOD rr_data_changed->modify_cell
      EXPORTING
        i_row_id    = rs_mod_cells-row_id
        i_fieldname = 'REQNO'
        i_value     = <l_field>.

    ASSIGN COMPONENT 'REQIT' OF STRUCTURE <gs_table> TO <l_field>.
    CALL METHOD rr_data_changed->modify_cell
      EXPORTING
        i_row_id    = rs_mod_cells-row_id
        i_fieldname = 'REQIT'
        i_value     = <l_field>.

    ASSIGN COMPONENT 'IBLNO' OF STRUCTURE <gs_table> TO <l_field>.
    CALL METHOD rr_data_changed->modify_cell
      EXPORTING
        i_row_id    = rs_mod_cells-row_id
        i_fieldname = 'IBLNO'
        i_value     = <l_field>.

    ASSIGN COMPONENT 'IBLIT' OF STRUCTURE <gs_table> TO <l_field>.
    CALL METHOD rr_data_changed->modify_cell
      EXPORTING
        i_row_id    = rs_mod_cells-row_id
        i_fieldname = 'IBLIT'
        i_value     = <l_field>.

    ASSIGN COMPONENT 'WAERS' OF STRUCTURE <gs_table> TO <l_field>.
    CALL METHOD rr_data_changed->modify_cell
      EXPORTING
        i_row_id    = rs_mod_cells-row_id
        i_fieldname = 'WAERS'
        i_value     = <l_field>.
  ENDIF.

ENDFORM.                    " mark_changed
*&---------------------------------------------------------------------*
*&      Form  check_domain_value
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM check_domain_values  USING    p_domain LIKE  dd07l-domname
                                   p_value
                                   p_msgty
                                   p_subrc.

  TABLES: dd01t.

  CALL FUNCTION 'CHECK_DOMAIN_VALUES'
    EXPORTING
      domname       = p_domain
      value         = p_value
    EXCEPTIONS
      no_domname    = 1
      wrong_value   = 2
      dom_not_found = 3
      OTHERS        = 4.
  p_subrc = sy-subrc.
  IF sy-subrc EQ 2.
    SELECT *
      FROM dd01t UP TO 1 ROWS
     WHERE domname    EQ p_domain
       AND ddlanguage EQ sy-langu.
    ENDSELECT.
    IF sy-subrc EQ 0.
      MESSAGE ID 'ZMMI' TYPE p_msgty NUMBER '951'
              WITH dd01t-ddtext p_value space space .
    ELSE.
      MESSAGE ID 'ZMMI' TYPE p_msgty NUMBER '951'
              WITH p_domain p_value space space .
    ENDIF.
  ELSEIF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE p_msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

ENDFORM.                    " check_domain_value
*&---------------------------------------------------------------------*
*&      Form  check_number_values
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM check_number_values  USING    p_domain
                                   p_value
                                   p_msgty
                                   p_subrc.

  DATA: l_dtype       LIKE dd01v-datatype,
        l_value(100)  TYPE c.

  PERFORM set_write_no_mask IN PROGRAM ('ZTIR0000') USING p_value.

  l_value = p_value.


  CALL FUNCTION 'Z_TI_NUMBER_CHECK'
    EXPORTING
      string_in  = l_value
    IMPORTING
      string_out = l_value
      htype      = l_dtype.

  IF NOT l_dtype EQ 'NUMC'.
    SELECT *
      FROM dd01t UP TO 1 ROWS
     WHERE domname    EQ p_domain
       AND ddlanguage EQ sy-langu.
    ENDSELECT.
    IF sy-subrc EQ 0.
      MESSAGE ID 'ZMMI' TYPE p_msgty NUMBER '951'
              WITH dd01t-ddtext l_value space space .
    ELSE.
      MESSAGE ID 'ZMMI' TYPE p_msgty NUMBER '951'
              WITH p_domain l_value space space .
    ENDIF.
    p_subrc = 4.
  ELSE.
    p_subrc = 0.
  ENDIF.

ENDFORM.                    " check_number_values

*&---------------------------------------------------------------------*
*&      Form  check_date_values
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM check_date_values  USING      p_domain
                                   p_value
                                   p_msgty
                                   p_subrc.

  DATA: l_date       LIKE sy-datum.

  l_date = p_value.

  CALL FUNCTION 'DATE_CHECK_PLAUSIBILITY'
    EXPORTING
      date                      = p_value
    EXCEPTIONS
      plausibility_check_failed = 1
      OTHERS                    = 2.

  p_subrc = sy-subrc.

  IF sy-subrc <> 0.
    SELECT *
      FROM dd04t UP TO 1 ROWS
     WHERE rollname   EQ p_domain
       AND ddlanguage EQ sy-langu.
    ENDSELECT.
    IF sy-subrc EQ 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
      MESSAGE ID 'ZMMI' TYPE p_msgty NUMBER '953'
              WITH dd04t-ddtext p_value space space .
    ELSE.
      MESSAGE ID 'ZMMI' TYPE p_msgty NUMBER '953'
              WITH p_domain p_value space space .
    ENDIF.
  ENDIF.

ENDFORM.                    " check_date_values
*&---------------------------------------------------------------------*
*&      Form  CHECK_CHECKTABLE_VALUE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM check_checktable_value  USING    p_table
                                      p_field
                                      p_domain
                                      p_value
                                      p_subrc.
  DATA: where_clause TYPE string,
        l_mandt      LIKE sy-mandt.

  CONCATENATE p_field ' = ''' p_value '''' INTO where_clause.

  SELECT mandt
    INTO l_mandt
    FROM (p_table) UP TO 1 ROWS
   WHERE (where_clause).
  ENDSELECT.
  p_subrc = sy-subrc.
  IF p_subrc NE 0.
    MESSAGE ID '00' TYPE 'S' NUMBER '058'
            WITH p_value p_table space space .
  ENDIF.

ENDFORM.                    " CHECK_CHECKTABLE_VALUE

*&---------------------------------------------------------------------*
*&      Form  SET_UPLOAD_LOG
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM set_upload_log  USING    p_msgty
                              p_ivono
                              p_ivnum
                              p_ebeln
                              p_ebelp.

  DATA: l_msgtx  TYPE bapi_msg,
        l_tabix  TYPE sy-tabix,
        l_wrbtr  LIKE bapicurr-bapicurr.

  FIELD-SYMBOLS: <gs_table>,
                 <l_smamt>,
                 <l_refwr>,
                 <l_ivamt>,
                 <l_ivamp>,
                 <l_ivwon>,
                 <l_waers>,
                 <l_reqno>,
                 <l_reqit>,
                 <l_blnum>,
                 <l_iblno>,
                 <l_iblit>,
                 <l_ivono>,
                 <l_rblgp>,
                 <l_ebeln>,
                 <l_ebelp>.

  ASSIGN LOCAL COPY OF INITIAL LINE OF <gt_table> TO <gs_table>.

  ASSIGN COMPONENT 'IVONO' OF STRUCTURE
                            <gs_table> TO <l_ivono>.
  ASSIGN COMPONENT 'RBLGP' OF STRUCTURE
                            <gs_table> TO <l_rblgp>.
  ASSIGN COMPONENT 'BLNUM' OF STRUCTURE
                            <gs_table> TO <l_blnum>.
  ASSIGN COMPONENT 'EBELN' OF STRUCTURE
                            <gs_table> TO <l_ebeln>.
  ASSIGN COMPONENT 'EBELP' OF STRUCTURE
                            <gs_table> TO <l_ebelp>.
  ASSIGN COMPONENT 'IBLNO' OF STRUCTURE
                            <gs_table> TO <l_iblno>.
  ASSIGN COMPONENT 'IBLIT' OF STRUCTURE
                            <gs_table> TO <l_iblit>.
  ASSIGN COMPONENT 'REQNO' OF STRUCTURE
                            <gs_table> TO <l_reqno>.
  ASSIGN COMPONENT 'REQIT' OF STRUCTURE
                            <gs_table> TO <l_reqit>.
  ASSIGN COMPONENT 'WAERS' OF STRUCTURE
                            <gs_table> TO <l_waers>.
  ASSIGN COMPONENT 'IVAMP' OF STRUCTURE
                            <gs_table> TO <l_ivamp>.
  ASSIGN COMPONENT 'IVWON' OF STRUCTURE
                            <gs_table> TO <l_ivwon>.
  ASSIGN COMPONENT 'IVAMT' OF STRUCTURE
                            <gs_table> TO <l_ivamt>.

  CALL FUNCTION 'MESSAGE_TEXT_BUILD'
    EXPORTING
      msgid               = sy-msgid
      msgnr               = sy-msgno
      msgv1               = sy-msgv1
      msgv2               = sy-msgv2
      msgv3               = sy-msgv3
      msgv4               = sy-msgv4
    IMPORTING
      message_text_output = l_msgtx.


  LOOP AT <gt_table> INTO <gs_table>.
    l_tabix = sy-tabix.

*    IF ZTITIVK-prpyn EQ 'P'.      ">사전송금.
*
*    ELSEIF ZTITIVK-prpyn EQ 'I'.  ">송장.
*
*    ENDIF.

    READ TABLE xztitivp WITH KEY ebeln = <l_ebeln>
                                  ebelp = <l_ebelp>
                                  reqno = <l_reqno>
                                  reqit = <l_reqit>
                                  iblno = <l_iblno>
                                  iblit = <l_iblit>.
    IF sy-subrc EQ 0.
      MOVE-CORRESPONDING <gs_table> TO gt_download.
      MOVE: l_msgtx                 TO gt_download-msgtx,
            p_msgty                 TO gt_download-msgty.

      CALL FUNCTION 'BAPI_CURRENCY_CONV_TO_EXTERNAL'
        EXPORTING
          currency        = <l_waers>
          amount_internal = <l_ivamp>
        IMPORTING
          amount_external = l_wrbtr.
      gt_download-ivamp = l_wrbtr.

      CALL FUNCTION 'BAPI_CURRENCY_CONV_TO_EXTERNAL'
        EXPORTING
          currency        = <l_waers>
          amount_internal = <l_ivwon>
        IMPORTING
          amount_external = l_wrbtr.
      gt_download-ivwon = l_wrbtr.

      CALL FUNCTION 'BAPI_CURRENCY_CONV_TO_EXTERNAL'
        EXPORTING
          currency        = <l_waers>
          amount_internal = <l_ivamt>
        IMPORTING
          amount_external = l_wrbtr.
      gt_download-ivamt = l_wrbtr.
*
      gt_download-reqno = <l_reqno>.
      gt_download-reqit = <l_reqit>.
      gt_download-iblno = <l_iblno>.
      gt_download-iblit = <l_iblit>.
      gt_download-ivono = <l_ivono>.
      gt_download-rblgp = <l_rblgp>.
      APPEND gt_download.

    ENDIF.
  ENDLOOP.

ENDFORM.                    " SET_UPLOAD_LOG
*&---------------------------------------------------------------------*
*&      Form  set_invoice_data
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM set_invoice_data .

  TABLES: tcurc.
  DATA  : l_pkchg LIKE ztitivk-pkchg.
  DATA  : l_remng LIKE ztitivp-remng.
  DATA  : l_item  LIKE itemdata.
*  DATA  : l_LBLNI LIKE ESSR-LBLNI.

  FREE:  itemdata,   taxdata,          withtaxdata,
         return,     accountingdata,   vendoritemsplitdata.

  CLEAR: headerdata, invoicedocnumber, fiscalyear,        addressdata,
         itemdata,   taxdata,          withtaxdata,
         return,     accountingdata,   vendoritemsplitdata.

*iso code용.
  SELECT SINGLE *
    FROM tcurc
   WHERE waers EQ ztitivk-waers.

***>>>>>>>>>>>>header data
  IF ztitivk-vorgang EQ '1' OR ztitivk-vorgang EQ '3'.
    MOVE 'X'  TO headerdata-invoice_ind."지시자: 송장전기
  ELSE.
    MOVE ' '  TO headerdata-invoice_ind.
  ENDIF.

  MOVE  ztitivk-blart TO  headerdata-doc_type.  "전표유형
  MOVE  ztitivk-bldat TO  headerdata-doc_date.  "전표증빙일
  MOVE  ztitivk-budat TO  headerdata-pstng_date."전표의 전기일
  MOVE  ztitivk-xblnr TO  headerdata-ref_doc_no."참조전표번호
  MOVE  ztitivk-bukrs TO  headerdata-comp_code. "회사코드
  MOVE  ztitivk-lifnr TO  headerdata-diff_inv.  "다른 송장발행처
  MOVE  ztitivk-waers TO  headerdata-currency.  "통화키
  MOVE  tcurc-isocd    TO  headerdata-currency_iso."ISO 통화코드


*  IF ZTITIVK-waers NE t001-waers.
  MOVE  ztitivk-kursf TO  headerdata-exch_rate. "직접호가환율*
*    headerdata-EXCH_RATE_V."간접호가환율
*  ENDIF.
  WRITE : ztitivk-ivamp TO g_text_amount CURRENCY ztitivk-waers.
  PERFORM set_write_no_mask(ztir0000)   USING g_text_amount.
  MOVE  g_text_amount TO  headerdata-gross_amount."총송장금액
*  headerdata-CALC_TAX_IND."세금을 자동으로 계산
  MOVE  ztitivk-zterm TO  headerdata-pmnttrms.  "지급조건키
  MOVE  ztitivk-zfbdt TO  headerdata-bline_date."만기계산기준일
  MOVE  ztitivk-zbd1t TO  headerdata-dsct_days1."현금할인기간 1
  MOVE  ztitivk-zbd2t TO  headerdata-dsct_days2."현금 할인기간 2
  MOVE  ztitivk-zbd3t TO  headerdata-netterms.  "순액지급조건기간
  MOVE  ztitivk-zbd1p TO  headerdata-dsct_pct1. "현금할인율 1
  MOVE  ztitivk-zbd2p TO  headerdata-dsct_pct2. "현금할인율 1
*  headerdata-IV_CATEGORY."물류송장검증 문서의 원본
  MOVE  ztitivk-bktxt TO  headerdata-header_txt."전표헤더텍스트
  MOVE  ztitivk-zlspr TO  headerdata-pmnt_block."지급보류키

*>비계획운송비용.
  CLEAR l_pkchg.
  l_pkchg  =
  ztitivk-pkchg + ztitivk-hdchg + ztitivk-otchg.
*  ZTITIVK-pkchg + ZTITIVK-hdchg + ZTITIVK-otchg + ZTITIVK-rtchg.
  WRITE : l_pkchg TO g_text_amount CURRENCY ztitivk-waers.
  PERFORM set_write_no_mask(ztir0000)   USING g_text_amount.
  MOVE  g_text_amount TO  headerdata-del_costs."비계획운송비용
*  headerdata-DEL_COSTS_TAXC."운송비용 세금코드
*  headerdata-DEL_COSTS_TAXJ."운송비용에 대한 조세관할코드
  MOVE  sy-uname       TO  headerdata-person_ext."외부시스템 사용자.
  MOVE  ztitivk-zlsch TO  headerdata-pymt_meth. "지급방법
  MOVE  ztitivk-uzawe TO  headerdata-pmtmthsupl."지급방법보충

*> 2004.6.22 추가: INT NUMBER사용함.
*  MOVE  ZTITIVK-belnr TO  headerdata-inv_doc_no."송장문서문서번호
*> 2004.6.22 추가: INT NUMBER사용함.

*  headerdata-SCBANK_IND."중앙은행지시자
*  headerdata-SUPCOUNTRY."공급국가
*  headerdata-BLLSRV_IND."서비스지시자 (해외지급)
  MOVE  ztitivk-xblnr TO  headerdata-ref_doc_no_long."참조전표번호
*  headerdata-DSCT_AMOUNT."문서통화의 현금할인액
*  headerdata-PO_SUB_NO."POR 서명자번호
*  headerdata-PO_CHECKDG."POR 점검숫자
*  headerdata-PO_REF_NO."POR 참조번호
*  headerdata-PAYEE_PAYER."수취인 / 지급인
*  headerdata-PARTNER_BK."거래처은행유형
*  headerdata-HOUSEBANKID."거래은행에 대한 단축키
*  headerdata-ALLOC_NMBR."지정번호
*  headerdata-PAYMT_REF."지급참조
*  headerdata-INV_REF_NO."송장참조: 송장참조를 위한 문서번호
*  headerdata-INV_YEAR."관련송장의 회계연도 (대변메모)
*  headerdata-INV_REC_DATE."송장수령일
*  headerdata-PLANNING_LEVEL."계획레벨
*  headerdata-PLANNING_DATE."계획일
*  headerdata-FIXEDTERMS."고정지급조건
  MOVE  ztitivk-gsber TO  headerdata-bus_area.  "사업영역
*  headerdata-LOT_NUMBER."전표 로트번호
  MOVE  ztitivk-sgtxt TO  headerdata-item_text. "항목텍스트

**> 분할금액이 있을 경우.
*  DESCRIBE TABLE it_ZTItivv LINES g_line.
*  CLEAR: g_count.
*  IF g_line GT 0.
**  IF NOT ZTITIVK-rtchg IS INITIAL.
*    LOOP AT it_ZTItivv.
*     WRITE:it_ZTItivv-splam TO g_text_amount CURRENCY ZTITIVK-waers.
*      PERFORM set_write_no_mask(ZTIr0000)   USING g_text_amount.
*      MOVE: it_ZTItivv-split TO vendoritemsplitdata-split_key,
*            g_text_amount     TO vendoritemsplitdata-split_amount,
*            it_ZTItivv-zlsch TO vendoritemsplitdata-pymt_meth,
*            it_ZTItivv-mwskz TO vendoritemsplitdata-tax_code,
*            it_ZTItivv-uzawe TO vendoritemsplitdata-pmtmthsupl,
*            it_ZTItivv-zterm TO vendoritemsplitdata-pmnttrms.
*      APPEND vendoritemsplitdata.
*    ENDLOOP.
*  ENDIF.

*>>>>>>>>>>>>>>>item.
  LOOP AT xztitivp.
    "송장문서의 문서품목
    MOVE xztitivp-ebeln    TO itemdata-po_number.  "구매오더번호
    MOVE xztitivp-ebelp    TO itemdata-po_item.    "구매문서 품목번호
    MOVE xztitivp-tbtkz    TO itemdata-de_cre_ind. "후속 차변/대변
    MOVE ztitivk-mwskz     TO itemdata-tax_code.     "세금코드
    WRITE : xztitivp-ivamt TO g_text_amount CURRENCY ztitivk-waers.
    PERFORM set_write_no_mask(ztir0000) USING g_text_amount.
    MOVE g_text_amount         TO  itemdata-item_amount."전표통화금액
*> 송장처리수량 = 송장수량 - 선급수량.
*    l_remng = g_tc_2130_wa-remng - g_tc_2130_wa-ppmng.
    l_remng = xztitivp-remng.
    IF l_remng LE 0.
      CONTINUE.
    ENDIF.

    WRITE : l_remng            TO g_text_amount UNIT xztitivp-meins.
    PERFORM set_write_no_mask(ztir0000) USING g_text_amount.
    MOVE g_text_amount         TO  itemdata-quantity.   "수량
    MOVE xztitivp-meins       TO  itemdata-po_unit.    "오더단위
*        itemdata-PO_UNIT_ISO"ISO 코드 오더단위

    SELECT SINGLE peinh bprme
      FROM ekpo
      INTO (itemdata-po_pr_qnt,itemdata-po_pr_uom)
     WHERE ebeln EQ xztitivp-ebeln
       AND ebelp EQ xztitivp-ebelp.
    MOVE xztitivp-sgtxt TO  itemdata-item_text.  "항목텍스트
***** 서비스 오더에 대한 로직.
*   입력서 번호 찾기.
    SELECT SINGLE lblni
      FROM essr
      INTO itemdata-sheet_no
     WHERE ebeln EQ xztitivp-ebeln
       AND ebelp EQ xztitivp-ebelp.

*   입력서 번호가 있으면 수량/단위 clear.
    IF NOT itemdata-sheet_no IS INITIAL.
      CLEAR : itemdata-quantity, itemdata-po_unit,
              itemdata-po_pr_qnt,itemdata-po_pr_uom.
    ENDIF.
**********

    READ TABLE itemdata INTO l_item
                        WITH KEY po_number = itemdata-po_number
                                 po_item   = itemdata-po_item.
    IF sy-subrc EQ 0.
      itemdata-po_pr_qnt = 0.
    ENDIF.

    COLLECT itemdata.
*    APPEND itemdata.
  ENDLOOP.

  CLEAR: g_count.
  LOOP AT itemdata.
    ADD 1 TO g_count.
    itemdata-invoice_doc_item = g_count.
    MODIFY itemdata.
  ENDLOOP.

  CLEAR: taxdata.
*  taxdata-tax_code         =  ZTITIVK-mwskz. "부가가치세코드.
  taxdata-tax_amount       =  0.     "전표통화세액.
  taxdata-tax_base_amount  =  0.     "문서통화로 표시된 과세표준액.
  APPEND taxdata.

ENDFORM.                    " set_invoice_data
*&---------------------------------------------------------------------*
*&      Form  set_invoice_header_data
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM set_invoice_header_data  USING   p_ivnum.

  MOVE: sy-mandt       TO ztitivk-mandt,
        ztitivk-ivamp TO ztitivk-ivamt,
        '1'            TO ztitivk-vorgang,
        'RE'           TO ztitivk-blart,
        p_budat        TO ztitivk-budat,
        p_bldat        TO ztitivk-civdt,
        p_bldat        TO ztitivk-bldat,
        '1100'         TO ztitivk-bupla,
        p_mwskz        TO ztitivk-mwskz,
        p_ivnum        TO ztitivk-xblnr,
        p_ivnum        TO ztitivk-sgtxt,
        '수입미착물대' TO ztitivk-bktxt,
        'N'            TO ztitivk-livst.

  MOVE: sy-uname   TO   ztitivk-cnam,
        sy-datlo   TO   ztitivk-cdat,
        sy-timlo   TO   ztitivk-ctme,

        sy-uname   TO   ztitivk-unam,
        sy-datlo   TO   ztitivk-udat,
        sy-timlo   TO   ztitivk-utme.

ENDFORM.                    " set_invoice_header_data
*&---------------------------------------------------------------------*
*&      Form  call_bapi_function
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM call_bapi_function .

  CALL FUNCTION 'Z_TI_BAPI_INVOICE_CREATE'
          EXPORTING
               headerdata             = headerdata
               addressdata            = addressdata
               empfb                  = space
               bupla                  = '1100'
               simulation             = space
          IMPORTING
               invoicedocnumber       = invoicedocnumber
               fiscalyear             = fiscalyear
          TABLES
               itemdata               = itemdata
               accountingdata         = accountingdata
               glaccountdata          = glaccountdata
               taxdata                = taxdata
*               WITHTAXDATA            = WITHTAXDATA
               vendoritemsplitdata    = vendoritemsplitdata
               return                 = return.


ENDFORM.                    " call_bapi_function
