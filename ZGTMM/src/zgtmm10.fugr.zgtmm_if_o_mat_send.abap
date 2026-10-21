FUNCTION zgtmm_if_o_mat_send.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(I_SYSTEM_ID) TYPE  ZGTE_IF_TARGET
*"     VALUE(I_BUKRS) TYPE  BUKRS
*"     VALUE(I_SDATE) TYPE  DATUM
*"     VALUE(I_EDATE) TYPE  DATUM
*"  EXPORTING
*"     VALUE(ZO_RESULT) TYPE  ZO_RESULT
*"     VALUE(ZO_MESSAGE) TYPE  ZO_MESSAGE
*"  TABLES
*"      OT_MAT STRUCTURE  ZGTMMS1007
*"----------------------------------------------------------------------
*&---------------------------------------------------------------------*
*& 모듈          : MM
*& 프로그램 ID : ZGTMM_IF_O_MAT_SEND
*& 프로그램 명 :  자재마스터 전송(G-SRM -> SAP)
*& 개요   : G-SRM(전자구매시스템) 에서 SAP로 조회 조건 전송 후 결과 값 리턴
*& 생성일 : 2026.01.16
*& 생성자 : ZGODEV07
*&---------------------------------------------------------------------*
*& 외부 호출 프로그램 개요   : N/A
*& 타 시스템 인터페이스 개요 : G-SRM -> EAI -> SAP
*&---------------------------------------------------------------------*
*& 프로그램 수정이력
*&---------------------------------------------------------------------*
*& 수정일  :
*& 수정자  :
*& 수정개요:
*&---------------------------------------------------------------------*

  "초기화
  CLEAR:
    ot_mat[],
    zo_result,
    zo_message.

*1) 전송 정보 누락 여부 확인
*	1-1) Import Parameter 중 전송 필수 정보가 없는 경우 다음 값 Return 후 종료
*   Export Parameter                      Value
*   ZO_RESULT                     "02"
*   ZO_MESSAGE                      "필수 값이 누락되었습니다."

  CONDENSE:
    i_system_id, i_bukrs.

  "시스템ID, 플랜트 필수 입력
  IF i_system_id EQ space OR i_bukrs EQ space
    OR i_sdate IS INITIAL OR i_edate IS INITIAL
    OR i_sdate EQ space OR i_edate EQ space.
    zo_result = gc_02.
    zo_message = TEXT-e01.
    EXIT.
  ENDIF.

*2-1) 입력 받은 회사코드 기준으로 데이터 대상 플랜트 선정
*
*2-2) 변경 이력 테이블에서 자재 대상 조회
*Table : CDHDR
*Select 조건  : OBJECTID
*WHERE 조건
*OBJECTCLAS = 'MATERIAL'
*TCODE : "MM01" , "MM02" , "MM06", "MM01(BAPI)", "MM02(BAPI)", "MM06(BAPI)", "SE38"
*CHANGE_IND = 'U'
*UPDATE = SY-DATLO -1 ~ SY-DATLO
*
*2-3) 조회된 OBJECTID 값 기준으로 Sorting 중복 제거 후 2-1에서 선정한 대상 플랜트 별 정보 추출
*   2-3) 조회된 OBJECTID 값 기준으로 Sorting 중복 제거 후 2-1에서 선정한 대상 플랜트 별 정보 추출
*     MARC-BESKZ = “F” or “X” 이고
*     MARC-PSTAT 값에 “E”가 존재하는 자재만 대상으로 함

*2-4) 자재 기본정보 추출
*
*	MATNR = 플랜트 별 추출된 자재번호
*
*2-4) 텍스트 정보 추출
*- 플랜트명 : T001-NAME1
*- 자재내역 : MAKT-MAKTX
*- 자재유형 내역 : T134-MTBEZ
*- 제품군내역 : TSPAT-VTEXT
*- 구매그룹 내역: T24-EKNAM
*- 조달유형 명: SOBL값 F=외부조달, E=내부생산, X=생산/조달 가능
*- 특별조달유형 명 : T460T-LTEXT
*- 자재그룹 명 : T023-WGBEZ, T023-WGBEZ60

  DATA:
    lr_udate TYPE RANGE OF cdhdr-udate,
    lr_tcode TYPE RANGE OF cdhdr-tcode.

  lr_udate = VALUE #( ( sign = 'I' option = 'BT' low = i_sdate high = i_edate ) ).
  lr_tcode = VALUE #( ( sign = 'I' option = 'CP' low = 'MM01*')
                                     ( sign = 'I' option = 'CP' low = 'MM02*')
                                     ( sign = 'I' option = 'CP' low = 'MM06*') ).

  SELECT
    mc~werks,
    mr~matnr,
    tw~name1,
    mr~mtart,
    t01~mtbez,
    mt~maktx,
    mr~zzmaktx80,
    mr~spart,
    t02~vtext,
    mr~meins,
    mc~ekgrp,
    t03~eknam,
    mc~beskz,
    mc~sobsl,
    t04~ltext,
    mc~xchpf,
    mc~lvorm,
    mr~bismt,
    mr~matkl,
    t05~wgbez,
    t05~wgbez60,
    ze~qr_using AS qr_use,
    ze~qr_example AS qr_url
    FROM mara AS mr
              INNER JOIN
            marc AS mc ON mr~matnr EQ mc~matnr
              INNER JOIN
            t001w AS tw ON mc~werks EQ tw~werks
              INNER JOIN
            t001k AS tk ON tw~bwkey EQ tk~bwkey
              LEFT OUTER JOIN
            makt AS mt ON mr~matnr EQ mt~matnr
                              AND mt~spras EQ @sy-langu
              LEFT OUTER JOIN
            t134t AS t01 ON mr~mtart EQ t01~mtart
                              AND t01~spras EQ @sy-langu
              LEFT OUTER JOIN
            tspat AS t02 ON mr~spart EQ t02~spart
                               AND t02~spras EQ @sy-langu
              LEFT OUTER JOIN
            t024 AS t03 ON mc~ekgrp EQ t03~ekgrp
              LEFT OUTER JOIN
            t460t AS t04 ON mc~werks EQ t04~werks
                                AND mc~sobsl EQ t04~sobsl
                                AND t04~spras EQ @sy-langu
               LEFT OUTER JOIN
            t023t AS t05 ON mr~matkl EQ t05~matkl
                              AND t05~spras EQ @sy-langu
**QR 정보 조회 조건 추가
              LEFT OUTER JOIN
              zgtedt6930 AS ze ON mr~matnr EQ ze~matnr
    WHERE tk~bukrs EQ @i_bukrs
*     MARC-BESKZ = “F” or “X” 이고 *- 2026.04.14 추가
   AND mc~beskz IN ( 'F', 'X' )
*     MARC-PSTAT 값에 “E”가 존재하는 자재만 대상으로 함 *- 2026.04.14 추가
   AND mc~pstat LIKE '%E%'
    AND EXISTS (
      SELECT cd~objectid
        FROM cdhdr AS cd
        WHERE cd~objectclas EQ 'MATERIAL'
           AND cd~objectid EQ mr~matnr
           AND cd~change_ind EQ 'U'
           AND cd~udate IN @lr_udate
           AND cd~tcode IN @lr_tcode
*           AND CD~TCODE IN ( 'MM01' , 'MM02' , 'MM06', 'MM01(BAPI)', 'MM02(BAPI)', 'MM06(BAPI)', 'SE38' )
    )
    INTO CORRESPONDING FIELDS OF TABLE @ot_mat.

  LOOP AT ot_mat ASSIGNING FIELD-SYMBOL(<ls_mat>).

    "전체품명 없을때 자재내역으로 대체
    IF <ls_mat>-zzmaktx80 IS INITIAL.
      <ls_mat>-zzmaktx80 = <ls_mat>-maktx.
    ENDIF.

    "자재코드
    CALL FUNCTION 'CONVERSION_EXIT_MATN1_OUTPUT'
      EXPORTING
        input  = <ls_mat>-matnr
      IMPORTING
        output = <ls_mat>-matnr.

    "단위
    CALL FUNCTION 'CONVERSION_EXIT_CUNIT_OUTPUT'
      EXPORTING
        input  = <ls_mat>-meins
      IMPORTING
        output = <ls_mat>-meins.

    "조달유형
*- 조달유형 명: SOBL값 F=외부조달, E=내부생산, X=생산/조달 가능
    CASE <ls_mat>-beskz.
      WHEN 'F'.
        <ls_mat>-beskz1 = TEXT-z01.
      WHEN 'E'.
        <ls_mat>-beskz1 = TEXT-z02.
      WHEN 'X'.
        <ls_mat>-beskz1 = TEXT-z03.
    ENDCASE.
  ENDLOOP.

  "성공
  zo_result = gc_00.

ENDFUNCTION.
