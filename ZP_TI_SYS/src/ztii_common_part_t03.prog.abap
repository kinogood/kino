************************************************************************
* Title         : ZTII_COMMON_PART_T03                                 *
*                                                                      *
* Description   : SmartForm 출력용 공용 Top Include                    *
*                                                                      *
* Creation Date : 2004/02/11                                           *
*                                                                      *
* Author        : SeogBong, Kang                                       *
*                 Copyright ⓒ ASEG Co., LTD. All rights reserved.     *
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

************************************************************************
* TYPES and TYPE-POOLS                                                 *
************************************************************************

************************************************************************
* SAP Include Define                                                   *
************************************************************************

************************************************************************
* Tables                                                               *
************************************************************************

************************************************************************
* SAP Views                                                            *
************************************************************************

*---------------------------------------------------------------------*
*> SAP SMARTFORM
*---------------------------------------------------------------------*
DATA: g_ssf_name             TYPE tdsfname,
      g_func_mod_name        TYPE rs38l_fnam,
      g_output_options       TYPE ssfcompop,
      g_control_parameters   TYPE ssfctrlop.

DATA: g_mail_recipient       LIKE swotobjid,
      g_mail_sender          LIKE swotobjid,
      g_mail_appl_obj        LIKE swotobjid,
      g_document_output_info TYPE ssfcrespd,
      g_job_output_info      TYPE ssfcrescl,
      g_job_output_options   TYPE ssfcresop,
*      g_ip_mailaddr          TYPE ppfdmailad,
      g_ip_mailaddr          TYPE so_name,
      g_param                LIKE ssfpp.

DATA : "g_cnt                 TYPE i,
       g_index_cnt           TYPE count,
       g_addr1_val           LIKE addr1_val,
       g_close_flag(1),
       g_open_flag(1),
       g_lines               LIKE tline OCCURS 1 WITH HEADER LINE,
       g_name                LIKE thead-tdname,
       g_tddevice            TYPE tddevice,
       page_flag(1).

DATA : BEGIN OF it_prtctl  OCCURS 0.
        INCLUDE STRUCTURE zmisprtctl.
DATA : END   OF it_prtctl.

*> pdf file
CONSTANTS: c_acrobat_reader_key(64) TYPE c VALUE
                                    'SOFTWARE\ADOBE\ACROBAT\EXE',
           c_printer                TYPE tddevice VALUE 'PRINTER',
           c_screen                 TYPE tddevice VALUE 'SCREEN',
           c_telefax                TYPE tddevice VALUE 'TELEFAX',
           c_mail                   TYPE tddevice VALUE 'MAIL',
           c_pdf                    TYPE tddevice VALUE 'PDF',
           c_url(30)                TYPE c        VALUE
                                    '@ustcax00.kcc.com'.

DATA: g_pdf                         TYPE STANDARD TABLE OF tline,
      g_size                        TYPE i,
      g_reg_value(128)              TYPE c.

DATA: g_mail_appl_obj_tab           TYPE TABLE OF swotobjid
                                         WITH HEADER LINE.
