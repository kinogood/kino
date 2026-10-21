*&---------------------------------------------------------------------*
*& Include          ZGTPPR3080F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form set_initialization
*&---------------------------------------------------------------------*
*& Initialization 값 구성
*&---------------------------------------------------------------------*
FORM set_initialization .
  DATA : ls_dyntxt TYPE smp_dyntxt.

*-- 1. Function Key 정보 구성
  ls_dyntxt = VALUE #(
                      icon_id   = icon_view_list
                      icon_text = |I/F List 조회|
                     ).
  sscrfields-functxt_01 = ls_dyntxt.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form submit_prg_if_list
*&---------------------------------------------------------------------*
*& I/F 리스트 조회 T-Code : ZGTPPR1000 수행
*&---------------------------------------------------------------------*
FORM submit_prg_if_list .
  DATA : lt_seltab TYPE ty_rsparams.

*-- PP Interface List(GT 통합) 조회조건 구성
  lt_seltab[] = VALUE #(
                        ( selname = |S_KIND|   kind = |S| sign = gc_sign-i option = gc_optn-eq low = |PP| )
                        ( selname = |S_CODE_G| kind = |S| sign = gc_sign-i option = gc_optn-eq low = |0020| )
                       ).
*-- 코드 마스터 관리 PP I/F 리스트 조회
  SUBMIT zgtppr1000 WITH SELECTION-TABLE lt_seltab
                    AND RETURN.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_f4_sysid
*&---------------------------------------------------------------------*
*& I/F 시스템 정보 Search Help 수행
*&---------------------------------------------------------------------*
FORM set_f4_sysid.

  DATA : lt_return TYPE vec_t_ddshretval,
         lt_dynp   TYPE dynpread_t,
         lt_field  TYPE ty_dfies,
         ls_field  TYPE dfies.


  DATA : BEGIN OF ls_sysid,
           fld_01 TYPE zgte_fldval,             " 수신 시스템
           fld_02 TYPE zgte_fldval,             " 수신 시스템 명
         END OF ls_sysid,
         lt_sysid LIKE TABLE OF ls_sysid WITH EMPTY KEY.

*-- 수신 시스템 F4 정보 Select
  SELECT a~fld_01,  a~fld_02

    FROM zgtppt1010 AS a
   WHERE a~module_kind EQ 'PP'
     AND a~codegrp     EQ '0010'

   ORDER BY a~fld_01

    INTO CORRESPONDING FIELDS OF TABLE @lt_sysid.

  CHECK lt_sysid[] IS NOT INITIAL.

*-- 필드명 정보 강제 구성
  PERFORM get_fieldinfo             USING    'ZGTPPT1010'
                                             'FLD_01'
                                    CHANGING ls_field.

  ls_field = VALUE #( BASE ls_field
                      position = 1
                      offset   = 0
                      reptext  = '수신 시스템'
                    ).

  APPEND ls_field TO lt_field.

  PERFORM get_fieldinfo             USING    'ZGTPPT1010'
                                             'FLD_02'
                                    CHANGING ls_field.

  ls_field = VALUE #( BASE ls_field
                      position = 2
                      offset   = 40
                      reptext  = '시스템 명'

                    ).

  APPEND ls_field TO lt_field.

*-- 수신 시스템 Search Help 수행
  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      retfield        = 'FLD_01'
      dynpprog        = sy-cprog
      dynpnr          = sy-dynnr
      window_title    = '수신 시스템'
      value_org       = 'S'
    TABLES
      value_tab       = lt_sysid
      field_tab       = lt_field
      return_tab      = lt_return
    EXCEPTIONS
      parameter_error = 1
      no_values_found = 2
      OTHERS          = 3.

  CHECK sy-subrc EQ 0.

*-- 선택된 수신 시스템 정보 화면에 Update 수행
  READ TABLE lt_return INDEX 1 INTO DATA(ls_return).

  READ TABLE lt_sysid WITH KEY fld_01 = ls_return-fieldval
                      INTO ls_sysid.

  CHECK sy-subrc EQ 0.

  lt_dynp = VALUE #(
                    ( fieldname = 'P_SYSID'  fieldvalue = ls_sysid-fld_01 )
                    ( fieldname = 'GV_SYSTX' fieldvalue = ls_sysid-fld_02 )
                   ).

  PERFORM dynp_values_update        USING    lt_dynp.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form dynp_values_update
*&---------------------------------------------------------------------*
*& 화면 Value 정보 Update 수행
*&---------------------------------------------------------------------*
*&      --> PT_DYNP  : 해당 Update Value 정보
*&---------------------------------------------------------------------*
FORM dynp_values_update  USING    pt_dynp  TYPE dynpread_t.

  CHECK pt_dynp[] IS NOT INITIAL.

  CALL FUNCTION 'DYNP_VALUES_UPDATE'
    EXPORTING
      dyname               = sy-cprog
      dynumb               = sy-dynnr
    TABLES
      dynpfields           = pt_dynp
    EXCEPTIONS
      invalid_abapworkarea = 1
      invalid_dynprofield  = 2
      invalid_dynproname   = 3
      invalid_dynpronummer = 4
      invalid_request      = 5
      no_fielddescription  = 6
      undefind_error       = 7
      OTHERS               = 8.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_f4_if_no
*&---------------------------------------------------------------------*
*& Process(I/F No) 정보 Search Help 수행
*&---------------------------------------------------------------------*
FORM set_f4_if_no .
  DATA : lt_return TYPE vec_t_ddshretval,
         lt_dynp   TYPE dynpread_t,
         lt_field  TYPE ty_dfies,
         ls_field  TYPE dfies.

  DATA : BEGIN OF ls_ifno,
           fld_01 TYPE zgte_fldval,             " I/F No.
           fld_02 TYPE zgte_fldval,             " I/F No. 내역
           fld_05 TYPE zgte_fldval,             " 호출 Function
         END OF ls_ifno,
         lt_ifno LIKE TABLE OF ls_ifno WITH EMPTY KEY.

*-- 수신 시스템 F4 정보 Select
  SELECT a~fld_01,  a~fld_02,  a~fld_05

    FROM zgtppt1010 AS a
   WHERE a~module_kind EQ 'PP'
     AND a~codegrp     EQ '0020'
     AND a~fld_03      EQ 'I'

   ORDER BY a~fld_01

    INTO CORRESPONDING FIELDS OF TABLE @lt_ifno.

  CHECK lt_ifno[] IS NOT INITIAL.
*-- 필드명 정보 강제 구성
  PERFORM get_fieldinfo             USING    'ZGTPPT1010'
                                             'FLD_01'
                                    CHANGING ls_field.

  ls_field = VALUE #( BASE ls_field
                      position = 1
                      offset   = 0
                      reptext  = 'Interface No'
                    ).

  APPEND ls_field TO lt_field.

  PERFORM get_fieldinfo             USING    'ZGTPPT1010'
                                             'FLD_02'
                                    CHANGING ls_field.

  ls_field = VALUE #( BASE ls_field
                      position = 2
                      offset   = 80
                      reptext  = 'Interface 명'

                    ).

  APPEND ls_field TO lt_field.

  PERFORM get_fieldinfo             USING    'ZGTPPT1010'
                                             'FLD_05'
                                    CHANGING ls_field.

  ls_field = VALUE #( BASE ls_field
                      position = 3
                      offset   = 160
                      reptext  = '호출 Function'

                    ).

  APPEND ls_field TO lt_field.

*-- 수신 시스템 Search Help 수행
  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      retfield        = 'FLD_01'
      dynpprog        = sy-cprog
      dynpnr          = sy-dynnr
      window_title    = 'Process(I/F No)'
      value_org       = 'S'
    TABLES
      value_tab       = lt_ifno
      field_tab       = lt_field
      return_tab      = lt_return
    EXCEPTIONS
      parameter_error = 1
      no_values_found = 2
      OTHERS          = 3.

  CHECK sy-subrc EQ 0.

*-- 선택된 수신 시스템 정보 화면에 Update 수행
  READ TABLE lt_return INDEX 1 INTO DATA(ls_return).

  READ TABLE lt_ifno WITH KEY fld_01 = ls_return-fieldval
                     INTO ls_ifno.

  CHECK sy-subrc EQ 0.

  lt_dynp = VALUE #(
                    ( fieldname = 'P_IF_NO'  fieldvalue = ls_ifno-fld_01 )
                    ( fieldname = 'GV_IFTXT' fieldvalue = ls_ifno-fld_02 )
                   ).

  PERFORM dynp_values_update        USING    lt_dynp.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_fieldinfo
*&---------------------------------------------------------------------*
*& 해당 필드 정보 구성
*&---------------------------------------------------------------------*
*&      --> PV_TABNAME    : 해당 테이블 명
*&      --> PV_FIELDNAME  : 해당 필드 명
*&      <-- PS_FIELD_TAB  : 해당 필드 정보 리턴
*&---------------------------------------------------------------------*
FORM get_fieldinfo  USING    pv_tabname   TYPE ddobjname
                             pv_fieldname
                    CHANGING ps_field_tab TYPE dfies.

  CALL FUNCTION 'DDIF_FIELDINFO_GET'
    EXPORTING
      tabname        = pv_tabname
      fieldname      = pv_fieldname
      lfieldname     = pv_fieldname
    IMPORTING
      dfies_wa       = ps_field_tab
    EXCEPTIONS
      not_found      = 1
      internal_error = 2
      OTHERS         = 3.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form init_sysid_desc_info
*&---------------------------------------------------------------------*
*& 수신 시스템 명 정보 구성
*&---------------------------------------------------------------------*
*&      --> PV_SYSID    : 수신 시스템 조회조건 입력 정보
*&      <-- PV_SYSTX    : 해당 수신 시스템명 정보 리턴
*&---------------------------------------------------------------------*
FORM init_sysid_desc_info  USING    pv_sysid
                           CHANGING pv_systx.

*-- 수신 시스템 정보 없을 경우 내역 정보 Clear
  IF p_sysid IS INITIAL.
    CLEAR pv_systx.
    RETURN.
  ENDIF.

*-- 해당 수신 시스템 정보 Select
  SELECT SINGLE a~fld_02
    FROM zgtppt1010 AS a
   WHERE a~module_kind EQ 'PP'
     AND a~codegrp     EQ '0010'
     AND a~fld_01      EQ @pv_sysid

   INTO @DATA(lv_systx).

  CHECK sy-subrc EQ 0.

  pv_systx = lv_systx.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form init_if_id_desc_info
*&---------------------------------------------------------------------*
*& Process(I/F No) 내역 정보 구성
*&---------------------------------------------------------------------*
*&      --> PV_IF_NO    : I/F No 정보
*&      <-- PV_IFTXT    : 해당 내역 정보 리턴
*&---------------------------------------------------------------------*
FORM init_if_id_desc_info  USING    pv_if_no
                           CHANGING pv_iftxt.

*-- I/F No. 없을 경우 내역 정보 Clear
  IF pv_if_no IS INITIAL.
    CLEAR pv_iftxt.
    RETURN.
  ENDIF.

*-- 해당 내역 정보 Select
  SELECT SINGLE a~fld_02
    FROM zgtppt1010 AS a
   WHERE a~module_kind EQ 'PP'
     AND a~codegrp     EQ '0020'
     AND a~fld_03      EQ 'I'
     AND a~fld_01      EQ @pv_if_no

    INTO @DATA(lv_iftxt).

  CHECK sy-subrc EQ 0.

  pv_iftxt = lv_iftxt.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form select_main_data
*&---------------------------------------------------------------------*
*& I/F 수신 모니터링 정보 Select
*&---------------------------------------------------------------------*
*&      <-- PV_EFLG    : 오류 발생시 'X' 리턴
*&---------------------------------------------------------------------*
FORM select_main_data CHANGING pv_eflg TYPE char01.

  DATA : lt_table    TYPE REF TO data,

         lt_head_key TYPE TABLE OF zgtppsif_rh WITH EMPTY KEY,

         lv_a_cnt    TYPE i,
         lv_s_cnt    TYPE i,
         lv_f_cnt    TYPE i,

         lv_dbtab    TYPE string.

  CLEAR : gs_tab_info, gs_if_rst,
          pv_eflg.

*-----------------------------------------------------------------------
*-- 1. 조회조건 기준 해당 Table 정보 Select
*-----------------------------------------------------------------------
  SELECT SINGLE a~fld_06 AS head_tab,
                a~fld_07 AS item_tab
    FROM zgtppt1010 AS a
   WHERE a~module_kind EQ 'PP'
     AND a~codegrp     EQ '0020'
     AND a~fld_01      EQ @p_if_no
     AND a~fld_03      EQ 'I'

    INTO @gs_tab_info.

  IF sy-subrc NE 0.
*-- 정보 없을경우 오류 메시지 처리 & Return
    MESSAGE s003 WITH '해당하는 IF Log Table이 없습니다.'(e01)
                 DISPLAY LIKE 'E'.
    pv_eflg = abap_true.
    RETURN.
  ENDIF.

  IF <fs_head_tab> IS ASSIGNED.
    UNASSIGN <fs_head_tab>.
  ENDIF.

  IF <fs_item_tab> IS ASSIGNED.
    UNASSIGN <fs_item_tab>.
  ENDIF.
*-----------------------------------------------------------------------
*-- 2. 해당 Head / Item 테이블 정보 기준 동적 Internal Table 구성
*-----------------------------------------------------------------------
*-- 2-1. Header Table 정보 있을경우 해당 동적 테이블 구성
  IF gs_tab_info-head_tab IS NOT INITIAL.
*-- 2-1-1. 해당 Table 명 기준 동적  Internal Table 정보 생성
    PERFORM crte_dynamic_tab_info   USING    gs_tab_info-head_tab
                                    CHANGING lt_table.

*-- 2-1-2. 헤딩 동적 Table 정보 없을경우 오류 메세지 처리 & Return
    IF lt_table IS  INITIAL.
      MESSAGE s005 WITH '코드마스터의 I/F Header Log Table'(e05) '이 DB에 존재하지 않습니다.'(e06)
                   DISPLAY LIKE 'E'.
      pv_eflg = abap_true.
      RETURN.
    ENDIF.

*-- 2-1-3. 해당 동적 Internal Table 생성
    ASSIGN lt_table->* TO <fs_head_tab>.
  ENDIF.

*-- 2-2. Item Table 정보 있을경우 해당 동적 테이블 구성
  IF gs_tab_info-item_tab IS NOT INITIAL.
*-- 2-2-1. 해당 Table 명 기준 동적  Internal Table 정보 생성
    PERFORM crte_dynamic_tab_info   USING    gs_tab_info-item_tab
                                    CHANGING lt_table.

*-- 2-2-2. 헤딩 동적 Table 정보 없을경우 오류 메세지 처리 & Return
    IF lt_table IS  INITIAL.
      MESSAGE s005 WITH '코드마스터의 I/F Item Log Table 이'(e07) '이 DB에 존재하지 않습니다.'(e06)
                   DISPLAY LIKE 'E'.
      pv_eflg = abap_true.
      RETURN.
    ENDIF.

*-- 2-2-3. 해당 동적 Internal Table 생성
    ASSIGN lt_table->* TO <fs_item_tab>.
  ENDIF.

*-----------------------------------------------------------------------
*-- 3. 조회조건 기준 해당 I/F 수신 정보 Select
*-----------------------------------------------------------------------
*-- 3-1. Header 정보 Select
  IF <fs_head_tab> IS ASSIGNED.
    SELECT *
      FROM (gs_tab_info-head_tab)

     WHERE zsystem_id EQ @p_sysid
       AND zserno     IN @s_serno
       AND ifdat      IN @s_ifdat
       AND iftim      IN @s_iftim

      INTO CORRESPONDING FIELDS OF TABLE @<fs_head_tab>.
  ENDIF.

*-- 3-2. Item 정보 Select
  IF <fs_head_tab> IS ASSIGNED AND
     <fs_item_tab> IS ASSIGNED.

*-- Header 고정 Key 정보 기준 Item 정보 동적 Select
    lt_head_key[]  = CORRESPONDING #( <fs_head_tab>[] ).

    lv_dbtab       = gs_tab_info-item_tab && | AS A INNER JOIN +KEY_INFO AS B| && | ON A~ZSYSTEM_ID EQ B~ZSYSTEM_ID| && | AND A~ZSERNO EQ B~ZSERNO|.

    WITH +key_info AS ( SELECT a~zsystem_id, a~zserno                 "--> Header 공통 Key 정보 구성
                          FROM @lt_head_key AS a
                         GROUP BY a~zsystem_id, a~zserno )
    SELECT a~*
      FROM (lv_dbtab)

      INTO CORRESPONDING FIELDS OF TABLE @<fs_item_tab>.

  ELSEIF <fs_item_tab> IS ASSIGNED.
*-- Item 단독정보 인 경우 동적 Select
    SELECT *
      FROM (gs_tab_info-item_tab)

     WHERE zsystem_id EQ @p_sysid
       AND zserno     IN @s_serno
       AND ifdat      IN @s_ifdat
       AND iftim      IN @s_iftim

      INTO CORRESPONDING FIELDS OF TABLE @<fs_item_tab>.
  ENDIF.

*-- 3-3. 조회정보 기준 전송결과 정보 구성
  IF <fs_head_tab> IS ASSIGNED.
*-- 3-3-1. Header 정보 있는 경우
    LOOP AT <fs_head_tab> ASSIGNING FIELD-SYMBOL(<fs_head>).
      ADD 1 TO lv_a_cnt.
*-- 전송상태 정보 기준 성공 / 실패 Count
      ASSIGN COMPONENT 'ZERP_STAT' OF STRUCTURE <fs_head> TO FIELD-SYMBOL(<fs_field>).

      CHECK <fs_field> IS ASSIGNED.

      IF <fs_field> EQ 'S'.
        ADD 1 TO lv_s_cnt.
      ELSE.
        ADD 1 TO lv_f_cnt.
      ENDIF.

      UNASSIGN <fs_field>.
    ENDLOOP.

  ELSEIF <fs_item_tab> IS ASSIGNED.
*-- 3-3-2 Item 정보 있는 경우
    LOOP AT <fs_item_tab> ASSIGNING FIELD-SYMBOL(<fs_item>).
      ADD 1 TO lv_a_cnt.
*-- 전송상태 정보 기준 성공 / 실패 Count
      ASSIGN COMPONENT 'ZERP_STAT' OF STRUCTURE <fs_item> TO <fs_field>.

      CHECK <fs_field> IS ASSIGNED.

      IF <fs_field> EQ 'S'.
        ADD 1 TO lv_s_cnt.
      ELSE.
        ADD 1 TO lv_f_cnt.
      ENDIF.

      UNASSIGN <fs_field>.
    ENDLOOP.

  ENDIF.

*-- 3-3-3. 집계 정보 구성
  gs_if_rst-ifsys = p_sysid && |-| && gv_systx.         " 수신 시스템
  gs_if_rst-pross = gv_iftxt.                           " Process(I/F 항목)

  WRITE : lv_a_cnt TO gs_if_rst-acnt,                   " 전체 건수
          lv_s_cnt TO gs_if_rst-scnt,                   " 성공 건수
          lv_f_cnt TO gs_if_rst-fcnt.                   " 실패 건수

  CONDENSE : gs_if_rst-ifsys,
             gs_if_rst-pross,
             gs_if_rst-acnt,
             gs_if_rst-scnt,
             gs_if_rst-fcnt.

*-- Header 조회정보 없을경우 메세지 처리 & Flag  'X' 구성
  IF <fs_head_tab> IS ASSIGNED AND <fs_head_tab>[] IS INITIAL.
    MESSAGE s005 WITH '코드마스터의 I/F Header Log Table'(e05) '의 데이터가 없습니다.'(e08)
                 DISPLAY LIKE 'E'.
    pv_eflg = abap_true.
    RETURN.
  ENDIF.

*-- Item 조회정보 없을경우 메세지 처리 & Flag  'X' 구성
  IF <fs_item_tab> IS ASSIGNED AND <fs_item_tab>[] IS INITIAL.
    MESSAGE s005 WITH '코드마스터의 I/F Item Log Table'(e07) '의 데이터가 없습니다.'(e08)
                 DISPLAY LIKE 'E'.
    pv_eflg = abap_true.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form crte_dynamic_tab_info
*&---------------------------------------------------------------------*
*& 테이블명 정보 기준 동적 Internal Table Pointer 정보 생성
*&---------------------------------------------------------------------*
*&      --> PV_TABNM  : 해당 Table 명 정보
*&      <-- PT_TABLE  : 해당 Internal Table Pointer 정보 리턴
*&---------------------------------------------------------------------*
FORM crte_dynamic_tab_info  USING    pv_tabnm  TYPE tabname
                            CHANGING pt_table  TYPE REF TO data.

  DATA : lt_fcat  TYPE lvc_t_fcat.

  CLEAR : pt_table.

  CHECK pv_tabnm IS NOT INITIAL.

*-- 1. 해당 Table 명 정보 기준 Fieldc Catalog 정보 구성
  CALL FUNCTION 'LVC_FIELDCATALOG_MERGE'
    EXPORTING
      i_structure_name       = pv_tabnm
    CHANGING
      ct_fieldcat            = lt_fcat
    EXCEPTIONS
      inconsistent_interface = 1
      program_error          = 2
      OTHERS                 = 3.

  CHECK lt_fcat[] IS NOT INITIAL.

*-- 2. 동적 Internal Table Pointer 정보 생성
  CALL METHOD cl_alv_table_create=>create_dynamic_table
    EXPORTING
      it_fieldcatalog = lt_fcat
    IMPORTING
      ep_table        = pt_table.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form init_class_alv_info_0100
*&---------------------------------------------------------------------*
*& Screen 0100 Class ALV 구성
*&---------------------------------------------------------------------*
FORM init_class_alv_info_0100 .

  IF go_cust_cont_0100 IS NOT BOUND.
*-- ALV Custom Container & ALV Grid 정보 구성
    PERFORM crte_objt_grid_0100     CHANGING go_cust_cont_0100
                                             go_grid_head
                                             go_grid_item.

*-----------------------------------------------------------------------
*-- Header ALV 정보 구성
*-----------------------------------------------------------------------
    IF go_grid_head IS BOUND.
*-- Header Layout 구성
      PERFORM set_layout_head       USING    gs_tab_info-head_tab
                                    CHANGING gs_layo_head.
*-- Header 예외 Toolbar 정보 구성
      PERFORM set_exclude_head      CHANGING gt_excl_head.
*-- Header Fieldcatalog 정보 구성
      PERFORM set_fcat_f_tabnm      USING    gs_tab_info-head_tab
                                    CHANGING gt_fcat_head.
*-- Header ALV Event 정보 구성
      PERFORM set_event_handler     USING    go_grid_head
                                    CHANGING go_event_handler.
*-- Header ALV Display
      PERFORM disp_alv_grid_head    USING    go_grid_head.
    ENDIF.

*-----------------------------------------------------------------------
*-- Item ALV 정보 구성
*-----------------------------------------------------------------------
    IF go_grid_item IS BOUND.
*-- Item Layout 구성
      PERFORM set_layout_item       USING    gs_tab_info-item_tab
                                    CHANGING gs_layo_item.
*-- Item 예외 Toolbar 정보 구성
      PERFORM set_exclude_item      CHANGING gt_excl_item.
*-- Item Fieldcatalog 정보 구성
      PERFORM set_fcat_f_tabnm      USING    gs_tab_info-item_tab
                                    CHANGING gt_fcat_item.
*-- Item ALV Event 정보 구성
      PERFORM set_event_handler     USING    go_grid_item
                                    CHANGING go_event_handler.
*-- Item ALV Display
      PERFORM disp_alv_grid_item    USING    go_grid_item.
    ENDIF.
*  ELSE.
**-- ALV Refresh 수행
*    IF go_grid_head IS BOUND.
*      PERFORM refresh_alv_disp      USING    go_grid_head.
*
*    ENDIF.
*
*    IF go_grid_item IS BOUND.
*      PERFORM refresh_alv_disp      USING    go_grid_item.
*
*    ENDIF.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form crte_objt_grid_0100
*&---------------------------------------------------------------------*
*&  Screen 0100 Class ALV Custom Container & Grid 정보 생성
*&---------------------------------------------------------------------*
*&      <-- PO_CUST_CONT  : 해당 Custom Container 생성 정보 리턴
*&      <-- PO_GRID_HEAD  : Header ALV Grid 생성 정보 리턴
*&      <-- PO_GRID_ITEM  : Item ALV Grid 생성 정보 리턴
*&---------------------------------------------------------------------*
FORM crte_objt_grid_0100  CHANGING po_cust_cont TYPE REF TO cl_gui_custom_container
                                   po_grid_head TYPE REF TO cl_gui_alv_grid
                                   po_grid_item TYPE REF TO cl_gui_alv_grid.
*-----------------------------------------------------------------------
*-- 1. Custom Container 생성
*-----------------------------------------------------------------------
  CREATE OBJECT po_cust_cont
    EXPORTING
      container_name = 'ALV_GRID_0100'.

*-----------------------------------------------------------------------
*-- 2-1. Header 정보 있는 경우 2 Row Split & Grid 구성
*-----------------------------------------------------------------------
  IF <fs_head_tab> IS ASSIGNED.
*-- 2-1-1. 2-Row 분할 생성
    CREATE OBJECT go_splt_0100
      EXPORTING
        parent  = po_cust_cont
        rows    = 2
        columns = 1.

*-- 2-1-2. Header ALV Container 구성
    CALL METHOD go_splt_0100->get_container
      EXPORTING
        row       = 1
        column    = 1
      RECEIVING
        container = go_gui_cont_head.

*-- 2-1-3. Item ALV Container 구성
    CALL METHOD go_splt_0100->get_container
      EXPORTING
        row       = 2
        column    = 1
      RECEIVING
        container = go_gui_cont_item.

*-- 2-1-4. Split Header ALV 높이 조정
    CALL METHOD go_splt_0100->set_row_height
      EXPORTING
        id     = 1
        height = 45.

*-- 2-1-5. Head ALV Grid 구성
    CREATE OBJECT po_grid_head
      EXPORTING
        i_parent = go_gui_cont_head.

*-- 2-1-6. Item ALV Grid 구성
    CREATE OBJECT po_grid_item
      EXPORTING
        i_parent = go_gui_cont_item.

  ELSE.
*-----------------------------------------------------------------------
*-- 2-2. Item 정보만 있는 경우 단일 ALV 구성
*-----------------------------------------------------------------------
    CREATE OBJECT po_grid_item
      EXPORTING
        i_parent = po_cust_cont.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_layout_head
*&---------------------------------------------------------------------*
*& Screen 0100 Header ALV Layout 정보 구성
*&---------------------------------------------------------------------*
*&      --> PV_TABNM    : 해당 Table 명 정보
*&      <-- PS_LAYOUT   : 해당 Layout 구성 정보 리턴
*&---------------------------------------------------------------------*
FORM set_layout_head  USING    pv_tabnm    TYPE tabname
                      CHANGING ps_layout   TYPE lvc_s_layo.

  CLEAR : ps_layout.

*-- 해당 Table 명 정보 Select
  SELECT SINGLE a~ddtext
    FROM dd02t AS a
   WHERE a~tabname EQ @pv_tabnm

    INTO @DATA(lv_tabnm).

  ps_layout = VALUE #(
                      grid_title = COND #( WHEN lv_tabnm IS NOT INITIAL THEN |(| && lv_tabnm && |) 수신결과 List|
                                           ELSE abap_false )
                      cwidth_opt = abap_true
                      sel_mode   = |D|
                      zebra      = abap_true
                     ).
ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_exclude_head
*&---------------------------------------------------------------------*
*& Screen 0100 Header ALV Toolbar 예외 버튼 정보 구성
*&---------------------------------------------------------------------*
*&      <-- PT_EXCLUDE  : 예외 정보 리턴
*&---------------------------------------------------------------------*
FORM set_exclude_head  CHANGING pt_exclude TYPE ui_functions.

  PERFORM add_exclude_toolbar       TABLES   pt_exclude[]
                                    USING  : cl_gui_alv_grid=>mc_fc_loc_undo,
                                             cl_gui_alv_grid=>mc_fc_auf,
                                             cl_gui_alv_grid=>mc_fc_check,
                                             cl_gui_alv_grid=>mc_fc_loc_paste,
                                             cl_gui_alv_grid=>mc_fc_loc_copy,
                                             cl_gui_alv_grid=>mc_fc_average,
                                             cl_gui_alv_grid=>mc_fc_graph,
                                             cl_gui_alv_grid=>mc_fc_info,
                                             cl_gui_alv_grid=>mc_fc_loc_copy_row,
                                             cl_gui_alv_grid=>mc_fc_loc_cut,
                                             cl_gui_alv_grid=>mc_fc_loc_delete_row,
                                             cl_gui_alv_grid=>mc_fc_loc_insert_row,
                                             cl_gui_alv_grid=>mc_fc_loc_append_row,
                                             cl_gui_alv_grid=>mc_fc_loc_paste,
                                             cl_gui_alv_grid=>mc_fc_loc_paste_new_row,
                                             cl_gui_alv_grid=>mc_fc_refresh.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form add_exclude_toolbar
*&---------------------------------------------------------------------*
*& Class ALV Toolbar 예외 버튼 정보 추가
*&---------------------------------------------------------------------*
*&      <-- PT_EXCLUDE  : 해당 예외 버튼 정보 추가
*&      --> PV_VALUE    : 예외 버튼 정보
*&---------------------------------------------------------------------*
FORM add_exclude_toolbar  TABLES   pt_exclude
                          USING    pv_value.

  DATA : ls_excl TYPE ui_func.

  ls_excl = pv_value.

  APPEND ls_excl TO pt_exclude.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_fcat_f_tabnm
*&---------------------------------------------------------------------*
*& Screen 0100 Table 명 기준 해당 ALV Fiedcatalog 정보 구성
*&---------------------------------------------------------------------*
*&      --> PV_TABNM    : 해당 Table 명 정보
*&      <-- PT_FCAT     : Header Fieldcatalog 정보 리턴
*&---------------------------------------------------------------------*
FORM set_fcat_f_tabnm  USING    pv_tabnm TYPE tabname
                       CHANGING pt_fcat  TYPE lvc_t_fcat.

  DATA : lt_chk_fcat TYPE TABLE OF lvc_s_fcat WITH EMPTY KEY.

  CLEAR : pt_fcat.

*--  Table 명 정보 기준 Fieldc Catalog 정보 구성
  CALL FUNCTION 'LVC_FIELDCATALOG_MERGE'
    EXPORTING
      i_structure_name       = pv_tabnm
    CHANGING
      ct_fieldcat            = pt_fcat
    EXCEPTIONS
      inconsistent_interface = 1
      program_error          = 2
      OTHERS                 = 3.

*-- 누락된 필드 정보 추가 구성
  lt_chk_fcat[] = CORRESPONDING #( pt_fcat[] ).

  SELECT SINGLE @abap_true
    FROM @lt_chk_fcat AS a
   WHERE a~reptext IS INITIAL
    INTO @DATA(lv_flag).

  CHECK sy-subrc EQ 0.

*-- 누락 필드명 정보 Select
  SELECT a~fieldname,  a~ddtext
    FROM dd03t AS a
   WHERE a~tabname    EQ @pv_tabnm
     AND a~ddlanguage EQ @sy-langu

   ORDER BY a~fieldname

    INTO TABLE @DATA(lt_fld_txt).

  LOOP AT pt_fcat ASSIGNING FIELD-SYMBOL(<fs_fcat>).
    IF <fs_fcat>-reptext IS INITIAL.
      READ TABLE lt_fld_txt WITH KEY fieldname = <fs_fcat>-fieldname
                            INTO DATA(ls_fld_txt).
      IF sy-subrc EQ 0.
        <fs_fcat> = VALUE #( BASE <fs_fcat>
                            reptext   = ls_fld_txt-ddtext
                            scrtext_l = ls_fld_txt-ddtext
                            scrtext_m = ls_fld_txt-ddtext
                            scrtext_s = ls_fld_txt-ddtext
                           ).
      ENDIF.
    ENDIF.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_event_handler
*&---------------------------------------------------------------------*
*& Screen 0100 Class ALV Event 정보 구성
*&---------------------------------------------------------------------*
*&      --> PO_GRID   : 해당 ALV Grid 정보
*&      <-- PO_EVENT  : 해당 ALV Event 구현 정보 리턴
*&---------------------------------------------------------------------*
FORM set_event_handler  USING    po_grid  TYPE REF TO cl_gui_alv_grid
                        CHANGING po_event TYPE REF TO lcl_event_handler.

  IF po_event IS NOT BOUND.
    CREATE OBJECT po_event.
  ENDIF.

*-- ALV Grid 별 Event 정보 구성
  CASE po_grid.
    WHEN go_grid_head.
      SET HANDLER po_event->handle_double_click           FOR po_grid.
    WHEN go_grid_item.
      SET HANDLER po_event->handle_double_click           FOR po_grid.
  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form disp_alv_grid_head
*&---------------------------------------------------------------------*
*& Screen 0100 Header ALV Display
*&---------------------------------------------------------------------*
*&      --> PO_GRID  : 해당 ALV Grid 정보
*&---------------------------------------------------------------------*
FORM disp_alv_grid_head  USING    po_grid TYPE REF TO cl_gui_alv_grid.

  CLEAR : gs_varient.
*-- Haader ALV Varient 기본 정보 구성
  gs_varient = VALUE #(
                          report   = sy-cprog
                          username = sy-uname
                          handle   = 1
                        ).

*-- ALV Display 수행
  CALL METHOD po_grid->set_table_for_first_display
    EXPORTING
      is_layout            = gs_layo_head
      it_toolbar_excluding = gt_excl_head
      is_variant           = gs_varient
      i_save               = 'A'
    CHANGING
      it_outtab            = <fs_head_tab>[]
      it_fieldcatalog      = gt_fcat_head.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_layout_item
*&---------------------------------------------------------------------*
*& Screen 0100 Item ALV Layout 정보 구성
*&---------------------------------------------------------------------*
*&      --> PV_TABNM    : 해당 Table 명 정보
*&      <-- PS_LAYOUT   : 해당 Layout 구성 정보 리턴
*&---------------------------------------------------------------------*
FORM set_layout_item  USING    pv_tabnm    TYPE tabname
                      CHANGING ps_layout   TYPE lvc_s_layo.

  CLEAR : ps_layout.

*-- 해당 Table 명 정보 Select
  SELECT SINGLE a~ddtext
    FROM dd02t AS a
   WHERE a~tabname EQ @pv_tabnm

    INTO @DATA(lv_tabnm).

  ps_layout = VALUE #(
                      grid_title = COND #( WHEN lv_tabnm IS NOT INITIAL THEN |(| && lv_tabnm && |) 수신결과 List|
                                           ELSE abap_false )
                      cwidth_opt = abap_true
                      sel_mode   = |D|
                      zebra      = abap_true
                     ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_exclude_item
*&---------------------------------------------------------------------*
*& Screen 0100 Item ALV Toolbar 예외 버튼 정보 구성
*&---------------------------------------------------------------------*
*&      <-- PT_EXCLUDE  : 예외 정보 리턴
*&---------------------------------------------------------------------*
FORM set_exclude_item  CHANGING pt_exclude TYPE ui_functions.

  PERFORM add_exclude_toolbar       TABLES   pt_exclude[]
                                    USING  : cl_gui_alv_grid=>mc_fc_loc_undo,
                                             cl_gui_alv_grid=>mc_fc_auf,
                                             cl_gui_alv_grid=>mc_fc_check,
                                             cl_gui_alv_grid=>mc_fc_loc_paste,
                                             cl_gui_alv_grid=>mc_fc_loc_copy,
                                             cl_gui_alv_grid=>mc_fc_average,
                                             cl_gui_alv_grid=>mc_fc_graph,
                                             cl_gui_alv_grid=>mc_fc_info,
                                             cl_gui_alv_grid=>mc_fc_loc_copy_row,
                                             cl_gui_alv_grid=>mc_fc_loc_cut,
                                             cl_gui_alv_grid=>mc_fc_loc_delete_row,
                                             cl_gui_alv_grid=>mc_fc_loc_insert_row,
                                             cl_gui_alv_grid=>mc_fc_loc_append_row,
                                             cl_gui_alv_grid=>mc_fc_loc_paste,
                                             cl_gui_alv_grid=>mc_fc_loc_paste_new_row,
                                             cl_gui_alv_grid=>mc_fc_refresh.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form disp_alv_grid_item
*&---------------------------------------------------------------------*
*& Screen 0100 Item ALV Display
*&---------------------------------------------------------------------*
*&      --> PO_GRID  : 해당 ALV Grid 정보
*&---------------------------------------------------------------------*
FORM disp_alv_grid_item  USING    po_grid TYPE REF TO cl_gui_alv_grid.

  CLEAR : gs_varient.
*-- Haader ALV Varient 기본 정보 구성
  gs_varient = VALUE #(
                          report   = sy-cprog
                          username = sy-uname
                          handle   = 2
                        ).

*-- ALV Display 수행
  CALL METHOD po_grid->set_table_for_first_display
    EXPORTING
      is_layout            = gs_layo_item
      it_toolbar_excluding = gt_excl_item
      is_variant           = gs_varient
      i_save               = 'A'
    CHANGING
      it_outtab            = <fs_item_tab>[]
      it_fieldcatalog      = gt_fcat_item.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form refresh_alv_disp
*&---------------------------------------------------------------------*
*& Class ALV Refresh 수행
*&---------------------------------------------------------------------*
*&      --> PO_GRID  : 해당 ALV Grid 정보
*&---------------------------------------------------------------------*
FORM refresh_alv_disp  USING    po_grid  TYPE REF TO cl_gui_alv_grid.

  DATA : ls_stbl TYPE lvc_s_stbl.

  ls_stbl = VALUE #(
                    row = abap_true
                    col = abap_true
                   ).

  CALL METHOD po_grid->refresh_table_display
    EXPORTING
      is_stable      = ls_stbl
    EXCEPTIONS
      finished       = 1
      OTHERS         = 2.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form double_click_0100
*&---------------------------------------------------------------------*
*& Screen 0100 Class ALV Double Click 이벤트 수행
*&---------------------------------------------------------------------*
*&      --> PO_SENDER   : 해당 ALV Grid 정보
*&      --> PS_ROW      : 해당 Row 정보
*&      --> PS_COLUMN   : 해당 필드 정보
*&      --> PS_ROW_NO   : 해당 Row ID 정보
*&---------------------------------------------------------------------*
FORM double_click_0100  USING    po_sender  TYPE REF TO cl_gui_alv_grid
                                 ps_row     TYPE lvc_s_row
                                 ps_column  TYPE lvc_s_col
                                 ps_row_no  TYPE lvc_s_roid.

  DATA : ls_stru TYPE REF TO data.
  CASE po_sender.
    WHEN go_grid_head.      " Header
      CASE ps_column-fieldname.
        WHEN 'AUFNR'.       " 생산오더
          READ TABLE <fs_head_tab> INDEX ps_row_no-row_id
                                   ASSIGNING FIELD-SYMBOL(<fs_head>).
          ASSIGN COMPONENT ps_column-fieldname OF STRUCTURE <fs_head> TO FIELD-SYMBOL(<fs_fld>).
          IF <fs_fld> IS ASSIGNED.
            SET PARAMETER ID 'ANR' FIELD <fs_fld>.

            CALL TRANSACTION 'CO03' AND SKIP FIRST SCREEN.

            UNASSIGN <fs_fld>.
          ENDIF.
        WHEN OTHERS.

      ENDCASE.

    WHEN go_grid_item.      " Item
      CASE ps_column-fieldname.
        WHEN 'AUFNR'.       " 생산오더
          READ TABLE <fs_item_tab> INDEX ps_row_no-row_id
                                   ASSIGNING FIELD-SYMBOL(<fs_item>).
          ASSIGN COMPONENT ps_column-fieldname OF STRUCTURE <fs_item> TO <fs_fld>.
          IF <fs_fld> IS ASSIGNED.
            SET PARAMETER ID 'ANR' FIELD <fs_fld>.

            CALL TRANSACTION 'CO03' AND SKIP FIRST SCREEN.

            UNASSIGN <fs_fld>.
          ENDIF.
        WHEN OTHERS.

      ENDCASE.
  ENDCASE.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form clear_alv_info
*&---------------------------------------------------------------------*
*& Class ALV 선언 정보 & 해당 변수 초기화
*&---------------------------------------------------------------------*
FORM clear_alv_info .

  CALL METHOD go_cust_cont_0100->free.

  CLEAR : go_cust_cont_0100, go_splt_0100,     go_event_handler,
          go_gui_cont_head,  go_gui_cont_item, go_grid_head, go_grid_item.

  CALL METHOD cl_gui_cfw=>flush.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form screen_output_1000
*&---------------------------------------------------------------------*
*& Screen 1000 출력 정보 제어
*&---------------------------------------------------------------------*
FORM screen_output_1000 .

*-- 조회조건 내역정보 구성
  PERFORM init_sysid_desc_info      USING    p_sysid
                                    CHANGING gv_systx.

  PERFORM init_if_id_desc_info      USING    p_if_no
                                    CHANGING gv_iftxt.

*-- Screen 1000 Selection-Screen 화면 정보 구성
  LOOP AT SCREEN.
*-- 필수 필드 표시 정보 구성
    IF screen-group1 EQ 'R01' AND screen-name NE 'S_IFDAT-HIGH'.
      screen-required = '2'.
      MODIFY SCREEN.
    ENDIF.

*-- 내역 정보 구성
    IF screen-name EQ 'GV_SYSTX' OR
       screen-name EQ 'GV_IFTXT'.
      MODIFY SCREEN.
    ENDIF.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form chk_req_value_for_sysid
*&---------------------------------------------------------------------*
*& 수신 시스템 필수값 체크
*&---------------------------------------------------------------------*
*&      --> PV_SYSID  : 수신 시스템 조회조건 값 정보
*&---------------------------------------------------------------------*
FORM chk_req_value_for_sysid  USING    pv_sysid  TYPE zgtetarget.

  CHECK sy-ucomm EQ 'ONLI'.

*-- 조회조건 없이 실행시 오류 메세시 구성
  IF pv_sysid IS INITIAL.
    MESSAGE e278(00) WITH '수신 시스템'(e02).
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form chk_req_value_for_if_no
*&---------------------------------------------------------------------*
*& Process(I/F No) 조회조건 필수값 확인
*&---------------------------------------------------------------------*
*&      --> PV_IF_NO : I/F No 조회조건 값 저옵
*&---------------------------------------------------------------------*
FORM chk_req_value_for_if_no  USING    pv_if_no TYPE char10.

  CHECK sy-ucomm EQ 'ONLI'.

*-- 조회조건 없이 실행시 오류 메세시 구성
  IF pv_if_no IS INITIAL.
    MESSAGE e278(00) WITH 'Process(I/F No)'(e03).
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form chk_req_value_for_ifdat
*&---------------------------------------------------------------------*
*& 수신일자 조회조건 필수값 확인
*&---------------------------------------------------------------------*
*&      --> PT_IFDAT  : 수신일자 조회조건 Range 정보
*&---------------------------------------------------------------------*
FORM chk_req_value_for_ifdat  USING    pt_ifdat TYPE wtysc_erdat_ranges_tab.

  CHECK sy-ucomm EQ 'ONLI'.

*-- 조회조건 없이 실행시 오류 메세시 구성
  IF pt_ifdat[] IS INITIAL.
    MESSAGE e278(00) WITH '수신일자'(e04).
  ENDIF.

ENDFORM.
