************************************************************************
* Title         :  ZTIRCOMMF00                                         *
*                                                                      *
* Description   : 수입 공용 Sub-routine Include                        *
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
*----------------------------------------------------------------------*
* 2012/06/18   FIB05            [제목] 지급은행 처리 변경              *
*                               [CSR_NO] C20120504_02700               *
*&---------------------------------------------------------------------*
*&      Form  USER_OK_TC                                               *
*&---------------------------------------------------------------------*
 FORM USER_OK_TC USING    P_TC_NAME TYPE DYNFNAM
                          P_TABLE_NAME
                          P_MARK_NAME
                 CHANGING P_OK      LIKE SY-UCOMM.

* BEGIN OF LOCAL DATA--------------------------------------------------*
   DATA: L_OK     TYPE SY-UCOMM,
         L_OFFSET TYPE I.
* END OF LOCAL DATA----------------------------------------------------*


*----------------------------------------------------------------------*
*> Table control specific operations                                   *
*> evaluate TC name and operations                                     *
*----------------------------------------------------------------------*
   SEARCH P_OK FOR P_TC_NAME.
   IF SY-SUBRC <> 0.
     EXIT.
   ENDIF.
   L_OFFSET = STRLEN( P_TC_NAME ) + 1.
   L_OK = P_OK+L_OFFSET.

*----------------------------------------------------------------------*
*> execute general and TC specific operations                          *
*----------------------------------------------------------------------*
   CASE L_OK.
     WHEN 'INSR'.                      "insert row
       PERFORM FCODE_INSERT_ROW USING    P_TC_NAME
                                         P_TABLE_NAME.
       CLEAR P_OK.
     WHEN 'INSR_N'.
       PERFORM FCODE_APPEND_ROW USING    P_TC_NAME
                                         P_TABLE_NAME
                                         G_DOCUMENT.
       CLEAR P_OK.
     WHEN 'DELE'.                      "delete row
       PERFORM FCODE_DELETE_ROW USING    P_TC_NAME
                                         P_TABLE_NAME
                                         P_MARK_NAME.
       CLEAR P_OK.
     WHEN 'DELE_N'.                      "delete row
       PERFORM FCODE_DELETE_ROW_NEW  USING  P_TC_NAME
                                            P_TABLE_NAME
                                            P_MARK_NAME
                                            G_DOCUMENT.
       CLEAR P_OK.
     WHEN 'P--' OR                     "top of list
          'P-'  OR                     "previous page
          'P+'  OR                     "next page
          'P++'.                       "bottom of list
       PERFORM COMPUTE_SCROLLING_IN_TC USING P_TC_NAME
                                             L_OK.
       CLEAR P_OK.
*     WHEN 'L--'.                       "total left
*       PERFORM FCODE_TOTAL_LEFT USING P_TC_NAME.
*
*     WHEN 'L-'.                        "column left
*       PERFORM FCODE_COLUMN_LEFT USING P_TC_NAME.
*
*     WHEN 'R+'.                        "column right
*       PERFORM FCODE_COLUMN_RIGHT USING P_TC_NAME.
*
*     WHEN 'R++'.                       "total right
*       PERFORM FCODE_TOTAL_RIGHT USING P_TC_NAME.
*
     WHEN 'MARK'.                      "mark all filled lines
       PERFORM FCODE_TC_MARK_LINES USING P_TC_NAME
                                         P_TABLE_NAME
                                         P_MARK_NAME   .
       CLEAR P_OK.

     WHEN 'DMRK'.                      "demark all filled lines
       PERFORM FCODE_TC_DEMARK_LINES USING P_TC_NAME
                                           P_TABLE_NAME
                                           P_MARK_NAME .
       CLEAR P_OK.

*     WHEN 'SASCEND'   OR
*          'SDESCEND'.                  "sort column
*       PERFORM FCODE_SORT_TC USING P_TC_NAME
*                                   l_ok.
     WHEN 'REFR'.                      "demark all filled lines
*       PERFORM FCODE_TC_REFRES
     WHEN 'DETL'.
       PERFORM FCODE_TC_SELECTED_DOCUMENT USING P_TC_NAME
                                                P_TABLE_NAME
                                                P_MARK_NAME
                                                G_DOCUMENT.

     WHEN 'PMVC'.
       PERFORM FCODE_TC_SELECTED_MOVE     USING P_TC_NAME
                                                P_TABLE_NAME
                                                G_DOCUMENT.
   ENDCASE.

 ENDFORM.                              " USER_OK_TC

*&---------------------------------------------------------------------*
*&      Form  FCODE_INSERT_ROW                                         *
*&---------------------------------------------------------------------*
 FORM FCODE_INSERT_ROW
               USING    P_TC_NAME           TYPE DYNFNAM
                        P_TABLE_NAME.

*> BEGIN OF LOCAL DATA-------------------------------------------------*
   DATA L_LINES_NAME       LIKE FELD-NAME.
   DATA L_SELLINE          LIKE SY-STEPL.
   DATA L_LASTLINE         TYPE I.
   DATA L_LINE             TYPE I.
   DATA L_TABLE_NAME       LIKE FELD-NAME.
   FIELD-SYMBOLS <TC>                 TYPE CXTAB_CONTROL.
   FIELD-SYMBOLS <TABLE>              TYPE STANDARD TABLE.
   FIELD-SYMBOLS <LINES>              TYPE I.
*> END OF LOCAL DATA---------------------------------------------------*

   ASSIGN (P_TC_NAME) TO <TC>.

*> get the table, which belongs to the tc
   CONCATENATE P_TABLE_NAME '[]' INTO L_TABLE_NAME. "table body
   ASSIGN (L_TABLE_NAME) TO <TABLE>.                "not headerline

*> get looplines of TableControl
   CONCATENATE 'G_' P_TC_NAME '_LINES' INTO L_LINES_NAME.
   ASSIGN (L_LINES_NAME) TO <LINES>.

*> get current line
   GET CURSOR LINE L_SELLINE.
   IF SY-SUBRC <> 0.                   " append line to table
     L_SELLINE = <TC>-LINES + 1.

*> set top line and new cursor line
     IF L_SELLINE > <LINES>.
       <TC>-TOP_LINE = L_SELLINE - <LINES> + 1 .
       L_LINE = 1.
     ELSE.
       <TC>-TOP_LINE = 1.
       L_LINE = L_SELLINE.
     ENDIF.
   ELSE.                               " insert line into table
     L_SELLINE = <TC>-TOP_LINE + L_SELLINE - 1.

*> set top line and new cursor line
     L_LASTLINE = L_SELLINE + <LINES> - 1.
     IF L_LASTLINE <= <TC>-LINES.
       <TC>-TOP_LINE = L_SELLINE.
       L_LINE = 1.
     ELSEIF <LINES> > <TC>-LINES.
       <TC>-TOP_LINE = 1.
       L_LINE = L_SELLINE.
     ELSE.
       <TC>-TOP_LINE = <TC>-LINES - <LINES> + 2 .
       L_LINE = L_SELLINE - <TC>-TOP_LINE + 1.
     ENDIF.
   ENDIF.

*> insert initial line
   INSERT INITIAL LINE INTO <TABLE> INDEX L_SELLINE.
   <TC>-LINES = <TC>-LINES + 1.
*> set cursor
   SET CURSOR LINE L_LINE.

 ENDFORM.                              " FCODE_INSERT_ROW

*&---------------------------------------------------------------------*
*&      Form  FCODE_APPEND_ROW                                         *
*&---------------------------------------------------------------------*
 FORM FCODE_APPEND_ROW
               USING    P_TC_NAME           TYPE DYNFNAM
                        P_TABLE_NAME
                        P_DOCUMENT.


*> BEGIN OF LOCAL DATA-------------------------------------------------*
   DATA L_LINES_NAME       LIKE FELD-NAME.
   DATA L_SELLINE          LIKE SY-STEPL.
   DATA L_LASTLINE         TYPE I.
   DATA L_LINE             TYPE I.
   DATA L_TABLE_NAME       LIKE FELD-NAME.
   FIELD-SYMBOLS <TC>                 TYPE CXTAB_CONTROL.
   FIELD-SYMBOLS <TABLE>              TYPE STANDARD TABLE.
   FIELD-SYMBOLS <LINES>              TYPE I.
*> END OF LOCAL DATA---------------------------------------------------*

   ASSIGN (P_TC_NAME) TO <TC>.

*> get the table, which belongs to the tc
   CONCATENATE P_TABLE_NAME '[]' INTO L_TABLE_NAME. "table body
   ASSIGN (L_TABLE_NAME) TO <TABLE>.                "not headerline

*> get looplines of TableControl
   CONCATENATE 'G_' P_TC_NAME '_LINES' INTO L_LINES_NAME.
   ASSIGN (L_LINES_NAME) TO <LINES>.

*> get current line
   L_SELLINE = <TC>-LINES + 1.

*> set top line and new cursor line
   IF L_SELLINE > <LINES>.
     <TC>-TOP_LINE = L_SELLINE - <LINES> + 1 .
     L_LINE = 1.
   ELSE.
     <TC>-TOP_LINE = 1.
     L_LINE = L_SELLINE.
   ENDIF.

   CASE P_DOCUMENT.
     WHEN C_LC.
       PERFORM APPEND_PO_ITEMS IN PROGRAM ('ZTIR0000')
                                USING L_LINE
                                      G_UCOMM.
     WHEN C_BL.
       PERFORM APPEND_LC_ITEMS IN PROGRAM ('ZTIR2000')
                                USING L_LINE
                                      G_UCOMM.
     WHEN C_IV.
       PERFORM APPEND_BL_ITEMS IN PROGRAM ('ZTIR3000')
                                USING L_LINE
                                      G_UCOMM.
     WHEN C_CC.
       PERFORM APPEND_BL_ITEMS IN PROGRAM ('ZTIR4000')
                                USING L_LINE
                                      G_UCOMM.
     WHEN C_GR.
       PERFORM APPEND_CC_ITEMS IN PROGRAM ('ZTIR7200')
                                USING L_LINE
                                      G_UCOMM.
     WHEN OTHERS.
   ENDCASE.
*> set cursor
   IF G_UCOMM EQ 'FCOPY'.
     SET CURSOR LINE L_LINE.
   ENDIF.

 ENDFORM.                              " FCODE_APPEND_ROW
*&---------------------------------------------------------------------*
*&      Form  FCODE_TC_SELECTED_MOVE                                   *
*&---------------------------------------------------------------------*
 FORM FCODE_TC_SELECTED_MOVE
               USING    P_TC_NAME           TYPE DYNFNAM
                        P_TABLE_NAME
                        P_DOCUMENT.


*> BEGIN OF LOCAL DATA-------------------------------------------------*
   DATA L_LINES_NAME       LIKE FELD-NAME.
   DATA L_SELLINE          LIKE SY-STEPL.
   DATA L_LASTLINE         TYPE I.
   DATA L_LINE             TYPE I.
   DATA L_TABLE_NAME       LIKE FELD-NAME.
   DATA L_FIELDNAME(25).

   FIELD-SYMBOLS <TC>                 TYPE CXTAB_CONTROL.
   FIELD-SYMBOLS <TABLE>              TYPE STANDARD TABLE.
   FIELD-SYMBOLS <LINES>              TYPE I.
   FIELD-SYMBOLS <FS>.
*> END OF LOCAL DATA---------------------------------------------------*

   ASSIGN (P_TC_NAME) TO <TC>.

*> get the table, which belongs to the tc
   CONCATENATE P_TABLE_NAME '[]' INTO L_TABLE_NAME. "table body
   ASSIGN (L_TABLE_NAME) TO <TABLE>.                "not headerline

*> get looplines of TableControl
   CONCATENATE 'G_' P_TC_NAME '_LINES' INTO L_LINES_NAME.
   ASSIGN (L_LINES_NAME) TO <LINES>.

   CASE P_DOCUMENT.
     WHEN C_LC OR C_IP.
       L_FIELDNAME = 'ZTITRQP-REQIT'.
     WHEN C_BL OR C_LG OR C_BS OR C_BI OR C_BO.
       L_FIELDNAME = 'ZTITBLP-IBLIT'.
     WHEN C_IV.
       L_FIELDNAME = 'ZTITIVP-RBLGP'.
     WHEN C_CC.
       L_FIELDNAME = 'ZTITCCP-ICCIT'.
     WHEN C_PN.
       L_FIELDNAME = 'ZTITPNP-PNTIT'.
     WHEN C_GR.
       L_FIELDNAME = 'ZTITGRP-ICCIT'.
     WHEN C_CS.
       L_FIELDNAME = 'ZTITCSP-ICSSQ'.
     WHEN OTHERS.
   ENDCASE.

*> field assign
   ASSIGN (L_FIELDNAME) TO <FS>.

   IF <FS> IS INITIAL.
     <TC>-TOP_LINE = 1.
*> set cursor
     SET CURSOR LINE 1.
   ELSE.
     IF <FS> > <TC>-LINES.
       <TC>-TOP_LINE = <TC>-LINES.
       SET CURSOR LINE <TC>-LINES.
     ELSE.
       <TC>-TOP_LINE = <FS>.
*> set cursor
       SET CURSOR LINE <FS>.
     ENDIF.
   ENDIF.
   CLEAR: <FS>.

 ENDFORM.                              " FCODE_TC_SELECTED_MOVE
*&---------------------------------------------------------------------*
*&      Form  FCODE_DELETE_ROW                                         *
*&---------------------------------------------------------------------*
 FORM FCODE_DELETE_ROW
               USING    P_TC_NAME           TYPE DYNFNAM
                        P_TABLE_NAME
                        P_MARK_NAME   .

*&SPWIZARD: BEGIN OF LOCAL DATA----------------------------------------*
   DATA L_TABLE_NAME       LIKE FELD-NAME.

   FIELD-SYMBOLS <TC>         TYPE CXTAB_CONTROL.
   FIELD-SYMBOLS <TABLE>      TYPE STANDARD TABLE.
   FIELD-SYMBOLS <WA>.
   FIELD-SYMBOLS <MARK_FIELD>.
*&SPWIZARD: END OF LOCAL DATA------------------------------------------*

   ASSIGN (P_TC_NAME) TO <TC>.

*&SPWIZARD: get the table, which belongs to the tc                     *
   CONCATENATE P_TABLE_NAME '[]' INTO L_TABLE_NAME. "table body
   ASSIGN (L_TABLE_NAME) TO <TABLE>.                "not headerline

*&SPWIZARD: delete marked lines                                        *
   DESCRIBE TABLE <TABLE> LINES <TC>-LINES.

   LOOP AT <TABLE> ASSIGNING <WA>.

*&SPWIZARD: access to the component 'FLAG' of the table header         *
     ASSIGN COMPONENT P_MARK_NAME OF STRUCTURE <WA> TO <MARK_FIELD>.

     IF <MARK_FIELD> = 'X'.
       DELETE <TABLE> INDEX SYST-TABIX.
       IF SY-SUBRC = 0.
         <TC>-LINES = <TC>-LINES - 1.
       ENDIF.
     ENDIF.
   ENDLOOP.

 ENDFORM.                              " FCODE_DELETE_ROW
*&---------------------------------------------------------------------*
*&      Form  FCODE_DELETE_ROW_NEW                                     *
*&---------------------------------------------------------------------*
 FORM FCODE_DELETE_ROW_NEW
               USING    P_TC_NAME           TYPE DYNFNAM
                        P_TABLE_NAME
                        P_MARK_NAME
                        P_DOCUMENT.

*> BEGIN OF LOCAL DATA-------------------------------------------------*
   DATA L_TABLE_NAME       LIKE FELD-NAME.
   DATA L_COUNT               TYPE I.
   DATA L_EBELN               TYPE EBELN.
   DATA L_EBELP               TYPE EBELP.
   DATA L_REQNO               TYPE ZTIREQNO.
   DATA L_REQIT               TYPE ZTIREQIT.
   DATA L_IBLNO               TYPE ZTIIBLNO.
   DATA L_IBLIT               TYPE ZTIIBLIT.
   DATA L_ICCNO               TYPE ZTIICCNO.
   DATA L_ICCIT               TYPE ZTIICCIT.
   DATA L_IGRNO               TYPE ZTIIGRNO.
   DATA L_PNTNO               TYPE ZTIPNTNO.
   DATA L_PNTIT               TYPE ZTIPNTIT.
   DATA L_IVONO               TYPE ZTIIVONO.
   DATA L_RBLGP               TYPE ZTIRBLGP.

   DATA L_TAXNO               TYPE ZTITAXNO.
   DATA L_TAXIT               TYPE ZTITAXIT.

   FIELD-SYMBOLS <TC>         TYPE CXTAB_CONTROL.
   FIELD-SYMBOLS <TABLE>      TYPE STANDARD TABLE.
   FIELD-SYMBOLS <WA>.
   FIELD-SYMBOLS <MARK_FIELD>.
   FIELD-SYMBOLS <FS>.
*> END OF LOCAL DATA--------------------------------------------------*

   CLEAR: G_SUBRC, G_COUNT.

   ASSIGN (P_TC_NAME) TO <TC>.

*> get the table, which belongs to the tc
   CONCATENATE P_TABLE_NAME '[]' INTO L_TABLE_NAME. "table body
   ASSIGN (L_TABLE_NAME) TO <TABLE>.                "not headerline

*> delete marked lines
   DESCRIBE TABLE <TABLE> LINES <TC>-LINES.

   LOOP AT <TABLE> ASSIGNING <WA>.

*> access to the component 'FLAG' of the table header
     ASSIGN COMPONENT P_MARK_NAME OF STRUCTURE <WA> TO <MARK_FIELD>.

     IF <MARK_FIELD> = 'X'.
       ADD 1 TO G_COUNT.
       CASE P_DOCUMENT.
         WHEN C_LC.
           ASSIGN COMPONENT 'REQNO' OF STRUCTURE <WA> TO <FS>.
           L_REQNO = <FS>.

           ASSIGN COMPONENT 'REQIT' OF STRUCTURE <WA> TO <FS>.
           L_REQIT = <FS>.

           PERFORM CHECK_LC_SUB_DOCUMENT_EXIST(ZTIR0000)
                                               USING L_REQNO
                                                     L_REQIT
                                                     C_INFO
                                                     G_SUBRC.
         WHEN C_BL.
           ASSIGN COMPONENT 'IBLNO' OF STRUCTURE <WA> TO <FS>.
           L_IBLNO = <FS>.

           ASSIGN COMPONENT 'IBLIT' OF STRUCTURE <WA> TO <FS>.
           L_IBLIT = <FS>.

           PERFORM CHECK_BL_SUB_DOCUMENT_EXIST(ZTIR2000)
                                               USING L_IBLNO
                                                     L_IBLIT
                                                     C_INFO
                                                     G_SUBRC.

         WHEN C_IV.
           ASSIGN COMPONENT 'IVONO' OF STRUCTURE <WA> TO <FS>.
           L_IVONO = <FS>.

           ASSIGN COMPONENT 'RBLGP' OF STRUCTURE <WA> TO <FS>.
           L_RBLGP = <FS>.

           PERFORM CHECK_IV_SUB_DOCUMENT_EXIST(ZTIR3000)
                                               USING L_IVONO
                                                     L_RBLGP
                                                     C_INFO
                                                     G_SUBRC.
         WHEN C_CC.
           ASSIGN COMPONENT 'IVONO' OF STRUCTURE <WA> TO <FS>.
           L_ICCNO = <FS>.

           ASSIGN COMPONENT 'RBLGP' OF STRUCTURE <WA> TO <FS>.
           L_ICCIT = <FS>.

           PERFORM CHECK_CC_SUB_DOCUMENT_EXIST(ZTIR4000)
                                               USING L_ICCNO
                                                     L_ICCIT
                                                     C_INFO
                                                     G_SUBRC.

         WHEN C_LG.
           CLEAR: G_SUBRC.
         WHEN C_GR.
           ASSIGN COMPONENT 'IGRNO' OF STRUCTURE <WA> TO <FS>.
           L_IGRNO = <FS>.

           ASSIGN COMPONENT 'ICCIT' OF STRUCTURE <WA> TO <FS>.
           L_ICCIT = <FS>.

           PERFORM CHECK_GR_SUB_DOCUMENT_EXIST(ZTIR7200)
                                               USING L_IGRNO
                                                     L_ICCIT
                                                     C_INFO
                                                     G_SUBRC.
         WHEN C_TX.
           ASSIGN COMPONENT 'TAXNO' OF STRUCTURE <WA> TO <FS>.
           L_TAXNO = <FS>.

           ASSIGN COMPONENT 'TAXIT' OF STRUCTURE <WA> TO <FS>.
           L_TAXIT = <FS>.

         WHEN C_PN.
*           ASSIGN COMPONENT 'PNTNO' OF STRUCTURE <wa> TO <fs>.
*           l_pntno = <fs>.
*
*           ASSIGN COMPONENT 'PNTIT' OF STRUCTURE <wa> TO <fs>.
*           l_pntit = <fs>.
*
*           PERFORM check_pn_sub_document_exist(ZTIr8000)
*                                               USING l_pntno
*                                                     l_pntit
*                                                     c_info
*                                                     g_subrc.
*         WHEN c_gr.
*           CLEAR: g_subrc.
         WHEN C_CS.
           CLEAR: G_SUBRC.
       ENDCASE.

       IF G_SUBRC EQ 0.
         DELETE <TABLE> INDEX SYST-TABIX.
         IF SY-SUBRC = 0.
           <TC>-LINES = <TC>-LINES - 1.
         ENDIF.
       ENDIF.
     ENDIF.
   ENDLOOP.

   IF G_COUNT EQ 0.
     MESSAGE S909.
   ENDIF.

 ENDFORM.                              " FCODE_DELETE_ROW_NEW

*&---------------------------------------------------------------------*
*&      Form  COMPUTE_SCROLLING_IN_TC
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
 FORM COMPUTE_SCROLLING_IN_TC USING    P_TC_NAME
                                       P_OK.
*> BEGIN OF LOCAL DATA-------------------------------------------------*
   DATA L_TC_NEW_TOP_LINE     TYPE I.
   DATA L_TC_NAME             LIKE FELD-NAME.
   DATA L_TC_LINES_NAME       LIKE FELD-NAME.
   DATA L_TC_FIELD_NAME       LIKE FELD-NAME.

   FIELD-SYMBOLS <TC>         TYPE CXTAB_CONTROL.
   FIELD-SYMBOLS <LINES>      TYPE I.
*> END OF LOCAL DATA---------------------------------------------------*

   ASSIGN (P_TC_NAME) TO <TC>.
*> get looplines of TableControl
   CONCATENATE 'G_' P_TC_NAME '_LINES' INTO L_TC_LINES_NAME.
   ASSIGN (L_TC_LINES_NAME) TO <LINES>.


*> is no line filled?
   IF <TC>-LINES = 0.
*> yes, ...
     L_TC_NEW_TOP_LINE = 1.
   ELSE.
*> no, ...
     CALL FUNCTION 'SCROLLING_IN_TABLE'
       EXPORTING
         ENTRY_ACT      = <TC>-TOP_LINE
         ENTRY_FROM     = 1
         ENTRY_TO       = <TC>-LINES
*        last_page_full = 'X'
         LAST_PAGE_FULL = ' '
         LOOPS          = <LINES>
         OK_CODE        = P_OK
         OVERLAPPING    = 'X'
       IMPORTING
         ENTRY_NEW      = L_TC_NEW_TOP_LINE
       EXCEPTIONS
*        NO_ENTRY_OR_PAGE_ACT  = 01
*        NO_ENTRY_TO    = 02
*        NO_OK_CODE_OR_PAGE_GO = 03
         OTHERS         = 0.
   ENDIF.

*> get actual tc and column
   GET CURSOR FIELD L_TC_FIELD_NAME
              AREA  L_TC_NAME.

   IF SYST-SUBRC = 0.
     IF L_TC_NAME = P_TC_NAME.
*> set actual column
       SET CURSOR FIELD L_TC_FIELD_NAME LINE 1.
     ENDIF.
   ENDIF.

*> set the new top line
   <TC>-TOP_LINE = L_TC_NEW_TOP_LINE.

 ENDFORM.                              " COMPUTE_SCROLLING_IN_TC

*&---------------------------------------------------------------------*
*&      Form  FCODE_TC_MARK_LINES
*&---------------------------------------------------------------------*
*       marks all TableControl lines
*----------------------------------------------------------------------*
 FORM FCODE_TC_MARK_LINES USING P_TC_NAME
                                P_TABLE_NAME
                                P_MARK_NAME.
*> EGIN OF LOCAL DATA--------------------------------------------------*
   DATA L_TABLE_NAME       LIKE FELD-NAME.

   FIELD-SYMBOLS <TC>         TYPE CXTAB_CONTROL.
   FIELD-SYMBOLS <TABLE>      TYPE STANDARD TABLE.
   FIELD-SYMBOLS <WA>.
   FIELD-SYMBOLS <MARK_FIELD>.
*> END OF LOCAL DATA---------------------------------------------------*

   ASSIGN (P_TC_NAME) TO <TC>.

*> get the table, which belongs to the tc
   CONCATENATE P_TABLE_NAME '[]' INTO L_TABLE_NAME. "table body
   ASSIGN (L_TABLE_NAME) TO <TABLE>.                "not headerline

*> mark all filled lines
   LOOP AT <TABLE> ASSIGNING <WA>.

*> access to the component 'FLAG' of the table header
     ASSIGN COMPONENT P_MARK_NAME OF STRUCTURE <WA> TO <MARK_FIELD>.

     <MARK_FIELD> = 'X'.
   ENDLOOP.
 ENDFORM.                                          "fcode_tc_mark_lines

*&---------------------------------------------------------------------*
*&      Form  FCODE_TC_DEMARK_LINES
*&---------------------------------------------------------------------*
*       demarks all TableControl lines
*----------------------------------------------------------------------*
 FORM FCODE_TC_DEMARK_LINES USING P_TC_NAME
                                  P_TABLE_NAME
                                  P_MARK_NAME .
*> BEGIN OF LOCAL DATA-------------------------------------------------*
   DATA L_TABLE_NAME       LIKE FELD-NAME.

   FIELD-SYMBOLS <TC>         TYPE CXTAB_CONTROL.
   FIELD-SYMBOLS <TABLE>      TYPE STANDARD TABLE.
   FIELD-SYMBOLS <WA>.
   FIELD-SYMBOLS <MARK_FIELD>.
*> END OF LOCAL DATA---------------------------------------------------*

   ASSIGN (P_TC_NAME) TO <TC>.

*> get the table, which belongs to the tc
   CONCATENATE P_TABLE_NAME '[]' INTO L_TABLE_NAME. "table body
   ASSIGN (L_TABLE_NAME) TO <TABLE>.                "not headerline

*> demark all filled lines
   LOOP AT <TABLE> ASSIGNING <WA>.

*> access to the component 'FLAG' of the table header
     ASSIGN COMPONENT P_MARK_NAME OF STRUCTURE <WA> TO <MARK_FIELD>.
     <MARK_FIELD> = SPACE.
   ENDLOOP.

 ENDFORM.                                          "fcode_tc_mark_lines
*&---------------------------------------------------------------------*
*&      Form  set_function_by_tcode
*&---------------------------------------------------------------------*
* 업무특성별(생성,변경,조회,삭제 등)로 불필요한 기능(functions)을      *
* disable 시키기 위해서 Internal table에 기능을 append 함.             *
*----------------------------------------------------------------------*
 FORM SET_FUNCTION_BY_TCODE .

   IF G_TREE_MODE EQ 'Y'.
     MOVE 'METRON'        TO FTAB-FCODE.   APPEND FTAB. ">개요펼치기.
   ELSE.
     MOVE 'METROF'        TO FTAB-FCODE.   APPEND FTAB. ">개요닫기.
   ENDIF.

*   IF NOT ( g_tcode EQ c_create_d OR
*            g_tcode EQ c_create   OR
*            g_tcode EQ c_change ).
*     MOVE 'METRON'        TO ftab-fcode.   APPEND ftab. ">개요펼치기.
*     MOVE 'METROF'        TO ftab-fcode.   APPEND ftab. ">개요닫기.
*   ENDIF.

   IF G_TCODE NE C_CHANGE.
   ENDIF.


   CASE G_TCODE.
     WHEN C_CREATE   OR C_CREATE_D OR C_CREATE_A.       ">생성.
       MOVE 'ZTIOTHER'     TO FTAB-FCODE.   APPEND FTAB. ">기타 문서.
       MOVE 'ZTICREATE'    TO FTAB-FCODE.   APPEND FTAB. ">생성.
       MOVE 'ZTIACCEPT'    TO FTAB-FCODE.   APPEND FTAB. ">접수.
       MOVE 'ZTIRETURN'    TO FTAB-FCODE.   APPEND FTAB. ">반려.
       MOVE 'ZTIAPPLY'     TO FTAB-FCODE.   APPEND FTAB. ">상신.
       MOVE 'ZTIAPPLYC'    TO FTAB-FCODE.   APPEND FTAB. ">상신취소.
       MOVE 'ZTIAPPLYB'    TO FTAB-FCODE.   APPEND FTAB. ">상신반려.
       MOVE 'ZTISEND'      TO FTAB-FCODE.   APPEND FTAB. ">개설신청.
       MOVE 'ZTIRECV'      TO FTAB-FCODE.   APPEND FTAB. ">개설(승인).
       MOVE 'ZTICLOSE'     TO FTAB-FCODE.   APPEND FTAB. ">종료.
       MOVE 'ZTICLOSEC'    TO FTAB-FCODE.   APPEND FTAB. ">종료취소.
       MOVE 'ZTICHDOC'     TO FTAB-FCODE.   APPEND FTAB. ">변경사항.
       MOVE 'ZTISUBSEQ'    TO FTAB-FCODE.   APPEND FTAB. ">후속기능.
       MOVE 'ZTIDELETE'    TO FTAB-FCODE.   APPEND FTAB. ">삭제.
*       MOVE 'ZTIEDI'       TO ftab-fcode.   APPEND ftab. ">EDI.
       MOVE 'ZTISENDC'     TO FTAB-FCODE.   APPEND FTAB. ">신청취소.
       MOVE 'ZTIRECVC'     TO FTAB-FCODE.   APPEND FTAB. ">개설취소.
*       MOVE 'ZTICOPY'      TO ftab-fcode.   APPEND ftab. ">참조생성.
       MOVE 'ZTIDOCHIS'    TO FTAB-FCODE.   APPEND FTAB. ">문서별.
       MOVE 'ZTIQTYHIS'    TO FTAB-FCODE.   APPEND FTAB. ">수량별.
       MOVE 'ZTIREVER'     TO FTAB-FCODE.   APPEND FTAB. ">전기취소.

       MOVE 'ZTIRQLNK'     TO FTAB-FCODE.   APPEND FTAB. ">전기취소.ZTIRQLNK

       IF G_DOCUMENT EQ C_LC.
         MOVE 'ZTISAVE'      TO FTAB-FCODE.   APPEND FTAB. ">저장.
       ENDIF.

***********************************************************************
* 날짜   : 2008.10.08
* 요청인 : 박혁세K
* 내용   : ztit200/ztit201 시 비용전기 버튼 없앰
***********************************************************************
       IF G_TCODE = 'ZTIT200' OR
          G_TCODE = 'ZTIT201'.
         MOVE 'ZTICOST'      TO FTAB-FCODE.   APPEND FTAB. ">저장.
       ENDIF.
***********************************************************************

     WHEN C_CHANGE.        ">변경.
*       MOVE 'ZTITRON'      TO ftab-fcode.   APPEND ftab. ">개요펼치기.
*       MOVE 'ZTITROFF'     TO ftab-fcode.   APPEND ftab. ">개요닫기.
       MOVE 'ZTICHANGE'    TO FTAB-FCODE.   APPEND FTAB. ">변경.
       MOVE 'ZTIACCEPT'    TO FTAB-FCODE.   APPEND FTAB. ">접수.
       MOVE 'ZTIRETURN'    TO FTAB-FCODE.   APPEND FTAB. ">반려.
       MOVE 'ZTIAPPLY'     TO FTAB-FCODE.   APPEND FTAB. ">상신.
       MOVE 'ZTIAPPLYC'    TO FTAB-FCODE.   APPEND FTAB. ">상신취소.
       MOVE 'ZTIAPPLYB'    TO FTAB-FCODE.   APPEND FTAB. ">상신반려.
       MOVE 'ZTISEND'      TO FTAB-FCODE.   APPEND FTAB. ">개설신청.
       MOVE 'ZTIRECV'      TO FTAB-FCODE.   APPEND FTAB. ">개설(승인).
       MOVE 'ZTICLOSE'     TO FTAB-FCODE.   APPEND FTAB. ">종료.
       MOVE 'ZTICLOSEC'    TO FTAB-FCODE.   APPEND FTAB. ">종료취소.
       MOVE 'ZTICOPY'      TO FTAB-FCODE.   APPEND FTAB. ">참조생성.
       MOVE 'ZTISUBSEQ'    TO FTAB-FCODE.   APPEND FTAB. ">후속기능.
       MOVE 'ZTIDELETE'    TO FTAB-FCODE.   APPEND FTAB. ">삭제.
*       MOVE 'ZTIEDI'       TO ftab-fcode.   APPEND ftab. ">EDI.
       MOVE 'ZTISENDC'     TO FTAB-FCODE.   APPEND FTAB. ">신청취소.
       MOVE 'ZTIRECVC'     TO FTAB-FCODE.   APPEND FTAB. ">개설취소.
       MOVE 'ZTIREVER'     TO FTAB-FCODE.   APPEND FTAB. ">전기취소.
*       MOVE 'ZTISAVE'      TO ftab-fcode.   APPEND ftab. ">저장.

       IF G_DOCUMENT EQ C_LC.
         MOVE 'ZTISAVE'      TO FTAB-FCODE.   APPEND FTAB. ">저장.
       ENDIF.
     WHEN C_DISPLAY.       ">조회.
*       MOVE 'METRON'       TO ftab-fcode.   APPEND ftab. ">개요펼치기.
*       MOVE 'METROF'       TO ftab-fcode.   APPEND ftab. ">개요닫기.
       MOVE 'ZTIITEMRF'    TO FTAB-FCODE.   APPEND FTAB. ">란/행 Refresh
       MOVE 'ZTICALC'      TO FTAB-FCODE.   APPEND FTAB. ">란/행 재계산.
       MOVE 'ZTIDISPLAY'   TO FTAB-FCODE.   APPEND FTAB. ">조회.
       MOVE 'ZTIACCEPT'    TO FTAB-FCODE.   APPEND FTAB. ">접수.
       MOVE 'ZTIRETURN'    TO FTAB-FCODE.   APPEND FTAB. ">반려.
       MOVE 'ZTIAPPLY'     TO FTAB-FCODE.   APPEND FTAB. ">상신.
       MOVE 'ZTIAPPLYC'    TO FTAB-FCODE.   APPEND FTAB. ">상신취소.
       MOVE 'ZTIAPPLYB'    TO FTAB-FCODE.   APPEND FTAB. ">상신반려.
       MOVE 'ZTISEND'      TO FTAB-FCODE.   APPEND FTAB. ">개설신청.
       MOVE 'ZTIRECV'      TO FTAB-FCODE.   APPEND FTAB. ">개설(승인).
       MOVE 'ZTICLOSE'     TO FTAB-FCODE.   APPEND FTAB. ">종료.
       MOVE 'ZTICLOSEC'    TO FTAB-FCODE.   APPEND FTAB. ">종료취소.
       MOVE 'ZTICOPY'      TO FTAB-FCODE.   APPEND FTAB. ">참조생성.
       MOVE 'ZTIDELETE'    TO FTAB-FCODE.   APPEND FTAB. ">삭제.
       MOVE 'ZTICHECK'     TO FTAB-FCODE.   APPEND FTAB. ">점검.
       MOVE 'ZTISAVE'      TO FTAB-FCODE.   APPEND FTAB. ">저장.
       MOVE 'ZTISENDC'     TO FTAB-FCODE.   APPEND FTAB. ">신청취소.
       MOVE 'ZTIRECVC'     TO FTAB-FCODE.   APPEND FTAB. ">개설취소.
       MOVE 'ZTIREQUEST'   TO FTAB-FCODE.   APPEND FTAB. ">수입의뢰요청.
       MOVE 'ZTIREQCANC'   TO FTAB-FCODE.   APPEND FTAB. ">요청취소.
       MOVE 'ZTISUBSEQ'    TO FTAB-FCODE.   APPEND FTAB. ">후속기능.
       MOVE 'ZTIREVER'     TO FTAB-FCODE.   APPEND FTAB. ">전기취소.
       MOVE 'ZTISIMUL'     TO FTAB-FCODE.   APPEND FTAB.
       MOVE 'ZTIPOST'      TO FTAB-FCODE.   APPEND FTAB.
       MOVE 'ZTISPLIT'     TO FTAB-FCODE.   APPEND FTAB. ">금액분할.
       MOVE 'ZTIHSCODE'    TO FTAB-FCODE.   APPEND FTAB. ">전기취소.
       MOVE 'ZTIRECALC'    TO FTAB-FCODE.   APPEND FTAB. ">란구성.
       MOVE 'ZCOTY'        TO FTAB-FCODE.   APPEND FTAB.
*       MOVE 'ZTITEST'      TO FTAB-FCODE.   APPEND FTAB. " TEST
     WHEN C_DELETE.        ">삭제.
       MOVE 'ZTICOST'      TO FTAB-FCODE.   APPEND FTAB. ">비용전기.
       MOVE 'ZTIITEMRF'    TO FTAB-FCODE.   APPEND FTAB. ">란/행 Refresh
       MOVE 'ZTICALC'      TO FTAB-FCODE.   APPEND FTAB. ">란/행 재계산.
       MOVE 'ZTITRON'      TO FTAB-FCODE.   APPEND FTAB. ">개요펼치기.
       MOVE 'ZTITROFF'     TO FTAB-FCODE.   APPEND FTAB. ">개요닫기.
       MOVE 'ZTIACCEPT'    TO FTAB-FCODE.   APPEND FTAB. ">접수.
       MOVE 'ZTIRETURN'    TO FTAB-FCODE.   APPEND FTAB. ">반려.
       MOVE 'ZTIAPPLY'     TO FTAB-FCODE.   APPEND FTAB. ">상신.
       MOVE 'ZTIAPPLYC'    TO FTAB-FCODE.   APPEND FTAB. ">상신취소.
       MOVE 'ZTIAPPLYB'    TO FTAB-FCODE.   APPEND FTAB. ">상신반려.
       MOVE 'ZTISEND'      TO FTAB-FCODE.   APPEND FTAB. ">개설신청.
       MOVE 'ZTIRECV'      TO FTAB-FCODE.   APPEND FTAB. ">개설(승인).
       MOVE 'ZTICLOSE'     TO FTAB-FCODE.   APPEND FTAB. ">종료.
       MOVE 'ZTICLOSEC'    TO FTAB-FCODE.   APPEND FTAB. ">종료취소.
       MOVE 'ZTICOPY'      TO FTAB-FCODE.   APPEND FTAB. ">참조생성.
       MOVE 'ZTISUBSEQ'    TO FTAB-FCODE.   APPEND FTAB. ">후속기능.
       MOVE 'ZTICHECK'     TO FTAB-FCODE.   APPEND FTAB. ">점검.
       MOVE 'ZTISENDC'     TO FTAB-FCODE.   APPEND FTAB. ">신청취소.
       MOVE 'ZTIRECVC'     TO FTAB-FCODE.   APPEND FTAB. ">개설취소.
       MOVE 'ZTIREQUEST'   TO FTAB-FCODE.   APPEND FTAB. ">수입의뢰요청.
       MOVE 'ZTIREQCANC'   TO FTAB-FCODE.   APPEND FTAB. ">요청취소.
       MOVE 'ZTIREVER'     TO FTAB-FCODE.   APPEND FTAB. ">전기취소.
       MOVE 'ZTISIMUL'     TO FTAB-FCODE.   APPEND FTAB.
       MOVE 'ZTIPOST'      TO FTAB-FCODE.   APPEND FTAB.
       MOVE 'ZTISAVE'      TO FTAB-FCODE.   APPEND FTAB. ">저장.
       MOVE 'ZTISPLIT'     TO FTAB-FCODE.   APPEND FTAB. ">금액분할.
       MOVE 'ZTIHSCODE'    TO FTAB-FCODE.   APPEND FTAB. ">전기취소.
       MOVE 'ZTIRECALC'    TO FTAB-FCODE.   APPEND FTAB. ">란구성.
*       MOVE 'ZTITEST'      TO FTAB-FCODE.   APPEND FTAB. " TEST
     WHEN C_ACCEPTANCE.    ">접수.
       MOVE 'ZTICALC'      TO FTAB-FCODE.   APPEND FTAB. ">란/행 재계산.
       MOVE 'ZTISEND'      TO FTAB-FCODE.   APPEND FTAB. ">개설신청.
       MOVE 'ZTIEDI'       TO FTAB-FCODE.   APPEND FTAB. ">EDI SCREEN.
       MOVE 'ZTITRON'      TO FTAB-FCODE.   APPEND FTAB. ">개요펼치기.
       MOVE 'ZTITROFF'     TO FTAB-FCODE.   APPEND FTAB. ">개요닫기.
       MOVE 'ZTISAVE'      TO FTAB-FCODE.   APPEND FTAB. ">저장.
       MOVE 'ZTICREATE'    TO FTAB-FCODE.   APPEND FTAB. ">생성.
       MOVE 'ZTICHANGE'    TO FTAB-FCODE.   APPEND FTAB. ">변경.
       MOVE 'ZTIAPPLY'     TO FTAB-FCODE.   APPEND FTAB. ">상신.
       MOVE 'ZTIAPPLYC'    TO FTAB-FCODE.   APPEND FTAB. ">상신취소.
       MOVE 'ZTIAPPLYB'    TO FTAB-FCODE.   APPEND FTAB. ">상신반려.
*       MOVE 'ZTISEND'      TO ftab-fcode.   APPEND ftab. ">개설신청.
       MOVE 'ZTIRECV'      TO FTAB-FCODE.   APPEND FTAB. ">개설(승인).
       MOVE 'ZTICLOSE'     TO FTAB-FCODE.   APPEND FTAB. ">종료.
       MOVE 'ZTICLOSEC'    TO FTAB-FCODE.   APPEND FTAB. ">종료취소.
       MOVE 'ZTIDELETE'    TO FTAB-FCODE.   APPEND FTAB. ">삭제.
*       MOVE 'ZTIEDI'       TO ftab-fcode.   APPEND ftab. ">EDI.
       MOVE 'ZTICHECK'     TO FTAB-FCODE.   APPEND FTAB. ">점검.
       MOVE 'ZTISENDC'     TO FTAB-FCODE.   APPEND FTAB. ">신청취소.
       MOVE 'ZTIRECVC'     TO FTAB-FCODE.   APPEND FTAB. ">개설취소.
       MOVE 'ZTIREQUEST'   TO FTAB-FCODE.   APPEND FTAB. ">수입의뢰요청.
       MOVE 'ZTIREQCANC'   TO FTAB-FCODE.   APPEND FTAB. ">요청취소.
       MOVE 'ZTISUBSEQ'    TO FTAB-FCODE.   APPEND FTAB. ">후속기능.
       MOVE 'ZTISPLIT'     TO FTAB-FCODE.   APPEND FTAB. ">금액분할.
       MOVE 'ZTIHSCODE'    TO FTAB-FCODE.   APPEND FTAB. ">전기취소.
       MOVE 'ZTIRECALC'    TO FTAB-FCODE.   APPEND FTAB. ">란구성.
     WHEN C_APPLY.         ">신청/관리.
       MOVE 'ZTITRON'      TO FTAB-FCODE.   APPEND FTAB. ">개요펼치기.
       MOVE 'ZTITROFF'     TO FTAB-FCODE.   APPEND FTAB. ">개요닫기.
       MOVE 'ZTIACCEPT'    TO FTAB-FCODE.   APPEND FTAB. ">접수.
       MOVE 'ZTIRETURN'    TO FTAB-FCODE.   APPEND FTAB. ">반려.
       MOVE 'ZTICREATE'    TO FTAB-FCODE.   APPEND FTAB. ">생성.
       MOVE 'ZTICHANGE'    TO FTAB-FCODE.   APPEND FTAB. ">변경.
       MOVE 'ZTICLOSE'     TO FTAB-FCODE.   APPEND FTAB. ">종료.
       MOVE 'ZTICLOSEC'    TO FTAB-FCODE.   APPEND FTAB. ">종료취소.
       MOVE 'ZTIDELETE'    TO FTAB-FCODE.   APPEND FTAB. ">삭제.
       MOVE 'ZTIAPPLYB'    TO FTAB-FCODE.   APPEND FTAB. ">상신반려.
       MOVE 'ZTIRECVC'     TO FTAB-FCODE.   APPEND FTAB. ">개설취소.
       MOVE 'ZTIREQUEST'   TO FTAB-FCODE.   APPEND FTAB. ">수입의뢰요청.
       MOVE 'ZTIREQCANC'   TO FTAB-FCODE.   APPEND FTAB. ">요청취소.
       MOVE 'ZTISUBSEQ'    TO FTAB-FCODE.   APPEND FTAB. ">후속기능.
       MOVE 'ZTIHSCODE'    TO FTAB-FCODE.   APPEND FTAB. ">전기취소.
       IF ZTITRQS-DOCST EQ 'Y'.
         MOVE 'ZTISEND'      TO FTAB-FCODE.   APPEND FTAB. ">SNED.
       ELSE.
         IF ZTITRQS-DOCST NE 'N'.
           MOVE 'ZTISENDC'     TO FTAB-FCODE.   APPEND FTAB. ">SNED.
         ENDIF.
       ENDIF.
       MOVE 'ZTISPLIT'     TO FTAB-FCODE.   APPEND FTAB. ">금액분할.
       MOVE 'ZTIRECALC'    TO FTAB-FCODE.   APPEND FTAB. ">란구성.
     WHEN 'ZTIT009'.         ">신청/관리.
       MOVE 'ZTICALC'      TO FTAB-FCODE.   APPEND FTAB. ">란/행 재계산.
       MOVE 'ZTITRON'      TO FTAB-FCODE.   APPEND FTAB. ">개요펼치기.
       MOVE 'ZTITROFF'     TO FTAB-FCODE.   APPEND FTAB. ">개요닫기.
       MOVE 'ZTISAVE'      TO FTAB-FCODE.   APPEND FTAB. ">저장.
       MOVE 'ZTICREATE'    TO FTAB-FCODE.   APPEND FTAB. ">생성.
       MOVE 'ZTICHANGE'    TO FTAB-FCODE.   APPEND FTAB. ">변경.
       MOVE 'ZTIAPPLY'     TO FTAB-FCODE.   APPEND FTAB. ">상신.
       MOVE 'ZTIAPPLYC'    TO FTAB-FCODE.   APPEND FTAB. ">상신취소.
*       MOVE 'ZTISEND'      TO ftab-fcode.   APPEND ftab. ">개설신청.
       MOVE 'ZTIRECV'      TO FTAB-FCODE.   APPEND FTAB. ">개설(승인).
       MOVE 'ZTIDELETE'    TO FTAB-FCODE.   APPEND FTAB. ">삭제.
       MOVE 'ZTICHECK'     TO FTAB-FCODE.   APPEND FTAB. ">점검.
*       MOVE 'ZTISENDC'     TO ftab-fcode.   APPEND ftab. ">신청취소.
       MOVE 'ZTIRECVC'     TO FTAB-FCODE.   APPEND FTAB. ">개설취소.
       MOVE 'ZTIREQUEST'   TO FTAB-FCODE.   APPEND FTAB. ">수입의뢰요청.
       MOVE 'ZTIREQCANC'   TO FTAB-FCODE.   APPEND FTAB. ">요청취소.
       MOVE 'ZTISUBSEQ'    TO FTAB-FCODE.   APPEND FTAB. ">후속기능.
       MOVE 'ZTISPLIT'     TO FTAB-FCODE.   APPEND FTAB. ">금액분할.
       MOVE 'ZTIACCEPT'    TO FTAB-FCODE.   APPEND FTAB. ">접수.
       MOVE 'ZTIRETURN'    TO FTAB-FCODE.   APPEND FTAB. ">반려.
       MOVE 'ZTIHSCODE'    TO FTAB-FCODE.   APPEND FTAB. ">전기취소.
       MOVE 'ZTICLOSE'     TO FTAB-FCODE.   APPEND FTAB. ">종료.
       MOVE 'ZTICLOSEC'    TO FTAB-FCODE.   APPEND FTAB. ">종료취소.
       IF ZTITRQS-DOCST EQ 'Y'.
         MOVE 'ZTISENDC'   TO FTAB-FCODE.   APPEND FTAB. ">SNED.
       ELSE.
         IF ZTITRQS-DOCST EQ 'N'.
           MOVE 'ZTISEND'  TO FTAB-FCODE.   APPEND FTAB. ">SNED.
         ENDIF.
       ENDIF.
       MOVE 'ZTIRECALC'    TO FTAB-FCODE.   APPEND FTAB. ">란구성.

     WHEN C_OPEN.          ">개설관리.
       MOVE 'ZTICALC'      TO FTAB-FCODE.   APPEND FTAB. ">란/행 재계산.
       MOVE 'ZTITRON'      TO FTAB-FCODE.   APPEND FTAB. ">개요펼치기.
       MOVE 'ZTITROFF'     TO FTAB-FCODE.   APPEND FTAB. ">개요닫기.
       MOVE 'ZTIACCEPT'    TO FTAB-FCODE.   APPEND FTAB. ">접수.
       MOVE 'ZTIAPPLY'     TO FTAB-FCODE.   APPEND FTAB. ">상신.
       MOVE 'ZTIAPPLYC'    TO FTAB-FCODE.   APPEND FTAB. ">상신취소.
       MOVE 'ZTIAPPLYB'    TO FTAB-FCODE.   APPEND FTAB. ">상신반려.
       MOVE 'ZTIRETURN'    TO FTAB-FCODE.   APPEND FTAB. ">반려.
       MOVE 'ZTICREATE'    TO FTAB-FCODE.   APPEND FTAB. ">생성.
       MOVE 'ZTICHANGE'    TO FTAB-FCODE.   APPEND FTAB. ">변경.
       MOVE 'ZTICLOSE'     TO FTAB-FCODE.   APPEND FTAB. ">종료.
       MOVE 'ZTICLOSEC'    TO FTAB-FCODE.   APPEND FTAB. ">종료취소.
       MOVE 'ZTIDELETE'    TO FTAB-FCODE.   APPEND FTAB. ">삭제.
       MOVE 'ZTISENDC'     TO FTAB-FCODE.   APPEND FTAB. ">신청취소.
       MOVE 'ZTIREQUEST'   TO FTAB-FCODE.   APPEND FTAB. ">수입의뢰요청.
       MOVE 'ZTIREQCANC'   TO FTAB-FCODE.   APPEND FTAB. ">요청취소.
       MOVE 'ZTISUBSEQ'    TO FTAB-FCODE.   APPEND FTAB. ">후속기능.
       MOVE 'ZTISEND'      TO FTAB-FCODE.   APPEND FTAB. ">SNED.
       MOVE 'ZTIHSCODE'    TO FTAB-FCODE.   APPEND FTAB. ">전기취소.
       IF ZTITRQS-DOCST NE 'O'.
         MOVE 'ZTIRECVC'      TO FTAB-FCODE.   APPEND FTAB. ">SNED.
       ENDIF.
       MOVE 'ZTISPLIT'     TO FTAB-FCODE.   APPEND FTAB. ">금액분할.
       MOVE 'ZTIRECALC'    TO FTAB-FCODE.   APPEND FTAB. ">란구성.
     WHEN C_CLOSE.    ">종료.
       MOVE 'ZTICALC'      TO FTAB-FCODE.   APPEND FTAB. ">란/행 재계산.
       MOVE 'ZTISEND'      TO FTAB-FCODE.   APPEND FTAB. ">개설신청.
       MOVE 'ZTITRON'      TO FTAB-FCODE.   APPEND FTAB. ">개요펼치기.
       MOVE 'ZTITROFF'     TO FTAB-FCODE.   APPEND FTAB. ">개요닫기.
       MOVE 'ZTISAVE'      TO FTAB-FCODE.   APPEND FTAB. ">저장.
       MOVE 'ZTICREATE'    TO FTAB-FCODE.   APPEND FTAB. ">생성.
       MOVE 'ZTICHANGE'    TO FTAB-FCODE.   APPEND FTAB. ">변경.
       MOVE 'ZTIAPPLY'     TO FTAB-FCODE.   APPEND FTAB. ">상신.
       MOVE 'ZTIAPPLYC'    TO FTAB-FCODE.   APPEND FTAB. ">상신취소.
       MOVE 'ZTIAPPLYB'    TO FTAB-FCODE.   APPEND FTAB. ">상신반려.
       MOVE 'ZTISEND'      TO FTAB-FCODE.   APPEND FTAB. ">개설신청.
       MOVE 'ZTIRECV'      TO FTAB-FCODE.   APPEND FTAB. ">개설(승인).
       MOVE 'ZTIDELETE'    TO FTAB-FCODE.   APPEND FTAB. ">삭제.
       MOVE 'ZTICHECK'     TO FTAB-FCODE.   APPEND FTAB. ">점검.
       MOVE 'ZTISENDC'     TO FTAB-FCODE.   APPEND FTAB. ">신청취소.
       MOVE 'ZTIRECVC'     TO FTAB-FCODE.   APPEND FTAB. ">개설취소.
       MOVE 'ZTIREQUEST'   TO FTAB-FCODE.   APPEND FTAB. ">수입의뢰요청.
       MOVE 'ZTIREQCANC'   TO FTAB-FCODE.   APPEND FTAB. ">요청취소.
       MOVE 'ZTISUBSEQ'    TO FTAB-FCODE.   APPEND FTAB. ">후속기능.
       MOVE 'ZTISPLIT'     TO FTAB-FCODE.   APPEND FTAB. ">금액분할.
       MOVE 'ZTIACCEPT'    TO FTAB-FCODE.   APPEND FTAB. ">접수.
       MOVE 'ZTIRETURN'    TO FTAB-FCODE.   APPEND FTAB. ">반려.
       MOVE 'ZTIHSCODE'    TO FTAB-FCODE.   APPEND FTAB. ">전기취소.
       MOVE 'ZTIRECALC'    TO FTAB-FCODE.   APPEND FTAB. ">란구성.
     WHEN C_POST.
       MOVE 'ZTIREVER'     TO FTAB-FCODE.   APPEND FTAB. ">전기취소.
       MOVE 'ZTIHSCODE'    TO FTAB-FCODE.   APPEND FTAB. ">전기취소.
       MOVE 'ZTISPLIT'     TO FTAB-FCODE.   APPEND FTAB. ">금액분할.
       MOVE 'ZTIDELETE'    TO FTAB-FCODE.   APPEND FTAB. ">삭제.
       MOVE 'ZTIREVCL'     TO FTAB-FCODE.   APPEND FTAB. ">차입취소.
       MOVE 'ZTIRECALC'    TO FTAB-FCODE.   APPEND FTAB. ">란구성.
     WHEN C_REVERSE.
       MOVE 'ZTICALC'      TO FTAB-FCODE.   APPEND FTAB. ">란/행 재계산.
       MOVE 'ZTIPOSTL'     TO FTAB-FCODE.   APPEND FTAB. ">차입.
       MOVE 'ZTIDELETE'    TO FTAB-FCODE.   APPEND FTAB.
       MOVE 'ZTISIMUL'     TO FTAB-FCODE.   APPEND FTAB.
       MOVE 'ZTIPOST'      TO FTAB-FCODE.   APPEND FTAB.
       MOVE 'ZTICHECK'     TO FTAB-FCODE.   APPEND FTAB. ">점검.
       MOVE 'ZTISPLIT'     TO FTAB-FCODE.   APPEND FTAB. ">금액분할.
       MOVE 'ZTIHSCODE'    TO FTAB-FCODE.   APPEND FTAB. ">전기취소.
       MOVE 'ZTIRECALC'    TO FTAB-FCODE.   APPEND FTAB. ">란구성.
*       MOVE 'ZTITEST'      TO FTAB-FCODE.   APPEND FTAB. " TEST
     WHEN OTHERS.
   ENDCASE.

 ENDFORM.                    " set_function_by_tcode
*&---------------------------------------------------------------------*
*&      Form  set_function_by_screen
*&---------------------------------------------------------------------*
* 화면특성별(초기/세부화면 등)로 불필요한 기능(functions)을            *
* disable 시키기 위해서 Internal table에 기능을 append 함.             *
*----------------------------------------------------------------------*
 FORM SET_FUNCTION_BY_SCREEN .

   CASE SY-DYNNR.
     WHEN C_SCR0100 OR C_SCR0101 OR C_SCR0200.
       MOVE 'ZTICOST'      TO FTAB-FCODE.   APPEND FTAB. ">비용전기.
       MOVE 'METRON'       TO FTAB-FCODE.   APPEND FTAB. ">개요펼치기.
       MOVE 'METROF'       TO FTAB-FCODE.   APPEND FTAB. ">개요닫기.
       MOVE 'ZTIOTHER'     TO FTAB-FCODE.   APPEND FTAB. ">기타문서.
* 20101214 SIMCHO BY 김성길D 송장오류 건 처리위해 잠시 저장기능 활성화
*       MOVE 'ZTISAVE'      TO ftab-fcode.   APPEND ftab. ">저장.
* 20101214
       MOVE 'ZTICHECK'     TO FTAB-FCODE.   APPEND FTAB. ">점검.
       MOVE 'ZTISUBSEQ'    TO FTAB-FCODE.   APPEND FTAB. ">후속기능.
       MOVE 'ZTIPRINT'     TO FTAB-FCODE.   APPEND FTAB. ">인쇄.
       MOVE 'ZTIDELETE'    TO FTAB-FCODE.   APPEND FTAB. ">삭제.
       MOVE 'ZTIREQUEST'   TO FTAB-FCODE.   APPEND FTAB. ">수입의뢰요청.
       MOVE 'ZTIREQCANC'   TO FTAB-FCODE.   APPEND FTAB. ">요청취소.
       MOVE 'ZTISEND'      TO FTAB-FCODE.   APPEND FTAB. ">개설신청.
       MOVE 'ZTIITEMRF'    TO FTAB-FCODE.   APPEND FTAB. ">란/행 Refresh
       MOVE 'ZTICALC'      TO FTAB-FCODE.   APPEND FTAB. ">란/행 재계산.
       MOVE 'ZTISELECT'    TO FTAB-FCODE.   APPEND FTAB. ">선택.
       MOVE 'ZTISHOWMSG'   TO FTAB-FCODE.   APPEND FTAB. ">메시지.
       MOVE 'ZTIEDI'       TO FTAB-FCODE.   APPEND FTAB. ">EDI 문서.
       MOVE 'ZTICHDOC'     TO FTAB-FCODE.   APPEND FTAB. ">변경문서.
       MOVE 'ZTIMK03'      TO FTAB-FCODE.   APPEND FTAB. ">공급업체.
       MOVE 'ZTIMM03'      TO FTAB-FCODE.   APPEND FTAB. ">자재.
       MOVE 'ZTIMD04'      TO FTAB-FCODE.   APPEND FTAB. ">재고/소요량.
       MOVE 'ZTIME2M'      TO FTAB-FCODE.   APPEND FTAB. ">미결구매오더.
       MOVE 'ZTIMB51'      TO FTAB-FCODE.   APPEND FTAB. ">자재문서.
       MOVE 'ZTIMMBE'      TO FTAB-FCODE.   APPEND FTAB. ">재고개요.
       MOVE 'ZTIME03'      TO FTAB-FCODE.   APPEND FTAB. ">소스리스트.
       MOVE 'ZTIDOCHIS'    TO FTAB-FCODE.   APPEND FTAB. ">문서별.
       MOVE 'ZTIQTYHIS'    TO FTAB-FCODE.   APPEND FTAB. ">수량별.
       MOVE 'ZTIACCEPT'    TO FTAB-FCODE.   APPEND FTAB. ">접수.
       MOVE 'ZTIRETURN'    TO FTAB-FCODE.   APPEND FTAB. ">반려.
       MOVE 'ZTIAPPLY'     TO FTAB-FCODE.   APPEND FTAB. ">신청.
       MOVE 'ZTIAPPLYC'    TO FTAB-FCODE.   APPEND FTAB. ">신청.
       MOVE 'ZTIAPPLYB'    TO FTAB-FCODE.   APPEND FTAB. ">상신반려.
       MOVE 'ZTISENDC'     TO FTAB-FCODE.   APPEND FTAB. ">신청서 취소.
       MOVE 'ZTIRECV'      TO FTAB-FCODE.   APPEND FTAB. ">개설등록.
       MOVE 'ZTIRECVC'     TO FTAB-FCODE.   APPEND FTAB. ">개설취소.
       MOVE 'ZTICLOSE'     TO FTAB-FCODE.   APPEND FTAB. ">종료.
       MOVE 'ZTICLOSEC'    TO FTAB-FCODE.   APPEND FTAB. ">종료취소.
       MOVE 'ZTISIMUL'     TO FTAB-FCODE.   APPEND FTAB. ">시뮬레이션.
       MOVE 'ZTIPOST'      TO FTAB-FCODE.   APPEND FTAB. ">전기.
       MOVE 'ZTIREVER'     TO FTAB-FCODE.   APPEND FTAB. ">종료취소.
       MOVE 'ZTISPLIT'     TO FTAB-FCODE.   APPEND FTAB. ">금액분할.
       MOVE 'ZTIAMEND'     TO FTAB-FCODE.   APPEND FTAB. ">변경항목.
       MOVE 'ZTIACDOC'     TO FTAB-FCODE.   APPEND FTAB. ">후속문서.
       MOVE 'ZTIMMDOC'     TO FTAB-FCODE.   APPEND FTAB. ">송장문서.
       MOVE 'ZTIDSTR'      TO FTAB-FCODE.   APPEND FTAB. ">원시데이타.
       MOVE 'ZTIHSCODE'    TO FTAB-FCODE.   APPEND FTAB. ">전기취소.
       MOVE 'ZTICONFIRM'   TO FTAB-FCODE.   APPEND FTAB. ">확인.
       MOVE 'ZTICONFIRC'   TO FTAB-FCODE.   APPEND FTAB. ">확인취소.
       MOVE 'ZTIRECALC'    TO FTAB-FCODE.   APPEND FTAB. ">란구성.
       MOVE 'ZTIRQLNK'     TO FTAB-FCODE.   APPEND FTAB. ">란구성.
*       MOVE 'ZTITEST'      TO FTAB-FCODE.   APPEND FTAB. " TEST
     WHEN C_SCR2000.       ">주화면.
* 20060701 SIMCHO BY C2006062601000000323
* 수입입고시(ZTIT501) 전기안하고 SAVE만 되는 현상 방지위함
* save 버튼 비활성화
       IF SY-TCODE = 'ZTIT501'.
         MOVE 'ZTISAVE'      TO FTAB-FCODE.   APPEND FTAB. ">저장.
       ENDIF.
* END BY C2006062601000000323
     WHEN OTHERS.          ">EDI 화면.
       MOVE 'ZTICOST'      TO FTAB-FCODE.   APPEND FTAB. ">비용전기.
       MOVE 'METRON'       TO FTAB-FCODE.   APPEND FTAB. ">개요펼치기.
       MOVE 'METROF'       TO FTAB-FCODE.   APPEND FTAB. ">개요닫기.
       MOVE 'ZTIEDI'       TO FTAB-FCODE.   APPEND FTAB. ">EDI 문서.
       MOVE 'ZTICHDOC'     TO FTAB-FCODE.   APPEND FTAB. ">변경문서.
       MOVE 'ZTIMK03'      TO FTAB-FCODE.   APPEND FTAB. ">공급업체.
       MOVE 'ZTIMM03'      TO FTAB-FCODE.   APPEND FTAB. ">자재.
       MOVE 'ZTIMD04'      TO FTAB-FCODE.   APPEND FTAB. ">재고/소요량.
       MOVE 'ZTIME2M'      TO FTAB-FCODE.   APPEND FTAB. ">미결구매오더.
       MOVE 'ZTIMB51'      TO FTAB-FCODE.   APPEND FTAB. ">자재문서.
       MOVE 'ZTIMMBE'      TO FTAB-FCODE.   APPEND FTAB. ">재고개요.
       MOVE 'ZTIME03'      TO FTAB-FCODE.   APPEND FTAB. ">소스리스트.
       MOVE 'ZTIDOCHIS'    TO FTAB-FCODE.   APPEND FTAB. ">문서별.
       MOVE 'ZTIQTYHIS'    TO FTAB-FCODE.   APPEND FTAB. ">수량별.
       MOVE 'ZTICLOSE'     TO FTAB-FCODE.   APPEND FTAB. ">종료.
       MOVE 'ZTICLOSEC'    TO FTAB-FCODE.   APPEND FTAB. ">종료취소.
       MOVE 'ZTISPLIT'     TO FTAB-FCODE.   APPEND FTAB. ">금액분할.
       MOVE 'ZTIHSCODE'    TO FTAB-FCODE.   APPEND FTAB. ">전기취소.
   ENDCASE.

   IF SY-DYNNR NE C_SCR0100 AND SY-DYNNR NE C_SCR0101.
     MOVE 'ZTICOPY'      TO FTAB-FCODE.   APPEND FTAB. ">복사생성.
     MOVE 'ZTICOPY1'     TO FTAB-FCODE.   APPEND FTAB. ">복사생성.
   ENDIF.

 ENDFORM.                    " set_function_by_screen
*&---------------------------------------------------------------------*
*&      Form  set_titlebar_by_screen
*&---------------------------------------------------------------------*
 FORM SET_TITLEBAR_BY_SCREEN .

   CASE G_TCODE.
     WHEN C_CREATE_A.
*       IF sy-tcode(6) EQ 'ZTIT05'.
*         SET TITLEBAR 'NORMAL' WITH 'Amend 생성/의뢰 관리'(a01).
*       ELSEIF sy-tcode(6) EQ 'ZTIT15'.
*         SET TITLEBAR 'NORMAL' WITH '배서 생성/의뢰 관리'(a02).
*       ELSE.
       SET TITLEBAR 'NORMAL' WITH '정정 생성 관리'(AA1).
*       ENDIF.
     WHEN C_CREATE OR C_CREATE_D.
*       IF sy-tcode(6) EQ 'ZTIT05'.
*         SET TITLEBAR 'NORMAL' WITH 'Amend 생성/의뢰 관리'(a01).
*       ELSEIF sy-tcode(6) EQ 'ZTIT15'.
*         SET TITLEBAR 'NORMAL' WITH '배서 생성/의뢰 관리'(a02).
*       ELSE.
       SET TITLEBAR 'NORMAL' WITH '생성 관리'(AA1).
*       ENDIF.
     WHEN C_CHANGE.
       SET TITLEBAR 'NORMAL' WITH '변경 관리'(C02).
     WHEN C_DISPLAY.
       SET TITLEBAR 'NORMAL' WITH '조회'(C03).
     WHEN C_DELETE.
       SET TITLEBAR 'NORMAL' WITH '삭제'(C04).
     WHEN C_ACCEPTANCE.
       IF G_DOCUMENT EQ C_BL.
         SET TITLEBAR 'NORMAL' WITH '선적서류 송부'(C21).
       ELSE.
         SET TITLEBAR 'NORMAL' WITH '접수/회송 관리'(C05).
       ENDIF.
     WHEN C_APPLY.
       IF G_DOCUMENT EQ C_LC.
         SET TITLEBAR 'NORMAL' WITH '은행배정 관리'(C11).
       ELSEIF G_DOCUMENT EQ C_BL.
         SET TITLEBAR 'NORMAL' WITH '실입항입력'(C22).
       ELSE.
         SET TITLEBAR 'NORMAL' WITH '개설신청 관리'(C09).
       ENDIF.
     WHEN C_OPEN.
       IF G_DOCUMENT EQ C_BL.
         SET TITLEBAR 'NORMAL' WITH '통관요청 관리'(C23).
       ELSE.
         SET TITLEBAR 'NORMAL' WITH '개설관리'(C08).
       ENDIF.
     WHEN C_POST.
       SET TITLEBAR 'NORMAL' WITH '전기'(C06).
     WHEN C_REVERSE.
       SET TITLEBAR 'NORMAL' WITH '전기취소'(C07).
     WHEN C_CLOSE.
       SET TITLEBAR 'NORMAL' WITH '종료처리'(C07).
     WHEN 'ZTIT009'.
       SET TITLEBAR 'NORMAL' WITH '승인 및 송신관리'(C19).
     WHEN OTHERS.
       SET TITLEBAR 'NORMAL' WITH '사후관리'(C10).
   ENDCASE.

 ENDFORM.                    " set_titlebar_by_screen
*&---------------------------------------------------------------------*
*&      Form  valid_pushbuttons_icons_set
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
 FORM VALID_PUSHBUTTONS_ICONS_SET
                CHANGING P_ICON
                         P_QUICKINFO LIKE  ICONT-QUICKINFO
                         P_STD_INFO  LIKE  ICON-INTERNAL
                         P_BUTTON    LIKE  G_DYN_9998-BUTTON.

   CALL FUNCTION 'ICON_CREATE'
     EXPORTING
       NAME       = P_ICON
       TEXT       = ''
       INFO       = P_QUICKINFO
       ADD_STDINF = P_STD_INFO
     IMPORTING
       RESULT     = P_BUTTON
     EXCEPTIONS
       OTHERS     = 0.

 ENDFORM.                    " valid_pushbuttons_icons_set
*&---------------------------------------------------------------------*
*&      Form  p1000_set_initial_data
*&---------------------------------------------------------------------*
 FORM P1000_SET_INITIAL_DATA .

*> program id setting
   G_REPID = G_TABSTRIP-PROG = SY-REPID.

*> global mode setting
   CASE SY-TCODE.
     WHEN   C_CREATE_D.      G_MODE = 'C'.   ">생성.
     WHEN   C_CREATE.        G_MODE = 'C'.   ">생성.
     WHEN   C_CREATE_A.      G_MODE = 'C'.   ">Amend.
     WHEN   C_CHANGE.        G_MODE = 'M'.   ">변경.
     WHEN   C_DISPLAY.       G_MODE = 'S'.   ">조회.
     WHEN   C_DELETE.        G_MODE = 'D'.   ">삭제.
     WHEN   C_ACCEPTANCE.    G_MODE = 'A'.   ">접수.
     WHEN   C_APPLY.         G_MODE = 'Y'.   ">신청.
     WHEN   C_SEND.          G_MODE = 'Y'.   ">신청.
     WHEN   C_OPEN.          G_MODE = 'O'.   ">개설.
     WHEN   C_POST.          G_MODE = 'P'.   ">전기.
     WHEN   C_REVERSE.       G_MODE = 'R'.   ">취소(전기).
*     WHEN   c_reverse1.      g_mode = 'E'.   ">역분개.
     WHEN   C_CLOSE.         G_MODE = 'G'.   ">취소.
     WHEN   OTHERS.          G_MODE = '0'.   ">구상.
   ENDCASE.

*> Initializaton By Program
   PERFORM  SET_INITIAL_VALUE.

*> Header Hide/display 전환 버튼용(Y:display, N:Hide)
   G_BUTTON1     = 'Y'.
   G_TREE_MODE   = 'N'.
   G_CALL_BUTTON = '1'.

   CLEAR: G_HISTORY, G_HISTORY_POST, G_HISTORY_COST.

   CLEAR: G_COUNT, G_TCODE, G_PSPNR_CHK, G_ANSWER, G_EDI_ANSWER.

   CLEAR: G_FCODE_DROPPED, G_TABLE_MODEL.

   G_TCODE = SY-TCODE.

   FREE : G_DOCKING,
          G_FACTORY,
          G_FRAMEWORK,
          G_FW,
          G_DATABLADE,
          G_ALV_TREE,
          G_DOCKING,
          G_CONTOLLER,
          G_CMD_PROC,
          G_COMMANDS,
          G_CONTAINER,
          G_CALL_VIEW,
          G_CALL_VIEW_STACK,
          G_DEFAULT_VIEW,
          G_COMPOSITE_VIEW,
          G_ENV_FUNCTIONS,
          G_MESSAGE_HANDLER,
          G_QUERY_CONTROLLER,
          G_PERSONALIZATION,
          G_PERSONALIZATION_WORK_SPPLY,
          G_ESDUS_STREAM,
          G_MEMORY_STREAM,
          G_INIT.

 ENDFORM.                    " p1000_set_initial_data
*&---------------------------------------------------------------------*
*&      Form  p1000_get_textid_and_text
*&---------------------------------------------------------------------*
*>  p_tdname   : Document Key
*>  p_tdobject : Text Object
*>  p_screen   : Screen Name
*>  p_init     : Initialization
*&---------------------------------------------------------------------*
 FORM P1000_GET_TEXTID_AND_TEXT USING P_TDNAME
                                      P_TDOBJECT
                                      P_SCREEN
                                      P_INIT
                                      P_DISMODE.

   DATA: L_TDNAME   LIKE THEAD-TDNAME,
         L_TDOBJECT LIKE THEAD-TDOBJECT.

   L_TDNAME   = P_TDNAME.
   L_TDOBJECT = P_TDOBJECT.

   REFRESH : G_TEXTTYPES, G_TEXTLINES.
   IF P_INIT  EQ C_TRUE.
     REFRESH GT_CONTROL.
   ENDIF.

   SELECT SINGLE * FROM TTXOB
          WHERE TDOBJECT = L_TDOBJECT.
   IF SY-SUBRC NE 0.
     MESSAGE S602(TD) WITH L_TDOBJECT.
     EXIT.
   ENDIF.

   SELECT * FROM TTXID
            INTO TABLE XTTXID
            WHERE TDOBJECT = L_TDOBJECT.

   LOOP AT XTTXID.
     G_TABIX = SY-TABIX.
     SELECT SINGLE * FROM TTXIT
            WHERE TDOBJECT = L_TDOBJECT
            AND   TDSPRAS  = SY-LANGU
            AND   TDID     = XTTXID-TDID.

     GT_CONTROL-OBJECT = L_TDOBJECT.

     MOVE: L_TDOBJECT          TO THEAD-TDOBJECT,
           L_TDNAME            TO THEAD-TDNAME,
           SY-LANGU            TO THEAD-TDSPRAS,
           XTTXID-TDID         TO THEAD-TDID.

     REFRESH: IT_LINE. CLEAR: IT_LINE.
     CALL FUNCTION 'READ_TEXT'
       EXPORTING
*        CLIENT                  = SY-MANDT
         ID                      = THEAD-TDID
         LANGUAGE                = THEAD-TDSPRAS
         NAME                    = THEAD-TDNAME
         OBJECT                  = THEAD-TDOBJECT
*        ARCHIVE_HANDLE          = 0
*        LOCAL_CAT               = ' '
*     IMPORTING
*        HEADER                  =
       TABLES
         LINES                   = IT_LINE
       EXCEPTIONS
         ID                      = 1
         LANGUAGE                = 2
         NAME                    = 3
         NOT_FOUND               = 4
         OBJECT                  = 5
         REFERENCE_CHECK         = 6
         WRONG_ACCESS_TO_ARCHIVE = 7
         OTHERS                  = 8.
     IF SY-SUBRC <> 0.
*     MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
     ENDIF.

     GT_CONTROL-EDITOR_TYPE = C_TEXTEDIT.
     GT_CONTROL-DYNNR       = P_SCREEN.

     IF G_TABIX EQ 1.
       GT_CONTROL-CURRENT_NODE  = THEAD-TDID.
       GT_CONTROL-PREVIOUS_NODE = THEAD-TDID.
     ENDIF.

     G_TEXTTYPES-TDOBJECT    = THEAD-TDOBJECT.
     G_TEXTTYPES-TDID        = THEAD-TDID.
     G_TEXTTYPES-TDTEXT      = TTXIT-TDTEXT.
     G_TEXTTYPES-TEXTFLAG    = SPACE.
     G_TEXTTYPES-FIXIE       = SPACE.
     G_TEXTTYPES-SOURCE      = SPACE.

     IF NOT ( SY-TCODE EQ C_DISPLAY OR
              SY-TCODE EQ C_DELETE  ).
       CLEAR: G_TEXTTYPES-DISPLAYMODE.
     ELSE.
       G_TEXTTYPES-DISPLAYMODE = C_TRUE.
     ENDIF.

     IF P_SCREEN EQ C_SCR0400.
       G_TEXTTYPES-DISPLAYMODE = P_DISMODE.
     ENDIF.

     APPEND G_TEXTTYPES.

     LOOP AT IT_LINE.
       MOVE: IT_LINE-TDLINE       TO G_TEXTLINES-TDLINE,
             IT_LINE-TDFORMAT     TO G_TEXTLINES-TDFORMAT,
             THEAD-TDOBJECT       TO G_TEXTLINES-TDOBJECT,
             THEAD-TDID           TO G_TEXTLINES-TDID.
       APPEND G_TEXTLINES.
     ENDLOOP.
   ENDLOOP.

   GT_CONTROL-TEXTTYPES[] = G_TEXTTYPES[].
   GT_CONTROL-TEXTLINES[] = G_TEXTLINES[].

   APPEND GT_CONTROL.

 ENDFORM.                    " p1000_get_textid_and_text
*&---------------------------------------------------------------------*
*&      Form  CHECK_DOMAIN_VALUES
*&---------------------------------------------------------------------*
*       Domain value check
*----------------------------------------------------------------------*
 FORM CHECK_DOMAIN_VALUES  USING    P_DOMAIN LIKE  DD07L-DOMNAME
                                    P_VALUE.

   CALL FUNCTION 'CHECK_DOMAIN_VALUES'
     EXPORTING
       DOMNAME       = P_DOMAIN
       VALUE         = P_VALUE
     EXCEPTIONS
       NO_DOMNAME    = 1
       WRONG_VALUE   = 2
       DOM_NOT_FOUND = 3
       OTHERS        = 4.
   IF SY-SUBRC <> 0.
     MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
             WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
   ENDIF.

 ENDFORM.                    " CHECK_DOMAIN_VALUES
*&---------------------------------------------------------------------*
*&      Form  CHECK_DOMAIN_VALUES
*&---------------------------------------------------------------------*
*       Domain Text Read
*----------------------------------------------------------------------*
 FORM GET_DOMAIN_VALUE_TEXT  USING  P_DOMAIN LIKE  DD07L-DOMNAME
                                    P_VALUE
                                    P_TEXT.

   DATA: L_VALUE LIKE DD07V-DOMVALUE_L,
         L_TEXT  LIKE DD07V-DDTEXT.

   CLEAR: L_TEXT.

   MOVE: P_VALUE TO L_VALUE.

   CALL FUNCTION 'RV_DOMAIN_VALUE_TEXTS'
     EXPORTING
       DOMNAME  = P_DOMAIN
       DOMVALUE = L_VALUE
     IMPORTING
       DDTEXT   = L_TEXT.

   MOVE: L_TEXT TO P_TEXT.

 ENDFORM.                    " CHECK_DOMAIN_VALUES

*&---------------------------------------------------------------------*
*&      Form  SHOW_PROGRESS_bar
*&---------------------------------------------------------------------*
 FORM SHOW_PROGRESS_BAR USING  TEXT PERC.

   CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
     EXPORTING
       PERCENTAGE = PERC
       TEXT       = TEXT.

 ENDFORM.                    " SHOW_PROGRESS_bar
*&---------------------------------------------------------------------*
*&      Form  GET_F4_FOR_ZTERM
*&---------------------------------------------------------------------*
 FORM GET_F4_FOR_ZTERM USING    P_ZTERM.

   CALL FUNCTION 'FI_F4_ZTERM'
     EXPORTING
       I_KOART       = 'K'
       I_ZTERM       = P_ZTERM
       I_XSHOW       = ' '
     IMPORTING
       E_ZTERM       = T052-ZTERM
     EXCEPTIONS
       NOTHING_FOUND = 01.

   IF SY-SUBRC NE 0.
     MESSAGE S177(06) WITH P_ZTERM.
     EXIT.
   ENDIF.

   IF T052-ZTERM NE SPACE.
     P_ZTERM = T052-ZTERM.
   ENDIF.

 ENDFORM.                    " GET_F4_FOR_ZTERM
*&---------------------------------------------------------------------*
*&      Form  get_f4_for_zterm_DYNPRO
*&---------------------------------------------------------------------*
 FORM GET_F4_FOR_ZTERM_DYNPRO  USING    P_ZTERM LIKE T052-ZTERM.

   IF SCREEN-INPUT EQ '1'.
     CALL FUNCTION 'FI_F4_ZTERM'
       EXPORTING
         I_KOART       = 'K'
         I_ZTERM       = P_ZTERM
         I_XSHOW       = ' '
       IMPORTING
         E_ZTERM       = T052-ZTERM
       EXCEPTIONS
         NOTHING_FOUND = 01.
   ELSE.
     CALL FUNCTION 'FI_F4_ZTERM'
       EXPORTING
         I_KOART       = 'K'
         I_ZTERM       = P_ZTERM
         I_XSHOW       = 'X'
       IMPORTING
         E_ZTERM       = T052-ZTERM
       EXCEPTIONS
         NOTHING_FOUND = 01.
   ENDIF.

   IF SY-SUBRC NE 0.
     MESSAGE S177(06) WITH P_ZTERM.
     EXIT.
   ENDIF.

   IF T052-ZTERM NE SPACE.
     P_ZTERM = T052-ZTERM.
   ENDIF.

 ENDFORM.                    " get_f4_for_zterm_DYNPRO

*&---------------------------------------------------------------------*
*&      Form  display_purchase_order
*&---------------------------------------------------------------------*
 FORM DISPLAY_PURCHASE_ORDER  USING    P_EBELN  LIKE EKPO-EBELN
                                       P_EBELP  LIKE EKPO-EBELP.

   CHECK NOT P_EBELN IS INITIAL.
   IF SY-BINPT IS INITIAL.
     SET PARAMETER ID 'ENJ_CALL_ME23N' FIELD C_TRUE.
   ELSE.
     SET PARAMETER ID 'ENJ_CALL_ME23N' FIELD C_FALSE.
   ENDIF.
   CLEAR: SY-BINPT .

   CALL FUNCTION 'ME_DISPLAY_PURCHASE_DOCUMENT'
     EXPORTING
       I_EBELN              = P_EBELN
       I_EBELP              = P_EBELP
       I_ENJOY              = C_TRUE
*      I_PREVIEW            =
*      I_DATA_FROM_BUFFER   =
*      I_BSTYP              =
*      I_DISPLAY_ONLY       = ' '
*      I_EDIT               = ' '
*      I_ETENR              =
*      I_DOC_INITIATOR      =
     EXCEPTIONS
       NOT_FOUND            = 1
       NO_AUTHORITY         = 2
       INVALID_CALL         = 3
       PREVIEW_NOT_POSSIBLE = 4
       OTHERS               = 5.
   IF SY-SUBRC <> 0.
     MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
             WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
   ENDIF.

 ENDFORM.                    " display_purchase_order
*&---------------------------------------------------------------------*
*&      Form  set_po_lock_object
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
 FORM SET_PO_LOCK_OBJECT  USING    P_EBELN
                                   P_EBELP
                                   P_MODE
                                   P_ERRMODE
                                   P_CHECK.
   CLEAR: P_CHECK.

   IF P_MODE EQ 'L'.
     CALL FUNCTION 'ENQUEUE_EMEKKOE'
       EXPORTING
         MANDT          = SY-MANDT
         EBELN          = P_EBELN
         EBELP          = P_EBELP
       EXCEPTIONS
         FOREIGN_LOCK   = 1
         SYSTEM_FAILURE = 2
         OTHERS         = 3.
     IF SY-SUBRC <> 0.
       P_CHECK = C_TRUE.
       MESSAGE ID SY-MSGID TYPE P_ERRMODE NUMBER SY-MSGNO
               WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
     ENDIF.
   ELSE.
     CALL FUNCTION 'DEQUEUE_EMEKKOE'
       EXPORTING
         MANDT = SY-MANDT
         EBELN = P_EBELN
         EBELP = P_EBELP.
   ENDIF.

 ENDFORM.                    " set_po_lock_object
*&---------------------------------------------------------------------*
*&      Form  set_lc_lock_object
*&---------------------------------------------------------------------*
*       수입의뢰 Lock/Unlock routine
*----------------------------------------------------------------------*
 FORM SET_LC_LOCK_OBJECT  USING    P_REQNO
                                   P_AMDSQ
                                   P_REQIT
                                   P_MODE
                                   P_ERRMODE
                                   P_CHECK.
   CLEAR: P_CHECK.

   IF P_MODE EQ 'L'.
     CALL FUNCTION 'ENQUEUE_EZ_TI_ZTITRQK'
       EXPORTING
         MANDT          = SY-MANDT
         REQNO          = P_REQNO
         AMDSQ          = P_AMDSQ
         REQIT          = P_REQIT
       EXCEPTIONS
         FOREIGN_LOCK   = 1
         SYSTEM_FAILURE = 2
         OTHERS         = 3.
     IF SY-SUBRC <> 0.
       P_CHECK = C_TRUE.
       MESSAGE ID SY-MSGID TYPE P_ERRMODE NUMBER SY-MSGNO
               WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
     ENDIF.
   ELSE.
     CALL FUNCTION 'DEQUEUE_EZ_TI_ZTITRQK'
       EXPORTING
         MANDT = SY-MANDT
         REQNO = P_REQNO
         AMDSQ = P_AMDSQ
         REQIT = P_REQIT.
   ENDIF.

 ENDFORM.                    " set_LC_lock_object
*&---------------------------------------------------------------------*
*&      Form  set_bl_lock_object
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
 FORM SET_BL_LOCK_OBJECT  USING    P_IBLNO
                                   P_IBLIT
                                   P_MODE
                                   P_ERRMODE
                                   P_CHECK.
   CLEAR: P_CHECK.

   IF P_MODE EQ 'L'.
     CALL FUNCTION 'ENQUEUE_EZ_TI_ZTITBLK'
       EXPORTING
         MANDT          = SY-MANDT
         IBLNO          = P_IBLNO
         IBLIT          = P_IBLIT
       EXCEPTIONS
         FOREIGN_LOCK   = 1
         SYSTEM_FAILURE = 2
         OTHERS         = 3.
     IF SY-SUBRC <> 0.
       P_CHECK = C_TRUE.
       MESSAGE ID SY-MSGID TYPE P_ERRMODE NUMBER SY-MSGNO
               WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
     ENDIF.
   ELSE.
     CALL FUNCTION 'DEQUEUE_EZ_TI_ZTITBLK'
       EXPORTING
         MANDT = SY-MANDT
         IBLNO = P_IBLNO
         IBLIT = P_IBLIT.
   ENDIF.

 ENDFORM.                    " set_bl_lock_object
*&---------------------------------------------------------------------*
*&      Form  set_iv_lock_object
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
 FORM SET_IV_LOCK_OBJECT  USING    P_IVONO
                                   P_RBLGP
                                   P_MODE
                                   P_ERRMODE
                                   P_CHECK.
   CLEAR: P_CHECK.

   IF P_MODE EQ 'L'.
     CALL FUNCTION 'ENQUEUE_EZ_TI_ZTITIVK'
       EXPORTING
         MANDT          = SY-MANDT
         IVONO          = P_IVONO
         RBLGP          = P_RBLGP
       EXCEPTIONS
         FOREIGN_LOCK   = 1
         SYSTEM_FAILURE = 2
         OTHERS         = 3.
     IF SY-SUBRC <> 0.
       P_CHECK = C_TRUE.
       MESSAGE ID SY-MSGID TYPE P_ERRMODE NUMBER SY-MSGNO
               WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
     ENDIF.
   ELSE.
     CALL FUNCTION 'DEQUEUE_EZ_TI_ZTITIVK'
       EXPORTING
         MANDT = SY-MANDT
         IVONO = P_IVONO
         RBLGP = P_RBLGP.
   ENDIF.

 ENDFORM.                    " set_iv_lock_object

*&---------------------------------------------------------------------*
*&      Form  set_va_lock_object
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
 FORM SET_VA_LOCK_OBJECT  USING    P_VATNO
                                   P_RBLGP
                                   P_MODE
                                   P_ERRMODE
                                   P_CHECK.
   CLEAR: P_CHECK.

   IF P_MODE EQ 'L'.
     CALL FUNCTION 'ENQUEUE_EZ_TI_ZTITVAK'
       EXPORTING
         MANDT          = SY-MANDT
         VATNO          = P_VATNO
         RBLGP          = P_RBLGP
       EXCEPTIONS
         FOREIGN_LOCK   = 1
         SYSTEM_FAILURE = 2
         OTHERS         = 3.
     IF SY-SUBRC <> 0.
       P_CHECK = C_TRUE.
       MESSAGE ID SY-MSGID TYPE P_ERRMODE NUMBER SY-MSGNO
               WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
     ENDIF.
   ELSE.
     CALL FUNCTION 'DEQUEUE_EZ_TI_ZTITVAK'
       EXPORTING
         MANDT = SY-MANDT
         VATNO = P_VATNO
         RBLGP = P_RBLGP.
   ENDIF.

 ENDFORM.                    " set_va_lock_object

*&---------------------------------------------------------------------*
*&      Form  set_cc_lock_object
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
 FORM SET_CC_LOCK_OBJECT  USING    P_ICCNO
                                   P_ICCSQ
                                   P_ICCIT
                                   P_MODE
                                   P_ERRMODE
                                   P_CHECK.
   CLEAR: P_CHECK.

   IF P_MODE EQ 'L'.
     CALL FUNCTION 'ENQUEUE_EZ_TI_ZTITCCK'
       EXPORTING
         MANDT          = SY-MANDT
         ICCNO          = P_ICCNO
         ICCSQ          = P_ICCSQ
         ICCIT          = P_ICCIT
       EXCEPTIONS
         FOREIGN_LOCK   = 1
         SYSTEM_FAILURE = 2
         OTHERS         = 3.
     IF SY-SUBRC <> 0.
       P_CHECK = C_TRUE.
       MESSAGE ID SY-MSGID TYPE P_ERRMODE NUMBER SY-MSGNO
               WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
     ENDIF.
   ELSE.
     CALL FUNCTION 'DEQUEUE_EZ_TI_ZTITCCK'
       EXPORTING
         MANDT = SY-MANDT
         ICCNO = P_ICCNO
         ICCSQ = P_ICCSQ
         ICCIT = P_ICCIT.
   ENDIF.

 ENDFORM.                    " set_cc_lock_object
*&---------------------------------------------------------------------*
*&      Form  set_ip_lock_object
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
 FORM SET_IP_LOCK_OBJECT  USING    P_IIPNO
                                   P_AMDSQ
                                   P_MODE
                                   P_ERRMODE
                                   P_CHECK.
   CLEAR: P_CHECK.

   IF P_MODE EQ 'L'.
     CALL FUNCTION 'ENQUEUE_EZ_TI_ZTITIP1'
       EXPORTING
         MANDT          = SY-MANDT
         IIPNO          = P_IIPNO
         AMDSQ          = P_AMDSQ
       EXCEPTIONS
         FOREIGN_LOCK   = 1
         SYSTEM_FAILURE = 2
         OTHERS         = 3.
     IF SY-SUBRC <> 0.
       P_CHECK = C_TRUE.
       MESSAGE ID SY-MSGID TYPE P_ERRMODE NUMBER SY-MSGNO
               WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
     ENDIF.
   ELSE.
     CALL FUNCTION 'DEQUEUE_EZ_TI_ZTITIP1'
       EXPORTING
         MANDT = SY-MANDT
         IIPNO = P_IIPNO
         AMDSQ = P_AMDSQ.
   ENDIF.

 ENDFORM.                    " set_ip_lock_object
*&---------------------------------------------------------------------*
*&      Form  set_pn_lock_object
*&---------------------------------------------------------------------*
*       Notice Lock Object.
*----------------------------------------------------------------------*
 FORM SET_PN_LOCK_OBJECT  USING    P_PNTNO
                                   P_PNTIT
                                   P_MODE
                                   P_ERRMODE
                                   P_CHECK.
   CLEAR: P_CHECK.

   IF P_MODE EQ 'L'.
     CALL FUNCTION 'ENQUEUE_EZ_TI_ZTITPNK'
       EXPORTING
         MANDT          = SY-MANDT
         PNTNO          = P_PNTNO
         PNTIT          = P_PNTIT
       EXCEPTIONS
         FOREIGN_LOCK   = 1
         SYSTEM_FAILURE = 2
         OTHERS         = 3.
     IF SY-SUBRC <> 0.
       P_CHECK = C_TRUE.
       MESSAGE ID SY-MSGID TYPE P_ERRMODE NUMBER SY-MSGNO
               WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
     ENDIF.
   ELSE.
     CALL FUNCTION 'DEQUEUE_EZ_TI_ZTITPNK'
       EXPORTING
         MANDT = SY-MANDT
         PNTNO = P_PNTNO
         PNTIT = P_PNTIT.
   ENDIF.

 ENDFORM.                    " set_PN_lock_object

*&---------------------------------------------------------------------*
*&      Form  set_lg_lock_object
*&---------------------------------------------------------------------*
*       L/G Lock Object.
*----------------------------------------------------------------------*
 FORM SET_LG_LOCK_OBJECT  USING    P_ILGNO
                                   P_MODE
                                   P_ERRMODE
                                   P_CHECK.
   CLEAR: P_CHECK.

   IF P_MODE EQ 'L'.
     CALL FUNCTION 'ENQUEUE_EZ_TI_ZTITLG1'
       EXPORTING
         MANDT          = SY-MANDT
         ILGNO          = P_ILGNO
       EXCEPTIONS
         FOREIGN_LOCK   = 1
         SYSTEM_FAILURE = 2
         OTHERS         = 3.
     IF SY-SUBRC <> 0.
       P_CHECK = C_TRUE.
       MESSAGE ID SY-MSGID TYPE P_ERRMODE NUMBER SY-MSGNO
               WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
     ENDIF.
   ELSE.
     CALL FUNCTION 'DEQUEUE_EZ_TI_ZTITLG1'
       EXPORTING
         MANDT = SY-MANDT
         ILGNO = P_ILGNO.
   ENDIF.

 ENDFORM.                    " set_lg_lock_object
*&---------------------------------------------------------------------*
*&      Form  set_gr_lock_object
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
 FORM SET_GR_LOCK_OBJECT  USING    P_IGRNO
                                   P_MODE
                                   P_ERRMODE
                                   P_CHECK.
   CLEAR: P_CHECK.

   IF P_MODE EQ 'L'.
     CALL FUNCTION 'ENQUEUE_EZ_TI_ZTITGRK'
       EXPORTING
         MANDT          = SY-MANDT
         IGRNO          = P_IGRNO
       EXCEPTIONS
         FOREIGN_LOCK   = 1
         SYSTEM_FAILURE = 2
         OTHERS         = 3.
     IF SY-SUBRC <> 0.
       P_CHECK = C_TRUE.
       MESSAGE ID SY-MSGID TYPE P_ERRMODE NUMBER SY-MSGNO
               WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
     ENDIF.
   ELSE.
     CALL FUNCTION 'DEQUEUE_EZ_TI_ZTITGRK'
       EXPORTING
         MANDT = SY-MANDT
         IGRNO = P_IGRNO.
   ENDIF.

 ENDFORM.                    " set_gr_lock_object

*&---------------------------------------------------------------------*
*&      Form  set_tx_lock_object
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
 FORM SET_TX_LOCK_OBJECT  USING    P_TAXNO
                                   P_MODE
                                   P_ERRMODE
                                   P_CHECK.
   CLEAR: P_CHECK.

   IF P_MODE EQ 'L'.
     CALL FUNCTION 'ENQUEUE_EZ_TI_ZTITTXK'
       EXPORTING
         MANDT          = SY-MANDT
         TAXNO          = P_TAXNO
       EXCEPTIONS
         FOREIGN_LOCK   = 1
         SYSTEM_FAILURE = 2
         OTHERS         = 3.
     IF SY-SUBRC <> 0.
       P_CHECK = C_TRUE.
       MESSAGE ID SY-MSGID TYPE P_ERRMODE NUMBER SY-MSGNO
               WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
     ENDIF.
   ELSE.
     CALL FUNCTION 'DEQUEUE_EZ_TI_ZTITTXK'
       EXPORTING
         MANDT = SY-MANDT
         TAXNO = P_TAXNO.
   ENDIF.

 ENDFORM.                    " set_tx_lock_object

*&---------------------------------------------------------------------*
*&      Form  set_ac_lock_object
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
 FORM SET_AC_LOCK_OBJECT  USING    P_ACDNO
                                   P_MODE
                                   P_ERRMODE
                                   P_CHECK.
   CLEAR: P_CHECK.

   IF P_MODE EQ 'L'.
     CALL FUNCTION 'ENQUEUE_EZ_TI_ZTITACK'
       EXPORTING
         MANDT          = SY-MANDT
         ACDNO          = P_ACDNO
       EXCEPTIONS
         FOREIGN_LOCK   = 1
         SYSTEM_FAILURE = 2
         OTHERS         = 3.
     IF SY-SUBRC <> 0.
       P_CHECK = C_TRUE.
       MESSAGE ID SY-MSGID TYPE P_ERRMODE NUMBER SY-MSGNO
               WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
     ENDIF.
   ELSE.
     CALL FUNCTION 'DEQUEUE_EZ_TI_ZTITACK'
       EXPORTING
         MANDT = SY-MANDT
         ACDNO = P_ACDNO.
   ENDIF.

 ENDFORM.                    " set_ac_lock_object

*&---------------------------------------------------------------------*
*&      Form  set_cs_lock_object
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
 FORM SET_CS_LOCK_OBJECT  USING    P_BUKRS
                                   P_ICSNO
                                   P_MODE
                                   P_ERRMODE
                                   P_CHECK.
   CLEAR: P_CHECK.

   IF P_MODE EQ 'L'.
     CALL FUNCTION 'ENQUEUE_EZ_TI_ZTITCSK'
       EXPORTING
         MANDT          = SY-MANDT
         BUKRS          = P_BUKRS
         ICSNO          = P_ICSNO
       EXCEPTIONS
         FOREIGN_LOCK   = 1
         SYSTEM_FAILURE = 2
         OTHERS         = 3.
     IF SY-SUBRC <> 0.
       P_CHECK = C_TRUE.
       MESSAGE ID SY-MSGID TYPE P_ERRMODE NUMBER SY-MSGNO
               WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
     ENDIF.
   ELSE.
     CALL FUNCTION 'DEQUEUE_EZ_TI_ZTITCSK'
       EXPORTING
         MANDT = SY-MANDT
         BUKRS = P_BUKRS
         ICSNO = P_ICSNO.
   ENDIF.

 ENDFORM.                    " set_cs_lock_object
*&---------------------------------------------------------------------*
*&      Form  set_bd_lock_object
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
 FORM SET_BD_LOCK_OBJECT  USING    P_ICCNO
                                   P_BDSEQ
                                   P_MODE
                                   P_ERRMODE
                                   P_CHECK.
   CLEAR: P_CHECK.

   IF P_MODE EQ 'L'.
     CALL FUNCTION 'ENQUEUE_EZ_TI_ZTITBDK'
       EXPORTING
         MANDT          = SY-MANDT
         ICCNO          = P_ICCNO
         BDSEQ          = P_BDSEQ
       EXCEPTIONS
         FOREIGN_LOCK   = 1
         SYSTEM_FAILURE = 2
         OTHERS         = 3.
     IF SY-SUBRC <> 0.
       P_CHECK = C_TRUE.
       MESSAGE ID SY-MSGID TYPE P_ERRMODE NUMBER SY-MSGNO
               WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
     ENDIF.
   ELSE.
     CALL FUNCTION 'DEQUEUE_EZ_TI_ZTITBDK'
       EXPORTING
         MANDT = SY-MANDT
         ICCNO = P_ICCNO
         BDSEQ = P_BDSEQ.
   ENDIF.

 ENDFORM.                    " set_bd_lock_object


*&---------------------------------------------------------------------*
*&      Form  set_return_message
*&---------------------------------------------------------------------*
 FORM SET_RETURN_MESSAGE  USING    NOI_TAB NOI_FIELD P_MSGTY.

   TABLES : DFIES.

   DATA: BEGIN OF FELD,
           TABLE(10),
           STRICH,
           NAME(10),
         END OF FELD,
         RC.

   FELD-TABLE = NOI_TAB.
   FELD-STRICH = '-'.
   CONDENSE FELD.
   SEARCH FELD FOR '-'.
   SY-FDPOS = SY-FDPOS - 1.
   WRITE '-' TO FELD+SY-FDPOS.
   SY-FDPOS = SY-FDPOS + 1.
   WRITE NOI_FIELD TO FELD+SY-FDPOS.
   IF SY-STEPL EQ 0.
     SET CURSOR FIELD FELD.
   ELSE.
     SET CURSOR FIELD FELD LINE SY-STEPL.
   ENDIF.

   PERFORM GET_FTEXT(RDDFIE00) USING NOI_TAB NOI_FIELD SY-LANGU
                               CHANGING DFIES RC.
   IF RC EQ 0.
     MESSAGE S083(ME) WITH DFIES-SCRTEXT_M.
   ELSE.
     MESSAGE S083(ME) WITH NOI_TAB NOI_FIELD.
   ENDIF.

   PERFORM SET_RETURN_MESSAGE_FILL USING P_MSGTY.

 ENDFORM.                    " set_return_message
*&---------------------------------------------------------------------*
*&      Form  set_return_message_FILL
*&---------------------------------------------------------------------*
 FORM SET_RETURN_MESSAGE_FILL USING P_MSGTY.

*> build message
   ZTI_MESSAGE P_MSGTY SY-MSGID SY-MSGNO
               SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.

 ENDFORM.                    " set_return_message_FILL
*&---------------------------------------------------------------------*
*&      Form  P9000_came_to_an_end
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
 FORM P9000_CAME_TO_AN_END .

*> Save User setting infomation
   PERFORM  SET_USER_SETTING_STRUCTURE.

   IF G_MODE NE C_CHARC.
     CALL FUNCTION 'SWU_OBJECT_RESTORE'
       EXPORTING
         OBJTYPE = G_NCR_OBJTYPE
         OBJKEY  = G_NCR_OBKEY.
   ENDIF.

   IF NOT G_ALV_TREE IS INITIAL.
     CALL METHOD G_ALV_TREE->FREE.
   ENDIF.
   IF NOT G_DOCKING IS INITIAL.
     CALL METHOD G_DOCKING->SET_VISIBLE
       EXPORTING
         VISIBLE           = '0'
       EXCEPTIONS
         CNTL_SYSTEM_ERROR = 1
         CNTL_ERROR        = 2.
*     CALL METHOD g_docking->free.
   ENDIF.

*     CALL METHOD g_alv_tree->is_active
*       EXPORTING
*         ret_active = l_active.
*
*      CALL METHOD g_alv_tree->execute( CHANGING im_fcode = 'METRON' ).
*      CALL METHOD g_alv_tree->SWITCH_TREE_ON.
*      CALL METHOD g_alv_tree->update_tree_display.

**     if l_active is initial.
*     call method g_docking->GET_VISIBLE
*          importing
*             VISIBLE = l_visible.

*     IF NOT g_docking IS INITIAL.
**     if l_visible eq 'X'.
*       CALL METHOD g_docking->free.
*     ENDIF.
*
*     CALL METHOD g_alv_tree->free.
**     endif.
*   ENDIF.


   FREE : G_DOCKING,
          G_FACTORY,
          G_FRAMEWORK,
          G_FW,
          G_DATABLADE,
          G_ALV_TREE,
          G_DOCKING,
          G_CONTOLLER,
          G_CMD_PROC,
          G_COMMANDS,
          G_CONTAINER,
          G_CALL_VIEW,
          G_CALL_VIEW_STACK,
          G_DEFAULT_VIEW,
          G_COMPOSITE_VIEW,
          G_ENV_FUNCTIONS,
          G_MESSAGE_HANDLER,
          G_QUERY_CONTROLLER,
          G_PERSONALIZATION,
          G_PERSONALIZATION_WORK_SPPLY,
*          g_esdus_stream,
          G_MEMORY_STREAM.

*-----global dequeue
   CALL FUNCTION 'DEQUEUE_ALL'.

 ENDFORM.                    " P9000_came_to_an_end

*&---------------------------------------------------------------------*
*&      Form  GET_SMART_FORM_NAME
*&---------------------------------------------------------------------*
*        GET THE SMART FORM'S FUNCTION MODULE
*----------------------------------------------------------------------*
 FORM GET_SMART_FORM_NAME  USING    P_NAME   P_FUNC_MOD_NAME.


* GET THE SMART FORM'S FUNCTION MODULE
   CALL FUNCTION 'SSF_FUNCTION_MODULE_NAME'
     EXPORTING
       FORMNAME           = P_NAME
     IMPORTING
       FM_NAME            = P_FUNC_MOD_NAME
     EXCEPTIONS
       NO_FORM            = 1
       NO_FUNCTION_MODULE = 2
       OTHERS             = 3.

* ERROR HANDLING
   IF SY-SUBRC <> 0.
     MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
             WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
   ENDIF.

 ENDFORM.                    " GET_SMART_FORM_NAME
*&---------------------------------------------------------------------*
*&      Form  GET_VENDOR_INFORMATION
*&---------------------------------------------------------------------*
 FORM GET_OUTPUT_INFORMATION  TABLES   P_PRTCTL STRUCTURE ZTISPRTCTL
                              USING    P_ANSWER.

   DATA : L_LOGONDATA LIKE    USLOGOND,
          L_DEFAULTS  LIKE    USDEFAULTS,
          L_ADDRESS   LIKE    USADDRESS.

   DATA BEGIN OF LT_PARAMETERS OCCURS 20.
   INCLUDE STRUCTURE USPARAM.
   DATA END OF LT_PARAMETERS.

*>Get User Information
   CALL FUNCTION 'SUSR_USER_READ'
     EXPORTING
       USER_NAME            = SY-UNAME
       WITH_TEXT            = 'X'
     IMPORTING
       USER_LOGONDATA       = L_LOGONDATA
       USER_DEFAULTS        = L_DEFAULTS
       USER_ADDRESS         = L_ADDRESS
     TABLES
       USER_PARAMETERS      = LT_PARAMETERS
     EXCEPTIONS
       USER_NAME_NOT_EXISTS = 1
       INTERNAL_ERROR       = 2
       OTHERS               = 3.

   IF SY-SUBRC NE 0.
     MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
             WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
   ENDIF.
   LOOP AT P_PRTCTL.
     IF L_DEFAULTS-SPLD IS INITIAL.
       P_PRTCTL-TDDEST     = 'LOLC'.
     ELSE.
       P_PRTCTL-TDDEST     = L_DEFAULTS-SPLD.
     ENDIF.
     P_PRTCTL-FLAG       = C_TRUE.
     IF P_PRTCTL-PRTTY IS INITIAL.
       P_PRTCTL-PRTTY      = '1'.   ">Printer
     ENDIF.
     IF P_PRTCTL-DOCTY IS INITIAL.
       P_PRTCTL-PRTTY      = '1'.   ">신청서.
     ENDIF.
     IF P_PRTCTL-TDCOPIES IS INITIAL.
       P_PRTCTL-TDCOPIES   = C_ONE.
     ENDIF.
     P_PRTCTL-PREVIEW    = C_TRUE.
     P_PRTCTL-TDNEWID    = C_TRUE.
     P_PRTCTL-TDIMMED    = C_TRUE.
     P_PRTCTL-TDDELETE   = C_TRUE.
     P_PRTCTL-TDRECEIVER = P_PRTCTL-TELFX.
     P_PRTCTL-PRINT_LANG = P_PRTCTL-SPRAS.
     P_PRTCTL-TDTELELAND = P_PRTCTL-LAND1.

     SELECT SMTP_ADDR INTO P_PRTCTL-SMTP_ADDR
            FROM  ADR6 UP TO 1 ROWS
            WHERE ADDRNUMBER EQ P_PRTCTL-ADRNR.
     ENDSELECT.

     MODIFY P_PRTCTL.
   ENDLOOP.

   CALL FUNCTION 'Z_TI_GET_VENDOR_BY_SEND'
     IMPORTING
       ANSWER  = P_ANSWER
     TABLES
       XPRTCTL = P_PRTCTL.

 ENDFORM.                    " GET_VENDOR_INFORMATION
*&---------------------------------------------------------------------*
*&      Form  set_output_information
*&---------------------------------------------------------------------*
 FORM SET_OUTPUT_INFORMATION  USING    P_PRTCTL STRUCTURE ZTISPRTCTL.

   TABLES : TSP03.

   CASE P_PRTCTL-PRTTY.
     WHEN '1'.    G_TDDEVICE = C_PRINTER.
     WHEN '2'.    G_TDDEVICE = C_TELEFAX.
     WHEN '3'.    G_TDDEVICE = C_MAIL.
     WHEN '4'.    G_TDDEVICE = C_PDF.
   ENDCASE.

* SET OUTPUT OPTIONS
   G_CONTROL_PARAMETERS-NO_OPEN   = ' '.             ">SAP Smart Forms
   G_CONTROL_PARAMETERS-NO_CLOSE  = ' '.             ">SAP Smart Forms
   G_CONTROL_PARAMETERS-NO_DIALOG = 'X'.             ">SAP Smart Forms
   G_CONTROL_PARAMETERS-PREVIEW   = P_PRTCTL-PREVIEW.">preview

   IF G_TDDEVICE = C_PDF OR
      G_TDDEVICE = C_MAIL.
     G_CONTROL_PARAMETERS-GETOTF    = 'X'.          ">Return of OTF
   ELSE.
     CLEAR G_CONTROL_PARAMETERS-GETOTF.             ">Return of OTF
   ENDIF.
   IF G_TDDEVICE = C_PDF.
     CLEAR: G_CONTROL_PARAMETERS-PREVIEW.
   ENDIF.
   IF P_PRTCTL-LIFNR EQ 'EN'.
     G_CONTROL_PARAMETERS-LANGU     = '3'.                ">Language key
   ELSE.
     G_CONTROL_PARAMETERS-LANGU     = P_PRTCTL-PRINT_LANG.">Language key
   ENDIF.

   G_CONTROL_PARAMETERS-REPLANGU1 = ' '.              ">Language key
   G_CONTROL_PARAMETERS-REPLANGU2 = ' '.              ">Language key
   G_CONTROL_PARAMETERS-REPLANGU3 = ' '.              ">Language key
   G_CONTROL_PARAMETERS-STARTPAGE = ' '.              "> Object name

   IF G_TDDEVICE EQ C_MAIL OR
      G_TDDEVICE EQ C_PDF  OR
      G_TDDEVICE EQ C_PRINTER.
     G_CONTROL_PARAMETERS-DEVICE    = C_PRINTER.    ">Output device
   ELSE.
     G_CONTROL_PARAMETERS-DEVICE    = G_TDDEVICE.  ">Output device
   ENDIF.

   CLEAR TSP03-PATYPE.
   IF NOT P_PRTCTL-TDDEST IS INITIAL.
     SELECT SINGLE PATYPE INTO TSP03-PATYPE
            FROM  TSP03
            WHERE PADEST = P_PRTCTL-TDDEST.
   ENDIF.

   IF G_TDDEVICE = C_TELEFAX.
     G_OUTPUT_OPTIONS-TDTELELAND = P_PRTCTL-TDTELELAND. ">Country key
     G_OUTPUT_OPTIONS-TDTELENUM  = P_PRTCTL-TDRECEIVER. ">Telec
     G_OUTPUT_OPTIONS-TDTELENUME = ''.        ">Telecommunications
     G_OUTPUT_OPTIONS-TDFAXUSER  = SY-UNAME.  ">SAPoffice user name
     G_OUTPUT_OPTIONS-FAXFORMAT  = ' '.       ">3-Byte field
   ENDIF.

   G_OUTPUT_OPTIONS-TDSCHEDULE = ' '.      ">Send time request
   G_OUTPUT_OPTIONS-TDSENDDATE = SY-DATLO. ">Requested send date
   G_OUTPUT_OPTIONS-TDSENDTIME = SY-TIMLO. ">Requested send time
   G_OUTPUT_OPTIONS-TDARMOD    = ' '.      ">Print: Archiving mode
   G_OUTPUT_OPTIONS-TDNOARMCH  = ' '.      ">No changes by archiving
* OUTPUT_OPTIONS-TDTITLE    = 'X'. ">Title in dialog box
   G_OUTPUT_OPTIONS-TDNOPREV   = ' '. ">No print preview
   G_OUTPUT_OPTIONS-TDNOPRINT  = ' '. ">No printing from print preview
   G_OUTPUT_OPTIONS-TDNOARCH   = ' '. ">No archiving from print preview
   G_OUTPUT_OPTIONS-TDIEXIT    = ' '. ">Immediate exit after
   G_OUTPUT_OPTIONS-TDDATASET  = ' '. ">Spool request: Name
   G_OUTPUT_OPTIONS-TDSUFFIX1  = ' '. ">Spool request: Suffix 1
   G_OUTPUT_OPTIONS-TDSUFFIX2  = ' '. ">Spool request: Suffix 2
   G_OUTPUT_OPTIONS-TDCOVTITLE = ' '. ">Print parameters

*>Title in dialog box.
   IF P_PRTCTL-PRTTY EQ '1'.
     CASE G_DOCUMENT.
       WHEN C_LC.
         G_OUTPUT_OPTIONS-TDTITLE = '수입의뢰신청서'(T01).
       WHEN C_LG.
         G_OUTPUT_OPTIONS-TDTITLE = 'L/G 발급신청서'(T51).
       WHEN C_IV.
       WHEN C_AC.
         G_OUTPUT_OPTIONS-TDTITLE = '내국신용장 물품수령 증명서'(T71).
     ENDCASE.
   ELSE.
     CASE G_DOCUMENT.
       WHEN C_LC.
         G_OUTPUT_OPTIONS-TDTITLE = '수입개설응답서'(T02).
       WHEN C_LG.
         G_OUTPUT_OPTIONS-TDTITLE = 'L/G 발급서'(T52).
       WHEN C_IV.
       WHEN C_AC.
         G_OUTPUT_OPTIONS-TDTITLE = '내국신용장 물품수령 증명서'(T71).
     ENDCASE.
   ENDIF.

   IF G_TDDEVICE = C_PRINTER OR
      G_TDDEVICE = C_MAIL    OR
      G_TDDEVICE = C_PDF.
     G_OUTPUT_OPTIONS-TDDEST     = P_PRTCTL-TDDEST.   ">Output device
     G_OUTPUT_OPTIONS-TDPRINTER  = TSP03-PATYPE.      ">Device type
   ENDIF.

   G_OUTPUT_OPTIONS-TDNEWID    = P_PRTCTL-TDNEWID.  ">new spool request
   G_OUTPUT_OPTIONS-TDIMMED    = P_PRTCTL-TDIMMED.  ">print immediately
   G_OUTPUT_OPTIONS-TDDELETE   = P_PRTCTL-TDDELETE. ">delete after print
   G_OUTPUT_OPTIONS-TDLIFETIME = ' '. ">Print parameters,spool retention
   G_OUTPUT_OPTIONS-TDAUTORITY = ' '. ">Print: Authorization
   G_OUTPUT_OPTIONS-TDFINAL    = ' '. ">Spool request completed
   G_OUTPUT_OPTIONS-TDCOVER    = P_PRTCTL-TDCOVER. ">SAP cover page
   G_OUTPUT_OPTIONS-TDRECEIVER = ' '. ">Print parameters, recipient
   G_OUTPUT_OPTIONS-TDDIVISION = ' '. ">Print parameters, department on
   G_OUTPUT_OPTIONS-TDCOPIES   = P_PRTCTL-TDCOPIES. ">Number of Copies
   G_OUTPUT_OPTIONS-TDPAGESLCT = ' '. ">Pages selected for printing

   IF G_TDDEVICE = C_PDF OR
      G_TDDEVICE = C_MAIL.
     CLEAR: G_OUTPUT_OPTIONS-TDIMMED, G_OUTPUT_OPTIONS-TDDELETE.
   ENDIF.

 ENDFORM.                    " call_smartforms_functions
*&---------------------------------------------------------------------*
*&      Form  exec_external_sending
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM EXEC_EXTERNAL_SENDING USING P_PRTCTL STRUCTURE ZTISPRTCTL.

   DATA: L_OFF_OBJ TYPE SOODK,
         L_OK      TYPE C,
         L_MSGNO   TYPE SYMSGNO,
         L_MSGID   TYPE SYMSGID,
         L_MSGV1   TYPE SYMSGV,
         L_MSGV2   TYPE SYMSGV,
         L_MSGV3   TYPE SYMSGV,
         L_MSGV4   TYPE SYMSGV.

   IF G_TDDEVICE = C_MAIL.
* no BOR RECIPIENT object yet
     CLEAR: G_MAIL_APPL_OBJ, G_MAIL_RECIPIENT, G_MAIL_SENDER.
*> For build  Recipient e-mail address
     G_IP_MAILADDR = P_PRTCTL-SMTP_ADDR.

     SET LOCALE LANGUAGE P_PRTCTL-SPRAS.   "'EN'.

     TRANSLATE G_IP_MAILADDR TO LOWER CASE.

     CALL FUNCTION 'CREATE_RECIPIENT_OBJ_PPF'
       EXPORTING
         IP_MAILADDR       = G_IP_MAILADDR
         IP_TYPE_ID        = 'U'
       IMPORTING
         EP_RECIPIENT_ID   = G_MAIL_RECIPIENT
*        EP_ADDRESS        = return_addr
       EXCEPTIONS
         INVALID_RECIPIENT = 1
         OTHERS            = 2.
     IF SY-SUBRC NE 0.
       MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
               WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
     ENDIF.
*> For build  Sender e-mail address
     CONCATENATE SY-UNAME C_URL INTO G_IP_MAILADDR.
     SET LOCALE LANGUAGE P_PRTCTL-SPRAS. "'EN'.
     TRANSLATE G_IP_MAILADDR TO LOWER CASE.

     CALL FUNCTION 'CREATE_RECIPIENT_OBJ_PPF'
       EXPORTING
         IP_MAILADDR       = G_IP_MAILADDR
         IP_TYPE_ID        = 'U'
       IMPORTING
         EP_RECIPIENT_ID   = G_MAIL_SENDER
*        EP_ADDRESS        = return_addr
       EXCEPTIONS
         INVALID_RECIPIENT = 1
         OTHERS            = 2.
     IF SY-SUBRC NE 0.
       MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
               WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
     ENDIF.

     CALL FUNCTION 'SSFCONVERT_OTF_AND_MAIL'
       EXPORTING
         MAIL_SENDER                 = G_MAIL_SENDER
         MAIL_RECIPIENT              = G_MAIL_RECIPIENT
         MAILOPTIONS                 = G_PARAM
       IMPORTING
         MAIL_OK                     = L_OK
         OFFICE_OBJID                = L_OFF_OBJ
         MSGNO                       = L_MSGNO
         MSGID                       = L_MSGID
         MSGV1                       = L_MSGV1
         MSGV2                       = L_MSGV2
         MSGV3                       = L_MSGV3
         MSGV4                       = L_MSGV4
       TABLES
         MAIL_APPLICATION_OBJECT_IDS = G_MAIL_APPL_OBJ_TAB
         OTF                         = G_JOB_OUTPUT_INFO-OTFDATA.

     IF L_OK = 'X'.
*       MAIL REQUEST WAS SUCCESSFULLY CREATED
       MESSAGE S024(SSFCOMPOSER) WITH L_OFF_OBJ-OBJNO.
       G_PARAM-MAILOBJ = L_OFF_OBJ-OBJNO.
     ELSE.
       MESSAGE ID L_MSGID TYPE 'E' NUMBER L_MSGNO
               WITH L_MSGV1 L_MSGV2 L_MSGV3 L_MSGV4.
     ENDIF.
   ELSEIF G_TDDEVICE = C_PDF.
     IF P_PRTCTL-PREVIEW EQ 'X'.
       CALL FUNCTION 'SSFCOMP_PDF_PREVIEW'
         EXPORTING
           I_OTF                    = G_JOB_OUTPUT_INFO-OTFDATA
         EXCEPTIONS
*          acrobat_not_registered   = 1
           CONVERT_OTF_TO_PDF_ERROR = 2
*          download_error           = 3
*          acrobat_not_started      = 4
           CNTL_ERROR               = 5.
       IF SY-SUBRC NE 0.
         MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
                 WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
       ENDIF.
     ELSE.
* try to locate acrobat reader
       CALL FUNCTION 'REGISTRY_GET'
         EXPORTING
           KEY   = C_ACROBAT_READER_KEY
         IMPORTING
           VALUE = G_REG_VALUE.

       IF G_REG_VALUE IS INITIAL.
         MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
                 WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
       ENDIF.

* convert otf to pdf
       CALL FUNCTION 'CONVERT_OTF'
         EXPORTING
           FORMAT                = 'PDF'
         IMPORTING
           BIN_FILESIZE          = G_SIZE
         TABLES
           OTF                   = G_JOB_OUTPUT_INFO-OTFDATA
           LINES                 = G_PDF
         EXCEPTIONS
           ERR_MAX_LINEWIDTH     = 1
           ERR_FORMAT            = 2
           ERR_CONV_NOT_POSSIBLE = 3
           OTHERS                = 4.

       IF SY-SUBRC <> 0.
         MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
                 WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
       ENDIF.

*-- remove temporary file ----------------------------------------------
       CALL FUNCTION 'WS_FILE_DELETE'
         EXPORTING
           FILE = 'C:\TEMP\~SMART.PDF'.
*              IMPORTING
*                   RETURN  =
*            EXCEPTIONS
*                 OTHERS  = 1.
*       IF sy-subrc <> 0.
**            MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
**                    WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
*       ENDIF.
*
* create pdf file
*      CALL FUNCTION 'WS_DOWNLOAD'
       CALL FUNCTION 'GUI_DOWNLOAD'
         EXPORTING
           BIN_FILESIZE = G_SIZE
*          CODEPAGE     = ' '
           FILENAME     = 'C:\TEMP\~SMART.PDF'
           FILETYPE     = 'BIN'
*          MODE         = ' '
         TABLES
           DATA_TAB     = G_PDF[]
*          FIELDNAMES   =
         EXCEPTIONS
*          file_open_error         = 1
*          file_write_error        = 2
*          invalid_filesize        = 3
*          invalid_type = 4
*          no_batch     = 5
*          unknown_error           = 6
*          invalid_table_width     = 7
*          gui_refuse_filetransfer = 8
*          customer_error          = 9
           OTHERS       = 10.

       IF SY-SUBRC <> 0.
         MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
                 WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
       ENDIF.

       CALL FUNCTION 'WS_EXECUTE'
         EXPORTING
           CD                 = 'C:\TEMP'
           COMMANDLINE        = ' /p /h ~SMART.PDF'
           PROGRAM            = G_REG_VALUE
         EXCEPTIONS
           FRONTEND_ERROR     = 1
           NO_BATCH           = 2
           PROG_NOT_FOUND     = 3
           ILLEGAL_OPTION     = 4
           GUI_REFUSE_EXECUTE = 5
           OTHERS             = 6.

       IF SY-SUBRC <> 0.
         MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
                 WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
       ENDIF.

     ENDIF.
   ENDIF.

 ENDFORM.                    " exec_external_sending
*&---------------------------------------------------------------------*
*&      Form  FCODE_TC_SELECTED_DOCUMENT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_P_TC_NAME  text
*      -->P_P_TABLE_NAME  text
*      -->P_0106   text
*----------------------------------------------------------------------*
 FORM FCODE_TC_SELECTED_DOCUMENT  USING    P_TC_NAME TYPE DYNFNAM
                                           P_TABLE_NAME
                                           P_MARK_NAME
                                           P_DOCUMENT.
*> BEGIN OF LOCAL DATA-------------------------------------------------*
   DATA L_TABLE_NAME          LIKE FELD-NAME.
   DATA L_COUNT               TYPE I.
   DATA L_SELLINE             LIKE SY-STEPL.

   DATA L_EBELN               TYPE EBELN.
   DATA L_EBELP               TYPE EBELP.
   DATA L_EXPGR               TYPE ZTIEXPGR.
   DATA L_REFNO               TYPE ZTIREQNO.
   DATA L_AMDSQ               TYPE ZTIAMSEQ.

   FIELD-SYMBOLS <TC>         TYPE CXTAB_CONTROL.
   FIELD-SYMBOLS <TABLE>      TYPE STANDARD TABLE.
   FIELD-SYMBOLS <WA>.
   FIELD-SYMBOLS <MARK_FIELD>.
   FIELD-SYMBOLS <FS>.
*> END OF LOCAL DATA--------------------------------------------------*

   ASSIGN (P_TC_NAME) TO <TC>.

*> get the table, which belongs to the tc
   CONCATENATE P_TABLE_NAME '[]' INTO L_TABLE_NAME. "table body
   ASSIGN (L_TABLE_NAME) TO <TABLE>.                "not headerline

*> delete marked lines
   DESCRIBE TABLE <TABLE> LINES <TC>-LINES.
   CLEAR: L_COUNT.

   LOOP AT <TABLE> ASSIGNING <WA>.

*> access to the component 'FLAG' of the table header
     ASSIGN COMPONENT P_MARK_NAME OF STRUCTURE <WA> TO <MARK_FIELD>.

     IF <MARK_FIELD> = 'X'.
       ADD 1 TO L_COUNT.
     ENDIF.
   ENDLOOP.

   CASE L_COUNT.
     WHEN C_ZERO.
*> get current line
       GET CURSOR LINE L_SELLINE.
       IF SY-SUBRC NE 0.
         MESSAGE S909.
         EXIT.
       ENDIF.
       LOOP AT <TABLE> ASSIGNING <WA> FROM L_SELLINE TO L_SELLINE.
         CASE P_DOCUMENT.
           WHEN C_LC OR C_BL OR C_IV OR C_PN OR C_GR OR
                C_IP OR C_BS OR C_BI OR C_BO.
             ASSIGN COMPONENT 'EBELN' OF STRUCTURE <WA>
                                      TO <FS>.
             L_EBELN = <FS>.
             ASSIGN COMPONENT 'EBELP' OF STRUCTURE <WA>
                                      TO <FS>.
             L_EBELP = <FS>.
             PERFORM DISPLAY_PURCHASE_ORDER
                         USING  L_EBELN L_EBELP.
           WHEN C_CS.
             ASSIGN COMPONENT 'EXPGR' OF STRUCTURE <WA>
                                      TO <FS>.
             L_EXPGR = <FS>.
             ASSIGN COMPONENT 'REFNO' OF STRUCTURE <WA>
                                      TO <FS>.
             L_REFNO = <FS>.
             ASSIGN COMPONENT 'AMDSQ' OF STRUCTURE <WA>
                                      TO <FS>.
             L_AMDSQ = <FS>.
             PERFORM DISPLAY_REF_DOCUMENT IN PROGRAM (G_REPID)
                                          USING L_EXPGR
                                                L_REFNO
                                                L_AMDSQ.
         ENDCASE.
       ENDLOOP.
       IF SY-SUBRC NE 0.
         MESSAGE S909.
       ENDIF.
     WHEN C_ONE.
       LOOP AT <TABLE> ASSIGNING <WA>.
*> access to the component 'FLAG' of the table header
         ASSIGN COMPONENT P_MARK_NAME OF STRUCTURE <WA> TO <MARK_FIELD>.

         IF <MARK_FIELD> = 'X'.
           CASE P_DOCUMENT.
             WHEN C_LC OR C_BL OR C_IV OR C_PN OR C_IP OR
                  C_CC OR C_GR OR C_LG OR C_BS OR C_BI OR
                  C_BO.
               ASSIGN COMPONENT 'EBELN' OF STRUCTURE <WA>
                                        TO <FS>.
               L_EBELN = <FS>.
               ASSIGN COMPONENT 'EBELP' OF STRUCTURE <WA>
                                        TO <FS>.
               L_EBELP = <FS>.
               PERFORM DISPLAY_PURCHASE_ORDER
                           USING  L_EBELN L_EBELP.
             WHEN C_CS.
               ASSIGN COMPONENT 'EXPGR' OF STRUCTURE <WA>
                                        TO <FS>.
               L_EXPGR = <FS>.
               ASSIGN COMPONENT 'REFNO' OF STRUCTURE <WA>
                                        TO <FS>.
               L_REFNO = <FS>.
               ASSIGN COMPONENT 'AMDSQ' OF STRUCTURE <WA>
                                        TO <FS>.
               L_AMDSQ = <FS>.
               PERFORM DISPLAY_REF_DOCUMENT IN PROGRAM (G_REPID)
                                            USING L_EXPGR
                                                  L_REFNO
                                                  L_AMDSQ.
           ENDCASE.
         ENDIF.
       ENDLOOP.
       IF SY-SUBRC NE 0.
         MESSAGE S909.
       ENDIF.

     WHEN OTHERS.
       MESSAGE S903.
   ENDCASE.

 ENDFORM.                    " FCODE_TC_SELECTED_DOCUMENT
*&---------------------------------------------------------------------*
*&      Form  ddic_domain_value_text_read
*&---------------------------------------------------------------------*
 FORM DDIC_DOMAIN_VALUE_TEXT_READ
                     USING  P_NAME  LIKE DD07V-DOMNAME
                            P_SPRAS LIKE DD07V-DDLANGUAGE
                            P_VALUE
                            P_TEXT  LIKE DD07V-DDTEXT
                            P_MTYPE.

   DATA: L_VALUE  LIKE DD07V-DOMVALUE_L,
         L_DDTEXT LIKE DD01T-DDTEXT.

   CLEAR: P_TEXT.
   MOVE: P_VALUE TO L_VALUE.

   CALL FUNCTION 'C_DIC_DOMAIN_VALUE_TEXT_READ'
     EXPORTING
       NAME      = P_NAME
       SPRAS     = P_SPRAS
       VALUE     = L_VALUE
     IMPORTING
       TEXT      = P_TEXT
     EXCEPTIONS
       NOT_FOUND = 1
       OTHERS    = 2.
   IF SY-SUBRC <> 0.
     SELECT DDTEXT
       INTO L_DDTEXT
       FROM DD01T UP TO 1 ROWS
      WHERE DOMNAME    EQ P_NAME
        AND DDLANGUAGE EQ P_SPRAS.
     ENDSELECT.
     IF SY-SUBRC EQ 0.
       MESSAGE E047 WITH L_DDTEXT L_VALUE.
     ELSE.
       MESSAGE E048 WITH P_NAME L_VALUE.
     ENDIF.
*     MESSAGE ID sy-msgid TYPE p_mtype NUMBER sy-msgno
*             WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
   ENDIF.

 ENDFORM.                    " ddic_domain_value_text_read
*&---------------------------------------------------------------------*
*&      Form  p9000_program_exit
*&---------------------------------------------------------------------*
 FORM P9000_PROGRAM_EXIT .

   IF NOT SY-CALLD IS INITIAL.
*     LEAVE.
     SET SCREEN 0.
*       LEAVE TO SCREEN 0.
   ELSE.
     IF SY-TCODE EQ C_CREATE_D.
       LEAVE TO SCREEN 0.
     ELSE.
       LEAVE TO TRANSACTION SY-TCODE.
     ENDIF.
   ENDIF.

 ENDFORM.                    " p9000_program_exit
*&---------------------------------------------------------------------*
*&      Form  call_others_transaction
*&---------------------------------------------------------------------*
 FORM CALL_OTHERS_TRANSACTION  USING    P_MODE
                                        P_TCODE
                                        P_LEAVE
                                        P_EXIT.
   IF SY-DYNNR EQ C_SCR0100 OR
      SY-DYNNR EQ C_SCR0101 OR               "기능개선 283274 - 추가
      SY-DYNNR EQ C_SCR0200.
     LEAVE PROGRAM.
   ELSEIF SY-DYNNR EQ C_SCR2200.
     IF OK_CODE_OLD EQ 'ZTIBACK' OR
        OK_CODE_OLD EQ 'ZTIEXIT' OR
        OK_CODE_OLD EQ 'ZTICANCEL'.
       IF G_DOCUMENT EQ C_LC.
         PERFORM  PAYORD_DATA_MOVE IN PROGRAM (G_REPID).
       ENDIF.
       LEAVE TO SCREEN C_SCR2000.
     ENDIF.
   ENDIF.

   IF G_MODE NE 'S'.    ">조회 모드가 아닐경우.
*> 공용 대화상자(메시지 통일).
     CASE OK_CODE.
       WHEN 'ZTIBACK' OR 'ZTIEXIT' OR 'ZTICANCEL'.
         CALL FUNCTION 'Z_TI_POPUP_TO_CONFIRM_MESSAGE'
           EXPORTING
             XMODE       = 'X'
             IM_DOCUMENT = G_DOCUMENT
           IMPORTING
             ANSWER      = G_ANSWER.

         IF G_ANSWER EQ C_Y.
           PERFORM P9000_CAME_TO_AN_END.
           LEAVE PROGRAM.
         ENDIF.

       WHEN OTHERS.
         CALL FUNCTION 'Z_TI_POPUP_TO_CONFIRM_MESSAGE'
           EXPORTING
             XMODE       = P_MODE
             IM_DOCUMENT = G_DOCUMENT
           IMPORTING
             ANSWER      = G_ANSWER.
     ENDCASE.

     IF P_MODE EQ C_CHARI.
       IF G_ANSWER EQ C_Y.
         G_EDI_ANSWER = C_Y.
       ELSEIF G_ANSWER EQ C_N.
         G_EDI_ANSWER = C_N.
         G_ANSWER     = C_Y.
       ENDIF.
       IF ZTSTIG0-EDIIF EQ C_CHARN.
         G_EDI_ANSWER = C_N.
         G_ANSWER     = C_Y.
       ENDIF.
     ENDIF.

     IF G_ANSWER EQ C_Y.
       IF P_MODE EQ C_CHARX OR
          P_MODE EQ C_CHARS.
         PERFORM P9000_CAME_TO_AN_END.
         LEAVE PROGRAM.
       ENDIF.
*>Value Check.
       CLEAR: G_LINE.
       IF OK_CODE_OLD EQ 'ZTIDELETE'.
         PERFORM  CHECK_FOR_SUB_DOCUMENT_EXIST IN PROGRAM (G_REPID).
       ELSE.
         PERFORM  CHECK_FOR_DOCUMENT_FIELD USING P_MODE.
       ENDIF.

       IF G_LINE EQ C_ZERO.
*>Switches on the local update task.
         SET UPDATE TASK LOCAL.
*>Data Save.
         PERFORM P8000_SAVE_MASTER_DATA USING P_MODE.
         CHECK G_SUBRC EQ C_ZERO.
*>EDI Sending
         IF P_MODE       EQ C_CHARI  AND
            G_EDI_ANSWER EQ C_Y.
           PERFORM EDI_DATA_SENDING IN PROGRAM (G_REPID).
         ENDIF.

*>for free by Objects
         PERFORM P9000_CAME_TO_AN_END.
         IF P_EXIT EQ C_TRUE.
           LEAVE PROGRAM.
         ELSE.
           IF P_LEAVE EQ C_TRUE.
             IF SY-CALLD EQ C_TRUE.
               LEAVE.
             ELSE.
               IF P_MODE EQ C_CHARX.
                 LEAVE.
               ELSE.
                 IF SY-TCODE EQ C_CREATE_D.
                   LEAVE TO SCREEN 0.
                 ELSE.
                   LEAVE TO TRANSACTION P_TCODE.
                 ENDIF.
               ENDIF.
             ENDIF.
           ELSE.
             PERFORM P9000_PROGRAM_EXIT.   ">Program Exit.
           ENDIF.
         ENDIF.
       ELSE.
         MESSAGE S910.
       ENDIF.

     ELSEIF G_ANSWER EQ 'N'.
       IF P_EXIT NE C_TRUE.
         PERFORM P9000_CAME_TO_AN_END.
         IF P_EXIT EQ C_TRUE.
           LEAVE PROGRAM.
         ELSE.
           IF P_LEAVE EQ C_TRUE.
             IF SY-CALLD EQ C_TRUE.
               LEAVE.
             ELSE.
               IF P_MODE EQ C_CHARX.
                 LEAVE.
               ELSE.
                 IF SY-TCODE EQ C_CREATE_D.
                   LEAVE TO SCREEN 0.
                 ELSE.
                   LEAVE TO TRANSACTION P_TCODE.
                 ENDIF.
               ENDIF.
             ENDIF.
           ELSE.
             PERFORM P9000_PROGRAM_EXIT.
           ENDIF.
         ENDIF.
       ENDIF.
     ENDIF.
   ELSE.
     PERFORM P9000_CAME_TO_AN_END.
     IF P_LEAVE EQ C_TRUE.
       IF SY-CALLD EQ C_TRUE.
         IF SY-BATCH EQ C_TRUE.
           LEAVE.
         ELSE.
           IF P_MODE EQ C_CHARX.
             LEAVE.
           ELSE.
             LEAVE TO TRANSACTION P_TCODE.
           ENDIF.
         ENDIF.
       ELSE.
         IF SY-TCODE EQ C_CREATE_D.
           LEAVE TO SCREEN 0.
         ELSE.
           IF P_MODE EQ C_CHARX.
             LEAVE.
           ELSE.
             LEAVE TO TRANSACTION P_TCODE.
           ENDIF.
         ENDIF.
       ENDIF.
     ELSE.
       PERFORM P9000_PROGRAM_EXIT.
     ENDIF.
   ENDIF.

 ENDFORM.                    " call_others_transaction
*&---------------------------------------------------------------------*
*&      Form  set_next_process
*&---------------------------------------------------------------------*
 FORM SET_NEXT_PROCESS  USING    P_NEXT_PROCESS.

   CASE P_NEXT_PROCESS.
     WHEN 'IP'.

     WHEN 'BL'.

     WHEN 'IV'.

     WHEN 'CC'.

     WHEN 'GR'.

   ENDCASE.

 ENDFORM.                    " set_next_process
*&---------------------------------------------------------------------*
*&      Form  get_request_no_by_po_number
*&---------------------------------------------------------------------*
*       구매문서번호로 의뢰된 수입의뢰 관리번호를 구하는 서브루틴.
*----------------------------------------------------------------------*
 FORM GET_REQUEST_NO_BY_PO_NUMBER USING    P_EBELN
                                           P_REQNO
                                           P_AMDSQ
                                           P_CLEAR_MODE.
   IF P_CLEAR_MODE EQ C_TRUE.
     CLEAR : P_REQNO, P_AMDSQ.
   ENDIF.

   IF NOT P_EBELN IS INITIAL.
     CLEAR: G_COUNT.
     SELECT  REQNO AMDSQ
       INTO (ZTIVRQ01-REQNO, ZTIVRQ01-AMDSQ)
       FROM  ZTIVRQ01
      WHERE  EBELN EQ P_EBELN
      GROUP  BY REQNO AMDSQ.
       ADD 1 TO G_COUNT.
     ENDSELECT.

     CASE G_COUNT.
       WHEN  0.
         MESSAGE E106 WITH P_EBELN.
       WHEN  1.
         MOVE: ZTIVRQ01-REQNO TO P_REQNO,
               ZTIVRQ01-AMDSQ TO P_AMDSQ.
         EXIT.
       WHEN OTHERS.
         CALL FUNCTION 'Z_TI_POPUP_TO_REQNO_BY_EBELN'
           EXPORTING
             XEBELN    = P_EBELN
           IMPORTING
             XREQNO    = P_REQNO
             XAMDSQ    = P_AMDSQ
           EXCEPTIONS
             NOT_FOUND = 1
             OTHERS    = 2.

         IF SY-SUBRC <> 0.
           MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
                   WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
         ENDIF.
     ENDCASE.
   ENDIF.

 ENDFORM.                    " get_request_no_by_po_number
*&---------------------------------------------------------------------*
*&      Form  get_request_no_by_po_number1
*&---------------------------------------------------------------------*
*       구매문서번호로 의뢰된 수입의뢰 관리번호를 구하는 서브루틴.
*----------------------------------------------------------------------*
 FORM GET_REQUEST_NO_BY_PO_NUMBER1 USING    P_EBELN
                                            P_REQNO
                                            P_AMDSQ
                                            P_CLEAR_MODE.
   IF P_CLEAR_MODE EQ C_TRUE.
     CLEAR : P_REQNO, P_AMDSQ.
   ENDIF.

   IF NOT P_EBELN IS INITIAL.
     CLEAR: G_COUNT.
     SELECT  REQNO AMDSQ
       INTO (ZTIVRQ01-REQNO, ZTIVRQ01-AMDSQ)
       FROM  ZTIVRQ00
      WHERE EBELN EQ P_EBELN
      GROUP BY REQNO AMDSQ.
       ADD 1 TO G_COUNT.
     ENDSELECT.

     CASE G_COUNT.
       WHEN  0.
         MESSAGE W106 WITH P_EBELN.
       WHEN  1.
         MOVE: ZTIVRQ01-REQNO TO P_REQNO,
               ZTIVRQ01-AMDSQ TO P_AMDSQ.
         EXIT.
       WHEN OTHERS.
         CALL FUNCTION 'Z_TI_POPUP_TO_REQNO_BY_EBELN1'
           EXPORTING
             XEBELN    = P_EBELN
           IMPORTING
             XREQNO    = P_REQNO
             XAMDSQ    = P_AMDSQ
           EXCEPTIONS
             NOT_FOUND = 1
             OTHERS    = 2.

         IF SY-SUBRC <> 0.
           MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
                   WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
         ENDIF.
     ENDCASE.
   ENDIF.

 ENDFORM.                    " get_request_no_by_po_number1

*&---------------------------------------------------------------------*
*&      Form  get_request_no_by_open_number
*&---------------------------------------------------------------------*
*       개설번호로 의뢰된 수입의뢰 관리번호를 구하는 서브루틴.
*----------------------------------------------------------------------*
 FORM GET_REQUEST_NO_BY_OPEN_NUMBER  USING    P_OPNNO
                                              P_REQNO
                                              P_AMDSQ
                                              P_CLEAR_MODE.
   IF P_CLEAR_MODE EQ C_TRUE.
     CLEAR : P_REQNO, P_AMDSQ.
   ENDIF.

   IF NOT P_OPNNO IS INITIAL.
     CLEAR: G_COUNT.
     SELECT  REQNO AMDSQ
             INTO (ZTIVRQ01-REQNO, ZTIVRQ01-AMDSQ)
             FROM  ZTIVRQ01  WHERE OPNNO EQ P_OPNNO
             GROUP BY REQNO AMDSQ.
       ADD 1 TO G_COUNT.
     ENDSELECT.

     CASE G_COUNT.
       WHEN  0.
         MESSAGE E106 WITH P_OPNNO.
       WHEN  1.
         MOVE: ZTIVRQ01-REQNO TO P_REQNO,
               ZTIVRQ01-AMDSQ TO P_AMDSQ.
         EXIT.
       WHEN OTHERS.
         CALL FUNCTION 'Z_TI_POPUP_TO_REQNO_BY_OPNNO'
           EXPORTING
             XOPNNO    = P_OPNNO
           IMPORTING
             XREQNO    = P_REQNO
             XAMDSQ    = P_AMDSQ
           EXCEPTIONS
             NOT_FOUND = 1
             OTHERS    = 2.

         IF SY-SUBRC <> 0.
           MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
                   WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
         ENDIF.
     ENDCASE.
   ENDIF.

 ENDFORM.                    " get_request_no_by_open_number
*&---------------------------------------------------------------------*
*&      Form  get_request_no_by_open_number1
*&---------------------------------------------------------------------*
*       개설번호로 의뢰된 수입의뢰 관리번호를 구하는 서브루틴.
*----------------------------------------------------------------------*
 FORM GET_REQUEST_NO_BY_OPEN_NUMBER1 USING    P_OPNNO
                                              P_REQNO
                                              P_AMDSQ
                                              P_CLEAR_MODE.
   IF P_CLEAR_MODE EQ C_TRUE.
     CLEAR : P_REQNO, P_AMDSQ.
   ENDIF.

   IF NOT P_OPNNO IS INITIAL.
     CLEAR: G_COUNT.
     SELECT  REQNO AMDSQ
             INTO (ZTIVRQ00-REQNO, ZTIVRQ00-AMDSQ)
             FROM  ZTIVRQ00  WHERE OPNNO EQ P_OPNNO
             GROUP BY REQNO AMDSQ.
       ADD 1 TO G_COUNT.
     ENDSELECT.

     CASE G_COUNT.
       WHEN  0.
         MESSAGE E106 WITH P_OPNNO.
       WHEN  1.
*         SELECT DISTINCT reqno amdsq
*           INTO (p_reqno, p_amdsq)
*           FROM ZTIvrq00
*          WHERE ebeln EQ p_opnno.
*         ENDSELECT.
         MOVE: ZTIVRQ00-REQNO TO P_REQNO,
               ZTIVRQ00-AMDSQ TO P_AMDSQ.
         EXIT.
       WHEN OTHERS.
         CALL FUNCTION 'Z_TI_POPUP_TO_REQNO_BY_OPNNO1'
           EXPORTING
             XOPNNO    = P_OPNNO
           IMPORTING
             XREQNO    = P_REQNO
             XAMDSQ    = P_AMDSQ
           EXCEPTIONS
             NOT_FOUND = 1
             OTHERS    = 2.

         IF SY-SUBRC <> 0.
           MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
                   WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
         ENDIF.
     ENDCASE.
   ENDIF.

 ENDFORM.                    " get_request_no_by_open_number1
*&---------------------------------------------------------------------*
*&      Form  get_bl_int_no_by_bl_number
*&---------------------------------------------------------------------*
*       B/L 번호로 생성된 B/L관리번호를 구하는 서브루틴.
*----------------------------------------------------------------------*
 FORM GET_BL_INT_NO_BY_BL_NUMBER  USING    P_BLNUM
                                           P_IBLNO
                                           P_CLEAR_MODE.
   DATA: L_IBLNO LIKE ZTITBLK-IBLNO.

   IF P_CLEAR_MODE EQ C_TRUE.
     CLEAR : P_IBLNO.
   ENDIF.

   IF NOT P_BLNUM IS INITIAL.
     CLEAR: G_COUNT.
     SELECT  IBLNO
             INTO  L_IBLNO
             FROM  ZTITBLK  WHERE BLNUM EQ P_BLNUM.
       ADD 1 TO G_COUNT.
     ENDSELECT.

     CASE G_COUNT.
       WHEN  0.
         MESSAGE E207 WITH P_BLNUM.
       WHEN  1.
*         SELECT DISTINCT reqno amdsq
*           INTO (p_reqno, p_amdsq)
*           FROM ZTIvrq00
*          WHERE ebeln EQ p_ebeln.
*         ENDSELECT.
         MOVE: L_IBLNO TO P_IBLNO.
         EXIT.
       WHEN OTHERS.
         CALL FUNCTION 'Z_TI_POPUP_TO_IBLNO_BY_BLNUM'
           EXPORTING
             XBLNUM    = P_BLNUM
           IMPORTING
             XIBLNO    = P_IBLNO
           EXCEPTIONS
             NOT_FOUND = 1
             OTHERS    = 2.

         IF SY-SUBRC <> 0.
           MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
                   WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
         ENDIF.
     ENDCASE.
   ENDIF.

 ENDFORM.                    " get_bl_int_no_by_bl_number
*&---------------------------------------------------------------------*
*&      Form  get_lg_int_no_by_bl_number
*&---------------------------------------------------------------------*
*       B/L 번호로 생성된 L/G관리번호를 구하는 서브루틴.
*----------------------------------------------------------------------*
 FORM GET_LG_INT_NO_BY_BL_NUMBER  USING    P_BLNUM
                                           P_ILGNO
                                           P_CLEAR_MODE.
   DATA: L_ILGNO LIKE ZTITLG1-ILGNO.

   IF P_CLEAR_MODE EQ C_TRUE.
     CLEAR : P_ILGNO.
   ENDIF.

   IF NOT P_BLNUM IS INITIAL.
     CLEAR: G_COUNT.
     SELECT  ILGNO
             INTO  L_ILGNO
             FROM  ZTIVLG01  WHERE BLNUM EQ P_BLNUM.
       ADD 1 TO G_COUNT.
     ENDSELECT.

     CASE G_COUNT.
       WHEN  0.
         MESSAGE E600 WITH P_BLNUM.
       WHEN  1.
*         SELECT DISTINCT reqno amdsq
*           INTO (p_reqno, p_amdsq)
*           FROM ZTIvrq00
*          WHERE ebeln EQ p_ebeln.
*         ENDSELECT.
         MOVE: L_ILGNO TO P_ILGNO.
         EXIT.
       WHEN OTHERS.
         CALL FUNCTION 'Z_TI_POPUP_TO_ILGNO_BY_BLNUM'
           EXPORTING
             XBLNUM    = P_BLNUM
           IMPORTING
             XILGNO    = P_ILGNO
           EXCEPTIONS
             NOT_FOUND = 1
             OTHERS    = 2.

         IF SY-SUBRC <> 0.
           MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
                   WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
         ENDIF.
     ENDCASE.
   ENDIF.

 ENDFORM.                    " get_lg_int_no_by_bl_number

*&---------------------------------------------------------------------*
*&      Form  get_gr_int_no_by_bl_no
*&---------------------------------------------------------------------*
*       B/L 관리번호로 생성된 G/R관리번호를 구하는 서브루틴.
*----------------------------------------------------------------------*
 FORM GET_GR_INT_NO_BY_BL_NO  USING        P_IBLNO
                                           P_IGRNO
                                           P_CLEAR_MODE.
   DATA: L_IGRNO LIKE ZTITGRK-IGRNO.

   IF P_CLEAR_MODE EQ C_TRUE.
     CLEAR : P_IGRNO.
   ENDIF.

   IF NOT P_IBLNO IS INITIAL.
     CLEAR: G_COUNT.
     SELECT  IGRNO
       INTO  L_IGRNO
       FROM  ZTITGRK
      WHERE  IBLNO EQ P_IBLNO.
       ADD 1 TO G_COUNT.
     ENDSELECT.

     CASE G_COUNT.
       WHEN  0.
         MESSAGE E200 WITH P_IBLNO.
       WHEN  1.
         MOVE: L_IGRNO TO P_IGRNO.
         EXIT.
       WHEN OTHERS.
         CALL FUNCTION 'Z_TI_POPUP_TO_IGRNO_BY_IBLNO'
           EXPORTING
             XIBLNO    = P_IBLNO
           IMPORTING
             XIGRNO    = P_IGRNO
           EXCEPTIONS
             NOT_FOUND = 1
             OTHERS    = 2.

         IF SY-SUBRC <> 0.
           MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
                   WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
         ENDIF.
     ENDCASE.
   ENDIF.

 ENDFORM.                    " get_gr_int_no_by_bl_no
*&---------------------------------------------------------------------*
*&      Form  get_gr_int_no_by_cc_no
*&---------------------------------------------------------------------*
*       통관 관리번호로 생성된 G/R관리번호를 구하는 서브루틴.
*----------------------------------------------------------------------*
 FORM GET_GR_INT_NO_BY_CC_NO  USING        P_ICCNO
                                           P_IGRNO
                                           P_CLEAR_MODE.
   DATA: L_IGRNO LIKE ZTITGRK-IGRNO.

   IF P_CLEAR_MODE EQ C_TRUE.
     CLEAR : P_IGRNO.
   ENDIF.

   IF NOT P_ICCNO IS INITIAL.
     CLEAR: G_COUNT.
     SELECT  IGRNO
       INTO  L_IGRNO
       FROM  ZTITGRK
      WHERE  ICCNO EQ P_ICCNO.
       ADD 1 TO G_COUNT.
     ENDSELECT.

     CASE G_COUNT.
       WHEN  0.
         MESSAGE E400 WITH P_ICCNO '00'.
       WHEN  1.
         MOVE: L_IGRNO TO P_IGRNO.
         EXIT.
       WHEN OTHERS.
         CALL FUNCTION 'Z_TI_POPUP_TO_IGRNO_BY_ICCNO'
           EXPORTING
             XICCNO    = P_ICCNO
           IMPORTING
             XIGRNO    = P_IGRNO
           EXCEPTIONS
             NOT_FOUND = 1
             OTHERS    = 2.

         IF SY-SUBRC <> 0.
           MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
                   WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
         ENDIF.
     ENDCASE.
   ENDIF.

 ENDFORM.                    " get_gr_int_no_by_cc_no

*&---------------------------------------------------------------------*
*&      Form  no_input_check
*&---------------------------------------------------------------------*
 FORM NO_INPUT_CHECK  USING NOI_TAB NOI_FIELD P_MSGTY.

   DATA: BEGIN OF FELD,
           TABLE(15),
           STRICH,
           NAME(10),
         END OF FELD.

   FELD-TABLE = NOI_TAB.
   FELD-STRICH = '-'.
   CONDENSE FELD.
   SEARCH FELD FOR '-'.
   SY-FDPOS = SY-FDPOS - 1.
   WRITE '-' TO FELD+SY-FDPOS.
   SY-FDPOS = SY-FDPOS + 1.
   WRITE NOI_FIELD TO FELD+SY-FDPOS.
   IF SY-STEPL EQ 0.
     SET CURSOR FIELD FELD.
   ELSE.
     SET CURSOR FIELD FELD LINE SY-STEPL.
   ENDIF.

************************************************************************
* 변경자 : FIB05
* 변경일 : 2011.10.27
* CSR No : C20110916_63637
* CSR제목 : 내국신용장 개설 시 필수조항 추가
* 변경내역 : 개설의뢰인,수혜자 대표자명2에 사업자등록번호를 입력하여,
*  적절한 메세지를 위하여 하드코딩함.
* (EDI관련 struct의 length때문에 불가피함)
************************************************************************
** Begin
   IF FELD EQ 'ZTITLO1-LAPPR2'
   OR FELD EQ 'ZTITLO1-LBEPR2'.
     IF FELD EQ 'ZTITLO1-LAPPR2'.
       MESSAGE ID 'ZMTE' TYPE P_MSGTY
          NUMBER 915 WITH '개설의뢰인 사업자등록번호'.
     ELSEIF FELD EQ 'ZTITLO1-LBEPR2'.
       MESSAGE ID 'ZMTE' TYPE P_MSGTY
          NUMBER 915 WITH '수혜자 사업자등록번호'.
     ELSEIF FELD EQ 'ZTITPC1-PSPID'.
       MESSAGE ID 'ZMTE' TYPE P_MSGTY
          NUMBER 915 WITH '공급자 사업자등록번호'.
     ENDIF.
** END
   ELSE.
     PERFORM GET_FTEXT(RDDFIE00) USING  NOI_TAB NOI_FIELD SY-LANGU
                                 CHANGING DFIES G_SUBRC.
     IF G_SUBRC EQ 0.
       IF P_MSGTY EQ C_WARNING.
         MESSAGE ID 'ZMTE' TYPE P_MSGTY NUMBER 925 WITH DFIES-SCRTEXT_M.
       ELSE.
         MESSAGE ID 'ZMTE' TYPE P_MSGTY NUMBER 915 WITH DFIES-SCRTEXT_M. "* 원본 BK
       ENDIF.
     ELSE.
       IF P_MSGTY EQ C_WARNING.
         MESSAGE ID 'ZMTE' TYPE P_MSGTY
            NUMBER 925 WITH NOI_TAB NOI_FIELD.
       ELSE.
         MESSAGE ID 'ZMTE' TYPE P_MSGTY
            NUMBER 915 WITH NOI_TAB NOI_FIELD.
       ENDIF.
     ENDIF.
   ENDIF.

 ENDFORM.                    " no_input_check
*&---------------------------------------------------------------------*
*&      Form  MESSAGE_NOT_FOUND_VENDOR
*&---------------------------------------------------------------------*
 FORM MESSAGE_NOT_FOUND_VENDOR  USING NOI_TAB NOI_FIELD P_MSGTY.

   DATA: BEGIN OF FELD,
           TABLE(10),
           STRICH,
           NAME(10),
         END OF FELD.

   FELD-TABLE = NOI_TAB.
   FELD-STRICH = '-'.
   CONDENSE FELD.
   SEARCH FELD FOR '-'.
   SY-FDPOS = SY-FDPOS - 1.
   WRITE '-' TO FELD+SY-FDPOS.
   SY-FDPOS = SY-FDPOS + 1.
   WRITE NOI_FIELD TO FELD+SY-FDPOS.
   IF SY-STEPL EQ 0.
     SET CURSOR FIELD FELD.
   ELSE.
     SET CURSOR FIELD FELD LINE SY-STEPL.
   ENDIF.

   PERFORM GET_FTEXT(RDDFIE00) USING    NOI_TAB NOI_FIELD SY-LANGU
                               CHANGING DFIES G_SUBRC.
   IF G_SUBRC EQ 0.
     MESSAGE ID 'ZMTI00' TYPE P_MSGTY NUMBER 915 WITH DFIES-SCRTEXT_M.
*    MESSAGE e915 WITH dfies-scrtext_m.
   ELSE.
     MESSAGE ID 'ZMTI00' TYPE P_MSGTY NUMBER 915 WITH NOI_TAB NOI_FIELD.
*    MESSAGE e915 WITH noi_tab noi_field.
   ENDIF.

 ENDFORM.                    " MESSAGE_NOT_FOUND_VENDOR
*&---------------------------------------------------------------------*
*&      Form  save_long_text
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
 FORM SAVE_LONG_TEXT USING P_TDNAME
                           P_TDOBJECT
                           P_SUBRC.

   DATA: L_TDNAME   LIKE THEAD-TDNAME,
         L_TDOBJECT LIKE THEAD-TDOBJECT.

   CLEAR: P_SUBRC.
*> Long text ID의 Key value move
   L_TDNAME   = P_TDNAME.
   L_TDOBJECT = P_TDOBJECT.

*>
   READ TABLE GT_CONTROL WITH KEY OBJECT = L_TDOBJECT.

*> Long text move
   IT_ALL_LINES[] = GT_CONTROL-TEXTLINES[].

   SELECT * FROM TTXID
            INTO TABLE XTTXID
            WHERE TDOBJECT = P_TDOBJECT.

*> Long text ID별로 Save.
   LOOP AT XTTXID.
     G_TABIX = SY-TABIX.
     MOVE: P_TDOBJECT          TO THEAD-TDOBJECT,
           L_TDNAME            TO THEAD-TDNAME,
           SY-LANGU            TO THEAD-TDSPRAS,
           XTTXID-TDID         TO THEAD-TDID.

     REFRESH: IT_LINE.
     LOOP AT IT_ALL_LINES INTO G_TEXTLINES
                          WHERE TDOBJECT = THEAD-TDOBJECT
                            AND TDID     = THEAD-TDID.
       CLEAR: IT_LINE.
       MOVE: G_TEXTLINES-TDLINE   TO IT_LINE-TDLINE,
             G_TEXTLINES-TDFORMAT TO IT_LINE-TDFORMAT.
       APPEND IT_LINE.
     ENDLOOP.

*> 삭제 모드일 경우.
     IF OK_CODE_OLD EQ 'ZTIDELETE'.
       CALL FUNCTION 'DELETE_TEXT'
         EXPORTING
           CLIENT    = SY-MANDT
           ID        = THEAD-TDID
           LANGUAGE  = THEAD-TDSPRAS
           NAME      = THEAD-TDNAME
           OBJECT    = THEAD-TDOBJECT
*          SAVEMODE_DIRECT       = ' '
*          TEXTMEMORY_ONLY       = ' '
*          LOCAL_CAT = ' '
         EXCEPTIONS
           NOT_FOUND = 1
           OTHERS    = 2.
       IF SY-SUBRC <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
       ENDIF.

     ELSE.

       CALL FUNCTION 'SAVE_TEXT'
         EXPORTING
           CLIENT   = SY-MANDT
           HEADER   = THEAD
*          INSERT   = ' '
*          SAVEMODE_DIRECT       = ' '
*          OWNER_SPECIFIED       = ' '
*          LOCAL_CAT             = ' '
*    IMPORTING
*          FUNCTION =
*          NEWHEADER             =
         TABLES
           LINES    = IT_LINE[]
         EXCEPTIONS
           ID       = 1
           LANGUAGE = 2
           NAME     = 3
           OBJECT   = 4
           OTHERS   = 5.

       IF SY-SUBRC <> 0.
         MOVE P_SUBRC TO SY-SUBRC.
         ROLLBACK WORK.
         MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
                 WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.

       ENDIF.
     ENDIF.
   ENDLOOP.

 ENDFORM.                    " save_long_text
*&---------------------------------------------------------------------*
*&      Form  display_vendor_master
*&---------------------------------------------------------------------*
 FORM DISPLAY_VENDOR_MASTER  USING    P_LIFNR
                                      P_EKORG.
*------- Direktwerte GPA/SPA-------------------------------------------*
   DATA: KDY_VAL(8) VALUE '/110',
         LV_LIFNR   TYPE LFA1-LIFNR.

   CLEAR : LV_LIFNR.

   CHECK NOT P_LIFNR IS INITIAL.

   IF P_EKORG IS INITIAL.
     SET PARAMETER ID 'EKO' FIELD SPACE.
     SET PARAMETER ID 'KDY' FIELD KDY_VAL.

*-- [CCM-MM] MK03 수정 ZLSGMM4 2023.04.19
*     SET PARAMETER ID 'LIF' FIELD P_LIFNR.
*     CALL TRANSACTION 'MK03' AND SKIP FIRST SCREEN.

     LV_LIFNR = P_LIFNR.

     CALL FUNCTION 'Z_BP_DISPLAY_S4H'
       EXPORTING
         I_LIFNR = LV_LIFNR
         I_GUBUN = 'K'
         I_TCODE = 'MK03'.
   ELSE.
     CALL FUNCTION 'MMPUR_VENDOR_DISPLAY'
       EXPORTING
         IM_LIFNR = P_LIFNR
         IM_EKORG = P_EKORG.

     LV_LIFNR = P_LIFNR.

     CALL FUNCTION 'Z_BP_DISPLAY_S4H'
       EXPORTING
         I_LIFNR = LV_LIFNR
         I_GUBUN = 'K'
         I_TCODE = 'MK03'.
   ENDIF.

 ENDFORM.                    " display_vendor_master

*&---------------------------------------------------------------------*
*&      Form  display_project_master
*&---------------------------------------------------------------------*
 FORM DISPLAY_PROJECT_MASTER  USING    P_PSPNR.

   DATA: L_PSPID   LIKE   PROJ-PSPID.

   CHECK NOT P_PSPNR IS INITIAL.

   SELECT SINGLE PSPID
     INTO L_PSPID
     FROM PROJ
    WHERE PSPNR  EQ  P_PSPNR.
   IF SY-SUBRC EQ 0.

*   SET PARAMETER ID 'PRO' FIELD L_PSPID.
     SET PARAMETER ID 'PSP' FIELD L_PSPID.
*   CALL TRANSACTION 'CJ13' AND SKIP FIRST SCREEN.
     CALL TRANSACTION 'CJ08' AND SKIP FIRST SCREEN.
   ENDIF.

 ENDFORM.                    " display_project_master
*&---------------------------------------------------------------------*
*&      Form  get_edi_partner
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
 FORM GET_EDI_PARTNER  USING    P_PARTNER  LIKE      ZTSTIG3-EPART
                                 P_PARTI    LIKE      ZTSTIG3-PARTI
                                 P_ZTSTIG3  STRUCTURE ZTSTIG3
                                 P_MSGTY.
   DATA: LV_BUKRS LIKE BKPF-BUKRS.

   CLEAR: P_ZTSTIG3.

   CHECK NOT P_PARTNER IS INITIAL.

*  회사코드 : DefaultValue

   IF LV_BUKRS IS INITIAL.
     CALL FUNCTION 'Z_FI_GET_ORG_CODE'
       EXPORTING
         I_UNAME = SY-UNAME
       IMPORTING
         E_BUKRS = LV_BUKRS.

     IF LV_BUKRS IS INITIAL.
       CALL FUNCTION 'ZTR_GET_BUKRS'
         EXPORTING
           I_BUKRS = LV_BUKRS
         IMPORTING
           O_BUKRS = LV_BUKRS.
     ENDIF.
     SET PARAMETER ID 'BUK' FIELD LV_BUKRS.
   ENDIF.

   IF LV_BUKRS IS INITIAL.
     SELECT SINGLE *
       INTO P_ZTSTIG3
       FROM ZTSTIG3
      WHERE EPART  EQ  P_PARTNER
        AND PARTI  EQ  P_PARTI.
   ELSE.
     SELECT SINGLE *
       INTO P_ZTSTIG3
       FROM ZTSTIG3
      WHERE EPART  EQ  P_PARTNER
        AND PARTI  EQ  P_PARTI
        AND BUKRS  EQ  LV_BUKRS.
   ENDIF.

   IF SY-SUBRC NE 0.
     MESSAGE ID 'ZMTE' TYPE P_MSGTY NUMBER 918 WITH P_PARTNER.
   ENDIF.

 ENDFORM.                    " get_edi_partner
*&---------------------------------------------------------------------*
*&      Form  GET_EDI_BUKRS_PARTNER
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
 FORM GET_EDI_BUKRS_PARTNER  USING P_BUKRS    LIKE      ZTSTIG3-BUKRS
                                   P_PARTNER  LIKE      ZTSTIG3-EPART
                                   P_PARTI    LIKE      ZTSTIG3-PARTI
                                   P_ZTSTIG3  STRUCTURE ZTSTIG3
                                   P_MSGTY.

   CLEAR: P_ZTSTIG3.

   CHECK NOT P_PARTNER IS INITIAL.

   SELECT SINGLE *
     INTO P_ZTSTIG3
     FROM ZTSTIG3
    WHERE EPART  EQ  P_PARTNER
      AND PARTI  EQ  P_PARTI
      AND BUKRS  EQ  P_BUKRS.

   IF SY-SUBRC NE 0.
     MESSAGE ID 'ZMTE' TYPE P_MSGTY NUMBER 918 WITH P_PARTNER.
   ENDIF.

 ENDFORM.                    " GET_EDI_BUKRS_PARTNER
*&---------------------------------------------------------------------*
*&      Form  display_infomation_by_items
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
 FORM DISPLAY_INFOMATION_BY_ITEMS USING    P_TC_NAME     TYPE DYNFNAM
                                            P_TABLE_NAME
                                            P_MARK_NAME
                                            P_LIFNR
                                   CHANGING P_OKCODE.
*> BEGIN OF LOCAL DATA-------------------------------------------------*
   DATA L_TABLE_NAME          LIKE FELD-NAME.
   DATA L_COUNT               TYPE I.
   DATA L_SELLINE             TYPE I.
   DATA L_EBELN               TYPE EBELN.
   DATA L_EBELP               TYPE EBELP.
   DATA L_ICSSQ               TYPE ZTIICSSQ.

   DATA:L_MATNR TYPE EKPO-EMATN,
        L_WERKS TYPE EKPO-WERKS,
        L_LGORT TYPE EKPO-LGORT.


   FIELD-SYMBOLS <TC>         TYPE CXTAB_CONTROL.
   FIELD-SYMBOLS <TABLE>      TYPE STANDARD TABLE.
   FIELD-SYMBOLS <WA>.
   FIELD-SYMBOLS <MARK_FIELD>.
   FIELD-SYMBOLS <FS>.
*> END OF LOCAL DATA--------------------------------------------------*
   CASE P_OKCODE.
     WHEN 'ZTIMM03' OR    ">자재.
          'ZTIMD04' OR    ">재고/소요량 리스트.
          'ZTIME2M' OR    ">미결 구매 오더.
          'ZTIMB51' OR    ">자재별 자재문서.
          'ZTIMMBE' OR    ">재고개요.
          'ZTIME03' OR    ">소스리스트.
          'ZTIDOCHIS' OR  ">문서별 진행관리.
          'ZTIQTYHIS'.    ">수량별 진행관리.
     WHEN OTHERS.
       EXIT.
   ENDCASE.

   ASSIGN (P_TC_NAME) TO <TC>.

*> get the table, which belongs to the tc
   CONCATENATE P_TABLE_NAME '[]' INTO L_TABLE_NAME. "table body
   ASSIGN (L_TABLE_NAME) TO <TABLE>.                "not headerline

*> delete marked lines
   DESCRIBE TABLE <TABLE> LINES <TC>-LINES.
   CLEAR: L_COUNT.

   LOOP AT <TABLE> ASSIGNING <WA>.

*> access to the component 'FLAG' of the table header
     ASSIGN COMPONENT P_MARK_NAME OF STRUCTURE <WA> TO <MARK_FIELD>.

     IF <MARK_FIELD> = 'X'.
       ADD 1 TO L_COUNT.
       L_SELLINE = SY-TABIX.
     ENDIF.
   ENDLOOP.

   CASE L_COUNT.
     WHEN C_ZERO.
*> get current line
       GET CURSOR LINE L_SELLINE.
       IF SY-SUBRC NE 0.
         MESSAGE S909.
         EXIT.
       ENDIF.
     WHEN C_ONE.

     WHEN OTHERS.
       MESSAGE S903.
       EXIT.
   ENDCASE.

   LOOP AT <TABLE> ASSIGNING <WA> FROM L_SELLINE TO L_SELLINE.

     ASSIGN COMPONENT 'MATNR' OF STRUCTURE <WA>
                              TO <FS>.
     L_MATNR = <FS>.
     ASSIGN COMPONENT 'WERKS' OF STRUCTURE <WA>
                              TO <FS>.
     L_WERKS = <FS>.
     ASSIGN COMPONENT 'LGORT' OF STRUCTURE <WA>
                              TO <FS>.
     L_LGORT = <FS>.
     ASSIGN COMPONENT 'EBELN' OF STRUCTURE <WA>
                              TO <FS>.
     L_EBELN = <FS>.
     ASSIGN COMPONENT 'EBELP' OF STRUCTURE <WA>
                              TO <FS>.
     L_EBELP = <FS>.

     CASE P_OKCODE.
       WHEN 'ZTIMM03'.    ">자재.
         PERFORM DISPLAY_MATERIAL_MASTER        USING L_MATNR
                                                      L_WERKS
                                                      L_LGORT.
       WHEN 'ZTIMD04'.    ">재고/소요량 리스트.
         PERFORM DISPLAY_STOCK_AND_REQUIREMENT  USING L_MATNR
                                                      L_WERKS.
       WHEN 'ZTIME2M'.    ">미결 구매 오더.
         PERFORM DISPLAY_OPEN_PURCHASE_ORDER    USING L_MATNR
                                                      L_WERKS.
       WHEN 'ZTIMB51'.    ">자재별 자재문서.
         PERFORM DISPLAY_MATERIAL_DOCUMENT      USING L_MATNR
                                                      L_WERKS
                                                      L_LGORT
                                                      P_LIFNR.
       WHEN 'ZTIMMBE'.    ">재고개요.
         PERFORM DISPLAY_INVENTORY_OVERVIEW     USING L_MATNR
                                                      L_WERKS
                                                      L_LGORT.
       WHEN 'ZTIME03'.    ">소스리스트.
         PERFORM DISPLAY_SOURCE_LIST            USING L_MATNR
                                                      L_WERKS.
       WHEN 'ZTIDOCHIS'.  ">문서별 진행관리.
         IF G_DOCUMENT EQ C_CS.
           ASSIGN COMPONENT 'ICSSQ' OF STRUCTURE <WA>
                                    TO <FS>.
           L_ICSSQ = <FS>.
           PERFORM DISPLAY_DISTRIBUTION IN PROGRAM (G_REPID)
                                                  USING L_ICSSQ.
         ELSE.
           PERFORM DISPLAY_DOCUMENT_HISTORY       USING L_EBELN
                                                        L_EBELP.
         ENDIF.
*       WHEN 'ZTIQTYHIS'.  ">수량별 진행관리.
*         PERFORM display_quantity_history       USING l_ebeln
*                                                      l_ebelp.
     ENDCASE.
   ENDLOOP.
   IF SY-SUBRC NE 0.
     MESSAGE S909.
   ENDIF.

 ENDFORM.                    " display_infomation_by_items
*&---------------------------------------------------------------------*
*&      Form  DISPLAY_MATERIAL_MASTER
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
 FORM DISPLAY_MATERIAL_MASTER  USING    P_MATNR
                                        P_WERKS
                                        P_LGORT.

   CHECK NOT P_MATNR IS INITIAL.

   CALL FUNCTION 'MMPUR_MATERIAL_DISPLAY'
     EXPORTING
       IM_MATNR = P_MATNR
       IM_WERKS = P_WERKS
       IM_LGORT = P_LGORT.


 ENDFORM.                    " DISPLAY_MATERIAL_MASTER
*&---------------------------------------------------------------------*
*&      Form  DISPLAY_INVENTORY_OVERVIEW
*&---------------------------------------------------------------------*
 FORM DISPLAY_INVENTORY_OVERVIEW  USING    P_MATNR
                                           P_WERKS
                                           P_LGORT.
   CHECK NOT P_MATNR IS INITIAL.

   CALL FUNCTION 'MMPUR_INVENTORY_DISPLAY'
     EXPORTING
       IM_MATNR              = P_MATNR
       IM_WERKS              = P_WERKS
       IM_LGORT              = P_LGORT
     EXCEPTIONS
       SYSTEM_FAILURE        = 1
       COMMUNICATION_FAILURE = 2
       OTHERS                = 3.

   IF SY-SUBRC NE 0.
     MESSAGE S303(ME) WITH SPACE SPACE SPACE SPACE.
   ELSE.
     MESSAGE S014(MEPO).
   ENDIF.

 ENDFORM.                    " DISPLAY_INVENTORY_OVERVIEW
*&---------------------------------------------------------------------*
*&      Form  display_STOCK_AND_requirement
*&---------------------------------------------------------------------*
*       재고/소요량 리스트 ( MD04 )
*----------------------------------------------------------------------*
 FORM DISPLAY_STOCK_AND_REQUIREMENT  USING    P_MATNR
                                              P_WERKS.

   CHECK : NOT P_MATNR IS INITIAL AND
           NOT P_WERKS IS INITIAL.

   SET PARAMETER ID 'MAT' FIELD P_MATNR.
   SET PARAMETER ID 'WRK' FIELD P_WERKS.
   CALL TRANSACTION 'MD04' AND SKIP FIRST SCREEN.


 ENDFORM.                    " display_STOCK_AND_requirement
*&---------------------------------------------------------------------*
*&      Form  display_open_purchase_order
*&---------------------------------------------------------------------*
*        미결 구매 오더 ( ME2M )
*----------------------------------------------------------------------*
 FORM DISPLAY_OPEN_PURCHASE_ORDER  USING    P_MATNR
                                            P_WERKS.

   CHECK : NOT P_MATNR IS INITIAL AND
           NOT P_WERKS IS INITIAL.

   SUBMIT RM06EM00
     WITH EM_MATNR EQ P_MATNR
     WITH EM_WERKS EQ P_WERKS
     WITH LISTU    EQ 'BEST'
     WITH SELPA    EQ 'WE101'         " 매개변?
     AND RETURN.

 ENDFORM.                    " display_open_purchase_order
*&---------------------------------------------------------------------*
*&      Form  display_reservation
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
 FORM DISPLAY_RESERVATION  USING    P_RSNUM
                                    P_RSPOS.

   CHECK NOT P_RSNUM IS INITIAL.

   SET PARAMETER ID 'RES' FIELD P_RSNUM.
   SET PARAMETER ID 'RPO' FIELD P_RSPOS.
   CALL TRANSACTION 'MB23' AND SKIP FIRST SCREEN.

 ENDFORM.                    " display_reservation

*&---------------------------------------------------------------------*
*&      Form  display_material_document
*&---------------------------------------------------------------------*
*       자재별 자재문서 ( MB51 )
*----------------------------------------------------------------------*
 FORM DISPLAY_MATERIAL_DOCUMENT  USING    P_MATNR
                                          P_WERKS
                                          P_LGORT
                                          P_LIFNR.
   CHECK : NOT P_MATNR IS INITIAL.

   SET PARAMETER ID 'MAT' FIELD P_MATNR.
   SET PARAMETER ID 'WRK' FIELD P_WERKS.
   SET PARAMETER ID 'LAG' FIELD P_LGORT. ">저장위치
   SET PARAMETER ID 'LIF' FIELD P_LIFNR.
   SET PARAMETER ID 'CHA' FIELD ''.      ">BATCH 번호

   CALL TRANSACTION 'MB51' AND SKIP FIRST SCREEN.

 ENDFORM.                    " display_material_document
*&---------------------------------------------------------------------*
*&      Form  display_source_list
*&---------------------------------------------------------------------*
*       소스리스트 ( ME03 )
*----------------------------------------------------------------------*
 FORM DISPLAY_SOURCE_LIST  USING    P_MATNR
                                    P_WERKS.

   CHECK : NOT P_MATNR IS INITIAL AND
           NOT P_WERKS IS INITIAL.

   CALL FUNCTION 'MMPUR_SOURCE_LIST_DISPLAY'
     EXPORTING
       IM_MATNR = P_MATNR
       IM_WERKS = P_WERKS.

 ENDFORM.                    " display_source_list
*&---------------------------------------------------------------------*
*&      Form  display_document_history
*&---------------------------------------------------------------------*
*       문서별 진행관리.
*----------------------------------------------------------------------*
 FORM DISPLAY_DOCUMENT_HISTORY  USING    P_EBELN
                                         P_EBELP.

   CHECK NOT P_EBELN IS INITIAL.

   SUBMIT ZTIRH010
     WITH S_EBELN  EQ P_EBELN
     WITH S_EBELP  EQ P_EBELP
     AND RETURN.

 ENDFORM.                    " display_document_history
*&---------------------------------------------------------------------*
*&      Form  DISPLAY_INB_DOCUMENT
*&---------------------------------------------------------------------*
*       인바운드 납품 조회.
*----------------------------------------------------------------------*
 FORM DISPLAY_INB_DOCUMENT  USING    P_VBELN.

   CHECK NOT P_VBELN IS INITIAL.

   SET PARAMETER ID 'VLM' FIELD P_VBELN.

   CALL TRANSACTION 'VL33N' AND SKIP FIRST SCREEN.

 ENDFORM.                    " DISPLAY_INB_DOCUMENT

*&---------------------------------------------------------------------*
*&      Form  display_quantity_history
*&---------------------------------------------------------------------*
*       수량별 진행관리.
*----------------------------------------------------------------------*
 FORM DISPLAY_QUANTITY_HISTORY  USING    P_EBELN
                                         P_EBELP.

   CHECK NOT P_EBELN IS INITIAL.

 ENDFORM.                    " display_quantity_history
*&---------------------------------------------------------------------*
*&      Form  SET_EDI_SCREEN
*&---------------------------------------------------------------------*
*       EDI 화면 결정.
*----------------------------------------------------------------------*
 FORM SET_EDI_SCREEN  USING    P_REQTY.

   IF ZTITRQS-AMDSQ IS INITIAL.
*> 개설 관련.
     CASE P_REQTY.
       WHEN C_LC.                  G_CALL_SUBSCREEN = C_SCR2210.
       WHEN C_PU.                  G_CALL_SUBSCREEN = C_SCR2220.
       WHEN C_LO.                  G_CALL_SUBSCREEN = C_SCR2230.
       WHEN C_TT.                  G_CALL_SUBSCREEN = C_SCR2240.
       WHEN C_DA OR C_DP.
       WHEN C_IP OR C_LG OR C_CC.  G_CALL_SUBSCREEN = C_SCR2210.
       WHEN OTHERS.
     ENDCASE.
   ELSE.
*> Amend 관련.
     CASE P_REQTY.
       WHEN C_LC.                  G_CALL_SUBSCREEN = C_SCR2215.
       WHEN C_PU.                  G_CALL_SUBSCREEN = C_SCR2220.
       WHEN C_LO.                  G_CALL_SUBSCREEN = C_SCR2235.
       WHEN C_TT.
       WHEN C_DA OR C_DP.
       WHEN C_IP OR C_LG OR C_CC.  G_CALL_SUBSCREEN = C_SCR2210.
       WHEN OTHERS.
     ENDCASE.
   ENDIF.

 ENDFORM.                    " SET_EDI_SCREEN
*&---------------------------------------------------------------------*
*&      Module  pbo_edi_fields_change_attr  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
 MODULE PBO_EDI_FIELDS_CHANGE_ATTR OUTPUT.

   LOOP AT SCREEN .
     IF G_MODE = 'S' OR
        G_MODE = 'D' OR
        G_MODE = '0'.
       SCREEN-INPUT = C_CHAR0.

*S__ 신용장 변경에 따른 수정 20181010 BY SDW
       IF SCREEN-GROUP4 = 'OLD'.
         SCREEN-ACTIVE = '0'.
       ENDIF.
*E__ 신용장 변경에 따른 수정 20181010 BY SDW
     ELSE.
*       screen-input = c_char1.
       IF ZTITIG00-RQEDS EQ C_CHARA.
         CLEAR G_FIELDGROUP.
         CONCATENATE SCREEN-GROUP1 SCREEN-GROUP2
                     SCREEN-GROUP3 SCREEN-GROUP4
                INTO G_FIELDGROUP.
         IF NOT G_FIELDGROUP IS INITIAL.
           SEARCH G_FIELDGROUP FOR G_MODE.
           IF SY-SUBRC <> 0.
             SCREEN-INPUT = C_CHAR0.
           ELSE.
             SCREEN-INPUT = C_CHAR1.
           ENDIF.
         ENDIF.
       ENDIF.

*-{ 기능개선 198545 - 개설 의뢰인 상호 수정 불가
       IF ( ZTITIG00-BUKRS = '1000' OR  ZTITIG00-BUKRS = '5000'
           OR  ZTITIG00-BUKRS = '6000' )
          AND  SCREEN-GROUP1 EQ 'NM' .
         SCREEN-INPUT = '0'.
       ENDIF.
*-} 기능개선 198545

*S__ 신용장 변경에 따른 수정 20181010 BY SDW
       IF SCREEN-GROUP4 = 'OLD' OR
          SCREEN-GROUP4 = 'OL1'.
         SCREEN-ACTIVE = '0'.
       ENDIF.

       IF SCREEN-NAME = 'SUB1'.
         SCREEN-ACTIVE = '0'.
       ENDIF.
*E__ 신용장 변경에 따른 수정 20181010 BY SDW

     ENDIF.
*     IF g_document EQ c_lc.
*       IF ZTITRQS-docst EQ 'O'.
*         screen-input = '0'.
*       ENDIF.
*     ENDIF.
*     IF g_document EQ c_ip.
*       IF ZTITIP1-docst EQ 'O'.
*         screen-input = '0'.
*       ENDIF.
*     ENDIF.
*     IF g_document EQ c_lg.
*       IF ZTITLG1-docst EQ 'O'.
*         screen-input = '0'.
*       ENDIF.
*     ENDIF.
     MODIFY SCREEN.
   ENDLOOP.

 ENDMODULE.                 " pbo_edi_fields_change_attr  OUTPUT
*&---------------------------------------------------------------------*
*&      Form  display_import_document
*&---------------------------------------------------------------------*
*       수입의뢰문서 조회.
*----------------------------------------------------------------------*
 FORM DISPLAY_IMPORT_DOCUMENT  USING    P_REQNO
                                        P_AMDSQ
                                        P_REQIT.
   CHECK NOT P_REQNO IS INITIAL.

   SET PARAMETER ID 'ZTIREQNO' FIELD P_REQNO.
   SET PARAMETER ID 'ZTIAMDSQ' FIELD P_AMDSQ.
   SET PARAMETER ID 'ZTIREQIT' FIELD P_REQIT.
   SET PARAMETER ID 'BES'      FIELD SPACE.
   SET PARAMETER ID 'ZTIOPNNO' FIELD SPACE.

   CALL TRANSACTION 'ZTIT003' AND SKIP FIRST SCREEN.

 ENDFORM.                    " display_import_document
*&---------------------------------------------------------------------*
*&      Form  excute_import_document
*&---------------------------------------------------------------------*
*       수입의뢰문서 조회.
*----------------------------------------------------------------------*
 FORM EXCUTE_IMPORT_DOCUMENT  USING    P_REQNO
                                       P_AMDSQ
                                       P_TCODE.
   CHECK NOT P_REQNO IS INITIAL.

   SET PARAMETER ID 'ZTIREQNO' FIELD P_REQNO.
   SET PARAMETER ID 'ZTIAMDSQ' FIELD P_AMDSQ.
   SET PARAMETER ID 'ZTIREQIT' FIELD SPACE.
   SET PARAMETER ID 'BES'      FIELD SPACE.
   SET PARAMETER ID 'ZTIOPNNO' FIELD SPACE.

   CALL TRANSACTION P_TCODE AND SKIP FIRST SCREEN.

 ENDFORM.                    " excute_import_document

*&---------------------------------------------------------------------*
*&      Form  display_ip_document
*&---------------------------------------------------------------------*
*       적하보험문서 조회.
*----------------------------------------------------------------------*
 FORM DISPLAY_IP_DOCUMENT  USING        P_IIPNO
                                        P_AMDSQ.

   CHECK NOT P_IIPNO IS INITIAL.

   SET PARAMETER ID 'ZTIIIPNO' FIELD P_IIPNO.
   SET PARAMETER ID 'ZTIAMSEQ' FIELD P_AMDSQ.
*   SET PARAMETER ID 'BES'      FIELD space.
*   SET PARAMETER ID 'ZTIOPNNO' FIELD space.
*
   CALL TRANSACTION 'ZTIT103' AND SKIP FIRST SCREEN.

 ENDFORM.                    " display_ip_document

*&---------------------------------------------------------------------*
*&      Form  display_bl_document
*&---------------------------------------------------------------------*
*       B/L 문서 조회.
*----------------------------------------------------------------------*
 FORM DISPLAY_BL_DOCUMENT      USING    P_IBLNO
                                        P_IBLIT.
   CHECK NOT P_IBLNO IS INITIAL.

   SET PARAMETER ID 'ZTIIBLNO' FIELD P_IBLNO.
   SET PARAMETER ID 'ZTIIBLIT' FIELD P_IBLIT.
   SET PARAMETER ID 'ZTIBLNUM' FIELD SPACE.

   CALL TRANSACTION 'ZTIT203' AND SKIP FIRST SCREEN.

 ENDFORM.                    " display_import_document
*&---------------------------------------------------------------------*
*&      Form  display_lg_document
*&---------------------------------------------------------------------*
*       L/G 문서 조회.
*----------------------------------------------------------------------*
 FORM DISPLAY_LG_DOCUMENT      USING    P_ILGNO.

   CHECK NOT P_ILGNO IS INITIAL.

   SET PARAMETER ID 'ZTIILGNO' FIELD P_ILGNO.

   CALL TRANSACTION 'ZTIT603' AND SKIP FIRST SCREEN.

 ENDFORM.                    " display_lg_document

*&---------------------------------------------------------------------*
*       입고 문서 조회.
*----------------------------------------------------------------------*
 FORM DISPLAY_MATERIAL_DOC      USING    P_MBLNR
                                         P_MJAHR
                                         P_ZEILE
                                         P_BUKRS.
   CHECK NOT P_MBLNR IS INITIAL.

   SET PARAMETER ID 'MBN' FIELD P_MBLNR.
   SET PARAMETER ID 'MJA' FIELD P_MJAHR.
   SET PARAMETER ID 'BUK' FIELD P_BUKRS.

*>
   CALL FUNCTION 'MIGO_DIALOG'
     EXPORTING
       I_ACTION            = 'A04'
       I_REFDOC            = 'R02'
       I_NOTREE            = 'X'
*      I_NO_AUTH_CHECK     =
       I_SKIP_FIRST_SCREEN = 'X'
       I_DEADEND           = 'X'
       I_OKCODE            = 'OK_GO'
*      I_LEAVE_AFTER_POST  =
*      I_NEW_ROLLAREA      = 'X'
*      I_SYTCODE           =
*      I_EBELN             =
*      I_EBELP             =
       I_MBLNR             = P_MBLNR
       I_MJAHR             = P_MJAHR
       I_ZEILE             = P_ZEILE
*      I_TRANSPORT         =
*      I_ORDER_NUMBER      =
*      I_ORDER_ITEM        =
*      I_TRANSPORT_MEANS   =
*      I_TRANSPORTIDENT    =
*      I_INBOUND_DELIV     =
*      I_OUTBOUND_DELIV    =
*      I_RESERVATION_NUMB  =
*      I_RESERVATION_ITEM  =
     EXCEPTIONS
       ILLEGAL_COMBINATION = 1
       OTHERS              = 2.
   IF SY-SUBRC <> 0.
     MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
             WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
   ENDIF.

 ENDFORM.                    " display_import_document

*&---------------------------------------------------------------------*
*&      Form  display_civ_document
*&---------------------------------------------------------------------*
*       상업송장 문서 조회.
*----------------------------------------------------------------------*
 FORM DISPLAY_CIV_DOCUMENT      USING    P_IVONO.

   CHECK NOT P_IVONO IS INITIAL.

   SET PARAMETER ID 'ZTIIVONO' FIELD P_IVONO.
   SET PARAMETER ID 'ZTIIBLNO' FIELD SPACE.
   SET PARAMETER ID 'ZTIBLNUM' FIELD SPACE.
   SET PARAMETER ID 'ZTIOPNNO' FIELD SPACE.
   SET PARAMETER ID 'ZTIREQNO' FIELD SPACE.
   SET PARAMETER ID 'BES'      FIELD SPACE.

   CALL TRANSACTION 'ZTIT303' AND SKIP FIRST SCREEN.

 ENDFORM.                    " display_civ_document

*&---------------------------------------------------------------------*
*&      Form  display_LIV_DOCUMENT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
 FORM DISPLAY_LIV_DOCUMENT  USING    P_BELNR
                                     P_GJAHR
                                     P_BUKRS.

   CHECK NOT P_BELNR IS INITIAL.
   SELECT SINGLE *
     FROM RBKP
    WHERE BELNR = P_BELNR
      AND GJAHR = P_GJAHR.
   IF SY-SUBRC EQ 0.
     SET PARAMETER ID 'RBN' FIELD P_BELNR.
     SET PARAMETER ID 'GJR' FIELD P_GJAHR.
     CALL TRANSACTION 'MIR4' AND SKIP FIRST SCREEN.
   ELSE.
     CALL FUNCTION 'FI_DOCUMENT_LIST_DISPLAY'
       EXPORTING
         BUKRS                = P_BUKRS
         BELNR                = P_BELNR
         GJAHR                = P_GJAHR
*        AKTYP                = 'A'
*        XEPOS                =
*        I_NOCHANGE           =
*        XPRNT                =
*    IMPORTING
*        E_CMRQ               =
*        E_CHNG               =
       EXCEPTIONS
         DISPLAY_NOT_POSSIBLE = 1
         NO_AUTHORITY         = 2
         OTHERS               = 3.

     IF SY-SUBRC <> 0.
       MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
               WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
     ENDIF.
   ENDIF.

 ENDFORM.                    " display_LIV_DOCUMENT

*&---------------------------------------------------------------------*
*&      Form  display_cc_document
*&---------------------------------------------------------------------*
*       통관 문서 조회.
*----------------------------------------------------------------------*
 FORM DISPLAY_CC_DOCUMENT      USING    P_ICCNO
                                        P_ICCSQ.

   CHECK NOT P_ICCNO IS INITIAL.

   SET PARAMETER ID 'ZTIICCNO' FIELD P_ICCNO.
   SET PARAMETER ID 'ZTIICCSQ' FIELD P_ICCSQ.
   SET PARAMETER ID 'ZTIIBLNO' FIELD SPACE.
   SET PARAMETER ID 'ZTIBLNUM' FIELD SPACE.
   SET PARAMETER ID 'BES'      FIELD SPACE.

   CALL TRANSACTION 'ZTIT403' AND SKIP FIRST SCREEN.

 ENDFORM.                    " display_cc_document

*&---------------------------------------------------------------------*
*&      Form  display_cr_document
*&---------------------------------------------------------------------*
*       통관 문서 조회.
*----------------------------------------------------------------------*
 FORM DISPLAY_CR_DOCUMENT      USING    P_ICCNO
                                        P_ICCSQ.

   CHECK NOT P_ICCNO IS INITIAL.

   SET PARAMETER ID 'ZTIICCNO' FIELD P_ICCNO.
   SET PARAMETER ID 'ZTIICCSQ' FIELD P_ICCSQ.
   SET PARAMETER ID 'ZTIIBLNO' FIELD SPACE.
   SET PARAMETER ID 'ZTIBLNUM' FIELD SPACE.
   SET PARAMETER ID 'BES'      FIELD SPACE.

   CALL TRANSACTION 'ZTIT433' AND SKIP FIRST SCREEN.

 ENDFORM.                    " display_cr_document

*&---------------------------------------------------------------------*
*&      Form  display_gr_document
*&---------------------------------------------------------------------*
*       입고 문서 조회.
*----------------------------------------------------------------------*
 FORM DISPLAY_GR_DOCUMENT      USING    P_IGRNO.

   CHECK NOT P_IGRNO IS INITIAL.

   SET PARAMETER ID 'ZTIIGRNO' FIELD P_IGRNO.
   SET PARAMETER ID 'ZTIICCNO' FIELD SPACE.
   SET PARAMETER ID 'ZTIIBLNO' FIELD SPACE.
   SET PARAMETER ID 'ZTIBLNUM' FIELD SPACE.
   SET PARAMETER ID 'ZTIREQNO' FIELD SPACE.
   SET PARAMETER ID 'ZTIAMDSQ' FIELD SPACE.
   SET PARAMETER ID 'BES'      FIELD SPACE.

   CALL TRANSACTION 'ZTIT503' AND SKIP FIRST SCREEN.

 ENDFORM.                    " display_gr_document
*&---------------------------------------------------------------------*
*       Notice 문서 조회.
*----------------------------------------------------------------------*
 FORM DISPLAY_PN_DOCUMENT      USING    P_PNTNO.

   CHECK NOT P_PNTNO IS INITIAL.

   SET PARAMETER ID 'ZTIPNTNO' FIELD P_PNTNO.
   SET PARAMETER ID 'ZTIICCNO' FIELD SPACE.
   SET PARAMETER ID 'ZTIIBLNO' FIELD SPACE.
   SET PARAMETER ID 'ZTIBLNUM' FIELD SPACE.
   SET PARAMETER ID 'ZTIREQNO' FIELD SPACE.
   SET PARAMETER ID 'ZTIAMDSQ' FIELD SPACE.
   SET PARAMETER ID 'BES'      FIELD SPACE.

   CALL TRANSACTION 'ZTIT803' AND SKIP FIRST SCREEN.

 ENDFORM.                    " display_pn_document

*&---------------------------------------------------------------------*
*       인수증 문서 조회.
*----------------------------------------------------------------------*
 FORM DISPLAY_AC_DOCUMENT      USING    P_ACDNO.

   CHECK NOT P_ACDNO IS INITIAL.

   SET PARAMETER ID 'ZTIACDNO' FIELD P_ACDNO.
   SET PARAMETER ID 'ZTIACCNO' FIELD SPACE.
   SET PARAMETER ID 'ZTIOPNNO' FIELD SPACE.

   CALL TRANSACTION 'ZTIT723' AND SKIP FIRST SCREEN.

 ENDFORM.                    " display_ac_document
*&---------------------------------------------------------------------*
*&      Form  display_va_document
*&---------------------------------------------------------------------*
*       세금계산서 문서 조회.
*----------------------------------------------------------------------*
 FORM DISPLAY_VA_DOCUMENT      USING    P_VATNO.

   CHECK NOT P_VATNO IS INITIAL.

   SET PARAMETER ID 'ZTIVATNO' FIELD P_VATNO.

   CALL TRANSACTION 'ZTIT703' AND SKIP FIRST SCREEN.

 ENDFORM.                    " display_vA_document

*&---------------------------------------------------------------------*
*&      Form  display_cs_document
*&---------------------------------------------------------------------*
*       비용 문서 조회.
*----------------------------------------------------------------------*
 FORM DISPLAY_CS_DOCUMENT      USING    P_ICSNO
                                        P_BUKRS.

   CHECK NOT P_ICSNO IS INITIAL.

   SET PARAMETER ID 'ZTIICSNO' FIELD P_ICSNO.
   SET PARAMETER ID 'BUK'      FIELD P_BUKRS.

   CALL TRANSACTION 'ZTIT903' AND SKIP FIRST SCREEN.

 ENDFORM.                    " display_cs_document

*&---------------------------------------------------------------------*
*&      Form  display_loan_master
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
 FORM DISPLAY_LOAN_MASTER  USING    P_XRANL
                                    P_BUKRS.

   DATA: LS_ZTITIG38 LIKE ZTITIG38.

   CHECK NOT  P_XRANL IS INITIAL.

   SELECT SINGLE *
     INTO LS_ZTITIG38
     FROM ZTITIG38
    WHERE BUKRS EQ P_BUKRS.

   IF SY-SUBRC EQ 0.
     IF LS_ZTITIG38-USDTC EQ C_CHARM.
       SET PARAMETER ID 'FAN' FIELD P_XRANL.
       SET PARAMETER ID 'BUK' FIELD P_BUKRS.
       CALL TRANSACTION 'TM03' AND SKIP FIRST SCREEN.
     ELSEIF LS_ZTITIG38-USDTC EQ C_CHARL.
       SET PARAMETER ID 'RAD' FIELD P_XRANL.
       SET PARAMETER ID 'BUK' FIELD P_BUKRS.
       CALL TRANSACTION 'FN3V' AND SKIP FIRST SCREEN.
     ENDIF.
   ENDIF.

 ENDFORM.                    " display_loan_master

*&---------------------------------------------------------------------*
*&      Form  GET_DOCUMENT_HISTORY
*&---------------------------------------------------------------------*
*       수입 DOCUMENT 이력 데이타 조회.
*----------------------------------------------------------------------*
 FORM GET_DOCUMENT_HISTORY  TABLES   PT_DOCHIS STRUCTURE ZTISDOCHIS
                            USING    P_DOCTY
                                     P_DOCNO
                                     P_AMDNO
                                     P_DATA.
   DATA: L_DOCNO TYPE  ZTIREQNO,
         L_DOCTY TYPE  ZTIREQTY,
         L_AMDNO TYPE  ZTIAMDSQ.

   REFRESH: PT_DOCHIS.
   CLEAR : G_TREE_HANDLE.

   MOVE : P_DOCTY    TO    L_DOCTY,
          P_DOCNO    TO    L_DOCNO,
          P_AMDNO    TO    L_AMDNO.

   CALL FUNCTION 'Z_TI_DOCUMENT_HISTORY_BY_TYPE'
     EXPORTING
       XDOCNO  = L_DOCNO
       XAMDNO  = L_AMDNO
       XDOCTY  = L_DOCTY
     IMPORTING
       XDATA   = P_DATA
     TABLES
       XDOCHIS = PT_DOCHIS.

*   CASE G_DOCUMENT.
*     WHEN C_LC.
*     WHEN C_BL.
*     WHEN C_CC.
*     WHEN C_GR.
*   ENDCASE.
*
 ENDFORM.                    " GET_DOCUMENT_HISTORY
*&---------------------------------------------------------------------*
*&      Form  get_invoice_by_iv_number
*&---------------------------------------------------------------------*
*       Invoice number로 송장관리번호를 Get
*----------------------------------------------------------------------*
*      -->P_IVONO       송장관리번호.
*      -->P_IVNUM       Invoice Number
*      -->P_CLEAR_MODE  파라메타 초기화 모드.
*----------------------------------------------------------------------*
 FORM GET_INVOICE_BY_IV_NUMBER  USING    P_IVONO
                                         P_IVNUM
                                         P_CLEAR_MODE.
   IF P_CLEAR_MODE EQ C_TRUE.
     CLEAR : P_IVONO.
   ENDIF.

   IF NOT P_IVNUM IS INITIAL.
     CLEAR: G_COUNT.
     SELECT  IVONO
       INTO  ZTIVIV00-IVONO
       FROM  ZTIVIV00
      WHERE  IVNUM EQ P_IVNUM
      GROUP BY IVONO.

       ADD 1 TO G_COUNT.
     ENDSELECT.

     CASE G_COUNT.
       WHEN  0.
         MESSAGE E320 WITH P_IVNUM.
       WHEN  1.
         MOVE: ZTIVIV00-IVONO TO P_IVONO.
         EXIT.
       WHEN OTHERS.
         CALL FUNCTION 'Z_TI_POPUP_TO_IVONO_BY_IVNUM'
           EXPORTING
             XIVNUM    = P_IVNUM
           IMPORTING
             XIVONO    = P_IVONO
           EXCEPTIONS
             NOT_FOUND = 1
             OTHERS    = 2.

         IF SY-SUBRC <> 0.
           MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
                   WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
         ENDIF.
     ENDCASE.
   ENDIF.

 ENDFORM.                    " get_invoice_by_iv_number

*&---------------------------------------------------------------------*
*&      Form  get_invoice_by_bl_number
*&---------------------------------------------------------------------*
*       B/L number로 송장관리번호를 Get
*----------------------------------------------------------------------*
*      -->P_IVONO       송장관리번호.
*      -->P_BLNUM       B/L Number
*      -->P_CLEAR_MODE  파라메타 초기화 모드.
*----------------------------------------------------------------------*
 FORM GET_INVOICE_BY_BL_NUMBER  USING    P_IVONO
                                         P_BLNUM
                                         P_CLEAR_MODE.
   IF P_CLEAR_MODE EQ C_TRUE.
     CLEAR : P_IVONO.
   ENDIF.

   IF NOT P_BLNUM IS INITIAL.
     CLEAR: G_COUNT.
     SELECT  IVONO
       INTO  ZTIVIV00-IVONO
       FROM  ZTIVIV02
      WHERE  BLNUM EQ P_BLNUM
      GROUP BY IVONO.

       ADD 1 TO G_COUNT.
     ENDSELECT.

     CASE G_COUNT.
       WHEN  0.
         MESSAGE E319 WITH P_BLNUM.
       WHEN  1.
         MOVE: ZTIVIV00-IVONO TO P_IVONO.
         EXIT.
       WHEN OTHERS.
         CALL FUNCTION 'Z_TI_POPUP_TO_IVONO_BY_BLNUM'
           EXPORTING
             XBLNUM    = P_BLNUM
           IMPORTING
             XIVONO    = P_IVONO
           EXCEPTIONS
             NOT_FOUND = 1
             OTHERS    = 2.

         IF SY-SUBRC <> 0.
           MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
                   WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
         ENDIF.
     ENDCASE.
   ENDIF.

 ENDFORM.                    " get_invoice_by_bl_number
*&---------------------------------------------------------------------*
*&      Form  get_invoice_by_bl_int_no
*&---------------------------------------------------------------------*
*       B/L 관리번호로 송장관리번호를 Get
*----------------------------------------------------------------------*
*      -->P_IVONO       송장관리번호.
*      -->P_IBLNO       B/L 관리번호.
*      -->P_CLEAR_MODE  파라메타 초기화 모드.
*----------------------------------------------------------------------*
 FORM GET_INVOICE_BY_BL_INT_NO  USING    P_IVONO
                                         P_IBLNO
                                         P_CLEAR_MODE.
   IF P_CLEAR_MODE EQ C_TRUE.
     CLEAR : P_IVONO.
   ENDIF.

   IF NOT P_IBLNO IS INITIAL.
     CLEAR: G_COUNT.
     SELECT  IVONO
       INTO  ZTIVIV00-IVONO
       FROM  ZTIVIV02
      WHERE  IBLNO EQ P_IBLNO
      GROUP BY IVONO.

       ADD 1 TO G_COUNT.
     ENDSELECT.

     CASE G_COUNT.
       WHEN  0.
         MESSAGE E318 WITH P_IBLNO.
       WHEN  1.
         MOVE: ZTIVIV00-IVONO TO P_IVONO.
         EXIT.
       WHEN OTHERS.
         CALL FUNCTION 'Z_TI_POPUP_TO_IVONO_BY_IBLNO'
           EXPORTING
             XIBLNO    = P_IBLNO
           IMPORTING
             XIVONO    = P_IVONO
           EXCEPTIONS
             NOT_FOUND = 1
             OTHERS    = 2.

         IF SY-SUBRC <> 0.
           MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
                   WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
         ENDIF.
     ENDCASE.
   ENDIF.

 ENDFORM.                    " get_invoice_by_bl_int_no
*&---------------------------------------------------------------------*
*&      Form  check_program_exit_command
*&---------------------------------------------------------------------*
 FORM CHECK_PROGRAM_EXIT_COMMAND .

   CASE OK_CODE.
     WHEN 'ZTIBACK' OR 'ZTIEXIT' OR 'ZTICANCEL'.
       PERFORM  CALL_OTHERS_TRANSACTION  USING   C_CHARX
                                                 SY-TCODE
                                                 C_TRUE
                                                 C_TRUE.
     WHEN 'ZTICREATE'.
       LEAVE TO TRANSACTION C_CREATE.
     WHEN 'ZTICHANGE'.
       LEAVE TO TRANSACTION C_CHANGE.
     WHEN 'ZTIDISPLAY'.
       LEAVE TO TRANSACTION C_DISPLAY.
   ENDCASE.

 ENDFORM.                    " check_program_exit_command
*&---------------------------------------------------------------------*
*&      Form  GET_COMPANY_CODE
*&---------------------------------------------------------------------*
*       Get 회사코드 관련 데이타.
*----------------------------------------------------------------------*
 FORM GET_COMPANY_CODE  USING    P_BUKRS.

   CALL FUNCTION 'COMPANY_CODE_READ'
     EXPORTING
       I_BUKRS = P_BUKRS
     IMPORTING
       E_T001  = T001
       E_T004  = T004
       E_T005  = T005
       E_T014  = T014
       E_T043  = T043
       E_T043T = T043T.

   CALL FUNCTION 'FI_CURRENCY_INFORMATION'
     EXPORTING
       I_BUKRS = T001-BUKRS
       I_LAND1 = T001-LAND1
       I_RCOMP = T001-RCOMP
     IMPORTING
       E_X001  = X001.

*------- Externe Buchungskreise ablehnen -------------------------------
   IF T001-XEXTB NE SPACE.
     MESSAGE E571(F5).
   ENDIF.

   IF T043T-BUKRS = SPACE.
     MESSAGE W103(F5) WITH P_BUKRS.
   ENDIF.

*  AUTHORITY-CHECK OBJECT F_BKPF_BUK
*    ID 'ACTVT' FIELD ACT_HINZ
*    ID 'BUKRS' FIELD BKPF-BUKRS.
*  IF SY-SUBRC NE 0.
*    MESSAGE E083(F5) WITH BKPF-BUKRS.
*  ENDIF.

*-------Get 세금키  --------------------------------------
   IF T001-BUKRS = SPACE.
     CALL FUNCTION 'FIND_TAX_SPREADSHEET'
       EXPORTING
         BUCHUNGSKREIS = T001-BUKRS
       IMPORTING
         SCHEMA        = T005-KALSM
       EXCEPTIONS
         NOT_FOUND     = 04.

     IF SY-SUBRC NE 0.
       MESSAGE E470(F5) WITH T001-BUKRS.
     ENDIF.
     CLEAR TTXD.
     SELECT SINGLE * FROM TTXD WHERE KALSM = T005-KALSM.
     T007A-KALSM = T005-KALSM.
*  ELSE.
*    T005-KALSM = T007A-KALSM.
   ENDIF.

   SET PARAMETER ID 'BUK' FIELD P_BUKRS.

 ENDFORM.                    " GET_COMPANY_CODE
*&---------------------------------------------------------------------*
*&      Form  PERIODE_DETERMINE
*&---------------------------------------------------------------------*
*       전기기간 결정.
*----------------------------------------------------------------------*
 FORM PERIODE_DETERMINE   USING I_BUKRS LIKE BKPF-BUKRS
                                I_BUDAT LIKE BKPF-BUDAT
                                E_GJAHR LIKE BKPF-GJAHR
                                E_MONAT LIKE BKPF-MONAT.

   CALL FUNCTION 'FI_PERIOD_DETERMINE'
     EXPORTING
       I_BUKRS = I_BUKRS
       I_BUDAT = I_BUDAT
       I_MONAT = E_MONAT
       I_GJAHR = E_GJAHR
     IMPORTING
       E_GJAHR = E_GJAHR
       E_MONAT = E_MONAT.

 ENDFORM.                    " PERIODE_DETERMINE

*&---------------------------------------------------------------------*
*&      Form  SET_WRITE_NO_MASK
*&---------------------------------------------------------------------*
 FORM SET_WRITE_NO_MASK CHANGING P_TEXT_AMOUNT.

   TABLES : USR01.

   SELECT SINGLE * FROM USR01 WHERE BNAME EQ SY-UNAME.

   CASE USR01-DCPFM.
     WHEN 'X'.    " Decimal point is period: N,NNN.NN
       PERFORM    SET_CHANGE_SYMBOL    USING P_TEXT_AMOUNT ',' ' '.
       CONDENSE         P_TEXT_AMOUNT    NO-GAPS.
     WHEN 'Y'.    " Decimal point is N NNN NNN,NN
       PERFORM    SET_CHANGE_SYMBOL    USING P_TEXT_AMOUNT  ',' '.'.
       CONDENSE         P_TEXT_AMOUNT    NO-GAPS.
     WHEN OTHERS. " Decimal point is comma: N.NNN,NN
       PERFORM    SET_CHANGE_SYMBOL    USING P_TEXT_AMOUNT  '.' ' '.
       PERFORM    SET_CHANGE_SYMBOL    USING P_TEXT_AMOUNT  ',' '.'.
       CONDENSE         P_TEXT_AMOUNT    NO-GAPS.
   ENDCASE.

 ENDFORM.                    " SET_WRITE_NO_MASK

*&---------------------------------------------------------------------*
*&      Form  SET_CHANGE_SYMBOL
*&---------------------------------------------------------------------*
 FORM SET_CHANGE_SYMBOL USING    P_AMOUNT  P_FROM  P_TO.

   DO.
     REPLACE  P_FROM   WITH   P_TO  INTO    P_AMOUNT.
     IF  SY-SUBRC  <>    0.
       EXIT.
     ENDIF.
   ENDDO.

 ENDFORM.                    " SET_CHANGE_SYMBOL
*&---------------------------------------------------------------------*
*&      Form  get_cost_document
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
 FORM GET_COST_DOCUMENT      TABLES   PT_COST STRUCTURE ZTISCOSTDOC
                             USING    P_DOCTY
                                      P_BUKRS
                                      P_DOCNO
                                      P_AMDNO
                                      P_DATA.

   DATA: L_DOCNO TYPE  ZTIREQNO,
         L_AMDNO TYPE  ZTIAMDSQ,
         L_DOCTY TYPE  ZTIREQTY,
         L_BUKRS TYPE  BUKRS.

   MOVE: P_BUKRS   TO  L_BUKRS,
         P_DOCNO   TO  L_DOCNO,
         P_AMDNO   TO  L_AMDNO,
         P_DOCTY   TO  L_DOCTY.

   REFRESH: PT_COST.

   CALL FUNCTION 'Z_TI_COST_DOCUMENTS_BY_DOCTYPE'
     EXPORTING
       XBUKRS = L_BUKRS
       XDOCNO = L_DOCNO
       XAMDNO = L_AMDNO
       XDOCTY = L_DOCTY
     IMPORTING
       XDATA  = P_DATA
     TABLES
       XCOST  = PT_COST.

 ENDFORM.                    " get_cost_document
*&---------------------------------------------------------------------*
*&      Form  check_EDI_AVAILABLE_CHAR
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
 FORM CHECK_EDI_AVAILABLE_CHAR  USING    P_FIELDNAME  P_MSGTY.

   FIELD-SYMBOLS: <L_FIELD>.
   DATA: L_SUBRC   TYPE  SUBRC,
         L_FDPOS   TYPE  SYFDPOS,
         L_CHAR(2) TYPE  C.

   DATA: BEGIN OF FIELD,
           TABLE(15),
           STRICH,
           NAME(10),
         END OF FIELD.

   ASSIGN (P_FIELDNAME) TO <L_FIELD>.

   CALL FUNCTION 'Z_TI_CHECK_EDI_AVAILABLE_CHAR'
     EXPORTING
       IN_STRING = <L_FIELD>
     IMPORTING
       EX_SUBRC  = L_SUBRC
       EX_FDPOS  = L_FDPOS.

   G_SUBRC = L_SUBRC.

   IF L_SUBRC NE 0.
     SEARCH P_FIELDNAME FOR '-'.
     IF SY-SUBRC EQ 0.
       FIELD-TABLE  = P_FIELDNAME(SY-FDPOS).
       FIELD+15     = P_FIELDNAME+SY-FDPOS.
       PERFORM GET_FTEXT(RDDFIE00) USING    FIELD-TABLE
                                            FIELD-NAME
                                            SY-LANGU
                                   CHANGING DFIES
                                            L_SUBRC.

       CALL FUNCTION 'Z_TI_CUT_2BYTES_STRINGS'
         EXPORTING
           I_STR     = <L_FIELD>
           I_START   = L_FDPOS
           I_LEN     = 1
           I_EXCLUDE = SPACE
         IMPORTING
           O_STR     = L_CHAR.

       SET CURSOR FIELD P_FIELDNAME.
       IF L_SUBRC EQ 0.
         MESSAGE ID 'ZMTI00' TYPE P_MSGTY NUMBER 928
                             WITH DFIES-SCRTEXT_M SPACE L_CHAR.
       ELSE.
         MESSAGE ID 'ZMTI00' TYPE P_MSGTY NUMBER 928
                             WITH FIELD-TABLE FIELD-NAME L_CHAR.
       ENDIF.
     ENDIF.
   ENDIF.

 ENDFORM.                    " CHECK_EDI_AVAILABLE_CHAR
*&---------------------------------------------------------------------*
*&      Form  check_mandatory_input
*&---------------------------------------------------------------------*
 FORM CHECK_MANDATORY_INPUT  USING    P_FIELDNAME  P_MSGTY.

   FIELD-SYMBOLS: <L_FIELD>.
   DATA: L_SUBRC   TYPE  SUBRC,
         L_FDPOS   TYPE  SYFDPOS,
         L_CHAR(2) TYPE  C.

   DATA: BEGIN OF FIELD,
           TABLE(15),
           STRICH,
           NAME(10),
         END OF FIELD.

   ASSIGN (P_FIELDNAME) TO <L_FIELD>.

   IF <L_FIELD> IS INITIAL.
     SEARCH P_FIELDNAME FOR '-'.
     IF SY-SUBRC EQ 0.
       FIELD-TABLE  = P_FIELDNAME(SY-FDPOS).
       FIELD+15     = P_FIELDNAME+SY-FDPOS.
       PERFORM NO_INPUT_CHECK USING FIELD-TABLE FIELD-NAME C_ERROR.
     ENDIF.
   ENDIF.

 ENDFORM.                    " check_mandatory_input
*&---------------------------------------------------------------------*
*&      Form  GET_PARENT_WBS_ELEMENT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
 FORM GET_PARENT_WBS_ELEMENT USING P_PS_PSP_PNR LIKE EKKN-PS_PSP_PNR
                                   P_PROJ       LIKE PROJ.

   DATA: L_PSPNR  LIKE PROJ-PSPNR.

   CLEAR: P_PROJ.

   CHECK  NOT P_PS_PSP_PNR IS INITIAL.

   SELECT SINGLE *
     INTO P_PROJ
     FROM PROJ
    WHERE PSPNR EQ ( SELECT PSPHI
                       FROM PRPS
                      WHERE PSPNR EQ P_PS_PSP_PNR ).
   IF SY-SUBRC EQ 0.
     EXIT.
   ENDIF.

   SELECT SINGLE *
     INTO P_PROJ
     FROM PROJ
    WHERE PSPNR EQ P_PS_PSP_PNR.

   IF SY-SUBRC EQ 0.
     EXIT.
   ENDIF.

 ENDFORM.                    " GET_PARENT_WBS_ELEMENT
*&---------------------------------------------------------------------*
*&      Form  get_wbs_element_by_network
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
 FORM GET_WBS_ELEMENT_BY_NETWORK  USING    P_NPLNR LIKE EKKN-NPLNR
                                           P_PROJ  LIKE PROJ.

   DATA: L_PSPNR  LIKE  EKKN-PS_PSP_PNR,
         L_PSPNR1 LIKE  AFPO-PROJN.

   CLEAR: P_PROJ.

   CHECK: NOT P_NPLNR IS INITIAL.

   SELECT SINGLE PSPEL
     INTO L_PSPNR
     FROM AUFK
    WHERE AUFNR  EQ  P_NPLNR.

   IF SY-SUBRC NE 0.
     EXIT.
   ENDIF.

   IF L_PSPNR IS INITIAL.
     SELECT  SINGLE  PROJN
       INTO  L_PSPNR
       FROM  AFPO
      WHERE  AUFNR  =  P_NPLNR
        AND  POSNR  =  '0001'.
   ENDIF.

   PERFORM GET_PARENT_WBS_ELEMENT USING L_PSPNR
                                        P_PROJ.

 ENDFORM.                    " get_wbs_element_by_network
*&---------------------------------------------------------------------*
*&      Form  set_return_mandatory
*&---------------------------------------------------------------------*
 FORM SET_RETURN_MANDATORY  USING    P_FIELDNAME  P_ERROR.

   FIELD-SYMBOLS: <L_FIELD>.
   DATA: L_SUBRC   TYPE  SUBRC,
         L_FDPOS   TYPE  SYFDPOS,
         L_CHAR(2) TYPE  C.

   DATA: BEGIN OF FIELD,
           TABLE(15),
           STRICH,
           NAME(10),
         END OF FIELD.

   ASSIGN (P_FIELDNAME) TO <L_FIELD>.

   IF <L_FIELD> IS INITIAL.
     SEARCH P_FIELDNAME FOR '-'.
     IF SY-SUBRC EQ 0.
       FIELD-TABLE  = P_FIELDNAME(SY-FDPOS).
       FIELD+15     = P_FIELDNAME+SY-FDPOS.
       PERFORM SET_RETURN_MESSAGE USING FIELD-TABLE FIELD-NAME P_ERROR.
     ENDIF.
   ENDIF.
 ENDFORM.                    " set_return_mandatory
*&---------------------------------------------------------------------*
*&      Form  check_business_area
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
 FORM CHECK_BUSINESS_AREA  USING    P_GSBER.

   CASE P_GSBER.
     WHEN C_GSBER1 OR C_GSBER2.
     WHEN OTHERS.
       MESSAGE E876 WITH P_GSBER.
   ENDCASE.

 ENDFORM.                    " check_business_area
*&---------------------------------------------------------------------*
*&      Form  display_fb03_document
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_IT_TAB_BELNR  text
*----------------------------------------------------------------------*
 FORM DISPLAY_FB03_DOCUMENT  USING    P_BELNR.

   CHECK NOT P_BELNR IS INITIAL.

   SET PARAMETER ID 'BLN' FIELD P_BELNR.
*   SET PARAMETER ID 'ZTIAMDSQ' FIELD p_amdsq.
*   SET PARAMETER ID 'ZTIREQIT' FIELD p_reqit.
*   SET PARAMETER ID 'BES'      FIELD space.
*   SET PARAMETER ID 'ZTIOPNNO' FIELD space.

   CALL TRANSACTION 'FB03' AND SKIP FIRST SCREEN.


 ENDFORM.                    " display_fb03_document
*&---------------------------------------------------------------------*
*&      Form  create_editor
*&---------------------------------------------------------------------*
 FORM CREATE_EDITOR  USING    P_TE_EDIT TYPE REF TO CL_GUI_TEXTEDIT
                              P_TE_CONT
                              TYPE REF TO CL_GUI_CUSTOM_CONTAINER
                              P_CONTROL.

*  prog  = SY-REPID.

*   create control container
   IF P_TE_CONT IS INITIAL.
     CREATE OBJECT P_TE_CONT
       EXPORTING
         CONTAINER_NAME              = P_CONTROL "P_CTNAME "'CCBEF'
       EXCEPTIONS
         CNTL_ERROR                  = 1
         CNTL_SYSTEM_ERROR           = 2
         CREATE_ERROR                = 3
         LIFETIME_ERROR              = 4
         LIFETIME_DYNPRO_DYNPRO_LINK = 5.
     IF SY-SUBRC NE 0.
*      add your handling
     ENDIF.
   ENDIF.

*   create calls constructor, which initializes, creats and links
*    a TextEdit Control
   IF P_TE_EDIT IS INITIAL.
     CREATE OBJECT P_TE_EDIT
       EXPORTING
         PARENT                     = P_TE_CONT
         WORDWRAP_MODE              = CL_GUI_TEXTEDIT=>WORDWRAP_AT_FIXED_POSITION
         WORDWRAP_TO_LINEBREAK_MODE = CL_GUI_TEXTEDIT=>TRUE
       EXCEPTIONS
         OTHERS                     = 1.
     IF SY-SUBRC NE 0.
*      CALL FUNCTION 'POPUP_TO_INFORM'
*           EXPORTING
*                TITEL = prog
*                TXT2  = SPACE
*                TXT1  = TEXT-001.
     ENDIF.
   ENDIF.                               " Editor is initial

* finally flush
   CALL METHOD CL_GUI_CFW=>FLUSH
     EXCEPTIONS
       OTHERS = 1.
   IF SY-SUBRC NE 0.
*    CALL FUNCTION 'POPUP_TO_INFORM'
*         EXPORTING
*              TITEL = prog
*              TXT2  = SPACE
*              TXT1  = TEXT-001.
   ENDIF.






 ENDFORM.                    " create_editor
*&---------------------------------------------------------------------*
*&      Form  upload_editor
*&---------------------------------------------------------------------*
 FORM UPLOAD_EDITOR .

 ENDFORM.                    " upload_editor
*&---------------------------------------------------------------------*
*&      Form  BUILD_FACTORIES_CLASS
*&---------------------------------------------------------------------*
*       Factories produce
*----------------------------------------------------------------------*
 FORM BUILD_FACTORIES_CLASS .

   CALL FUNCTION 'MEVIEWS_GET_FACTORY'
     IMPORTING
       EX_VIEW_FACTORY = G_FACTORY.

 ENDFORM.                    " BUILD_FACTORIES_CLASS
*&---------------------------------------------------------------------*
*&      Form  BUILD_VIEWS_FRAMEWORK
*&---------------------------------------------------------------------*
*       View Framework develop
*----------------------------------------------------------------------*
 FORM BUILD_VIEWS_FRAMEWORK .

   CREATE OBJECT G_DEFAULT_VIEW
     EXPORTING
       IM_DYNPRO       = C_SCR2000
       IM_PROG         = SY-REPID
       IM_MAX_SUBVIEWS = 1
       IM_PFSTATUS     = 'NORMAL'.

   CALL METHOD G_DEFAULT_VIEW->SET_NAME( 'Default' ).

*>
   CREATE OBJECT G_DOCUMENT_VIEW
     EXPORTING
       IM_DYNPRO       = C_SCR2100
       IM_PROG         = SY-REPID
       IM_MAX_SUBVIEWS = 5.

   CALL METHOD G_DOCUMENT_VIEW->SET_NAME( 'Document' ).


   CREATE OBJECT G_ITEM_VIEW.

*   CREATE OBJECT g_document_commands.
*   CREATE OBJECT g_cmd_proc.
*   CALL METHOD g_cmd_proc->add( g_document_commands ).
*
*   CREATE OBJECT g_contoller
*          EXPORTING im_commands = g_cmd_proc
*                    im_model    = g_document_view.
*
*   CALL METHOD g_document_view->set_controller( g_contoller ).


   CALL METHOD G_DEFAULT_VIEW->ADD
     EXPORTING
       IM_SCREEN_VIEW = G_DOCUMENT_VIEW.
*
 ENDFORM.                    " BUILD_VIEWS_FRAMEWORK
*&---------------------------------------------------------------------*
*&      Form  BUILD_USER_SETTING_STRUCTURE
*&---------------------------------------------------------------------*
*       User Settings structure develop
*----------------------------------------------------------------------*
 FORM BUILD_USER_SETTING_STRUCTURE .

   CREATE OBJECT G_ESDUS_STREAM
     EXPORTING
       IM_ACTION_ID = C_ACTION.

   CREATE OBJECT G_MEMORY_STREAM
     EXPORTING
       IM_ACTION_ID = C_ACTION
       IM_MEMORY_ID = 'DATABLADE'.

   CREATE OBJECT: G_PERSONALIZATION,
                  G_PERSONALIZATION_WORK_SPPLY.

* the current personalization version is 1.1.0
   G_PERSONALIZATION->MY_NAME = 'Version'.
   G_PERSONALIZATION->MY_VALUE = '1.1.0'.
*
   CALL METHOD G_PERSONALIZATION->APPEND(
       IM_NAME   = 'Work_Supply'
       IM_OBJECT = G_PERSONALIZATION_WORK_SPPLY ).

* Initialisierung Message Handler ----------------------------------*

   CALL METHOD CL_MESSAGE_HANDLER_MM=>GET_HANDLER
     IMPORTING
       EX_HANDLER = G_MESSAGE_HANDLER.

   CALL METHOD G_MESSAGE_HANDLER->SET_CONFIG_FOR_MEPO( ).

 ENDFORM.                    " BUILD_USER_SETTING_STRUCTURE
*&---------------------------------------------------------------------*
*&      Form  build_tree_container
*&---------------------------------------------------------------------*
*       Tree ALV develop
*----------------------------------------------------------------------*
 FORM BUILD_TREE_CONTAINER .

*> create docking als container
   IF G_DOCKING IS INITIAL.
     CREATE OBJECT G_DOCKING
       EXPORTING
         REPID     = G_REPID
         DYNNR     = C_SCR2000
         SIDE      = G_DOCKING->DOCK_AT_LEFT
         EXTENSION = 210.
   ENDIF.
*> Make query view
   G_ALV_TREE  ?= G_FACTORY->MAKE_QUERY_VIEW(
                 IM_DATABLADE_FACTORY = G_DATABLADE
                 IM_USER_SETTINGS     = G_PERSONALIZATION_WORK_SPPLY
                 IM_CONTAINER         = G_DOCKING
                 IM_PROG              = SY-REPID    ).

   IF NOT G_ALV_TREE IS INITIAL.
     CALL METHOD G_DEFAULT_VIEW->ADD
       EXPORTING
         IM_SCREEN_VIEW = G_ALV_TREE.
   ENDIF.

   IF NOT G_ALV_TREE IS INITIAL.
     SET HANDLER G_DOCUMENT_VIEW->HANDLE_TREE FOR G_ALV_TREE.
   ENDIF.

   CALL METHOD G_ESDUS_STREAM->IF_READER_MM~READ_ROOT(
     G_PERSONALIZATION ).
*
 ENDFORM.                    " build_tree_container
*&---------------------------------------------------------------------*
*&      Form  set_user_setting_structure
*&---------------------------------------------------------------------*
*       Save User setting infomation
*----------------------------------------------------------------------*
 FORM SET_USER_SETTING_STRUCTURE .

   CALL METHOD G_ESDUS_STREAM->IF_WRITER_MM~WRITE_ROOT(
     G_PERSONALIZATION ).

   CALL METHOD G_ESDUS_STREAM->SAVE.

 ENDFORM.                    " set_user_setting_structure
*&---------------------------------------------------------------------*
*&      Form  build_shopping_carts_screen
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
 FORM BUILD_SHOPPING_CARTS_SCREEN
                USING    IM_TREE               TYPE MMPUR_SCREEN_VIEW
                         IM_VIEW_FACTORY       TYPE MMPUR_VIEW_FACTORY.

   DATA: L_TEXT   TYPE ITEX132,
         DDCNT    TYPE REF TO CL_DRAG_DROP_CONTROLLER_MM,
         ALV_TREE TYPE REF TO CL_TABLE_MODEL_TREE_VIEW_MM,
         FW       TYPE REF TO CL_FRAMEWORK_MM,
         L_DYNP   TYPE SY-DYNNR.

   MMPUR_DYNAMIC_CAST ALV_TREE IM_TREE.
   CHECK NOT ALV_TREE IS INITIAL.
*
   CALL METHOD CL_FRAMEWORK_MM=>GET_INSTANCE
     IMPORTING
       EX_INSTANCE = FW.
*
*> Shopping-Basket Image-Control-View
   CREATE OBJECT G_SHOPPING_BASKET
     EXPORTING
       IM_DYNPRO         = C_SCR2110
       IM_PROG           = SY-REPID
       IM_CONTAINER_NAME = 'CONTROL'.

   L_TEXT = 'Shopping Cart'(H12).
   CALL METHOD G_SHOPPING_BASKET->SET_NAME(
     'Shopping-Basket #1' ).
   CALL METHOD G_SHOPPING_BASKET->SET_LABEL( L_TEXT(40) ).

   CALL METHOD G_SHOPPING_BASKET->SET_STRUCT_NAME(
       IM_STRUCT_NAME = 'MEPO1211'
       IM_APPLICATION = 'MMPUR_PO_VIEWS' ).

   IF G_MODE EQ C_CHARC OR G_MODE EQ C_CHARM.
     CALL METHOD G_SHOPPING_BASKET->ACCEPT_FLAVOR( MMPUR_FLAVOR_PDOCS ).
     CALL METHOD G_SHOPPING_BASKET->ACCEPT_FLAVOR( MMPUR_FLAVOR_REQ ).
     CALL METHOD G_SHOPPING_BASKET->ACCEPT_FLAVOR( '0005' ).
   ENDIF.

   DDCNT = G_SHOPPING_BASKET->GET_DRAGDROP_CONTROLLER( ).

   CREATE OBJECT G_COMPOSITE_VIEW
     EXPORTING
       IM_DYNPRO       = '0000'
       IM_PROG         = G_REPID
       IM_MAX_SUBVIEWS = 1.
   CALL METHOD G_COMPOSITE_VIEW->ADD
     EXPORTING
       IM_SCREEN_VIEW = G_SHOPPING_BASKET
       IM_POSITION    = 1.

   G_CLASS_VIEW-VIEW ?= G_COMPOSITE_VIEW.

 ENDFORM.                    " build_shopping_carts_screen
*&---------------------------------------------------------------------*
*&      Form  alv_tree_dispatcher
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
 FORM ALV_TREE_DISPATCHER .

* nesseccary for the control
   DATA: L_FCODE TYPE SY-UCOMM.
   DATA: FW TYPE REF TO CL_FRAMEWORK_MM.

   CALL METHOD CL_GUI_CFW=>DISPATCH.
   CALL METHOD CL_GUI_CFW=>FLUSH.

   CALL METHOD CL_FRAMEWORK_MM=>GET_INSTANCE
     IMPORTING
       EX_INSTANCE = FW.

   CALL METHOD FW->GET_FCODE
     IMPORTING
       EX_FCODE = L_FCODE.

   IF NOT L_FCODE IS INITIAL.
     IF L_FCODE EQ 'METRON' AND
        NOT G_DOCKING IS INITIAL.
       CALL METHOD G_DOCKING->SET_VISIBLE
         EXPORTING
           VISIBLE           = '1'
         EXCEPTIONS
           CNTL_SYSTEM_ERROR = 1
           CNTL_ERROR        = 2.
     ENDIF.

* give the controller a chance
     CALL METHOD G_ALV_TREE->EXECUTE( CHANGING IM_FCODE = L_FCODE ).

*     CLEAR: l_fcode.
*     CALL METHOD fw->set_fcode
*       EXPORTING
*         im_fcode = l_fcode.
*
* leave on the screen
     SET SCREEN SY-DYNNR.
   ENDIF.

 ENDFORM.                    " alv_tree_dispatcher
*&---------------------------------------------------------------------*
*&      Form  build_application
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
 FORM BUILD_APPLICATION .

* the application
   CREATE OBJECT G_APPLICATION
     EXPORTING
       IM_DOCUMENT_VIEW = G_DOCUMENT_VIEW
       IM_TREE          = G_ALV_TREE
       IM_VIEW_FACTORY  = G_FACTORY.

   CALL METHOD G_DOCUMENT_VIEW->SET_APPLICATION( G_APPLICATION ).

 ENDFORM.                    " build_application
*&---------------------------------------------------------------------*
*&      Form  build_first_plugin
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  build_first_plugin
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
 FORM BUILD_FIRST_PLUGIN  USING    P_PROCESS.

   DATA: L_PROCESS           TYPE  MEPO_PROCESS.

   L_PROCESS = P_PROCESS.

   CALL METHOD G_APPLICATION->INIT_FIRST_PLUGIN(
       IM_PROCESS = L_PROCESS ).

 ENDFORM.                    " build_first_plugin
*&---------------------------------------------------------------------*
*&      Form  build_header_screen_plugin
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
 FORM BUILD_HEADER_SCREEN_PLUGIN
                USING    IM_MODEL_HOLDER       TYPE MMPUR_SCREEN_VIEW
                         IM_TREE               TYPE MMPUR_SCREEN_VIEW
                         IM_VIEW_FACTORY       TYPE MMPUR_VIEW_FACTORY
                CHANGING EX_HEADER_VIEW        TYPE MMPUR_SCREEN_VIEW
                         EX_HEADER_TOGGLE_VIEW TYPE MMPUR_SCREEN_VIEW
                         EX_PLUGIN             TYPE MMPUR_SCREEN_VIEW.

   DATA: HEADER_VIEW        TYPE REF TO LCL_HEADER_VIEW,
         HEADER_TOGGLE_VIEW TYPE REF TO CL_TOGGLE_VIEW_MM,
         COMPOSITE          TYPE REF TO CL_COMPOSITE_SCREEN_VIEW_MM,
         L_TEXT             TYPE ITEX132,
         L_TEXT101          LIKE TEXTPOOL,
         L_TEXT111          LIKE TEXTPOOL,
         ALV_TREE           TYPE REF TO CL_TABLE_MODEL_TREE_VIEW_MM,
         LT_TEXTELEMENTS    LIKE TEXTPOOL OCCURS 0,
         L_MODEL_HOLDER     TYPE REF TO IF_MODEL_HOLDER_MM,
         L_QUICKINFO_OPEN   TYPE STRING,
         L_QUICKINFO_CLOSED TYPE STRING.

   DATA:
     PO_VIEWS           TYPE MEPO_MFS_APPLICATION
                               VALUE 'MMPUR_PO_VIEWS'.      "#EC NOTEXT

   DATA: L_PROG             TYPE SY-REPID.

   L_PROG = SY-REPID.

   MMPUR_DYNAMIC_CAST G_ALV_TREE IM_TREE.
   CHECK NOT G_ALV_TREE IS INITIAL.

***********************************************************************
* Kopfdetailbilder
***********************************************************************
   MMPUR_DYNAMIC_CAST L_MODEL_HOLDER IM_MODEL_HOLDER.
   CHECK NOT L_MODEL_HOLDER IS INITIAL.

   CREATE OBJECT HEADER_VIEW
     EXPORTING
       IM_DYNPRO       = C_SCR2120
       IM_PROG         = SY-REPID
       IM_MAX_TABS     = 30
       IM_PATTERN      = 'TABHDT%'
       IM_MODEL_HOLDER = L_MODEL_HOLDER.

*  CALL METHOD header_view->set_tabstripcontrol
*    CHANGING
*      ch_tabstripcontrol = header_detail.
**
*  l_text = '헤더'(007).
*  CALL METHOD header_view->set_name( 'HEADER-TABSTRIP' ).
*  CALL METHOD header_view->set_label( l_text(40) ).
*
   HEADER_TOGGLE_VIEW =
              IM_VIEW_FACTORY->MAKE_TOGGLE_VIEW(
                  IM_VIEW_A  = HEADER_VIEW
                  IM_POSTFIX = 0 ).

   L_QUICKINFO_OPEN = '헤더접기 Ctrl+F5'(911).
   L_QUICKINFO_CLOSED = '헤더펼치기 Ctrl+F2'(912).
*
   COMPOSITE = IM_VIEW_FACTORY->MAKE_COMPLEX_EXPAND_VIEW(
                  IM_TOGGLE_VIEW      = HEADER_TOGGLE_VIEW
                  IM_POSTFIX          = 0
                  IM_QUICKINFO_OPEN   = L_QUICKINFO_OPEN
                  IM_QUICKINFO_CLOSED = L_QUICKINFO_CLOSED
                  IM_BUTTON_FCODE_ON  = 'METOGGON1'
                  IM_BUTTON_FCODE_OFF = 'METOGGOFF1' ).

   EX_HEADER_VIEW = HEADER_VIEW.
   EX_HEADER_TOGGLE_VIEW = HEADER_TOGGLE_VIEW.
   EX_PLUGIN = COMPOSITE.

 ENDFORM.                    " build_header_screen_plugin

*&---------------------------------------------------------------------*
*&      Form  build_topline_screen_plugin
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
 FORM BUILD_TOPLINE_SCREEN_PLUGIN
                USING    IM_MODEL_HOLDER       TYPE MMPUR_SCREEN_VIEW
                         IM_TREE               TYPE MMPUR_SCREEN_VIEW
                         IM_VIEW_FACTORY       TYPE MMPUR_VIEW_FACTORY
                CHANGING "ex_topline            TYPE mmpur_screen_view
                         EX_SHOPPING_BASKET    TYPE MMPUR_SCREEN_VIEW
                         EX_PLUGIN             TYPE MMPUR_SCREEN_VIEW.

   DATA: COMPOSITE         TYPE REF TO CL_COMPOSITE_SCREEN_VIEW_MM,
         L_TEXT            TYPE ITEX132,
         L_SHOPPING_BASKET TYPE REF TO LCL_SHOPPING_BASKET,
         DDCNT             TYPE REF TO CL_DRAG_DROP_CONTROLLER_MM,
         ALV_TREE          TYPE REF TO CL_TABLE_MODEL_TREE_VIEW_MM,
         FW                TYPE REF TO CL_FRAMEWORK_MM,
         L_DYNP            TYPE SY-DYNNR.

   MMPUR_DYNAMIC_CAST G_ALV_TREE IM_TREE.
   CHECK NOT G_ALV_TREE IS INITIAL.

************************************************************************
* Kopfzeile (Belegart, Belegnummer, Lieferant/Lieferwerk, Belegdatum)  *
************************************************************************
   CALL METHOD CL_FRAMEWORK_MM=>GET_INSTANCE
     IMPORTING
       EX_INSTANCE = FW.

*> Shopping-Basket Image-Control-View
   CREATE OBJECT L_SHOPPING_BASKET
     EXPORTING
       IM_DYNPRO         = '2110'
       IM_PROG           = G_REPID
       IM_CONTAINER_NAME = 'CONTROL'.

   L_TEXT = '쇼핑카트'(H12).
   CALL METHOD L_SHOPPING_BASKET->SET_NAME(
     'Shopping-Basket #1' ).
   CALL METHOD L_SHOPPING_BASKET->SET_LABEL( L_TEXT(40) ).

   CALL METHOD L_SHOPPING_BASKET->SET_STRUCT_NAME(
       IM_STRUCT_NAME = 'MEPO1211'
       IM_APPLICATION = 'MMPUR_PO_VIEWS' ).

   CALL METHOD L_SHOPPING_BASKET->ACCEPT_FLAVOR( MMPUR_FLAVOR_PDOCS ).
   CALL METHOD L_SHOPPING_BASKET->ACCEPT_FLAVOR( MMPUR_FLAVOR_REQ ).
   CALL METHOD L_SHOPPING_BASKET->ACCEPT_FLAVOR( '0005' ).

   DDCNT = L_SHOPPING_BASKET->GET_DRAGDROP_CONTROLLER( ).

   CREATE OBJECT COMPOSITE
     EXPORTING
       IM_DYNPRO       = '2100'
       IM_PROG         = SY-REPID
       IM_MAX_SUBVIEWS = 1.

   CALL METHOD COMPOSITE->ADD
     EXPORTING
       IM_SCREEN_VIEW = L_SHOPPING_BASKET
       IM_POSITION    = 1.

*  ex_topline = topline_view.
   EX_SHOPPING_BASKET = L_SHOPPING_BASKET.
   EX_PLUGIN          = COMPOSITE.

 ENDFORM.                    " build_topline_screen_plugin
*&---------------------------------------------------------------------*
*&      Form  build_class_object
*&---------------------------------------------------------------------*
*       Create Class Object
*----------------------------------------------------------------------*
 FORM BUILD_CLASS_OBJECT .

*> 1. Factories produce
   PERFORM  BUILD_FACTORIES_CLASS.

*> 2. Produces a Datablade Factory for the access to Datablades (Query)
   PERFORM  BUILD_QUERY_FACTORIES_CLASS IN PROGRAM (G_REPID).

*> 3. View Framework develop
   PERFORM  BUILD_VIEWS_FRAMEWORK.

*> 4. User Settings structure develop
   PERFORM  BUILD_USER_SETTING_STRUCTURE.

*> 5. Tree ALV develop
   PERFORM  BUILD_TREE_CONTAINER.

*> 6. Create applications
   PERFORM  BUILD_APPLICATION.

*> 7. First plug In
   PERFORM  BUILD_FIRST_PLUGIN  USING  C_ACTION.

*> 8. Shopping Carts Screen develop
   G_TREE = G_ALV_TREE.
   PERFORM  BUILD_SHOPPING_CARTS_SCREEN USING    G_TREE
                                                 G_FACTORY.

 ENDFORM.                    " build_class_object
*&---------------------------------------------------------------------*
*&      Form  p1000_alv_fields_initial
*&---------------------------------------------------------------------*
*       Read default layout (description only, w/o field catalog)
*----------------------------------------------------------------------*
 FORM P1000_ALV_FIELDS_INITIAL .

   G_REPID = SY-REPID.

   G_VARIANT_SAVE = C_CHARA.
   CLEAR GS_VARIANTE.
   GS_VARIANTE-REPORT = G_REPID.

*>Get Default-Variante :
   GS_DEF_VARIANTE = GS_VARIANTE.
   CALL FUNCTION 'REUSE_ALV_VARIANT_DEFAULT_GET'
     EXPORTING
       I_SAVE     = G_VARIANT_SAVE
     CHANGING
       CS_VARIANT = GS_DEF_VARIANTE
     EXCEPTIONS
       NOT_FOUND  = 2.
   IF SY-SUBRC = 0.
     P_VARI = GS_DEF_VARIANTE-VARIANT.
   ENDIF.

   REFRESH IT_SORT.               CLEAR IT_SORT.
   REFRESH IT_FIELDCAT.           CLEAR IT_FIELDCAT.
   REFRESH IT_XHEADER.            CLEAR IT_XHEADER.
   REFRESH IT_COLOR.              CLEAR IT_COLOR.
   REFRESH IT_GRUPPEN.            CLEAR IT_GRUPPEN.
   REFRESH IT_EVENTS .            CLEAR IT_EVENTS.
   REFRESH IT_EVENT_EXIT .        CLEAR IT_EVENT_EXIT.
   REFRESH IT_LISTHEADER .        CLEAR IT_LISTHEADER.

* PRINT default SETTINGS
   CLEAR GS_PRINT.
   GS_PRINT-NO_PRINT_LISTINFOS = C_CHARX.
   GS_PRINT-NO_COVERPAGE       = C_CHARX.
   GS_PRINT-NO_PRINT_LISTINFOS = C_CHARX.

* Layout default SETTINGS
   GS_LAYOUT-GET_SELINFOS      = C_CHARX.
   GS_LAYOUT-GROUP_CHANGE_EDIT = C_CHARX.
   GS_LAYOUT-ZEBRA             = C_CHARX.
*
*> 1 : Heading + List 모두 VLine
*> 2 : List상의 Item Level만 Vline
*> othres : 모두 안나옴.
*   gs_layout-no_vline          = c_char1.
   GS_LAYOUT-NO_VLINE          = C_CHARX.

 ENDFORM.                    " p1000_alv_fields_initial
*&---------------------------------------------------------------------*
*&      Form  p1101_check_variant_value
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
 FORM P1101_CHECK_VARIANT_VALUE .

   IF NOT P_VARI IS INITIAL.
     MOVE GS_VARIANTE TO GS_DEF_VARIANTE.
     MOVE P_VARI TO GS_DEF_VARIANTE-VARIANT.
     CALL FUNCTION 'REUSE_ALV_VARIANT_EXISTENCE'
       EXPORTING
         I_SAVE     = G_VARIANT_SAVE
       CHANGING
         CS_VARIANT = GS_DEF_VARIANTE.
     GS_VARIANTE = GS_DEF_VARIANTE.
   ELSE.
     CLEAR GS_VARIANTE.
     GS_VARIANTE-REPORT = G_REPID.
   ENDIF.

 ENDFORM.                    " p1101_check_variant_value
*&---------------------------------------------------------------------*
*&      Form  p1102_f4_for_variant
*&---------------------------------------------------------------------*
*       Display variant selection dialog box
*----------------------------------------------------------------------*
 FORM P1102_F4_FOR_VARIANT .

   CALL FUNCTION 'REUSE_ALV_VARIANT_F4'
     EXPORTING
       IS_VARIANT = GS_VARIANTE
       I_SAVE     = G_VARIANT_SAVE
*      it_default_fieldcat =
     IMPORTING
       E_EXIT     = G_VARIANT_EXIT
       ES_VARIANT = GS_DEF_VARIANTE
     EXCEPTIONS
       NOT_FOUND  = 2.
   IF SY-SUBRC = 2.
     MESSAGE ID SY-MSGID TYPE 'S' NUMBER SY-MSGNO
             WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
   ELSE.
     IF G_VARIANT_EXIT = SPACE.
       P_VARI = GS_DEF_VARIANTE-VARIANT.
     ENDIF.
   ENDIF.

 ENDFORM.                    " p1102_f4_for_variant
*&---------------------------------------------------------------------*
*&      Form  display_INB_DELEVERY
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
 FORM DISPLAY_INB_DELEVERY  USING    P_VBELN
                                     P_POSNR.

   CHECK NOT P_VBELN IS INITIAL.


 ENDFORM.                    " display_INB_DELEVERY
*&---------------------------------------------------------------------*
*&      Form  set_change_indicator
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
 FORM SET_CHANGE_INDICATOR  USING    P_UPD.

   CASE SY-TCODE.
     WHEN C_CREATE OR C_CREATE_D.
       P_UPD             = 'I'.
     WHEN OTHERS.
       P_UPD             = 'U'.
   ENDCASE.

   IF OK_CODE_OLD EQ 'ZTIDELETE'.
     P_UPD             = 'D'.
   ENDIF.

 ENDFORM.                    " set_change_indicator
*&---------------------------------------------------------------------*
*&      Form  display_FI_document
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
 FORM DISPLAY_FI_DOCUMENT  USING    P_BELNR
                                    P_GJAHR
                                    P_BUKRS.

   CALL FUNCTION 'FI_DOCUMENT_LIST_DISPLAY'
     EXPORTING
       BUKRS                = P_BUKRS
       BELNR                = P_BELNR
       GJAHR                = P_GJAHR
*      AKTYP                = 'A'
*      XEPOS                =
*      I_NOCHANGE           =
*      XPRNT                =
*    IMPORTING
*      E_CMRQ               =
*      E_CHNG               =
     EXCEPTIONS
       DISPLAY_NOT_POSSIBLE = 1
       NO_AUTHORITY         = 2
       OTHERS               = 3.

   IF SY-SUBRC <> 0.
     MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
             WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
   ENDIF.

 ENDFORM.                    " display_FI_document
*&---------------------------------------------------------------------*
*&      Form  set_generic_object_service
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
 FORM SET_GENERIC_OBJECT_SERVICE  USING  P_OBJTYPE
                                         P_PKVALUE.

   CHECK G_MODE NE C_CHARC.

   CONCATENATE 'ZTI' P_PKVALUE  INTO G_NCR_OBKEY.  ">키값 생성.

   G_NCR_OBJTYPE  =  P_OBJTYPE.

   CALL FUNCTION 'SWU_OBJECT_PUBLISH'
     EXPORTING
       OBJTYPE = G_NCR_OBJTYPE
       OBJKEY  = G_NCR_OBKEY.   " 오브젝트 키문자열.

 ENDFORM.                    " set_generic_object_service
*&---------------------------------------------------------------------*
*&      Form  FILL_AMENDENT_FILED
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
 FORM FILL_AMENDENT_FILED  USING    P_NEW_FIELD   P_OLD_FIELD
                                    P_INDICATOER  P_REF
                                    P_TEXT.

   FIELD-SYMBOLS: <L_FIELD1>,
                  <L_FIELD2>.

   DATA: L_SUBRC   TYPE  SUBRC,
         L_FDPOS   TYPE  SYFDPOS,
         L_CHAR(2) TYPE  C,
         L_DOMNAME TYPE DOMNAME,
         L_DDTEXT  TYPE DDTEXT.

   DATA: BEGIN OF FIELD,
           TABLE(15),
           STRICH,
           NAME(10),
         END OF FIELD.

   SEARCH P_NEW_FIELD FOR '-'.
   IF SY-SUBRC EQ 0.
     FIELD-TABLE  = P_NEW_FIELD(SY-FDPOS).
     FIELD+15     = P_NEW_FIELD+SY-FDPOS.
   ENDIF.

   ASSIGN (P_NEW_FIELD) TO <L_FIELD1>.
   ASSIGN (P_OLD_FIELD) TO <L_FIELD2>.

   MOVE: FIELD-TABLE  TO IT_AMEND_FIELDS-TABNAME,
         FIELD-NAME   TO IT_AMEND_FIELDS-FIELDNAME,
         P_TEXT       TO IT_AMEND_FIELDS-SCRTEXT_M.

   IF P_INDICATOER IS INITIAL.
     MOVE: <L_FIELD1>   TO IT_AMEND_FIELDS-F_NEW,
           <L_FIELD2>   TO IT_AMEND_FIELDS-F_OLD.
     CLEAR: L_DOMNAME.
     SELECT SINGLE DOMNAME
       INTO L_DOMNAME
       FROM DD04L
      WHERE AS4LOCAL = 'A'
        AND AS4VERS  = 0
        AND ROLLNAME = ( SELECT ROLLNAME
                           FROM DD03L
                          WHERE TABNAME   EQ FIELD-TABLE
                            AND FIELDNAME EQ FIELD-NAME ).
     IF SY-SUBRC EQ 0.
       CLEAR: L_DDTEXT.
       SELECT SINGLE DDTEXT
         INTO L_DDTEXT
         FROM DD07T
        WHERE DOMNAME     EQ L_DOMNAME
          AND DDLANGUAGE  EQ SY-LANGU
          AND AS4LOCAL    EQ 'A'
          AND AS4VERS     EQ 0
          AND DOMVALUE_L  EQ IT_AMEND_FIELDS-F_NEW.
       IF SY-SUBRC EQ 0.
         IT_AMEND_FIELDS-F_NEW = L_DDTEXT.
       ENDIF.
       CLEAR: L_DDTEXT.
       SELECT SINGLE DDTEXT
         INTO L_DDTEXT
         FROM DD07T
        WHERE DOMNAME     EQ L_DOMNAME
          AND DDLANGUAGE  EQ SY-LANGU
          AND AS4LOCAL    EQ 'A'
          AND AS4VERS     EQ 0
          AND DOMVALUE_L  EQ IT_AMEND_FIELDS-F_OLD.
       IF SY-SUBRC EQ 0.
         IT_AMEND_FIELDS-F_OLD = L_DDTEXT.
       ENDIF.
     ENDIF.
   ELSE.
     IF P_INDICATOER EQ C_CHARC.
       WRITE: <L_FIELD1> TO IT_AMEND_FIELDS-F_NEW CURRENCY P_REF.
       WRITE: <L_FIELD2> TO IT_AMEND_FIELDS-F_OLD CURRENCY P_REF.
     ELSEIF P_INDICATOER EQ C_CHARQ.
       WRITE: <L_FIELD1> TO IT_AMEND_FIELDS-F_NEW UNIT     P_REF.
       WRITE: <L_FIELD2> TO IT_AMEND_FIELDS-F_OLD UNIT     P_REF.
     ELSE.
       WRITE: <L_FIELD1> TO IT_AMEND_FIELDS-F_NEW.
       WRITE: <L_FIELD2> TO IT_AMEND_FIELDS-F_OLD.
     ENDIF.

     CONDENSE IT_AMEND_FIELDS-F_NEW.
     CONDENSE IT_AMEND_FIELDS-F_OLD.
*> 단위 및 통화를 붙임.
     IF P_INDICATOER EQ C_CHARC OR
        P_INDICATOER EQ C_CHARQ.
       CONCATENATE IT_AMEND_FIELDS-F_NEW P_REF
              INTO IT_AMEND_FIELDS-F_NEW
              SEPARATED BY SPACE.
       CONCATENATE IT_AMEND_FIELDS-F_OLD P_REF
              INTO IT_AMEND_FIELDS-F_OLD
              SEPARATED BY SPACE.
     ENDIF.
   ENDIF.

   APPEND IT_AMEND_FIELDS.

 ENDFORM.                    " FILL_AMENDENT_FILED
*&---------------------------------------------------------------------*
*&      Form  READ_CUSTOMER_name
*&---------------------------------------------------------------------*
 FORM READ_CUSTOMER_NAME  USING    P_KUNNR
                          CHANGING P_NAME.

   CLEAR P_NAME.
   SELECT SINGLE NAME1
     INTO P_NAME
     FROM KNA1
    WHERE KUNNR EQ P_KUNNR.

 ENDFORM.                    " READ_CUSTOMER_name
*&---------------------------------------------------------------------*
*&      Form  display_sales_order
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
 FORM DISPLAY_SALES_ORDER  USING    P_VBELN.

   SET PARAMETER ID 'AUN' FIELD P_VBELN.
   CALL TRANSACTION 'VA03' AND SKIP FIRST SCREEN.

 ENDFORM.                    " display_sales_order
*&---------------------------------------------------------------------*
*&      Form  DISPLAY_CHANGE_DOCUMENT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
 FORM DISPLAY_CHANGE_DOCUMENT  USING  P_OBJEKT   LIKE CDHDR-OBJECTCLAS
                                      P_OBJEKTID LIKE CDHDR-OBJECTID.

   SUBMIT  RCS00120 WITH  OBJEKT   =   P_OBJEKT
                    WITH  OBJEKTID =   P_OBJEKTID
                    AND   RETURN.

 ENDFORM.                    " DISPLAY_CHANGE_DOCUMENT
*&---------------------------------------------------------------------*
*&      Form  P7000_SET_SMART_FORM_NAME
*&---------------------------------------------------------------------*
 FORM P7000_SET_SMART_FORM_NAME USING  P_DOC_TYPE
                                       P_AMEND_SEQ
                                       P_DOC_GUBUN
                                       P_SSF_NAME.
   CLEAR: P_SSF_NAME.

   CASE P_DOC_TYPE.
     WHEN C_AC.
       P_SSF_NAME = C_LOCRCT_R.
     WHEN C_LC.
       IF P_AMEND_SEQ IS INITIAL.
         IF P_DOC_GUBUN EQ '1'.
           P_SSF_NAME = C_APP700_R.
         ELSE.
*&    2010.06.10 양식새로 생성하여 영문화 작업
*                구분을 하기위해 공급업체 필드에 'EN' 삽입
           IF IT_PRTCTL-LIFNR EQ 'EN'.
             P_SSF_NAME = C_INF7002_R.
           ELSEIF ZTITRQK-BUKRS EQ '6000'.
             P_SSF_NAME = C_INF7003_R.
           ELSE.
             P_SSF_NAME = C_INF700_R.
           ENDIF.
         ENDIF.
       ELSE.
         IF P_DOC_GUBUN EQ '1'.
           P_SSF_NAME = C_APP707_R.
         ELSE.
           P_SSF_NAME = C_INF707_R.
         ENDIF.
       ENDIF.

     WHEN C_TT.
       IF P_DOC_GUBUN EQ '1'.
         P_SSF_NAME = C_PAYORD_R.
       ELSE.
*         MESSAGE e907(zmti00).
*&    2010.06.10 양식새로 생성하여 영문화 작업
*                구분을 하기위해 공급업체 필드에 'EN' 삽입
         IF IT_PRTCTL-LIFNR EQ 'EN'.
           P_SSF_NAME = C_DEBADV2_R.
         ELSE.
           P_SSF_NAME = C_DEBADV_R.
         ENDIF.
       ENDIF.

     WHEN C_PU.
       IF P_DOC_GUBUN EQ '1'.
         P_SSF_NAME = C_APPPCR_R.
       ELSE.
         P_SSF_NAME = C_PCRLIC_R.
       ENDIF.
*       p_ssf_name = c_apppcr_r.
     WHEN C_LO.
       IF P_AMEND_SEQ IS INITIAL.
         IF P_DOC_GUBUN EQ '1'.
           P_SSF_NAME = C_LOCAPP_R.
         ELSE.
           P_SSF_NAME = C_LOCADV_R.
         ENDIF.
       ELSE.
         IF P_DOC_GUBUN EQ '1'.
           P_SSF_NAME = C_LOCAMR_R.
         ELSE.
           P_SSF_NAME = C_LOCAMA_R.
         ENDIF.
       ENDIF.
*       p_ssf_name = c_payord_r.
     WHEN C_LG.
       IF P_DOC_GUBUN EQ '1'.
         P_SSF_NAME = C_APPLOG_R.
       ELSE.
         P_SSF_NAME = C_LOGUAR_R.
       ENDIF.

     WHEN C_IV.
       P_SSF_NAME = C_RELEASE_R.

     WHEN C_IP.

     WHEN OTHERS.
       MESSAGE E907(ZMTI00).
   ENDCASE.

 ENDFORM.                    " P7000_SET_SMART_FORM_NAME
*&---------------------------------------------------------------------*
*&      Form  get_and_copy_pre_doc_text
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_DOCNO           문서번호.
*      -->P_TDOBJECT_FROM   From 텍스트 오브젝트.
*      -->P_TDOBJECT_TO     To   텍스트 오브젝트.
*      -->P_INIT            초기화 여부.
*----------------------------------------------------------------------*
 FORM GET_AND_COPY_PRE_DOC_TEXT  USING    P_DOCNO
                                          P_TDOBJECT_FROM
                                          P_TDOBJECT_TO
                                          P_INIT
                                          P_LANGU.


   DATA : BEGIN OF LT_ZTSTIGT OCCURS 0.
            INCLUDE STRUCTURE ZTSTIGT.
   DATA : END   OF LT_ZTSTIGT.

   DATA L_TEXTLINES LIKE MMPUR_TEXTLINES OCCURS 0 WITH HEADER LINE.

   SELECT *
     INTO CORRESPONDING FIELDS OF TABLE LT_ZTSTIGT
     FROM ZTSTIGT
    WHERE TDOBF  EQ  P_TDOBJECT_FROM
      AND TDOBT  EQ  P_TDOBJECT_TO.

   CHECK SY-SUBRC EQ 0.

   READ TABLE GT_CONTROL WITH KEY OBJECT = P_TDOBJECT_TO.
   CHECK SY-SUBRC EQ 0.

*> Long text move
   L_TEXTLINES[] = GT_CONTROL-TEXTLINES[].

   REFRESH: G_TEXTLINES.

   LOOP AT LT_ZTSTIGT.
*> 초기화가 아닐경우.
     IF P_INIT EQ C_FALSE.
       MOVE: LT_ZTSTIGT-TDOBT   TO THEAD-TDOBJECT,
             P_DOCNO            TO THEAD-TDNAME,
             P_LANGU            TO THEAD-TDSPRAS,
             LT_ZTSTIGT-TDIDT   TO THEAD-TDID.

       LOOP AT L_TEXTLINES WHERE TDID EQ LT_ZTSTIGT-TDIDF.
         MOVE: L_TEXTLINES-TDLINE      TO G_TEXTLINES-TDLINE,
               L_TEXTLINES-TDFORMAT    TO G_TEXTLINES-TDFORMAT,
               THEAD-TDOBJECT          TO G_TEXTLINES-TDOBJECT,
               THEAD-TDID              TO G_TEXTLINES-TDID.
         APPEND G_TEXTLINES.
       ENDLOOP.
     ENDIF.
*> 선행문서 텍스트를 읽음.
     THEAD-TDID      = LT_ZTSTIGT-TDIDF.
     THEAD-TDOBJECT  = LT_ZTSTIGT-TDOBF.
     THEAD-TDNAME    = P_DOCNO.
     THEAD-TDSPRAS   = P_LANGU.

     REFRESH: IT_LINE. CLEAR: IT_LINE.

     CALL FUNCTION 'READ_TEXT'
       EXPORTING
*        CLIENT                  = SY-MANDT
         ID                      = THEAD-TDID
         LANGUAGE                = THEAD-TDSPRAS
         NAME                    = THEAD-TDNAME
         OBJECT                  = THEAD-TDOBJECT
*        ARCHIVE_HANDLE          = 0
*        LOCAL_CAT               = ' '
*     IMPORTING
*        HEADER                  =
       TABLES
         LINES                   = IT_LINE
       EXCEPTIONS
         ID                      = 1
         LANGUAGE                = 2
         NAME                    = 3
         NOT_FOUND               = 4
         OBJECT                  = 5
         REFERENCE_CHECK         = 6
         WRONG_ACCESS_TO_ARCHIVE = 7
         OTHERS                  = 8.


     IF SY-SUBRC <> 0.
*     MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
     ELSE.
       MOVE: LT_ZTSTIGT-TDOBT   TO THEAD-TDOBJECT,
             P_DOCNO            TO THEAD-TDNAME,
             P_LANGU            TO THEAD-TDSPRAS,
             LT_ZTSTIGT-TDIDT   TO THEAD-TDID.

       LOOP AT IT_LINE.
         MOVE: IT_LINE-TDLINE       TO G_TEXTLINES-TDLINE,
               IT_LINE-TDFORMAT     TO G_TEXTLINES-TDFORMAT,
               THEAD-TDOBJECT       TO G_TEXTLINES-TDOBJECT,
               THEAD-TDID           TO G_TEXTLINES-TDID.
         APPEND G_TEXTLINES.
       ENDLOOP.
     ENDIF.
   ENDLOOP.

   IF SY-SUBRC EQ 0.
     READ TABLE GT_CONTROL WITH KEY OBJECT = P_TDOBJECT_TO.
     IF SY-SUBRC EQ 0.
       G_TABIX = SY-TABIX.
       GT_CONTROL-TEXTLINES[] = G_TEXTLINES[].
       MODIFY GT_CONTROL INDEX G_TABIX.
     ENDIF.
   ENDIF.

 ENDFORM.                    " get_and_copy_pre_doc_text
*&---------------------------------------------------------------------*
*&      Form  set_message_preparations
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
 FORM SET_MESSAGE_PREPARATIONS .

   CALL METHOD CL_MESSAGE_HANDLER_MM=>GET_HANDLER
     IMPORTING
       EX_HANDLER = G_MESSAGE_HANDLER.

   CALL METHOD G_MESSAGE_HANDLER->SET_CONFIG_FOR_MEPO( ).
   CALL METHOD G_MESSAGE_HANDLER->REMOVE_ALL( ).
   CALL METHOD G_MESSAGE_HANDLER->CLEANUP( ).

 ENDFORM.                    " set_message_preparations
*&---------------------------------------------------------------------*
*&      Form  check_text_by_text_id
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
 FORM CHECK_TEXT_BY_TEXT_ID  USING    P_TXTOBJ
                                      P_TXTID
                                      P_CHECK
                                      P_TDTEXT.

   DATA L_TEXTLINES LIKE MMPUR_TEXTLINES OCCURS 0 WITH HEADER LINE.

   CLEAR: P_CHECK, P_TDTEXT.

   SELECT SINGLE TDTEXT
     INTO P_TDTEXT
     FROM TTXIT
    WHERE TDSPRAS  EQ SY-LANGU
      AND TDOBJECT EQ P_TXTOBJ
      AND TDID     EQ P_TXTID.
   IF SY-SUBRC NE 0.
     EXIT.
   ENDIF.

   READ TABLE GT_CONTROL WITH KEY OBJECT = P_TXTOBJ.
   CHECK SY-SUBRC EQ 0.

*> Long text move
   L_TEXTLINES[] = GT_CONTROL-TEXTLINES[].
   LOOP AT L_TEXTLINES WHERE TDOBJECT = P_TXTOBJ
                         AND TDID     = P_TXTID.
     IF NOT L_TEXTLINES-TDLINE IS INITIAL.
       P_CHECK = C_TRUE.
       EXIT.
     ENDIF.
   ENDLOOP.

 ENDFORM.                    " check_text_by_text_id
*&---------------------------------------------------------------------*
*&      Form  build_edi_status_record
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
 FORM BUILD_EDI_STATUS_RECORD  USING    P_SNCNT
                                        P_EDITY
                                        P_BUKRS
                                        P_REFNO
                                        P_AMDSQ
                                        P_RECID
                                        P_RECNM
                                        P_RECNO
                                        P_SUBRC.

   DATA: L_LCONO TYPE  ZTIREQNO.
   CLEAR: P_SUBRC.

   CHECK NOT P_EDITY IS INITIAL.

   IF NOT P_SNCNT IS INITIAL.
     L_LCONO = P_SNCNT.
   ELSE.
     CALL FUNCTION 'Z_TI_GET_NUMBER_NEXT'
       EXPORTING
         ZMPTY    = 'ED'
*        BUKRS    =
       IMPORTING
         LCONO    = L_LCONO
       EXCEPTIONS
         NOT_TYPE = 1
         OTHERS   = 2.

     IF SY-SUBRC <> 0.
       MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
               WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
     ENDIF.
   ENDIF.

   CLEAR: ZTSTEDIS.
   MOVE: SY-MANDT     TO ZTSTEDIS-MANDT,
         L_LCONO      TO ZTSTEDIS-SNCNT,
         P_EDITY      TO ZTSTEDIS-EDITY,
         SPACE        TO ZTSTEDIS-SNDST,
         P_REFNO      TO ZTSTEDIS-REFNO,
         P_AMDSQ      TO ZTSTEDIS-AMDSQ,
         P_RECID      TO ZTSTEDIS-RECID,
         P_RECNM      TO ZTSTEDIS-RECNM,
         P_RECNO      TO ZTSTEDIS-RECNO,
         P_BUKRS      TO ZTSTEDIS-BUKRS,
         'I'          TO ZTSTEDIS-IMEXI,
*                     TO ZTsTEDIS-RCVNO,
*                     TO ZTsTEDIS-SENDU,
*                     TO ZTsTEDIS-SENDD,
*                     TO ZTsTEDIS-SENDT,
*                     TO ZTsTEDIS-RECVU,
*                     TO ZTsTEDIS-RECVD,
*                     TO ZTsTEDIS-RECVT,
         SY-UNAME     TO ZTSTEDIS-CNAM,
         SY-DATLO     TO ZTSTEDIS-CDAT,
         SY-TIMLO     TO ZTSTEDIS-CTME,
         SY-UNAME     TO ZTSTEDIS-UNAM,
         SY-DATLO     TO ZTSTEDIS-UDAT,
         SY-TIMLO     TO ZTSTEDIS-UTME.

   MODIFY   ZTSTEDIS.
   P_SUBRC = SY-SUBRC.
   IF P_SUBRC NE 0.
     EXIT.
   ENDIF.

   P_SNCNT = L_LCONO.

 ENDFORM.                    " build_edi_status_record
*&---------------------------------------------------------------------*
*&      Form  delete_edi_status_record
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
 FORM DELETE_EDI_STATUS_RECORD  USING    P_SNCNT
                                         P_SUBRC.
   CLEAR: P_SUBRC.

   CHECK NOT P_SNCNT IS INITIAL.
   SELECT SINGLE *
     FROM ZTSTEDIS
    WHERE SNCNT  EQ  P_SNCNT.
   IF SY-SUBRC EQ 0.
     OPEN DATASET ZTSTEDIS-FNAME FOR OUTPUT
                                 IN TEXT MODE ENCODING DEFAULT.
     IF SY-SUBRC EQ 0.
       DELETE DATASET ZTSTEDIS-FNAME.
       IF SY-SUBRC EQ 0.
         DELETE FROM ZTSTEDIS WHERE SNCNT EQ P_SNCNT.
         P_SUBRC = SY-SUBRC.
         P_SUBRC = 4.
       ENDIF.
     ELSE.
       P_SUBRC = 4.
     ENDIF.
   ELSE.
     P_SUBRC = 4.
   ENDIF.

   IF P_SUBRC NE 0.
     MESSAGE S036.
   ENDIF.

 ENDFORM.                    " DELETE_edi_status_record
*&---------------------------------------------------------------------*
*&      Form  currency_convert_to_external
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
 FORM CURRENCY_CONVERT_TO_EXTERNAL  USING    P_WRBTR_FROM
                                             P_WAERS
                                             P_WRBTR_TO.

**   p_waers           = P_waers_to.
*   bapicurx-bapicurx = p_wrbtr_from.
*
*   CALL FUNCTION 'BAPI_CURRENCY_CONV_TO_EXTERN_9'
*     EXPORTING
*       currency             = p_waers
*       amount_external      = bapicurx-bapicurx
**      max_number_of_digits = g_digits
*     IMPORTING
*       amount_internal      = p_wrbtr_to.
***     RETURN                     =
**  .
**
 ENDFORM.                    " currency_convert_to_external
*&---------------------------------------------------------------------*
*&      Form  CONVERT_TO_LOCAL_CURRENCY_COM
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
 FORM CONVERT_TO_LOCAL_CURRENCY_COM  USING    P_WAERS_FR
                                              P_WAERS_TO
                                              P_UKURS
                                              P_DATE
                                              P_WRBTR
                                              P_DMBTR.

*> 원화환율.
   DATA: L_EXCHANGE_RATE LIKE TCURR-UKURS,
         L_CONV_DATE     LIKE SY-DATUM.

   DATA: BEGIN OF RATEEQUATION,
           KURSP  LIKE RFCU9-KURSP,
           FFACTP LIKE TCURF-FFACT,
           TFACTP LIKE TCURF-TFACT,
           FCURRP LIKE TCURC-WAERS,
           TCURRP LIKE TCURC-WAERS,
           KURSM  LIKE RFCU9-KURSM,
           FFACTM LIKE TCURF-FFACT,
           TFACTM LIKE TCURF-TFACT,
           FCURRM LIKE TCURC-WAERS,
           TCURRM LIKE TCURC-WAERS,
         END OF RATEEQUATION.

   DATA  RATE       LIKE TCURR-UKURS.

   DATA: BEGIN OF AMOUNTS,
           FORAMOUNT(13) TYPE P DECIMALS 2,
           LOCAMOUNT(13) TYPE P DECIMALS 2,
           FORCUR        LIKE TCURR-FCURR,
           LOCCUR        LIKE TCURR-TCURR,
         END OF AMOUNTS.


   DATA : L_TEXT_EXRATE(255)    TYPE C,
          L_FOREIGN_FACTOR(255) TYPE C,
          L_FTEXT11(11)         TYPE C,
          L_TTEXT11(11)         TYPE C,
          L_FACTOR              TYPE P,
          L_DATE                TYPE DATUM.

   L_CONV_DATE = P_DATE.
   IF L_CONV_DATE IS INITIAL.
     L_CONV_DATE = SY-DATLO.
   ENDIF.

   CALL FUNCTION 'READ_EXCHANGE_RATE'
     EXPORTING
       DATE             = L_CONV_DATE
       FOREIGN_CURRENCY = P_WAERS_FR
       LOCAL_CURRENCY   = P_WAERS_TO
       TYPE_OF_RATE     = 'M'
     IMPORTING
       EXCHANGE_RATE    = L_EXCHANGE_RATE
     EXCEPTIONS
       ERROR_MESSAGE    = 1.
   IF SY-SUBRC = 1.
     MESSAGE ID SY-MSGID TYPE 'I' NUMBER SY-MSGNO
             WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
     EXIT.
   ENDIF.
*   IF l_exchange_rate > 0.
*     rateequation-kursp = l_exchange_rate.
*     IF ztitrqs-akkur IS INITIAL.
*       ztitrqs-akkur = l_exchange_rate.
*     ENDIF.
*     IF ztitrqs-akkur NE rateequation-kursp.
*       rateequation-kursp = ztitrqs-akkur.
*     ENDIF.
*     CLEAR rateequation-kursm.
*   ELSE.
*     IF ztitrqs-akkur IS INITIAL.
*       ztitrqs-akkur = - l_exchange_rate.
*     ENDIF.
*     rateequation-kursm = - l_exchange_rate.
*     IF ztitrqs-akkur NE rateequation-kursm.
*       rateequation-kursm = ztitrqs-akkur.
*     ENDIF.
*     CLEAR rateequation-kursp.
*   ENDIF.
*
   IF L_EXCHANGE_RATE GT 0.
     IF L_EXCHANGE_RATE LT 1.
       IF P_UKURS IS INITIAL.
         RATE = L_EXCHANGE_RATE.
       ELSE.
         RATE = 1 / P_UKURS.
       ENDIF.
     ELSE.
       IF P_UKURS IS INITIAL.
         RATE = L_EXCHANGE_RATE.
       ELSE.
         RATE = P_UKURS.
       ENDIF.
     ENDIF.
   ELSE.
     IF L_EXCHANGE_RATE GT -1.
       IF P_UKURS IS INITIAL.
         RATE = - L_EXCHANGE_RATE.
       ELSE.
         RATE = - P_UKURS.
         RATE = 1 / RATE.
       ENDIF.
     ELSE.
       IF P_UKURS IS INITIAL.
         RATE = - L_EXCHANGE_RATE.
       ELSE.
         RATE = - P_UKURS.
       ENDIF.
     ENDIF.
   ENDIF.

*   IF rateequation-kursm IS INITIAL.
*     IF p_ukurs IS INITIAL.
*       rate = rateequation-kursp.
*     ELSE.
*       rate = p_ukurs.
*     ENDIF.
*   ELSE.
**     rate = - rateequation-kursm.
*     IF p_ukurs IS INITIAL.
*       rate = - rateequation-kursp.
*     ELSE.
*       rate = - p_ukurs.
*     ENDIF.
*   ENDIF.
   AMOUNTS-FORAMOUNT = P_WRBTR.

   CALL FUNCTION 'CONVERT_TO_LOCAL_CURRENCY'
     EXPORTING
       DATE             = L_CONV_DATE
       FOREIGN_AMOUNT   = AMOUNTS-FORAMOUNT
       FOREIGN_CURRENCY = P_WAERS_FR
       LOCAL_CURRENCY   = P_WAERS_TO
       RATE             = RATE
       TYPE_OF_RATE     = 'M'
     IMPORTING
       LOCAL_AMOUNT     = AMOUNTS-LOCAMOUNT
     EXCEPTIONS
       ERROR_MESSAGE    = 1.

   IF SY-SUBRC <> 0.
     MESSAGE ID SY-MSGID TYPE 'I' NUMBER SY-MSGNO
             WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
     EXIT.
   ENDIF.
   P_DMBTR = AMOUNTS-LOCAMOUNT.

 ENDFORM.                    " CONVERT_TO_LOCAL_CURRENCY_COM
*&---------------------------------------------------------------------*
*&      Form  get_bs_int_no_by_iblno
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
 FORM GET_BS_INT_NO_BY_IBLNO  USING    P_IBSNO
                                       P_IBLNO
                                       P_CLEAR_MODE.

   DATA: L_IBSNO LIKE ZTITBSK-IBSNO.

   IF P_CLEAR_MODE EQ C_TRUE.
     CLEAR : P_IBSNO.
   ENDIF.

   IF NOT P_IBLNO IS INITIAL.
     CLEAR: G_COUNT.
     SELECT  IBSNO
             INTO  L_IBSNO
             FROM  ZTITBSK  WHERE IBLNO EQ P_IBLNO.
       ADD 1 TO G_COUNT.
     ENDSELECT.

     CASE G_COUNT.
       WHEN  0.
         MESSAGE E207 WITH P_IBLNO.
       WHEN  1.
*         SELECT DISTINCT reqno amdsq
*           INTO (p_reqno, p_amdsq)
*           FROM ZTIvrq00
*          WHERE ebeln EQ p_ebeln.
*         ENDSELECT.
         MOVE: L_IBSNO TO P_IBLNO.
         EXIT.
       WHEN OTHERS.
         CALL FUNCTION 'Z_TI_POPUP_TO_IBLNO_BY_BLNUM'
           EXPORTING
             XBLNUM    = P_IBLNO
           IMPORTING
             XIBLNO    = P_IBLNO
           EXCEPTIONS
             NOT_FOUND = 1
             OTHERS    = 2.

         IF SY-SUBRC <> 0.
           MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
                   WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
         ENDIF.
     ENDCASE.
   ENDIF.


 ENDFORM.                    " get_bs_int_no_by_iblno
*&---------------------------------------------------------------------*
*&      Form  get_iccno_by_bl_number
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
 FORM GET_ICCNO_BY_BL_NUMBER  USING    P_BLNUM
                                       P_ICCNO
                                       P_ICCSQ
                                       P_CLEAR_MODE.
   DATA: L_ICCNO LIKE ZTITCCK-ICCNO.
   DATA: L_ICCSQ LIKE ZTITCCK-ICCSQ.

   IF P_CLEAR_MODE EQ C_TRUE.
     CLEAR : P_ICCNO, P_ICCSQ.
   ENDIF.

   IF NOT P_BLNUM IS INITIAL.

     CLEAR: G_COUNT.
     SELECT  ICCNO ICCSQ
       INTO  (L_ICCNO,L_ICCSQ)
       FROM  ZTITCCK
      WHERE  IBLNO IN ( SELECT IBLNO
                          FROM ZTITBLK
                         WHERE BLNUM EQ P_BLNUM )
      GROUP BY ICCNO ICCSQ.
       ADD 1 TO G_COUNT.
     ENDSELECT.

     CASE G_COUNT.
       WHEN  0.
         MESSAGE E439 WITH P_BLNUM.
       WHEN  1.
         MOVE: L_ICCNO TO P_ICCNO.
         EXIT.
       WHEN OTHERS.
         CALL FUNCTION 'Z_TI_POPUP_TO_ICCNO_BY_BLNUM'
           EXPORTING
             XBLNUM    = P_BLNUM
           IMPORTING
             XICCNO    = P_ICCNO
             XICCSQ    = P_ICCSQ
           EXCEPTIONS
             NOT_FOUND = 1
             OTHERS    = 2.

         IF SY-SUBRC <> 0.
           MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
                   WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
         ENDIF.
     ENDCASE.
   ENDIF.

 ENDFORM.                    " get_iccno_by_bl_number
*&---------------------------------------------------------------------*
*&      Form  get_iccno_by_iblno
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
 FORM GET_ICCNO_BY_IBLNO  USING        P_IBLNO
                                       P_ICCNO
                                       P_ICCSQ
                                       P_CLEAR_MODE.
   DATA: L_ICCNO LIKE ZTITCCK-ICCNO.
   DATA: L_ICCSQ LIKE ZTITCCK-ICCSQ.

   IF P_CLEAR_MODE EQ C_TRUE.
     CLEAR : P_ICCNO, P_ICCSQ.
   ENDIF.

   IF NOT P_IBLNO IS INITIAL.

     CLEAR: G_COUNT.
     SELECT  ICCNO ICCSQ
       INTO  (L_ICCNO,L_ICCSQ)
       FROM  ZTITCCK
      WHERE  IBLNO EQ P_IBLNO
      GROUP BY ICCNO ICCSQ.
       ADD 1 TO G_COUNT.
     ENDSELECT.

     CASE G_COUNT.
       WHEN  0.
         MESSAGE E440 WITH P_IBLNO.
       WHEN  1.
         MOVE: L_ICCNO TO P_ICCNO,
               L_ICCSQ TO P_ICCSQ.
         EXIT.
       WHEN OTHERS.
*        CALL FUNCTION 'Z_TI_POPUP_TO_ICCNO_BY_BLNUM'
*          EXPORTING
*            xblnum    = p_blnum
*          IMPORTING
*            xiccno    = p_iccno
*            xiccsq    = p_iccsq
*          EXCEPTIONS
*            not_found = 1
*            OTHERS    = 2.
*
*        IF sy-subrc <> 0.
*          MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
*                  WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
*        ENDIF.
     ENDCASE.
   ENDIF.

 ENDFORM.                    " get_iccno_by_iblno
*&---------------------------------------------------------------------*
*&      Form  get_fi_document_header
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
 FORM GET_FI_DOCUMENT_HEADER  USING    P_GJAHR
                                       P_BELNR
                                       P_BUKRS
                                       P_AWTYP
                                       P_BKPF.

   DATA: X_ACCDN LIKE ACCDN OCCURS 1 WITH HEADER LINE.

   DATA: L_AWTYP      LIKE  ACCHD-AWTYP,
         L_AWREF      LIKE  ACCHD-AWREF,
         L_AWORG      LIKE  ACCHD-AWORG,
         L_AWSYS      LIKE  ACCHD-AWSYS,
         L_AWTYP_INCL LIKE  ACCHD-AWTYP,
         L_AWTYP_EXCL LIKE  ACCHD-AWTYP,
         L_BUKRS      LIKE  ACCIT-BUKRS,
         L_VALUTYP    LIKE  ACCCR-VALUTYP   VALUE '0'.

   CLEAR: P_BKPF.

   IF P_AWTYP EQ 'MKPF'.        ">자재문서(입고)
     SELECT SINGLE *
       FROM MKPF
      WHERE MBLNR  =  P_BELNR
        AND MJAHR  =  P_GJAHR.
   ELSEIF P_AWTYP EQ 'RMRP'.    ">송장처리..
     SELECT SINGLE *
       FROM RBKP
      WHERE BELNR  =  P_BELNR
        AND GJAHR  =  P_GJAHR.
   ELSE.
     EXIT.
   ENDIF.

   IF SY-SUBRC EQ 0.
     L_AWREF  =  P_BELNR.
     L_AWORG  =  P_GJAHR.
     L_AWTYP  =  P_AWTYP.
     L_AWSYS  =  RBKP-LOGSYS.
     L_BUKRS  =  P_BUKRS.
   ELSE.
     EXIT.
   ENDIF.

   REFRESH X_ACCDN.
   CALL FUNCTION 'FI_DOCUMENT_FIND_FOR_INTERFACE'
     EXPORTING
       I_AWTYP      = L_AWTYP
       I_AWREF      = L_AWREF
       I_AWORG      = L_AWORG
       I_AWSYS      = L_AWSYS
       I_BUKRS      = L_BUKRS
     TABLES
       E_ACCDN      = X_ACCDN
*      I_ACCDN      =
     EXCEPTIONS
       NO_DOC_FOUND = 1
       OTHERS       = 2.

   READ TABLE X_ACCDN INDEX 1.
   IF SY-SUBRC EQ 0.
     SELECT SINGLE *
       FROM BKPF
      WHERE BUKRS EQ X_ACCDN-BUKRS
        AND BELNR EQ X_ACCDN-BELNR
        AND GJAHR EQ X_ACCDN-GJAHR.
   ENDIF.

 ENDFORM.                    " get_fi_document_header
*&---------------------------------------------------------------------*
*&      Form  check_EDI_AVAILABLE_CHAR
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
 FORM CHECK_EDI_AVAILABLE_CHAR2  USING    P_FIELDNAME  P_MSGTY.

   FIELD-SYMBOLS: <L_FIELD>.
   DATA: L_SUBRC   TYPE  SUBRC,
         L_FDPOS   TYPE  SYFDPOS,
         L_CHAR(2) TYPE  C.

   DATA: BEGIN OF FIELD,
           TABLE(15),
           STRICH,
           NAME(10),
         END OF FIELD.

   ASSIGN (P_FIELDNAME) TO <L_FIELD>.

   CALL FUNCTION 'Z_TI_CHECK_EDI_AVAILABLE_CHAR2'
     EXPORTING
       IN_STRING = <L_FIELD>
     IMPORTING
       EX_SUBRC  = L_SUBRC
       EX_FDPOS  = L_FDPOS.

   G_SUBRC = L_SUBRC.

   IF L_SUBRC NE 0.
     SEARCH P_FIELDNAME FOR '-'.
     IF SY-SUBRC EQ 0.
       FIELD-TABLE  = P_FIELDNAME(SY-FDPOS).
       FIELD+15     = P_FIELDNAME+SY-FDPOS.
       PERFORM GET_FTEXT(RDDFIE00) USING    FIELD-TABLE
                                            FIELD-NAME
                                            SY-LANGU
                                   CHANGING DFIES
                                            L_SUBRC.

       CALL FUNCTION 'Z_TI_CUT_2BYTES_STRINGS'
         EXPORTING
           I_STR     = <L_FIELD>
           I_START   = L_FDPOS
           I_LEN     = 1
           I_EXCLUDE = SPACE
         IMPORTING
           O_STR     = L_CHAR.

       SET CURSOR FIELD P_FIELDNAME.
       IF L_SUBRC EQ 0.
         MESSAGE ID 'ZMTI00' TYPE P_MSGTY NUMBER 928
                             WITH DFIES-SCRTEXT_M SPACE L_CHAR.
       ELSE.
         MESSAGE ID 'ZMTI00' TYPE P_MSGTY NUMBER 928
                             WITH FIELD-TABLE FIELD-NAME L_CHAR.
       ENDIF.
     ENDIF.
   ENDIF.

 ENDFORM.                    "CHECK_EDI_AVAILABLE_CHAR2
*&---------------------------------------------------------------------*
*&      Form  CHECK_EDI_AVAILABLE_CHAR3
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_9108   text
*      -->P_9109   text
*      -->P_C_ERROR  text
*----------------------------------------------------------------------*
 FORM CHECK_EDI_AVAILABLE_CHAR3  USING   P_VALUE
                                         P_FIELDNAME
                                         P_MSGTY.

   FIELD-SYMBOLS: <L_FIELD>.
   DATA: L_SUBRC   TYPE  SUBRC,
         L_FDPOS   TYPE  SYFDPOS,
         L_CHAR(2) TYPE  C.

   DATA: BEGIN OF FIELD,
           TABLE(15),
           STRICH,
           NAME(10),
         END OF FIELD.

*   ASSIGN (P_VALUE) TO <L_FIELD>.

   CALL FUNCTION 'Z_TI_CHECK_EDI_AVAILABLE_CHAR2'
     EXPORTING
       IN_STRING = P_VALUE
     IMPORTING
       EX_SUBRC  = L_SUBRC
       EX_FDPOS  = L_FDPOS.

   G_SUBRC = L_SUBRC.

   IF L_SUBRC NE 0.
     SEARCH P_FIELDNAME FOR '-'.
     IF SY-SUBRC EQ 0.
       FIELD-TABLE  = P_FIELDNAME(SY-FDPOS).
       FIELD+15     = P_FIELDNAME+SY-FDPOS.
       PERFORM GET_FTEXT(RDDFIE00) USING    FIELD-TABLE
                                            FIELD-NAME
                                            SY-LANGU
                                   CHANGING DFIES
                                            L_SUBRC.

       CALL FUNCTION 'Z_TI_CUT_2BYTES_STRINGS'
         EXPORTING
           I_STR     = P_VALUE
           I_START   = L_FDPOS
           I_LEN     = 1
           I_EXCLUDE = SPACE
         IMPORTING
           O_STR     = L_CHAR.

       SET CURSOR FIELD P_FIELDNAME.
       IF L_SUBRC EQ 0.
         MESSAGE ID 'ZMTI00' TYPE P_MSGTY NUMBER 928
                             WITH DFIES-SCRTEXT_M SPACE L_CHAR.
       ELSE.
         MESSAGE ID 'ZMTI00' TYPE P_MSGTY NUMBER 928
                             WITH FIELD-TABLE FIELD-NAME L_CHAR.
       ENDIF.
     ENDIF.
   ENDIF.
 ENDFORM.                    " CHECK_EDI_AVAILABLE_CHAR3
*&---------------------------------------------------------------------*
*&      Form  CHECK_MANDATORY_INPUT_2
*&---------------------------------------------------------------------*
 FORM CHECK_MANDATORY_INPUT_2  USING    P_FIELDNAME  P_MSGTY.

   FIELD-SYMBOLS: <L_FIELD>.
   DATA: L_SUBRC   TYPE  SUBRC,
         L_FDPOS   TYPE  SYFDPOS,
         L_CHAR(2) TYPE  C.

   DATA: BEGIN OF FIELD,
           TABLE(15),
           STRICH,
           NAME(10),
         END OF FIELD.

   ASSIGN (P_FIELDNAME) TO <L_FIELD>.

   IF <L_FIELD> IS INITIAL.
     SEARCH P_FIELDNAME FOR '-'.
     IF SY-SUBRC EQ 0.
       FIELD-TABLE  = P_FIELDNAME(SY-FDPOS).
       FIELD+15     = P_FIELDNAME+SY-FDPOS.
       PERFORM NO_INPUT_CHECK USING FIELD-TABLE FIELD-NAME C_WARNING.
     ENDIF.
   ENDIF.

 ENDFORM.                    " CHECK_MANDATORY_INPUT_2
