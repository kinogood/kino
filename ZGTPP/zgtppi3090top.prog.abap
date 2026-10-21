*&---------------------------------------------------------------------*
*& Include          ZGTPPI3090TOP
*&---------------------------------------------------------------------*
*----------------------------------------------------------------------*
* TABLES
*----------------------------------------------------------------------*
TABLES : zgtppt3150, zgtppt3160.
*-----------------------------------------------------------------*
* DATA: Variable
*-----------------------------------------------------------------*
DATA : gv_error,
       gt_ucomm    TYPE TABLE OF sy-ucomm,
       gv_ok_code  LIKE sy-ucomm,
       gv_ok_code2 LIKE sy-ucomm.

DATA : gt_row_table TYPE lvc_t_row WITH HEADER LINE,
       gv_lines     TYPE index.

DATA : gv_result  TYPE zo_result,
       gv_message TYPE zo_message,
       gv_answer  TYPE c,
       gv_cnt     TYPE sy-index,
       gv_tabix   TYPE sy-tabix.
*-----------------------------------------------------------------*
* DATA: Structure. (Field strings : Working area)
*-----------------------------------------------------------------*
*- 데이터 취합
DATA : gs_6210 LIKE zgtmmt6210,
       gs_6211 LIKE zgtmmt6211,
       gs_2121 LIKE zgtedt2121.
*- ALV
* 상단 화면 : 생산 제조지시
DATA : BEGIN OF gs_header, "처리 모드 : 전송
         icon(4), "전송 상태
         zmessage(100), "결과 메시지
         zsystem_id      LIKE zgtppt3010-zsystem_id, "수신 시스템
         zsystem_id_desc LIKE dd07v-ddtext, "시스템 내역
         jobls           LIKE zgtppt3160-jobls, "MES 요청번호
         job_no          LIKE zgtppt3160-job_no, "제조지시번호
         zjob_name       LIKE zgtedt2121-zjob_name, "제조지시내역
         line_no         LIKE zgtppt3160-line_no, "라인번호
         serial_info     LIKE zgtppt3160-serial_info, "시리얼정보
         prcss_seq       LIKE zgtppt3160-prcss_seq, "공정순번
         prcss_sub_seq   LIKE zgtppt3160-prcss_sub_seq, "SUB순번
         zmode           LIKE zgtppt3160-zmode, "처리모드
         werks           LIKE zgtppt3150-werks, "플랜트
         oper_code       LIKE zgtppt3160-oper_code, "공정코드
         oper_name       LIKE zgtppt3160-oper_name, "공정명
         oper_matnr      LIKE zgtppt3160-oper_matnr, "생산품목코드
         maktx           LIKE makt-maktx, "생산품목내역
         menge           LIKE zgtppt3160-menge, "생산수량
         meins           LIKE zgtppt3160-meins, "단위
         idnlf           LIKE zgtppt3160-idnlf, "외주공정 자재그룹
         bstmg           LIKE zgtppt3160-bstmg, "외주가공 수량
         bstme           LIKE zgtppt3160-bstme, "외주가공 단위
         netwr           LIKE zgtppt3160-netwr, "외주가공 금액
         beskz           LIKE zgtppt3160-beskz, "외주 전환 처리
       END OF gs_header.

DATA : BEGIN OF gs_header2, "처리 모드 : 로그 조회
         zifkey          LIKE zgtppt3210-zifkey, "인터페이스 키
         icon(4), "전송 상태
         zmessage(100), "결과 메시지
         zsystem_id      LIKE zgtppt3010-zsystem_id, "수신 시스템
         zsystem_id_desc LIKE dd07v-ddtext, "시스템 내역
         jobls           LIKE zgtppt3210-jobls, "MES 요청번호
         job_no          LIKE zgtppt3160-job_no, "제조지시번호
         zjob_name       LIKE zgtedt2121-zjob_name, "제조지시내역
         line_no         LIKE zgtppt3160-line_no, "라인번호
         serial_info     LIKE zgtppt3160-serial_info, "시리얼정보
         prcss_seq       LIKE zgtppt3160-prcss_seq, "공정순번
         prcss_sub_seq   LIKE zgtppt3160-prcss_sub_seq, "SUB순번
         zmode           LIKE zgtppt3160-zmode, "처리모드
         werks           LIKE zgtppt3150-werks, "플랜트
         oper_code       LIKE zgtppt3160-oper_code, "공정코드
         oper_name       LIKE zgtppt3160-oper_name, "공정명
         oper_matnr      LIKE zgtppt3160-oper_matnr, "생산품목코드
         maktx           LIKE makt-maktx, "생산품목내역
         menge           LIKE zgtppt3160-menge, "생산수량
         meins           LIKE zgtppt3160-meins, "단위
         beskz           LIKE zgtppt3210-beskz, "외주 전환 처리
         idnlf           LIKE zgtppt3160-idnlf, "외주공정 자재그룹
         bstmg           LIKE zgtppt3160-bstmg, "외주가공 수량
         bstme           LIKE zgtppt3160-bstme, "외주가공 단위
         netwr           LIKE zgtppt3160-netwr, "외주가공 금액
         ifdat           LIKE zgtppt3210-ifdat, "전송일자
         iftim           LIKE zgtppt3210-iftim, "전송시간
         ifnam           LIKE zgtppt3210-ifnam, "전송자
       END OF gs_header2.
* 하단 화면 : 구매 제조지시
DATA : BEGIN OF gs_jejo_c, "처리 모드 : 전송
         zsystem_id      LIKE zgtppt3010-zsystem_id, "수신 시스템
         zsystem_id_desc LIKE dd07v-ddtext, "시스템 내역
         jobls           LIKE zgtmmt6210-jobls, "MES 요청번호
         werks           LIKE zgtmmt6210-werks, "플랜트
         i_mode          LIKE zgtppt3160-zmode, "처리모드
         job_no          LIKE zgtmmt6210-job_no, "제조지시번호
         zjob_name       LIKE zgtedt2121-zjob_name, "제조지시내역
         line_no         LIKE zgtmmt6210-line_no, "라인번호
         serial_no       LIKE zgtmmt6210-serial_info, "시리얼정보
         bstyp           LIKE zgtmmt6210-bstyp, "구매문서범주
         ekorg           LIKE zgtmmt6210-ekorg, "구매조직
         ekgrp           LIKE zgtmmt6210-ekgrp, "구매그룹
         afnam           LIKE zgtmmt6210-afnam, "요청자 이름
         pstyp           LIKE zgtmmt6210-pstyp, "품목범주
         eindt           LIKE zgtmmt6210-eindt, "납품일
         matkl           LIKE zgtmmt6210-matkl, "자재그룹
         matnr           LIKE zgtmmt6210-matnr, "자재번호
         txz01           LIKE makt-maktx, "내역
         menge           LIKE zgtmmt6210-menge, "구매요청수량
         meins           LIKE zgtmmt6210-meins, "구매요청단위
         lgort           LIKE zgtmmt6210-lgort, "저장위치
         emlif           LIKE zgtmmt6210-emlif, "공급업체
         kunnr           LIKE zgtmmt6210-kunnr, "고객번호
         knttp           LIKE zgtmmt6210-knttp, "계정지정범주
         ablad           LIKE zgtmmt6210-ablad, "하적지점
         sakto           LIKE zgtmmt6210-sakto, "G/L계정번호
         kostl           LIKE zgtmmt6210-kostl, "코스트 센터
         sobkz           LIKE zgtmmt6210-sobkz, "특별 재고 지시자
         vbeln           LIKE zgtmmt6210-vbeln, "판매 관리 문서 번호
         vbelp           LIKE zgtmmt6210-vbelp, "판매 문서 항목
         flief           LIKE zgtmmt6210-flief, "고정 공급업체
         umson           LIKE zgtmmt6210-umson, "무상 품목
         exprc           LIKE zgtmmt6210-exprc, "외주공정 단가사용
         idnlf           LIKE zgtmmt6210-idnlf, "외주공정 자재그룹
         bstmg           LIKE zgtmmt6210-bstmg, "외주가공 수량
         bstme           LIKE zgtmmt6210-bstme, "외주가공 단위
         waers           LIKE zgtmmt6210-waers, "통화 키
         netpr           LIKE zgtmmt6210-netpr, "외주가공 단가
         peinh           LIKE zgtmmt6210-peinh, "가격 단위
         netwr           LIKE zgtmmt6210-netwr, "외주가공 금액
         infnr           LIKE zgtmmt6210-infnr, "외주가공 정보레코드
       END OF gs_jejo_c.

DATA : BEGIN OF gs_jejo_c2, "처리 모드 : 로그 조회
         zifkey          LIKE zgtppt3220-zifkey, "인터페이스 키
         zsystem_id      LIKE zgtppt3010-zsystem_id, "수신 시스템
         zsystem_id_desc LIKE dd07v-ddtext, "시스템 내역
         jobls           LIKE zgtmmt6210-jobls, "MES 요청번호
         werks           LIKE zgtmmt6210-werks, "플랜트
         i_mode          LIKE zgtppt3160-zmode, "처리모드
         job_no          LIKE zgtmmt6210-job_no, "제조지시번호
         zjob_name       LIKE zgtedt2121-zjob_name, "제조지시내역
         line_no         LIKE zgtmmt6210-line_no, "라인번호
         serial_no       LIKE zgtmmt6210-serial_info, "시리얼정보
         bstyp           LIKE zgtmmt6210-bstyp, "구매문서범주
         ekorg           LIKE zgtmmt6210-ekorg, "구매조직
         ekgrp           LIKE zgtmmt6210-ekgrp, "구매그룹
         afnam           LIKE zgtmmt6210-afnam, "요청자 이름
         pstyp           LIKE zgtmmt6210-pstyp, "품목범주
         eindt           LIKE zgtmmt6210-eindt, "납품일
         matkl           LIKE zgtmmt6210-matkl, "자재그룹
         matnr           LIKE zgtmmt6210-matnr, "자재번호
         txz01           LIKE makt-maktx, "내역
         menge           LIKE zgtmmt6210-menge, "구매요청수량
         meins           LIKE zgtmmt6210-meins, "구매요청단위
         lgort           LIKE zgtmmt6210-lgort, "저장위치
         emlif           LIKE zgtmmt6210-emlif, "공급업체
         kunnr           LIKE zgtmmt6210-kunnr, "고객번호
         knttp           LIKE zgtmmt6210-knttp, "계정지정범주
         ablad           LIKE zgtmmt6210-ablad, "하적지점
         sakto           LIKE zgtmmt6210-sakto, "G/L계정번호
         kostl           LIKE zgtmmt6210-kostl, "코스트 센터
         sobkz           LIKE zgtmmt6210-sobkz, "특별 재고 지시자
         vbeln           LIKE zgtmmt6210-vbeln, "판매 관리 문서 번호
         vbelp           LIKE zgtmmt6210-vbelp, "판매 문서 항목
         flief           LIKE zgtmmt6210-flief, "고정 공급업체
         umson           LIKE zgtmmt6210-umson, "무상 품목
         exprc           LIKE zgtmmt6210-exprc, "외주공정 단가사용
         idnlf           LIKE zgtmmt6210-idnlf, "외주공정 자재그룹
         bstmg           LIKE zgtmmt6210-bstmg, "외주가공 수량
         bstme           LIKE zgtmmt6210-bstme, "외주가공 단위
         waers           LIKE zgtmmt6210-waers, "통화 키
         netpr           LIKE zgtmmt6210-netpr, "외주가공 단가
         peinh           LIKE zgtmmt6210-peinh, "가격 단위
         netwr           LIKE zgtmmt6210-netwr, "외주가공 금액
         infnr           LIKE zgtmmt6210-infnr, "외주가공 정보레코드
       END OF gs_jejo_c2.
* 하단 화면 : 구매 제조지시 구성품
DATA : BEGIN OF gs_jejo_i, "처리 모드 : 전송
         zsystem_id      LIKE zgtppt3010-zsystem_id, "수신 시스템
         zsystem_id_desc LIKE dd07v-ddtext, "시스템 내역
         jobls           LIKE zgtmmt6211-jobls, "MES 요청번호
         mes_cmp         LIKE zgtmmt6211-mes_cmp, "MES 요청 구성품번호
         werks           LIKE zgtmmt6210-werks, "플랜트
         i_mode          LIKE zgtppt3160-zmode, "처리모드
         job_no          LIKE zgtmmt6211-job_no, "제조지시번호
         zjob_name       LIKE zgtedt2121-zjob_name, "제조지시내역
         matnr           LIKE zgtmmt6211-matnr, "자재번호
         maktx           LIKE makt-maktx, "내역
         bdmng           LIKE zgtmmt6211-bdmng, "소요량
         meins           LIKE zgtmmt6211-meins, "기본 단위
       END OF gs_jejo_i.

DATA : BEGIN OF gs_jejo_i2, "처리 모드 : 로그 조회
         zifkey          LIKE zgtppt3220-zifkey, "인터페이스 키
         zsystem_id      LIKE zgtppt3010-zsystem_id, "수신 시스템
         zsystem_id_desc LIKE dd07v-ddtext, "시스템 내역
         jobls           LIKE zgtmmt6211-jobls, "MES 요청번호
         mes_cmp         LIKE zgtmmt6211-mes_cmp, "MES 요청 구성품번호
         werks           LIKE zgtmmt6210-werks, "플랜트
         i_mode          LIKE zgtppt3160-zmode, "처리모드
         job_no          LIKE zgtmmt6211-job_no, "제조지시번호
         zjob_name       LIKE zgtedt2121-zjob_name, "제조지시내역
         matnr           LIKE zgtmmt6211-matnr, "자재번호
         maktx           LIKE makt-maktx, "내역
         bdmng           LIKE zgtmmt6211-bdmng, "소요량
         meins           LIKE zgtmmt6211-meins, "기본 단위
       END OF gs_jejo_i2.
*- 로그 업데이트
DATA : gs_send_header LIKE zgtppt3210, "상단 화면 : 생산 제조지시
       gs_send_jejo_c LIKE zgtppt3220, "하단 화면 - 구매 제조지시
       gs_send_jejo_i LIKE zgtppt3230. "하단 화면 - 구매 제조지시 구성품
*- MES 전송
DATA : gs_mes_header LIKE TABLE OF zgtppsif0030, "상단 화면 : 생산 제조지시
       gs_mes_jejo_c LIKE TABLE OF zgtppsif0031, "하단 화면 - 구매 제조지시
       gs_mes_jejo_i LIKE TABLE OF zgtppsif0032. "하단 화면 - 구매 제조지시 구성품
*- 로그 조회 데이터 취합
DATA : gs_zgtppt3210 LIKE zgtppt3210, "상단 화면 : 생산 제조지시
       gs_zgtppt3220 LIKE zgtppt3220, "하단 화면 - 구매 제조지시
       gs_zgtppt3230 LIKE zgtppt3230. "하단 화면 - 구매 제조지시 구성품

DATA : BEGIN OF gs_zifkey,
         zifkey LIKE zgtppt3210-zifkey,
         jobls  LIKE zgtppt3210-jobls,
       END OF gs_zifkey. "로그 조회 데이터 취합용 조건 데이터
*-----------------------------------------------------------------*
* DATA: Internal Table.
*-----------------------------------------------------------------*
*- 데이터 취합
DATA : gt_6210 LIKE TABLE OF zgtmmt6210,
       gt_6211 LIKE TABLE OF zgtmmt6211,
       gt_2121 LIKE TABLE OF zgtedt2121.
*- ALV
* 처리 모드 : 전송
DATA : gt_header LIKE TABLE OF gs_header, "상단 화면 - 생산 제조지시
       gt_jejo_c LIKE TABLE OF gs_jejo_c, "하단 화면 - 구매 제조지시
       gt_jejo_i LIKE TABLE OF gs_jejo_i. "하단 화면 - 구매 제조지시 구성품
* 처리 모드 : 로그 조회
DATA : gt_header2 LIKE TABLE OF gs_header2, "상단 화면 - 생산 제조지시
       gt_jejo_c2 LIKE TABLE OF gs_jejo_c2, "하단 화면 - 구매 제조지시
       gt_jejo_i2 LIKE TABLE OF gs_jejo_i2. "하단 화면 - 구매 제조지시 구성품
*- 로그 업데이트
DATA : gt_send_header LIKE TABLE OF zgtppt3210, "상단 화면 : 생산 제조지시
       gt_send_jejo_c LIKE TABLE OF zgtppt3220, "하단 화면 - 구매 제조지시
       gt_send_jejo_i LIKE TABLE OF zgtppt3230. "하단 화면 - 구매 제조지시 구성품
*- MES 전송
DATA : gt_mes_header LIKE TABLE OF zgtppsif0030, "상단 화면 : 생산 제조지시
       gt_mes_jejo_c LIKE TABLE OF zgtppsif0031, "하단 화면 - 구매 제조지시
       gt_mes_jejo_i LIKE TABLE OF zgtppsif0032. "하단 화면 - 구매 제조지시 구성품
*- 로그 조회 데이터 취합
DATA : gt_zgtppt3210 LIKE TABLE OF zgtppt3210, "상단 화면 : 생산 제조지시
       gt_zgtppt3220 LIKE TABLE OF zgtppt3220, "하단 화면 - 구매 제조지시
       gt_zgtppt3230 LIKE TABLE OF zgtppt3230, "하단 화면 - 구매 제조지시 구성품
       gt_zifkey     LIKE TABLE OF gs_zifkey. "로그 조회 데이터 취합용 조건 데이터
*-------------------------------------------------------------------*
* ALV
*-------------------------------------------------------------------*
*& CLASS Reference 정의
CLASS: lcl_event_handler      DEFINITION DEFERRED.

DATA : gv_dynnr  LIKE sy-dynnr,
       gv_dynnr2 LIKE sy-dynnr.

CONTROLS : tabstr    TYPE TABSTRIP.
* reference to custom container: neccessary to bind ALV Control
DATA : g_custom_container TYPE REF TO cl_gui_custom_container,
       g_grid             TYPE REF TO cl_gui_alv_grid,
       g_event_handler    TYPE REF TO lcl_event_handler.
*---------ALV 1-----------
DATA : gt_exclude   TYPE ui_functions.
DATA : gs_print       TYPE lvc_s_prnt,
       gs_layout      TYPE lvc_s_layo,
       gv_mycontainer TYPE scrfname VALUE 'CONTAINER_100',
*      fieldcatalog for output table,
       gs_fieldcat    TYPE lvc_s_fcat,
       gt_fieldcat    TYPE lvc_t_fcat,
       gs_fcatlayo    TYPE lvc_s_layo,
       gs_f4          TYPE lvc_s_f4,      " F4 필드 관련
       gt_f4          TYPE lvc_t_f4.
DATA : gs_fcat TYPE lvc_s_fcat.

DATA : gs_sort      TYPE lvc_s_sort.
DATA : gt_sort      TYPE lvc_t_sort.

DATA : gv_repid LIKE sy-repid.
DATA : gv_alv_variant LIKE disvariant.
DATA : gt_row_no TYPE lvc_t_roid WITH HEADER LINE.
*-----------
*ALV GRID 100
DATA : go_contain_0100 TYPE REF TO cl_gui_container.
DATA : go_grid_0100 TYPE REF TO cl_gui_alv_grid.
DATA : gs_layout_0100 TYPE lvc_s_layo.
DATA : gt_sort_0100 TYPE lvc_t_sort.
DATA : gt_exclude_0100 TYPE ui_functions.
DATA : gt_fieldcat_0100 TYPE lvc_t_fcat.
DATA : go_object TYPE REF TO cl_alv_event_toolbar_set.
DATA : go_docking_container TYPE REF TO cl_gui_docking_container.
DATA : go_splitter TYPE REF TO cl_gui_splitter_container.
*================================================================
DATA : gc_container_name1   TYPE scrfname VALUE 'CONTAINER1',
       gc_container_name2   TYPE scrfname VALUE 'CONTAINER2',
       gc_container_name3   TYPE scrfname VALUE 'CONTAINER3',
       gc_container_name4   TYPE scrfname VALUE 'CONTAINER4',
       gc_custom_container1 TYPE REF TO cl_gui_custom_container,
       gc_custom_container2 TYPE REF TO cl_gui_custom_container,
       gc_custom_container3 TYPE REF TO cl_gui_custom_container,
       gc_custom_container4 TYPE REF TO cl_gui_custom_container,
       gc_alv_grid1         TYPE REF TO cl_gui_alv_grid,
       gc_alv_grid2         TYPE REF TO cl_gui_alv_grid,
       gc_alv_grid3         TYPE REF TO cl_gui_alv_grid,
       gc_alv_grid4         TYPE REF TO cl_gui_alv_grid.

DATA : gv_itab    LIKE gs_fieldcat-tabname,
       gv_pos     LIKE gs_fieldcat-col_pos,
       gs_scroll  TYPE lvc_s_stbl,
       gs_variant TYPE disvariant,
       gv_stable  TYPE lvc_s_stbl VALUE 'XX'.
