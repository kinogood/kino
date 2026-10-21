*&----------------------------------------------------------------*
*& Include          ZGTPPI1030TOP
*&----------------------------------------------------------------*
*-----------------------------------------------------------------*
* TABLES
*-----------------------------------------------------------------*
 TABLES: MARA, MKAL, T001W, ZGTPPT1040.
*-----------------------------------------------------------------*
* DATA: Variable
*-----------------------------------------------------------------*
 DATA : GV_ERROR.
 DATA : GT_UCOMM    TYPE TABLE OF SY-UCOMM,
        GV_OK_CODE  LIKE SY-UCOMM,
        GV_OK_CODE2 LIKE SY-UCOMM.
 DATA : GV_CNT  TYPE SY-INDEX.
 DATA : GV_RESULT  TYPE ZO_RESULT,
        GV_MESSAGE TYPE ZO_MESSAGE.
 DATA : GV_ANSWER TYPE C.
 DATA : GV_LINES_C TYPE C LENGTH 10.

 RANGES : GR_WERKS FOR MAPL-WERKS.
*-----------------------------------------------------------------*
* DATA: Structure. (Field strings : Working area)
*-----------------------------------------------------------------*
 DATA : BEGIN OF GS_DATA,
          MATNR TYPE MARA-MATNR,
          WERKS TYPE MARC-WERKS,
          VERID TYPE MKAL-VERID,
          ANDAT TYPE MKAL_AEND-ANDAT,
          AEDAT TYPE MKAL_AEND-AEDAT,
          ZAEHL TYPE MKAL_AEND-ZAEHL,
        END OF GS_DATA.

 DATA : BEGIN OF GS_MKAL,
          MATNR LIKE MKAL-MATNR,
          WERKS LIKE MKAL-WERKS,
          VERID LIKE MKAL-VERID,
          TEXT1 LIKE MKAL-TEXT1,
          ADATU LIKE MKAL-ADATU,
          BDATU LIKE MKAL-BDATU,
          PLNNR LIKE MKAL-PLNNR,
          ALNAL LIKE MKAL-ALNAL,
          STLAL LIKE MKAL-STLAL,
          MDV01 LIKE MKAL-MDV01,
          ALORT LIKE MKAL-ALORT,
          ELPRO LIKE MKAL-ELPRO,
          MTART LIKE MARA-MTART,
          DISPO LIKE MARC-DISPO,

          PRDAT LIKE MKAL-PRDAT,
        END OF GS_MKAL.
* 전송
 DATA : BEGIN OF GS_DISP,
          ICON(4), "전송 상태
          ZMESSAGE(100), "결과 메시지
          ZSYSTEM_ID      LIKE ZGTPPT1040-ZSYSTEM_ID, "수신 시스템
          ZSYSTEM_ID_DESC LIKE DD07V-DDTEXT, "시스템 내역
          WERKS           LIKE MKAL-WERKS, "플랜트
          NAME1           LIKE T001W-NAME1, "플랜트 내역
          MATNR           LIKE MKAL-MATNR, " 자재코드
          MAKTX           LIKE MAKT-MAKTX, "자재내역
          VERID           LIKE MKAL-VERID, "Product Version
          TEXT1           LIKE MKAL-TEXT1, "Version Description
          ANDAT           LIKE MKAL_AEND-ANDAT, "생성일
          AEDAT           LIKE MKAL_AEND-AEDAT, "변경일
          ADATU           LIKE MKAL-ADATU, "생산버젼 효력발생일
          BDATU           LIKE MKAL-BDATU, "실행시간종료: 생산버젼
          PLNNR           LIKE MKAL-PLNNR, "직무리스트그룹 키
          ALNAL           LIKE MKAL-ALNAL, "Routing Group Counter
          STLAL           LIKE MKAL-STLAL, "대체 BOM No.
          MDV01           LIKE MKAL-MDV01, "작업장
          ALORT           LIKE MKAL-ALORT, "입고 저장위치
          ELPRO           LIKE MKAL-ELPRO, "출고 저장위치
        END OF GS_DISP.
* 로그 조회(재처리)
 DATA : BEGIN OF GS_DISP2,
          ZIFKEY          LIKE ZGTPPT1040-ZIFKEY, "인터페이스 키
          ZSEQNO          LIKE ZGTPPT1040-ZSEQNO, "순번
          ZSTAT           LIKE ZGTPPT1040-ZSTAT, "전송 결과
          ICON(4), "전송 결과
          ZMESSAGE        LIKE ZGTPPT1040-ZMESSAGE, "결과 메시지
          ZSYSTEM_ID      LIKE ZGTPPT1040-ZSYSTEM_ID, "수신 시스템
          ZSYSTEM_ID_DESC LIKE DD07V-DDTEXT, "시스템 내역
          WERKS           LIKE ZGTPPT1040-WERKS, "플랜트
          NAME1           LIKE T001W-NAME1, "플랜트 내역
          MATNR           LIKE ZGTPPT1040-MATNR, " 자재코드
          MAKTX           LIKE MAKT-MAKTX, "자재내역
          VERID           LIKE ZGTPPT1040-VERID, "Product Version
          TEXT1           LIKE ZGTPPT1040-TEXT1, "Version Description
          ANDAT           LIKE ZGTPPT1040-ANDAT, "생성일
          AEDAT           LIKE ZGTPPT1040-AEDAT, "변경일
          ADATU           LIKE ZGTPPT1040-ADATU, "생산버젼 효력발생일
          BDATU           LIKE ZGTPPT1040-BDATU, "실행시간종표: 생산버젼
          PLNNR           LIKE ZGTPPT1040-PLNNR, "직무리스트그룹 키
          ALNAL           LIKE ZGTPPT1040-ALNAL, "Routing Group Counter
          STLAL           LIKE ZGTPPT1040-STLAL, "대체 BOM No.
          MDV01           LIKE ZGTPPT1040-MDV01, "작업장
          ALORT           LIKE ZGTPPT1040-ALORT, "입고 저장위치
          ELPRO           LIKE ZGTPPT1040-ELPRO, "출고 저장위치
          IFDAT           LIKE ZGTPPT1040-IFDAT, "전송일자
          IFTIM           LIKE ZGTPPT1040-IFTIM, "전송시간
          IFNAM           LIKE ZGTPPT1040-IFNAM, "전송자
        END OF GS_DISP2.

 DATA : GS_ZGTPPT1040 LIKE ZGTPPT1040.
 DATA : GS_SEND LIKE ZGTPPT1040.
 DATA : GS_ZGTPPT1010 LIKE ZGTPPT1010.
*-----------------------------------------------------------------*
* DATA: Internal Table.
*-----------------------------------------------------------------*
* DATA : GT_MKAL TYPE TABLE OF ZAUIF_PP_S006S. "HISTORY_TABLE 저장용 테이블
 DATA : GT_MKAL LIKE TABLE OF GS_MKAL.
 DATA : GT_DISP   LIKE TABLE OF GS_DISP.   "전송 ALV 테이블
 DATA : GT_DISP2 LIKE TABLE OF GS_DISP2. "로그 조회(재처리) ALV 테이블
 DATA : GT_ZGTPPT1040 LIKE TABLE OF GS_ZGTPPT1040.
 DATA : GT_ROW_NO TYPE LVC_T_ROID WITH HEADER LINE.
 DATA : GT_SEND LIKE TABLE OF ZGTPPT1040. "ALV 출력용 테이블 (전송 이력 조회)
 DATA : GT_OT_ITAB  TYPE TABLE OF ZGTPPSIF0002. "MES 전송용 테이블
 DATA : GT_ZGTPPT1010 TYPE TABLE OF ZGTPPT1010. "코드 마스터 테이블
 DATA : GT_DATA LIKE TABLE OF GS_DATA.
*-----------------------------------------------------------------*
* ALV
*-----------------------------------------------------------------*
*& CLASS Reference 정의
 CLASS: LCL_EVENT_HANDLER      DEFINITION DEFERRED,
        LCL_ALV_GRID           DEFINITION DEFERRED.

*& ALV Global Field
 DATA : ALV_VARIANT LIKE DISVARIANT,
        ALV_REPID   LIKE SY-REPID.
*- ALV COMMON
 TYPE-POOLS : KKBLO.
 DATA : GS_STBL      TYPE LVC_S_STBL,
        GT_SFIELDCAT TYPE KKBLO_T_FIELDCAT,
        GS_EXCLUDING TYPE LINE OF UI_FUNCTIONS,
        GT_EXCLUDING TYPE UI_FUNCTIONS.

*- ALV1
 DATA : GRID                TYPE REF TO CL_GUI_ALV_GRID,
        G_CUSTOM_CONTAINER  TYPE REF TO CL_GUI_CUSTOM_CONTAINER,
        G_DOCKING_CONTAINER TYPE REF TO CL_GUI_DOCKING_CONTAINER,
        G_SPLITTER          TYPE REF TO CL_GUI_SPLITTER_CONTAINER,
        G_CONTAINER         TYPE REF TO CL_GUI_CONTAINER,
        G_CON               TYPE SCRFNAME VALUE 'ALV1',

        LCL_PARENT_HTML     TYPE REF TO CL_GUI_CONTAINER,
        LCL_PARENT_GRID     TYPE REF TO CL_GUI_CONTAINER,
        LCL_DYNDOC_ID       TYPE REF TO CL_DD_DOCUMENT.

 DATA : GS_LAYOUT   TYPE LVC_S_LAYO,
        GT_FIELDCAT TYPE LVC_T_FCAT,
        GS_FIELDCAT TYPE LVC_S_FCAT,
        GT_SORT     TYPE LVC_T_SORT,
        GS_SORT     TYPE LVC_S_SORT,
        GT_EXCLUDE  TYPE UI_FUNCTIONS,
        GT_STYL     TYPE LVC_T_STYL,
        GS_STYL     TYPE LVC_S_STYL.
*& Drop-Down List Box List.
 DATA : GT_DROPDOWN TYPE LVC_T_DROP,
        GS_DROPDOWN TYPE LVC_S_DROP.

 DATA : GO_DOCKING_CONTAINER TYPE REF TO CL_GUI_DOCKING_CONTAINER.
 DATA : GO_SPLITTER TYPE REF TO CL_GUI_SPLITTER_CONTAINER.
 DATA : GO_EVENT_HANDLER TYPE REF TO LCL_EVENT_HANDLER.
*-----------
*ALV GRID 100
 DATA : GO_CONTAIN_0100 TYPE REF TO CL_GUI_CONTAINER.
 DATA : GO_GRID_0100 TYPE REF TO CL_GUI_ALV_GRID.
 DATA : GS_VARIANT TYPE DISVARIANT.
 DATA : GS_LAYOUT_0100 TYPE LVC_S_LAYO.
 DATA : GT_SORT_0100 TYPE LVC_T_SORT.
 DATA : GT_EXCLUDE_0100 TYPE UI_FUNCTIONS.
 DATA : GT_FIELDCAT_0100 TYPE LVC_T_FCAT.
 DATA : GO_OBJECT TYPE REF TO CL_ALV_EVENT_TOOLBAR_SET.

*-----------
* ALV GRID 0101
 DATA : GO_CONTAIN_0101 TYPE REF TO CL_GUI_CONTAINER.
 DATA : GO_GRID_0101 TYPE REF TO CL_GUI_ALV_GRID.
 DATA : GS_LAYOUT_0101 TYPE LVC_S_LAYO.
 DATA : GT_SORT_0101 TYPE LVC_T_SORT.
 DATA : GT_EXCLUDE_0101 TYPE UI_FUNCTIONS.
 DATA : GT_FIELDCAT_0101 TYPE LVC_T_FCAT.

 DATA : GV_STABLE TYPE LVC_S_STBL VALUE 'XX'.
