*&---------------------------------------------------------------------*
*& Include          ZGTSDI0001F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form INITIALIZATION
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM initialization .
*  s_targ-low = gc_kpcm.
*  __rng s_targ 'I' 'EQ' s_targ-low s_targ-high.

  s_erdat-low = sy-datlo.
  s_erdat-high = sy-datlo.
  __rng s_erdat 'I' 'EQ' s_erdat-low s_erdat-high.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form MODIFY_SCREEN
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM modify_screen .


ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHECK_INPUT_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM check_input_data .

  CLEAR gv_error.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form AUTHORITY_CHECK
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM authority_check .


ENDFORM.
*&---------------------------------------------------------------------*
*& Form DATA_QUERY
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM data_query .



*___ HEAD 가져오기 .
  SELECT * INTO CORRESPONDING FIELDS OF TABLE gt_head
    FROM zsdt_d365_020
    WHERE week IN s_week
    AND pltype IN s_pltype
    AND vkbur IN s_vkbur
    AND cycltype IN s_ctype
    AND ( erdat IN s_erdat OR aedat IN s_erdat ).

  CHECK gt_head[] IS NOT INITIAL.

*___ ITEM 가져오기.
  SELECT * INTO CORRESPONDING FIELDS OF TABLE gt_item
    FROM zsdt_d365_021
    FOR ALL ENTRIES IN gt_head
    WHERE week = gt_head-week
    AND pltype = gt_head-pltype
    AND vkbur = gt_head-vkbur
    AND cycltype = gt_head-cycltype.



ENDFORM.
*&---------------------------------------------------------------------*
*& Form SEND_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM send_data .

  DATA: lv_erdat  LIKE sy-datum,
        lv_erzet  LIKE sy-uzeit,
        lv_dest   TYPE zifdest-dest,
        lv_result TYPE zo_result,
        lv_msg    TYPE zo_message2,
        lv_tar    TYPE zgtetarget,
        lv_stamp  TYPE timestampl.

  DATA : lt_head TYPE TABLE OF zgtsdsif0025 WITH HEADER LINE,
         lt_item TYPE TABLE OF zgtsdsif0026 WITH HEADER LINE.
  DATA : lt_hlog TYPE TABLE OF zgtsdt1021 WITH HEADER LINE.
  DATA : lt_ilog TYPE TABLE OF zgtsdt1022 WITH HEADER LINE.


  CLEAR : gt_result, gt_result[].

  CHECK gt_head[] IS NOT INITIAL.

  lv_tar = p_targ.

  CALL FUNCTION 'Z_IF_DESTINATION'
    EXPORTING
      gubun                 = 'IS'
    IMPORTING
      dest_name             = lv_dest
    EXCEPTIONS
      destination_not_found = 1
      OTHERS                = 2.


  LOOP AT gt_head.
    CLEAR : lv_erdat, lv_erzet, lv_result, lv_msg.
    CLEAR : lt_head, lt_head[], lt_item, lt_item[].


    lv_erdat = sy-datum.
    lv_erzet = sy-uzeit.
    GET TIME STAMP FIELD lv_stamp.

    "HEAD 전송데이터
    MOVE-CORRESPONDING gt_head TO lt_head.
    APPEND lt_head. CLEAR : lt_head.

    "HEAD LOG
    MOVE-CORRESPONDING gt_head TO lt_hlog.
    lt_hlog-zifkey = lv_stamp.
    lt_hlog-zsystem_id = p_targ.
    lt_hlog-ifdat = lv_erdat.
    lt_hlog-iftim = lv_erzet.
    lt_hlog-ifnam = sy-uname.
    APPEND lt_hlog. CLEAR : lt_hlog.


    LOOP AT gt_item WHERE week = gt_head-week
      AND pltype = gt_head-pltype
      AND cycltype = gt_head-cycltype
      AND vkbur = gt_head-vkbur.

      "ITEM 전송 데이터
      MOVE-CORRESPONDING gt_item TO lt_item.
      APPEND lt_item. CLEAR : lt_item.

      "ITEM LOG.
      MOVE-CORRESPONDING gt_item TO lt_ilog.
      lt_ilog-zifkey = lv_stamp.
      APPEND lt_ilog. CLEAR : lt_ilog.
    ENDLOOP.


    TRY.
        CALL FUNCTION 'ZGTSD_IF_O_SALESPLAN_INFO'
          DESTINATION lv_dest
          EXPORTING
            i_system_id           = lv_tar
          IMPORTING
            zo_result             = lv_result
            zo_message            = lv_msg
          TABLES
            ot_tab_h              = lt_head
            ot_tab_i              = lt_item
          EXCEPTIONS
            system_failure        = 1 MESSAGE lv_msg
            communication_failure = 2 MESSAGE lv_msg
            illegalname           = 3
            OTHERS                = 4.
        IF sy-subrc NE 0.
          lv_result = |01|.
        ENDIF.

      CATCH cx_root INTO DATA(lo_err).
        MESSAGE s000 WITH lo_err->get_longtext( ) DISPLAY LIKE gc_e.EXIT.
    ENDTRY.

    "결과 조회를 위한 결과 저장
    MOVE-CORRESPONDING gt_head TO gt_result.
    gt_result-zo_result = lv_result.
    gt_result-zo_message2 = lv_msg.
    APPEND gt_result .CLEAR : gt_result.

    lt_hlog-zresult = lv_result.
    lt_hlog-zmessage = lv_msg.
    MODIFY lt_hlog TRANSPORTING zresult zmessage
    WHERE zifkey = lv_stamp.


  ENDLOOP.

  IF lt_hlog[] IS NOT INITIAL.
    MODIFY zgtsdt1021 FROM TABLE lt_hlog.
    COMMIT WORK.
  ENDIF.

  IF lt_Ilog[] IS NOT INITIAL.
    MODIFY zgtsdt1022 FROM TABLE lt_Ilog.
    COMMIT WORK.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form WRITE_RESULT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM write_result .

  IF gt_head[] IS INITIAL.
    WRITE : 'NO_DATA'.
  ENDIF.

  LOOP AT gt_result INTO gs_result.
    WRITE: / 'WEEK:',       gs_result-week,
           / 'PLTYPE:',     gs_result-pltype,
           / 'CYCLTYPE:',   gs_result-cycltype,
           / 'VKBUR:',      gs_result-vkbur,
           / 'ZO_RESULT:',  gs_result-zo_result,
           / 'ZO_MESSAGE2:',gs_result-zo_message2,
           /.
  ENDLOOP.
ENDFORM.
