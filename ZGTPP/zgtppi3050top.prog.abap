*&----------------------------------------------------------------*
*& Include          ZGTPPI1030TOP
*&----------------------------------------------------------------*
*-----------------------------------------------------------------*
* TABLES
*-----------------------------------------------------------------*
 TABLES: mara, mkal, t001w,
         matdoc,  ekpo, zgtppt3090.
*-----------------------------------------------------------------*
* DATA: Variable
*-----------------------------------------------------------------*
 DATA : gv_error.
 DATA : gt_ucomm    TYPE TABLE OF sy-ucomm,
        gv_ok_code  LIKE sy-ucomm,
        gv_ok_code2 LIKE sy-ucomm.
 DATA : gv_cnt  TYPE sy-index.
 DATA : gv_result  TYPE zo_result,
        gv_message TYPE zo_message.
 DATA : gv_answer TYPE c.

 RANGES : gr_werks FOR mapl-werks.
*-----------------------------------------------------------------*
* DATA: Structure. (Field strings : Working area)
*-----------------------------------------------------------------*
 DATA : BEGIN OF gs_data,
          ebeln  TYPE zppt0019-ebeln, "구매 문서 번호
          ebelp  TYPE zppt0019-ebelp, "구매 문서의 품목 번호
          mblnr  TYPE zppt0019-mblnr, "자재 문서 번호
          mjahr  TYPE zppt0019-mjahr, "자재 문서 연도
          wamng  TYPE zppt0019-enmng, "출고수량
          erfme  TYPE zppt0019-meins, "기본 단위
          charg  TYPE zppt0019-charg, "배치 번호
          tagnr  TYPE zppt0019-tagnr, "꼬리표번호
          lgort	 TYPE zppt0019-lgort, "저장위치
          werks  TYPE ekpo-werks,     "플랜트
          matnr  TYPE ekpo-matnr,     "자재코드
          txz01  TYPE ekpo-txz01,     "내역
          menge  TYPE ekpo-menge,     "구매 오더 수량
          meins  TYPE ekpo-meins,     "구매 오더 단위
          reswk  TYPE ekko-reswk,     "재고 운송 오더의 경우 공급(출고)플랜트
          zeile  TYPE matdoc-zeile,   "자재 문서 항목
          budat  TYPE matdoc-budat,   "문서 내 전기일
          bwart	 TYPE matdoc-bwart,   "이동 유형(재고 관리)
          zifkey TYPE zgtppt3090-zifkey, " 전송key
          zstat  TYPE zgtppt3060-zstat,  " 전송 상대
          ifdat  TYPE zgtppt3060-ifdat,  " 전송일자
          iftim  TYPE zgtppt3060-iftim,  " 전송시간
          ifnam  TYPE zgtppt3060-ifnam,  " 전송자
          zmessage   TYPE zgtppt3060-zmessage,
          zsystem_id TYPE zgtppt3060-zsystem_id,
        END OF gs_data.

 DATA : BEGIN OF gs_makt,
          matnr TYPE makt-matnr,
          spras TYPE makt-spras,
          maktx TYPE makt-maktx,
        END OF gs_makt.

 DATA : BEGIN OF gs_t001w,
          werks TYPE t001w-werks,
          name1 TYPE t001w-name1,
        END OF gs_t001w.


 DATA : BEGIN OF gs_mkal,
          matnr LIKE mkal-matnr,
          werks LIKE mkal-werks,
          verid LIKE mkal-verid,
          text1 LIKE mkal-text1,
          adatu LIKE mkal-adatu,
          bdatu LIKE mkal-bdatu,
          plnnr LIKE mkal-plnnr,
          alnal LIKE mkal-alnal,
          stlal LIKE mkal-stlal,
          mdv01 LIKE mkal-mdv01,
          alort LIKE mkal-alort,
          elpro LIKE mkal-elpro,
          mtart LIKE mara-mtart,
          dispo LIKE marc-dispo,
        END OF gs_mkal.
* 전송
 DATA : BEGIN OF gs_disp,
          icon(4), "전송 상태
          message(100), "결과 메시지
          zsystem_id_desc LIKE dd07v-ddtext,      "시스템 내역
          ebeln           LIKE zppt0019-ebeln,  "구매문서 번호
          ebelp           LIKE zppt0019-ebelp,  "구매문서 품목 번호
          mblnr           LIKE zppt0019-mblnr,  "자재 문서 번호
          mjahr           LIKE zppt0019-mjahr,  "자재 문서 연도
          wamng           LIKE zppt0019-enmng,  "출고수량
          erfme           LIKE zppt0019-meins,  "기본 단위
          charg           LIKE zppt0019-charg,  "배치 번호
          tagnr           LIKE zppt0019-tagnr,  "꼬리표번호
          lgort	          LIKE zppt0019-lgort,   "저장 위치
          werks           LIKE ekpo-werks,       "플랜트
          matnr           LIKE ekpo-matnr,       "자재코드
          maktx           LIKE makt-maktx,       "자재코드내역
          txz01           LIKE ekpo-txz01,       "내역
          menge           LIKE ekpo-menge,       "구매문서오더수량
          meins           LIKE ekpo-meins,       " 구매수량단위
          reswk           LIKE ekko-reswk,       "재고 운송 오더의 경우 공급(출고)플랜트
          zeile           LIKE matdoc-zeile,     "자재 문서 항목
          budat           LIKE matdoc-budat,     "문서 내 전기일
          bwart	          LIKE matdoc-bwart,     "이동 유형(재고 관리)
          zifkey          LIKE zgtppt3090-zifkey, " 전송KEY
          "수신 시스템 (PCM: 지중 MES)
          zsystem_id      LIKE zgtppt3060-zsystem_id,
          zstat           LIKE zgtppt3060-zstat,     "전송 상태
          zmessage        LIKE zgtppt3060-zmessage,  "전송 메시지
          ifdat           LIKE zgtppt3060-ifdat,      "전송일자
          iftim           LIKE zgtppt3060-iftim,     "전송시간
          ifnam           LIKE zgtppt3060-ifnam,      "전송자
        END OF gs_disp.
* 로그 조회(재처리)
 DATA : BEGIN OF gs_disp2,
          icon(4), "전송 상태
          message(100), "결과 메시지
          zsystem_id_desc LIKE dd07v-ddtext,      "시스템 내역
          ebeln           LIKE zppt0019-ebeln,  "구매문서 번호
          ebelp           LIKE zppt0019-ebelp,  "구매문서 품목 번호
          mblnr           LIKE zppt0019-mblnr,  "자재 문서 번호
          mjahr           LIKE zppt0019-mjahr,  "자재 문서 연도
          wamng           LIKE zppt0019-enmng,  "출고수량
          erfme           LIKE zppt0019-meins,  "기본 단위
          charg           LIKE zppt0019-charg,  "배치 번호
          tagnr           LIKE zppt0019-tagnr,  "꼬리표번호
          lgort	          LIKE zppt0019-lgort,   "저장 위치
          werks           LIKE ekpo-werks,       "플랜트
          matnr           LIKE ekpo-matnr,       "자재코드
          maktx           LIKE makt-maktx,       "자재코드내역
          txz01           LIKE ekpo-txz01,       "내역
          menge           LIKE ekpo-menge,        "구매문서오더수량
          meins           LIKE ekpo-meins,        " 구매수량단위
          reswk           LIKE ekko-reswk,
          zeile           LIKE matdoc-zeile,
          budat           LIKE matdoc-budat,
          bwart	          LIKE matdoc-bwart,
          zifkey          LIKE zgtppt3090-zifkey, " 전송key
          "수신 시스템 (PCM: 지중 MES)
          zsystem_id      LIKE zgtppt3060-zsystem_id,
          zstat           LIKE zgtppt3060-zstat,     "전송 상태
          zmessage        LIKE zgtppt3060-zmessage,  "전송 메시지
          ifdat           LIKE zgtppt3060-ifdat,      "전송일자
          iftim           LIKE zgtppt3060-iftim,     "전송시간
          ifnam           LIKE zgtppt3060-ifnam,      "전송자
        END OF gs_disp2.

 DATA : gs_zgtppt3090 LIKE zgtppt3090.
 DATA : gs_send LIKE zgtppt3090.
 DATA : gs_zgtppt1010 LIKE zgtppt1010.
*-----------------------------------------------------------------*
* DATA: Internal Table.
*-----------------------------------------------------------------*

 DATA : gt_mkal LIKE TABLE OF gs_mkal.
 DATA : gt_disp   LIKE TABLE OF gs_disp.   "전송 ALV 테이블
 "로그 조회(재처리) ALV 테이블
 DATA : gt_disp2 LIKE TABLE OF gs_disp2.
 DATA : gt_zgtppt3090 LIKE TABLE OF gs_zgtppt3090.
 DATA : gt_row_no TYPE lvc_t_roid WITH HEADER LINE.
 ."ALV 출력용 테이블 (전송 이력 조회)
 DATA : gt_send LIKE TABLE OF zgtppt3090.
 DATA : gt_ot_itab  TYPE TABLE OF zgtppsif0015. " 자재문서 전송용 테이블
 "코드 마스터 테이블
 DATA : gt_zgtppt1010 TYPE TABLE OF zgtppt1010 WITH HEADER LINE.
 DATA : gt_data LIKE TABLE OF gs_data.
 DATA : gt_makt LIKE TABLE OF gs_makt WITH HEADER LINE.
*-----------------------------------------------------------------*
* ALV
*-----------------------------------------------------------------*
*& CLASS Reference 정의
 CLASS: lcl_event_handler      DEFINITION DEFERRED,
        lcl_alv_grid           DEFINITION DEFERRED.

*& ALV Global Field
 DATA : alv_variant LIKE disvariant,
        alv_repid   LIKE sy-repid.
*- ALV COMMON
 TYPE-POOLS : kkblo.
 DATA : gs_stbl      TYPE lvc_s_stbl,
        gt_sfieldcat TYPE kkblo_t_fieldcat,
        gs_excluding TYPE LINE OF ui_functions,
        gt_excluding TYPE ui_functions.

*- ALV1
 DATA : grid                TYPE REF TO cl_gui_alv_grid,
        g_custom_container  TYPE REF TO cl_gui_custom_container,
        g_docking_container TYPE REF TO cl_gui_docking_container,
        g_splitter          TYPE REF TO cl_gui_splitter_container,
        g_container         TYPE REF TO cl_gui_container,
        g_con               TYPE scrfname VALUE 'ALV1',

        lcl_parent_html     TYPE REF TO cl_gui_container,
        lcl_parent_grid     TYPE REF TO cl_gui_container,
        lcl_dyndoc_id       TYPE REF TO cl_dd_document.

 DATA : gs_layout   TYPE lvc_s_layo,
        gt_fieldcat TYPE lvc_t_fcat,
        gs_fieldcat TYPE lvc_s_fcat,
        gt_sort     TYPE lvc_t_sort,
        gs_sort     TYPE lvc_s_sort,
        gt_exclude  TYPE ui_functions,
        gt_styl     TYPE lvc_t_styl,
        gs_styl     TYPE lvc_s_styl.
*& Drop-Down List Box List.
 DATA : gt_dropdown TYPE lvc_t_drop,
        gs_dropdown TYPE lvc_s_drop.

 DATA : go_docking_container TYPE REF TO cl_gui_docking_container.
 DATA : go_splitter TYPE REF TO cl_gui_splitter_container.
 DATA : go_event_handler TYPE REF TO lcl_event_handler.
*-----------
*ALV GRID 100
 DATA : go_contain_0100 TYPE REF TO cl_gui_container.
 DATA : go_grid_0100 TYPE REF TO cl_gui_alv_grid.
 DATA : gs_variant TYPE disvariant.
 DATA : gs_layout_0100 TYPE lvc_s_layo.
 DATA : gt_sort_0100 TYPE lvc_t_sort.
 DATA : gt_exclude_0100 TYPE ui_functions.
 DATA : gt_fieldcat_0100 TYPE lvc_t_fcat.
 DATA : go_object TYPE REF TO cl_alv_event_toolbar_set.

*-----------
* ALV GRID 0101
 DATA : go_contain_0101 TYPE REF TO cl_gui_container.
 DATA : go_grid_0101 TYPE REF TO cl_gui_alv_grid.
 DATA : gs_layout_0101 TYPE lvc_s_layo.
 DATA : gt_sort_0101 TYPE lvc_t_sort.
 DATA : gt_exclude_0101 TYPE ui_functions.
 DATA : gt_fieldcat_0101 TYPE lvc_t_fcat.

 DATA : gv_stable TYPE lvc_s_stbl VALUE 'XX'.
