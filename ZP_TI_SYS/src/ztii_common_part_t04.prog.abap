************************************************************************
* Title         : ZTII_COMMON_PART_T04                                 *
*                                                                      *
* Description   : ALV Grid Control을 위한 공용 Top Include             *
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
TYPE-POOLS: slis,   "> Globale Type(ALV)
            kkblo.  "> Generic list types

************************************************************************
* SAP Include Define                                                   *
************************************************************************
INCLUDE : <icon>,
          <symbol>.

************************************************************************
* Tables                                                               *
************************************************************************
TABLES: icon.         ">아이콘테이블.

************************************************************************
* SAP Views                                                            *
************************************************************************


************************************************************************
* CONSTANTS                                                            *
************************************************************************
CONSTANTS:
      c_save(1)           TYPE  c              VALUE 'A',
      c_top_of_page       TYPE  slis_formname  VALUE 'TOP_OF_PAGE',
      c_pf_status_set     TYPE  slis_formname  VALUE 'SET_STATUS',
      c_user_command      TYPE  slis_formname  VALUE 'USER_COMMAND'.

************************************************************************
* Internal Tables                                                      *
************************************************************************
DATA: it_fieldcat         TYPE slis_t_fieldcat_alv.
DATA: it_xheader          TYPE slis_t_listheader     WITH HEADER LINE.
DATA: it_color            TYPE slis_t_specialcol_alv WITH HEADER LINE.
DATA: it_sort             TYPE slis_t_sortinfo_alv.
DATA: it_filter           TYPE slis_t_filter_alv.
DATA: it_gruppen          TYPE slis_t_sp_group_alv   WITH HEADER LINE.
DATA: it_events           TYPE slis_t_event.
DATA: it_event_exit       TYPE slis_t_event_exit     WITH HEADER LINE.
DATA: it_listheader       TYPE slis_t_listheader.

************************************************************************
* DATA Declarations                                                    *
************************************************************************
DATA: gs_keyinfo          TYPE slis_keyinfo_alv.
DATA: gs_layout           TYPE slis_layout_alv.
DATA: gs_print            TYPE slis_print_alv.
DATA: gs_selfield         TYPE slis_selfield.
DATA: gs_fieldcat         TYPE slis_fieldcat_alv.
DATA: gs_color_info       TYPE slis_specialcol_alv.
DATA: gs_listheader       TYPE slis_listheader.

DATA: gs_variante         LIKE disvariant,
      gs_def_variante     LIKE disvariant,
      g_variant_exit(1)   TYPE c,
      g_variant_save(1)   TYPE c,
      g_variant_def(1)    TYPE c.

***********************************************************************
* FIELD-SYMBOLS
***********************************************************************
FIELD-SYMBOLS: <sortfield>.
