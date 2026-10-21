*&---------------------------------------------------------------------*
*& 모듈        : SD
*& 프로그램 ID : ZGTSDR9060
*& 프로그램 명 : 판매오더 Migration
*& 개요   :
*& 생성일 : 2025.04.09
*& 생성자 : ZGSISD04
*&---------------------------------------------------------------------*
*& 외부 호출 프로그램 개요   : N/A
*& 타 시스템 인터페이스 개요 : N/A
*&---------------------------------------------------------------------*
*& 프로그램 수정이력
*&---------------------------------------------------------------------*
*& 수정일  :
*& 수정자  :
*& 수정개요:
*&---------------------------------------------------------------------*
REPORT zgtsdr9060       MESSAGE-ID zgtsd01.

*-----------------------------------------------------------------------
*-- Include
*-----------------------------------------------------------------------
INCLUDE : zgtsdr9060top,              " TOP Include
          zgtsdr9060s01,              " Selection-Screen Include
          zgtsdr9060c01,              " Class ALV Include
          zgtsdr9060o01,              " PBO Include
          zgtsdr9060i01,              " PAI Include
          zgtsdr9060f01.              " Form Include

*-----------------------------------------------------------------------
*-- INITIALIZATION
*-----------------------------------------------------------------------
INITIALIZATION.
  PERFORM set_initialization.

*-----------------------------------------------------------------------
*-- AT SELECTION-SCREEN OUTPUT
*-----------------------------------------------------------------------
AT SELECTION-SCREEN OUTPUT.
  PERFORM screen_output_1000.

*-----------------------------------------------------------------------
*-- AT SELECTION-SCREEN ON VALUE-REQUEST FOR Field
*-----------------------------------------------------------------------
AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_fname.
*-- 파일 경로 선택 Dilog 창 수행
  PERFORM upload_file_path_dialog   CHANGING p_fname.

*-----------------------------------------------------------------------
*-- AT SELECTION-SCREEN ON Field
*-----------------------------------------------------------------------
AT SELECTION-SCREEN ON p_vkorg.
*-- 영업조직 필수값 체크
  PERFORM chk_req_value_for_vkorg   USING    p_vkorg.

AT SELECTION-SCREEN ON p_werks.
*-- 플랜트 필수값 체크
  PERFORM chk_req_value_for_werks   USING    p_werks.

AT SELECTION-SCREEN ON p_spart.
*-- 제품군 필수값 체크
  PERFORM chk_req_value_for_spart   USING    p_spart.

AT SELECTION-SCREEN ON p_vstel.
*-- 출하지점 필수값 체크
  PERFORM chk_req_value_for_vstel   USING    p_vstel.

AT SELECTION-SCREEN ON p_fname.
*-- File Path 핈수값 체크
  PERFORM chk_req_value_for_fname   USING    p_fname.

*-----------------------------------------------------------------------
*-- START-OF-SELECTION
*-----------------------------------------------------------------------
START-OF-SELECTION.

  CASE abap_true.
    WHEN p_search.          " 조회
      PERFORM select_data           CHANGING gv_eflag.

    WHEN p_crte.            " S/O 생성
      PERFORM upload_excel_file     CHANGING gv_eflag.

    WHEN p_del.             " 업로드 데이터 조회/삭제
      PERFORM select_del_data       CHANGING gv_eflag.

    WHEN p_rej.             " As-Is 판매오더 거부사유 처리
      PERFORM upload_rej_excel      CHANGING gv_eflag.

  ENDCASE.

*-----------------------------------------------------------------------
*-- END-OF-SELECTION
*-----------------------------------------------------------------------
END-OF-SELECTION.

  IF gv_eflag EQ abap_true.
    MESSAGE s010 DISPLAY LIKE 'E'.
    EXIT.
  ENDIF.

  CALL SCREEN 0100.
