*&---------------------------------------------------------------------*
*& INCLUDE          ZGTMMR4370F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& FORM CREATE_ALV
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
FORM CREATE_ALV .

  PERFORM :
            SET_CONTAINER USING GC_100,
*            SET_ALV_GRID USING GC_100,
            SET_ALV_FIELDCAT USING '0',
            SET_ALV_LAYOUT,
            SET_ALV_TOOLBAR,
            SET_EVENT        CHANGING GCL_EVENT GCL_GRID,
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
*              SET_ALV_GRID    USING GC_300,
*              SET_ALV_FIELDCAT USING '1', "HEADER
              SET_ALV_FIELDCAT USING '2', "ITEM
              SET_ALV_LAYOUT,
              SET_ALV_TOOLBAR ,   "
              SET_EVENT             CHANGING GCL_EVENT2 GCL_GRID_HD,
*              SET_EVENT2           CHANGING GCL_EVENT2 GCL_GRID_IT,
              DISPLAY_ALV          TABLES GT_FCAT_HD GT_ITEM GT_EXCLUD
                                            USING GCL_GRID_HD.
*              DISPLAY_ALV          TABLES GT_FCAT_IT GT_ITEM GT_EXCLUD
*                                            USING GCL_GRID_IT.

ENDFORM.

*&---------------------------------------------------------------------*
*& FORM SET_CONTAINER
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
FORM SET_CONTAINER USING PV_GB.

*  DATA:
*    LO_SPLIT TYPE REF TO CL_GUI_SPLITTER_CONTAINER,
*    LO_HCNTR TYPE REF TO CL_GUI_CONTAINER,
*    LO_ICNTR TYPE REF TO CL_GUI_CONTAINER.

  CASE PV_GB.
*자재성적서DOWMLOAD(RB_DOWM)
    WHEN GC_100.
      IF GCL_DOCKING IS NOT BOUND.

        CREATE OBJECT GCL_DOCKING
          EXPORTING
            REPID     = SY-REPID
            DYNNR     = SY-DYNNR
            SIDE      = CL_GUI_DOCKING_CONTAINER=>DOCK_AT_LEFT
            EXTENSION = 2500.

        "ALV OBJ.
        GCL_GRID = NEW #( I_PARENT = GCL_DOCKING ).

      ENDIF.

*OEM검사관리(RB_OEM)
    WHEN GC_300.
      IF GCL_DOCKING2 IS NOT BOUND.

        CREATE OBJECT GCL_DOCKING2
          EXPORTING
            REPID     = SY-REPID
            DYNNR     = SY-DYNNR
            SIDE      = CL_GUI_DOCKING_CONTAINER=>DOCK_AT_LEFT
            EXTENSION = 2500.

        "ALV OBJ.
        GCL_GRID_HD = NEW #( I_PARENT = GCL_DOCKING2 ).

*      "SPLIT CONTAINER
*        LO_SPLIT = NEW #( PARENT    = GCL_CUSTOM
*                                      ROWS       = 2
*                                      COLUMNS = 1 ).
*
*        LO_HCNTR = LO_SPLIT->GET_CONTAINER( ROW = 1 COLUMN = 1 ).
*        LO_ICNTR  = LO_SPLIT->GET_CONTAINER( ROW = 2 COLUMN = 1 ).

        "ALV OBJ.
**HEADER<->ITEM 그리드 서로 위치 변경.
*        GCL_GRID_IT = NEW #( I_PARENT = LO_HCNTR ).
*        GCL_GRID_HD = NEW #( I_PARENT = LO_ICNTR ).
**        GCL_GRID_HD = NEW #( I_PARENT = LO_HCNTR ).
**        GCL_GRID_IT = NEW #( I_PARENT = LO_ICNTR ).

      ENDIF.

    WHEN OTHERS.
  ENDCASE.

ENDFORM.

*&---------------------------------------------------------------------*
*& FORM SET_ALV_GRID
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
FORM SET_ALV_GRID USING PV_GB.

  CASE  PV_GB.
*자재성적서DOWMLOAD(RB_DOWM)
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

*OEM검사관리(RB_OEM)
    WHEN GC_300.
      IF GCL_GRID_HD IS NOT BOUND.
        CREATE OBJECT GCL_GRID_HD
          EXPORTING
            I_PARENT          = GCL_CUSTOM_HD
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
            I_PARENT          = GCL_CUSTOM_IT
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
*& FORM ADJUST_FLDCATS_300
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
FORM ADJUST_FLDCATS_300 TABLES PT_FCAT TYPE LVC_T_FCAT.

  DEFINE _FCAT.
    <FS_S_FCT>-SCRTEXT_S  =
    <FS_S_FCT>-SCRTEXT_M  =
    <FS_S_FCT>-SCRTEXT_L  =
    <FS_S_FCT>-COLTEXT    =
    <FS_S_FCT>-REPTEXT    = &1.
  END-OF-DEFINITION.

  DATA LV_COL TYPE I.
  CLEAR : GT_FCAT_HD[].

  LOOP AT PT_FCAT ASSIGNING FIELD-SYMBOL(<FS_S_FCT>).
    CLEAR : <FS_S_FCT>-COL_POS.

    CASE <FS_S_FCT>-FIELDNAME.

      WHEN 'STATUS'.    "상태
        _FCAT TEXT-F47.
        <FS_S_FCT>-ICON = GC_X.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'BUKRS'.    "회사코드
        _FCAT TEXT-F01.
        <FS_S_FCT>-NO_OUT = GC_X.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'EBELN'.      "구매오더
        _FCAT TEXT-F02.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'EBELP'.      "항번
        _FCAT TEXT-F03.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'AEDAT'.      "구매오더생성일
        _FCAT TEXT-F04.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'EINDT'.      "납품예정일
        _FCAT TEXT-F05.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'WERKS'.      "플랜트
        _FCAT TEXT-F06.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'LIFNR'.     "공급업체코드
        _FCAT TEXT-F07.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'LIFNR_N'.
        _FCAT TEXT-F08.
        <FS_S_FCT>-JUST = 'C'.
        <FS_S_FCT>-EMPHASIZE = 'C300'.
      WHEN 'VBELN'.     "판매문서
        _FCAT TEXT-F09.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'POSNR'.    "항번
        _FCAT TEXT-F03.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'KUNNR'.       "고객코드
        _FCAT TEXT-F10.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'KUNNR_N'.
        _FCAT TEXT-F11.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'VKBUR'.     "영업팀
        _FCAT TEXT-F12.
        <FS_S_FCT>-NO_OUT = GC_X.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'VKBUR_N'.  "영업팀명
        _FCAT TEXT-F13.
        <FS_S_FCT>-JUST = 'C'.
        <FS_S_FCT>-EMPHASIZE = 'C400'.
      WHEN 'VKGRP'.     "영업그룹
        _FCAT TEXT-F14.
        <FS_S_FCT>-NO_OUT = GC_X.
        <FS_S_FCT>-JUST = 'C'.

      WHEN 'VKGRP_N'.  "영업그룹명
        _FCAT TEXT-F15.
        <FS_S_FCT>-JUST = 'C'.
        <FS_S_FCT>-EMPHASIZE = 'C400'.
      WHEN 'MATNR'.      "
        _FCAT TEXT-F16.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'MAKTX'.      "
        _FCAT TEXT-F17.
        <FS_S_FCT>-JUST = 'C'.
        <FS_S_FCT>-EMPHASIZE = 'C410'.
      WHEN 'COLOR'.      "색상
        _FCAT TEXT-F18.
        <FS_S_FCT>-JUST = 'C'.
        <FS_S_FCT>-EMPHASIZE = 'C410'.
      WHEN 'MENGE'.     "발주수량(M)
        _FCAT TEXT-F19.     "
        <FS_S_FCT>-QFIELDNAME = 'MEINS'.
        <FS_S_FCT>-JUST = 'R'.
        <FS_S_FCT>-EMPHASIZE = 'C300'.
      WHEN 'MEINS'.      "발주단위
        _FCAT TEXT-F20.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'LENGTH'.      "조장
        _FCAT TEXT-F21.
        <FS_S_FCT>-JUST = 'C'.
        <FS_S_FCT>-EMPHASIZE = 'C700'.
      WHEN 'DRQTY'.     "드럼수
        _FCAT TEXT-F22.
        <FS_S_FCT>-QFIELDNAME = 'DR_MEINS'.
        <FS_S_FCT>-JUST = 'R'.
        <FS_S_FCT>-EMPHASIZE = 'C300'.
      WHEN 'DR_MEINS'.      "드럼단위
        _FCAT TEXT-F23.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'INSPECTION'.      "입회검사여부
        _FCAT TEXT-F50.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'GR_QTY_M'.     "입고수량(M)
        _FCAT TEXT-F24.
        <FS_S_FCT>-QFIELDNAME = 'GR_MEINS_M'.
        <FS_S_FCT>-JUST = 'R'.
      WHEN 'GR_MEINS_M'.      "입고단위
        _FCAT TEXT-F25.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'GR_QTY_DR'.     "입고량(드럼)
        _FCAT TEXT-F26.
        <FS_S_FCT>-QFIELDNAME = 'DR_MEINS'.
        <FS_S_FCT>-JUST = 'R'.
      WHEN 'REQDATE'.     "직송요청일
        _FCAT TEXT-F27.
        <FS_S_FCT>-JUST = 'C'.

      WHEN 'QI_REQ_QTY'.     "검사요청수(DR)
        _FCAT TEXT-F28.
        <FS_S_FCT>-QFIELDNAME = 'DR_MEINS'.
        <FS_S_FCT>-JUST = 'R'.
        <FS_S_FCT>-EMPHASIZE = 'C300'.
      WHEN 'QI_RESULT_QTY'.     "검사완료수(DR)
        _FCAT TEXT-F29.
        <FS_S_FCT>-QFIELDNAME = 'DR_MEINS'.
        <FS_S_FCT>-JUST = 'R'.
        <FS_S_FCT>-EMPHASIZE = 'C300'.
      WHEN 'ELIKZ'.     "구매종료
        _FCAT TEXT-F30.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'QI_CLOSE'.   "검사대상
        _FCAT TEXT-F31.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'ZINSP_NO'.      "검사요청번호
        _FCAT TEXT-F32.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'ZINSP_QTY'.      " 검사요청수량(DR)
        _FCAT TEXT-F28.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'QCMEINS'.    "단위
        _FCAT 'QC단위'."TEXT-F33.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'ZINSP_DATE'.  "검사요청일
        _FCAT TEXT-F34.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'ZINSPTYPE'.      "검사방법
        _FCAT TEXT-F35.
        <FS_S_FCT>-F4AVAILABL = GC_X.
        <FS_S_FCT>-REF_TABLE = 'ZGTMMT4402'.
        <FS_S_FCT>-REF_FIELD  = 'ZINSPTYPE'.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'ZINSPTYPE_N'.      "검사방법명
        _FCAT TEXT-F36.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'ZINSPDATE'.      "출장검사예정일
        _FCAT TEXT-F48.
        <FS_S_FCT>-F4AVAILABL = GC_X.
        <FS_S_FCT>-REF_TABLE = 'SYST' ."'ZGTMMT4402'.
        <FS_S_FCT>-REF_FIELD  = 'DATUM' ."'ZINSPDATE'.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'ZINSP_PERNO'.      "출장담당자사번
        _FCAT TEXT-F49.
        <FS_S_FCT>-EDIT = GC_X.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'ZINSP_NAME'.      "출장담당자명
        _FCAT TEXT-F37.
        <FS_S_FCT>-EDIT = GC_X.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'ZINSPRES'.      "검사결과
        _FCAT TEXT-F38.
        <FS_S_FCT>-EDIT = GC_X.
        <FS_S_FCT>-F4AVAILABL = GC_X.
        <FS_S_FCT>-REF_TABLE = 'ZGTMMT4402'.
        <FS_S_FCT>-REF_FIELD  = 'ZINSPRES'.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'ZINSPRES_N'.      "검사결과명
        _FCAT TEXT-F39.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'ZINSP_CERTI'.   "성적서 경로
        _FCAT TEXT-F40.
        <FS_S_FCT>-HOTSPOT = GC_X.
        <FS_S_FCT>-JUST = 'L'.
        <FS_S_FCT>-EMPHASIZE = 'C601'.
      WHEN 'QCREQDATE'.   "검사요청등록일
        _FCAT TEXT-F51.
        <FS_S_FCT>-JUST = 'C'.
        <FS_S_FCT>-EMPHASIZE = 'C300'.
      WHEN OTHERS.
        <FS_S_FCT>-NO_OUT = GC_X.
    ENDCASE.

    APPEND <FS_S_FCT> TO GT_FCAT_HD.
  ENDLOOP.

ENDFORM.

*&---------------------------------------------------------------------*
*& FORM ADJUST_FLDCATS
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
FORM ADJUST_FLDCATS  TABLES PT_FCAT TYPE LVC_T_FCAT.

  DEFINE _FCAT.
    <FS_S_FCT>-SCRTEXT_S  =
    <FS_S_FCT>-SCRTEXT_M  =
    <FS_S_FCT>-SCRTEXT_L  =
    <FS_S_FCT>-COLTEXT    =
    <FS_S_FCT>-REPTEXT    = &1.
  END-OF-DEFINITION.

  DATA LV_COL TYPE I.
  CLEAR : GT_FCAT[].

  LOOP AT PT_FCAT ASSIGNING FIELD-SYMBOL(<FS_S_FCT>).
    CLEAR : <FS_S_FCT>-COL_POS.

    CASE <FS_S_FCT>-FIELDNAME.

      WHEN 'DELNO'.     "납품서
        _FCAT TEXT-F41.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'DELITEM	'.
        _FCAT TEXT-F03.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'LIFNR'.       "
        _FCAT TEXT-F07.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'LIFNR_N'.       "
        _FCAT TEXT-F08.
        <FS_S_FCT>-JUST = 'C'.
        <FS_S_FCT>-EMPHASIZE = 'C200'.
      WHEN 'BUKRS'.    "
        _FCAT TEXT-F01.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'WERKS'.    "
        _FCAT TEXT-F06.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'EBELN'.       "
        _FCAT TEXT-F02.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'EBELP'.       "
        _FCAT TEXT-F03.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'AEDAT'.     "구매오더생성일
        _FCAT TEXT-F04.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'MATNR'.     "
        _FCAT TEXT-F16.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'MAKTX'.     "
        _FCAT TEXT-F17.
        <FS_S_FCT>-JUST = 'C'.
        <FS_S_FCT>-EMPHASIZE = 'C410'.
      WHEN 'LGORT	'. "
        _FCAT TEXT-F42.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'LGORT_N	'.
        _FCAT TEXT-F43.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'MENGE	'.
        _FCAT TEXT-F44.
        <FS_S_FCT>-JUST = 'R'.
        <FS_S_FCT>-EMPHASIZE = 'C300'.
      WHEN 'MEINS'.     "
        _FCAT TEXT-F33.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'BUDAT'.     "납품예정일
        _FCAT TEXT-F05.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'LICHA	'.       "업체LOT
        _FCAT TEXT-F45.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'HSDAT	'.       "제조일
        _FCAT TEXT-F46.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'DOC_URL	'.       "성적서 경로
        _FCAT TEXT-F40.
        <FS_S_FCT>-HOTSPOT = GC_X.
        <FS_S_FCT>-JUST = 'L'.
        <FS_S_FCT>-EMPHASIZE = 'C601'.
      WHEN OTHERS.
        <FS_S_FCT>-NO_OUT  = GC_X.
    ENDCASE.

    APPEND <FS_S_FCT> TO GT_FCAT.

  ENDLOOP.

ENDFORM.

*&---------------------------------------------------------------------*
*& FORM ADJUST_FLDCATS
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
FORM ADJUST_FLDCATS_IT  TABLES PT_FCAT TYPE LVC_T_FCAT .

  DEFINE _FCAT.
    <FS_S_FCT>-SCRTEXT_S  =
    <FS_S_FCT>-SCRTEXT_M  =
    <FS_S_FCT>-SCRTEXT_L  =
    <FS_S_FCT>-COLTEXT    =
    <FS_S_FCT>-REPTEXT    = &1.
  END-OF-DEFINITION.

  DATA LV_COL TYPE I.
  CLEAR : GT_FCAT_IT[].

  LOOP AT PT_FCAT ASSIGNING FIELD-SYMBOL(<FS_S_FCT>).
    CLEAR : <FS_S_FCT>-COL_POS.

    CASE <FS_S_FCT>-FIELDNAME.

      WHEN 'STATUS'. "상태
        _FCAT TEXT-F47.
        <FS_S_FCT>-ICON = GC_X.

      WHEN 'BUKRS'.    "회사코드
        _FCAT TEXT-F01.
        <FS_S_FCT>-NO_OUT  = GC_X.

      WHEN 'EBELN'.      "구매오더
        _FCAT TEXT-F02.

      WHEN 'EBELP'.      "
        _FCAT TEXT-F03.

      WHEN 'ZINSP_NO'.      "검사요청번호
        _FCAT TEXT-F32.

      WHEN 'ZINSP_QTY'.      " 검사요청수량(DR)
        _FCAT TEXT-F28.

      WHEN 'MEINS'.    "단위
        _FCAT TEXT-F33.

      WHEN 'ZINSP_DATE'.  "검사요청일
        _FCAT TEXT-F34.

      WHEN 'ZINSPTYPE'.      "검사방법
        _FCAT TEXT-F35.
        <FS_S_FCT>-F4AVAILABL = GC_X.
        <FS_S_FCT>-REF_TABLE = 'ZGTMMT4402'.
        <FS_S_FCT>-REF_FIELD  = 'ZINSPTYPE'.

      WHEN 'ZINSPTYPE_N'.      "검사방법명
        _FCAT TEXT-F36.

      WHEN 'ZINSPDATE'.      "출장검사예정일
        _FCAT TEXT-F48.
        <FS_S_FCT>-F4AVAILABL = GC_X.
        <FS_S_FCT>-REF_TABLE = 'ZGTMMT4402'.
        <FS_S_FCT>-REF_FIELD  = 'ZINSPDATE'.

      WHEN 'ZINSP_PERNO'.      "출장담당자사번
        _FCAT TEXT-F49.
        <FS_S_FCT>-F4AVAILABL = GC_X.
        <FS_S_FCT>-REF_TABLE = 'ZZPA0001'.
        <FS_S_FCT>-REF_FIELD  = 'PERNR'.

      WHEN 'ZINSP_NAME'.      "출장담당자명
        _FCAT TEXT-F37.

      WHEN 'ZINSPRES'.      "검사결과
        _FCAT TEXT-F38.
        <FS_S_FCT>-EDIT = GC_X.
        <FS_S_FCT>-F4AVAILABL = GC_X.
        <FS_S_FCT>-REF_TABLE = 'ZGTMMT4402'.
        <FS_S_FCT>-REF_FIELD  = 'ZINSPRES'.

      WHEN 'ZINSPRES_N'.      "검사결과명
        _FCAT TEXT-F39.

      WHEN 'ZINSP_CERTI'.   "성적서 경로
        _FCAT TEXT-F40.
        <FS_S_FCT>-HOTSPOT = GC_X.

      WHEN OTHERS.
        <FS_S_FCT>-NO_OUT = GC_X.
    ENDCASE.

    APPEND <FS_S_FCT> TO GT_FCAT_IT.

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
*                       NO_ROWINS  = GC_X
                       ZEBRA          = GC_X
                       SEL_MODE    = GC_D
                       CWIDTH_OPT  = GC_A
*                       NO_ROWMARK = COND #( WHEN RB_MNG = GC_X THEN GC_X ELSE '' )
                       STYLEFNAME = 'STYLE'
                        ).

ENDFORM.

*&---------------------------------------------------------------------*
*& FORM SET_ALV_TOOLBAR
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
FORM SET_ALV_TOOLBAR .

  REFRESH : GT_EXCLUD, GT_EXCLUD_IT.

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

  IF RB_OEM = GC_X.
    PERFORM SET_CELL_STYLE.
  ENDIF.

*  DATA: LT_F4 TYPE LVC_T_F4,
*        LS_F4 TYPE LVC_S_F4.
*
*  LS_F4-FIELDNAME  = 'LGORT'.
*  LS_F4-REGISTER     = 'X'.
*  LS_F4-GETBEFORE  = 'X'.
*  LS_F4-CHNGEAFTER = 'X'.
*  APPEND LS_F4 TO LT_F4.
*
*  CALL METHOD PCL_GRID->REGISTER_F4_FOR_FIELDS
*    EXPORTING
*      IT_F4 = LT_F4.

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
*  PO_EVENT->HANDLE_DATA_CHANGED_FINISHED  FOR PCL_GRID,
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
                                  COND #( WHEN RB_OEM = GC_X AND PCL_GRID = GCL_GRID_HD
                                                THEN '0001'
                                                WHEN RB_OEM = GC_X AND PCL_GRID = GCL_GRID_IT
                                                THEN '0002'
                                                WHEN RB_DOWN = GC_X THEN '0003'  ELSE '0004' ) ).

  CALL METHOD PCL_GRID->SET_TABLE_FOR_FIRST_DISPLAY
    EXPORTING
      IS_LAYOUT            = GS_LAYOUT
      IT_TOOLBAR_EXCLUDING = PT_EXCLUD[] "GT_EXCLUD[]
      IS_VARIANT           = LS_VARIANT
      I_SAVE                  = GC_A
    CHANGING
      IT_OUTTAB             = PT_LIST[] "GT_LIST[]
      IT_FIELDCATALOG   = PT_FCAT[] "GT_FCAT[]
      IT_SORT                 = GT_SORT[]
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
*    GCL_GRID_HD->FREE( ).
*    CLEAR : GCL_GRID_HD, GV_BOTTOM .
    CLEAR : GCL_GRID_HD, GV_OKCODE_SAVE2,
                 GCL_GRID_IT, GCL_CUSTOM.
  ENDIF.

*  IF GCL_GRID_IT IS BOUND.
*    GCL_GRID_IT->FREE( ).
*    CLEAR : GCL_GRID_IT, GV_BOTTOM  .
*  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*& FORM INITIALIZATION
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
FORM INITIALIZATION .

  DATA: LT_VALUES TYPE TABLE OF USVALUES,
        LS_VALUES TYPE USVALUES.

  CLEAR : S_AEDAT, S_EINDT, S_AEDAT[], S_EINDT[], S_ERDAT, S_ERDAT[].

  S_ERDAT[]  = VALUE #( ( SIGN     = GC_I
                                         OPTION = GC_BT
                                         LOW      = SY-DATLO - 14
                                         HIGH      = SY-DATLO ) ).

  S_AEDAT[]  = VALUE #( ( SIGN     = GC_I
                                         OPTION = GC_BT
                                         LOW      = SY-DATLO - 60
                                         HIGH      = SY-DATLO + 60 ) ).

  S_EINDT[]  = VALUE #( ( SIGN     = GC_I
                                        OPTION = GC_BT
                                        LOW      = SY-DATLO - 30
                                        HIGH      = SY-DATLO + 60 ) ).

*DOMAIN VALUE
  CALL FUNCTION 'GET_DOMAIN_VALUES'
    EXPORTING
      DOMNAME    = 'ZGTD_INSPTYPE'
    TABLES
      VALUES_TAB = GT_ZINSPTYPE.

  SORT GT_ZINSPTYPE BY DOMVALUE_L DDTEXT.

  CALL FUNCTION 'GET_DOMAIN_VALUES'
    EXPORTING
      DOMNAME    = 'ZGTD_INSPVAL'
    TABLES
      VALUES_TAB = GT_DD07T.

  SORT GT_DD07T BY DDLANGUAGE DOMVALUE_L DDTEXT.

  CALL FUNCTION 'SUSR_USER_AUTH_FOR_OBJ_GET'
    EXPORTING
      MANDANT           = SY-MANDT
      SEL_OBJECT        = 'ZCBO_MM001' " 조회할 권한 오브젝트명
      USER_NAME         = SY-UNAME
    TABLES
      VALUES            = LT_VALUES
    EXCEPTIONS
      USER_NAME_INVALID = 1
      OBJECT_NOT_FOUND  = 2
      INTERNAL_ERROR    = 3
      OTHERS            = 4.

  DELETE  LT_VALUES WHERE VON = '*'.

  IF LT_VALUES[] IS NOT INITIAL.

    READ TABLE LT_VALUES INTO LS_VALUES WITH KEY FIELD = 'BUKRS'.
    IF SY-SUBRC EQ 0. P_BUKRS = LS_VALUES-VON. ENDIF.

    READ TABLE LT_VALUES INTO LS_VALUES WITH KEY FIELD = 'WERKS'.
    IF SY-SUBRC EQ 0. P_WERKS = LS_VALUES-VON.      ENDIF.

  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*& FORM SELECTION_SCREEN_OUTPUT
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
FORM SELECTION_SCREEN_OUTPUT.

  LOOP AT SCREEN.

    IF  SCREEN-NAME = '%_BLOCK_1000019'. "조회옵션 블럭제어
      CASE GC_X.
        WHEN RB_OEM.
          SCREEN-ACTIVE = 1.  "활성
        WHEN  OTHERS.
          SCREEN-ACTIVE = 0.  "비활성
      ENDCASE.
    ENDIF.

    IF  SCREEN-GROUP1 = 'OEM'.
      CASE GC_X.
        WHEN RB_OEM.
          SCREEN-ACTIVE = 1.  "활성
        WHEN  OTHERS.
          SCREEN-ACTIVE = 0.  "비활성
      ENDCASE.
    ENDIF.

    MODIFY SCREEN.
  ENDLOOP.

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

  AUTHORITY-CHECK OBJECT 'ZCBO_MM001'
               ID 'WERKS' FIELD P_WERKS.

  CHECK SY-SUBRC <> 0.

  SET CURSOR FIELD 'P_WERKS'.
  MESSAGE E106 WITH P_WERKS. "플랜트[&] 작업권한을 확인하세요.

ENDFORM.

*&---------------------------------------------------------------------*
*& FORM INPUT_VALIDATION
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
FORM INPUT_VALIDATION.

  CLEAR : GT_LIST, GV_ERR.

  IF P_WERKS IS INITIAL.
    MESSAGE S008 WITH TEXT-T11 DISPLAY LIKE GC_E.
    GV_ERR = GC_X. STOP. "필수 값이 누락되었습니다. &
  ENDIF.

  SELECT SINGLE 1
    FROM T001W
    WHERE WERKS = @P_WERKS
    INTO @DATA(LV_EXST).

  IF SY-SUBRC <> 0.
    MESSAGE S000 WITH TEXT-M01 DISPLAY LIKE GC_E.
    GV_ERR = GC_X. STOP. "유효하지 않은 플랜트 입니다.
  ENDIF.

  IF S_AEDAT[] IS INITIAL.
    MESSAGE S008 WITH TEXT-F04 DISPLAY LIKE GC_E.
    GV_ERR = GC_X. STOP. "필수 값이 누락되었습니다. '구매오더생성일'
  ENDIF.

  IF S_EBELN-LOW IS NOT INITIAL.
    CLEAR LV_EXST.
    LOOP AT S_EBELN INTO DATA(LS_EBELN).

      SELECT SINGLE 1"
       FROM EKKO
       WHERE EBELN EQ @LS_EBELN-LOW
        INTO @LV_EXST.

      IF SY-SUBRC <> 0.
        MESSAGE S081 WITH TEXT-F02 DISPLAY LIKE GC_E.
        GV_ERR = GC_X. STOP. "존재하지 않는 & 입니다.
      ENDIF.
    ENDLOOP.
  ENDIF.

  IF S_VBELN-LOW IS NOT INITIAL.
    CLEAR LV_EXST.
    LOOP AT S_VBELN INTO DATA(LS_VBELN).

      SELECT SINGLE 1"
       FROM VBAK
       WHERE VBELN EQ @LS_VBELN-LOW
        INTO @LV_EXST.

      IF SY-SUBRC <> 0.
        MESSAGE S081 WITH TEXT-F09 DISPLAY LIKE GC_E.
        GV_ERR = GC_X. STOP. "존재하지 않는 & 입니다.
      ENDIF.
    ENDLOOP.
  ENDIF.

  IF S_MATNR-LOW IS NOT INITIAL.
    CLEAR LV_EXST.
    LOOP AT S_MATNR INTO DATA(LS_MATNR).

      SELECT SINGLE 1
      FROM MARA
      WHERE MATNR EQ @LS_MATNR-LOW
      INTO @LV_EXST.

      IF SY-SUBRC <> 0.
        MESSAGE S081 WITH TEXT-F16 DISPLAY LIKE GC_E.
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

  IF S_LIFNR IS NOT INITIAL.
    LOOP AT S_LIFNR INTO DATA(LS_LOW).

      SELECT SINGLE 1
      FROM LFA1
      WHERE LIFNR EQ @LS_LOW-LOW
      INTO @LV_EXST.

      IF SY-SUBRC <> 0.
        MESSAGE S000 WITH TEXT-M03 DISPLAY LIKE GC_E.
        GV_ERR = GC_X. STOP. "유효하지 않은 공급업체코드 입니다.
      ENDIF.
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
  CLEAR : GV_ERR, GT_LIST, GT_ITEM.
*  GT_HEAD,


*--DATA 조회
*필수 입력 데이터 웨어조건 설정
  LV_WHERE &&= | BUKRS = '{ P_BUKRS }' AND WERKS = '{ P_WERKS }'  |.
  LV_WHERE &&= | AND AEDAT >= '{ S_AEDAT-LOW }'  AND AEDAT <= '{ S_AEDAT-HIGH }' |.
  LV_WHERE &&= | AND EINDT >= '{ S_EINDT-LOW }'  AND EINDT <= '{ S_EINDT-HIGH }' |.
  LV_WHERE &&= | AND LIFNR IN @S_LIFNR AND EBELN IN @S_EBELN AND MATNR IN @S_MATNR |.
  LV_WHERE &&= | AND QCREQDATE >= '{ S_ERDAT-LOW }'  AND QCREQDATE <= '{ S_ERDAT-HIGH }' |.

  CASE GC_X.
    WHEN RB_OEM. "OEM 검사 관리

      LV_WHERE &&= | AND KUNNR IN @S_KUNNR AND VBELN IN @S_VBELN  |.
      IF P_CHK = GC_X.
         LV_WHERE &&= | AND QI_CLOSE = 'X' |.
      ENDIF.

      SELECT FROM ZGTMM_CV_GET_OEM_PO_DATA_INFO
      FIELDS
                 BUKRS, EBELN, EBELP, AEDAT, EINDT,
                 WERKS, LIFNR, LIFNR_N, VBELN, POSNR,
                 KUNNR, KUNNR_N, VKBUR,  VKBUR_N,
                 VKGRP,  VKGRP_N, MATNR, MAKTX, COLOR,
                 MENGE,  MEINS, LENGTH, DRQTY, DR_MEINS,
                 GR_QTY_M  , GR_MEINS_M, GR_QTY_DR,
                 INSPECTION,
                 REQDATE, QI_REQ_QTY, QI_RESULT_QTY,
                 ELIKZ, QI_CLOSE, MTART, ZINSP_NO, ZINSP_QTY,
                 QCMEINS, ZINSP_DATE, ZINSPTYPE, ZINSPDATE,
                 ZINSPRES, ZINSP_CERTI, ZINSP_PERNO, ZINSP_NAME, QCREQDATE,

                 CASE WHEN QI_CLOSE IS NOT INITIAL THEN '@EO@' "ICON_INSPECTION_LOT
                           ELSE '@5D@' END AS STATUS  "ICON_INSPECTION_LOT

      WHERE (LV_WHERE)
      INTO TABLE @DATA(LT_DATA).

      IF LT_DATA[] IS INITIAL .
        GV_ERR = GC_X.
        MESSAGE S000 WITH TEXT-E01. EXIT.           "조회 조건에 일치하는 정보가 없습니다.
      ENDIF.

      GT_ITEM[] = CORRESPONDING #( LT_DATA[] ).
      SORT GT_ITEM BY EBELN EBELP ASCENDING  AEDAT DESCENDING.

      LOOP AT GT_ITEM ASSIGNING FIELD-SYMBOL(<ITEM>).
*검사방법 텍스트
        READ TABLE GT_ZINSPTYPE INTO DATA(LS_TYPE)
        WITH KEY DOMVALUE_L = <ITEM>-ZINSPTYPE BINARY SEARCH.
        IF SY-SUBRC = 0.
            <ITEM>-ZINSPTYPE_N = LS_TYPE-DDTEXT.
        ENDIF.
*검사결과 텍스트
        READ TABLE GT_DD07T INTO DATA(LS_DD)
        WITH KEY DOMVALUE_L = <ITEM>-ZINSPRES BINARY SEARCH.
        IF SY-SUBRC = 0.
            <ITEM>-ZINSPRES_N = LS_DD-DDTEXT.
        ENDIF.
      ENDLOOP.

    WHEN RB_DOWN. "자재성적서 DOWNLOAD

      SELECT FROM ZGTMM_CV_GET_MAT_INSPCERT
      FIELDS *
      WHERE (LV_WHERE)
      INTO TABLE @DATA(LT_LIST).

      IF LT_LIST[] IS INITIAL . "
        GV_ERR = GC_X.
        MESSAGE S000 WITH TEXT-E01. EXIT. "조회 조건에 일치하는 정보가 없습니다.
      ENDIF.

      GT_LIST[] = CORRESPONDING #( LT_LIST[] ).
      SORT GT_LIST BY DELNO DELITEM LIFNR BUKRS WERKS EBELN EBELP.

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
*
  CASE PO_SENDER.
    WHEN GCL_GRID_HD.
*       PERFORM SET_CELL_STYLE.
*       PERFORM REFRESH_TABLE USING GCL_GRID_HD SPACE.
       CALL METHOD CL_GUI_CFW=>SET_NEW_OK_CODE
            EXPORTING
                NEW_CODE = 'ENTER'.
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
    WHEN OTHERS.
  ENDCASE.
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

    LS_STYLE-FIELDNAME = &2.
    CASE &1.
      WHEN 'E'.
        LS_STYLE-STYLE = CL_GUI_ALV_GRID=>MC_STYLE_ENABLED.
      WHEN 'D'.
        LS_STYLE-STYLE = CL_GUI_ALV_GRID=>MC_STYLE_DISABLED.
    ENDCASE.
    INSERT LS_STYLE INTO TABLE &3.

  END-OF-DEFINITION.


    IF RB_OEM = GC_X.
      GCL_GRID_HD->SET_READY_FOR_INPUT( 1 ).
    ENDIF.

    LOOP AT GT_ITEM ASSIGNING FIELD-SYMBOL(<ITEM>).
     CLEAR : <ITEM>-STYLE[].

     CASE GC_X.
       WHEN RB_OEM. "OEM 검사 관리
*'검사결과' 값에 따라 편집 가능 여부 제어_검사방법
        IF <ITEM>-ZINSP_NO IS INITIAL.
            _SET_STYLE : GC_D 'ZINSPDATE' <ITEM>-STYLE.     ""DISABLED
            _SET_STYLE : GC_D 'ZINSP_PERNO' <ITEM>-STYLE.
            _SET_STYLE : GC_D 'ZINSP_NAME' <ITEM>-STYLE.
            _SET_STYLE : GC_D 'ZINSPTYPE' <ITEM>-STYLE.
            _SET_STYLE : GC_D 'ZINSP_NAME' <ITEM>-STYLE.
            _SET_STYLE : GC_D 'ZINSPRES' <ITEM>-STYLE.

        ELSE.
          IF <ITEM>-ZINSPRES IS INITIAL. "없으면, 편집가능.
            _SET_STYLE : GC_E 'ZINSPTYPE' <ITEM>-STYLE."ENABLED
*'검사방법'이 편집가능이어도, 'C'의 경우는 편집불가_출장검사예정일/출장담당자사번
          IF <ITEM>-ZINSPTYPE = GC_C.  "시험성적서
            _SET_STYLE : GC_D 'ZINSPDATE' <ITEM>-STYLE.     ""DISABLED
            _SET_STYLE : GC_D 'ZINSP_PERNO' <ITEM>-STYLE.
            _SET_STYLE : GC_D 'ZINSP_NAME' <ITEM>-STYLE.
          ELSE.
            _SET_STYLE : GC_E 'ZINSPDATE' <ITEM>-STYLE.     "ENABLED
            _SET_STYLE : GC_E 'ZINSP_PERNO' <ITEM>-STYLE."
            _SET_STYLE : GC_E 'ZINSP_NAME' <ITEM>-STYLE."
          ENDIF.

        ELSE. "있으면, 편집불가.
            _SET_STYLE : GC_D 'ZINSPTYPE' <ITEM>-STYLE. "DISABLED
*검사방법'이 편집불가이면, 출장검사예정일/출장담당자사번도 편집불가.
            _SET_STYLE : GC_D 'ZINSPDATE' <ITEM>-STYLE.     ""DISABLED
            _SET_STYLE : GC_D 'ZINSP_PERNO' <ITEM>-STYLE.
            _SET_STYLE : GC_D 'ZINSP_NAME' <ITEM>-STYLE."
        ENDIF.


        ENDIF.




**'검사방법' 값에 따라 편집(불)가능 제어_출장검사예정일/출장담당자사번
*        IF <ITEM>-ZINSPTYPE = GC_C.  "시험성적서
*            _SET_STYLE : GC_D 'ZINSPDATE' <ITEM>-STYLE.     ""DISABLED
*            _SET_STYLE : GC_D 'ZINSP_PERNO' <ITEM>-STYLE.
*        ELSE.
*          IF <ITEM>-ZINSPRES IS INITIAL.
*            _SET_STYLE : GC_E 'ZINSPDATE' <ITEM>-STYLE.     "ENABLED
*            _SET_STYLE : GC_E 'ZINSP_PERNO' <ITEM>-STYLE."
*          ELSE.
*            _SET_STYLE : GC_D 'ZINSPDATE' <ITEM>-STYLE.
*            _SET_STYLE : GC_D 'ZINSP_PERNO' <ITEM>-STYLE."
*          ENDIF.
*        ENDIF.

       WHEN OTHERS.
     ENDCASE.

    ENDLOOP.

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

*    WHEN '1'.
*      CREATE DATA GR_DREF LIKE GS_HEAD.

    WHEN '2'.
      CREATE DATA GR_DREF LIKE GS_ITEM.

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

*    WHEN '1'.
*      PERFORM ADJUST_FLDCATS_HD TABLES LT_FCAT .

    WHEN '2'.
      PERFORM ADJUST_FLDCATS_300 TABLES LT_FCAT .

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

    WHEN GCL_GRID_HD.
      PERFORM DATA_CHANGED_1 USING PO_DATA_CHANGED GCL_GRID_HD.

    WHEN OTHERS.
      EXIT.
  ENDCASE.

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
  DATA :
    LV_FD    TYPE LVC_FNAME,
    LV_MSG TYPE BAPI_MSG,
    LV_ERR  TYPE CHAR1,
    LV_PERNO TYPE PERSNO.

  LOOP AT PO_DATA_CHANGED->MT_MOD_CELLS INTO DATA(LS_MOD_CELLS).

    READ TABLE GT_ITEM ASSIGNING FIELD-SYMBOL(<FS>) INDEX LS_MOD_CELLS-ROW_ID.
    CHECK <FS> IS ASSIGNED.

    CASE LS_MOD_CELLS-FIELDNAME.

      WHEN 'ZINSPTYPE'. "검사방법
         TRANSLATE LS_MOD_CELLS-VALUE TO UPPER CASE.

         READ TABLE GT_ZINSPTYPE ASSIGNING FIELD-SYMBOL(<TYPE>)
         WITH KEY DOMVALUE_L = LS_MOD_CELLS-VALUE BINARY SEARCH.

         IF SY-SUBRC = 0.
            <FS>-ZINSPTYPE     = <TYPE>-DOMVALUE_L.
            <FS>-ZINSPTYPE_N = <TYPE>-DDTEXT.
         ELSE.
            CLEAR : <FS>-ZINSPTYPE, <FS>-ZINSPTYPE_N.
         ENDIF.

        IF <TYPE>-DOMVALUE_L = GC_C.
             <FS>-ZINSPDATE  = ''.
             <FS>-ZINSP_PERNO = ''.
             <FS>-ZINSP_NAME   = ''.
       ENDIF.

         IF <FS>-ZINSPTYPE IS NOT INITIAL AND <FS>-ZINSPDATE IS NOT INITIAL.
            <FS>-ZINSPTYPE = GC_Q. ""출장검사(출장검사예정일만 날짜 입력 가능하므로)
         ENDIF.

      WHEN 'ZINSPDATE'. "출장검사예정일
         IF LS_MOD_CELLS-VALUE IS INITIAL.
          CLEAR <FS>-ZINSPDATE.
        ELSE.
          <FS>-ZINSPDATE = LS_MOD_CELLS-VALUE.
*ZINSPDATE는 ZINSPTYPE = Q인 경우만 입력 가능하므로 값이 없는경우에만 Q로 변경해줌.
          <FS>-ZINSPTYPE = COND #( WHEN <FS>-ZINSPTYPE IS INITIAL THEN GC_Q
                                                       ELSE <FS>-ZINSPTYPE ).
          READ TABLE GT_ZINSPTYPE INTO DATA(LS_TYPE)
          WITH KEY DOMVALUE_L = <FS>-ZINSPTYPE BINARY SEARCH.
          IF SY-SUBRC = 0.
             <FS>-ZINSPTYPE_N = LS_TYPE-DDTEXT.
          ENDIF.

        ENDIF.

      WHEN 'ZINSP_PERNO'. "출장담당자사번
        IF LS_MOD_CELLS-VALUE IS INITIAL.
           CLEAR : <FS>-ZINSP_PERNO, <FS>-ZINSP_NAME.
        ELSE.
           TRANSLATE LS_MOD_CELLS-VALUE TO UPPER CASE.

           LV_PERNO = LS_MOD_CELLS-VALUE.
           SELECT SINGLE PERNR , SNAME
             FROM ZZPA0001
             WHERE PERNR = @LV_PERNO
             INTO  ( @DATA(LV_PERNR) , @DATA(LV_SNAME) ).

           IF LV_PERNR IS INITIAL.
              CLEAR : <FS>-ZINSP_PERNO, <FS>-ZINSP_NAME.
           ELSE.
              <FS>-ZINSP_PERNO = LV_PERNR.
              <FS>-ZINSP_NAME   = LV_SNAME.
           ENDIF.
        ENDIF.

      WHEN 'ZINSPRES'. "검사결과
        IF LS_MOD_CELLS-VALUE IS INITIAL.
           CLEAR : <FS>-ZINSPRES, <FS>-ZINSPRES_N, GV_ERR.
        ELSE.
          TRANSLATE LS_MOD_CELLS-VALUE TO UPPER CASE.
          <FS>-ZINSPRES = LS_MOD_CELLS-VALUE.

          IF <FS>-ZINSPTYPE IS INITIAL.
            CLEAR : <FS>-ZINSPRES, <FS>-ZINSPRES_N.
            GV_ERR = GC_X.   "검사 방법을 먼저 입력하세요.
            MESSAGE S000 WITH TEXT-E11 DISPLAY LIKE GC_E.
          ENDIF.
        ENDIF.

        CHECK GV_ERR IS INITIAL.
        READ TABLE GT_DD07T ASSIGNING FIELD-SYMBOL(<DD>)
        WITH KEY DDLANGUAGE = SY-LANGU
                       DOMVALUE_L = LS_MOD_CELLS-VALUE BINARY SEARCH.
        IF SY-SUBRC = 0.
          <FS>-ZINSPRES_N = <DD>-DDTEXT.
        ENDIF.

      WHEN OTHERS.
    ENDCASE.

    <FS>-STATUS = ICON_CHANGE.
    MODIFY GT_ITEM FROM <FS> INDEX  LS_MOD_CELLS-ROW_ID.
  ENDLOOP.

*  PERFORM SET_CELL_STYLE.
*  PERFORM REFRESH_TABLE USING GCL_GRID_HD SPACE.

*  IF LV_FD IS NOT INITIAL.
*    PERFORM ADD_ENTRY USING PO_DATA_CHANGED LV_FD
*                                                 LS_MOD_CELLS-ROW_ID.
*    CALL METHOD PO_DATA_CHANGED->DISPLAY_PROTOCOL.
*  ENDIF.

*  CL_GUI_CFW=>SET_NEW_OK_CODE( NEW_CODE = 'NEWCODE' ).

ENDFORM. " DATA_CHANGED_1

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
    CLEAR : LS_TBAR.
    LS_TBAR-BUTN_TYPE = &1.
    LS_TBAR-FUNCTION   = &2.
    LS_TBAR-ICON           = &3.
    LS_TBAR-TEXT           = &4.
    LS_TBAR-QUICKINFO  = &4.
    APPEND LS_TBAR TO PO_OBJECT->MT_TOOLBAR.
  END-OF-DEFINITION.

  CASE PO_SENDER.

    WHEN GCL_GRID_HD.
*      DELETE PO_OBJECT->MT_TOOLBAR WHERE FUNCTION = 'ITEM'.
*
*      _SET_TBAR 3 '    ' '              ' '    '.
*      _SET_TBAR 0 'ITEM' '' '상세조회'(B01).
*
*    WHEN GCL_GRID_IT.
      DELETE PO_OBJECT->MT_TOOLBAR WHERE FUNCTION = 'REFRESH'.
      DELETE PO_OBJECT->MT_TOOLBAR WHERE FUNCTION = 'SAVE'.
      DELETE PO_OBJECT->MT_TOOLBAR WHERE FUNCTION = 'METHOD'.
      DELETE PO_OBJECT->MT_TOOLBAR WHERE FUNCTION = 'SCHEDULE'.
      DELETE PO_OBJECT->MT_TOOLBAR WHERE FUNCTION = 'REJULT'.

      _SET_TBAR 3 '    ' '              ' '    '.
      _SET_TBAR 0 'REFRESH' ICON_REFRESH 'REFRESH'(B02).
      _SET_TBAR 0 'SAVE' ICON_SYSTEM_SAVE '저장'(B03).
      _SET_TBAR 3 '    ' '              ' '    '.
      _SET_TBAR 0 'METHOD' ICON_INSPECTION_METHOD '검사방법등록'(B04).
      _SET_TBAR 0 'SCHEDULE' ICON_DATE '출장검사일정등록'(B05).
      _SET_TBAR 0 'RESULT' ICON_CHECKED '검사결과등록'(B06).

    WHEN OTHERS.
      EXIT.
  ENDCASE.

ENDFORM.

*&---------------------------------------------------------------------*
*& FORM USER_COMMAND
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
FORM USER_COMMAND  USING  PO_UCOMM LIKE SY-UCOMM.

  CLEAR GV_UCOMM.
  GV_UCOMM = PO_UCOMM.

  IF GCL_GRID_HD IS BOUND.
    CALL METHOD GCL_GRID_HD->CHECK_CHANGED_DATA.
  ENDIF.

  CASE GV_UCOMM.

*    WHEN 'ITEM' ."상세조회
*      PERFORM GET_ITEM_DATA USING 'ITEM'.

    WHEN  'REFRESH'.
*      PERFORM DATA_REFRESH.
      PERFORM GET_DATA.
      PERFORM SET_CELL_STYLE.
      PERFORM REFRESH_TABLE USING GCL_GRID_HD SPACE.

    WHEN 'SAVE'. "저장
      PERFORM DATA_SAVE.

    WHEN 'METHOD'.     "검사방법등록
      PERFORM SET_DATA_METHOD.

    WHEN 'SCHEDULE'. "출장검사일정등록
      PERFORM SET_DATA_SCHEDULE.

    WHEN 'RESULT'. "검사결과등록
      PERFORM SET_DATA_RESULT.

    WHEN OTHERS.
      EXIT.
  ENDCASE.

*  IF GV_OKCODE_SAVE = 'CANC' OR GV_OKCODE_SAVE2 = 'NO'.
*  ELSE.
*    PERFORM DATA_REFRESH.
*  ENDIF.

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

  DATA :
    LV_MSG TYPE BAPI_MSG,
    LV_URL TYPE STRING.

  CASE PO_SENDER.

    WHEN GCL_GRID.
      READ TABLE GT_LIST INTO DATA(LS_LIST) INDEX PS_ROW_NO-INDEX.
      CHECK SY-SUBRC = 0.

      IF PS_COLUMN-FIELDNAME = 'DOC_URL'.
        CHECK LS_LIST-DOC_URL IS NOT INITIAL.
        LV_URL = LS_LIST-DOC_URL.
      ELSE.
        EXIT.
      ENDIF.

   WHEN GCL_GRID_HD.
      READ TABLE GT_ITEM INTO DATA(LS_ITEM) INDEX PS_ROW_NO-INDEX.
      CHECK SY-SUBRC = 0.

      IF PS_COLUMN-FIELDNAME = 'ZINSP_CERTI'.
        CHECK LS_ITEM-ZINSP_CERTI IS NOT INITIAL.
        LV_URL = LS_ITEM-ZINSP_CERTI.
      ELSE.
        EXIT.
      ENDIF.

   WHEN OTHERS.
  ENDCASE.

*URL 실행
    TRY.
        CL_GUI_FRONTEND_SERVICES=>EXECUTE(
            EXPORTING
              DOCUMENT               = LV_URL
            EXCEPTIONS
              CNTL_ERROR           = 1
              ERROR_NO_GUI        = 2
              BAD_PARAMETER     = 3
            OTHERS                     = 10  ).

      CATCH CX_ROOT INTO DATA(LV_ERR).
         LV_MSG = LV_ERR->GET_TEXT( ).
         MESSAGE S000 WITH LV_MSG DISPLAY LIKE GC_E. EXIT.
    ENDTRY.


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
*FORM SET_F4_FIELD .
*
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
*
*ENDFORM.

***&---------------------------------------------------------------------*
***& FORM DYNP_VALUES_READ
***&---------------------------------------------------------------------*
***& TEXT
***&---------------------------------------------------------------------*
***&      --> P_
***&      <-- P_BUKRS
***&---------------------------------------------------------------------*
**FORM DYNP_VALUES_READ USING       PV_FNAME
**                                           CHANGING PV_FVAL.
**
**  DATA : LT_DYN LIKE DYNPREAD OCCURS 0 WITH HEADER LINE.
**
**
**  CLEAR : LT_DYN[], PV_FVAL.
**  LT_DYN[] = VALUE #( ( FIELDNAME = PV_FNAME ) ).
**
**  CALL FUNCTION 'DYNP_VALUES_READ'
**    EXPORTING
**      DYNAME               = SY-REPID
**      DYNUMB               = SY-DYNNR
**    TABLES
**      DYNPFIELDS           = LT_DYN
**    EXCEPTIONS
**      INVALID_ABAPWORKAREA = 1
**      INVALID_DYNPROFIELD  = 2
**      INVALID_DYNPRONAME   = 3
**      INVALID_DYNPRONUMMER = 4
**      INVALID_REQUEST      = 5
**      NO_FIELDDESCRIPTION  = 6
**      INVALID_PARAMETER    = 7
**      UNDEFIND_ERROR       = 8
**      DOUBLE_CONVERSION    = 9
**      STEPL_NOT_FOUND      = 10
**      OTHERS               = 11.
**
**  IF SY-SUBRC <> 0.
**    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
**          WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
**    EXIT.
**  ENDIF.
**
**  PV_FVAL = VALUE #( LT_DYN[ 1 ]-FIELDVALUE OPTIONAL ).
**
**ENDFORM.
***&---------------------------------------------------------------------*
***& FORM F4IF_FIELD
***&---------------------------------------------------------------------*
***& TEXT
***&---------------------------------------------------------------------*
***&      --> P_
***&      --> P_
***&      --> P_
***&      --> P_
***&---------------------------------------------------------------------*
**FORM F4IF_FIELD USING PV_TNAME
**                                     PV_FNAME
**                                     PV_SHELP
**                                     PV_FIELD.
**
**  CLEAR : GT_RTAB[].
**
**  CALL FUNCTION 'F4IF_FIELD_VALUE_REQUEST'
**    EXPORTING
**      TABNAME           = CONV TABNAME( PV_TNAME )
**      FIELDNAME         = CONV FIELDNAME( PV_FNAME )
**      SEARCHHELP        = CONV SHLPNAME( PV_SHELP )
***     SHLPPARAM         = ' '
**      DYNPPROG          = SY-REPID
**      DYNPNR            = SY-DYNNR
**      DYNPROFIELD       = CONV DYNFNAM( PV_FIELD )
***     STEPL             = 0
***     VALUE             = ' '
***     MULTIPLE_CHOICE   = ' '
***     DISPLAY           = ' '
***     SUPPRESS_RECORDLIST       = ' '
***     CALLBACK_PROGRAM  = ' '
***     CALLBACK_FORM     = ' '
***     CALLBACK_METHOD   =
***     SELECTION_SCREEN  = ' '
***   IMPORTING
***     USER_RESET        =
**    TABLES
**      RETURN_TAB        = GT_RTAB
**    EXCEPTIONS
**      FIELD_NOT_FOUND   = 1
**      NO_HELP_FOR_FIELD = 2
**      INCONSISTENT_HELP = 3
**      NO_VALUES_FOUND   = 4
**      OTHERS            = 5.
**
**ENDFORM.
***&---------------------------------------------------------------------*
***& FORM F4IF_FIELD
***&---------------------------------------------------------------------*
***& TEXT
***&---------------------------------------------------------------------*
***&      --> P_
***&      --> P_
***&      --> P_
***&      --> P_
***&---------------------------------------------------------------------*
**FORM F4IF_TABLE USING PV_VKBUR
**                                       PV_VKGRP
**                                       PV_FIELD.
**
*** F4 도움말 필드 속성 정의
**  DATA : LT_FIELDS TYPE TABLE OF DFIES,
**         LS_FIELD  LIKE LINE OF LT_FIELDS.
**  DATA : LT_RETURN TYPE STANDARD TABLE OF DDSHRETVAL.
**  DATA: BEGIN OF LT_DATA OCCURS 0,
**          VALUE TYPE C LENGTH 30,
**        END OF LT_DATA.
**
**  SELECT FROM TVBVK AS A  INNER JOIN TVGRT AS B
**         ON A~VKGRP EQ B~VKGRP
**         FIELDS A~VKBUR, B~VKGRP, B~BEZEI
**         WHERE A~VKBUR EQ @PV_VKBUR
**              AND B~SPRAS EQ @GC_3
**         INTO TABLE @GT_VKGRP.
**
**  IF GT_VKGRP[] IS NOT INITIAL.
**
**    LT_FIELDS = VALUE #(  ( FIELDNAME = 'VKBUR'
**                                      INTTYPE = 'C'
**                                      INTLEN = 8
**                                      LENG = 8
**                                      OUTPUTLEN = 8
**                                      REPTEXT = '영업팀' )
**                                      ( FIELDNAME = 'VKGRP'
**                                      INTTYPE = 'C'
**                                      INTLEN = 8
**                                      LENG = 8
**                                      OUTPUTLEN = 8
**                                      REPTEXT = '영업그룹' )
**                                      ( FIELDNAME = 'BEZEI'
**                                      INTTYPE = 'C'
**                                      INTLEN = 20
**                                      LENG = 20
**                                      OUTPUTLEN = 20
**                                      REPTEXT = '영업그룹명' ) ).
**
**    LOOP AT GT_VKGRP ASSIGNING FIELD-SYMBOL(<FS>).
**      APPEND VALUE #( VALUE = <FS>-VKBUR ) TO LT_DATA.
**      APPEND VALUE #( VALUE = <FS>-VKGRP ) TO LT_DATA.
**      APPEND VALUE #( VALUE = <FS>-BEZEI ) TO LT_DATA.
**    ENDLOOP.
**
**    CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
**      EXPORTING
**        RETFIELD     = 'VKGRP'
**        WINDOW_TITLE = '영업그룹'
***       DYNPROFIELD  = 'P_VKGRP'
***       VALUE_ORG    = 'C'
**      TABLES
**        VALUE_TAB    = LT_DATA
**        FIELD_TAB    = LT_FIELDS
**        RETURN_TAB   = LT_RETURN.
**    IF SY-SUBRC <> 0.
**      MESSAGE S000 WITH '조건에 맞는 영업그룹 정보가 없습니다.'(E02) DISPLAY LIKE GC_E.
**    ENDIF.
**
**    READ TABLE LT_RETURN INTO DATA(LS_RETURN) INDEX 1.
**    IF SY-SUBRC = 0.
**      P_VKGRP = LS_RETURN-FIELDVAL.
**    ENDIF.
**
**  ENDIF.
**
**ENDFORM.
**
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
FORM SET_LIST_SAVE.

  DATA :
    LV_TYPE  TYPE TY_ITEM-ZINSPTYPE_N,
    LV_RST    TYPE TY_ITEM-ZINSPRES_N,
    LV_MSG   TYPE STRING.

  CLEAR : GV_ERR, GS_ROW.

*검사방법명
  READ TABLE GT_ZINSPTYPE ASSIGNING FIELD-SYMBOL(<TYPE>)
  WITH KEY DOMVALUE_L = GV_WAY BINARY SEARCH.
  IF SY-SUBRC = 0.
    LV_TYPE = <TYPE>-DDTEXT.
  ENDIF.
*검사결과명
  READ TABLE GT_DD07T ASSIGNING FIELD-SYMBOL(<DD>)
  WITH KEY DOMVALUE_L = GV_RESULT BINARY SEARCH.
  IF SY-SUBRC = 0.
    LV_RST = <DD>-DDTEXT.
  ENDIF.
*출장자이름
  SELECT SINGLE SNAME
    FROM ZZPA0001
    WHERE PERNR = @GV_PERNR
    INTO @DATA(LV_NAME).


  LOOP AT GT_ROWS INTO GS_ROW.

    READ TABLE GT_ITEM  ASSIGNING FIELD-SYMBOL(<FS>) INDEX GS_ROW-INDEX.
    CHECK <FS> IS ASSIGNED.

    CASE GV_UCOMM .
*검사방법 등록
      WHEN 'METHOD'.
        <FS>-ZINSPTYPE = GV_WAY.
        <FS>-ZINSPTYPE_N = LV_TYPE.

*SCHEDULE_출장검사일정등록
      WHEN 'SCHEDULE'.
        <FS>-ZINSPDATE = GV_BUDAT.
        <FS>-ZINSP_PERNO = GV_PERNR.
        <FS>-ZINSP_NAME = LV_NAME.
        <FS>-ZINSPTYPE = COND #( WHEN <FS>-ZINSPTYPE IS INITIAL THEN GC_Q
                                                    ELSE <FS>-ZINSPTYPE ).

*RESULT_검사결과등록
      WHEN 'RESULT'.
        <FS>-ZINSPRES = GV_RESULT.
        <FS>-ZINSPRES_N = LV_RST.

    ENDCASE.

    <FS>-STATUS = ICON_CHANGE.

    MODIFY GT_ITEM FROM <FS> INDEX GS_ROW-INDEX.
    CLEAR GS_ROW.
  ENDLOOP.


ENDFORM.
*&---------------------------------------------------------------------*
*& FORM DATA_SAVE
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
*& -->  P1        TEXT
*& <--  P2        TEXT
*&---------------------------------------------------------------------*
FORM DATA_SAVE.

  DATA LT_ITEM TYPE STANDARD TABLE OF TY_ITEM.
  CLEAR : GV_ANSWER, GV_ERR.

*  PERFORM GET_SELECTED_ROWS USING GCL_GRID_HD '' 'X' ''.
*  CHECK GV_ERR IS INITIAL.

  IF LINE_EXISTS( GT_ITEM[ STATUS = ICON_CHANGE  ] ).
    LOOP AT GT_ITEM ASSIGNING FIELD-SYMBOL(<FS>)."GT_ROWS INTO GS_ROW.
*       READ TABLE GT_ITEM ASSIGNING FIELD-SYMBOL(<FS>) INDEX GS_ROW-INDEX.
       CHECK <FS> IS ASSIGNED.
       CHECK <FS>-STATUS = ICON_CHANGE.

       IF <FS>-ZINSPRES IS NOT INITIAL AND <FS>-ZINSPTYPE IS INITIAL.
         GV_ERR = GC_X. CLEAR LT_ITEM.
         MESSAGE S000 WITH '검사 방법이 없는 결과는 등록할 수 없습니다.'(M09)
         DISPLAY LIKE GC_E.  EXIT.
       ENDIF.

       CHECK GV_ERR IS INITIAL.
       APPEND <FS> TO LT_ITEM.
    ENDLOOP.

    CHECK GV_ERR IS INITIAL.   "OEM 검사 관리 정보를 등록 하시겠습니까?
    PERFORM POPUP_TO_CONFIRM_STEP  USING 'N' TEXT-M06 '' TEXT-T03.

  ELSE.
    MESSAGE S000 WITH '등록/변경된 정보가 없습니다.'(M08) DISPLAY LIKE GC_E.
    EXIT.
  ENDIF.

  CHECK GV_ANSWER = GC_J.
*  CLEAR GS_ROW.

*  LOOP AT GT_ROWS INTO GS_ROW.
   LOOP AT LT_ITEM ASSIGNING FIELD-SYMBOL(<ITEM>).
*    READ TABLE GT_ITEM ASSIGNING FIELD-SYMBOL(<ITEM>) INDEX GS_ROW-INDEX.
    CHECK <ITEM> IS ASSIGNED.

        UPDATE ZGTMMT4402
        SET ZINSPTYPE = <ITEM>-ZINSPTYPE
               ZINSPDATE = <ITEM>-ZINSPDATE
               ZINSPRES   = <ITEM>-ZINSPRES
               ZINSP_PERNO = <ITEM>-ZINSP_PERNO
               ZINSP_NAME   = <ITEM>-ZINSP_NAME
               AEDAT = SY-DATUM
               AEDAT_LOCAL = SY-DATLO
               AETIM = SY-UZEIT
               AETIM_LOCAL = SY-TIMLO
               AENAM = SY-UNAME

        WHERE BUKRS = <ITEM>-BUKRS
             AND EBELN = <ITEM>-EBELN
             AND EBELP = <ITEM>-EBELP
             AND ZINSP_NO = <ITEM>-ZINSP_NO.

    IF SY-SUBRC = 0.
      COMMIT WORK AND WAIT .
      MESSAGE S000 WITH TEXT-M05. "검사 정보를 등록했습니다.
    ENDIF.

  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& FORM SET_DATA_METHOD
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
*& -->  P1        TEXT
*& <--  P2        TEXT
*&---------------------------------------------------------------------*
FORM SET_DATA_METHOD.

  PERFORM GET_SELECTED_ROWS USING GCL_GRID_HD '' 'X' TEXT-E04.
  CHECK GV_ERR IS INITIAL.  "검사 방법을 입력할 라인을 선택하세요.

  LOOP AT  GT_ROWS INTO GS_ROW.

       READ TABLE GT_ITEM ASSIGNING FIELD-SYMBOL(<FS>) INDEX GS_ROW-INDEX.
       CHECK <FS> IS ASSIGNED.

       IF <FS>-ZINSPRES IS NOT INITIAL.
         GV_ERR = GC_X.
         MESSAGE S000 WITH '검사 결과가 등록된 데이터는 검사 방법을 바꿀 수 없습니다.'(E06)
         DISPLAY LIKE GC_E.  EXIT.
       ENDIF.

  ENDLOOP.

  CHECK GV_ERR IS INITIAL.
  CALL SCREEN 0200 STARTING AT 5 10 .

ENDFORM.
*&---------------------------------------------------------------------*
*& FORM DATA_REFRESH
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
*& -->  P1        TEXT
*& <--  P2        TEXT
*&---------------------------------------------------------------------*
*FORM DATA_REFRESH.
**헤더 데이터 기준으로 아이템 데이터 재조회.
*  CLEAR : GS_ITEM, GT_ITEM[].
*    "ITEM
*  CHECK GT_HEAD[] IS NOT INITIAL.
*  SELECT FROM ZGTMMT4402
*           FIELDS *
*           FOR ALL ENTRIES IN @GT_HEAD
*          WHERE BUKRS = @P_BUKRS
*              AND EBELN = @GT_HEAD-EBELN
*              AND EBELP = @GT_HEAD-EBELP
*              INTO TABLE @DATA(LT_ITEM).
*
*  IF LT_ITEM[] IS INITIAL.
*    MESSAGE S002 DISPLAY LIKE GC_E.
*  ELSE.
*    LOOP AT LT_ITEM ASSIGNING FIELD-SYMBOL(<FS>).
*      CLEAR GS_ITEM.
*      GS_ITEM = CORRESPONDING #( <FS> ).
**검사방법명
*      READ TABLE GT_ZINSPTYPE ASSIGNING FIELD-SYMBOL(<TYPE>)
*      WITH KEY DOMVALUE_L = <FS>-ZINSPTYPE BINARY SEARCH.
*      IF SY-SUBRC = 0.
*           GS_ITEM-ZINSPTYPE_N = <TYPE>-DDTEXT.
*      ENDIF.
**검사결과명
*      READ TABLE GT_DD07T ASSIGNING FIELD-SYMBOL(<RESULT>)
*      WITH KEY DOMVALUE_L = <FS>-ZINSPRES BINARY SEARCH.
*      IF SY-SUBRC = 0.
*           GS_ITEM-ZINSPRES_N = <RESULT>-DDTEXT.
*      ENDIF.
**출장자이름
*      SELECT SINGLE SNAME
*      FROM ZZPA0001
*      WHERE PERNR = @<FS>-ZINSP_PERNO
*      INTO @<FS>-ZINSP_NAME.
*
*      APPEND GS_ITEM TO GT_ITEM.
*    ENDLOOP.
**    GT_ITEM[] =  CORRESPONDING #( LT_ITEM[] ).
*    SORT GT_ITEM BY BUKRS EBELN EBELP.
*  ENDIF.
*
*ENDFORM.
*&---------------------------------------------------------------------*
*& FORM SET_DATA_SCHEDULE
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
*& -->  P1        TEXT
*& <--  P2        TEXT
*&---------------------------------------------------------------------*
FORM  SET_DATA_SCHEDULE.

  PERFORM GET_SELECTED_ROWS USING GCL_GRID_HD '' 'X' TEXT-E07.
  CHECK GV_ERR IS INITIAL.  "출장 검사 일정을 입력할 라인을 선택하세요.

  LOOP AT  GT_ROWS INTO GS_ROW.

    READ TABLE GT_ITEM ASSIGNING FIELD-SYMBOL(<FS>) INDEX GS_ROW-INDEX.
    CHECK <FS> IS ASSIGNED.

    IF <FS>-ZINSPRES IS NOT INITIAL.
      GV_ERR = GC_X.
      MESSAGE S000 WITH '검사 결과가 등록된 데이터는 출장 검사 일정을 바꿀 수 없습니다.'(E09)
      DISPLAY LIKE GC_E.  EXIT.
    ENDIF.

  ENDLOOP.

  CHECK GV_ERR IS INITIAL.
  CALL SCREEN 0200 STARTING AT 5 10 .

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_ITEM_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
*FORM GET_ITEM_DATA  USING PV_GB.
*
*  DATA : LR_BUKRS TYPE RANGE OF ZGTMM_CV_GET_OEM_DELIVERY_BASE-BUKRS ,
*             LR_EBELN TYPE RANGE OF ZGTMMT4402-EBELN ,
*             LR_EBELP TYPE RANGE OF ZGTMMT4402-EBELP.
*
*  CLEAR : GV_BOTTOM, GT_ITEM[].
*
*  IF PV_GB IS INITIAL.
*    CHECK GT_HEAD[] IS NOT INITIAL.
*
*    SELECT FROM ZGTMMT4402
*      FIELDS *
*      FOR ALL ENTRIES IN @GT_HEAD
*      WHERE BUKRS = @GT_HEAD-BUKRS
*           AND EBELN = @GT_HEAD-EBELN
*           AND EBELP = @GT_HEAD-EBELP
*      INTO CORRESPONDING FIELDS OF TABLE @GT_ITEM.
*  ENDIF.
*
*
*  LOOP AT GT_ITEM ASSIGNING FIELD-SYMBOL(<ITEM>).
**검사방법 텍스트
*        READ TABLE GT_ZINSPTYPE INTO DATA(LS_TYPE)
*        WITH KEY DOMVALUE_L = <ITEM>-ZINSPTYPE BINARY SEARCH.
*        IF SY-SUBRC = 0.
*            <ITEM>-ZINSPTYPE_N = LS_TYPE-DDTEXT.
*        ENDIF.
**검사결과 텍스트
*        READ TABLE GT_DD07T INTO DATA(LS_DD)
*        WITH KEY DOMVALUE_L = <ITEM>-ZINSPRES BINARY SEARCH.
*        IF SY-SUBRC = 0.
*            <ITEM>-ZINSPRES_N = LS_DD-DDTEXT.
*        ENDIF.
*  ENDLOOP.
*
*  IF PV_GB IS NOT INITIAL.
*    PERFORM SET_CELL_STYLE.
*    PERFORM REFRESH_TABLE USING GCL_GRID_IT SPACE.
*  ENDIF.
*
*ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_DATA_RESULT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_DATA_RESULT.

  PERFORM GET_SELECTED_ROWS USING GCL_GRID_HD '' 'X' TEXT-E10.
  CHECK GV_ERR IS INITIAL.  "검사결과를 입력할 라인을 선택하세요.

  CHECK GV_ERR IS INITIAL.
  CALL SCREEN 0200 STARTING AT 5 10 .

ENDFORM.
