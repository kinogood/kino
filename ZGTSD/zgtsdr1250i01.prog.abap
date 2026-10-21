*&---------------------------------------------------------------------*
*&  Include           MZQM0696I01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  EXIT  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE exit INPUT.

  save_ok = ok_code.
  CLEAR ok_code.

  CASE save_ok.
    WHEN 'BACK' OR 'CANC' OR 'EXIT' .
      LEAVE TO SCREEN 0.

  ENDCASE.

ENDMODULE.                 " EXIT  INPUT
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0100 INPUT.

  save_ok = ok_code.
  CLEAR : ok_code, g_codi, g_codi_chk.

  CASE save_ok.


      SET PARAMETER ID 'BUK' FIELD s_bukrs+3(4).


*__신규접수
    WHEN 'CREA'.
      gd_bukrs = s_bukrs+3(4).
*      EXPORT GD_BUKRS TO MEMORY ID 'BUKRS_ID'.
      EXPORT gd_bukrs TO MEMORY ID 'BUKRS_ID_GO'.
      CALL TRANSACTION 'ZGTSDR1230'.
      PERFORM get_data.
      PERFORM make_data.

*__고객불만 조회
    WHEN 'REFE'.
      PERFORM modi_checkbox.

      READ TABLE gt_data WITH KEY selx = 'X'.
      IF sy-subrc = 0.

        SET PARAMETER ID 'ZRCEPNO_GO' FIELD gt_data-rcepno.
        CALL TRANSACTION 'ZGTSDR1232'. "조회

      ELSE.
        MESSAGE s001 WITH '고객불만 조회할 데이타를 선택하세요. '
        DISPLAY LIKE 'E'.
      ENDIF.

*__고객불만 변경
    WHEN 'CHAN'.
      PERFORM modi_checkbox.

      CLEAR gt_data.
      READ TABLE gt_data WITH KEY selx = 'X'.
      IF sy-subrc = 0.

*[S] 안정화
*        IF ( GV_SUSER IS NOT INITIAL OR GT_DATA-RCNAM = SY-UNAME )  AND  "SUPER USER/접수자
        IF ( gv_suser IS NOT INITIAL OR sy-uname CS gt_data-rcnam  )  AND  "SUPER USER/접수자
           gt_data-status EQ 'CL10'.

          SET PARAMETER ID 'ZRCEPNO_GO' FIELD gt_data-rcepno.
          CALL TRANSACTION 'ZGTSDR1231'.

          PERFORM get_data.
          PERFORM make_data.

*[S] 안정화
*        ELSEIF GT_DATA-RCNAM NE SY-UNAME AND GV_SUSER IS INITIAL.
        ELSEIF gv_suser IS INITIAL AND NOT sy-uname CS gt_data-rcnam  .
          MESSAGE e001 WITH '접수자만 변경할 수 있습니다.'.

        ELSEIF gt_data-status NE 'CL10'.
          MESSAGE e001 WITH '접수내용을 변경할 수 있는 상태가 아닙니다.'.

        ENDIF.

*        IF ( GT_DATA-RCNAM = SY-UNAME OR SY-UNAME = 'PMB01'
*              OR SY-UNAME = 'ZLSGQM' OR SY-UNAME = 'ZCNSSD'
*              OR SY-UNAME = 'SDB02'   OR SY-UNAME = 'QMA04'
*              OR SY-UNAME = 'ZLSGPP1'  )
*           AND GT_DATA-STATUS = 'CL10'.
*          SET PARAMETER ID 'ZRCEPNO' FIELD GT_DATA-RCEPNO.
*          CALL TRANSACTION 'ZGTSDR1231'.
*
*          PERFORM GET_DATA.
*          PERFORM MAKE_DATA.
*        ELSEIF GT_DATA-RCNAM <> SY-UNAME AND SY-UNAME <> 'PMB01' AND
*               SY-UNAME <> 'ZLSGQM'  AND SY-UNAME <> 'ZLSGPP1'.
*          MESSAGE E001 WITH '접수자만 변경할 수 있습니다.'.
*
*        ELSEIF GT_DATA-STATUS <> 'CL10'.
*          MESSAGE E001 WITH '접수내용을 변경할 수 있는 상태가 아닙니다.'
*          .
*
*        ENDIF.

      ELSE.
        MESSAGE s001 WITH '변경할 데이타를 선택하세요. ' DISPLAY LIKE
        'E'.
      ENDIF.

*__고객불만 처리
    WHEN 'EXEC'.



      PERFORM modi_checkbox.

      READ TABLE gt_data WITH KEY selx = 'X'.

      IF sy-subrc = 0.
        CLEAR : g_codi_chk, g_sdnam_chk, g_codi, g_sdnam.
        g_codi = gt_data-cordi.  "코디네이터 아이디
        g_sdnam = gt_data-sdnam. "영업담당자 아이디
*[기능개선263877] 고객불만 관련 변경요청
* 코디네이터ID와 접속한 아이디가 동일한 경우 G_CODI_CHK = X 입력
        PERFORM check_user_id USING  sy-uname
                                     g_codi
                            CHANGING g_codi_chk.

        PERFORM check_user_id USING  sy-uname
                                     g_sdnam
                            CHANGING g_sdnam_chk.

        IF g_codi_chk NE 'X' AND g_sdnam_chk NE 'X'.

          PERFORM check_user_cc USING  sy-uname
                                       g_codi
                              CHANGING g_codi_chk.

          PERFORM check_user_cc USING  sy-uname
                                       g_sdnam
                              CHANGING g_sdnam_chk.

        ENDIF.

        IF gt_data-status = 'CL05'   OR gt_data-status = 'CL20'  OR
           gt_data-status = 'CL30'.
          IF   gt_data-status =  'CL30'   AND
*[S] 안정화
*             ( gt_data-cordi  <> sy-uname AND
*               gt_data-sdnam  <> sy-uname AND
             ( gv_suser IS INITIAL   AND
               NOT sy-uname CS gt_data-cordi  AND
               NOT sy-uname CS gt_data-sdnam  )  AND

             ( g_codi_chk  NE 'X' AND
               g_sdnam_chk NE 'X'             ).

*               SY-UNAME <> 'PMB01' AND
*               SY-UNAME <> 'ZLSGQM1' AND
*               SY-UNAME <> 'ZLSGQM2' AND
*               SY-UNAME <> 'ZLSGSD2' AND
*               SY-UNAME <> 'ZLSGPP1' ) AND
*
*             ( GT_DATA-BUKRS EQ '1000' AND G_CODI_CHK NE 'X' AND
*               G_SDNAM_CHK NE 'X') .

            MESSAGE e001
               WITH '코디네이터/영업담당자만 처리할 수 있습니다.'.
*            ENDIF.
          ENDIF.

*          IF ( GT_DATA-STATUS = 'CL05' OR GT_DATA-STATUS = 'CL20' ) AND
*              ( GT_DATA-CORDI  <> SY-UNAME AND SY-UNAME <> 'PMB01' AND
*               SY-UNAME <> 'ZLSGQM'  AND SY-UNAME <> 'ZLSGPP1' ) AND
*              ( GT_DATA-BUKRS EQ '1000' AND G_CODI_CHK NE 'X' ) .
          IF ( gt_data-status = 'CL05' OR gt_data-status = 'CL20' ) AND
* [S] 안정화
*             ( gt_data-cordi  NE sy-uname AND gv_suser NE 'X'     ) AND
            ( gv_suser NE 'X' AND  NOT sy-uname  CS gt_data-cordi  ) AND
             ( g_codi_chk NE 'X'                                  ).

            MESSAGE e001 WITH '코디네이터만 처리할 수 있습니다.'.

          ENDIF.

          SET PARAMETER ID 'ZRCEPNO_GO' FIELD gt_data-rcepno.
          CALL TRANSACTION 'ZGTSDR1231'.

          PERFORM get_data.
          PERFORM make_data.
        ELSE.
          MESSAGE e001
             WITH '고객불만을 처리할 수 있는 상태가 아닙니다.'.
        ENDIF.

      ELSE.
        MESSAGE s001 WITH '처리할 데이타를 선택하세요. ' DISPLAY LIKE
        'E'.
      ENDIF.

*__종료승인/반려
    WHEN 'END'.
      PERFORM modi_checkbox.

      READ TABLE gt_data WITH KEY selx = 'X'.
      IF sy-subrc = 0.

*[S] 안정화
*        IF gt_data-status = 'CL40' AND gt_data-jgnam = sy-uname.
        IF gt_data-status = 'CL40' AND sy-uname CS gt_data-jgnam .
          SET PARAMETER ID 'ZRCEPNO_GO' FIELD gt_data-rcepno.
          CALL TRANSACTION 'ZGTSDR1231'.

          PERFORM get_data.
          PERFORM make_data.

        ELSEIF gt_data-status <> 'CL40'.
          MESSAGE e001 WITH '종료승인/반려할 수 있는 상태가 아닙니다.'.

        ELSEIF gt_data-jgnam <> sy-uname .
          MESSAGE e001 WITH '승인자만 처리할 수 있습니다.'.
        ENDIF.

      ELSE.
        MESSAGE s001 WITH '종료 승인/반려할 데이타를 선택하세요. '
        DISPLAY LIKE 'E'.
      ENDIF.

    WHEN 'RFSH'.
      PERFORM get_data.
      PERFORM make_data.

  ENDCASE.

ENDMODULE.                 " USER_COMMAND_0100  INPUT
