*&---------------------------------------------------------------------*
*& INCLUDE          ZGTMMR4400F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& FORM CREATE_ALV
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
FORM CREATE_ALV .

  PERFORM :
            SET_CONTAINER USING GC_100,
            SET_ALV_GRID USING GC_100,
*            SET_TOP_OF_PAGE,
            SET_ALV_FIELDCAT USING '0',
            SET_ALV_LAYOUT,
            SET_ALV_TOOLBAR USING '',
            SET_ALV_SORT,
            SET_EVENT        CHANGING GCL_EVENT GCL_GRID,
            SET_CELL_COLOR,
            DISPLAY_ALV TABLES GT_FCAT GT_LIST GT_EXCLUD
                                   USING GCL_GRID.

ENDFORM.

*&---------------------------------------------------------------------*
*& FORM CREATE_ALV_300
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
FORM CREATE_ALV_300 .

  PERFORM :
            SET_CONTAINER USING GC_300,
            SET_ALV_GRID    USING GC_300,
            SET_ALV_FIELDCAT USING '1', "HEADER
            SET_ALV_FIELDCAT USING '2', "ITEM
            SET_ALV_LAYOUT,
            SET_ALV_TOOLBAR USING '',   "HEADER
            SET_ALV_TOOLBAR USING GC_X,    "ITEM
            SET_ALV_SORT,
            SET_EVENT             CHANGING GCL_EVENT GCL_GRID_HD,
            SET_EVENT2           CHANGING GCL_EVENT2 GCL_GRID_IT,

            SET_CELL_COLOR_300 ,"USING '300',
            DISPLAY_ALV           TABLES GT_FCAT_HD GT_HEAD GT_EXCLUD
                                           USING GCL_GRID_HD,
            DISPLAY_ALV          TABLES GT_FCAT_IT GT_ITEM GT_EXCLUD_IT
                                          USING GCL_GRID_IT.

ENDFORM.

*&---------------------------------------------------------------------*
*& FORM CREATE_ALV_400
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
FORM CREATE_ALV_400.

  PERFORM :
            SET_CONTAINER USING GC_400,
            SET_ALV_GRID    USING GC_400,
            SET_ALV_FIELDCAT USING '3', "HEADER
            SET_ALV_FIELDCAT USING '4', "ITEM
            SET_ALV_LAYOUT,
            SET_ALV_TOOLBAR USING '',   "HEADER
            SET_ALV_TOOLBAR USING GC_X,    "ITEM
            SET_EVENT             CHANGING GCL_EVENT GCL_GRID_GRHD,
            SET_EVENT2           CHANGING GCL_EVENT2 GCL_GRID_GRIT,
            SET_CELL_COLOR_400 , " USING '400',
            DISPLAY_ALV           TABLES GT_FCAT_GRHD GT_HEADGR GT_EXCLUD
                                           USING GCL_GRID_GRHD,
            DISPLAY_ALV          TABLES GT_FCAT_GRIT GT_ITEM_GR GT_EXCLUD_IT
                                          USING GCL_GRID_GRIT.

ENDFORM.

*&---------------------------------------------------------------------*
*& FORM CREATE_ALV_500
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
FORM CREATE_ALV_500.

  PERFORM :
            SET_CONTAINER USING GC_500,
            SET_ALV_GRID    USING GC_500,
            SET_ALV_FIELDCAT USING '5',
            SET_ALV_LAYOUT,
            SET_ALV_TOOLBAR USING '',
            SET_EVENT             CHANGING GCL_EVENT GCL_GRID_TR,
            DISPLAY_ALV           TABLES GT_FCAT_TR GT_TRINFO GT_EXCLUD
                                           USING GCL_GRID_TR.

ENDFORM.

*&---------------------------------------------------------------------*
*& FORM SET_CONTAINER
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
FORM SET_CONTAINER USING PV_GB.

  CASE PV_GB.
*의뢰접수(RB_RCV)
    WHEN GC_100.
      IF GCL_DOCKING IS NOT BOUND.

        CREATE OBJECT GCL_DOCKING
          EXPORTING
            REPID     = SY-REPID
            DYNNR     = SY-DYNNR
            SIDE      = CL_GUI_DOCKING_CONTAINER=>DOCK_AT_TOP "_left
            EXTENSION = 3000.

      ENDIF.

*의뢰관리(RB_MNG)
    WHEN GC_300.
      IF GCL_DOCK_IT IS NOT BOUND.
        CREATE OBJECT GCL_DOCK_IT
          EXPORTING
            REPID                   = SY-REPID
            DYNNR                   = SY-DYNNR
            SIDE                    = CL_GUI_DOCKING_CONTAINER=>DOCK_AT_BOTTOM
            NO_AUTODEF_PROGID_DYNNR = 'X'
            EXTENSION               = 200. " 아래쪽 컨테이너 높이 지정
      ENDIF.

      IF GCL_DOCK_HD IS NOT BOUND.
        CREATE OBJECT GCL_DOCK_HD
          EXPORTING
            REPID                   = SY-REPID
            DYNNR                   = SY-DYNNR
            SIDE                    = CL_GUI_DOCKING_CONTAINER=>DOCK_AT_TOP
            NO_AUTODEF_PROGID_DYNNR = 'X'
            EXTENSION               = 100. " 위쪽 컨테이너 높이 지정
      ENDIF.


*      IF gcl_custom_hd IS NOT BOUND.
*
*        CREATE OBJECT gcl_custom_hd
*          EXPORTING
*            container_name = 'CC_HEADER'.
*      ENDIF.
*
*      IF gcl_custom_it IS NOT BOUND.
*
*        CREATE OBJECT gcl_custom_it
*          EXPORTING
*            container_name = 'CC_ITEM'.
*      ENDIF.

*입고처리(RB_GR)
    WHEN GC_400.
      IF GCL_DOCK_400 IS NOT BOUND.

*        CREATE OBJECT gcl_custom_gr
*          EXPORTING
*            container_name = 'CC_GR'.

        CREATE OBJECT GCL_DOCK_400
          EXPORTING
            REPID     = SY-REPID
            DYNNR     = SY-DYNNR
            SIDE      = CL_GUI_DOCKING_CONTAINER=>DOCK_AT_TOP
            EXTENSION = 3000.

        " CREATE SPLITTER
        CREATE OBJECT GCL_SPLIT
          EXPORTING
            PARENT  = GCL_DOCK_400 "gcl_custom_gr
            ROWS    = 2
            COLUMNS = 1.

        GCL_SPLIT->SET_ROW_HEIGHT( ID = 1 HEIGHT = 30 )."위아래 넓이..
        GCL_SPLIT->SET_BORDER( BORDER = ZGTFI_X ). "테두리
        GCL_SPLIT->GET_CONTAINER( :
                               EXPORTING ROW      = 1
                                             COLUMN    = 1
                               RECEIVING CONTAINER = GCL_CON_TOP ),
                               EXPORTING ROW       = 2
                                              COLUMN    = 1
                               RECEIVING CONTAINER = GCL_CON_BODY ).
      ENDIF.

*배차관리정보(팝업)
    WHEN GC_500.
      IF GCL_CUSTOM_TR IS NOT BOUND.
        CREATE OBJECT GCL_CUSTOM_TR
          EXPORTING
            CONTAINER_NAME = 'CC_TR'.
      ENDIF.

*      IF GCL_CUSTOM_GRHD IS NOT BOUND.
*
*        CREATE OBJECT GCL_CUSTOM_GRHD
*          EXPORTING
*            CONTAINER_NAME = 'CC_HEADER_GR'.
*      ENDIF.
*
*      IF GCL_CUSTOM_GRIT IS NOT BOUND.
*
*        CREATE OBJECT GCL_CUSTOM_GRIT
*          EXPORTING
*            CONTAINER_NAME = 'CC_ITEM_GR'.
*      ENDIF.

    WHEN OTHERS.
  ENDCASE.

*    " CREATE SPLITTER
*    CREATE OBJECT GCL_SPLIT
*      EXPORTING
*        PARENT    = GCL_DOCKING
*        ROWS       = 2
*        COLUMNS = 1.
*
*    GCL_SPLIT->SET_ROW_HEIGHT( ID = 1 HEIGHT = 10 ). "위아래 넓이..
*    GCL_SPLIT->SET_BORDER( BORDER = ZGTFI_X ). "테두리...
*    GCL_SPLIT->GET_CONTAINER( : EXPORTING ROW      = 1
*                                         COLUMN    = 1
*                               RECEIVING CONTAINER = GCL_CON_TOP ),
*
*                               EXPORTING ROW       = 2
*                                         COLUMN    = 1
*                               RECEIVING CONTAINER = GCL_CON_BODY ).

*  IF GCL_CL_DD IS NOT BOUND.
*    CREATE OBJECT GCL_CL_DD
*      EXPORTING
*        STYLE = 'ALV_GRID'.
*  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*& FORM SET_ALV_GRID
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
FORM SET_ALV_GRID USING PV_GB.

  CASE  PV_GB.
*의뢰접수(RB_RCV)
    WHEN GC_100.
      IF GCL_GRID IS NOT BOUND.
        CREATE OBJECT GCL_GRID
          EXPORTING
            I_PARENT          = GCL_DOCKING
          EXCEPTIONS
            ERROR_CNTL_CREATE = 1
            ERROR_CNTL_INIT   = 2
            ERROR_CNTL_LINK   = 3
            ERROR_DP_CREATE   = 4
            OTHERS            = 5.

        IF SY-SUBRC <> 0.
          "COULD NOT CREATE ALV GRID (SY-SUBRC = &)
          MESSAGE E725(BT) WITH SY-SUBRC.
        ENDIF.
      ENDIF.

*의뢰관리(RB_MNG)
    WHEN GC_300.
      IF GCL_GRID_HD IS NOT BOUND.
        CREATE OBJECT GCL_GRID_HD
          EXPORTING
            I_PARENT          = GCL_DOCK_HD  "gcl_custom_hd
          EXCEPTIONS
            ERROR_CNTL_CREATE = 1
            ERROR_CNTL_INIT   = 2
            ERROR_CNTL_LINK   = 3
            ERROR_DP_CREATE   = 4
            OTHERS            = 5.

        IF SY-SUBRC <> 0.
          "COULD NOT CREATE ALV GRID (SY-SUBRC = &)
          MESSAGE E725(BT) WITH SY-SUBRC.
        ENDIF.
      ENDIF.

      IF GCL_GRID_IT IS NOT BOUND.
        CREATE OBJECT GCL_GRID_IT
          EXPORTING
            I_PARENT          = GCL_DOCK_IT  "gcl_custom_it
          EXCEPTIONS
            ERROR_CNTL_CREATE = 1
            ERROR_CNTL_INIT   = 2
            ERROR_CNTL_LINK   = 3
            ERROR_DP_CREATE   = 4
            OTHERS            = 5.

        IF SY-SUBRC <> 0.
          "COULD NOT CREATE ALV GRID (SY-SUBRC = &)
          MESSAGE E725(BT) WITH SY-SUBRC.
        ENDIF.
      ENDIF.

*입고처리(RB_GR)
    WHEN GC_400.
      IF GCL_GRID_GRHD IS NOT BOUND.
        CREATE OBJECT GCL_GRID_GRHD
          EXPORTING
            I_PARENT          = GCL_CON_TOP "GCL_CUSTOM_GRHD
          EXCEPTIONS
            ERROR_CNTL_CREATE = 1
            ERROR_CNTL_INIT   = 2
            ERROR_CNTL_LINK   = 3
            ERROR_DP_CREATE   = 4
            OTHERS            = 5.

        IF SY-SUBRC <> 0.
          "COULD NOT CREATE ALV GRID (SY-SUBRC = &)
          MESSAGE E725(BT) WITH SY-SUBRC.
        ENDIF.
      ENDIF.

      IF GCL_GRID_GRIT IS NOT BOUND.
        CREATE OBJECT GCL_GRID_GRIT
          EXPORTING
            I_PARENT          = GCL_CON_BODY "GCL_CUSTOM_GRIT
          EXCEPTIONS
            ERROR_CNTL_CREATE = 1
            ERROR_CNTL_INIT   = 2
            ERROR_CNTL_LINK   = 3
            ERROR_DP_CREATE   = 4
            OTHERS            = 5.

        IF SY-SUBRC <> 0.
          "COULD NOT CREATE ALV GRID (SY-SUBRC = &)
          MESSAGE E725(BT) WITH SY-SUBRC.
        ENDIF.
      ENDIF.

    WHEN GC_500.
      IF GCL_GRID_TR IS NOT BOUND.
        CREATE OBJECT GCL_GRID_TR
          EXPORTING
            I_PARENT          = GCL_CUSTOM_TR
          EXCEPTIONS
            ERROR_CNTL_CREATE = 1
            ERROR_CNTL_INIT   = 2
            ERROR_CNTL_LINK   = 3
            ERROR_DP_CREATE   = 4
            OTHERS            = 5.

        IF SY-SUBRC <> 0.
          "COULD NOT CREATE ALV GRID (SY-SUBRC = &)
          MESSAGE E725(BT) WITH SY-SUBRC.
        ENDIF.
      ENDIF.

    WHEN OTHERS.
  ENDCASE.

ENDFORM.

*&---------------------------------------------------------------------*
*& FORM ADJUST_FLDCATS
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
FORM ADJUST_FLDCATS  TABLES PT_FCAT TYPE LVC_T_FCAT.

  DEFINE _FCAT.
    <fs_s_fct>-scrtext_s  =
    <fs_s_fct>-scrtext_m  =
    <fs_s_fct>-scrtext_l  =
    <fs_s_fct>-coltext    =
    <fs_s_fct>-reptext    = &1.
  END-OF-DEFINITION.

  DATA LV_COL TYPE I.
  CLEAR : GT_FCAT[].

  LOOP AT PT_FCAT ASSIGNING FIELD-SYMBOL(<FS_S_FCT>).
    CLEAR : <FS_S_FCT>-COL_POS.

    CASE <FS_S_FCT>-FIELDNAME.

      WHEN 'BUKRS'.    "회사코드
        _FCAT TEXT-F01.
        <FS_S_FCT>-NO_OUT = GC_X.
        <FS_S_FCT>-JUST = 'C'.

      WHEN 'ZREQ_TYPE'.    "신청유형
        _FCAT TEXT-F02.
        <FS_S_FCT>-NO_OUT = GC_X.
        <FS_S_FCT>-JUST = 'C'.

      WHEN 'ZREQ_NAME'.    "신청유형명
        _FCAT TEXT-F03.
        <FS_S_FCT>-JUST = 'C'.
        <FS_S_FCT>-EMPHASIZE = 'C110'.

      WHEN 'LIFNR'.     "공급업체코드
        _FCAT TEXT-F04.
        <FS_S_FCT>-JUST = 'C'.

      WHEN 'VNAME'.
        _FCAT TEXT-F05.
        <FS_S_FCT>-JUST = 'C'.
        <FS_S_FCT>-EMPHASIZE = 'C700'.

      WHEN 'KUNNR'.       "고객코드
        _FCAT TEXT-F06.
        <FS_S_FCT>-JUST = 'C'.

      WHEN 'CNAME'.
        _FCAT TEXT-F07.
        <FS_S_FCT>-JUST = 'C'.
        <FS_S_FCT>-EMPHASIZE = 'C110'.

      WHEN 'DEST1'.       "납지
        _FCAT TEXT-F08.
        <FS_S_FCT>-JUST = 'C'.
        <FS_S_FCT>-EMPHASIZE = 'C110'.

      WHEN 'CITY1'.           "도시
        _FCAT TEXT-F09.
        <FS_S_FCT>-NO_OUT = GC_X.
        <FS_S_FCT>-JUST = 'C'.

      WHEN 'AR_DATE'.      "도착요청일
        _FCAT TEXT-F10.
        <FS_S_FCT>-JUST = 'C'.
        <FS_S_FCT>-EMPHASIZE = 'C311'.

      WHEN 'AR_TIME'.     "도착요청시간
        _FCAT TEXT-F11.
        <FS_S_FCT>-NO_OUT = GC_X.
        <FS_S_FCT>-JUST = 'C'.

      WHEN 'EBELN'.      "구매오더
        _FCAT TEXT-F12.
        <FS_S_FCT>-JUST = 'C'.
        <FS_S_FCT>-HOTSPOT = GC_X.

      WHEN 'EBELP'.      "
        _FCAT TEXT-F13.
        <FS_S_FCT>-JUST = 'C'.

      WHEN 'MATNR'.      "
        _FCAT TEXT-F14.
        <FS_S_FCT>-JUST = 'C'.
        <FS_S_FCT>-HOTSPOT = GC_X.

      WHEN 'MAKTX'.      "
        _FCAT TEXT-F15.
        <FS_S_FCT>-JUST = 'C'.
        <FS_S_FCT>-EMPHASIZE = 'C200'.

      WHEN 'COLOR'.      "색상
        _FCAT TEXT-F16.
        <FS_S_FCT>-JUST = 'C'.
        <FS_S_FCT>-EMPHASIZE = 'C200'.

      WHEN 'LENGTH'.      "조장
        _FCAT TEXT-F17.
        <FS_S_FCT>-JUST = 'R'.
        <FS_S_FCT>-EMPHASIZE = 'C200'.

      WHEN 'EINDT'.       "납품예정일
        _FCAT TEXT-F18.
        <FS_S_FCT>-JUST = 'C'.

      WHEN 'MENGE'.     "발주량
        _FCAT TEXT-F19.     "
        <FS_S_FCT>-QFIELDNAME = 'MEINS'.
        <FS_S_FCT>-NO_OUT = GC_X.
        <FS_S_FCT>-JUST = 'R'.

      WHEN 'MEINS'.      "발주단위
        _FCAT TEXT-F20.
        <FS_S_FCT>-NO_OUT = GC_X.
        <FS_S_FCT>-JUST = 'C'.

      WHEN 'PO_DRQTY'.     "발주드럼수
        _FCAT TEXT-F21.
        <FS_S_FCT>-QFIELDNAME = 'DR_MEINS'.
        <FS_S_FCT>-JUST = 'R'.

      WHEN 'DR_MEINS'.      "드럼단위
        _FCAT TEXT-F22.
        <FS_S_FCT>-NO_OUT = GC_X.
        <FS_S_FCT>-JUST = 'C'.

      WHEN 'REQ_MENGE'.     "직송요청량
        _FCAT TEXT-F23.
        <FS_S_FCT>-QFIELDNAME = 'MEINS'.
        <FS_S_FCT>-NO_OUT = GC_X.
        <FS_S_FCT>-JUST = 'R'.

      WHEN 'REQ_DRQTY'.     "직송요청량(드럼)
        _FCAT TEXT-F24.
        <FS_S_FCT>-QFIELDNAME = 'DR_MEINS'.
        <FS_S_FCT>-JUST = 'R'.
        <FS_S_FCT>-EMPHASIZE = 'C311'.

      WHEN 'GR_MENGE'.     "입고량
        _FCAT TEXT-F25.
        <FS_S_FCT>-QFIELDNAME = 'MEINS'.
        <FS_S_FCT>-NO_OUT = GC_X.
        <FS_S_FCT>-JUST = 'R'.

      WHEN 'GR_DRQTY'.     "입고량(드럼)
        _FCAT TEXT-F26.
        <FS_S_FCT>-QFIELDNAME = 'DR_MEINS'.
        <FS_S_FCT>-JUST = 'R'.

      WHEN 'NGR_MENGE'.     "미입고량
        _FCAT TEXT-F27.
        <FS_S_FCT>-NO_OUT = GC_X.
        <FS_S_FCT>-QFIELDNAME = 'MEINS'.
        <FS_S_FCT>-JUST = 'R'.

      WHEN 'NGR_DRQTY'.     "미입고량(드럼)
        _FCAT TEXT-F28.
        <FS_S_FCT>-QFIELDNAME = 'DR_MEINS'.
        <FS_S_FCT>-JUST = 'R'.

      WHEN 'ANO_QTY_A'.     "미입고량(드럼)
        _FCAT TEXT-F93.
        <FS_S_FCT>-QFIELDNAME = 'DR_MEINS'.
        <FS_S_FCT>-JUST = 'R'.

      WHEN 'REMAIN_QTY_A'.     "미입고량(드럼)
        _FCAT TEXT-F94.
        <FS_S_FCT>-QFIELDNAME = 'DR_MEINS'.
        <FS_S_FCT>-JUST = 'R'.

      WHEN 'KALAB'.     "보관재고량(M)
        _FCAT TEXT-F89.
        <FS_S_FCT>-QFIELDNAME = 'MEINS'.
        <FS_S_FCT>-NO_OUT = GC_X.
        <FS_S_FCT>-JUST = 'R'.

      WHEN 'STOCK_DRQTY'.     "보관재고량(DR)
        _FCAT TEXT-F90.
        <FS_S_FCT>-QFIELDNAME = 'DR_MEINS'.
        <FS_S_FCT>-JUST = 'R'.

      WHEN 'ZCHECK'.     "직송가능여부
        _FCAT TEXT-F95.
        <FS_S_FCT>-EMPHASIZE = 'C310'. "색/노랑/진하게/반전없음
        <FS_S_FCT>-JUST = 'C'.

      WHEN 'VKBUR'.     "영업팀
        _FCAT TEXT-F29.
        <FS_S_FCT>-NO_OUT = GC_X.
        <FS_S_FCT>-JUST = 'C'.

      WHEN 'VKBUR_N'.  "영업팀명
        _FCAT TEXT-F30.
        <FS_S_FCT>-JUST = 'C'.

      WHEN 'VKGRP'.     "영업그룹
        _FCAT TEXT-F31.
        <FS_S_FCT>-NO_OUT = GC_X.
        <FS_S_FCT>-JUST = 'C'.

      WHEN 'VKGRP_N'.  "영업그룹명
        _FCAT TEXT-F32.
        <FS_S_FCT>-JUST = 'C'.

      WHEN 'VBELN'.     "판매문서
        _FCAT TEXT-F33.
        <FS_S_FCT>-JUST = 'C'.
        <FS_S_FCT>-HOTSPOT = GC_X.

      WHEN 'POSNR'.
        _FCAT TEXT-F34.
        <FS_S_FCT>-JUST = 'C'.

      WHEN 'DLVRQ'.     "출하요청번호
        _FCAT TEXT-F35.
        <FS_S_FCT>-JUST = 'C'.

      WHEN 'REJ_CODE'.  "반려사유
        _FCAT TEXT-F36.
        <FS_S_FCT>-EDIT = GC_X.
        <FS_S_FCT>-JUST = 'C'.

      WHEN 'WERKS'.    "플랜트
        _FCAT TEXT-F70.
        <FS_S_FCT>-NO_OUT = GC_X.
        <FS_S_FCT>-JUST = 'C'.

      WHEN 'WERKS_N'.    "플랜트명
        _FCAT TEXT-F70.
        <FS_S_FCT>-NO_OUT = GC_X.
        <FS_S_FCT>-JUST = 'C'.

      WHEN 'REQDATE'.     "직송요청일
        _FCAT TEXT-F69.
        <FS_S_FCT>-NO_OUT = GC_X.
        <FS_S_FCT>-JUST = 'C'.

      WHEN 'BLAND'.       "지역
        _FCAT TEXT-F39.
        <FS_S_FCT>-NO_OUT = GC_X.
        <FS_S_FCT>-JUST = 'C'.

      WHEN 'BLAND_N'.       "지역명
        _FCAT TEXT-F40.
        <FS_S_FCT>-NO_OUT = GC_X.
        <FS_S_FCT>-JUST = 'C'.

      WHEN 'SITE_NAME'.      "현장담당자
        _FCAT TEXT-F41.
        <FS_S_FCT>-NO_OUT = GC_X.
        <FS_S_FCT>-JUST = 'C'.

      WHEN 'SITE_TEL'.      "현장담당TEL
        _FCAT TEXT-F42.
        <FS_S_FCT>-NO_OUT = GC_X.
        <FS_S_FCT>-JUST = 'C'.

      WHEN 'CUST_NAME'.      "고객담당자
        _FCAT TEXT-F43.
        <FS_S_FCT>-NO_OUT = GC_X.
        <FS_S_FCT>-JUST = 'C'.

      WHEN 'CUST_TEL'.      ""고객담당자TEL
        _FCAT TEXT-F44.
        <FS_S_FCT>-NO_OUT = GC_X.
        <FS_S_FCT>-JUST = 'C'.

      WHEN 'DEST2'.      "현장납지
        _FCAT TEXT-F45.
        <FS_S_FCT>-NO_OUT = GC_X.
        <FS_S_FCT>-JUST = 'C'.

      WHEN 'SP_NOTE'.      "특기사항
        _FCAT TEXT-F46.
        <FS_S_FCT>-NO_OUT = GC_X.
        <FS_S_FCT>-JUST = 'C'.

      WHEN 'PROD_DATE'.      "생산일
        _FCAT TEXT-F53.
        <FS_S_FCT>-NO_OUT = GC_X.
        <FS_S_FCT>-JUST = 'C'.

      WHEN ' ZINSPTYPE'.     "품질검사유형
        _FCAT TEXT-F54.
        <FS_S_FCT>-NO_OUT = GC_X.
        <FS_S_FCT>-JUST = 'C'.

      WHEN 'ZINSPDATE'.      "입회검사예정일
        _FCAT TEXT-F55.
        <FS_S_FCT>-NO_OUT = GC_X.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'ZINSPRES'.          "검사결과
        _FCAT TEXT-F56.
        <FS_S_FCT>-NO_OUT = GC_X.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'ZSD_STAT'.       "영업상태
        _FCAT TEXT-F49.
        <FS_S_FCT>-NO_OUT = GC_X.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'ZSD_STAT_N'.     "영업상태
        _FCAT TEXT-F50.
        <FS_S_FCT>-NO_OUT = GC_X.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'ZMM_STAT'.       "구매접수상태
        _FCAT TEXT-F49.
        <FS_S_FCT>-NO_OUT = GC_X.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'ZMM_STAT_N'.       "구매접수상태
        _FCAT TEXT-F49.
        <FS_S_FCT>-NO_OUT = GC_X.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'ZMM_DRQTY'.     "구매접수수량
        _FCAT TEXT-F67.
        <FS_S_FCT>-QFIELDNAME = 'DR_MEINS'.
        <FS_S_FCT>-NO_OUT = GC_X.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'ZMM_DATE'.     "구매접수일
        _FCAT TEXT-F50.
        <FS_S_FCT>-NO_OUT = GC_X.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'ZQM_STAT'.      "품질상태
        _FCAT '품질상태'.
        <FS_S_FCT>-NO_OUT = GC_X.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'ZQM_STAT_N'.    "검사일
        _FCAT '품질상태명'.
        <FS_S_FCT>-NO_OUT = GC_X.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'ZVD_STAT'.      "업체상태
        _FCAT '업체상태'.
        <FS_S_FCT>-NO_OUT = GC_X.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'ZQM_STAT_N'.    "검사일
        _FCAT '업체상태명'.
        <FS_S_FCT>-NO_OUT = GC_X.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'ZVD_DRQTY'.     "업체접수수량
        _FCAT TEXT-F68.
        <FS_S_FCT>-QFIELDNAME = 'DR_MEINS'.
        <FS_S_FCT>-NO_OUT = GC_X.
        <FS_S_FCT>-JUST = 'R'.
      WHEN 'ZVD_DATE'.       "업체접수일
        _FCAT TEXT-F52.
        <FS_S_FCT>-NO_OUT = GC_X.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'ZLE_STAT'.     "
        _FCAT '배차상태'.
        <FS_S_FCT>-NO_OUT = GC_X.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'ZDOC_STAT'.     "
        _FCAT '거래명세서상태'.
        <FS_S_FCT>-NO_OUT = GC_X.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'ZDOC_NO'.      "
        _FCAT '거래명세서번호발행일'.
        <FS_S_FCT>-NO_OUT = GC_X.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'ZDOC_DATE'.      "
        _FCAT '거래명세서발행일'.
        <FS_S_FCT>-NO_OUT = GC_X.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'ZDOC_TRTYPE'.
        _FCAT '운송방식'.
        <FS_S_FCT>-NO_OUT = GC_X.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'ZPP_STAT'.     ""구매승인상태
        _FCAT '생관입고상태'.
        <FS_S_FCT>-NO_OUT = GC_X.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'ZDESC'.
        _FCAT '비고'.
        <FS_S_FCT>-NO_OUT = GC_X.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'ERDAT'.      "생성일자
        _FCAT TEXT-F79.
        <FS_S_FCT>-NO_OUT  = GC_X.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'ERDAT_LOCAL'.      "생성일자
        _FCAT TEXT-F79.
        <FS_S_FCT>-NO_OUT  = GC_X.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'ERTIM'.      "생성시간
        _FCAT TEXT-F80.
        <FS_S_FCT>-NO_OUT  = GC_X.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'ERTIM_LOCAL'.      "생성시간
        _FCAT TEXT-F80.
        <FS_S_FCT>-NO_OUT  = GC_X.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'ERNAM'.      "생성자
        _FCAT TEXT-F81.
        <FS_S_FCT>-NO_OUT  = GC_X.
        <FS_S_FCT>-JUST = 'C'.
      WHEN OTHERS.
        <FS_S_FCT>-NO_OUT = GC_X.
    ENDCASE.

    APPEND <FS_S_FCT> TO GT_FCAT.
  ENDLOOP.

ENDFORM.

*&---------------------------------------------------------------------*
*& FORM ADJUST_FLDCATS_HD
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
FORM ADJUST_FLDCATS_HD  TABLES PT_FCAT TYPE LVC_T_FCAT.

  DEFINE _FCAT.
    <fs_s_fct>-scrtext_s  =
    <fs_s_fct>-scrtext_m  =
    <fs_s_fct>-scrtext_l  =
    <fs_s_fct>-coltext    =
    <fs_s_fct>-reptext    = &1.
  END-OF-DEFINITION.

  DATA LV_COL TYPE I.
  CLEAR : GT_FCAT_HD[], GT_FCAT_GRHD[].

  LOOP AT PT_FCAT ASSIGNING FIELD-SYMBOL(<FS_S_FCT>).
    CLEAR : <FS_S_FCT>-COL_POS.

    CASE <FS_S_FCT>-FIELDNAME.
      WHEN 'CHECK'. "선택
        _FCAT TEXT-F37.
        <FS_S_FCT>-EDIT = GC_X.
        <FS_S_FCT>-CHECKBOX = GC_X.
        <FS_S_FCT>-TECH = COND #( WHEN RB_GR = GC_X THEN GC_X ELSE '' ).
        <FS_S_FCT>-JUST = 'C'.

      WHEN 'GRSTATUS'.    "입고상태
        _FCAT '입고상태'.
        <FS_S_FCT>-ICON = GC_X.
        <FS_S_FCT>-TECH = COND #( WHEN RB_GR = GC_X THEN '' ELSE GC_X ).
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'BUKRS'.    "회사코드
        _FCAT TEXT-F01.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'ZREQ_TYPE'.    "신청유형
        _FCAT TEXT-F02.
*        <FS_S_FCT>-TECH = COND #( WHEN RB_GR = GC_X THEN GC_X ELSE '' ).
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'ZREQ_NAME'.    "신청유형명
        _FCAT TEXT-F03.
*        <FS_S_FCT>-TECH = COND #( WHEN RB_GR = GC_X THEN GC_X ELSE '' ).
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'DLVRQ'.     "출하요청번호
        _FCAT TEXT-F35.
        <FS_S_FCT>-JUST = 'C'.
*      WHEN 'WERKS'.     "플랜트
*        _FCAT TEXT-F70.
*        <FS_S_FCT>-TECH = COND #( WHEN RB_GR = GC_X THEN '' ELSE GC_X ).
*
*      WHEN 'WERKS_N'. "플랜트명
*        _FCAT '플랜트명'.
*        <FS_S_FCT>-TECH = COND #( WHEN RB_GR = GC_X THEN '' ELSE GC_X ).

      WHEN 'VKBUR'.     "영업팀
        _FCAT TEXT-F29.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'VKBUR_N'.
        _FCAT TEXT-F30.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'VKGRP'.     "영업그룹
        _FCAT TEXT-F31.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'VKGRP_N'.
        _FCAT TEXT-F32.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'VBELN'.       "판매문서
        _FCAT TEXT-F33.
*        <FS_S_FCT>-NO_OUT = GC_X.
*        <FS_S_FCT>-TECH = COND #( WHEN RB_GR = GC_X THEN '' ELSE GC_X ).
*        <fs_s_fct>-hotspot = gc_x.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'POSNR'.       "항번
        _FCAT TEXT-F34.
        <FS_S_FCT>-NO_OUT = GC_X.
*        <FS_S_FCT>-TECH = COND #( WHEN RB_GR = GC_X THEN '' ELSE GC_X ).
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'KUNNR'.       "고객코드
        _FCAT TEXT-F06.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'CNAME'.
        _FCAT TEXT-F07.
        <FS_S_FCT>-JUST = 'C'.
        <FS_S_FCT>-EMPHASIZE = 'C410'.
      WHEN 'REQ_DATE'.  "직송의뢰일
        IF RB_GR = GC_X.
          _FCAT '직송요청일'.
        ELSE.
          _FCAT TEXT-F38.
        ENDIF.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'PO_DRQTY'.
        _FCAT '발주량(DR)'.
        <FS_S_FCT>-NO_OUT = GC_X.
*        <FS_S_FCT>-TECH = COND #( WHEN RB_GR = GC_X THEN '' ELSE GC_X ).
        <FS_S_FCT>-JUST = 'R'.
      WHEN 'DR_MEINS'.
        _FCAT '발주드럼단위'.
        <FS_S_FCT>-NO_OUT = GC_X.
*        <FS_S_FCT>-TECH = COND #( WHEN RB_GR = GC_X THEN '' ELSE GC_X ).
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'REQ_DRQTY'.
        _FCAT '직송요청량(DR)'.
        <FS_S_FCT>-NO_OUT = GC_X.
*        <FS_S_FCT>-TECH = COND #( WHEN RB_GR = GC_X THEN '' ELSE GC_X ).
        <FS_S_FCT>-JUST = 'R'.
      WHEN 'GR_DRQTY'.
        _FCAT '입고량(DR)'.
        <FS_S_FCT>-NO_OUT = GC_X.
*        <FS_S_FCT>-TECH = COND #( WHEN RB_GR = GC_X THEN '' ELSE GC_X ).
        <FS_S_FCT>-JUST = 'R'.
      WHEN 'NGR_DRQTY'.
        _FCAT '미입고량(DR)'.
        <FS_S_FCT>-NO_OUT = GC_X.
*        <FS_S_FCT>-TECH = COND #( WHEN RB_GR = GC_X THEN '' ELSE GC_X ).
        <FS_S_FCT>-JUST = 'R'.
      WHEN 'AR_DATE'.      "도착요청일
        _FCAT TEXT-F10.
        <FS_S_FCT>-JUST = 'C'.
        <FS_S_FCT>-EMPHASIZE = 'C410'.
      WHEN 'AR_TIME'.     "도착요청시간
        <FS_S_FCT>-JUST = 'C'.        _FCAT TEXT-F11.

      WHEN 'Q1'.
        _FCAT '영업의뢰'.
*        <FS_S_FCT>-TECH = COND #( WHEN RB_GR = GC_X THEN '' ELSE GC_X ).
        <FS_S_FCT>-JUST = 'RIGHT'.
        <FS_S_FCT>-EMPHASIZE = 'C300'.

      WHEN 'Q2'.
        _FCAT '구매접수'.
*        <FS_S_FCT>-TECH = COND #( WHEN RB_GR = GC_X THEN GC_X ELSE '' ).
        <FS_S_FCT>-JUST = 'RIGHT'.
        <FS_S_FCT>-EMPHASIZE = 'C700'.

      WHEN 'Q3'.
        _FCAT '업체접수'.
*        <FS_S_FCT>-TECH = COND #( WHEN RB_GR = GC_X THEN GC_X ELSE '' ).
        <FS_S_FCT>-JUST = 'RIGHT'.
        <FS_S_FCT>-EMPHASIZE = 'C300'.
      WHEN 'Q6'.
        _FCAT '요청반려'.
*        <FS_S_FCT>-TECH = COND #( WHEN RB_GR = GC_X THEN GC_X ELSE '' ).
        <FS_S_FCT>-JUST = 'RIGHT'.
        <FS_S_FCT>-EMPHASIZE = 'C700'.
      WHEN 'Q4'.
        _FCAT '품질의뢰'.
*        <FS_S_FCT>-TECH = COND #( WHEN RB_GR = GC_X THEN GC_X ELSE '' ).
        <FS_S_FCT>-JUST = 'RIGHT'.
        <FS_S_FCT>-EMPHASIZE = 'C300'.

      WHEN 'Q5'.
        _FCAT '검사완료'.
*        <FS_S_FCT>-TECH = COND #( WHEN RB_GR = GC_X THEN GC_X ELSE '' ).
        <FS_S_FCT>-JUST = 'RIGHT'.
        <FS_S_FCT>-EMPHASIZE = 'C700'.
      WHEN 'Q7'.
        _FCAT '배차여부'.
*        <FS_S_FCT>-TECH = COND #( WHEN RB_GR = GC_X THEN GC_X ELSE '' ).
        <FS_S_FCT>-JUST = 'CENTER'.
        <FS_S_FCT>-EMPHASIZE = 'C300'.

      WHEN 'Q9'.
        _FCAT '배차완료'.
*        <FS_S_FCT>-TECH = COND #( WHEN RB_GR = GC_X THEN GC_X ELSE '' ).
        <FS_S_FCT>-JUST = 'RIGHT'.
        <FS_S_FCT>-HOTSPOT = GC_X.
        <FS_S_FCT>-EMPHASIZE = 'C700'.
      WHEN 'Q10'.
        _FCAT '거래명세서'.
*        <FS_S_FCT>-TECH = COND #( WHEN RB_GR = GC_X THEN GC_X ELSE '' ).
        <FS_S_FCT>-JUST = 'RIGHT'.
        <FS_S_FCT>-HOTSPOT = GC_X.
        <FS_S_FCT>-EMPHASIZE = 'C300'.

      WHEN 'Q8'.
        _FCAT '구매확인'.
*        <FS_S_FCT>-TECH = COND #( WHEN RB_GR = GC_X THEN GC_X ELSE '' ).
        <FS_S_FCT>-JUST = 'CENTER'.
        <FS_S_FCT>-EMPHASIZE = 'C700'.
        <FS_S_FCT>-NO_OUT = GC_X.
      WHEN 'Q11'.
        _FCAT '출고확정'.
*        <FS_S_FCT>-TECH = COND #( WHEN RB_GR = GC_X THEN GC_X ELSE '' ).
        <FS_S_FCT>-JUST = 'RIGHT'.
        <FS_S_FCT>-EMPHASIZE = 'C300'.
        <FS_S_FCT>-NO_OUT = GC_X.

      WHEN 'Q12'.
        _FCAT '생관입고'.
*        <FS_S_FCT>-TECH = COND #( WHEN RB_GR = GC_X THEN GC_X ELSE '' ).
        <FS_S_FCT>-JUST = 'RIGHT'.
        <FS_S_FCT>-EMPHASIZE = 'C700'.
      WHEN 'CHECKMM'.       "지역
        _FCAT TEXT-F91.
        <FS_S_FCT>-NO_OUT = GC_X.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'BLAND'.       "지역
        _FCAT TEXT-F39.
*        <FS_S_FCT>-TECH = COND #( WHEN RB_GR = GC_X THEN GC_X ELSE '' ).
        <FS_S_FCT>-NO_OUT = GC_X.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'BLAND_N'.       "지역명
        _FCAT TEXT-F40.
        <FS_S_FCT>-NO_OUT = GC_X.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'CITY1'.           "도시
        _FCAT TEXT-F09.
        <FS_S_FCT>-NO_OUT = GC_X.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'DEST1'.       "납지
        _FCAT TEXT-F08.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'SITE_NAME'.      "현장담당자
        _FCAT TEXT-F41.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'SITE_TEL'.      "현장담당TEL
        _FCAT TEXT-F42.
*        <FS_S_FCT>-NO_OUT = COND #( WHEN RB_GR = GC_X THEN GC_X ELSE '' ).
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'CUST_NAME'.      "고객담당자
        _FCAT TEXT-F43.
*        <FS_S_FCT>-TECH = COND #( WHEN RB_GR = GC_X THEN GC_X ELSE '' ).
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'CUST_TEL'.      ""고객담당자TEL
        _FCAT TEXT-F44.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'DEST2'.      "현장납지
        _FCAT TEXT-F45.
*        <FS_S_FCT>-TECH = COND #( WHEN RB_GR = GC_X THEN GC_X ELSE '' ).
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'SP_NOTE'.      "특기사항
        _FCAT TEXT-F46.
*        <FS_S_FCT>-NO_OUT = COND #( WHEN RB_GR = GC_X THEN GC_X ELSE '' ).
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'PERNR'.
        _FCAT '요청자사번'.
        <FS_S_FCT>-NO_OUT = GC_X.
*        <FS_S_FCT>-TECH = COND #( WHEN RB_GR = GC_X THEN '' ELSE GC_X ).
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'NAME'.
        _FCAT '요청자명'.
        <FS_S_FCT>-NO_OUT = GC_X.
*        <FS_S_FCT>-TECH = COND #( WHEN RB_GR = GC_X THEN '' ELSE GC_X ).
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'EMAIL'.
        _FCAT '요청자 E-MAIL'.
        <FS_S_FCT>-NO_OUT = GC_X.
*        <FS_S_FCT>-TECH = COND #( WHEN RB_GR = GC_X THEN '' ELSE GC_X ).
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'MEINS'.
        _FCAT '발주단위'.
        <FS_S_FCT>-NO_OUT = GC_X.
*        <FS_S_FCT>-TECH = COND #( WHEN RB_GR = GC_X THEN '' ELSE GC_X ).
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'LOADQTY_M'.
        _FCAT '적재수량(M)'.
        <FS_S_FCT>-NO_OUT  = GC_X.
*        <FS_S_FCT>-TECH = COND #( WHEN RB_GR = GC_X THEN '' ELSE GC_X ).
        <FS_S_FCT>-JUST = 'R'.
      WHEN 'LOADQTY_DR'.
        _FCAT '적재수량(DR)'.
        <FS_S_FCT>-NO_OUT = GC_X.
*        <FS_S_FCT>-TECH = COND #( WHEN RB_GR = GC_X THEN '' ELSE GC_X ).
        <FS_S_FCT>-JUST = 'R'.
      WHEN 'GRQTY_M'.
        _FCAT '입고수량(M)'.
        <FS_S_FCT>-NO_OUT  = GC_X.
*        <FS_S_FCT>-TECH = COND #( WHEN RB_GR = GC_X THEN '' ELSE GC_X ).
        <FS_S_FCT>-JUST = 'R'.
      WHEN 'GRQTY_DR'.
        _FCAT '입고수량(DR)'.
        <FS_S_FCT>-NO_OUT = GC_X.
*        <FS_S_FCT>-TECH = COND #( WHEN RB_GR = GC_X THEN '' ELSE GC_X ).
        <FS_S_FCT>-JUST = 'R'.
      WHEN 'REMAINQTY_M'.
        _FCAT '미입고수량(M)'.
        <FS_S_FCT>-NO_OUT  = GC_X.
*        <FS_S_FCT>-TECH = COND #( WHEN RB_GR = GC_X THEN '' ELSE GC_X ).
        <FS_S_FCT>-JUST = 'R'.
      WHEN 'REMAINQTY_DR'.
        _FCAT '미입고수량(DR)'.
        <FS_S_FCT>-NO_OUT = GC_X.
*        <FS_S_FCT>-TECH = COND #( WHEN RB_GR = GC_X THEN '' ELSE GC_X ).
        <FS_S_FCT>-JUST = 'R'.
      WHEN 'ZSD_STAT'.      "직송요청상태
        _FCAT TEXT-F77.
        <FS_S_FCT>-NO_OUT  = GC_X.
*        <FS_S_FCT>-TECH = COND #( WHEN RB_GR = GC_X THEN GC_X ELSE '' ).
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'ZDESC'.      "비고
        _FCAT TEXT-F78.
        <FS_S_FCT>-NO_OUT  = GC_X.
*        <FS_S_FCT>-TECH = COND #( WHEN RB_GR = GC_X THEN GC_X ELSE '' ).
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'ERDAT'.      "생성일자
        _FCAT TEXT-F79.
        <FS_S_FCT>-NO_OUT  = GC_X.
*        <FS_S_FCT>-TECH = COND #( WHEN RB_GR = GC_X THEN GC_X ELSE '' ).
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'ERDAT_LOCAL'.      "생성일자
        _FCAT TEXT-F79.
        <FS_S_FCT>-NO_OUT  = GC_X.
*        <FS_S_FCT>-TECH = COND #( WHEN RB_GR = GC_X THEN GC_X ELSE '' ).
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'ERTIM'.      "생성시간
        _FCAT TEXT-F80.
        <FS_S_FCT>-NO_OUT  = GC_X.
*        <FS_S_FCT>-TECH = COND #( WHEN RB_GR = GC_X THEN GC_X ELSE '' ).
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'ERTIM_LOCAL'.      "생성시간
        _FCAT TEXT-F80.
        <FS_S_FCT>-NO_OUT  = GC_X.
*        <FS_S_FCT>-TECH = COND #( WHEN RB_GR = GC_X THEN GC_X ELSE '' ).
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'ERNAM'.      "생성자
        _FCAT TEXT-F81.
        <FS_S_FCT>-NO_OUT  = GC_X.
*        <FS_S_FCT>-TECH = COND #( WHEN RB_GR = GC_X THEN GC_X ELSE '' ).
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'AEDAT'.      "변경일자
        _FCAT TEXT-F82.
        <FS_S_FCT>-NO_OUT  = GC_X.
*        <FS_S_FCT>-TECH = COND #( WHEN RB_GR = GC_X THEN GC_X ELSE '' ).
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'AEDAT_LOCAL'.      "변경일자
        _FCAT TEXT-F82.
        <FS_S_FCT>-NO_OUT  = GC_X.
*        <FS_S_FCT>-TECH = COND #( WHEN RB_GR = GC_X THEN GC_X ELSE '' ).
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'AETIM'.      "변경시간
        _FCAT TEXT-F83.
        <FS_S_FCT>-NO_OUT  = GC_X.
*        <FS_S_FCT>-TECH = COND #( WHEN RB_GR = GC_X THEN GC_X ELSE '' ).
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'AETIM_LOCAL'.      "변경시간
        _FCAT TEXT-F83.
        <FS_S_FCT>-NO_OUT  = GC_X.
*        <FS_S_FCT>-TECH = COND #( WHEN RB_GR = GC_X THEN GC_X ELSE '' ).
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'AENAM'.      "변경자
        _FCAT TEXT-F84.
        <FS_S_FCT>-NO_OUT  = GC_X.
*        <FS_S_FCT>-TECH = COND #( WHEN RB_GR = GC_X THEN GC_X ELSE '' ).
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'STATUS'.
        _FCAT '처리상태'.
        <FS_S_FCT>-TECH = COND #( WHEN RB_GR = GC_X THEN '' ELSE GC_X ).
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'MESSAGE'.
        _FCAT '메시지'.
        <FS_S_FCT>-TECH = COND #( WHEN RB_GR = GC_X THEN '' ELSE GC_X ).
        <FS_S_FCT>-JUST = 'C'.
      WHEN OTHERS.
        <FS_S_FCT>-NO_OUT  = GC_X.
    ENDCASE.

    IF RB_GR = GC_X.
      APPEND <FS_S_FCT> TO GT_FCAT_GRHD.
    ELSE.
      APPEND <FS_S_FCT> TO GT_FCAT_HD.
    ENDIF.

  ENDLOOP.

ENDFORM.

*&---------------------------------------------------------------------*
*& FORM ADJUST_FLDCATS
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
FORM ADJUST_FLDCATS_IT  TABLES PT_FCAT TYPE LVC_T_FCAT .

  DEFINE _FCAT.
    <fs_s_fct>-scrtext_s  =
    <fs_s_fct>-scrtext_m  =
    <fs_s_fct>-scrtext_l  =
    <fs_s_fct>-coltext    =
    <fs_s_fct>-reptext    = &1.
  END-OF-DEFINITION.

  DATA LV_COL TYPE I.
  CLEAR : GT_FCAT_IT[], GT_FCAT_GRIT[].

  LOOP AT PT_FCAT ASSIGNING FIELD-SYMBOL(<FS_S_FCT>).
    CLEAR : <FS_S_FCT>-COL_POS.

    CASE <FS_S_FCT>-FIELDNAME.
      WHEN 'CHECK'. "선택
        _FCAT TEXT-F37.
        <FS_S_FCT>-EDIT = GC_X.
        <FS_S_FCT>-CHECKBOX = GC_X.
        <FS_S_FCT>-TECH = COND #( WHEN RB_GR = GC_X THEN GC_X ELSE '' ).
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'ZSTATUS'. "접수상태
        _FCAT TEXT-F47.
        <FS_S_FCT>-TECH = COND #( WHEN RB_GR = GC_X THEN GC_X ELSE '' ).
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'GRSTATUS'.    "입고상태
        _FCAT '입고상태'.
        <FS_S_FCT>-ICON = GC_X.
        <FS_S_FCT>-TECH = COND #( WHEN RB_GR = GC_X THEN '' ELSE GC_X ).
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'BUKRS'.    "회사코드
        _FCAT TEXT-F01.
        <FS_S_FCT>-NO_OUT  = GC_X.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'DLVRQ'.     "출하요청번호
        _FCAT TEXT-F35.
*        <FS_S_FCT>-NO_OUT = COND #( WHEN RB_GR = GC_X THEN GC_X ELSE '' ).
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'WERKS'.     "플랜트
        _FCAT TEXT-F70.
        <FS_S_FCT>-TECH = COND #( WHEN RB_GR = GC_X THEN '' ELSE GC_X ).
        <FS_S_FCT>-NO_OUT = COND #( WHEN RB_GR = GC_X THEN GC_X ELSE '' ).
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'WERKS_N'. "플랜트명
        _FCAT '플랜트명'.
        <FS_S_FCT>-TECH = COND #( WHEN RB_GR = GC_X THEN '' ELSE GC_X ).
        <FS_S_FCT>-NO_OUT = COND #( WHEN RB_GR = GC_X THEN GC_X ELSE '' ).
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'VKBUR'.     "영업팀
        _FCAT TEXT-F29.
        <FS_S_FCT>-TECH = COND #( WHEN RB_GR = GC_X THEN '' ELSE GC_X ).
        <FS_S_FCT>-NO_OUT = COND #( WHEN RB_GR = GC_X THEN GC_X ELSE '' ).
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'VKBUR_N'.
        _FCAT TEXT-F30.
        <FS_S_FCT>-TECH = COND #( WHEN RB_GR = GC_X THEN '' ELSE GC_X ).
        <FS_S_FCT>-NO_OUT = COND #( WHEN RB_GR = GC_X THEN GC_X ELSE '' ).
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'VKGRP'.     "영업그룹
        _FCAT TEXT-F31.
        <FS_S_FCT>-TECH = COND #( WHEN RB_GR = GC_X THEN '' ELSE GC_X ).
        <FS_S_FCT>-NO_OUT = COND #( WHEN RB_GR = GC_X THEN GC_X ELSE '' ).
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'VKGRP_N'.
        _FCAT TEXT-F32.
        <FS_S_FCT>-TECH = COND #( WHEN RB_GR = GC_X THEN '' ELSE GC_X ).
        <FS_S_FCT>-NO_OUT = COND #( WHEN RB_GR = GC_X THEN GC_X ELSE '' ).
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'VBELN'.     "판매문서
        _FCAT TEXT-F33.
        <FS_S_FCT>-JUST = 'C'.
        <FS_S_FCT>-HOTSPOT = GC_X.
      WHEN 'POSNR'.
        _FCAT TEXT-F34.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'EBELN'.      "구매오더
        _FCAT TEXT-F12.
        <FS_S_FCT>-JUST = 'C'.
        <FS_S_FCT>-HOTSPOT = GC_X.
      WHEN 'EBELP'.      "
        _FCAT TEXT-F13.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'REQDATE'.   "직송요청일
        _FCAT TEXT-F69.
        <FS_S_FCT>-TECH = COND #( WHEN RB_GR = GC_X THEN '' ELSE GC_X ).
        <FS_S_FCT>-NO_OUT = COND #( WHEN RB_GR = GC_X THEN GC_X ELSE '' ).
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'EINDT'.   "직송요청일
        _FCAT 'PO납품예정일'.
        <FS_S_FCT>-TECH = COND #( WHEN RB_GR = GC_X THEN '' ELSE GC_X ).
        <FS_S_FCT>-NO_OUT = COND #( WHEN RB_GR = GC_X THEN GC_X ELSE '' ).
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'LIFNR'.     "공급업체코드
        _FCAT TEXT-F04.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'VNAME'.
        _FCAT TEXT-F05.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'KUNNR'.       "고객코드
        _FCAT TEXT-F06.
        <FS_S_FCT>-TECH = COND #( WHEN RB_GR = GC_X THEN '' ELSE GC_X ).
        <FS_S_FCT>-NO_OUT = COND #( WHEN RB_GR = GC_X THEN GC_X ELSE '' ).
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'CNAME'.
        _FCAT TEXT-F07.
        <FS_S_FCT>-TECH = COND #( WHEN RB_GR = GC_X THEN '' ELSE GC_X ).
        <FS_S_FCT>-NO_OUT = COND #( WHEN RB_GR = GC_X THEN GC_X ELSE '' ).
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'MATNR'.
        IF RB_GR = GC_X.
          _FCAT 'OEM제품'.
        ELSE.
          _FCAT TEXT-F14.
        ENDIF. "
        <FS_S_FCT>-JUST = 'C'.

        <FS_S_FCT>-HOTSPOT = GC_X.
      WHEN 'MAKTX'.      "
        _FCAT TEXT-F15.
        <FS_S_FCT>-JUST = 'C'.
        <FS_S_FCT>-EMPHASIZE = 'C410'.
      WHEN 'COLOR'.      "색상
        _FCAT TEXT-F16.
        <FS_S_FCT>-JUST = 'C'.
        <FS_S_FCT>-EMPHASIZE = 'C410'.

      WHEN 'ST_COLOR'.      "띠줄색상
        _FCAT TEXT-F96.
        <FS_S_FCT>-TECH = COND #( WHEN RB_GR = GC_X THEN GC_X ELSE '' ).
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'ST_COLOR_NO'.      "띠줄수
        _FCAT TEXT-F97.
        <FS_S_FCT>-TECH = COND #( WHEN RB_GR = GC_X THEN GC_X ELSE '' ).
        <FS_S_FCT>-JUST = 'R'.

      WHEN 'LENGTH'.      "조장
        _FCAT TEXT-F17.
        <FS_S_FCT>-JUST = 'C'.
        <FS_S_FCT>-EMPHASIZE = 'C410'.
      WHEN 'STATUS1'.      "구매
        _FCAT TEXT-F86.
        <FS_S_FCT>-JUST = 'CENTER'.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'STATUS2'.      "업체
        _FCAT TEXT-F87.
        <FS_S_FCT>-JUST = 'CENTER'.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'STATUS3'.      "배차
        _FCAT TEXT-F88.
        <FS_S_FCT>-JUST = 'CENTER'.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'LOADQTY_M'.
        _FCAT '적재수량'.
        <FS_S_FCT>-TECH = COND #( WHEN RB_GR = GC_X THEN '' ELSE GC_X ).
        <FS_S_FCT>-NO_OUT  = GC_X.
        <FS_S_FCT>-EMPHASIZE = 'C300'.
        <FS_S_FCT>-JUST = 'R'.
      WHEN 'LOADQTY_DR'.
        _FCAT '적재수량'.
        <FS_S_FCT>-TECH = COND #( WHEN RB_GR = GC_X THEN '' ELSE GC_X ).
        <FS_S_FCT>-QFIELDNAME = 'DR_MEINS'.
        <FS_S_FCT>-EMPHASIZE = 'C300'.
        <FS_S_FCT>-JUST = 'R'.
      WHEN 'MENGE'.    "발주량
        _FCAT TEXT-F19.
        <FS_S_FCT>-NO_OUT  = GC_X.
        <FS_S_FCT>-QFIELDNAME = 'MEINS'.
        <FS_S_FCT>-JUST = 'R'.
      WHEN 'MTOSTOCK'.    "보관재고량
        _FCAT TEXT-F89.
        <FS_S_FCT>-NO_OUT  = GC_X.
        <FS_S_FCT>-QFIELDNAME = 'MEINS'.
        <FS_S_FCT>-JUST = 'R'.
      WHEN 'MEINS'.    "단위
        _FCAT TEXT-F20.
        <FS_S_FCT>-NO_OUT  = GC_X.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'PO_DRQTY'.     "발주드럼수
        _FCAT TEXT-F21.
        <FS_S_FCT>-QFIELDNAME = 'DR_MEINS'.
        <FS_S_FCT>-JUST = 'R'.
        <FS_S_FCT>-EMPHASIZE = 'C300'.
      WHEN 'MTOSTOCKDR'.     "보관재고드럼수
        _FCAT TEXT-F90.
        <FS_S_FCT>-QFIELDNAME = 'DR_MEINS'.
        <FS_S_FCT>-JUST = 'R'.
        <FS_S_FCT>-EMPHASIZE = 'C700'.
      WHEN 'DR_MEINS'.      "드럼단위
        _FCAT TEXT-F22.
        <FS_S_FCT>-NO_OUT  = GC_X.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'KALAB'.
        _FCAT '보관재고량(M)'.
        <FS_S_FCT>-TECH = COND #( WHEN RB_GR = GC_X THEN '' ELSE GC_X ).
        <FS_S_FCT>-NO_OUT = COND #( WHEN RB_GR = GC_X THEN GC_X ELSE '' ).
        <FS_S_FCT>-QFIELDNAME = 'MEINS'.
        <FS_S_FCT>-JUST = 'R'.
      WHEN 'STOCK_DRQTY'.
        _FCAT '보관재고량(DR)'.
        <FS_S_FCT>-TECH = COND #( WHEN RB_GR = GC_X THEN '' ELSE GC_X ).
        <FS_S_FCT>-NO_OUT = COND #( WHEN RB_GR = GC_X THEN GC_X ELSE '' ).
        <FS_S_FCT>-QFIELDNAME = 'DR_MEINS'.
        <FS_S_FCT>-JUST = 'R'.
      WHEN 'REQ_MENGE'.
        _FCAT '직송요청량(M)'.
        <FS_S_FCT>-QFIELDNAME = 'MEINS'.
        <FS_S_FCT>-TECH = COND #( WHEN RB_GR = GC_X THEN '' ELSE GC_X ).
        <FS_S_FCT>-NO_OUT = COND #( WHEN RB_GR = GC_X THEN GC_X ELSE '' ).
        <FS_S_FCT>-JUST = 'R'.
      WHEN 'GR_MENGE'.     "입고량
        _FCAT TEXT-F25.
        <FS_S_FCT>-QFIELDNAME = 'MEINS'.
        <FS_S_FCT>-NO_OUT  = GC_X.
        <FS_S_FCT>-JUST = 'R'.
      WHEN 'GR_DRQTY'.     "입고량(드럼)
        _FCAT TEXT-F26.
        <FS_S_FCT>-QFIELDNAME = 'DR_MEINS'.
        <FS_S_FCT>-NO_OUT = COND #( WHEN RB_MNG = GC_X THEN GC_X ELSE '' ).
        <FS_S_FCT>-JUST = 'R'.
      WHEN 'NGR_MENGE'.     "미입고량
        _FCAT TEXT-F27.
        <FS_S_FCT>-QFIELDNAME = 'MEINS'.
        <FS_S_FCT>-NO_OUT  = GC_X.
        <FS_S_FCT>-JUST = 'R'.
      WHEN 'NGR_DRQTY'.     "미입고량(드럼)
        _FCAT TEXT-F28.
        <FS_S_FCT>-NO_OUT = COND #( WHEN RB_MNG = GC_X THEN GC_X ELSE '' ).
        <FS_S_FCT>-QFIELDNAME = 'DR_MEINS'.
        <FS_S_FCT>-JUST = 'R'.
      WHEN 'REQ_DRQTY'.     "직송의뢰량(드럼)
        _FCAT TEXT-F48.
        <FS_S_FCT>-QFIELDNAME = 'DR_MEINS'.
        <FS_S_FCT>-JUST = 'R'.
        <FS_S_FCT>-EMPHASIZE = 'C300'.
      WHEN 'AR_DATE'.
        _FCAT '도착요청일'.
        <FS_S_FCT>-TECH = COND #( WHEN RB_GR = GC_X THEN '' ELSE GC_X ).
        <FS_S_FCT>-NO_OUT = COND #( WHEN RB_GR = GC_X THEN GC_X ELSE '' ).
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'AR_TIME'.
        _FCAT '도착요청시간'.
        <FS_S_FCT>-TECH = COND #( WHEN RB_GR = GC_X THEN '' ELSE GC_X ).
        <FS_S_FCT>-NO_OUT = COND #( WHEN RB_GR = GC_X THEN GC_X ELSE '' ).
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'DEST1'.
        _FCAT '납지'.
        <FS_S_FCT>-TECH = COND #( WHEN RB_GR = GC_X THEN '' ELSE GC_X ).
        <FS_S_FCT>-NO_OUT = COND #( WHEN RB_GR = GC_X THEN GC_X ELSE '' ).
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'CITY1'.
        _FCAT '도시'.
        <FS_S_FCT>-TECH = COND #( WHEN RB_GR = GC_X THEN '' ELSE GC_X ).
        <FS_S_FCT>-NO_OUT = COND #( WHEN RB_GR = GC_X THEN GC_X ELSE '' ).
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'SITE_NAME'.
        _FCAT '현장명'.
        <FS_S_FCT>-TECH = COND #( WHEN RB_GR = GC_X THEN '' ELSE GC_X ).
        <FS_S_FCT>-NO_OUT = COND #( WHEN RB_GR = GC_X THEN GC_X ELSE '' ).
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'SITE_TEL'.
        _FCAT '현장전화번호'.
        <FS_S_FCT>-TECH = COND #( WHEN RB_GR = GC_X THEN '' ELSE GC_X ).
        <FS_S_FCT>-NO_OUT = COND #( WHEN RB_GR = GC_X THEN GC_X ELSE '' ).
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'SP_NOTE'.
        _FCAT '특기사항'.
        <FS_S_FCT>-TECH = COND #( WHEN RB_GR = GC_X THEN '' ELSE GC_X ).
        <FS_S_FCT>-NO_OUT = COND #( WHEN RB_GR = GC_X THEN GC_X ELSE '' ).
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'PERNR'.
        _FCAT '요청자사번'.
        <FS_S_FCT>-TECH = COND #( WHEN RB_GR = GC_X THEN '' ELSE GC_X ).
        <FS_S_FCT>-NO_OUT = COND #( WHEN RB_GR = GC_X THEN GC_X ELSE '' ).
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'NAME'.
        _FCAT '요청자명'.
        <FS_S_FCT>-TECH = COND #( WHEN RB_GR = GC_X THEN '' ELSE GC_X ).
        <FS_S_FCT>-NO_OUT = COND #( WHEN RB_GR = GC_X THEN GC_X ELSE '' ).
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'EMAIL'.
        _FCAT '요청자E-MAIL'.
        <FS_S_FCT>-TECH = COND #( WHEN RB_GR = GC_X THEN '' ELSE GC_X ).
        <FS_S_FCT>-NO_OUT = COND #( WHEN RB_GR = GC_X THEN GC_X ELSE '' ).
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'ZMM_STAT'.       "구매접수상태
        _FCAT TEXT-F49.
        <FS_S_FCT>-NO_OUT  = GC_X.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'ZMM_STAT_N'.       "구매접수상태명
        _FCAT '구매접수상태명'.
        <FS_S_FCT>-TECH = COND #( WHEN RB_GR = GC_X THEN '' ELSE GC_X ).
        <FS_S_FCT>-NO_OUT  = GC_X.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'ZMM_DRQTY'.     "구매접수수량
        _FCAT TEXT-F67.
        <FS_S_FCT>-QFIELDNAME = 'DR_MEINS'.
        <FS_S_FCT>-NO_OUT = COND #( WHEN RB_MNG = GC_X THEN GC_X ELSE '' ).
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'ZMM_DATE'.     "구매접수일
        _FCAT TEXT-F50.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'ZVD_STAT'.      "업체접수상태
        _FCAT TEXT-F51.
        <FS_S_FCT>-NO_OUT  = GC_X.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'ZVD_STAT_N'.       "업체접수상태명
        _FCAT '업체접수상태명'.
        <FS_S_FCT>-TECH = COND #( WHEN RB_GR = GC_X THEN '' ELSE GC_X ).
        <FS_S_FCT>-NO_OUT  = GC_X.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'ZVD_DATE'.       "업체접수일
        _FCAT TEXT-F52.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'ZSEQ'.
        _FCAT '배차순번'.
        <FS_S_FCT>-TECH = COND #( WHEN RB_GR = GC_X THEN '' ELSE GC_X ).
        <FS_S_FCT>-NO_OUT  = GC_X.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'ZVD_DRQTY'.     "업체접수수량
        _FCAT TEXT-F68.
        <FS_S_FCT>-QFIELDNAME = 'DR_MEINS'.
        <FS_S_FCT>-NO_OUT = COND #( WHEN RB_MNG = GC_X THEN GC_X ELSE '' ).
        <FS_S_FCT>-JUST = 'R'.
*      WHEN 'PRD_DATE'.      "생산일
*        _FCAT TEXT-F53.
*        <FS_S_FCT>-TECH = COND #( WHEN RB_GR = GC_X THEN GC_X ELSE '' ).
*
*      WHEN ' ZINSPTYPE'.     "품질검사유형
*        _FCAT TEXT-F54.
*        <FS_S_FCT>-TECH = COND #( WHEN RB_GR = GC_X THEN GC_X ELSE '' ).

*      WHEN 'ZINSPDATE'.      "입회검사예정일
*        _FCAT TEXT-F55.
*        <FS_S_FCT>-TECH = COND #( WHEN RB_GR = GC_X THEN GC_X ELSE '' ).
*
*      WHEN 'ZINSPRES'.          "검사결과
*        _FCAT TEXT-F56.
*        <FS_S_FCT>-TECH = COND #( WHEN RB_GR = GC_X THEN GC_X ELSE '' ).
*
*      WHEN 'ZQMDATE'.         "검사일
*        _FCAT TEXT-F67.
*        <FS_S_FCT>-TECH = COND #( WHEN RB_GR = GC_X THEN GC_X ELSE '' ).

*      WHEN 'ZDOC_STAT'.         "거래명세서발행상태
*        _FCAT TEXT-F58.
*        <FS_S_FCT>-TECH = COND #( WHEN RB_GR = GC_X THEN GC_X ELSE '' ).
*
*      WHEN 'ZDOC_NO'.       "거래명세서번호
*        _FCAT TEXT-F59.
*
*      WHEN 'ZDOC_ITEM_NO'.   "항번
*        _FCAT TEXT-F34.
*        <FS_S_FCT>-TECH = COND #( WHEN RB_GR = GC_X THEN '' ELSE 'X' ).
*
*      WHEN 'ZDOC_DATE'.      "발행일
*        _FCAT TEXT-F60.
*
*      WHEN 'ZDOC_TRTYPE'.       "발행유형
*        _FCAT TEXT-F61.
*        <FS_S_FCT>-TECH = COND #( WHEN RB_GR = GC_X THEN GC_X ELSE '' ).
*
*      WHEN 'ZLE_STAT'.     "배차상태
*        _FCAT TEXT-F62.     "
*        <FS_S_FCT>-TECH = COND #( WHEN RB_GR = GC_X THEN GC_X ELSE '' ).

      WHEN 'LOADQTY'.      "배차드럼수
        _FCAT TEXT-F63.
        <FS_S_FCT>-QFIELDNAME = 'DR_MEINS'.
        <FS_S_FCT>-TECH = COND #( WHEN RB_GR = GC_X THEN GC_X ELSE '' ).
        <FS_S_FCT>-JUST = 'R'.
        <FS_S_FCT>-EMPHASIZE = 'C700'.
      WHEN 'LOADSTATUS'.      "배차상태
        _FCAT TEXT-F85.
        <FS_S_FCT>-NO_OUT = COND #( WHEN RB_MNG = GC_X THEN GC_X ELSE '' ).
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'REJ_CODE'.     "반품사유
        _FCAT TEXT-F64.
        <FS_S_FCT>-EDIT = GC_X.
        <FS_S_FCT>-TECH = COND #( WHEN RB_GR = GC_X THEN GC_X ELSE '' ).
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'ZPP_STAT'.     "입고상태
        _FCAT TEXT-F65.     "
        <FS_S_FCT>-TECH = COND #( WHEN RB_GR = GC_X THEN GC_X ELSE '' ).
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'ZMM_CHECK'.    "구매확정
        _FCAT TEXT-F92.
        <FS_S_FCT>-NO_OUT  = GC_X.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'ZPP_DATE'.      "입고일
        _FCAT TEXT-F66.
        <FS_S_FCT>-TECH = COND #( WHEN RB_GR = GC_X THEN GC_X ELSE '' ).
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'AEDAT'.      "변경일자
        _FCAT TEXT-F82.
        <FS_S_FCT>-NO_OUT  = GC_X.
        <FS_S_FCT>-TECH = COND #( WHEN RB_GR = GC_X THEN GC_X ELSE '' ).
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'AEDAT_LOCAL'.      "변경일자
        _FCAT TEXT-F82.
        <FS_S_FCT>-NO_OUT  = GC_X.
        <FS_S_FCT>-TECH = COND #( WHEN RB_GR = GC_X THEN GC_X ELSE '' ).
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'AETIM'.      "변경시간
        _FCAT TEXT-F83.
        <FS_S_FCT>-NO_OUT  = GC_X.
        <FS_S_FCT>-TECH = COND #( WHEN RB_GR = GC_X THEN GC_X ELSE '' ).
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'AETIM_LOCAL'.      "변경시간
        _FCAT TEXT-F83.
        <FS_S_FCT>-NO_OUT  = GC_X.
        <FS_S_FCT>-TECH = COND #( WHEN RB_GR = GC_X THEN GC_X ELSE '' ).
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'AENAM'.      "변경자
        _FCAT TEXT-F84.
        <FS_S_FCT>-NO_OUT  = GC_X.
        <FS_S_FCT>-TECH = COND #( WHEN RB_GR = GC_X THEN GC_X ELSE '' ).
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'ZDOC_NO'.
        _FCAT '거래명세서번호'.
        <FS_S_FCT>-TECH = COND #( WHEN RB_GR = GC_X THEN '' ELSE GC_X ).
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'ZDOC_ITEM_NO'.
        _FCAT '거래명세서항번'.
        <FS_S_FCT>-TECH = COND #( WHEN RB_GR = GC_X THEN '' ELSE GC_X ).
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'DELNO'.
        _FCAT '납품서번호'.
        <FS_S_FCT>-TECH = COND #( WHEN RB_GR = GC_X THEN '' ELSE GC_X ).
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'DELITEM'.
        _FCAT '납품서항번'.
        <FS_S_FCT>-TECH = COND #( WHEN RB_GR = GC_X THEN '' ELSE GC_X ).
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'MJAHR'.
        _FCAT '연도'.
        <FS_S_FCT>-TECH = COND #( WHEN RB_GR = GC_X THEN '' ELSE GC_X ).
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'MBLNR'.
        _FCAT '자재문서'.
        <FS_S_FCT>-TECH = COND #( WHEN RB_GR = GC_X THEN '' ELSE GC_X ).
        <FS_S_FCT>-JUST = 'C'.
        <FS_S_FCT>-HOTSPOT = GC_X.
      WHEN 'STATUS'.
        _FCAT '처리상태'.
        <FS_S_FCT>-ICON = GC_X.
        <FS_S_FCT>-TECH = COND #( WHEN RB_GR = GC_X THEN '' ELSE GC_X ).
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'MESSAGE'.
        _FCAT '메시지'.
        <FS_S_FCT>-TECH = COND #( WHEN RB_GR = GC_X THEN '' ELSE GC_X ).
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'DPCBT'.
        _FCAT '단일배치사용유무'.
        <FS_S_FCT>-NO_OUT = GC_X..
      WHEN OTHERS.
        <FS_S_FCT>-NO_OUT = GC_X.
    ENDCASE.

    IF RB_GR = GC_X.
      APPEND <FS_S_FCT> TO GT_FCAT_GRIT.
    ELSE.
      APPEND <FS_S_FCT> TO GT_FCAT_IT.
    ENDIF.

  ENDLOOP.

ENDFORM.

*&---------------------------------------------------------------------*
*& FORM ADJUST_FLDCATS_TR
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
FORM ADJUST_FLDCATS_TR  TABLES PT_FCAT TYPE LVC_T_FCAT.

  DEFINE _FCAT.
    <fs_s_fct>-scrtext_s  =
    <fs_s_fct>-scrtext_m  =
    <fs_s_fct>-scrtext_l  =
    <fs_s_fct>-coltext    =
    <fs_s_fct>-reptext    = &1.
  END-OF-DEFINITION.

  DATA LV_COL TYPE I.
  CLEAR : GT_FCAT_TR[].

  LOOP AT PT_FCAT ASSIGNING FIELD-SYMBOL(<FS_S_FCT>).
    CLEAR : <FS_S_FCT>-COL_POS.

    CASE <FS_S_FCT>-FIELDNAME.

      WHEN 'BUKRS'.    "회사코드
        _FCAT TEXT-F01.
        <FS_S_FCT>-NO_OUT = GC_X.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'ZREQ_TYPE'.    "신청유형
        _FCAT TEXT-F02.
        <FS_S_FCT>-NO_OUT = GC_X.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'DLVRQ'.     "출하요청번호
        _FCAT TEXT-F35.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'VBELN'.     "판매문서
        _FCAT TEXT-F33.
        <FS_S_FCT>-JUST = 'C'.
        <FS_S_FCT>-HOTSPOT = GC_X.
      WHEN 'POSNR'.
        _FCAT TEXT-F34.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'EBELN'.      "
        _FCAT TEXT-F12.
        <FS_S_FCT>-NO_OUT = COND #( WHEN GV_A = GC_X THEN SPACE ELSE GC_X ).
        <FS_S_FCT>-JUST = 'C'.
        <FS_S_FCT>-HOTSPOT = GC_X.
      WHEN 'EBELP'.      "
        _FCAT TEXT-F13.
        <FS_S_FCT>-NO_OUT = COND #( WHEN GV_A = GC_X THEN SPACE ELSE GC_X ).
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'ZSEQ'.
        _FCAT '순번'.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'ZTRTYPE'.    "직송거래운송방식
        _FCAT '직송거래운송방식'.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'REGIONT'.
        _FCAT '차량번호지역'.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'NO2DIGIT'.
        _FCAT '차량번호숫자(2자리)'.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'CH1DIGIT'.
        _FCAT '차량번호문자(1자리)'.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'NO4DIGIT'.
        _FCAT '차량번호숫자(4자리)'.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'TEL'.
        _FCAT '운송자 연락처'.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'NAME'.
        _FCAT '운송자 이름'.
*        <FS_S_FCT>-NO_OUT = GC_X.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'PARCELNAME'.
        _FCAT '택배사명'.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'LOADQTY'.
        _FCAT '적재수량'.
        <FS_S_FCT>-EMPHASIZE = 'C300'.
        <FS_S_FCT>-JUST = 'R'.
*        <FS_S_FCT>-NO_OUT = GC_X.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'DR_MEINS'.      "드럼단위
        _FCAT TEXT-F22.
*        <FS_S_FCT>-NO_OUT = GC_X.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'ZDOC_NO'.      "거래명세서번호
        _FCAT TEXT-F59.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'ZDOC_ITEM_NO'.      "
        _FCAT '거래명세서품목번호'.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'ZDOC_DATE'.
        _FCAT '거래명세서생성일'.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'DELNO'.      "
        _FCAT '납품문서번호'.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'DELITEM'.
        _FCAT '납품문서품목번호'.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'PRINTYN'.
        _FCAT '거래명세서 출력여부(Y/N)'.     "
*        <FS_S_FCT>-NO_OUT = GC_X.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'GIDATE'.      "발주단위
        _FCAT '출하일자'.
*        <FS_S_FCT>-NO_OUT = GC_X.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'ERDAT'.      "생성일자
        _FCAT TEXT-F79.
*        <FS_S_FCT>-NO_OUT  = GC_X.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'ERDAT_LOCAL'.      "생성일자
        _FCAT TEXT-F79.
*        <FS_S_FCT>-NO_OUT  = GC_X.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'ERTIM'.      "생성시간
        _FCAT TEXT-F80.
*        <FS_S_FCT>-NO_OUT  = GC_X.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'ERTIM_LOCAL'.      "생성시간
        _FCAT TEXT-F80.
*        <FS_S_FCT>-NO_OUT  = GC_X.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'ERNAM'.      "생성자
        _FCAT TEXT-F81.
*        <FS_S_FCT>-NO_OUT  = GC_X.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'AEDAT'.      "생성일자
        _FCAT '변경일'.
*        <FS_S_FCT>-NO_OUT  = GC_X.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'AEDAT_LOCAL'.      "생성일자
        _FCAT '변경일(LOCAL)'.
*        <FS_S_FCT>-NO_OUT  = GC_X.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'AETIM'.      "생성시간
        _FCAT '변경시간'.
*        <FS_S_FCT>-NO_OUT  = GC_X.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'AETIM_LOCAL'.      "생성시간
        _FCAT '변경시간(LOCAL)'.
*        <FS_S_FCT>-NO_OUT  = GC_X.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'AENAM'.      "생성자
        _FCAT '변경자'.
*        <FS_S_FCT>-NO_OUT  = GC_X.
        <FS_S_FCT>-JUST = 'C'.
      WHEN OTHERS.
        <FS_S_FCT>-NO_OUT = GC_X.
    ENDCASE.

    APPEND <FS_S_FCT> TO GT_FCAT_TR.
  ENDLOOP.

ENDFORM.

*&---------------------------------------------------------------------*
*& FORM SET_ALV_LAYOUT
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
FORM SET_ALV_LAYOUT.

  CLEAR GS_LAYOUT.
  GS_LAYOUT = VALUE #(
                       NO_ROWINS  = GC_X
                       ZEBRA          = GC_X
                       SEL_MODE    = GC_D "GC_A
                       CWIDTH_OPT  = GC_A
                       NO_ROWMARK = COND #( WHEN RB_MNG = GC_X THEN GC_X ELSE '' )
                       CTAB_FNAME = 'F_COL'
*                       STYLEFNAME = 'STYLE''
                        ).

ENDFORM.

*&---------------------------------------------------------------------*
*& FORM SET_ALV_TOOLBAR
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
FORM SET_ALV_TOOLBAR USING PV_GB.

  REFRESH : GT_EXCLUD, GT_EXCLUD_IT.

*  IF PV_GB = GC_X. "ALV_BOTTOM '의뢰관리' 경우 하단 그리드에는 툴바 모두 제거
*     GT_EXCLUD_IT[] = VALUE #( ( CL_GUI_ALV_GRID=>MC_FC_EXCL_ALL ) ).
*
*  ELSE.

  GT_EXCLUD[] = VALUE #(
*                         ( CL_GUI_ALV_GRID=>MC_MB_VIEW              )
                       ( CL_GUI_ALV_GRID=>MC_FC_LOC_UNDO          )
                       ( CL_GUI_ALV_GRID=>MC_FC_AUF               )
                       ( CL_GUI_ALV_GRID=>MC_FC_DETAIL            )
                       ( CL_GUI_ALV_GRID=>MC_FC_GRAPH             )
                       ( CL_GUI_ALV_GRID=>MC_FC_INFO              )
                       ( CL_GUI_ALV_GRID=>MC_FC_LOC_COPY          )
                       ( CL_GUI_ALV_GRID=>MC_FC_LOC_COPY_ROW      )
                       ( CL_GUI_ALV_GRID=>MC_FC_LOC_CUT           )
                       ( CL_GUI_ALV_GRID=>MC_FC_LOC_DELETE_ROW    )
                       ( CL_GUI_ALV_GRID=>MC_FC_LOC_INSERT_ROW    )
                       ( CL_GUI_ALV_GRID=>MC_FC_LOC_MOVE_ROW      )
                       ( CL_GUI_ALV_GRID=>MC_FC_LOC_APPEND_ROW    )
                       ( CL_GUI_ALV_GRID=>MC_FC_LOC_PASTE         )
                       ( CL_GUI_ALV_GRID=>MC_FC_LOC_PASTE_NEW_ROW )
*                         ( CL_GUI_ALV_GRID=>MC_FC_PRINT             )
                       ( CL_GUI_ALV_GRID=>MC_FC_REFRESH           )
                       ).

*  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& FORM SET_ALV_SORT
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
FORM SET_ALV_SORT.

*  GT_SORT[] = VALUE LVC_T_SORT(
*    ( SPOS = '1' FIELDNAME = 'WERKS'       UP = ZGTFI_X )
*    ( SPOS = '2' FIELDNAME = 'WERKS_TX' UP = ZGTFI_X SUBTOT = ZGTFI_X )
*    ( SPOS = '3' FIELDNAME = 'MTART'    UP = ZGTFI_X )
*    ( SPOS = '4' FIELDNAME = 'MATNR'    UP = ZGTFI_X )
*                                ).

ENDFORM.
*&---------------------------------------------------------------------*
*& FORM SET_EVENT
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
FORM SET_EVENT  CHANGING PO_EVENT TYPE REF TO LCL_EVT_RECEIVER
                                               PCL_GRID  TYPE REF TO CL_GUI_ALV_GRID.

  PCL_GRID->REGISTER_EDIT_EVENT( CL_GUI_ALV_GRID=>MC_EVT_MODIFIED ).
  PCL_GRID->REGISTER_EDIT_EVENT( CL_GUI_ALV_GRID=>MC_EVT_ENTER ).

*  PERFORM SET_CELL_STYLE.

  CREATE OBJECT PO_EVENT.

  SET HANDLER :
  PO_EVENT->HANDLE_DATA_CHANGED                 FOR PCL_GRID,
  PO_EVENT->HANDLE_TOOLBAR                           FOR PCL_GRID,
  PO_EVENT->HANDLE_USER_COMMAND               FOR PCL_GRID,
  PO_EVENT->HANDLE_DATA_CHANGED_FINISHED  FOR PCL_GRID,
  PO_EVENT->HANDLE_HOTSPOT_CLICK                FOR PCL_GRID.
*  PO_EVENT->HANDLE_ON_F4                               FOR PCL_GRID.


ENDFORM.

*&---------------------------------------------------------------------*
*& FORM SET_EVENT2
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
FORM SET_EVENT2 CHANGING PO_EVENT TYPE REF TO LCL_EVT_RECEIVER
                                               PCL_GRID  TYPE REF TO CL_GUI_ALV_GRID.

  PCL_GRID->REGISTER_EDIT_EVENT( CL_GUI_ALV_GRID=>MC_EVT_MODIFIED ).
  PCL_GRID->REGISTER_EDIT_EVENT( CL_GUI_ALV_GRID=>MC_EVT_ENTER ).

  CREATE OBJECT PO_EVENT.

  SET HANDLER :
  PO_EVENT->HANDLE_DATA_CHANGED                 FOR PCL_GRID,
  PO_EVENT->HANDLE_TOOLBAR                           FOR PCL_GRID,
  PO_EVENT->HANDLE_USER_COMMAND               FOR PCL_GRID,
  PO_EVENT->HANDLE_DATA_CHANGED_FINISHED  FOR PCL_GRID,
  PO_EVENT->HANDLE_HOTSPOT_CLICK                FOR PCL_GRID.
*  PO_EVENT->HANDLE_ON_F4                               FOR PCL_GRID.


ENDFORM.

*&---------------------------------------------------------------------*
*& FORM DISPLAY_ALV
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
FORM DISPLAY_ALV  TABLES PT_FCAT LIKE GT_FCAT
                                             PT_LIST
                                             PT_EXCLUD
                                  USING PCL_GRID  TYPE REF TO CL_GUI_ALV_GRID.

  DATA(LS_VARIANT) = VALUE DISVARIANT( REPORT  = SY-CPROG
                                             HANDLE  =
                                  COND #( WHEN RB_RCV = GC_X
                                                THEN '0001'
                                                WHEN RB_MNG = GC_X AND PCL_GRID = GCL_GRID_HD
                                                THEN '0002'
                                                WHEN RB_MNG = GC_X AND PCL_GRID = GCL_GRID_IT
                                                THEN '0003'
                                                WHEN RB_GR = GC_X AND PCL_GRID = GCL_GRID_GRHD
                                                THEN '0004'
                                                WHEN RB_GR = GC_X AND PCL_GRID = GCL_GRID_GRIT
                                                THEN '0005' ELSE '0006' ) ).

  CALL METHOD PCL_GRID->SET_TABLE_FOR_FIRST_DISPLAY "GCL_GRID->SET_TABLE_FOR_FIRST_DISPLAY
    EXPORTING
      IS_LAYOUT            = GS_LAYOUT
      IT_TOOLBAR_EXCLUDING = PT_EXCLUD[] "GT_EXCLUD[]
      IS_VARIANT           = LS_VARIANT
      I_SAVE               = GC_A
    CHANGING
      IT_OUTTAB            = PT_LIST[] "GT_LIST[]
      IT_FIELDCATALOG      = PT_FCAT[] "GT_FCAT[]
      IT_SORT              = GT_SORT[]
    EXCEPTIONS
      OTHERS               = 4.

  IF SY-SUBRC <> 0.
    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
          WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*& FORM RELEASE_ALV
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
FORM RELEASE_ALV .

  IF GCL_GRID IS BOUND.
    GCL_GRID->FREE( ).
    CLEAR GCL_GRID.
  ENDIF.

  IF GCL_GRID_HD IS BOUND.
    GCL_GRID_HD->FREE( ).
    CLEAR : GCL_GRID_HD, GV_BOTTOM.
  ENDIF.

  IF GCL_GRID_IT IS BOUND.
    GCL_GRID_IT->FREE( ).
    CLEAR : GCL_GRID_IT, GV_BOTTOM .
  ENDIF.

  IF GCL_GRID_GRHD IS BOUND.
    GCL_GRID_GRHD->FREE( ).
    GCL_GRID_GRIT->FREE( ).
    CLEAR : GCL_GRID_GRHD, GCL_GRID_GRIT.
  ENDIF.

*  IF GCL_GRID_TR IS BOUND.
*    GCL_GRID_TR->FREE( ).
*    CLEAR : GCL_GRID_TR.
*  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*& FORM INITIALIZATION
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
FORM INITIALIZATION .

  CLEAR : S_DATE[], S_DATE2[].
  S_DATE[] = VALUE #( ( SIGN     = GC_I
                                                          OPTION = GC_BT
                                                          LOW      = SY-DATLO - 90
                                                          HIGH      = SY-DATLO ) ).
  S_DATE2[] = VALUE #( ( SIGN     = GC_I
                                                          OPTION = GC_BT
                                                          LOW      = SY-DATLO - 90
                                                          HIGH      = SY-DATLO + 30 ) ).
  CASE SY-TCODE.
*    WHEN 'ZGTMMR4400B'.
*      RB_QUL = GC_X.
    WHEN 'ZGTMMR4400C'.
      RB_GR = GC_X.
    WHEN OTHERS.
      RB_RCV = GC_X.
  ENDCASE.

  " 1번 버튼 세팅 (텍스트 및 아이콘)
  SSCRFIELDS-FUNCTXT_01 = VALUE SMP_DYNTXT(
    TEXT      = 'OEM E-MAIL'
    ICON_ID   =  ICON_MAIL
    ICON_TEXT = 'OEM업체메일등록'
  ).

  " 2번 버튼 세팅
  SSCRFIELDS-FUNCTXT_02 = VALUE SMP_DYNTXT(
    TEXT      = 'E-MAIN&NAME'
    ICON_ID   = ICON_MAIL
    ICON_TEXT = '담당자메일등록'
  ).

ENDFORM.

*&---------------------------------------------------------------------*
*& FORM SELECTION_SCREEN
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
FORM SELECTION_SCREEN.

  CASE SSCRFIELDS-UCOMM."SY-UCOMM.
    WHEN 'FC01'. "OEM 업체 메일 등록_ZGTMMT1023
      PERFORM EMAIL_MANAGEMENT  USING 'M'.

    WHEN 'FC02'. "담당자 메일 등록_ZGTMMT1024
      PERFORM EMAIL_MANAGEMENT  USING ''.
  ENDCASE.

ENDFORM.

*&---------------------------------------------------------------------*
*& FORM EMAIL_MANAGEMENT
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
*& -->  P1        TEXT
*& <--  P2        TEXT
*&---------------------------------------------------------------------*
FORM EMAIL_MANAGEMENT  USING PV_GB.

  DATA : LV_VIEW TYPE DD02V-TABNAME,
         LV_MSG  TYPE STRING.

*    SELECT SINGLE BUKRS
*      FROM T024E
*      WHERE EKORG = @P_EKORG
*      INTO @DATA(LV_BUKRS).

*    IF LV_BUKRS IS NOT INITIAL.
*      SET PARAMETER ID 'BUK' FIELD LV_BUKRS. "회사 코드 메모리에 저장
*    ENDIF.

*M=OEM 업체 메일 등록_ZGTMMV1023 CALL
*''=담당자 메일 등록_ZGTMMV1024 CALL
  LV_VIEW = COND #( WHEN PV_GB = 'M' THEN 'ZGTMMV1023' ELSE 'ZGTMMV1024' ).

  TRY.

      CALL FUNCTION 'VIEW_MAINTENANCE_CALL'
        EXPORTING
          ACTION                       = 'U'         " 'U'는 수정 모드, 'S'는 조회 모드
          VIEW_NAME                    = LV_VIEW " 호출할 유지보수 뷰
        EXCEPTIONS
          CLIENT_REFERENCE             = 1
          FOREIGN_LOCK                 = 2
          INVALID_ACTION               = 3
          NO_CLIENTINDEPENDENT_AUTH    = 4
          NO_DATABASE_FUNCTION         = 5
          NO_EDITOR_FUNCTION           = 6
          NO_SHOW_AUTH                 = 7
          NO_TVDIR_ENTRY               = 8
          NO_UPD_AUTH                  = 9
          ONLY_SHOW_ALLOWED            = 10
          SYSTEM_FAILURE               = 11
          UNKNOWN_FIELD_IN_DBA_SELLIST = 12
          VIEW_NOT_FOUND               = 13
          MAINTENANCE_PROHIBITED       = 14
          OTHERS                       = 15.

    CATCH CX_ROOT INTO DATA(LV_ERR).
      LV_MSG = LV_ERR->GET_TEXT(  ).
      MESSAGE S000 WITH LV_MSG DISPLAY LIKE GC_E.
  ENDTRY.

ENDFORM.

*&---------------------------------------------------------------------*
*& FORM SELECTION_SCREEN_OUTPUT
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
FORM SELECTION_SCREEN_OUTPUT.

  LOOP AT SCREEN.

    CASE SY-TCODE.
      WHEN 'ZGTMMR4400A'.
        IF SCREEN-GROUP1 = 'RD4'. "SCREEN-GROUP1 = 'RD3' OR
          SCREEN-ACTIVE = 0.
        ENDIF.

      WHEN 'ZGTMMR4400B'.
        SCREEN-ACTIVE = COND #( WHEN SCREEN-GROUP1 = 'RD4' THEN 1 ELSE 0 ).

*      WHEN 'ZGTMMR4400C'.
*        IF SCREEN-GROUP1 = 'RD4'.
*          SCREEN-ACTIVE = 1.
*        ELSE.
*          SCREEN-ACTIVE = 0.
*        ENDIF.
      WHEN OTHERS.
    ENDCASE.

    IF  SCREEN-GROUP1 = 'GR'.
      CASE GC_X.
        WHEN RB_RCV OR RB_MNG.
          SCREEN-ACTIVE = 0.  "비활성
        WHEN RB_GR. "
          SCREEN-ACTIVE = 1.  "활성
      ENDCASE.
    ENDIF.

    MODIFY SCREEN.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& FORM INPUT_VALIDATION
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
FORM INPUT_VALIDATION.

  CLEAR : GT_LIST, GV_ERR.

**--> 26.09 플랜트 조건 변경
*  IF P_WERKS IS INITIAL.
*    MESSAGE S008 WITH TEXT-T11 DISPLAY LIKE GC_E.
*    GV_ERR = GC_X. STOP. "필수 값이 누락되었습니다. &
*  ENDIF.
  "입고처리는 저장위치를 플랜트로 결정하므로 플랜트 필수
  IF RB_GR = GC_X AND S_WERKS[] IS INITIAL.
    MESSAGE S008 WITH TEXT-T11 DISPLAY LIKE GC_E.
    GV_ERR = GC_X. STOP. "필수 값이 누락되었습니다. 플랜트
  ENDIF.

  SELECT SINGLE 1
    FROM T001W
*    WHERE WERKS = @P_WERKS
    WHERE WERKS IN @S_WERKS
    INTO @DATA(LV_EXST).

  IF SY-SUBRC <> 0.
    MESSAGE S000 WITH TEXT-M01 DISPLAY LIKE GC_E.
    GV_ERR = GC_X. STOP. "유효하지 않은 플랜트 입니다.
  ENDIF.

  IF S_DATE[] IS INITIAL.
    MESSAGE S008 WITH TEXT-T04 DISPLAY LIKE GC_E.
    GV_ERR = GC_X. STOP. "필수 값이 누락되었습니다. 신청일자
  ENDIF.

  IF S_VKBUR-LOW IS NOT INITIAL.
    CLEAR LV_EXST.
    LOOP AT S_VKBUR INTO DATA(LS_VKBUR).

      SELECT SINGLE 1"VKBUR 영업팀
       FROM TVBVK
       WHERE VKBUR EQ @LS_VKBUR-LOW
        INTO @LV_EXST.

      IF SY-SUBRC <> 0.
        MESSAGE S081 WITH TEXT-F29 DISPLAY LIKE GC_E.
        GV_ERR = GC_X. STOP. "존재하지 않는 & 입니다.
      ENDIF.
    ENDLOOP.
  ENDIF.

  IF S_VKGRP-LOW IS NOT INITIAL.
    CLEAR LV_EXST.
    LOOP AT S_VKGRP INTO DATA(LS_VKGRP).

      SELECT SINGLE 1"VKGRP 영업그룹
      FROM TVBVK
      WHERE VKGRP EQ @LS_VKGRP-LOW
      INTO @LV_EXST.

      IF SY-SUBRC <> 0.
        MESSAGE S081 WITH TEXT-F31 DISPLAY LIKE GC_E.
        GV_ERR = GC_X. STOP. "존재하지 않는 & 입니다.
      ENDIF.
    ENDLOOP.
  ENDIF.

  IF  S_KUNNR-LOW IS NOT INITIAL.
    CLEAR LV_EXST.
    LOOP AT S_KUNNR INTO DATA(LS_KUNNR).

      SELECT SINGLE 1"KUNNR
       FROM KNA1
       WHERE KUNNR EQ @LS_KUNNR-LOW
        INTO @LV_EXST.

      IF SY-SUBRC <> 0.
        MESSAGE S000 WITH TEXT-M02 DISPLAY LIKE GC_E.
        GV_ERR = GC_X. STOP. "유효하지 않은 고객코드 입니다.
      ENDIF.

    ENDLOOP.
  ENDIF.

*  IF S_LIFNR IS NOT INITIAL.
*    LOOP AT S_LIFNR INTO DATA(LS_LOW).
*
*      SELECT SINGLE 1
*      FROM LFA1
*      WHERE LIFNR EQ @LS_LOW-LOW
*      INTO @LV_EXST.
*
*      IF SY-SUBRC <> 0.
*        MESSAGE S000 WITH TEXT-M03 DISPLAY LIKE GC_E.
*        GV_ERR = GC_X. STOP. "유효하지 않은 공급업체코드 입니다.
*      ENDIF.
*    ENDLOOP.
*  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*& FORM CHECK_AUTH
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
FORM CHECK_AUTH .

  AUTHORITY-CHECK OBJECT 'ZCBO_MM001'
               ID 'BUKRS' FIELD P_BUKRS.

  CHECK SY-SUBRC <> 0.

  SET CURSOR FIELD 'P_BUKRS'.
  MESSAGE E172 WITH P_BUKRS. "회사코드[&] 작업권한을 확인하세요.


**--> 26.09 플랜트 조건 변경
  IF S_WERKS[] IS NOT INITIAL.
    READ TABLE S_WERKS INDEX 1.
    AUTHORITY-CHECK OBJECT 'ZCBO_MM001'
*               ID 'WERKS' FIELD P_WERKS.
                 ID 'WERKS' FIELD S_WERKS-LOW.

    CHECK SY-SUBRC <> 0.

    SET CURSOR FIELD 'P_WERKS'.
*    MESSAGE E106 WITH P_WERKS. "플랜트[&] 작업권한을 확인하세요.
    MESSAGE E106 WITH S_WERKS-LOW. "플랜트[&] 작업권한을 확인하세요.
  ENDIF.


  AUTHORITY-CHECK OBJECT 'ZCBO_SD003'
               ID 'VKBUR' FIELD P_VKBUR.

  CHECK SY-SUBRC <> 0.

  SET CURSOR FIELD 'P_VKBUR'.
  MESSAGE E174 WITH P_VKBUR. "영업팀[&] 작업권한을 확인하세요.

  AUTHORITY-CHECK OBJECT 'ZCBO_SD003'
               ID 'VKGRP' FIELD P_VKGRP.

  CHECK SY-SUBRC <> 0.

  SET CURSOR FIELD 'P_VKGRP'.
  MESSAGE E175 WITH P_VKGRP. "영업그룹[&] 작업권한을 확인하세요.

  IF S_VKBUR[] IS NOT INITIAL.
    LOOP AT S_VKBUR INTO DATA(LS_VKBUR).
      AUTHORITY-CHECK OBJECT 'ZCBO_SD003'
                   ID 'VKBUR' FIELD LS_VKBUR-LOW.

      CHECK SY-SUBRC <> 0.

      SET CURSOR FIELD 'S_VKBUR-LOW'.
      MESSAGE E174 WITH S_VKBUR-LOW. "영업팀[&] 작업권한을 확인하세요.
    ENDLOOP.
  ENDIF.

  IF S_VKGRP[] IS NOT INITIAL.
    LOOP AT S_VKGRP INTO DATA(LS_VKGRP).
      AUTHORITY-CHECK OBJECT 'ZCBO_SD003'
                   ID 'VKGRP' FIELD LS_VKGRP-LOW.

      CHECK SY-SUBRC <> 0.

      SET CURSOR FIELD 'S_VKGRP-LOW'.
      MESSAGE E175 WITH S_VKGRP-LOW. "영업그룹[&] 작업권한을 확인하세요.
    ENDLOOP.
  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*& FORM GET_DATA
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
FORM GET_DATA .

  DATA LV_WHERE  TYPE STRING.
  DATA LV_WHEREA  TYPE STRING.
  DATA LV_WHEREB  TYPE STRING.
  CLEAR : GV_ERR, GT_LIST, GT_HEAD, GT_ITEM.

*--DATA 조회
*필수 입력 데이터 웨어조건 설정
**--> 26.09 플랜트 조건 변경
*  LV_WHERE &&= | BUKRS = '{ P_BUKRS }' AND WERKS = '{ P_WERKS }'  |.
  LV_WHERE &&= | BUKRS = '{ P_BUKRS }' AND WERKS IN @S_WERKS |.
**--< 26.09 플랜트 조건 변경
  LV_WHERE &&= | AND REQDATE >= '{ S_DATE-LOW }'  AND REQDATE <= '{ S_DATE-HIGH }' |.

**--> 26.09 플랜트 조건 변경
*  LV_WHEREA &&= | BUKRS = '{ P_BUKRS }' AND WERKS = '{ P_WERKS }'  |.
  LV_WHEREA &&= | BUKRS = '{ P_BUKRS }' AND WERKS IN @S_WERKS |.
  LV_WHEREA &&= | AND REQDATE >= '{ S_DATE-LOW }'  AND REQDATE <= '{ S_DATE-HIGH }' |.

**--> 26.09 플랜트 조건 변경
*  LV_WHEREB &&= | BUKRS = '{ P_BUKRS }' AND WERKS = '{ P_WERKS }'  |.
  LV_WHEREB &&= | BUKRS = '{ P_BUKRS }' AND WERKS IN @S_WERKS |.
**--< 26.09 플랜트 조건 변경
  LV_WHEREB &&= | AND REQDATE >= '{ S_DATE-LOW }'  AND REQDATE <= '{ S_DATE-HIGH }' |.

  CASE GC_X.
    WHEN RB_RCV.
      LV_WHEREA &&= | AND KUNNR IN @S_KUNNR AND VKBUR IN @S_VKBUR AND VKGRP IN @S_VKGRP AND VBELN IN @S_VBELN  AND ZREQ_TYPE = 'A'|.
      LV_WHEREB &&= | AND KUNNR IN @S_KUNNR AND VKBUR IN @S_VKBUR AND VKGRP IN @S_VKGRP AND VBELN IN @S_VBELN  AND ZREQ_TYPE = 'B'|.
    WHEN RB_MNG.
      LV_WHERE &&= | AND AR_DATE IN @S_DATE2 AND VKBUR IN @S_VKBUR AND VKGRP IN @S_VKGRP AND VBELN IN @S_VBELN |.
      LV_WHERE &&= | AND KUNNR IN @S_KUNNR |.
*    WHEN RB_GR.
*      IF P_DELNO <> ''.
*        SELECT FROM ZGTMM_CV_GET_DELNO_DDR
*          FIELDS *
*          WHERE DELNO = @P_DELNO
*          INTO TABLE @DATA(LT_DELLIST).
*
*      ELSE.
*            LV_WHERE &&= | AND AR_DATE IN @S_DATE2 AND VKBUR IN @S_VKBUR AND VKGRP IN @S_VKGRP AND VBELN IN @S_VBELN |.
*            LV_WHERE &&= | AND KUNNR IN @S_KUNNR  AND ZREQ_TYPE = 'A' |.
*      ENDIF.
    WHEN OTHERS.
  ENDCASE.


  CASE GC_X.
*--의뢰접수
    WHEN RB_RCV.

      LV_WHEREA &&= | AND ZMM_STAT <> @GC_A AND ZMM_STAT <> @GC_R  AND MENGE > 0  AND TRTYP <> '06' AND TRTYP <> '07'|.
      LV_WHEREB &&= | AND ZMM_STAT <> @GC_A AND ZMM_STAT <> @GC_R AND TRTYP <> '06' AND TRTYP <> '07'|.

      SELECT FROM ZGTMM_CV_GET_DDINFO
      FIELDS *
      WHERE (LV_WHEREA)
      INTO TABLE @DATA(LT_LIST).

      SELECT FROM ZGTMM_CV_GET_DDINFO
      FIELDS *
      WHERE (LV_WHEREB)
      APPENDING TABLE @LT_LIST.

      IF LT_LIST[] IS INITIAL .
        GV_ERR = GC_X.
        MESSAGE S000 WITH TEXT-E01. EXIT.           "조회 조건에 일치하는 정보가 없습니다.
      ELSE.
        LOOP AT LT_LIST ASSIGNING FIELD-SYMBOL(<FS1>).
          CLEAR : <FS1>-ZCHECK.
          IF <FS1>-REMAIN_QTY_A LT 0.
            <FS1>-ZCHECK =  GC_X.
          ENDIF.
        ENDLOOP.
      ENDIF.

      GT_LIST[] = CORRESPONDING #( LT_LIST[] ).
      SORT GT_LIST BY DLVRQ DESCENDING LIFNR KUNNR DEST1 AR_DATE  EBELN EBELP.

*--의뢰관리
    WHEN RB_MNG.

      LV_WHERE &&= | AND ( Q2 > 0  OR Q6 > 0 ) |.

      SELECT FROM ZGTMM_CV_DDR_REPORT_H
      FIELDS *
      WHERE (LV_WHERE)
      INTO TABLE @DATA(LT_HEAD).

      IF LT_HEAD[] IS INITIAL . "
        GV_ERR = GC_X.
        MESSAGE S000 WITH TEXT-E01. EXIT. "조회 조건에 일치하는 정보가 없습니다.
      ELSE.
        LOOP AT LT_HEAD ASSIGNING FIELD-SYMBOL(<FS>).

          CLEAR : <FS>-Q7, <FS>-Q8.

          IF <FS>-ZREQ_TYPE = GC_A.
            IF <FS>-Q5 > <FS>-Q9.
              <FS>-Q7 = ICON_LED_YELLOW.
            ELSEIF <FS>-Q5 = <FS>-Q9 AND <FS>-Q5 > 0.
              <FS>-Q7 = ICON_LED_GREEN.
            ELSE.
              <FS>-Q7 =  ICON_LED_RED.
            ENDIF.

            IF <FS>-Q9 > <FS>-Q11.
              <FS>-Q8 = ICON_LED_YELLOW.
            ELSEIF <FS>-Q9 = <FS>-Q11 AND <FS>-Q9 > 0.
              <FS>-Q8 = ICON_LED_GREEN.
            ELSE.
              <FS>-Q8 = ICON_LED_RED.
            ENDIF.

          ELSE.
            IF <FS>-Q3 > <FS>-Q9.
              <FS>-Q7 = ICON_LED_RED.
            ELSEIF <FS>-Q3 = <FS>-Q9 AND <FS>-Q3 > 0.
              <FS>-Q7 = ICON_LED_GREEN.
            ELSE.
              <FS>-Q7 = ICON_LED_YELLOW.
            ENDIF.
          ENDIF.

        ENDLOOP.
      ENDIF.

      GT_HEAD[] = CORRESPONDING #( LT_HEAD[] ).
      SORT GT_HEAD BY  DLVRQ DESCENDING VKBUR VKGRP KUNNR DEST1 AR_DATE.

*--입고처리
    WHEN RB_GR.

      IF P_DELNO <> ''.
        SELECT FROM ZGTMM_CV_GET_DELNO_DDR
          FIELDS *
          WHERE DELNO = @P_DELNO
          INTO TABLE @DATA(LT_DELLIST).

        IF LT_DELLIST[] IS NOT INITIAL.
          IF P_GRFIN = GC_X. "입고완료제외
            SELECT FROM ZGTMM_CV_DDR_REPORT_H
            FIELDS *
            FOR ALL ENTRIES IN @LT_DELLIST
**-- 26.09 플랜트 조건 변경
*            WHERE  BUKRS =  @P_BUKRS  AND WERKS =  @P_WERKS   AND REQDATE >=  @S_DATE-LOW  AND REQDATE <=  @S_DATE-HIGH
            WHERE  BUKRS =  @P_BUKRS  AND WERKS IN  @S_WERKS   AND REQDATE >=  @S_DATE-LOW  AND REQDATE <=  @S_DATE-HIGH
                 AND AR_DATE IN @S_DATE2 AND VKBUR IN @S_VKBUR AND VKGRP IN @S_VKGRP AND VBELN IN @S_VBELN
                 AND KUNNR IN @S_KUNNR  AND ZREQ_TYPE = 'A'  AND  Q3 > 0 AND DLVRQ = @LT_DELLIST-DLVRQ AND GRQTY = @GC_X
            INTO TABLE @DATA(LT_HEAD_GR2).

          ELSE.
            SELECT FROM ZGTMM_CV_DDR_REPORT_H
            FIELDS *
            FOR ALL ENTRIES IN @LT_DELLIST
**-- 26.09 플랜트 조건 변경
*            WHERE  BUKRS =  @P_BUKRS  AND WERKS =  @P_WERKS   AND REQDATE >=  @S_DATE-LOW  AND REQDATE <=  @S_DATE-HIGH
            WHERE  BUKRS =  @P_BUKRS  AND WERKS IN  @S_WERKS   AND REQDATE >=  @S_DATE-LOW  AND REQDATE <=  @S_DATE-HIGH
                 AND AR_DATE IN @S_DATE2 AND VKBUR IN @S_VKBUR AND VKGRP IN @S_VKGRP AND VBELN IN @S_VBELN
                 AND KUNNR IN @S_KUNNR  AND ZREQ_TYPE = 'A'  AND  Q3 > 0 AND DLVRQ = @LT_DELLIST-DLVRQ
            INTO TABLE @LT_HEAD_GR2.
          ENDIF.
        ENDIF.

      ELSE.
        IF P_GRFIN = GC_X. "입고완료제외
          SELECT FROM ZGTMM_CV_DDR_REPORT_H
          FIELDS *
**-- 26.09 플랜트 조건 변경
*          WHERE  BUKRS =  @P_BUKRS  AND WERKS =  @P_WERKS   AND REQDATE >=  @S_DATE-LOW  AND REQDATE <=  @S_DATE-HIGH
          WHERE  BUKRS =  @P_BUKRS  AND WERKS IN  @S_WERKS   AND REQDATE >=  @S_DATE-LOW  AND REQDATE <=  @S_DATE-HIGH

            AND AR_DATE IN @S_DATE2 AND VKBUR IN @S_VKBUR AND VKGRP IN @S_VKGRP AND VBELN IN @S_VBELN
            AND KUNNR IN @S_KUNNR  AND ZREQ_TYPE = 'A'  AND  Q3 > 0 AND GRQTY = @GC_X
            INTO TABLE @DATA(LT_HEAD_GR).

        ELSE.
          SELECT FROM ZGTMM_CV_DDR_REPORT_H
          FIELDS *
**-- 26.09 플랜트 조건 변경
*          WHERE  BUKRS =  @P_BUKRS  AND WERKS =  @P_WERKS   AND REQDATE >=  @S_DATE-LOW  AND REQDATE <=  @S_DATE-HIGH
          WHERE  BUKRS =  @P_BUKRS  AND WERKS IN  @S_WERKS   AND REQDATE >=  @S_DATE-LOW  AND REQDATE <=  @S_DATE-HIGH
            AND AR_DATE IN @S_DATE2 AND VKBUR IN @S_VKBUR AND VKGRP IN @S_VKGRP AND VBELN IN @S_VBELN
            AND KUNNR IN @S_KUNNR  AND ZREQ_TYPE = 'A'  AND  Q3 > 0
            INTO TABLE @LT_HEAD_GR.
        ENDIF.
      ENDIF.



*
*
*      SELECT FROM ZGTMM_CV_DDR_REPORT_H
*      FIELDS *
*      WHERE (LV_WHERE)
*      INTO TABLE @DATA(LT_HEAD_GR).


      IF LT_HEAD_GR[] IS INITIAL  AND LT_HEAD_GR2[] IS INITIAL.
        MESSAGE S000 WITH TEXT-E01.  "조회 조건에 일치하는 정보가 없습니다.
      ELSE.

        IF LT_HEAD_GR[] IS NOT INITIAL .

          LOOP AT LT_HEAD_GR ASSIGNING FIELD-SYMBOL(<FS2>).

            CLEAR : <FS2>-Q7, <FS2>-Q8.

            IF <FS2>-ZREQ_TYPE = GC_A.
              IF <FS2>-Q5 > <FS2>-Q9.
                <FS2>-Q7 = ICON_LED_YELLOW.
              ELSEIF <FS2>-Q5 = <FS2>-Q9 AND <FS2>-Q5 > 0.
                <FS2>-Q7 = ICON_LED_GREEN.
              ELSE.
                <FS2>-Q7 =  ICON_LED_RED.
              ENDIF.

              IF <FS2>-Q9 > <FS2>-Q11.
                <FS2>-Q8 = ICON_LED_YELLOW.
              ELSEIF <FS2>-Q9 = <FS2>-Q11 AND <FS2>-Q9 > 0.
                <FS2>-Q8 = ICON_LED_GREEN.
              ELSE.
                <FS2>-Q8 = ICON_LED_RED.
              ENDIF.

            ELSE.
              IF <FS2>-Q3 > <FS2>-Q9.
                <FS2>-Q7 = ICON_LED_RED.
              ELSEIF <FS2>-Q3 = <FS2>-Q9 AND <FS2>-Q3 > 0.
                <FS2>-Q7 = ICON_LED_GREEN.
              ELSE.
                <FS2>-Q7 = ICON_LED_YELLOW.
              ENDIF.
            ENDIF.

          ENDLOOP.

          GT_HEADGR[] = CORRESPONDING #( LT_HEAD_GR[] ).
          SORT GT_HEADGR BY VKBUR VKGRP KUNNR DEST1 AR_DATE DLVRQ .

        ELSE.

          LOOP AT LT_HEAD_GR2 ASSIGNING FIELD-SYMBOL(<FS4>).

            CLEAR : <FS4>-Q7, <FS4>-Q8.

            IF <FS4>-ZREQ_TYPE = GC_A.
              IF <FS4>-Q5 > <FS4>-Q9.
                <FS4>-Q7 = ICON_LED_YELLOW.
              ELSEIF <FS4>-Q5 = <FS4>-Q9 AND <FS4>-Q5 > 0.
                <FS4>-Q7 = ICON_LED_GREEN.
              ELSE.
                <FS4>-Q7 =  ICON_LED_RED.
              ENDIF.

              IF <FS4>-Q9 > <FS4>-Q11.
                <FS4>-Q8 = ICON_LED_YELLOW.
              ELSEIF <FS4>-Q9 = <FS4>-Q11 AND <FS4>-Q9 > 0.
                <FS4>-Q8 = ICON_LED_GREEN.
              ELSE.
                <FS4>-Q8 = ICON_LED_RED.
              ENDIF.

            ELSE.
              IF <FS4>-Q3 > <FS4>-Q9.
                <FS4>-Q7 = ICON_LED_RED.
              ELSEIF <FS4>-Q3 = <FS4>-Q9 AND <FS4>-Q3 > 0.
                <FS4>-Q7 = ICON_LED_GREEN.
              ELSE.
                <FS4>-Q7 = ICON_LED_YELLOW.
              ENDIF.
            ENDIF.

          ENDLOOP.

          GT_HEADGR[] = CORRESPONDING #( LT_HEAD_GR2[] ).
          SORT GT_HEADGR BY VKBUR VKGRP KUNNR DEST1 AR_DATE DLVRQ .

        ENDIF.

      ENDIF.


*      SORT GT_HEAD_GR BY BUKRS WERKS DLVRQ VKBUR VKGRP KUNNR AR_DATE REQDATE .

    WHEN OTHERS.
  ENDCASE.


ENDFORM.

*&---------------------------------------------------------------------*
*&      FORM  POPUP_TO_CONFIRM_STEP
*&---------------------------------------------------------------------*
*       TEXT
*----------------------------------------------------------------------*
FORM POPUP_TO_CONFIRM_STEP  USING PV_OPT
                                                                PV_TEXT1
                                                                PV_TEXT2
                                                                PV_TITLE.
  CLEAR GV_ANSWER.
  CALL FUNCTION 'POPUP_TO_CONFIRM_STEP'
    EXPORTING
      DEFAULTOPTION  = PV_OPT
      TEXTLINE1      = PV_TEXT1
      TEXTLINE2      = PV_TEXT2
      TITEL          = PV_TITLE
      CANCEL_DISPLAY = ''
    IMPORTING
      ANSWER         = GV_ANSWER.

ENDFORM.                    " POPUP_TO_CONFIRM_STEP

*&---------------------------------------------------------------------*
*& FORM REFRESH_TABLE
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
FORM REFRESH_TABLE USING PO_GRID TYPE REF TO CL_GUI_ALV_GRID
                                               PV_SOFT_REFRESH.

  DATA : LS_STABLE TYPE LVC_S_STBL.

  LS_STABLE-ROW = ABAP_TRUE.
  LS_STABLE-COL = ABAP_TRUE.

  CALL METHOD PO_GRID->REFRESH_TABLE_DISPLAY
    EXPORTING
      IS_STABLE = LS_STABLE
*     I_SOFT_REFRESH = PV_SOFT_REFRESH
    EXCEPTIONS
      FINISHED  = 1
      OTHERS    = 2.

ENDFORM.

*&---------------------------------------------------------------------*
*& FORM DATA_CHANGED_FINISHED
*&---------------------------------------------------------------------*
*& TEXT4
*&---------------------------------------------------------------------*
FORM DATA_CHANGED_FINISHED  USING    PV_MODIFIED TYPE CHAR01
                                     PT_MOD_CELLS TYPE LVC_T_MODI
                                     PO_SENDER.
*  DATA : LV_FD   TYPE LVC_FNAME.
*
*  CHECK PV_MODIFIED IS NOT INITIAL.

  CALL METHOD CL_GUI_CFW=>SET_NEW_OK_CODE
    EXPORTING
      NEW_CODE = 'ENTER'.

*  CASE PO_SENDER.
*    WHEN GCL_GRID.
*
*      LOOP AT PT_MOD_CELLS INTO DATA(LS_MOD_CELLS).
*
*        READ TABLE GT_LIST ASSIGNING FIELD-SYMBOL(<FS>) INDEX LS_MOD_CELLS-ROW_ID.
*
*        CASE LS_MOD_CELLS-FIELDNAME.
*          WHEN 'EKGRP'.
*
*            SELECT SINGLE EKNAM
*             FROM T024
*             WHERE EKGRP = @LS_MOD_CELLS-VALUE
*                 INTO @DATA(LV_EKNAM).
*
*             IF LV_EKNAM IS  INITIAL.
*                 <FS>-STATUS = ICON_LED_RED.
*                  LV_FD = 'EKGRP'.
*             ELSE.
*                 <FS>-EKGRP  = LS_MOD_CELLS-VALUE.
*                 <FS>-EKNAM  = LV_EKNAM.
*                 <FS>-STATUS = ICON_CHANGE.
*             ENDIF.
*
*          WHEN 'DISMM'.
*
*          WHEN 'LGFSB'. "입고저장위치
*
*          SELECT SINGLE LGOBE
*             FROM T001L
*             WHERE WERKS = @PA_WERKS
*                  AND LGORT = @LS_MOD_CELLS-VALUE
*                 INTO @DATA(LV_LGOBE).
*
*             IF LV_LGOBE IS  INITIAL.
*                 <FS>-STATUS = ICON_LED_RED.
*                  LV_FD = 'LGFSB'.
*             ELSE.
*                 <FS>-LGFSB  = LS_MOD_CELLS-VALUE.
*                 <FS>-LGOBE  = LV_LGOBE.
*                 <FS>-STATUS = ICON_CHANGE.
*             ENDIF.
*
*        ENDCASE.
*      ENDLOOP.
*
*    WHEN OTHERS.
*  ENDCASE.
*
*
*  PERFORM REFRESH_TABLE USING PO_SENDER SPACE.
*
*  CALL METHOD CL_GUI_CFW=>SET_NEW_OK_CODE
*    EXPORTING
*      NEW_CODE = 'ENTER'.


ENDFORM.

*&---------------------------------------------------------------------*
*& FORM SET_CELL_STYLE
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
FORM SET_CELL_STYLE .

  DATA : LS_STYLE TYPE LVC_S_STYL.

  DEFINE _SET_STYLE.

    ls_style-fieldname = &2.
    CASE &1.
      WHEN 'E'.
        ls_style-style = cl_gui_alv_grid=>mc_style_enabled.
      WHEN 'D'.
        ls_style-style = cl_gui_alv_grid=>mc_style_disabled.
    ENDCASE.
    INSERT ls_style INTO TABLE &3.

  END-OF-DEFINITION.


  IF GV_EDIT IS INITIAL.
    GCL_GRID->SET_READY_FOR_INPUT( 0 ).
  ELSE.
    GCL_GRID->SET_READY_FOR_INPUT( 1 ). "입력가능
  ENDIF.

*    LOOP AT GT_LIST ASSIGNING FIELD-SYMBOL(<LS_LIST>).
*      CLEAR : <LS_LIST>-STYLE[].
*
*     CASE GC_X.
*       WHEN RB_RCV. "의뢰접수
*
*        IF GV_EDIT = GC_X. "변경
*         _SET_STYLE : GC_E 'REJ_CODE' <LS_LIST>-STYLE."ENABLED
*        ELSE."조회
**          CLEAR : <LS_LIST>-STATUS, <LS_LIST>-MESSAGE.
*         _SET_STYLE : GC_D 'REJ_CODE' <LS_LIST>-STYLE. "DISABLED
*        ENDIF.
*
*       WHEN RB_MNG.  "의뢰관리
*
*      WHEN OTHERS.  "품질관리/입고처리
*        IF GV_EDIT = GC_X.
*           _SET_STYLE : GC_E 'INSMK' <LS_LIST>-STYLE.
*        ELSE.
*           _SET_STYLE : GC_D 'INSMK' <LS_LIST>-STYLE.
*        ENDIF.
*    ENDCASE.
*
*    ENDLOOP.

ENDFORM.

*&---------------------------------------------------------------------*
*& FORM SET_ALV_FIELDCAT
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
FORM SET_ALV_FIELDCAT  USING PV_GUBUN TYPE CHAR1.

  DATA :
    LR_TABDESCR TYPE REF TO CL_ABAP_STRUCTDESCR,
    LT_DFIES    TYPE DDFIELDS,
    LS_DFIES    TYPE DFIES,
    LT_FCAT     TYPE LVC_T_FCAT,
    LS_FCAT     TYPE LVC_S_FCAT.

  DATA : GR_DREF  TYPE REF TO DATA.
  CLEAR GR_DREF.

  CASE PV_GUBUN.
    WHEN '0'.
      CREATE DATA GR_DREF LIKE GS_LIST.

    WHEN '1'.
      CREATE DATA GR_DREF LIKE GS_HEAD.

    WHEN '2'.
      CREATE DATA GR_DREF LIKE GS_ITEM.

    WHEN '3'.
      CREATE DATA GR_DREF LIKE GS_HEADGR.
*      CREATE DATA GR_DREF LIKE GS_HEAD_GR.

    WHEN '4'.
      CREATE DATA GR_DREF LIKE GS_ITEM_GR.

    WHEN '5'.
      CREATE DATA GR_DREF LIKE GS_TRINFO.

    WHEN OTHERS.
  ENDCASE.

  LR_TABDESCR ?= CL_ABAP_STRUCTDESCR=>DESCRIBE_BY_DATA_REF( GR_DREF ).
  LT_DFIES = CL_SALV_DATA_DESCR=>READ_STRUCTDESCR( LR_TABDESCR ) .

  REFRESH : LT_FCAT.

  LOOP AT LT_DFIES INTO LS_DFIES.
    CLEAR : LS_FCAT.
    MOVE-CORRESPONDING LS_DFIES TO LS_FCAT.
    APPEND LS_FCAT TO LT_FCAT.
  ENDLOOP.

  " 필드 카탈로그 변경사항 적용
  CASE PV_GUBUN.
    WHEN '0'.
      PERFORM ADJUST_FLDCATS TABLES LT_FCAT.

    WHEN '1'.
      PERFORM ADJUST_FLDCATS_HD TABLES LT_FCAT .

    WHEN '2'.
      PERFORM ADJUST_FLDCATS_IT TABLES LT_FCAT .

    WHEN '3'.
      PERFORM ADJUST_FLDCATS_HD TABLES LT_FCAT .

    WHEN '4'.
      PERFORM ADJUST_FLDCATS_IT TABLES LT_FCAT .

    WHEN '5'.
      PERFORM ADJUST_FLDCATS_TR TABLES LT_FCAT .

    WHEN OTHERS.
  ENDCASE.
ENDFORM.

*&---------------------------------------------------------------------*
*& FORM DATA_CHANGED
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
FORM DATA_CHANGED  USING  PO_DATA_CHANGED
                                     TYPE REF TO CL_ALV_CHANGED_DATA_PROTOCOL
                                                PO_SENDER.

  CASE PO_SENDER.

    WHEN GCL_GRID.
      PERFORM DATA_CHANGED_1 USING PO_DATA_CHANGED GCL_GRID.

    WHEN GCL_GRID_HD.
      PERFORM DATA_CHANGED_2 USING PO_DATA_CHANGED GC_1.

    WHEN GCL_GRID_IT.
      PERFORM DATA_CHANGED_2 USING PO_DATA_CHANGED ''.

    WHEN OTHERS.
      EXIT.
  ENDCASE.
*
*  IF GV_BOTTOM = GC_X.
*  CALL METHOD CL_GUI_CFW=>SET_NEW_OK_CODE
*    EXPORTING
*      NEW_CODE = 'ENTER'.
*  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*&      FORM  DATA_CHANGED_1
*&---------------------------------------------------------------------*
*       TEXT
*----------------------------------------------------------------------*
*      -->P_PO_DATA_CHANGED  TEXT
*----------------------------------------------------------------------*
FORM DATA_CHANGED_1 USING PO_DATA_CHANGED
                                       TYPE REF TO CL_ALV_CHANGED_DATA_PROTOCOL
                                       PCL_GRID TYPE REF TO CL_GUI_ALV_GRID.

  DATA : LV_ERR TYPE CHAR1.
  DATA : LV_FD  TYPE LVC_FNAME,
         LV_MSG TYPE BAPI_MSG.

  PERFORM GET_SELECTED_ROWS USING PCL_GRID 'M' LV_ERR LV_MSG.

  LOOP AT PO_DATA_CHANGED->MT_MOD_CELLS INTO DATA(LS_MOD_CELLS).

    READ TABLE GT_LIST ASSIGNING FIELD-SYMBOL(<FS>) INDEX LS_MOD_CELLS-ROW_ID.
    CHECK <FS> IS ASSIGNED.
    CLEAR LV_FD.

    CASE LS_MOD_CELLS-FIELDNAME.

      WHEN 'CHECK'.
        <FS>-CHECK = LS_MOD_CELLS-VALUE.
        LOOP AT GT_LIST ASSIGNING FIELD-SYMBOL(<LIST>) WHERE LIFNR = <FS>-LIFNR
                                                                                          AND KUNNR = <FS>-KUNNR
                                                                                          AND DEST1 = <FS>-DEST1
                                                                                          AND AR_DATE = <FS>-AR_DATE.
          <LIST>-CHECK = LS_MOD_CELLS-VALUE.
        ENDLOOP.

      WHEN 'REJ_CODE'.


    ENDCASE.

  ENDLOOP.

  IF LV_FD IS NOT INITIAL.
    PERFORM ADD_ENTRY USING PO_DATA_CHANGED LV_FD
                                                 LS_MOD_CELLS-ROW_ID.
    CALL METHOD PO_DATA_CHANGED->DISPLAY_PROTOCOL.
  ENDIF.

  CL_GUI_CFW=>SET_NEW_OK_CODE( NEW_CODE = 'NEWCODE' ).

ENDFORM. " DATA_CHANGED_1

*&---------------------------------------------------------------------*
*&      FORM  DATA_CHANGED_2
*&---------------------------------------------------------------------*
*       TEXT
*----------------------------------------------------------------------*
*      -->P_PO_DATA_CHANGED  TEXT
*----------------------------------------------------------------------*
FORM DATA_CHANGED_2 USING PO_DATA_CHANGED
                                                 TYPE REF TO CL_ALV_CHANGED_DATA_PROTOCOL
                                                 PV_GB.

  DATA : LV_ERR TYPE CHAR1.

  CLEAR : GV_BLAND, GV_CITY1, GV_DEST1, GV_SITE_NAME, GV_SITE_TEL,
               GV_CUST_NAME , GV_CUST_TEL, GV_DEST2, GV_SP_NOTE, GV_BOTTOM.

  LOOP AT PO_DATA_CHANGED->MT_MOD_CELLS INTO DATA(LS_MOD_CELLS).

    IF PV_GB = GC_1.
      READ TABLE GT_HEAD ASSIGNING FIELD-SYMBOL(<FS>) INDEX LS_MOD_CELLS-ROW_ID.
      CHECK <FS> IS ASSIGNED.
    ENDIF.

    CASE LS_MOD_CELLS-FIELDNAME.

      WHEN 'CHECK'.
        IF LS_MOD_CELLS-VALUE IS INITIAL.
          PERFORM MODIFY_CELL USING PO_DATA_CHANGED 'CHECK'
                          LS_MOD_CELLS-VALUE LS_MOD_CELLS-ROW_ID.
          IF PV_GB = GC_1 AND GT_ITEM[] IS NOT INITIAL.
            DELETE GT_ITEM WHERE DLVRQ = <FS>-DLVRQ.
          ENDIF.

        ELSE.
          IF PV_GB = GC_1.
*기존 체크된 데이터 있으면, 클리어 후 새로 선택한 데이터로 체크.
            READ TABLE GT_HEAD ASSIGNING FIELD-SYMBOL(<OLD>)
            WITH KEY CHECK = GC_X.

            IF SY-SUBRC = 0.
              CLEAR : <OLD>-CHECK.
              DELETE GT_ITEM WHERE DLVRQ = <OLD>-DLVRQ.
            ENDIF.

            <FS>-CHECK = LS_MOD_CELLS-VALUE.
*상단 ALV에서 1라인만 체크한 경우,대상 ITEM ALV 구성
            "상단 정보->중간 영역 스크린 필드 채우기
            GV_BLAND  = <FS>-BLAND_N."<FS>-BLAND.
            GV_CITY1    = <FS>-CITY1.
            GV_DEST1   = <FS>-DEST1.
            GV_SITE_NAME = <FS>-SITE_NAME.
            GV_SITE_TEL    = <FS>-SITE_TEL.
            GV_CUST_NAME  = <FS>-CUST_NAME.
            GV_CUST_TEL     = <FS>-CUST_TEL.
            GV_DEST2           = <FS>-DEST2.
            GV_SP_NOTE      = <FS>-SP_NOTE.

            GV_BOTTOM = GC_X.
            "선택 라인 기준의 ITEM 데이터 가져오기
            SELECT FROM ZGTMM_CV_DDR_REPORT_I
            FIELDS *
            WHERE BUKRS = @P_BUKRS
                 AND DLVRQ = @<FS>-DLVRQ
                INTO CORRESPONDING FIELDS OF TABLE @GT_ITEM.

            IF SY-SUBRC = 0.
              LOOP AT GT_ITEM ASSIGNING FIELD-SYMBOL(<ITEM2>).
                IF <ITEM2>-ZMM_STAT = GC_A.
                  <ITEM2>-STATUS1 = ICON_ALLOW.
                ELSEIF  <ITEM2>-ZMM_STAT = GC_R.
                  <ITEM2>-STATUS1 = ICON_REJECT.
                ELSE.
                  CLEAR <ITEM2>-STATUS1.
                ENDIF.

                IF <ITEM2>-ZVD_STAT = GC_A.
                  <ITEM2>-STATUS2 = ICON_ALLOW.
                ELSEIF  <ITEM2>-ZVD_STAT = GC_R.
                  <ITEM2>-STATUS2 = ICON_REJECT.
                ELSE.
                  CLEAR <ITEM2>-STATUS2.
                ENDIF.

                IF <ITEM2>-LOADQTY GT 0.
                  <ITEM2>-STATUS3 = ICON_TRANSPORT.
                ELSE.
                  CLEAR <ITEM2>-STATUS3.
                ENDIF.

              ENDLOOP.

*              GV_BOTTOM = GC_X.
*              PERFORM CREATE_ALV_300 USING GC_X.
            ELSE.
              MESSAGE S000 WITH '상세 직송 의뢰 건이 존재하지 않습니다.'(e03) DISPLAY LIKE GC_E.
            ENDIF.

          ELSE. "PV_GB = '2''
*하단 ALV는 다중 선택 가능
            PERFORM MODIFY_CELL USING PO_DATA_CHANGED 'CHECK'
                            LS_MOD_CELLS-VALUE LS_MOD_CELLS-ROW_ID.
            READ TABLE GT_ITEM ASSIGNING FIELD-SYMBOL(<ITEM>) INDEX LS_MOD_CELLS-ROW_ID.
            IF SY-SUBRC = 0.
              <ITEM>-CHECK =  LS_MOD_CELLS-VALUE.
              MODIFY GT_ITEM FROM <ITEM> INDEX  LS_MOD_CELLS-ROW_ID.
            ENDIF.
          ENDIF.

        ENDIF.

      WHEN OTHERS.
    ENDCASE.

  ENDLOOP.

*  IF PV_GB = GC_1. "헤더의 체크박스 변경일 때만 적용_ 중간 스크린 필드 갱신용
*    CL_GUI_CFW=>SET_NEW_OK_CODE( NEW_CODE = 'NEWCODE' ).
*  ELSE.
*    PERFORM REFRESH_TABLE USING GCL_GRID_IT SPACE.
*  ENDIF.

ENDFORM. " DATA_CHANGED_2

*&---------------------------------------------------------------------*
*& FORM HANDEL_TOOLBAR
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
FORM HANDLE_TOOLBAR  USING  PO_OBJECT
                                                   TYPE REF TO CL_ALV_EVENT_TOOLBAR_SET
                                                    PO_ENTIV
                                                    PO_SENDER.

  DATA : LS_TBAR TYPE STB_BUTTON.

  DEFINE _SET_TBAR.
    CLEAR : ls_tbar.
    ls_tbar-butn_type = &1.
    ls_tbar-function   = &2.
    ls_tbar-icon           = &3.
    ls_tbar-text           = &4.
    ls_tbar-quickinfo  = &4.
    APPEND ls_tbar TO po_object->mt_toolbar.
  END-OF-DEFINITION.

  CASE PO_SENDER.

    WHEN GCL_GRID_HD.
*      DELETE PO_OBJECT->MT_TOOLBAR WHERE FUNCTION = 'GICHK'.
      DELETE PO_OBJECT->MT_TOOLBAR WHERE FUNCTION = 'REFRESH'.

      _SET_TBAR 3 '    ' '              ' '    '.
*      _SET_TBAR 0 'GICHK' ICON_ALLOW '출고확정'(B03).
      _SET_TBAR 0 'REFRESH' ICON_REFRESH 'REFRESH'(b05).

    WHEN GCL_GRID_IT.
      DELETE PO_OBJECT->MT_TOOLBAR WHERE FUNCTION = 'CANC'.
      DELETE PO_OBJECT->MT_TOOLBAR WHERE FUNCTION = 'RJT'.

      _SET_TBAR 3 '    ' '              ' '    '.
      _SET_TBAR 0 'CANC' ICON_CANCEL '접수취소'(b01).
      _SET_TBAR 0 'RJT' ICON_REJECT  '반려'(b02).

    WHEN GCL_GRID_GRHD.
      DELETE PO_OBJECT->MT_TOOLBAR WHERE FUNCTION = 'GR'.

      _SET_TBAR 3 '    ' '              ' '    '.
      _SET_TBAR 0 'ITEM' ICON_SELECT_DETAIL '상세조회'(b08).
      _SET_TBAR 0 'REFRESH' ICON_REFRESH 'REFRESH'(b05).
*      _SET_TBAR 0 'GR' ICON_STOCK '보관입고처리'(B04).

    WHEN GCL_GRID_GRIT.
      DELETE PO_OBJECT->MT_TOOLBAR WHERE FUNCTION = 'REFRESH'.
      DELETE PO_OBJECT->MT_TOOLBAR WHERE FUNCTION = 'DRGR'.
      DELETE PO_OBJECT->MT_TOOLBAR WHERE FUNCTION = 'GRCANC'.

      _SET_TBAR 3 '    ' '              ' '    '.
      _SET_TBAR 0 'REFRESH' ICON_REFRESH 'REFRESH'(b05).
      _SET_TBAR 0 'DRGR' ICON_TRANSPORT  '직송입고'(b06).
      _SET_TBAR 0 'GRCANC' ICON_REJECT '입고취소'(b07).

    WHEN OTHERS.
      EXIT.
  ENDCASE.

ENDFORM.

*&---------------------------------------------------------------------*
*& FORM USER_COMMAND
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
FORM USER_COMMAND  USING  PO_UCOMM LIKE SY-UCOMM
                                                  PO_SENDER.

  CHECK PO_UCOMM NE 'BACK' OR PO_UCOMM NE 'CANC'.

  CLEAR GV_UCOMM.
  GV_UCOMM = PO_UCOMM.

  CASE PO_UCOMM.

    WHEN 'CANC'. "접수취소
      PERFORM DATA_CANCEL .
      PERFORM REFRESH_TABLE USING GCL_GRID_IT SPACE.

    WHEN 'RJT'.     "반려
      PERFORM DATA_REJECT.
      PERFORM REFRESH_TABLE USING GCL_GRID_IT SPACE.

*    WHEN 'GICHK'. "출고확인
*      PERFORM DATA_GI_CHECK.

    WHEN 'ITEM' OR 'REFRESH'."상세조회 OR 'REFRESH'-상단 선택기준 ITEM재조회 기능임
      CASE PO_SENDER.
        WHEN GCL_GRID_GRHD.
          PERFORM GET_GRDATA_ITEM.
          PERFORM REFRESH_TABLE USING GCL_GRID_GRHD SPACE.
          PERFORM REFRESH_TABLE USING GCL_GRID_GRIT SPACE.

        WHEN GCL_GRID_HD.
          PERFORM GET_MNGDATA_ITEM.
          PERFORM REFRESH_TABLE USING GCL_GRID_HD SPACE.
          PERFORM REFRESH_TABLE USING GCL_GRID_IT SPACE.
        WHEN OTHERS.
      ENDCASE.

    WHEN 'GR'. "보관입고처리
      CALL TRANSACTION 'ZGTMMR4330'.

    WHEN 'DRGR'. "직송입고
      PERFORM SET_DATA_DRGR.
      PERFORM REFRESH_TABLE USING GCL_GRID_GRHD SPACE.
      PERFORM REFRESH_TABLE USING GCL_GRID_GRIT SPACE.

    WHEN 'GRCANC'. "입고취소
      PERFORM SET_DATA_GRCANC.
      PERFORM REFRESH_TABLE USING GCL_GRID_GRHD SPACE.
      PERFORM REFRESH_TABLE USING GCL_GRID_GRIT SPACE.

    WHEN OTHERS.
      EXIT.
  ENDCASE.


ENDFORM.

*&---------------------------------------------------------------------*
*& FORM MODIFY_CELL
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
*&      --> PR_CHNG
*&      --> P_
*&      --> P_
*&---------------------------------------------------------------------*
FORM MODIFY_CELL USING PR_CHNG TYPE REF TO CL_ALV_CHANGED_DATA_PROTOCOL
                                           PV_FNAME
                                           PV_FVAL
                                           PV_INDEX.

  CALL METHOD PR_CHNG->MODIFY_CELL
    EXPORTING
      I_ROW_ID    = PV_INDEX
      I_FIELDNAME = PV_FNAME
      I_VALUE     = PV_FVAL.

ENDFORM.

*&---------------------------------------------------------------------*
*& FORM ADD_ENTRY
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
*&      --> PR_CHNG
*&      --> P_
*&      --> P_
*&---------------------------------------------------------------------*
FORM ADD_ENTRY     USING PR_CHNG TYPE REF TO CL_ALV_CHANGED_DATA_PROTOCOL
                                           PV_FNAME
                                           PV_INDEX.

  CALL METHOD PR_CHNG->ADD_PROTOCOL_ENTRY
    EXPORTING
      I_MSGID     = 'ZGTMM01'
      I_MSGNO     = '013'
      I_MSGV1     = PV_FNAME
      I_MSGTY     = GC_E
      I_FIELDNAME = PV_FNAME
      I_ROW_ID    = PV_INDEX.

ENDFORM.

*&---------------------------------------------------------------------*
*& FORM HOTSPOT_CLICK
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
FORM HOTSPOT_CLICK USING PS_ROW_NO TYPE LVC_S_ROW
                                               PS_COLUMN TYPE LVC_S_COL
                                               PO_SENDER.

*  CHECK PO_SENDER = GCL_GRID .
  CHECK PS_ROW_NO-ROWTYPE IS INITIAL.
  CLEAR GV_A.

  CASE PO_SENDER.
    WHEN GCL_GRID.
      READ TABLE GT_LIST INTO DATA(LS_LIST0) INDEX PS_ROW_NO-INDEX.
      CHECK SY-SUBRC = 0.

      IF PS_COLUMN-FIELDNAME = 'EBELN'.
        CHECK LS_LIST0-EBELN IS NOT INITIAL.

        SET PARAMETER ID 'BES' FIELD LS_LIST0-EBELN.
        CALL TRANSACTION 'ME23N' AND SKIP FIRST SCREEN.
      ELSEIF PS_COLUMN-FIELDNAME = 'VBELN'.
        CHECK LS_LIST0-VBELN IS NOT INITIAL.
        SET PARAMETER ID 'AUN' FIELD LS_LIST0-VBELN.
        CALL TRANSACTION 'VA03' AND SKIP FIRST SCREEN.
      ELSEIF PS_COLUMN-FIELDNAME = 'MATNR'.
        CHECK LS_LIST0-MATNR IS NOT INITIAL.
        SET PARAMETER ID 'MAT' FIELD LS_LIST0-MATNR.
        CALL TRANSACTION 'MM03' AND SKIP FIRST SCREEN.
      ENDIF.

    WHEN GCL_GRID_HD.
      READ TABLE GT_HEAD INTO DATA(LS_HD) INDEX PS_ROW_NO-INDEX.
      CHECK SY-SUBRC = 0.

      IF PS_COLUMN-FIELDNAME = 'Q9' OR PS_COLUMN-FIELDNAME = 'Q10'. "'배차완료'."''거래명세서'.

        CASE LS_HD-ZREQ_TYPE.
          WHEN GC_A.
            SELECT * FROM ZGTMMT4403
              WHERE DLVRQ = @LS_HD-DLVRQ
              INTO CORRESPONDING FIELDS OF TABLE @GT_TRINFO.

            GV_A = GC_X.

          WHEN GC_B.
            SELECT * FROM ZGTMMT4405
              WHERE DLVRQ = @LS_HD-DLVRQ
              INTO CORRESPONDING FIELDS OF TABLE @GT_TRINFO.

          WHEN OTHERS.
        ENDCASE.

        IF GT_TRINFO[] IS NOT INITIAL.
          CALL SCREEN 0500 STARTING AT 10 5 ENDING AT 130 15.
        ENDIF.


      ENDIF.

    WHEN  GCL_GRID_GRHD.
      READ TABLE GT_HEADGR INTO DATA(LS_HD_GR) INDEX PS_ROW_NO-INDEX.
      CHECK SY-SUBRC = 0.

      IF PS_COLUMN-FIELDNAME = 'Q9' OR PS_COLUMN-FIELDNAME = 'Q10'. "'배차완료'."''거래명세서'.

        CASE LS_HD_GR-ZREQ_TYPE.
          WHEN GC_A.
            SELECT * FROM ZGTMMT4403
              WHERE DLVRQ = @LS_HD_GR-DLVRQ
              INTO CORRESPONDING FIELDS OF TABLE @GT_TRINFO.

            GV_A = GC_X.

          WHEN GC_B.
            SELECT * FROM ZGTMMT4405
              WHERE DLVRQ = @LS_HD_GR-DLVRQ
              INTO CORRESPONDING FIELDS OF TABLE @GT_TRINFO.

          WHEN OTHERS.
        ENDCASE.

        IF GT_TRINFO[] IS NOT INITIAL.
          CALL SCREEN 0500 STARTING AT 10 5 ENDING AT 130 15.
        ENDIF.


      ENDIF.

    WHEN GCL_GRID_IT.
      READ TABLE GT_ITEM INTO DATA(LS_LIST2) INDEX PS_ROW_NO-INDEX.
      CHECK SY-SUBRC = 0.
      IF PS_COLUMN-FIELDNAME = 'EBELN'.
        CHECK LS_LIST2-EBELN IS NOT INITIAL.

        SET PARAMETER ID 'BES' FIELD LS_LIST2-EBELN.
        CALL TRANSACTION 'ME23N' AND SKIP FIRST SCREEN.
      ELSEIF PS_COLUMN-FIELDNAME = 'VBELN'.
        CHECK LS_LIST2-VBELN IS NOT INITIAL.
        SET PARAMETER ID 'AUN' FIELD LS_LIST2-VBELN.
        CALL TRANSACTION 'VA03' AND SKIP FIRST SCREEN.
      ELSEIF PS_COLUMN-FIELDNAME = 'MATNR'.
        CHECK LS_LIST2-MATNR IS NOT INITIAL.
        SET PARAMETER ID 'MAT' FIELD LS_LIST2-MATNR.
        CALL TRANSACTION 'MM03' AND SKIP FIRST SCREEN.
      ENDIF.


    WHEN GCL_GRID_GRIT.
      READ TABLE GT_ITEM_GR INTO DATA(LS_LIST) INDEX PS_ROW_NO-INDEX.
      CHECK SY-SUBRC = 0.

      IF PS_COLUMN-FIELDNAME = 'MBLNR'.
        CHECK LS_LIST-MBLNR IS NOT INITIAL.

        CALL FUNCTION 'MIGO_DIALOG'
          EXPORTING
            I_MBLNR             = LS_LIST-MBLNR
            I_MJAHR             = LS_LIST-MJAHR
          EXCEPTIONS
            ILLEGAL_COMBINATION = 1
            OTHERS              = 2.
        IF SY-SUBRC <> 0.
* Implement suitable error handling here
        ENDIF.

      ELSEIF PS_COLUMN-FIELDNAME = 'EBELN'.
        CHECK LS_LIST-EBELN IS NOT INITIAL.

        SET PARAMETER ID 'BES' FIELD LS_LIST-EBELN.
        CALL TRANSACTION 'ME23N' AND SKIP FIRST SCREEN.
      ELSEIF PS_COLUMN-FIELDNAME = 'VBELN'.
        CHECK LS_LIST-VBELN IS NOT INITIAL.
        SET PARAMETER ID 'AUN' FIELD LS_LIST-VBELN.
        CALL TRANSACTION 'VA03' AND SKIP FIRST SCREEN.
      ELSEIF PS_COLUMN-FIELDNAME = 'MATNR'.
        CHECK LS_LIST-MATNR IS NOT INITIAL.
        SET PARAMETER ID 'MAT' FIELD LS_LIST-MATNR.
        CALL TRANSACTION 'MM03' AND SKIP FIRST SCREEN.

      ELSE.
        EXIT.
      ENDIF.

    WHEN OTHERS.
  ENDCASE.

ENDFORM.

*&---------------------------------------------------------------------*
*&      FORM  ON_F4
*&---------------------------------------------------------------------*
FORM ON_F4  USING E_FIELDNAME    TYPE LVC_FNAME
                  E_FIELDVALUE   TYPE LVC_VALUE
                  ES_ROW_NO      TYPE LVC_S_ROID
                  ER_EVENT_DATA  TYPE REF TO CL_ALV_EVENT_DATA
                  ET_BAD_CELLS   TYPE LVC_T_MODI
                  E_DISPLAY      TYPE CHAR01.

*  DATA : SELECTFIELD  LIKE HELP_INFO-FIELDNAME,
*         IT_FIELDS    LIKE HELP_VALUE OCCURS 1 WITH HEADER LINE,
*         LS_HEADING   TYPE F4TYP_HEAD_STRUC,
*         LT_HEADING   TYPE F4TYP_HEADING_TAB,
*         SELECT_VALUE LIKE HELP_INFO-FLDVALUE,
*         LV_TABIX     LIKE SY-TABIX,
*         LS_MODI      TYPE LVC_S_MODI,
*         F_DATE       LIKE SY-DATUM.
*
*  FIELD-SYMBOLS : <F4TAB> TYPE LVC_T_MODI.
*
*  CASE E_FIELDNAME.
*    WHEN  'LGFSB'.
**  IF E_FIELDNAME = 'LGFSB'.
*    IT_FIELDS-TABNAME    = 'T001L'.
*    IT_FIELDS-FIELDNAME  = 'WERKS'.
*    IT_FIELDS-SELECTFLAG = ' '.
*    APPEND IT_FIELDS.
*
*    IT_FIELDS-TABNAME    = 'T001L'.
*    IT_FIELDS-FIELDNAME  = 'LGORT'.
*    IT_FIELDS-SELECTFLAG = 'X'.
*    APPEND IT_FIELDS.
*
*    IT_FIELDS-TABNAME    = 'T001L'.
*    IT_FIELDS-FIELDNAME  = 'LGOBE'.
*    IT_FIELDS-SELECTFLAG = ' '.
*    APPEND IT_FIELDS.
*
*    CLEAR LS_HEADING.
*    LS_HEADING-TABNAME = 'T001L'.
*    LS_HEADING-FIELDNAME = 'WERKS'.
*    LS_HEADING-HEAD_TEXT = TEXT-F02.
*    APPEND LS_HEADING TO LT_HEADING.
*
*    CLEAR LS_HEADING.
*    LS_HEADING-TABNAME = 'T001L'.
*    LS_HEADING-FIELDNAME = 'LGORT'.
*    LS_HEADING-HEAD_TEXT = TEXT-F23.
*    APPEND LS_HEADING TO LT_HEADING.
*
*    CLEAR LS_HEADING.
*    LS_HEADING-TABNAME = 'T001L'.
*    LS_HEADING-FIELDNAME = 'LGOBE'.
*    LS_HEADING-HEAD_TEXT = TEXT-F24.
*    APPEND LS_HEADING TO LT_HEADING.
*
*    CALL FUNCTION 'HELP_VALUES_GET_NO_DD_NAME'
*      EXPORTING
*        SELECTFIELD           = SELECTFIELD
*      IMPORTING
*        IND                          = LV_TABIX
*        SELECT_VALUE       = SELECT_VALUE
*      TABLES
*        FIELDS                    = IT_FIELDS
*        FULL_TABLE           = T001L
*        HEADING_TABLE      = LT_HEADING
*      EXCEPTIONS
*        FULL_TABLE_EMPTY                    = 1
*        NO_TABLESTRUCTURE_GIVEN      = 2
*        NO_TABLEFIELDS_IN_DICTIONARY = 3
*        MORE_THEN_ONE_SELECTFIELD   = 4
*        NO_SELECTFIELD                          = 5
*        OTHERS                                        = 6.
*
*    IF SY-SUBRC <> 0.
*      MESSAGE S002 WITH 'POSSIBLE ENTRY DATA가 없습니다 !!!'.
*    ENDIF.
*
*    READ TABLE T001L INTO DATA(LS_TEMP) INDEX LV_TABIX.
*
*    ASSIGN ER_EVENT_DATA->M_DATA->* TO <F4TAB>.
*
*    LS_MODI-ROW_ID    = ES_ROW_NO-ROW_ID.
*    LS_MODI-FIELDNAME = 'LGFSB'.
*    LS_MODI-VALUE     = SELECT_VALUE.
*    APPEND LS_MODI TO <F4TAB>.
*
*    LS_MODI-FIELDNAME = 'LGOBE'.
*    LS_MODI-VALUE     = LS_TEMP-LGOBE.
*    APPEND LS_MODI TO <F4TAB>.

*    WHEN  'MWSKZ'.
**  ELSEIF E_FIELDNAME = 'MWSKZ'.
*
*    IT_FIELDS-TABNAME    = 'T007S'.
*    IT_FIELDS-FIELDNAME  = 'MWSKZ'.
*    IT_FIELDS-SELECTFLAG = 'X'.
*    APPEND IT_FIELDS.
*
*    IT_FIELDS-TABNAME    = 'T007S'.
*    IT_FIELDS-FIELDNAME  = 'TEXT1'.
*    IT_FIELDS-SELECTFLAG = ' '.
*    APPEND IT_FIELDS.
*
*    CLEAR LS_HEADING.
*    LS_HEADING-TABNAME = 'T007S'.
*    LS_HEADING-FIELDNAME = 'MWSKZ'.
*    LS_HEADING-HEAD_TEXT = TEXT-F54.
*    APPEND LS_HEADING TO LT_HEADING.
*
*    CLEAR LS_HEADING.
*    LS_HEADING-TABNAME = 'T007S'.
*    LS_HEADING-FIELDNAME = 'TEXT1'.
*    LS_HEADING-HEAD_TEXT = TEXT-F60.
*    APPEND LS_HEADING TO LT_HEADING.
*
*    CALL FUNCTION 'HELP_VALUES_GET_NO_DD_NAME'
*      EXPORTING
*        SELECTFIELD                  = SELECTFIELD
*      IMPORTING
*        IND                          = LV_TABIX
*        SELECT_VALUE                 = SELECT_VALUE
*      TABLES
*        FIELDS                       = IT_FIELDS
*        FULL_TABLE                   = GT_007S
*        HEADING_TABLE                = LT_HEADING
*      EXCEPTIONS
*        FULL_TABLE_EMPTY             = 1
*        NO_TABLESTRUCTURE_GIVEN      = 2
*        NO_TABLEFIELDS_IN_DICTIONARY = 3
*        MORE_THEN_ONE_SELECTFIELD    = 4
*        NO_SELECTFIELD               = 5
*        OTHERS                       = 6.
*
*    IF SY-SUBRC <> 0.
*      MESSAGE S002 WITH 'POSSIBLE ENTRY DATA가 없습니다 !!!'.
*    ENDIF.
*
*    READ TABLE GT_007S INDEX LV_TABIX.
*
*    ASSIGN ER_EVENT_DATA->M_DATA->* TO <F4TAB>.
*
*    LS_MODI-ROW_ID    = ES_ROW_NO-ROW_ID.
*    LS_MODI-FIELDNAME = 'MWSKZ'.
*    LS_MODI-VALUE     = SELECT_VALUE.
*    APPEND LS_MODI TO <F4TAB>.
*
*    LS_MODI-FIELDNAME = 'MWSKZ_TX'.
*    LS_MODI-VALUE     = GT_007S-TEXT1.
*    APPEND LS_MODI TO <F4TAB>.
*  ENDIF.

*    WHEN OTHERS.
*  ENDCASE.

** TO AVOID STANDARD F4-HELP.
*  IF LS_MODI-VALUE <> ' ' .
*    ER_EVENT_DATA->M_EVENT_HANDLED = 'X'.
*  ENDIF.

ENDFORM.                                                    " ON_F41

*&---------------------------------------------------------------------*
*& FORM SET_F4_FIELD
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
FORM SET_F4_FIELD .

*  CLEAR : GT_F4_3, GT_F4_4.
*
*  IF GV_300GB = 1.
*    GS_F4_4-FIELDNAME  = 'MWSKZ'.
*    GS_F4_4-REGISTER   = 'X'.
*    APPEND GS_F4_4 TO GT_F4_4.
*
*    CALL METHOD GCL_GRID_4->REGISTER_F4_FOR_FIELDS
*      EXPORTING
*        IT_F4 = GT_F4_4.
*  ENDIF.
*
*  GS_F4_3-FIELDNAME  = 'HKONT'.
*  GS_F4_3-REGISTER   = 'X'.
*  APPEND GS_F4_3 TO GT_F4_3.
*
*  CALL METHOD GCL_GRID_3->REGISTER_F4_FOR_FIELDS
*    EXPORTING
*      IT_F4 = GT_F4_3.

ENDFORM.

*&---------------------------------------------------------------------*
*& FORM CLEAR_POST_PROCESS
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
FORM CLEAR_POST_PROCESS  USING    PV_SIMUL.   "X면 SIMUL.

  CHECK GV_ERR IS INITIAL.

ENDFORM.

*&---------------------------------------------------------------------*
*& FORM CHECK_CLOSING_MONTH
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
FORM CHECK_CLOSING_MONTH  USING  PV_DATE TYPE DATUM
                                             CHANGING  PV_CHK  TYPE CHAR1.

*  CLEAR PV_CHK.
*
*  CALL FUNCTION 'ZTR_CLOSING_MONTH_CHECK'
*    EXPORTING
*      IBUKRS       = P_BUKRS
*      IDATE        = PV_DATE
*    EXCEPTIONS
*      NO_SETTING   = 1
*      CLOSING_DATE = 2
*      OTHERS       = 3.
*
*  IF SY-SUBRC <> 0.
*    PV_CHK = ABAP_TRUE.
*  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& FORM SAVE_DATA
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
*& -->  P1        TEXT
*& <--  P2        TEXT
*&---------------------------------------------------------------------*
FORM SAVE_DATA .

  DATA :
    HEADDATA    LIKE  BAPIMATHEAD,
    CLIENTDATA  LIKE  BAPI_MARA,
    CLIENTDATAX LIKE  BAPI_MARAX,
    PLANTDATA   LIKE  BAPI_MARC,
    PLANTDATAX  LIKE  BAPI_MARCX.

**  DATA(LT_LIST) = GT_LIST[].
**  DELETE LT_LIST WHERE STATUS IS INITIAL.
*
*  LOOP AT GT_LIST INTO DATA(LS_LIST) WHERE STATUS IS NOT INITIAL .
*     CLEAR : HEADDATA, CLIENTDATA, CLIENTDATAX, PLANTDATA, PLANTDATAX.
**HEADER
*     HEADDATA-MATERIAL = LS_LIST-MATNR.
**CLIENT
*     CLIENTDATA-PUR_VALKEY   = COND #( WHEN RB_RCV = ZGTFI_X THEN LS_LIST-EKWSL ELSE '' ).
*     CLIENTDATAX-PUR_VALKEY = COND #( WHEN RB_RCV = ZGTFI_X THEN ZGTFI_X ELSE '' ).
**PLANT
*     PLANTDATA = VALUE #(
*                           PLANT            = PA_WERKS
*                           PUR_GROUP   = COND #( WHEN RB_RCV = ZGTFI_X THEN LS_LIST-EKGRP ELSE '' )
*                           MRP_TYPE      = COND #( WHEN RB_MNG = ZGTFI_X THEN LS_LIST-DISMM ELSE '' )
*                           PLND_DELRY  = COND #( WHEN RB_MNG = ZGTFI_X THEN LS_LIST-PLIFZ ELSE '' )
*                           GR_PR_TIME   = COND #( WHEN RB_RCV = ZGTFI_X THEN LS_LIST-WEBAZ ELSE '' )
*                           LOTSIZEKEY   = COND #( WHEN RB_MNG = ZGTFI_X THEN LS_LIST-DISLS ELSE '' )
*                           REORDER_PT  = COND #( WHEN RB_MNG = ZGTFI_X THEN LS_LIST-MINBE ELSE '' )
*                           SAFETY_STK   = COND #( WHEN RB_MNG = ZGTFI_X THEN LS_LIST-EISBE ELSE '' )
*                           FIXED_LOT      = COND #( WHEN RB_MNG = ZGTFI_X THEN LS_LIST-BSTFE ELSE '' )
*                           SLOC_EXPRC = COND #( WHEN RB_MNG = ZGTFI_X THEN LS_LIST-LGFSB ELSE '' )
*                           SOURCELIST   = COND #( WHEN RB_RCV = ZGTFI_X THEN LS_LIST-KORDB ELSE '' )
*                           IND_POST_TO_INSP_STOCK =
*                           COND #( WHEN RB_QUL = ZGTFI_X THEN LS_LIST-INSMK ELSE '' ) ).
*
*     PLANTDATAX = VALUE #(
*                           PLANT            = PA_WERKS
*                           PUR_GROUP   = COND #( WHEN RB_RCV = ZGTFI_X THEN ZGTFI_X ELSE '' )
*                           MRP_TYPE      = COND #( WHEN RB_MNG = ZGTFI_X THEN ZGTFI_X ELSE '' )
*                           PLND_DELRY  = COND #( WHEN RB_MNG = ZGTFI_X THEN ZGTFI_X ELSE '' )
*                           GR_PR_TIME   = COND #( WHEN RB_RCV = ZGTFI_X THEN ZGTFI_X ELSE '' )
*                           LOTSIZEKEY   = COND #( WHEN RB_MNG = ZGTFI_X THEN ZGTFI_X ELSE '' )
*                           REORDER_PT  = COND #( WHEN RB_MNG = ZGTFI_X THEN ZGTFI_X ELSE '' )
*                           SAFETY_STK   = COND #( WHEN RB_MNG = ZGTFI_X THEN ZGTFI_X ELSE '' )
*                           FIXED_LOT      = COND #( WHEN RB_MNG = ZGTFI_X THEN ZGTFI_X ELSE '' )
*                           SLOC_EXPRC  = COND #( WHEN RB_MNG = ZGTFI_X THEN ZGTFI_X ELSE '' )
*                           SOURCELIST   = COND #( WHEN RB_RCV = ZGTFI_X THEN ZGTFI_X ELSE '' )
*                           IND_POST_TO_INSP_STOCK =
*                           COND #( WHEN RB_QUL = ZGTFI_X THEN ZGTFI_X ELSE '' ) ).
*
**BAPI
*      CALL FUNCTION 'BAPI_MATERIAL_SAVEDATA'
*        EXPORTING
*          HEADDATA                   =  HEADDATA
*         CLIENTDATA                  =  CLIENTDATA
*         CLIENTDATAX                =  CLIENTDATAX
*         PLANTDATA                   =  PLANTDATA
*         PLANTDATAX                 =  PLANTDATAX
*       IMPORTING
*         RETURN                       =  GS_RETURN
*                .
*
*       IF GS_RETURN-TYPE = ZGTFI_S.
*
*         CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
*          EXPORTING
*            WAIT = ZGTFI_X.
*
*          LS_LIST-STATUS    = ICON_LED_GREEN.
*          LS_LIST-MESSAGE = TEXT-M08. "자재 마스터가 변경 되었습니다.
*
*       ELSE.
*          CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
*
*          LS_LIST-STATUS    = ICON_LED_RED.
*          LS_LIST-MESSAGE = GS_RETURN-MESSAGE.
*       ENDIF.
*
*       MODIFY GT_LIST FROM LS_LIST TRANSPORTING STATUS MESSAGE.
*  ENDLOOP.



ENDFORM.
*&---------------------------------------------------------------------*
*& FORM F4_VKBUR
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
*& -->  P1        TEXT
*& <--  P2        TEXT
*&---------------------------------------------------------------------*
FORM F4_VKBUR .

  PERFORM DYNP_VALUES_READ USING 'P_BUKRS'
                        CHANGING  P_BUKRS.

  SET PARAMETER ID 'BUK' FIELD P_BUKRS.

  PERFORM F4IF_FIELD USING 'TVBVK'
                                             'VKBUR'
                                             'H_TVBUR'
                                             'P_VKBUR'.

ENDFORM.
*&---------------------------------------------------------------------*
*& FORM F4_VKGRP
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
*& -->  P1        TEXT
*& <--  P2        TEXT
*&---------------------------------------------------------------------*
FORM F4_VKGRP .

  PERFORM DYNP_VALUES_READ USING 'P_VKBUR'
                                                   CHANGING  P_VKBUR.
  SET PARAMETER ID 'VKB' FIELD P_VKBUR.

  IF P_VKBUR IS INITIAL.
    PERFORM F4IF_FIELD USING 'TVBVK'
                                               'VKGRP'
                                               'H_TVKGR'
                                               'P_VKGRP'.
  ELSE.
    PERFORM F4IF_TABLE USING P_VKBUR
                                                'VKGRP'
                                                'P_VKGRP'.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& FORM DYNP_VALUES_READ
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
*&      --> P_
*&      <-- P_BUKRS
*&---------------------------------------------------------------------*
FORM DYNP_VALUES_READ USING       PV_FNAME
                                           CHANGING PV_FVAL.

  DATA : LT_DYN LIKE DYNPREAD OCCURS 0 WITH HEADER LINE.


  CLEAR : LT_DYN[], PV_FVAL.
  LT_DYN[] = VALUE #( ( FIELDNAME = PV_FNAME ) ).

  CALL FUNCTION 'DYNP_VALUES_READ'
    EXPORTING
      DYNAME               = SY-REPID
      DYNUMB               = SY-DYNNR
    TABLES
      DYNPFIELDS           = LT_DYN
    EXCEPTIONS
      INVALID_ABAPWORKAREA = 1
      INVALID_DYNPROFIELD  = 2
      INVALID_DYNPRONAME   = 3
      INVALID_DYNPRONUMMER = 4
      INVALID_REQUEST      = 5
      NO_FIELDDESCRIPTION  = 6
      INVALID_PARAMETER    = 7
      UNDEFIND_ERROR       = 8
      DOUBLE_CONVERSION    = 9
      STEPL_NOT_FOUND      = 10
      OTHERS               = 11.

  IF SY-SUBRC <> 0.
    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
          WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    EXIT.
  ENDIF.

  PV_FVAL = VALUE #( LT_DYN[ 1 ]-FIELDVALUE OPTIONAL ).

ENDFORM.
*&---------------------------------------------------------------------*
*& FORM F4IF_FIELD
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
*&      --> P_
*&      --> P_
*&      --> P_
*&      --> P_
*&---------------------------------------------------------------------*
FORM F4IF_FIELD USING PV_TNAME
                                     PV_FNAME
                                     PV_SHELP
                                     PV_FIELD.

  CLEAR : GT_RTAB[].

  CALL FUNCTION 'F4IF_FIELD_VALUE_REQUEST'
    EXPORTING
      TABNAME           = CONV TABNAME( PV_TNAME )
      FIELDNAME         = CONV FIELDNAME( PV_FNAME )
      SEARCHHELP        = CONV SHLPNAME( PV_SHELP )
*     SHLPPARAM         = ' '
      DYNPPROG          = SY-REPID
      DYNPNR            = SY-DYNNR
      DYNPROFIELD       = CONV DYNFNAM( PV_FIELD )
*     STEPL             = 0
*     VALUE             = ' '
*     MULTIPLE_CHOICE   = ' '
*     DISPLAY           = ' '
*     SUPPRESS_RECORDLIST       = ' '
*     CALLBACK_PROGRAM  = ' '
*     CALLBACK_FORM     = ' '
*     CALLBACK_METHOD   =
*     SELECTION_SCREEN  = ' '
*   IMPORTING
*     USER_RESET        =
    TABLES
      RETURN_TAB        = GT_RTAB
    EXCEPTIONS
      FIELD_NOT_FOUND   = 1
      NO_HELP_FOR_FIELD = 2
      INCONSISTENT_HELP = 3
      NO_VALUES_FOUND   = 4
      OTHERS            = 5.

ENDFORM.
*&---------------------------------------------------------------------*
*& FORM F4IF_FIELD
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
*&      --> P_
*&      --> P_
*&      --> P_
*&      --> P_
*&---------------------------------------------------------------------*
FORM F4IF_TABLE USING PV_VKBUR
                                       PV_VKGRP
                                       PV_FIELD.

* F4 도움말 필드 속성 정의
  DATA : LT_FIELDS TYPE TABLE OF DFIES,
         LS_FIELD  LIKE LINE OF LT_FIELDS.
  DATA : LT_RETURN TYPE STANDARD TABLE OF DDSHRETVAL.
  DATA: BEGIN OF LT_DATA OCCURS 0,
          VALUE TYPE C LENGTH 30,
        END OF LT_DATA.

  SELECT FROM TVBVK AS A  INNER JOIN TVGRT AS B
         ON A~VKGRP EQ B~VKGRP
         FIELDS A~VKBUR, B~VKGRP, B~BEZEI
         WHERE A~VKBUR EQ @PV_VKBUR
              AND B~SPRAS EQ @GC_3
         INTO TABLE @GT_VKGRP.

  IF GT_VKGRP[] IS NOT INITIAL.

    LT_FIELDS = VALUE #(  ( FIELDNAME = 'VKBUR'
                                      INTTYPE = 'C'
                                      INTLEN = 8
                                      LENG = 8
                                      OUTPUTLEN = 8
                                      REPTEXT = '영업팀' )
                                      ( FIELDNAME = 'VKGRP'
                                      INTTYPE = 'C'
                                      INTLEN = 8
                                      LENG = 8
                                      OUTPUTLEN = 8
                                      REPTEXT = '영업그룹' )
                                      ( FIELDNAME = 'BEZEI'
                                      INTTYPE = 'C'
                                      INTLEN = 20
                                      LENG = 20
                                      OUTPUTLEN = 20
                                      REPTEXT = '영업그룹명' ) ).

    LOOP AT GT_VKGRP ASSIGNING FIELD-SYMBOL(<FS>).
      APPEND VALUE #( VALUE = <FS>-VKBUR ) TO LT_DATA.
      APPEND VALUE #( VALUE = <FS>-VKGRP ) TO LT_DATA.
      APPEND VALUE #( VALUE = <FS>-BEZEI ) TO LT_DATA.
    ENDLOOP.

    CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
      EXPORTING
        RETFIELD     = 'VKGRP'
        WINDOW_TITLE = '영업그룹'
*       DYNPROFIELD  = 'P_VKGRP'
*       VALUE_ORG    = 'C'
      TABLES
        VALUE_TAB    = LT_DATA
        FIELD_TAB    = LT_FIELDS
        RETURN_TAB   = LT_RETURN.
    IF SY-SUBRC <> 0.
      MESSAGE S000 WITH '조건에 맞는 영업그룹 정보가 없습니다.'(e02) DISPLAY LIKE GC_E.
    ENDIF.

    READ TABLE LT_RETURN INTO DATA(LS_RETURN) INDEX 1.
    IF SY-SUBRC = 0.
      P_VKGRP = LS_RETURN-FIELDVAL.
    ENDIF.

  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*& FORM GET_SELECTED_ROWS
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
*&      --> GR_GRID
*&      --> P_
*&      --> P_
*&      --> P_
*&---------------------------------------------------------------------*
FORM GET_SELECTED_ROWS USING PR_GRID TYPE REF TO CL_GUI_ALV_GRID
                                                        PV_MODE  "한라인씩 처리 가능:S(SINGLE), 여러 라인 가능:M(MULTI)
                                                        PV_CHK     "선택 라인 없는 경우 에러 처리: X
                                                        PV_MSG.   "별도 지정된 메시지 보여줘야 할때 입력

  CLEAR : GT_ROWS, GS_ROW, GV_ERR.

  CALL METHOD PR_GRID->GET_SELECTED_ROWS
    IMPORTING
      ET_INDEX_ROWS = GT_ROWS.

  DESCRIBE TABLE GT_ROWS.

  CASE SY-TFILL.
    WHEN 0.
      IF PV_CHK = GC_X. "에러 처리
        GV_ERR = GC_X.

        IF PV_MSG IS  INITIAL.
          MESSAGE S004 DISPLAY LIKE 'E'. "라인을 선택하세요.
        ELSE.
          MESSAGE S000 DISPLAY LIKE 'E' WITH PV_MSG.
        ENDIF.
      ENDIF.

    WHEN 1.
      IF PV_MODE = GC_S. "한 라인 씩만 처리 가능 모드
        READ TABLE GT_ROWS INTO GS_ROW INDEX 1.
      ENDIF.

    WHEN OTHERS.
      IF PV_MODE = GC_S. "한 라인 씩만 처리 가능 모드
        GV_ERR = GC_X.
        MESSAGE S005 DISPLAY LIKE 'E'. "하나의 라인만 선택 가능합니다.
      ENDIF.
  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& FORM SET_LIST_SAVE
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
*& -->  P1        TEXT
*& <--  P2        TEXT
*&---------------------------------------------------------------------*
FORM SET_LIST_SAVE USING PV_MODE. "RC:접수,RJ:반려,RN:반려사유

  DATA : LT_4411   LIKE TABLE OF ZGTMMT4411,
         LT_4412   LIKE TABLE OF ZGTMMT4412,
         LT_SAVE_A LIKE TABLE OF ZGTMMT4411,
         LT_SAVE_B LIKE TABLE OF ZGTMMT4412,
         LV_STAT   TYPE ZGTMMT4411-ZMM_STAT,
         LV_RJCD   TYPE ZGTMMT4411-REJ_CODE,
         LV_SUBRC  TYPE SY-SUBRC, "접수상태(4411/4412) UPDATE 결과
         LV_MSG    TYPE STRING.

  DATA:
    LV_CHECK       TYPE C LENGTH 1,
    LO_RECEIVER    TYPE REF TO IF_RECIPIENT_BCS,
    LO_EMAIL       TYPE REF TO CL_BCS,
    LO_EMAIL_BODY  TYPE REF TO CL_DOCUMENT_BCS,
    LX_EXCEPTION   TYPE REF TO CX_BCS,
    LV_SEND_RESULT TYPE C.

  DATA:
    LV_EMAIL     TYPE AD_SMTPADR,
    LV_HEAD_TEXT TYPE SO_OBJ_DES.

  DATA : BEGIN OF LS_LIST_M,
           WERKS     TYPE ZGTMM_CV_GET_DDINFO-WERKS, "메일 제목 구분(AT NEW LIFNR 상위 키)
           LIFNR     TYPE ZGTMM_CV_GET_DDINFO-LIFNR,
           ZREQ_NAME TYPE ZGTMM_CV_GET_DDINFO-ZREQ_NAME,
           VBELN     TYPE ZGTMM_CV_GET_DDINFO-VBELN,
           POSNR     TYPE ZGTMM_CV_GET_DDINFO-POSNR,
           MATNR     TYPE ZGTMM_CV_GET_DDINFO-MATNR,
           MAKTX     TYPE ZGTMM_CV_GET_DDINFO-MAKTX,
           COLOR     TYPE ZGTMM_CV_GET_DDINFO-COLOR,
           LENGTH    TYPE ZGTMM_CV_GET_DDINFO-LENGTH,
           AR_DATE   TYPE ZGTMM_CV_GET_DDINFO-AR_DATE,
           DEST1     TYPE ZGTMM_CV_GET_DDINFO-DEST1,
           SITE_TEL  TYPE ZGTMM_CV_GET_DDINFO-SITE_TEL,
           SITE_NAME TYPE ZGTMM_CV_GET_DDINFO-SITE_NAME,
           CUST_TEL  TYPE ZGTMM_CV_GET_DDINFO-CUST_TEL,
           CUST_NAME TYPE ZGTMM_CV_GET_DDINFO-CUST_NAME,
           REQ_DRQTY TYPE ZGTMM_CV_GET_DDINFO-REQ_DRQTY,
           SP_NOTE   TYPE ZGTMM_CV_GET_DDINFO-SP_NOTE,
         END OF LS_LIST_M.

  CLEAR : GV_ERR, LV_STAT, LV_RJCD, GT_LIST_M. "메일 대상은 이번 처리분만
  SORT GT_HEAD BY CHECK.
*접수상태
  LV_STAT = COND #( WHEN PV_MODE = 'RC' THEN GC_A
                                 WHEN PV_MODE = 'RJ' OR PV_MODE = 'RN' OR PV_MODE = 'RJT'
                                 THEN GC_R  ELSE '' ).

  CASE PV_MODE.
    WHEN 'RC' OR 'RJ' OR 'RN'.    "의뢰접수-접수/반려/반려사유등록&반려

      LOOP AT GT_LIST ASSIGNING FIELD-SYMBOL(<FS>) WHERE CHECK = GC_X.
*접수상태_ALV UPDATE.접수:'A' 반려:'R'.
        CHECK <FS> IS ASSIGNED.
        <FS>-ZMM_STAT = LV_STAT.
        CLEAR LV_SUBRC.


        "반려사유
        LV_RJCD = COND #( WHEN ( PV_MODE = 'RN' )  THEN GV_REASON
                                       WHEN ( PV_MODE = 'RJ' )  THEN <FS>-REJ_CODE
                                       ELSE  '' ).

        IF PV_MODE = 'RC'.
          CLEAR : LS_LIST_M .
          LS_LIST_M = CORRESPONDING #( <FS> ).
          APPEND LS_LIST_M  TO GT_LIST_M.
        ENDIF.

*접수상태/TIMESTAMP_ZGTMMT4411/4412 UPDATE
        IF <FS>-ZREQ_TYPE = GC_A.
          UPDATE ZGTMMT4411
                SET ZMM_STAT = @LV_STAT,
                       ZMM_DATE = @SY-DATLO,
                       REJ_CODE  = @LV_RJCD,
                       AEDAT = @SY-DATUM,
                       AEDAT_LOCAL = @SY-DATLO,
                       AETIM = @SY-UZEIT,
                       AETIM_LOCAL = @SY-TIMLO,
                       AENAM = @SY-UNAME
           WHERE BUKRS = @<FS>-BUKRS
                AND DLVRQ = @<FS>-DLVRQ
                AND VBELN = @<FS>-VBELN
                AND POSNR = @<FS>-POSNR
                AND EBELN = @<FS>-EBELN
                AND EBELP = @<FS>-EBELP.
**--> 26.09 CHECK는 루프 다음 행으로 건너뛰어 접수(RC) 시 COMMIT/오류판정이 누락됨
          LV_SUBRC = SY-SUBRC.
*          CHECK LV_STAT = GC_R.
          IF LV_STAT = GC_R. "반려일 때만 ZLET0401 삭제표시
            UPDATE ZLET0401
                  SET LVORM = GC_X
             WHERE DLVRQ = <FS>-DLVRQ
                  AND VBELN = <FS>-VBELN
                  AND POSNR = <FS>-POSNR.
          ENDIF.
**--< 26.09
        ENDIF.

        IF <FS>-ZREQ_TYPE = GC_B.
          UPDATE ZGTMMT4412
                SET ZMM_STAT = @LV_STAT,
                       ZMM_DATE = @SY-DATLO,
                       REJ_CODE  = @LV_RJCD,
                       AEDAT = @SY-DATUM,
                       AEDAT_LOCAL = @SY-DATLO,
                       AETIM = @SY-UZEIT,
                       AETIM_LOCAL = @SY-TIMLO,
                       AENAM = @SY-UNAME
           WHERE BUKRS = @<FS>-BUKRS
                AND DLVRQ = @<FS>-DLVRQ
                AND VBELN = @<FS>-VBELN
                AND POSNR = @<FS>-POSNR.
**--> 26.09 CHECK는 루프 다음 행으로 건너뛰어 접수(RC) 시 COMMIT/오류판정이 누락됨
          LV_SUBRC = SY-SUBRC.
*          CHECK LV_STAT = GC_R.
          IF LV_STAT = GC_R. "반려일 때만 ZLET0401 삭제표시
            UPDATE ZLET0401
                  SET LVORM = GC_X
             WHERE DLVRQ = <FS>-DLVRQ
                  AND VBELN = <FS>-VBELN
                  AND POSNR = <FS>-POSNR.
          ENDIF.
**--< 26.09
        ENDIF.

**--> 26.09 접수상태 UPDATE 결과로 판정 (ZLET0401 미존재는 오류 아님)
*        IF SY-SUBRC = 0.
        IF LV_SUBRC = 0.
**--< 26.09
          COMMIT WORK AND WAIT .
        ELSE.
          GV_ERR = GC_X.
        ENDIF.


        CLEAR LV_RJCD.
      ENDLOOP.

      IF GV_ERR <> GC_X AND PV_MODE = 'RC'.

**--> 26.09 플랜트 조건 변경
*        IF P_WERKS = '6500'.
*          LV_HEAD_TEXT = '(전력)' && '가온전선 직송 요청 문의드립니다.'(m24).
*        ELSEIF P_WERKS = '6600'.
*          LV_HEAD_TEXT = '(통신)' && '가온전선 직송 요청 문의드립니다.'(m24).
*        ENDIF.
        "메일 제목은 플랜트+공급업체 단위로 각 라인의 플랜트 기준 설정(AT NEW LIFNR 내부)
**--< 26.09 플랜트 조건 변경


        DATA:
          LV_LINE TYPE SO_TEXT255,
          LT_BODY TYPE BCSY_TEXT.

        SORT GT_LIST_M BY WERKS LIFNR VBELN POSNR MATNR COLOR LENGTH.

*    LOOP AT GT_LIST_M ASSIGNING FIELD-SYMBOL(<FS_M>) .
        LOOP AT GT_LIST_M INTO DATA(GS_LIST_M).
          AT NEW LIFNR.
**--> 26.09 플랜트 조건 변경
            CLEAR LV_HEAD_TEXT.
            IF GS_LIST_M-WERKS = '6500'.
              LV_HEAD_TEXT = '(전력)' && '가온전선 직송 요청 문의드립니다.'(m24).
            ELSEIF GS_LIST_M-WERKS = '6600'.
              LV_HEAD_TEXT = '(통신)' && '가온전선 직송 요청 문의드립니다.'(m24).
            ENDIF.
**--< 26.09 플랜트 조건 변경
            LV_LINE = |<html><body style="font-size:14">|.
            LT_BODY = VALUE #( BASE LT_BODY ( LINE = LV_LINE ) ).
            LV_LINE = |<p>{ TEXT-EM1 }</p>|.

            LT_BODY = VALUE #( BASE LT_BODY ( LINE = LV_LINE ) ).
            LV_LINE = |<p>안녕하세요.</p>|.
            LT_BODY = VALUE #( BASE LT_BODY ( LINE = LV_LINE ) ).
            LV_LINE = |<p>가온전선입니다.</p>|.
            LT_BODY = VALUE #( BASE LT_BODY ( LINE = LV_LINE ) ).
            LV_LINE = |<p>아래와 같이 가온전선에서 발주 중인 품목 직송을 문의드립니다</p>|.
            LT_BODY = VALUE #( BASE LT_BODY ( LINE = LV_LINE ) ).

            LV_LINE = |<table border=1 STYLE="border-collapse: collapse;border-color: #000000;font-size:11:width:1000px" >|.
            LT_BODY = VALUE #( BASE LT_BODY ( LINE = LV_LINE ) ).

            LV_LINE = |<tr align="center" style="background-color: #ADD8E6;height : 50px;" ><td width="100px"><strong>판매오더</strong></td>|.
            LT_BODY = VALUE #( BASE LT_BODY ( LINE = LV_LINE ) ).
            LV_LINE = |<td width="50px" ><strong>항번</strong></td>|.
            LT_BODY = VALUE #( BASE LT_BODY ( LINE = LV_LINE ) ).
            LV_LINE = |<td width="400px" ><strong>품명</strong></td>|.
            LT_BODY = VALUE #( BASE LT_BODY ( LINE = LV_LINE ) ).
            LV_LINE = |<td width="50px" ><strong>색상</strong></td>|.
            LT_BODY = VALUE #( BASE LT_BODY ( LINE = LV_LINE ) ).
            LV_LINE = |<td width="100px" ><strong>조장</strong></td>|.
            LT_BODY = VALUE #( BASE LT_BODY ( LINE = LV_LINE ) ).
            LV_LINE = |<td width="100px" ><strong>직송요청수량</strong></td>|.
            LT_BODY = VALUE #( BASE LT_BODY ( LINE = LV_LINE ) ).
            LV_LINE = |<td width="100px" ><strong>도착요청일</strong></td>|.
            LT_BODY = VALUE #( BASE LT_BODY ( LINE = LV_LINE ) ).
          ENDAT.

          LV_LINE = |<tr><td align="center" >{ GS_LIST_M-VBELN  ALPHA = OUT }</td>|.
          LT_BODY = VALUE #( BASE LT_BODY ( LINE = LV_LINE ) ).
          LV_LINE = |<td align="center" >{ GS_LIST_M-POSNR ALPHA = OUT }</td>|.
          LT_BODY = VALUE #( BASE LT_BODY ( LINE = LV_LINE ) ).
          LV_LINE = |<td align="center" >{ GS_LIST_M-MAKTX ALPHA = OUT }</td>|.
          LT_BODY = VALUE #( BASE LT_BODY ( LINE = LV_LINE ) ).
          LV_LINE = |<td align="center" >{ GS_LIST_M-COLOR ALPHA = OUT }</td>|.
          LT_BODY = VALUE #( BASE LT_BODY ( LINE = LV_LINE ) ).
          LV_LINE = |<td align="center" >{ GS_LIST_M-LENGTH ALPHA = OUT }</td>|.
          LT_BODY = VALUE #( BASE LT_BODY ( LINE = LV_LINE ) ).
          LV_LINE = |<td align="center" >{ GS_LIST_M-REQ_DRQTY  }</td>|.
          LT_BODY = VALUE #( BASE LT_BODY ( LINE = LV_LINE ) ).
          LV_LINE = |<td align="center" >{ GS_LIST_M-AR_DATE }</td>|.
          LT_BODY = VALUE #( BASE LT_BODY ( LINE = LV_LINE ) ).
          LV_LINE = |<tr><td colspan="7" style="font-size: 15px;height: 100px;">{ '   납지 : ' && GS_LIST_M-DEST1  &&  '/' && GS_LIST_M-CUST_TEL && '/' && GS_LIST_M-CUST_NAME } <Br>{ '   현장담당자 연락처 : ' && GS_LIST_M-SITE_TEL   }</BR> </td>|.
          LT_BODY = VALUE #( BASE LT_BODY ( LINE = LV_LINE ) ).
          LV_LINE = |<tr style="background-color: #DCDCDC;height : 50px;"><td colspan="7" style="font-size: 15px;height: 100px;">{ '   특기사항 : '  && GS_LIST_M-SP_NOTE  }</td>|.
          LT_BODY = VALUE #( BASE LT_BODY ( LINE = LV_LINE ) ).
          AT END OF LIFNR.

            LV_LINE = |</table></body></html>|.
            LT_BODY = VALUE #( BASE LT_BODY ( LINE = LV_LINE ) ).

            SELECT  EMAIL
            FROM ZGTMMT1023
            WHERE LIFNR = @GS_LIST_M-LIFNR
            INTO TABLE @DATA(LT_EMAIL_T).

            LOOP AT LT_EMAIL_T ASSIGNING FIELD-SYMBOL(<MAIL>).

              CLEAR : LV_EMAIL.
              LV_EMAIL =  <MAIL>-EMAIL..

              TRY.
                  LO_EMAIL = CL_BCS=>CREATE_PERSISTENT( ).

                  LO_EMAIL_BODY = CL_DOCUMENT_BCS=>CREATE_DOCUMENT(
                                  I_TYPE    = 'HTM'
                                  I_TEXT    = LT_BODY
                                  I_SUBJECT = LV_HEAD_TEXT ).

                  LO_EMAIL->SET_DOCUMENT( LO_EMAIL_BODY ).

                  LO_RECEIVER =
                  CL_CAM_ADDRESS_BCS=>CREATE_INTERNET_ADDRESS( LV_EMAIL ).

                  LO_EMAIL->ADD_RECIPIENT( I_RECIPIENT = LO_RECEIVER
                                           I_EXPRESS = 'X' ).

                  LO_EMAIL->SET_SEND_IMMEDIATELY( 'X' ).

                  LO_EMAIL->SEND( EXPORTING I_WITH_ERROR_SCREEN = 'X'
                                  RECEIVING RESULT = LV_SEND_RESULT ).
                CATCH CX_BCS INTO LX_EXCEPTION.
                  LV_CHECK = GC_E.
              ENDTRY.
              COMMIT WORK AND WAIT.
              CLEAR : LV_CHECK,    LO_RECEIVER ,  LO_EMAIL ,  LO_EMAIL_BODY ,  LX_EXCEPTION  ,    LV_SEND_RESULT.

              CLEAR  :  LV_MSG , LV_EMAIL.
            ENDLOOP.
            CLEAR : LT_BODY. "본문은 해당 업체 수신자 전원 발송 후 초기화
          ENDAT.

        ENDLOOP.

      ENDIF.
    WHEN 'RJT'.   "의뢰관리-반려

      READ TABLE GT_HEAD ASSIGNING FIELD-SYMBOL(<FS2>)
      WITH KEY CHECK = GC_X BINARY SEARCH.

      IF SY-SUBRC = 0.

        LOOP AT GT_ITEM ASSIGNING FIELD-SYMBOL(<ITEM>) WHERE CHECK = GC_X.
          CHECK <ITEM> IS ASSIGNED.
*접수상태_ALV UPDATE.접수:'A' 반려:'R'.
          <ITEM>-ZMM_STAT = LV_STAT.

          "반려사유
          LV_RJCD = COND #( WHEN ( PV_MODE = 'RN' OR PV_MODE = 'RJT' )
                                         THEN GV_REASON ELSE <ITEM>-REJ_CODE ).

*접수상태/TIMESTAMP_ZGTMMT4411/4412 UPDATE
          IF <FS2>-ZREQ_TYPE = GC_A.
            UPDATE ZGTMMT4411
                  SET ZMM_STAT = @LV_STAT,
                         ZMM_DATE = @SY-DATLO,
                         REJ_CODE  = @LV_RJCD,
                         AEDAT = @SY-DATUM,
                         AEDAT_LOCAL = @SY-DATLO,
                         AETIM = @SY-UZEIT,
                         AETIM_LOCAL = @SY-TIMLO,
                         AENAM = @SY-UNAME
             WHERE BUKRS = @<ITEM>-BUKRS
                  AND DLVRQ = @<ITEM>-DLVRQ
                  AND VBELN = @<ITEM>-VBELN
                  AND POSNR = @<ITEM>-POSNR
                  AND EBELN = @<ITEM>-EBELN
                  AND EBELP = @<ITEM>-EBELP.

            CHECK LV_STAT = GC_R.
            UPDATE ZLET0401
                  SET LVORM = GC_X
             WHERE DLVRQ = <ITEM>-DLVRQ
                  AND VBELN = <ITEM>-VBELN
                  AND POSNR = <ITEM>-POSNR.
          ENDIF.

          IF <FS2>-ZREQ_TYPE = GC_B.
            UPDATE ZGTMMT4412
                  SET ZMM_STAT = @LV_STAT,
                         ZMM_DATE = @SY-DATLO,
                         REJ_CODE  = @LV_RJCD,
                         AEDAT = @SY-DATUM,
                         AEDAT_LOCAL = @SY-DATLO,
                         AETIM = @SY-UZEIT,
                         AETIM_LOCAL = @SY-TIMLO,
                         AENAM = @SY-UNAME
             WHERE BUKRS = @<ITEM>-BUKRS
                  AND DLVRQ = @<ITEM>-DLVRQ
                  AND VBELN = @<ITEM>-VBELN
                  AND POSNR = @<ITEM>-POSNR.

            CHECK LV_STAT = GC_R.
            UPDATE ZLET0401
                  SET LVORM = GC_X
             WHERE DLVRQ = <ITEM>-DLVRQ
                  AND VBELN = <ITEM>-VBELN
                  AND POSNR = <ITEM>-POSNR.
          ENDIF.

          IF SY-SUBRC = 0.
            COMMIT WORK AND WAIT .
            MESSAGE S000 WITH '반려되었습니다'(m16) DISPLAY LIKE GC_S.
          ELSE.
            GV_ERR = GC_X.
          ENDIF.

          CLEAR LV_RJCD.
        ENDLOOP.

      ENDIF.

    WHEN OTHERS.
  ENDCASE.

*  CASE PV_MODE.
*    WHEN 'RC' OR 'RJ' OR 'RN'.    "의뢰접수-접수/반려/반려사유등록&반려
*      DATA(LT_DATA_A) = GT_LIST[].
*      DELETE LT_DATA_A WHERE CHECK IS INITIAL.
*      DELETE LT_DATA_A WHERE ZREQ_TYPE = 'B'.
*
*      IF LT_DATA_A[] IS NOT INITIAL.
*        SELECT FROM ZGTMMT4411
*        FIELDS *
*        FOR ALL ENTRIES IN @LT_DATA_A
*        WHERE BUKRS = @LT_DATA_A-BUKRS
*           AND DLVRQ = @LT_DATA_A-DLVRQ
*           AND VBELN = @LT_DATA_A-VBELN
*           AND POSNR = @LT_DATA_A-POSNR
*           AND EBELN = @LT_DATA_A-EBELN
*           AND EBELP = @LT_DATA_A-EBELP
*           INTO TABLE @LT_4411.
*      ENDIF.
*
*      DATA(LT_DATA_B) = GT_LIST[].
*      DELETE LT_DATA_B WHERE CHECK IS INITIAL.
*      DELETE LT_DATA_B WHERE ZREQ_TYPE = 'A'.
*
*      IF LT_DATA_B[] IS NOT INITIAL.
*        SELECT FROM ZGTMMT4412
*        FIELDS *
*        FOR ALL ENTRIES IN @LT_DATA_B
*        WHERE BUKRS = @LT_DATA_B-BUKRS
*           AND DLVRQ = @LT_DATA_B-DLVRQ
*           AND VBELN = @LT_DATA_A-VBELN
*           AND POSNR = @LT_DATA_B-POSNR
*           INTO TABLE @LT_4412.
*      ENDIF.
*
*    WHEN 'RJT'.   "의뢰관리-접수취소
*      DATA(LT_DATA2) = GT_ITEM[].
*      DELETE LT_DATA2 WHERE CHECK IS INITIAL.
*
*      IF LT_DATA2[] IS NOT INITIAL.
*        SELECT FROM ZGTMMT4411
*        FIELDS *
*        FOR ALL ENTRIES IN @LT_DATA2
*        WHERE BUKRS = @LT_DATA2-BUKRS
*           AND DLVRQ = @LT_DATA2-DLVRQ
*           AND VBELN = @LT_DATA2-VBELN
*           AND POSNR = @LT_DATA2-POSNR
*           AND EBELN = @LT_DATA2-EBELN
*           AND EBELP = @LT_DATA2-EBELP
*           INTO TABLE @LT_4411.
*      ENDIF.
*
*    WHEN OTHERS.
*  ENDCASE.
*
*    CLEAR : LV_MSG.
***UNIQUE INDEX(GUID/UUID) CREATE_선택된 라인 별 동일그룹으로 관리
**       TRY.
**           DATA(LV_GUID_32) = CL_SYSTEM_UUID=>CREATE_UUID_C32_STATIC( ).
**
**        CATCH  CX_UUID_ERROR INTO DATA(LV_ERROR).
**            LV_MSG = LV_ERROR->GET_TEXT(  ).
**            MESSAGE S000 WITH LV_MSG DISPLAY LIKE GC_E.
**            EXIT.
**       ENDTRY.
*
**ZGTMMT4411 저장
*    LT_SAVE = VALUE #( BASE LT_SAVE FOR WA IN LT_4411
*                                 ( VALUE #( BASE CORRESPONDING #( WA )
**                                    ZGUID = LV_GUID_32
*                                    ZMM_STAT = COND #( WHEN PV_MODE = 'RC' THEN GC_A
*                                                                      WHEN PV_MODE = 'RJ' OR PV_MODE = 'RN'
*                                                                                OR PV_MODE = 'RJT'
*                                                                      THEN GC_R  ELSE '' )
*                                    ZMM_DATE = SY-DATLO
*                                    REJ_CODE  = COND #( WHEN ( PV_MODE = 'RN' OR PV_MODE = 'RJT' )
*                                                                       THEN GV_REASON ELSE WA-REJ_CODE )
*                                    AEDAT = SY-DATUM
*                                    AEDAT_LOCAL = SY-DATLO
*                                    AETIM = SY-UZEIT
*                                    AETIM_LOCAL = SY-TIMLO
*                                    AENAM = SY-UNAME ) ) ).
*
*    IF LT_SAVE_A[] IS NOT INITIAL.
*      CLEAR LV_MSG.
*      TRY.
*          MODIFY  ZGTMMT4411 FROM TABLE LT_SAVE_A.
*
*        CATCH CX_ROOT INTO DATA(LV_ERR).
*          LV_MSG = LV_ERR->GET_TEXT(  ).
*          MESSAGE S000 WITH LV_MSG DISPLAY LIKE GC_E.
*          EXIT.
*      ENDTRY.
*
**ALV UPDATE_접수:'A' 반려:'R'.
*      LOOP AT LT_SAVE_A ASSIGNING FIELD-SYMBOL(<FS>).
**      "의뢰관리-반려
*         IF PV_MODE = 'RJT'.
*
*           READ TABLE GT_ITEM INTO DATA(LS_IT)
*           WITH KEY  BUKRS = <FS>-BUKRS
*                           DLVRQ = <FS>-DLVRQ
*                           VBELN = <FS>-VBELN
*                           POSNR = <FS>-POSNR
*                           EBELN = <FS>-EBELN
*                           EBELP = <FS>-EBELP BINARY SEARCH.
*
*           IF SY-SUBRC = 0.
*             DATA(LV_TABIX) = SY-TABIX.
*             LS_IT-ZMM_STAT = GC_R.
*
*             MODIFY GT_ITEM FROM LS_IT INDEX LV_TABIX TRANSPORTING ZMM_STAT.
*           ENDIF.
*
*         ELSE  .
**      "의뢰접수-접수/반려/반려사유
*           READ TABLE GT_LIST INTO DATA(LS_LIST)
*           WITH KEY  BUKRS = <FS>-BUKRS
*                           DLVRQ = <FS>-DLVRQ
*                           VBELN = <FS>-VBELN
*                           POSNR = <FS>-POSNR
*                           EBELN = <FS>-EBELN
*                           EBELP = <FS>-EBELP BINARY SEARCH.
*
*           IF SY-SUBRC = 0.
*             LV_TABIX = SY-TABIX.
*             LS_LIST-ZMM_STAT = COND #( WHEN PV_MODE = 'RC' THEN GC_A
*                                                             WHEN PV_MODE = 'RJ' OR PV_MODE = 'RN'
*                                                             THEN GC_R  ELSE '' ).
*             MODIFY GT_LIST FROM LS_LIST INDEX LV_TABIX TRANSPORTING ZMM_STAT.
*           ENDIF.
*         ENDIF.
*
*         CLEAR : LV_TABIX, LS_IT, LS_LIST.
*      ENDLOOP.
*    ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& FORM DATA_CANCEL
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
*& -->  P1        TEXT
*& <--  P2        TEXT
*&---------------------------------------------------------------------*
FORM DATA_CANCEL .

  DATA : LV_DATE TYPE DATUM,
         LV_MSG  TYPE BAPI_MSG.
  CLEAR : LV_DATE, GV_ANSWER.
  CLEAR : GV_ERR.

*  PERFORM GET_SELECTED_ROWS USING GCL_GRID_IT 'M' GV_ERR LV_MSG.


  IF LINE_EXISTS( GT_ITEM[ CHECK = GC_X  ] ).


    IF LINE_EXISTS( GT_ITEM[ CHECK = GC_X  ZVD_STAT = 'A' ] ).
      MESSAGE S000 WITH '선택된 항목은 접수 취소 할 수 없습니다.'(m17) DISPLAY LIKE GC_E.
      GV_ERR = GC_X.
    ELSEIF LINE_EXISTS( GT_ITEM[ CHECK = GC_X  ZMM_STAT = '' ] ).
      MESSAGE S000 WITH '선택된 항목은 접수 취소 할 수 없습니다.'(m17) DISPLAY LIKE GC_E.
      GV_ERR = GC_X.
    ELSEIF LINE_EXISTS( GT_ITEM[ CHECK = GC_X  ZMM_STAT = 'R' ] ).
      MESSAGE S000 WITH '선택된 항목은 접수 취소 할 수 없습니다.'(m17) DISPLAY LIKE GC_E.
      GV_ERR = GC_X.

    ELSEIF   LINE_EXISTS( GT_ITEM[ CHECK = GC_X LOADSTATUS = 'A' ] ).
      MESSAGE S000 WITH '선택된 항목은 접수 취소 할 수 없습니다.'(m17) DISPLAY LIKE GC_E.
      GV_ERR = GC_X.

    ENDIF.

  ELSE.
    MESSAGE S000 WITH '접수 취소 대상을 선택하세요.'(m13) DISPLAY LIKE GC_E.
    GV_ERR = GC_X.
  ENDIF.

  CHECK GV_ERR IS INITIAL.
  PERFORM POPUP_TO_CONFIRM_STEP  USING 'N' TEXT-M12 '' TEXT-M09.
  CHECK GV_ANSWER = GC_J.
  SORT GT_HEAD BY CHECK DLVRQ.

  READ TABLE GT_HEAD ASSIGNING FIELD-SYMBOL(<FS>)
  WITH KEY CHECK = GC_X.
  CHECK <FS> IS ASSIGNED.

  LOOP AT GT_ITEM INTO DATA(LS_ITEM) WHERE CHECK = GC_X.

    CASE <FS>-ZREQ_TYPE.
      WHEN GC_A.

        UPDATE ZGTMMT4411
        SET ZMM_STAT = ''
               ZMM_DATE = LV_DATE
               REJ_CODE = ''
               AEDAT = SY-DATUM
               AEDAT_LOCAL = SY-DATLO
               AETIM = SY-UZEIT
               AETIM_LOCAL = SY-TIMLO
               AENAM = SY-UNAME
        WHERE BUKRS = LS_ITEM-BUKRS
        AND DLVRQ = LS_ITEM-DLVRQ
        AND VBELN = LS_ITEM-VBELN
        AND POSNR = LS_ITEM-POSNR
        AND EBELN = LS_ITEM-EBELN
        AND EBELP = LS_ITEM-EBELP.

      WHEN GC_B.

        UPDATE ZGTMMT4412
        SET ZMM_STAT = ''
               ZMM_DATE = LV_DATE
               REJ_CODE = ''
               AEDAT = SY-DATUM
               AEDAT_LOCAL = SY-DATLO
               AETIM = SY-UZEIT
               AETIM_LOCAL = SY-TIMLO
               AENAM = SY-UNAME
        WHERE BUKRS = LS_ITEM-BUKRS
        AND DLVRQ = LS_ITEM-DLVRQ
        AND VBELN = LS_ITEM-VBELN
        AND POSNR = LS_ITEM-POSNR.

      WHEN OTHERS.
    ENDCASE.

    IF SY-SUBRC = 0.
      COMMIT WORK AND WAIT .
      MESSAGE S000 WITH '접수 취소되었습니다.'(m23) DISPLAY LIKE GC_S.
    ENDIF.

    CLEAR LS_ITEM.
  ENDLOOP.


  IF GV_ERR IS INITIAL.
    PERFORM GET_DATA.
  ENDIF.

*  IF LINE_EXISTS( GT_ITEM[ CHECK = '' ] ).
*    MESSAGE S000 WITH '접수 취소 대상을 선택하세요.'(M13) DISPLAY LIKE GC_E.
*    EXIT.
*
*  ELSE.
*    PERFORM POPUP_TO_CONFIRM_STEP  USING 'N' TEXT-M12 '' TEXT-M09.
*    CHECK GV_ANSWER = GC_J.
*  ENDIF.

*  LOOP AT GT_ITEM INTO DATA(LS_ITEM) WHERE CHECK = GC_X.
*
*      UPDATE ZGTMMT4411
*            SET ZMM_STAT = ''
*                   ZMM_DATE = LV_DATE
*                   AEDAT = SY-DATUM
*                   AEDAT_LOCAL = SY-DATLO
*                   AETIM = SY-UZEIT
*                   AETIM_LOCAL = SY-TIMLO
*                   AENAM = SY-UNAME
*       WHERE BUKRS = LS_ITEM-BUKRS
*            AND DLVRQ = LS_ITEM-DLVRQ
*            AND VBELN = LS_ITEM-VBELN
*            AND POSNR = LS_ITEM-POSNR
*            AND EBELN = LS_ITEM-EBELN
*            AND EBELP = LS_ITEM-EBELP.
*
*    CLEAR LS_ITEM.
*  ENDLOOP.


ENDFORM.
*&---------------------------------------------------------------------*
*& FORM DATA_REJECT
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
*& -->  P1        TEXT
*& <--  P2        TEXT
*&---------------------------------------------------------------------*
FORM DATA_REJECT .

  CLEAR GV_ANSWER.

  IF LINE_EXISTS( GT_ITEM[ CHECK = GC_X  ] ).


*    IF LINE_EXISTS( GT_ITEM[ CHECK = GC_X   ZVD_STAT = 'A' ] ).
*      MESSAGE S000 WITH '선택된 항목은 반려 할 수 없습니다.'(M18) DISPLAY LIKE GC_E.
*      EXIT.
*    ELSEIF LINE_EXISTS( GT_ITEM[ CHECK = GC_X  ZMM_STAT = '' ] ).
*      MESSAGE S000 WITH '선택된 항목은 반려 할 수 없습니다.'(M18) DISPLAY LIKE GC_E.
*      EXIT.
*    ELSEIF LINE_EXISTS( GT_ITEM[ CHECK = GC_X  ZMM_STAT = 'R' ] ).
*      MESSAGE S000 WITH '선택된 항목은 반려 할 수 없습니다.'(M18) DISPLAY LIKE GC_E.
*      EXIT.
    IF LINE_EXISTS( GT_ITEM[ CHECK = GC_X  ZMM_STAT = 'R' ] ).
      MESSAGE S000 WITH '선택된 항목은 반려 할 수 없습니다.'(m18) DISPLAY LIKE GC_E.
      EXIT.
    ELSEIF   LINE_EXISTS( GT_ITEM[ CHECK = GC_X ZMM_STAT = 'A' ] ).
      MESSAGE S000 WITH '선택된 항목은 반려 할 수 없습니다.'(m18) DISPLAY LIKE GC_E.
      EXIT.
    ELSEIF   LINE_EXISTS( GT_ITEM[ CHECK = GC_X LOADSTATUS = 'A' ] ).
      MESSAGE S000 WITH '선택된 항목은 반려 할 수 없습니다.'(m18) DISPLAY LIKE GC_E.
      EXIT.
    ELSE.
      GV_QUES = '선택된 직송 요청을 반려 하시겠습니까?'(m10).
*반려사유 입력 팝업
      CALL SCREEN 0200  STARTING AT 10 5  ENDING AT 50 10.

      IF GV_QUES IS NOT INITIAL.
        CLEAR GV_QUES.
      ENDIF.
    ENDIF.

  ELSE.
    MESSAGE S000 DISPLAY LIKE 'E' WITH '반려 대상을 선택하세요.'(m11).
    EXIT.

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& FORM DATA_REFRESH
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
*& -->  P1        TEXT
*& <--  P2        TEXT
*&---------------------------------------------------------------------*
FORM DATA_REFRESH.
*접수취소/반려 처리 한 헤더 데이터 기준으로 아이템 데이터 재조회.
  CLEAR : GS_LIST, GS_HEAD.
  READ TABLE GT_HEAD INTO GS_HEAD WITH KEY CHECK = GC_X.

  IF SY-SUBRC = 0.
    "중간 헤더 데이터 영역 재구성(스크린 필드)
    GS_LIST = VALUE #( BLAND        = GS_HEAD-BLAND
                                   BLAND_N    = GS_HEAD-BLAND_N
                                   CITY1          = GS_HEAD-CITY1
                                   DEST1         = GS_HEAD-DEST1
                                   SITE_NAME  = GS_HEAD-SITE_NAME
                                   SITE_TEL     = GS_HEAD-SITE_TEL
                                   CUST_NAME = GS_HEAD-CUST_NAME
                                   CUST_TEL    = GS_HEAD-CUST_TEL
                                   DEST2          = GS_HEAD-DEST2
                                   SP_NOTE     = GS_HEAD-SP_NOTE ).
    "ITEM
    SELECT FROM ZGTMM_CV_DDR_REPORT_I
           FIELDS *
          WHERE BUKRS = @P_BUKRS
              AND DLVRQ = @GS_HEAD-DLVRQ
              INTO TABLE @DATA(LT_ITEM).

    IF LT_ITEM[] IS NOT INITIAL.
      CLEAR : GT_ITEM.
      GT_ITEM[] =  CORRESPONDING #( LT_ITEM[] ).
    ENDIF.
  ENDIF.

*조회조건 기준으로 헤더 데이터 재조회
  SELECT FROM ZGTMM_CV_DDR_REPORT_H
              FIELDS *
             WHERE BUKRS = @P_BUKRS
**--> 26.09 플랜트 조건 변경
*                  AND WERKS = @P_WERKS
                  AND WERKS IN @S_WERKS
                  AND REQDATE BETWEEN @S_DATE-LOW AND @S_DATE-HIGH
                  AND KUNNR IN @S_KUNNR
                 INTO TABLE @DATA(LT_HEAD).

  IF LT_HEAD[] IS NOT INITIAL.
    CLEAR : GT_HEAD.
    GT_HEAD[] = CORRESPONDING #( LT_HEAD[] ).

    SORT GT_HEAD BY DLVRQ.

    READ TABLE GT_HEAD ASSIGNING FIELD-SYMBOL(<FS>)
    WITH KEY DLVRQ = GS_HEAD-DLVRQ BINARY SEARCH.

    IF SY-SUBRC = 0.
      <FS>-CHECK = GC_X.
    ENDIF.

    SORT GT_HEAD BY VKBUR VKGRP KUNNR DEST1 AR_DATE DLVRQ.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& FORM DATA_GI_CHECK
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
*& -->  P1        TEXT
*& <--  P2        TEXT
*&---------------------------------------------------------------------*
FORM DATA_GI_CHECK .

  DATA : LV_MSG TYPE BAPI_MSG.
  CLEAR :GV_ERR, GV_ANSWER.

  IF LINE_EXISTS( GT_HEAD[ CHECK = GC_X ] ).

*  SORT GT_HEAD BY CHECK.
    READ TABLE GT_HEAD ASSIGNING FIELD-SYMBOL(<HD>)
    WITH KEY CHECK = GC_X.

    IF <HD>-CHECKMM = GC_X.
      MESSAGE S000 WITH '출고 확인 대상이 없습니다.'(e11)
      DISPLAY LIKE GC_E .  EXIT.
    ENDIF.

    PERFORM POPUP_TO_CONFIRM_STEP  USING 'N' TEXT-M14 '' TEXT-M09.
    "선택된 직송 건에 대한 출고 확인을 하시겠습니까?
  ELSE.
    MESSAGE S000 WITH '출고 확정 할 데이터를 선택하세요.'(e04) DISPLAY LIKE GC_E.
    EXIT.
  ENDIF.

  CHECK GV_ANSWER = GC_J.

*  SORT GT_HEAD BY CHECK.
*  READ TABLE GT_HEAD ASSIGNING FIELD-SYMBOL(<HD>)
*  WITH KEY CHECK = GC_X.

  IF <HD> IS ASSIGNED.
*   IF ( <HD>-Q10  LE  <HD>-Q11 ) OR <HD>-Q10 = 0.
*      MESSAGE S000 WITH '출고 확인 대상이 없습니다.'(E11)
*      DISPLAY LIKE GC_E .  EXIT.
*
*   ENDIF.

    LOOP AT GT_ITEM ASSIGNING FIELD-SYMBOL(<ITEM>).

      CASE <HD>-ZREQ_TYPE.
        WHEN GC_A.

          UPDATE ZGTMMT4403
          SET ZMM_CHECK = GC_A
                 AEDAT = SY-DATUM
                 AEDAT_LOCAL = SY-DATLO
                 AETIM = SY-UZEIT
                 AETIM_LOCAL = SY-TIMLO
                 AENAM = SY-UNAME
          WHERE BUKRS = <ITEM>-BUKRS
          AND DLVRQ = <ITEM>-DLVRQ
          AND VBELN = <ITEM>-VBELN
          AND POSNR = <ITEM>-POSNR
          AND EBELN = <ITEM>-EBELN
          AND EBELP = <ITEM>-EBELP
          AND ZMM_CHECK = ''.

        WHEN GC_B.

          UPDATE ZGTMMT4405
          SET ZMM_CHECK = GC_A
                 AEDAT = SY-DATUM
                 AEDAT_LOCAL = SY-DATLO
                 AETIM = SY-UZEIT
                 AETIM_LOCAL = SY-TIMLO
                 AENAM = SY-UNAME
          WHERE BUKRS = <ITEM>-BUKRS
          AND DLVRQ = <ITEM>-DLVRQ
          AND VBELN = <ITEM>-VBELN
          AND POSNR = <ITEM>-POSNR
          AND ZMM_CHECK = ''.

        WHEN OTHERS.
      ENDCASE.

      IF SY-SUBRC = 0.
        COMMIT WORK AND WAIT .
        MESSAGE S000 WITH TEXT-M19. "출고 확인 처리 되었습니다.
      ELSE.
        GV_ERR = GC_X.
      ENDIF.

    ENDLOOP.
  ENDIF.

  IF GV_ERR IS INITIAL.
    PERFORM GET_DATA.
    PERFORM REFRESH_TABLE USING GCL_GRID_HD SPACE.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_GRDATA_ITEM
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM GET_GRDATA_ITEM .

  DATA : LR_BUKRS TYPE RANGE OF ZGTMM_CV_GET_OEM_DELIVERY_BASE-BUKRS,
         LR_DLVRQ TYPE RANGE OF ZGTMM_CV_GET_OEM_DELIVERY_BASE-DLVRQ,
         LR_WERKS TYPE RANGE OF ZGTMM_CV_GET_OEM_DELIVERY_BASE-WERKS,
         LR_VBELN TYPE RANGE OF ZGTMM_CV_GET_OEM_DELIVERY_BASE-VBELN,
         LR_POSNR TYPE RANGE OF ZGTMM_CV_GET_OEM_DELIVERY_BASE-POSNR.

  CLEAR : GS_ROW, GV_ERR, GT_ITEM_GR[].

  PERFORM GET_SELECTED_ROWS USING GCL_GRID_GRHD '' 'X' ''.
  CHECK GV_ERR IS INITIAL.

  LOOP AT  GT_ROWS INTO GS_ROW.

    READ TABLE GT_HEADGR ASSIGNING FIELD-SYMBOL(<FS>) INDEX GS_ROW-INDEX.
    CHECK <FS> IS ASSIGNED.

    APPEND VALUE #( SIGN = GC_I  OPTION = GC_EQ
                                 LOW = <FS>-BUKRS  ) TO LR_BUKRS.
    APPEND VALUE #( SIGN = GC_I  OPTION = GC_EQ
                                 LOW = <FS>-DLVRQ  ) TO LR_DLVRQ.
*    APPEND VALUE #( SIGN = GC_I  OPTION = GC_EQ
*                                 LOW = <FS>-WERKS  ) TO LR_WERKS.
*    APPEND VALUE #( SIGN = GC_I  OPTION = GC_EQ
*                                 LOW = <FS>-VBELN  ) TO LR_VBELN.
*    APPEND VALUE #( SIGN = GC_I  OPTION = GC_EQ
*                                 LOW = <FS>-POSNR  ) TO LR_POSNR.

  ENDLOOP.

*선택 라인 기준의 ITEM 데이터 가져오기
  SELECT FROM ZGTMM_CV_GET_OEM_DELIVERY_INFO

      FIELDS BUKRS, DLVRQ ,WERKS, WERKS_N,
*                 VKBUR, VKBUR_N, VKGRP, VKGRP_N,
                 VBELN, POSNR, EBELN, EBELP,
                 EINDT, LIFNR, VNAME,  MATNR, MAKTX,
                 COLOR, LENGTH, MEINS, DR_MEINS, LOADQTY_M,
                 LOADQTY_DR,  ZDOC_NO, ZDOC_ITEM_NO,
                 DELNO,DELITEM,
                 GRQTY_M, GRQTY_DR,
                 MJAHR, MBLNR, BUDAT, ZMM_CHECK,DPCBT,

                 CASE WHEN MBLNR IS NOT INITIAL THEN '@DF@'
                          ELSE
                             CASE WHEN ZMM_CHECK IS NOT INITIAL THEN '@5D@'
                                      ELSE '@5D@' END
                 END AS GRSTATUS " ICON_COMPLETE

      WHERE BUKRS IN @LR_BUKRS
           AND DLVRQ IN @LR_DLVRQ
*           AND WERKS IN @LR_WERKS
*           AND VBELN IN @LR_VBELN
*           AND POSNR IN @LR_POSNR
      INTO CORRESPONDING FIELDS OF TABLE @GT_ITEM_GR.

  IF SY-SUBRC <> 0.
    MESSAGE S000 WITH TEXT-E05 DISPLAY LIKE GC_E.
  ENDIF.

*      LOOP AT GT_ITEM_GR INTO DATA(LS_GR).
*        IF LS_GR-MBLNR IS INITIAL.
*            LS_GR-GRSTATUS = ICON_INCOMPLETE.
*        ELSE.
*             LS_GR-GRSTATUS = ICON_COMPLETE.
*        ENDIF.
*
*        MODIFY GT_ITEM_GR FROM LS_GR.
*      ENDLOOP.

*조회된 데이터가 없어도 ALV 수행
*      GV_BOTTOM = GC_X.
*      CALL SCREEN 0400.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_MNGDATA_ITEM
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM GET_MNGDATA_ITEM .

  CLEAR : GS_ROW, GV_ERR, GT_HEAD, GT_ITEM.

  PERFORM GET_DATA. "HEADER DATA.

  CLEAR : GV_BLAND, GV_CITY1, GV_DEST1, GV_SITE_NAME, GV_SITE_TEL,
               GV_CUST_NAME , GV_CUST_TEL, GV_DEST2, GV_SP_NOTE, GV_BOTTOM.

* "ITEM 데이터 가져오기
*  IF GT_HEAD[] IS NOT INITIAL.
*
*    SELECT FROM ZGTMM_CV_DDR_REPORT_I
*    FIELDS *
*    FOR ALL ENTRIES IN @GT_HEAD
*    WHERE BUKRS = @GT_HEAD-BUKRS
*         AND DLVRQ = @GT_HEAD-DLVRQ
*    INTO CORRESPONDING FIELDS OF TABLE @GT_ITEM.
*
*    IF SY-SUBRC <> 0.
*      MESSAGE S000 WITH TEXT-E05 DISPLAY LIKE GC_E.
*    ENDIF.
*  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_DATA_DRGR
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_DATA_DRGR .

  CLEAR : GT_ROWS, GS_ROW, GV_ERR, GV_ANSWER, GV_QUES, GT_DRGR[].

  PERFORM GET_SELECTED_ROWS USING GCL_GRID_GRIT '' 'X' TEXT-E06.
  CHECK GV_ERR IS INITIAL.

  LOOP AT GT_ROWS INTO GS_ROW.

    READ TABLE GT_ITEM_GR ASSIGNING FIELD-SYMBOL(<FS>) INDEX GS_ROW-INDEX.
    IF <FS> IS ASSIGNED.

      IF <FS>-MBLNR IS INITIAL AND  <FS>-ZDOC_NO IS NOT INITIAL.
**--> 26.09 일반자재는 적재수량(M)/적재드럼수로 드럼별 수량을 나누므로 드럼수 0이면 ZERODIVIDE 덤프
        IF <FS>-DPCBT <> GC_A AND <FS>-LOADQTY_DR <= 0.
          GV_ERR = GC_X.
          MESSAGE S000 WITH '적재드럼수가 없는 품목은 입고할 수 없습니다.'(e15)
          DISPLAY LIKE GC_E .  EXIT.
        ENDIF.
**--< 26.09
*         <FS>-INDEX = GS_ROW-INDEX.
        APPEND <FS> TO GT_DRGR.
      ELSEIF <FS>-MBLNR IS NOT INITIAL.
        GV_ERR = GC_X.
        MESSAGE S000 WITH '이미 입고 완료된 정보가 존재합니다.'(e07)

        DISPLAY LIKE GC_E .  EXIT.
      ELSEIF  <FS>-ZDOC_NO IS  INITIAL.
        GV_ERR = GC_X.
        MESSAGE S000 WITH '거래명세표가 미발행된 수량은 입고할 수 없습니다.'(e13)
        DISPLAY LIKE GC_E .  EXIT.
      ENDIF.

*      IF <FS>-ZMM_CHECK IS INITIAL.
*         GV_ERR = GC_X.
*         MESSAGE S000 WITH '이미 입고 완료된 정보가 존재합니다..'(E12)
*         DISPLAY LIKE GC_E .  EXIT.
*      ENDIF.

    ENDIF.

  ENDLOOP.

  CHECK GV_ERR IS INITIAL.

  IF GT_DRGR[] IS NOT INITIAL.
    GV_BUDAT = SY-DATLO.
    GV_QUES  = '선택된 납품 물량을 입고 처리 하시겠습니까?'(m20).
*전기일 입력 팝업
    CALL SCREEN 0200  STARTING AT 10 5  ENDING AT 50 10.

    IF GV_BUDAT IS NOT INITIAL.
      CLEAR GV_BUDAT.
    ENDIF.
    IF GV_QUES IS NOT INITIAL.
      CLEAR GV_QUES.
    ENDIF.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_LIST_GR
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_LIST_GR  .

  DATA :
    LS_HEAD    TYPE BAPI2017_GM_HEAD_01,
    LS_CODE    TYPE BAPI2017_GM_CODE,
    LS_HEADRET TYPE BAPI2017_GM_HEAD_RET,
    LV_MBLNR   TYPE BAPI2017_GM_HEAD_RET-MAT_DOC,
    LV_MJAHR   TYPE BAPI2017_GM_HEAD_RET-DOC_YEAR,
    LV_SQTY    TYPE ZGTMM_CV_GET_OEM_DELIVERY_BASE-LOADQTY_M,
    LT_ITEM    LIKE TABLE OF BAPI2017_GM_ITEM_CREATE,
    LT_RETURN  LIKE TABLE OF BAPIRET2.

  DATA : LT_ALLOC    TYPE TABLE OF BAPI1003_ALLOC_VALUES_CHAR,
         LV_KEY      TYPE BAPI1003_KEY-OBJECT,
         LV_MAT18    TYPE MATNR18,
         LT_RETURN_T TYPE STANDARD TABLE OF BAPIRET2,
         LT_ALC_NUM  TYPE TABLE OF BAPI1003_ALLOC_VALUES_NUM,
         LT_ALC_CURR TYPE TABLE OF BAPI1003_ALLOC_VALUES_CURR.

  DATA : BEGIN OF ALLOC_S,
           MATNR  TYPE MARA-MATNR,
           CHARG  TYPE MCH1-CHARG,
           CLASS  TYPE KLAH-CLASS,
           LENGTH TYPE ZGTMM_CV_GET_OEM_DELIVERY_INFO-LENGTH,
         END OF ALLOC_S.
  DATA : ALLOC_T LIKE TABLE OF ALLOC_S.
*>S.2026.08.12
  DATA :
    LT_RESB       TYPE TY_T_PO_RESB,
    LT_DELCOMP    TYPE TY_T_PO_DELCOMP,
    LT_DISPO      TYPE TY_T_PO_DISPO,
    LT_MSLB       TYPE TY_T_MSLB,
    LT_EKPO       TYPE TY_T_EKPO,
    LT_ZGTMMT9450 TYPE TY_T_ZGTMMT9450,
    LV_CHECK.
*<E.2026.08.12_ZGODEV04

  CLEAR GV_ERR.

  IF GV_BUDAT IS INITIAL.
    GV_ERR = GC_X.
    MESSAGE S000 WITH '전기일자 입력은 필수입니다.'(e08) DISPLAY LIKE GC_E.
  ENDIF.

  CHECK GV_ERR IS INITIAL.
  SORT GT_DRGR BY DELNO .

*>S.2026.08.12
*PSTYP(품목범주) = 3(외주임가공)인 자재
*COMPONENT 투입 자재 참조 기준 데이터 가져오기..
*1.납품문서 COMPONENT 조회
  PERFORM GET_DELCOMP USING GT_DRGR CHANGING LT_DELCOMP.
*2.외주임가공 투입정보 관리 이력 테이블 정보 점검(ISSUE_COMP)
  PERFORM GET_ZGTMMT9450 USING GT_DRGR CHANGING LT_ZGTMMT9450.
*3.외주 임가공 PO 예약데이터 조회
  PERFORM GET_PO_RESB USING GT_DRGR CHANGING LT_RESB.
*4.단일배치관리/재고 조회
  PERFORM GET_MSLB USING LT_RESB LT_DELCOMP CHANGING LT_MSLB.
*5.품목범주정보
  IF GT_DRGR[] IS NOT INITIAL.
    SELECT EBELN, EBELP, PSTYP
      FROM EKPO
      FOR ALL ENTRIES IN @GT_DRGR
      WHERE EBELN = @GT_DRGR-EBELN
           AND EBELP = @GT_DRGR-EBELP
      INTO TABLE @LT_EKPO.
    SORT LT_EKPO BY EBELN EBELP.
  ENDIF.
*<E.2026.08.12_ZGODEV04

*저장위치 정보
  SELECT SINGLE FLD_02
     FROM ZGTPPT1010
   WHERE MODULE_KIND = @GC_MM
        AND CODEGRP = @GC_0800
**--> 26.09 플랜트 조건 변경
*        AND FLD_01 = @P_WERKS
        AND FLD_01 IN @S_WERKS
   INTO @DATA(LV_LGORT).

*---HEADER 정보 설정---
  CLEAR : LS_HEAD, LS_CODE.
  LS_HEAD = VALUE #( PSTNG_DATE  = GV_BUDAT
                                   DOC_DATE     = SY-DATLO ).
  LS_CODE = VALUE #( GM_CODE  = '01').

*--- DELNO의 (품목별 상세 내역) 설정 ---
  LOOP AT GT_DRGR ASSIGNING FIELD-SYMBOL(<FS>) GROUP BY ( DELNO = <FS>-DELNO )
                                                             ASSIGNING FIELD-SYMBOL(<FSG>).

    CLEAR : LV_SQTY, LV_MBLNR, LV_MJAHR, LS_HEADRET, LT_RETURN, LT_ITEM.

    LOOP AT GROUP <FSG> ASSIGNING FIELD-SYMBOL(<LS_GR>).
      IF <LS_GR>-DPCBT = GC_A.
        DATA : LV_LENGTH_I TYPE INT4.
        DATA : LV_CHARG  TYPE MCHA-CHARG,
               LV_STATUS TYPE BAPI1003_KEY-STATUS,
               LV_CLASS  TYPE KLAH-CLASS.

        LV_LENGTH_I = <LS_GR>-LENGTH.
        LV_CHARG = LV_LENGTH_I.
        CONDENSE  LV_CHARG.

*>S.2026.08.12_외주임가공 오더 입고 로직 추가
*품목 및 하위자재 투입 아이템 구성 추가필요.
        PERFORM SET_BAPI_ITEM USING <LS_GR> LT_RESB LT_DELCOMP LT_MSLB LT_EKPO LT_ZGTMMT9450 LV_LGORT LV_CHARG ''
                                             CHANGING LT_ITEM LS_HEAD LV_CHECK.
*        APPEND VALUE #( material           = <ls_gr>-matnr
*                                     plant                = <ls_gr>-werks
*                                     stge_loc         = lv_lgort
*                                     move_type       = '101'
*                                     entry_qnt       = <ls_gr>-loadqty_m
*                                     entry_uom      = <ls_gr>-meins
*                                     po_number      = <ls_gr>-ebeln
*                                     po_item            = <ls_gr>-ebelp
*                                     item_text        = <ls_gr>-delno && '-' && <ls_gr>-delitem
*                                     batch          = lv_charg
*                                     mvt_ind            = gc_b   ) TO lt_item.
*<E.2026.08.12_ZGODEV04

*2-13-2) FACTOR 배치 자재의 CLASS 조회
* CLASS번호
        CLEAR: LV_CLASS.
        CALL FUNCTION 'CLFC_BATCH_ALLOCATION_TO_CLASS'
          EXPORTING
            MATERIAL           = <LS_GR>-MATNR "입고자재
            PLANT              = <LS_GR>-WERKS "플랜트
            CLASSTYPE          = '023'       "클래스유형(배치)
          IMPORTING
            CLASS              = LV_CLASS
          EXCEPTIONS
            NO_CLASS_FOUND     = 1
            NO_CLASSTYPE_FOUND = 2
            OTHERS             = 3.

        CHECK LV_CLASS IS NOT INITIAL.

        ALLOC_S-MATNR = <LS_GR>-MATNR.
        ALLOC_S-CHARG =  LV_CHARG.
        ALLOC_S-CLASS = LV_CLASS.
        ALLOC_S-LENGTH = <LS_GR>-LENGTH.

        APPEND ALLOC_S TO ALLOC_T.
        CLEAR ALLOC_S.

      ELSE.

*적재드럼수_ 이 수량 만큼 ITEM LINE 설정.
        DATA(LV_DRQTY) = <LS_GR>-LOADQTY_DR.
*ITEM LINE별 수량 계산_<적재수량(M)/적재수량(드럼)>
        LV_SQTY = <LS_GR>-LOADQTY_M / <LS_GR>-LOADQTY_DR.

        DO LV_DRQTY TIMES.
*>S.2026.08.12_외주임가공 오더 입고 로직 추가
*품목 및 하위자재 투입 아이템 구성 추가필요.
          CLEAR LV_CHARG . "DPCBT NE A인 자재는 배치 자동채번이므로 클리어..
          PERFORM SET_BAPI_ITEM USING <LS_GR> LT_RESB LT_DELCOMP LT_MSLB LT_EKPO LT_ZGTMMT9450
                                                          LV_LGORT LV_CHARG LV_SQTY
                                             CHANGING LT_ITEM LS_HEAD  LV_CHECK.
*          APPEND VALUE #( material           = <ls_gr>-matnr
*                                       plant                = <ls_gr>-werks
*                                       stge_loc         = lv_lgort
*                                       move_type       = '101'
*                                       entry_qnt       = lv_sqty
*                                       entry_uom      = <ls_gr>-meins
*                                       po_number      = <ls_gr>-ebeln
*                                       po_item            = <ls_gr>-ebelp
*                                       item_text        = <ls_gr>-delno && '-' && <ls_gr>-delitem
*                                       mvt_ind            = gc_b   ) TO lt_item.
*<E.2026.08.12_ZGODEV04
        ENDDO.
        CLEAR : LV_DRQTY, LV_SQTY.
      ENDIF.

    ENDLOOP. "ITEM 구성 루프 종료.

*"--- BAPI호출. 입고_MBLNR 번호 채번_헤더의 DELNO기준 ---
*>S.2026.08.12_외주임가공 오더 입고 로직 추가->아이템 구성과정 중 하위자재 투입 에러 발생시 중단.
    IF LV_CHECK EQ GC_E.
      LT_RETURN = VALUE #( ( TYPE = GC_E MESSAGE = TEXT-E14 ) ). "투입 자재 정보를 확인하세요.

    ELSE.
*팩터배치자재_바피 수행 전 특성 정보 업데이트 선 수행 추가.
      PERFORM UPDATE_BATCHCLASS USING <LS_GR>.
*<E.2026.08.12_ZGODEV04
      CALL FUNCTION 'BAPI_GOODSMVT_CREATE'
        EXPORTING
          GOODSMVT_HEADER  = LS_HEAD
          GOODSMVT_CODE    = LS_CODE
        IMPORTING
          GOODSMVT_HEADRET = LS_HEADRET
          MATERIALDOCUMENT = LV_MBLNR
          MATDOCUMENTYEAR  = LV_MJAHR
        TABLES
          GOODSMVT_ITEM    = LT_ITEM
          RETURN           = LT_RETURN.
    ENDIF.

    SORT LT_RETURN BY TYPE.

    IF LINE_EXISTS( LT_RETURN[ TYPE = GC_E ] ) .
      CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
      READ TABLE LT_RETURN INTO DATA(LS_RT) INDEX 1.

      LOOP AT GT_ROWS INTO DATA(LS_ROW).
**MAIN ALV DATA UPDATE
        READ TABLE GT_ITEM_GR ASSIGNING FIELD-SYMBOL(<GRITEM>) INDEX LS_ROW-INDEX.
        IF <GRITEM> IS ASSIGNED .
          CHECK <GRITEM>-DELNO = <FSG>-DELNO .
          CLEAR : <GRITEM>-MBLNR, <GRITEM>-MJAHR.
          <GRITEM>-GRSTATUS = ICON_INCOMPLETE.
          <GRITEM>-STATUS = ICON_LED_RED.
          <GRITEM>-MESSAGE = LS_RT-MESSAGE.
          MODIFY GT_ITEM_GR FROM <GRITEM> INDEX LS_ROW-INDEX.
        ENDIF.
      ENDLOOP.

    ELSE.
**--> 26.09 ZGTMMT4403 UPDATE를 자재문서와 같은 LUW로 확정
*      CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
*        EXPORTING
*          WAIT = GC_X.
**--< 26.09

      CLEAR LS_ROW.
      LOOP AT GT_ROWS INTO LS_ROW.
**MAIN ALV DATA UPDATE
        READ TABLE GT_ITEM_GR ASSIGNING FIELD-SYMBOL(<GRITEM2>) INDEX LS_ROW-INDEX.
        IF <GRITEM2> IS ASSIGNED .
          CHECK <GRITEM2>-DELNO = <FSG>-DELNO .
          <GRITEM2>-MBLNR = LV_MBLNR.
          <GRITEM2>-MJAHR  = LV_MJAHR.
          <GRITEM2>-GRSTATUS = ICON_COMPLETE.
          <GRITEM2>-STATUS = ICON_LED_GREEN.
          <GRITEM2>-MESSAGE = '자재문서' && LV_MBLNR && '이 생성되었습니다.'.
          MODIFY GT_ITEM_GR FROM <GRITEM2> INDEX LS_ROW-INDEX.
*ZGTMMT4403 UPDATE
          UPDATE ZGTMMT4403
                SET MBLNR = LV_MBLNR
                       MJAHR = LV_MJAHR
           WHERE DLVRQ = <GRITEM2>-DLVRQ
                AND VBELN = <GRITEM2>-VBELN
                AND POSNR = <GRITEM2>-POSNR
                AND EBELN = <GRITEM2>-EBELN
                AND EBELP = <GRITEM2>-EBELP
                AND ZDOC_NO = <GRITEM2>-ZDOC_NO
                AND ZDOC_ITEM_NO = <GRITEM2>-ZDOC_ITEM_NO
                AND DELNO = <GRITEM2>-DELNO
                AND DELITEM = <GRITEM2>-DELITEM.
        ENDIF.
      ENDLOOP.

**--> 26.09 ZGTMMT4403 UPDATE를 자재문서와 같은 LUW로 확정
*      뒤 그룹 ROLLBACK 시 앞 그룹 4403 기록이 되돌려져 중복 입고되던 문제
      CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
        EXPORTING
          WAIT = GC_X.
**--< 26.09

      IF  ALLOC_T[] IS NOT INITIAL.
        WAIT UP TO '0.5' SECONDS.
        CLEAR : LT_RETURN_T, LT_RETURN_T[].

        LOOP AT ALLOC_T ASSIGNING FIELD-SYMBOL(<ALLO>).
          CLEAR : LT_ALLOC , LT_ALLOC[].
          LT_ALLOC[] = VALUE #( BASE LT_ALLOC
                                          ( CHARACT = 'SAP_MILLCA_LENGTH'
                                            VALUE_CHAR = <ALLO>-LENGTH )
                                          ( CHARACT = 'SAP_MILLCA_LENGTH_SUB'
                                            VALUE_CHAR = <ALLO>-LENGTH ) ). "26.07.29조장으로 변경(기존 공백)

          SELECT SINGLE CUOBJ_BM
               FROM MCH1
             WHERE MATNR = @<ALLO>-MATNR
                  AND CHARG = @<ALLO>-CHARG
             INTO @DATA(LV_OBJKEY).

*          CLEAR : lv_mat18, lv_key, lt_return.
*          lv_mat18 = |{ <allo>-matnr ALPHA = IN }|.
*          lv_key(18) = lv_mat18.
*          lv_key+18(10) = <allo>-charg.
          IF LV_OBJKEY IS NOT INITIAL.

            CALL FUNCTION 'BAPI_OBJCL_CHANGE_KEY'
              EXPORTING
                CLOBJECTKEY         = LV_OBJKEY
                CLASSNUM            = LV_CLASS
              IMPORTING
                CLASSIF_STATUS      = LV_STATUS
              TABLES
                ALLOCVALUESNUM_NEW  = LT_ALC_NUM
                ALLOCVALUESCHAR_NEW = LT_ALLOC
                ALLOCVALUESCURR_NEW = LT_ALC_CURR
                RETURN              = LT_RETURN_T.

*          CALL FUNCTION 'BAPI_OBJCL_CHANGE'
*            EXPORTING
*              objectkey          = lv_key
*              objecttable        = 'MCH1'
*              classnum           = <allo>-class
*              classtype          = '023'
*            TABLES
*              allocvaluesnumnew  = lt_alc_num
*              allocvaluescharnew = lt_alloc
*              allocvaluescurrnew = lt_alc_curr
*              return             = lt_return_t.

            READ TABLE LT_RETURN_T ASSIGNING FIELD-SYMBOL(<LS_R2TURN>) WITH KEY TYPE = GC_E.
            IF SY-SUBRC EQ 0.
              CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
            ELSE.
*      배치특성 성공
              CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
                EXPORTING
                  WAIT = ABAP_TRUE.
            ENDIF.
          ENDIF.

        ENDLOOP.
      ENDIF.
      CLEAR : ALLOC_T , ALLOC_T[].

    ENDIF.

  ENDLOOP.  "자재문서(입고)생성 루프 종료.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_DATA_GRCANC
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_DATA_GRCANC .

  CLEAR : GT_RETURN, GT_ROWS, GS_ROW, GV_ERR, GV_ANSWER, GT_DRGR[].

  PERFORM GET_SELECTED_ROWS USING GCL_GRID_GRIT '' 'X' TEXT-E09.
  CHECK GV_ERR IS INITIAL.

  LOOP AT GT_ROWS INTO GS_ROW.

    READ TABLE GT_ITEM_GR ASSIGNING FIELD-SYMBOL(<FS>) INDEX GS_ROW-INDEX.
    IF <FS> IS ASSIGNED.

      IF <FS>-MBLNR IS INITIAL.
        GV_ERR = GC_X.
        MESSAGE S000 WITH '입고 취소 대상이 아닌 정보를 선택했습니다.'(e10)
        DISPLAY LIKE GC_E .  EXIT.
      ELSE.
        APPEND <FS> TO GT_DRGR.
      ENDIF.

    ENDIF.

  ENDLOOP.

  CHECK GV_ERR IS INITIAL.

  IF GT_DRGR[] IS NOT INITIAL.
    READ TABLE GT_DRGR ASSIGNING FIELD-SYMBOL(<GR>) INDEX 1.
    IF SY-SUBRC = 0.
      GV_BUDAT = <GR>-BUDAT.
    ENDIF.
*      GV_BUDAT = SY-DATLO.
    GV_QUES  = '선택된 입고를 취소 하시겠습니까?'(m21).
*전기일 입력 팝업
    CALL SCREEN 0200  STARTING AT 10 5  ENDING AT 50 10.

    IF GV_BUDAT IS NOT INITIAL.
      CLEAR GV_BUDAT.
    ENDIF.
    IF GV_QUES IS NOT INITIAL.
      CLEAR GV_QUES.
    ENDIF.
  ENDIF.

*  CHECK GV_ERR IS INITIAL.
*  PERFORM POPUP_TO_CONFIRM_STEP  USING 'N' TEXT-M21 '' TEXT-M09.
*  CHECK GV_ANSWER = GC_J. "선택된 입고를 취소 하시겠습니까?
*
*  IF GT_DRGR[] IS NOT INITIAL.
*     SORT GT_DRGR BY MJAHR MBLNR.
*     DELETE ADJACENT DUPLICATES FROM GT_DRGR COMPARING MJAHR MBLNR.
*
*     LOOP AT GT_DRGR ASSIGNING FIELD-SYMBOL(<DRGR>).
**BAPI_입고취소
*       CALL FUNCTION 'BAPI_GOODSMVT_CANCEL'
*         EXPORTING
*           MATERIALDOCUMENT = <DRGR>-MBLNR
*           MATDOCUMENTYEAR  = <DRGR>-MJAHR
*         TABLES
*           RETURN                     = GT_RETURN
*                 .
*       IF LINE_EXISTS( GT_RETURN[ TYPE = GC_E ] ) .
*         CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
*         READ TABLE GT_RETURN INTO DATA(LS_RT) INDEX 1.
*
*         LOOP AT GT_ROWS INTO DATA(LS_ROW).
***MAIN ALV DATA UPDATE
*           READ TABLE GT_ITEM_GR ASSIGNING FIELD-SYMBOL(<GRITEM>) INDEX LS_ROW-INDEX.
*
*           IF <GRITEM>-MJAHR = <DRGR>-MJAHR AND <GRITEM>-MBLNR = <DRGR>-MBLNR .
*             <GRITEM>-STATUS = ICON_LED_RED.
*             <GRITEM>-MESSAGE = LS_RT-MESSAGE.
*
*             MODIFY GT_ITEM_GR FROM <GRITEM> INDEX LS_ROW-INDEX.
*           ENDIF.
*         ENDLOOP.
*
*       ELSE.
*         CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
*           EXPORTING
*             WAIT = GC_X.
*
*         CLEAR LS_ROW.
*         LOOP AT GT_ROWS INTO LS_ROW.
***MAIN ALV DATA UPDATE
*           READ TABLE GT_ITEM_GR ASSIGNING FIELD-SYMBOL(<GRITEM2>) INDEX LS_ROW-INDEX.
*
*           IF <GRITEM2>-MJAHR = <DRGR>-MJAHR AND <GRITEM2>-MBLNR = <DRGR>-MBLNR .
*             CLEAR : <GRITEM2>-MBLNR , <GRITEM2>-MJAHR.
*             <GRITEM2>-GRSTATUS = ICON_INCOMPLETE.
*             <GRITEM2>-STATUS = ICON_LED_GREEN.
*             <GRITEM2>-MESSAGE = '자재문서가 역분개 되었습니다.'.
*
*             MODIFY GT_ITEM_GR FROM <GRITEM2> INDEX LS_ROW-INDEX.
*           ENDIF.
*         ENDLOOP.
*       ENDIF.
*
*     ENDLOOP.
*  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_LIST_GRCANC
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_LIST_GRCANC .

  CLEAR : GT_RETURN, GV_ERR.

  IF GV_BUDAT IS INITIAL.
    GV_ERR = GC_X.
    MESSAGE S000 WITH '전기일자 입력은 필수입니다.'(e08) DISPLAY LIKE GC_E.
  ENDIF.

  CHECK GV_ERR IS INITIAL.

  IF GT_DRGR[] IS NOT INITIAL.
    SORT GT_DRGR BY MJAHR MBLNR.
    DELETE ADJACENT DUPLICATES FROM GT_DRGR COMPARING MJAHR MBLNR.

    LOOP AT GT_DRGR ASSIGNING FIELD-SYMBOL(<DRGR>).
*BAPI_입고취소
      CALL FUNCTION 'BAPI_GOODSMVT_CANCEL'
        EXPORTING
          MATERIALDOCUMENT = <DRGR>-MBLNR
          MATDOCUMENTYEAR  = <DRGR>-MJAHR
        TABLES
          RETURN           = GT_RETURN.
      IF LINE_EXISTS( GT_RETURN[ TYPE = GC_E ] ) .
        CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
        READ TABLE GT_RETURN INTO DATA(LS_RT) INDEX 1.

        LOOP AT GT_ROWS INTO DATA(LS_ROW).
**MAIN ALV DATA UPDATE
          READ TABLE GT_ITEM_GR ASSIGNING FIELD-SYMBOL(<GRITEM>) INDEX LS_ROW-INDEX.

          IF <GRITEM>-MJAHR = <DRGR>-MJAHR AND <GRITEM>-MBLNR = <DRGR>-MBLNR .
            <GRITEM>-STATUS = ICON_LED_RED.
            <GRITEM>-MESSAGE = LS_RT-MESSAGE.

            MODIFY GT_ITEM_GR FROM <GRITEM> INDEX LS_ROW-INDEX.
          ENDIF.
        ENDLOOP.

      ELSE.
        CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
          EXPORTING
            WAIT = GC_X.

        CLEAR LS_ROW.
        LOOP AT GT_ROWS INTO LS_ROW.
**MAIN ALV DATA UPDATE
          READ TABLE GT_ITEM_GR ASSIGNING FIELD-SYMBOL(<GRITEM2>) INDEX LS_ROW-INDEX.

          IF <GRITEM2>-MJAHR = <DRGR>-MJAHR AND <GRITEM2>-MBLNR = <DRGR>-MBLNR .
            CLEAR : <GRITEM2>-MBLNR , <GRITEM2>-MJAHR.
            <GRITEM2>-GRSTATUS = ICON_INCOMPLETE.
            <GRITEM2>-STATUS = ICON_LED_GREEN.
            <GRITEM2>-MESSAGE = '자재문서가 역분개 되었습니다.'.

            MODIFY GT_ITEM_GR FROM <GRITEM2> INDEX LS_ROW-INDEX.
*ZGTMMT4403 UPDATE
            UPDATE ZGTMMT4403
                  SET MBLNR = <GRITEM2>-MBLNR
                         MJAHR = <GRITEM2>-MJAHR
             WHERE DLVRQ = <GRITEM2>-DLVRQ
                  AND VBELN = <GRITEM2>-VBELN
                  AND POSNR = <GRITEM2>-POSNR
                  AND EBELN = <GRITEM2>-EBELN
                  AND EBELP = <GRITEM2>-EBELP
                  AND ZDOC_NO = <GRITEM2>-ZDOC_NO
                  AND ZDOC_ITEM_NO = <GRITEM2>-ZDOC_ITEM_NO
                  AND DELNO = <GRITEM2>-DELNO
                  AND DELITEM = <GRITEM2>-DELITEM.
          ENDIF.
        ENDLOOP.
      ENDIF.

    ENDLOOP.
  ENDIF.


ENDFORM.
**&---------------------------------------------------------------------*
**& Form SET_CELL_COLOR
**&---------------------------------------------------------------------*
**& text
**&---------------------------------------------------------------------*
**& -->  p1        text
**& <--  p2        text
**&---------------------------------------------------------------------*
*FORM SET_CELL_COLOR USING PV_GB.
*
*  DATA:
*    LS_COLOR   TYPE  LVC_S_SCOL,
*    LO_DATA      TYPE REF TO DATA,
*    LO_TABLE_DESC TYPE REF TO CL_ABAP_TABLEDESCR.
*
*  FIELD-SYMBOLS: <LT_DATA> TYPE STANDARD TABLE.
*
*" 1. 인터널 테이블의 구조(TYPE) 정보를 동적으로 읽어옴
*  CASE PV_GB.
*    WHEN '100'.
*      LO_TABLE_DESC ?= CL_ABAP_TYPEDESCR=>DESCRIBE_BY_DATA( GT_LIST ).
*    WHEN '300H'.
*      LO_TABLE_DESC ?= CL_ABAP_TYPEDESCR=>DESCRIBE_BY_DATA( GT_HEAD ).
*    WHEN '300IT'.
*      LO_TABLE_DESC ?= CL_ABAP_TYPEDESCR=>DESCRIBE_BY_DATA( GT_ITEM ).
*    WHEN '400H'.
*      LO_TABLE_DESC ?= CL_ABAP_TYPEDESCR=>DESCRIBE_BY_DATA( GT_HEADGR ).
**    WHEN '400IT'.
**      LO_TABLE_DESC ?= CL_ABAP_TYPEDESCR=>DESCRIBE_BY_DATA( GT_ITEM_GR ).
*    WHEN OTHERS.
*  ENDCASE.
*
*" 2. 읽어온 구조와 동일한 동적 인터널 테이블 객체 생성
*  IF LO_TABLE_DESC IS BOUND.
*    CLEAR LO_DATA.
*    CREATE DATA LO_DATA TYPE HANDLE LO_TABLE_DESC.
*  ENDIF.
*
*" 3. 생성된 객체를 필드 심볼 <LT_DATA>에 연결
*  IF LO_DATA IS BOUND.
*    ASSIGN LO_DATA->* TO <LT_DATA>.
*  ENDIF.
*
*  CHECK <LT_DATA> IS ASSIGNED.
*
*  LOOP AT <LT_DATA> ASSIGNING FIELD-SYMBOL(<LIST>).
**셀컬러 딥스트럭쳐 클리어
*    ASSIGN COMPONENT 'F_COL' OF STRUCTURE <LIST> TO FIELD-SYMBOL(<F_COL>).
*
*    IF <F_COL> IS ASSIGNED.
*      CLEAR: <F_COL>, LS_COLOR.
*    ELSE.
*      CONTINUE.
*    ENDIF.
*
*    CASE PV_GB.
*      WHEN '100'.
**선택_요청수량 유무에 따라 색 구분 해 봄...
*        ASSIGN COMPONENT 'REQ_MENGE' OF STRUCTURE <LIST> TO FIELD-SYMBOL(<REQ_MENGE>).
*        IF <REQ_MENGE> IS ASSIGNED.
*          LS_COLOR = VALUE #( FNAME = 'CHECK'
*                                             COLOR-COL = COND  #( WHEN  <REQ_MENGE> IS INITIAL
*                                                                                   THEN '0'  ELSE '3' )"흰색(기본)0 / 노랑 3
*                                             COLOR-INT = '0'     "색 연하게( 1 : 진하게 )
*                                             COLOR-INV = '0' ). "배경색/글자색 반전여부 ( 1: 반전 )
*          INSERT LS_COLOR INTO TABLE <F_COL>.
*        ENDIF.
*
*        CLEAR LS_COLOR.
*
*      WHEN '300H'.
*
*      WHEN '300IT'.
*
*      WHEN '400H'.
*        CLEAR LS_COLOR.
*        ASSIGN COMPONENT 'GRSTATUS' OF STRUCTURE <LIST> TO FIELD-SYMBOL(<GRSTATUS>).
*
*        IF <GRSTATUS> IS ASSIGNED.
**입고상태_완료 이면, 녹색 아니면 노랑으로 설정 해 봄..
*          LS_COLOR = VALUE #( FNAME = 'GRSTATUS'
*                                             COLOR-COL = COND  #( WHEN  <GRSTATUS> =  ICON_COMPLETE
*                                                                                   THEN '5'  ELSE '3' )"녹색 5/노랑 3
*                                             COLOR-INT = '0'     "색 연하게( 1 : 진하게 )
*                                             COLOR-INV = '0' ). "배경색/글자색 반전여부 ( 1: 반전 )
*          INSERT LS_COLOR INTO TABLE <F_COL>.
*        ENDIF.
*
*        CLEAR LS_COLOR.
*
*      WHEN '400IT'.
*      WHEN OTHERS.
*    ENDCASE.
*
*  ENDLOOP.
*
*
**COL 값 표준 색상
**0 : 기본 배경색 (우유색/회색)  COL_BACKGROUND (일반 배경)
**1 : 진한 파란색 / 청회색  COL_HEADING (헤더/타이틀)
**2 : 연한 회색  COL_NORMAL (일반 셀 강조)
**3 : 노란색  COL_TOTAL (합계 / 요약 라인)
**4 : 청록색 / 하늘색  COL_KEY (Key 필드 고정 색상)
**5 : 녹색  COL_POSITIVE (양수 / 성공 / 안전 데이터)
**6 : 빨간색  COL_NEGATIVE (음수 / 에러 / 경고 데이터)
**7 : 주황색 / 자주색  COL_GROUP (제어 레벨 / 그룹화 라인)
*ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_CELL_COLOR
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_CELL_COLOR.

  DATA:
    LS_COLOR   TYPE  LVC_S_SCOL.

  LOOP AT GT_LIST ASSIGNING FIELD-SYMBOL(<LIST>).
    CLEAR: <LIST>-F_COL, LS_COLOR.
*직송가능여부
    LS_COLOR = VALUE #( FNAME = 'ZCHECK'
                                       COLOR-COL = COND  #( WHEN  <LIST>-ZCHECK IS INITIAL
                                                                             THEN '0'  ELSE '3' )"흰색(기본)0 / 노랑 3
                                       COLOR-INT = '0'     "색 연하게( 1 : 진하게 )
                                       COLOR-INV = '0' ). "배경색/글자색 반전여부 ( 1: 반전 )
    INSERT LS_COLOR INTO TABLE <LIST>-F_COL.

*    CLEAR LS_COLOR.
**입고상태_완료 이면, 녹색 아니면 노랑으로 설정 해 봄..
*    LS_COLOR = VALUE #( FNAME = 'GRSTATUS'
*                                       COLOR-COL = COND  #( WHEN  <GRSTATUS> =  ICON_COMPLETE
*                                                                             THEN '5'  ELSE '3' )"녹색 5/노랑 3
*                                       COLOR-INT = '0'     "색 연하게( 1 : 진하게 )
*                                       COLOR-INV = '0' ). "배경색/글자색 반전여부 ( 1: 반전 )
*    INSERT LS_COLOR INTO TABLE <F_COL>.

  ENDLOOP.

**COL 값 표준 색상
**0 : 기본 배경색 (우유색/회색)  COL_BACKGROUND (일반 배경)
**1 : 진한 파란색 / 청회색  COL_HEADING (헤더/타이틀)
**2 : 연한 회색  COL_NORMAL (일반 셀 강조)
**3 : 노란색  COL_TOTAL (합계 / 요약 라인)
**4 : 청록색 / 하늘색  COL_KEY (Key 필드 고정 색상)
**5 : 녹색  COL_POSITIVE (양수 / 성공 / 안전 데이터)
**6 : 빨간색  COL_NEGATIVE (음수 / 에러 / 경고 데이터)
**7 : 주황색 / 자주색  COL_GROUP (제어 레벨 / 그룹화 라인)
ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_CELL_COLOR_300
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_CELL_COLOR_300.

  DATA:
    LS_COLOR   TYPE  LVC_S_SCOL.

  LOOP AT GT_HEAD ASSIGNING FIELD-SYMBOL(<HEAD>).
    CLEAR: <HEAD>-F_COL, LS_COLOR.
*입고상태_완료 이면, 녹색 아니면 노랑으로 설정 해 봄..
    LS_COLOR = VALUE #( FNAME = 'Q7'
                                       COLOR-COL = COND  #( WHEN  <HEAD>-Q7 =  ICON_COMPLETE
                                                                             THEN '5'  ELSE '3' )"녹색 5/노랑 3
                                       COLOR-INT = '0'     "색 연하게( 1 : 진하게 )
                                       COLOR-INV = '0' ). "배경색/글자색 반전여부 ( 1: 반전 )
    INSERT LS_COLOR INTO TABLE <HEAD>-F_COL.

*    CLEAR LS_COLOR. "여기부터 필요하면 위와 동일하게 추가 구성..필드명만 변경..조건은 주기 나름..

  ENDLOOP.

  LOOP AT GT_ITEM ASSIGNING FIELD-SYMBOL(<ITEM>).
    CLEAR: <ITEM>-F_COL, LS_COLOR.
*입고상태
    LS_COLOR = VALUE #( FNAME = 'STATUS1'
                                       COLOR-COL = COND  #( WHEN <ITEM>-STATUS1 =  ICON_COMPLETE
                                                                             THEN '5'  ELSE '3' )"녹색 5/노랑 3
                                       COLOR-INT = '0'     "색 연하게( 1 : 진하게 )
                                       COLOR-INV = '0' ). "배경색/글자색 반전여부 ( 1: 반전 )
    INSERT LS_COLOR INTO TABLE <ITEM>-F_COL.

*    CLEAR LS_COLOR. "여기부터 필요하면 위와 동일하게 추가 구성..필드명만 변경..조건은 주기 나름..

  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_CELL_COLOR_400
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_CELL_COLOR_400.

  DATA:
    LS_COLOR   TYPE  LVC_S_SCOL.

  LOOP AT GT_HEADGR ASSIGNING FIELD-SYMBOL(<HEAD>).
    CLEAR: <HEAD>-F_COL, LS_COLOR.
*입고상태_완료 이면, 녹색 아니면 노랑으로 설정 해 봄..
    LS_COLOR = VALUE #( FNAME = 'Q7'
                                       COLOR-COL = COND  #( WHEN  <HEAD>-Q7 =  ICON_COMPLETE
                                                                             THEN '5'  ELSE '3' )"녹색 5/노랑 3
                                       COLOR-INT = '0'     "색 연하게( 1 : 진하게 )
                                       COLOR-INV = '0' ). "배경색/글자색 반전여부 ( 1: 반전 )
    INSERT LS_COLOR INTO TABLE <HEAD>-F_COL.

*    CLEAR LS_COLOR. "여기부터 필요하면 위와 동일하게 추가 구성..필드명만 변경..조건은 주기 나름..

  ENDLOOP.

*  LOOP AT GT_ITEM_GR ASSIGNING FIELD-SYMBOL(<ITEM>).
*    CLEAR: <ITEM>-F_COL, LS_COLOR.
**입고상태
*    LS_COLOR = VALUE #( FNAME = 'STATUS1'
*                                       COLOR-COL = COND  #( WHEN <ITEM>-STATUS1 =  ICON_COMPLETE
*                                                                             THEN '5'  ELSE '3' )"녹색 5/노랑 3
*                                       COLOR-INT = '0'     "색 연하게( 1 : 진하게 )
*                                       COLOR-INV = '0' ). "배경색/글자색 반전여부 ( 1: 반전 )
*    INSERT LS_COLOR INTO TABLE <ITEM>-F_COL.

*    CLEAR LS_COLOR. "여기부터 필요하면 위와 동일하게 추가 구성..필드명만 변경..조건은 주기 나름..
*
*  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_BAPI_ITEM
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> <LS_GR>
*&      <-- LT_ITEM
*&---------------------------------------------------------------------*
FORM SET_BAPI_ITEM  USING  PS_LIST TYPE TY_ITEM_GR
                                           PT_RESB TYPE TY_T_PO_RESB
                                           PT_DELCOMP TYPE TY_T_PO_DELCOMP
                                           PT_MSLB TYPE TY_T_MSLB
                                           PT_EKPO TYPE TY_T_EKPO
                                           PT_ZGTMMT9450 TYPE TY_T_ZGTMMT9450
                                           PV_LGORT
                                           PV_CHARG TYPE CHARG_D
                                           PV_SQTY TYPE ZGTMM_CV_GET_OEM_DELIVERY_BASE-LOADQTY_M
                              CHANGING CT_ITEM TYPE TY_T_BAPI2017_GM_ITEM_CREATE
                                               PS_HEAD TYPE BAPI2017_GM_HEAD_01
                                               CV_CHECK.

  FIELD-SYMBOLS <LS_RESB> TYPE TY_PO_RESB.

  DATA : LT_LIST   LIKE TABLE OF GS_LIST,
         LS_HEAD   TYPE BAPI2017_GM_HEAD_01,
         LS_ITEM   TYPE BAPI2017_GM_ITEM_CREATE,
         LT_ITEM   TYPE TABLE OF BAPI2017_GM_ITEM_CREATE,
         LV_CODE   TYPE BAPI2017_GM_CODE-GM_CODE,
         LV_DOC    TYPE BAPI2017_GM_HEAD_RET-MAT_DOC,
         LV_MENGE  TYPE ZGTMM_CV_GET_OEM_DELIVERY_BASE-LOADQTY_M,
         LS_BATCH  TYPE BAPIBATCHATT,
         LS_BATCHX TYPE BAPIBATCHATTX,
         LV_MSG    TYPE BAPI_MSG.

  DATA :
    LV_VCQ       TYPE ERFMG,
    LV_TIME      TYPE I,
    LV_CNT_RUN   TYPE INT4,
    LV_START_IDX TYPE INT4,
    LV_END_IDX   TYPE INT4,
    LV_FACTOR .

  DATA:
    LT_RETURN   TYPE STANDARD TABLE OF BAPIRET2,
    LT_ALLOC    TYPE TABLE OF BAPI1003_ALLOC_VALUES_CHAR,
    LT_ALC_NUM  TYPE TABLE OF BAPI1003_ALLOC_VALUES_NUM,
    LT_ALC_CURR TYPE TABLE OF BAPI1003_ALLOC_VALUES_CURR,
    LV_CLASS    TYPE BAPI1003_KEY-CLASSNUM, "KLAH-CLASS,
    LV_STATUS   TYPE BAPI1003_KEY-STATUS,
    LV_KEY      TYPE BAPI1003_KEY-OBJECT,
    LV_MAT18    TYPE MATNR18,
    LV_LENTH    TYPE ATWRT30.

*BAPI ITEM LINE SET
  LS_ITEM-MATERIAL = PS_LIST-MATNR.
  LS_ITEM-PLANT = PS_LIST-WERKS.
  LS_ITEM-STGE_LOC = PV_LGORT.
  LS_ITEM-PO_NUMBER = PS_LIST-EBELN.
  LS_ITEM-PO_ITEM = PS_LIST-EBELP.
  LS_ITEM-MOVE_TYPE = '101'.
*DPCBT = 'A'(pv_gb = 'A')인 자재는 조회된 수량..
*아닌 자재는 *<적재수량(M)/적재수량(드럼)> 계산된 수량으로 설정.
  LS_ITEM-ENTRY_QNT = COND #( WHEN PS_LIST-DPCBT  = 'A' THEN PS_LIST-LOADQTY_M
                                             ELSE  PV_SQTY ).
  LS_ITEM-ENTRY_UOM = PS_LIST-MEINS.
*  item_text                    delno&-&delitem go2026020001-10
  LS_ITEM-ITEM_TEXT = PS_LIST-DELNO && '-' && PS_LIST-DELITEM.
*  ls_item-batch  = pv_charg.
  LS_ITEM-MVT_IND = GC_B.

*품목 범주에 따른 구분 추가.
  READ TABLE PT_EKPO ASSIGNING FIELD-SYMBOL(<EKPO>)
  WITH KEY EBELN = PS_LIST-EBELN
                 EBELP = PS_LIST-EBELP BINARY SEARCH.

*  CASE <ekpo>-pstyp.
*    WHEN space OR '0'. "일반
*CASE1. 일반 입고 : IT_TAB-PSTYP = ""
*1)배치관리 유형 FACTOR BATCH 면,(DPCBT = 'A') 조장정보로,
  IF PS_LIST-DPCBT = 'A'.
    LS_ITEM-BATCH  = PV_CHARG.
  ELSE.
*2)배치관리 유형 FACTOR BATCH 아니면, 자동채번.
    LS_ITEM-BATCH = ''.
  ENDIF.
*    WHEN OTHERS.
*  ENDCASE.

  LS_ITEM-LINE_ID = LINES( CT_ITEM ) + 1.
  CT_ITEM = VALUE #( BASE CT_ITEM ( LS_ITEM ) ).
*---메인 자재 아이템 구성 완료.

*---콤포넌트(하위자재) 아이템 추가 구성 시작_"외주 임가공인 경우만.
  CHECK  <EKPO>-PSTYP EQ GC_3.
*3-2-4-2) COMPONENT 소비량 산출(COMP_QTY)
*: 입고 수량 * 단위당소요량(RESB-BDMNG/EKPO-MENGE)
*COMPONENT 자재 항목 라인별로 BAPI ITEM 라인 추가
  DATA:
    LV_ERFMG   TYPE MENGV13,
    LV_ERFMG_O TYPE ERFMG.

  FIELD-SYMBOLS <LS_MSLB> TYPE TY_MSLB.

  DATA LS_COMP TYPE BAPI2017_GM_ITEM_CREATE.
  LS_COMP-PARENT_ID	 = LS_ITEM-LINE_ID. "메인자재의 lind_id
  LS_COMP-LINE_ID = LS_ITEM-LINE_ID. " 추가 위한 선 설정(추가시 여기에 +1)

  READ TABLE PT_DELCOMP WITH KEY EBELN = PS_LIST-EBELN
                                                    EBELP = PS_LIST-EBELP
                                                    DELNO = PS_LIST-DELNO
                                                    DELITEM = PS_LIST-DELITEM BINARY SEARCH TRANSPORTING NO FIELDS.
  IF SY-SUBRC EQ 0.
    "납품문서 COMPONENT 기준
    LOOP AT PT_DELCOMP ASSIGNING FIELD-SYMBOL(<LS_DELCOMP>) FROM SY-TABIX.
      IF <LS_DELCOMP>-EBELN NE PS_LIST-EBELN
        OR <LS_DELCOMP>-EBELP NE PS_LIST-EBELP
        OR <LS_DELCOMP>-DELNO NE PS_LIST-DELNO
        OR <LS_DELCOMP>-DELITEM NE PS_LIST-DELITEM.
        EXIT.
      ENDIF.

      LS_COMP-MATERIAL = <LS_DELCOMP>-IDNRK.
      LS_COMP-PLANT = <LS_DELCOMP>-WERKS.
      LS_COMP-STGE_LOC = <LS_DELCOMP>-LGORT.
      LS_COMP-PO_NUMBER = <LS_DELCOMP>-EBELN.
      LS_COMP-PO_ITEM = <LS_DELCOMP>-EBELP.
      LS_COMP-MOVE_TYPE = '543'.
      LS_COMP-BATCH = <LS_DELCOMP>-CHARG.
      LS_COMP-ENTRY_QNT = <LS_DELCOMP>-ISSUE_QTY.
      LS_COMP-ENTRY_UOM = <LS_DELCOMP>-ISSUE_UNIT.
      LS_COMP-MVT_IND = GC_B.

      "라인추가
      IF <LS_DELCOMP>-XCHPF EQ ABAP_TRUE AND <LS_DELCOMP>-CHARG EQ SPACE.
*"투입자재가 배치관리 자재이고 (ZGTMM_CV_SC_RESBLIST-XCHPF = 'X')
*PO_COMP-CHARG 값이 공백인 경우
*공급업체 재고 테이블 기준 BATCH 번호 추출 투입 처리(선입 선출 기준)
*TABLE : MSLB
*SELECT 조건 : LBLAB 0 이 아닌 CHARG
*WHERE 조건 :
*MATNR = PO_COMP-MATNR
*WERKS = PO_COMP_WERKS
*LIFNR = EKKO-LIFNR
        LV_ERFMG = LS_COMP-ENTRY_QNT. "대상 출고 수량
        READ TABLE PT_MSLB WITH KEY MATNR = <LS_DELCOMP>-IDNRK
                                                   WERKS = <LS_DELCOMP>-WERKS
                                                   LIFNR = <LS_DELCOMP>-LIFNR BINARY SEARCH TRANSPORTING NO FIELDS.
        IF SY-SUBRC EQ 0.
          LOOP AT PT_MSLB ASSIGNING <LS_MSLB> FROM SY-TABIX.
            IF <LS_MSLB>-MATNR NE <LS_DELCOMP>-IDNRK
              OR <LS_MSLB>-WERKS NE <LS_DELCOMP>-WERKS
              OR <LS_MSLB>-LIFNR NE <LS_DELCOMP>-LIFNR.
              EXIT.
            ENDIF.

            CHECK <LS_MSLB>-LBLAB GE 0. "재고수량이 0보다 큰 경우만 진행

            "적용 수량 빼기
            LV_ERFMG_O = LV_ERFMG.
            LV_ERFMG -= <LS_MSLB>-LBLAB.

            LS_COMP-BATCH = <LS_MSLB>-CHARG.

            IF LV_ERFMG LT 0.
              "적용한 수량이 대상 출고수량 보다 큰 경우
              IF <LS_MSLB>-XPCBT EQ ABAP_TRUE AND <LS_MSLB>-XPRGI EQ SPACE.
*"BATCH 별 투입 시 지정된 BATCH가 단일 배치단위이면 (MCH1-XPCBT='X')
*BATCH 가용재고전량투입 처리"
*& 부분수량 GI 허용이 SPACE 인 경우
                LS_COMP-ENTRY_QNT = <LS_MSLB>-LBLAB.
              ELSE.
                "단일 배치단위가 아니면 잔량적용
                LS_COMP-ENTRY_QNT = LV_ERFMG_O.
              ENDIF.
            ELSE.
              LS_COMP-ENTRY_QNT = <LS_MSLB>-LBLAB.
            ENDIF.

            "재고수량에서 적용수량 빼기
            <LS_MSLB>-LBLAB -=  LS_COMP-ENTRY_QNT.

            LS_COMP-LINE_ID += 1.
            CT_ITEM = VALUE #( BASE CT_ITEM ( LS_COMP ) ). "라인추가
*              ps_list-line_id = ls_comp-line_id.

            "적용 수량이 대상 출고수량을 초과한 경우 종료
            IF LV_ERFMG LE 0.
              EXIT.
            ENDIF.

          ENDLOOP.
        ELSE.
          LS_COMP-LINE_ID += 1.
          CT_ITEM = VALUE #( BASE CT_ITEM ( LS_COMP ) ).
*            ps_list-line_id = ls_comp-line_id.
        ENDIF.
      ELSE.
        LS_COMP-LINE_ID += 1.
        CT_ITEM = VALUE #( BASE CT_ITEM ( LS_COMP ) ).
*          ps_list-line_id = ls_comp-line_id.
      ENDIF.
    ENDLOOP.

  ELSE.
    READ TABLE PT_ZGTMMT9450 WITH KEY EBELN = PS_LIST-EBELN
                                                                 EBELP = PS_LIST-EBELP
                                                                 WERKS = PS_LIST-WERKS
                                                          BINARY SEARCH TRANSPORTING NO FIELDS.
    IF SY-SUBRC EQ 0.
*3-2-4-2) 외주임가공 투입정보 관리 이력 테이블 정보 점검(ISSUE_COMP)
*TABLE : ZGTMMT9450
*SELECT 조건 : IDNRK,CHARG,EBELN,EBELP,MENGE,MEINS
*WHRE 조건 : IT_TAB-EBELN,IT_TAB-EBELP,LIFNR,WERKS
*조회된  COMPONENT 자재,배치별 BAPI ITEM 라인 추가

      LOOP AT PT_ZGTMMT9450 ASSIGNING FIELD-SYMBOL(<LS_ZGTMMT9450>).

        LS_COMP-MATERIAL = <LS_ZGTMMT9450>-IDNRK.
        LS_COMP-PLANT = PS_LIST-WERKS.
        LS_COMP-PO_NUMBER = <LS_ZGTMMT9450>-EBELN.
        LS_COMP-PO_ITEM = <LS_ZGTMMT9450>-EBELP.
        LS_COMP-MOVE_TYPE = '543'.
        LS_COMP-BATCH = <LS_ZGTMMT9450>-CHARG.
        LS_COMP-ENTRY_UOM = <LS_ZGTMMT9450>-MEINS.
        LS_COMP-MVT_IND = GC_B.

*"1) ISSUE_COMP=CHARGE <> NULL
*  : ISSUE_COMP-MENGE
*2) ISSUE_COMP=CHARGE """" 이면
*  : PO 소요량정보로 입고수량 대비 투입 처리 수량 산출
*  -> 입고 수량 * 단위당소요량(RESB-BDMNG/EKPO-MENGE)"

        IF <LS_ZGTMMT9450>-CHARG IS NOT INITIAL.
          LS_COMP-ENTRY_QNT = <LS_ZGTMMT9450>-MENGE.
        ELSE.

          READ TABLE PT_RESB ASSIGNING <LS_RESB> WITH KEY  EBELN = <LS_ZGTMMT9450>-EBELN
                                                                                                EBELP = <LS_ZGTMMT9450>-EBELP
                                                                                                MATNR = <LS_ZGTMMT9450>-IDNRK.
          IF SY-SUBRC EQ 0.
            IF <LS_RESB>-MENGE IS NOT INITIAL.
              CLEAR LV_MENGE.
              LV_MENGE = COND #( WHEN PS_LIST-DPCBT  = 'A' THEN PS_LIST-LOADQTY_M ELSE  PV_SQTY ).
              LS_COMP-ENTRY_QNT = LV_MENGE * ( <LS_RESB>-BDMNG / <LS_RESB>-MENGE ).
            ELSE.
              LS_COMP-ENTRY_QNT = 0.
            ENDIF.
          ELSE.
            CV_CHECK = GC_E.
            EXIT.
          ENDIF.
        ENDIF.

        LS_COMP-LINE_ID += 1.
        CT_ITEM = VALUE #( BASE CT_ITEM ( LS_COMP ) ).
*          ps_list-line_id = ls_comp-line_id.
      ENDLOOP.

    ELSE.
      "PO COMPONENT 기준
      READ TABLE PT_RESB WITH KEY EBELN = PS_LIST-EBELN
                                                     EBELP = PS_LIST-EBELP
                                                        BINARY SEARCH TRANSPORTING NO FIELDS.
      IF SY-SUBRC EQ 0.
        LOOP AT PT_RESB ASSIGNING <LS_RESB> FROM SY-TABIX.
          IF <LS_RESB>-EBELN NE PS_LIST-EBELN
            OR <LS_RESB>-EBELP NE PS_LIST-EBELP.
            EXIT.
          ENDIF.

          LS_COMP-MATERIAL = <LS_RESB>-MATNR.
          LS_COMP-PLANT = <LS_RESB>-WERKS.
          LS_COMP-STGE_LOC = <LS_RESB>-LGORT.
          LS_COMP-PO_NUMBER = <LS_RESB>-EBELN.
          LS_COMP-PO_ITEM = <LS_RESB>-EBELP.
          LS_COMP-MOVE_TYPE = '543'.
          LS_COMP-BATCH = <LS_RESB>-CHARG.
          IF <LS_RESB>-MENGE IS NOT INITIAL.
            CLEAR LV_MENGE.
            LV_MENGE = COND #( WHEN PS_LIST-DPCBT  = 'A' THEN PS_LIST-LOADQTY_M ELSE  PV_SQTY ).
            LS_COMP-ENTRY_QNT = LV_MENGE * ( <LS_RESB>-BDMNG / <LS_RESB>-MENGE ).
          ELSE.
            LS_COMP-ENTRY_QNT = 0.
          ENDIF.
          LS_COMP-ENTRY_UOM = <LS_RESB>-MEINS.
          LS_COMP-MVT_IND = GC_B.

          "라인추가
          IF <LS_RESB>-XCHPF EQ ABAP_TRUE AND <LS_RESB>-CHARG EQ SPACE.
*"투입자재가 배치관리 자재이고 (ZGTMM_CV_SC_RESBLIST-XCHPF = 'X')
*PO_COMP-CHARG 값이 공백인 경우
*공급업체 재고 테이블 기준 BATCH 번호 추출 투입 처리(선입 선출 기준)
*TABLE : MSLB
*SELECT 조건 : LBLAB 0 이 아닌 CHARG
*WHERE 조건 :
*MATNR = PO_COMP-MATNR
*WERKS = PO_COMP_WERKS
*LIFNR = EKKO-LIFNR
            LV_ERFMG = LS_COMP-ENTRY_QNT. "대상 출고 수량
            READ TABLE PT_MSLB WITH KEY MATNR = <LS_RESB>-MATNR
                                                       WERKS = <LS_RESB>-WERKS
                                                       LIFNR = <LS_RESB>-LIFNR BINARY SEARCH TRANSPORTING NO FIELDS.
            IF SY-SUBRC EQ 0.
              LOOP AT PT_MSLB ASSIGNING <LS_MSLB> FROM SY-TABIX.
                IF <LS_MSLB>-MATNR NE <LS_RESB>-MATNR
                  OR <LS_MSLB>-WERKS NE <LS_RESB>-WERKS
                  OR <LS_MSLB>-LIFNR NE <LS_RESB>-LIFNR.
                  EXIT.
                ENDIF.

                CHECK <LS_MSLB>-LBLAB GE 0. "재고수량이 0보다 큰 경우만 진행

                "적용 수량 빼기
                LV_ERFMG_O = LV_ERFMG.
                LV_ERFMG -= <LS_MSLB>-LBLAB.

                LS_COMP-BATCH = <LS_MSLB>-CHARG.

                IF LV_ERFMG LT 0.
                  "적용한 수량이 대상 출고수량 보다 큰 경우
                  IF <LS_MSLB>-XPCBT EQ ABAP_TRUE AND <LS_MSLB>-XPRGI EQ SPACE.
*"BATCH 별 투입 시 지정된 BATCH가 단일 배치단위이면 (MCH1-XPCBT='X')
*BATCH 가용재고전량투입 처리"
* & 부분수량 GI 허용이 SPACE 인 경우
                    LS_COMP-ENTRY_QNT = <LS_MSLB>-LBLAB.
                  ELSE.
                    "단일 배치단위가 아니면 잔량적용
                    LS_COMP-ENTRY_QNT = LV_ERFMG_O.
                  ENDIF.
                ELSE.
                  LS_COMP-ENTRY_QNT = <LS_MSLB>-LBLAB.
                ENDIF.

                "재고수량에서 적용수량 빼기
                <LS_MSLB>-LBLAB -=  LS_COMP-ENTRY_QNT.

                LS_COMP-LINE_ID += 1.
                CT_ITEM = VALUE #( BASE CT_ITEM ( LS_COMP ) ). "라인추가
*                  ps_list-line_id = ls_comp-line_id.

                "적용 수량이 대상 출고수량을 초과한 경우 종료
                IF LV_ERFMG LE 0.
                  EXIT.
                ENDIF.

              ENDLOOP.

            ELSE.
              LS_COMP-LINE_ID += 1.
              CT_ITEM = VALUE #( BASE CT_ITEM ( LS_COMP ) ).
*                ps_list-line_id = ls_comp-line_id.
            ENDIF.

          ELSE.
            LS_COMP-LINE_ID += 1.
            CT_ITEM = VALUE #( BASE CT_ITEM ( LS_COMP ) ).
*              ps_list-line_id = ls_comp-line_id.
          ENDIF.

        ENDLOOP.
      ENDIF.
    ENDIF.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& FORM GET_DELCOMP
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
*&      --> GT_LIST_S
*&      <-- LT_DELCOMP
*&---------------------------------------------------------------------*
FORM GET_DELCOMP  USING PT_TAB TYPE  TY_T_ITEM_GR
                             CHANGING CT_DELCOMP TYPE TY_T_PO_DELCOMP.
**COMPONENT  자재 투입 처리 기준 참조 우선순위 조건
*1) 납품문서 기준 COMPONENT 투입 정보가 존재하는 경우 정보 점검(DEL_COMP)
* 납품 문서->마지막 수신 받은 KEY 기준 ZGTMMT9410-STATUS <>X 인 대상
*	TABLE: ZGTMMT9412
*	SELECT조건 : IDNRK,CHARG,WERKS,WERKS,ISSUE_QTY,ISSUE_UNIT,EBELN,EBELP
*	WHERE 조건:
*	DELNO = IT_TAB-DELNO
*	DELITEM = IT_TAB-DELITEM
*	EBELN = IT_TAB-EBELN
*	EBELP = IT_TAB-EBELP

  WITH
  +V_MAX AS (
      SELECT
      Z1~SYSTEM_ID,
      Z1~DELNO,
      Z1~DELITEM,
      Z1~WERKS,
      MAX( Z1~ZIFKEY ) AS ZIFKEY
      FROM ZGTMMT9410 AS Z1
      WHERE EXISTS (
##ITAB_KEY_IN_SELECT
        SELECT ZZ~DELNO
          FROM @PT_TAB AS ZZ
          WHERE ZZ~EBELN EQ Z1~EBELN
          AND ZZ~EBELP EQ Z1~EBELP
          AND ZZ~DELNO EQ Z1~DELNO
          AND ZZ~DELITEM EQ Z1~DELITEM
          AND ZZ~WERKS EQ Z1~WERKS
      )
      AND Z1~SYSTEM_ID EQ @GC_KSRM
      GROUP BY Z1~SYSTEM_ID, Z1~DELNO, Z1~DELITEM, Z1~WERKS
  )
  SELECT
      Z1~EBELN,
      Z1~EBELP,
      Z1~DELNO,
      Z1~DELITEM,
      Z2~IDNRK,
      Z2~LIFNR,
      Z2~CHARG,
      Z2~WERKS,
      Z2~LGORT,
      Z2~ISSUE_QTY,
      Z2~ISSUE_UNIT,
      MC~XCHPF
    FROM +V_MAX AS V1
                INNER JOIN
           ZGTMMT9410 AS Z1 ON V1~SYSTEM_ID EQ Z1~SYSTEM_ID
                                       AND V1~DELNO EQ Z1~DELNO
                                       AND V1~DELITEM EQ Z1~DELITEM
                                       AND V1~WERKS EQ Z1~WERKS
                                       AND V1~ZIFKEY EQ Z1~ZIFKEY
                INNER JOIN
           ZGTMMT9412 AS Z2 ON V1~SYSTEM_ID EQ Z2~SYSTEM_ID
                                       AND V1~DELNO EQ Z2~DELNO
                                       AND V1~DELITEM EQ Z2~DELITEM
                                       AND V1~WERKS EQ Z2~WERKS
                                       AND V1~ZIFKEY EQ Z2~ZIFKEY
                INNER JOIN
           MARC AS MC ON Z2~IDNRK EQ MC~MATNR
                            AND Z2~WERKS EQ MC~WERKS
      WHERE Z1~STATUS EQ @SPACE
     ORDER BY Z1~EBELN, Z1~EBELP, Z1~DELNO, Z1~DELITEM
     INTO CORRESPONDING FIELDS OF TABLE @CT_DELCOMP.

ENDFORM.
*&---------------------------------------------------------------------*
*& FORM GET_ZGTMMT9450
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
*&      --> LT_TAB
*&      <-- LT_ZGTMMT9450
*&---------------------------------------------------------------------*
FORM GET_ZGTMMT9450  USING    PT_TAB TYPE TY_T_ITEM_GR
                                CHANGING PT_ZGTMMT9450 TYPE TY_T_ZGTMMT9450.
**COMPONENT  자재 투입 처리 기준 참조 우선순위 조건
*1)조건에 맞지 않으면, 2)외주임가공 투입정보 관리 이력 테이블 정보 점검(ISSUE_COMP)
*	TABLE : ZGTMMT9450
*	SELECT 조건 : IDNRK,CHARG,EBELN,EBELP,MENGE,MEINS
*	WHRE 조건 : IT_TAB-EBELN,IT_TAB-EBELP,LIFNR,WERKS

  ##ITAB_KEY_IN_SELECT
  SELECT
    Z1~EBELN,
    Z1~EBELP,
    Z1~WERKS,
    Z1~IDNRK,
    Z1~CHARG,
    Z1~MENGE,
    Z1~MEINS
    FROM ZGTMMT9450 AS Z1
    WHERE EXISTS (
      SELECT @ABAP_TRUE
      FROM @PT_TAB AS ZZ
      WHERE ZZ~EBELN EQ Z1~EBELN
        AND ZZ~EBELP EQ Z1~EBELP
        AND ZZ~WERKS EQ Z1~WERKS
    )
    ORDER BY Z1~EBELN, Z1~EBELP, Z1~WERKS
    INTO CORRESPONDING FIELDS OF TABLE @PT_ZGTMMT9450.

ENDFORM.
*&---------------------------------------------------------------------*
*& FORM GET_PO_RESB
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
*&      --> LT_LOG_DATA
*&      <-- LT_RESB
*&---------------------------------------------------------------------*
FORM GET_PO_RESB  USING  PT_TAB TYPE TY_T_ITEM_GR
                             CHANGING CT_RESB TYPE TY_T_PO_RESB.
**COMPONENT  자재 투입 처리 기준 참조 우선순위 조건
*납품문서 투입실적, 임가공 투입정보 정보가 존재하지 않는 경우,3번째 기준.
*3) 구매오더의 COMPONENT 자재 정보추출(PO_COMP)
*	TABLE ; RESB
*	SELECT조건 : RSPOS,MATNR,BDMNG,MEINS,WERKS,LGORT,CHARG
*	WHRE 조건 : IT_TAB-EBELN, IT-TAB-EBELP
*3-1) COMPONENT 소비량 산출(COMP_QTY)
*  입고 수량 * 단위당소요량(RESB-BDMNG/EKPO-MENGE)

  SELECT
    EP~EBELN,
    EP~EBELP,
    EP~MENGE,
    RS~RSNUM,
    RS~RSPOS,
    RS~BDMNG,
    RS~MATNR,
    RS~MEINS,
    RS~WERKS,
    RS~LGORT,
    RS~CHARG,
    MC~XCHPF,
    EK~LIFNR
    FROM EKPO AS EP
              INNER JOIN
            RESB AS RS ON EP~EBELN EQ RS~EBELN
                          AND EP~EBELP EQ RS~EBELP
              INNER JOIN
            MARC AS MC ON RS~MATNR EQ MC~MATNR
                             AND RS~WERKS EQ MC~WERKS
              INNER JOIN
            EKKO AS EK ON EP~EBELN EQ EK~EBELN
    WHERE EP~PSTYP EQ @GC_3
    AND EXISTS (
##ITAB_KEY_IN_SELECT
      SELECT ZZ~EBELN, ZZ~EBELP
        FROM @PT_TAB AS ZZ
        WHERE ZZ~EBELN EQ EP~EBELN
           AND ZZ~EBELP EQ EP~EBELP
    )
    AND EP~LOEKZ EQ @SPACE
    AND RS~XLOEK EQ @SPACE
    ORDER BY EP~EBELN, EP~EBELP, RS~RSNUM, RS~RSPOS
    INTO TABLE @CT_RESB.

ENDFORM.
*&---------------------------------------------------------------------*
*& FORM F_GET_MSLB_POGR_RCV
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
*&      --> LT_RESB
*&      --> LT_DELCOMP
*&      <-- LT_MSLB
*&---------------------------------------------------------------------*
FORM GET_MSLB  USING PT_RESB TYPE TY_T_PO_RESB
                                                             PT_DELCOMP TYPE TY_T_PO_DELCOMP
                                            CHANGING CT_MSLB TYPE TY_T_MSLB.

*"투입자재가 배치관리 자재이고 (ZGTMM_CV_SC_RESBLIST-XCHPF = 'X')
*PO_COMP-CHARG 값이 공백인 경우, 4번째 우선순위 기준.
*4)공급업체 재고 테이블 기준 BATCH 번호 추출 투입 처리(선입 선출 기준)
*TABLE : MSLB
*SELECT 조건 : LBLAB 0 이 아닌 CHARG
*WHERE 조건 :
*MATNR = PO_COMP-MATNR
*WERKS = PO_COMP_WERKS
*LIFNR = EKKO-LIFNR"
*"BATCH 별 투입 시 지정된 BATCH가 단일 배치단위이면 (MCH1-XPCBT='X')
*BATCH 가용재고전량투입 처리"

  DATA:
    BEGIN OF LS_KEY,
      MATNR TYPE MSLB-MATNR,
      WERKS TYPE MSLB-WERKS,
      LIFNR TYPE MSLB-LIFNR,
    END OF LS_KEY,
    LT_KEY LIKE STANDARD TABLE OF LS_KEY.

  "KEY 생성
  ##ITAB_KEY_IN_SELECT
  ##ITAB_DB_SELECT
  SELECT DISTINCT
    ZZ~MATNR,
    ZZ~WERKS,
    ZZ~LIFNR
    FROM @PT_RESB AS ZZ
    WHERE ZZ~XCHPF EQ @ABAP_TRUE
    AND ZZ~CHARG EQ @SPACE
    APPENDING TABLE @LT_KEY.

  ##ITAB_DB_SELECT
  ##ITAB_KEY_IN_SELECT
  SELECT DISTINCT
    ZZ~IDNRK,
    ZZ~WERKS,
    ZZ~LIFNR
    FROM @PT_DELCOMP AS ZZ
    WHERE ZZ~XCHPF EQ @ABAP_TRUE
    AND ZZ~CHARG EQ @SPACE
    APPENDING TABLE @LT_KEY.

  "중복제거
  SORT LT_KEY BY MATNR WERKS LIFNR.
  DELETE ADJACENT DUPLICATES FROM LT_KEY COMPARING MATNR WERKS LIFNR.

  "재고조회
  ##ITAB_KEY_IN_SELECT
  SELECT
    MS~MATNR,
    MS~WERKS,
    MS~CHARG,
    MS~LIFNR,
    MS~LBLAB,
    MC~XPCBT
    FROM @LT_KEY AS ZZ
              INNER JOIN
            MSLB AS MS ON ZZ~MATNR EQ MS~MATNR
                              AND ZZ~WERKS EQ MS~WERKS
                              AND ZZ~LIFNR EQ MS~LIFNR
              INNER JOIN
            MCH1 AS MC ON MS~MATNR EQ MC~MATNR
                             AND MS~CHARG EQ MC~CHARG
    WHERE MS~LBLAB IS NOT INITIAL
    ORDER BY MS~MATNR, MS~WERKS, MS~LIFNR, MC~LWEDT, MS~CHARG
    INTO TABLE @CT_MSLB.


  "부분수량 GI 허용 플래그
  ##ITAB_KEY_IN_SELECT
  SELECT MM~MATNR
    FROM MARM AS MM
    WHERE EXISTS (
      SELECT ZZ~MATNR
        FROM @CT_MSLB AS ZZ
        WHERE ZZ~MATNR EQ MM~MATNR
    )
    AND MM~ATINN IS NOT INITIAL
    AND MM~PCBUT EQ @GC_B
    ORDER BY MM~MATNR
    INTO TABLE @DATA(LT_MARM).

  LOOP AT CT_MSLB ASSIGNING FIELD-SYMBOL(<LS_MSLB>).
    READ TABLE LT_MARM WITH KEY MATNR = <LS_MSLB>-MATNR BINARY SEARCH TRANSPORTING NO FIELDS.
    CHECK SY-SUBRC EQ 0.
    <LS_MSLB>-XPRGI = ABAP_TRUE.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form update_batchclass
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> <LS_GR>
*&---------------------------------------------------------------------*
FORM UPDATE_BATCHCLASS  USING    PS_GR TYPE TY_ITEM_GR.

  DATA:
    LT_RETURN   TYPE STANDARD TABLE OF BAPIRET2,
    LT_ALLOC    TYPE TABLE OF BAPI1003_ALLOC_VALUES_CHAR,
    LT_ALC_NUM  TYPE TABLE OF BAPI1003_ALLOC_VALUES_NUM,
    LT_ALC_CURR TYPE TABLE OF BAPI1003_ALLOC_VALUES_CURR,
    LV_CLASS    TYPE BAPI1003_KEY-CLASSNUM,
    LV_CHARG    TYPE CHARG_D,
    LV_STATUS   TYPE BAPI1003_KEY-STATUS.

  CHECK PS_GR-DPCBT = 'A'.

  CALL FUNCTION 'CLFC_BATCH_ALLOCATION_TO_CLASS'
    EXPORTING
      MATERIAL           = PS_GR-MATNR "입고자재
      PLANT              = PS_GR-WERKS "플랜트
      CLASSTYPE          = '023'       "클래스유형(배치)
    IMPORTING
      CLASS              = LV_CLASS
    EXCEPTIONS
      NO_CLASS_FOUND     = 1
      NO_CLASSTYPE_FOUND = 2
      OTHERS             = 3.

  CHECK LV_CLASS IS NOT INITIAL.
*3-2-3)배치 클래스 속성 정보 업데이트  BAPI 수행
  DATA(LV_LENGTH) = CONV INT4( PS_GR-LENGTH ).
  LV_CHARG = LV_LENGTH. "배치번호 = 조장

  CLEAR LT_ALC_NUM.
  LT_ALC_NUM[] = VALUE #( BASE LT_ALC_NUM
                                        ( CHARACT = 'SAP_MILLCA_LENGTH'
                                          VALUE_FROM = PS_GR-LENGTH )
                                        ( CHARACT = 'SAP_MILLCA_LENGTH_SUB'
                                          VALUE_FROM = PS_GR-LENGTH ) ).

  SELECT SINGLE CUOBJ_BM
       FROM MCH1
     WHERE MATNR = @PS_GR-MATNR
          AND CHARG = @LV_CHARG
     INTO @DATA(LV_OBJKEY).

  IF LV_OBJKEY IS NOT INITIAL.
    CLEAR : LT_RETURN.

    CALL FUNCTION 'BAPI_OBJCL_CHANGE_KEY'
      EXPORTING
        CLOBJECTKEY         = LV_OBJKEY
        CLASSNUM            = LV_CLASS
      IMPORTING
        CLASSIF_STATUS      = LV_STATUS
      TABLES
        ALLOCVALUESNUM_NEW  = LT_ALC_NUM
        ALLOCVALUESCHAR_NEW = LT_ALLOC
        ALLOCVALUESCURR_NEW = LT_ALC_CURR
        RETURN              = LT_RETURN.

    READ TABLE LT_RETURN ASSIGNING FIELD-SYMBOL(<LS_R2TURN>) WITH KEY TYPE = GC_E.
    IF SY-SUBRC EQ 0.
*      오류
      CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
    ELSE.
*      배치특성 성공
      CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
        EXPORTING
          WAIT = ABAP_TRUE.
    ENDIF.
  ENDIF.

ENDFORM.
