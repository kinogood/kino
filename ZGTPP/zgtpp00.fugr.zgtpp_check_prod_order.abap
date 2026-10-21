FUNCTION zgtpp_check_prod_order.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  TABLES
*"      IT_HEADER_TABLE STRUCTURE  CAUFVDB OPTIONAL
*"      IT_HEADER_TABLE_OLD STRUCTURE  CAUFVDB OPTIONAL
*"      IT_STATUS_TABLE STRUCTURE  JEST OPTIONAL
*"      IT_STATUS_TABLE_OLD STRUCTURE  JEST OPTIONAL
*"      IT_POSITION_TABLE STRUCTURE  AFPOB OPTIONAL
*"      IT_POSITION_TABLE_OLD STRUCTURE  AAFPO OPTIONAL
*"      IT_COMPONENT_TABLE STRUCTURE  RESBB OPTIONAL
*"      IT_COMPONENT_TABLE_OLD STRUCTURE  ARESB OPTIONAL
*"      IT_OPERATION_TABLE STRUCTURE  AFVGB OPTIONAL
*"      IT_OPERATION_TABLE_OLD_AFVC STRUCTURE  AAFVC OPTIONAL
*"----------------------------------------------------------------------
*                        MODIFICATION LOG                              *
*----------------------------------------------------------------------*
* No      DATE      AUTHORS              DESCRIPTION                   *
* ---  ----------  ---------  -----------------------------------------*
* U01  2025.04.21  ZGSIDEV08  해저 MES 전송 추가
* U02  2026.03.19  ZGODEV06   가온전선 추가
************************************************************************

  DATA : lv_jobname   LIKE tbtcjob-jobname VALUE 'ZGTPPI2010',
         lv_jobnamesm LIKE tbtcjob-jobname VALUE 'ZPPR7070',  "U01(+)
         lv_jobname2  LIKE tbtcjob-jobname,
         lv_jobcount  LIKE tbtcjob-jobcount,
         lv_released  LIKE btch0000-char1,
         lv_uzeit     LIKE sy-uzeit.

  DATA : lt_zgtppt1010 LIKE TABLE OF zgtppt1010,
         ls_zgtppt1010 LIKE zgtppt1010,
         lv_mandt      TYPE sy-mandt.

  RANGES : lr_werks FOR aufk-werks,
           lr_aufnr FOR aufk-aufnr,
           lr_erdat FOR sy-datum,
           lr_dispo FOR afko-dispo.

  DATA : lv_batch.

  CLEAR : it_header_table, it_header_table_old, lr_werks, lr_werks[], lr_aufnr, lr_aufnr[],
          lr_erdat, lr_erdat[], lv_batch, ls_zgtppt1010, lt_zgtppt1010.

  READ TABLE it_header_table INDEX 1.
  READ TABLE it_header_table_old INDEX 1.

* 지중, 부스닥트 , 소재 플랜트만 점검
  CHECK it_header_table-werks EQ gc_werks-1302 OR
        it_header_table-werks EQ gc_werks-1305 OR  "// U01(+)
        it_header_table-werks EQ gc_werks-1802 OR
        it_header_table-werks EQ gc_werks-6500 OR  "// U02(+)
        it_header_table-werks EQ gc_werks-6600.

* 플랜트 및 SPG 코드 발췌
  SELECT *
    INTO CORRESPONDING FIELDS OF TABLE @lt_zgtppt1010
    FROM zgtppt1010
   WHERE module_kind EQ'PP'
     AND codegrp     EQ'0010'
     AND fld_03      EQ @it_header_table-werks.

  LOOP AT lt_zgtppt1010 INTO ls_zgtppt1010.
    lr_dispo-sign = 'I'.
    lr_dispo-option = 'CP'.
    CONCATENATE ls_zgtppt1010-fld_04 '*' INTO lr_dispo-low.
    APPEND lr_dispo.
    CLEAR lr_dispo.
  ENDLOOP.

* 해당 오더가 위에서 발췌한 플랜트 및 SPG에 해당할 경우에만 하단 점검 로직 태울 것
*  SELECT SINGLE A~MANDT INTO @LV_MANDT
*    FROM AUFK AS A
*   INNER JOIN AFKO AS B ON A~AUFNR EQ B~AUFNR
*   WHERE A~WERKS EQ @IT_HEADER_TABLE-WERKS
*     AND A~AUFNR EQ @IT_HEADER_TABLE-AUFNR
*     AND B~DISPO IN @LR_DISPO.
  SELECT SINGLE mandt INTO @lv_mandt FROM marc
                      WHERE werks EQ @it_header_table-werks
                        AND matnr EQ @it_header_table-plnbez
                        AND dispo IN @lr_dispo.

  CHECK lv_mandt IS NOT INITIAL.

* 프로그램 호출 때 사용
  lr_werks-sign = 'I'.
  lr_werks-option = 'EQ'.
  lr_werks-low = it_header_table-werks.
  APPEND lr_werks.

  lr_aufnr-sign = 'I'.
  lr_aufnr-option = 'EQ'.
  lr_aufnr-low = it_header_table-aufnr.
  APPEND lr_aufnr.

*** 2026.06.24 추가 KSW ***
  SELECT SINGLE erdat
     FROM aufk
   WHERE aufnr = @it_header_table-aufnr
      INTO @DATA(lv_erdat).

  IF sy-subrc = 0.
    lr_erdat-sign = 'I'.
    lr_erdat-option = 'EQ'.
    lr_erdat-low = lv_erdat.
    APPEND lr_erdat.
  ELSE.
    lr_erdat-sign = 'I'.
    lr_erdat-option = 'EQ'.
    lr_erdat-low = sy-datum.
    APPEND lr_erdat.
  ENDIF.
*** 2026.06.24 추가 KSW ***

**- 릴리즈 점검
** 릴리즈를 새로 수행했는 지 체크
*  CLEAR it_status_table.
*  READ TABLE it_status_table WITH KEY objnr+0(2) = 'OR'
*                                                                    stat = 'I0002' "릴리스됨
*                                                                    inact = space.
*  IF sy-subrc = 0.
***- 변경 데이터 점검
**- 헤더정보 변경여부 점검
** 생산시작일자 or 생산종료일자 비교하여 하나라도 다를 경우 생산오더 정보 송신
*    IF it_header_table-gstrp <> it_header_table_old-gstrp OR
*      it_header_table-gltrp <> it_header_table_old-gltrp.
*      lv_batch = 'X'.
** 같을 경우 오더 아이템 수량을 비교하여 다른 게 존재하면 생산오더 정보 송신
*    ELSE.
*
*      LOOP AT it_position_table.
*
*        CLEAR it_position_table_old.
*        READ TABLE it_position_table_old
*            WITH KEY aufnr = it_position_table-aufnr
*                            posnr = it_position_table-posnr.
*
*        IF it_position_table-psmng NE it_position_table_old-psmng.
*          lv_batch = 'X'.
*          EXIT.
*        ENDIF.
*
*      ENDLOOP.
*
*    ENDIF.
**- 구성부품 변경 점검
*    IF lv_batch IS INITIAL AND it_component_table_old[] IS NOT INITIAL.
** 해당 구조체에 데이터가 존재하면 구성부품이 변경되었다는 의미이므로 생산오더 정보 송신
*      lv_batch = 'X'.
*    ENDIF.
**- 라우팅 변경 점검
** 자원 오브젝트 ID( ARBID )나 작업 내역( LTXA1 )이 다를 경우 생산오더 정보 송신
*    IF lv_batch IS INITIAL.
*
*      LOOP AT it_operation_table_old_afvc.
*
*        CLEAR it_operation_table.
*        READ TABLE it_operation_table
*                  WITH KEY aufpl = it_operation_table_old_afvc-aufpl
*                               aplzl = it_operation_table_old_afvc-aplzl.
*        IF ( ( it_operation_table_old_afvc-arbid NE it_operation_table-arbid ) OR
*          ( it_operation_table_old_afvc-ltxa1 NE it_operation_table-ltxa1 ) ).
*          lv_batch = 'X'.
*          EXIT.
*        ENDIF.
*
*      ENDLOOP.
*
*    ENDIF.
**- REL 상태가 아닌 경우 오더 상태 점검
*  ELSE.
*
*    CLEAR it_status_table.
*    READ TABLE it_status_table WITH KEY objnr = it_header_table-objnr
*                                                                stat = 'I0045' "기술적으로 완료됨
*                                                                inact = space.
*    IF sy-subrc = 0.
*      lv_batch = 'X'.
*    ELSE.
*
*      CLEAR it_status_table.
*      READ TABLE it_status_table WITH KEY objnr = it_header_table-objnr
*                                                                  stat = 'I0076' "삭제 플래그
*                                                                  inact = space.
*      IF sy-subrc = 0.
*        lv_batch = 'X'.
*      ENDIF.
*
*    ENDIF.
*
*  ENDIF.

  DELETE lr_aufnr WHERE low EQ space.

  CHECK lr_aufnr[] IS NOT INITIAL.

  CLEAR : lv_jobname2, lv_jobcount, lv_released, lv_uzeit.

*  IF lv_batch = 'X'.
*  WMS 전송 호출
*-U01(+)
*      CONCATENATE LV_JOBNAME '_' SY-DATUM '_' SY-UZEIT INTO LV_JOBNAME2.
*- Start 2025.06.04
  CONCATENATE '생산오더 전송_' it_header_table-werks '_' sy-datum '_' sy-uzeit
         INTO lv_jobname2.
*  IF it_header_table-werks EQ '1802'.
*    CONCATENATE lv_jobnamesm '_' it_header_table-werks '_' sy-datum '_' sy-uzeit
*           INTO lv_jobname2.
*  ELSE.
*    CONCATENATE lv_jobname '_' it_header_table-werks '_' sy-datum '_' sy-uzeit
*           INTO lv_jobname2.
*  ENDIF.
*- End 2025.06.04
*-U01(+)

  CLEAR lv_jobcount.

  DO.
    CALL FUNCTION 'JOB_OPEN'
      EXPORTING
        jobname          = lv_jobname2
      IMPORTING
        jobcount         = lv_jobcount
      EXCEPTIONS
        cant_create_job  = 1
        invalid_job_data = 2
        jobname_missing  = 3
        OTHERS           = 4.
    IF sy-subrc = 0.
      EXIT.
    ENDIF.
  ENDDO.

* 조회 조건에 플랜트 빼고 헤더 플랜트로 "지중" OR "부스닥트" MES 라디오 버튼 선택
  IF it_header_table-werks EQ gc_werks-1302. "지중 MES
    SUBMIT zgtppi2010 VIA JOB lv_jobname2
                       NUMBER lv_jobcount
                         WITH s_aufnr IN lr_aufnr
                         WITH s_erdat IN lr_erdat
                         WITH p_r1  EQ 'X'
                         WITH p_r2  EQ ' '
                         WITH p_r3  EQ 'X'
                         WITH p_r4  EQ ' '
                         WITH p_r9  EQ ' '
                         WITH p_r10 EQ ' '
                         WITH p_r11 EQ ' '
                         WITH p_r8  EQ 'X'
                          AND RETURN.
  ELSEIF it_header_table-werks EQ gc_werks-1305. "소재 MOM
    SUBMIT zgtppi2010 VIA JOB lv_jobname2
                     NUMBER lv_jobcount
                       WITH s_aufnr IN lr_aufnr
                       WITH s_erdat IN lr_erdat
                       WITH p_r1  EQ 'X'
                       WITH p_r2  EQ ' '
                       WITH p_r3  EQ ' '
                       WITH p_r4  EQ ' '
                       WITH p_r9  EQ 'X'
                       WITH p_r10 EQ ' '
                       WITH p_r11 EQ ' '
                       WITH p_r8  EQ 'X'
                        AND RETURN.
  ELSEIF it_header_table-werks EQ gc_werks-1306. "부스닥트 MES
    SUBMIT zgtppi2010 VIA JOB lv_jobname2
                       NUMBER lv_jobcount
                         WITH s_aufnr IN lr_aufnr
                         WITH s_erdat IN lr_erdat
                         WITH p_r1  EQ 'X'
                         WITH p_r2  EQ ' '
                         WITH p_r3  EQ ' '
                         WITH p_r4  EQ 'X'
                         WITH p_r9  EQ ' '
                         WITH p_r10 EQ ' '
                         WITH p_r11 EQ ' '
                         WITH p_r8  EQ 'X'
                          AND RETURN.
*-U01(+)
  ELSEIF it_header_table-werks EQ gc_werks-1802.   "해저 MES
    SUBMIT zppr7070 VIA JOB lv_jobname2
                     NUMBER lv_jobcount
                       WITH p_werks EQ it_header_table-werks
                       WITH s_aufnr IN lr_aufnr
                       WITH p_c1    EQ 'X'
                        AND RETURN.
*-U01(+)
*-U02(+)
  ELSEIF it_header_table-werks EQ gc_werks-6500. "// 가온 전력 MES.
    SUBMIT zgtppi2010 VIA JOB lv_jobname2
                       NUMBER lv_jobcount
                         WITH s_aufnr IN lr_aufnr
                         WITH s_erdat IN lr_erdat
                         WITH p_r1  EQ 'X'
                         WITH p_r2  EQ ' '
                         WITH p_r3  EQ ' '
                         WITH p_r4  EQ ' '
                         WITH p_r9  EQ ' '
                         WITH p_r10 EQ 'X'
                         WITH p_r11 EQ ' '
                         WITH p_r8  EQ 'X'
                          AND RETURN.
  ELSEIF it_header_table-werks EQ gc_werks-6600. "// 가온 통신 MES.
    SUBMIT zgtppi2010 VIA JOB lv_jobname2
                       NUMBER lv_jobcount
                         WITH s_aufnr IN lr_aufnr
                         WITH s_erdat IN lr_erdat
                         WITH p_r1  EQ 'X'
                         WITH p_r2  EQ ' '
                         WITH p_r3  EQ ' '
                         WITH p_r4  EQ ' '
                         WITH p_r9  EQ ' '
                         WITH p_r10 EQ ' '
                         WITH p_r11 EQ 'X'
                         WITH p_r8  EQ 'X'
                          AND RETURN.
*-U02(+)
  ENDIF.

  CLEAR lv_uzeit.
  lv_uzeit = sy-uzeit + 2.

  CALL FUNCTION 'JOB_CLOSE'
    EXPORTING
      jobcount             = lv_jobcount
      jobname              = lv_jobname2
      sdlstrtdt            = sy-datum
      sdlstrttm            = lv_uzeit
      strtimmed            = 'X'  "즉시 기동
    IMPORTING
      job_was_released     = lv_released
    EXCEPTIONS
      cant_start_immediate = 1
      invalid_startdate    = 2
      jobname_missing      = 3
      job_close_failed     = 4
      job_nosteps          = 5
      job_notex            = 6
      lock_failed          = 7
      OTHERS               = 8.

ENDFUNCTION.
