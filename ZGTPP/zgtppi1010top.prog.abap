*&----------------------------------------------------------------*
*& Include          ZGTPPI1010TOP
*&----------------------------------------------------------------*
*-----------------------------------------------------------------*
* TABLES
*-----------------------------------------------------------------*
 TABLES: CRHD, T001W, ZGTPPT1020.
*-----------------------------------------------------------------*
* DATA: Variable
*-----------------------------------------------------------------*
 DATA : GV_ERROR,
        GT_UCOMM    TYPE TABLE OF SY-UCOMM,
        GV_OK_CODE  LIKE SY-UCOMM,
        GV_OK_CODE2 LIKE SY-UCOMM.

 DATA : GV_RESULT  TYPE ZO_RESULT,
        GV_MESSAGE TYPE ZO_MESSAGE.

 DATA : GV_ANSWER TYPE C,
        GV_CNT    TYPE SY-INDEX.

 RANGES : GR_WERKS FOR MAPL-WERKS.
*-----------------------------------------------------------------*
* DATA: Structure. (Field strings : Working area)
*-----------------------------------------------------------------*
* 데이터 취합
 DATA : BEGIN OF GS_DATA,
          WERKS               LIKE CRHD-WERKS, "플랜트
          ARBPL               LIKE CRHD-ARBPL, "작업장 코드
          VERWE               LIKE CRHD-VERWE,  "작업장 범주
          VERAN               LIKE CRHD-VERAN,  "책임자
          LVORM               LIKE CRHD-LVORM, "삭제플래그
          BEGDA               LIKE CRHD-BEGDA, "시작일
          AEDAT_GRND          LIKE CRHD-AEDAT_GRND, "변경일
          KOSTL               LIKE CRCO-KOSTL, "코스트센터
          KTEXT               LIKE CRTX-KTEXT, "작업장 내역
          LASTCHANGE_DATETIME LIKE CRHD-LASTCHANGE_DATETIME, "최종변경일자
        END OF GS_DATA.
* 전송
 DATA : BEGIN OF GS_DISP,
          ICON(4), "전송 상태
          ZMESSAGE(100), "결과 메시지
          ZSYSTEM_ID      LIKE ZGTPPT1020-ZSYSTEM_ID, "수신 시스템
          ZSYSTEM_ID_DESC LIKE DD07V-DDTEXT, "시스템 내역
          WERKS           LIKE CRHD-WERKS, "플랜트
          ARBPL           LIKE CRHD-ARBPL, " 작업장 코드
          KTEXT           LIKE CRTX-KTEXT, "작업장 내역
          VERWE           LIKE CRHD-VERWE, "작업장 범주
          ZZTEXT1         LIKE TC30T-KTEXT, "작업장 범주 내역
          VERAN           LIKE CRHD-VERAN, "책임자
          ZZTEXT2         LIKE TC24-KTEXT, "책임자 내역
          KOSTL           LIKE CRCO-KOSTL, "코스트센터
          LVORM           LIKE CRHD-LVORM, "삭제플래그
          BEGDA           LIKE CRHD-BEGDA, "시작일
          AEDAT_GRND      LIKE CRHD-AEDAT_GRND, "변경일
          GONG_CD         LIKE ZEDT0011-GONG_CD,
          GONG_NM         LIKE ZEDT0011-GONG_NM,
        END OF GS_DISP.
* 로그 조회(재처리)
 DATA : BEGIN OF GS_DISP2,
          ZIFKEY          LIKE ZGTPPT1020-ZIFKEY, "인터페이스 키
          ZSTAT           LIKE ZGTPPT1020-ZSTAT, "전송 결과
          ICON(4), "전송 결과
          ZMESSAGE        LIKE ZGTPPT1020-ZMESSAGE, "결과 메시지
          ZSYSTEM_ID      LIKE ZGTPPT1020-ZSYSTEM_ID, "수신 시스템
          ZSYSTEM_ID_DESC LIKE DD07V-DDTEXT, "시스템 내역
          WERKS           LIKE ZGTPPT1020-WERKS, "플랜트
          ARBPL           LIKE ZGTPPT1020-ARBPL, " 작업장 코드
          KTEXT           LIKE ZGTPPT1020-KTEXT, "작업장 내역
          VERWE           LIKE ZGTPPT1020-VERWE, "작업장 범주
          ZZTEXT1         LIKE ZGTPPT1020-ZZTEXT1, "작업장 범주 내역
          VERAN           LIKE ZGTPPT1020-VERAN, "책임자
          ZZTEXT2         LIKE ZGTPPT1020-ZZTEXT2, "책임자 내역
          KOSTL           LIKE ZGTPPT1020-KOSTL, "코스트센터
          LVORM           LIKE ZGTPPT1020-LVORM, "삭제플래그
          BEGDA           LIKE ZGTPPT1020-BEGDA, "시작일
          AEDAT_GRND      LIKE ZGTPPT1020-AEDAT_GRND, "변경일
          GONG_CD         LIKE ZEDT0011-GONG_CD,
          GONG_NM         LIKE ZEDT0011-GONG_NM,
          IFDAT           LIKE ZGTPPT1020-IFDAT, "전송일자
          IFTIM           LIKE ZGTPPT1020-IFTIM, "전송시간
          IFNAM           LIKE ZGTPPT1020-IFNAM, "전송자
        END OF GS_DISP2.

 DATA : GS_ZGTPPT1010 LIKE ZGTPPT1010.
 DATA : GS_ZGTPPT1020 LIKE ZGTPPT1020.
 DATA : GS_SEND LIKE ZGTPPT1020.
*-----------------------------------------------------------------*
* DATA: Internal Table.
*-----------------------------------------------------------------*
 DATA : GT_DISP   LIKE TABLE OF GS_DISP.   "전송 ALV 테이블
 DATA : GT_DISP2 LIKE TABLE OF GS_DISP2. "로그 조회(재처리) ALV 테이블
 DATA : GT_ZGTPPT1010 TYPE TABLE OF ZGTPPT1010. "코드 마스터 테이블
 DATA : GT_DATA LIKE TABLE OF GS_DATA.
 DATA : GT_ZGTPPT1020 LIKE TABLE OF GS_ZGTPPT1020.
 DATA : GT_SEND LIKE TABLE OF ZGTPPT1020. "ALV 출력용 테이블 (전송 이력 조회)
 DATA : GT_OT_ITAB  TYPE TABLE OF ZGTPPSIF0003. "MES 전송용 테이블
 DATA : GT_ROW_NO TYPE LVC_T_ROID WITH HEADER LINE.
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
