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


  RANGES : r_dlvrq FOR zlet0400-dlvrq.
  RANGES : r_dlvrq2 FOR zlet0400-dlvrq.


*___ 전송 대상 찾기

  SELECT  h~dlvrq AS low
    INTO CORRESPONDING FIELDS OF TABLE r_dlvrq2
    FROM zlet0400 AS h
    INNER JOIN zlet0401 AS i
    ON h~dlvrq EQ i~dlvrq
    WHERE h~vkorg IN s_vkorg
    AND h~vtweg IN s_vtweg
    AND h~spart IN s_spart
    AND h~vstel IN s_vstel
    AND h~dlvrq IN s_dlvrq
    AND ( h~erdat IN s_erdat OR
          i~aedat IN s_erdat ).

  CHECK r_dlvrq2[] IS NOT INITIAL..

  SORT r_dlvrq2.
  DELETE ADJACENT DUPLICATES FROM r_dlvrq2 COMPARING ALL FIELDS.

  r_dlvrq[] = VALUE #( FOR wa IN r_dlvrq2
                     ( sign = 'I'
                       option = 'EQ'
                       low = wa-low
                       high = wa-high ) ).


*___ 데이터 가져오기 .

  SELECT * INTO CORRESPONDING FIELDS OF TABLE gt_head
    FROM zlet0400
    WHERE dlvrq IN r_dlvrq.

  SELECT * INTO CORRESPONDING FIELDS OF TABLE gt_item1
    FROM zlet0401
    WHERE dlvrq IN r_dlvrq.

  SELECT * INTO CORRESPONDING FIELDS OF TABLE gt_item2
    FROM zlet0402
    WHERE dlvrq IN r_dlvrq.

  SELECT * INTO CORRESPONDING FIELDS OF TABLE gt_item3
    FROM zlet0406
    WHERE dlvrq IN r_dlvrq.

  LOOP AT gt_head.
    __alpha_ou : gt_head-kunwe gt_head-kunwe,
                 gt_head-kunag gt_head-kunag.
    MODIFY gt_head. CLEAR : gt_head.
  ENDLOOP.


  LOOP AT gt_item1.
    __alpha_ou : gt_item1-posnr gt_item1-posnr,
                 gt_item1-matnr gt_item1-matnr.
    MODIFY gt_item1. CLEAR : gt_item1.
  ENDLOOP.

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
        lv_ernam  LIKE sy-uname,
        lv_dest   TYPE zifdest-dest,
        lv_result TYPE zo_result,
        lv_msg    TYPE zo_message2,
        lv_tar    TYPE zgtetarget,
        lv_last   TYPE c,
        lv_stamp  TYPE timestampl.
*
*  DATA : lt_head  TYPE TABLE OF zgtsdsif0027 WITH HEADER LINE,
*         lt_item1 TYPE TABLE OF zgtsdsif0028 WITH HEADER LINE,
*         lt_item2 TYPE TABLE OF zgtsdsif0029 WITH HEADER LINE,
*         lt_item3 TYPE TABLE OF zgtsdsif0030 WITH HEADER LINE.

  DATA : lt_HLOG TYPE TABLE OF zgtsdt1023 WITH HEADER LINE.
  DATA : lt_ILOG1 TYPE TABLE OF zgtsdt1024 WITH HEADER LINE.
  DATA : lt_ILOG2 TYPE TABLE OF zgtsdt1025 WITH HEADER LINE.
  DATA : lt_ILOG3 TYPE TABLE OF zgtsdt1026 WITH HEADER LINE.
*
*
  CLEAR : gt_result, gt_result[].

  CHECK gt_head[] IS NOT INITIAL.
*
  lv_tar = p_targ.

  CALL FUNCTION 'Z_IF_DESTINATION'
    EXPORTING
      gubun                 = 'IS'
    IMPORTING
      dest_name             = lv_dest
    EXCEPTIONS
      destination_not_found = 1
      OTHERS                = 2.
*



*__ LOG 데이터 생성

  lv_erdat = sy-datum.
  lv_erzet = sy-uzeit.
  lv_ernam = sy-uname.
  GET TIME STAMP FIELD lv_stamp.


  lt_hlog[] = VALUE #( FOR ls_head IN gt_head
                 ( VALUE #( BASE CORRESPONDING #( ls_head )
                  zifkey = lv_stamp
                  ifdat = lv_erdat
                  iftim = lv_erzet
                  ifnam = lv_ernam  ) )
                  ).

  lt_ilog1[] = VALUE #( FOR ls_item1 IN gt_item1
                 ( VALUE #( BASE CORRESPONDING #( ls_item1 )
                  zifkey = lv_stamp
                  ifdat = lv_erdat
                  iftim = lv_erzet
                  ifnam = lv_ernam  ) )
                  ).


  lt_ilog2[] = VALUE #( FOR ls_item2 IN gt_item2
                 ( VALUE #( BASE CORRESPONDING #( ls_item2 )
                  zifkey = lv_stamp
                  ifdat = lv_erdat
                  iftim = lv_erzet
                  ifnam = lv_ernam  ) )
                  ).

  lt_ilog3[] = VALUE #( FOR ls_item3 IN gt_item3
                 ( VALUE #( BASE CORRESPONDING #( ls_item3 )
                  zifkey = lv_stamp
                  ifdat = lv_erdat
                  iftim = lv_erzet
                  ifnam = lv_ernam  ) )
                  ).



  TRY.
      CALL FUNCTION 'ZGTSD_IF_O_DELIVERY_REQ_INFO'
        DESTINATION lv_dest
        EXPORTING
          i_system_id           = lv_tar
        IMPORTING
          zo_result             = lv_result
          zo_message            = lv_msg
        TABLES
          ot_tab_h              = gt_head
          ot_tab_i1             = gt_item1
          ot_tab_i2             = gt_item2
          ot_tab_i3             = gt_item3
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
  lt_hlog-zresult = lv_result.
  lt_hlog-zmessage = lv_msg.
  lt_hlog-zsystem_id = p_targ.

  MODIFY lt_hlog TRANSPORTING zresult zmessage zsystem_id
  WHERE zifkey = lv_stamp.


  lt_ilog1-zresult = lv_result.
  lt_ilog1-zmessage = lv_msg.
  lt_ilog1-zsystem_id = p_targ.

  MODIFY lt_ilog1 TRANSPORTING zresult zmessage zsystem_id
  WHERE zifkey = lv_stamp.


*
  IF lt_hlog[] IS NOT INITIAL.
    MODIFY zgtsdt1023 FROM TABLE lt_hlog.
    COMMIT WORK.
  ENDIF.
*
  IF lt_Ilog1[] IS NOT INITIAL.
    MODIFY zgtsdt1024 FROM TABLE lt_Ilog1.
    COMMIT WORK.
  ENDIF.

  IF lt_Ilog2[] IS NOT INITIAL.
    MODIFY zgtsdt1025 FROM TABLE lt_Ilog2.
    COMMIT WORK.
  ENDIF.

  IF lt_Ilog3[] IS NOT INITIAL.
    MODIFY zgtsdt1026 FROM TABLE lt_Ilog3.
    COMMIT WORK.
  ENDIF.

  WRITE : lv_stamp , lv_result,  lv_msg.

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

*  LOOP AT gt_result INTO gs_result.
*    WRITE: / 'WEEK:',       gs_result-week,
*           / 'PLTYPE:',     gs_result-pltype,
*           / 'CYCLTYPE:',   gs_result-cycltype,
*           / 'VKBUR:',      gs_result-vkbur,
*           / 'ZO_RESULT:',  gs_result-zo_result,
*           / 'ZO_MESSAGE2:',gs_result-zo_message2,
*           /.
*  ENDLOOP.
ENDFORM.
