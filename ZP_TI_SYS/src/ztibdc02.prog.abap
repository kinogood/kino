************************************************************************
* Title         :  ZTIBDC02                                            *
*                                                                      *
* Description   : [BDC] OPEN B/L(AWB) Upload                           *
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
REPORT  ztibdc02       MESSAGE-ID zmmi
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
        ztivrq00,
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
        bldty(01),            "문서종류.
        blnum(25),            "B/L 번호.
        rptty(01),            "수입신고구분.
        brgew(17),            "총중량(KG기준).
        volum(17),            "볼륨(M3기준).
        bletd(10),            "ETD.
        bleta(10),            "ETA.
        bldat(10),            "B/L발행일.
        inydt(10),            "YARD도착예정일.
        ivsln(35),            "선기명(주운송수단).
        smamt(20),            "미착금액(총금액).
*> ITEM
        opnno(20),            "개설문서번호.
        ebeln(10),            "구매문서.
        ebelp(05),            "구매문서 품목번호.
        blmng(20),            "B/L 수량.
        refwr(20),            "품목별 금액.
        reqno(10),            "수입의뢰 관리번호.
        reqit(05),            "수입의뢰 품목번호.
        notye(03),            "미착 IV 대상.
        ivamt(20),            "미착 IV 금액.
        iblno(10),            "B/L 관리번호.
        iblit(05),            "B/L 품목번호.
        END   OF ty_upload.

DATA:  gs_upload   TYPE ty_upload.

DATA: gt_upload_list  LIKE gs_upload OCCURS 0 WITH HEADER LINE,
      gt_upload_title LIKE gs_upload OCCURS 0 WITH HEADER LINE,
      gs_upload_list  LIKE gs_upload.

DATA: BEGIN OF gs_download.
        INCLUDE STRUCTURE gs_upload.
DATA: msgty      TYPE  bapi_mtype,
      msgtx      TYPE  bapi_msg,
      END   OF gs_download.

DATA: gt_download  LIKE gs_download OCCURS 0 WITH HEADER LINE.

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
      p_mode(1).

DATA: file_path(1200),
      file_name(1200),
      p_down              LIKE rlgrap-filename,
      p_sdown             LIKE rlgrap-filename.


************************************************************************
* SELECT-OPTIONS / PARAMETERS                                          *
************************************************************************
SELECTION-SCREEN BEGIN OF BLOCK blk1 WITH FRAME.
PARAMETERS: p_upload  LIKE rlgrap-filename             " UPLOAD File
                      DEFAULT 'C:\upload\OPEN_BL.xls'
                                                       OBLIGATORY.
*SELECTION-SCREEN SKIP 1.
*PARAMETERS: p_down    LIKE rlgrap-filename             " DOWNLOAD File
*                 DEFAULT 'C:\upload\LC_UPLOAD_ERROR.xls'
*                                         OBLIGATORY.
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

*AT SELECTION-SCREEN  ON VALUE-REQUEST FOR p_down.
*  PERFORM filename_get_up USING 'P_DOWN'.
*
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
  DATA:it_excl LIKE ztisexcel  OCCURS 0 WITH HEADER LINE,
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
      i_end_col               = 50
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
  ac 'ITAB   CHECK ZTITRQS                      FWDTY X'.
  ac 'ITAB   BLMNGLZTITBLP                      BLMNGLXQMEINS'.

  ac 'ITAB   INCO1 ZTITBLK                      INCO1 X'.
  ac 'ITAB   LIFNR ZTITBLK                      LIFNR X'.
  ac 'ITAB   BUKRS ZTITBLK                      BUKRS X'.
  ac 'ITAB   EKORG ZTITBLK                      EKORG X'.
  ac 'ITAB   EKGRP ZTITBLK                      EKGRP X'.

  ac 'ITAB   FLAND ZTITBLK                      FLAND X'.
  ac 'ITAB   FPORT ZTITBLK                      FPORT X'.
  ac 'ITAB   PLLOD ZTITBLK                      PLLOD X'.
  ac 'ITAB   TLAND ZTITBLK                      TLAND X'.
  ac 'ITAB   TPORT ZTITBLK                      TPORT X'.
  ac 'ITAB   PLTRN ZTITBLK                      PLTRN X'.
  ac 'ITAB   FWDTY ZTITBLK                      FWDTY X'.

  ac 'ITAB   MENGE EKPO                         MENGE X'.
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

  ac 'ITAB   EBELN ZTITBLP                      EBELN  '.
  ac 'ITAB   EBELP ZTITBLP                      EBELP  '.
  ac 'ITAB   OPNNO ZTIVRQ04                     OPNNO  '.
  ac 'ITAB   REQNO ZTITBLP                      REQNO  '.
  ac 'ITAB   REQIT ZTITBLP                      REQIT  '.

  ac 'ITAB   BLDTY ZTITBLK                      BLDTY  '.
  ac 'ITAB   BLNUM ZTITBLK                      BLNUM  '.
  ac 'ITAB   RPTTY ZTITBLK                      RPTTY  '.
  ac 'ITAB   BRGEW ZTITBLK                      BRGEW  QGEWEI'.
  ac 'ITAB   GEWEI ZTITBLK                      GEWEI  '.
  ac 'ITAB   VOLUM ZTITBLK                      VOLUM  QVOLEH'.
  ac 'ITAB   VOLEH ZTITBLK                      VOLEH  '.
  ac 'ITAB   BLETD ZTITBLK                      BLETD  '.
  ac 'ITAB   BLETA ZTITBLK                      BLETA  '.
  ac 'ITAB   BLDAT ZTITBLK                      BLDAT  '.
  ac 'ITAB   INYDT ZTITBLK                      INYDT  '.
  ac 'ITAB   IVSLN ZTITBLK                      IVSLN  '.
  ac 'ITAB   SMAMT ZTITBLK                      SMAMT  CWAERS  '.
  ac 'ITAB   WAERS ZTITBLK                      WAERS  '.
*> ITEM
  ac 'ITAB   BLMNG ZTITBLP                      BLMNG  QMEINS'.
  ac 'ITAB   MEINS ZTITBLP                      MEINS  '.
  ac 'ITAB   REFWR ZTITBLP                      REFWR  CWAERS  '.
*  ac 'ITAB   IVAMT ZTITBLP                     IVAMT  CWAERS  '.
*  ac 'ITAB   NOTYE ZTITBLP                     NOTYE  '.
  ac 'ITAB   IBLNO ZTITBLP                      IBLNO  '.
  ac 'ITAB   IBLIT ZTITBLP                      IBLIT  '.

  fc1[] = fc[].

  ac 'ITAB   COLOR SLIS_T_SPECIALCOL_ALV              X'.

  LOOP AT fc1 INTO fcs.
    CLEAR: fcs-key .
    CASE fcs-fieldname.
      WHEN 'REQNO' OR 'REQIT' OR 'MEINS' OR 'LAND1' OR
           'GEWEI' OR 'VOLEH' OR 'WAERS' OR
           'IBLNO' OR 'IBLIT'.
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
  PERFORM build_fields_table USING : 'ZTITBLK' <gs_table>,
                                     'ZTITBLP' <gs_table>,
                                     'ZTITRQS' <gs_table>.
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
  header-info = 'Open L/C 및 T/T Upload '.
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
  DATA: l_tabix   LIKE sy-tabix.
  DATA: l_subrc   LIKE sy-subrc.
  DATA: l_tcode   LIKE sy-tcode.
  DATA: l_reqno   TYPE ztireqno.
  DATA: l_amdsq   TYPE ztiamdsq.
  DATA: l_lcono   TYPE ztireqno.

  DATA: lt_fc     TYPE kkblo_t_fieldcat,
        ls_fc     TYPE kkblo_fieldcat.

  DATA: BEGIN OF lt_blnum OCCURS 0,
        blnum     TYPE ztiblnum,
        END   OF lt_blnum.

  DATA: BEGIN OF lt_err_blnum OCCURS 0,
        blnum     TYPE ztiblnum,
        END   OF lt_err_blnum.

  DATA : BEGIN OF xztitblp OCCURS 0.
          INCLUDE STRUCTURE vztitblp.
  DATA : END   OF xztitblp.

  FIELD-SYMBOLS: <gs_table>,
                 <l_field>,
                 <l_field1>,
                 <l_field2>,
                 <l_ebeln>,
                 <l_ebelp>,
                 <l_iblno>,
                 <l_iblit>,
                 <l_reqno>,
                 <l_reqit>.

  ASSIGN LOCAL COPY OF INITIAL LINE OF <gt_table> TO <gs_table>.

  REFRESH:   lt_err_blnum.

  CASE r_ucomm.
    WHEN 'ZTIUPLOAD'.
      ASSIGN COMPONENT 'CHECK' OF STRUCTURE
                            <gs_table> TO <l_field>.
      ASSIGN COMPONENT 'IBLNO' OF STRUCTURE
                            <gs_table> TO <l_field1>.
      ASSIGN COMPONENT 'BLNUM' OF STRUCTURE
                            <gs_table> TO <l_field2>.
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

      CLEAR: l_count, g_post_chk.

      LOOP AT <gt_table> INTO <gs_table>.
        IF <l_field> EQ 'E'.
          ADD 1 TO l_count.
*> 2004.6.21 오류 로그 추가
*<<
          lt_err_blnum-blnum = <l_field2>.
          COLLECT lt_err_blnum.

        ELSE.

          IF NOT <l_field1> IS INITIAL.
            g_post_chk = 'X'.
          ENDIF.
          lt_blnum-blnum = <l_field2>.
          COLLECT lt_blnum.

        ENDIF.

      ENDLOOP.

*<<   2004.6.21 오류 로그 추가
*> 오류 번호 삭제.

      LOOP AT lt_blnum.
        DELETE lt_blnum WHERE blnum = lt_err_blnum-blnum.
      ENDLOOP.
*>>   2004.6.21 오류 로그 추가

      IF l_count NE 0.
        MESSAGE i957.   "EXIT.
      ENDIF.

      IF g_post_chk EQ 'X'.
        MESSAGE i958.  EXIT.
      ENDIF.

*<<   2004.6.21 오류 로그 추가
      ASSIGN COMPONENT 'LOGNO' OF STRUCTURE
                              <gs_table> TO <l_field1>.

      LOOP AT lt_err_blnum.

        CLEAR: l_count.
        REFRESH : xztitblp.

        LOOP AT <gt_table> INTO <gs_table>.
          IF <l_field2> EQ lt_err_blnum-blnum.
            ADD 1 TO l_count.
            MOVE-CORRESPONDING : <gs_table> TO ztitblk.

            MOVE-CORRESPONDING <gs_table> TO xztitblp.
            xztitblp-mandt = sy-mandt.
            xztitblp-iblit = l_count.
            APPEND xztitblp.
          ENDIF.
          ztitblk-lponr = l_count.
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
                                        lt_err_blnum-blnum
                                        <l_ebeln>
                                        <l_ebelp>.
      ENDLOOP.

*>>   2004.6.21 오류 로그 추가

*> 정상데이터처리
      LOOP AT lt_blnum.
        CLEAR: l_count.
        REFRESH : xztitblp.

        LOOP AT <gt_table> INTO <gs_table>.
          IF <l_field> EQ 'E'.
            l_tabix = sy-tabix.
          ENDIF.
          IF <l_field2> EQ lt_blnum-blnum.
            ADD 1 TO l_count.
            MOVE-CORRESPONDING : <gs_table> TO ztitblk.

            MOVE-CORRESPONDING <gs_table> TO xztitblp.
            xztitblp-mandt = sy-mandt.
            xztitblp-iblit = l_count.
            APPEND xztitblp.
          ENDIF.
          ztitblk-lponr = l_count.
        ENDLOOP.

        IF l_count GT 0.
*> Begin work
          SET UPDATE TASK LOCAL.

          CALL FUNCTION 'Z_TI_GET_NUMBER_NEXT'
            EXPORTING
              zmpty    = 'BL'
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
                                            lt_blnum-blnum
                                            <l_ebeln>
                                            <l_ebelp>.
            CONTINUE.
          ENDIF.

          MOVE: sy-mandt       TO ztitblk-mandt,
                l_lcono        TO ztitblk-iblno,
                ztitblk-smamt TO ztitblk-ivamt,
                'Y'            TO ztitblk-appct.


          MOVE: sy-uname   TO   ztitblk-cnam,
                sy-datlo   TO   ztitblk-cdat,
                sy-timlo   TO   ztitblk-ctme,

                sy-uname   TO   ztitblk-unam,
                sy-datlo   TO   ztitblk-udat,
                sy-timlo   TO   ztitblk-utme.

*> Status table modify
          MODIFY ztitblk.
          IF sy-subrc NE 0.
            ROLLBACK WORK.
            MESSAGE s912.
            PERFORM  set_upload_log  USING  'E'
                                            lt_blnum-blnum
                                            <l_ebeln>
                                            <l_ebelp>.
            CONTINUE.
          ENDIF.

          LOOP AT xztitblp.
            xztitblp-iblno = ztitblk-iblno.
            xztitblp-cnam  = sy-uname.
            xztitblp-cdat  = sy-datlo.
            xztitblp-ctme  = sy-timlo.
            xztitblp-unam  = sy-uname.
            xztitblp-udat  = sy-datlo.
            xztitblp-utme  = sy-timlo.
            MODIFY xztitblp.
          ENDLOOP.
          MODIFY ztitblp FROM TABLE xztitblp.
          IF sy-subrc NE 0.
            ROLLBACK WORK.
            MESSAGE s912.
            PERFORM  set_upload_log  USING  'E'
                                            lt_blnum-blnum
                                            <l_ebeln>
                                            <l_ebelp>.
            CONTINUE.
          ENDIF.

          LOOP AT <gt_table> INTO <gs_table>.
            l_tabix = sy-tabix.
            IF <l_field2> EQ lt_blnum-blnum.
              READ TABLE xztitblp WITH KEY ebeln = <l_ebeln>
                                            ebelp = <l_ebelp>
                                            reqno = <l_reqno>
                                            reqit = <l_reqit>.
              IF sy-subrc EQ 0.
                <l_iblno> = xztitblp-iblno.
                <l_iblit> = xztitblp-iblit.
                MODIFY <gt_table> FROM <gs_table> INDEX l_tabix.

              ENDIF.
            ENDIF.
          ENDLOOP.
          MESSAGE s202 WITH xztitblp-iblno.
          PERFORM  set_upload_log  USING  'S'
                                          lt_blnum-blnum
                                          <l_ebeln>
                                          <l_ebelp>.
          COMMIT WORK.
        ENDIF.
      ENDLOOP.

*> DownLoad files.
      PERFORM split_path(oaall) USING p_upload file_path file_name.

      CONCATENATE file_path '\' 'BL_Upload_Log_' sy-datlo
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
        MESSAGE i997 WITH
        'B/L 생성완료 결과를' p_down '로 다운로드 하였습니다!!!'.
      ENDIF.

      rs_selfield-refresh = 'X'.

    WHEN 'DISPLAY' OR '&IC1'.    " AUF DOPPELKLICK REAGIERIEN
      CHECK rs_selfield-tabindex GT 0.

      IF  rs_selfield-fieldname  =  'IBLNO'  AND
          NOT rs_selfield-value  IS  INITIAL.
        SET  PARAMETER  ID  'ZTIIBLNO'  FIELD  rs_selfield-value.
        CALL  TRANSACTION  'ZTIT203'  AND SKIP   FIRST  SCREEN.
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
FORM set_others_fields  USING    p_table
                                 p_first_mode.

  DATA: l_ebeln       TYPE ebeln,
        l_ebelp       TYPE ebelp,
        l_reqno       TYPE ztireqno,
        l_reqit       TYPE ztireqit,
        l_opnno       TYPE ztiopnno,
        l_rqmng       TYPE ztirqmng,
        l_blmng       TYPE ztiblmng,
        l_blmngl      TYPE ztiblmngi,
        l_blmngs      TYPE ztiblmngs,
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
                 <l_reqno>,
                 <l_reqit>,
                 <l_field>,
                 <l_fieldt>,
                 <l_menget>,
                 <l_meinst>,
                 <l_menge>,
                 <l_rqmng>,
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
                 <l_fwdty>,
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
  l_ebeln = <l_field1>.
  l_ebelp = <l_field2>.
  l_opnno = <l_field>.

  ASSIGN COMPONENT 'RQMNG' OF STRUCTURE p_table TO <l_rqmng>.
  ASSIGN COMPONENT 'BLMNG' OF STRUCTURE p_table TO <l_blmng>.
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
  ASSIGN COMPONENT 'FWDTY' OF STRUCTURE p_table TO <l_fwdty>.

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
      <l_field> = ekko-lifnr.

      ASSIGN COMPONENT 'WAERS' OF STRUCTURE p_table TO <l_field>.
      <l_field> = ekko-waers.

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
**수입개설번호	구매오더 	품번
        IF l_opnno IS INITIAL.
          <l_field_error> = 'E'.
          PERFORM no_input_check IN PROGRAM ('ZTIR0000')
                                 USING 'ZTITRQS' 'OPNNO' 'S'.
          PERFORM set_return_message USING 'E' <l_logno>
                                               l_ebeln l_ebelp.
        ELSE.
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
            <l_fwdty> = ztivrq00-fwdty.

            ASSIGN COMPONENT 'STAWN' OF STRUCTURE p_table TO <l_field>.
            <l_field> = ztivrq00-stawn.
            ASSIGN COMPONENT 'FLAND' OF STRUCTURE p_table TO <l_field>.
            <l_field> = ztivrq00-fland.
            ASSIGN COMPONENT 'FPORT' OF STRUCTURE p_table TO <l_field>.
            <l_field> = ztivrq00-fport.
            ASSIGN COMPONENT 'PLLOD' OF STRUCTURE p_table TO <l_field>.
            <l_field> = ztivrq00-pllod.
            ASSIGN COMPONENT 'TLAND' OF STRUCTURE p_table TO <l_field>.
            <l_field> = ztivrq00-tland.
            ASSIGN COMPONENT 'TPORT' OF STRUCTURE p_table TO <l_field>.
            <l_field> = ztivrq00-tport.
            ASSIGN COMPONENT 'PLTRN' OF STRUCTURE p_table TO <l_field>.
            <l_field> = ztivrq00-pltrn.

            SELECT SUM( blmng )
              INTO l_blmngs
              FROM ztitblp
             WHERE ebeln EQ l_ebeln
               AND ebelp EQ l_ebelp
               AND reqno EQ ztivrq00-reqno
               AND reqit EQ ztivrq00-reqit.

            l_blmngl = <l_rqmng> - l_blmngs.

*> 2004.8.5: 삭제
*            IF <l_blmng> GT l_blmngl.
*              <l_field_error> = 'E'.
*              WRITE l_blmngl TO g_menget(15) UNIT <l_meins>.
*              CONCATENATE g_menget <l_meins> INTO g_menget.
*              MESSAGE s208 WITH g_menget.
*              PERFORM set_return_message USING 'E' <l_logno>
*                                                   l_ebeln l_ebelp.
*            ENDIF.

            IF <l_blmng> EQ l_blmngl.
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

*> 문서종류.
  ASSIGN COMPONENT 'BLDTY' OF STRUCTURE p_table TO <l_field>.
  IF NOT ( <l_field> EQ 'A' OR
           <l_field> EQ 'C' OR
           <l_field> EQ 'O' OR
           <l_field> EQ 'S' OR
           <l_field> EQ ' ' ).
    <l_field_error> = 'E'.
    PERFORM check_domain_values  USING 'ZTIBLDTY' <l_field> 'S' l_subrc.
    IF l_subrc NE 0.
      PERFORM set_return_message USING 'E' <l_logno>
                                           l_ebeln l_ebelp.
    ENDIF.
  ENDIF.

*> B/L 번호.
  ASSIGN COMPONENT 'BLNUM' OF STRUCTURE p_table TO <l_field>.
  IF <l_field> IS INITIAL.
    <l_field_error> = 'E'.
    PERFORM no_input_check IN PROGRAM ('ZTIR0000')
                           USING 'ZTITBLK' 'BLNUM' 'S'.
    PERFORM set_return_message USING 'E' <l_logno>
                                         l_ebeln l_ebelp.
  ENDIF.

  IF  NOT  <l_field>  IS  INITIAL.
    TRANSLATE  <l_field>  TO  UPPER  CASE.
  ENDIF.

*> 수입신고구분.
  ASSIGN COMPONENT 'RPTTY' OF STRUCTURE p_table TO <l_field>.
  IF NOT ( <l_field> EQ '1' OR
           <l_field> EQ '2' OR
           <l_field> EQ '3' OR
           <l_field> EQ 'Z' ).
    <l_field_error> = 'E'.
    PERFORM check_domain_values  USING 'ZTIRPTTY' <l_field> 'S' l_subrc.
    IF l_subrc NE 0.
      PERFORM set_return_message USING 'E' <l_logno>
                                           l_ebeln l_ebelp.
    ENDIF.
  ENDIF.

*>총중량.
  ASSIGN COMPONENT 'BRGEW' OF STRUCTURE p_table TO <l_menget>.
  IF <l_menget> IS INITIAL.
*    <l_field_error> = 'E'.
*    PERFORM no_input_check IN PROGRAM ('ZTIR0000')
*                           USING 'ZTITBLK' 'BRGEW' 'S'.
*    PERFORM set_return_message USING 'E' <l_logno>
*                                         l_ebeln l_ebelp.
  ELSE.
    l_string = <l_menget>.
    PERFORM check_number_values  USING 'ZTIBRGEW' l_string 'S' l_subrc.
    IF l_subrc NE 0.
      <l_field_error> = 'E'.
      PERFORM set_return_message USING 'E' <l_logno>
                                           l_ebeln l_ebelp.
    ENDIF.
  ENDIF.
  ASSIGN COMPONENT 'GEWEI' OF STRUCTURE p_table TO <l_meinst>.
  <l_meinst> = 'KG'.

*>볼륨.
  ASSIGN COMPONENT 'VOLUM' OF STRUCTURE p_table TO <l_menget>.
  IF <l_menget> IS INITIAL.
*    <l_field_error> = 'E'.
*    PERFORM no_input_check IN PROGRAM ('ZTIR0000')
*                           USING 'ZTITBLK' 'VOLUM' 'S'.
*    PERFORM set_return_message USING 'E' <l_logno>
*                                         l_ebeln l_ebelp.
  ELSE.
    l_string = <l_menget>.
    PERFORM check_number_values  USING 'ZTIVOLUM' l_string 'S' l_subrc.
    IF l_subrc NE 0.
      <l_field_error> = 'E'.
      PERFORM set_return_message USING 'E' <l_logno>
                                           l_ebeln l_ebelp.
    ENDIF.
  ENDIF.
  ASSIGN COMPONENT 'VOLEH' OF STRUCTURE p_table TO <l_meinst>.
  <l_meinst> = 'M3'.

*>ETD.
  ASSIGN COMPONENT 'BLETD' OF STRUCTURE p_table TO <l_field>.
  IF NOT <l_field> IS INITIAL..
    PERFORM check_date_values  USING 'ZTIBLETD' <l_field> 'S' l_subrc.
    IF l_subrc NE 0.
      <l_field_error> = 'E'.
      PERFORM set_return_message USING 'E' <l_logno>
                                           l_ebeln l_ebelp.
    ENDIF.
  ELSE.
    <l_field_error> = 'E'.
    PERFORM no_input_check IN PROGRAM ('ZTIR0000')
                           USING 'ZTITBLK' 'BLETD' 'S'.
    PERFORM set_return_message USING 'E' <l_logno>
                                         l_ebeln l_ebelp.
  ENDIF.

*>ETA.
  ASSIGN COMPONENT 'BLETA' OF STRUCTURE p_table TO <l_field>.
  IF NOT <l_field> IS INITIAL..
    PERFORM check_date_values  USING 'ZTIBLETA' <l_field> 'S' l_subrc.
    IF l_subrc NE 0.
      <l_field_error> = 'E'.
      PERFORM set_return_message USING 'E' <l_logno>
                                           l_ebeln l_ebelp.
    ENDIF.
  ELSE.
    <l_field_error> = 'E'.
    PERFORM no_input_check IN PROGRAM ('ZTIR0000')
                           USING 'ZTITBLK' 'BLETA' 'S'.
    PERFORM set_return_message USING 'E' <l_logno>
                                         l_ebeln l_ebelp.
  ENDIF.

*>B/L발행일.
  ASSIGN COMPONENT 'BLDAT' OF STRUCTURE p_table TO <l_field>.
  IF NOT <l_field> IS INITIAL..
    PERFORM check_date_values  USING 'ZTIBLDAT' <l_field> 'S' l_subrc.
    IF l_subrc NE 0.
      <l_field_error> = 'E'.
      PERFORM set_return_message USING 'E' <l_logno>
                                           l_ebeln l_ebelp.
    ENDIF.
  ELSE.
    <l_field_error> = 'E'.
    PERFORM no_input_check IN PROGRAM ('ZTIR0000')
                           USING 'ZTITBLK' 'BLDAT' 'S'.
    PERFORM set_return_message USING 'E' <l_logno>
                                         l_ebeln l_ebelp.
  ENDIF.

*>Yard도착예정일.
  ASSIGN COMPONENT 'INYDT' OF STRUCTURE p_table TO <l_field>.
  IF NOT <l_field> IS INITIAL..
    PERFORM check_date_values  USING 'ZTIINYDT' <l_field> 'S' l_subrc.
    IF l_subrc NE 0.
      <l_field_error> = 'E'.
      PERFORM set_return_message USING 'E' <l_logno>
                                           l_ebeln l_ebelp.
    ENDIF.
  ELSE.
    <l_field_error> = 'E'.
    PERFORM no_input_check IN PROGRAM ('ZTIR0000')
                           USING 'ZTITBLK' 'INYDT' 'S'.
    PERFORM set_return_message USING 'E' <l_logno>
                                         l_ebeln l_ebelp.
  ENDIF.

*> 선기명.
  ASSIGN COMPONENT 'IVSLN' OF STRUCTURE p_table TO <l_field>.
  IF <l_field> IS INITIAL.
    <l_field_error> = 'E'.
    PERFORM no_input_check IN PROGRAM ('ZTIR0000')
                           USING 'ZTITBLK' 'IVSLN' 'S'.
    PERFORM set_return_message USING 'E' <l_logno>
                                         l_ebeln l_ebelp.
  ENDIF.


*>통화단위.
  ASSIGN COMPONENT 'WAERS' OF STRUCTURE p_table TO <l_waers>.
  IF <l_waers> IS INITIAL.
    <l_field_error> = 'E'.
    PERFORM no_input_check IN PROGRAM ('ZTIR0000')
                           USING 'ZTITBLK' 'WAERS' 'S'.
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
  ASSIGN COMPONENT 'SMAMT' OF STRUCTURE p_table TO <l_wrbtr>.
  IF <l_wrbtr> IS INITIAL.
*    <l_field_error> = 'E'.
*    PERFORM no_input_check IN PROGRAM ('ZTIR0000')
*                           USING 'ZTITBLK' 'SMAMT' 'S'.
*    PERFORM set_return_message USING 'E' <l_logno>
*                                         l_ebeln l_ebelp.
  ELSE.
    l_string = <l_wrbtr>.
    PERFORM check_number_values  USING 'ZTISMAMT' l_string 'S' l_subrc.
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

  ASSIGN COMPONENT 'REFWR' OF STRUCTURE p_table TO <l_wrbtr>.
  IF <l_wrbtr> IS INITIAL.
*    <l_field_error> = 'E'.
*    PERFORM no_input_check IN PROGRAM ('ZTIR0000')
*                           USING 'ZTITBLIT' 'REFWR' 'S'.
*    PERFORM set_return_message USING 'E' <l_logno>
*                                         l_ebeln l_ebelp.
  ELSE.
    l_string = <l_wrbtr>.
    PERFORM check_number_values  USING 'REFWR' l_string 'S' l_subrc.
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

*

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
           'VOLEH'.
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
    PERFORM set_others_fields             USING  <gs_table>
                                                 space.

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
                              p_blnum
                              p_ebeln
                              p_ebelp.

  DATA: l_msgtx  TYPE bapi_msg,
        l_tabix  TYPE sy-tabix,
        l_wrbtr  LIKE bapicurr-bapicurr.

  FIELD-SYMBOLS: <gs_table>,
                 <l_smamt>,
                 <l_refwr>,
                 <l_ivamt>,
                 <l_waers>,
                 <l_reqno>,
                 <l_reqit>,
                 <l_blnum>,
                 <l_iblno>,
                 <l_iblit>,
                 <l_ebeln>,
                 <l_ebelp>.

  ASSIGN LOCAL COPY OF INITIAL LINE OF <gt_table> TO <gs_table>.

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
  ASSIGN COMPONENT 'SMAMT' OF STRUCTURE
                            <gs_table> TO <l_smamt>.
  ASSIGN COMPONENT 'REFWR' OF STRUCTURE
                            <gs_table> TO <l_refwr>.
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
*    IF <l_blnum> EQ p_blnum AND
*       <l_ebeln> EQ p_ebeln AND
*       <l_ebelp> EQ p_ebelp.
    IF <l_blnum> EQ p_blnum.

      MOVE-CORRESPONDING <gs_table> TO gt_download.
      MOVE: l_msgtx                 TO gt_download-msgtx,
            p_msgty                 TO gt_download-msgty.

      CALL FUNCTION 'BAPI_CURRENCY_CONV_TO_EXTERNAL'
        EXPORTING
          currency        = <l_waers>
          amount_internal = <l_smamt>
        IMPORTING
          amount_external = l_wrbtr.
      gt_download-smamt = l_wrbtr.

      CALL FUNCTION 'BAPI_CURRENCY_CONV_TO_EXTERNAL'
        EXPORTING
          currency        = <l_waers>
          amount_internal = <l_refwr>
        IMPORTING
          amount_external = l_wrbtr.
      gt_download-refwr = l_wrbtr.

      CALL FUNCTION 'BAPI_CURRENCY_CONV_TO_EXTERNAL'
        EXPORTING
          currency        = <l_waers>
          amount_internal = <l_ivamt>
        IMPORTING
          amount_external = l_wrbtr.
      gt_download-ivamt = l_wrbtr.

      gt_download-reqno = <l_reqno>.
      gt_download-reqit = <l_reqit>.
      gt_download-iblno = <l_iblno>.
      gt_download-iblit = <l_iblit>.
      APPEND gt_download.
    ENDIF.
  ENDLOOP.

ENDFORM.                    " SET_UPLOAD_LOG
