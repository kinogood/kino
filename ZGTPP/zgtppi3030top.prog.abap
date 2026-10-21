*&----------------------------------------------------------------*
*& Include          ZGTPPI1030TOP
*&----------------------------------------------------------------*
*-----------------------------------------------------------------*
* TABLES
*-----------------------------------------------------------------*
 TABLES: mara, mkal, t001w, zgtppt1040,
         matdoc, zgtppt3060.
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
          mblnr      TYPE matdoc-mblnr,
          mjahr      TYPE matdoc-mjahr,
          zeile      TYPE matdoc-zeile,
          werks      TYPE matdoc-werks,
          budat      TYPE matdoc-budat,
          bwart      TYPE matdoc-bwart,
          matnr      TYPE matdoc-matnr,
          aufnr      TYPE matdoc-aufnr,
          menge      TYPE matdoc-menge,
          meins      TYPE matdoc-meins,
          lgort      TYPE matdoc-lgort,
          charg      TYPE matdoc-charg,
          cpudt      TYPE matdoc-cpudt,
          cputm      TYPE matdoc-cputm,
          zifkey     TYPE zgtppt3060-zifkey, " 전송key
          zstat      TYPE zgtppt3060-zstat,  " 전송 상대
          ifdat      TYPE zgtppt3060-ifdat,  " 전송일자
          iftim      TYPE zgtppt3060-iftim,  " 전송시간
          ifnam      TYPE zgtppt3060-ifnam,  " 전송자
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
          mblnr           LIKE zgtppt3060-mblnr, "자재문서번호
          mjahr           LIKE zgtppt3060-mjahr, "자재문서연도
          zeile           LIKE zgtppt3060-zeile, "자재문서항목
          werks           LIKE zgtppt3060-werks, "플랜트
          budat           LIKE zgtppt3060-budat, "전기일자
          bwart           LIKE zgtppt3060-bwart, "이동유형
          matnr           LIKE zgtppt3060-matnr, "자재코드
          maktx           LIKE makt-maktx,       "자재코드내역
          aufnr           LIKE zgtppt3060-aufnr, "생산오더번호
          menge           LIKE zgtppt3060-menge, "실적처리수량
          meins           LIKE zgtppt3060-meins, "단위
          lgort           LIKE zgtppt3060-lgort, "입출고창고
          "배치번호(입고, 출고 배치번호)
          charg           LIKE zgtppt3060-charg,
          cpudt           LIKE zgtppt3060-cpudt, "문서생성일
          cputm           LIKE zgtppt3060-cputm, " 문서생성시간
          zifkey          LIKE zgtppt3060-zifkey, " 전송key
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
          mblnr           LIKE zgtppt3060-mblnr, "자재문서번호
          mjahr           LIKE zgtppt3060-mjahr, "자재문서연도
          zeile           LIKE zgtppt3060-zeile, "자재문서항목
          werks           LIKE zgtppt3060-werks, "플랜트
          budat           LIKE zgtppt3060-budat, "전기일자
          bwart           LIKE zgtppt3060-bwart, "이동유형
          matnr           LIKE zgtppt3060-matnr, "자재코드
          maktx           LIKE makt-maktx,       "자재코드내역
          aufnr           LIKE zgtppt3060-aufnr, "생산오더번호
          menge           LIKE zgtppt3060-menge, "실적처리수량
          meins           LIKE zgtppt3060-meins, "단위
          lgort           LIKE zgtppt3060-lgort, "입출고창고
          "배치번호(입고, 출고 배치번호)
          charg           LIKE zgtppt3060-charg,
          cpudt           LIKE zgtppt3060-cpudt, "문서생성일
          cputm           LIKE zgtppt3060-cputm, " 문서생성시간
          zifkey          LIKE zgtppt3060-zifkey, " 전송key
          "수신 시스템 (PCM: 지중 MES)
          zsystem_id      LIKE zgtppt3060-zsystem_id,
          zstat           LIKE zgtppt3060-zstat,     "전송 상태
          zmessage        LIKE zgtppt3060-zmessage,  "전송 메시지
          ifdat           LIKE zgtppt3060-ifdat,      "전송일자
          iftim           LIKE zgtppt3060-iftim,     "전송시간
          ifnam           LIKE zgtppt3060-ifnam,      "전송자
        END OF gs_disp2.

 DATA : gs_zgtppt3060 LIKE zgtppt3060.
 DATA : gs_send LIKE zgtppt3060.
 DATA : gs_zgtppt1010 LIKE zgtppt1010.
*-----------------------------------------------------------------*
* DATA: Internal Table.
*-----------------------------------------------------------------*

 DATA : gt_mkal LIKE TABLE OF gs_mkal.
 DATA : gt_disp   LIKE TABLE OF gs_disp.   "전송 ALV 테이블
 "로그 조회(재처리) ALV 테이블
 DATA : gt_disp2 LIKE TABLE OF gs_disp2.
 DATA : gt_zgtppt3060 LIKE TABLE OF gs_zgtppt3060.
 DATA : gt_row_no TYPE lvc_t_roid WITH HEADER LINE.
 ."ALV 출력용 테이블 (전송 이력 조회)
 DATA : gt_send LIKE TABLE OF zgtppt3060.
 DATA : gt_ot_itab  TYPE TABLE OF zgtppsif0011. " 자재문서 전송용 테이블
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
