*&----------------------------------------------------------------*
*& Include          ZGTPPI1030TOP
*&----------------------------------------------------------------*
*-----------------------------------------------------------------*
* TABLES
*-----------------------------------------------------------------*
 TABLES: mara, mkal, t001w, aufk, mast,
         afpo, resb, afko.
*-----------------------------------------------------------------*
* DATA: Variable
*-----------------------------------------------------------------*
 DATA : gv_error.
 DATA : gt_ucomm    TYPE TABLE OF sy-ucomm,
        gv_ok_code  LIKE sy-ucomm,
        gv_ok_code2 LIKE sy-ucomm.
 DATA : gv_cnt   TYPE sy-index,
        gv_mandt LIKE sy-mandt.
 DATA : gv_result  TYPE zo_result,
        gv_message TYPE zo_message.
 DATA : gv_answer TYPE c.

 RANGES : gr_werks FOR mapl-werks.
*-----------------------------------------------------------------*
* DATA: Structure. (Field strings : Working area)
*-----------------------------------------------------------------*
 DATA : BEGIN OF gs_data,
          werks      TYPE marc-werks,
          matnr      TYPE marc-matnr,
          beskz      TYPE marc-beskz,  "조달 유형
          sobsl      TYPE marc-sobsl,  " 특별 조달 유형
*          werks TYPE mast-werks,
*          matnr TYPE mast-matnr,
          stlan      TYPE mast-stlan,    "BOM 용도
          stlal      TYPE mast-stlal,     "대체 BOM
          stlnr      TYPE mast-stlnr,      "BOM
*          werks TYPE mapl-werks,
*          matnr TYPE mapl-matnr,
          plnnr      TYPE mapl-plnnr,   " 태스크 리스트 그룹의 키
          plnty      TYPE mapl-plnty,   " 태스크 리스트 유형
          plnal      TYPE mapl-plnal,   " 그룹 카운터
          delflag(1),
        END OF gs_data.

 DATA : BEGIN OF gs_mkal,
          matnr    LIKE mkal-matnr,  " 품목코드
          werks    LIKE mkal-werks,  " 플랜트
          verid    LIKE mkal-verid,  " 생산버전
          text1    LIKE mkal-text1,  " 생산버전내역
          adatu    LIKE mkal-adatu,  " 효력시작일
          bdatu    LIKE mkal-bdatu,  " 효력종료일
          stlan    LIKE mkal-stlan,  " BOM 용도
          stlal    LIKE mkal-stlal,  " 대체 BOM
          plnnr    LIKE mkal-plnnr,  " 그룹번호
          plnty    LIKE mkal-plnty,  " 태스트 리스트 유형
          alnal    LIKE mkal-alnal,  " 그룹카운터
          prfg_s   LIKE mkal-prfg_s, "  BOM 점검
          prfg_f   LIKE mkal-prfg_f, "  라우팅 점검
          prdat    LIKE mkal-bdatu,  "  최종점검일자
          dflag(1),
        END OF gs_mkal.

 DATA : BEGIN OF gs_resb,
          matnr    TYPE resb-matnr,
          bdmng    TYPE resb-bdmng,
          meins    TYPE resb-meins,
          aufnr    TYPE resb-aufnr,
          objnr    TYPE resb-objnr,
          erfme    TYPE resb-erfme,
          dflag(1),
        END OF gs_resb.

 DATA : BEGIN OF gs_mseg,
          aufnr TYPE mseg-aufnr,
          matnr TYPE mseg-matnr,
          menge TYPE mseg-menge,
          meins TYPE mseg-meins,
          shkzg TYPE mseg-shkzg,
        END OF gs_mseg.

 DATA : BEGIN OF gs_makt,
          matnr TYPE makt-matnr,
          spras TYPE makt-spras,
          maktx TYPE makt-maktx,
        END OF gs_makt.

 DATA : BEGIN OF gs_t001w,
          werks TYPE t001w-werks,
          name1 TYPE t001w-name1,
        END OF gs_t001w.

* display data
 DATA : BEGIN OF gs_disp,
          zstat(4),                       "처리상태
          zmessage(100),                  " 메시지
          matnr          LIKE mkal-matnr,  " 품목코드
          maktx          LIKE makt-maktx,  " 품목내역
          werks          LIKE mkal-werks,  " 플랜트
          name1          LIKE t001w-name1, "  플랜트내역
          verid          LIKE mkal-verid,  " 생산버전
          text1          LIKE mkal-text1,  " 생산버전내역
          adatu          LIKE mkal-adatu,  " 효력시작일
          bdatu          LIKE mkal-bdatu,  " 효력종료일
          stlan          LIKE mkal-stlan,  " BOM 용도
          stlal          LIKE mkal-stlal,  " 대체 BOM
          stlst          LIKE stko-stlst,  " BOM 상태
          plnnr          LIKE mkal-plnnr,  " 그룹번호
          plnty          LIKE mkal-plnty,  " 태스트 리스트 유형
          alnal          LIKE mkal-alnal,  " 그룹카운터
          prfg_s         LIKE mkal-prfg_s, "  BOM 점검
          prfg_s_icon(4),                  "  BOM 점검 icon
          prfg_f         LIKE mkal-prfg_f, "  라우팅 점검
          prfg_f_icon(4),                  "  라우팅 점검 icon
          prdat          LIKE mkal-bdatu,  "  최종점검일자
          delflag(1),                      " 삭제 대상 레코드
          delflag2(1),                     " 생산버젼 생성 유무
          beskz          LIKE marc-beskz,  " 조달 유형
          sobsl          LIKE marc-sobsl,  "특별 조달 유형
          cellscol       TYPE  lvc_t_scol,
          celltab        TYPE  lvc_t_styl,
        END OF gs_disp.

 DATA : BEGIN OF gs_disp_add,
          zstat(4),                       "처리상태
          zmessage(100),                  " 메시지
          matnr          LIKE mkal-matnr,  " 품목코드
          maktx          LIKE makt-maktx,  " 품목내역
          werks          LIKE mkal-werks,  " 플랜트
          name1          LIKE t001w-name1, "  플랜트내역
          verid          LIKE mkal-verid,  " 생산버전
          text1          LIKE mkal-text1,  " 생산버전내역
          adatu          LIKE mkal-adatu,  " 효력시작일
          bdatu          LIKE mkal-bdatu,  " 효력종료일
          stlan          LIKE mkal-stlan,  " BOM 용도
          stlal          LIKE mkal-stlal,  " 대체 BOM
          stlst          LIKE stko-stlst,  " BOM 상태
          plnnr          LIKE mkal-plnnr,  " 그룹번호
          plnty          LIKE mkal-plnty,  " 태스트 리스트 유형
          alnal          LIKE mkal-alnal,  " 그룹카운터
          prfg_s         LIKE mkal-prfg_s, "  BOM 점검
          prfg_s_icon(4),                  "  BOM 점검 icon
          prfg_f         LIKE mkal-prfg_f, "  라우팅 점검
          prfg_f_icon(4),                  "  라우팅 점검 icon
          prdat          LIKE mkal-bdatu,  "  최종점검일자
          delflag(1),                      " 삭제 대상 레코드
          delflag2(1),                     " 생산버젼 생성 유무
          beskz          LIKE marc-beskz,  " 조달 유형
          sobsl          LIKE marc-sobsl,  "특별 조달 유형
          cellscol       TYPE  lvc_t_scol,
          celltab        TYPE  lvc_t_styl,
        END OF gs_disp_add.

*-----------------------------------------------------------------*
* DATA: TYPES
*-----------------------------------------------------------------*
 " 생산버젼 생성
 TYPES : BEGIN OF lt_mkal,
           matnr  TYPE  mkal-matnr,
           werks  TYPE  mkal-werks,
           verid  TYPE  mkal-verid,
           bdatu  TYPE  mkal-bdatu,
           adatu  TYPE  mkal-adatu,
           stlal  TYPE  mkal-stlal,
           stlan  TYPE  mkal-stlan,
           plnty  TYPE  mkal-plnty,
           plnnr  TYPE  mkal-plnnr,
           alnal  TYPE  mkal-alnal,
           beskz  TYPE  mkal-beskz,
           sobsl  TYPE  mkal-sobsl,
           losgr  TYPE  mkal-losgr,
           mdv01  TYPE  mkal-mdv01,
           mdv02  TYPE  mkal-mdv02,
           text1  TYPE  mkal-text1,
           ewahr  TYPE  mkal-ewahr,
           verto  TYPE  mkal-verto,
           serkz  TYPE  mkal-serkz,
           bstmi  TYPE  mkal-bstmi,
           bstma  TYPE  mkal-bstma,
           rgekz  TYPE  mkal-rgekz,
           alort  TYPE  mkal-alort,
           pltyg  TYPE  mkal-pltyg,
           plnng  TYPE  mkal-plnng,
           alnag  TYPE  mkal-alnag,
           pltym  TYPE  mkal-pltym,
           plnnm  TYPE  mkal-plnnm,
           alnam  TYPE  mkal-alnam,
           csplt  TYPE  mkal-csplt,
           matko  TYPE  mkal-matko,
           elpro  TYPE  mkal-elpro,
           prvbe  TYPE  mkal-prvbe,
           prfg_f TYPE  mkal-prfg_f,
           prdat  TYPE  mkal-prdat,
           mksp   TYPE  mkal-mksp,
           prfg_r TYPE  mkal-prfg_r,
           prfg_g TYPE  mkal-prfg_g,
           prfg_s TYPE  mkal-prfg_s,
           ucmat  TYPE  mkal-ucmat,
*      utilized type  mkal-utilized  ,
*      sauft    type  mkal-sauft     ,
         END OF lt_mkal.
*-----------------------------------------------------------------*
* DATA: Internal Table.
*-----------------------------------------------------------------*
 DATA : gt_disp   LIKE TABLE OF gs_disp . "전송 ALV 테이블
 DATA : gt_disp1  LIKE TABLE OF gs_disp . "전송 ALV 테이블 생산오더별
 DATA : gt_disp2  LIKE TABLE OF gs_disp.  "전송 ALV 테이블 모품목별
 DATA : gt_disp3  LIKE TABLE OF gs_disp.  "전송 ALV 테이블 자품목별
 DATA : gt_disp_add  LIKE TABLE OF gs_disp_add.  "전송 ALV 테이블 자품목별
 DATA : gt_disp_tmp  LIKE TABLE OF gs_disp WITH HEADER LINE.
 DATA : gt_disp_mat  LIKE TABLE OF gs_disp WITH HEADER LINE.
 DATA : gt_data LIKE TABLE OF gs_data WITH HEADER LINE.
 DATA : gt_data_tmp LIKE TABLE OF gs_data WITH HEADER LINE.
 DATA : gt_data_wemng LIKE TABLE OF gs_data WITH HEADER LINE.
 DATA : gt_resb LIKE TABLE OF gs_resb WITH HEADER LINE.
 DATA : gt_resb_sum LIKE TABLE OF gs_resb WITH HEADER LINE.
 DATA : gt_mseg LIKE TABLE OF gs_mseg WITH HEADER LINE.
 DATA : gt_mseg_tmp LIKE TABLE OF gs_mseg WITH HEADER LINE.
 DATA : gt_mseg_sum LIKE TABLE OF gs_mseg WITH HEADER LINE.
 DATA : gt_makt LIKE TABLE OF gs_makt WITH HEADER LINE.
 DATA : gt_t001w LIKE TABLE OF gs_t001w WITH HEADER LINE.
 DATA : gt_mkal LIKE TABLE OF gs_mkal WITH HEADER LINE.

*& 도움말 생성관련 구조 및 테이블정의...
 DATA  : gs_selectfield  LIKE help_info-fieldname,
         gs_select_value LIKE help_info-fldvalue,
         gt_field        LIKE help_value OCCURS 0 WITH HEADER LINE,
         gt_dynpread     LIKE dynpread   OCCURS 0 WITH HEADER LINE,
         gt_dynpupdate   TYPE dynpread   OCCURS 0 WITH HEADER LINE,
         gt_row_no       TYPE lvc_t_roid WITH HEADER LINE.

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

*- BDC
 DATA: gs_params  LIKE ctu_params,
       gt_bdcdata LIKE bdcdata OCCURS 0 WITH HEADER LINE,
       gt_message LIKE bdcmsgcoll OCCURS 0 WITH HEADER LINE.
