*&---------------------------------------------------------------------*
*& Include          ZGTSDI0001TOP
*&---------------------------------------------------------------------*

*----------------------------------------------------------------------*
* TABLES
*----------------------------------------------------------------------*
TABLES : vbak, vbap, vttk.
TABLES : ZLET0400, ZLET0401, ZGTSDT1003.

*----------------------------------------------------------------------*
* Class
*----------------------------------------------------------------------*


*----------------------------------------------------------------------*
* CONSTANTS
*----------------------------------------------------------------------*
CONSTANTS : gc_e    TYPE char1 VALUE 'E',
            gc_x    TYPE char1 VALUE 'X',
            gc_kpcm TYPE zgtetarget VALUE 'KPCM',
            gc_kscm TYPE zgtetarget VALUE 'KSCM',
            gc_kbdm TYPE zgtetarget VALUE 'KBDM'.

CONSTANTS : gc_crlf TYPE c VALUE cl_bcs_convert=>gc_crlf,
            gc_tab  TYPE c VALUE cl_bcs_convert=>gc_tab.


*----------------------------------------------------------------------*
* VARIABLE
*----------------------------------------------------------------------*
DATA : gv_saveok  LIKE sy-ucomm,
       gv_okcode  LIKE sy-ucomm,
       gv_error   TYPE char1,
       gv_tar     TYPE zgtetarget,
       gv_result  TYPE c LENGTH 2,
       gv_message TYPE string,
       gv_ivno    LIKE zlet0005-iv_no,
       gv_answer  TYPE char1.

*----------------------------------------------------------------------*
* TYPE & STRUCTURE & INTERNAL TABLE
*----------------------------------------------------------------------*

DATA : gt_head TYPE TABLE OF ZGTSDSIF0027 WITH HEADER LINE.
DATA : gt_item1 TYPE TABLE OF ZGTSDSIF0028 WITH HEADER LINE.
DATA : gt_item2 TYPE TABLE OF ZGTSDSIF0029 WITH HEADER LINE.
DATA : gt_item3 TYPE TABLE OF ZGTSDSIF0030 WITH HEADER LINE.

DATA : BEGIN OF gt_result OCCURS 0 .
data :  stamp  TYPE timestampl.
DATA : zo_result   TYPE zo_result,
       zo_message2 TYPE zo_message2.
DATA : END OF gt_result.
DATA : gs_result LIKE GT_RESULT.
*----------------------------------------------------------------------*
* DEFINE
*----------------------------------------------------------------------*
DEFINE __cle.
  CLEAR: &1, &1[].
END-OF-DEFINITION.

DEFINE __rng.
  &1-sign   = &2.
  &1-option = &3.
  &1-low    = &4.
  &1-high    = &5.
  APPEND &1. CLEAR &1.
END-OF-DEFINITION.

DEFINE __alpha_in.
  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
    EXPORTING
      input  = &1
    IMPORTING
      output = &2.
END-OF-DEFINITION.

DEFINE __alpha_ou.
  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
    EXPORTING
      input  = &1
    IMPORTING
      output = &2.
END-OF-DEFINITION.

DEFINE __get_rows.
  __cle : &2.
  CHECK &1 IS BOUND.
  CALL METHOD &1->get_selected_rows
     IMPORTING
       et_index_rows = &2[].

  DELETE &2 WHERE rowtype IS NOT INITIAL.

  CHECK &3 IS NOT INITIAL.


END-OF-DEFINITION.
