*&----------------------------------------------------------------*
*& INCLUDE          ZGTPPI1030TOP
*&----------------------------------------------------------------*
*-----------------------------------------------------------------*
* TABLES
*-----------------------------------------------------------------*
 TABLES: MARA, MKAL, T001W, AUFK,ZGTPPT2130,
         ZPPT0107,AFPO, RESB, AFKO, AFRU, VBAK, MARC.
*-----------------------------------------------------------------*
* DATA: VARIABLE
*-----------------------------------------------------------------*
 DATA : GV_ERROR.
 DATA : GT_UCOMM    TYPE TABLE OF SY-UCOMM,
        GV_OK_CODE  LIKE SY-UCOMM,
        GV_OK_CODE2 LIKE SY-UCOMM.
 DATA : GV_CNT      TYPE SY-INDEX.
 DATA : GV_RESULT   TYPE ZO_RESULT,
        GV_MESSAGE  TYPE ZO_MESSAGE.
 DATA : GV_ANSWER   TYPE C.
 DATA : GV_CHECK_ERROR.

*-----------------------------------------------------------------*
* DATA: STRUCTURE. (FIELD STRINGS : WORKING AREA)
*-----------------------------------------------------------------*

* 전송
 DATA : BEGIN OF GS_DISP,
          STATUS        LIKE ICON-ID,
          STATUS_VAL(3),
          WERKS         LIKE ZGTPPT2130-WERKS, "플랜트
          SPGCD         LIKE ZGTPPT2130-SPGCD,  " SPG 코드
          ARBPL         LIKE ZGTPPT2130-ARBPL,  "작업장
          DATUV         LIKE ZGTPPT2130-DATUV,  "효력 시작일
          DATUB         LIKE ZGTPPT2130-DATUB,  "효력 종료일
          OPTYPE        LIKE ZGTPPT2130-OPTYPE, " 가동유형
          OPTYPET(20)," 가동유형 내역
          OPRDAY        LIKE ZGTPPT2130-OPRDAY, " 소요일
          NOPNM         LIKE ZGTPPT2130-NOPNM,  " 비가동 내역
          ERDAT         LIKE ZGTPPT2130-ERDAT,  "레코드 생성일
          ERNAM         LIKE ZGTPPT2130-ERNAM,  "오브젝트 생성 책임자 이름
          AEDAT         LIKE ZGTPPT2130-AEDAT,  "최종 변경일
          AENAM         LIKE ZGTPPT2130-AENAM,  "오브젝트 변경자 이름
          KTEXT         LIKE CRTX-KTEXT,        " 작업장 내역
          CHK_CHG(1),  "
          NULL_CHK(1),
          CELLSCOL      TYPE  LVC_T_SCOL,
          CELLTAB       TYPE  LVC_T_STYL,
        END OF GS_DISP.


 DATA : BEGIN OF GS_CRHD,
          WERKS         LIKE CRHD-WERKS,  "작업장
          ARBPL         LIKE CRHD-ARBPL,  "작업장
          KTEXT         LIKE CRTX-KTEXT,  "작업장
        END OF GS_CRHD.

 DATA : BEGIN OF GS_OPTYPE,
          OPTYPE         LIKE ZGTPPT2130-OPTYPE,
          NOPNM         LIKE ZGTPPT2130-NOPNM,
          OPTYPET(20),
        END OF GS_OPTYPE.

*-----------------------------------------------------------------*
* DATA: INTERNAL TABLE.
*-----------------------------------------------------------------*
 DATA : GT_DISP       LIKE TABLE OF GS_DISP . "전송 ALV 테이블
 DATA : GT_DISP_TMP   LIKE TABLE OF GS_DISP WITH HEADER LINE.
 DATA : GT_CRHD       LIKE TABLE OF GS_CRHD.
 DATA : GT_OPTYPE     LIKE TABLE OF GS_OPTYPE.
 DATA : GV_CHK_CHANGE TYPE C. " 데이터 변경 체크
 DATA : GV_DIS_MODE   TYPE C VALUE 'U'.

*-----------------------------------------------------------------*
* ALV
*-----------------------------------------------------------------*
*& CLASS REFERENCE 정의
 CLASS: LCL_EVENT_HANDLER      DEFINITION DEFERRED,
        LCL_ALV_GRID           DEFINITION DEFERRED.
*& ALV GLOBAL FIELD
 DATA : ALV_VARIANT LIKE DISVARIANT,
        ALV_REPID   LIKE SY-REPID.
*- ALV COMMON
 TYPE-POOLS : KKBLO.
 DATA : GS_STBL      TYPE LVC_S_STBL,
        GT_SFIELDCAT TYPE KKBLO_T_FIELDCAT,
        GS_EXCLUDING TYPE LINE OF UI_FUNCTIONS,
        GT_EXCLUDING TYPE UI_FUNCTIONS.
* DATA : CELLCOL TYPE LVC_T_SCOL,
*        CELLTAB TYPE LVC_T_STYL.

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
*& DROP-DOWN LIST BOX LIST.
 DATA : GT_DROPDOWN TYPE LVC_T_DROP,
        GS_DROPDOWN TYPE LVC_S_DROP.

 DATA : GO_DOCKING_CONTAINER TYPE REF TO CL_GUI_DOCKING_CONTAINER.
 DATA : GO_SPLITTER TYPE REF TO CL_GUI_SPLITTER_CONTAINER.
 DATA : GO_EVENT_HANDLER TYPE REF TO LCL_EVENT_HANDLER.
*-----------
*ALV GRID 100
 DATA : GO_CONTAIN_0100 TYPE REF TO CL_GUI_CONTAINER.
 DATA : GO_CONTAIN_TOP_0100 TYPE REF TO CL_GUI_CONTAINER.
 DATA : GO_GRID_0100 TYPE REF TO CL_GUI_ALV_GRID.
 DATA : GS_VARIANT TYPE DISVARIANT.
 DATA : GS_LAYOUT_0100 TYPE LVC_S_LAYO.
 DATA : GT_SORT_0100 TYPE LVC_T_SORT.
 DATA : GT_EXCLUDE_0100 TYPE UI_FUNCTIONS.
 DATA : GT_FIELDCAT_0100 TYPE LVC_T_FCAT.
 DATA : GO_OBJECT TYPE REF TO CL_ALV_EVENT_TOOLBAR_SET.
 DATA : GO_DD_DOCU_0100   TYPE REF TO CL_DD_DOCUMENT.

 DATA : GV_STABLE TYPE LVC_S_STBL VALUE 'XX'.

 DATA: GT_F4 TYPE LVC_T_F4,
       GS_F4 TYPE LVC_S_F4.
