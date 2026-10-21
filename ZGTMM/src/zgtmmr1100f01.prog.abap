*&---------------------------------------------------------------------*
*& INCLUDE          ZGTMMR3000F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& FORM CREATE_ALV
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
FORM CREATE_ALV .

  PERFORM :
            SET_CONTAINER,
            SET_ALV_GRID,
            SET_ALV_FIELDCAT,
            SET_ALV_LAYOUT,
            SET_ALV_TOOLBAR.

  IF GV_HOTSPOT = GC_X.
    PERFORM SET_EVENT   CHANGING GCL_EVENT GCL_GRID_BOM.
    PERFORM DISPLAY_ALV TABLES GT_BOM GT_FCAT_BOM CHANGING GCL_GRID_BOM.
  ELSE.
    PERFORM SET_EVENT   CHANGING GCL_EVENT GCL_GRID.
    PERFORM DISPLAY_ALV TABLES GT_LIST GT_FCAT CHANGING GCL_GRID.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& FORM SET_CONTAINER
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
FORM SET_CONTAINER .

  IF GCL_DOCKING IS NOT BOUND.

    CREATE OBJECT GCL_DOCKING
      EXPORTING
        REPID     = SY-REPID
        DYNNR     = SY-DYNNR
        SIDE      = CL_GUI_DOCKING_CONTAINER=>DOCK_AT_LEFT
        EXTENSION = 2500.

  ENDIF.

  CHECK GV_HOTSPOT = GC_X.
  IF GCL_DOCKBOM IS NOT BOUND.

    CREATE OBJECT GCL_DOCKBOM
      EXPORTING
        REPID     = SY-REPID
        DYNNR     = SY-DYNNR
        SIDE      = CL_GUI_DOCKING_CONTAINER=>DOCK_AT_LEFT
        EXTENSION = 2500.

  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*& FORM SET_ALV_GRID
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
FORM SET_ALV_GRID .

  IF GV_HOTSPOT IS INITIAL.

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

  ELSE.
    IF GCL_GRID_BOM IS NOT BOUND.
      CREATE OBJECT GCL_GRID_BOM
        EXPORTING
          I_PARENT          = GCL_DOCKBOM
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

  ENDIF.

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
      WHEN 'STATUS'. "상태
        _FCAT TEXT-F01.

      WHEN 'CLOSING'.      "
        _FCAT '마감'."TEXT-F01.
        <FS_S_FCT>-NO_OUT = GC_X.

      WHEN 'EKORG'.       "구매조직
        _FCAT TEXT-F02.
        <FS_S_FCT>-NO_OUT = GC_X.

      WHEN 'EKORG_N'.  "구매조직명
        _FCAT TEXT-F03.
        <FS_S_FCT>-NO_OUT = GC_X.

      WHEN 'WERKS'.       "플랜트
        _FCAT TEXT-F04.

      WHEN 'WERKS_N'.  "플랜트명
        _FCAT TEXT-F05.
        <FS_S_FCT>-NO_OUT = GC_X.

      WHEN 'INFNR'.     "정보레코드
        _FCAT TEXT-F08.
        <FS_S_FCT>-NO_OUT = GC_X.
        <FS_S_FCT>-HOTSPOT = GC_X.

      WHEN 'LIFNR'.   "공급업체
        _FCAT TEXT-F09.
        <FS_S_FCT>-NO_OUT = GC_X.
        <FS_S_FCT>-EMPHASIZE = 'C410'. "색/노랑/진하게/반전없음
      WHEN 'LIFNR_N'.   "업체명
        _FCAT TEXT-F10.
        <FS_S_FCT>-EMPHASIZE = 'C410'. "색/노랑/진하게/반전없음
      WHEN 'MATNR'.        "자재코드
        _FCAT TEXT-F11.
        <FS_S_FCT>-HOTSPOT = GC_X.
        <FS_S_FCT>-EMPHASIZE = 'C300'. "색/노랑/연하게/반전없음
      WHEN 'MATNR_N'.        "전체품명
        _FCAT TEXT-F12.
        <FS_S_FCT>-EMPHASIZE = 'C300'. "색/노랑/연하게/반전없음
      WHEN 'PRDNAME'.     "품명
        _FCAT TEXT-F13.
        <FS_S_FCT>-EMPHASIZE = 'C300'. "색/노랑/연하게/반전없음
      WHEN 'PRODSIZE'.     "규격
        _FCAT TEXT-F14.
        <FS_S_FCT>-EMPHASIZE = 'C300'. "색/노랑/연하게/반전없음
      WHEN 'SPEC_NO'.        "SPEC NO.
        _FCAT TEXT-F15.
        <FS_S_FCT>-EMPHASIZE = 'C300'. "색/노랑/연하게/반전없음
      WHEN 'COLOR'.        "색상
        _FCAT TEXT-F16.
      WHEN 'EINE_LOEKZ'.
        _FCAT '삭제'.
        <FS_S_FCT>-EDIT = GC_X.
        <FS_S_FCT>-CHECKBOX = GC_X.
      WHEN 'ESOKZ'.        "인포유형
        _FCAT TEXT-F17.
        <FS_S_FCT>-NO_OUT = GC_X.
      WHEN 'PERIOD'.        "월
        _FCAT TEXT-F18.
*        <FS_S_FCT>-NO_OUT = GC_X.
      WHEN 'TTS'.     " TTS 월 평균 환율
        _FCAT TEXT-F19.

      WHEN 'TTM'.  "TTM 월 평균 환율
        _FCAT TEXT-F20.

      WHEN 'CU_NES'.     "CU 비철 유형
        _FCAT TEXT-F21.
        <FS_S_FCT>-NO_OUT = GC_X.

      WHEN 'CU_KGW'.     "CU 비철 중량
        _FCAT TEXT-F22.
        <FS_S_FCT>-QFIELDNAME = 'CU_BME'.
        <FS_S_FCT>-EMPHASIZE = 'C700'.

      WHEN 'CU_BME'.        "CU 중량단위(KG)
        _FCAT TEXT-F23.

      WHEN 'CU_KGU'.        "기본단위 PER(M)
        _FCAT TEXT-F24.
*        <FS_S_FCT>-NO_OUT = GC_X.

      WHEN 'CU_PREMIUM'.        "프리미엄피
        _FCAT TEXT-F25.
*        <FS_S_FCT>-NO_OUT = GC_X.
        <FS_S_FCT>-CFIELDNAME = 'CU_PREMIUM_WAERS'.

      WHEN 'CU_PREMIUM_WAERS'.        "프리미엄피 통화
        _FCAT TEXT-F26.
        <FS_S_FCT>-NO_OUT = GC_X.

      WHEN 'CU_CRATE'.        "부대비용계수
        _FCAT TEXT-F27.
*        <FS_S_FCT>-NO_OUT = GC_X.

      WHEN 'CU_MCOST'.        "가공비
        _FCAT 'CU가공비'."TEXT-F28.
*        <FS_S_FCT>-NO_OUT = GC_X.
        <FS_S_FCT>-CFIELDNAME = 'CU_MWAERS'.

      WHEN 'CU_PER'.        "PER
        _FCAT TEXT-F29.
*        <FS_S_FCT>-NO_OUT = GC_X.

      WHEN 'CU_MUNIT'.        "가공비단위
        _FCAT TEXT-F30.
*        <FS_S_FCT>-NO_OUT = GC_X.

      WHEN 'CU_MWAERS'.        "가공비통화
        _FCAT TEXT-F31.
*        <FS_S_FCT>-NO_OUT = GC_X.

      WHEN 'CU_KURST'.        "환율유형
        _FCAT TEXT-F32.
*        <FS_S_FCT>-NO_OUT = GC_X.

      WHEN 'CU_PRICE'.        "CU LME 가격
        _FCAT TEXT-F33.
*        <FS_S_FCT>-NO_OUT = GC_X.
        <FS_S_FCT>-CFIELDNAME = 'FWAERS'.

      WHEN 'CU_LMEPER'.        "CU LME PER
        _FCAT TEXT-F34.
*        <FS_S_FCT>-NO_OUT = GC_X.

      WHEN 'CU_MEINS'.        "CU 단위(KG)
        _FCAT TEXT-F35.
*        <FS_S_FCT>-NO_OUT = GC_X.

      WHEN 'CU_SLMC'.        "CU 환산 원화단가
        _FCAT TEXT-F36.
        <FS_S_FCT>-CFIELDNAME = 'KWAERS'.

      WHEN 'CU_LMC'.        "적용 동가
        _FCAT TEXT-F37.
        <FS_S_FCT>-CFIELDNAME = 'KWAERS'.

      WHEN 'SCR_SC'.        "SCR 가공비
        _FCAT TEXT-F38.
        <FS_S_FCT>-CFIELDNAME = 'KWAERS'.

      WHEN 'KWAERS'.        "통화
        _FCAT TEXT-F39.

      WHEN 'AL_NES'.     "AL 비철 유형
        _FCAT TEXT-F40.
*        <FS_S_FCT>-NO_OUT = GC_X.

      WHEN 'AL_KGW'.     "AL 비철 중량
        _FCAT TEXT-F41.
        <FS_S_FCT>-QFIELDNAME = 'AL_BME'.
        <FS_S_FCT>-EMPHASIZE = 'C700'.

      WHEN 'AL_BME'.        "AL 중량단위(KG)
        _FCAT TEXT-F42.

      WHEN 'AL_KGU'.        "기본단위 PER(M)
        _FCAT 'AL 기본단위 PER(M)'."TEXT-F24.
*        <FS_S_FCT>-NO_OUT = GC_X.

      WHEN 'AL_PREMIUM'.        "프리미엄피
        _FCAT 'AL프리미엄피'."TEXT-F25.
*        <FS_S_FCT>-NO_OUT = GC_X.
        <FS_S_FCT>-CFIELDNAME = 'AL_PREMIUM_WAERS'.

      WHEN 'AL_PREMIUM_WAERS'.        "프리미엄피 통화
        _FCAT 'AL프리미엄피 통화'."TEXT-F26.

      WHEN 'AL_CRATE'.        "부대비용계수
        _FCAT 'AL부대비용계수'."TEXT-F27.

      WHEN 'AL_MCOST'.        "가공비
        _FCAT 'AL 가공비'."TEXT-F28.
        <FS_S_FCT>-CFIELDNAME = 'AL_MWAERS'.

      WHEN 'AL_PER'.        "PER
        _FCAT 'AL PER'."TEXT-F29.

      WHEN 'AL_MUNIT'.        "가공비단위
        _FCAT 'AL가공비단위'."TEXT-F30.

      WHEN 'AL_MWAERS'.        "가공비통화
        _FCAT 'AL가공비통화'." TEXT-F31.

      WHEN 'AL_KURST'.        "환율유형
        _FCAT 'AL환율유형'."TEXT-F32.
*        <FS_S_FCT>-NO_OUT = GC_X.

      WHEN 'AL_PRICE'.        "AL LME 가격
        _FCAT 'AL LME가격'."TEXT-F43.
*        <FS_S_FCT>-NO_OUT = GC_X.
        <FS_S_FCT>-CFIELDNAME = 'FWAERS'.

      WHEN 'AL_LMEPER'.        "AL LME PER
        _FCAT 'AL LME PER'."TEXT-F44.
*        <FS_S_FCT>-NO_OUT = GC_X.

      WHEN 'AL_MEINS'.        "AL 단위(KG)
        _FCAT TEXT-F45.
*        <FS_S_FCT>-NO_OUT = GC_X.

      WHEN 'AL_SLMC'.        "AL 환산 원화단가
        _FCAT TEXT-F46.
        <FS_S_FCT>-CFIELDNAME = 'KWAERS'.

      WHEN 'CU_C_QTY'.        "CU 소요량(도체)
        _FCAT TEXT-F47.
        <FS_S_FCT>-QFIELDNAME = 'KGMEINS'.

      WHEN 'AL_C_SPEC'.        "AL SPEC(도체)
        _FCAT TEXT-F48.
        <FS_S_FCT>-F4AVAILABL = GC_X.

      WHEN 'AL_C_QTY'.        "AL 소요량(도체)
        _FCAT TEXT-F49.
        <FS_S_FCT>-QFIELDNAME = 'KGMEINS'.

      WHEN 'KGMEINS'.        "중량단위
        _FCAT TEXT-F50.

      WHEN 'AL_C_PRICE'.        "AL 단가(도체)
        _FCAT TEXT-F51.
        <FS_S_FCT>-CFIELDNAME = 'KWAERS'.

      WHEN 'CU_S_QTY'.        "CU 소요량(외장)
        _FCAT TEXT-F52.
        <FS_S_FCT>-QFIELDNAME = 'KGMEINS'.

      WHEN 'AL_S_SPEC'.        "AL SPEC(외장)
        _FCAT TEXT-F53.
        <FS_S_FCT>-F4AVAILABL = GC_X.

      WHEN 'AL_S_QTY'.        "AL 소요량(외장)
        _FCAT TEXT-F54.
        <FS_S_FCT>-QFIELDNAME = 'KGMEINS'.

      WHEN 'AL_S_PRICE'.        "AL 단가(외장)
        _FCAT TEXT-F55.
        <FS_S_FCT>-CFIELDNAME = 'KWAERS'.

      WHEN 'CU_T_QTY'.        "CU 소요량(Tape)
        _FCAT TEXT-F56.
        <FS_S_FCT>-QFIELDNAME = 'CU_MEINS'.

      WHEN 'CU_PRICE_TOTAL'.        "CU 총금액
        _FCAT TEXT-F57.
        <FS_S_FCT>-EDIT = GC_X.
        <FS_S_FCT>-CFIELDNAME = 'KWAERS'.

      WHEN 'AL_PRICE_TOTAL'.        "AL 총금액
        _FCAT TEXT-F58.
        <FS_S_FCT>-EDIT = GC_X.
        <FS_S_FCT>-CFIELDNAME = 'KWAERS'.

      WHEN 'S_MAT_COST'.        "부재료비
        _FCAT TEXT-F59.
        <FS_S_FCT>-CFIELDNAME = 'KWAERS'.
        <FS_S_FCT>-EDIT = GC_X.

      WHEN 'MFG_COST'.        "가공비
        _FCAT TEXT-F06.
        <FS_S_FCT>-CFIELDNAME = 'KWAERS'.

      WHEN 'PKG_COST'.        "포장비
        _FCAT TEXT-F60.
        <FS_S_FCT>-CFIELDNAME = 'KWAERS'.

      WHEN 'ADD_COST'.        "추가비용
        _FCAT TEXT-F93.
        <FS_S_FCT>-CFIELDNAME = 'KWAERS'.
        <FS_S_FCT>-EDIT = GC_X.

      WHEN 'ETC_COST'.     "기타비용
        _FCAT TEXT-F62.
        <FS_S_FCT>-CFIELDNAME = 'KWAERS'.

      WHEN 'SUB_PRICE_TOTAL'.        "재료/가공비 총금액
        _FCAT TEXT-F61.
        <FS_S_FCT>-CFIELDNAME = 'KWAERS'.

      WHEN 'OEM_PRICE'.     "OEM 적용가
        _FCAT TEXT-F63.
        <FS_S_FCT>-CFIELDNAME = 'KWAERS'.
        <FS_S_FCT>-EDIT = GC_X.
        <FS_S_FCT>-EMPHASIZE = 'C600'. "색/노랑/진하게/반전없음

      WHEN 'DIS_PRICE'.     "할인단가
        _FCAT TEXT-F64.
        <FS_S_FCT>-CFIELDNAME = 'KWAERS'.
        <FS_S_FCT>-NO_OUT = GC_X.

      WHEN 'DRUM_SPEC'.     "드럼기준
        _FCAT TEXT-F65.
        <FS_S_FCT>-EDIT = GC_X.
        <FS_S_FCT>-DRDN_HNDL = 1.
        <FS_S_FCT>-DRDN_ALIAS = GC_X.

      WHEN 'LAST_PO_DATE'.    "최종발주일
        _FCAT TEXT-F66.

      WHEN 'GR_QTY'.    "미정산수량
        _FCAT TEXT-F67.
        <FS_S_FCT>-QFIELDNAME = 'GRMEINS'.

      WHEN 'GRMEINS'.     "기본단위
        _FCAT TEXT-F68.

      WHEN 'AP_PRICE'.     "월 정산대상금액
        _FCAT TEXT-F69.
        <FS_S_FCT>-CFIELDNAME = 'KWAERS'.

      WHEN 'MEINS'.     "자재기본단위
        _FCAT '자재기본단위'."TEXT-F68.
*        <FS_S_FCT>-NO_OUT = GC_X.

      WHEN 'FWAERS'.     "외화기준통화(USD)
        _FCAT TEXT-F71.
*        <FS_S_FCT>-NO_OUT = GC_X.

      WHEN 'KBETR'.     "INFO금액
        _FCAT TEXT-F72.
        <FS_S_FCT>-CFIELDNAME = 'KONWA'."'FWAERS'.

      WHEN 'KONWA'.     "INFO통화
        _FCAT 'INFO통화'.

      WHEN 'KPEINS'.        "PER
        _FCAT 'INFO PER'."TEXT-F29.

      WHEN 'KMEINS'.        "단가단위
        _FCAT TEXT-F73.

      WHEN 'QIRATE'.        "견적인상율
        _FCAT TEXT-F94.
        <FS_S_FCT>-EDIT = GC_X.

      WHEN 'MTYPE'.     "처리결과
        _FCAT TEXT-F74.

      WHEN 'MESSAGE'.   "처리메시지
        _FCAT TEXT-F75.

      WHEN 'ERDAT'.     "생성일
        _FCAT TEXT-F76.
        <FS_S_FCT>-NO_OUT = GC_X.

      WHEN 'ERDAT_LOCAL'.     "생성일(LOCAL)
        _FCAT TEXT-F77.
        <FS_S_FCT>-NO_OUT = GC_X.

      WHEN 'ERTIM'.     "생성시간
        _FCAT TEXT-F78.
        <FS_S_FCT>-NO_OUT = GC_X.

      WHEN 'ERTIM_LOCAL'.     "
        _FCAT TEXT-F79.
        <FS_S_FCT>-NO_OUT = GC_X.

      WHEN 'ERNAM'.     "생성자
        _FCAT TEXT-F80.
        <FS_S_FCT>-NO_OUT = GC_X.

      WHEN 'AEDAT'.     "변경일
        _FCAT TEXT-F81.
        <FS_S_FCT>-NO_OUT = GC_X.

      WHEN 'AEDAT_LOCAL'.     "
        _FCAT TEXT-F82.
        <FS_S_FCT>-NO_OUT = GC_X..

      WHEN 'AETIM'.     "변경시간
        _FCAT TEXT-F83.
        <FS_S_FCT>-NO_OUT = GC_X.

      WHEN 'AETIM_LOCAL'.   "
        _FCAT TEXT-F84.
        <FS_S_FCT>-NO_OUT = GC_X.

      WHEN 'AENAM'.     "변경자
        _FCAT TEXT-F85.
        <FS_S_FCT>-NO_OUT = GC_X.

*      WHEN 'INSMK'.        "재고유형
*        _FCAT TEXT-F37.
*        <FS_S_FCT>-EDIT = GC_X.
*        <FS_S_FCT>-F4AVAILABL = GC_X.
*        <FS_S_FCT>-REF_TABLE = 'EKPO'.
*        <FS_S_FCT>-REF_FIELD  = 'INSMK'.

      WHEN OTHERS.
        <FS_S_FCT>-NO_OUT = GC_X.

    ENDCASE.

    APPEND <FS_S_FCT> TO GT_FCAT.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& FORM ADJUST_FLDCATS_BOM
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
FORM ADJUST_FLDCATS_BOM  TABLES PT_FCAT TYPE LVC_T_FCAT.

  DEFINE _FCAT.
    <FS_S_FCT>-SCRTEXT_S  =
    <FS_S_FCT>-SCRTEXT_M  =
    <FS_S_FCT>-SCRTEXT_L  =
    <FS_S_FCT>-COLTEXT    =
    <FS_S_FCT>-REPTEXT    = &1.
  END-OF-DEFINITION.

  DATA LV_COL TYPE I.
  CLEAR : GT_FCAT_BOM[].

  LOOP AT PT_FCAT ASSIGNING FIELD-SYMBOL(<FS_S_FCT>).
    CLEAR : <FS_S_FCT>-COL_POS.

    CASE <FS_S_FCT>-FIELDNAME.
      WHEN 'BOMLEVEL'. "레벨
        _FCAT TEXT-F86.

      WHEN 'COMPONENT'.      "COMPONENT
        _FCAT TEXT-F87.

      WHEN 'MAKTX'.       "COMPONENT명
        _FCAT TEXT-F88.

      WHEN 'BOMitemQty'.  "수량
        _FCAT TEXT-F89.

      WHEN 'BOMitemQtyUnit'. "단위
        _FCAT TEXT-F07.

      WHEN 'ComponentScrapInPercent'. "스크랩율
        _FCAT TEXT-F90.

      WHEN 'hrktx'.  "재질
        _FCAT TEXT-F91.

      WHEN 'atwrt'.  "특성
        _FCAT TEXT-F92.

      WHEN OTHERS.
        <FS_S_FCT>-NO_OUT = GC_X.

    ENDCASE.

    APPEND <FS_S_FCT> TO GT_FCAT_BOM.
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
*                       NO_ROWINS  = ZGTFI_X
                       ZEBRA  = ZGTFI_X
                       SEL_MODE   = ZGTFI_A
                       CWIDTH_OPT  = ZGTFI_A
                       STYLEFNAME = 'STYLE'
  ).

ENDFORM.

*&---------------------------------------------------------------------*
*& FORM SET_ALV_TOOLBAR
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
FORM SET_ALV_TOOLBAR.

  REFRESH GT_EXCLUD.

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

  IF GV_HOTSPOT IS INITIAL.
    PERFORM SET_CELL_STYLE.
  ENDIF.

  CREATE OBJECT PO_EVENT.

  SET HANDLER :
  PO_EVENT->HANDLE_DATA_CHANGED                 FOR PCL_GRID,
  PO_EVENT->HANDLE_DATA_CHANGED_FINISHED  FOR PCL_GRID,
  PO_EVENT->HANDLE_HOTSPOT_CLICK                FOR PCL_GRID,
  PO_EVENT->HANDLE_TOOLBAR                           FOR PCL_GRID,
  PO_EVENT->HANDLE_USER_COMMAND               FOR PCL_GRID,
  PO_EVENT->HANDLE_ON_F4                               FOR PCL_GRID.

ENDFORM.

*&---------------------------------------------------------------------*
*& FORM DISPLAY_ALV
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
FORM DISPLAY_ALV TABLES PT_LIST PT_FCAT
                                CHANGING PCL_GRID  TYPE REF TO CL_GUI_ALV_GRID.

  CLEAR GS_VARIANT.
  GS_VARIANT-REPORT = SY-REPID.
  GS_VARIANT-HANDLE = COND #( WHEN GV_HOTSPOT IS INITIAL THEN '0001' ELSE '0002' ).

*  " F4 대상 필드 등록
  DATA: LT_F4 TYPE LVC_T_F4.
  LT_F4 = VALUE #(
               ( FIELDNAME = 'AL_C_SPEC' REGISTER   = 'X' )
               ( FIELDNAME = 'AL_S_SPEC' REGISTER   = 'X' ) ).

  CALL METHOD PCL_GRID->REGISTER_F4_FOR_FIELDS
    EXPORTING
      IT_F4 = LT_F4.

*DROPDOWN(LISTBOX) SET
  CALL METHOD PCL_GRID->SET_DROP_DOWN_TABLE
    EXPORTING
*      IT_DROP_DOWN       = GT_DROPDOWN
      IT_DROP_DOWN_ALIAS = GT_DROP
      .

  CALL METHOD PCL_GRID->SET_TABLE_FOR_FIRST_DISPLAY
    EXPORTING
      IS_LAYOUT            = GS_LAYOUT
      IT_TOOLBAR_EXCLUDING = GT_EXCLUD[]
      IS_VARIANT           = GS_VARIANT "LS_VARINT
      I_SAVE                  = ZGTFI_A
    CHANGING
      IT_OUTTAB            = PT_LIST[] "GT_LIST[]
      IT_FIELDCATALOG  = PT_FCAT[]
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

ENDFORM.

*&---------------------------------------------------------------------*
*& FORM INITIALIZATION
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
FORM INITIALIZATION .

  DATA: lt_values TYPE TABLE OF USVALUES,
      ls_values TYPE USVALUES.

  CLEAR : P_BUDAT. "정산기준일_전월 말일(SY-DATUM기준)
  DATA: LV_LAST_DAY TYPE SY-DATUM.

  LV_LAST_DAY = SY-DATUM.
  LV_LAST_DAY+6(2) = '01'.

  P_BUDAT = LV_LAST_DAY - 1.

  CLEAR:
    GT_T001W[],
    GT_T024E[].

  SELECT
    WERKS,
    NAME1
    FROM T001W
    INTO TABLE @GT_T001W.

  SELECT
    EKORG,
    EKOTX
    FROM T024E
    INTO TABLE @GT_T024E.

    CALL FUNCTION 'SUSR_USER_AUTH_FOR_OBJ_GET'
      EXPORTING
        MANDANT = SY-MANDT
        SEL_OBJECT     = 'ZCBO_MM001' " 조회할 권한 오브젝트명
        user_name         = sy-uname
      TABLES
        values          = lt_values
      EXCEPTIONS
        user_name_invalid = 1
        object_not_found  = 2
        internal_error    = 3
        OTHERS            = 4.

      DELETE  LT_VALUES WHERE VON = '*'.

    IF LT_VALUES[] IS NOT INITIAL.
      " 2. 권한 필드(예: WERKS)의 값을 추출하여 Select-options에 매핑
      READ TABLE LT_VALUES INTO LS_VALUES WITH KEY FIELD = 'EKORG'.
      IF SY-SUBRC EQ 0. P_EKORG = LS_VALUES-VON. ENDIF.

      READ TABLE LT_VALUES INTO LS_VALUES WITH KEY FIELD = 'WERKS'.
      IF SY-SUBRC EQ 0. P_WERKS = LS_VALUES-VON. ENDIF.

    ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*& FORM INPUT_VALIDATION
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
FORM INPUT_VALIDATION.

  CLEAR : GT_LIST, GV_ERR.

  IF  P_WERKS IS INITIAL.
     MESSAGE S000 WITH TEXT-E03 DISPLAY LIKE GC_E.
     GV_ERR = GC_X. STOP. "플랜트는 필수 입력 입니다.

  ELSE.
      SELECT SINGLE 1
       FROM T001W
       WHERE WERKS EQ @P_WERKS
        INTO @DATA(LV_EXST).

      IF SY-SUBRC <> 0.
        MESSAGE S000 WITH TEXT-M01 DISPLAY LIKE GC_E.
        GV_ERR = GC_X. STOP. "유효하지 않은 플랜트 입니다.
      ENDIF.

      CHECK GV_ERR IS INITIAL.
*ALV_'DRUM_SPEC' 필드 리스트박스 세팅
      SELECT FLD_02, FLD_03
        FROM ZGTPPT1010
        WHERE MODULE_KIND = 'MM'
             AND CODEGRP = '0760'
             AND FLD_01 = @P_WERKS
        INTO TABLE @DATA(LT_1010).

       IF LT_1010 IS NOT INITIAL.
          CLEAR GT_DROP[].
          GT_DROP[] = VALUE #( BASE GT_DROP FOR LS IN LT_1010
                                         ( HANDLE = '1'
                                           VALUE   = |{ LS-FLD_02 } { LS-FLD_03 }| "텍스트
                                           INT_VALUE = LS-FLD_02 ) ). "코드
       ENDIF.
  ENDIF.

  IF S_LIFNR[] IS NOT INITIAL.
    LOOP AT S_LIFNR INTO DATA(LS_LIFNR).

      SELECT SINGLE 1
      FROM LFA1
      WHERE LIFNR EQ @LS_LIFNR-LOW
      INTO @LV_EXST.

      IF SY-SUBRC <> 0.
        MESSAGE S000 WITH TEXT-M03 DISPLAY LIKE GC_E.
        GV_ERR = GC_X. STOP. "유효하지 않은 공급업체 입니다.
      ENDIF.
    ENDLOOP.
  ENDIF.

  IF S_MATNR[] IS NOT INITIAL.
    LOOP AT S_MATNR INTO DATA(LS_MATNR).

      SELECT SINGLE 1
      FROM MARA
      WHERE MATNR EQ @LS_MATNR-LOW
      INTO @LV_EXST.

      IF SY-SUBRC <> 0.
        MESSAGE S000 WITH TEXT-M10 DISPLAY LIKE GC_E.
        GV_ERR = GC_X. STOP. "유효하지 않은 자재코드 입니다.
      ENDIF.
    ENDLOOP.
  ENDIF.

*  IF S_MAKTX[] IS NOT INITIAL.
*    LOOP AT S_MAKTX INTO DATA(LS_MAKTX).

*      SELECT SINGLE 1
*      FROM MAKT
*      WHERE MATNR EQ @LS_MATNR-LOW
*           AND SPRAS EQ @SY-LANGU
*      INTO @LV_EXST.

*      IF SY-SUBRC <> 0.
*        MESSAGE S000 WITH TEXT-M10 DISPLAY LIKE GC_E.
*        GV_ERR = GC_X. STOP. "유효하지 않은 자재코드 입니다.
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
               ID 'EKORG' FIELD P_EKORG.

  CHECK SY-SUBRC <> 0.

  SET CURSOR FIELD 'P_EKORG'.
  MESSAGE E170 WITH P_EKORG. "구매조직 [&] 작업권한을 확인하세요.


  AUTHORITY-CHECK OBJECT 'ZCBO_MM001'
               ID 'WERKS' FIELD P_WERKS.

  CHECK SY-SUBRC <> 0.

  SET CURSOR FIELD 'P_WERKS'.
  MESSAGE E106 WITH P_WERKS. "플랜트 [&] 작업권한을 확인하세요.

ENDFORM.

*&---------------------------------------------------------------------*
*& FORM GET_DATA
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
FORM GET_DATA .

  CLEAR : GV_SPMON, GV_ERR, GT_LIST, GS_ONCE-WAERS.

  IF P_BUDAT IS NOT INITIAL.
    GV_SPMON = P_BUDAT(6).
  ENDIF.

  SELECT FROM ZGTMM_CV_GET_OEM_CAL_SCHMA
    FIELDS *
    WHERE EKORG EQ @P_EKORG
         AND WERKS EQ @P_WERKS
         AND LIFNR   IN @S_LIFNR
         AND MATNR IN @S_MATNR
         AND MATNR_N IN @S_MAKTX
         AND PERIOD EQ @GV_SPMON
         AND DELINFO EQ ''
    INTO CORRESPONDING FIELDS OF TABLE @GT_LIST.

*저장 데이터에 CU 비철 정보가 비어 있는 행(엑셀 업로드 등)은 RAW2 값으로 보강. 마감 행 제외. ZLSGMM5 계정만 적용.
  IF SY-UNAME = 'ZLSGMM5' AND GT_LIST[] IS NOT INITIAL.
    SELECT FROM ZGTMM_CV_GET_OEM_CAL_RAW2(
                            p_datE = @P_BUDAT, P_MON = @GV_SPMON ) AS R2
      FIELDS R2~EKORG, R2~WERKS, R2~LIFNR, R2~MATNR, R2~ESOKZ,
                 R2~CU_NES, R2~CU_KGW, R2~CU_BME, R2~CU_KGU, R2~CU_PREMIUM,
                 R2~CU_PERMIUM_WAERS, R2~CU_CRATE, R2~CU_MCOST, R2~CU_PER,
                 R2~CU_MUNIT, R2~CU_MWAERS, R2~CU_KURST, R2~CU_PRICE,
                 R2~CU_LMEPER, R2~CU_MEINS, R2~CU_SLMC
      WHERE R2~CU_KGW > 0
      AND EXISTS (
##ITAB_KEY_IN_SELECT
        SELECT ZZ~MATNR
          FROM @GT_LIST AS ZZ
          WHERE ZZ~EKORG EQ R2~EKORG
          AND ZZ~WERKS EQ R2~WERKS
          AND ZZ~LIFNR EQ R2~LIFNR
          AND ZZ~MATNR EQ R2~MATNR
          AND ZZ~ESOKZ EQ R2~ESOKZ
          AND ZZ~CU_NES EQ ''
          AND ZZ~CU_KGW EQ 0
          AND ZZ~CLOSING EQ ''
          )
      INTO TABLE @DATA(LT_FILL).

    LOOP AT LT_FILL ASSIGNING FIELD-SYMBOL(<LS_FILL>).
      LOOP AT GT_LIST ASSIGNING FIELD-SYMBOL(<LS_FLD>)
                      WHERE EKORG = <LS_FILL>-EKORG
                        AND WERKS = <LS_FILL>-WERKS
                        AND LIFNR = <LS_FILL>-LIFNR
                        AND MATNR = <LS_FILL>-MATNR
                        AND ESOKZ = <LS_FILL>-ESOKZ
                        AND CU_NES IS INITIAL
                        AND CU_KGW IS INITIAL
                        AND CLOSING IS INITIAL.
        <LS_FLD>-CU_NES           = <LS_FILL>-CU_NES.
        <LS_FLD>-CU_KGW           = <LS_FILL>-CU_KGW.
        <LS_FLD>-CU_BME           = <LS_FILL>-CU_BME.
        <LS_FLD>-CU_KGU           = <LS_FILL>-CU_KGU.
        <LS_FLD>-CU_PREMIUM       = <LS_FILL>-CU_PREMIUM.
        <LS_FLD>-CU_PERMIUM_WAERS = <LS_FILL>-CU_PERMIUM_WAERS.
        <LS_FLD>-CU_CRATE         = <LS_FILL>-CU_CRATE.
        <LS_FLD>-CU_MCOST         = <LS_FILL>-CU_MCOST.
        <LS_FLD>-CU_PER           = <LS_FILL>-CU_PER.
        <LS_FLD>-CU_MUNIT         = <LS_FILL>-CU_MUNIT.
        <LS_FLD>-CU_MWAERS        = <LS_FILL>-CU_MWAERS.
        <LS_FLD>-CU_KURST         = <LS_FILL>-CU_KURST.
        <LS_FLD>-CU_PRICE         = <LS_FILL>-CU_PRICE.
        <LS_FLD>-CU_LMEPER        = <LS_FILL>-CU_LMEPER.
        <LS_FLD>-CU_MEINS         = <LS_FILL>-CU_MEINS.
        <LS_FLD>-CU_SLMC          = <LS_FILL>-CU_SLMC.
        "보강 표시: 기존 메시지 앞에 [비철정보변경] 추가(중복 방지)
        IF <LS_FLD>-MESSAGE NP '[비철정보변경]*'.
          <LS_FLD>-MESSAGE = |[비철정보변경] { <LS_FLD>-MESSAGE }|.
        ENDIF.
      ENDLOOP.
    ENDLOOP.
  ENDIF.

*    IF GT_LIST[] IS INITIAL.
*      DATA(LV_RAW2) = GC_X.

    SELECT FROM ZGTMM_CV_GET_OEM_CAL_RAW2(
                            p_datE = @P_BUDAT, P_MON = @GV_SPMON ) AS R2

      FIELDS R2~CLOSING, R2~EKORG, EKORG_N, R2~WERKS, R2~WERKS_N,
                 R2~INFNR, R2~LIFNR, R2~LIFNR_N, R2~MATNR, R2~MATNR_N,
                 R2~PRDNAME, R2~PRODSIZE, SPEC_NO , R2~COLOR, R2~ESOKZ,
                 R2~TTS, R2~TTM, R2~CU_NES, R2~CU_KGW, R2~CU_BME,
                 R2~CU_KGU, R2~CU_PREMIUM, R2~CU_PERMIUM_WAERS, R2~CU_CRATE,
                 R2~CU_MCOST, R2~CU_PER, R2~CU_MUNIT, R2~CU_MWAERS, R2~CU_KURST,
                 R2~CU_PRICE, R2~CU_LMEPER, R2~CU_MEINS, R2~CU_SLMC, R2~CU_LMC,
                 R2~SCR_SC, R2~KWAERS, R2~AL_NES, R2~AL_KGW, R2~AL_BME, R2~AL_KGU,
                 R2~AL_PREMIUM, R2~AL_PERMIUM_WAERS, R2~AL_CRATE, R2~AL_MCOST,
                 R2~AL_PER, R2~AL_MUNIT, R2~AL_MWAERS, R2~AL_KURST, R2~AL_PRICE,
                 R2~AL_LMEPER, R2~AL_MEINS, R2~AL_SLMC, R2~CU_C_QTY, R2~AL_C_SPEC,
                 R2~AL_C_QTY, R2~KGMEINS, R2~CU_S_QTY, R2~AL_S_SPEC,
                 R2~AL_S_QTY, R2~CU_T_QTY,
                 R2~S_MAT_COST, R2~MFG_COST, R2~PKG_COST, R2~ETC_COST,
                 R2~AL_C_PRICE, R2~AL_S_PRICE, R2~ADD_COST,
                 R2~LAST_PO_DATE, R2~GR_QTY, R2~GRMEINS,
                 R2~MEINS, R2~FWAERS, R2~KBETR, R2~KPEIN, R2~KMEIN, R2~KONWA,
                 @GV_SPMON AS PERIOD,
                 @ABAP_FALSE AS DRUM_SPEC

      WHERE NOT EXISTS (
##ITAB_KEY_IN_SELECT
        SELECT ZZ~INFNR
          FROM @GT_LIST AS ZZ
          WHERE ZZ~EKORG EQ R2~EKORG
          AND ZZ~WERKS EQ R2~WERKS
          AND ZZ~LIFNR EQ R2~LIFNR
          AND ZZ~INFNR EQ R2~INFNR
          AND ZZ~MATNR EQ R2~MATNR
          AND ZZ~ESOKZ EQ R2~ESOKZ
          AND ZZ~PERIOD EQ @GV_SPMON
          )
      AND EKORG EQ @P_EKORG
      AND WERKS EQ @P_WERKS
      AND LIFNR   IN @S_LIFNR
      AND MATNR IN @S_MATNR
      AND MATNR_N IN @S_MAKTX

    APPENDING CORRESPONDING FIELDS OF TABLE @GT_LIST.

*3단계: 입고 대상인데 위 ①②에 없는 품목(기준일에 유효한 단가 조건이 없는 품목)
*       기준일 이전에 종료된 마지막 조건(이전 단가) 기준으로 보강. 기존 ①② 로직은 변경하지 않음.
*       이전 조건이 유효했던 종료일을 RAW2 기준일로 호출해 INFO금액(이전 단가)·특성·템플릿·적용동가·입고수량을 채운다.
  SELECT FROM ZGTMM_CV_GET_TARGET_IVSUM
    FIELDS EKORG, WERKS, LIFNR, MATNR
    WHERE SPMON EQ @GV_SPMON
      AND EKORG EQ @P_EKORG
      AND WERKS EQ @P_WERKS
      AND LIFNR IN @S_LIFNR
      AND MATNR IN @S_MATNR
    INTO TABLE @DATA(LT_TGT).

*이미 목록에 있는 구매조직+플랜트+업체+자재는 제외
  LOOP AT LT_TGT ASSIGNING FIELD-SYMBOL(<LS_TGT>).
    READ TABLE GT_LIST TRANSPORTING NO FIELDS
         WITH KEY EKORG = <LS_TGT>-EKORG
                  WERKS = <LS_TGT>-WERKS
                  LIFNR = <LS_TGT>-LIFNR
                  MATNR = <LS_TGT>-MATNR.
    IF SY-SUBRC = 0.
      DELETE LT_TGT.
    ENDIF.
  ENDLOOP.

  IF LT_TGT[] IS NOT INITIAL.
*업체·자재·구매조직·플랜트별 기준일 이전에 종료된 마지막 조건의 종료일
    SELECT FROM ZGTMM_CV_GET_INFOPRICE AS P
      FIELDS P~LIFNR, P~MATNR, P~EKORG, P~WERKS,
             MAX( P~DATBI ) AS DATBI_PREV
      WHERE P~ESOKZ EQ '0'
        AND P~DATBI LT @P_BUDAT
        AND P~EINA_LOEKZ EQ ''
        AND P~EINE_LOEKZ EQ ''
        AND EXISTS (
##ITAB_KEY_IN_SELECT
          SELECT Z~MATNR
            FROM @LT_TGT AS Z
            WHERE Z~LIFNR EQ P~LIFNR
              AND Z~MATNR EQ P~MATNR
              AND Z~EKORG EQ P~EKORG
              AND Z~WERKS EQ P~WERKS
          )
      GROUP BY P~LIFNR, P~MATNR, P~EKORG, P~WERKS
      INTO TABLE @DATA(LT_PREV).

    IF LT_PREV[] IS NOT INITIAL.
*종료일이 같은 품목끼리 묶어 RAW2를 호출 (보통 월말 몇 개)
      DATA LT_DAYS TYPE STANDARD TABLE OF SY-DATUM WITH DEFAULT KEY.
      CLEAR LT_DAYS.
      LOOP AT LT_PREV ASSIGNING FIELD-SYMBOL(<LS_PREV0>).
        APPEND <LS_PREV0>-DATBI_PREV TO LT_DAYS.
      ENDLOOP.
      SORT LT_DAYS.
      DELETE ADJACENT DUPLICATES FROM LT_DAYS.

      LOOP AT LT_DAYS INTO DATA(LV_DAY).
        DATA(LV_FROM) = LINES( GT_LIST ) + 1.

        SELECT FROM ZGTMM_CV_GET_OEM_CAL_RAW2(
                                p_datE = @LV_DAY, P_MON = @GV_SPMON ) AS R2
          FIELDS *
          WHERE EXISTS (
##ITAB_KEY_IN_SELECT
            SELECT ZZ~MATNR
              FROM @LT_PREV AS ZZ
              WHERE ZZ~DATBI_PREV EQ @LV_DAY
                AND ZZ~LIFNR EQ R2~LIFNR
                AND ZZ~MATNR EQ R2~MATNR
                AND ZZ~EKORG EQ R2~EKORG
                AND ZZ~WERKS EQ R2~WERKS
            )
            AND R2~ESOKZ EQ '0'
            AND R2~MATNR_N IN @S_MAKTX
          APPENDING CORRESPONDING FIELDS OF TABLE @GT_LIST.

*이전 단가 기준으로 추가된 행 표시
        LOOP AT GT_LIST ASSIGNING FIELD-SYMBOL(<LS_PREV>) FROM LV_FROM.
          <LS_PREV>-PERIOD  = GV_SPMON.
          <LS_PREV>-MESSAGE = |[이전단가] { <LS_PREV>-MESSAGE }|.
        ENDLOOP.
      ENDLOOP.
    ENDIF.
  ENDIF.

*    ENDIF.

    IF GT_LIST[] IS NOT INITIAL.
        LOOP AT GT_LIST ASSIGNING FIELD-SYMBOL(<LS_LIST>).
*일괄적용(단가) 버튼을 위한 데이터 담아두기. 통화참조용.
          GS_ONCE-WAERS = <LS_LIST>-KWAERS.
*어느 뷰에서 가져오든 아래 금액 필드 계산식은 동일.
          "CU 총금액
*           IF <LS_LIST>-CU_PRICE_TOTAL = 0.
          <LS_LIST>-CU_PRICE_TOTAL = ( <LS_LIST>-CU_LMC + <LS_LIST>-SCR_SC ) *
                       ( <LS_LIST>-CU_C_QTY + <LS_LIST>-CU_S_QTY + <LS_LIST>-CU_T_QTY ) / 1000 .
*          ENDIF.
*           IF <LS_LIST>-AL_PRICE_TOTAL = 0.
          "AL 총금액
          <LS_LIST>-AL_PRICE_TOTAL = ( ( <LS_LIST>-AL_C_QTY * <LS_LIST>-AL_C_PRICE ) +
                                                         ( <LS_LIST>-AL_S_QTY * <LS_LIST>-AL_S_PRICE ) ) / 1000 .
*          ENDIF.
          "재료/가공비 총금액
          <LS_LIST>-SUB_PRICE_TOTAL = <LS_LIST>-S_MAT_COST + <LS_LIST>-MFG_COST + <LS_LIST>-PKG_COST  + <LS_LIST>-ADD_COST.
          "OEM 적용가
          <LS_LIST>-OEM_PRICE = <LS_LIST>-CU_PRICE_TOTAL + <LS_LIST>-AL_PRICE_TOTAL + <LS_LIST>-SUB_PRICE_TOTAL +  <LS_LIST>-ETC_COST.
          "월 정산 대상 금액
          <LS_LIST>-AP_PRICE = <LS_LIST>-GR_QTY * <LS_LIST>-OEM_PRICE.
**ZGTMM_CV_GET_OEM_CAL_SCHMA에 데이터가 없어,ZGTMM_CV_GET_OEM_CAL_RAW2 데이터
**가져온 경우에는 아래 필드 별도 설정.
*          IF LV_RAW2 = GC_X.
*            "월
*            <LS_LIST>-PERIOD = GV_SPMON.
*
*            CLEAR : <LS_LIST>-DIS_PRICE, <LS_LIST>-DRUM_SPEC,
*                         <LS_LIST>-MTYPE, <LS_LIST>-MESSAGE, <LS_LIST>-ERDAT, <LS_LIST>-ERDAT_LOCAL,
*                         <LS_LIST>-ERTIM, <LS_LIST>-ERTIM_LOCAL, <LS_LIST>-ERNAM, <LS_LIST>-AEDAT,
*                         <LS_LIST>-AEDAT_LOCAL, <LS_LIST>-AETIM, <LS_LIST>-AETIM_LOCAL, <LS_LIST>-AENAM.
*          ENDIF.
        ENDLOOP.
    ENDIF.

    SORT GT_LIST BY EKORG WERKS LIFNR MATNR PRDNAME PRODSIZE SPEC_NO COLOR.


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

*  CHECK PO_GRID IS BOUND.

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
                                     PT_GOOD_CELLS TYPE LVC_T_MODI
                                     PO_SENDER.

  CHECK PV_MODIFIED IS NOT INITIAL.

  CASE PO_SENDER.
    WHEN GCL_GRID.

      LOOP AT PT_GOOD_CELLS INTO DATA(LS_MOD_CELLS).

        READ TABLE GT_LIST ASSIGNING FIELD-SYMBOL(<LS_LIST>)
                                               INDEX LS_MOD_CELLS-ROW_ID.

        CASE LS_MOD_CELLS-FIELDNAME.
          WHEN 'S_MAT_COST' OR 'MFG_COST' OR 'PKG_COST' OR 'ADD_COST' OR
                       'ETC_COST' OR 'GR_QTY' OR 'DIS_PRICE'.
*비용/수량 변경 시, CU·AL 총금액(직접 입력값 포함)은 유지하고 재료/가공비~OEM 적용가만 재계산
            "재료/가공비 총금액
            <LS_LIST>-SUB_PRICE_TOTAL = <LS_LIST>-S_MAT_COST + <LS_LIST>-MFG_COST + <LS_LIST>-PKG_COST + <LS_LIST>-ADD_COST.
            "OEM 적용가
            <LS_LIST>-OEM_PRICE = <LS_LIST>-CU_PRICE_TOTAL + <LS_LIST>-AL_PRICE_TOTAL + <LS_LIST>-SUB_PRICE_TOTAL + <LS_LIST>-ETC_COST.
            "월 정산 대상 금액
            <LS_LIST>-AP_PRICE = <LS_LIST>-GR_QTY * <LS_LIST>-OEM_PRICE.
          WHEN 'CU_LMC' OR 'SCR_SC' OR 'CU_C_QTY' OR 'CU_S_QTY' OR
                       'CU_T_QTY' OR 'C_QTY' OR 'S_QTY' OR 'AL_C_PRICE' OR
                       'AL_S_PRICE' OR 'AL_C_QTY' OR 'AL_S_QTY'.
*위 필드 변경 시, CU/AL 총금액부터 월 정산 대상 금액(AP_PRICE)까지 자동 계산
            "CU 총금액
            <LS_LIST>-CU_PRICE_TOTAL =  ( <LS_LIST>-CU_LMC + <LS_LIST>-SCR_SC ) *
                                                           ( <LS_LIST>-CU_C_QTY + <LS_LIST>-CU_S_QTY + <LS_LIST>-CU_T_QTY ) / 1000 .
            "AL 총금액
            <LS_LIST>-AL_PRICE_TOTAL = ( ( <LS_LIST>-AL_C_QTY * <LS_LIST>-AL_C_PRICE ) +
                                                           ( <LS_LIST>-AL_S_QTY * <LS_LIST>-AL_S_PRICE ) ) / 1000.
            "재료/가공비 총금액
            <LS_LIST>-SUB_PRICE_TOTAL = <LS_LIST>-S_MAT_COST + <LS_LIST>-MFG_COST + <LS_LIST>-PKG_COST + <LS_LIST>-ADD_COST.
            "OEM 적용가
            <LS_LIST>-OEM_PRICE = <LS_LIST>-CU_PRICE_TOTAL + <LS_LIST>-AL_PRICE_TOTAL + <LS_LIST>-SUB_PRICE_TOTAL + <LS_LIST>-ETC_COST.
            "월 정산 대상 금액
            <LS_LIST>-AP_PRICE = <LS_LIST>-GR_QTY * <LS_LIST>-OEM_PRICE.
          WHEN 'CU_PRICE_TOTAL' or 'AL_PRICE_TOTAL'.
            "OEM 적용가
            <LS_LIST>-OEM_PRICE = <LS_LIST>-CU_PRICE_TOTAL + <LS_LIST>-AL_PRICE_TOTAL + <LS_LIST>-SUB_PRICE_TOTAL + <LS_LIST>-ETC_COST.
            "월 정산 대상 금액
            <LS_LIST>-AP_PRICE = <LS_LIST>-GR_QTY * <LS_LIST>-OEM_PRICE.
        ENDCASE.
      ENDLOOP.

    WHEN OTHERS.
  ENDCASE.

  PERFORM REFRESH_TABLE USING PO_SENDER SPACE.

  CALL METHOD CL_GUI_CFW=>SET_NEW_OK_CODE
    EXPORTING
      NEW_CODE = 'ENTER'.


ENDFORM.

*&---------------------------------------------------------------------*
*& FORM SET_CELL_STYLE
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
FORM SET_CELL_STYLE.

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


  GCL_GRID->SET_READY_FOR_INPUT( 1 ). "입력가능

  LOOP AT GT_LIST ASSIGNING FIELD-SYMBOL(<LS_LIST>).
    CLEAR : <LS_LIST>-STYLE[].

    IF <LS_LIST>-CLOSING = GC_X.  "DISABLED
    _SET_STYLE : GC_D 'CU_C_QTY' <LS_LIST>-STYLE,
                          GC_D 'SCR_SC' <LS_LIST>-STYLE,
                          GC_D 'AL_C_SPEC' <LS_LIST>-STYLE,
                          GC_D 'AL_C_QTY' <LS_LIST>-STYLE,
                          GC_D 'AL_C_PRICE' <LS_LIST>-STYLE,
                          GC_D 'CU_S_QTY' <LS_LIST>-STYLE,
                          GC_D 'AL_S_SPEC' <LS_LIST>-STYLE,
                          GC_D 'AL_S_QTY' <LS_LIST>-STYLE,
                          GC_D 'AL_S_PRICE' <LS_LIST>-STYLE,
                          GC_D 'CU_T_QTY' <LS_LIST>-STYLE,
                          GC_D 'CU_LMC' <LS_LIST>-STYLE,
                          GC_D 'MFG_COST' <LS_LIST>-STYLE,
                          GC_D 'PKG_COST' <LS_LIST>-STYLE,
                          GC_D 'ETC_COST' <LS_LIST>-STYLE,
                          GC_D 'DIS_PRICE' <LS_LIST>-STYLE,
                          GC_D 'DRUM_SPEC' <LS_LIST>-STYLE.

    ELSE. "ENABLED
      _SET_STYLE : GC_E 'MFG_COST' <LS_LIST>-STYLE,
                            GC_E 'PKG_COST' <LS_LIST>-STYLE,
                            GC_E 'ETC_COST' <LS_LIST>-STYLE,
                            GC_E 'DIS_PRICE' <LS_LIST>-STYLE,
                            GC_E 'DRUM_SPEC' <LS_LIST>-STYLE.

*      IF <LS_LIST>-CU_KGW IS INITIAL.
*        _SET_STYLE : GC_D 'CU_C_QTY' <LS_LIST>-STYLE,
*                              GC_D 'CU_S_QTY' <LS_LIST>-STYLE,
*                              GC_D 'CU_T_QTY' <LS_LIST>-STYLE,
*                              GC_D 'SCR_SC' <LS_LIST>-STYLE,
*                              GC_D 'CU_LMC' <LS_LIST>-STYLE.
*      ELSE.
        _SET_STYLE : GC_E 'CU_C_QTY' <LS_LIST>-STYLE,
                              GC_E 'CU_S_QTY' <LS_LIST>-STYLE,
                              GC_E 'CU_T_QTY' <LS_LIST>-STYLE,
                              GC_E 'SCR_SC' <LS_LIST>-STYLE,
                              GC_E 'CU_LMC' <LS_LIST>-STYLE.
*      ENDIF.

*      IF <LS_LIST>-AL_KGW IS INITIAL.
*        _SET_STYLE : GC_D 'AL_C_SPEC' <LS_LIST>-STYLE,
*                              GC_D 'AL_C_QTY' <LS_LIST>-STYLE,
*                              GC_D 'AL_C_PRICE' <LS_LIST>-STYLE,
*                              GC_D 'AL_S_SPEC' <LS_LIST>-STYLE,
*                              GC_D 'AL_S_QTY' <LS_LIST>-STYLE,
*                              GC_D 'AL_S_PRICE' <LS_LIST>-STYLE.
*      ELSE.
        _SET_STYLE : GC_E 'AL_C_SPEC' <LS_LIST>-STYLE,
                              GC_E 'AL_C_QTY' <LS_LIST>-STYLE,
                              GC_E 'AL_C_PRICE' <LS_LIST>-STYLE,
                              GC_E 'AL_S_SPEC' <LS_LIST>-STYLE,
                              GC_E 'AL_S_QTY' <LS_LIST>-STYLE,
                              GC_E 'AL_S_PRICE' <LS_LIST>-STYLE.
*      ENDIF.
    ENDIF.

  ENDLOOP.

ENDFORM.

**&---------------------------------------------------------------------*
**& FORM SET_CELL_COLOR
**&---------------------------------------------------------------------*
**& TEXT
**&---------------------------------------------------------------------*
*FORM SET_CELL_COLOR .
*
*  DATA : LS_COLOR TYPE    LVC_S_SCOL.
*
**  DEFINE _SET_COLOR.
**
**    LS_COLOR-FNAME = &1.
**    LS_COLOR-COLOR-COL = &2.
**    LS_COLOR-COLOR-INT  = &3
**    INSERT LS_STYLE INTO TABLE &4.
**
**  END-OF-DEFINITION.
*
*  LOOP AT GT_LIST ASSIGNING FIELD-SYMBOL(<LS_LIST>).
*
*    CLEAR : <LS_LIST>-COLO[].
*
**입고상태
*    LS_COLOR-FNAME = GC_ZGRSTATUS.
*    LS_COLOR-COLOR-COL = COND #( WHEN <LS_LIST>-ZGRSTATUS_C = GC_C
*                                                           THEN '6'
*                                                           WHEN <LS_LIST>-ZGRSTATUS_C = GC_D
*                                                           THEN '7' ELSE '0' ).
*    LS_COLOR-COLOR-INT   = '1'.
*    INSERT LS_COLOR INTO TABLE <LS_LIST>-COLO.
*
**정산상태
*    CLEAR LS_COLOR.
*
*    CASE <LS_LIST>-ZIVSTATUS_C.
*      WHEN GC_A OR GC_E.
*        LS_COLOR-FNAME = GC_ZIVSTATUS.
*        LS_COLOR-COLOR-COL = '6'.
*        LS_COLOR-COLOR-INT   = '1'.
*        INSERT LS_COLOR INTO TABLE <LS_LIST>-COLO.
*
*      WHEN GC_C OR GC_D.
*        LS_COLOR-FNAME = GC_ZIVSTATUS.
*        LS_COLOR-COLOR-COL = '7'.
*        LS_COLOR-COLOR-INT   = '1'.
*        INSERT LS_COLOR INTO TABLE <LS_LIST>-COLO.
*      WHEN OTHERS.
*    ENDCASE.
*
*  ENDLOOP.
*
*ENDFORM.

*&---------------------------------------------------------------------*
*& FORM SET_ALV_FIELDCAT
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
FORM SET_ALV_FIELDCAT.

  DATA :
    LR_TABDESCR TYPE REF TO CL_ABAP_STRUCTDESCR,
    LT_DFIES    TYPE DDFIELDS,
    LS_DFIES    TYPE DFIES,
    LT_FCAT     TYPE LVC_T_FCAT,
    LS_FCAT     TYPE LVC_S_FCAT.

  DATA : GR_DREF  TYPE REF TO DATA.

  CLEAR GR_DREF.
  IF GV_HOTSPOT IS INITIAL.
    CREATE DATA GR_DREF LIKE GS_LIST.
  ELSE.
    CREATE DATA GR_DREF LIKE GS_BOM.
  ENDIF.

  LR_TABDESCR ?= CL_ABAP_STRUCTDESCR=>DESCRIBE_BY_DATA_REF( GR_DREF ).
  LT_DFIES = CL_SALV_DATA_DESCR=>READ_STRUCTDESCR( LR_TABDESCR ) .

  REFRESH : LT_FCAT.

  LOOP AT LT_DFIES INTO LS_DFIES.
    CLEAR : LS_FCAT.
    MOVE-CORRESPONDING LS_DFIES TO LS_FCAT.
    APPEND LS_FCAT TO LT_FCAT.
  ENDLOOP.

*  " 필드 카탈로그 변경사항 적용
  IF GV_HOTSPOT IS INITIAL.
    PERFORM ADJUST_FLDCATS TABLES LT_FCAT.
  ELSE.
    PERFORM ADJUST_FLDCATS_BOM TABLES LT_FCAT.
  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*& FORM TOOLBAR
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
FORM TOOLBAR  USING PR_OBJ TYPE REF TO CL_ALV_EVENT_TOOLBAR_SET
                                     PO_SENDER.

  DATA : LS_TBAR TYPE STB_BUTTON.

  DEFINE _SET_TBAR.
    CLEAR : LS_TBAR.

    LS_TBAR-BUTN_TYPE = &1.
    LS_TBAR-FUNCTION   = &2.
    LS_TBAR-ICON           = &3.
    LS_TBAR-TEXT          = &4.
    LS_TBAR-QUICKINFO = &4.

    APPEND LS_TBAR TO PR_OBJ->MT_TOOLBAR.
  END-OF-DEFINITION.


  CASE PO_SENDER.

    WHEN GCL_GRID.
      IF GV_HOTSPOT IS INITIAL.

        _SET_TBAR 3 '    ' '              ' '    '.
        _SET_TBAR 0 'REFRESH' ICON_REFRESH 'REFRESH'(B01).
        _SET_TBAR 0 'ALL'  ICON_MASS_CHANGE   '일괄적용'(B02).
        _SET_TBAR 0 'TEMSAVE'  ICON_SYSTEM_SAVE  'TEMPLATE 저장'(B03).
        _SET_TBAR 0 'TEMDEL' ICON_DELETE 'TEMPLATE 삭제'(B04).
        _SET_TBAR 0 'KRWCAL' ICON_CALCULATION  '원화 계산식 관리'(B05).
        _SET_TBAR 0 'UPLOAD' ICON_TREND_UP  'EXCEL UPLOAD'(B06).
        _SET_TBAR 0 'CREATE' ICON_PRICE  '단가생성'(B07).

      ENDIF.

    WHEN OTHERS.

  ENDCASE.

ENDFORM.

*&---------------------------------------------------------------------*
*& FORM USER_COMMAND
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
FORM USER_COMMAND  USING PV_UCOMM LIKE SY-UCOMM.

  CLEAR : GV_ANSWER, GV_UCOMM.
  GV_UCOMM = PV_UCOMM.

  CASE PV_UCOMM.
    WHEN 'REFRESH'.
      PERFORM POPUP_TO_CONFIRM_STEP USING GC_N
                                                                TEXT-M04 "현재 작업 중인 데이터 존재 시, 모두 초기화 됩니다.
                                                                TEXT-M09  "계속 진행 하시겠습니까?
                                                                TEXT-T04. "확인
      CHECK GV_ANSWER = GC_J.
      PERFORM GET_DATA.
      PERFORM SET_CELL_STYLE.

    WHEN 'ALL'. "일괄적용
      PERFORM ONCE_CHANGE_DATA.

    WHEN 'TEMSAVE'.
      PERFORM TEMPLATE_SAVE_DEL USING PV_UCOMM.

    WHEN 'TEMDEL'.
      PERFORM TEMPLATE_SAVE_DEL USING PV_UCOMM.

    WHEN 'KRWCAL'. "원화계산식관리
      PERFORM CALCULATION_KRW_MANAGEMENT .

    WHEN 'UPLOAD'  .
      PERFORM EXCEL_UPLOAD.
      PERFORM SET_CELL_STYLE.

    WHEN 'CREATE'. "단가생성
      PERFORM CREATE_PRICE.

    WHEN OTHERS.
  ENDCASE.

  PERFORM REFRESH_TABLE USING GCL_GRID SPACE.

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
        PERFORM DATA_CHANGED_1 USING PO_DATA_CHANGED.

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
                                       TYPE REF TO CL_ALV_CHANGED_DATA_PROTOCOL.

  DATA : LV_ERR   TYPE CHAR1.

  LOOP AT PO_DATA_CHANGED->MT_GOOD_CELLS INTO DATA(LS_MOD_CELLS).

    READ TABLE GT_LIST  INTO DATA(LS_LIST) INDEX LS_MOD_CELLS-ROW_ID.
    CHECK SY-SUBRC EQ 0.

    PERFORM MODIFY_CELL USING PO_DATA_CHANGED LS_MOD_CELLS-FIELDNAME
                                                    LS_MOD_CELLS-VALUE LS_MOD_CELLS-ROW_ID.

    CASE LS_MOD_CELLS-FIELDNAME.

      WHEN 'CU_LMC' .   "적용동가
        LS_LIST-CU_LMC = LS_MOD_CELLS-VALUE.
      WHEN 'SCR_SC'.    "SCR가공비/
        LS_LIST-SCR_SC = LS_MOD_CELLS-VALUE.
      WHEN 'CU_C_QTY'."CU소요량(도체)
        LS_LIST-CU_C_QTY = LS_MOD_CELLS-VALUE.
      WHEN 'CU_S_QTY'."CU소요량(외장)
        LS_LIST-CU_S_QTY = LS_MOD_CELLS-VALUE.
      WHEN 'CU_T_QTY'. "CU소요량(Tape)
        LS_LIST-CU_T_QTY = LS_MOD_CELLS-VALUE.
      WHEN 'AL_C_SPEC'.  "AL SPEC(도체)
        LS_LIST-AL_C_SPEC = LS_MOD_CELLS-VALUE.
      WHEN 'AL_C_QTY'.   "AL 소요량(도체)
        LS_LIST-AL_C_QTY = LS_MOD_CELLS-VALUE.
      WHEN 'AL_C_PRICE'. "AL 단가(도체)
        LS_LIST-AL_C_PRICE = LS_MOD_CELLS-VALUE.
      WHEN 'AL_S_SPEC'.  "AL SPEC(외장)
        LS_LIST-AL_S_SPEC = LS_MOD_CELLS-VALUE.
      WHEN 'AL_S_QTY'.   "AL 소요량(외장)
        LS_LIST-AL_S_QTY = LS_MOD_CELLS-VALUE.
      WHEN 'AL_S_PRICE'. "AL 단가(외장)
        LS_LIST-AL_S_PRICE = LS_MOD_CELLS-VALUE.
      WHEN 'S_MAT_COST'. "부재료비
        LS_LIST-S_MAT_COST = LS_MOD_CELLS-VALUE.
      WHEN 'MFG_COST' .
        LS_LIST-MFG_COST = LS_MOD_CELLS-VALUE.
      WHEN 'PKG_COST' .
        LS_LIST-PKG_COST = LS_MOD_CELLS-VALUE.
      WHEN 'ETC_COST'.
        LS_LIST-ETC_COST = LS_MOD_CELLS-VALUE.
      WHEN  'DIS_PRICE'.
        LS_LIST-DIS_PRICE = LS_MOD_CELLS-VALUE.
      WHEN  'DRUM_SPEC'.
        LS_LIST-DRUM_SPEC = LS_MOD_CELLS-VALUE.
      WHEN 'EINE_LOEKZ'.
        LS_LIST-EINE_LOEKZ = LS_MOD_CELLS-VALUE.
      WHEN OTHERS.
    ENDCASE.

    MODIFY GT_LIST FROM LS_LIST INDEX LS_MOD_CELLS-ROW_ID.
  ENDLOOP.

*  IF LV_ERR IS NOT INITIAL.
*    CALL METHOD PO_DATA_CHANGED->DISPLAY_PROTOCOL.
*  ENDIF.

ENDFORM. " DATA_CHANGED_1
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
      I_MSGTY     = ZGTFI_E
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

  CHECK PS_ROW_NO-ROWTYPE IS INITIAL.
  CLEAR GV_HOTSPOT.

  CASE PO_SENDER.
     WHEN GCL_GRID.
        READ TABLE GT_LIST INTO DATA(LS_LIST0) INDEX PS_ROW_NO-INDEX.
        CHECK SY-SUBRC = 0.

        IF PS_COLUMN-FIELDNAME = 'MATNR'.
           CHECK ls_list0-MATNR IS NOT INITIAL.
           SET PARAMETER ID 'MAT' FIELD ls_list0-MATNR.
           CALL TRANSACTION 'MM03' AND SKIP FIRST SCREEN.

        ELSEIF   PS_COLUMN-FIELDNAME = 'INFNR'.
           CHECK ls_list0-MATNR IS NOT INITIAL AND  ls_list0-LIFNR IS NOT INITIAL.
           SET PARAMETER ID 'LIF' FIELD ls_list0-LIFNR. " Vendor Number
           SET PARAMETER ID 'MAT' FIELD ls_list0-MATNR. " Material Number
           SET PARAMETER ID 'EKO' FIELD ls_list0-EKORG. " Purchasing Organization
           SET PARAMETER ID 'WRK' FIELD ls_list0-WERKS.
           CALL TRANSACTION 'ME13' AND SKIP FIRST SCREEN.
        ELSE.
          EXIT.
        ENDIF.

    WHEN GCL_GRID_BOM.
        READ TABLE GT_LIST INTO DATA(LS_LIST) INDEX PS_ROW_NO-INDEX.
        CHECK SY-SUBRC = 0.

        IF PS_COLUMN-FIELDNAME = 'MATNR'.
          CHECK LS_LIST-MATNR IS NOT INITIAL.

          SELECT FROM ZGTMM_CV_GET_BOM_REC3(
            P_MATNR = @LS_LIST-MATNR,
            P_WERKS = @LS_LIST-WERKS,
            P_DATUM = @P_BUDAT )
            FIELDS *
            INTO CORRESPONDING FIELDS OF TABLE @GT_BOM.

            IF GT_BOM[] IS NOT INITIAL.
                GV_HOTSPOT = GC_X.
                SORT GT_BOM BY BOMLEVEL COMPONENT.
                CALL SCREEN 0300.
            ENDIF.

        ELSE.
          EXIT.
        ENDIF.

    WHEN OTHERS.
  ENDCASE.

ENDFORM.

**&---------------------------------------------------------------------*
**&      FORM  ON_F4
**&---------------------------------------------------------------------*
FORM ON_F4  USING E_FIELDNAME    TYPE LVC_FNAME
                  E_FIELDVALUE   TYPE LVC_VALUE
                  ES_ROW_NO      TYPE LVC_S_ROID
                  ER_EVENT_DATA  TYPE REF TO CL_ALV_EVENT_DATA
                  ET_BAD_CELLS   TYPE LVC_T_MODI
                  E_DISPLAY      TYPE CHAR01.

  DATA : LT_RETURN TYPE TABLE OF DDSHRETVAL,
             LS_RETURN TYPE DDSHRETVAL,
             LS_MODI      TYPE LVC_S_MODI.
  DATA : LV_MWSKZ TYPE MWSKZ.

  FIELD-SYMBOLS : <F4TAB> TYPE LVC_T_MODI.
  ASSIGN ER_EVENT_DATA->M_DATA->* TO <F4TAB>.

  CLEAR : LS_RETURN, LT_RETURN.

  IF E_FIELDNAME = 'AL_C_SPEC' OR E_FIELDNAME = 'AL_S_SPEC'.
*"데이터 추출 (HRKFT = 'M102'인 SPECCODE만)
    SELECT HRKFT, SPECCODE
      FROM ZGTMMT1090
      WHERE HRKFT = @GC_M102
      INTO TABLE @DATA(LT_TEMP).

*F4 HELP 호출
    CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
      EXPORTING
        RETFIELD        = 'SPECCODE'         " 내부 테이블에서 가져올 필드명
        WINDOW_TITLE    = '스펙 코드 선택'
        VALUE_ORG       = 'S'
      TABLES
        VALUE_TAB       = LT_TEMP       " 데이터가 담긴 ITAB
        RETURN_TAB      = LT_RETURN   " 사용자가 선택한 행의 정보가 담김
      EXCEPTIONS
        PARAMETER_ERROR = 1
        NO_VALUES_FOUND = 2
        OTHERS          = 3.

    IF SY-SUBRC <> 0.
      MESSAGE S000 WITH 'POSSIBLE ENTRY DATA가 없습니다 !!!'.
    ENDIF.

    IF SY-SUBRC = 0 AND LT_RETURN IS NOT INITIAL.
        READ TABLE LT_RETURN INTO LS_RETURN INDEX 1.

        CLEAR : LS_MODI.
        LS_MODI-ROW_ID      = ES_ROW_NO-ROW_ID.
        LS_MODI-FIELDNAME =  E_FIELDNAME.
        LS_MODI-VALUE        = LS_RETURN-FIELDVAL.
        APPEND LS_MODI TO <F4TAB>.
    ENDIF.

  ENDIF.

* TO AVOID STANDARD F4-HELP.
  ER_EVENT_DATA->M_EVENT_HANDLED = 'X'.

ENDFORM.                                                    " ON_F41

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
FORM GET_SELECTED_ROWS USING PR_GRID TYPE REF TO CL_GUI_ALV_GRID.

  DATA LV_MSG TYPE BAPI_MSG.

  CLEAR : GT_ROWS, GS_ROW, GV_ERR.

  CALL METHOD PR_GRID->GET_SELECTED_ROWS
    IMPORTING
      ET_INDEX_ROWS = GT_ROWS.

  DESCRIBE TABLE GT_ROWS.

  IF SY-TFILL = 0.
    GV_ERR = GC_X.

    CASE GV_UCOMM . "SY-UCOMM.
      WHEN 'ALL'.
        LV_MSG = '일괄 적용할 데이터를 선택하세요.'(E06).
      WHEN 'TEMSAVE'.
        LV_MSG = 'TEMPLATE 저장할 데이터를 선택하세요.'(E07).
      WHEN 'TEMDEL'.
        LV_MSG = 'TEMPLATE 삭제할 데이터를 선택하세요.'(E09).
      WHEN 'CREATE'.
        LV_MSG = '단가 생성할 데이터를 선택하세요.'(E08).
      WHEN OTHERS.
    ENDCASE.

    MESSAGE S000 WITH LV_MSG DISPLAY LIKE GC_E.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& FORM ONCE_CHANGE_DATA
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
*& -->  P1        TEXT
*& <--  P2        TEXT
*&---------------------------------------------------------------------*
FORM ONCE_CHANGE_DATA.

  CLEAR : GV_ANSWER, GV_ERR.

  PERFORM GET_SELECTED_ROWS USING GCL_GRID.

  IF GT_ROWS[] IS NOT INITIAL AND LINE_EXISTS( GT_LIST[ CLOSING = GC_X ] ).
      MESSAGE S000 WITH TEXT-E05 DISPLAY LIKE GC_E.
      GV_ERR = GC_X. EXIT."마감이 끝난 데이터는 수정할 수 없습니다.
  ELSE.
    READ TABLE GT_ROWS INTO DATA(LS_ROW) INDEX 1.
    CHECK SY-SUBRC = 0.

    READ TABLE GT_LIST ASSIGNING FIELD-SYMBOL(<LIST>)
    INDEX LS_ROW-INDEX.
    IF SY-SUBRC = 0.
      GS_ONCE-WAERS = <LIST>-KWAERS.
    ENDIF.
  ENDIF.

  CHECK GV_ERR IS INITIAL.

  GV_INFO = '일괄 적용 값을 입력 후 선택하세요.'(M14).
  CALL SCREEN 0200 STARTING AT 5 10.


ENDFORM.
*&---------------------------------------------------------------------*
*& FORM TEMPLATE_SAVE_DEL
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
*& -->  P1        TEXT
*& <--  P2        TEXT
*&---------------------------------------------------------------------*
FORM TEMPLATE_SAVE_DEL USING PV_GB.

  DATA : LV_MSG TYPE BAPI_MSG,
             LV_MSG2 TYPE BAPI_MSG,
             LS_1112 TYPE ZGTMMT1112,
             LT_1112 TYPE TABLE OF ZGTMMT1112.

  CLEAR : GV_ANSWER, GV_ERR.

  PERFORM GET_SELECTED_ROWS USING GCL_GRID.
  CHECK GV_ERR IS INITIAL.

  LV_MSG = COND #( WHEN PV_GB = 'TEMSAVE' THEN TEXT-M05 ELSE TEXT-M08 ).
  LV_MSG2 = COND #( WHEN PV_GB = 'TEMSAVE' THEN TEXT-M07 ELSE TEXT-M06 ).

  PERFORM POPUP_TO_CONFIRM_STEP USING GC_N
                                                                       LV_MSG
                                                                       LV_MSG2
                                                                       TEXT-T04.
  CHECK GV_ANSWER = GC_J.

  LOOP AT GT_ROWS INTO DATA(LS_ROW).
     READ TABLE GT_LIST ASSIGNING FIELD-SYMBOL(<FS>) INDEX LS_ROW-INDEX.
     IF SY-SUBRC = 0.

        CLEAR LS_1112.
        LS_1112 = CORRESPONDING #( <FS> ).
        LS_1112-ERDAT = LS_1112-AEDAT  = SY-DATUM.
        LS_1112-ERDAT_LOCAL = LS_1112-AEDAT_LOCAL = SY-DATLO.
        LS_1112-ERTIM = LS_1112-AETIM = SY-UZEIT.
        LS_1112-ERTIM_LOCAL = LS_1112-AETIM_LOCAL = SY-TIMLO.
        LS_1112-ERNAM = LS_1112-AENAM = SY-UNAME.
        APPEND LS_1112 TO LT_1112.

     ENDIF.
  ENDLOOP.

  IF LT_1112[] IS INITIAL.
     MESSAGE S010 DISPLAY LIKE GC_E. "저장에 실패했습니다.
  ELSE.
    IF PV_GB = 'TEMSAVE'.
      MODIFY ZGTMMT1112 FROM TABLE LT_1112.
      IF SY-SUBRC = 0.
        COMMIT WORK AND WAIT.
        MESSAGE S080. "저장성공
      ELSE.
        MESSAGE S010 DISPLAY LIKE GC_E. "저장에 실패했습니다.
      ENDIF.

    ELSE.
      DELETE ZGTMMT1112 FROM TABLE LT_1112.
      IF SY-SUBRC = 0.
        COMMIT WORK AND WAIT.
        MESSAGE S036 WITH TEXT-B04  DISPLAY LIKE GC_S. "TEMPALTE 삭제 성공했습니다.
      ELSE.
        MESSAGE S014 DISPLAY LIKE GC_E. "삭제에 실패했습니다.
      ENDIF.
    ENDIF.

  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*& FORM SET_ONCE_PRICE
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
*& -->  P1        TEXT
*& <--  P2        TEXT
*&---------------------------------------------------------------------*
FORM SET_ONCE_PRICE .

  CLEAR : GV_ANSWER, GV_ERR.

  LOOP AT GT_ROWS INTO GS_ROW.
    READ TABLE GT_LIST  INTO DATA(LS_LIST) INDEX GS_ROW-INDEX.
    IF SY-SUBRC = 0.

     GS_ONCE-WAERS = LS_LIST-KWAERS.

     IF GS_ONCE-CHK_CU = GC_X AND GS_ONCE-CU_LMC IS NOT INITIAL AND LS_LIST-CU_KGW > 0.
        LS_LIST-CU_LMC = GS_ONCE-CU_LMC.
     ENDIF.

     IF GS_ONCE-CHK_SCR = GC_X AND GS_ONCE-SCR_SC IS NOT INITIAL AND LS_LIST-CU_KGW > 0.
        LS_LIST-SCR_SC = GS_ONCE-SCR_SC.
     ENDIF.

     IF GS_ONCE-CHK_1350 = GC_X AND GS_ONCE-AL1350 IS NOT INITIAL.
        LS_LIST-AL_C_PRICE = COND #( WHEN LS_LIST-AL_C_SPEC = 'AL1350'
                                                          THEN GS_ONCE-AL1350 ELSE LS_LIST-AL_C_PRICE ).
        LS_LIST-AL_S_PRICE = COND #( WHEN LS_LIST-AL_S_SPEC = 'AL1350'
                                                          THEN GS_ONCE-AL1350 ELSE LS_LIST-AL_S_PRICE ).
     ENDIF.

     IF GS_ONCE-CHK_STAL = GC_X AND GS_ONCE-STAL IS NOT INITIAL.
        LS_LIST-AL_C_PRICE = COND #( WHEN LS_LIST-AL_C_SPEC = 'STAL'
                                                          THEN GS_ONCE-STAL ELSE LS_LIST-AL_C_PRICE ).
        LS_LIST-AL_S_PRICE = COND #( WHEN LS_LIST-AL_S_SPEC = 'STAL'
                                                          THEN GS_ONCE-STAL ELSE LS_LIST-AL_S_PRICE ).
     ENDIF.

     IF GS_ONCE-CHK_HTAL = GC_X AND GS_ONCE-HTAL IS NOT INITIAL.
        LS_LIST-AL_C_PRICE = COND #( WHEN LS_LIST-AL_C_SPEC = 'HTAL'
                                                          THEN GS_ONCE-HTAL ELSE LS_LIST-AL_C_PRICE ).
        LS_LIST-AL_S_PRICE = COND #( WHEN LS_LIST-AL_S_SPEC = 'HTAL'
                                                          THEN GS_ONCE-HTAL ELSE LS_LIST-AL_S_PRICE ).
     ENDIF.

     IF GS_ONCE-CHK_8176 = GC_X AND GS_ONCE-AL8176 IS NOT INITIAL.
        LS_LIST-AL_C_PRICE = COND #( WHEN LS_LIST-AL_C_SPEC = 'AL8176'
                                                          THEN GS_ONCE-AL8176 ELSE LS_LIST-AL_C_PRICE ).
        LS_LIST-AL_S_PRICE = COND #( WHEN LS_LIST-AL_S_SPEC = 'AL8176'
                                                          THEN GS_ONCE-AL8176 ELSE LS_LIST-AL_S_PRICE ).
     ENDIF.

     IF GS_ONCE-CHK_DIS = GC_X AND GS_ONCE-DIS_PRICE IS NOT INITIAL.
        LS_LIST-DIS_PRICE = GS_ONCE-DIS_PRICE.
     ENDIF.
*위 필드 일괄 변경에 따른 금액 재계산
     "CU 총금액
     LS_LIST-CU_PRICE_TOTAL =  ( LS_LIST-CU_LMC + LS_LIST-SCR_SC ) *
                                                  ( LS_LIST-CU_C_QTY + LS_LIST-CU_S_QTY + LS_LIST-CU_T_QTY ) / 1000 .
     "AL 총금액
     LS_LIST-AL_PRICE_TOTAL = ( ( LS_LIST-AL_C_QTY * LS_LIST-AL_C_PRICE ) +
                                                ( LS_LIST-AL_S_QTY * LS_LIST-AL_S_PRICE ) ) / 1000 .
     "재료/가공비 총금액
     LS_LIST-SUB_PRICE_TOTAL = LS_LIST-S_MAT_COST + LS_LIST-MFG_COST + LS_LIST-PKG_COST + LS_LIST-ADD_COST.
     "OEM 적용가
     LS_LIST-OEM_PRICE = LS_LIST-CU_PRICE_TOTAL + LS_LIST-AL_PRICE_TOTAL + LS_LIST-SUB_PRICE_TOTAL + LS_LIST-ETC_COST.
     "월 정산 대상 금액
     LS_LIST-AP_PRICE = LS_LIST-GR_QTY * LS_LIST-OEM_PRICE.

      MODIFY GT_LIST FROM LS_LIST INDEX GS_ROW-INDEX.
    ENDIF.

    CLEAR : LS_LIST.
  ENDLOOP.

  CLEAR : GS_ONCE.

ENDFORM.
*&---------------------------------------------------------------------*
*& FORM CALCULATION_KRW_MANAGEMENT
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
*& -->  P1        TEXT
*& <--  P2        TEXT
*&---------------------------------------------------------------------*
FORM CALCULATION_KRW_MANAGEMENT .

    DATA LV_MSG      TYPE STRING.

    SELECT SINGLE BUKRS
      FROM T024E
      WHERE EKORG = @P_EKORG
      INTO @DATA(LV_BUKRS).

    IF LV_BUKRS IS NOT INITIAL.
      SET PARAMETER ID 'BUK' FIELD LV_BUKRS. "회사 코드 메모리에 저장
    ENDIF.

    TRY.

    CALL FUNCTION 'VIEW_MAINTENANCE_CALL'
      EXPORTING
        ACTION                       = 'U'         " 'U'는 수정 모드, 'S'는 조회 모드
        VIEW_NAME                = 'ZGTMMV1100' " 호출할 유지보수 뷰
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
*& FORM EXCEL_UPLOAD_OPT1
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
*& -->  P1        TEXT
*& <--  P2        TEXT
*&---------------------------------------------------------------------*
FORM EXCEL_UPLOAD.

*EXCEL 업로드 시 ALV 에 데이터가 존재하면 데이터 CLEAR 후 엑셀 입력 데이터로 반영
*  PERFORM GET_EXCEL_DATA USING 1 1 50 60000 'TY_LIST' CHANGING GT_LIST.
  PERFORM GET_EXCEL_DATA_NEW USING 1 1 80 60000 'TY_LIST' CHANGING GT_LIST.

  "데이터 설정
  PERFORM SET_ALV_DATA_OPT1 CHANGING GT_LIST.

ENDFORM.
*&---------------------------------------------------------------------*
*& FORM GET_EXCEL_DATA
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
*&      --> P_1
*&      --> P_4
*&      --> P_1
*&      --> P_6000
*&      <-- LT_XLS
*&---------------------------------------------------------------------*
FORM GET_EXCEL_DATA  USING PV_BEGIN_COL
                                                      PV_BEGIN_ROW
                                                      PV_END_COL
                                                      PV_END_ROW
                                                      PV_T_TYPE
                       CHANGING CT_XLS TYPE STANDARD TABLE.
  CLEAR:
     CT_XLS[].

  DATA:
      LV_FILENAME  TYPE STRING,
      LT_FILE_TABLE TYPE FILETABLE,
      LV_RC         TYPE I,
      LT_BIN_DATA   TYPE SOLIX_TAB, " BINARY 데이터를 담을 테이블
      LV_BIN_SIZE   TYPE I,
      LV_USER_ACTION TYPE I,
      LV_MSG     TYPE BAPI_MSG,
      LV_CONTENT    TYPE XSTRING.   " 최종 변환될 XSTRING

  DATA: LT_COMPONENTS TYPE CL_ABAP_STRUCTDESCR=>COMPONENT_TABLE,
            LS_COMPONENT  LIKE LINE OF LT_COMPONENTS.

" 1. 파일 선택 다이얼로그 (경로 확보)
  CALL METHOD CL_GUI_FRONTEND_SERVICES=>FILE_OPEN_DIALOG
    CHANGING
      FILE_TABLE = LT_FILE_TABLE
      RC              = LV_RC
      USER_ACTION  = LV_USER_ACTION
    EXCEPTIONS
      FILE_OPEN_DIALOG_FAILED = 1
      CNTL_ERROR              = 2
      ERROR_NO_GUI            = 3
      NOT_SUPPORTED_BY_GUI    = 4
      OTHERS                  = 5.

  IF SY-SUBRC <> 0 OR LV_USER_ACTION = CL_GUI_FRONTEND_SERVICES=>ACTION_CANCEL..
     MESSAGE S023 DISPLAY LIKE GC_E. EXIT.
  ENDIF.

  CHECK LT_FILE_TABLE[] IS NOT INITIAL.

  READ TABLE LT_FILE_TABLE INDEX 1 INTO DATA(LS_FILE).
  LV_FILENAME = LS_FILE-FILENAME.

* 2. 파일을 바이너리(BIN) 형식으로 업로드
  CALL METHOD CL_GUI_FRONTEND_SERVICES=>GUI_UPLOAD
    EXPORTING
      FILENAME   = LV_FILENAME
      FILETYPE   = 'BIN'
    IMPORTING
      FILELENGTH = LV_BIN_SIZE
    CHANGING
    DATA_TAB   = LT_BIN_DATA.

* 3. SOLIX TABLE -> XSTRING 변환
  LV_CONTENT = CL_BCS_CONVERT=>SOLIX_TO_XSTRING( IT_SOLIX = LT_BIN_DATA
                                                                                          IV_SIZE = LV_BIN_SIZE ).

* 4. 엑셀 객체 생성
  TRY.
    DATA(LO_EXCEL) = NEW CL_FDT_XL_SPREADSHEET(
                                DOCUMENT_NAME = LV_FILENAME
                                XDOCUMENT     = LV_CONTENT  ).
      CATCH CX_ROOT INTO DATA(LV_ERR).
        LV_MSG = LV_ERR->GET_TEXT( ).
        MESSAGE S000 WITH LV_MSG.
  ENDTRY.

  DATA LO_EXCEL_IF TYPE REF TO IF_FDT_DOC_SPREADSHEET.
  LO_EXCEL_IF = CAST #( LO_EXCEL ).

" 시트 목록 중 첫 번째 시트 이름 가져오기
  DATA: LT_WORKSHEETS TYPE IF_FDT_DOC_SPREADSHEET=>T_WORKSHEET_NAMES.
  LO_EXCEL_IF->GET_WORKSHEET_NAMES(
    IMPORTING
      WORKSHEET_NAMES = LT_WORKSHEETS ).

  READ TABLE LT_WORKSHEETS INDEX 1 INTO DATA(LV_SHEET_NAME).

" 해당 시트의 데이터를 동적 구조로 확보
  DATA: LO_DATA TYPE REF TO DATA.
  LO_DATA = LO_EXCEL_IF->GET_ITAB_FROM_WORKSHEET( LV_SHEET_NAME ).

  IF LO_DATA IS BOUND.
    FIELD-SYMBOLS <LT_DATA> TYPE STANDARD TABLE.
    ASSIGN LO_DATA->* TO <LT_DATA>. " 엑셀의 전체 데이터
  ENDIF.

"헤더의 필드명과 필드타입 설정.
  READ TABLE <LT_DATA> INDEX 1 ASSIGNING FIELD-SYMBOL(<LS_HD_ROW>).
  IF SY-SUBRC = 0.
    DO.
      ASSIGN COMPONENT SY-INDEX OF STRUCTURE <LS_HD_ROW> TO FIELD-SYMBOL(<LV_HD_VAL>).
      IF SY-SUBRC <> 0. EXIT. ENDIF.

*GT_FCAT에서 REPTEXT 비교하여 필드 정보 찾기(업로드양식의 필드명은 한글-필드캣의 REPTEXT임)
      READ TABLE GT_FCAT INTO DATA(LS_FCAT) WITH KEY REPTEXT = <LV_HD_VAL>.
      IF SY-SUBRC = 0.
      " TY_LIST 구조체에서 해당 필드의 원본 타입 정보를 가져와 컴포넌트 추가
        APPEND VALUE #(
        NAME = LS_FCAT-FIELDNAME
        TYPE = CAST CL_ABAP_DATADESCR( CL_ABAP_TYPEDESCR=>DESCRIBE_BY_NAME(
                            'TY_LIST-' && LS_FCAT-FIELDNAME ) )      ) TO LT_COMPONENTS.
      ENDIF.
    ENDDO.
  ENDIF.

*5. 엑셀 컬럼 구성에 맞는 설계도(RTTS) 생성 (업로드 구조체)
  DATA(LO_NEW_STRUCT) = CL_ABAP_STRUCTDESCR=>CREATE( LT_COMPONENTS ).
*  DATA(LO_NEW_TABLE) = CL_ABAP_TABLEDESCR=>CREATE( LO_NEW_STRUCT ).
  "동적 ITAB의 구조와 동일한 신규 WORK AREA 생성
  DATA: LR_WA TYPE REF TO DATA.
  CREATE DATA LR_WA TYPE HANDLE LO_NEW_STRUCT.
  ASSIGN LR_WA->* TO FIELD-SYMBOL(<LS_WA>).

**6. 실제 ITAB 메모리 할당
**<LT_DATA>는 엑셀 원본 데이터, <LT_EXEL>은 RTTS로 만든 동적 ITAB
*  DATA:
*    LR_DATA     TYPE REF TO DATA.
*  FIELD-SYMBOLS <LT_EXEL> TYPE STANDARD TABLE.
*
*  CREATE DATA LR_DATA TYPE HANDLE LO_NEW_TABLE.
*  ASSIGN LR_DATA->* TO <LT_EXEL>.

  LOOP AT <LT_DATA> ASSIGNING FIELD-SYMBOL(<LS_ROW>) FROM 2.
" 2행부터 데이터 시작 (1행 헤더 제외)
    DO.
    " 엑셀의 N번째 컬럼 읽기
      ASSIGN COMPONENT SY-INDEX OF STRUCTURE <LS_ROW> TO FIELD-SYMBOL(<LV_EXCEL_VAL>).
      IF SY-SUBRC <> 0. EXIT. ENDIF. " 더 이상 읽을 컬럼이 없으면 종료

    " 대응하는 동적 ITAB 구조체의 N번째 필드에 값 할당
      ASSIGN COMPONENT SY-INDEX OF STRUCTURE <LS_WA> TO FIELD-SYMBOL(<LV_TARGET_FIELD>).
      IF SY-SUBRC = 0.
      " 엑셀의 문자열 값을 타겟 필드의 데이터 타입에 맞게 할당
      <LV_TARGET_FIELD> = <LV_EXCEL_VAL>.
      ENDIF.
    ENDDO.

*완성된 한 줄을 MAIN ITAB에 추가
*    APPEND <LS_WA> TO <LT_EXEL>.
    CLEAR GS_LIST.
    GS_LIST = CORRESPONDING #( <LS_WA> ).
    APPEND GS_LIST TO CT_XLS.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& FORM GET_EXCEL_DATA_NEW
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
*&      --> P_1
*&      --> P_4
*&      --> P_1
*&      --> P_6000
*&      <-- LT_XLS
*&---------------------------------------------------------------------*
FORM GET_EXCEL_DATA_NEW  USING PV_BEGIN_COL
                                                      PV_BEGIN_ROW
                                                      PV_END_COL
                                                      PV_END_ROW
                                                      PV_T_TYPE
                       CHANGING CT_XLS TYPE STANDARD TABLE.
  CLEAR:
     CT_XLS[].

  DATA:
      LV_FILENAME  TYPE RLGRAP-FILENAME,"STRING,
      LT_FILE_TABLE TYPE FILETABLE,
      LV_RC         TYPE I,
      LT_BIN_DATA   TYPE SOLIX_TAB, " BINARY 데이터를 담을 테이블
      LV_BIN_SIZE   TYPE I,
      LV_USER_ACTION TYPE I,
      LV_PREV_ROW TYPE I,
      LV_MSG     TYPE BAPI_MSG,
      LV_CONTENT    TYPE XSTRING.   " 최종 변환될 XSTRING

  DATA: LT_COMPONENTS TYPE CL_ABAP_STRUCTDESCR=>COMPONENT_TABLE,
            LT_NEW_COMPONENTS TYPE CL_ABAP_STRUCTDESCR=>COMPONENT_TABLE,
            LS_COMPONENT  LIKE LINE OF LT_COMPONENTS.

" 1. 파일 선택 다이얼로그 (경로 확보)
  CALL METHOD CL_GUI_FRONTEND_SERVICES=>FILE_OPEN_DIALOG
    CHANGING
      FILE_TABLE = LT_FILE_TABLE
      RC              = LV_RC
      USER_ACTION  = LV_USER_ACTION
    EXCEPTIONS
      FILE_OPEN_DIALOG_FAILED = 1
      CNTL_ERROR              = 2
      ERROR_NO_GUI            = 3
      NOT_SUPPORTED_BY_GUI    = 4
      OTHERS                  = 5.

  IF SY-SUBRC <> 0 OR LV_USER_ACTION = CL_GUI_FRONTEND_SERVICES=>ACTION_CANCEL..
     MESSAGE S023 DISPLAY LIKE GC_E. EXIT.
  ENDIF.

  CHECK LT_FILE_TABLE[] IS NOT INITIAL.

  READ TABLE LT_FILE_TABLE INDEX 1 INTO DATA(LS_FILE).
  LV_FILENAME = LS_FILE-FILENAME.

  DATA:
      LT_ALSM_DATA TYPE TABLE OF ALSMEX_TABLINE,
      LV_MAX_ROW   TYPE I VALUE 1,
      LV_MAX_COL   TYPE I VALUE 1.

" 2. 엑셀 데이터 구동
  CALL FUNCTION 'ALSM_EXCEL_TO_INTERNAL_TABLE'
    EXPORTING
      FILENAME              = LV_FILENAME
      I_BEGIN_COL         = PV_BEGIN_COL
      I_BEGIN_ROW        = PV_BEGIN_ROW
      I_END_COL            = PV_END_COL        " 최대 열 수 지정
      I_END_ROW           = PV_END_ROW     " 최대 행 수 지정
    TABLES
      INTERN                  = LT_ALSM_DATA
    EXCEPTIONS
      INCONSISTENT_PARAMETERS = 1
      UPLOAD_OLE              = 2
      OTHERS                  = 3.

  IF SY-SUBRC <> 0.
    MESSAGE '엑셀 파일을 읽는 데 실패했습니다. 보안 상태나 엑셀 프로그램을 확인해주세요.' TYPE 'E'.
  ENDIF.

  CHECK LT_ALSM_DATA[] IS NOT INITIAL.

" 3. 기존 <LT_DATA>와 동일한 구조를 동적으로 만들기 위해 최대 크기 측정
  LOOP AT LT_ALSM_DATA INTO DATA(LS_ALSM).
    IF LS_ALSM-ROW > LV_MAX_ROW.
      LV_MAX_ROW = LS_ALSM-ROW.
    ENDIF.
    IF LS_ALSM-COL > LV_MAX_COL.
      LV_MAX_COL = LS_ALSM-COL.
    ENDIF.
  ENDLOOP.

" 4. '문자열 타입의 N개 열'을 가진 가상 구조
  DATA: LT_MOCK_COMPONENTS TYPE CL_ABAP_STRUCTDESCR=>COMPONENT_TABLE.
  DO LV_MAX_COL TIMES.
    APPEND VALUE #(
      NAME = 'COL_' && SY-INDEX
      TYPE = CAST CL_ABAP_DATADESCR( CL_ABAP_TYPEDESCR=>DESCRIBE_BY_NAME( 'STRING' ) )
                               ) TO LT_COMPONENTS.
  ENDDO.

  DATA(LO_STRUC) = CL_ABAP_STRUCTDESCR=>CREATE( LT_COMPONENTS ).
  DATA(LO_TABLE)  = CL_ABAP_TABLEDESCR=>CREATE( LO_STRUC ).

  DATA: LR_DATA TYPE REF TO DATA.
  CREATE DATA LR_DATA TYPE HANDLE LO_TABLE.

  FIELD-SYMBOLS <LT_DATA> TYPE STANDARD TABLE.
  ASSIGN LR_DATA->* TO <LT_DATA>.

" 5. <LT_DATA> 구조 형태로 조립
  DATA: LR_ROW TYPE REF TO DATA.
  CREATE DATA LR_ROW TYPE HANDLE LO_STRUC.
  ASSIGN LR_ROW->* TO FIELD-SYMBOL(<LS_ROW>).

  SORT LT_ALSM_DATA BY ROW COL.

  LOOP AT LT_ALSM_DATA INTO LS_ALSM.
    " 새로운 행이 시작되었는데, 이전 행의 데이터가 채워져 있다면 테이블에 추가
    IF LV_PREV_ROW <> 0 AND LV_PREV_ROW <> LS_ALSM-ROW.
      APPEND <LS_ROW> TO <LT_DATA>.
      CLEAR <LS_ROW>.
    ENDIF.

    LV_PREV_ROW = LS_ALSM-ROW. " 현재 행 번호 저장

    " 해당 행의 해당하는 컬럼 위치에 값을 매핑
    ASSIGN COMPONENT LS_ALSM-COL OF STRUCTURE <LS_ROW> TO FIELD-SYMBOL(<LV_CELL>).
    IF SY-SUBRC = 0.
      <LV_CELL> = LS_ALSM-VALUE.
    ENDIF.
  ENDLOOP.

  " LOOP가 종료된 후, 아직 적재되지 않은 마지막 행 데이터를 마저 추가합니다.
  IF LV_PREV_ROW <> 0.
    APPEND <LS_ROW> TO <LT_DATA>.
  ENDIF.

"헤더의 필드명과 필드타입 설정.
  DATA(LO_TABLE_DESC) = CAST CL_ABAP_TABLEDESCR( CL_ABAP_TYPEDESCR=>DESCRIBE_BY_DATA( CT_XLS ) ).
  DATA(LO_STRUC_DESC) = CAST CL_ABAP_STRUCTDESCR( LO_TABLE_DESC->GET_TABLE_LINE_TYPE( ) ).

  READ TABLE <LT_DATA> INDEX 1 ASSIGNING FIELD-SYMBOL(<LS_HD_ROW>).
  IF SY-SUBRC = 0.
    DO.
      ASSIGN COMPONENT SY-INDEX OF STRUCTURE <LS_HD_ROW> TO FIELD-SYMBOL(<LV_HD_VAL>).
      IF SY-SUBRC <> 0. EXIT. ENDIF.

*GT_FCAT에서 REPTEXT 비교하여 필드 정보 찾기(업로드양식의 필드명은 한글-필드캣의 REPTEXT임)
      READ TABLE GT_FCAT INTO DATA(LS_FCAT) WITH KEY REPTEXT = <LV_HD_VAL>.
      IF SY-SUBRC = 0.
        DATA(LO_COMP_DESC) = LO_STRUC_DESC->GET_COMPONENT_TYPE( LS_FCAT-FIELDNAME ).
      " TY_LIST 구조체에서 해당 필드의 원본 타입 정보를 가져와 컴포넌트 추가
        APPEND VALUE #( NAME = LS_FCAT-FIELDNAME
                                     TYPE = LO_COMP_DESC
                                   ) TO LT_NEW_COMPONENTS.
      ENDIF.
    ENDDO.
  ENDIF.

*5. 엑셀 컬럼 구성에 맞는 설계도(RTTS) 생성 (업로드 구조체)
  CHECK LT_NEW_COMPONENTS IS NOT INITIAL.

  DATA(LO_NEW_STRUCT) = CL_ABAP_STRUCTDESCR=>CREATE( LT_NEW_COMPONENTS ).
*  DATA(LO_NEW_TABLE) = CL_ABAP_TABLEDESCR=>CREATE( LO_NEW_STRUCT ).
  "동적 ITAB의 구조와 동일한 신규 WORK AREA 생성
  DATA: LR_WA TYPE REF TO DATA.
  CREATE DATA LR_WA TYPE HANDLE LO_NEW_STRUCT.
  ASSIGN LR_WA->* TO FIELD-SYMBOL(<LS_WA>).

**6. 실제 ITAB 메모리 할당
  DATA: LR_TARGET_ROW TYPE REF TO DATA.

  CREATE DATA LR_TARGET_ROW TYPE HANDLE LO_STRUC_DESC.
  ASSIGN LR_TARGET_ROW->* TO FIELD-SYMBOL(<LS_TARGET_ROW>).

  DATA:
    LV_FIELD_TYPE  TYPE C,
    LV_CLEAN_VAL  TYPE STRING,
    LV_DUMMY_DEC TYPE P DECIMALS 7.

  LOOP AT <LT_DATA> ASSIGNING <LS_ROW> FROM 2.
    CLEAR: <LS_WA>, <LS_TARGET_ROW>.
" 2행부터 데이터 시작 (1행 헤더 제외)
    DO.
    " 엑셀의 N번째 컬럼 읽기
      ASSIGN COMPONENT SY-INDEX OF STRUCTURE <LS_ROW> TO FIELD-SYMBOL(<LV_EXCEL_VAL>).
      IF SY-SUBRC <> 0. EXIT. ENDIF. " 더 이상 읽을 컬럼이 없으면 종료

    " 대응하는 동적 ITAB 구조체의 N번째 필드에 값 할당
      ASSIGN COMPONENT SY-INDEX OF STRUCTURE <LS_WA> TO FIELD-SYMBOL(<LV_TARGET_FIELD>).
      IF SY-SUBRC = 0.

        DESCRIBE FIELD <LV_TARGET_FIELD> TYPE LV_FIELD_TYPE.
        " P(Packed/DEC), I(Integer), F(Float) 등 숫자형 타입인 경우 데이터 정제
        IF LV_FIELD_TYPE = 'P' OR LV_FIELD_TYPE = 'I' OR LV_FIELD_TYPE = 'F' OR LV_FIELD_TYPE = 'g'.

          LV_CLEAN_VAL = <LV_EXCEL_VAL>.
          CONDENSE LV_CLEAN_VAL NO-GAPS. " 앞뒤 및 내부 공백 제거
          " 엑셀 천 단위 콤마(,) 제거
          REPLACE ALL OCCURRENCES OF ',' IN LV_CLEAN_VAL WITH ''.

          " 만약 빈 값이면 0 세팅
          IF LV_CLEAN_VAL IS INITIAL.
            <LV_TARGET_FIELD> = 0.
          ELSE.
            TRY.
                "DEC타입(P)으로 안전하게 변환하기 위해 임시 변수(LV_DUMMY_DEC) 활용
              LV_DUMMY_DEC = LV_CLEAN_VAL.
              <LV_TARGET_FIELD> = LV_DUMMY_DEC.

              CATCH CX_SY_CONVERSION_NO_NUMBER CX_SY_CONVERSION_OVERFLOW.
                <LV_TARGET_FIELD> = 0.
            ENDTRY.
          ENDIF.

           " 날짜형 타입
        ELSEIF LV_FIELD_TYPE = 'D'.

          LV_CLEAN_VAL = <LV_EXCEL_VAL>.
          CONDENSE LV_CLEAN_VAL NO-GAPS.
          REPLACE ALL OCCURRENCES OF '-' IN LV_CLEAN_VAL WITH ''.

          IF LV_CLEAN_VAL IS INITIAL.
            CLEAR <LV_TARGET_FIELD>.
          ELSE.
            TRY.
              <LV_TARGET_FIELD> = LV_CLEAN_VAL.

                CATCH CX_SY_CONVERSION_NO_DATE.
                    CLEAR <LV_TARGET_FIELD>.
            ENDTRY.
          ENDIF.

        ELSE.
          <LV_TARGET_FIELD> = <LV_EXCEL_VAL>.
        ENDIF.

      ENDIF.
    ENDDO.

*완성된 한 줄을 MAIN ITAB에 추가
    MOVE-CORRESPONDING <LS_WA> TO <LS_TARGET_ROW>.
    APPEND <LS_TARGET_ROW> TO CT_XLS.

  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& FORM SET_ALV_DATA_OPT1
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
*&      --> LT_XLS
*&      <-- GT_OPT1
*&      <-- LV_CHECK
*&---------------------------------------------------------------------*
FORM SET_ALV_DATA_OPT1  CHANGING CT_OPT1 LIKE GT_LIST
                                          .
DEFINE _UNIT.
    "단위
    CALL FUNCTION 'CONVERSION_EXIT_CUNIT_INPUT'
      EXPORTING
        INPUT  = &1 "LS_OPT1-MEINS
      IMPORTING
        OUTPUT = &1 "LS_OPT1-MEINS
        .
END-OF-DEFINITION.
DEFINE _MATN1.
    "자재코드
    CALL FUNCTION 'CONVERSION_EXIT_MATN1_INPUT'
      EXPORTING
        INPUT  = &1 "LS_OPT1-MATNR
      IMPORTING
        OUTPUT = &1 "LS_OPT1-MATNR
        .
END-OF-DEFINITION.
DEFINE _CURRENCY.
      CLEAR:
       LV_AMT_EXT,
       LV_AMT_INT.

      "금액 변환(EXT - > INT)
      LV_AMT_EXT = &1. "LS_OPT1-CU_LMC.
      CALL FUNCTION 'BAPI_CURRENCY_CONV_TO_INTERNAL'
        EXPORTING
          CURRENCY                      = &2 "LS_OPT1-KWAERS
          AMOUNT_EXTERNAL        = LV_AMT_EXT
          MAX_NUMBER_OF_DIGITS = 23
        IMPORTING
          AMOUNT_INTERNAL          = LV_AMT_INT.

      &1 = LV_AMT_INT.

END-OF-DEFINITION.



  "초기화
  CLEAR:
    GV_ERR.

  DATA:
    LT_FNAME     TYPE TY_T_FNAME,
    LS_OPT1        LIKE GS_LIST,
    LV_AMT_EXT TYPE BAPICURR-BAPICURR,
    LV_AMT_INT  TYPE MATDOC-DMBTR.

  LOOP AT CT_OPT1 ASSIGNING FIELD-SYMBOL(<LS_XLS>).
    CLEAR LS_OPT1.
    "대문자 변경
    TRANSLATE:
      <LS_XLS>-MATNR TO UPPER CASE,
      <LS_XLS>-WERKS TO UPPER CASE,
      <LS_XLS>-EKORG TO UPPER CASE,
      <LS_XLS>-LIFNR TO UPPER CASE,
      <LS_XLS>-KWAERS TO UPPER CASE,
      <LS_XLS>-FWAERS TO UPPER CASE.

##REGEX_POSIX
*    <LS_XLS>-CU_KGW = CONDENSE( VAL = REPLACE( VAL = <LS_XLS>-CU_KGW REGEX = '[^0-9.]' WITH = '' OCC = 0 ) ).
*    <LS_XLS>-CU_KGU = CONDENSE( VAL = REPLACE( VAL = <LS_XLS>-CU_KGU REGEX = '[^0-9.]' WITH = '' OCC = 0 ) ).
*    <LS_XLS>-CU_PREMIUM = CONDENSE( VAL = REPLACE( VAL = <LS_XLS>-CU_PREMIUM REGEX = '[^0-9.]' WITH = '' OCC = 0 ) ).
*    <LS_XLS>-CU_MCOST = CONDENSE( VAL = REPLACE( VAL = <LS_XLS>-CU_MCOST REGEX = '[^0-9.]' WITH = '' OCC = 0 ) ).
*    <LS_XLS>-CU_PER = CONDENSE( VAL = REPLACE( VAL = <LS_XLS>-CU_PER REGEX = '[^0-9.]' WITH = '' OCC = 0 ) ).
*    <LS_XLS>-CU_PRICE = CONDENSE( VAL = REPLACE( VAL = <LS_XLS>-CU_PRICE REGEX = '[^0-9.]' WITH = '' OCC = 0 ) ).
*    <LS_XLS>-CU_LMEPER = CONDENSE( VAL = REPLACE( VAL = <LS_XLS>-CU_LMEPER REGEX = '[^0-9.]' WITH = '' OCC = 0 ) ).
*    <LS_XLS>-CU_SLMC = CONDENSE( VAL = REPLACE( VAL = <LS_XLS>-CU_SLMC REGEX = '[^0-9.]' WITH = '' OCC = 0 ) ).
*    <LS_XLS>-CU_LMC = CONDENSE( VAL = REPLACE( VAL = <LS_XLS>-CU_LMC REGEX = '[^0-9.]' WITH = '' OCC = 0 ) ).
*    <LS_XLS>-SCR_SC = CONDENSE( VAL = REPLACE( VAL = <LS_XLS>-SCR_SC REGEX = '[^0-9.]' WITH = '' OCC = 0 ) ).
*    <LS_XLS>-AL_KGW = CONDENSE( VAL = REPLACE( VAL = <LS_XLS>-AL_KGW REGEX = '[^0-9.]' WITH = '' OCC = 0 ) ).
*    <LS_XLS>-AL_KGU = CONDENSE( VAL = REPLACE( VAL = <LS_XLS>-AL_KGU REGEX = '[^0-9.]' WITH = '' OCC = 0 ) ).
*    <LS_XLS>-AL_PREMIUM = CONDENSE( VAL = REPLACE( VAL = <LS_XLS>-AL_PREMIUM REGEX = '[^0-9.]' WITH = '' OCC = 0 ) ).
*    <LS_XLS>-AL_MCOST = CONDENSE( VAL = REPLACE( VAL = <LS_XLS>-AL_MCOST REGEX = '[^0-9.]' WITH = '' OCC = 0 ) ).
*    <LS_XLS>-AL_PER = CONDENSE( VAL = REPLACE( VAL = <LS_XLS>-AL_PER REGEX = '[^0-9.]' WITH = '' OCC = 0 ) ).
*    <LS_XLS>-AL_PRICE = CONDENSE( VAL = REPLACE( VAL = <LS_XLS>-AL_PRICE REGEX = '[^0-9.]' WITH = '' OCC = 0 ) ).
*    <LS_XLS>-AL_LMEPER = CONDENSE( VAL = REPLACE( VAL = <LS_XLS>-AL_LMEPER REGEX = '[^0-9.]' WITH = '' OCC = 0 ) ).
*    <LS_XLS>-AL_SLMC = CONDENSE( VAL = REPLACE( VAL = <LS_XLS>-AL_SLMC REGEX = '[^0-9.]' WITH = '' OCC = 0 ) ).
*    <LS_XLS>-CU_C_QTY = CONDENSE( VAL = REPLACE( VAL = <LS_XLS>-CU_C_QTY REGEX = '[^0-9.]' WITH = '' OCC = 0 ) ).
*    <LS_XLS>-AL_C_QTY = CONDENSE( VAL = REPLACE( VAL = <LS_XLS>-AL_C_QTY REGEX = '[^0-9.]' WITH = '' OCC = 0 ) ).
*    <LS_XLS>-AL_C_PRICE = CONDENSE( VAL = REPLACE( VAL = <LS_XLS>-AL_C_PRICE REGEX = '[^0-9.]' WITH = '' OCC = 0 ) ).
*    <LS_XLS>-CU_S_QTY = CONDENSE( VAL = REPLACE( VAL = <LS_XLS>-CU_S_QTY REGEX = '[^0-9.]' WITH = '' OCC = 0 ) ).
*    <LS_XLS>-AL_S_QTY = CONDENSE( VAL = REPLACE( VAL = <LS_XLS>-AL_S_QTY REGEX = '[^0-9.]' WITH = '' OCC = 0 ) ).
*    <LS_XLS>-AL_S_PRICE =  CONDENSE( VAL = REPLACE( VAL = <LS_XLS>-AL_S_PRICE REGEX = '[^0-9.]' WITH = '' OCC = 0 ) ).
*    <LS_XLS>-CU_T_QTY = CONDENSE( VAL = REPLACE( VAL = <LS_XLS>-CU_T_QTY REGEX = '[^0-9.]' WITH = '' OCC = 0 ) ).
*    <LS_XLS>-CU_PRICE_TOTAL = CONDENSE( VAL = REPLACE( VAL = <LS_XLS>-CU_PRICE_TOTAL REGEX = '[^0-9.]' WITH = '' OCC = 0 ) ).
*    <LS_XLS>-AL_PRICE_TOTAL = CONDENSE( VAL = REPLACE( VAL = <LS_XLS>-AL_PRICE_TOTAL REGEX = '[^0-9.]' WITH = '' OCC = 0 ) ).
*    <LS_XLS>-S_MAT_COST = CONDENSE( VAL = REPLACE( VAL = <LS_XLS>-S_MAT_COST REGEX = '[^0-9.]' WITH = '' OCC = 0 ) ).
*    <LS_XLS>-MFG_COST = CONDENSE( VAL = REPLACE( VAL = <LS_XLS>-MFG_COST REGEX = '[^0-9.]' WITH = '' OCC = 0 ) ).
*    <LS_XLS>-PKG_COST =  CONDENSE( VAL = REPLACE( VAL = <LS_XLS>-PKG_COST REGEX = '[^0-9.]' WITH = '' OCC = 0 ) ).
*    <LS_XLS>-SUB_PRICE_TOTAL = CONDENSE( VAL = REPLACE( VAL = <LS_XLS>-SUB_PRICE_TOTAL REGEX = '[^0-9.]' WITH = '' OCC = 0 ) ).
*    <LS_XLS>-ETC_COST = CONDENSE( VAL = REPLACE( VAL = <LS_XLS>-ETC_COST REGEX = '[^0-9.]' WITH = '' OCC = 0 ) ).
*    <LS_XLS>-OEM_PRICE = CONDENSE( VAL = REPLACE( VAL = <LS_XLS>-OEM_PRICE REGEX = '[^0-9.]' WITH = '' OCC = 0 ) ).
*    <LS_XLS>-DIS_PRICE = CONDENSE( VAL = REPLACE( VAL = <LS_XLS>-DIS_PRICE REGEX = '[^0-9.]' WITH = '' OCC = 0 ) ).
*    <LS_XLS>-AP_PRICE = CONDENSE( VAL = REPLACE( VAL = <LS_XLS>-AP_PRICE REGEX = '[^0-9.]' WITH = '' OCC = 0 ) ).
*    <LS_XLS>-KBETR = CONDENSE( VAL = REPLACE( VAL = <LS_XLS>-KBETR REGEX = '[^0-9.]' WITH = '' OCC = 0 ) ).
*    <LS_XLS>-KPEIN = CONDENSE( VAL = REPLACE( VAL = <LS_XLS>-KPEIN REGEX = '[^0-9.]' WITH = '' OCC = 0 ) ).
*    <LS_XLS>-LAST_PO_DATE = CONDENSE( VAL = REPLACE( VAL = <LS_XLS>-LAST_PO_DATE REGEX = '[^0-9.]' WITH = '' OCC = 0 ) ).
*    <LS_XLS>-ERDAT = CONDENSE( VAL = REPLACE( VAL = <LS_XLS>-ERDAT REGEX = '[^0-9.]' WITH = '' OCC = 0 ) ).
*    <LS_XLS>-ERDAT_LOCAL = CONDENSE( VAL = REPLACE( VAL = <LS_XLS>-ERDAT_LOCAL REGEX = '[^0-9.]' WITH = '' OCC = 0 ) ).
*    <LS_XLS>-AEDAT = CONDENSE( VAL = REPLACE( VAL = <LS_XLS>-AEDAT REGEX = '[^0-9.]' WITH = '' OCC = 0 ) ).
*    <LS_XLS>-AEDAT_LOCAL = CONDENSE( VAL = REPLACE( VAL = <LS_XLS>-AEDAT_LOCAL REGEX = '[^0-9.]' WITH = '' OCC = 0 ) )..

**    "공백 제거
**    CONDENSE:
**      <LS_XLS>-CU_KGW, <LS_XLS>-CU_KGU, <LS_XLS>-CU_PREMIUM,
**      <LS_XLS>-CU_MCOST, <LS_XLS>-CU_PER, <LS_XLS>-CU_PRICE,
**      <LS_XLS>-CU_LMEPER, <LS_XLS>-CU_SLMC, <LS_XLS>-CU_LMC,
**      <LS_XLS>-SCR_SC, <LS_XLS>-AL_KGW, <LS_XLS>-AL_KGU,
**      <LS_XLS>-AL_PREMIUM,
**      <LS_XLS>-AL_MCOST, <LS_XLS>-AL_PER, <LS_XLS>-AL_PRICE,
**      <LS_XLS>-AL_LMEPER, <LS_XLS>-AL_SLMC, <LS_XLS>-CU_C_QTY,
**      <LS_XLS>-AL_C_QTY, <LS_XLS>-AL_C_PRICE, <LS_XLS>-CU_S_QTY,
**      <LS_XLS>-AL_S_QTY, <LS_XLS>-AL_S_PRICE, <LS_XLS>-CU_T_QTY,
**      <LS_XLS>-CU_PRICE_TOTAL, <LS_XLS>-AL_PRICE_TOTAL, <LS_XLS>-S_MAT_COST,
**      <LS_XLS>-MFG_COST, <LS_XLS>-PKG_COST, <LS_XLS>-SUB_PRICE_TOTAL,
**      <LS_XLS>-ETC_COST, <LS_XLS>-OEM_PRICE, <LS_XLS>-DIS_PRICE, <LS_XLS>-AP_PRICE,
**      <LS_XLS>-KBETR, <LS_XLS>-KPEIN, <LS_XLS>-LAST_PO_DATE, <LS_XLS>-ERDAT,
**      <LS_XLS>-ERDAT_LOCAL, <LS_XLS>-AEDAT, <LS_XLS>-AEDAT_LOCAL NO-GAPS.

    "값 설정
    LS_OPT1 = CORRESPONDING #( BASE ( LS_OPT1 )  <LS_XLS> ).

    "ALPHA CONVERSION
    LS_OPT1-LIFNR = |{ LS_OPT1-LIFNR ALPHA = IN }|.

    "단위
    _UNIT LS_OPT1-MEINS.

    "자재코드
    _MATN1 LS_OPT1-MATNR.

    "통화 기본값(엑셀에 통화가 없으면 뷰 기준 KRW/USD) - 금액환산 전에 확정해야 KRW 100배 표시 방지
    IF LS_OPT1-KWAERS IS INITIAL.
      LS_OPT1-KWAERS = 'KRW'.
    ENDIF.
    IF LS_OPT1-FWAERS IS INITIAL.
      LS_OPT1-FWAERS = 'USD'.
    ENDIF.

    "금액환산
    _CURRENCY LS_OPT1-CU_SLMC LS_OPT1-KWAERS.
    _CURRENCY LS_OPT1-CU_LMC LS_OPT1-KWAERS.
    _CURRENCY LS_OPT1-SCR_SC LS_OPT1-KWAERS.
    _CURRENCY LS_OPT1-AL_SLMC LS_OPT1-KWAERS.
    _CURRENCY LS_OPT1-AL_C_PRICE LS_OPT1-KWAERS.
    _CURRENCY LS_OPT1-CU_PRICE_TOTAL LS_OPT1-KWAERS.
    _CURRENCY LS_OPT1-AL_PRICE_TOTAL LS_OPT1-KWAERS.
    _CURRENCY LS_OPT1-S_MAT_COST LS_OPT1-KWAERS.
    _CURRENCY LS_OPT1-MFG_COST LS_OPT1-KWAERS.
    _CURRENCY LS_OPT1-PKG_COST LS_OPT1-KWAERS.
    _CURRENCY LS_OPT1-SUB_PRICE_TOTAL LS_OPT1-KWAERS.
    _CURRENCY LS_OPT1-ETC_COST LS_OPT1-KWAERS.
    _CURRENCY LS_OPT1-ADD_COST LS_OPT1-KWAERS.
    _CURRENCY LS_OPT1-OEM_PRICE LS_OPT1-KWAERS.
    _CURRENCY LS_OPT1-DIS_PRICE LS_OPT1-KWAERS.
    _CURRENCY LS_OPT1-AP_PRICE LS_OPT1-KWAERS.
    _CURRENCY LS_OPT1-KBETR LS_OPT1-KWAERS.
    _CURRENCY LS_OPT1-AL_PREMIUM LS_OPT1-AL_PERMIUM_WAERS.

      MODIFY CT_OPT1 FROM LS_OPT1.
  ENDLOOP.

  CHECK CT_OPT1[] IS NOT INITIAL. "데이터가 있으면 진행


*  SELECT FROM ZGTMM_CV_GET_OEM_CAL_SCHMA AS MA
*    FIELDS *
*##ITAB_KEY_IN_SELECT
*    WHERE EXISTS (
*      SELECT ZZ~MATNR
*        FROM @CT_OPT1 AS ZZ
*        WHERE ZZ~MATNR EQ MA~MATNR
*    )
*    AND EKORG EQ @P_EKORG
*    AND WERKS EQ @P_WERKS
*    AND PERIOD EQ @GV_SPMON
*    INTO TABLE @DATA(LT_LIST).
*
*    IF LT_LIST IS INITIAL.
*      SELECT FROM ZGTMM_CV_GET_OEM_CAL_RAW2( p_datE = @P_BUDAT, P_MON = @GV_SPMON ) AS RAW
*      FIELDS *
*##ITAB_KEY_IN_SELECT
*      WHERE EXISTS (
*        SELECT ZZ~MATNR
*        FROM @CT_OPT1 AS ZZ
*        WHERE ZZ~MATNR EQ RAW~MATNR
*         )
*        AND EKORG EQ @P_EKORG
*        AND WERKS EQ @P_WERKS
*        INTO CORRESPONDING FIELDS OF TABLE @LT_LIST.
*    ENDIF.


      SELECT FROM ZGTMM_CV_GET_OEM_CAL_RAW2( p_datE = @P_BUDAT, P_MON = @GV_SPMON ) AS RAW
      FIELDS *
##ITAB_KEY_IN_SELECT
      WHERE EXISTS (
        SELECT ZZ~MATNR
        FROM @CT_OPT1 AS ZZ
        WHERE ZZ~MATNR EQ RAW~MATNR
         )
        AND EKORG EQ @P_EKORG
        AND WERKS EQ @P_WERKS
        INTO TABLE @DATA(LT_LIST).


    SORT LT_LIST BY EKORG MATNR.


  SELECT
    MR~MATNR,
    MR~MEINS,
    MR~ZZMAKTX80,
    MT~MAKTX
    FROM MARA AS MR
    LEFT OUTER JOIN  MAKT AS MT
    ON MR~MATNR EQ MT~MATNR
    AND MT~SPRAS EQ @SY-LANGU
##ITAB_KEY_IN_SELECT
    WHERE EXISTS (
      SELECT ZZ~MATNR
        FROM @CT_OPT1 AS ZZ
        WHERE ZZ~MATNR EQ MR~MATNR
    )
    ORDER BY MR~MATNR
    INTO TABLE @DATA(LT_MARA).

  SELECT
    MC~MATNR,
    MC~WERKS
    FROM MARC AS MC
##ITAB_KEY_IN_SELECT
    WHERE EXISTS (
      SELECT ZZ~MATNR
        FROM @CT_OPT1 AS ZZ
        WHERE ZZ~MATNR EQ MC~MATNR
             AND ZZ~WERKS EQ MC~WERKS
    )
    ORDER BY MC~MATNR, MC~WERKS
    INTO TABLE @DATA(LT_MARC).

*  "구매조직
  READ TABLE GT_T024E ASSIGNING FIELD-SYMBOL(<LS_T024E>)
  WITH TABLE KEY EKORG = P_EKORG.

  LOOP AT CT_OPT1 ASSIGNING FIELD-SYMBOL(<LS_OPT1>).

    <LS_OPT1>-EKORG = P_EKORG.
    IF <LS_T024E> IS ASSIGNED.
      <LS_OPT1>-EKORG_N = <LS_T024E>-EKOTX.
    ENDIF.

    IF <LS_OPT1>-MATNR IS NOT INITIAL.
      READ TABLE LT_MARA ASSIGNING FIELD-SYMBOL(<LS_MARA>) WITH KEY MATNR = <LS_OPT1>-MATNR BINARY SEARCH.
      IF SY-SUBRC EQ 0.
        <LS_OPT1>-MATNR_N = COND #( WHEN <LS_MARA>-ZZMAKTX80 IS INITIAL THEN <LS_MARA>-MAKTX
                                                             ELSE <LS_MARA>-ZZMAKTX80 ).
      ENDIF.

      READ TABLE LT_LIST ASSIGNING FIELD-SYMBOL(<LIST>)
      WITH KEY EKORG = P_EKORG
                     MATNR = <LS_OPT1>-MATNR BINARY SEARCH.
      IF SY-SUBRC = 0.
         <LS_OPT1>-LIFNR = COND #( WHEN <LS_OPT1>-LIFNR IS INITIAL THEN <LIST>-LIFNR ELSE <LS_OPT1>-LIFNR ).
         <LS_OPT1>-LIFNR_N = COND #( WHEN <LS_OPT1>-LIFNR_N IS INITIAL THEN <LIST>-LIFNR_N ELSE <LS_OPT1>-LIFNR_N ).
         <LS_OPT1>-WERKS = COND #( WHEN <LS_OPT1>-WERKS IS INITIAL THEN <LIST>-WERKS ELSE <LS_OPT1>-WERKS ).

         READ TABLE GT_T001W ASSIGNING FIELD-SYMBOL(<LS_T001W>)
         WITH TABLE KEY WERKS = <LS_OPT1>-WERKS.
         IF <LS_T001W> IS ASSIGNED.
           <LS_OPT1>-WERKS_N = <LS_T001W>-NAME1.
         ENDIF.

         <LS_OPT1>-FWAERS = COND #( WHEN <LS_OPT1>-FWAERS IS INITIAL THEN <LIST>-FWAERS ELSE <LS_OPT1>-FWAERS ).
         <LS_OPT1>-KWAERS = COND #( WHEN <LS_OPT1>-KWAERS IS INITIAL THEN <LIST>-KWAERS ELSE <LS_OPT1>-KWAERS ).
         <LS_OPT1>-ESOKZ = COND #( WHEN <LS_OPT1>-ESOKZ IS INITIAL THEN <LIST>-ESOKZ ELSE <LS_OPT1>-ESOKZ ).
*         <LS_OPT1>-PERIOD = COND #( WHEN <LS_OPT1>-PERIOD IS INITIAL THEN <LIST>-PERIOD ELSE <LS_OPT1>-PERIOD ).
         <LS_OPT1>-CLOSING = COND #( WHEN <LS_OPT1>-CLOSING IS INITIAL THEN <LIST>-CLOSING ELSE <LS_OPT1>-CLOSING ).

*엑셀에 CU 비철 정보가 없으면(비철유형/중량 공란) 마스터 기준 RAW2 값으로 보강. 금액 계산 필드(SCR·동가·소요량)는 변경하지 않음.
         IF <LS_OPT1>-CU_NES IS INITIAL AND <LS_OPT1>-CU_KGW IS INITIAL AND <LIST>-CU_KGW > 0.
           <LS_OPT1>-CU_NES           = <LIST>-CU_NES.
           <LS_OPT1>-CU_KGW           = <LIST>-CU_KGW.
           <LS_OPT1>-CU_BME           = <LIST>-CU_BME.
           <LS_OPT1>-CU_KGU           = <LIST>-CU_KGU.
           <LS_OPT1>-CU_PREMIUM       = <LIST>-CU_PREMIUM.
           <LS_OPT1>-CU_PERMIUM_WAERS = <LIST>-CU_PERMIUM_WAERS.
           <LS_OPT1>-CU_CRATE         = <LIST>-CU_CRATE.
           <LS_OPT1>-CU_MCOST         = <LIST>-CU_MCOST.
           <LS_OPT1>-CU_PER           = <LIST>-CU_PER.
           <LS_OPT1>-CU_MUNIT         = <LIST>-CU_MUNIT.
           <LS_OPT1>-CU_MWAERS        = <LIST>-CU_MWAERS.
           <LS_OPT1>-CU_KURST         = <LIST>-CU_KURST.
           <LS_OPT1>-CU_PRICE         = <LIST>-CU_PRICE.
           <LS_OPT1>-CU_LMEPER        = <LIST>-CU_LMEPER.
           <LS_OPT1>-CU_MEINS         = <LIST>-CU_MEINS.
           <LS_OPT1>-CU_SLMC          = <LIST>-CU_SLMC.
         ENDIF.
      ENDIF.

    ENDIF.
*각 총금액 계산
            "CU 총금액_(적용동가+SCR가공비)*(CU 도체+외장+TAPE 소요량)/1000
    <LS_OPT1>-CU_PRICE_TOTAL =  ( <LS_OPT1>-CU_LMC + <LS_OPT1>-SCR_SC ) *
                                                      ( <LS_OPT1>-CU_C_QTY + <LS_OPT1>-CU_S_QTY + <LS_OPT1>-CU_T_QTY ) / 1000 .
            "AL 총금액_(AL도체소요량*단가)+(AL외장소요량*단가)/1000
    <LS_OPT1>-AL_PRICE_TOTAL = ( ( <LS_OPT1>-AL_C_QTY * <LS_OPT1>-AL_C_PRICE ) +
                                                       ( <LS_OPT1>-AL_S_QTY * <LS_OPT1>-AL_S_PRICE ) ) / 1000.
            "재료/가공비 총금액_(부재료비+가공비+포장비+추가비용)
    <LS_OPT1>-SUB_PRICE_TOTAL = <LS_OPT1>-S_MAT_COST + <LS_OPT1>-MFG_COST + <LS_OPT1>-PKG_COST + <LS_OPT1>-ADD_COST.
            "OEM 적용가_(CU 총금액+AL 총금액+재료/가공비 총금액+기타비용)
    <LS_OPT1>-OEM_PRICE = <LS_OPT1>-CU_PRICE_TOTAL + <LS_OPT1>-AL_PRICE_TOTAL + <LS_OPT1>-SUB_PRICE_TOTAL + <LS_OPT1>-ETC_COST.
            "월 정산 대상 금액(미정산수량*OEM 적용가)
    <LS_OPT1>-AP_PRICE = <LS_OPT1>-GR_QTY * <LS_OPT1>-OEM_PRICE.

*INFORECORD
    SELECT SINGLE  A~INFNR
      FROM EINA AS A
      INNER JOIN EINE AS E
        ON A~INFNR = E~INFNR
      WHERE  A~MATNR = @<LS_OPT1>-MATNR
           AND A~LIFNR = @<LS_OPT1>-LIFNR
           AND E~EKORG = @<LS_OPT1>-EKORG
           AND E~WERKS = @<LS_OPT1>-WERKS
           AND E~ESOKZ = 0
      INTO @<LS_OPT1>-INFNR.

*'EINE_LOEKZ_삭제'필드는 체크박스 표기라..업로드 시 한글 등으로 되어 있으면 클리어..
     IF <LS_OPT1>-EINE_LOEKZ IS NOT INITIAL AND <LS_OPT1>-EINE_LOEKZ NE 'X' .
        CLEAR <LS_OPT1>-EINE_LOEKZ.
     ENDIF.

  ENDLOOP.

  CHECK GV_ERR IS INITIAL.
  DESCRIBE TABLE CT_OPT1 LINES DATA(LV_LINES).
  MESSAGE S074 WITH LV_LINES.

ENDFORM.

*&---------------------------------------------------------------------*
*& FORM CREATE_PRICE
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
*& -->  P1        TEXT
*& <--  P2        TEXT
*&---------------------------------------------------------------------*
FORM CREATE_PRICE .

  DATA : LV_MSG TYPE BAPI_MSG.
  CLEAR : GV_ANSWER, GV_ERR, GS_ROW.

  PERFORM GET_SELECTED_ROWS USING GCL_GRID.
  CHECK GV_ERR IS INITIAL.

  LOOP AT GT_ROWS INTO GS_ROW.
    READ TABLE GT_LIST  INTO DATA(LS_LIST) INDEX GS_ROW-INDEX.
    IF SY-SUBRC = 0 .

      IF LS_LIST-CLOSING = GC_X.
        GV_ERR = GC_X.
        MESSAGE S000 WITH '마감이 끝난 데이터는 단가 생성을 할 수 없습니다.'(E10)
        DISPLAY LIKE GC_E. EXIT.
      ENDIF.

      IF LS_LIST-OEM_PRICE = 0.
        GV_ERR = GC_X.
        MESSAGE S000 WITH '단가가 계산되지 않은 품목이 존재합니다.'(E11)
        DISPLAY LIKE GC_E. EXIT.
      ENDIF.

    ENDIF.
  ENDLOOP.

  CHECK GV_ERR IS INITIAL.
  LV_MSG = P_BUDAT(4) && '년' && ' ' && P_BUDAT+4(2) && '월'.
  PERFORM POPUP_TO_CONFIRM_STEP USING GC_N
                                                                       LV_MSG "2026년 04월<-조회 조건의 정산기준일(YYYY/MM)
                                                                       TEXT-M13 "월 OEM 단가를 생성 하시겠습니까?
                                                                       TEXT-T04.
  CHECK GV_ANSWER = GC_J.
  DATA :
    LS_EINA  TYPE MEWIEINA,
    LS_EEINA TYPE  MEWIEINA,
    LS_EINAX TYPE  MEWIEINAX,
    LS_EINE  TYPE  MEWIEINE,
    LS_EEINE TYPE	MEWIEINE,
    LS_EINEX TYPE  MEWIEINEX,
    LS_1111 TYPE ZGTMMT1111,
    LS_1110 TYPE ZGTMMT1110.

  DATA:
    COND_VALIDITY TYPE TABLE OF MEWIVALIDITY,
    CONDITION     TYPE TABLE OF MEWICONDITION.

  DATA:
    LT_PRITEM  TYPE TABLE OF BAPIMEREQITEMIMP,
    LT_PRITEMX TYPE TABLE OF BAPIMEREQITEMX,
    LT_1111 TYPE TABLE OF ZGTMMT1111,
    LT_1110 TYPE TABLE OF ZGTMMT1110.

  DATA:
    LS_RETURN TYPE BAPIRET2,
    LT_RETURN LIKE TABLE OF BAPIRET2,
    LT_RTN    LIKE TABLE OF BAPIRETURN,
    LV_VFROM TYPE SY-DATUM,
    LV_VTO TYPE SY-DATUM.

  DATA :
    LV_AMT_EXT TYPE BAPICURR-BAPICURR,
    LV_AMT_INT  TYPE MATDOC-DMBTR,
    LV_PRICE TYPE ZGTMM_CV_GET_OEM_CAL_SCHMA-OEM_PRICE.

  DEFINE _BAPI_CURR.
   CLEAR:
       LV_AMT_EXT,
       LV_AMT_INT.

   LV_AMT_INT = &2.
   CALL FUNCTION 'BAPI_CURRENCY_CONV_TO_EXTERNAL'
     EXPORTING
      CURRENCY                 = &1
      AMOUNT_INTERNAL    = LV_AMT_INT
    IMPORTING
     AMOUNT_EXTERNAL    = LV_AMT_EXT
            .
   &2 = LV_AMT_EXT.
  END-OF-DEFINITION.

  CLEAR GS_ROW.
  LV_VFROM = P_BUDAT(6) && '01'.
  LV_VTO = P_BUDAT.

  LOOP AT GT_ROWS INTO GS_ROW.

      READ TABLE GT_LIST ASSIGNING FIELD-SYMBOL(<FS>) INDEX GS_ROW-INDEX.
      IF SY-SUBRC = 0.
*인포레코드 변경용 데이터 구성 후 ->아래 조건에 따라 처리 구분
        CLEAR: LS_EINA, LS_EINAX, LS_EINE, LS_EINEX, COND_VALIDITY, CONDITION, LT_RTN.

        LS_EINA = VALUE #( MATERIAL = <FS>-MATNR
                                       VENDOR    = <FS>-LIFNR ).

        LS_EINAX = VALUE #( MATERIAL = GC_X
                                          VENDOR   = GC_X ).

        LS_EINE = VALUE #( PURCH_ORG = <FS>-EKORG
                                       PLANT         = <FS>-WERKS
                                       DELETE_IND = <FS>-EINE_LOEKZ
                                       INFO_TYPE  = <FS>-ESOKZ  ).

        LS_EINEX = VALUE #(
                           PURCH_ORG  = COND #( WHEN <FS>-EKORG IS INITIAL THEN SPACE ELSE GC_X )
                           PLANT           = COND #( WHEN <FS>-WERKS IS INITIAL THEN SPACE ELSE GC_X )
                           DELETE_IND  = GC_X
                           INFO_TYPE    = COND #( WHEN <FS>-ESOKZ IS INITIAL THEN SPACE ELSE GC_X ) ).

        APPEND VALUE #( VALID_FROM = LV_VFROM
                                     VALID_TO     = LV_VTO ) TO COND_VALIDITY.

*금액변환
        LV_PRICE = <FS>-OEM_PRICE.
        _BAPI_CURR <FS>-KWAERS LV_PRICE.

        APPEND VALUE #( COND_TYPE    =  'PB00'
                                     COND_VALUE = LV_PRICE "<FS>-OEM_PRICE
                                     CURRENCY     = <FS>-KWAERS
                                     COND_P_UNT = 1
                                     COND_UNIT    = <FS>-KMEIN ) TO CONDITION.

          CALL FUNCTION 'ME_INFORECORD_MAINTAIN'
            EXPORTING
              I_EINA         = LS_EINA
              I_EINAX       = LS_EINAX
              I_EINE         = LS_EINE
              I_EINEX       = LS_EINEX
            IMPORTING
              E_EINA        = LS_EEINA
              E_EINE        = LS_EEINE
            TABLES
              COND_VALIDITY = COND_VALIDITY
              CONDITION        = CONDITION
              RETURN            = LT_RTN.

          IF LINE_EXISTS( LT_RTN[ TYPE = GC_E ] ) OR LS_EEINA-INFO_REC IS INITIAL.
            CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
            READ TABLE LT_RTN INTO DATA(LS_RTN) WITH KEY TYPE = GC_E.

            <FS>-MTYPE     = GC_E.
            <FS>-STATUS = ICON_LED_RED.
            <FS>-MESSAGE = LS_RTN-MESSAGE.

            IF LINES( LT_RTN ) > 1.
              LOOP AT LT_RTN INTO DATA(LS_RETN).
                CLEAR : LS_RETURN.
                CALL FUNCTION 'BALW_RETURN_TO_RET2'
                  EXPORTING
                    RETURN_IN       = LS_RETN
                  IMPORTING
                   RETURN_OU       = LS_RETURN                          .

                APPEND LS_RETURN TO LT_RETURN.
              ENDLOOP.
            ENDIF.
.
            CONTINUE.

          ELSE.
            CHECK LS_EEINA-INFO_REC IS NOT INITIAL.
            CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
              EXPORTING
                WAIT = 'X'.

            <FS>-MTYPE     = GC_S.
            <FS>-STATUS    = ICON_LED_GREEN.
            <FS>-MESSAGE = 'INFO RECORD 단가를 업데이트 했습니다.'(M15).

            CLEAR LS_1111.
            LS_1111 = CORRESPONDING #( <FS> ).
            LS_1111-ERDAT = SY-DATUM.
            LS_1111-ERDAT_LOCAL = SY-DATLO.
            LS_1111-ERTIM = SY-UZEIT.
            LS_1111-ERTIM_LOCAL = SY-TIMLO.
            LS_1111-ERNAM = SY-UNAME.
            APPEND LS_1111 TO LT_1111.

            CLEAR LS_1110.
            LS_1110 = CORRESPONDING #( <FS> ).
            LS_1110-ERDAT = SY-DATUM.
            LS_1110-ERDAT_LOCAL = SY-DATLO.
            LS_1110-ERTIM = SY-UZEIT.
            LS_1110-ERTIM_LOCAL = SY-TIMLO.
            LS_1110-ERNAM = SY-UNAME.
            APPEND LS_1110 TO LT_1110.

          ENDIF.

      ENDIF.
    ENDLOOP.

    IF LT_1111[] IS NOT INITIAL.
*OEM 단가 환산 LOG TABLE(월별) UPDATE
      MODIFY ZGTMMT1111 FROM TABLE LT_1111.
      IF SY-SUBRC = 0.
          COMMIT WORK.
      ENDIF.
    ENDIF.

    IF LT_1110[] IS NOT INITIAL.
*OEM 단가 환산 LOG TABLE(월별) UPDATE
      MODIFY ZGTMMT1110 FROM TABLE LT_1110.
      IF SY-SUBRC = 0.
          COMMIT WORK.
      ENDIF.
    ENDIF.

*TEMPLATE(ZGTMMT1112) 자동 저장 : 단가생성에 성공한 행의 소요량·단가·비용을 다음 조회의 기본값으로 저장한다.
*  - 같은 품목에 더 늦은 정산월 LOG(ZGTMMT1110)가 있으면 과거월 재생성이므로 저장하지 않는다.
*  - AL 단가(도체·외장)가 0이면 기존 TEMPLATE 값을 유지하고, 추가비용은 0도 그대로 저장한다.
*  - 최초 생성 정보는 유지하고 변경 정보만 갱신한다.
    IF LT_1110[] IS NOT INITIAL.
      DATA :
        LT_TEMPLATE TYPE TABLE OF ZGTMMT1112,
        LS_TEMPLATE TYPE ZGTMMT1112.

      SELECT FROM ZGTMMT1110
        FIELDS INFNR, MATNR, LIFNR, EKORG, ESOKZ, WERKS
        FOR ALL ENTRIES IN @LT_1110
        WHERE INFNR  = @LT_1110-INFNR
          AND MATNR  = @LT_1110-MATNR
          AND LIFNR  = @LT_1110-LIFNR
          AND EKORG  = @LT_1110-EKORG
          AND ESOKZ  = @LT_1110-ESOKZ
          AND WERKS  = @LT_1110-WERKS
          AND PERIOD > @LT_1110-PERIOD
        INTO TABLE @DATA(LT_LATER_PERIOD).

      SELECT * FROM ZGTMMT1112
        FOR ALL ENTRIES IN @LT_1110
        WHERE INFNR = @LT_1110-INFNR
          AND MATNR = @LT_1110-MATNR
          AND LIFNR = @LT_1110-LIFNR
          AND EKORG = @LT_1110-EKORG
          AND ESOKZ = @LT_1110-ESOKZ
          AND WERKS = @LT_1110-WERKS
        INTO TABLE @DATA(LT_OLD_TEMPLATE).

      LOOP AT LT_1110 INTO DATA(LS_NEW_LOG).
        READ TABLE LT_LATER_PERIOD TRANSPORTING NO FIELDS
             WITH KEY INFNR = LS_NEW_LOG-INFNR MATNR = LS_NEW_LOG-MATNR
                      LIFNR = LS_NEW_LOG-LIFNR EKORG = LS_NEW_LOG-EKORG
                      ESOKZ = LS_NEW_LOG-ESOKZ WERKS = LS_NEW_LOG-WERKS.
        IF SY-SUBRC = 0.
          CONTINUE.
        ENDIF.

        CLEAR LS_TEMPLATE.
        READ TABLE LT_OLD_TEMPLATE INTO DATA(LS_OLD_TEMPLATE)
             WITH KEY INFNR = LS_NEW_LOG-INFNR MATNR = LS_NEW_LOG-MATNR
                      LIFNR = LS_NEW_LOG-LIFNR EKORG = LS_NEW_LOG-EKORG
                      ESOKZ = LS_NEW_LOG-ESOKZ WERKS = LS_NEW_LOG-WERKS.
        IF SY-SUBRC = 0.
          LS_TEMPLATE = LS_OLD_TEMPLATE.
        ELSE.
          LS_TEMPLATE-ERDAT       = SY-DATUM.
          LS_TEMPLATE-ERDAT_LOCAL = SY-DATLO.
          LS_TEMPLATE-ERTIM       = SY-UZEIT.
          LS_TEMPLATE-ERTIM_LOCAL = SY-TIMLO.
          LS_TEMPLATE-ERNAM       = SY-UNAME.
        ENDIF.

        LS_TEMPLATE-INFNR      = LS_NEW_LOG-INFNR.
        LS_TEMPLATE-MATNR      = LS_NEW_LOG-MATNR.
        LS_TEMPLATE-LIFNR      = LS_NEW_LOG-LIFNR.
        LS_TEMPLATE-EKORG      = LS_NEW_LOG-EKORG.
        LS_TEMPLATE-ESOKZ      = LS_NEW_LOG-ESOKZ.
        LS_TEMPLATE-WERKS      = LS_NEW_LOG-WERKS.
        LS_TEMPLATE-KWAERS     = LS_NEW_LOG-KWAERS.
        LS_TEMPLATE-KGMEINS    = LS_NEW_LOG-KGMEINS.
        LS_TEMPLATE-SCR_SC     = LS_NEW_LOG-SCR_SC.
        LS_TEMPLATE-CU_C_QTY   = LS_NEW_LOG-CU_C_QTY.
        LS_TEMPLATE-AL_C_SPEC  = LS_NEW_LOG-AL_C_SPEC.
        LS_TEMPLATE-AL_C_QTY   = LS_NEW_LOG-AL_C_QTY.
        LS_TEMPLATE-CU_S_QTY   = LS_NEW_LOG-CU_S_QTY.
        LS_TEMPLATE-AL_S_SPEC  = LS_NEW_LOG-AL_S_SPEC.
        LS_TEMPLATE-AL_S_QTY   = LS_NEW_LOG-AL_S_QTY.
        LS_TEMPLATE-CU_T_QTY   = LS_NEW_LOG-CU_T_QTY.
        LS_TEMPLATE-S_MAT_COST = LS_NEW_LOG-S_MAT_COST.
        LS_TEMPLATE-MFG_COST   = LS_NEW_LOG-MFG_COST.
        LS_TEMPLATE-PKG_COST   = LS_NEW_LOG-PKG_COST.
        LS_TEMPLATE-ADD_COST   = LS_NEW_LOG-ADD_COST.
        LS_TEMPLATE-ETC_COST   = LS_NEW_LOG-ETC_COST.
        IF LS_NEW_LOG-AL_C_PRICE <> 0.
          LS_TEMPLATE-AL_C_PRICE = LS_NEW_LOG-AL_C_PRICE.
        ENDIF.
        IF LS_NEW_LOG-AL_S_PRICE <> 0.
          LS_TEMPLATE-AL_S_PRICE = LS_NEW_LOG-AL_S_PRICE.
        ENDIF.

        LS_TEMPLATE-AEDAT       = SY-DATUM.
        LS_TEMPLATE-AEDAT_LOCAL = SY-DATLO.
        LS_TEMPLATE-AETIM       = SY-UZEIT.
        LS_TEMPLATE-AETIM_LOCAL = SY-TIMLO.
        LS_TEMPLATE-AENAM       = SY-UNAME.
        APPEND LS_TEMPLATE TO LT_TEMPLATE.
      ENDLOOP.

      IF LT_TEMPLATE[] IS NOT INITIAL.
        MODIFY ZGTMMT1112 FROM TABLE LT_TEMPLATE.
        IF SY-SUBRC = 0.
          COMMIT WORK.
        ENDIF.
      ENDIF.
    ENDIF.

    IF LT_RETURN[] IS NOT INITIAL.
        CALL FUNCTION 'C14ALD_BAPIRET2_SHOW'
          TABLES
            I_BAPIRET2_TAB = LT_RETURN .
    ENDIF.

ENDFORM.
