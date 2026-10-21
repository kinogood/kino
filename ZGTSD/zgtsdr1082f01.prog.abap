*&---------------------------------------------------------------------*
*& Include          ZGTSDR1082F01
*&---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Form  alv_write_rtn
*&---------------------------------------------------------------------*
FORM alv_write_rtn.

** ALV 출력을 위한 HEADER및 FIELD SETTING
  PERFORM  alvprn_basic.
  PERFORM  alvprn_header.
  PERFORM  alvprn_field.

** ALV DISPLAY
  PERFORM  alv_display.

ENDFORM.                    " alv_write_rtn

*&---------------------------------------------------------------------*
*&      Form  ALVPRN_BASIC
*&---------------------------------------------------------------------*
*       ALV를 실행하기위한 기본 정보 SETTING
*----------------------------------------------------------------------*
FORM alvprn_basic.

  CLEAR:   g_events_t, g_layout_s.
  REFRESH: g_events_t.

** Default SETTING
  g_layout_s-detail_popup      = 'X'.
* g_layout_s-no_totalline      = 'X'.    " 합계필드의 사용여부
  g_layout_s-zebra             = 'X'.
  g_layout_s-box_fieldname     = 'CHK'.
* G_LAYOUT_S-CELL_MERGE        = 'X'.
  g_layout_s-colwidth_optimize = 'X'.

** FORM문 발췌함수
  CALL FUNCTION 'REUSE_ALV_EVENTS_GET'
    EXPORTING
      i_list_type = 0
    IMPORTING
      et_events   = g_events_t.

** FORM문   생성
  PERFORM form_setting  TABLES g_events_t
                         USING : slis_ev_pf_status_set  c_status_set,
                                 slis_ev_user_command   c_user_command,
                                 slis_ev_top_of_page    c_top_of_page.
  " Grapic Display

** PROGRAM  ID
  g_program = sy-repid.

ENDFORM.                    " ALVPRN_BASIC

*&---------------------------------------------------------------------*
*&      Form  ALVPRN_HEADER
*&---------------------------------------------------------------------*
*       ALV HEADER SETTING
*----------------------------------------------------------------------*
FORM alvprn_header.

  DATA : l_data1(100),
         l_data2(100),
         l_data3(100),
         l_data4(100),
         l_data5(100),
         l_kunnr LIKE kna1-kunnr.

  REFRESH g_list_top_of_page_t.

  READ TABLE g_itab_t INDEX 1.

  CONCATENATE  g_itab_t-vkbur '(' g_itab_t-text02 ')'
         INTO  l_data1.

  CONCATENATE  g_itab_t-vkgrp '(' g_itab_t-text03 ')'
         INTO  l_data2.

  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
    EXPORTING
      input  = g_itab_t-kunnr
    IMPORTING
      output = l_kunnr.

  CONCATENATE  l_kunnr '(' g_itab_t-name1 ')'
         INTO  l_data3.

  PERFORM header_setting TABLES g_list_top_of_page_t
                          USING: 'S'  '영업팀     : ' l_data1,
                                 'S'  '영업그룹   : ' l_data2,
                                 'S'  '거 래 선   : ' l_data3.

ENDFORM.                    " ALVPRN_HEADER

*&---------------------------------------------------------------------*
*&      Form  ALVPRN_FIELD
*&---------------------------------------------------------------------*
*       ALV FIELD  SETTING
*----------------------------------------------------------------------*
FORM   alvprn_field.

  REFRESH: g_field_t, g_fieldcat_t.

* FIELD발췌
  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
    EXPORTING
      i_program_name         = g_program
      i_internal_tabname     = 'G_ITAB_T'
      i_client_never_display = 'X'
      i_inclname             = 'ZGTSDR1082TOP'
      i_bypassing_buffer     = 'X'
      i_buffer_active        = 'X'
    CHANGING
      ct_fieldcat            = g_field_t[].

  PERFORM  field_setting  TABLES g_fieldcat_t
                          USING: 'S' 'VBELN'       ' ',
                                 ' ' 'SELTEXT_L'   '문서번호',
                                 ' ' 'DDICTXT'     'L',
                                 ' ' 'OUTPUTLEN'   '10',
                                 ' ' 'COL_POS'     '1',
                                 'E' 'KEY'         'X',

                                 'S' 'POSNR'       ' ',
                                 ' ' 'SELTEXT_L'   '품목',
                                 ' ' 'DDICTXT'     'L',
                                 ' ' 'OUTPUTLEN'   '6',
                                 'E' 'COL_POS'     '2',

                                  'S' 'PSTYV'       ' ',
                                 ' ' 'SELTEXT_L'   '품목범주',
                                 ' ' 'DDICTXT'     'L',
                                 ' ' 'OUTPUTLEN'   '4',
                                 'E' 'COL_POS'     '3',

                                 'S' 'WAERK'       ' ',
                                 ' ' 'SELTEXT_L'   '통화',
                                 ' ' 'DDICTXT'     'L',
                                 ' ' 'OUTPUTLEN'   '5',
                                 'E' 'COL_POS'     '20',

                                 'S' 'KURRF'       ' ',
                                 ' ' 'SELTEXT_L'   '환율',
                                 ' ' 'DDICTXT'     'L',
                                 ' ' 'OUTPUTLEN'   '12',
                                 ' ' 'JUST'        'R',
                                 'E' 'COL_POS'     '21',

                                 'S' 'NETWR_A'     ' ',
                                 ' ' 'SELTEXT_L'   'Billing미처리',
                                 ' ' 'DDICTXT'     'L',
                                 ' ' 'OUTPUTLEN'   '20',
                                 ' ' 'JUST'        'R',
                                 'E' 'COL_POS'     '22',

                                 'S' 'MWSBK_A'     ' ',
                                 ' ' 'SELTEXT_L'   'Billing미처리(Tax)',
                                 ' ' 'DDICTXT'     'L',
                                 ' ' 'OUTPUTLEN'   '20',
                                 ' ' 'JUST'        'R',
                                 'E' 'COL_POS'     '23',

                                 'S' 'ZFLAG1'      ' ',
                                 ' ' 'SELTEXT_L'   '무상빌링미처리',
                                 ' ' 'DDICTXT'     'L',
                                 ' ' 'OUTPUTLEN'   '14',
                                 ' ' 'JUST'        'C',
                                 'E' 'COL_POS'     '24',

                                 'S' 'NETWR_B'     ' ',
                                 ' ' 'SELTEXT_L'   '전표미생성',
                                 ' ' 'DDICTXT'     'L',
                                 ' ' 'OUTPUTLEN'   '20',
                                 ' ' 'JUST'        'R',
                                 'E' 'COL_POS'     '25',

                                 'S' 'MWSBK_B'     ' ',
                                 ' ' 'SELTEXT_L'   '전표미생성(Tax)',
                                 ' ' 'DDICTXT'     'L',
                                 ' ' 'OUTPUTLEN'   '20',
                                 ' ' 'JUST'        'R',
                                 'E' 'COL_POS'     '26',

                                 'S' 'NETWR_C'     ' ',
                                 ' ' 'SELTEXT_L'   '계산서미발행',
                                 ' ' 'DDICTXT'     'L',
                                 ' ' 'OUTPUTLEN'   '20',
                                 ' ' 'JUST'        'R',
                                 'E' 'COL_POS'     '27',

                                 'S' 'MWSBK_C'     ' ',
                                 ' ' 'SELTEXT_L'   '계산서미발행(Tax)',
                                 ' ' 'DDICTXT'     'L',
                                 ' ' 'OUTPUTLEN'   '20',
                                 ' ' 'JUST'        'R',
                                 'E' 'COL_POS'     '28',

                                 'S' 'NETWR_D'     ' ',
                                 ' ' 'SELTEXT_L'   '계산서발행',
                                 ' ' 'DDICTXT'     'L',
                                 ' ' 'OUTPUTLEN'   '20',
                                 ' ' 'JUST'        'R',
                                 'E' 'COL_POS'     '29',

                                 'S' 'MWSBK_D'     ' ',
                                 ' ' 'SELTEXT_L'   '계산서발행(Tax)',
                                 ' ' 'DDICTXT'     'L',
                                 ' ' 'OUTPUTLEN'   '20',
                                 ' ' 'JUST'        'R',
                                 'E' 'COL_POS'     '30',

*                                 'S' 'NETWR_F'     ' ',
*                                 ' ' 'SELTEXT_L'   '적송',
*                                 ' ' 'DDICTXT'     'L',
*                                 ' ' 'OUTPUTLEN'   '20',
*                                 ' ' 'JUST'        'R',
*                                 'E' 'COL_POS'     '31',
*
*                                 'S' 'MWSBK_F'     ' ',
*                                 ' ' 'SELTEXT_L'   '적송(Tax)',
*                                 ' ' 'DDICTXT'     'L',
*                                 ' ' 'OUTPUTLEN'   '20',
*                                 ' ' 'JUST'        'R',
*                                 'E' 'COL_POS'     '32',

                                 'S' 'NETWR_G'     ' ',
                                 ' ' 'SELTEXT_L'   '금액(전자세금)',
                                 ' ' 'DDICTXT'     'L',
                                 ' ' 'OUTPUTLEN'   '20',
                                 ' ' 'JUST'        'R',
                                 'E' 'COL_POS'     '32',

                                 'S' 'MWSBK_G'     ' ',
                                 ' ' 'SELTEXT_L'   '부가세(전자세금)',
                                 ' ' 'DDICTXT'     'L',
                                 ' ' 'OUTPUTLEN'   '20',
                                 ' ' 'JUST'        'R',
                                 'E' 'COL_POS'     '33',


                                 'S' 'BILLSTATX'   ' ',
                                 ' ' 'SELTEXT_L'   '전자세금계산서상태',
                                 ' ' 'DDICTXT'     'L',
                                 ' ' 'OUTPUTLEN'   '30',
                                 ' ' 'JUST'        'C',
                                 'E' 'COL_POS'     '34',


                                 'S' 'ZFLAG2'      ' ',
                                 ' ' 'SELTEXT_L'   '대금청구계획보류',
                                 ' ' 'DDICTXT'     'L',
                                 ' ' 'OUTPUTLEN'   '16',
                                 ' ' 'JUST'        'C',
                                 'E' 'COL_POS'     '35',

                                 'S' 'MESG'        ' ',
                                 ' ' 'SELTEXT_L' 'BDC메세지(오더관련)',
                                 ' ' 'DDICTXT'     'L',
                                 ' ' 'OUTPUTLEN'   '70',
                                 'E' 'COL_POS'     '40',

                                 'S' 'MESG2'       ' ',
                                 ' ' 'SELTEXT_L' 'BDC메세지(빌링관련)',
                                 ' ' 'DDICTXT'     'L',
                                 ' ' 'OUTPUTLEN'   '70',
                                 'E' 'COL_POS'     '41',


                                 'S' 'MESG3'       ' ',
                                 ' ' 'SELTEXT_L' 'BDC메세지(빌링관련)',
                                 ' ' 'DDICTXT'     'L',
                                 ' ' 'OUTPUTLEN'   '70',
                                 'E' 'COL_POS'     '42',


                                 'S' 'FBUDA'       ' ',
                                 ' ' 'SELTEXT_L' '서비스제공일',
                                 ' ' 'DDICTXT'     'L',
                                 ' ' 'OUTPUTLEN'   '8',
                                 'E' 'COL_POS'     '43'.


ENDFORM.                    " ALVPRN_FIELD

*&---------------------------------------------------------------------*
*&      Form  ALV_DISPLAY
*&---------------------------------------------------------------------*
*       ALV DISPLAY
*----------------------------------------------------------------------*
FORM alv_display.

  g_save  =  'A'.

  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
* call function 'REUSE_ALV_LIST_DISPLAY'
    EXPORTING
      i_callback_program      = g_program
      is_layout               = g_layout_s
      i_save                  = g_save
      is_variant              = g_variant_s
      it_events               = g_events_t[]
      it_fieldcat             = g_fieldcat_t[]
    IMPORTING
      e_exit_caused_by_caller = g_exit_caused_by_caller
      es_exit_caused_by_user  = g_exit_caused_by_user_s
    TABLES
      t_outtab                = g_itab_t.

ENDFORM.                    " ALV_DISPLAY

*-------------------------------------------------------------------*
*        Form  PF_STATUS_SET
*-------------------------------------------------------------------*
*       외부(REUSE_ALV_EVENTS_GET)에서 CALL한 FORM 문이다.
*-------------------------------------------------------------------*
FORM pf_status_set USING p_rt_extab TYPE slis_t_extab.

  CLEAR : gt_fcode, gt_fcode[].

  IF g_p_spart NE '70'.
    APPEND 'ZCHG' TO gt_fcode.
  ENDIF.

  IF p_lock IS NOT INITIAL.
    APPEND 'ZCHG' TO gt_fcode.
    APPEND 'ZFLAG2' TO gt_fcode.
    APPEND 'ZTAX' TO gt_fcode.
    APPEND 'ZVF_CANC' TO gt_fcode.
  ENDIF.

  SET PF-STATUS '1000' EXCLUDING gt_fcode.
  SET TITLEBAR '1000'.

ENDFORM.                    "pf_status_set

*---------------------------------------------------------------------*
*      Form  TOP_OF_PAGE
*---------------------------------------------------------------------*
*      TOP의 로그 부분 SETTING.
*---------------------------------------------------------------------*
FORM top_of_page.

  CALL FUNCTION 'REUSE_ALV_COMMENTARY_WRITE'
    EXPORTING
      i_logo             = ' '
      it_list_commentary = g_list_top_of_page_t.

ENDFORM.                    "top_of_page

*---------------------------------------------------------------------*
*      Form  USER COMMAND
*---------------------------------------------------------------------*
*      USER COMMAND 정의.
*---------------------------------------------------------------------*
FORM  user_command USING p_ucomm    LIKE sy-ucomm
                         p_selfield TYPE slis_selfield.

  CASE p_ucomm.

    WHEN '&IC1'.

      CASE p_selfield-sel_tab_field.

        WHEN 'G_ITAB_T-ZFLAG1' OR  'G_ITAB_T-ZFLAG2'.
          READ TABLE g_itab_t INDEX p_selfield-tabindex.
          PERFORM  call_va02  USING  g_itab_t-vbeln_a.

        WHEN 'G_ITAB_T-VBELN'.
          READ TABLE g_itab_t INDEX p_selfield-tabindex.
          PERFORM  call_vbeln  USING  g_itab_t-vbeln.
      ENDCASE.

    WHEN  'ZFLAG2'.
      PERFORM  check_va02_rtn.

    WHEN  'ZTAX'.           " 부가세조정
      p_ucomm = '&REFRESH'.
      PERFORM  pai(saplslvc_fullscreen).
      PERFORM  ztax_calc_rtn.
      PERFORM  add_ztax." CHM2510-00065
      P_UCOMM = '&REFRESH'. " CHM2510-00065
      PERFORM  PAI(SAPLSLVC_FULLSCREEN). " CHM2510-00065

    WHEN  'ZCHG'.
      p_ucomm = '&REFRESH'.
      PERFORM  pai(saplslvc_fullscreen).
      PERFORM  zchg_calc_rtn.
      PERFORM  alv_write_rtn.

    WHEN  'ZVF_CANC'.
      p_ucomm = '&REFRESH'.
      PERFORM  pai(saplslvc_fullscreen).
      PERFORM  billing_cancel.
*      P_UCOMM = '&REFRESH'.
*      PERFORM  PAI(SAPLSLVC_FULLSCREEN).
*      PERFORM  BILLING_CANCEL_M.

    WHEN  'BACK' OR 'EXIT' OR 'CANC'.
      SET SCREEN 0.
      LEAVE SCREEN.

  ENDCASE.

ENDFORM.                    "user_command

*&---------------------------------------------------------------------*
*&      Form  call_va02
*&---------------------------------------------------------------------*
FORM call_va02  USING    p_value.

  CHECK NOT p_value IS INITIAL.

* PARAMETER SETTING
  SET PARAMETER ID: 'AUN'    FIELD   p_value.

* CALL TRANSACTION
  CALL TRANSACTION  'VA02' AND SKIP FIRST SCREEN.
  COMMIT WORK AND WAIT.

ENDFORM.                                                    " call_va02

*&---------------------------------------------------------------------*
*&      Form  check_va02_rtn
*&---------------------------------------------------------------------*
FORM check_va02_rtn .

  DATA : l_cnt TYPE i.

  l_cnt  =  0.

  LOOP AT g_itab_t WHERE chk = 'X'.
    l_cnt  =  l_cnt  +  1.
  ENDLOOP.

  IF  l_cnt  >  1.
    MESSAGE e001 WITH '하나이상의 Record는 선택불가합니다.'.
  ELSEIF  l_cnt  =  0.
    MESSAGE e001 WITH '보류해제하실 Record를 선택하세요.'.
  ENDIF.

  READ TABLE g_itab_t WITH KEY chk = 'X'.

  IF  g_itab_t-zflag2  NE  'O'.
    MESSAGE e001 WITH '선택하신 Data를 확인하세요.'.
  ENDIF.

  PERFORM  call_va02  USING  g_itab_t-vbeln_a.

ENDFORM.                    " check_va02_rtn

*&---------------------------------------------------------------------*
*&      Module  STATUS_2000  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_2000 OUTPUT.

  SET PF-STATUS '2000'.
  SET TITLEBAR '2000'.

ENDMODULE.                 " STATUS_2000  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_2000  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_2000 INPUT.

  CASE  sy-ucomm.

    WHEN  'ENTE'.
      LEAVE TO SCREEN 0.

    WHEN  'CANC'.
      g_p_tax  =  0.
      LEAVE TO SCREEN 0.

  ENDCASE.

ENDMODULE.                 " USER_COMMAND_2000  INPUT

*&---------------------------------------------------------------------*
*&      Form  ztax_calc_rtn
*&---------------------------------------------------------------------*
FORM ztax_calc_rtn .

  DATA : l_cnt   TYPE i,
         l_fkdat LIKE sy-datum,
         l_fkart LIKE vbrk-fkart,
         l_maktx LIKE makt-maktx,
         l_vbeln LIKE vbak-vbeln.
  CLEAR : l_cnt, l_vbeln, l_maktx, l_fkdat, l_fkart,
          g_p_auart, g_p_vkorg, g_p_vtweg,
          g_p_spart, g_p_vkbur, g_p_vkgrp, g_p_date,
          g_p_kunnr, g_p_name1, g_p_matnr, g_p_maktx,
          g_p_tax,   g_c_tax.

** 빌링문서(대금청구유형:F2, RE)일 경우에만 해당된다.
  LOOP AT g_itab_t WHERE chk = 'X'.

* START : C20090602_65991
*// 영업오더 유형이 CR과 DR일 경우 제외
*// 대금청구유형으로 구분함.
    SELECT  SINGLE fkart
      INTO  l_fkart
      FROM  vbrk
     WHERE  vbeln  =  g_itab_t-vbeln.

    IF  g_itab_t-vbeln+0(3)  NE  '811'.
      IF l_fkart = 'G2' OR l_fkart = 'L2'.
      ELSE.
* END : C20090602_65991
        MESSAGE e001 WITH '선택하신 Data를 확인하세요.'.
        EXIT.
      ENDIF.
    ELSE.

      SELECT  SINGLE fkart
        INTO  l_fkart
        FROM  vbrk
       WHERE  vbeln  =  g_itab_t-vbeln.

      IF sy-subrc NE 0.
        MESSAGE e001 WITH '선택하신 Data를 확인하세요.'.
        EXIT.
      ENDIF.

    ENDIF.

    IF  g_itab_t-kdkg4  NE  '4D'.
      MESSAGE e001 WITH '부가세조정은 내수용입니다.'.
      EXIT.
    ENDIF.


    SELECT  SINGLE werks aubel matnr
      INTO (g_p_werks, l_vbeln, g_p_matnr)
      FROM  vbrp
     WHERE  vbeln  =  g_itab_t-vbeln.

    CLEAR: ls_kunnr_ship.

    SELECT SINGLE kunnr
      INTO ls_kunnr_ship
      FROM vbpa
     WHERE vbeln = g_itab_t-vbeln
       AND parvw = 'WE'.

    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
      EXPORTING
        input  = ls_kunnr_ship
      IMPORTING
        output = g_p_kunnr_ship.


    SELECT  SINGLE maktx
      INTO  l_maktx
      FROM  makt
     WHERE  matnr  =  g_p_matnr
       AND  spras  =  sy-langu.

    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
      EXPORTING
        input  = g_itab_t-kunnr
      IMPORTING
        output = g_p_kunnr.

    CONCATENATE  g_p_kunnr '( ' g_itab_t-name1 ' )'
           INTO  g_p_name1.

*-> CCM : 13.04.2023 13:58:10 / ZLSGSD4
*    call function 'CONVERSION_EXIT_ALPHA_OUTPUT'
*      EXPORTING
*        input  = g_p_matnr
*      IMPORTING
*        output = g_p_matnr.

    CALL FUNCTION 'CONVERSION_EXIT_MATN1_OUTPUT'
      EXPORTING
        input  = g_p_matnr
      IMPORTING
        output = g_p_matnr.
*<-

    CONCATENATE  g_p_matnr '( ' l_maktx ' )'
           INTO  g_p_maktx.

**[start] 매출마감지원 긴급처리
    IF g_p_kunnr_ship+0(1) <> '1' AND
       g_p_kunnr_ship+0(1) <> '6'.
      g_p_kunnr_ship =  g_p_kunnr.
    ENDIF.
**[end]매출마감지원 긴급처리
    l_cnt  =  l_cnt  +  1.
  ENDLOOP.

  IF  sy-subrc  <>  0.
    MESSAGE e001 WITH '부가세조정할 문서를 선택하세요.'.
  ELSEIF  sy-subrc  =  0  AND
          l_cnt  >  1.
    MESSAGE e001 WITH '부가세조정은 건별로 수행됩니다.'.
  ENDIF.

  CALL SCREEN 2000 STARTING AT 15 7 ENDING AT 80 12.

** 부가세조정 BDC수행.
  IF  sy-ucomm  =  'ENTE'  AND
      g_p_tax  <>  0.

    IF  g_p_tax  >  1000  OR
        g_p_tax  < -1000.
      MESSAGE e001 WITH '1000원 이상으로는 조정할수 없습니다.'.
      EXIT.
    ENDIF.

    IF  g_p_tax  >  0.
      g_p_auart  =  'ZDR'.
    ELSEIF  g_p_tax  <  0.
      g_p_auart  =  'ZCR'.
      g_p_tax  =  g_p_tax  *  -1.
    ENDIF.

    g_c_tax  =  g_p_tax.

    SELECT  SINGLE
            vkorg vtweg spart vkbur vkgrp
      INTO (g_p_vkorg, g_p_vtweg, g_p_spart,
            g_p_vkbur, g_p_vkgrp)
      FROM  vbak
     WHERE  vbeln  =  l_vbeln.

    SELECT  SINGLE fkdat
      INTO  l_fkdat
      FROM  vbrk
     WHERE  vbeln  =  g_itab_t-vbeln.

    g_p_date  =  l_fkdat.

    PERFORM  bdc_process_rtn2.

  ENDIF.

ENDFORM.                    " ztax_calc_rtn

*&---------------------------------------------------------------------*
*&      Form  bdc_process_rtn2
*&---------------------------------------------------------------------*
FORM bdc_process_rtn2.

  CLEAR : bdctab, g_msg_t.
  REFRESH : bdctab, g_msg_t.

  PERFORM  record_rtn2.

** Transaction option
  ctu_params-dismode  =  g_imode.
  ctu_params-updmode  =  'S'.
  ctu_params-racommit =  'X'.

  CALL TRANSACTION 'VA01' USING bdctab
                          OPTIONS FROM ctu_params
                          MESSAGES INTO g_msg_t.

  PERFORM  message_rtn2.

ENDFORM.                    " bdc_process_rtn2

*&---------------------------------------------------------------------*
*&      Form  record_rtn2
*&---------------------------------------------------------------------*
FORM record_rtn2.

  PERFORM  dynpro  USING :
                   'X'  'SAPMV45A'         '0101',
                   ' '  'BDC_OKCODE'       '/00',
                   ' '  'VBAK-AUART'       g_p_auart,
                   ' '  'VBAK-VKORG'       g_p_vkorg,
                   ' '  'VBAK-VTWEG'       g_p_vtweg,
                   ' '  'VBAK-SPART'       g_p_spart,
                   ' '  'VBAK-VKBUR'       g_p_vkbur,
                   ' '  'VBAK-VKGRP'       g_p_vkgrp.

  PERFORM  dynpro  USING :
                   'X'  'SAPMV45A'         '4001',
                   ' '  'BDC_OKCODE'       '/00',
                   ' '  'KUAGV-KUNNR'      g_p_kunnr,
                   ' '  'KUWEV-KUNNR'      g_p_kunnr_ship.

  PERFORM  dynpro  USING :
                   'X'  'SAPMV45A'         '4001',
                   ' '  'BDC_OKCODE'       '=KPAR_SUB'.

  PERFORM  dynpro  USING :
                   'X'  'SAPMV45A'         '4002',
                   ' '  'BDC_OKCODE'       '=T\01',
                   ' '  'BDC_CURSOR'  'GVS_TC_DATA-REC-PARTNER_EXT(03)',
                   ' '  'GV_FILTER'        'PARALL',
                   ' '  'GVS_TC_DATA-REC-PARTNER_EXT(03)'
                                           g_p_kunnr.

  PERFORM  dynpro  USING :
                   'X'  'SAPMV45A'         '4002',
                   ' '  'BDC_OKCODE'       '/EBACK',
                   ' '  'VBAK-AUDAT'       g_p_date.

  PERFORM  dynpro  USING :
                   'X'  'SAPMV45A'         '4001',
                   ' '  'BDC_OKCODE'       '/00',
                   ' '  'RV45A-MABNR(01)'  g_p_matnr,
                   ' '  'VBAP-ZMENG(01)'   '1'.


  PERFORM  dynpro  USING :
                  'X'  'SAPMV45A'         '4001',
                  ' '  'BDC_OKCODE'       '=PDE2',
                  ' '  'RV45A-VBAP_SELKZ(01)'  'X'.

  PERFORM  dynpro  USING :
                   'X'  'SAPMV45A'         '4003',
                   ' '  'BDC_OKCODE'       '=T\04',
                   ' '  'VBAP-WERKS'       g_p_werks.

*  PERFORM  dynpro  USING :
*                   'X'  'SAPMV45A'         '4003',
*                   ' '  'BDC_OKCODE'       '=T\04'.


  PERFORM  dynpro  USING :
                   'X'  'SAPMV45A'         '4003',
                   ' '  'BDC_OKCODE'       '=T\05',
                   ' '  'VBKD-FBUDA'       g_p_date.


  PERFORM  dynpro  USING :
                   'X'  'SAPMV45A'         '5003',
                   ' '  'BDC_OKCODE'       '/00',
                   ' '  'KOMV-KWERT(02)'   g_c_tax.

  PERFORM  dynpro  USING :
                   'X'  'SAPMV45A'         '5003',
                   ' '  'BDC_OKCODE'       '=SICH'.

ENDFORM.                    " record_rtn2

*&---------------------------------------------------------------------*
*&      Form  dynpro
*&---------------------------------------------------------------------*
FORM dynpro USING dynbegin fnam fval.

  CLEAR bdctab.

  IF  dynbegin  =  'X'.

    bdctab-dynbegin  =  'X'.
    bdctab-program   =  fnam.
    bdctab-dynpro    =  fval.
    APPEND bdctab.

  ELSE.

    bdctab-fnam      =  fnam.
    bdctab-fval      =  fval.
    APPEND bdctab.

  ENDIF.

ENDFORM.                    " dynpro

*&---------------------------------------------------------------------*
*&      Form  message_rtn2
*&---------------------------------------------------------------------*
FORM message_rtn2 .

  DATA : l_line     TYPE i,
         l_vbeln    LIKE vbak-vbeln,
         l_mesg(70).

  CLEAR : gv_vbeln.
  DESCRIBE TABLE g_msg_t LINES l_line.
  READ TABLE g_msg_t INDEX l_line.

  IF  g_msg_t-msgtyp = 'S'.

    CALL FUNCTION 'MESSAGE_TEXT_BUILD'
      EXPORTING
        msgid               = g_msg_t-msgid
        msgnr               = g_msg_t-msgnr
        msgv1               = g_msg_t-msgv1
        msgv2               = g_msg_t-msgv2
        msgv3               = g_msg_t-msgv3
        msgv4               = g_msg_t-msgv4
      IMPORTING
        message_text_output = l_mesg.

    l_vbeln  =  g_msg_t-msgv2.
    gv_vbeln = l_vbeln." CHM2510-00065
** 성공적으로 수행을 하면 빌링처리를 한다.
    PERFORM  bdc_vf01_rtn   USING  l_vbeln.

  ELSE.

    CALL FUNCTION 'MESSAGE_TEXT_BUILD'
      EXPORTING
        msgid               = g_msg_t-msgid
        msgnr               = g_msg_t-msgnr
        msgv1               = g_msg_t-msgv1
        msgv2               = g_msg_t-msgv2
        msgv3               = g_msg_t-msgv3
        msgv4               = g_msg_t-msgv4
      IMPORTING
        message_text_output = l_mesg.

    g_itab_t-mesg2  =  '오더문서 생성중 ERROR발생'.

  ENDIF.

  g_itab_t-mesg  =  l_mesg.

  MODIFY g_itab_t TRANSPORTING mesg mesg2
                       WHERE chk = 'X'.

ENDFORM.                    " message_rtn2

*&---------------------------------------------------------------------*
*&      Form  bdc_vf01_rtn
*&---------------------------------------------------------------------*
FORM bdc_vf01_rtn  USING    p_vbeln.

  CLEAR : bdctab, g_msg_t.
  REFRESH : bdctab, g_msg_t.

  PERFORM  dynpro  USING :
                   'X'  'SAPMV60A'         '0102',
                   ' '  'BDC_OKCODE'       '=SICH',
                   ' '  'RV60A-FKDAT'      g_p_date,
                   ' '  'KOMFK-VBELN(01)'  p_vbeln.

** Transaction option
  ctu_params-dismode  =  'N'.
  ctu_params-updmode  =  'S'.
  ctu_params-racommit =  'X'.

  CALL TRANSACTION 'VF01' USING bdctab
                          OPTIONS FROM ctu_params
                          MESSAGES INTO g_msg_t.

  PERFORM  message_rtn3.

ENDFORM.                    " bdc_vf01_rtn

*&---------------------------------------------------------------------*
*&      Form  message_rtn3
*&---------------------------------------------------------------------*
FORM message_rtn3 .

  DATA : l_line     TYPE i,
         l_mesg(70).

  DESCRIBE TABLE g_msg_t LINES l_line.
  READ TABLE g_msg_t INDEX l_line.

  IF  g_msg_t-msgtyp = 'S'.

    CALL FUNCTION 'MESSAGE_TEXT_BUILD'
      EXPORTING
        msgid               = g_msg_t-msgid
        msgnr               = g_msg_t-msgnr
        msgv1               = g_msg_t-msgv1
        msgv2               = g_msg_t-msgv2
        msgv3               = g_msg_t-msgv3
        msgv4               = g_msg_t-msgv4
      IMPORTING
        message_text_output = l_mesg.

  ELSE.

    CALL FUNCTION 'MESSAGE_TEXT_BUILD'
      EXPORTING
        msgid               = g_msg_t-msgid
        msgnr               = g_msg_t-msgnr
        msgv1               = g_msg_t-msgv1
        msgv2               = g_msg_t-msgv2
        msgv3               = g_msg_t-msgv3
        msgv4               = g_msg_t-msgv4
      IMPORTING
        message_text_output = l_mesg.

  ENDIF.

  g_itab_t-mesg2  =  l_mesg.

  MODIFY g_itab_t TRANSPORTING mesg2
                       WHERE chk = 'X'.

ENDFORM.                    " message_rtn3
*&---------------------------------------------------------------------*
*&      Form  zchg_calc_rtn
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM zchg_calc_rtn .

  DATA : l_vbeln LIKE vbrp-vbeln,
         l_posnr LIKE vbrp-posnr,
         l_cnt   TYPE i.
  DATA : ls_matnr LIKE vbap-matnr.

  DATA : l_sum_menge LIKE mseg-menge,
         l_menge     LIKE mseg-menge,
         l_shkzg     LIKE mseg-shkzg,
         l_sum_fkimg LIKE vbrp-fkimg,
         l_vf_fkimg  LIKE vbrp-fkimg.

  CLEAR : bdctab, bdctab[],
          l_vbeln, l_posnr, l_cnt.

  l_cnt  =  0.

  LOOP AT g_itab_t WHERE chk = 'X'.

    CHECK g_itab_t-pstyv EQ 'ZDIE'.

    CLEAR: l_sum_menge, l_menge, l_shkzg, ls_matnr.

    SELECT SINGLE matnr
      INTO ls_matnr
      FROM vbap
     WHERE vbeln = g_itab_t-vbeln
       AND posnr = g_itab_t-posnr.


    SELECT menge shkzg
      INTO (l_menge, l_shkzg)
      FROM matdoc
     WHERE werks = g_itab_t-werks
       AND matnr = ls_matnr
       AND kdauf = g_itab_t-vbeln
       AND kdpos = g_itab_t-posnr
       AND budat >= g_fkdat_low
       AND budat <= g_fkdat_high.


*    select menge shkzg
*      into (l_menge, l_shkzg)
*      from zmseg
*     where MATNR = ls_matnr
*       and KDAUF = g_itab_t-vbeln
*       and KDPOS = g_itab_t-POSNR
*       and BUDAT >= g_fkdat_low
*       and BUDAT <= g_fkdat_high.

      IF l_shkzg = 'S'.
        l_sum_menge = l_sum_menge + l_menge.
      ELSE.
        l_sum_menge = l_sum_menge - l_menge.
      ENDIF.

    ENDSELECT.

    CLEAR:  l_menge, l_shkzg, l_sum_fkimg, l_vf_fkimg.

    SELECT  SUM( b~fkimg )
      INTO  l_vf_fkimg
      FROM  vbrk AS a INNER JOIN vbrp AS b
        ON  a~vbeln = b~vbeln
     WHERE  a~fksto = ' '
       AND  b~vgbel  =  g_itab_t-vbeln
       AND  b~vgpos  =  g_itab_t-posnr
       AND  a~fkdat  >= g_fkdat_low
       AND  a~fkdat  <= g_fkdat_high
       AND  a~fkart  NOT IN ('ZF2', 'ZRE', 'S1', 'S2',
                    'FAS', 'B4', 'ZDRM')
*-> CCM : 13.04.2023 11:15:36 / ZLSGSD4
       AND  a~draft  = space
       AND  b~draft  = space.
*<-


    IF l_vf_fkimg <> l_sum_menge.
      MOVE '당월 빌링건이 남아있습니다.' TO g_itab_t-mesg3.

      MODIFY g_itab_t TRANSPORTING mesg3
                         WHERE vbeln = g_itab_t-vbeln
                           AND posnr = g_itab_t-posnr.


    ELSE.

** 익월을 계산하는 Function.
      CALL FUNCTION 'RP_CALC_DATE_IN_INTERVAL'   " 당월 + 1월
        EXPORTING
          date      = g_fkdat_low                " 기준월
          days      = '00'
          months    = '01'                   " 구하고자하는월
          signum    = '+'                    " '+' or '-'
          years     = '00'
        IMPORTING
          calc_date = g_fkdat_return.                " Date


      g_bdc_t-vbeln  =  g_itab_t-vbeln.
      g_bdc_t-posnr  =  g_itab_t-posnr.
      g_bdc_t-date1  =  g_fkdat_return.

      APPEND  g_bdc_t.
      CLEAR:  g_bdc_t, g_fkdat_return.

    ENDIF.

    l_cnt  =  l_cnt  +  1.
    CLEAR : l_vf_fkimg.

  ENDLOOP.

  IF  sy-subrc  <>  0  OR
      l_cnt  =  0.
    MESSAGE e001 WITH '대금청구일 이월 처리할 문서를 선택하세요'.
  ENDIF.
  CLEAR : l_cnt.

  PERFORM  bdc_process_rtn_va01.

ENDFORM.                    " zchg_calc_rtn
*&---------------------------------------------------------------------*
*&      Form  bdc_process_rtn_va01
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM bdc_process_rtn_va01 .
  DATA: g_type TYPE c.

  LOOP AT g_bdc_t.

    PERFORM  record_va01_main_rtn2.

** Transaction option
    ctu_params-dismode  =  g_imode.
    ctu_params-racommit =  'X'.
    ctu_params-updmode  =  'S'.

    CLEAR: g_type.
    g_type = 'K'.
    EXPORT g_type TO MEMORY ID 'ZSD192'.

    CALL TRANSACTION 'VA02' USING bdctab
                            OPTIONS FROM ctu_params
                            MESSAGES INTO g_msg_t.

*    FREE MEMORY ID 'ZSD192'.

    g_bdc_t-subrc = sy-subrc.

    PERFORM message_rtn.

  ENDLOOP.



ENDFORM.                    " bdc_process_rtn_va01
*&---------------------------------------------------------------------*
*&      Form  message_rtn
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM message_rtn .
  DATA : l_line TYPE i.

  DESCRIBE TABLE g_msg_t LINES l_line.
  READ TABLE g_msg_t INDEX l_line.

  IF  g_msg_t-msgtyp = 'S'.

    CALL FUNCTION 'MESSAGE_TEXT_BUILD'
      EXPORTING
        msgid               = g_msg_t-msgid
        msgnr               = g_msg_t-msgnr
        msgv1               = g_msg_t-msgv1
        msgv2               = g_msg_t-msgv2
        msgv3               = g_msg_t-msgv3
        msgv4               = g_msg_t-msgv4
      IMPORTING
        message_text_output = g_bdc_t-mesg.

    g_bdc_t-subrc  =  0.

  ELSE.

    CALL FUNCTION 'MESSAGE_TEXT_BUILD'
      EXPORTING
        msgid               = g_msg_t-msgid
        msgnr               = g_msg_t-msgnr
        msgv1               = g_msg_t-msgv1
        msgv2               = g_msg_t-msgv2
        msgv3               = g_msg_t-msgv3
        msgv4               = g_msg_t-msgv4
      IMPORTING
        message_text_output = g_bdc_t-mesg.

  ENDIF.

  g_itab_t-mesg3  =  g_bdc_t-mesg.

  MODIFY g_itab_t TRANSPORTING mesg3
                         WHERE vbeln = g_bdc_t-vbeln
                           AND posnr = g_bdc_t-posnr.

  MODIFY g_bdc_t TRANSPORTING subrc mesg
                       WHERE vbeln = g_bdc_t-vbeln
                         AND posnr = g_bdc_t-posnr.

ENDFORM.                    " message_rtn
*&---------------------------------------------------------------------*
*&      Form  record_va01_main_rtn2
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM record_va01_main_rtn2 .

  CLEAR : bdctab, g_msg_t.
  REFRESH : bdctab, g_msg_t.

  PERFORM  dynpro  USING :
                   'X'  'SAPMV45A'         '0102',
                   ' '  'BDC_OKCODE'       '/00',
                   ' '  'VBAK-VBELN'       g_bdc_t-vbeln.

  PERFORM  dynpro  USING :
                   'X'  'SAPMV45A'         '4001',
                   ' '  'BDC_OKCODE'       '=POPO'.

  PERFORM  dynpro  USING :
                   'X'  'SAPMV45A'         '0251',
                   ' '  'BDC_OKCODE'       '=POSI',
                   ' '  'RV45A-POSNR'      g_bdc_t-posnr.

  PERFORM  dynpro  USING :
                   'X'  'SAPMV45A'         '4001',
                   ' '  'BDC_OKCODE'       '=ITEM',
                   ' '  'RV45A-VBAP_SELKZ(01)' 'X'.

  PERFORM  dynpro  USING :
                   'X'  'SAPMV45A'         '4003',
                   ' '  'BDC_OKCODE'       '=T\04'.

  PERFORM  dynpro  USING :
                   'X'  'SAPMV45A'         '4003',
                   ' '  'BDC_OKCODE'       '=SICH',
                   ' '  'BDC_CURSOR'       'VBKD-FBUDA',
                   ' '  'VBKD-FKDAT'       g_bdc_t-date1.


ENDFORM.                    " record_va01_main_rtn2
*&---------------------------------------------------------------------*
*& Form MODI_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM modi_data .

  DATA : lt_for LIKE TABLE OF g_itab_t WITH EMPTY KEY.

  CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
    EXPORTING
      text   = 'Data Loading....'
    EXCEPTIONS
      OTHERS = 1.

  __cle : gt_pod_list, gt_1010.
  lt_for[] = g_itab_t[].
  SORT lt_for BY vbeln.
  DELETE ADJACENT DUPLICATES FROM lt_for COMPARING vbeln.
  IF lt_for[] IS NOT INITIAL.
    SELECT zgtsdt1010~* INTO CORRESPONDING FIELDS OF TABLE @gt_1010
      FROM zgtsdt1010
       FOR ALL ENTRIES IN @lt_for
     WHERE vbeln_vf = @lt_for-vbeln
       AND loekz = @space.
  ENDIF.

  lt_for[] = g_itab_t[].
  SORT lt_for BY vbeln.
  DELETE ADJACENT DUPLICATES FROM lt_for COMPARING vbeln.
  IF lt_for[] IS NOT INITIAL.
    WITH +mblnr AS (
      SELECT vbeln, posnv, vbelv, posnn, rfmng
        FROM vbfa
       WHERE vbtyp_n = 'p'
         AND vbtyp_v = 'J'
         AND bwart   = '601'
       ORDER BY vbeln DESCENDING )
    SELECT DISTINCT b~vbeln, b~posnr, d~fkdat AS podat,
           a~vbeln AS vbeln_vf," A~POSNR AS POSNR_VF,
           m~vbeln AS mblnr, m~rfmng, m~posnv AS posnn
      FROM @lt_for AS c INNER JOIN vbrp AS a
        ON c~vbeln = a~vbeln
     INNER JOIN vbrk AS d
        ON a~vbeln = d~vbeln
     INNER JOIN lips AS b
        ON a~vgbel = b~vbeln
*       AND A~VGPOS = B~POSNR
     INNER JOIN +mblnr AS m
        ON m~vbelv = b~vbeln
       AND m~posnv = b~posnr
     WHERE b~bwart = '687'
       AND fksto = @space
       AND sfakn = @space
      INTO CORRESPONDING FIELDS OF TABLE @gt_pod_list.
  ENDIF.

  LOOP AT g_itab_t.

    SELECT SINGLE name INTO g_itab_t-text01 FROM j_1bbranch
                               WHERE branch = g_itab_t-branch
                                AND  bukrs = g_p_vkorg.

    SELECT SINGLE bezei INTO g_itab_t-text02 FROM tvkbt
                               WHERE vkbur = g_itab_t-vkbur
                                AND  spras = sy-langu.

    SELECT SINGLE bezei INTO g_itab_t-text03 FROM tvgrt
                               WHERE vkgrp = g_itab_t-vkgrp
                                AND  spras = sy-langu.

    SELECT SINGLE vtext INTO g_itab_t-text04 FROM tvtwt
                               WHERE vtweg = g_itab_t-vtweg
                                AND  spras = sy-langu.

    SELECT SINGLE vtext INTO g_itab_t-text05 FROM tvkggt
                               WHERE kdkgr = g_itab_t-kdkg4
                                AND  spras = sy-langu.

    SELECT SINGLE name1 INTO g_itab_t-name1  FROM kna1
                               WHERE kunnr = g_itab_t-kunnr.

    IF g_itab_t-vbeln+0(1) = '6' OR g_itab_t-vbeln+0(1) = '2'.

      SELECT SINGLE pstyv INTO g_itab_t-pstyv  FROM lips
                                 WHERE vbeln = g_itab_t-vbeln
                                   AND posnr = g_itab_t-posnr.


    ENDIF.
**** 전자세금계산서 상태 description을 가져온다.
    IF g_itab_t-billstat IS NOT INITIAL.
      CLEAR: lv_domain.
      lv_domain = g_itab_t-billstat.

      CALL FUNCTION 'DOMAIN_VALUE_GET'
        EXPORTING
          i_domname  = 'ZDBILLSTAT'
          i_domvalue = lv_domain
        IMPORTING
          e_ddtext   = g_itab_t-billstatx
        EXCEPTIONS
          not_exist  = 1
          OTHERS     = 2.

    ENDIF.

    READ TABLE gt_1010 TRANSPORTING NO FIELDS WITH KEY k_key COMPONENTS
                        vbeln_vf = g_itab_t-vbeln.
    IF sy-subrc = 0.
      g_itab_t-pod = |X|.
    ENDIF.

    READ TABLE gt_pod_list TRANSPORTING NO FIELDS WITH KEY k_key
                           COMPONENTS vbeln_vf = g_itab_t-vbeln.
    IF sy-subrc = 0.
      g_itab_t-pod = |X|.
    ENDIF.

    MODIFY  g_itab_t.
    CLEAR  g_itab_t.

  ENDLOOP.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form BILLING_CANCEL
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM billing_cancel .

  DATA : l_vbeln LIKE vbrp-vbeln,
         l_posnr LIKE vbrp-posnr,
         lv_err  TYPE c,
         l_cnt   TYPE i.
  DATA : ls_matnr LIKE vbap-matnr.

  DATA : l_sum_menge LIKE mseg-menge,
         l_menge     LIKE mseg-menge,
         l_shkzg     LIKE mseg-shkzg,
         l_sum_fkimg LIKE vbrp-fkimg,
         l_vf_fkimg  LIKE vbrp-fkimg.

  CLEAR : bdctab, bdctab[],
          l_vbeln, l_posnr, l_cnt.

  __cle : gt_pod, gt_vf_c.

  l_cnt  =  0.

  LOOP AT g_itab_t WHERE chk = 'X'.

    IF g_itab_t-pod IS INITIAL.
      IF g_itab_t-vbeln(1) = |8|.
        MOVE-CORRESPONDING g_itab_t TO gt_vf_c.
        APPEND gt_vf_c. CLEAR gt_vf_c.
        l_cnt  =  l_cnt  +  1.
      ENDIF.
    ELSE.
      MOVE-CORRESPONDING g_itab_t TO gt_pod.
      APPEND gt_pod. CLEAR gt_pod.
      l_cnt  =  l_cnt  +  1.
    ENDIF.

  ENDLOOP.

  IF  sy-subrc  <>  0  OR l_cnt  =  0.
    MESSAGE e001 WITH '대금청구 취소할 문서를 선택하세요'.
  ENDIF.

  CLEAR : l_cnt.

*일반 빌링 취소
  LOOP AT gt_vf_c.
    __cle : gt_vbrp.
    SELECT a~vgbel, a~vgpos
      INTO CORRESPONDING FIELDS OF TABLE @gt_vbrp
      FROM vbrp AS a INNER JOIN vbrk AS b
        ON a~vbeln = b~vbeln
     WHERE a~vbeln = @gt_vf_c-vbeln
       AND b~sfakn = @space
       AND b~fksto = @space.
    IF sy-subrc = 0.
      PERFORM cancel_billing USING gt_vf_c-vbeln '' CHANGING gt_vf_c-err.
    ENDIF.
    MODIFY gt_vf_c.

*에러 없을 경우 해당 라인 삭제
    CHECK gt_vf_c-err IS INITIAL.
    READ TABLE g_itab_t WITH KEY vbeln = gt_vf_c-vbeln.
    IF sy-subrc = 0.
      DELETE g_itab_t INDEX sy-tabix.
    ENDIF.
  ENDLOOP.

**********************************************************************
*POD 빌링 취소
  LOOP AT gt_pod.

    CLEAR lv_err.
    __cle : gt_vbrp, gt_lip_sts. CLEAR gs_lip_sts.

    SELECT a~vgbel, a~vgpos
      INTO CORRESPONDING FIELDS OF TABLE @gt_vbrp
      FROM vbrp AS a INNER JOIN vbrk AS b
        ON a~vbeln = b~vbeln
     WHERE a~vbeln = @gt_pod-vbeln
       AND b~sfakn = @space
       AND b~fksto = @space.
    IF sy-subrc = 0.
      PERFORM cancel_billing USING gt_pod-vbeln 'X' CHANGING lv_err.
    ENDIF.

    CHECK lv_err IS INITIAL.

*POD 602(취소) 생성
    DATA(lt_do) = FILTER #( gt_1010 USING KEY k_key
                                    WHERE vbeln_vf = gt_pod-vbeln ).
    SORT lt_do BY mblnr.
    DELETE ADJACENT DUPLICATES FROM lt_do COMPARING mblnr.
    LOOP AT lt_do INTO DATA(ls_do) USING KEY k_key
                                   WHERE vbeln_vf = gt_pod-vbeln.

      PERFORM create_pod_602 USING ls_do-mblnr
                          CHANGING lv_err.

    ENDLOOP.

*에러 없을 경우 해당 라인 삭제
    CHECK lv_err IS INITIAL.
    READ TABLE g_itab_t WITH KEY vbeln = gt_pod-vbeln.
    IF sy-subrc = 0.
      DELETE g_itab_t INDEX sy-tabix.
    ENDIF.

  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CANCEL_BILLING
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GT_POD_VBELN
*&      <-- LV_ERR
*&---------------------------------------------------------------------*
FORM cancel_billing  USING    pv_vbeln
                              pv_pod
                     CHANGING pv_err.

  DATA : lv_pod TYPE c.

  CLEAR : bdctab, g_msg_t, ctu_params.
  REFRESH : bdctab, g_msg_t.
  PERFORM  dynpro  USING :
                'X'  'SAPMV60A'         '0102',
                ' '  'KOMFK-VBELN(1)'    pv_vbeln,
                ' '  'BDC_OKCODE'       '/00'.

  PERFORM  dynpro  USING :
                'X'  'SAPMV60A'         '0103',
                ' '  'BDC_OKCODE'       '=SICH'.

  ctu_params-dismode  =  'E'.
  ctu_params-updmode  =  'S'.
  ctu_params-racommit =  'X'.

  lv_pod = pv_pod.
  EXPORT lv_pod TO MEMORY ID 'ZGTSDPOD01'.

  CALL TRANSACTION 'VF11' USING bdctab
                          OPTIONS FROM ctu_params
                          MESSAGES INTO g_msg_t.
  DO 10 TIMES.

    SELECT SINGLE a~vbeln INTO @DATA(l_vbeln)
      FROM vbrp AS a INNER JOIN vbrk AS b
        ON a~vbeln = b~vbeln
     WHERE a~vbeln = @pv_vbeln
       AND ( b~fksto NE @space OR b~sfakn NE @space ).
    IF sy-subrc = 0.
      EXIT.
    ELSE.
      WAIT UP TO '0.3' SECONDS.
    ENDIF.
  ENDDO.

  IF l_vbeln IS INITIAL.
    MESSAGE s001 WITH '빌링취소 실패 했습니다.' DISPLAY LIKE 'E'.
    pv_err = |X|.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form CREATE_POD_602
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GT_POD_VBELN
*&      <-- LV_ERR
*&---------------------------------------------------------------------*
FORM create_pod_602  USING pv_mblnr
                  CHANGING pv_err.

  DATA : lv_mblnr TYPE mblnr,
         ls_1010  TYPE zgtsdt1010,
         lt_mseg  TYPE TABLE OF mesg.

  DATA(lt_lip) = FILTER #( gt_1010 USING KEY k_key2
                                   WHERE mblnr = pv_mblnr ).
  IF lt_lip[] IS NOT INITIAL.
    SELECT b~vbeln, b~posnr, b~charg, lfimg, meins, b~vgbel,
           b~vgpos, a~fkstk, a~gbstk, a~pdstk, fksta, pdsta,
           kzpod, uecha
      FROM likp AS a INNER JOIN lips AS b
        ON a~vbeln = b~vbeln
       FOR ALL ENTRIES IN @lt_lip
     WHERE b~vbeln = @lt_lip-vbeln
      INTO CORRESPONDING FIELDS OF TABLE @gt_lip_sts.
  ENDIF.

  CHECK lt_lip[] IS NOT INITIAL.

*602생성전 LIKP/LIPS 상태값을 조정한다.
  SORT lt_lip BY vbeln posnr posnn.
  LOOP AT lt_lip INTO DATA(ls_sts).
    PERFORM update_stat USING ls_sts-vbeln
                              ls_sts-posnr
                              ls_sts-posnn
                              '602'.
  ENDLOOP.

  READ TABLE lt_lip INTO ls_sts INDEX 1.
  __cle : lt_mseg.
  SELECT mseg~* INTO CORRESPONDING FIELDS OF TABLE @lt_mseg
    FROM mseg
   WHERE mblnr    = @pv_mblnr
     AND mjahr    = @ls_sts-podat(4)
     AND vbeln_im = @ls_sts-vbeln.

*해당 601이동문서를 문서범주를 'R'로 변경
  UPDATE vbfa
     SET vbtyp_n = 'R'
   WHERE vbeln = pv_mblnr.
  COMMIT WORK.

*WS_REVERSE_GOODS_ISSUE
  SUBMIT zgtsdr0120_cancel WITH p_vbeln  = ls_sts-vbeln
                           WITH p_budat  = ls_sts-podat
                           WITH p_mblnr  = ls_sts-mblnr
                           WITH p_tcode  = 'VL09'
                           WITH p_vbtyp  = 'T'
                           WITH p_mjahr  = ls_sts-podat(4)
                           AND RETURN.

  IMPORT lv_mblnr FROM MEMORY ID 'ZPODCANC'.
  FREE MEMORY ID 'ZPODCANC'.

  IF lv_mblnr IS INITIAL.

    DATA(lt_tmp) = FILTER #( gt_1010[] USING KEY k_key3 WHERE vbeln = ls_sts-vbeln ).
    SORT lt_tmp BY mblnr.
    DELETE ADJACENT DUPLICATES FROM lt_tmp COMPARING mblnr.
    IF lines( lt_tmp ) = 1.
*WS_REVERSE_GOODS_ISSUE 실패시 VLPOD BDC 수행
      PERFORM pod_cancel_bdc USING ls_sts pv_err.
    ELSE.
      pv_err = |X|.
      PERFORM roll_back_status.
    ENDIF.

  ELSE.
    " T성공후 상태 업데이트
    PERFORM set_cancel_status_ok USING ls_sts lv_mblnr.

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form UPDATE_STAT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> PV_VBELN
*&      --> PV_POSNR
*&---------------------------------------------------------------------*
FORM update_stat  USING    pv_vbeln
                           pv_posnr
                           pv_posnn
                           pv_type.

  DATA : lv_kzpod TYPE lips-kzpod.

  CASE pv_type.

    WHEN '602'.

      UPDATE likp
         SET fkstk = 'A'
             gbstk = 'B'
             pdstk = 'B'
       WHERE vbeln = pv_vbeln.

      UPDATE lips
         SET fksta = 'A'
             gbsta = 'B'
             pdsta = 'B'
             kzpod = 'A'
       WHERE vbeln = pv_vbeln.

  ENDCASE.

  COMMIT WORK.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form ROLL_BACK_STATUS
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM roll_back_status .


  LOOP AT gt_lip_sts INTO gs_lip_sts.

    UPDATE likp
       SET fkstk = gs_lip_sts-fkstk
           gbstk = gs_lip_sts-gbstk
           pdstk = gs_lip_sts-pdstk
     WHERE vbeln = gs_lip_sts-vbeln.

    UPDATE lips
       SET fksta = gs_lip_sts-fksta
           pdsta = gs_lip_sts-pdsta
           kzpod = gs_lip_sts-kzpod
     WHERE vbeln = gs_lip_sts-vbeln
       AND posnr = gs_lip_sts-posnr.

  ENDLOOP.

  COMMIT WORK.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form BILLING_CANCEL_M
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM billing_cancel_m .

  CHECK 1 = 2.


  DATA : l_vbeln LIKE vbrp-vbeln,
         l_posnr LIKE vbrp-posnr,
         lv_ok   TYPE c,
         lv_err  TYPE c,
         l_cnt   TYPE i.
  DATA : ls_matnr LIKE vbap-matnr.

  DATA : l_sum_menge LIKE mseg-menge,
         l_menge     LIKE mseg-menge,
         l_shkzg     LIKE mseg-shkzg,
         l_sum_fkimg LIKE vbrp-fkimg,
         l_vf_fkimg  LIKE vbrp-fkimg.

  CLEAR : bdctab, bdctab[],
          l_vbeln, l_posnr, l_cnt.

  __cle gt_pod.

  l_cnt  =  0.

  LOOP AT g_itab_t WHERE chk = 'X'.

    IF g_itab_t-pod IS INITIAL.

      MOVE 'POD 빌링 문서가 아닙니다.' TO g_itab_t-mesg3.
      MODIFY g_itab_t TRANSPORTING mesg3
                         WHERE vbeln = g_itab_t-vbeln
                           AND posnr = g_itab_t-posnr.
    ELSE.
      MOVE-CORRESPONDING g_itab_t TO gt_pod.
      APPEND gt_pod. CLEAR gt_pod.
      l_cnt  =  l_cnt  +  1.
    ENDIF.

  ENDLOOP.

  IF  sy-subrc  <>  0  OR l_cnt  =  0.
    MESSAGE e001 WITH 'POD 취소할 문서를 선택하세요'.
  ENDIF.

  CLEAR : l_cnt.

  LOOP AT gt_pod.

    __cle : gt_vbrp, gt_lip_sts. CLEAR gs_lip_sts.

*빌링 취소
    SELECT a~vgbel, a~vgpos
      INTO CORRESPONDING FIELDS OF TABLE @gt_vbrp
      FROM vbrp AS a INNER JOIN vbrk AS b
        ON a~vbeln = b~vbeln
     WHERE a~vbeln = @gt_pod-vbeln
       AND b~sfakn = @space
       AND b~fksto = @space.
    IF sy-subrc = 0.
      PERFORM cancel_billing USING gt_pod-vbeln 'X' CHANGING lv_err.
    ENDIF.

    CHECK lv_err IS INITIAL.

*POD 602(취소) 생성
    DATA(lt_do) = FILTER #( gt_pod_list USING KEY k_key
                              WHERE vbeln_vf = gt_pod-vbeln ).

    DATA(lt_mblnr) = FILTER #( gt_pod_list USING KEY k_key
                              WHERE vbeln_vf = gt_pod-vbeln ).
    SORT lt_do BY vbeln.
    DELETE ADJACENT DUPLICATES FROM lt_do COMPARING vbeln.

    DELETE lt_mblnr WHERE mblnr IS INITIAL.
    SORT lt_mblnr BY mblnr DESCENDING.
    DELETE ADJACENT DUPLICATES FROM lt_mblnr COMPARING mblnr.

*빌링의 DO 별  루프
    LOOP AT lt_do INTO DATA(ls_do).
*DO의 자재문서로  루프
      LOOP AT lt_mblnr INTO DATA(ls_mblnr) USING KEY k_key3
                       WHERE vbeln = ls_do-vbeln.

        PERFORM create_pod_602_m USING ls_mblnr-mblnr
                              CHANGING lv_err lv_ok.

      ENDLOOP.
    ENDLOOP.

  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CREATE_POD_602_M
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GT_POD_VBELN
*&      <-- LV_ERR
*&---------------------------------------------------------------------*
FORM create_pod_602_m  USING pv_mblnr
                    CHANGING pv_err
                             pv_ok.

  DATA : ls_emkpf TYPE emkpf,
         ls_1010  TYPE zgtsdt1010,
         lt_mesg  TYPE TABLE OF mesg.

  DATA(lt_lip) = FILTER #( gt_pod_list USING KEY k_key4
                                   WHERE mblnr = pv_mblnr ).
  IF lt_lip[] IS NOT INITIAL.
    SELECT b~vbeln, b~posnr, b~charg, lfimg, meins, b~vgbel,
           b~vgpos, a~fkstk, a~gbstk, a~pdstk, fksta, pdsta,
           kzpod, uecha
      FROM likp AS a INNER JOIN lips AS b
        ON a~vbeln = b~vbeln
       FOR ALL ENTRIES IN @lt_lip
     WHERE b~vbeln = @lt_lip-vbeln
      INTO CORRESPONDING FIELDS OF TABLE @gt_lip_sts.
  ENDIF.

  CHECK lt_lip[] IS NOT INITIAL.

*602생성전 LIKP/LIPS 상태값을 조정한다.
  SORT lt_lip BY vbeln posnr posnn.
  LOOP AT lt_lip INTO DATA(ls_sts).
    PERFORM update_stat USING ls_sts-vbeln
                              ls_sts-posnr
                              ls_sts-posnn
                              '602'.
  ENDLOOP.

  READ TABLE lt_lip INTO ls_sts INDEX 1.

*해당 601이동문서를 문서범주를 'R'로 변경
  UPDATE vbfa
     SET vbtyp_n = 'R'
   WHERE vbeln = pv_mblnr.
  COMMIT WORK.

  __cle : lt_mesg. CLEAR ls_emkpf.
  TRY.
      CALL FUNCTION 'WS_REVERSE_GOODS_ISSUE'
        EXPORTING
          i_vbeln                   = ls_sts-vbeln
          i_budat                   = ls_sts-podat
          i_mblnr                   = ls_sts-mblnr
          i_tcode                   = 'VL09'
          i_vbtyp                   = 'T'
          i_mjahr                   = ls_sts-podat(4)
        IMPORTING
          es_emkpf                  = ls_emkpf
        TABLES
          t_mesg                    = lt_mesg
        EXCEPTIONS
          error_reverse_goods_issue = 1
          OTHERS                    = 2.
    CATCH cx_root INTO DATA(lo_err).
      PERFORM roll_back_status.
      MESSAGE s001 WITH lo_err->get_longtext( ) DISPLAY LIKE 'E'.
      EXIT.
  ENDTRY.

  IF ls_emkpf-mblnr  IS NOT INITIAL.

    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      EXPORTING
        wait = 'X'.

*601 업데이트
    UPDATE vbfa
       SET vbtyp_n = 'p'
     WHERE vbeln = pv_mblnr.

    UPDATE likp
       SET wbstk = 'C'
     WHERE vbeln = ls_sts-vbeln.

    UPDATE lips
       SET wbsta = 'C'
           kzpod = 'B'
     WHERE vbeln = ls_sts-vbeln.

*602 업데이트
    UPDATE vbfa
       SET vbtyp_n = 'p'
     WHERE vbeln = ls_emkpf-mblnr.

**********************************************************************
*LOG 업데이트
**********************************************************************
    zgtsd_cl_common=>set_timestamp( EXPORTING iv_gubun =
      zgtsd_u CHANGING  cs_timestamp = ls_1010-timestamp ).

    UPDATE zgtsdt1010
       SET loekz    = 'X'
           aedat    = ls_1010-aedat
           aezeit   = ls_1010-aezeit
           aenam    = ls_1010-aenam
           aedatlo  = ls_1010-aedatlo
           aetimlo  = ls_1010-aetimlo
     WHERE vbeln = ls_sts-vbeln
       AND mblnr = pv_mblnr
       AND loekz = space.

    COMMIT WORK.

*** 강제 취소시 문서흐름에 나타나지 않는 문제가 있음 VBFA Table에 Insert
*    PERFORM CREATE_VBFA_CANC_DATA USING LS_EMKPF-MBLNR
*                                        LS_STS.

  ELSE.
    PERFORM roll_back_status.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CALL_VBELN
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> G_ITAB_T_VBELN
*&---------------------------------------------------------------------*
FORM call_vbeln  USING    pv_vbeln.

  SELECT SINGLE mandt INTO sy-mandt
    FROM vbrk
   WHERE vbeln = pv_vbeln.
  IF sy-subrc = 0.
    SET PARAMETER ID: 'VF'    FIELD   pv_vbeln.
    CALL TRANSACTION  'VF03' AND SKIP FIRST SCREEN.
    COMMIT WORK AND WAIT.
    EXIT.
  ENDIF.

  SELECT SINGLE mandt INTO sy-mandt
    FROM likp
   WHERE vbeln = pv_vbeln.
  IF sy-subrc = 0.
    SET PARAMETER ID: 'VL'    FIELD   pv_vbeln.
    CALL TRANSACTION  'VL03N' AND SKIP FIRST SCREEN.
    EXIT.
  ENDIF.

  SELECT SINGLE mandt INTO sy-mandt
    FROM vbak
   WHERE vbeln = pv_vbeln.
  IF sy-subrc = 0.
    SET PARAMETER ID: 'AUN'    FIELD   pv_vbeln.
    CALL TRANSACTION  'VA03' AND SKIP FIRST SCREEN.
    EXIT.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_CANCEL_STATUS_OK
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LS_STS
*&---------------------------------------------------------------------*
FORM set_cancel_status_ok  USING    ps_sts STRUCTURE zgtsdt1010
                                    pv_mblnr.

  DATA : ls_1010  TYPE zgtsdt1010.

**********************************************************************
*601 업데이트
**********************************************************************
  UPDATE vbfa
     SET vbtyp_n = 'p'
   WHERE vbeln = ps_sts-mblnr.

  UPDATE likp
     SET wbstk = 'C'
   WHERE vbeln = ps_sts-vbeln.

  UPDATE lips
     SET wbsta = 'C'
         kzpod = 'B'
   WHERE vbeln = ps_sts-vbeln.

**********************************************************************
*602 업데이트
**********************************************************************
  UPDATE vbfa
     SET vbtyp_n = 'p'
   WHERE vbeln = pv_mblnr.

* 서비스 취소 데이터 삭제
  DELETE FROM vbfa
   WHERE vbelv    = @ps_sts-vbeln
     AND bwart    = @space
     AND plmin    = '-'
     AND rfmng    = 0
     AND vbtyp_n  = 'h'.
**********************************************************************
*LOG 업데이트
**********************************************************************
  zgtsd_cl_common=>set_timestamp( EXPORTING iv_gubun     = zgtsd_u
                                  CHANGING  cs_timestamp = ls_1010-timestamp ).

  UPDATE zgtsdt1010
     SET loekz    = 'X'
         aedat    = ls_1010-aedat
         aezeit   = ls_1010-aezeit
         aenam    = ls_1010-aenam
         aedatlo  = ls_1010-aedatlo
         aetimlo  = ls_1010-aetimlo
   WHERE vbeln = ps_sts-vbeln
     AND mblnr = ps_sts-mblnr
     AND loekz = space.

  COMMIT WORK.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form POD_CANCEL_BDC
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LS_STS
*&      --> PV_ERR
*&---------------------------------------------------------------------*
FORM pod_cancel_bdc  USING    ps_sts STRUCTURE zgtsdt1010
                              pv_err.

  CLEAR : bdctab, g_msg_t.
  REFRESH : bdctab, g_msg_t.

*POD 취소를 위한 상태 업데이트
  UPDATE lips
     SET pdsta = 'C'
   WHERE vbeln = ps_sts-vbeln.
  COMMIT WORK.

  PERFORM  dynpro  USING :
                'X'  'SAPMV50A'         '4006',
                ' '  'BDC_CURSOR'       'LIKP-VBELN',
                ' '  'LIKP-VBELN'       ps_sts-vbeln,
                ' '  'BDC_OKCODE'       '=ENT2'.


  PERFORM  dynpro  USING :
                'X'  'SAPMV50A'         '1000',
                ' '  'BDC_SUBSCR'       'SAPMV50A',
                ' '  'BDC_OKCODE'       '=PODS'.

  PERFORM  dynpro  USING :
                'X'  'SAPMV50A'         '1000',
                ' '  'BDC_SUBSCR'       'SAPMV50A',
                ' '  'LIKP-PODAT'       ps_sts-podat,
                ' '  'BDC_OKCODE'       '=SICH_T'.

  ctu_params-dismode  =  'E'.
  ctu_params-updmode  =  'S'.
  ctu_params-racommit =  'X'.

  CALL TRANSACTION 'VLPOD' USING bdctab
                          OPTIONS FROM ctu_params
                          MESSAGES INTO g_msg_t.
  DO 5 TIMES.

    SELECT SINGLE mblnr INTO @DATA(lv_mblnr)
      FROM mseg
     WHERE smbln = @ps_sts-mblnr.
    IF sy-subrc = 0.
      EXIT.
    ELSE.
      WAIT UP TO '0.3' SECONDS.
    ENDIF.
  ENDDO.

*602  이동 문서 생성시 VBFA로그생성...
  IF lv_mblnr IS INITIAL.
    pv_err = |X|.
  ELSE.

* 강제 취소시 문서흐름에 나타나지 않는 문제가 있음 VBFA Table에 Insert
    PERFORM make_vbfa_602 USING ps_sts lv_mblnr.

    " T성공후 상태 업데이트
    PERFORM set_cancel_status_ok USING ps_sts lv_mblnr.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form MAKE_VBFA_602
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> PS_STS
*&      --> LV_MBLNR
*&---------------------------------------------------------------------*
FORM make_vbfa_602  USING  ps_sts STRUCTURE zgtsdt1010
                           pv_mblnr.

  DATA : lt_vbapf   TYPE TABLE OF vbapf  WITH HEADER LINE,
         lt_vbfavb  TYPE TABLE OF vbfavb WITH HEADER LINE,
         lt_vbfavby TYPE TABLE OF vbfavb WITH HEADER LINE,
         ls_vbfa    TYPE vbfa,
         ls_vbfad   TYPE vbfad.

  SELECT SINGLE mseg~* INTO @DATA(ls_mseg)
    FROM mseg
   WHERE mblnr = @pv_mblnr
     AND mjahr = @ps_sts-podat(4)
     AND bwart = '602'.

  LOOP AT gt_1010 INTO DATA(ls_1010) USING KEY k_key2
                                     WHERE mblnr = ps_sts-mblnr.

    ls_vbfa-vbelv    = ls_1010-vbeln.
    ls_vbfa-posnv    = ls_1010-posnn.
    ls_vbfa-vbeln    = pv_mblnr.
    ls_vbfa-posnn    = ls_mseg-line_id.
    ls_vbfa-vbtyp_n  = 'p'.
    ls_vbfa-rfmng    = ls_1010-lfimg.
    ls_vbfa-meins    = ls_1010-vrkme.
    ls_vbfa-vbtyp_v  = 'J'.
    ls_vbfa-plmin    = '-'.
    ls_vbfa-bwart    = '602'.

    SELECT SINGLE a~matnr, b~waerk, vgbel, vgpos INTO @DATA(ls_lips)
      FROM lips AS a INNER JOIN likp AS b
        ON a~vbeln = b~vbeln
     WHERE a~vbeln = @ls_1010-vbeln
       AND a~posnr = @ls_1010-posnr.
    IF sy-subrc = 0.
      ls_vbfa-matnr  = ls_lips-matnr.
      ls_vbfa-waers  = ls_lips-waerk.
      ls_vbfad-aubel = ls_lips-vgbel.
      ls_vbfad-aupos = ls_lips-vgpos.
    ENDIF.

    ls_vbfad-autyp = 'C'.

    CALL FUNCTION 'RV_XVBFA_MAINTAIN'
      EXPORTING
        fvbfa     = ls_vbfa
        fvbfad    = ls_vbfad
        f_vorgang = 'H'
      TABLES
        fxvbapf   = lt_vbapf
        fxvbfa    = lt_vbfavb
        fyvbfa    = lt_vbfavby.

    READ TABLE lt_vbfavb INDEX 1.
    IF lt_vbfavb-ruuid IS NOT INITIAL.
      CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
        EXPORTING
          wait = 'X'.
      COMMIT WORK.
    ENDIF.

  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form ADD_ZTAX
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM add_ztax .
  DATA : lv_vbeln LIKE vbrk-vbeln.
  DATA : lv_mwsbk LIKE vbrk-mwsbk.
  CHECK gv_vbeln IS NOT INITIAL.
  CLEAR : g_itab_t.
  SELECT SINGLE
    vbrk~vbeln
    vbrk~kurrf
    vbrk~waerk
    vbrk~netwr
    vbrk~mwsbk
    INTO ( g_itab_t-vbeln,
           g_itab_t-kurrf,
           g_itab_t-waerk,
           g_itab_t-netwr_c,
           g_itab_t-mwsbk_c )

    FROM vbrk AS vbrk
    INNER JOIN vbrp AS vbrp
      ON vbrk~vbeln EQ vbrp~vbeln
    WHERE vbrp~aubel = gv_vbeln
    AND vbrk~sfakn = ' '
    AND vbrk~fksto = ' '.

  g_itab_t-sumamt_c = g_itab_t-netwr_c + g_itab_t-mwsbk_c.
  APPEND g_itab_t. CLEAR : g_itab_t.

ENDFORM.
