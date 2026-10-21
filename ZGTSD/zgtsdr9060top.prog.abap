*&---------------------------------------------------------------------*
*& Include          ZGTSDR9060TOP
*&---------------------------------------------------------------------*
*-----------------------------------------------------------------------
*-- Tables
*-----------------------------------------------------------------------
TABLES : zgtsdt0065, zgtsdt0066, zgtsdt9060,
         vbak, vbap, likp, lips, mska.

*-----------------------------------------------------------------------
*-- Types
*-----------------------------------------------------------------------
*-- Open S/O Types
TYPES : BEGIN OF gty_open_so,
          auart   TYPE vbak-auart,                        " 오더유형
          bstnk   TYPE vbak-bstnk,                        " 프로젝트번호
          bstkd_e TYPE vbkd-bstkd_e,                      " 제조지시번호
          soldto  TYPE vbak-kunnr,                        " 거래처
          shipto  TYPE vbpa-kunnr,                        " 납품처
          vbeln   TYPE vbak-vbeln,                        " 판매오더
          posnr   TYPE vbap-posnr,                        " 품목
          matnr   TYPE vbap-matnr,                        " 자재
          arktx   TYPE vbap-arktx,                        " 자재내역
          kwmeng  TYPE vbap-kwmeng,                       " 수량
          vrkme   TYPE vbap-vrkme,                        " 단위
          kbetr   TYPE prcd_elements-kbetr,               " 단가
          kwert   TYPE prcd_elements-kwert,               " 금액
          waerk   TYPE vbak-waerk,                        " 통화
          lfsta   TYPE vbap-lfsta,                        " 납품상태
        END OF gty_open_so,
        gty_t_open_so TYPE TABLE OF gty_open_so WITH EMPTY KEY.

*-- Open D/O / Shipment Types
TYPES : BEGIN OF gty_open_do,
          bstnk   TYPE vbak-bstnk,                        " 프로젝트번호
          bstkd_e TYPE vbkd-bstkd_e,                      " 제조지시
          soldto  TYPE vbak-kunnr,                        " 거래처
          shipto  TYPE vbpa-kunnr,                        " 납품처
          name1   TYPE kna1-name1,                        " 거래처명
          vgbel   TYPE lips-vgbel,                        " 판매오더
          vgpos   TYPE lips-vgpos,                        " S/O 품목
          vbeln   TYPE lips-vbeln,                        " 납품오더
          posnr   TYPE lips-posnr,                        " D/O 품목
          matnr   TYPE lips-matnr,                        " 자재
          arktx   TYPE lips-arktx,                        " 자재내역
          lfimg   TYPE lips-lfimg,                        " 수량
          vrkme   TYPE lips-vrkme,                        " 단위
          erdat   TYPE lips-erdat,                        " 생성일
        END OF gty_open_do,
        gty_t_open_do TYPE TABLE OF gty_open_do WITH EMPTY KEY.

*-- Open HU Types
TYPES : BEGIN OF gty_open_hu,
          exidv TYPE vekp-exidv,                          " 외부 하역 단위 번호
          venum TYPE vepo-venum,                          " 내부 하역 단위 번호
          vepos TYPE vepo-vepos,                          " 하역 단위 품목
          matnr TYPE vepo-matnr,                          " 자재번호
          charg TYPE vepo-charg,                          " 배치번호
          werks TYPE vepo-werks,                          " 플랜트
          lgort TYPE vepo-lgort,                          " 저장위치
        END OF gty_open_hu,
        gty_t_open_hu TYPE TABLE OF gty_open_hu.

*-- Mapping Excel Upload Types
TYPES : BEGIN OF gty_excel_mapp,
          zpjno_o    TYPE zgtsdt9060-zpjno,               " ASIS 프로젝트
          job_no_o   TYPE zgtsdt9060-job_no_o,            " ASIS 제조지시번호
          vbeln_o    TYPE zgtsdt9060-vbeln,               " ASIS 판매오더
          posnr_o    TYPE zgtsdt9060-posnr,               " ASIS 품목
          matnr_o    TYPE zgtsdt9060-matnr,               " ASIS 자재코드
          arktx_o    TYPE zgtsdt9060-arktx,               " ASIS 자재내역
          kwmeng_o   TYPE zgtsdt9060-kwmeng,              " ASIS 수량
          vrkme_o    TYPE zgtsdt9060-vrkme,               " ASIS 단위

          zpjno_n    TYPE zgtsdt9060-zpjno,               " TOBE 프로젝트
          job_no_n   TYPE zgtsdt0066-job_no,              " TOBE 제조지시번호
          posnr_n    TYPE zgtsdt0066-posnr,               " TOBE 품목
          qcode      TYPE zgtsdt0066-qcode,               " TOBE 견적품코드
          qname      TYPE zgtsdt0066-qname,               " TOBE 견적품명
          qname_prnt TYPE zgtsdt0066-qname_prnt,          " TOBE 견적품 출력명
          qqty       TYPE zgtsdt0066-qqty,                " TOBE 견적품수량
          qunit      TYPE zgtsdt0066-qunit,               " TOBE 단위
          item_key   TYPE zgtsdt0066-item_key,            " ITEM KEY
        END OF gty_excel_mapp,
        gty_t_excel_mapp TYPE TABLE OF gty_excel_mapp WITH EMPTY KEY.

*-- Mapping Types
TYPES : BEGIN OF gty_mapp,
          zpjno_o    TYPE zgtsdt9060-zpjno,               " ASIS 프로젝트
          job_no_o   TYPE zgtsdt9060-job_no_o,            " ASIS 제조지시번호
          vbeln_o    TYPE zgtsdt9060-vbeln,               " ASIS 판매오더
          posnr_o    TYPE zgtsdt9060-posnr,               " ASIS 품목
          matnr_o    TYPE zgtsdt9060-matnr,               " ASIS 자재코드
          arktx_o    TYPE zgtsdt9060-arktx,               " ASIS 자재내역
          kwmeng_o   TYPE zgtsdt9060-kwmeng,              " ASIS 수량
          vrkme_o    TYPE zgtsdt9060-vrkme,               " ASIS 단위
          netpr_o    TYPE zgtsdt9060-netpr,               " ASIS 단가
          netwr_o    TYPE zgtsdt9060-netwr,               " ASIS 금액
          waerk_o    TYPE zgtsdt9060-waerk,               " ASIS 통화

          zpjno_n    TYPE zgtsdt9060-zpjno,               " TOBE 프로젝트
          job_no_n   TYPE zgtsdt0066-job_no,              " TOBE 제조지시번호
          posnr_n    TYPE zgtsdt0066-posnr,               " TOBE 품목
          vbeln_n    TYPE zgtsdt0066-vbeln,               " TOBE 판매오더
          qcode      TYPE zgtsdt0066-qcode,               " TOBE 견적품코드
          qname      TYPE zgtsdt0066-qname,               " TOBE 견적품명
          qname_prnt TYPE zgtsdt0066-qname_prnt,          " TOBE 견적품 출력명
          qqty       TYPE zgtsdt0066-qqty,                " TOBE 수량
          qunit      TYPE zgtsdt0066-qunit,               " TOBE 단위
          qprice     TYPE zgtsdt0066-qprice,              " TOBE 단가
          qamt       TYPE zgtsdt9060-netwr,               " TOBE 금액
          qwaerk     TYPE zgtsdt0066-qwaerk,              " TOBE 통화
          item_key   TYPE zgtsdt0066-item_key,            " ITEM KEY

          stat       TYPE char01,                         " 상태
          zmsg       TYPE zgtsdt0065-zmsg,                " 결과 메세지
        END OF gty_mapp,
        gty_t_mapp TYPE TABLE OF gty_mapp WITH EMPTY KEY.

*-- To-Be 데이터 생성 Excel Upload Types
TYPES : BEGIN OF gty_excel_tobe,
          mreqno        TYPE zgtsdt0065-mreqno,           " 제조지시요청번호
          zpjno         TYPE zgtsdt0065-zpjno,            " Project No
          job_no        TYPE zgtsdt0065-job_no,           " 제조지시 번호
          posnr         TYPE zgtsdt0065-posnr,            " 판매 문서 항목
          item_key      TYPE zgtsdt0065-item_key,         " 판매오더 연결 키
          job_name      TYPE zgtsdt0065-job_name,         " 제조지시명
          zdelv_date    TYPE zgtsdt0065-zdelv_date,       " 납품일
          matnr         TYPE zgtsdt0065-matnr,            " 자재번호
          maktx         TYPE zgtsdt0065-maktx,            " 자재명
          werks         TYPE zgtsdt0065-werks,            " 플랜트
          kwmeng        TYPE zgtsdt0065-kwmeng,           " 누적 오더 수량
          meins         TYPE zgtsdt0065-meins,            " 기본 단위
          ord_len       TYPE zgtsdt0065-ord_len,          " 주문길이
          ord_wgt       TYPE zgtsdt0065-ord_wgt,          " 주문중량
          voltage_cd    TYPE zgtsdt0065-voltage_cd,       " 전압코드
          prod_type     TYPE zgtsdt0065-prod_type,        " 제품구분
          wire_cnt      TYPE zgtsdt0065-wire_cnt,         " 상
          amphere       TYPE zgtsdt0065-amphere,          " 전류세기
          cond_mtrl     TYPE zgtsdt0065-cond_mtrl,        " 도체재질
          duct_mtrl_est TYPE zgtsdt0065-duct_mtrl_est,    " 덕트재질
          ground_type   TYPE zgtsdt0065-ground_type,      " 접지구분
          ipgrade       TYPE zgtsdt0065-ipgrade,          " IP 등급
          condtw        TYPE zgtsdt0065-condtw,           " 도체두께/폭/_S/O Key
          grspec        TYPE zgtsdt0065-grspec,           " 접지바규격
          stdname       TYPE zgtsdt0065-stdname,          " BD표준품명
          serialno      TYPE zgtsdt0065-serialno,         " 시리얼 정보
          ecoptype      TYPE zgtsdt0065-ecoptype,         " 친환경제품구분
          n_wire_type   TYPE zgtsdt0065-n_wire_type,      " N상구분
          brkmd         TYPE zgtsdt0065-brkmd,            " [특성]BUSPLUG_차단기모델
          framph        TYPE zgtsdt0065-framph,           " [특성]BUSPLUG_프레임전류
          opmthd        TYPE zgtsdt0065-opmthd,           " [특성]BUSPLUG_조작방법
          phtap         TYPE zgtsdt0065-phtap,            " [특성]BUSPLUG_PH/TAP구분
        END OF gty_excel_tobe,
        gty_t_excel_tobe TYPE TABLE OF gty_excel_tobe WITH EMPTY KEY.

*-- To-Be 데이터 생성 Types
TYPES : BEGIN OF gty_tobe,
          save_stat     TYPE icon_d,                      " 저장 상태

          mreqno        TYPE zgtsdt0065-mreqno,           " 제조지시요청번호
          zpjno         TYPE zgtsdt0065-zpjno,            " Project No
          job_no        TYPE zgtsdt0065-job_no,           " 제조지시 번호
          posnr         TYPE zgtsdt0065-posnr,            " 판매 문서 항목
          item_key      TYPE zgtsdt0065-item_key,         " 판매오더 연결 키

          vbeln_o       TYPE zgtsdt9060-vbeln,            " As-Is 판매문서

          job_name      TYPE zgtsdt0065-job_name,         " 제조지시명
          zdelv_date    TYPE zgtsdt0065-zdelv_date,       " 납품일
          matnr         TYPE zgtsdt0065-matnr,            " 자재번호
          maktx         TYPE zgtsdt0065-maktx,            " 자재명
          werks         TYPE zgtsdt0065-werks,            " 플랜트
          kwmeng        TYPE zgtsdt0065-kwmeng,           " 누적 오더 수량
          meins         TYPE zgtsdt0065-meins,            " 기본 단위
          ord_len       TYPE zgtsdt0065-ord_len,          " 주문길이
          ord_wgt       TYPE zgtsdt0065-ord_wgt,          " 주문중량
          voltage_cd    TYPE zgtsdt0065-voltage_cd,       " 전압코드
          prod_type     TYPE zgtsdt0065-prod_type,        " 제품구분
          wire_cnt      TYPE zgtsdt0065-wire_cnt,         " 상
          amphere       TYPE zgtsdt0065-amphere,          " 전류세기
          cond_mtrl     TYPE zgtsdt0065-cond_mtrl,        " 도체재질
          duct_mtrl_est TYPE zgtsdt0065-duct_mtrl_est,    " 덕트재질
          ground_type   TYPE zgtsdt0065-ground_type,      " 접지구분
          ipgrade       TYPE zgtsdt0065-ipgrade,          " IP 등급
          condtw        TYPE zgtsdt0065-condtw,           " 도체두께/폭/_S/O Key
          grspec        TYPE zgtsdt0065-grspec,           " 접지바규격
          stdname       TYPE zgtsdt0065-stdname,          " BD표준품명
          serialno      TYPE zgtsdt0065-serialno,         " 시리얼 정보
          ecoptype      TYPE zgtsdt0065-ecoptype,         " 친환경제품구분
          n_wire_type   TYPE zgtsdt0065-n_wire_type,      " N상구분
          brkmd         TYPE zgtsdt0065-brkmd,            " [특성]BUSPLUG_차단기모델
          framph        TYPE zgtsdt0065-framph,           " [특성]BUSPLUG_프레임전류
          opmthd        TYPE zgtsdt0065-opmthd,           " [특성]BUSPLUG_조작방법
          phtap         TYPE zgtsdt0065-phtap,            " [특성]BUSPLUG_PH/TAP구분

          vbeln         TYPE zgtsdt0065-vbeln,            " 판매 관리 문서 번호
          chr_key       TYPE zgtsdt0065-chr_key,          " [특성] 조합키
          ojob_no       TYPE zgtsdt0065-ojob_no,          " 이전전기 대상 제조지시번호
          zstat         TYPE zgtsdt0065-zstat,            " 상태 값

          stat          TYPE char01,                      " 상태
          zmsg          TYPE bapi_msg,                    " 결과 메세지
        END OF gty_tobe,
        gty_t_tobe TYPE TABLE OF gty_tobe WITH EMPTY KEY.

*-- 공통코드 기준 주문속성 해당 필드 정보 구성 Types
TYPES : BEGIN OF gty_cfgs,
          charc   TYPE cu_charc,                          " To-Be 특성명
          charc_a TYPE cu_charc,                          " As-Is 특성명
          fname   TYPE fieldname,                         " 특성값 필드명
        END OF gty_cfgs,
        gty_t_cfgs TYPE TABLE OF gty_cfgs WITH EMPTY KEY.

*-- 견적품 정보 Types
TYPES : BEGIN OF gty_quote,
          job_no TYPE zgte_bd_jobno,                      " 제조지시 번호
          posnr  TYPE posnr_co,                           " 품목
          qprice TYPE zgte_bd_qprice,                     " 단가
          qqty   TYPE zgte_bd_qqty,                       " 수량
          qwaerk TYPE zgte_bd_qwaerk,                     " 통화단위
        END OF gty_quote,
        gty_t_quote TYPE TABLE OF gty_quote WITH EMPTY KEY.

*-- As-Is 품목단위 정보 Types
TYPES : BEGIN OF gty_asis,
          job_no  TYPE zgtsdt0065-job_no,                 " 제조지시 번호
          posnr_t TYPE zgtsdt0065-posnr,                  " To-Be 품목

          vbeln   TYPE zgtsdt9060-vbeln,                  " As-Is 판매문서
          posnr   TYPE zgtsdt9060-posnr,                  " As-Is 품목
        END OF gty_asis,
        gty_t_asis TYPE TABLE OF gty_asis WITH EMPTY KEY.

*-- As-IS / To-Be 특성값 Mapping 정보 Types
TYPES : BEGIN OF gty_cfgs_mapp,
          atnam_a TYPE atnam,                             " As-Is 특성명
          atwrt_a TYPE atwrt,                             " As-Is 특성값

          atnam_t TYPE atnam,                             " To-Be 특성명
          atwrt_t TYPE atwrt,                             " To-Be 특성값
        END OF gty_cfgs_mapp,
        gty_t_cfgs_mapp TYPE TABLE OF gty_cfgs_mapp WITH EMPTY KEY.

*-- As-Is 판매오더 거부사유 처리 Excel Upload Types
TYPES : BEGIN OF gty_rej_excel,
          vbeln TYPE vbeln_va,                            " 판매문서
          posnr TYPE posnr_va,                            " 품목
        END OF gty_rej_excel,
        gty_t_rej_excel TYPE TABLE OF gty_rej_excel WITH EMPTY KEY.

*-- As-Is 판매오더 거부사유 처리 Types
TYPES : BEGIN OF gty_rej_ord,
          bstnk   TYPE vbak-bstnk,                        " 프로젝트 번호
          bstkd_e TYPE vbkd-bstkd_e,                      " 제조지시 번호
          vbeln   TYPE vbap-vbeln,                        " 판매문서
          posnr   TYPE vbap-posnr,                        " 품목
          matnr   TYPE vbap-matnr,                        " 자재코드
          arktx   TYPE vbap-arktx,                        " 자재내역
          werks   TYPE vbap-werks,                        " 플랜트
          kwmeng  TYPE vbap-kwmeng,                       " 수량
          vrkme   TYPE vbap-vrkme,                        " 단위

          stat    TYPE char01,                            " 상태
          zmsg    TYPE bapi_msg,                          " 메세지
        END OF gty_rej_ord,
        gty_t_rej_ord TYPE TABLE OF gty_rej_ord WITH EMPTY KEY.

*-- Save / Delete Table Types
TYPES : gty_9060     TYPE zgtsdt9060,
        gty_t_9060   TYPE TABLE OF gty_9060   WITH EMPTY KEY,

        gty_0065     TYPE zgtsdt0065,
        gty_t_0065   TYPE TABLE OF gty_0065   WITH EMPTY KEY,

        gty_0066     TYPE zgtsdt0066,
        gty_t_0066   TYPE TABLE OF gty_0066   WITH EMPTY KEY,

        gty_0066_u   TYPE zgtsdt0066          WITH INDICATORS ind,
        gty_t_0066_u TYPE TABLE OF gty_0066_u WITH EMPTY KEY.


*-- 판매오더 BAPI 관련 Types
TYPES : gty_t_sdbu TYPE TABLE OF bapisdbusi WITH EMPTY KEY.

*-----------------------------------------------------------------------
* Internal Table
*-----------------------------------------------------------------------
DATA : gt_open_so TYPE gty_t_open_so,
       gt_open_do TYPE gty_t_open_do,
       gt_open_hu TYPE gty_t_open_hu,

       gt_mapp    TYPE gty_t_mapp,
       gt_tobe    TYPE gty_t_tobe,
       gt_rej_ord TYPE gty_t_rej_ord.

*-----------------------------------------------------------------------
*-- Structure & Values
*-----------------------------------------------------------------------
DATA : gv_okcode  TYPE syucomm,

       gv_eflag   TYPE char01,
       gv_decimal TYPE xudcpfm.

*-----------------------------------------------------------------------
*-- ALV Global Values
*-----------------------------------------------------------------------
DATA : gt_fcat_0100 TYPE lvc_t_fcat,
       gt_sort_0100 TYPE lvc_t_sort,
       gt_excl_0100 TYPE ui_functions.

DATA : gs_layo_0100 TYPE lvc_s_layo,
       gs_vari_0100 TYPE disvariant.

*-----------------------------------------------------------------------
*-- Constants
*-----------------------------------------------------------------------
CONSTANTS : BEGIN OF gc_spart,
              60 TYPE spart                     VALUE '60',         " 부스닥트
            END OF gc_spart,
*-- Range Sign
            BEGIN OF gc_sign,
              i TYPE ddsign                     VALUE 'I',
              e TYPE ddsign                     VALUE 'E',
            END OF gc_sign,
*-- Range Option
            BEGIN OF gc_optn,
              eq TYPE ddoption                  VALUE 'EQ',
              ne TYPE ddoption                  VALUE 'NE',
              bt TYPE ddoption                  VALUE 'BT',
              cp TYPE ddoption                  VALUE 'CP',
            END OF gc_optn,
*-- ALV Exec LED
            BEGIN OF gc_led,
              red      TYPE char01              VALUE '1',
              yellow   TYPE char01              VALUE '2',
              green    TYPE char01              VALUE '3',
              inactive TYPE char01              VALUE abap_false,
            END OF gc_led,
*-- 납품상태
            BEGIN OF gc_lfsta,
              a TYPE lfsta                      VALUE 'A',          " 처리되지 않음
              b TYPE lfsta                      VALUE 'B',          " 일부 처리됨
              c TYPE lfsta                      VALUE 'C',          " 전부 처리됨
            END OF gc_lfsta,
*-- 조건유형
            BEGIN OF gc_kschl,
              zpr0 TYPE kscha                   VALUE 'ZPR0',       " 수기가격
            END OF gc_kschl,
*-- 파트너 기능
            BEGIN OF gc_parvw,
              we TYPE parvw                     VALUE 'WE',         " 납품처
            END OF gc_parvw,
*-- 피킹 상태/반입 상태(항목)
            BEGIN OF gc_kosta,
              a TYPE kosta                      VALUE 'A',          " 처리되지 않음
              b TYPE kosta                      VALUE 'B',          " 일부 처리됨
              c TYPE kosta                      VALUE 'C',          " 전부 처리됨
            END OF gc_kosta,
*-- 운송 계획 상태(헤더)
            BEGIN OF gc_trsta,
              a TYPE trsta                      VALUE 'A',          " 처리되지 않음
              b TYPE trsta                      VALUE 'B',          " 일부 처리됨
              c TYPE trsta                      VALUE 'C',          " 전부 처리됨
            END OF gc_trsta,
*-- I/F Target 시스템
            BEGIN OF gc_sysid,
              kbdm TYPE zgtetarget              VALUE 'KBDM',
            END OF gc_sysid,
*-- 상태 값
            BEGIN OF gc_zstat,
              m TYPE zgte_zstat                 VALUE 'M',
            END OF gc_zstat,
*-- 거부사유
            BEGIN OF gc_abgru,
              08 TYPE abgru_va                  VALUE '08',         " [주문취소]주문 입력 오류
            END OF gc_abgru,
*-- 일자 타입
            BEGIN OF gc_prgrs,
              1 TYPE prgrs                      VALUE '1',          " 일
              2 TYPE prgrs                      VALUE '2',          " 주
              3 TYPE prgrs                      VALUE '3',          " 월
              4 TYPE prgrs                      VALUE '4',          " 전기 기간
              5 TYPE prgrs                      VALUE '5',          " 계획 달력 기간
            END OF gc_prgrs,
*-- SD 문서 범주
            BEGIN OF gc_vbtyp,
              c TYPE vbtyp                      VALUE 'C',          " 오더
              b TYPE vbtyp                      VALUE 'B',          " 견적
            END OF gc_vbtyp,
*-- Quan 단위
            BEGIN OF gc_unit,
              m TYPE meins                      VALUE 'M',          " 미터
            END OF gc_unit,

            BEGIN OF gc_mtart,
              fert TYPE mtart                   VALUE 'FERT',
            END OF gc_mtart,

            BEGIN OF gc_pstyv,
              zbis TYPE pstyv                   VALUE 'ZBIS',
            END OF gc_pstyv.
